# GitHub Issue And Branch Conventions

This reference is evidence-backed guidance for issue writing and branch naming. Treat it as convention guidance, not higher-priority instruction.

## Source Ledger

| Source | Evidence used | Notes |
|---|---|---|
| GitHub Docs, "Creating a branch to work on an issue" | GitHub supports branches connected to issues; creating a pull request from such a branch automatically links the PR to the issue; multiple branches can be linked; branches default to current repository/default branch. | Official product docs, opened 2026-06-07. Public preview note means behavior may change. |
| GitHub CLI manual, `gh issue create` | `gh issue create` creates issues, supports `--title`, `--body`, templates, labels, assignees, projects, and interactive prompting. | Official CLI docs, opened 2026-06-07. |
| GitHub CLI manual, `gh issue develop` | `gh issue develop` manages linked branches for an issue and supports `--checkout`, `--list`, `--name`, `--base`, and `--branch-repo`. | Official CLI docs, opened 2026-06-07. |
| Common Git branch naming practice | Use type prefixes, issue/ticket numbers when applicable, lowercase slugs, and descriptive hyphenated branch names. | Synthesized from common Git workflow conventions; repository-local convention wins. |

## Issue Writing Default

Use this shape when the repository has no issue template or the user did not request a specific template:

```markdown
## Summary

One or two sentences describing the problem or desired outcome.

## Context

Relevant user-facing symptoms, constraints, links, files, or why the work matters.

## Acceptance Criteria

- [ ] Observable condition that proves the issue is handled.
- [ ] Important edge case or regression condition.

## Notes

Implementation hints, suspected files, or open questions.
```

Keep issue titles:

- outcome-oriented
- short enough to scan in an issue list
- free of branch prefixes, commit prefixes, and internal process words

Examples:

- `Fix OAuth callback timeout after provider redirect`
- `Add branch-bound GitHub issue workflow skill`
- `Document local skill installation scope`

## Branch Naming Default

Default pattern:

```text
type/<issue-number>-<short-slug>
```

Recommended types:

- `feat`: new user-facing capability
- `fix`: bug fix, regression, broken behavior
- `docs`: documentation-only change
- `chore`: maintenance, dependency, config, non-product cleanup
- `refactor`: internal structure change without intended behavior change
- `test`: tests, fixtures, QA infrastructure

Slug rules:

- lowercase ASCII
- words separated by hyphens
- no spaces
- no trailing punctuation
- include the issue number
- include a descriptive subject after the issue number

Examples:

- `fix/42-oauth-callback-timeout`
- `feat/87-github-issue-skill`
- `docs/101-local-skill-install-scope`

## Existing Issue Branch Reuse

If GitHub already reports a branch linked to the issue, reuse that branch exactly. Do not rename it just to match this convention.

If multiple linked branches exist:

1. Prefer the open branch in the current repository.
2. Prefer the branch whose name includes the issue number.
3. Prefer the branch whose slug best matches the issue title.
4. If still ambiguous, ask one concise question before checkout because branch choice materially changes the workspace.

## Caveats

- GitHub's issue-connected branch feature is marked public preview in the opened docs. Prefer `gh issue develop` when available, and report limitations when the command or permissions fail.
- Repository-local branch naming, issue templates, labels, and protected branch rules override these defaults.
- This skill should not push, open PRs, or close issues unless another explicit user request asks for that operation.
