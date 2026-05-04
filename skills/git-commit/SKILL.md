---
name: git-commit
description: "[Hyper] Create one or more Conventional Commits from the current repository state. Inspect staged and unstaged changes, group them into logical change sets, generate a compliant message per group, and commit each group separately in sequence."
license: MIT
allowed-tools: Bash
compatibility: Requires Bash and scripts under skills/git-commit/scripts.
---

# Git Commit Skill

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

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

- Create one or more Conventional Commits from the current repository state, one per logical change group.
- Base every decision on actual git status and diff output.
- When multiple logical groups of changes exist, identify each group and commit them separately in sequence.

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
- If the candidate set contains multiple logical change groups, identify each group and commit them separately in sequence. Do not stop or ask for clarification — iterate through all groups.
- If the current session's work is already fully committed, allow the remaining uncommitted changes to become the next candidate set and apply the same grouping logic.

If ARGUMENT is "ALL" or "all":

- Take ALL uncommitted changes in the repository, regardless of whether they were touched in the current session.
- Group all changes into logical change sets based on related functionality, feature area, or purpose.
- Commit each group separately in sequence. Do not stop, do not ask for confirmation, do not skip any files.
- Every uncommitted file must be included in exactly one commit group. No file may be left behind.

If ARGUMENT is present (other than ALL):

- Treat ARGUMENT as the primary commit target or filter.
- Use it to narrow repository discovery, file selection, staging, and commit message generation.
- If the filtered set contains multiple logical groups, commit each group separately.
- Stop if ARGUMENT does not match the actual repository state.

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
| Logical scope | Each commit covers exactly one logical change. When multiple logical groups exist, identify each group and commit them separately in sequence. Do not stop to ask — iterate through all groups. |
| Staging discipline | Stage only the files required for the selected logical change. Do not stage everything by default. |
| Type selection | Choose the Conventional Commit type from the actual dominant change, not from filenames alone. |
| Scope selection | Use a scope only when one module, package, feature area, or subsystem clearly owns the change. Omit scope when the change spans multiple unrelated areas or the scope would be vague. |
| Language | Write commit subject and body in Korean. The Conventional Commit `type` and `scope` stay in English (e.g. `feat(auth):`), but the description after the colon and the body text must be in Korean. |
| Subject line | Use imperative mood, present tense, lowercase after the colon, and keep the subject under 72 characters. |
| Body/footer | Add a body only when the subject cannot capture important context. Add footers only for verified issue references, breaking changes, or explicitly requested metadata. |
| Push confirmation | After `git add` and `git commit` complete successfully, ask whether to run `git push`. In Codex, ask in plain text. In OpenCode, prefer its native ask-style approval prompt when available; otherwise fall back to plain text. |
| Safety | Never commit secrets, generated credentials, or unrelated user changes. Never use `--no-verify`, force flags, or destructive git commands unless the user explicitly asks. |
| Failure handling | If hooks fail, inspect the error. Fix and retry only when the failure is directly caused by the current change set and the fix is safe. Otherwise stop and report the blocker. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Staging | `git add .` or blanket staging when unrelated changes exist (exception: ALL mode stages all files but still commits per logical group) |
| Argument handling | ignoring an explicit ARGUMENT and committing a broader change set than requested |
| Cherry-picking in ALL mode | skipping files or leaving uncommitted changes behind when ARGUMENT is ALL |
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
| No ARGUMENT provided | Start from the current session's modified files and repositories, confirm them with git state, group into logical changes, and commit each group separately |
| No ARGUMENT provided, and current-session work is already committed | If uncommitted changes still remain, allow the remaining uncommitted change set to become the next candidate and apply the same grouping logic |
| ARGUMENT is "ALL" or "all" | Take ALL uncommitted changes regardless of session, group into logical changes, and commit each group separately — no stopping, no skipping, every file must be committed |
| ARGUMENT provided (other than ALL) and matches one logical change | Use ARGUMENT as the primary filter for repository discovery, staging, and message generation |
| ARGUMENT provided (other than ALL) and covers multiple logical groups | Use ARGUMENT as the filter, then group and commit each group separately |
| ARGUMENT provided (other than ALL) but conflicts with git state | Stop and report the mismatch |

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
| No staged changes, multiple unrelated changes | Group changes into logical sets. Stage and commit each group separately in sequence. |
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
- ARGUMENT is "ALL" or "all": take ALL uncommitted changes regardless of session scope.
- ARGUMENT present (other than ALL): derive the initial candidate set from ARGUMENT, then verify it with git state.

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

