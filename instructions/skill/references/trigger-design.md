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

Minimum set:

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "should_trigger": true },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "should_trigger": true },
  { "id": "p3", "prompt": "Create a new skill folder and include the validation rules", "should_trigger": true },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "should_trigger": false },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "should_trigger": false },
  { "id": "b1", "prompt": "Create a guide for writing skills", "should_trigger": "depends_on_output_shape" },
  { "id": "b2", "prompt": "Read the latest papers and build a new skill", "should_trigger": "after_research_or_with_research_skill" },
  { "id": "b3", "prompt": "Make this skill run the deploy command automatically", "should_trigger": true, "requires_gate": "production_side_effect" }
]
```

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
