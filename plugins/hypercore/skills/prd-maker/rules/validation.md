# Validation

Use this checklist before declaring the planning package complete.

## Required checks

- The request really called for a product planning package, PRD, diagram, feature spec, user flow, or wireframe.
- The package folder exists under `.hypercore/prd/[slug]/`.
- New packages contain `prd.md`, `diagram.md`, `diagram.data.json`, `diagram.svg`, `feature-spec.md`, `user-flow.md`, `wireframe.md`, `preview.html`, and `sources.md`.
- The PRD includes goals, scope, non-goals, requirements, metrics, risks/dependencies, open questions, and change history.
- The diagram includes a central idea node, branches for PRD/spec/flow/wireframe, second-level nodes, open gaps, and valid Mermaid/text structure, valid JSON node data, and a rendered SVG.
- The feature spec covers all must-have requirements with acceptance criteria, states, permissions, errors, analytics, and rollout notes when relevant.
- The user flow covers actors, entry points, happy paths, alternate paths, edge/error states, and exit points.
- The preview HTML opens without external dependencies and includes the diagram plus text artifacts.
- The wireframe covers each user-facing flow with screen inventory, layout blocks, components, and unresolved design/product questions.
- Any research-backed non-obvious claim has a link in `sources.md`.
- `sources.md` contains provided context and either distinct queries or an explicit note that external research was unnecessary.
- When updating, the PRD change history shows what changed and why.
- Unknowns are visible as open questions or assumptions, not silently omitted.
- Complex packages include `flow.json` with current phase state and final validation status.

## Cross-artifact checks

- The diagram maps the package at a glance and links to the text artifacts.
- PRD requirements map to feature-spec requirements.
- Feature-spec behaviors map to user-flow paths or explicit non-user-facing notes.
- User-facing flows map to wireframe screens or screen states.
- Preview content is rebuilt after source artifact changes.
- Metrics and analytics events are consistent across PRD and feature spec.
- Risks, dependencies, and open questions are not contradicted across files.

## Quality checks

- The package is concise enough to scan quickly.
- Main decisions live in `prd.md`; detailed behavior lives in `feature-spec.md`; evidence accumulation lives in `sources.md`.
- Requirements are written as product behavior or outcomes, not implementation mandates unless that constraint is genuinely required.
- Wireframes are low-fidelity structure, not premature visual polish.

## Forward-test questions

- Could a new teammate understand what problem this initiative solves?
- Could engineering tell what is required, optional, and out of scope?
- Could design understand the required screens and states before making visual comps?
- Could someone revisit the package next month and see what changed?
- If evidence shifts, can `sources.md` be refreshed without rewriting the package?
