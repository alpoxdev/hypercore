---
name: prd-maker
description: "[Hyper] Create or update a ManyFast-style AI planning package from a rough product idea: PRD, visual planning diagram, feature spec, user flow, low-fidelity wireframe, HTML preview viewer, source log, and optional flow tracking under `.hypercore/prd/[slug]/`. Use when the user wants product planning output before implementation, especially PRD plus diagram/specs/flows/wireframes."
compatibility: Works best with local file search/edit tools and live web search when the planning package needs current market, user, product, legal, or technical evidence.
---

@rules/package-workflow.md
@rules/storage-and-updates.md
@rules/validation.md
@references/planning-package.md
@references/prd-sections.md

# PRD Maker

> Turn a rough product idea into a reviewable AI planning package: PRD, planning diagram, feature spec, user flow, wireframe, preview viewer, and source log.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Create or update planning folders under `.hypercore/prd/[slug]/` from short product ideas, feature requests, or initiative notes.
- Produce the core planning outputs a team can review before implementation: product requirements, visual planning map, functional details, user flow, low-fidelity wireframe, and browser preview.
- Keep assumptions, open questions, scope decisions, and evidence visible instead of pretending the idea is fully specified.

</purpose>

<routing_rule>

Use `prd-maker` when the main output is a stored product planning package, PRD, planning diagram, feature specification, user flow, wireframe, or preview viewer.

Use `research` instead when the job is only fact-finding and no planning package should be written yet.

Use `docs-maker` instead when the output is a general document, runbook, guide, or technical spec not stored as a product planning folder.

Use `plan` instead when the user wants discussion or task planning but does not want files under `.hypercore/prd/`.

Do not use `prd-maker` when:

- the user only wants brainstorming with no saved artifact
- the user only wants implementation, coding, or debugging
- the requested output is only a generic markdown document rather than product requirements/planning output

</routing_rule>

<activation_examples>

Positive requests:

- "Create a PRD and flow for team inbox assignments."
- "Make a ManyFast-style planning output for a billing retry feature."
- "Turn this app idea into PRD, diagram, feature spec, user flow, and wireframe docs."
- "Update the existing onboarding PRD with a new flow and acceptance criteria."

Negative requests:

- "Research how competitors handle onboarding."
- "Implement the billing retry flow."
- "Rewrite this runbook for support engineers."

Boundary request:

- "Plan this feature before coding."
  Use `prd-maker` only if the plan should become a saved planning package under `.hypercore/prd/`. Otherwise route to `plan`.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|------|------|
| A rough product idea needs a complete planning package | create |
| A PRD needs a supporting diagram, feature spec, user flow, or wireframe added | update |
| Existing planning docs need scope, requirements, metrics, risks, or flows refreshed | update |
| A release or initiative needs source-backed requirements before implementation | create/update |

</trigger_conditions>

<supported_targets>

- New planning package folders under `.hypercore/prd/[slug]/`
- Existing package updates under `.hypercore/prd/[slug]/`
- `prd.md` product requirements
- `diagram.md` visual planning map source, `diagram.data.json` node data, and rendered `diagram.svg`
- `feature-spec.md` functional specification and acceptance criteria
- `user-flow.md` actor journeys, states, and edge cases
- `wireframe.md` text-based low-fidelity wireframes and screen inventory
- `preview.html` browser-viewable package preview generated from the package files and `assets/preview.template.html`
- `sources.md` evidence, query, and context log
- `flow.json` phase tracking for complex multi-session packages

</supported_targets>

<complexity_classification>

Classify before writing files:

| Complexity | Signals | Path |
|------------|---------|------|
| **Simple** | Single feature, clear audience, limited unknowns, minimal research, small output | Direct package — write the core markdown files and source log without flow tracking |
| **Complex** | Multi-feature initiative, vague or high-stakes scope, external research, multiple personas, cross-team dependencies, phased rollout | Tracked package — add and maintain `flow.json` |

Announce the classification:

```text
Complexity: [simple/complex] — [one-line reason]
```

When uncertain, classify as complex. Losing phase state is more expensive than maintaining a small flow file.

</complexity_classification>

<output_shape>

Default package shape:

```text
.hypercore/prd/[slug]/
├── prd.md
├── diagram.md
├── diagram.data.json
├── diagram.svg
├── feature-spec.md
├── user-flow.md
├── wireframe.md
├── preview.html
├── sources.md
└── flow.json          (complex path only)
```

- `prd.md` explains the product decision: problem, goals, scope, requirements, metrics, risks, and open questions.
- `diagram.md` contains a ManyFast-like branching planning map: central idea → PRD/spec/flow/wireframe branches, with key subnodes and open gaps.
- `diagram.data.json` feeds `scripts/render-planning-map.mjs`, which renders the card-and-connector map to `diagram.svg` without adding dependencies.
- `feature-spec.md` translates the PRD into functional behavior, acceptance criteria, states, and edge cases.
- `user-flow.md` captures the key paths, decision points, empty/error states, and handoffs.
- `wireframe.md` describes low-fidelity screens and layout blocks in text so designers/builders can review structure before visual work.
- `preview.html` embeds the package content and `diagram.svg` into a local browser viewer for fast review.
- `sources.md` logs provided context, research queries, links, and evidence gaps.
- `flow.json` tracks phase progress for complex packages. See `references/flow-schema.md`.

