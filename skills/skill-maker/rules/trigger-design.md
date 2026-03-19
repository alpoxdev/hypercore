# Trigger Design

**Purpose**: Make skills trigger on the right requests and stay out of the way on the wrong ones.

## 1. Description Rules

The `description` must explain:

- what the skill does
- when it should be used
- what kinds of user requests should trigger it

Weak:

```yaml
description: Helps with skills
```

Better:

```yaml
description: Create and refactor Codex skills, including SKILL.md, rules, references, scripts, assets, and trigger/validation guidance.
```

## 2. Trigger Examples

Include realistic user utterances in the body or examples:

- "Make a skill for reviewing SQL migrations"
- "Refactor this skill so it loads references correctly"
- "Create a new Codex skill for browser-based QA"

Negative examples:

- "Rewrite this runbook for clarity"
- "Summarize these OpenAI docs"

Boundary examples:

- "Create a guide for writing skills"
- "Refactor this skill and then commit it"

## 3. Scope Boundaries

State what the skill does not own.

For example:

- use `docs-maker` for generic documentation work
- use `skill-maker` when the output is a skill folder or skill refactor
- use `research` when the main job is fact-finding
- use `plan` when the main job is planning before implementation
- use `git-commit` when the main job is creating the commit

## 4. Trigger Validation

Check whether the description would:

- trigger on target requests
- avoid unrelated requests
- remain understandable without reading the whole skill body

## 5. Anti-Patterns

- vague descriptions
- descriptions that list tools but not the job
- descriptions that list jobs but not trigger timing
- descriptions so broad they overlap every meta-skill
