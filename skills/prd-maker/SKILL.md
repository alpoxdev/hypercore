---
name: prd-maker
description: Create or update a living product requirements document under `.hypercore/prd/[slug]/`, including evidence-backed PRD content, scoped requirements, open questions, and source tracking.
compatibility: Works best with local file search/edit tools and live web search when the PRD needs fresh market, user, product, or technical evidence.
---

@rules/prd-workflow.md
@rules/storage-and-updates.md
@rules/validation.md

# PRD Maker

> Create and maintain living PRDs inside this repository.

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
- Scope changes, assumptions, risks, metrics, dependencies, and open questions

</supported_targets>

<document_shape>

Default output shape:

```text
.hypercore/prd/[slug]/
├── prd.md
└── sources.md
```

- `prd.md` is the living product requirements document.
- `sources.md` captures the evidence used to create or update the PRD.
- Keep version history inside `prd.md` rather than creating extra changelog files.
- Create the files from [assets/prd.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/prd.template.md) and [assets/sources.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/sources.template.md) when the folder does not exist yet.

</document_shape>

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

| Phase | Task | Output |
|------|------|------|
| 0 | Confirm that the requested deliverable is a PRD and choose `create` or `update` | Mode decision |
| 1 | Gather the minimum product context and decide whether external research is required | Working brief |
| 2 | Create or locate `.hypercore/prd/[slug]/` and determine what files must change | Storage target |
| 3 | Write or update `prd.md` using the section reference and template assets | Living PRD |
| 4 | Write or update `sources.md` with queries, links, retrieval dates, and short findings | Evidence log |
| 5 | Validate scope clarity, citations, open questions, and change tracking | Finalized PRD folder |

### Phase rules

- Prefer updating an existing PRD when the request is a revision, not a brand-new initiative.
- If the request depends on current market, customer, legal, technical, or competitive facts, run live research with distinct queries before writing.
- If the user already provided enough reliable context, do not force unnecessary external research.
- Keep the main PRD concise. Put raw source accumulation in `sources.md`, not in the main body.
- Preserve prior decisions unless the new information clearly supersedes them.

</workflow>

<required>

- Store every PRD under `.hypercore/prd/[slug]/`.
- Prefer ASCII kebab-case slugs.
- Keep explicit sections for goals, scope, non-goals, requirements, metrics, risks or dependencies, open questions, and change history.
- Add links for non-obvious claims when research informed the document.
- When updating, append a dated change-log row instead of silently overwriting significant decisions.

</required>

<forbidden>

- Writing a PRD only in chat without saving the folder output
- Rewriting the entire PRD when only one section needs updating
- Hiding unresolved questions or assumptions
- Mixing raw research notes into the main PRD body when they belong in `sources.md`
- Creating extra README or changelog files for the PRD folder

</forbidden>
