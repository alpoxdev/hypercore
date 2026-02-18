---
description: 모든 변경사항 커밋 후 푸시
---

# Git All Command

> 모든 변경사항을 커밋하고 푸시.

---

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|----------|------|
| `${CLAUDE_SCRIPTS_ROOT}/git/git-info.sh` | 상태 + diff 요약 출력 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "msg" [files]` | Co-Authored-By 포함 커밋 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-push.sh` | 안전한 푸시 |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-all.sh "msg"` | add all + commit + push (단순 케이스) |
| `${CLAUDE_SCRIPTS_ROOT}/git/git-clean-check.sh` | clean 여부 확인 |

</scripts>

---

<workflow>

## 워크플로우

### 단순 케이스 (단일 커밋)

```bash
# 1. 상태 확인
${CLAUDE_SCRIPTS_ROOT}/git/git-info.sh

# 2. 모든 변경사항 커밋 + 푸시
${CLAUDE_SCRIPTS_ROOT}/git/git-all.sh "feat: 기능 추가"
```

### 복잡한 케이스 (논리적 분리 필요)

```bash
# 1. 상태 확인
${CLAUDE_SCRIPTS_ROOT}/git/git-info.sh

# 2. 그룹별 커밋
${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "feat: A 기능" src/a.ts src/a.test.ts
${CLAUDE_SCRIPTS_ROOT}/git/git-commit.sh "fix: B 버그 수정" src/b.ts

# 3. clean 확인 후 푸시
${CLAUDE_SCRIPTS_ROOT}/git/git-clean-check.sh
${CLAUDE_SCRIPTS_ROOT}/git/git-push.sh
```

</workflow>

---

<mode>

**전체 커밋 모드**

- **모든 변경사항**을 논리적 단위로 분리하여 **전부 커밋**
- **반드시 푸시** (git push)
- **남은 변경사항 없음** (clean working directory) 확인 필수

</mode>

