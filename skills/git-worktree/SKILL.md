---
name: git-worktree
description: "[Hyper] Use this skill when the user asks to create, enter, list, remove, clean up, or repair Git worktrees for isolated branches and parallel agent sessions, including a direct `git-worktree ARGUMENT` create, branch-per-folder workflows, parallel Codex/Claude/Cursor workspaces, or the repository-local `.hyper/git-worktree/` convention. Do not use it for ordinary branch checkout, history rewriting, or container or VM isolation."
compatibility: Requires Git with `git worktree`; the bundled validator needs bash 3.2+ and jq 1.6+. Editor, tmux, and agent CLIs are optional and used only when already available in the repository environment.
---

@rules/worktree-lifecycle.md

# Git Worktree Skill

> Make isolated branch workspaces cheap, visible, and safe.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Create and manage Git worktrees under the project convention: `.hyper/git-worktree/<folder_name>`.
- Support parallel feature work, agent sessions, reviews, hotfixes, and experiments without branch-switching churn.
- Keep worktree operations safe by asking for missing task intent before creation, checking status before removal, resolving the current linked worktree when no path is given, using explicit paths, and validating Git's worktree registry.

</purpose>

<routing_rule>

Use `git-worktree` when the user wants to:

- create a worktree, workspace, branch folder, or isolated checkout
- run multiple coding agents or tasks in parallel without file conflicts
- list, open, switch to, remove, prune, repair, lock, or unlock worktrees
- delete the current linked worktree from inside it ("remove/delete this worktree")
- standardize or configure worktree folders under `.hyper/git-worktree/<folder_name>`
- review or test a branch/PR/issue in a separate local directory

Do not use `git-worktree` when:

- the user only asks for normal branch creation or checkout in the current folder
- the user asks for history rewriting, rebase strategy, or commit grouping without a worktree operation
- the user asks a conceptual Git question with no operation to perform
- the requested isolation must be a container, VM, or separate clone rather than a Git worktree

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Create, enter, inspect, remove, clean up, or repair isolated Git worktree workspaces. |
| Trigger | Activate on worktree/workspace/branch-folder isolation requests or explicit `git-worktree` operations. |
| Scope | Own repository/worktree discovery, path and branch derivation, local exclude setup, worktree lifecycle commands, context movement, and status reporting. Commits, merges, pull requests, and container or VM isolation are out of scope. |
| Authority | User and project instructions outrank this skill; Git worktree registry output, branch state, and filesystem checks are execution evidence. |
| Evidence | Use `git rev-parse`, `git worktree list --porcelain`, target-path checks, branch refs, and per-worktree status before mutation. |
| Tools | Use native Git and shell; editor, tmux, or agent launches are optional and only run when available and requested by the operation. |
| Loop | None. One pass per requested lifecycle operation: discover the repository, resolve the target, check safety, mutate, verify, and report. Repeat only for a further requested worktree operation; a dirty, destructive, or ambiguous target stops before mutation. |
| Output | Korean report of worktree path, branch/commit, clean or dirty state, active-context movement, and remaining setup or cleanup. |
| Verification | Confirm repository root, worktree registry, target path safety, post-create working directory/status, and pre-remove status or prune dry run. |
| Stop condition | Stop when the requested lifecycle operation is verified, or a dirty/destructive/ambiguous target is reported before mutation. |

</instruction_contract>

<activation_examples>

Positive requests:

- "Create a worktree for `feature/auth` and open Codex there."
- "`git-worktree fix/api-timeout`"
- "Spin up three isolated worktrees for parallel agents."
- "Create a new worktree and move me into it."
- "List my active git worktrees and remove the stale ones safely."
- "I'm already in this worktree; delete this worktree safely."
- "Set up PR #42 for review in a separate worktree."

Negative requests:

- "Create a new branch here and checkout it." Use normal Git branch workflow.
- "Explain what Git worktree means." Answer directly.
- "Make a Docker dev environment for each branch." Use a container/dev-env workflow instead.

Boundary request:

- "Set up an isolated workspace for this risky refactor." Use this skill if Git branch isolation is enough; escalate to a container/VM workflow only if runtime, database, port, or dependency isolation is required.

</activation_examples>

<trigger_conditions>

- Canonical path: `<repo-root>/.hyper/git-worktree/<folder_name>` unless the user provided another path.
- Direct argument: when the user invokes `git-worktree <ARGUMENT>` or supplies one positional argument after the skill name, treat it as an explicit create target and do not ask what worktree to create. Interpret it as the branch/task label unless it is clearly a PR/issue/ref/path; preserve the branch/ref text and sanitize only the folder label. Ask only if it is unsafe, reserved, conflicts with an unrelated path, or cannot map to a Git ref/branch/task label.
- Work intent: with no argument, branch, PR, issue, or task supplied, ask what work will happen in the worktree before creating it. For Korean users, ask exactly: "이 worktree에서 어떤 작업을 할 예정인가요?" Derive a concise sanitized slug from the answer.
- Operation: infer the operation from the request whenever possible. If it is truly ambiguous, ask one short question in the user's language; for Korean users, list create, list, open/move, delete, clean up, repair, lock, and unlock in Korean. Never ask a generic English operation menu.
- Pathless removal: when the active context is inside a linked worktree, the current worktree root is the target.

