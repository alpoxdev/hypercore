---
name: version-update
description: "[Hyper] Update semantic versions across node/rust/python projects, keep discovered version files synchronized, and prefer the installed `git-commit` skill for the final git step with a direct fallback when it is unavailable."
allowed-tools: Bash Read Edit
compatibility: Requires a git repository and scripts under skills/version-update/scripts. Detects `git-commit` only from repository-local skill paths such as `skills/git-commit`, `.agents/skills/git-commit`, `.claude/skills/git-commit`, or `.codex/skills/git-commit` before choosing the final git path.
---

# Version Update Skill

> Cross-stack semantic version update for node/rust/python with conditional `git-commit` handoff.

<purpose>

- Update one semantic version across node, rust, and python version-bearing files.
- Keep discovered manifest files and inline version markers synchronized.
- Prefer the installed `git-commit` skill for the final git add/commit/push flow.
- Fall back to local direct git execution only when `git-commit` is unavailable.

</purpose>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "bump this package to 1.4.0" | yes |
| "update the version and commit it" | yes |
| "increase patch version for this crate" | yes |
| "just make a git commit" | no, use `git-commit` |
| "rewrite this release runbook" | no |

</trigger_conditions>

<supported_targets>

- `package.json`
- `Cargo.toml`
- `pyproject.toml`
- `setup.py`
- python `__version__` declarations
- inline `.version('x.y.z')` code patterns

</supported_targets>

<scripts>

## Available scripts

| Script | Purpose |
|------|------|
| `scripts/stack-detect.sh` | Detect stacks (`node`, `rust`, `python`) |
| `scripts/version-find.sh [--plain]` | Discover version-bearing files |
| `scripts/version-current.sh [file]` | Extract current semver (`file|version`) |
| `scripts/version-bump.sh <current> <type>` | Calculate next semver |
| `scripts/version-apply.sh <new> [files...]` | Apply version to discovered/selected files |
| `scripts/git-commit-detect.sh` | Detect whether a usable project-local `git-commit` skill exists in repository skill directories |
| `scripts/git-commit.sh "msg" [files]` | Fallback direct commit helper when `git-commit` is not installed |
| `scripts/git-push.sh` | Fallback direct push helper when `git-commit` is not installed |

</scripts>

<git_integration>

- Run `scripts/git-commit-detect.sh` before the final git step.
- The detector checks, in order: `skills/git-commit`, `.agents/skills/git-commit`, `.claude/skills/git-commit`, and `.codex/skills/git-commit` inside the current repository.
- Use `git-commit` only when the detector returns `installed|...`.
- When handing off to `git-commit`, pass only the files changed by `version-update` and use `chore: bump version to x.y.z` unless the user requested a different message.
- If the detector returns `missing|...`, use the local fallback scripts in `skills/version-update/scripts/`.
- If the user asked for version-only work, stop after the version files and diff review. Do not commit or push.
- If push is requested and the detector returns `installed|...`, let `git-commit` own push confirmation. Otherwise use `scripts/git-push.sh` only after explicit user request.

</git_integration>

<version_rules>

| Argument | Action | Example |
|------|------|------|
| `+1` / `+patch` | Patch +1 | `0.1.13 -> 0.1.14` |
| `+minor` | Minor +1 | `0.1.13 -> 0.2.0` |
| `+major` | Major +1 | `0.1.13 -> 1.0.0` |
| `x.y.z` | Explicit set | `0.1.13 -> 2.0.0` |

</version_rules>

<workflow>

## Workflow

```bash
# 1) detect stack(s)
scripts/stack-detect.sh

# 2) find version-bearing files
scripts/version-find.sh

# 3) read current version
scripts/version-current.sh
# output: <file>|<version>

# 4) compute next version
scripts/version-bump.sh 1.2.3 +minor
# -> 1.3.0

# 5) apply to all discovered files (or selected files)
scripts/version-apply.sh 1.3.0

# 6) review the final diff and changed file list
git diff --stat
git diff

# 7) detect whether a git-commit skill is actually usable
scripts/git-commit-detect.sh
# -> installed|/abs/path/to/current-repo/skills/git-commit
# or missing|comma,separated,current-repo,paths|reason

# 8a) if git-commit is installed and usable, hand off the git step to that skill
# target message: chore: bump version to 1.3.0

# 8b) otherwise, use the local fallback
scripts/git-commit.sh "chore: bump version to 1.3.0" package.json

# 9) optional push only when explicitly requested
scripts/git-push.sh
```

</workflow>

<stack_targets>

| Stack | Primary files | Additional patterns |
|------|------|------|
| Node | `package.json` | `.version('x.y.z')` in code |
| Rust | `Cargo.toml` (`[package].version`) | `.version('x.y.z')` in code |
| Python | `pyproject.toml`, `setup.py`, `__version__` in `.py` | `.version('x.y.z')` in code |

</stack_targets>

<required>

| Category | Required |
|------|------|
| Input | Parse ARGUMENT as bump rule or explicit semver |
| Discovery | Run `version-find.sh` before applying updates |
| Current state | Read the current version with `version-current.sh` before computing the target version |
| Consistency | Keep all discovered version files synchronized |
| Git detection | Run `scripts/git-commit-detect.sh` before choosing the git path |
| Git scope | If handing off to `git-commit`, constrain it to the version-update file set |
| Safety | Use conventional commit message (`chore: bump version to x.y.z`) unless the user requests otherwise |
| Git | Keep git write operations sequential |

</required>

<scope_boundaries>

- `version-update` owns version discovery, target calculation, file updates, and diff review.
- `git-commit` owns repository inspection, staging discipline, commit creation, and push confirmation when the detector confirms that a repository-local skill is usable.
- The local git scripts are fallback helpers, not the preferred path when `git-commit` is available.

</scope_boundaries>

<examples>

## Positive triggers

- "bump this repo from 0.8.2 to 0.9.0 and commit it"
- "increase the patch version for this Python package"
- "update package.json and Cargo.toml to 2.0.0"

## Negative triggers

- "make a git commit for these docs changes"
- "summarize our release process"

## Boundary trigger

- "update the version only, do not commit yet"

</examples>

<validation>

Trigger checks:

- [ ] At least 3 positive trigger examples remain valid
- [ ] At least 2 negative trigger examples stay out of scope
- [ ] At least 1 boundary example stays explicit about commit vs no-commit

Execution checklist:

- [ ] Current version identified with `version-current.sh`
- [ ] Target version computed via `version-bump.sh` (or explicit semver validated)
- [ ] `version-apply.sh` updated all intended files
- [ ] `git diff` reviewed
- [ ] `scripts/git-commit-detect.sh` run before choosing the git path
- [ ] The detector searched only `skills/git-commit`, `.agents/skills/git-commit`, `.claude/skills/git-commit`, and `.codex/skills/git-commit` inside the current repository
- [ ] If the detector returns `installed|...`, the final git step is handed off with the narrowed version-update scope
- [ ] If the detector returns `missing|...`, the fallback `scripts/git-commit.sh` is used with only the version-update files
- [ ] Optional push executed only when requested

Forbidden:

- [ ] Starting updates without reading current version
- [ ] Updating only one file when multiple version files exist
- [ ] Using the fallback git scripts when the detector already returned `installed|...` without reason
- [ ] Force-pushing protected branches

</validation>
