# Commit And Push Policy

Use this rule when `git-maker` is active and you need the durable commit/push contract after the fast inspection pass.

## Argument Modes

| Input | Action |
|------|------|
| no argument | Start from current-session changes, verify against git state, group into logical commits, then push. If session changes are already committed, use remaining uncommitted changes as the next candidate set. |
| `ALL` or `all` | Include every uncommitted file, group into logical commits, and leave no file behind. |
| `--force` | Remove `--force` from commit arguments and pass it only to the push phase, which must use `--force-with-lease` and still block `main`/`master`. |
| other argument | Treat it as a filter for repo discovery, file selection, staging, and message generation. Stop if it does not match actual git state. |

## Commit Rules

| Category | Rule |
|------|------|
| Inspect first | Run a status/preflight command before staging or committing. |
| Diff source | If staged changes exist, treat staged files as the default candidate and inspect staged diff. If nothing is staged, inspect unstaged/untracked changes. |
| Repository boundary | Multiple repositories must be committed independently. Never stage or commit from a non-repository parent as if nested repos were one repo. In linked Git worktrees, use the checkout root from `git rev-parse --show-toplevel` as the boundary; do not collapse it to the shared `git-common-dir`. |
| Logical scope | Each commit covers exactly one logical change. Commit multiple groups sequentially. |
| Staging discipline | Stage only files required for the selected group. Do not use blanket staging unless `ALL` mode truly includes every uncommitted file and grouping still happens per logical unit. |
| Type selection | Choose the Conventional Commit type from the actual dominant change. |
| Scope selection | Use scope only when one module/package/feature clearly owns the change. |
| Language | Commit subject and body are Korean; Conventional Commit type/scope remain English. |
| Subject line | Use neutral Conventional Commit result/summary wording, not Korean command/imperative endings; lowercase after colon, under 72 characters. |
| Body/footer | Add only when needed for why/risk/follow-up, breaking change, verified issue references, or explicitly requested metadata. |
| Safety | Never commit secrets, generated credentials, or unrelated user changes. Never use `--no-verify`, rebase, reset, amend, or destructive history operations unless explicitly requested. |
| Hook failures | Inspect the error. Fix and retry only if the current change caused it and the fix is safe; otherwise stop and report the blocker. |

## Commit Message Tone

Write the Korean subject as a commit-message summary, not as an instruction to the reader.

| Use | Avoid | Why |
|------|------|------|
| `build(deps): align build paths with stable toolchain versions` | `build(deps): make the build paths use stable toolchain versions` | The avoided form reads like an instruction. |
| `build(cloudflare): stabilize Workers deployment path` | `build(cloudflare): stabilize the Workers deployment path now` | The avoided form reads like an imperative order. |
| `refactor(nextjs): secure deploy stability with stronger architecture boundaries` | `refactor(nextjs): force architecture boundaries to secure deploy stability` | Commit subjects should describe the change/result. |

Preferred Korean subject shapes:

- noun/result phrase, such as "build path alignment", "deployment path stabilization", or "validation flow improvement"
- concise past-effect/result summary, such as "dependency resolution pinned" or "routing boundary separated"
- no sentence-final Korean command endings or direct orders to future maintainers

If the natural draft reads like a command, rewrite it to the result now present in the commit.

## Grouping Heuristics

1. Files that implement the same feature or fix belong together.
2. Tests belong with corresponding implementation files.
3. Config/build changes belong with the feature they support.
4. Unrelated standalone changes each form their own group.
5. In `ALL` mode, every uncommitted file must appear in exactly one group.

## Push Rules

| Category | Rule |
|------|------|
| Commit first | All commit groups must succeed before any push. |
| No confirmation | Do not ask whether to push after successful commits; push automatically. |
| Explicit repos | Prefer passing the repo list from `scripts/git-maker-fast.sh inspect` into `scripts/git-maker-fast.sh push` to avoid duplicate discovery. |
| Worktrees | Linked worktrees are valid push targets when on a named branch; pass their checkout root paths, not `.git/worktrees/...` or the common git dir. |
| Upstream | If no upstream exists, push with `-u origin <branch>`. |
| Safety | Never force push to `main` or `master`. Never push from detached HEAD. |
| Failure | If push fails, report failed repos. Commits remain local; do not pretend the operation completed. |

## Type Selection

| Observed dominant change | Type |
|------|------|
| user-facing capability added | `feat` |
| incorrect behavior fixed | `fix` |
| docs only | `docs` |
| formatting/style only | `style` |
| internal restructure | `refactor` |
| performance improvement | `perf` |
| tests added/updated | `test` |
| build/dependency/tooling | `build` |
| CI automation | `ci` |
| maintenance/metadata | `chore` |
| revert | `revert` |

## Failure Handling

| Failure case | Response |
|------|------|
| candidate filter does not match git state | stop; do not push |
| no changes to commit | report no commit was created; push only if there are already unpushed commits and user intent still includes push |
| one commit group fails | stop; do not push any later groups |
| push fails | report which repositories failed; local commits remain safe |
| network/auth prompt risk | use non-interactive push helper output; report remote/auth blocker if push cannot proceed |