</trigger_conditions>

<skill_architecture>

- Core (`SKILL.md`): routing, target resolution, phase order, required and forbidden behavior, stop condition.
- Rules: `rules/worktree-lifecycle.md` owns command patterns, naming, safety checks, removal, pruning, repair, and context-move rules.
- References: `references/source-survey.md` holds the rationale and upstream behavior comparison; it is not loaded by default.
- Assets: `assets/evals/git-worktree-cases.jsonl`, the trigger and behavior corpus.
- Scripts: `scripts/validate-git-worktree-skill.sh` runs the deterministic skill regression command.

</skill_architecture>

<loop_policy>

None. One pass per requested lifecycle operation: discover, resolve the target, check safety, mutate, verify, report. A repeated attempt is a new user-requested operation, not a retry loop; a dirty, destructive, or ambiguous target ends the pass before mutation.

</loop_policy>

<language_and_translation_default>

Ask clarification questions in the user's language: Korean prompts get Korean questions and a Korean operation list, never an English menu. Write the report in Korean unless the user asked otherwise, and keep paths, branch names, and commands verbatim.

</language_and_translation_default>

<reference_routing>

- Read [rules/worktree-lifecycle.md](rules/worktree-lifecycle.md) before any lifecycle command, and whenever naming, removal, pruning, repair, or context movement is in question.
- Read [references/source-survey.md](references/source-survey.md) only when the rationale, upstream behavior, or a source comparison matters.

</reference_routing>

<support_file_read_order>

1. This core, to confirm the operation and resolve the target path.
2. `rules/worktree-lifecycle.md` for the command and safety checks of that operation.
3. `references/source-survey.md` when rationale or upstream behavior needs support.
4. `scripts/validate-git-worktree-skill.sh`, run after editing this skill folder and checked against `assets/evals/git-worktree-cases.jsonl`.

</support_file_read_order>

<workflow>

1. Confirm the repository root with `git rev-parse --show-toplevel` and read `git worktree list --porcelain`.
2. Infer the operation: create, open, list, remove, prune, repair, lock, or unlock.
3. Resolve the target: a direct argument or stated task for create (ask the work-intent question only when neither exists); the saved current top-level path for pathless removal inside a linked worktree, stopping if it is the main worktree.
4. Run the lifecycle rule's safety checks and command for that operation.
5. For create and enter/open/switch requests, do not stop after `git worktree add`; move the active context there or prove the next command ran with `workdir=<path>`.
6. Report path, branch/commit, clean/dirty state, which context-move mechanism was used, remaining setup, and for cleanup the remaining `git worktree list`.

</workflow>

<required>

| Category | Rule |
|------|------|
| Context move | A worktree creation is not complete until the active execution context has moved: actually execute `cd <path>` in a persistent shell, or set `workdir=<path>` for the next command and keep it there. Do not merely display `cd <path>` as the answer; when the parent shell cannot change, report it as the user's fallback and state whether the agent context moved. |
| Exclude before nesting | Add or verify a local exclude for `.hyper/git-worktree/` before creating nested worktrees. |
| Status before removal | Check `git -C <path> status --short` and `git worktree prune --dry-run` before removing or pruning. |
| Pathless removal | Save the current top-level path, refuse the main worktree, move to a safe worktree, then remove the saved target. |
| Native tools | Prefer native `git worktree` commands over extra managers, with one task, branch, terminal session, and editor window per worktree. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| English menu | showing a generic English operation menu to a Korean user |
| Main worktree | removing the main worktree, or the worktree the agent is currently in before moving out |
| Unchecked removal | removing a worktree before reading its status, or forcing removal the user did not request |
| Unverified creation | reporting a worktree as ready without `git worktree list` evidence and a proven context move |
| Convention drift | creating worktrees outside `.hyper/git-worktree/<folder_name>` when the user gave no other path |

</forbidden>

<validation>

Deterministic regression command:

```bash
bash skills/git-worktree/scripts/validate-git-worktree-skill.sh
```

Operation checks:

- [ ] `git rev-parse --show-toplevel` succeeds and `git worktree list --porcelain` is read before path construction or mutation.
- [ ] direct `git-worktree <ARGUMENT>` invocations create from the argument without asking what worktree to create; otherwise a missing work intent gets one concise question before choosing `<folder_name>`.
- [ ] clarification questions match the user's language; Korean users are not shown English operation menus.
- [ ] `.hyper/git-worktree/` is ignored or locally excluded before nested worktree creation.
- [ ] removal checks `git -C <path> status --short` first unless the user explicitly asks for force removal.
- [ ] current-worktree deletion saves the current top-level path, refuses the main worktree, moves to another safe worktree, and removes the saved target path.
- [ ] cleanup runs `git worktree prune --dry-run` before `git worktree prune`.
- [ ] after creation, subsequent commands use the new worktree as their working directory: a persistent session actually changed directory, or at least one post-create command ran via `workdir=<path>`.
- [ ] `assets/evals/git-worktree-cases.jsonl` still covers the lifecycle operations and boundaries this file states.

</validation>
