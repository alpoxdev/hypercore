# Issue And Branch Workflow

Use this rule file before running `gh issue`, `gh issue develop`, `git switch`, or `git checkout`.

## Preconditions

- Work only inside the current repository.
- Confirm `git rev-parse --show-toplevel` exits 0.
- Confirm `gh auth status` exits 0 for the host that owns the target repository.
- Confirm the target repository with `gh repo view --json nameWithOwner,url` unless the user supplied an explicit repository.
- Check `git status --short --branch` before checkout. If the working tree has unrelated uncommitted changes, avoid destructive checkout behavior; use `git switch` only when Git can preserve the changes.

## Existing Issue

When the user supplies an issue number or URL:

1. Normalize the issue reference for `gh`.
2. Run:

```bash
gh issue view "$issue" --json number,title,state,url
```

3. Run:

```bash
gh issue develop --list "$issue"
```

4. If a linked branch is present, fetch and checkout that branch. Prefer exact branch names from `gh` output over regenerated names.
5. If no linked branch is present, derive `type/<number>-<slug>` and run:

```bash
gh issue develop "$number" --checkout --name "$branch"
```

6. Verify with:

```bash
git branch --show-current
git status --short --branch
```

Do not ask for confirmation in this path unless the issue cannot be resolved, checkout would overwrite changes, or credentials/permissions are missing.

## New Issue

When the user supplies a topic/task instead of an existing issue:

1. Draft a concise title.
2. Draft a body with these sections when the information is available:

```markdown
## Summary

## Context

## Acceptance Criteria

## Notes
```

3. Create the issue:

```bash
gh issue create --title "$title" --body "$body"
```

4. Extract or confirm the issue number:

```bash
gh issue view "$issue_url_or_number" --json number,title,url
```

5. Derive the branch name from the created issue number and title.
6. Create and checkout the linked branch:

```bash
gh issue develop "$number" --checkout --name "$branch"
```

7. Verify active branch.

## Branch Type Selection

| Intent signal | Branch type |
|---|---|
| bug, broken, error, regression, failure, Korean equivalent | `fix` |
| new user-visible behavior, enhancement, feature | `feat` |
| docs, README, comments-only docs | `docs` |
| dependency, config, cleanup, maintenance | `chore` |
| structure change without intended behavior change | `refactor` |
| tests, QA, fixtures | `test` |

When uncertain, choose `chore` for maintenance work and `feat` for user-facing capability work.

## Branch Name Rules

- Default format: `type/<issue-number>-<slug>`.
- Use lowercase ASCII, digits, hyphens, and one slash after the type.
- Build the slug from the issue title or user-provided task summary.
- Remove punctuation, collapse whitespace to hyphens, trim repeated hyphens, and keep the slug short enough to scan.
- Avoid branch names that are only numbers, only issue IDs, or only generic words.

Examples:

- `fix/42-oauth-callback-timeout`
- `feat/87-github-issue-branch-skill`
- `docs/101-update-install-guide`
- `chore/118-refresh-ci-cache`

## Fallbacks

- If `gh issue develop` is unavailable, first verify whether the local `gh` version supports it with `gh issue develop --help`.
- If the command is unavailable but issue creation succeeded, create a local branch with `git switch -c "$branch"` from the chosen base and report that GitHub's linked-branch state was not confirmed.
- If checkout fails because of local changes, stop and report the exact blocking files instead of stashing or discarding them.
- If authentication or permission fails, stop before creating local state that implies a GitHub-linked branch exists.
