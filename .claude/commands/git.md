---
description: Git 상태 확인 및 커밋 작업
allowed-tools: Bash(git:*)
argument-hint: [push|pull|커밋 지시사항...]
---

Git 상태 확인 후 아래 규칙에 따라 작업 진행.

**지시사항**: $ARGUMENTS

## 실행 흐름

```
$ARGUMENTS 있음 → 해당 지시 우선 수행
$ARGUMENTS 없음 → 기본 동작:
  1. git status (현재 상태)
  2. git diff (변경 내용 분석)
  3. 논리적 단위로 분리하여 git add + git commit
  4. git status (완료 확인)
```

## CRITICAL: 절대 금지

| 금지 항목 |
|----------|
| "Generated with Claude Code" 포함 |
| "🤖" 또는 AI 관련 이모지 |
| "Co-Authored-By:" 헤더 |
| AI/봇 작성 표시 일체 |
| 여러 줄 커밋 메시지 |
| 커밋 메시지에 마침표(.) |
| 여러 작업 하나로 퉁치기 |

## 커밋 규칙

**형식**: `<prefix>: <설명>` (한 줄, 본문/푸터 없음)

**핵심 원칙**: 하나의 커밋 = 하나의 논리적 변경

### Prefix

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

### 분리 기준

| 분리 필요 | 묶어도 됨 |
|----------|----------|
| 서로 다른 기능 | 동일 기능의 관련 파일들 |
| 버그 수정 + 새 기능 | 동일 기능의 타입 + 구현 |
| 코드 변경 + 문서 변경 | |
| 리팩토링 + 기능 추가 | |

## 예시

```bash
# ✅ 올바른
feat: 사용자 로그인 기능 추가
fix: 세션 만료 오류 수정
refactor: 서비스 클래스 구조 개선

# ❌ 잘못된
사용자 인증 기능 추가함     # prefix 없음
feat: 사용자 인증 추가.     # 마침표
FEAT: 사용자 인증 추가      # 대문자
feat(auth): 인증 추가       # scope 불필요
feat: 로그인, 회원가입, 프로필  # 여러 작업 퉁침
```
