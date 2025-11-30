# Git 워크플로우

> TanStack Start + React 프로젝트 Git 컨벤션

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
```

---

## ✅ ALWAYS (필수)

### 작업 완료 후 반드시 실행

```bash
git add .
git commit -m "<prefix>: <설명>"
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
| `feat` | 새로운 기능 | `feat: 사용자 로그인 기능 추가` |
| `fix` | 버그 수정 | `fix: 세션 만료 오류 수정` |
| `refactor` | 리팩토링 | `refactor: 인증 로직 분리` |
| `style` | 코드 스타일 | `style: eslint 규칙 적용` |
| `docs` | 문서 수정 | `docs: API 문서 업데이트` |
| `test` | 테스트 | `test: 로그인 테스트 추가` |
| `chore` | 빌드/설정 | `chore: vite 설정 업데이트` |
| `perf` | 성능 개선 | `perf: 이미지 로딩 최적화` |
| `ci` | CI/CD | `ci: GitHub Actions 추가` |

---

## ✅ 올바른 예시

```bash
feat: 회원가입 폼 유효성 검사 추가
fix: 비밀번호 재설정 이메일 발송 오류 수정
refactor: UserService 클래스 구조 개선
docs: README 설치 가이드 추가
chore: Prisma 7.x 버전 업그레이드
```

---

## ❌ 잘못된 예시

```bash
# prefix 없음
회원가입 기능 추가함

# 마침표 불필요
feat: 회원가입 기능 추가.

# 대문자 사용
FEAT: 회원가입 기능 추가

# scope 불필요
feat(auth): 회원가입 추가

# AI 작성 표시 (절대 금지!)
feat: 로그인 기능 추가

🤖 Generated with Claude Code

# Co-Author 표시 (절대 금지!)
feat: 로그인 기능 추가

Co-Authored-By: Claude <noreply@anthropic.com>

# 여러 줄 본문 (금지)
feat: 로그인 기능 추가

- 이메일 인증 추가
- 세션 관리 구현
```

---

## 🔄 작업 흐름

```bash
# 1. 작업 전 최신 코드 동기화
git pull origin main

# 2. 코드 작업 진행
# ...

# 3. 변경사항 커밋
git add .
git commit -m "feat: 새 기능 설명"

# 4. 푸시
git push origin main
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
feature/user-authentication
feature/payment-integration
fix/login-session-error
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
```

---

## 📚 .gitignore

```gitignore
# Dependencies
node_modules/

# Build
.output/
dist/
build/

# Environment
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store

# Prisma
prisma/generated/

# Cache
.cache/
.turbo/
```
