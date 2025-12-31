---
description: 계획 실행 또는 간단한 작업 수행. ultrathink + sequential thinking 2-5 + TodoWrite 필수.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task, TodoWrite, mcp__sequential-thinking__sequentialthinking
argument-hint: <실행할 작업 또는 계획 파일명>
---

# Execute Command

계획 문서를 기반으로 실행하거나, 간단한 작업을 바로 수행하는 커맨드.

## CRITICAL: 필수 요구사항

| 요구사항 | 설명 |
|----------|------|
| **ARGUMENT 필수** | 작업 내용 없이 실행 시 되물음 |
| **Ultrathink** | 깊은 사고로 작업 분석 |
| **Sequential Thinking 2-5** | 복잡도에 따라 조정 |
| **TodoWrite** | 진행 상황 추적 필수 |

## ARGUMENT 확인

```
$ARGUMENTS 없음 → 즉시 질문:
"무엇을 실행할까요?
- 계획 파일명 (예: session-auth)
- 또는 구체적인 작업 설명"

$ARGUMENTS 있음 → 실행 모드 판별
```

**실행 대상**: $ARGUMENTS

## 실행 모드 판별

```
ARGUMENT 분석:
├─ .claude/plans/*.md 존재? → 계획 기반 실행
├─ 구체적 작업 설명? → 직접 실행
└─ 모호함? → 되물음
```

**모드 판별 예시:**

| ARGUMENT | 모드 |
|----------|------|
| `session-auth` | 계획 기반 (.claude/plans/session-auth.md) |
| `버튼 색상을 파란색으로 변경` | 직접 실행 |
| `인증 개선` | 되물음 (계획? 직접?) |

## 계획 기반 실행

### 실행 흐름

```
1. .claude/plans/$ARGUMENTS.md 읽기
2. Sequential Thinking으로 단계 파악
3. TodoWrite로 체크리스트 생성
4. 단계별 실행:
   a. 현재 단계 in_progress 표시
   b. 코드 수정
   c. 테스트 실행 (있다면)
   d. 완료 표시
5. 전체 완료 후 git commit
```

### 계획 문서 읽기

```
파일 위치: .claude/plans/[기능명].md

읽을 내용:
- 선택된 접근 방식
- 구현 단계 및 체크리스트
- 변경 파일 목록
- 고려사항/리스크
```

### TodoWrite 연동

```
계획의 체크리스트 → TodoWrite로 변환:

계획 문서:
### 1단계: 컴포넌트 생성
- [ ] Button 컴포넌트 생성
- [ ] 스타일 적용

→ TodoWrite:
- "Button 컴포넌트 생성" (pending)
- "스타일 적용" (pending)
```

## 직접 실행

### 실행 흐름

```
1. ARGUMENT 확인 (작업 설명)
2. Sequential Thinking으로 분석 (2-5단계)
3. 필요시 Task로 코드 탐색
4. TodoWrite로 작업 목록 생성
5. 코드 수정
6. 테스트 실행 (있다면)
7. git commit
```

### 복잡도 판단

| 복잡도 | 사고 횟수 | 예시 | 권장 |
|--------|----------|------|------|
| 간단 | 2 | 오타 수정, 색상 변경 | 직접 실행 |
| 보통 | 3-4 | 함수 추가, 컴포넌트 수정 | 직접 실행 |
| 복잡 | 5 | 다중 파일 변경 | 직접 실행 |
| 매우 복잡 | - | 아키텍처 변경 | /plan 먼저 |

**복잡도가 높으면:**

```
"이 작업은 복잡해 보입니다.
/plan 커맨드로 먼저 계획을 세우시겠습니까? (Y/N)"

Y → /plan 안내
N → Sequential Thinking 5단계로 진행
```

## Sequential Thinking 가이드

**간단 (2단계):**

```
thought 1: 작업 내용 파악 및 대상 파일 확인
thought 2: 수정 방안 및 영향 확인
```

**보통 (3-4단계):**

```
thought 1: 작업 분석 및 범위 파악
thought 2: 관련 코드 구조 이해
thought 3: 수정 계획 수립
thought 4: 테스트 방안 (필요시)
```

**복잡 (5단계):**

```
thought 1: 작업 분석 및 복잡도 판단
thought 2: 코드베이스 탐색 전략
thought 3: 의존성 및 영향 범위 파악
thought 4: 단계별 수정 계획
thought 5: 검증 및 롤백 계획
```

## Task Subagent 활용

| subagent_type | 용도 |
|---------------|------|
| `Explore` | 관련 파일 탐색, 패턴 파악 |
| `general-purpose` | 복잡한 로직 분석 |

**Task 호출 시점:**

```
- 수정 대상 파일 불명확
- 영향 범위 파악 필요
- 기존 패턴 확인 필요
```

## 진행 상황 추적

**TodoWrite 필수 사용:**

```
작업 시작 시:
1. 전체 작업 목록 TodoWrite로 생성
2. 현재 작업 in_progress
3. 완료 시 즉시 completed 표시
4. 다음 작업으로 이동
```

**예시:**

```
TodoWrite:
- [completed] 파일 구조 분석
- [in_progress] Button 컴포넌트 수정
- [pending] 테스트 실행
- [pending] git commit
```

## Git 커밋 규칙

**수정 완료 후 커밋:**

```bash
# 수정한 파일만 add
git add <수정된 파일>

# 커밋 (한 줄, prefix 필수, 마침표 없음)
git commit -m "<prefix>: <설명>"
```

**Prefix:**

| Prefix | 용도 |
|--------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 리팩토링 |
| style | UI/스타일 변경 |
| perf | 성능 개선 |
| test | 테스트 추가 |
| docs | 문서 수정 |
| chore | 설정/빌드 |

## 예시 워크플로우

### 계획 기반 실행

```
1. 사용자: /execute session-auth

2. .claude/plans/session-auth.md 읽기

3. TodoWrite 생성:
   - 세션 스토어 설정 (pending)
   - 미들웨어 구현 (pending)
   - API 엔드포인트 수정 (pending)
   - 테스트 작성 (pending)

4. 단계별 실행 및 완료 표시

5. git commit -m "feat: 세션 기반 인증 구현"
```

### 직접 실행

```
1. 사용자: /execute 로그인 버튼 색상을 파란색으로 변경

2. Sequential Thinking (2단계):
   thought 1: "로그인 버튼 → LoginButton 컴포넌트 찾기"
   thought 2: "색상 변경 위치 확인, CSS/Tailwind 스타일"

3. TodoWrite:
   - LoginButton 컴포넌트 수정 (in_progress)
   - 변경 확인 (pending)

4. Edit으로 수정

5. git commit -m "style: 로그인 버튼 색상 파란색으로 변경"
```

## 테스트 실행

**코드 수정 후 테스트:**

```
테스트 파일 존재 시:
1. 관련 테스트 실행
2. 실패 시 수정
3. 전체 테스트 통과 확인

테스트 파일 없을 시:
- 수동 확인 안내
- 또는 테스트 작성 제안
```

## CRITICAL: 절대 금지

| 금지 항목 |
|----------|
| ARGUMENT 없이 실행 시작 |
| TodoWrite 없이 작업 진행 |
| Sequential Thinking 없이 수정 |
| 테스트 실패 상태로 커밋 |
| "Generated with Claude Code" 포함 |
| "Co-Authored-By:" 헤더 |
| 여러 줄 커밋 메시지 |
| 커밋 메시지에 마침표(.) |
| 매우 복잡한 작업을 /plan 없이 진행 |
