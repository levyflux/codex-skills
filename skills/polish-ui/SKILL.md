---
name: polish-ui
description: Art-direct and visually refine distinctive production-quality interfaces through references and screenshot-based iteration. Use when the request explicitly emphasizes visual polish, aesthetic quality, brand character, reference matching, or avoiding generic AI styling. Do not use for ordinary UI implementation, behavior-only changes, or backend work.
---

# Polish UI

Produce a coherent interface with an intentional visual point of view. Treat aesthetics as an evidence loop: establish direction, implement within the product system, inspect the rendered result, and revise.

Do not require another external model. Use project evidence, supplied references, and the available
browser and image capabilities.

## 1. Establish the design contract

Before editing:

1. Read the nearest project instructions.
2. Inspect the current page, neighboring screens, shared components, tokens, fonts, icons, routing, data contracts, and relevant tests.
3. State a compact contract covering:
   - target user and primary task;
   - one intended first-glance focal point;
   - primary and secondary actions;
   - desired character in three concrete adjectives;
   - information density and responsive behavior;
   - facts found in the product versus assumptions;
   - acceptance evidence and non-goals.
4. Preserve established product language. Treat external products as quality references, not templates to copy.

If the user supplied references, extract transferable traits: hierarchy, composition, density, typography, color relationships, imagery, motion, and interaction patterns. State what to borrow and what not to copy.

For substantial greenfield work without a clear visual direction, outline two or three genuinely different directions. Recommend one and proceed with it unless the choice would materially alter an established brand or product strategy.

## 2. Define the visual system

Turn vague adjectives into implementation constraints. Define or confirm:

- type scale, weights, line lengths, and numeric treatment;
- spacing rhythm and content width;
- surface, border, radius, and shadow hierarchy;
- semantic color roles and contrast;
- grid, alignment, and responsive breakpoints;
- icon and image treatment;
- interaction and motion principles.

Prefer typography, alignment, whitespace, scale, and contrast for hierarchy. Avoid adding containers merely to separate content.

Do not introduce generic AI styling by default: gratuitous gradients, glassmorphism, glowing accents, nested cards, excessive pills, oversized marketing headings, decorative microcopy, arbitrary purple/blue palettes, or uniform rounding on every element. Use any of these only when the product context or reference supports it.

Read [visual-rubric.md](references/visual-rubric.md) before implementing a substantial UI or conducting a visual-polish pass.

## 3. Implement coherently

Reuse existing primitives and tokens. Make the smallest change that delivers a complete visual result.

Cover the states relevant to the feature: loading, empty, error, success, disabled, active, selected, hover, and focus. Keep accessibility semantics, keyboard behavior, contrast, content hierarchy, and responsiveness aligned with the visual design.

Do not invent business rules, permissions, statuses, thresholds, or irreversible actions to make a mockup appear complete. Use clearly labeled representative data when needed.

## 4. Validate in a real browser

A passing build is not visual evidence.

When the environment permits:

1. Run the interface in a real browser.
2. Inspect representative desktop and mobile viewports, plus an intermediate width when layout behavior changes.
3. Exercise the important interaction and data states.
4. Capture screenshots with consistent viewport sizes.
5. Score the result with [visual-rubric.md](references/visual-rubric.md).
6. Record the five highest-impact defects in concrete terms and fix them.
7. Re-render and repeat the review at least once for substantial UI work.

Prioritize fixes in this order:

1. task clarity and hierarchy;
2. composition, alignment, and responsive behavior;
3. typography and density;
4. color, surface, and component consistency;
5. decorative detail and motion.

Never claim the interface is polished based only on source inspection, tests, or a successful build. If browser execution is unavailable, report the exact user-visible validation gap.

## 5. Finish with evidence

Report:

- the visual direction and intended focal point;
- changed files;
- static checks performed;
- viewports and states inspected;
- defects found and corrected across each visual pass;
- remaining risks or validation gaps.

Do not claim deployment or production behavior from local evidence.
