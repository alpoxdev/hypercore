---
description: Git 상태 확인 및 커밋 작업
allowed-tools: Bash
argument-hint: [push|pull|커밋 지시사항...]
---

@../instructions/git-rules.md

# Git Command

Git 상태 확인 후 논리적 단위로 커밋.

**지시사항**: $ARGUMENTS

<workflow>

**ARGUMENT 있음** → 해당 지시 우선 수행

**ARGUMENT 없음** → 기본 동작:

1. **초기 분석** (병렬 실행 필수)
   ```bash
   git status
   git diff
   ```

2. **논리적 단위로 분리하여 커밋**
   - 하나의 커밋 = 하나의 논리적 변경

3. **완료 확인**
   ```bash
   git status  # clean working directory 확인
   ```

</workflow>

<commit_principles>

| 분리 필요 | 묶어도 됨 |
|----------|----------|
| 서로 다른 기능 | 동일 기능의 관련 파일들 |
| 버그 수정 + 새 기능 | 동일 기능의 타입 + 구현 |
| 코드 변경 + 문서 변경 | |
| 리팩토링 + 기능 추가 | |

</commit_principles>

<examples>

```bash
# ✅ 올바른
git add src/auth/login.ts
git commit -m "feat: 로그인 기능 추가"

git add src/auth/logout.ts
git commit -m "feat: 로그아웃 기능 추가"

# ❌ 잘못된
git add src/auth/*.ts
git commit -m "feat: 인증 기능 추가"  # 여러 기능 퉁침
```

</examples>

<references>

커밋 형식과 prefix는 @git-rules.md 참조

</references>
