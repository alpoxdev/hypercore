---
name: prd-maker
description: Create or update a living product requirements document under `.hypercore/prd/[slug]/`, including evidence-backed PRD content, scoped requirements, open questions, and source tracking. Routes simple PRDs directly; tracks complex multi-phase PRDs via flow.json in the PRD folder.
compatibility: Works best with local file search/edit tools and live web search when the PRD needs fresh market, user, product, or technical evidence.
---

@rules/prd-workflow.md
@rules/storage-and-updates.md
@rules/validation.md

# PRD Maker

> Create and maintain living PRDs inside this repository — classify complexity first, then either write directly or track progress through structured phases.

<purpose>

- Turn a product idea, feature request, or initiative into a reusable PRD folder under `.hypercore/prd/`.
- Update existing PRDs in place instead of rewriting them from scratch when the intent is refinement.
- Keep product reasoning, scope decisions, risks, and source evidence explicit and easy to review.

</purpose>

<routing_rule>

Use `prd-maker` when the main output is a PRD or an update to an existing PRD.

Use `research` instead when the job is still fact-finding and there is no PRD deliverable yet.

Use `docs-maker` instead when the output is a general document, spec, or runbook rather than a PRD folder.

Use `plan` instead when the user wants planning but does not want the result stored as a PRD under `.hypercore/prd/`.

Do not use `prd-maker` when:

- the user only wants brainstorming with no document output
- the user only wants market or technical research with no PRD to write
- the user wants implementation, coding, or debugging rather than product requirements

</routing_rule>

<activation_examples>

Positive requests:

- "Write a PRD for team inbox assignments."
- "Create a product requirements doc for the new billing retry flow."
- "Update the existing PRD with the latest launch scope and open questions."

Negative requests:

- "Research how competitors handle onboarding."
- "Implement the billing retry flow."

Boundary request:

- "Plan this feature before coding."
  Use `prd-maker` only if the output should become a stored PRD under `.hypercore/prd/`. Otherwise route to `plan` or `docs-maker`.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|------|------|
| A new PRD needs to be created | create |
| An existing PRD needs scope, requirements, metrics, or risks updated | update |
| A product idea needs to be turned into a maintained requirements folder | create |
| A release or initiative needs refreshed source-backed requirements | update |

</trigger_conditions>

<supported_targets>

- New PRD folders under `.hypercore/prd/[slug]/`
- Existing PRD updates under `.hypercore/prd/[slug]/`
- `prd.md` living requirements documents
- `sources.md` evidence logs and query logs
- `flow.json` phase tracking for complex PRDs
- Scope changes, assumptions, risks, metrics, dependencies, and open questions

</supported_targets>

<complexity_classification>

## Complexity Classification

Classify before starting work:

| Complexity | Signals | Path |
|------------|---------|------|
| **Simple** | Single feature, clear scope, minimal research needed, few stakeholders, small PRD (≤3 requirements sections) | **Direct** — write `prd.md` + `sources.md` without flow tracking |
| **Complex** | Multi-feature initiative, extensive research needed, multiple stakeholders, large scope, cross-team dependencies, phased rollout | **Tracked** — add `flow.json` to the PRD folder |

Announce the classification:

```
Complexity: [simple/complex] — [one-line reason]
```

When uncertain, classify as complex. It is cheaper to track than to lose progress on a large PRD.

</complexity_classification>

<document_shape>

Default output shape:

```text
.hypercore/prd/[slug]/
├── prd.md
├── sources.md
└── flow.json       (complex path only)
```

- `prd.md` is the living product requirements document.
- `sources.md` captures the evidence used to create or update the PRD.
- `flow.json` tracks phase progress for complex PRDs. See `references/flow-schema.md` for the full schema.
- Keep version history inside `prd.md` rather than creating extra changelog files.
- Create the files from [assets/prd.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/prd.template.md) and [assets/sources.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/sources.template.md) when the folder does not exist yet.

</document_shape>

<flow_tracking>

## Flow Tracking (Complex Path Only)

