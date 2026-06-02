# Package Workflow

Use this rule file to turn a rough product request into a create or update flow for the full planning package.

## 1. Choose the mode first

- `create`: no existing package folder matches the initiative, or the user explicitly wants a new planning package.
- `update`: an existing package already exists and the request refines scope, requirements, diagrams, flows, wireframes, metrics, risks, or launch details.

Prefer `update` when the user is iterating on an established initiative.

## 2. Gather the minimum working brief

Before writing, identify or infer:

- product or feature name
- problem to solve
- target users or operators
- desired outcome or business goal
- primary use case
- known constraints or deadlines
- likely platforms or surfaces
- known unknowns

If the request is sparse, infer only low-risk basics and keep the rest as explicit assumptions or open questions.

## 3. Decide whether research is required

Run live research when requirements depend on:

- current market or competitor claims
- recent product, user, legal, platform, or technical facts
- specific metrics, benchmarks, prices, policies, or APIs the user did not provide
- safety, compliance, or financial claims

Research rules:

- Use distinct queries from different angles.
- Prefer official, primary, or otherwise authoritative sources.
- Stop when the evidence is sufficient to support package decisions.
- Record queries, links, retrieval dates, and evidence gaps in `sources.md`.

Skip external research when the user provided enough context and the package can safely mark remaining unknowns.

## 4. Draft in dependency order

Use this order for new packages:

1. `sources.md` working context and research notes
2. `prd.md` product decision record
3. `diagram.md` branching planning map
4. `feature-spec.md` functional details and acceptance criteria
5. `user-flow.md` journeys, branches, and states
6. `wireframe.md` screen inventory and low-fidelity layout blocks
7. `preview.html` local browser preview

This order keeps the PRD as the source of product truth and downstream docs as derived review artifacts.

## 5. Update instead of rewrite

When updating:

- read all existing package files first
- preserve decisions that still hold
- patch only affected sections
- append a dated change-history row to `prd.md`
- update downstream docs when PRD changes affect behavior, flows, or screens
- add new evidence to `sources.md` instead of deleting earlier evidence unless it is clearly obsolete

## 6. Keep artifacts aligned

After drafting or updating, check cross-document consistency:

- the diagram has a central initiative node and branches for PRD, feature spec, user flow, wireframe, and open questions
- every must-have PRD requirement appears in `feature-spec.md`
- every major feature behavior has a user-flow path or explicit non-user-facing note
- every user-facing flow has a wireframe screen or screen-state entry
- `preview.html` reflects the latest package files and rendered diagram
- every research-backed non-obvious claim has a source entry
- every unresolved ambiguity is visible in open questions or assumptions
