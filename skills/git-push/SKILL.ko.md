---
name: git-push
description: '원격에 아직 올라가지 않은 커밋을 푸시합니다. 현재 저장소 또는 하위 저장소를 찾고, upstream보다 앞선 커밋이 있는지 확인한 뒤 안전하게 push합니다. 사용자가 push, 원격 동기화, 커밋 업로드를 원할 때 사용합니다.'
license: MIT
allowed-tools: Bash
compatibility: Bash와 `skills/git-push/scripts` 아래 스크립트가 필요합니다.
---

# Git Push 스킬

<scripts>

## 사용 가능한 스크립트

| Script | Purpose |
|------|------|
| `scripts/git-push.sh [--force]` | 저장소를 찾고, 미푸시 커밋을 확인한 뒤, 안전하게 푸시 |

</scripts>

<objective>

- 발견된 모든 저장소의 미푸시 커밋을 원격에 푸시한다.
- 푸시할 커밋이 없으면 아무것도 하지 않고 종료한다.
- 위험한 작업(메인 브랜치 강제 푸시, detached HEAD)을 막는다.

</objective>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "push" | yes |
| "git push" | yes |
| "/git-push" | yes |
| "push my changes" | yes |
| "push commits to remote" | yes |
| "sync to remote" | yes |
| 커밋/rebase/reset만 요청 | no |
| "push back on this idea" 같은 비-git 문맥 | no |

</trigger_conditions>

<argument_validation>

ARGUMENT가 없으면:

- 발견된 모든 저장소에서 미푸시 커밋을 푸시한다.

ARGUMENT가 `--force`이면:

- 푸시는 `--force-with-lease`로 수행한다.
- 보호 브랜치(`main`, `master`)는 여전히 차단한다.

</argument_validation>

<scope_assumptions>

- 현재 작업 디렉터리에서 시작한다. 현재 위치가 git 저장소가 아니면 하위 디렉터리에서 git 저장소를 찾는다.
- push만 수행한다. commit, amend, rebase, history rewrite는 하지 않는다.
- 푸시할 커밋이 있으면 확인 없이 즉시 푸시한다.
- Bash 명령만 사용한다.

</scope_assumptions>

<required>

| Category | Rule |
|------|------|
| Safety | main/master에는 force push 하지 않는다. |
| Safety | detached HEAD에서는 push 하지 않는다. |
| Safety | force push 시 `--force` 대신 `--force-with-lease`를 사용한다. |
| Upstream | upstream이 없으면 `-u origin <branch>`로 tracking을 설정한다. |
| Idempotent | 이미 최신이면 깔끔하게 보고하고 종료한다. |
| Multi-repo | 하위 저장소들을 각각 독립적으로 처리한다. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Force push | main/master에 `--force` |
| History rewrite | amend, rebase, reset 등 history 수정 |
| Commit | 커밋 생성 금지 — 이건 git-commit 스킬의 역할 |
| Raw force | `git push --force` 금지 — 항상 `--force-with-lease` |

</forbidden>

<workflow>

## 스크립트 실행

```bash
scripts/git-push.sh
```

force 옵션이 필요하면:

```bash
scripts/git-push.sh --force
```

스크립트가 알아서 다음을 처리한다:

1. 저장소를 찾는다. (현재 디렉터리 또는 하위 디렉터리)
2. 각 저장소의 브랜치와 upstream 상태를 확인한다.
3. 미푸시 커밋이 없거나, detached HEAD이거나, 보호 브랜치 충돌이 있으면 건너뛴다.
4. upstream보다 앞선 커밋이 있는 저장소를 푸시한다.
5. 푸시됨 / 건너뜀 / 실패 저장소 요약을 출력한다.

</workflow>

<examples>

## 기본 푸시

```text
/git-push
```

결과: 저장소를 찾고, 미푸시 커밋이 있는 저장소만 푸시한다.

## Force push (기능 브랜치)

```text
/git-push --force
```

결과: `--force-with-lease`로 푸시한다. main/master에서는 차단된다.

## 푸시할 것이 없음

```text
/git-push
```

결과: "Already up to date"를 보고하고 정상 종료한다.

## 다중 저장소 푸시

```text
/git-push
```

결과: 하위 저장소를 각각 독립적으로 푸시하고 요약을 보고한다.

</examples>

<validation>

- 수동 git 명령이 아니라 스크립트를 실행했는지 확인한다.
- main/master에 force push 하지 않았는지 확인한다.
- detached HEAD는 건너뛰었는지 확인한다.
- 사용자에게 최종 요약을 전달했는지 확인한다.

</validation>