## Phase 2. Identify logical change groups

Analyze the full candidate set and partition it into logical change groups. Each group should contain files that belong to the same feature, fix, module, or purpose.

Grouping heuristics (apply in order):
1. Files that implement the same feature or fix belong together.
2. Test files belong with their corresponding implementation files.
3. Config/build changes related to the same feature belong with that feature.
4. Unrelated standalone changes each form their own group.

In ALL mode: every uncommitted file must appear in exactly one group. No file may be left behind.

## Phase 3. Stage and commit each group (loop)

For each logical group identified in Phase 2, repeat the following:

### 3a. Stage the group

Use targeted staging commands. Stage only the files in the current group.

```bash
git add path/to/file1 path/to/file2
git add -p
git restore --staged path/to/file
```

### 3b. Generate the commit message for this group

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

### 3c. Execute the commit

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

### 3d. Continue to next group

Move to the next logical group. Repeat 3a–3c until all groups are committed.

Stop within a group only if:
- secrets or credential files appear in the candidate set
- ARGUMENT (other than ALL) conflicts with the actual modified files or repositories

If multiple descendant repositories are in scope, repeat Phase 2 and Phase 3 inside each repository separately.

## Phase 4. Ask whether to push

After a successful commit, ask for explicit push confirmation.

- In Codex: ask a plain-text question such as `Commit created. Run git push?`
- In OpenCode: prefer the runtime-native approval prompt rather than assuming a generic Y/N flow
- In other runtimes with interactive confirmation UI: use the native confirmation surface when available, but explicit confirmation is still required before push

## Phase 5. Handle commit failures or push follow-up

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
- `fix(cache): prevent stale data when reading projects`
- `docs(cli): document release prerequisites`
- `refactor(worker): split mailbox parsing logic`

## Bad subjects

- `updated stuff`
- `Fix bug in the API module`
- `feat: add new feature`
- `chore(repo): change many things`

## Good multiline commit

```bash
git commit -m "$(cat <<'EOF'
feat(api): filter team memberships

Include only memberships visible to active users in the list response.

Refs: #482
EOF
)"
```

## Good no-argument handling (single group)

```text
/git-commit
```

Result:
- inspect work done in the current session
- confirm the matching repositories and files with git state
- all changes belong to one logical group → commit once

## Good no-argument handling (multiple groups)

```text
/git-commit
```

Result:
- inspect work done in the current session
- session touched auth module files AND unrelated docs files
- group 1: auth module changes → `feat(auth): add passkey login flow`
- group 2: docs changes → `docs(cli): document release prerequisites`
- commit group 1, then commit group 2

## Good no-argument fallback handling

```text
/git-commit
```

Result:
- detect that the current session's work is already committed
- inspect the remaining uncommitted changes
- group and commit each remaining logical change

## Good ALL mode handling

```text
/git-commit ALL
```

Result:
- take ALL uncommitted changes, regardless of current session
- group into logical change sets
- commit each group separately — no files left behind

Example output sequence:
```bash
scripts/git-commit.sh "feat(auth): add passkey login flow" src/auth/passkey.ts src/auth/passkey.test.ts
scripts/git-commit.sh "fix(cache): prevent stale data when reading projects" src/cache/reader.ts
scripts/git-commit.sh "docs(cli): document release prerequisites" docs/release.md
scripts/git-commit.sh "chore: update dependencies" package.json pnpm-lock.yaml
```

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
- Confirm the final candidate set matches the current session when no ARGUMENT was provided, matches ALL uncommitted changes when ARGUMENT is ALL, or matches ARGUMENT when another ARGUMENT was provided.
- Confirm that no-argument mode may fall back to remaining uncommitted changes only after current-session work is already committed.
- Confirm that when multiple logical groups exist, each group was committed separately in sequence.
- Confirm that in ALL mode, every uncommitted file was included in exactly one commit group with no files left behind.
- Confirm each descendant repository received its own `git add` and `git commit` sequence.
- Confirm `git push` was not run until explicit confirmation was received.
- Confirm each individual commit covers exactly one logical change.
- Confirm the final message matches Conventional Commits format.
- Confirm the subject is imperative, present tense, and under 72 characters.
- Confirm no secret or credential files were included.
- Confirm no forbidden flags or history-rewrite commands were used.
- Confirm hook failures were handled explicitly instead of bypassed.

</validation>
