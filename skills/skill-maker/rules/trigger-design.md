# Trigger Design

**Purpose**: Make skills trigger on the right requests and stay out of the way on the wrong ones.

Trigger behaviour is probabilistic. Nothing in this file is proven by reading one sentence, so every rule
below is written to be checkable rather than asserted.

## 1. Description Rules

The `description` must explain:

- what the skill does
- when it should be used
- which neighboring requests it should not own when ambiguity is likely

Weak:

```yaml
description: Helps with skills.
```

Better:

```yaml
description: Use this skill when the user asks to create or refactor a reusable Codex skill folder, including SKILL.md trigger wording, rules, references, scripts, assets, and validation checks. Do not use for generic documentation that is not a skill.
```

Write the description in **third person**. It is injected into a system prompt, and a description that
shifts point of view ("I can help you…", "You can use this to…") causes discovery problems. Prefer the
imperative `Use this skill when…` shape used above, which is already third-person and outcome-first.

## 2. Writing Pattern

- Start with `Use this skill when...` when the runtime accepts prose descriptions.
- Put user intent and outcome before internal implementation details.
- Put the most important trigger terms early, because a host may shorten the description before it is
  ever matched against a request.
- Include a short negative boundary when the skill has close neighbors.
- Avoid descriptions so broad they overlap every meta-skill.

## 3. The Two Axes

Build trigger examples along **two orthogonal axes**. They do not replace each other, and only crossing
both catches real failures.

| Axis | Values | What it verifies |
|---|---|---|
| Activation | positive / negative / boundary | Whether the description responds only to the right requests |
| Invocation mode | explicit / implicit / contextual / negative control | Whether it matches without the name, and does not misfire |

| Invocation mode | Meaning | Example |
|---|---|---|
| explicit | Names the skill directly | `Use $skill-maker to build a skill` |
| implicit | Matches the description in natural language without the name | `Create a reusable skill folder for me` |
| contextual | A real work sentence mixed with domain context | `Make this migration review procedure run identically every time` |
| negative control | A similar request that must not activate | `Clean up this runbook so it reads better` |

## 4. Trigger Case Shape

