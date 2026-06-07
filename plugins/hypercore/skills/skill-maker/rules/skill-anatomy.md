# Skill Anatomy

**Purpose**: Define the minimum shape and responsibility split for a high-quality skill.

## 1. Minimum Anatomy

A skill starts with `SKILL.md` and may include support files only when they improve triggerability, reliability, reuse, or validation.

Recommended shape:

```text
skill-name/
├── SKILL.md
├── SKILL.ko.md
├── rules/
├── references/
├── scripts/
├── assets/
└── agents/
```

| Element | Requirement | Responsibility |
|---|---|---|
| `SKILL.md` | Required | Metadata, trigger, core execution contract, workflow, validation |
| `SKILL.ko.md` | Repo convention | Korean mirror for local/user-facing use |
| `rules/` | Conditional | Reusable policy, decision criteria, validation checklists, anti-patterns |
| `references/` | Conditional | Official summaries, detailed knowledge, schemas, edge cases, long examples |
| `scripts/` | Conditional | Deterministic helpers, validators, formatters, data transforms |
| `assets/` | Conditional | Templates, fixtures, schemas, static output resources |
| `agents/` | Conditional | Runtime/UI metadata only when a runtime consumes it |

## 2. Frontmatter

Use clear discovery metadata:

```yaml
---
name: skill-name
description: Use this skill when the user asks to ... Do not use for ...
compatibility: Optional runtime/dependency requirements.
---
```

Rules:

- `name` should be lowercase kebab-case and match the folder when possible.
- `description` is trigger guidance, not marketing copy.
- `description` should state both what the skill does and when to use it.
- `compatibility` is optional and should mention real runtime, network, package, tool, or permission constraints.
- Implementation-specific fields such as tool allowlists are optional and must not replace the core instructions.

## 3. Minimum Core Contract

A non-trivial `SKILL.md` should expose:

- output language contract
- purpose
- routing rule
- instruction contract
- activation examples
- trigger conditions or supported targets
- skill architecture or resource model
- workflow
- support-file read order or navigation cues
- required and forbidden behavior
- validation checklist

The instruction contract should make these discoverable: intent, trigger, scope, authority, evidence, tools, output, verification, and stop condition.

## 4. What Belongs in `SKILL.md`

Keep these in the core skill:

- what the skill does
- when to use it and when not to use it
- what outputs or transformations it should produce
- the high-level workflow
- essential authority, safety, and stop-condition boundaries
- pointers to deeper rules or references

Do not turn the core skill into a full knowledge base.

## 5. Language and Mirror Pairing

Write canonical skill markdown in English by default, but require generated user-facing artifacts to default to Korean.

Whenever you create or materially update a markdown file inside a skill folder, maintain a Korean sibling translation:

- `SKILL.md` pairs with `SKILL.ko.md`
- `rules/name.md` pairs with `rules/name.ko.md`
- `references/path/name.md` pairs with `references/path/name.ko.md`

Keep headings, section order, links, and examples structurally aligned across the pair unless localization requires minor wording changes.

## 6. Quality Gate

- [ ] `SKILL.md` explains the skill without reading every support file.
- [ ] Frontmatter supports discovery and trigger selection.
- [ ] Contract fields are discoverable: intent, trigger, scope, authority, evidence, tools, output, verification, stop.
- [ ] Rules hold policy, not bloated reference detail.
- [ ] References hold detail, not core trigger logic.
- [ ] Scripts/assets exist only when justified and documented.
- [ ] Optional metadata is intentionally present or intentionally omitted.
