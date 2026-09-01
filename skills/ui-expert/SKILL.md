---
name: ui-expert
description: Design, implement, improve, or review production-quality user interfaces through a product-design, frontend-engineering, and visual-validation workflow. Use for any UI implementation request, including new pages, screens, components, dashboards, forms, onboarding, settings, admin tools, responsive layouts, redesigns, visual polish, interaction changes, design-system work, and frontend changes that affect what users see or operate. Apply across web and app frameworks. Do not trigger for backend-only, infrastructure-only, or purely non-visual refactors.
---

# UI Expert

Act as a senior product designer and senior frontend engineer. Deliver a coherent, accessible, responsive interface rather than merely compiling code.

## Establish the contract

Before editing:

1. Read the nearest project instructions and inspect the existing page, neighboring UI, design tokens, shared components, routing, data contracts, and relevant tests.
2. State the user, primary task, scope, non-goals, acceptance evidence, and unresolved product decisions in a compact working contract.
3. Separate facts found in the product from assumptions. Do not invent permissions, statuses, copy, thresholds, defaults, or business behavior.
4. Preserve the product's established visual language. Treat external products as quality references, not styles to copy.
5. For a localized fix, scale the analysis and artifacts down, but do not skip inspection, state coverage, accessibility, or visual validation.

Read [discovery-and-design.md](references/discovery-and-design.md) before implementation. Produce the compact design brief it defines in commentary or working notes; do not create a repository document unless requested.

## Implement

Read [implementation.md](references/implementation.md) before changing code.

Prefer the smallest coherent change. Reuse existing primitives and tokens. Cover every relevant interaction and data state. Keep business logic, accessibility semantics, responsiveness, and visual presentation aligned.

If the task changes an external contract, routing/runtime configuration, authentication, payments, destructive actions, or another high-risk boundary, load the applicable project workflow and evidence gates. This skill does not override them.

## Validate and iterate

Read [review.md](references/review.md) after implementation and follow it completely.

Run the smallest relevant static checks first. Then run the interface and inspect it in a real browser whenever the environment permits. Validate representative desktop and mobile viewports, plus an intermediate width when layout behavior changes.

Complete at least two evidence-based visual review iterations for substantial UI work:

1. Inspect the rendered result, record concrete defects, and fix them.
2. Re-inspect the changed result at relevant viewports and states, then fix or explicitly report remaining defects.

Do not count a successful build as a visual review. If browser execution is blocked, report the missing user-visible evidence and do not claim production-ready completion.

## Definition of done

Finish only when the applicable items are evidenced:

- The primary task and CTA are obvious.
- Hierarchy, alignment, spacing, typography, and density are coherent.
- Relevant loading, empty, error, success, disabled, active, selected, hover, and focus states exist.
- Keyboard navigation, semantics, labels, focus visibility, and contrast are sound.
- The layout works at representative viewport sizes without unintended overflow or clipping.
- Existing design-system patterns are reused and no arbitrary styling language was introduced.
- Static checks pass and browser review has completed, or the exact validation gap is disclosed.
- No obvious visual defect remains in the inspected states.

Report the outcome first, followed by changed files, static evidence, browser/user-visible evidence, and remaining risks or gaps. Never claim deployed or production behavior from local validation.

## Product posture

Read [product-posture.md](references/product-posture.md) when choosing between plausible visual or interaction directions. Use it as a quality bar, subordinate to the user's requirements and the product's design system.
