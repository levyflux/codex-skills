# Implementation

## Follow the local system

Use the repository's components, tokens, utilities, patterns, and dependency versions. Inspect real implementations before choosing an API. Do not add a dependency merely for styling convenience.

Prefer semantic structure and composition over deep wrapper trees. Keep layout ownership clear and avoid duplicating components with near-identical purposes.

## Visual discipline

- Use the existing spacing scale; use an 8px rhythm only when no system exists, allowing 4px for fine alignment.
- Keep typography hierarchy restrained, normally no more than four visibly distinct levels on one screen.
- Reuse established colors, radii, borders, and shadows. Add a token only when the product needs a reusable semantic role.
- Use motion to clarify state or continuity; respect reduced-motion preferences.
- Use familiar icons from the existing library and pair ambiguous icons with labels.
- Avoid decorative gradients, glass effects, oversized headings, excessive padding, nested cards, and arbitrary shadows unless the product language or user request calls for them.

## Interaction and state coverage

Implement every relevant state from the design brief. Check hover, focus-visible, active, selected, disabled, loading, validation, empty, error, success, and permission-limited behavior.

Prevent layout shift where practical. Preserve user input across recoverable errors. Put validation near the affected control and make asynchronous progress understandable. Ensure destructive actions communicate consequence and recovery.

## Responsive behavior

Design responsive transformations rather than shrinking the desktop screen. Define what wraps, stacks, scrolls, collapses, becomes a menu, or changes order. Keep touch targets usable and primary actions reachable. Avoid hiding essential information solely to make a narrow viewport fit.

## Accessibility

Use native elements first. Maintain logical heading order, accessible names, form labels, error associations, keyboard operation, visible focus, sensible tab order, and announced dynamic status where needed. Do not encode meaning by color alone.

## Engineering quality

Keep data fetching and business rules in their established layers. Avoid broad refactors during visual work unless required for correctness. Add or update focused tests for behavior that can regress; do not rely on snapshots as the only evidence for interaction correctness.