When classified as complex, write `flow.json` inside the PRD folder and update it as each phase progresses. See `references/flow-schema.md` for the full schema.

### Phase progression

| Phase | Description | Next |
|-------|-------------|------|
| `brief` | Gather minimum working brief (problem, users, goals, constraints) | `research` |
| `research` | Run live research if needed, or mark as skipped | `draft` |
| `draft` | Write or update `prd.md` using section reference and template | `sources` |
| `sources` | Write or update `sources.md` with evidence log | `validate` |
| `validate` | Run validation checks, finalize | done |

### Resume support

If `flow.json` already exists in the PRD folder, read it first and continue from the last incomplete phase. Do not restart completed phases. This enables multi-session PRD writing for large initiatives.

</flow_tracking>

<support_file_read_order>

Read in this order:

1. This core `SKILL.md` to confirm that the job is PRD creation or update.
2. [rules/prd-workflow.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/rules/prd-workflow.md) to choose create vs update mode and decide when research is required.
3. [rules/storage-and-updates.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/rules/storage-and-updates.md) to apply folder, file, slug, and merge rules.
4. [references/prd-sections.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/references/prd-sections.md) when drafting or updating the PRD body, including optional launch-gating sections such as release criteria.
5. [assets/prd.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/prd.template.md) and [assets/sources.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/sources.template.md) when creating a new PRD folder.
6. [instructions/sourcing/reliable-search.md](/Users/alpox/Desktop/dev/kood/hypercore/instructions/sourcing/reliable-search.md) when live research is needed.
7. [rules/validation.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/rules/validation.md) before declaring the PRD complete.

</support_file_read_order>

<workflow>

## Simple Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | Confirm PRD deliverable, choose `create`/`update`, classify as simple | Mode + complexity |
| 1 | Gather minimum product context | Working brief |
| 2 | Create or locate `.hypercore/prd/[slug]/` | Storage target |
| 3 | Write or update `prd.md` + `sources.md` | Living PRD |
| 4 | Validate scope, citations, open questions | Finalized PRD folder |

## Complex Path

| Phase | Task | Output |
|-------|------|--------|
| 0 | Confirm PRD deliverable, choose `create`/`update`, classify as complex | Mode + complexity |
| 1 | Create or locate `.hypercore/prd/[slug]/`, write `flow.json` with `brief: in_progress` | Storage target + flow |
| 2 | Gather product context → update flow `brief: completed` | Working brief |
| 3 | Run live research if needed → update flow `research: completed` (or `skipped`) | Evidence |
| 4 | Write or update `prd.md` → update flow `draft: completed` | Living PRD |
| 5 | Write or update `sources.md` → update flow `sources: completed` | Evidence log |
| 6 | Validate and finalize → update flow `validate: completed`, status: `completed` | Finalized PRD folder |

### Phase rules

- Prefer updating an existing PRD when the request is a revision, not a brand-new initiative.
- If the request depends on current market, customer, legal, technical, or competitive facts, run live research with distinct queries before writing.
- If the user already provided enough reliable context, do not force unnecessary external research.
- Keep the main PRD concise. Put raw source accumulation in `sources.md`, not in the main body.
- Preserve prior decisions unless the new information clearly supersedes them.

</workflow>

<required>

- Complexity classified (simple/complex) before starting work.
- Store every PRD under `.hypercore/prd/[slug]/`.
- Prefer ASCII kebab-case slugs.
- Keep explicit sections for goals, scope, non-goals, requirements, metrics, risks or dependencies, open questions, and change history.
- Add links for non-obvious claims when research informed the document.
- When updating, append a dated change-log row instead of silently overwriting significant decisions.
- For complex path: maintain `flow.json` and update after each phase.

</required>

<forbidden>

- Writing a PRD only in chat without saving the folder output
- Rewriting the entire PRD when only one section needs updating
- Hiding unresolved questions or assumptions
- Mixing raw research notes into the main PRD body when they belong in `sources.md`
- Creating extra README or changelog files for the PRD folder
- Skipping `flow.json` updates in complex path

</forbidden>
