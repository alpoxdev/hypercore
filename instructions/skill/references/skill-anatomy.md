# Skill Anatomy

> Korean version: [`skill-anatomy.ko.md`](skill-anatomy.ko.md)

Skill anatomy defines what responsibility each file carries, more than which files a skill must have.

## 1. Required and optional

| Element | Requirement | Responsibility |
|---|---|---|
| `SKILL.md` | Required | Metadata, trigger, core execution contract, workflow, validation |
| `SKILL.ko.md` | Recommended | Korean user-facing mirror |
| `rules/` | Conditional | Recurring policy, decision rules, checklists |
| `references/` | Conditional | Official doc summaries, detailed knowledge, edge cases, long examples |
| `scripts/` | Conditional | Deterministic helpers, validators, formatters, data transforms |
| `assets/` | Conditional | Templates, schemas, example artifacts, static resources |
| `agents/` | Conditional | OpenAI or specific UI/runtime metadata |

## 2. Frontmatter

Base frontmatter:

```yaml
---
name: skill-name
description: Use this skill when the user asks to ...
compatibility: Optional runtime/dependency requirements.
---
```

### Spec fields and constraints

Per the Agent Skills specification (<https://agentskills.io/specification>, checked 2026-09-19).

| Field | Required | Constraint |
|---|---|---|
| `name` | Required | 1-64 chars. Lowercase `a-z`, digits, and hyphens only. Cannot start or end with a hyphen, and no consecutive hyphens (`--`). **Must match the parent directory name** |
| `description` | Required | 1-1024 chars. Covers both what it does and when to use it |
| `license` | Optional | A license name or a reference to a bundled license file. Keep it short |
| `compatibility` | Optional | 1-500 chars. Only when there are environment requirements such as intended product, system packages, or network access |
| `metadata` | Optional | A string key-value map for properties the spec does not define. Keep keys unique to avoid collisions |
| `allowed-tools` | Optional | A space-separated string of pre-approved tools. **Experimental — support varies between implementations** |

### Progressive disclosure budgets

| Stage | When it loads | Recommended budget |
|---|---|---|
| Metadata | At startup, for every skill | `name` + `description`, roughly 100 tokens |
| Instructions | On skill activation | `SKILL.md` body **under 5,000 tokens** and **under 500 lines** |
| Resources | Only when needed | `scripts/`, `references/`, `assets/` loaded individually |

The Codex runtime caps the listing-stage budget at 2% of context or 8,000 characters (<https://learn.chatgpt.com/docs/build-skills>). Assume `description` may be truncated and put the key trigger up front.

### Rules

- Write `name` in lowercase kebab-case and **match the folder name** (a spec requirement, not a recommendation).
- `description` is a trigger sentence. Do not merely enumerate features.
- Use `compatibility` only when there are runtime, network, system package, or tool requirements. Most skills do not need it.
- `allowed-tools` is Experimental per the spec, so use it only after confirming support in that runtime, and do not enforce it as a shared rule.
- Write file references as paths relative to the skill root and keep them **one level deep**. Do not build deeply nested reference chains.

### Validation tool

The official reference implementation can machine-validate frontmatter and naming conventions.

```bash
skills-ref validate ./my-skill
```

This repository runs `skills-ref validate` through `uvx` across all of `skills/**/SKILL.md` from [`scripts/validate-skills.sh`](../../../scripts/validate-skills.sh).

## 3. Core body responsibility

Keep only the following in `SKILL.md`.

1. Output language / localization contract
2. Purpose
3. Routing rule
4. Instruction contract
5. Activation examples
6. High-level workflow
7. Support-file read order
8. Validation checklist
9. A summary of forbidden and required behavior

Long API detail, many examples, official documentation summaries, and per-environment options must stay out of the core body.

## 4. Rule files responsibility

`rules/` holds "procedural policy that always applies."

Good examples:

- Trigger design criteria
- Resource placement criteria
- Validation checklists
- Anti-patterns
- Rules deciding when to read provider-sensitive guidance

Bad examples:

- Verbatim copies of official documentation
- Repeating the same sentences as the core workflow
- Long examples needed by only one specific task

## 5. References responsibility

`references/` holds detailed knowledge read on demand.

Good examples:

- Summaries of OpenAI and Anthropic official documentation
- API schemas
- Per-framework edge cases
- Long examples
- A domain glossary

Rules:

- Keep each reference focused on one topic.
- Link it from `SKILL.md` together with "when to read it."
- Avoid deep chains where one reference sends you to another.

## 6. Scripts responsibility

Add `scripts/` only when code is more reliable than prose.

Criteria to add:

- The same transform or validation repeats.
- The command sequence is fragile.
- Structured output is required.
- The failure message lets the agent self-correct.

Required documentation:

- How to run it
- Dependencies
- Input and output
- Failure modes
- Version pinning or environment requirements

## 7. Assets responsibility

`assets/` holds copy-or-fill targets needed to produce the artifact.

Examples:

- Report templates
- Schema JSON
- Style guide samples
- Prompt templates
- Fixture data

Assets do not substitute for reasoning. Put their usage conditions and fill rules in `SKILL.md` or `rules/`.

## 8. Quality gate

- [ ] Reading `SKILL.md` alone conveys the purpose, trigger, and completion conditions.
- [ ] Detailed material is split out to load on demand.
- [ ] Support files are referenced directly by relative path.
- [ ] Scripts and assets have a clear reason to exist.
- [ ] Files needing a Korean mirror are structurally synchronized.
