# Validation

Run these checks before declaring `git-maker` changes complete or before reporting a fast-path run as successful.

## Skill Quality Checks

- Description says this skill commits and pushes together, and distinguishes it from `git-commit` and `git-push`.
- At least 3 positive trigger examples exist.
- At least 2 negative trigger examples exist.
- At least 1 boundary example exists.
- Core `SKILL.md` stays lean and points directly to rules/scripts without duplicating them.
- Script additions are justified by deterministic speed or safety improvements.

## Runtime Checks

- `bash -n scripts/git-maker-fast.sh` passes.
- `scripts/git-maker-fast.sh inspect . --jobs 2` emits `repos|begin`, `repo-status|begin`, and file inventory blocks.
- Push helper is not tested against a real remote unless the user asked to push; use local fixtures when validating behavior.
- Commit phase still uses targeted staging and one logical change per commit.
- Push phase is automatic only after all commit groups succeed.
- Force push remains blocked for `main` and `master`.

## Readback Checks

Read as:

1. a trigger model: the skill activates on commit+push, not commit-only or push-only.
2. a rushed operator: the fastest safe command is obvious.
3. a maintainer: future speed rules belong in `rules/speed-and-automation.md`; durable commit policy belongs in `rules/commit-and-push-policy.md`.
