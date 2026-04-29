---
name: git-worktree
description: Create, enter, list, remove, clean up, or repair Git worktrees for isolated branches and parallel agent sessions, including deleting the current linked worktree when the user is already inside it. Use when the user asks for git worktree setup/removal, branch-per-folder workflows, parallel Codex/Claude/Cursor workspaces, or the repository-local `.hypercore/git-worktree/<folder_name>` convention; when creating and the task is unclear, ask what work will happen there, derive the folder name, then move subsequent work into the new worktree.
compatibility: Requires Git with `git worktree`; optional editor, tmux, and agent CLIs may be used only when already available in the repository environment.
---

@rules/worktree-lifecycle.md
@references/source-survey.md

# Git Worktree Skill

> Make isolated branch workspaces cheap, visible, and safe.

<purpose>

- Create and manage Git worktrees under the project convention: `.hypercore/git-worktree/<folder_name>`.
- Support parallel feature work, agent sessions, reviews, hotfixes, and experiments without branch-switching churn.
- Keep worktree operations safe by asking for missing task intent before creation, checking status before removal, resolving the current linked worktree when no path is given, using explicit paths, and validating Git’s worktree registry.

</purpose>

<routing_rule>

Use `git-worktree` when the user wants to:

- create a worktree, workspace, branch folder, or isolated checkout
- run multiple coding agents or tasks in parallel without file conflicts
- list, open, switch to, remove, prune, repair, lock, or unlock worktrees
- delete the current linked worktree when the user is already inside it and says things like "remove/delete this worktree" or "워크트리 삭제"
- standardize worktree folders under `.hypercore/git-worktree/<folder_name>`
- review or test a branch/PR/issue in a separate local directory

Do not use `git-worktree` when:

- the user only asks for normal branch creation or checkout in the current folder
- the user asks for history rewriting, rebase strategy, or commit grouping without a worktree operation
- the requested isolation must be a container, VM, or separate clone rather than a Git worktree

</routing_rule>

<activation_examples>

Positive requests:

- "Create a worktree for `feature/auth` and open Codex there."
- "이 브랜치를 `.hypercore/git-worktree` 아래 워크트리로 만들어줘."
- "Spin up three isolated worktrees for parallel agents."
- "새 worktree 하나 만들고 거기로 이동해줘."
- "List my active git worktrees and remove the stale ones safely."
- "I'm already in this worktree; delete this worktree safely."
- "이미 이 워크트리 안에 있는데, 워크트리 삭제해줘."
- "PR #42를 별도 worktree에서 리뷰하게 세팅해줘."

Negative requests:

- "Create a new branch here and checkout it." Use normal Git branch workflow.
- "Explain what Git worktree means." Answer directly unless an actionable worktree operation is requested.
- "Make a Docker dev environment for each branch." Use a container/dev-env workflow instead.

Boundary request:

- "Set up an isolated workspace for this risky refactor."
  Use this skill if Git branch isolation is enough; escalate to a container/VM workflow only if runtime, database, port, or dependency isolation is required.

</activation_examples>

<trigger_conditions>

| User intent | Activate |
|------|------|
| Create a branch-specific working directory | yes |
| Parallel AI agent/coding sessions on one repo | yes |
| List or open existing worktrees | yes |
| Remove, prune, lock, unlock, repair, or move worktrees | yes |
| Delete the current linked worktree from inside that worktree | yes |
| Configure project default worktree root | yes |
| Plain `git checkout` or branch-only operations | no |
| General Git tutorial with no operation | no |

</trigger_conditions>

<defaults>

