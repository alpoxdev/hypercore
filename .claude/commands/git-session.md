---
description: 현재 세션에서 수정한 파일만 커밋 후 푸시
allowed-tools: Bash
---

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

---

<selection_criteria>

| 포함 | 제외 |
|------|------|
| 현재 세션 관련 파일 | 이전 세션의 미완성 작업 |
| 방금 전 작업한 파일 | 자동 생성된 파일 (lock, cache) |
| 관련 기능의 파일들 | 무관한 변경사항 |

</selection_criteria>

<forbidden>

| 금지 항목 |
|----------|
| "Generated with Claude Code" 포함 |
| "🤖" 또는 AI 관련 이모지 |
| "Co-Authored-By:" 헤더 |
| AI/봇 작성 표시 일체 |
| 여러 줄 커밋 메시지 |
| 커밋 메시지에 마침표(.) |
| 여러 작업 하나로 퉁치기 |

</forbidden>

<commit_format>

**형식**: `<prefix>: <설명>` (한 줄, 본문/푸터 없음)

**핵심 원칙**: 하나의 커밋 = 하나의 논리적 변경

| Prefix | 용도 |
|--------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 리팩토링 |
| style | 코드 스타일 |
| docs | 문서 수정 |
| test | 테스트 |
| chore | 빌드/설정 |
| perf | 성능 개선 |
| ci | CI/CD |

</commit_format>

<commit_principles>

| 분리 필요 | 묶어도 됨 |
|----------|----------|
| 서로 다른 기능 | 동일 기능의 관련 파일들 |
| 버그 수정 + 새 기능 | 동일 기능의 타입 + 구현 |
| 코드 + 문서 | |

</commit_principles>

<examples>

```bash
# 상황: 로그인 기능 작업 중, 이전에 프로필 기능도 미완성

git status
# modified: src/auth/login.ts (현재 세션)
# modified: src/auth/logout.ts (현재 세션)
# modified: src/profile/edit.ts (이전 세션)

# ✅ 올바른 - 로그인 관련만 커밋
git add src/auth/login.ts src/auth/logout.ts
git commit -m "feat: 로그인/로그아웃 기능 추가"
git push

# ❌ 잘못된
git add .
git commit -m "feat: 인증 및 프로필 기능"  # 여러 작업 퉁침

사용자 인증 기능 추가함     # prefix 없음
feat: 사용자 인증 추가.     # 마침표
FEAT: 사용자 인증 추가      # 대문자
feat(auth): 인증 추가       # scope 불필요
```

</examples>
