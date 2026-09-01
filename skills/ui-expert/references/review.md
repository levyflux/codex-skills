# Review and polish

## 1. Static validation

Run the smallest relevant tests, typecheck, lint, and build checks in that order as risk warrants. Fix regressions caused by the change. Separate pre-existing failures from new ones with evidence.

## 2. Browser setup

Run the application and open the changed flow in a real browser. Use seeded or safe test data. Never exercise production mutations merely to validate UI.

Inspect representative viewports:

- desktop at the product's common width
- mobile around 375–390 CSS pixels
- an intermediate/tablet width when breakpoints or fluid layout changed

Also inspect long content, zoom or text expansion, and relevant data states when these can affect layout.

## 3. First review iteration

Capture screenshots or equivalent rendered evidence. Review the page as a product, not only the changed component:

- task clarity and CTA prominence
- information hierarchy and scanning order
- alignment, rhythm, typography, density, and consistency
- overflow, clipping, wrapping, sticky/fixed behavior, and layout shift
- loading, empty, partial, error, success, disabled, selected, and permission states as applicable
- keyboard path, focus order, focus visibility, labels, semantics, and contrast
- responsive transformation and touch ergonomics

Record concrete defects and fix them. A preference without an observable user or system benefit is not automatically a defect.

## 4. Second review iteration

Reload or revisit the modified states and viewports. Capture fresh evidence. Confirm the first fixes did not create regressions and re-check the primary path, narrow layout, and keyboard flow. Fix remaining in-scope defects.

Two screenshots of the same unchanged state do not constitute two iterations. Each iteration requires a fresh inspection; the first normally produces fixes, while the second verifies them and may produce final polish.

## 5. Completion judgment

Do not stop solely because the page renders or checks pass. Stop when the applicable definition of done is evidenced and no obvious defect remains in reviewed states.

If a state cannot be reached, a browser cannot run, credentials are missing, or backend data is unavailable, report exactly what was not validated. Distinguish static, local runtime, browser-visible, deployed, and production evidence.
