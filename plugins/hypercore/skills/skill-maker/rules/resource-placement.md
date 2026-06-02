# Resource Placement

**Purpose**: Decide where new skill content belongs before adding it.

## Decision Order

Ask these in order:

1. Is this the core identity or trigger of the skill?
2. Is this reusable policy?
3. Is this detailed knowledge loaded only when needed?
4. Is this better as deterministic execution?
5. Is this an output resource rather than reasoning context?

## Placement Rules

- Put it in `SKILL.md` if it defines the skill's job, trigger, or top-level workflow.
- Put it in `rules/` if it is reusable policy, validation, or repeated decision guidance.
- Put it in `references/` if it is detailed knowledge, official documentation, schemas, or variant-specific notes.
- Put it in `scripts/` if deterministic execution is more reliable than prose.
- Put it in `assets/` if the file supports output generation rather than reasoning.

## Quick Tests

- If removing it would make the skill's job unclear, it probably belongs in `SKILL.md`.
- If it explains how to decide repeatedly, it probably belongs in `rules/`.
- If it is large and optional, it probably belongs in `references/`.
- If it is procedural and fragile, it may belong in `scripts/`.
- If it is copied, filled, or embedded into output, it probably belongs in `assets/`.
