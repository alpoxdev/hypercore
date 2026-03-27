---
name: git-push
description: 'Push unpushed commits to the remote. Discovers the current or descendant git repositories, checks for commits ahead of upstream, and pushes them. Use when the user wants to push, sync to remote, or send commits upstream.'
license: MIT
allowed-tools: Bash
compatibility: Requires Bash and scripts under skills/git-push/scripts.
---

# Git Push Skill

<scripts>

## Available scripts

| Script | Purpose |
|------|------|
| `scripts/git-push.sh [--force]` | Discover repos, check for unpushed commits, and push safely |

</scripts>

<objective>

- Push unpushed commits to the remote for all discovered repositories.
- Do nothing if there are no commits to push.
- Block unsafe operations (force push to main/master, detached HEAD).

</objective>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "push" | yes |
| "git push" | yes |
| "/git-push" | yes |
| "push my changes" | yes |
| "push commits to remote" | yes |
| "sync to remote" | yes |
| requests that only ask for commit/rebase/reset | no |
| "push back on this idea" (non-git context) | no |

</trigger_conditions>

<argument_validation>

If ARGUMENT is missing:

- Push all unpushed commits in all discovered repositories.

If ARGUMENT is `--force`:

- Use `--force-with-lease` for push. Protected branches (main/master) are still blocked.

</argument_validation>

<scope_assumptions>

- Start from the current working directory. If it is not a git repository, inspect descendant directories for git repositories.
- Push only. Do not commit, amend, rebase, or rewrite history.
- No confirmation needed — if there are commits to push, push them immediately.
- Use Bash commands only.

</scope_assumptions>

<required>

| Category | Rule |
|------|------|
| Safety | Never force push to main or master. |
| Safety | Never push from detached HEAD. |
| Safety | Use `--force-with-lease` instead of `--force` when force pushing. |
| Upstream | If no upstream is set, push with `-u origin <branch>` to set tracking. |
| Idempotent | If already up to date, report and exit cleanly. |
| Multi-repo | Handle descendant repositories independently. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Force push | `--force` to main or master |
| History rewrite | amend, rebase, reset, or other history-editing commands |
| Commit | Do not create commits — that is the git-commit skill's job |
| Raw force | `git push --force` — always use `--force-with-lease` |

</forbidden>

<workflow>

## Run the script

```bash
scripts/git-push.sh
```

Or with force:

```bash
scripts/git-push.sh --force
```

The script handles everything:

1. Discovers repositories (current directory or descendants).
2. For each repository, checks the branch and upstream status.
3. Skips repositories with no unpushed commits, detached HEAD, or protected branch conflicts.
4. Pushes repositories that have commits ahead of upstream.
5. Reports a summary of pushed, skipped, and failed repositories.

</workflow>

<examples>

## Simple push

```text
/git-push
```

Result: discovers repos, pushes any that have unpushed commits.

## Force push (feature branch)

```text
/git-push --force
```

Result: pushes with `--force-with-lease`. Blocked on main/master.

## Nothing to push

```text
/git-push
```

Result: reports "Already up to date" and exits cleanly.

## Multi-repo push

```text
/git-push
```

Result: discovers descendant repos, pushes each independently, reports summary.

</examples>

<validation>

- Confirm the script was executed, not manual git commands.
- Confirm force push was not used on main/master.
- Confirm detached HEAD was skipped.
- Confirm the summary output was reported to the user.

</validation>
