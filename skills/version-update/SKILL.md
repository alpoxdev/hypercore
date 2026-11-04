---
name: version-update
description: "[Hyper] Use this skill when the user asks to bump, set, or synchronize a semantic version across a node, rust, or python project, or to commit and push exactly the files that version change touched. Do not use it for a commit with no version change, a release plan or changelog, or a dependency upgrade that leaves the project version alone."
compatibility: Requires Bash 3.2+ with the scripts under skills/version-update/scripts and a local git repository for the optional commit and push.
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

<routing_rule>

Use this skill when the deliverable is a version change across the project's version-bearing files, with an optional commit and push of exactly those files.

Route away when the deliverable has another shape:

| Requested output | Where it belongs |
|---|---|
| A commit with no version change | a commit request, not a version update |
| A release plan, changelog, or tag strategy with no version edit | release planning |
| A dependency upgrade that changes a manifest but not the project version | dependency work |
| A version check whose only output is the current number | a read-only version report |

</routing_rule>

<activation_examples>

Positive:

- "bump this repo from 0.8.2 to 0.9.0 and commit it"
- "increase the patch version for this Python package"
- "update package.json and Cargo.toml to 2.0.0"

Negative:

- "make a git commit for these docs changes"
- "summarize our release process"

Boundary:

- "update the version only, do not commit yet"

</activation_examples>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "bump this package to 1.4.0" | yes |
| "update the version and commit it" | yes |
| "increase patch version for this crate" | yes |
| "just make a git commit" | no |
| "rewrite this release runbook" | no |

</trigger_conditions>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Update synchronized semantic versions across supported project files. |
| Trigger | Activate on version bump/set requests, especially when the user asks to update versions and optionally commit them. |
| Scope | Own stack detection, version-file discovery, target-version calculation, version application, diff review, and requested git operations. |
| Authority | User and project instructions outrank this skill; discovered version files, semver rules, script output, and diffs are evidence. |
| Evidence | Use the bash helpers, target argument parsing, and `git diff` before git writes. |
| Tools | Use `bash scripts/*.sh` helpers and local file edits; use this skill's direct git helpers only when requested. |
| Loop | None. One pass per request: detect the stack, discover the version files, read the current version, compute the target, apply it, review the diff, then stop. Re-invoke only when the user asks for another version change. |
| Output | Korean report of current version, target version, changed files, commit/push status, and caveats. |
| Verification | Confirm all intended version files changed consistently, review diff, and execute optional git steps only when requested. |
| Stop condition | Stop when version files are updated and reviewed, or when requested git steps are completed or blocked with evidence. |

</instruction_contract>

<skill_architecture>

- Core (`SKILL.md`): trigger, contract, version rules, helper order, and the git boundary.
- Scripts: the seven bash helpers in `<scripts>`, the only execution surface; each is documented there with its purpose and argument shape.
- Assets: `assets/evals/version-update-cases.jsonl`, the trigger and behavior cases.
- No rules or references: the procedure fits in the core, and a copied semver summary would drift from the helpers that apply it.

</skill_architecture>

<loop_policy>

No loop. One pass per request: detect, discover, read, compute, apply, review, then the requested git step. A mis-typed argument or an unsupported stack stops with the helper's error; it does not start a retry cycle. Re-invoke only for another version change.

</loop_policy>

<language_and_translation_default>

- Canonical package files are English; every `*.ko.md` is a structurally aligned Korean translation of the same rules.
- Deliverables follow `<output_language>`: Korean by default, with identifiers, commands, paths, and commit messages in their original form.

</language_and_translation_default>

<reference_routing>

- Read `<scripts>` before the first helper run: it carries each helper's purpose, arguments, and output.
- Read `<workflow>` for the order to run them in, and `<version_rules>` when the user's argument is a bump rule rather than an explicit version.
- Read `assets/evals/version-update-cases.jsonl` only when changing a trigger, a version rule, or the git boundary.

</reference_routing>

<support_file_read_order>

1. This core, for the trigger boundary, the contract, and the version rules.
2. `<scripts>` before running any helper.
3. `<workflow>` while running, so each step's evidence is collected as it happens.
4. `<validation>` before reporting.

</support_file_read_order>

<scripts>

| Script | Purpose |
|------|------|
| `bash scripts/stack-detect.sh` | Detect stacks (`node`, `rust`, `python`) |
| `bash scripts/version-find.sh [--plain]` | Discover version-bearing files |
| `bash scripts/version-current.sh [file]` | Extract current semver (`file|version`) |
| `bash scripts/version-bump.sh <current> <type>` | Calculate next semver |
| `bash scripts/version-apply.sh <new> [files...]` | Apply version to discovered/selected files |
| `bash scripts/git-commit.sh "msg" [files]` | Directly commit the specified version-update files |
| `bash scripts/git-push.sh` | Directly push after an explicit user request |

