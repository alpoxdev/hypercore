---
name: git-commit
description: 'Create a Conventional Commit from the current repository state. Inspect staged and unstaged changes, choose one logical change set, generate a compliant message, and stop on ambiguous or risky conditions.'
license: MIT
allowed-tools: Bash
compatibility: Requires Bash and scripts under skills/git-commit/scripts.
---

# Git Commit Skill

<scripts>

## Available scripts

| Script | Purpose |
|------|------|
| `scripts/repo-discover.sh [start_dir]` | Detect current-repo vs descendant-repo layout |
| `scripts/repo-status.sh [repo]` | Show branch, status, staged summary, and unstaged summary |
| `scripts/git-commit.sh [--repo path] "msg" [files...]` | Commit staged or selected files in one repository |
| `scripts/git-push.sh [--repo path] [--force]` | Push the current branch safely in one repository |

</scripts>

<objective>

- Create one Conventional Commit from the current repository state.
- Base every decision on actual git status and diff output.
- Stop instead of guessing when the change set is ambiguous, mixed, or risky.

</objective>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "commit these changes" | yes |
| "make a git commit" | yes |
| "/git-commit" | yes |
| requests that only ask for push/rebase/reset | no, unless commit creation is also requested |

</trigger_conditions>

<argument_validation>

If ARGUMENT is missing:

- Default to the files, repositories, and logical change units touched in the current session.
- Verify the session-derived candidate set against actual `git status` and `git diff` output before staging or committing.
- If the current session's work is already fully committed, allow the remaining uncommitted changes to become the next candidate set.
- Stop if the current session contains multiple unrelated change groups and the intended commit split is not clear.

If ARGUMENT is present:

- Treat ARGUMENT as the primary commit target or filter.
- Use it to narrow repository discovery, file selection, staging, and commit message generation.
- Stop if ARGUMENT does not match the actual repository state or still spans multiple unrelated logical changes.

</argument_validation>

<scope_assumptions>

- Start from the current working directory. If it is not a git repository, inspect descendant directories for git repositories before proceeding.
- Commit only. Do not push, amend, rebase, or rewrite history unless the user explicitly asks.
- After a successful commit, ask whether to push. In Codex, do this with a plain-text confirmation question. In OpenCode, prefer the runtime-native approval prompt when available.
- Use Bash commands only.

</scope_assumptions>

<required>

| Category | Rule |
|------|------|
| Inspect first | Run `git status --short --branch` before any staging or commit command. |
| Argument mode | Resolve whether execution is in session-default mode or explicit-argument mode before repository discovery and staging. |
| Repository discovery | Determine whether the current working directory is a git repository. If not, inspect descendant directories and build a repository list before any `git add` or `git commit` action. |
| Diff source | If staged changes exist, treat the staged set as the default commit candidate and inspect with `git diff --staged`. If nothing is staged, inspect `git diff`. |
| Repository boundary | When multiple git repositories are discovered under the current directory, run `git status`, `git add`, and `git commit` inside each repository separately. Never treat multiple repositories as one commit unit. |
| Logical scope | Commit one logical change only. If the repo contains unrelated changes, split them or stop for clarification. |
| Staging discipline | Stage only the files required for the selected logical change. Do not stage everything by default. |
| Type selection | Choose the Conventional Commit type from the actual dominant change, not from filenames alone. |
| Scope selection | Use a scope only when one module, package, feature area, or subsystem clearly owns the change. Omit scope when the change spans multiple unrelated areas or the scope would be vague. |
| Subject line | Use imperative mood, present tense, lowercase after the colon, and keep the subject under 72 characters. |
| Body/footer | Add a body only when the subject cannot capture important context. Add footers only for verified issue references, breaking changes, or explicitly requested metadata. |
| Push confirmation | After `git add` and `git commit` complete successfully, ask whether to run `git push`. In Codex, ask in plain text. In OpenCode, prefer its native ask-style approval prompt when available; otherwise fall back to plain text. |
| Safety | Never commit secrets, generated credentials, or unrelated user changes. Never use `--no-verify`, force flags, or destructive git commands unless the user explicitly asks. |
| Failure handling | If hooks fail, inspect the error. Fix and retry only when the failure is directly caused by the current change set and the fix is safe. Otherwise stop and report the blocker. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Staging | `git add .` or blanket staging when unrelated changes exist |
| Argument handling | ignoring an explicit ARGUMENT and committing a broader change set than requested |
| Repository boundary | running `git add` or `git commit` from a non-repository root and assuming nested repositories will be included |
| Push | auto-running `git push` after commit without explicit confirmation |
| Hooks | `--no-verify` unless the user explicitly requests it |
| History rewrite | amend, rebase, reset, force push, or other history-editing commands without explicit request |
| Secrets | committing `.env`, credentials, private keys, or tokens |
| Guessing | inventing a scope, footer, or grouped change set that is not supported by the diff |

