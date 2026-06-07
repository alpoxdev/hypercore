# Issue And Branch Workflow

`gh issue`, `gh issue develop`, `git switch`, `git checkout`을 실행하기 전에 이 rule file을 사용합니다.

## Preconditions

- 현재 repository 안에서만 작업합니다.
- `git rev-parse --show-toplevel`이 0으로 종료되는지 확인합니다.
- target repository를 소유한 host에 대해 `gh auth status`가 0으로 종료되는지 확인합니다.
- 사용자가 explicit repository를 준 경우가 아니면 `gh repo view --json nameWithOwner,url`로 target repository를 확인합니다.
- checkout 전에 `git status --short --branch`를 확인합니다. working tree에 관련 없는 uncommitted changes가 있으면 destructive checkout behavior를 피하고, Git이 변경사항을 보존할 수 있을 때만 `git switch`를 사용합니다.

## Existing Issue

사용자가 issue number 또는 URL을 제공한 경우:

1. issue reference를 `gh`에 맞게 normalize합니다.
2. 실행합니다.

```bash
gh issue view "$issue" --json number,title,state,url
```

3. 실행합니다.

```bash
gh issue develop --list "$issue"
```

4. linked branch가 있으면 fetch 후 그 branch를 checkout합니다. 재생성한 이름보다 `gh` 출력의 exact branch name을 우선합니다.
5. linked branch가 없으면 `type/<number>-<slug>`를 만들고 실행합니다.

```bash
gh issue develop "$number" --checkout --name "$branch"
```

6. 다음으로 검증합니다.

```bash
git branch --show-current
git status --short --branch
```

issue를 해석할 수 없거나, checkout이 변경사항을 덮어쓸 수 있거나, credential/permission이 없을 때가 아니면 이 path에서는 확인 질문을 하지 않습니다.

## New Issue

사용자가 기존 issue 대신 topic/task를 제공한 경우:

1. concise title을 draft합니다.
2. 정보가 있으면 다음 section으로 body를 draft합니다.

```markdown
## Summary

## Context

## Acceptance Criteria

## Notes
```

3. issue를 생성합니다.

```bash
gh issue create --title "$title" --body "$body"
```

4. issue number를 추출하거나 확인합니다.

```bash
gh issue view "$issue_url_or_number" --json number,title,url
```

5. 생성된 issue number와 title에서 branch name을 만듭니다.
6. linked branch를 만들고 checkout합니다.

```bash
gh issue develop "$number" --checkout --name "$branch"
```

7. active branch를 검증합니다.

## Branch Type Selection

| Intent signal | Branch type |
|---|---|
| bug, broken, error, regression, failure 및 한국어 대응 표현 | `fix` |
| 새 user-visible behavior, enhancement, feature | `feat` |
| docs, README, comments-only docs | `docs` |
| dependency, config, cleanup, maintenance | `chore` |
| 의도한 behavior change 없는 structure change | `refactor` |
| tests, QA, fixtures | `test` |

확실하지 않으면 maintenance work는 `chore`, user-facing capability work는 `feat`를 선택합니다.

## Branch Name Rules

- 기본 format: `type/<issue-number>-<slug>`.
- lowercase ASCII, digit, hyphen, type 뒤 slash 하나만 사용합니다.
- issue title 또는 사용자가 제공한 task summary에서 slug를 만듭니다.
- punctuation을 제거하고 whitespace를 hyphen으로 합치며, repeated hyphen을 정리하고 slug를 scan 가능한 길이로 유지합니다.
- 숫자만 있거나 issue ID만 있거나 generic word만 있는 branch name은 피합니다.

Examples:

- `fix/42-oauth-callback-timeout`
- `feat/87-github-issue-branch-skill`
- `docs/101-update-install-guide`
- `chore/118-refresh-ci-cache`

## Fallbacks

- `gh issue develop`을 사용할 수 없으면 먼저 `gh issue develop --help`로 local `gh` version 지원 여부를 확인합니다.
- command가 없지만 issue creation은 성공했다면, 선택한 base에서 `git switch -c "$branch"`로 local branch를 만들고 GitHub linked-branch 상태를 확인하지 못했다고 보고합니다.
- local changes 때문에 checkout이 실패하면 stash 또는 discard하지 말고 정확한 blocking file을 보고하고 멈춥니다.
- authentication 또는 permission이 실패하면 GitHub-linked branch가 존재하는 것처럼 보이는 local state를 만들기 전에 멈춥니다.
