#!/usr/bin/env python3
"""Produce a deterministic VRF audit surface map from Solidity source.

This scanner emits evidence locations, not vulnerability verdicts. It uses only the
Python standard library and intentionally favors transparent regex cues over a
pretend Solidity parser.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Iterable


EXCLUDED_DIRS = {".git", "artifacts", "cache", "lib", "node_modules", "out", "vendor"}

PATTERNS = {
    "provider_markers": re.compile(
        r"VRFConsumerBase|VRFConsumerBaseV2|VRFConsumerBaseV2Plus|"
        r"VRFV2WrapperConsumerBase|VRFV2PlusWrapperConsumerBase|"
        r"VRFCoordinator|IVRFCoordinator|VRFV2PlusClient|"
        r"IEntropyConsumer|\bEntropy\b|ISupraRouter|SupraRouter"
    ),
    "request_surfaces": re.compile(
        r"\b(?:requestRandom(?:Words?|ness|Numbers?)\w*|generateRequest|requestV2)\s*"
        r"(?:\{[^}]*\})?\s*\("
    ),
    "fulfillment": re.compile(
        r"\b(?:(?:rawFulfill|fulfill)Random(?:Words?|ness|Numbers?)|"
        r"entropyCallback|generateRngCallback)\s*\("
    ),
    "request_binding": re.compile(
        r"\b\w*requestId\w*\b|requestTo|ToRequest|pendingRequest|lastRequest",
        re.IGNORECASE,
    ),
    "retry_cancel_recovery": re.compile(
        r"\b(?:retry|redraw|reroll|reRequest|cancel|expire|timeout|refund|recover|forceResolve)\w*\b",
        re.IGNORECASE,
    ),
    "configuration": re.compile(
        r"callbackGasLimit|requestConfirmations|keyHash|gasLane|subscriptionId|subId|"
        r"setCoordinator|setConfig|nativePayment"
    ),
    "randomness_mapping": re.compile(
        r"\b(?:randomWords?|randomNumber|rngList)\s*\[|\bkeccak256\s*\(|"
        r"\bbytes32\s*\(\s*abi\.encode|%\s*[\w(]"
    ),
    "fallback_randomness": re.compile(
        r"block\.(?:prevrandao|difficulty)|\bblockhash\s*\(|"
        r"\b(?:swap|replace|set|change)\w*(?:Random|Rng|Vrf|Source)\w*\b",
        re.IGNORECASE,
    ),
    "try_catch_surfaces": re.compile(r"\b(?:try|catch)\b"),
    "settlement_claim_cues": re.compile(
        r"\bfunction\s+(?:settle|claim|finalize|resolve|consume|pickWinner|selectWinner|distribute)\w*\b",
        re.IGNORECASE,
    ),
    "governance_migration_cues": re.compile(
        r"\bfunction\s+(?:(?:upgrade|migrate|pause|unpause)\w*|"
        r"set\w*(?:Coordinator|Wrapper|Provider|Source)\w*)\b",
        re.IGNORECASE,
    ),
    "input_mutator_cues": re.compile(
        r"\bfunction\s+(?:enter|join|bet|deposit|mint|stake|addPlayer|setWeight|setOdds|setPrize)\w*\b",
        re.IGNORECASE,
    ),
    "narrowing_cues": re.compile(
        r"uint(?:8|16|24|32|40|48|56|64|72|80|88|96|104|112|120|128|136|144|152|160|168|176|184|192|200|208|216|224|232|240|248)\s+"
        r"(?:(?:public|private|internal|immutable|constant)\s+)*\w*[Rr]equest\w*|"
        r"uint(?:8|16|24|32|40|48|56|64|72|80|88|96|104|112|120|128|136|144|152|160|168|176|184|192|200|208|216|224|232|240|248)\s*\(\s*\w*[Rr]equest\w*\s*\)"
    ),
}

CALLBACK_RISK_PATTERNS = {
    "external_call": re.compile(
        r"\.call\s*(?:\{[^}]*\})?\s*\(|\.delegatecall\s*\(|\.staticcall\s*\(|\.transfer\s*\(|"
        r"\.send\s*\(|safeTransfer|safeMint|transferFrom|swap\w*\s*\("
    ),
    "member_call": re.compile(r"\.\s*[A-Za-z_]\w*\s*(?:\{[^}]*\})?\s*\("),
    "loop": re.compile(r"\b(?:for|while)\s*\("),
    "explicit_revert": re.compile(r"\brequire\s*\(|\brevert\b|\bassert\s*\("),
    "dynamic_length": re.compile(r"\.length\b"),
}


def mask_non_code(text: str) -> str:
    """Mask comments and quoted strings while preserving offsets and newlines."""
    chars = list(text)
    index = 0
    while index < len(chars):
        if chars[index] == "/" and index + 1 < len(chars) and chars[index + 1] == "/":
            chars[index] = chars[index + 1] = " "
            index += 2
            while index < len(chars) and chars[index] != "\n":
                chars[index] = " "
                index += 1
            continue
        if chars[index] == "/" and index + 1 < len(chars) and chars[index + 1] == "*":
            chars[index] = chars[index + 1] = " "
            index += 2
            while index + 1 < len(chars) and not (chars[index] == "*" and chars[index + 1] == "/"):
                if chars[index] != "\n":
                    chars[index] = " "
                index += 1
            if index + 1 < len(chars):
                chars[index] = chars[index + 1] = " "
                index += 2
            continue
        if chars[index] in {'"', "'"}:
            quote = chars[index]
            chars[index] = " "
            index += 1
            escaped = False
            while index < len(chars):
                current = chars[index]
                if current == "\n" and not escaped:
                    break
                chars[index] = " " if current != "\n" else current
                if current == quote and not escaped:
                    index += 1
                    break
                escaped = current == "\\" and not escaped
                if current != "\\":
                    escaped = False
                index += 1
            continue
        index += 1
    return "".join(chars)


def solidity_files(inputs: Iterable[str]) -> tuple[list[Path], list[dict[str, str]]]:
    files: set[Path] = set()
    errors: list[dict[str, str]] = []
    for raw in inputs:
        if raw == "-":
            files.add(Path("-"))
            continue
        path = Path(raw)
        if path.is_file():
            files.add(path.resolve())
            continue
        if not path.exists():
            errors.append({"input": raw, "error": "path does not exist"})
            continue
        if not path.is_dir():
            errors.append({"input": raw, "error": "input is neither a file nor a directory"})
            continue
        discovered = 0
        for candidate in path.rglob("*.sol"):
            relative_directories = candidate.relative_to(path).parts[:-1]
            if not any(part in EXCLUDED_DIRS for part in relative_directories):
                files.add(candidate.resolve())
                discovered += 1
        if discovered == 0:
            errors.append({"input": raw, "error": "no Solidity files found"})
    return sorted(files, key=str), errors


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def compact(line: str, limit: int = 180) -> str:
    value = " ".join(line.strip().split())
    return value if len(value) <= limit else value[: limit - 1] + "…"


def pattern_hits(
    path: Path, code: str, original: str, pattern: re.Pattern[str]
) -> list[dict[str, object]]:
    lines = original.splitlines()
    result = []
    seen: set[int] = set()
    for match in pattern.finditer(code):
        number = line_number(code, match.start())
        if number in seen:
            continue
        seen.add(number)
        result.append({"file": str(path), "line": number, "snippet": compact(lines[number - 1])})
    return result


def function_body(text: str, name_pattern: re.Pattern[str], start: int) -> tuple[int, int] | None:
    match = name_pattern.search(text, start)
    if not match:
        return None
    brace = text.find("{", match.end())
    semicolon = text.find(";", match.end())
    if brace < 0 or (semicolon >= 0 and semicolon < brace):
        return None
    depth = 0
    for index in range(brace, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return brace, index + 1
    return None


def callback_regions(path: Path, original: str, code: str) -> list[dict[str, object]]:
    callback = re.compile(
        r"\bfunction\s+((?:(?:rawFulfill|fulfill)Random(?:Words?|ness|Numbers?)|"
        r"entropyCallback|generateRngCallback))\s*\("
    )
    result = []
    cursor = 0
    while True:
        match = callback.search(code, cursor)
        if not match:
            break
        bounds = function_body(code, callback, match.start())
        if not bounds:
            cursor = match.end()
            continue
        body_start, body_end = bounds
        body = code[body_start:body_end]
        risks = []
        for label, pattern in CALLBACK_RISK_PATTERNS.items():
            for risk in pattern.finditer(body):
                absolute = body_start + risk.start()
                risks.append({"kind": label, "line": line_number(code, absolute)})
        result.append(
            {
                "file": str(path),
                "function": match.group(1),
                "start_line": line_number(code, match.start()),
                "end_line": line_number(code, body_end),
                "risk_cues": sorted(risks, key=lambda item: (int(item["line"]), str(item["kind"]))),
            }
        )
        cursor = body_end
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="+", help="Solidity files/directories, or - for stdin")
    parser.add_argument("--pretty", action="store_true", help="pretty-print JSON")
    args = parser.parse_args()

    files, input_errors = solidity_files(args.paths)
    report: dict[str, object] = {
        "schema_version": 7,
        "limitations": [
            "Regex surface map only; reopen and trace every hit in current source.",
            "A callback risk cue is not a vulnerability verdict.",
            "Absence of a hit does not prove absence of VRF or randomness behavior.",
            "Member-call cues include internal/library calls and require manual classification.",
        ],
        "files_discovered": len(files),
        "files_scanned": 0,
        "input_errors": input_errors,
        "categories": {name: [] for name in PATTERNS},
        "callback_regions": [],
    }

    categories = report["categories"]
    callbacks = report["callback_regions"]
    assert isinstance(categories, dict)
    assert isinstance(callbacks, list)
    assert isinstance(input_errors, list)

    for path in files:
        try:
            text = sys.stdin.read() if path == Path("-") else path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as exc:
            input_errors.append({"input": str(path), "error": f"could not read: {exc}"})
            continue
        if path == Path("-") and not text.strip():
            input_errors.append({"input": "-", "error": "stdin was empty"})
            continue
        report["files_scanned"] = int(report["files_scanned"]) + 1
        code = mask_non_code(text)
        for name, pattern in PATTERNS.items():
            categories[name].extend(pattern_hits(path, code, text, pattern))
        callbacks.extend(callback_regions(path, text, code))

    json.dump(report, sys.stdout, indent=2 if args.pretty else None, sort_keys=True)
    sys.stdout.write("\n")
    return 2 if input_errors or report["files_scanned"] == 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
