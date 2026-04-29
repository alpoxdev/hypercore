---
name: git-maker
description: "[Hyper] Commit and push in one action. Runs the full git-commit workflow (inspect, group, stage, commit) then automatically pushes all committed changes to the remote — no confirmation step between commit and push. Use when the user wants to commit and push together."
license: MIT
allowed-tools: Bash
compatibility: Requires Bash and scripts under skills/git-maker/scripts (symlinks to git-commit and git-push scripts).
---

# Git Maker Skill

<scripts>

## Available scripts

| Script | Purpose |
|------|------|
| `scripts/repo-discover.sh [start_dir]` | Detect current-repo vs descendant-repo layout |
| `scripts/repo-status.sh [repo]` | Show branch, status, staged summary, and unstaged summary |
| `scripts/git-commit.sh [--repo path] "msg" [files...]` | Commit staged or selected files in one repository |
| `scripts/git-push.sh [--force]` | Discover repos, check for unpushed commits, and push safely |

</scripts>

<objective>

- Create one or more Conventional Commits from the current repository state, then automatically push all committed changes to the remote.
- This is a sequential composition: **git-commit workflow first, git-push workflow second**.
- No confirmation step between commit and push. The push happens automatically after all commits succeed.

</objective>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "commit and push" | yes |
| "commit and push these changes" | yes |
| "/git-maker" | yes |
| "make a commit and push it" | yes |
| "commit then push" | yes |
| "save and push my changes" | yes |
| requests that only ask for commit without push | no — use git-commit instead |
| requests that only ask for push without commit | no — use git-push instead |
| requests for rebase, reset, or other history operations | no |

</trigger_conditions>

<argument_validation>

Arguments are passed through to the commit phase. Push phase has no arguments unless `--force` is specified.

If ARGUMENT is missing:

- Default to the files, repositories, and logical change units touched in the current session.
- Verify the session-derived candidate set against actual `git status` and `git diff` output before staging or committing.
- If the candidate set contains multiple logical change groups, identify each group and commit them separately in sequence. Do not stop or ask for clarification — iterate through all groups.
- If the current session's work is already fully committed, allow the remaining uncommitted changes to become the next candidate set and apply the same grouping logic.

If ARGUMENT is "ALL" or "all":

- Take ALL uncommitted changes in the repository, regardless of whether they were touched in the current session.
- Group all changes into logical change sets based on related functionality, feature area, or purpose.
- Commit each group separately in sequence. Do not stop, do not ask for confirmation, do not skip any files.
- Every uncommitted file must be included in exactly one commit group. No file may be left behind.

If ARGUMENT contains `--force`:

- Extract `--force` and pass it to the push phase (uses `--force-with-lease`).
- The remaining argument (if any) is passed to the commit phase.

If ARGUMENT is present (other than ALL and --force):

- Treat ARGUMENT as the primary commit target or filter.
- Use it to narrow repository discovery, file selection, staging, and commit message generation.
- If the filtered set contains multiple logical groups, commit each group separately.
- Stop if ARGUMENT does not match the actual repository state.

</argument_validation>

<scope_assumptions>

- Start from the current working directory. If it is not a git repository, inspect descendant directories for git repositories before proceeding.
- Commit AND push. No confirmation between the two phases.
- Use Bash commands only.

</scope_assumptions>

<workflow>

## Phase 1. Commit — follow git-commit workflow

Execute the **full git-commit workflow** with these phases:

### 1a. Inspect repository state

Decide argument mode, then discover repositories.

```bash
scripts/repo-discover.sh
```

Then for each discovered repository:

```bash
scripts/repo-status.sh
scripts/repo-status.sh path/to/repo
```

### 1b. Identify logical change groups

Analyze the full candidate set and partition into logical change groups.

Grouping heuristics (apply in order):
1. Files that implement the same feature or fix belong together.
2. Test files belong with their corresponding implementation files.
3. Config/build changes related to the same feature belong with that feature.
4. Unrelated standalone changes each form their own group.

