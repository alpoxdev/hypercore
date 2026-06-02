# Skill Anatomy

**Purpose**: Define the minimum shape and placement rules for a high-quality skill.

## 1. Minimum Anatomy

A skill should start with:

- `SKILL.md`
- zero or more rule files
- zero or more references
- scripts or assets only when they materially improve reliability or reuse
- optional UI metadata such as `agents/openai.yaml` when the runtime or UI needs it

Recommended shape:

```text
skill-name/
├── SKILL.md
├── SKILL.ko.md
├── rules/
│   ├── ...
│   └── example.ko.md
├── references/
│   ├── ...
│   └── example.ko.md
├── agents/
│   └── openai.yaml
├── scripts/
│   └── ...
└── assets/
    └── ...
```

## 2. What Belongs in `SKILL.md`

Keep these in the core skill:

- what the skill does
- when to use it
- what outputs or transformations it should produce
- the high-level workflow
- pointers to deeper rules or references

Do not turn the core skill into a full knowledge base.

## 3. Markdown Language and Translation Pairing

Write canonical skill markdown in English by default, but require generated user-facing artifacts to default to Korean.

Whenever you create or materially update a markdown file inside a skill folder, maintain a Korean sibling translation:

- `SKILL.md` pairs with `SKILL.ko.md`
- `rules/name.md` pairs with `rules/name.ko.md`
- `references/path/name.md` pairs with `references/path/name.ko.md`

Keep the English file as the source of truth. Keep headings, section order, links, and examples structurally aligned in the Korean translation unless localization requires a small wording adjustment. Add an `<output_language>` section near the top of every core skill so agents loading either entrypoint know that deliverables, reports, generated docs, summaries, and validation notes should be Korean by default.

## 4. What Belongs in Rules

Put these in `rules/`:

- reusable policy
- decision criteria
- repeated patterns
- validation checklists
- anti-patterns

Rules should support the core skill, not restate it verbatim.

## 5. What Belongs in References

Put these in `references/`:

- domain detail
- official documentation summaries
- schemas
- framework-specific notes
- provider-sensitive information

References are for information that should be loaded only when needed.

## 6. What Belongs in Scripts or Assets

Use `scripts/` when:

- deterministic execution is better than prose
- the same code would otherwise be rewritten repeatedly
- the workflow is fragile and benefits from automation

Use `assets/` when:

- output resources should be copied, filled, or reused
- the files support output rather than reasoning

## 7. Optional UI Metadata

Use UI metadata such as `agents/openai.yaml` when:

- the environment displays skills in a picker, chip list, or UI card
- the runtime expects interface metadata separate from `SKILL.md`

Omit it when:

- the environment does not consume it
- it would duplicate unsupported or stale metadata
- the skill is still too unstable to justify UI-facing defaults

UI metadata should summarize the skill, not replace the core skill instructions.

## 8. Quality Checks

- [ ] The core `SKILL.md` explains the skill without reading every support file
- [ ] Canonical markdown is in English, each new or materially changed `*.md` file has a matching Korean `*.ko.md` translation, and the core skill has a Korean-by-default `<output_language>` contract
- [ ] Rules hold policy, not bloated reference detail
- [ ] References hold detail, not core trigger logic
- [ ] Scripts/assets exist only when justified
- [ ] Optional UI metadata is either intentionally present or intentionally omitted
