#!/usr/bin/env python3
"""Regression tests for scan_vrf_surface.py using only the standard library."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path


SCANNER = Path(__file__).with_name("scan_vrf_surface.py")


SAMPLE = r'''
pragma solidity ^0.8.20;

contract SyntheticVRF is VRFConsumerBaseV2Plus {
    // function retryFromComment() external { requestRandomWords(fake); }
    string constant EXAMPLE = "function fulfillRandomWords() { retry(); }";
    uint64 public lastRequestId;

    function retryDraw() external {
        try coordinator.requestRandomWords(req) returns (uint256 currentChainlinkRequestId) {
            lastRequestId = uint64(currentChainlinkRequestId);
        } catch {}
    }

    function setRandomSource(address source) external {}
    function claimPrize() external {}

    function fulfillRandomWords(uint256 requestId, uint256[] calldata words) internal override {
        require(words.length > 0);
        bytes32 outcome = bytes32(abi.encodePacked(words, requestId));
        uint256 winner = words[0] % players.length;
        uint256 bucket = words[0] % 10;
        for (uint256 i; i < players.length; ++i) {
            receiver.onResult(outcome, winner);
            payable(players[i]).call{value: 1}("");
        }
    }

    function weakFallback() external view returns (uint256) {
        return uint256(block.prevrandao) ^ block.timestamp;
    }
}
'''

PYTH_SAMPLE = r'''
contract PythConsumer is IEntropyConsumer {
    function requestRandomNumber() external payable {
        uint64 sequenceNumber = entropy.requestV2{value: fee}();
    }

    function entropyCallback(
        uint64 sequenceNumber,
        address provider,
        bytes32 randomNumber
    ) internal override {
        results[sequenceNumber] = randomNumber;
    }
}
'''


def main() -> int:
    completed = subprocess.run(
        [sys.executable, str(SCANNER), "-"],
        input=SAMPLE,
        text=True,
        capture_output=True,
        check=True,
    )
    report = json.loads(completed.stdout)
    categories = report["categories"]

    assert report["schema_version"] == 7
    assert report["files_discovered"] == 1
    assert report["files_scanned"] == 1
    assert report["input_errors"] == []
    assert len(categories["request_surfaces"]) == 1, categories["request_surfaces"]
    assert len(categories["fulfillment"]) == 1, categories["fulfillment"]
    assert len(categories["retry_cancel_recovery"]) == 1, categories["retry_cancel_recovery"]
    assert categories["narrowing_cues"], "request ID narrowing was not detected"
    assert categories["randomness_mapping"], "randomness mapping was not detected"
    assert any("% 10" in hit["snippet"] for hit in categories["randomness_mapping"]), (
        "numeric-literal modulo was not detected"
    )
    assert categories["fallback_randomness"], "fallback/source changes were not detected"
    assert categories["try_catch_surfaces"], "try/catch was not detected"
    assert categories["settlement_claim_cues"], "claim surface was not detected"
    assert categories["governance_migration_cues"], "source setter was not detected"

    assert len(report["callback_regions"]) == 1
    risks = {item["kind"] for item in report["callback_regions"][0]["risk_cues"]}
    assert {"dynamic_length", "explicit_revert", "external_call", "loop", "member_call"} <= risks

    pyth_completed = subprocess.run(
        [sys.executable, str(SCANNER), "-"],
        input=PYTH_SAMPLE,
        text=True,
        capture_output=True,
        check=True,
    )
    pyth_report = json.loads(pyth_completed.stdout)
    assert pyth_report["categories"]["provider_markers"]
    assert len(pyth_report["categories"]["request_surfaces"]) == 2
    assert len(pyth_report["callback_regions"]) == 1
    assert pyth_report["callback_regions"][0]["function"] == "entropyCallback"

    with tempfile.TemporaryDirectory() as temporary_directory:
        missing = Path(temporary_directory) / "missing"
        valid = Path(temporary_directory) / "Fixture.sol"
        valid.write_text(SAMPLE, encoding="utf-8")
        missing_completed = subprocess.run(
            [sys.executable, str(SCANNER), str(missing)],
            text=True,
            capture_output=True,
            check=False,
        )
        missing_report = json.loads(missing_completed.stdout)
        assert missing_completed.returncode == 2
        assert missing_report["files_scanned"] == 0
        assert missing_report["input_errors"]

        partial_completed = subprocess.run(
            [sys.executable, str(SCANNER), str(valid), str(missing)],
            text=True,
            capture_output=True,
            check=False,
        )
        partial_report = json.loads(partial_completed.stdout)
        assert partial_completed.returncode == 2
        assert partial_report["files_scanned"] == 1
        assert partial_report["input_errors"]

        with tempfile.TemporaryDirectory() as empty_directory:
            empty_completed = subprocess.run(
                [sys.executable, str(SCANNER), empty_directory],
                text=True,
                capture_output=True,
                check=False,
            )
            empty_report = json.loads(empty_completed.stdout)
            assert empty_completed.returncode == 2
            assert empty_report["files_scanned"] == 0
            assert empty_report["input_errors"]

    print("scan_vrf_surface regression tests passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
