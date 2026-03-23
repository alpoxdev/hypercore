---
name: elon-musk
description: Break a problem into hard constraints, conventions, and unknowns, then redesign options from fundamentals. Use when current answers feel copied from industry defaults.
---

@rules/execution.md
@references/frameworks.md

# Elon Musk

> Rebuild decisions from first principles instead of inheriting analogy-driven defaults.

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

<workflow>

## Workflow

| Phase | Task | Output |
|------|------|------|
| 1 | Clarify the decision | One-line problem framing |
| 2 | Identify constraints, conventions, and unknowns | A/B/C matrix |
| 3 | Rebuild alternatives from fundamentals | Current vs rebuilt options |
| 4 | Stress-test the best path | Failure modes and mitigations |
| 5 | Recommend next actions | Execution sequence |

Research rule:

- if the problem depends on current facts, gather and cite them
- if the problem is conceptual, do not force web or team workflows

</workflow>

<output_contract>

The final answer should include:

- `A/B/C matrix` for assumptions
- `Rebuilt options` from fundamentals
- `Current vs first-principles comparison`
- `Failure modes` from inversion or pre-mortem
- `Recommended next steps`

</output_contract>

<validation>

Before finishing, check:

- conventions are separated from true constraints
- unknowns that need evidence are labeled explicitly
- the recommendation does not depend on obsolete tool or model names
- inversion or pre-mortem was used to challenge the preferred path

</validation>
