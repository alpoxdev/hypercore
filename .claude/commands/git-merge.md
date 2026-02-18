---
description: 타겟 브랜치에 소스 브랜치를 merge 후 push
argument-hint: <target-branch> <source-branch>
---

# Git Merge Command

> 타겟 브랜치에 소스 브랜치를 merge하고 push.

---

<scripts>

## 사용 가능한 스크립트

| 스크립트 | 용도 |
|----------|------|
| `${CLAUDE_SCRIPTS_ROOT}/git/git-merge.sh <target> <source>` | checkout → merge → push → 원래 브랜치 복귀 |

</scripts>

---

<workflow>

## 워크플로우

```bash
# 인자에서 타겟/소스 브랜치 추출 후 실행
${CLAUDE_SCRIPTS_ROOT}/git/git-merge.sh <target-branch> <source-branch>
```

**스크립트 동작:**
1. Working directory clean 확인
2. `git fetch origin`
3. 타겟 브랜치 checkout + pull
4. 소스 브랜치 merge (`--no-edit`)
5. 타겟 브랜치 push
6. 원래 브랜치로 복귀

</workflow>

---

<examples>

```bash
# deploy/prod에 dev 머지
${CLAUDE_SCRIPTS_ROOT}/git/git-merge.sh deploy/prod dev

# main에 feature/auth 머지
${CLAUDE_SCRIPTS_ROOT}/git/git-merge.sh main feature/auth
```

</examples>

---

<error_handling>

| 상황 | 대응 |
|------|------|
| **Working directory dirty** | 커밋 또는 stash 후 재시도 안내 |
| **Merge conflict** | 수동 해결 안내 (타겟 브랜치에 머물러 있음) |
| **브랜치 미존재** | 에러 출력 후 종료 |

</error_handling>