</forbidden>

<decision_tables>

## Argument mode

| Input state | Action |
|------|------|
| No ARGUMENT provided | Start from the current session's modified files and repositories, then confirm them with git state before selecting the commit candidate |
| No ARGUMENT provided, and current-session work is already committed | If uncommitted changes still remain, allow the remaining uncommitted change set to become the next candidate |
| ARGUMENT provided and matches one logical change | Use ARGUMENT as the primary filter for repository discovery, staging, and message generation |
| ARGUMENT provided but conflicts with git state | Stop and report the mismatch |
| ARGUMENT provided but still covers multiple unrelated changes | Stop and ask for a narrower target |

## Repository discovery

| Observed layout | Action |
|------|------|
| Current working directory is a git repository | Operate in the current repository and follow the normal commit workflow |
| Current working directory is not a git repository, but one or more descendant directories are repositories | Build the repository list and run the full commit workflow separately inside each repository that has relevant changes |
| Current working directory is not a git repository and no descendant repository exists | Stop and report that no git repository was found |

## Change-set selection

| Repository state | Action |
|------|------|
| Staged changes only | Commit the staged set. |
| Staged + unstaged changes, same logical change | Stage the missing files deliberately, then commit the full set. |
| Staged + unstaged changes, unrelated changes mixed together | Default to the staged set only, or stop if the intended commit target is unclear. |
| No staged changes, one clear logical change | Stage only the relevant files, then commit. |
| No staged changes, multiple unrelated changes | Do not guess. Ask how to split or stage one group explicitly. |
| No diff to commit | Stop and report that there is nothing to commit. |

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

## Subject/body/footer selection

| Condition | Output rule |
|------|------|
| One-line subject fully explains the change | Subject only |
| Why, risk, or follow-up matters for reviewers | Add a short body |
| Breaking API, schema, or behavior change | Use `!` and/or `BREAKING CHANGE:` footer |
| Verified issue or ticket reference exists | Add `Refs:` or `Closes:` footer |
| Co-author requested explicitly by the user | Add `Co-authored-by:` footer exactly as requested |

</decision_tables>

<workflow>

## Phase 1. Inspect repository state

Decide argument mode first:

- No ARGUMENT: derive the initial candidate set from the current session's work, then verify it with git state.
- No ARGUMENT fallback: if that session-derived set is already fully committed, inspect the remaining uncommitted changes and allow them to become the next candidate set.
- ARGUMENT present: derive the initial candidate set from ARGUMENT, then verify it with git state.

```bash
scripts/repo-discover.sh
```

Then branch by repository layout:

1. If `git rev-parse --show-toplevel` succeeds, inspect the current repository:

```bash
scripts/repo-status.sh
```

2. If the current directory is not a repository but descendant repositories exist, inspect each repository independently:

```bash
scripts/repo-status.sh path/to/repo
```

Do not run one `git add` or one `git commit` from the non-repository root for multiple descendant repositories.

## Phase 2. Select and prepare one logical change

Use targeted staging commands only when needed. The candidate set must match the current session when no ARGUMENT is provided, or match ARGUMENT when it is provided.

```bash
git add path/to/file1 path/to/file2
git add -p
git restore --staged path/to/file
```

Stop if:
- secrets or credential files appear in the candidate set
- unrelated changes cannot be separated confidently
- the user intent conflicts with the staged state
- ARGUMENT conflicts with the actual modified files or repositories
- multiple descendant repositories contain changes but the intended commit split is unclear

## Phase 3. Generate the commit message

Build:
1. `type`
2. optional `scope`
3. subject
4. optional body
5. optional footer

Message format:

