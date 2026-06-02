# Speed And Automation

Use this rule when `git-maker` feels slow or the user explicitly asks for a faster commit-and-push path.

## Fast Path

Prefer this path before the verbose manual workflow:

```bash
scripts/git-maker-fast.sh inspect . --jobs 4
```

Then commit each logical group with the existing commit helper:

```bash
scripts/git-commit.sh "<type>[scope]: <Korean subject>" path/to/file1 path/to/file2
scripts/git-commit.sh --repo path/to/repo "<type>[scope]: <Korean subject>" path/to/file1
```

After all commits succeed, reuse the inspected repo list instead of rediscovering:

```bash
scripts/git-maker-fast.sh push /absolute/repo/path
scripts/git-maker-fast.sh push --force /absolute/repo/path
```

If the fast helper fails or omits needed detail, fall back to `repo-discover.sh`, `repo-status.sh`, `git-commit.sh`, and `git-push.sh`.

## What The Fast Helper Automates

| Step | Automation |
|------|------|
| repository discovery | current repo/worktree short-circuit; descendant discovery prunes heavy generated directories and recognizes linked worktree `.git` files |
| multi-repo inspection | parallel per-repo status blocks via `--jobs` / `GIT_MAKER_JOBS` |
| file inventory | emits staged, unstaged, and untracked file lists for grouping |
| worktree context | emits `worktree|primary` or `worktree|linked` plus git dir metadata so operators keep checkout roots separate from the common git dir |
| push | accepts explicit repo paths, uses `GIT_TERMINAL_PROMPT=0`, skips detached HEAD, blocks protected force pushes |

## Parallelization Rules

- Parallelize read-only inspection across repositories.
- Do not parallelize commits inside the same repository; staging/index state is shared.
- Repositories may be committed independently, but only when file groups and repo boundaries are already clear.
- Push only after all intended commits have succeeded.

## Slow Path Triggers

Use the slower full workflow when:

- partial hunks require `git add -p`
- staged and unstaged changes are intentionally mixed
- hooks fail and require diagnosis
- filter arguments do not clearly map to files
- a push failure needs remote/auth investigation

## Timing Expectations

The helper is meant to remove avoidable overhead, not bypass safety. It speeds up:

- duplicated repository discovery between commit and push
- large descendant tree scans by pruning common generated folders
- linked worktree runs by resolving the checkout root without assuming `.git` is a directory
- multiple-repository status checks by parallelizing read-only work

It does not remove the need to inspect diffs, group logical changes, write correct commit messages, or handle hook failures.