A trigger case is not a boolean. Each case carries its own repetition count and threshold, and the run
records the resulting rate:

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p3", "prompt": "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "b1", "prompt": "Create a guide for writing skills", "expect": "no_trigger", "runs": 3, "threshold": 0.5, "note": "depends on output shape" }
]
```

A run appends the measured `trigger_rate` to each case, so the result file carries the same keys plus the
outcome:

```json
{ "id": "p1", "expect": "trigger", "runs": 3, "threshold": 0.5, "trigger_rate": 1.0 }
```

Rules:

- **Every case states its own `runs` and `threshold`.** Do not let a case inherit a default; the value
  must be visible at the point of use, because `runs` changes what the rate means.
- `3` runs and a `0.5` threshold are the **starting point** the standard recommends, not a validated
  optimum. Raise `runs` when the observed spread is too wide to separate the case from its threshold.
- Do not pad the set to a target size. A case that probes nothing new adds calls, not evidence. Add a row
  only when it probes something the existing rows do not, and promote each real failure into a row.
- This is a `stochastic-model` measurement: record the model and runtime identity and the run count with
  the result, and note that a fixed seed alone does not estimate variance.

## 5. Description Optimization

Writing a description once is not the whole job; repeated edits overfit the examples they were tuned on.
These rules are normative.

- SK-O-1: Split the query set into **train and validation**. Improve against train; **select** by validation pass rate.
- SK-O-2: **The best description may not be the last one.** When a later iteration scores lower on validation, keep the earlier iteration.
- SK-O-3: Descriptions grow while you optimize. Re-check the **1024-character limit** on every edit.
- SK-O-4: When fine-tuning stops helping, **change the structure** - a different framing or a different sentence shape, not another adjective.

A run that reports only its final validation score is not evidence of improvement. Report the train and
validation numbers for each iteration so the selection is visible.

## 6. Description Budgets

The description competes for a fixed listing budget, and the two reviewed runtimes measure it differently.

| Runtime | Listing budget | What happens when it overflows |
|---|---|---|
| Codex | 2% of the context window, or 8,000 characters when the window is unknown | Descriptions are **shortened first**; for large skill sets some skills may then be **omitted from the initial list entirely**, with a warning |
| Claude Code | 1% of the context window, with each entry's `description` + `when_to_use` capped at **1,536 characters** | Descriptions are shortened, dropping the **least-invoked** skills first |

Consequences:

- Lead with the key trigger. A description whose distinguishing words sit at the end can lose them before
  a request is ever matched against it.
- The Codex failure mode is not only truncation. A skill that does not appear in the initial list is not
  a candidate at all, so a description that is merely long is a real availability risk.
- **This repository is already over the Codex budget.** Measured 2026-09-20: 38 skills whose descriptions
  total 14,641 characters. Codex emitted its shortening warning during that session. Any growth makes
  this worse, so a longer description needs a reason.

## 7. Coexistence

A skill does not trigger in isolation. Adding one can degrade another by taking its requests.

- **Coexistence is an evaluation dimension, not an afterthought.** The question is: does adding this
  skill degrade existing skills? The named failure is a new description broad enough to **steal triggers**
  from an existing skill.
- Measure it with a near-miss case: a request that shares the new skill's verbs and nouns but belongs to
  a neighbor. That is the case that fails when a description is too broad, and it is the case a plain
  negative example cannot catch.

The measured overlap in this repository, 2026-09-20:

| Token | Skills sharing it |
|---|---|
| `refactor` | 5, including `skill-maker`, `docs-maker`, `prompt-maker`, `readme-maker`, `agent-md-maker` |
| `create` | 12 |

So `skill-maker`'s nearest neighbors are the four skills sharing `refactor`, and the coexistence case
must distinguish a reusable *skill folder* from a reusable *prompt*, *document*, or *instruction file*.

## 8. Scope Boundaries

State what the skill does not own.

Examples:

- use `docs-maker` for generic documentation work
- use `prompt-maker` when the deliverable is a reusable prompt rather than a skill folder
- use `skill-maker` when the output is a skill folder or skill refactor
- use `research` when source-backed fact-finding is the main job
- use `plan` when planning before implementation is the main job
- use `git-commit` when commit creation is the main job

## 9. Anti-Patterns

- vague descriptions
- descriptions that list tools but not the job
- descriptions that list jobs but not trigger timing
- no should-not-trigger examples
- descriptions so broad they overlap neighboring skills
- a trigger case that inherits its `runs` or `threshold` instead of stating them
- reporting only the final validation score, so the selection between iterations is invisible
- growing a description without re-checking the length limit
- no near-miss case, so trigger stealing is never measured

## Sources

> Links checked 2026-09-20.

| Claim | Source |
|---|---|
| The four invocation modes (explicit, implicit, contextual, negative control), the 10-20 prompt starting set, and the four evaluation axes | <https://developers.openai.com/blog/eval-skills> |
| Trigger rate as the metric, 3 runs, the 0.5 default threshold, the train/validation split, "the best may not be the last", the 1024-character re-check, and the structural-change fallback behind `SK-O-1` to `SK-O-4` | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| The 1024-character `description` limit, and `name` matching the parent directory | <https://agentskills.io/specification> |
| The Codex 2% / 8,000-character listing budget, shorten-then-omit, and the omission warning | <https://learn.chatgpt.com/docs/build-skills> |
| The Claude Code 1% listing budget, the 1,536-character per-entry cap, and least-invoked-first dropping | <https://code.claude.com/docs/en/skills> |
| Coexistence as an evaluation dimension and the trigger-stealing failure | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| The `stochastic-model` measurement contract for a measured rate | `instructions/autoresearch/references/config-and-metrics.md` §2 |

### Evidence grade

The optimization rules are `PRIMARY` - the specification site states them directly. The 10-20 prompt
figure is a starting point that source recommends, not a validated optimum, and this file does not state
a required case count for that reason. The 38-skill / 14,641-character figures are measurements of this
repository taken on 2026-09-20, not external claims.
