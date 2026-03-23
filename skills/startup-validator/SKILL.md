---
name: startup-validator
description: Evaluate a startup idea with explicit evidence, uncertainty, and scoring discipline. Use when the job is validation, not brainstorming or implementation planning.
---

@rules/evidence-and-scoring.md
@references/frameworks.md

# Startup Validator

> Score startup ideas with explicit evidence and uncertainty instead of optimism.

<when_to_use>

Use this skill when:

- validating a new startup or product idea
- deciding whether to proceed, pivot, or narrow the market
- preparing for customer discovery or fundraising conversations

Do not use this skill when:

- the main job is generating many new ideas
- the request is technical implementation planning
- the user wants first-principles redesign rather than validation scoring

Boundary:

- use `genius-thinking` for broad ideation
- use `elon-musk` for assumption teardown and redesign

Examples:

```bash
/startup-validator AI-based education service
/startup-validator subscription healthcare app
/startup-validator B2B purchasing automation
```

</when_to_use>

<input_check>

If `$ARGUMENTS` is missing, ask:

`Which startup idea should we validate?`

If founder, market, or customer evidence is missing, continue with explicit assumptions instead of inventing certainty.

</input_check>

<owned_job>

For each run:

1. Restate the idea and identify the key unknowns.
2. Score the idea using the framework set in [references/frameworks.md](references/frameworks.md).
3. Mark evidence quality and uncertainty for each major claim.
4. Summarize the strongest strengths, critical weaknesses, and next validation steps.

</owned_job>

<workflow>

## Workflow

| Phase | Task | Output |
|------|------|------|
| 1 | Frame the idea and missing context | One-line thesis plus assumptions |
| 2 | Score the Thiel questions | Per-question rationale and provisional score |
| 3 | Check PMF and switching forces | Demand and behavior read |
| 4 | Apply penalties or caution flags | Adjusted score and risk map |
| 5 | Recommend next validation actions | Prioritized roadmap |

Scoring rule:

- do not fabricate precise scores when evidence is thin
- mark uncertain sections as provisional and explain what evidence would change them

</workflow>

<output_contract>

The final answer should include:

- `Total score / grade`
- `Per-question rationale`
- `Critical weaknesses`
- `Evidence and uncertainty notes`
- `Next validation steps`

</output_contract>

<validation>

Before finishing, check:

- unsupported certainty is called out as provisional
- evidence quality is distinguished from opinion
- the score ties back to named frameworks
- the output includes concrete next validation actions

</validation>
