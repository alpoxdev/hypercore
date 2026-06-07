# Session Branch Guard

Use this rule after `git-issue` checks out or creates an issue branch.

## Guard Definition

The issue branch guard is a current-AI-session constraint:

- It starts after the issue branch checkout is verified.
- It applies to subsequent commands and edits made by the active AI session.
- It does not claim to mutate the user's parent shell outside the agent's controllable execution surface.
- It ends only when the user explicitly asks to leave the issue branch, targets a different issue through `git-issue`, or asks for a Git workflow that necessarily changes branches.

## Required State

Record these values in the working context before editing:

- issue number
- issue URL
- branch name
- repository root
- checkout verification command and result

## Enforcement

- Before any later file edit or Git operation in the same task, check `git branch --show-current`.
- If the current branch is not the guarded branch, switch back to the guarded branch before continuing.
- Do not run `git switch`, `git checkout`, `git worktree add`, rebase, reset, or branch delete against unrelated branches unless the user explicitly exits or retargets the guard.
- If a command must temporarily inspect another branch, prefer read-only commands such as `git show`, `git diff`, or `gh` queries that do not change checkout.

## Reporting

In the final or handoff message, say:

- which issue branch is active
- that the guard is scoped to the current AI session
- whether the checkout was verified by `git status --short --branch`

## Blockers

Stop and report the blocker when:

- checkout would overwrite local changes
- the guarded branch was deleted or renamed externally
- `gh` can no longer resolve the issue
- the user requests a conflicting branch operation without explicitly retargeting or exiting the guard
