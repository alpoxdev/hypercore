# Git 워크플로우

> NPX CLI 프로젝트 Git 컨벤션

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
git add src/commands/init.ts src/utils/copy.ts
git commit -m "feat: 템플릿 복사 기능 추가"

git add src/commands/list.ts
git commit -m "feat: 템플릿 목록 조회 기능 추가"

git add docs/
git commit -m "docs: CLI 사용법 문서 추가"
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
| `feat` | 새로운 기능 | `feat: 템플릿 복사 기능 추가` |
| `fix` | 버그 수정 | `fix: 경로 처리 오류 수정` |
| `refactor` | 리팩토링 | `refactor: copy 유틸 분리` |
| `style` | 코드 스타일 | `style: prettier 적용` |
| `docs` | 문서 수정 | `docs: README 업데이트` |
| `test` | 테스트 | `test: copy 유틸 테스트 추가` |
| `chore` | 빌드/설정 | `chore: 버전 업데이트` |
| `perf` | 성능 개선 | `perf: 파일 복사 최적화` |
| `ci` | CI/CD | `ci: GitHub Actions 추가` |

---

## ✅ 올바른 예시

```bash
feat: CLI 옵션 추가
fix: 템플릿 경로 오류 수정
docs: 사용법 문서 추가
refactor: logger 유틸 분리
chore: 의존성 업데이트
```

---

## ❌ 잘못된 예시

```bash
# prefix 없음
템플릿 기능 추가함

# 마침표 불필요
feat: 새 기능 추가.

# 대문자 사용
FEAT: 새 기능 추가

# scope 불필요
feat(cli): 옵션 추가

# AI 작성 표시 (절대 금지!)
feat: 기능 추가

🤖 Generated with Claude Code

# Co-Author 표시 (절대 금지!)
feat: 기능 추가

Co-Authored-By: Claude <noreply@anthropic.com>

# 여러 줄 본문 (금지)
feat: 새 기능 추가

- 옵션 A 추가
- 옵션 B 추가

# 여러 작업을 하나로 퉁침 (금지)
feat: init, list, copy 명령어 추가
```

---

## 🔄 작업 흐름

```bash
# 1. 작업 전 최신 코드 동기화
git pull origin main

# 2. 명령어 작업 완료 → 커밋
git add src/commands/init.ts src/utils/copy.ts
git commit -m "feat: 템플릿 초기화 명령어 추가"

# 3. 유틸리티 작업 완료 → 커밋
git add src/utils/logger.ts src/utils/spinner.ts
git commit -m "feat: 로깅 및 스피너 유틸 추가"

# 4. 문서 작업 완료 → 커밋
git add docs/
git commit -m "docs: CLI 사용법 문서 추가"

# 5. 푸시
git push origin main
```

---

## 📦 커밋 분리 가이드

### 언제 커밋을 분리해야 하나요?

| 상황 | 커밋 분리 |
|------|----------|
| 서로 다른 CLI 명령어 | ✅ 분리 |
| 버그 수정 + 새 기능 | ✅ 분리 |
| 코드 변경 + 문서 변경 | ✅ 분리 |
| 리팩토링 + 기능 추가 | ✅ 분리 |
| 동일 명령어의 핸들러 + 유틸 | 🔄 묶어도 됨 |
| 동일 기능의 타입 + 구현 | 🔄 묶어도 됨 |

### 예시: CLI 도구 개발

```bash
# 1. init 명령어 커밋
git add src/commands/init.ts src/utils/copy.ts
git commit -m "feat: 템플릿 초기화 명령어 추가"

# 2. list 명령어 커밋
git add src/commands/list.ts
git commit -m "feat: 템플릿 목록 조회 명령어 추가"

# 3. 공통 유틸 커밋
git add src/utils/logger.ts src/utils/spinner.ts
git commit -m "feat: CLI 유틸리티 함수 추가"

# 4. 테스트 커밋
git add tests/
git commit -m "test: CLI 명령어 테스트 추가"

# 5. 문서 커밋
git add docs/ README.md
git commit -m "docs: CLI 사용법 및 README 추가"
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
feature/multi-template
feature/interactive-mode
fix/path-resolution
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

## 🏷 버전 관리

### 버전 업데이트

```bash
# 패치 버전 (0.1.0 → 0.1.1)
npm version patch

# 마이너 버전 (0.1.0 → 0.2.0)
npm version minor

# 메이저 버전 (0.1.0 → 1.0.0)
npm version major
```

### 배포 전 체크리스트

```
□ 버전 업데이트 완료
□ CHANGELOG 작성 완료
□ 테스트 통과 확인
□ 빌드 성공 확인
```

---

## 📚 .gitignore

```gitignore
# Dependencies
node_modules/

# Build
dist/
lib/

# Environment
.env
.env.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store

# Logs
*.log
npm-debug.log*

# Cache
.cache/
```

---

## 🔗 관련 문서

- [CLAUDE.md](../../CLAUDE.md)
