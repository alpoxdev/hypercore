---
description: 개발 진행 방법 검토 및 옵션 제시. ultrathink + sequential thinking 3-7 필수. 코드 수정 없이 계획만.
allowed-tools: Read, Glob, Grep, Bash(git:*, ast-grep:*), Task, Write, mcp__sequential-thinking__sequentialthinking
argument-hint: <개발할 기능 또는 해결할 문제>
---

# Plan Command

> 개발 진행 방법을 검토하고 2-3개 옵션과 장단점을 제시하는 커맨드.

**계획 대상**: $ARGUMENTS

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"무엇을 계획해야 하나요? 구체적으로 알려주세요.

예시:
- 새 기능 추가
- 버그 수정
- 리팩토링
- 아키텍처 변경"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 없으면 질문 | - |
| 2. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 3. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore) + Read/Grep |
| 4. 옵션 도출 | 가능한 접근 4-5개 → 주요 2-3개 선정 | sequentialthinking (2-6단계) |
| 5. 옵션 제시 | 장단점, 영향 범위, 추천안 제시 | - |
| 6. 사용자 선택 | 옵션 선택 대기 | - |
| 7. 문서 작성 | 선택 시 계획 문서 생성 | Write |

</workflow>

---

<agent_usage>

## @refactor-advisor Agent 활용

**언제 사용:**
- 리팩토링 계획 수립
- 코드 품질 개선 필요
- 복잡도 감소, 중복 제거

**호출 방법:**
```bash
@refactor-advisor
# 또는 자연어
"이 코드 리팩토링 계획 세워줘"
"코드 개선점 분석해줘"
```

**장점:**
- 복잡도, 중복, 패턴 자동 분석
- Sequential Thinking으로 개선점 도출 (3-5단계)
- 우선순위별 리팩토링 계획 (High/Medium/Low)
- 구체적 Before/After 코드 예시
- 점진적 변경 단계 제안

**분석 영역:**
- 복잡도 (함수 길이, 중첩 깊이)
- 중복 (동일/유사 코드)
- 명명 (변수/함수명)
- 구조 (파일/모듈)
- 패턴 (안티패턴)
- 타입 (any 제거)

**plan command와의 차이:**
- plan: 새 기능/아키텍처 변경 계획
- @refactor-advisor: 기존 코드 개선 계획 (기능 변경 없음)

**리팩토링 후 실행:**
```bash
# 1. 리팩토링 계획
@refactor-advisor

# 2. 계획 승인 후 구현
@implementation-executor

# 3. 검증
@deployment-validator
```

</agent_usage>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 복잡도 판단
- 영향 범위: 파일 수, 모듈 수
- 의존성: 외부 라이브러리, 다른 시스템 연동
- 리스크: 기존 기능 영향, 롤백 가능성
- 기술적 난이도: 새로운 패턴, 미지의 영역
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 3 | 1-2 파일, 명확한 변경 | 복잡도 판단 → 현재 상태 → 옵션 도출 |
| **보통** | 5 | 3-5 파일, 로직 변경 | 복잡도 판단 → 현재 상태 → 접근 방식 탐색 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 제약사항 → 접근 방식 → 비교 → 상세 분석 → 추천안 |

### 보통 복잡도 패턴 (5단계)

```
thought 1: 복잡도 판단 및 분석 범위 결정
thought 2: 현재 상태 분석 (코드, 아키텍처, 제약)
thought 3: 가능한 접근 방식 열거 (4-5개)
thought 4: 주요 옵션 3개 선정 및 장단점 분석
thought 5: 최종 옵션 정리 및 추천안 도출
```

### 복잡한 경우 패턴 (7단계)

```
thought 1: 복잡도 판단
thought 2: 현재 상태 심층 분석
thought 3: 기술적 제약 및 요구사항 정리
thought 4: 가능한 접근 방식 탐색
thought 5: 각 접근 방식 비교 분석
thought 6: 옵션 3개 선정 및 상세 장단점
thought 7: 추천안 및 근거
```

