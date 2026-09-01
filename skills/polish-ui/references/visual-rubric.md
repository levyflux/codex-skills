# Visual review rubric

Use this rubric after rendering the interface. Score each category from 1 to 5 and attach one sentence of evidence. Fix high-impact problems rather than optimizing the numeric total.

## Scoring scale

- **1 — broken:** obstructs comprehension or use.
- **2 — weak:** obvious inconsistency or generic treatment harms trust.
- **3 — competent:** usable and coherent, but ordinary or locally uneven.
- **4 — strong:** intentional, polished, and appropriate to the product.
- **5 — exceptional:** distinctive and highly resolved without sacrificing usability.

## Categories

### 1. Task clarity and hierarchy

- Is the primary task obvious within five seconds?
- Is there one first-glance focal point?
- Are primary, secondary, and tertiary actions visually distinct?
- Does the page reveal information in the order users need it?

### 2. Composition and alignment

- Do major regions form a deliberate composition rather than a stack of components?
- Are edges, baselines, columns, and gutters consistent?
- Does whitespace group related content and separate unrelated content?
- Does the layout remain balanced with realistic short and long content?

### 3. Typography

- Are size, weight, line height, and color doing distinct jobs?
- Are line lengths readable and labels concise?
- Are numeric values, metadata, and long-form text treated appropriately?
- Are there too many near-identical text styles?

### 4. Density and rhythm

- Does density match the user's frequency and expertise?
- Do repeated elements follow a consistent spacing rhythm?
- Are controls compact enough for the task without harming touch or readability?
- Are empty regions intentional rather than accidental?

### 5. Color, surfaces, and depth

- Does color communicate state and emphasis instead of merely decorating?
- Are contrast and focus visibility sufficient?
- Are borders, shadows, and surfaces used sparingly and consistently?
- Can any card or divider be removed while preserving clarity?

### 6. Components and states

- Do repeated components look and behave consistently?
- Are loading, empty, error, disabled, active, selected, hover, and focus states covered where relevant?
- Are hit targets, labels, semantics, and keyboard behavior sound?
- Does the implementation reuse the established design system?

### 7. Responsiveness

- Does each viewport have an intentional composition rather than a compressed desktop layout?
- Is content priority preserved when space decreases?
- Is there clipping, overflow, awkward wrapping, or unstable height?
- Are navigation and complex controls usable on touch devices?

### 8. Distinctiveness and restraint

- Does the interface express the product's character rather than generic AI styling?
- Is there a memorable but useful visual idea?
- Are decorative effects justified by product context?
- Have gradients, glass effects, pills, oversized headings, nested cards, and ornamental copy been avoided unless intentional?

## Review output

Record findings in this compact form:

| Category | Score | Evidence | Highest-impact correction |
| --- | ---: | --- | --- |
| Task clarity | 1–5 | What is visible in the rendered UI | Specific change |

Then list the five corrections in priority order. Use measurable language such as “reduce the header from 112px to 72px” or “replace four equal-weight actions with one primary button and a text menu,” not “make it cleaner.”
