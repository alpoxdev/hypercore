# Trigger Design

> Korean version: [`trigger-design.ko.md`](trigger-design.ko.md)

The goal of trigger design is to make a skill activate on the work that needs it and stay quietly out of the way otherwise.

## 1. Description authoring rules

A good `description` contains three things.

1. The class of work it performs
2. The situation in which it should be used
3. The boundary to exclude, or the important keywords

Weak example:

```yaml
description: Helps with documentation.
```

Strong example:

```yaml
description: Use this skill when the user asks to create or refactor a reusable Codex skill folder, including SKILL.md trigger wording, rules, references, scripts, assets, and validation checks. Do not use for generic documentation that is not a skill.
```

## 2. Authoring pattern

- Start with "Use this skill when...".
- Lead with user intent. Write the outcome the user wants rather than the internal implementation.
- Put the key keywords near the front. Assume the description may be truncated in a long skill list.
- Do not pack too many jobs into one description.
- Include a short negative boundary.

## 3. Trigger example set

Build trigger examples along **two orthogonal axes**. One is "should it activate," the other is "how is it invoked." They do not replace each other, and only crossing both axes catches real failures.

| Axis | Values | What it verifies |
|---|---|---|
| Activation | positive / negative / boundary | Whether the description responds only to the right requests |
| Invocation mode | explicit / implicit / contextual / negative control | Whether it matches without the name, and does not misfire |

The invocation-mode axis comes from OpenAI's skill eval guide (<https://developers.openai.com/blog/eval-skills>, checked 2026-09-19), whose targeted prompt set distinguishes four invocation cases: **explicit invocation**, **implicit invocation**, **contextual invocation**, and **negative control**. This repository generalizes them into the axis below.

| Invocation mode | Meaning | Example |
|---|---|---|
| explicit | Names the skill directly | `Use $skill-maker to build a skill` |
| implicit | Matches the description in natural language without the name | `Create a reusable skill folder for me` |
| contextual | A real work sentence mixed with domain context | `Make this migration review procedure run identically every time` |
| negative control | A similar request that must not activate | `Clean up this runbook so it reads better` |

Start the dataset at 10-20 prompts, and keep it alive by adding every failure you meet as a regression case.

The positive/negative/boundary sets below are the **activation axis**. Every new or heavily refactored skill keeps examples.

### Positive

- Sentences where a real user should invoke the skill
- Sentences that never mention the official skill name
- Sentences with typos, abbreviations, or mixed Korean and English

### Negative

- Sentences that look similar but belong to a different skill
- General document, planning, or summarization requests
- Simple one-step tasks

### Boundary

- Requests where two skills overlap
- Requests needing an order, such as research followed by skill creation
- Requests needing a follow-on skill, such as commit or deploy
- Requests where a source ledger must come first, such as external research plus skill creation
- Requests needing a safety gate, involving network, credentials, or destructive actions
- Ambiguous requests such as "make the prompt better," where general prompt improvement and reusable skill creation are indistinguishable

## 4. Trigger smoke test