### 핵심 원칙

```text
✅ 사고 과정을 출력해야 실제로 생각이 일어남
✅ 복잡도가 불확실하면 높게 책정 (5→7로 확장 가능)
✅ 각 thought에서 구체적 분석 필요 (추상적 설명 금지)
✅ 필요 시 isRevision으로 이전 사고 수정
```

</thinking_strategy>

---

<codebase_exploration>

## Task Subagent 활용

### Subagent 선택

| subagent_type | 용도 | 예시 |
|---------------|------|------|
| **Explore** | 코드베이스 구조 파악, 관련 파일 탐색 | "현재 인증 구조 분석" |
| **Plan** | 구현 전략 수립, 단계별 계획 | "마이그레이션 계획 수립" |
| **general-purpose** | 복잡한 분석, 다중 시스템 연관 | "여러 모듈 간 의존성 분석" |

### Task 호출 패턴

**단일 탐색:**

```typescript
Task({
  subagent_type: 'Explore',
  description: '현재 인증 구조 분석',
  prompt: `
    현재 인증 관련 코드 구조 파악.
    - 사용 중인 라이브러리
    - 세션 관리 방식
    - 수정이 필요한 파일 목록
  `
})
```

**병렬 탐색 (복잡한 경우):**

```typescript
// 단일 메시지에 다중 Task 호출
Task({
  subagent_type: 'Explore',
  prompt: '프론트엔드 인증 구조 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '백엔드 API 인증 엔드포인트 분석'
})

Task({
  subagent_type: 'Explore',
  prompt: '데이터베이스 세션 스키마 분석'
})

// → 결과 취합 후 옵션 정리
```

### 탐색 체크리스트

```text
✅ 현재 구현 방식 파악
✅ 사용 중인 라이브러리/프레임워크 버전
✅ 관련 파일 및 디렉토리 위치
✅ 의존성 및 연관 모듈
✅ 기존 제약사항 (보안, 성능, 호환성)
```

</codebase_exploration>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 3개 제시 (표준)

```markdown
## 분석 결과

### 옵션 1: [옵션 이름] (추천)

**접근 방식:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/auth/`, `src/api/`
- 예상 변경 규모: 중간
- 리스크: 낮음

---

### 옵션 2: [옵션 이름]

**접근 방식:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**영향 범위:**
...

---

### 옵션 3: [옵션 이름]

**접근 방식:**
...

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션을 선택하시겠습니까? (1/2/3)
```

### 옵션 2개 제시 (선택지가 명확한 경우)

```markdown
## 분석 결과

두 가지 접근 방식이 있습니다:

### 옵션 A: [옵션 이름]
...

### 옵션 B: [옵션 이름]
...

어떤 옵션을 선택하시겠습니까? (A/B)
```

</option_presentation>

---

<document_generation>

## 문서 작성

### 문서 작성 질문

```
옵션 [N]을 선택하셨습니다.

계획 문서를 작성할까요?
- Y: .claude/plans/[기능명].md 생성
- N: 바로 구현 시작

선택해주세요. (Y/N)
```

### 계획 문서 템플릿

**파일 위치:** `.claude/plans/[기능명].md`

```markdown
# [기능명] 구현 계획

## 개요

**목표:** [무엇을 달성할 것인가]
**선택된 접근 방식:** [옵션 N]
**예상 영향 범위:** [파일/모듈 목록]

## 현재 상태

- 현재 구조 설명
- 관련 코드 위치
- 기존 제약사항

## 구현 단계

### 1단계: [단계 이름]

**작업:**
- [ ] 작업 1
- [ ] 작업 2

**변경 파일:**
- `src/file1.ts`
- `src/file2.ts`

### 2단계: [단계 이름]

**작업:**
- [ ] 작업 3

**변경 파일:**
- `src/file3.ts`

### 3단계: [단계 이름]
...

## 고려사항

### 리스크

