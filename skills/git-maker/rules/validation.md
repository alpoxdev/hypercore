# Validation

Run these checks before declaring `git-maker` changes complete or before reporting a fast-path run as successful.

## Skill Quality Checks

- Description says this skill commits and pushes together, and distinguishes it from `git-commit` and `git-push`.
- At least 3 positive trigger examples exist.
- At least 2 negative trigger examples exist.
- At least 1 boundary example exists.
- Core `SKILL.md` stays lean and points directly to rules/scripts without duplicating them.
- Script additions are justified by deterministic speed or safety improvements.
- Agent parallelism guidance is isolated in `rules/agent-parallelism.md` and not duplicated in the core.
- Worktree guidance is explicit: linked worktrees are valid contexts, checkout roots stay separate, and `.git` is not assumed to be a directory.

## Runtime Checks

- `bash -n scripts/git-maker-fast.sh` passes.
- `scripts/git-maker-fast.sh inspect . --jobs 2` emits `repos|begin`, `repo-status|begin`, and file inventory blocks.
- A local linked-worktree fixture, when practical, shows `worktree|linked` and a `repo|...` path at the linked checkout root.
- Push helper is not tested against a real remote unless the user asked to push; use local fixtures when validating behavior.
- Commit phase still uses targeted staging and one logical change per commit.
- Commit subjects read like neutral Conventional Commit summaries, not Korean command-style imperatives.
- Push phase is automatic only after all commit groups succeed.
- Force push remains blocked for `main` and `master`.
- If subagents were used, their work was read-only and final git mutations stayed with the main integrator.

## Readback Checks

Read as:

1. a trigger model: the skill activates on commit+push, not commit-only or push-only.
2. a rushed operator: the fastest safe command is obvious.
3. a commit reviewer: generated Korean subjects look like concise change/result summaries, not instructions.
4. a maintainer: future speed rules belong in `rules/speed-and-automation.md`; durable commit policy belongs in `rules/commit-and-push-policy.md`; subagent lane rules belong in `rules/agent-parallelism.md`.