Minimum set. The earlier boolean `should_trigger` is gone: a trigger is probabilistic, so each case carries its own repetition count and threshold, and the run records the resulting rate. See `SKILL_AUTHORING.md` → `## Judgement Rules` for the judgement rules these keys serve.

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p3", "prompt": "Create a new skill folder and include the validation rules", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "b1", "prompt": "Create a guide for writing skills", "expect": "no_trigger", "runs": 3, "threshold": 0.5, "note": "depends on output shape" },
  { "id": "b2", "prompt": "Read the latest papers and build a new skill", "expect": "trigger", "runs": 3, "threshold": 0.5, "note": "after or with a research skill" },
  { "id": "b3", "prompt": "Make this skill run the deploy command automatically", "expect": "trigger", "runs": 3, "threshold": 0.5, "requires_gate": "production_side_effect" }
]
```

A run appends the measured `trigger_rate` to each case, so the result file carries the same four keys plus the outcome:

```json
{ "id": "p1", "expect": "trigger", "runs": 3, "threshold": 0.5, "trigger_rate": 1.0 }
```

**Every case states its own `runs` and `threshold`.** Do not let a case inherit a default: the value must be visible at the point of use, because `runs` changes what the rate means. The cases below are **one example set, not a required count** — each exists because it probes something the others do not, and adding a case that probes nothing new only adds calls:

| Case | What it probes that the others do not |
|---|---|
| `p1` | A plain build request that should fire on the description alone |
| `p2` | A request naming an existing artifact rather than the skill |
| `p3` | A request whose trigger words are spread across the sentence |
| `n1` | A similar verb on an unrelated artifact (negative control) |
| `n2` | A documentation task in the same domain (negative control) |
| `b1` | A request that only becomes skill work depending on the requested output shape |
| `b2` | A request that needs a companion workflow before this skill applies |
| `b3` | A request that must additionally trip a safety gate once active |

Do not pad the set to a target size. A case that probes nothing new adds calls, not evidence.

In a trigger eval, do not look only at prompt wording; also record the companion workflow needed once it activates.

| Boundary | Expected routing |
|---|---|
| research + skill creation | Sourcing and research first, then write the skill from that evidence |
| prompt improvement only | The context-engineering prompt guide; do not create a skill |
| reusable skill folder | Activate skill authoring |
| adding tool permissions | Skill authoring + safety/validation reference |
| includes deploy, commit, or publish | The relevant follow-on skill or a user permission gate |

## 5. Failure patterns

| Failure | Symptom | Fix |
|---|---|---|
| Too broad | The skill activates every time and wastes context | Add negative boundaries |
| Too narrow | It activates only when the user says the skill name | Add user intent and synonyms |
| Implementation-centric | The user stated a purpose but the trigger did not fire | Lead with outcomes rather than tool or file names |
| Ambiguous scope | Conflicts with another skill | Separate owned from not-owned in the routing rule |
| Long description | Only the front survives in the skill list and the core is lost | Compress the key trigger into the first sentence |
| Missing safety gate | Once active, the skill takes external side effects for granted | State gated actions in the description or routing rule |
| Missing prior research | A recency claim is baked straight into the skill | Require a sourcing stage for source-sensitive triggers |

## 6. Completion criteria

- [ ] The first sentence of the description reads as a trigger.
- [ ] Positive, negative, and boundary examples exist (activation axis).
- [ ] Explicit, implicit, contextual, and negative-control examples exist (invocation-mode axis).
- [ ] The difference from similar skills is stated.
- [ ] A should-trigger and should-not-trigger smoke set exists.
- [ ] Boundaries exist for companion workflows such as research, safety, deploy, and commit.

## 7. Description optimization

Writing a description once is not the whole job; repeated edits overfit the examples they were tuned on. These rules are normative.

- SK-O-1: Split the query set into **train and validation**. Improve against train; **select** by validation pass rate.
- SK-O-2: **The best description may not be the last one.** When a later iteration scores lower on validation, keep the earlier iteration.
- SK-O-3: Descriptions grow while you optimize. Re-check the **1024-character limit** on every edit.
- SK-O-4: When fine-tuning stops helping, **change the structure** — a different framing or a different sentence shape, not another adjective.

A run that reports only its final validation score is not evidence of improvement. Report the train and validation numbers for each iteration so the selection is visible.

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| Claim | Source |
|---|---|
| The four invocation modes (explicit, implicit, contextual, negative control) and the 10-20 prompt starting set | <https://developers.openai.com/blog/eval-skills> |
| Trigger rate as the metric, 3 runs, the 0.5 default threshold, the train/validation split, "the best may not be the last", the 1024-character re-check, and the structural-change fallback behind `SK-O-1` to `SK-O-4` | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| The 1024-character `description` limit | <https://agentskills.io/specification> |

### Evidence grade

The optimization rules above are `PRIMARY` — the specification site states them directly. The 10-20 prompt figure is quoted as a starting point that source recommends, not as a validated optimum. The case count in §4 is deliberately not fixed: the source does not state one, so this file states a **composition** requirement instead — each case must probe something the others do not.
