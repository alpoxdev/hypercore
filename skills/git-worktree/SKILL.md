---
name: git-worktree
description: "[Hyper] Create, enter, list, remove, clean up, or repair Git worktrees for isolated branches and parallel agent sessions, including direct `git-worktree <ARGUMENT>` creation without follow-up questions. Use when the user asks for git worktree setup/removal, branch-per-folder workflows, parallel Codex/Claude/Cursor workspaces, or the repository-local `.hypercore/git-worktree/<folder_name>` convention; when creating and no argument/task is clear, ask what work will happen there in the user's language, derive the folder name, then move subsequent work into the new worktree."
compatibility: Requires Git with `git worktree`; optional editor, tmux, and agent CLIs may be used only when already available in the repository environment.
---

@rules/worktree-lifecycle.md
@references/source-survey.md

# Git Worktree Skill

> Make isolated branch workspaces cheap, visible, and safe.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Create and manage Git worktrees under the project convention: `.hypercore/git-worktree/<folder_name>`.
- Support parallel feature work, agent sessions, reviews, hotfixes, and experiments without branch-switching churn.
- Keep worktree operations safe by asking for missing task intent before creation, checking status before removal, resolving the current linked worktree when no path is given, using explicit paths, and validating Git’s worktree registry.
- Match the user's language for any clarification question. For Korean prompts, ask in Korean; do not show an English operation menu.

</purpose>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Create, enter, inspect, remove, clean up, or repair isolated Git worktree workspaces. |
| Trigger | Activate on worktree/workspace/branch-folder isolation requests or explicit `git-worktree` operations. |
| Scope | Own repository/worktree discovery, path and branch derivation, local exclude setup, worktree lifecycle commands, context movement, and status reporting. |
| Authority | User and project instructions outrank this skill; Git worktree registry output, branch state, and filesystem checks are execution evidence. |
| Evidence | Use `git rev-parse`, `git worktree list --porcelain`, target-path checks, branch refs, and per-worktree status before mutation. |
| Tools | Use native Git and shell; editor, tmux, or agent launches are optional and only run when available and requested by the operation. |
| Output | Korean report of worktree path, branch/commit, clean or dirty state, active-context movement, and remaining setup or cleanup. |
| Verification | Confirm repository root, worktree registry, target path safety, post-create working directory/status, and pre-remove status or prune dry run. |
| Stop condition | Stop when the requested lifecycle operation is verified, or a dirty/destructive/ambiguous target is reported before mutation. |

</instruction_contract>

<routing_rule>

Use `git-worktree` when the user wants to:

- create a worktree, workspace, branch folder, or isolated checkout
- run multiple coding agents or tasks in parallel without file conflicts
- list, open, switch to, remove, prune, repair, lock, or unlock worktrees
- delete the current linked worktree when the user is already inside it and says things like "remove/delete this worktree" or "delete worktree"
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
- "`git-worktree fix/api-timeout`"
- "Create this branch as a worktree under `.hypercore/git-worktree`."
- "Spin up three isolated worktrees for parallel agents."
- "Create a new worktree and move me into it."
- "List my active git worktrees and remove the stale ones safely."
- "I'm already in this worktree; delete this worktree safely."
- "I am already inside this worktree; delete the worktree safely."
- "Set up PR #42 for review in a separate worktree."

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

<support_file_read_order>

1. Read `rules/worktree-lifecycle.md` for command patterns, safety checks, removal, pruning, repair, and context-move rules.
2. Read `references/source-survey.md` only when the rationale, upstream behavior, or source comparison matters.
3. Use the deterministic validator `scripts/validate-git-worktree-skill.py` after editing this skill folder.

</support_file_read_order>

<argument_handling>

- If the user invokes `git-worktree <ARGUMENT>` or supplies one positional argument after the skill name, treat `<ARGUMENT>` as an explicit create target and do not ask what worktree to create.
- Interpret `<ARGUMENT>` as the branch/task label unless it is clearly a PR/issue/ref/path; preserve the branch/ref text and sanitize only the folder label.
- Use `.hypercore/git-worktree/<folder_name>`, then move the active agent context into the new worktree.
- Ask only if the argument is unsafe, reserved, conflicts with an unrelated path, or cannot map to a Git ref/branch/task label.

