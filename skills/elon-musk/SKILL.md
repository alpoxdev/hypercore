---
name: elon-musk
description: "[Hyper] Break a problem into hard constraints, conventions, and unknowns, then redesign options from fundamentals. Saves structured multi-file analysis under .hypercore/elon-musk/[topic-slug]/ with phase tracking. Use when current answers feel copied from industry defaults."
---

@rules/execution.md
@references/frameworks.md

# Elon Musk

> Rebuild decisions from first principles instead of inheriting analogy-driven defaults. Organize results as a multi-file folder for future reference.

<when_to_use>

Use this skill when:

- the current options all look like slight variations of the same idea
- cost, structure, or strategy feels constrained by habit
- you need to separate real constraints from inherited assumptions

Do not use this skill when:

- the job is mostly factual research with no redesign
- the request is standard implementation planning
- the user needs startup validation scoring rather than assumption teardown

Boundary:

- if the main job is startup scoring and readiness assessment, use `startup-validator`
- if the main job is broad idea generation, use `genius-thinking`

Examples:

```bash
/elon-musk SaaS pricing is crowded and undifferentiated
/elon-musk infrastructure cost is 40% of revenue
/elon-musk churn is high and retention playbooks are failing
```

</when_to_use>

<input_check>

If `$ARGUMENTS` is missing, ask:

`Which problem should we deconstruct using first principles?`

</input_check>

<owned_job>

For each run:

1. Restate the problem and desired outcome.
2. Gather facts only where the answer depends on current evidence.
3. Classify assumptions using the A/B/C model from [references/frameworks.md](references/frameworks.md).
4. Rebuild options from the surviving fundamentals.
5. Stress-test the best path with inversion and pre-mortem.

</owned_job>

<document_shape>

## Output Structure

```text
.hypercore/elon-musk/[topic-slug]/
├── flow.json           # phase tracking
├── research.md         # domain research (conventions + facts + innovation cases)
├── assumptions.md      # A/B/C matrix with Socratic questioning
├── redesign.md         # rebuilt options from fundamentals + comparison table
└── execution.md        # inversion + pre-mortem + action plan
```

- Use ASCII kebab-case for `[topic-slug]` (e.g., `saas-infra-cost`).
- Each phase produces its own file for organized reference.
- `flow.json` tracks progress through phases. See `references/flow-schema.md` for the schema.
- If the folder exists from a prior run, read existing files before updating.

</document_shape>

<flow_tracking>

## Flow Tracking

Write `flow.json` at the start and update as each phase completes.

### Phase progression

| Phase | Output file | Next |
|-------|-------------|------|
| `research` | `research.md` — industry conventions, actual facts, innovation cases | `deconstruct` |
| `deconstruct` | `assumptions.md` — A/B/C matrix with Socratic questioning | `redesign` |
| `redesign` | `redesign.md` — rebuilt options + current vs first-principles comparison | `execute` |
| `execute` | `execution.md` — inversion, pre-mortem, action sequence | done |

### Resume support

If `flow.json` already exists, read it and continue from the last incomplete phase. Do not restart completed phases.

</flow_tracking>

<workflow>

## Workflow

| Phase | Task | Output file |
|------|------|-------------|
| 1 | Clarify the decision, gather domain research | `research.md` |
| 2 | Identify constraints, conventions, unknowns (A/B/C matrix) | `assumptions.md` |
| 3 | Rebuild alternatives from fundamentals | `redesign.md` |
| 4 | Stress-test the best path, recommend next actions | `execution.md` |

Research rule:

- if the problem depends on current facts, gather and cite them
- if the problem is conceptual, do not force web or team workflows

</workflow>

<output_contract>

Each output file should include:

- `research.md`: industry conventions, actual data/benchmarks, innovation cases (with source URLs)
- `assumptions.md`: A/B/C matrix (A=physical constraints, B=conventions to eliminate, C=needs verification), Socratic questioning applied
- `redesign.md`: current vs first-principles comparison table, 3-5 alternative paths with feasibility/impact scores
- `execution.md`: inversion failure scenarios (5-7), pre-mortem analysis, prioritized action sequence

</output_contract>

<validation>

Before finishing, check:

- conventions are separated from true constraints
- unknowns that need evidence are labeled explicitly
- the recommendation does not depend on obsolete tool or model names
- inversion or pre-mortem was used to challenge the preferred path
- all output files are saved under `.hypercore/elon-musk/[topic-slug]/`
- `flow.json` status is set to `completed`

</validation>
