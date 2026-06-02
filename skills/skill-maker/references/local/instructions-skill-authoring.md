# Local Instructions: Skill Authoring Baseline

Source provenance:

- Root instruction map: `../../../../instructions/README.md`
- Skill authoring guide: `../../../../instructions/skill/SKILL_AUTHORING.md`
- References: `../../../../instructions/skill/references/*.md`
- Research report: `../../../../.hypercore/research/2026-06-02-official-skill-authoring-instructions.md`

Use this reference as the project-local baseline when creating or refactoring skills in this repository. It summarizes the root instructions so `skill-maker` can stay self-contained without treating external provider docs as higher authority.

## Core model

A skill is a triggerable execution package, not just a prompt. It should define:

| Axis | Required question |
|---|---|
| Intent | What repeatable outcome does the skill improve? |
| Trigger | Which user requests should activate it, and which should not? |
| Scope | Which files, actions, and outputs does the skill own? |
| Authority | What wins when user, project, provider, existing skill, and retrieved content conflict? |
| Workflow | What should the agent read, decide, and do in order? |
| Resources | Which details, templates, scripts, or assets are loaded only when needed? |
| Verification | How is trigger, execution, output, and safety correctness proven? |
| Stop condition | When is the skill done, blocked, or escalated? |

## Required authoring posture

- Local project instructions come first.
- `description` is trigger guidance, not marketing copy.
- The core `SKILL.md` stays lean.
- Reusable policy goes in `rules/`.
- Detailed knowledge and official summaries go in `references/`.
- Deterministic helpers go in `scripts/` only when they improve reliability.
- Output templates and static resources go in `assets/`.
- Validation is part of the skill, not an afterthought.
- User-facing outputs default to Korean in this repository.

## Minimum `SKILL.md` contract

Every non-trivial skill should expose:

- output language contract
- purpose
- routing rule
- instruction contract
- activation examples
- workflow
- support-file read order or navigation cue
- validation checklist
- forbidden/required behavior summary when relevant

## Trigger baseline

A new or materially changed skill should include:

- at least 3 positive examples
- at least 2 negative examples
- at least 1 boundary example
- `description` that states both what the skill does and when to use it
- a boundary against neighboring skills such as `docs-maker`, `research`, `plan`, and `git-commit`

## Placement baseline

| Content | Placement |
|---|---|
| Job, trigger, top-level workflow, stop condition | `SKILL.md` |
| Reusable policy and repeated decision criteria | `rules/` |
| Official docs, schemas, domain detail, long examples | `references/` |
| Deterministic validators, formatters, data transforms | `scripts/` |
| Templates, fixtures, static output resources | `assets/` |
| Runtime or UI metadata | `agents/` only when consumed |

## Validation baseline

Before completion, verify:

- frontmatter and folder anatomy
- trigger positives, negatives, and boundaries
- support-file links and code fences
- contract discoverability: intent, trigger, scope, authority, evidence, tools, output, verification, stop
- resource placement and one-level navigation
- script usage/dependencies/failure handling when scripts exist
- safety gates for credential, network, destructive, production, or broad permission actions
- source ledger or claim-source mapping for provider-sensitive/current claims
