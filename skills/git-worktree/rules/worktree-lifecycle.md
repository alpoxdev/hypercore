# Worktree Lifecycle Rules

Use these rules when operating on Git worktrees for the `git-worktree` skill.

## 1. Repository discovery

Run from any descendant of the target repository:

```bash
git rev-parse --show-toplevel
git rev-parse --git-common-dir
git worktree list --porcelain
```

If not inside a Git repository, stop the operation and report that a repository path is required.

## 2. Task intent, naming, and paths

Default root:

```text
<repo-root>/.hypercore/git-worktree/<folder_name>
```

Before creating a worktree, establish what will happen there:

- If the user already named a branch, PR, issue, task, or concrete work item, use that context.
- If the user only says to create a worktree and the task is unclear, ask exactly one concise question before creating it: "이 worktree에서 어떤 작업을 할 예정인가요?" / "What work will happen in this worktree?"
- Derive `<folder_name>` from the answer. Do not use a random timestamp or generic `worktree-1` unless the user explicitly wants that.

Naming rules:

- Prefer a short task label: `feature-auth`, `fix-login`, `review-pr-42`, `agent-docs-pass`.
- Preserve the real branch name separately from the folder name.
- Sanitize folder names with an explicit slug algorithm: lowercase the task label, replace `/`, whitespace, and shell-sensitive characters with `-`, collapse repeated separators, trim leading/trailing separators, and reject reserved labels such as `.`, `..`, `.git`, `main`, or an empty slug.
- If the sanitized slug is too generic (`worktree`, `task`, `new-worktree`), add one concrete noun from the user's stated intent before creating the folder.
- Cap very long labels to a readable length and add a numeric suffix when the target path already exists.
- Refuse paths outside the repository only when the user did not explicitly request them.
- Never create a worktree inside an existing linked worktree unless the user explicitly asks and understands the nesting risk.

Because this project’s requested convention nests worktrees under the repository, always ensure the root is ignored locally:

```bash
exclude_file="$(git rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$exclude_file")"
grep -qxF ".hypercore/git-worktree/" "$exclude_file" 2>/dev/null || printf '\n.hypercore/git-worktree/\n' >> "$exclude_file"
```

Prefer local excludes over editing `.gitignore` unless the user asks to commit the convention.

## 3. Create worktree

### New branch from current `HEAD`

```bash
git worktree add -b <branch> <path> HEAD
```

### New branch from a base branch

```bash
git fetch --all --prune
git worktree add -b <branch> <path> <base-ref>
```

### Existing local branch

```bash
git worktree add <path> <branch>
```

If Git reports the branch is already checked out elsewhere, list the existing worktree and open it instead of forcing a duplicate checkout.

### Existing remote branch

```bash
git fetch --all --prune
git switch --track -c <branch> origin/<branch>
# or, from the main worktree:
git worktree add -b <branch> <path> origin/<branch>
```

Prefer commands that do not disturb the user’s current working tree. If using `git switch` would change the current worktree, use the `git worktree add -b ... origin/...` form instead.

### Detached review

```bash
git worktree add --detach <path> <commit-or-tag>
```

Use detached worktrees only for read-only inspection, bisect-like diagnostics, or explicit throwaway review.

After creation, verify the worktree exists and make it the active context for follow-up work:

```bash
git -C <path> status --short --branch
cd <path>
pwd
```

In agent environments where `cd` in a subprocess cannot persist, run every subsequent shell/tool command with the worktree path as the working directory, or use `git -C <path>` for Git commands.

## 4. Move, open, or hand off

After creation, switch into the folder for subsequent work and provide one or more available handoff commands:

```bash
cd <path>
pwd
code <path>
cursor <path>
tmux new-session -A -s <folder_name> -c <path>
```

For AI-agent workflows, hand off the task and boundaries explicitly:

- branch name
- worktree path
- target files or ownership boundary
- verification command
- merge/cleanup expectation

Do not start external editor or agent commands unless the user asked for it or the current skill invocation clearly includes that action. Moving the active agent command context to the new worktree is part of creation and does not require an extra confirmation.

## 5. List and status dashboard

Use both Git’s registry and per-worktree status:

```bash
git worktree list --porcelain
git worktree list --verbose
for p in $(git worktree list --porcelain | awk '/^worktree / {print substr($0, 10)}'); do
  printf '\n== %s ==\n' "$p"
  git -C "$p" status --short --branch
 done
```

Report:

- path
- branch or detached commit
- clean/dirty state
- locked/prunable annotations
- recommended next action

## 6. Remove safely

Before removing:

```bash
git -C <path> status --short --branch
git -C <path> log --oneline --decorate -5
```

Safe removal path:

```bash
git worktree remove <path>
```

Only use force when explicitly requested or when the user has already confirmed the changes are disposable:

```bash
git worktree remove --force <path>
```

Branch deletion is separate and should be explicit:

```bash
git branch -d <branch>
# use -D only when explicitly requested and disposable
```

Never delete the main worktree.

## 7. Prune, lock, unlock, repair

Prune only after dry run:

```bash
git worktree prune --dry-run
git worktree prune
```

Lock long-lived or externally stored worktrees:

```bash
git worktree lock --reason "<reason>" <path>
git worktree unlock <path>
```

If paths were moved manually, repair before recreating:

```bash
git worktree repair <path>
```

## 8. Merge-back handoff

When a worktree’s task is complete:

1. Verify status is clean or intentionally staged/committed.
2. Run the project’s tests/build in that worktree.
3. Merge, rebase, or open a PR according to the project’s normal Git workflow.
4. Remove the worktree only after work is merged, pushed, or intentionally abandoned.
5. Prune stale metadata with a dry run first.

## 9. Common hazards

- Nested worktrees under `.hypercore/git-worktree/` must be ignored locally or the main worktree becomes noisy.
- Same branch cannot normally be checked out in two worktrees at once.
- Linked worktrees share Git object storage and config but have independent working files.
- Per-worktree dependency folders, ports, databases, and generated artifacts may still collide; use separate env files or ports when needed.
- Windows/WSL path portability can break if a worktree is created by one Git executable and used by another.
