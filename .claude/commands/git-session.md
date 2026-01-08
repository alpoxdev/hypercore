---
description: 현재 세션에서 수정한 파일만 커밋 후 푸시
allowed-tools: Bash
---

@../instructions/git-rules.md

# Git Session Command

현재 세션에서 수정한 파일만 선택적으로 커밋 후 푸시.

<workflow>

1. **초기 분석** (병렬 실행 필수)
   ```bash
   git status
   git diff
   ```

2. **현재 세션 관련 파일만 선택**
   - 방금 전 작업한 파일
   - 관련 기능의 파일들
   - 의도적으로 수정한 파일

3. **논리적 단위로 커밋**

4. **완료 확인**
   ```bash
   git status
   ```

5. **푸시**
   ```bash
   git push
   ```

</workflow>

<selection_criteria>

| 포함 | 제외 |
|------|------|
| 현재 세션 관련 파일 | 이전 세션의 미완성 작업 |
| 방금 전 작업한 파일 | 자동 생성된 파일 (lock, cache) |
| 관련 기능의 파일들 | 무관한 변경사항 |

</selection_criteria>

<example>

```bash
# 상황: 로그인 기능 작업 중, 이전에 프로필 기능도 미완성

git status
# modified: src/auth/login.ts (현재 세션)
# modified: src/auth/logout.ts (현재 세션)
# modified: src/profile/edit.ts (이전 세션)

→ 로그인 관련만 커밋
git add src/auth/login.ts src/auth/logout.ts
git commit -m "feat: 로그인/로그아웃 기능 추가"
git push
```

</example>

<references>

커밋 형식은 @git-rules.md 참조

</references>
