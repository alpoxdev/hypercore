# Git 커밋 컨벤션

> NPX CLI 프로젝트 Git 워크플로우 및 커밋 메시지 규칙

---

## ⛔ 절대 금지 사항

```
❌ "Generated with Claude Code" 포함 금지
❌ "🤖" 또는 AI 관련 이모지 포함 금지
❌ "Co-Authored-By:" 헤더 포함 금지
❌ AI/봇이 작성했다는 어떤 표시도 금지
❌ 커밋 메시지 여러 줄 작성 금지
❌ 커밋 메시지에 이모지 사용 금지
```

---

## 커밋 메시지 형식

### 기본 형식

```
<prefix>: <설명>
```

- **한 줄만 작성**
- **본문 없음**
- **마침표 없음**
- **이모지 없음**

### Prefix 목록

| Prefix | 용도 | 예시 |
|--------|------|------|
| `feat` | 새 기능 | `feat: 템플릿 복사 기능 추가` |
| `fix` | 버그 수정 | `fix: 경로 처리 오류 수정` |
| `refactor` | 리팩토링 | `refactor: copy 유틸 분리` |
| `style` | 코드 스타일 | `style: prettier 적용` |
| `docs` | 문서 | `docs: README 업데이트` |
| `test` | 테스트 | `test: copy 유틸 테스트 추가` |
| `chore` | 기타 작업 | `chore: 버전 업데이트` |
| `perf` | 성능 개선 | `perf: 파일 복사 최적화` |
| `ci` | CI/CD | `ci: GitHub Actions 추가` |

---

## 좋은 예시 vs 나쁜 예시

### ✅ 좋은 예시

```bash
feat: CLI 옵션 추가
fix: 템플릿 경로 오류 수정
docs: 사용법 문서 추가
refactor: logger 유틸 분리
chore: 의존성 업데이트
```

### ❌ 나쁜 예시

```bash
# 이모지 사용
🚀 feat: 새 기능 추가

# 여러 줄
feat: 새 기능 추가

상세 설명...

# AI 표시
feat: 기능 추가

Generated with Claude Code

# Co-Authored-By 포함
feat: 기능 추가

Co-Authored-By: Claude <noreply@anthropic.com>

# 마침표 사용
feat: 새 기능 추가.

# 모호한 설명
fix: 버그 수정
chore: 업데이트
```

---

## 커밋 명령어

### 기본 커밋

```bash
git add .
git commit -m "feat: 새 기능 설명"
```

### 파일 지정 커밋

```bash
git add src/commands/init.ts src/utils/copy.ts
git commit -m "feat: 템플릿 복사 기능 구현"
```

---

## 브랜치 전략

### 브랜치 네이밍

```
feature/<기능명>
fix/<버그명>
refactor/<대상>
docs/<문서명>
```

### 예시

```bash
git checkout -b feature/multi-template
git checkout -b fix/path-resolution
git checkout -b refactor/copy-utils
git checkout -b docs/readme-update
```

---

## 워크플로우

### 1. 브랜치 생성

```bash
git checkout -b feature/new-feature
```

### 2. 작업 및 커밋

```bash
# 작업 진행
git add .
git commit -m "feat: 새 기능 구현"
```

### 3. 푸시

```bash
git push origin feature/new-feature
```

### 4. PR 생성

```bash
# GitHub에서 PR 생성
# 또는 gh CLI 사용
gh pr create --title "feat: 새 기능 추가" --body "설명"
```

---

## 자주 사용하는 명령어

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

## 커밋 전 체크리스트

```
□ 커밋 메시지가 한 줄인가?
□ 적절한 prefix를 사용했는가?
□ 이모지가 없는가?
□ AI 관련 표시가 없는가?
□ Co-Authored-By가 없는가?
□ 마침표가 없는가?
□ 설명이 명확한가?
```

---

## 관련 문서

- [CLAUDE.md](../../CLAUDE.md)
