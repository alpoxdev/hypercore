---
description: Git 상태 확인 및 커밋 작업
argument-hint: [push|pull|커밋 지시사항...]
---

# Git Command

@git-operator 에이전트를 사용하여 Git 작업 수행.

<mode>

**기본 모드**: 선택적 커밋

- 일부 변경사항만 커밋 가능
- 푸시는 선택적 (명시 시에만)

</mode>

---

<arguments>

**$ARGUMENTS 있음**: 해당 지시사항 우선 수행

| 예시 | 동작 |
|------|------|
| `push` | 커밋 후 푸시 |
| `pull` | git pull 먼저 실행 |
| `로그인 기능만` | 해당 파일만 커밋 |

**$ARGUMENTS 없음**: 기본 동작

1. git status, git diff 분석
2. 논리적 단위로 그룹핑
3. 선택적 커밋

</arguments>
