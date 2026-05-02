# Agent Parallelism

Use this rule when `git-maker` is active and the dirty tree is complex enough that Claude Code or Codex subagents can reduce analysis time without touching git state.

## When To Delegate

Spawn parallel read-only agents only when at least one condition is true:

- multiple repositories are in scope
- multiple logical commit groups are likely
- the diff is large enough that grouping, safety review, and message drafting can run independently
- the user explicitly asks to use parallel agents

Do not spawn agents for a single obvious one-file or one-group commit; coordination overhead is usually slower than direct execution.

## Safe Agent Lanes

| Lane | Responsibility | Inputs | Output | Edit/stage/commit? |
|------|------|------|------|------|
| Repo Mapper | Map repositories/worktree roots, staged/unstaged/untracked files, and ownership boundaries | `git-maker-fast.sh inspect` output, `git diff --name-only` | repo/file map, linked-worktree context, and ambiguity list | no |
| Grouping Critic | Propose logical commit groups and flag unrelated files or secrets | status, file list, diff summaries | group plan with confidence and exclusions | no |
| Message Drafter | Draft Korean Conventional Commit subjects/bodies | group plan and diff summaries | message candidates with rationale | no |
| Safety Verifier | Check secrets, destructive operations, protected branch, detached HEAD, upstream/push risk | status, branch/upstream output, script diff | pass/block report | no |
| Main Integrator | Resolve conflicts between lanes, stage, commit, push, and report | all lane outputs | actual commits and push summary | yes |

## Hard Boundaries

- Subagents may inspect files, run read-only commands, and propose decisions.
- Subagents must not run `git add`, `git commit`, `git push`, `git reset`, `git rebase`, `git clean`, or `git restore`.
- Same-repository staging and commit must remain single-owner because the git index and staged set are shared.
- Push waits until every intended commit group succeeds.
- The main integrator owns final grouping, message selection, staging, commit execution, and push.

## Runtime Notes

- Claude Code: use task-specific subagents for independent lanes and coordinate results through the lead agent.
- Codex: use native/project-local subagents when available for bounded read-only lanes.
- Project-local agent definitions may be added later under `.claude/agents/` or `.codex/agents/`, but this skill must not depend on home/global agent directories.
- If the runtime cannot spawn subagents, use the same lane checklist manually in the main context.

## Recommended Flow

1. Main integrator runs:

   ```bash
   scripts/git-maker-fast.sh inspect . --jobs 4
   ```

2. If complex, spawn independent read-only lanes with the same inspect output.
3. Integrate lane outputs into one final commit plan.
4. Stage and commit each group sequentially with `scripts/git-commit.sh`.
5. Push only after every commit succeeds, preferably with explicit repo paths from preflight.


## Delegation Prompt Templates

Use these templates as copy-ready prompts. Replace bracketed fields with the current inspect output or file list. Every lane is read-only.

### Repo Mapper

```text
Read-only git-maker repo mapping. Do not edit, stage, commit, push, or restore files.
Input: [paste git-maker-fast inspect output and optional git diff --name-only].
Return: repositories/worktree roots in scope, staged/unstaged/untracked files by repo, linked-worktree context if present, ownership boundaries, and ambiguity list.
```

### Grouping Critic

```text
Read-only git-maker grouping review. Do not edit, stage, commit, push, or restore files.
Input: [paste status, file list, and focused diff summaries].
Return: proposed logical commit groups, files included in each group, exclusions, confidence, and any secret/unrelated-change concerns.
```

### Message Drafter

```text
Read-only git-maker commit message drafting. Do not edit, stage, commit, push, or restore files.
Input: [paste final or candidate group plan and diff summary].
Return: Korean Conventional Commit subject/body candidates for each group, with rationale, no fabricated issue footers, and no command-style endings such as `~하라`, `~해라`, or `~라`.
```

### Safety Verifier

```text
Read-only git-maker safety verification. Do not edit, stage, commit, push, or restore files.
Input: [paste branch/upstream/status output, changed file list, and changed git-maker script diff if this run modifies scripts].
Return: pass/block verdict for secrets, destructive git operations, protected branch force-push risk, detached HEAD, upstream risk, and missing validation.
```

## Conflict Resolution

| Conflict | Resolution |
|------|------|
| Grouping Critic and Message Drafter disagree | prefer the grouping evidence; rewrite message after final group selection |
| Safety Verifier reports a blocker | stop mutation and report the blocker |
| Repo Mapper finds repo boundary mismatch | re-run focused inspect before staging |
| Agent output is stale after edits/hooks | refresh status and revalidate before push |

## Validation

Before final reporting, confirm:

- every spawned lane was read-only
- no two agents owned the same git index mutation
- final staged files match the main integrator's selected group
- push was attempted only after all commit groups succeeded
- skipped/failed push targets are reported explicitly