Use the templates in `assets/` when creating a folder for the first time. For the diagram, create `diagram.md`, `diagram.data.json`, and `diagram.svg`; prefer `scripts/render-planning-map.mjs` because it renders the visual map without new dependencies.

</output_shape>

<support_file_read_order>

Read in this order:

1. This core `SKILL.md` to confirm the request belongs to a planning package.
2. `rules/package-workflow.md` to choose create/update mode, complexity, research need, and package phase order.
3. `rules/storage-and-updates.md` to apply folder, slug, file, and merge rules.
4. `references/planning-package.md` when drafting `diagram.md`, `feature-spec.md`, `user-flow.md`, or `wireframe.md`.
5. `references/prd-sections.md` when drafting or updating `prd.md`.
6. Relevant localized templates in `assets/` when creating missing package files, including `*.template.ko.md` and `diagram.data.template.ko.json` by default; use English templates only when requested or required.
7. `scripts/render-planning-map.mjs` when rendering `diagram.svg` from `diagram.data.json`.
8. `assets/preview.template.html` and `scripts/build-preview.mjs` when generating `preview.html`.
9. `assets/sources.template.ko.md` by default when live research is needed and the package needs a source ledger; use `assets/sources.template.md` only when requested or required.
10. `references/flow-schema.md` when the package is complex or a `flow.json` already exists.
11. `rules/validation.md` before declaring the package complete.

</support_file_read_order>

<workflow>

## Direct package path

| Phase | Task | Output |
|-------|------|--------|
| 0 | Confirm package deliverable, choose create/update, classify simple | Mode + complexity |
| 1 | Extract or infer a minimum brief; put unresolved gaps in open questions | Working brief |
| 2 | Create or locate `.hypercore/prd/[slug]/` | Storage target |
| 3 | Write or update `prd.md`, `diagram.md`, `feature-spec.md`, `user-flow.md`, `wireframe.md`, `preview.html`, and `sources.md` | Reviewable package |
| 4 | Validate consistency, scope, evidence, and unknowns | Final package |

## Tracked package path

| Phase | Task | Output |
|-------|------|--------|
| 0 | Confirm package deliverable, choose create/update, classify complex | Mode + complexity |
| 1 | Create or locate folder and initialize/resume `flow.json` | Storage target + phase state |
| 2 | Gather minimum brief and update `flow.json` | Working brief |
| 3 | Run live research if needed or record why skipped | Evidence basis |
| 4 | Draft/update PRD, diagram, feature spec, user flow, wireframe, preview, and sources in phase order | Planning package |
| 5 | Validate and mark flow completed | Final package |

### Operating rules

- Start from the user's rough idea; infer only low-risk basics and mark everything else as assumptions or open questions.
- Do not ask for clarification unless a missing answer would materially branch the product direction.
- If current market, competitor, legal, platform, or technical facts affect requirements, run live research before finalizing claims.
- Update existing packages surgically. Preserve valid decisions and append dated change history rather than rewriting everything.
- Keep raw research and context in `sources.md`, not in the PRD body.
- Treat the diagram as a navigable product map, not a decorative image.
- Rebuild `preview.html` after package content changes so the viewer is never stale.
- Treat wireframes as structural review artifacts, not polished visual design.

</workflow>

<required>

- Complexity classified before writing.
- Every package stored under `.hypercore/prd/[slug]/` with ASCII kebab-case slug preferred.
- New packages include `prd.md`, `diagram.md`, `diagram.data.json`, `diagram.svg`, `feature-spec.md`, `user-flow.md`, `wireframe.md`, `preview.html`, and `sources.md`.
- PRD includes goals, scope, non-goals, requirements, metrics, risks/dependencies, open questions, and change history.
- Diagram includes a central initiative node, first-level planning branches, second-level requirement/flow/screen nodes, and open gaps.
- Feature spec includes functional requirements, acceptance criteria, states, errors, permissions, analytics, and rollout notes when relevant.
- User flow includes actors, happy paths, alternate paths, edge/error states, and entry/exit points.
- Wireframe includes screen inventory, layout blocks, component notes, and unresolved visual/product questions.
- Preview HTML opens locally in a browser and includes the diagram plus text artifacts.
- `sources.md` records provided context and either distinct research queries or why external research was unnecessary.
- Complex packages maintain `flow.json` and update it after each phase.

</required>

<forbidden>

- Returning the planning package only in chat without saving files.
- Creating a PRD without the supporting diagram, spec, flow, wireframe, and preview when making a new package.
- Hiding assumptions or unresolved questions.
- Copying raw source material into the PRD instead of summarizing and linking it from `sources.md`.
- Creating extra README, notes, or changelog files unless the user explicitly asks.
- Treating the diagram as final architecture or the wireframe as final UI design/implementation code.

</forbidden>
