---
name: genius-thinking
description: "[Hyper] Generate and prioritize differentiated ideas for stuck product, strategy, or innovation problems when ordinary brainstorming is too shallow. Saves structured multi-file analysis under .hypercore/genius-thinking/[topic-slug]/ with phase tracking."
---

@rules/execution-rules.md
@rules/output-discipline.md
@references/formula-guide.md
@references/output-template.md

# Genius Thinking Skill

> Combine a small number of validated innovation frameworks to generate diverse options and rank them with explicit reasoning. Organize results as a multi-file folder for future reference.

## When to use

### Positive triggers

- `Generate differentiated AI education ideas for working professionals.`
- `Rethink customer acquisition for a startup that keeps repeating generic SaaS tactics.`
- `Find bold product directions for a healthcare app that looks interchangeable with competitors.`

### Out of scope

- `Summarize these existing product ideas without adding new ones.`
- `Give me ten random ideas with no prioritization or rationale.`

### Boundary case

- `We already have three strong options and only need a final decision.` Use a decision review unless the real problem is weak idea generation or reframing.

## Required inputs

Collect or infer:

- the problem or opportunity statement
- the target user or market
- the decision or output needed
- meaningful constraints such as budget, team, timing, or regulation

## Core job

1. Restate the problem.
2. Choose 2-3 frameworks with a brief selection rationale.
3. Reframe the opportunity before ideation.
4. Generate 10+ ideas with real diversity, not cosmetic variations.
5. Rank the best options with evidence-backed prioritization.

## Framework choice

Use only the frameworks that fit the task. Common pairings and diversity checks live in [references/formula-guide.md](references/formula-guide.md).

<document_shape>

## Output Structure

```text
.hypercore/genius-thinking/[topic-slug]/
├── flow.json           # phase tracking
├── frameworks.md       # selected formulas + rationale + HMW reframing
├── analysis.md         # deep analysis (SCAMPER, TRIZ, JTBD application)
├── ideas.md            # 10+ ideas with evaluations (title, description, score)
└── priorities.md       # ERRC validation + ranking + next steps
```

- Use ASCII kebab-case for `[topic-slug]` (e.g., `ai-education-service`).
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
| `select` | `frameworks.md` — selected formulas + rationale + HMW reframing | `analyze` |
| `analyze` | `analysis.md` — deep framework application (1500+ chars) | `ideate` |
| `ideate` | `ideas.md` — 10+ ideas with evaluations | `prioritize` |
| `prioritize` | `priorities.md` — ERRC validation + ranking + next steps | done |

### Resume support

If `flow.json` already exists, read it and continue from the last incomplete phase. Do not restart completed phases.

</flow_tracking>

## Workflow

| Phase | Goal | Output file |
|------|------|-------------|
| 1 | Clarify the challenge | (inline) |
| 2 | Choose frameworks | `frameworks.md` |
| 3 | Deep analysis + reframe the opportunity | `analysis.md` |
| 4 | Generate 10+ ideas across distinct directions | `ideas.md` |
| 5 | Prioritize with ERRC validation | `priorities.md` |

Parallel ideation is optional. Use it only when it materially improves coverage.

## Output requirements

- include a selection rationale for the chosen frameworks
- show diversity across the idea set
- separate observed evidence from inference
- explain why the top ideas outrank the others

Use the full report and idea format in [references/output-template.md](references/output-template.md).

## Validation

- Do not force hard character quotas.
- Do not dump framework trivia that does not change the answer.
- Do not present near-duplicate ideas as separate wins.
- Do not prioritize ideas without naming the assumption and next cheap test.
- All output files must be saved under `.hypercore/genius-thinking/[topic-slug]/`.
- `flow.json` status must be set to `completed`.