- Canonical root: `<repo-root>/.hypercore/git-worktree/`.
- Canonical path: `<repo-root>/.hypercore/git-worktree/<folder_name>`.
- Default `<folder_name>`: ask what work will happen in the worktree when the user has not already supplied a clear task, then derive a concise sanitized slug from that answer.
- If the user already supplied a branch, PR, issue, or task name, derive `<folder_name>` from that context without asking again.
- After creating a worktree, move the active execution context into that folder: run follow-up shell commands with `workdir=<path>`, open the requested editor/session there, and report `cd <path>` for the user shell.
- If removal is requested without a path and the active context is already inside a linked worktree, treat the current worktree root as the removal target, move out to a safe worktree before removal, and never remove the main worktree.
- Add or verify a local ignore/exclude for `.hypercore/git-worktree/` before creating nested worktrees.
- Prefer native `git worktree` commands over installing extra managers.
- Prefer one task, branch, terminal session, and editor window per worktree.

</defaults>

<supported_operations>

- Create a worktree from a new branch, existing local branch, remote branch, PR ref, issue task, or commit.
- Enter/open a worktree in the shell, editor, tmux session, or agent CLI when available.
- List worktrees with branch, path, dirty/clean status, lock/prunable annotations, and next action.
- Remove completed worktrees after verifying committed or intentionally discarded changes.
- Remove the current linked worktree even when the request is made from inside it, by resolving the current top-level path first and executing `git worktree remove` from another safe worktree.
- Prune stale metadata with a dry run first.
- Repair moved worktrees and lock long-lived worktrees when accidental pruning would be harmful.

</supported_operations>

<workflow>

## Phase 1. Inspect repository and intent

1. Confirm the current directory is inside a Git repository.
2. Resolve the repository root with `git rev-parse --show-toplevel`.
3. Read existing worktrees with `git worktree list --porcelain`.
4. Identify the requested operation: create, open, list, remove, prune, repair, lock, or unlock.
5. For removal with no explicit path, if the current directory is inside a linked worktree, select the current worktree root as the target; if it is the main worktree, stop and ask for a specific target instead of deleting the repository root.
6. Derive branch name, folder name, and base reference from user wording or current branch.
7. If creating and the task/folder intent is missing or too vague, ask one concise question before creation: "이 worktree에서 어떤 작업을 할 예정인가요?" / "What work will happen in this worktree?"

## Phase 2. Apply the project path convention

Use `.hypercore/git-worktree/<folder_name>` as the default target path unless the user explicitly provides another path. Choose `<folder_name>` from the stated work intent, not from an arbitrary timestamp.

Before creating the worktree:

- create the parent directory if needed
- derive and sanitize `<folder_name>` from the stated work intent before path construction
- verify the target path does not already contain unrelated files
- ensure `.hypercore/git-worktree/` is ignored or locally excluded so the main worktree does not treat nested worktrees as normal untracked content
- avoid reusing a branch already checked out by another worktree unless the operation is only to open/list it

## Phase 3. Execute the worktree operation

Follow `@rules/worktree-lifecycle.md` for command patterns, safety checks, and cleanup rules.

Creation preference:

1. Existing local branch: `git worktree add <path> <branch>`.
2. Existing remote branch: create a tracking/local branch if needed, then add the worktree.
3. New task branch: `git worktree add -b <branch> <path> <base-ref>`.
4. Detached inspection: use `--detach` only when the user is reviewing a commit and does not intend to commit changes.

Current-worktree removal preference:

1. When the user says to delete/remove the worktree while already inside a linked worktree, infer the target from `git rev-parse --show-toplevel`.
2. Confirm it is not the main worktree by comparing `git rev-parse --git-dir` and `git rev-parse --git-common-dir` and by reading `git worktree list --porcelain`.
3. Check status from the target path, save the target path, move execution to the main/safe worktree, then run `git worktree remove <target-path>`.
4. Use `--force` only when the user explicitly requested force/discard semantics or has confirmed dirty changes are disposable.

## Phase 4. Move into the new worktree and verify

After a create operation:

