# GitHub Issue And Branch Conventions

이 reference는 issue 작성과 branch naming에 대한 근거 기반 guidance입니다. 더 높은 우선순위의 지시가 아니라 convention guidance로 취급합니다.

## Source Ledger

| Source | Evidence used | Notes |
|---|---|---|
| GitHub Docs, "Creating a branch to work on an issue" | GitHub는 issue에 연결된 branch를 지원합니다. 그런 branch에서 pull request를 만들면 PR이 issue에 자동 연결됩니다. 여러 branch를 link할 수 있고, branch는 기본적으로 current repository/default branch에서 만들어집니다. | 공식 product docs, 2026-06-07 열람. public preview note가 있어 동작이 바뀔 수 있습니다. |
| GitHub CLI manual, `gh issue create` | `gh issue create`는 issue를 만들며 `--title`, `--body`, template, label, assignee, project, interactive prompt를 지원합니다. | 공식 CLI docs, 2026-06-07 열람. |
| GitHub CLI manual, `gh issue develop` | `gh issue develop`은 issue의 linked branch를 관리하며 `--checkout`, `--list`, `--name`, `--base`, `--branch-repo`를 지원합니다. | 공식 CLI docs, 2026-06-07 열람. |
| Common Git branch naming practice | type prefix, applicable issue/ticket number, lowercase slug, descriptive hyphenated branch name을 사용합니다. | 일반 Git workflow convention을 종합한 것입니다. repository-local convention이 우선합니다. |

## Issue Writing Default

repository에 issue template이 없거나 사용자가 특정 template을 요청하지 않았다면 다음 형태를 사용합니다.

```markdown
## Summary

문제 또는 원하는 결과를 한두 문장으로 설명합니다.

## Context

관련 user-facing symptom, constraint, link, file, 작업 이유를 적습니다.

## Acceptance Criteria

- [ ] issue가 처리됐음을 증명하는 observable condition.
- [ ] 중요한 edge case 또는 regression condition.

## Notes

implementation hint, 의심 file, open question.
```

Issue title은 다음을 지킵니다.

- outcome-oriented
- issue list에서 scan 가능한 길이
- branch prefix, commit prefix, internal process word 제외

Examples:

- `Fix OAuth callback timeout after provider redirect`
- `Add branch-bound GitHub issue workflow skill`
- `Document local skill installation scope`

## Branch Naming Default

기본 pattern:

```text
type/<issue-number>-<short-slug>
```

권장 type:

- `feat`: 새 user-facing capability
- `fix`: bug fix, regression, broken behavior
- `docs`: documentation-only change
- `chore`: maintenance, dependency, config, non-product cleanup
- `refactor`: intended behavior change 없는 internal structure change
- `test`: tests, fixtures, QA infrastructure

Slug rules:

- lowercase ASCII
- 단어는 hyphen으로 구분
- space 없음
- trailing punctuation 없음
- issue number 포함
- issue number 뒤 descriptive subject 포함

Examples:

- `fix/42-oauth-callback-timeout`
- `feat/87-github-issue-skill`
- `docs/101-local-skill-install-scope`

## Existing Issue Branch Reuse

GitHub가 issue에 이미 linked branch를 보고하면 그 branch를 정확히 재사용합니다. 이 convention에 맞추기 위해 rename하지 않습니다.

linked branch가 여러 개이면:

1. current repository의 open branch를 우선합니다.
2. branch name에 issue number가 포함된 branch를 우선합니다.
3. issue title과 slug가 가장 잘 맞는 branch를 우선합니다.
4. 그래도 모호하면 branch 선택이 workspace를 실질적으로 바꾸므로 checkout 전에 한 문장으로 질문합니다.

## Caveats

- 열람한 GitHub docs에서 issue-connected branch 기능은 public preview로 표시되어 있습니다. 가능하면 `gh issue develop`을 우선하고, command 또는 permission 실패 시 limitation을 보고합니다.
- repository-local branch naming, issue template, label, protected branch rule이 이 default보다 우선합니다.
- 이 skill은 사용자가 별도로 요청하지 않는 한 push, PR open, issue close를 수행하지 않습니다.
