# Trigger Design

**Purpose**: Make skills trigger on the right requests and stay out of the way on the wrong ones.

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

## 2. Writing Pattern

- Start with `Use this skill when...` when the runtime accepts prose descriptions.
- Put user intent and outcome before internal implementation details.
- Put the most important trigger terms early.
- Include a short negative boundary when the skill has close neighbors.
- Avoid descriptions so broad they overlap every meta-skill.

## 3. Trigger Example Set

Include realistic user utterances:

Positive examples:

- "Make a skill for reviewing SQL migrations."
- "Refactor this skill so it loads references correctly."
- "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘."

Negative examples:

- "Rewrite this runbook for clarity."
- "Summarize these OpenAI docs."
- "Create a prompt, not a skill folder."

Boundary examples:

- "Create a guide for writing skills."
- "Research the latest skill docs and update this skill."
- "Refactor this skill and then commit it."

## 4. Trigger Smoke Test

For new or materially changed skills, keep a small smoke set:

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "should_trigger": true },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "should_trigger": true },
  { "id": "p3", "prompt": "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘", "should_trigger": true },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "should_trigger": false },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "should_trigger": false },
  { "id": "b1", "prompt": "Create a guide for writing skills", "should_trigger": "depends_on_output_shape" }
]
```

## 5. Scope Boundaries

State what the skill does not own.

Examples:

- use `docs-maker` for generic documentation work
- use `skill-maker` when the output is a skill folder or skill refactor
- use `research` when source-backed fact-finding is the main job
- use `plan` when planning before implementation is the main job
- use `git-commit` when commit creation is the main job

## 6. Anti-Patterns

- vague descriptions
- descriptions that list tools but not the job
- descriptions that list jobs but not trigger timing
- no should-not-trigger examples
- descriptions so broad they overlap neighboring skills