In ALL mode: every uncommitted file must appear in exactly one group. No file may be left behind.

### 1c. Stage and commit each group (loop)

For each logical group, repeat:

**Stage** — only the files in the current group:

```bash
git add path/to/file1 path/to/file2
```

**Generate commit message** — Conventional Commits format:

```text
<type>[optional scope]: <subject>

[optional body]

[optional footer]
```

**Execute commit:**

```bash
scripts/git-commit.sh "<type>[scope]: <subject>"
scripts/git-commit.sh --repo path/to/repo "<type>[scope]: <subject>"
```

With body or footer:

```bash
scripts/git-commit.sh "$(cat <<'EOF'
<type>[scope]: <subject>

<optional body>

<optional footer>
EOF
)"
```

Continue to next group until all groups are committed.

### Commit rules (same as git-commit skill)

| Category | Rule |
|------|------|
| Inspect first | Run `git status --short --branch` before any staging or commit command. |
| Diff source | If staged changes exist, treat the staged set as the default commit candidate and inspect with `git diff --staged`. If nothing is staged, inspect `git diff`. |
| Repository boundary | When multiple git repositories are discovered, run `git status`, `git add`, and `git commit` inside each repository separately. |
| Logical scope | Each commit covers exactly one logical change. |
| Staging discipline | Stage only the files required for the selected logical change. |
| Type selection | Choose the Conventional Commit type from the actual dominant change, not from filenames alone. |
| Scope selection | Use a scope only when one module, package, feature area, or subsystem clearly owns the change. Omit scope when the change spans multiple unrelated areas. |
| Language | Write commit subject and body in Korean. The Conventional Commit `type` and `scope` stay in English (e.g. `feat(auth):`), but the description after the colon and the body text must be in Korean. |
| Subject line | Imperative mood, present tense, lowercase after the colon, under 72 characters. |
| Body/footer | Add a body only when the subject cannot capture important context. Add footers only for verified issue references, breaking changes, or explicitly requested metadata. |
| Safety | Never commit secrets, generated credentials, or unrelated user changes. Never use `--no-verify`, force flags, or destructive git commands unless the user explicitly asks. |
| Failure handling | If hooks fail, inspect the error. Fix and retry only when safe. Otherwise stop and report the blocker. |

## Phase 2. Push — automatic after successful commits

**Do NOT ask for push confirmation.** Push automatically after all commits succeed.

If any commit failed, stop and report the failure. Do not push.

```bash
scripts/git-push.sh
```

Or with force (when `--force` was in the argument):

```bash
scripts/git-push.sh --force
```

The push script handles:
1. Discovers repositories (current directory or descendants).
2. For each repository, checks the branch and upstream status.
3. Skips repositories with no unpushed commits, detached HEAD, or protected branch conflicts.
4. Pushes repositories that have commits ahead of upstream.
5. Reports a summary of pushed, skipped, and failed repositories.

### Push failure handling

| Failure case | Response |
|------|------|
| Push succeeds for all repositories | Report success and continue to Phase 3 |
| Push fails for one or more repositories | Report which repositories failed. Commits are NOT lost — they remain in the local repository. Suggest the user retry `git push` manually or investigate the remote. |
| No upstream and `-u origin <branch>` also fails | Report the failure. Commits remain local. |
| Network error during push | Report the error. Commits remain local. Do not retry automatically. |

## Phase 3. Report results

Report a combined summary:
- How many commits were created (and their messages)
- How many repositories were pushed
- Any skipped or failed push targets

</workflow>

<required>

