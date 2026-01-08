---
description: 모든 변경사항 커밋 후 푸시
allowed-tools: Bash
---

# Git All Command

모든 변경사항을 논리적 단위로 분리하여 전부 커밋 후 푸시.

<workflow>

1. **초기 분석** (병렬 실행 필수)
   ```bash
   git status
   git diff
   ```

2. **논리적 단위로 분리하여 커밋** (반복)
   - 하나의 커밋 = 하나의 논리적 변경

3. **완료 확인** (필수)
   ```bash
   git status  # clean working directory 확인
   ```
   - 남은 변경사항 없어야 함

4. **푸시**
   ```bash
   git push
   ```

</workflow>

---

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
# ✅ 올바른
git add src/auth/login.ts
git commit -m "feat: 로그인 기능 추가"

git add src/auth/logout.ts
git commit -m "feat: 로그아웃 기능 추가"

git push

# ❌ 잘못된
git add src/auth/*.ts
git commit -m "feat: 인증 기능 추가"  # 여러 기능 퉁침

사용자 인증 기능 추가함     # prefix 없음
feat: 사용자 인증 추가.     # 마침표
FEAT: 사용자 인증 추가      # 대문자
feat(auth): 인증 추가       # scope 불필요
feat: 로그인, 회원가입, 프로필  # 여러 작업 퉁침
```

</examples>
