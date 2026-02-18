---
description: 현재 세션에서 수정한 파일만 커밋 후 푸시
---

# Git Session Command

> 현재 세션 파일만 선택적으로 커밋하고 푸시.

---

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|----------|------|
| `${CLAUDE_SCRIPTS_ROOT}/git/git-info.sh` | 상태 + diff 요약 출력 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "msg" [files]` | Co-Authored-By 포함 커밋 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-push.sh` | 안전한 푸시 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-clean-check.sh` | clean 여부 확인 |

</scripts>

---

<workflow>

## 워크플로우

```bash
# 1. 상태 확인
${CLAUDE_SCRIPTS_ROOT}/git/git-info.sh

# 2. 현재 세션 파일만 선택하여 커밋
${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "feat: 로그인 기능" src/auth/login.ts src/auth/logout.ts

# 3. 푸시
${CLAUDE_SCRIPTS_ROOT}/git/git-push.sh
```

</workflow>

---

<mode>

**세션 커밋 모드**

- **현재 세션 관련 파일만** 선택적 커밋
- **반드시 푸시** (git push)

</mode>

---

<selection_criteria>

| 포함 | 제외 |
|------|------|
| 현재 세션 관련 파일 | 이전 세션의 미완성 작업 |
| 방금 전 작업한 파일 | 자동 생성 파일 (lock, cache) |
| 관련 기능의 파일들 | 무관한 변경사항 |

</selection_criteria>

---

<example>

```bash
# 상황: 로그인 기능 작업 중, 이전 프로필 기능은 미완성

${CLAUDE_SCRIPTS_ROOT}/git/git-info.sh
# modified: src/auth/login.ts (현재 세션)
# modified: src/auth/logout.ts (현재 세션)
# modified: src/profile/edit.ts (이전 세션)

# ✅ 로그인 관련만 커밋
${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "feat: 로그인/로그아웃 기능 추가" src/auth/login.ts src/auth/logout.ts
${CLAUDE_SCRIPTS_ROOT}/git/git-push.sh
```

</example>

