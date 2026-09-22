---
name: version-update
description: "[Hyper] Update semantic versions across node/rust/python projects, keep discovered version files synchronized, and use this skill's Bun MJS helpers for optional commits and pushes."
allowed-tools: Bash Read Edit
compatibility: Requires Bun, a git repository, and MJS scripts under skills/version-update/scripts.
---

# Version Update Skill

> Cross-stack semantic version update for node/rust/python with direct optional git operations.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, coordination notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Update one semantic version across node, rust, and python version-bearing files.
- Keep discovered manifest files and inline version markers synchronized.
- Use this skill's direct git helpers for requested commit and push operations.

</purpose>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Update synchronized semantic versions across supported project files. |
| Trigger | Activate on version bump/set requests, especially when the user asks to update versions and optionally commit them. |
| Scope | Own stack detection, version-file discovery, target-version calculation, version application, diff review, and requested git operations. |
| Authority | User and project instructions outrank this skill; discovered version files, semver rules, script output, and diffs are evidence. |
| Evidence | Use Bun MJS helpers, target argument parsing, and `git diff` before git writes. |
| Tools | Use `bun scripts/*.mjs` helpers and local file edits; use this skill's direct git helpers only when requested. |
| Loop | None. One pass per request: detect the stack, discover the version files, read the current version, compute the target, apply it, review the diff, then stop. Re-invoke only when the user asks for another version change. |
| Output | Korean report of current version, target version, changed files, commit/push status, and caveats. |
| Verification | Confirm all intended version files changed consistently, review diff, and execute optional git steps only when requested. |
| Stop condition | Stop when version files are updated and reviewed, or when requested git steps are completed or blocked with evidence. |

</instruction_contract>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "bump this package to 1.4.0" | yes |
| "update the version and commit it" | yes |
| "increase patch version for this crate" | yes |
| "just make a git commit" | no |
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
| `bun scripts/stack-detect.mjs` | Detect stacks (`node`, `rust`, `python`) |
| `bun scripts/version-find.mjs [--plain]` | Discover version-bearing files |
| `bun scripts/version-current.mjs [file]` | Extract current semver (`file|version`) |
| `bun scripts/version-bump.mjs <current> <type>` | Calculate next semver |
| `bun scripts/version-apply.mjs <new> [files...]` | Apply version to discovered/selected files |
| `bun scripts/git-commit.mjs "msg" [files]` | Directly commit the specified version-update files |
| `bun scripts/git-push.mjs` | Directly push after an explicit user request |

</scripts>

<git_integration>

- If the user asked for version-only work, stop after the version files and diff review. Do not commit or push.
- For a requested commit, run `bun scripts/git-commit.mjs "chore: bump version to x.y.z" [files...]` with only the files changed by `version-update`, unless the user requested a different message.
- For a requested push, run `bun scripts/git-push.mjs` only after the commit succeeds and the user explicitly requested push.
- Keep git write operations sequential.

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
bun scripts/stack-detect.mjs

# 2) find version-bearing files
bun scripts/version-find.mjs

# 3) read current version
bun scripts/version-current.mjs
# output: <file>|<version>

# 4) compute next version
bun scripts/version-bump.mjs 1.2.3 +minor
# -> 1.3.0

# 5) apply to all discovered files (or selected files)
bun scripts/version-apply.mjs 1.3.0

# 6) review the final diff and changed file list
git diff --stat
git diff

# 7) optional commit only when explicitly requested
bun scripts/git-commit.mjs "chore: bump version to 1.3.0" package.json

# 8) optional push only when explicitly requested
bun scripts/git-push.mjs
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
| Discovery | Run `bun scripts/version-find.mjs` before applying updates |
| Current state | Read the current version with `bun scripts/version-current.mjs` before computing the target version |
| Consistency | Keep all discovered version files synchronized |
| Git scope | Commit only the version-update file set |
| Safety | Use conventional commit message (`chore: bump version to x.y.z`) unless the user requests otherwise |
| Git | Use `bun scripts/git-commit.mjs` and `bun scripts/git-push.mjs` only for requested git writes, sequentially |

</required>

<scope_boundaries>

- `version-update` owns version discovery, target calculation, file updates, diff review, and requested git operations.
- Commit only files changed by `version-update`.

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

- [ ] Current version identified with `bun scripts/version-current.mjs`
- [ ] Target version computed via `bun scripts/version-bump.mjs` (or explicit semver validated)
- [ ] `bun scripts/version-apply.mjs` updated all intended files
- [ ] `git diff` reviewed
- [ ] Requested commit used `bun scripts/git-commit.mjs` with only the version-update files
- [ ] Requested push used `bun scripts/git-push.mjs` only after a successful commit

Forbidden:

- [ ] Starting updates without reading current version
- [ ] Updating only one file when multiple version files exist
- [ ] Committing files outside the version-update file set
- [ ] Force-pushing protected branches

</validation>
