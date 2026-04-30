---
name: git-maker
description: "[Hyper] Commit and push in one action. Use when the user asks to commit and push together, save and push changes, or run `/git-maker`; it performs safe commit grouping first, then automatically pushes without a second confirmation."
license: MIT
allowed-tools: Bash
compatibility: Requires Bash and scripts under skills/git-maker/scripts.
---

# Git Maker Skill

> Fast, safe commit-and-push orchestration.

<purpose>

- Create one or more Conventional Commits from current repository changes.
- Push successfully created commits automatically, with no confirmation step between commit and push.
- Use the fast helper first to reduce repeated repository discovery and parallelize read-only inspection.

</purpose>

<routing_rule>

Use `git-maker` when the user wants **commit + push** in one operation.

Use a neighboring skill instead when:

- the user asks only to commit → use `git-commit`
- the user asks only to push/sync commits → use `git-push`
- the user asks to rebase/reset/amend/rewrite history → do not use `git-maker` unless commit+push is also explicitly requested and the history operation is separately authorized

</routing_rule>

<trigger_conditions>

Positive triggers:

- "commit and push"
- "commit and push these changes"
- "/git-maker"
- "make a commit and push it"
- "save and push my changes"
- "커밋하고 푸시해"
- "변경사항 저장하고 올려"

Negative triggers:

- "commit these changes" → `git-commit`
- "push my commits" → `git-push`
- "rebase this branch" → not this skill

Boundary trigger:

- "commit this, then maybe push" → use `git-commit` because push is conditional, not automatic

</trigger_conditions>

<scripts>

| Script | Purpose |
|------|------|
| `scripts/git-maker-fast.sh inspect [start_dir] [--jobs N]` | Fast preflight: pruned repo discovery, parallel repo status, file inventory |
| `scripts/git-maker-fast.sh push [--force] [repo...]` | Push explicit repos without rediscovering; non-interactive; protected force-push guard |
| `scripts/git-commit.sh [--repo path] "msg" [files...]` | Commit staged or selected files in one repository |
| `scripts/git-push.sh [--force]` | Legacy/discovered safe push fallback |
| `scripts/repo-discover.sh [start_dir]` | Legacy repo discovery fallback |
| `scripts/repo-status.sh [repo]` | Legacy status fallback |

</scripts>

<support_file_read_order>

Read only what is needed:

1. `rules/speed-and-automation.md` when the user asks for speed, the repo set may be large, or multiple repositories may be present.
2. `rules/commit-and-push-policy.md` before staging/committing or when argument mode, grouping, safety, or push behavior is unclear.
3. `rules/validation.md` before reporting the run or skill refactor complete.

</support_file_read_order>

<argument_validation>

Arguments pass to the commit phase unless `--force` is present.

| Argument | Meaning |
|------|------|
| missing | start from current-session changes, verify against git state, group logically |
| `ALL` / `all` | include all uncommitted changes, group logically, leave no file behind |
| `--force` | remove from commit arguments and pass only to push (`--force-with-lease`, blocked on `main`/`master`) |
| other text | treat as a filter for repo discovery, file selection, staging, and commit message generation |

Stop if an explicit filter does not match actual git state.

</argument_validation>

<workflow>

## Phase 1. Fast preflight

Run the fast helper first:

```bash
scripts/git-maker-fast.sh inspect . --jobs 4
```

Use its repo list and file inventory to decide:

- which repositories are in scope
- staged vs unstaged vs untracked files
- logical change groups
- whether a slower fallback is needed

If the helper fails or insufficient detail is available, fall back to:

```bash
scripts/repo-discover.sh
scripts/repo-status.sh
scripts/repo-status.sh path/to/repo
```

## Phase 2. Group and commit

Partition changes into logical groups. Commit each group sequentially per repository:

```bash
scripts/git-commit.sh "<type>[scope]: <한국어 subject>" path/to/file1 path/to/file2
scripts/git-commit.sh --repo path/to/repo "<type>[scope]: <한국어 subject>" path/to/file1
```

Rules:

- one logical change per commit
- targeted staging only
- Korean subject/body after the Conventional Commit type/scope
- no secrets, unrelated user changes, destructive git operations, or `--no-verify`
- if any commit fails, stop and do not push

For detailed policy, read `rules/commit-and-push-policy.md`.

## Phase 3. Push automatically

After all commit groups succeed, push without asking for confirmation.

Prefer reusing the preflight repo list:

```bash
scripts/git-maker-fast.sh push /absolute/repo/path
scripts/git-maker-fast.sh push --force /absolute/repo/path
```

Fallback:

```bash
scripts/git-push.sh
scripts/git-push.sh --force
```

## Phase 4. Report

Report:

- commits created and messages
- repositories pushed
- skipped or failed push targets
- any remaining local changes or blockers

</workflow>

<parallelization>

- Parallelize read-only repository inspection with `scripts/git-maker-fast.sh inspect --jobs N`.
- Do not parallelize commits in the same repository because the git index is shared.
- Multi-repo commits may be worked independently only after repo boundaries and file groups are clear.
- Push only after every intended commit succeeds.

</parallelization>

<required>

| Category | Rule |
|------|------|
| Commit first | All commit groups must succeed before push. |
| Automatic push | Do not ask whether to push after successful commits. |
| Safety | Never force push to `main` or `master`; never push from detached HEAD. |
| Upstream | If no upstream exists, push with `-u origin <branch>`. |
| Reuse preflight | Prefer `git-maker-fast.sh push [repo...]` to avoid duplicate discovery. |
| Validation | Run `rules/validation.md` checks before final reporting. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Push confirmation | asking "want to push?" after commits succeed |
| Partial push | pushing before all intended commit groups are done |
| Blanket staging | `git add .` unless `ALL` mode intentionally includes everything and grouping remains explicit |
| Unsafe history | amend, rebase, reset, raw `--force`, or `--no-verify` without explicit request |
| Secrets | committing credentials, tokens, private keys, or unrelated user changes |

</forbidden>

<examples>

## Simple fast commit and push

```text
/git-maker
```

Result: fast inspect → group session changes → commit each group → auto-push inspected repo(s).

## Commit all and push

```text
/git-maker ALL
```

Result: all uncommitted files are grouped, committed, and pushed. No file is skipped.

## Commit and force push a feature branch

```text
/git-maker --force
```

Result: commit normally, then push with `--force-with-lease`; blocked on `main`/`master`.

## Commit-only request

```text
commit these changes
```

Result: do not use this skill; route to `git-commit`.

</examples>

<validation>

Before claiming completion:

- `bash -n scripts/git-maker-fast.sh`
- `scripts/git-maker-fast.sh inspect . --jobs 2`
- confirm trigger examples still distinguish commit+push from commit-only and push-only
- confirm the final report includes commits, push result, skipped/failure cases, and blockers

</validation>
