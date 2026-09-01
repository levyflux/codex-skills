# Discovery and design

Do not start with code. Inspect enough product evidence to answer the following, then write a compact design brief.

## Product analysis

- Identify the users, their primary job, secondary jobs, frequency of use, environment, and likely device constraints.
- Identify the actual data source, permissions, navigation context, and adjacent workflow.
- Distinguish a missing requirement from a design choice. Ask only when the choice materially changes behavior; otherwise make and disclose a reversible assumption.

## State and task model

Map the shortest successful path and relevant recovery paths. Include only states the feature can actually reach:

- initial or empty
- loading or progressive loading
- partial data
- validation failure
- request or system error
- success and confirmation
- disabled, unavailable, or permission-limited
- destructive confirmation and recovery, when applicable

Do not invent states or copy unsupported by product behavior.

## Information hierarchy

Classify content and actions as primary, supporting, or tertiary. Choose one primary CTA per task context. Reduce the visual weight of secondary actions and keep rare actions discoverable without competing with the main path.

Select the layout from content relationships and user behavior. Explain why the chosen grouping, ordering, density, and responsive transformation support the task. Avoid using cards as a default grouping device.

## Reuse inventory

Record the existing components, tokens, icons, form patterns, tables, dialogs, navigation structures, and responsive conventions to reuse. Identify any unavoidable new primitive and why composition cannot solve it.

## Compact design brief

Before editing, capture:

- operator/user and primary task
- hierarchy and primary CTA
- layout and responsive behavior
- reused primitives
- relevant loading/empty/error/disabled/success states
- keyboard and accessibility behavior
- acceptance viewports and evidence
- assumptions and unresolved decisions

For a small local change, one concise paragraph or checklist is sufficient. For a new or substantially redesigned screen, add a text wireframe or component tree and interaction sequence. Keep these as working notes unless the user requests a durable specification.