Run every helper from the target root with Bash 3.2+ and git. Each prints its result to stdout and exits non-zero with a usage or format error on invalid input: `version-bump.sh` rejects a version that is not `x.y.z` and a bump that is not `+1`, `+patch`, `+minor`, `+major`, or an explicit `x.y.z`, `version-current.sh` prints `<file>|<version>`, `version-find.sh --plain` prints bare paths, and `git-commit.sh` stages only the paths it was given and aborts on unrelated staged changes.

</scripts>

<version_rules>

| Argument | Action | Example |
|------|------|------|
| `+1` / `+patch` | Patch +1 | `0.1.13 -> 0.1.14` |
| `+minor` | Minor +1 | `0.1.13 -> 0.2.0` |
| `+major` | Major +1 | `0.1.13 -> 1.0.0` |
| `x.y.z` | Explicit set | `0.1.13 -> 2.0.0` |

</version_rules>

<stack_targets>

| Stack | Primary files | Additional patterns |
|------|------|------|
| Node | `package.json` | `.version('x.y.z')` in code |
| Rust | `Cargo.toml` (`[package].version`) | `.version('x.y.z')` in code |
| Python | `pyproject.toml`, `setup.py`, `__version__` in `.py` | `.version('x.y.z')` in code |

</stack_targets>

<git_integration>

- If the user asked for version-only work, stop after the version files and diff review. Do not commit or push.
- For a requested commit, run `bash scripts/git-commit.sh "chore: bump version to x.y.z" [files...]` with only the files changed by `version-update`, unless the user requested a different message.
- For a requested push, run `bash scripts/git-push.sh` only after the commit succeeds and the user explicitly requested push.
- Keep git write operations sequential.

</git_integration>

<workflow>

| Phase | Action | Evidence that ends the phase |
|---|---|---|
| 1. Detect | Run `bash scripts/stack-detect.sh` from the target root | The stacks it prints, or the unsupported-stack stop |
| 2. Discover | Run `bash scripts/version-find.sh` | The version-bearing files |
| 3. Read current | Run `bash scripts/version-current.sh [file]` | The `<file>|<version>` line |
| 4. Compute target | Run `bash scripts/version-bump.sh <current> <type>` | The target version |
| 5. Apply | Run `bash scripts/version-apply.sh <new> [files...]` | Every intended file carrying the new version |
| 6. Review | Run `git diff --stat` and `git diff` | The diff read, with only intended files changed |
| 7. Commit, when requested | Run `bash scripts/git-commit.sh` with the message and files | The commit touching only the version files |
| 8. Push, when requested | Run `bash scripts/git-push.sh` after a successful commit | The push result |

</workflow>

<required>

| Category | Required |
|------|------|
| Input | Parse ARGUMENT as bump rule or explicit semver |
| Discovery | Run `bash scripts/version-find.sh` before applying updates |
| Current state | Read the current version with `bash scripts/version-current.sh` before computing the target version |
| Consistency | Keep all discovered version files synchronized |
| Git scope | Commit only the version-update file set |
| Safety | Use conventional commit message (`chore: bump version to x.y.z`) unless the user requests otherwise |
| Git | Use `bash scripts/git-commit.sh` and `bash scripts/git-push.sh` only for requested git writes, sequentially |

</required>

<forbidden>

| Category | Forbidden |
|------|------|
| State | Applying an update without reading the current version |
| Consistency | Updating one version file while the others keep the old version |
| Git scope | Committing files outside the version-update file set |
| Git safety | Force-pushing a protected branch, or pushing when the commit failed |
| Authority | Committing or pushing when the user asked for the version change only |

</forbidden>

<validation>

Trigger checks:

- [ ] At least 3 positive trigger examples remain valid
- [ ] At least 2 negative trigger examples stay out of scope
- [ ] At least 1 boundary example stays explicit about commit vs no-commit

Execution checklist:

- [ ] Current version identified with `bash scripts/version-current.sh`
- [ ] Target version computed via `bash scripts/version-bump.sh` (or explicit semver validated)
- [ ] `bash scripts/version-apply.sh` updated all intended files
- [ ] `git diff` reviewed
- [ ] Requested commit used `bash scripts/git-commit.sh` with only the version-update files
- [ ] Requested push used `bash scripts/git-push.sh` only after a successful commit

</validation>
