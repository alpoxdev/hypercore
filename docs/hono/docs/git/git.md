# Git 워크플로우

> Hono 서버 프레임워크 프로젝트 Git 컨벤션

---

## ⛔ NEVER (절대 금지)

```
❌ 커밋에 "Generated with Claude Code" 포함
❌ 커밋에 "🤖" 또는 AI 관련 이모지 포함
❌ 커밋에 "Co-Authored-By:" 헤더 포함
❌ 커밋에 AI/봇이 작성했다는 어떤 표시도 포함
❌ 커밋 메시지 여러 줄 작성
❌ 커밋 메시지에 이모지 사용
❌ 커밋 메시지에 마침표(.) 사용
❌ 여러 작업을 하나의 커밋으로 퉁치기
```

---

## ✅ ALWAYS (필수)

### 작업 완료 후 반드시 실행

```bash
git add <관련 파일들>
git commit -m "<prefix>: <설명>"
```

### ⭐ 커밋 분리 원칙

**하나의 커밋 = 하나의 논리적 변경 단위**

```bash
# ❌ 잘못된 방식: 모든 작업을 하나로 퉁침
git add .
git commit -m "feat: 여러 기능 추가"

# ✅ 올바른 방식: 논리적 단위로 분리
git add src/routes/auth.ts src/middleware/auth.ts
git commit -m "feat: 사용자 인증 API 추가"

git add src/routes/users.ts src/services/user.ts
git commit -m "feat: 사용자 CRUD API 추가"

git add docs/
git commit -m "docs: API 문서 업데이트"
```

---

## 📝 커밋 형식

```
<prefix>: <설명>
```

**한 줄로 간결하게** 작성합니다. 본문이나 푸터는 작성하지 않습니다.

---

## 🏷 Prefix 목록

| Prefix | 용도 | 예시 |
|--------|------|------|
| `feat` | 새로운 기능 | `feat: 사용자 인증 API 추가` |
| `fix` | 버그 수정 | `fix: JWT 토큰 검증 오류 수정` |
| `refactor` | 리팩토링 | `refactor: 인증 미들웨어 분리` |
| `style` | 코드 스타일 | `style: prettier 적용` |
| `docs` | 문서 수정 | `docs: API 문서 업데이트` |
| `test` | 테스트 | `test: 인증 미들웨어 테스트 추가` |
| `chore` | 빌드/설정 | `chore: wrangler 설정 업데이트` |
| `perf` | 성능 개선 | `perf: 쿼리 최적화` |
| `ci` | CI/CD | `ci: GitHub Actions 추가` |

---

## ✅ 올바른 예시

```bash
feat: 사용자 로그인 API 추가
fix: 세션 만료 오류 수정
refactor: 인증 미들웨어 분리
docs: README 설치 가이드 추가
chore: Prisma 7.x 버전 업그레이드
```

---

## ❌ 잘못된 예시

```bash
# prefix 없음
사용자 인증 기능 추가함

# 마침표 불필요
feat: 사용자 인증 추가.

# 대문자 사용
FEAT: 사용자 인증 추가

# scope 불필요
feat(auth): 인증 추가

# AI 작성 표시 (절대 금지!)
feat: 로그인 기능 추가

🤖 Generated with Claude Code

# Co-Author 표시 (절대 금지!)
feat: 로그인 기능 추가

Co-Authored-By: Claude <noreply@anthropic.com>

# 여러 줄 본문 (금지)
feat: 로그인 기능 추가

- JWT 인증 구현
- 세션 관리 추가

# 여러 작업을 하나로 퉁침 (금지)
feat: 로그인, 회원가입, 사용자 API 추가
```

---

## 🔄 작업 흐름

```bash
# 1. 작업 전 최신 코드 동기화
git pull origin main

# 2. 라우트 작업 완료 → 커밋
git add src/routes/users.ts src/validators/user.ts
git commit -m "feat: 사용자 CRUD API 구현"

# 3. 미들웨어 작업 완료 → 커밋
git add src/middleware/auth.ts src/middleware/logger.ts
git commit -m "feat: 인증 및 로깅 미들웨어 추가"

# 4. 문서 작업 완료 → 커밋
git add docs/
git commit -m "docs: API 엔드포인트 문서 추가"

# 5. 푸시
git push origin main
```

---

## 📦 커밋 분리 가이드

### 언제 커밋을 분리해야 하나요?

| 상황 | 커밋 분리 |
|------|----------|
| 서로 다른 API 엔드포인트 | ✅ 분리 |
| 버그 수정 + 새 기능 | ✅ 분리 |
| 코드 변경 + 문서 변경 | ✅ 분리 |
| 리팩토링 + 기능 추가 | ✅ 분리 |
| 동일 기능의 라우트 + 밸리데이터 | 🔄 묶어도 됨 |
| 동일 기능의 서비스 + 타입 | 🔄 묶어도 됨 |

### 예시: 사용자 관리 API 개발

```bash
# 1. 인증 API 커밋
git add src/routes/auth.ts src/middleware/auth.ts src/validators/auth.ts
git commit -m "feat: 사용자 인증 API 추가"

# 2. 사용자 API 커밋
git add src/routes/users.ts src/services/user.ts src/validators/user.ts
git commit -m "feat: 사용자 CRUD API 추가"

# 3. 에러 핸들링 커밋
git add src/lib/errors.ts src/index.ts
git commit -m "feat: 글로벌 에러 핸들러 추가"

# 4. 테스트 커밋
git add tests/
git commit -m "test: 사용자 API 테스트 추가"

# 5. 문서 커밋
git add docs/
git commit -m "docs: 사용자 API 문서 추가"
```

---

## 🌿 브랜치 전략

### 간단한 프로젝트
```
main ← 모든 작업 직접 커밋
```

### 팀 프로젝트
```
main
  └── feature/기능명
  └── fix/버그명
  └── hotfix/긴급수정
```

### 브랜치 명명
```bash
feature/user-auth-api
feature/payment-webhook
fix/jwt-validation-error
hotfix/security-patch
```

---

## 📋 자주 사용하는 명령어

```bash
# 상태 확인
git status

# 변경 내용 확인
git diff

# 최근 커밋 로그
git log --oneline -10

# 커밋 취소 (작업 내용 유지)
git reset --soft HEAD~1

# 스테이징 취소
git restore --staged .

# 변경사항 임시 저장
git stash
git stash pop

# 특정 파일만 스테이징
git add <파일경로>

# 대화형 스테이징 (부분 커밋용)
git add -p
```

---

## 📚 .gitignore

```gitignore
# Dependencies
node_modules/

# Build
dist/
.output/

# Environment
.env
.env.local
.dev.vars

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store

# Prisma
prisma/generated/

# Wrangler
.wrangler/

# Cache
.cache/
```

---

## 🔗 관련 문서

- [CLAUDE.md](../../CLAUDE.md)
- [아키텍처](../architecture/architecture.md)