- immediately switch subsequent agent commands to the new worktree path
- if a shell command must demonstrate entry, run `pwd` from that path or execute commands with `git -C <path>` / tool `workdir=<path>`
- if an editor, tmux session, or agent was requested, launch it with the new worktree path as its working directory
- report the exact `cd <path>` command because a subprocess `cd` cannot persistently change the user's parent shell

After any operation, report:

- worktree path
- branch or commit checked out
- whether the worktree is clean or dirty
- command to enter/open it, and whether the active agent context has been moved there
- any setup still needed inside that folder, such as dependency install, environment copy, unique ports, or agent prompt handoff

For removal/cleanup, report what was removed and what remains in `git worktree list`.

</workflow>

<examples>

## Create a new feature worktree and move into it

If the user only says "create a worktree" and no task is clear, ask first:

```text
이 worktree에서 어떤 작업을 할 예정인가요?
```

Then derive the folder name from the answer:

```bash
repo_root="$(git rev-parse --show-toplevel)"
branch="feature/auth-session"
folder="auth-session"
path="$repo_root/.hypercore/git-worktree/$folder"
exclude_file="$(git rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$path")" "$(dirname "$exclude_file")"
grep -qxF ".hypercore/git-worktree/" "$exclude_file" 2>/dev/null || printf '\n.hypercore/git-worktree/\n' >> "$exclude_file"
git fetch --all --prune
git worktree add -b "$branch" "$path" HEAD
cd "$path"
pwd
```

## List worktrees for review

```bash
git worktree list --porcelain
git worktree list --verbose
```

## Safe cleanup

```bash
git -C "$path" status --short
git worktree remove "$path"
git worktree prune --dry-run
git worktree prune
```

## Delete the current linked worktree from inside it

When the user is already inside a linked worktree and says "delete this worktree" / "워크트리 삭제", resolve the target before moving out:

```bash
target_path="$(git rev-parse --show-toplevel)"
git_dir="$(git rev-parse --git-dir)"
common_dir="$(git rev-parse --git-common-dir)"
main_path="$(git worktree list --porcelain | awk 'NR==1 && /^worktree / {print substr($0, 10)}')"

# Refuse if this is the main worktree or no safe main worktree is available.
if [ "$(cd "$git_dir" && pwd -P)" = "$(cd "$common_dir" && pwd -P)" ] || [ -z "$main_path" ] || [ "$main_path" = "$target_path" ]; then
  echo "Refusing to remove this path as a linked worktree: $target_path" >&2
  exit 1
fi

git -C "$target_path" status --short --branch
cd "$main_path"
git worktree remove "$target_path"
git worktree list --porcelain
```

</examples>

<validation>

Trigger checks:

- [ ] Positive examples above clearly activate this skill.
- [ ] Negative examples route away from this skill.
- [ ] Boundary examples choose Git worktrees only when branch-level isolation is sufficient.

Operation checks:

- [ ] `git rev-parse --show-toplevel` succeeds before path construction.
- [ ] create operations have a clear work intent; if missing, one concise question is asked before choosing `<folder_name>`.
- [ ] `<folder_name>` is derived from the stated work intent and sanitized before path construction.
- [ ] `.hypercore/git-worktree/` is ignored or locally excluded before nested worktree creation.
- [ ] `git worktree list --porcelain` is read before mutating existing worktrees.
- [ ] removal checks `git -C <path> status --short` first unless the user explicitly asks for force removal.
- [ ] current-worktree deletion resolves the current top-level path first, refuses the main worktree, moves to another safe worktree, and removes the saved target path rather than running removal from inside the target.
- [ ] cleanup runs `git worktree prune --dry-run` before `git worktree prune`.
- [ ] after creation, subsequent commands use the new worktree as their working directory or report why they cannot.

Resource placement checks:

- [ ] Core workflow stays in `SKILL.md`.
- [ ] Detailed command policy stays in `rules/worktree-lifecycle.md`.
- [ ] External research and pattern rationale stay in `references/source-survey.md`.

</validation>