```text
<type>[optional scope]: <subject>

[optional body]

[optional footer]
```

## Phase 4. Execute the commit

Subject only:

```bash
scripts/git-commit.sh "<type>[scope]: <subject>"
scripts/git-commit.sh --repo path/to/repo "<type>[scope]: <subject>"
```

Body or footer included:

```bash
scripts/git-commit.sh "$(cat <<'EOF'
<type>[scope]: <subject>

<optional body>

<optional footer>
EOF
)"
scripts/git-commit.sh --repo path/to/repo "$(cat <<'EOF'
<type>[scope]: <subject>

<optional body>

<optional footer>
EOF
)"
```

If multiple descendant repositories are in scope, repeat Phase 2 through Phase 4 inside each repository separately.

## Phase 5. Ask whether to push

After a successful commit, ask for explicit push confirmation.

- In Codex: ask a plain-text question such as `Commit created. Run git push?`
- In OpenCode: prefer the runtime-native approval prompt rather than assuming a generic Y/N flow
- In other runtimes with interactive confirmation UI: use the native confirmation surface when available, but explicit confirmation is still required before push

## Phase 6. Handle commit failures or push follow-up

| Failure case | Response |
|------|------|
| Hook or lint failure caused by current changes | Fix the issue, restage the affected files, and create a new commit attempt |
| Hook failure unrelated to the current change set | Stop and report the blocker |
| Empty commit after staging decision | Stop and report that nothing remains to commit |
| Merge conflict or index lock | Stop and report the repository state |
| User declines push | Stop after reporting the successful commit |
| User approves push | Run `scripts/git-push.sh` in the relevant repository, then report the result |

</workflow>

<examples>

## Good subjects

- `feat(auth): add passkey login flow`
- `fix(cache): avoid stale project reads`
- `docs(cli): document release prerequisites`
- `refactor(worker): split mailbox parsing logic`

## Bad subjects

- `updated stuff`
- `Fix bug in the API module`
- `feat: Added New Feature`
- `chore(repo): miscellaneous changes`

## Good multiline commit

```bash
git commit -m "$(cat <<'EOF'
feat(api): add team membership filter

Limit list responses to memberships visible to the active user.

Refs: #482
EOF
)"
```

## Good no-argument handling

```text
/git-commit
```

Result:
- inspect work done in the current session
- confirm the matching repositories and files with git state
- commit one logical change from that session

## Good no-argument fallback handling

```text
/git-commit
```

Result:
- detect that the current session's work is already committed
- inspect the remaining uncommitted changes
- allow one logical remainder change to become the next commit candidate

## Good explicit-argument handling

```text
/git-commit packages/api session validation fix
```

Result:
- treat `packages/api session validation fix` as the primary target
- limit repository discovery and staging to the matching repository and files
- generate the commit message from that target

## Good post-commit push confirmation

```text
Commit created. Run git push?
```

## Good OpenCode push confirmation

- Prefer OpenCode's native ask-style approval prompt when available
- If that prompt surface is not available in the current integration, ask in plain text before push

## Good multi-repository handling

```bash
scripts/git-commit.sh --repo packages/web "fix(web): handle empty session" src/auth.ts
scripts/git-commit.sh --repo packages/api "fix(api): validate session payload" src/routes/session.ts
```

## Bad multi-repository handling

```bash
git add packages/web/src/auth.ts packages/api/src/routes/session.ts
git commit -m "fix: update web and api"
```

</examples>

<validation>

- Confirm the repository layout was checked before staging or commit.
- Confirm the argument mode was resolved before repository discovery.
- Confirm descendant repositories, if any, were handled one repository at a time.
- Confirm the final candidate set matches the current session when no ARGUMENT was provided, or matches ARGUMENT when it was provided.
- Confirm that no-argument mode may fall back to remaining uncommitted changes only after current-session work is already committed.
- Confirm each descendant repository received its own `git add` and `git commit` sequence.
- Confirm `git push` was not run until explicit confirmation was received.
- Confirm the committed files match one logical change.
- Confirm the final message matches Conventional Commits format.
- Confirm the subject is imperative, present tense, and under 72 characters.
- Confirm no secret or credential files were included.
- Confirm no forbidden flags or history-rewrite commands were used.
- Confirm hook failures were handled explicitly instead of bypassed.

</validation>