</argument_handling>

<defaults>

- Canonical root: `<repo-root>/.hypercore/git-worktree/`.
- Canonical path: `<repo-root>/.hypercore/git-worktree/<folder_name>`.
- Default `<folder_name>`: ask what work will happen in the worktree when the user has not already supplied a clear task. For Korean users, ask exactly: "이 worktree에서 어떤 작업을 할 예정인가요?" Then derive a concise sanitized slug from that answer.
- If the user already supplied a positional argument, branch, PR, issue, or task name, derive `<folder_name>` from that context without asking again.
- Clarification language: infer the operation from the request whenever possible. If an operation is truly ambiguous, ask one short question in the user's language. For Korean users, ask which worktree operation they want, such as create, list, open/move, delete, clean up, repair, lock, or unlock. Never ask a generic English operation menu.
- After creating a worktree, creation is not complete until the active execution context has moved into that folder: in a persistent shell/session, actually execute `cd <path>` there; in tool-only environments, set the next command's `workdir=<path>` and keep subsequent commands there. Do not merely display `cd <path>` as the final answer.
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

1. Confirm the repository root with `git rev-parse --show-toplevel`.
2. Read existing worktrees with `git worktree list --porcelain`.
3. Infer the operation: create, open, list, remove, prune, repair, lock, or unlock.
4. For pathless removal inside a linked worktree, resolve the current top-level path as the target; if it is the main worktree, stop before deleting the repository root.
5. Treat `git-worktree <ARGUMENT>` as a create target and derive branch, folder, and base ref before asking anything.
6. If creating and the task intent is unclear, ask one concise localized question for the work that will happen there.
7. Use `.hypercore/git-worktree/<folder_name>` unless the user provided another path.
8. Follow `@rules/worktree-lifecycle.md` for command details, safety checks, and cleanup.
9. For "create and enter/open/switch", do not stop after `git worktree add`; move the active context there or prove the next command ran with `workdir=<path>`.
10. Report path, branch/commit, clean/dirty state, context movement, remaining setup, and for cleanup the remaining `git worktree list`.

</workflow>

<validation>

Deterministic regression command:

```bash
python3 skills/git-worktree/scripts/validate-git-worktree-skill.py
```

Trigger checks:

- [ ] Positive examples above clearly activate this skill.
- [ ] Negative examples route away from this skill.
- [ ] Boundary examples choose Git worktrees only when branch-level isolation is sufficient.

Operation checks:

- [ ] `git rev-parse --show-toplevel` succeeds before path construction.
- [ ] create operations have a clear work intent; if missing, one concise question is asked before choosing `<folder_name>`.
- [ ] direct `git-worktree <ARGUMENT>` invocations create from the argument without asking what worktree to create.
- [ ] clarification questions match the user's language; Korean users are not shown English operation menus.
- [ ] `<folder_name>` is derived from the stated work intent and sanitized before path construction.
- [ ] `.hypercore/git-worktree/` is ignored or locally excluded before nested worktree creation.
- [ ] `git worktree list --porcelain` is read before mutating existing worktrees.
- [ ] removal checks `git -C <path> status --short` first unless the user explicitly asks for force removal.
- [ ] current-worktree deletion resolves the current top-level path first, refuses the main worktree, moves to another safe worktree, and removes the saved target path rather than running removal from inside the target.
- [ ] cleanup runs `git worktree prune --dry-run` before `git worktree prune`.
- [ ] after creation, subsequent commands use the new worktree as their working directory; if the parent shell cannot be persistently changed, the final report includes `cd <path>` and says whether the active agent context moved there.
- [ ] the operator did not merely print `cd <path>`; a persistent session actually changed directory, or at least one post-create command ran from the new worktree via `workdir=<path>` or an equivalent tool working-directory setting.

Resource placement checks:

- [ ] Core workflow stays in `SKILL.md`.
- [ ] Detailed command policy stays in `rules/worktree-lifecycle.md`.
- [ ] External research and pattern rationale stay in `references/source-survey.md`.

</validation>