| Category | Rule |
|------|------|
| Commit first | All commits must succeed before any push is attempted. |
| No confirmation | Do NOT ask whether to push. Push is automatic. |
| Safety | Never force push to main or master. Never push from detached HEAD. |
| Upstream | If no upstream is set, push with `-u origin <branch>` to set tracking. |
| All git-commit rules | All required rules from git-commit apply to the commit phase. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Push confirmation | Asking "want to push?" or waiting for push approval |
| Partial push | Pushing before all commit groups are finished |
| All git-commit forbidden items | All forbidden rules from git-commit apply to the commit phase |
| Force push to protected branches | `--force` to main or master |
| History rewrite | amend, rebase, reset, force push, or other history-editing commands without explicit request |

</forbidden>

<decision_tables>

## Repository discovery

| Observed layout | Action |
|------|------|
| Current working directory is a git repository | Operate in the current repository and follow the normal commit-then-push workflow |
| Current working directory is not a git repository, but one or more descendant directories are repositories | Build the repository list and run the full commit workflow separately inside each repository that has relevant changes, then push each |
| Current working directory is not a git repository and no descendant repository exists | Stop and report that no git repository was found |

## Argument mode

| Input state | Action |
|------|------|
| No ARGUMENT | Commit session changes (grouped), then auto-push |
| ARGUMENT is "ALL" or "all" | Commit ALL uncommitted changes (grouped), then auto-push |
| ARGUMENT contains `--force` | Extract --force for push phase, commit as normal, then push with --force-with-lease |
| ARGUMENT present (other) | Commit filtered changes (grouped), then auto-push |
| ARGUMENT conflicts with git state | Stop and report mismatch — do not push |

## Type selection

| Observed dominant change | Type |
|------|------|
| User-facing capability added | `feat` |
| Incorrect behavior fixed | `fix` |
| Docs only | `docs` |
| Formatting or style only, no behavior change | `style` |
| Internal restructure without feature or bug fix | `refactor` |
| Performance improvement | `perf` |
| Tests added or updated | `test` |
| Build tooling or dependency management | `build` |
| CI workflow or automation config | `ci` |
| Repo maintenance, chores, metadata | `chore` |
| Reverting an earlier commit | `revert` |

</decision_tables>

<examples>

## Simple commit and push

```text
/git-maker
```

Result:
- inspects current session changes
- groups, stages, and commits each logical group
- automatically pushes — no confirmation asked

## Commit all and push

```text
/git-maker ALL
```

Result:
- takes ALL uncommitted changes
- groups into logical change sets
- commits each group separately
- automatically pushes all

## Commit and force push

```text
/git-maker --force
```

Result:
- commits session changes as normal
- pushes with `--force-with-lease` (blocked on main/master)

## Commit specific target and push

```text
/git-maker packages/api session validation fix
```

Result:
- filters commit candidates to match ARGUMENT
- commits matching changes
- automatically pushes

## Multiple logical groups

```text
/git-maker
```

Result:
- session touched auth module + unrelated docs
- group 1: `feat(auth): add passkey login flow` → commit
- group 2: `docs(cli): document release prerequisites` → commit
- auto-push both commits

## Multi-repo commit and push

```text
/git-maker
```

Result (current directory is not a repo, but has descendant repos):
- discovers `packages/web` and `packages/api` as separate repositories
- commits in each repo independently:
  ```bash
  scripts/git-commit.sh --repo packages/web "fix(web): handle empty sessions" src/auth.ts
  scripts/git-commit.sh --repo packages/api "fix(api): validate session payload" src/routes/session.ts
  ```
- pushes each repo:
  ```bash
  scripts/git-push.sh
  ```
- reports: 2 commits created, 2 repositories pushed

## Commit fails — no push

Result:
- hook failure during commit
- reports the blocker
- does NOT attempt push

</examples>

<validation>

- Confirm all git-commit validation checks passed for the commit phase.
- Confirm push was NOT preceded by a confirmation prompt.
- Confirm push was NOT attempted when any commit failed.
- Confirm force push was not used on main/master.
- Confirm the combined summary (commits + push) was reported.

</validation>
