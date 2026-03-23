# Skill Refactor Guide

Use this reference when autoresearch failures come from the target skill's structure rather than a single missing instruction.

This guide adapts the local `skill-maker` patterns for use inside autoresearch runs.

## 1. Recognize Structural Failures

Common signs that the target skill needs anatomy work:

- the `description` is too vague to trigger reliably
- the core `SKILL.md` has become a mini-wiki
- detailed knowledge is trapped in the core with no support files
- repeated policy is duplicated across sections
- validation is weak or missing
- the next file to read is unclear for a future maintainer

## 2. Refactor by Layer

Use this split:

- `SKILL.md` for the owned job, trigger, high-level workflow, and support-file pointers
- `rules/` for reusable policy, decision criteria, validation, and anti-patterns
- `references/` for detailed knowledge, schemas, long examples, and provider-sensitive detail
- `scripts/` only when deterministic execution is more reliable than prose

Do not solve a structure problem by pouring more prose into the core file.

## 3. Fix Trigger Wording Early

If the skill is triggering poorly:

- rewrite the `description` so it says what the skill does and when it should be used
- add positive, negative, and boundary examples
- state what neighboring skill should own out-of-scope requests

Trigger quality often improves more than any deeper prompt tweak.

## 4. Keep the Core Lean

Good signals:

- the first screen explains the skill's job and boundary
- the workflow is legible without opening every support file
- detailed examples and schemas live elsewhere

Bad signals:

- long blocks of examples in the core
- official doc summaries in the core
- repeated definitions across core and references

## 5. Prefer One-Level Support Files

Link support files directly from `SKILL.md`.

Avoid:

- deep chains of references
- support files that only point to more support files
- extra documents like `README.md` or `QUICK_REFERENCE.md` with duplicated content

## 6. Structural Mutation Ideas

When anatomy is the bottleneck, try mutations like:

- move validation rules into `rules/`
- move output schemas and long examples into `references/`
- shorten a bloated section and replace it with one direct pointer
- add one clear scope boundary with a neighboring skill
- remove duplicated guidance that makes the core heavier without changing behavior

## 7. Structural Checks During Autoresearch

Ask:

- would a new maintainer know where to put the next detail?
- would a trigger model understand the boundary from metadata plus the first screen?
- would an agent under context pressure know what to read next?

If the answer is no, spend an experiment on structure before adding more behavioral instructions.