| 리스크 | 완화 방안 |
|--------|----------|
| 리스크 1 | 방안 1 |
| 리스크 2 | 방안 2 |

### 의존성

- 외부 라이브러리: [목록]
- 다른 시스템: [목록]

### 롤백 계획

문제 발생 시 롤백 방법.

## 검증 방법

- 테스트 항목 1
- 테스트 항목 2
- 통합 테스트

## 참조

- 관련 문서 링크
- 참고 자료
```

</document_generation>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드베이스 탐색
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 영향 범위 및 예상 작업량 제시
```

절대 금지:

```text
❌ ARGUMENT 없이 분석 시작
❌ Edit 도구 사용 (코드 수정 금지)
❌ Sequential Thinking 3단계 미만
❌ 옵션 1개만 제시
❌ 코드 탐색 없이 추측으로 옵션 제시
❌ 사용자 선택 없이 구현 시작
❌ 장단점 없이 옵션만 나열
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: 인증 시스템 변경

```bash
사용자: /plan 사용자 인증을 JWT에서 세션 기반으로 변경

1. Sequential Thinking (7단계):
   thought 1: "인증 시스템 변경 - 복잡도 높음, 다중 모듈 영향"
   thought 2: "현재 JWT 구현 분석: src/auth/jwt.ts, 토큰 검증 미들웨어"
   thought 3: "제약사항: 기존 사용자 세션 유지, Redis/DB 선택"
   thought 4: "접근 방식: 점진적 마이그레이션, 완전 대체, 하이브리드"
   thought 5: "점진적이 리스크 낮음, 하이브리드는 복잡도 높음"
   thought 6: "옵션 3개 선정 및 장단점 분석"
   thought 7: "점진적 마이그레이션 추천 - 롤백 용이, 단계적 검증"

2. Task 탐색:
   Task (Explore): "현재 JWT 인증 구현 분석"
   → src/auth/, src/middleware/, API 엔드포인트 파악

3. 옵션 제시:
   옵션 1: 점진적 마이그레이션 (추천)
   - 장점: 롤백 용이, 리스크 낮음
   - 단점: 구현 시간 길어짐

   옵션 2: 완전 대체
   - 장점: 깔끔한 구조
   - 단점: 높은 리스크

   옵션 3: 하이브리드 방식
   - 장점: 유연성
   - 단점: 복잡도 증가

4. 사용자 선택: 1

5. 문서 작성 질문: Y

6. .claude/plans/session-auth.md 생성
```

### 예시 2: 실시간 알림 기능

```bash
사용자: /plan 실시간 알림 기능 추가

1. Sequential Thinking (5단계):
   thought 1: "실시간 알림 - 보통 복잡도, 새 기능 추가"
   thought 2: "현재 통신 구조: REST API, 폴링 없음"
   thought 3: "접근 방식: WebSocket, SSE, Long Polling, Firebase"
   thought 4: "WebSocket이 양방향, SSE는 단방향이지만 간단"
   thought 5: "WebSocket 추천, 폴링은 비효율적"

2. Task 탐색:
   Task (Explore): "현재 API 구조 및 클라이언트 통신 방식"

3. 옵션:
   옵션 1: WebSocket (추천)
   옵션 2: Server-Sent Events
   옵션 3: Short Polling

4. 선택 후 계획 문서 생성
```

### 예시 3: 간단한 리팩토링

```bash
사용자: /plan utils 함수를 TypeScript로 전환

1. Sequential Thinking (3단계):
   thought 1: "단순 리팩토링 - 간단, 1-2 파일"
   thought 2: "현재 utils.js 분석 필요"
   thought 3: "타입 정의 → 전환 → 테스트 검증"

2. Task 탐색:
   Read: src/utils.js
   Grep: utils 사용처 검색

3. 옵션:
   옵션 A: 점진적 전환 (파일별)
   옵션 B: 일괄 전환

4. 선택 → 구현 (문서 작성 생략 가능)
```

</examples>
