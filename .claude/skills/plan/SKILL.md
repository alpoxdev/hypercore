# Plan Skill

> 개발 진행 방법 검토 및 옵션 제시

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **새 기능 추가** | 인증 시스템, 실시간 알림, 결제 모듈 |
| **아키텍처 변경** | 상태 관리 전환, DB 마이그레이션, 모노레포 전환 |
| **리팩토링** | 코드 구조 개선, 타입 전환, 모듈 분리 |
| **기술 선택** | 라이브러리 비교, 프레임워크 선정 |
| **문제 해결** | 성능 개선, 버그 수정 전략 |

## 호출 방법

```bash
# 직접 처리 (명확한 범위)
/plan 사용자 프로필 편집 기능 추가

# planner agent 위임 (복잡한 경우)
Task({
  subagent_type: 'planner',
  model: 'opus',
  description: '인증 시스템 재설계 계획',
  prompt: 'JWT를 세션 기반으로 전환'
})
```

## 결과물

- 2-3개 옵션 제시 (장단점, 영향 범위)
- 추천안 및 근거
- 선택 후 `.claude/plans/[기능명].md` 자동 생성

</when_to_use>

---

<parallel_agent_execution>

## 병렬 Agent 실행

### Recommended Agents

| Agent | Model | 용도 | 복잡도 |
|-------|-------|------|--------|
| **@planner** | opus | 계획 수립, 체계적 분석 | HIGH |
| **@explore** | haiku/sonnet | 코드베이스 탐색, 구조 파악 | LOW-MEDIUM |
| **@architect** | sonnet/opus | 아키텍처 분석, 설계 검토 | MEDIUM-HIGH |
| **@analyst** | sonnet | 요구사항 분석, 기술 조사 | MEDIUM |

---

### Parallel Execution Patterns

**1. 탐색 + 분석 병렬**

복잡한 시스템에서 여러 영역을 동시에 조사할 때 사용:

```typescript
// 프론트엔드 + 백엔드 동시 탐색
Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '프론트엔드 인증 UI 및 상태 관리 구조 분석'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  prompt: '백엔드 인증 API 엔드포인트 및 미들웨어 분석'
})

Task({
  subagent_type: 'architect',
  model: 'sonnet',
  prompt: '현재 인증 아키텍처 평가 및 개선점 도출'
})
```

**2. 여러 영역 계획 병렬**

독립적인 모듈/시스템을 각각 계획할 때:

```typescript
// 여러 모듈 리팩토링 계획 동시 수립
Task({
  subagent_type: 'planner',
  model: 'opus',
  prompt: 'User 모듈 리팩토링 상세 계획 수립'
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  prompt: 'Payment 모듈 리팩토링 상세 계획 수립'
})

Task({
  subagent_type: 'planner',
  model: 'sonnet',
  prompt: 'Notification 모듈 리팩토링 상세 계획 수립'
})
```

**3. 조사 병렬화**

기술 스택 선정, 라이브러리 비교 시:

```typescript
// 여러 솔루션 동시 조사
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: 'WebSocket 라이브러리 조사 (Socket.io, ws, uWebSockets)'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: 'SSE 구현 방식 조사 (EventSource, fetch streams)'
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  prompt: '폴링 방식 조사 (short/long polling 패턴)'
})
```

---

### Model Routing

| 복잡도 | 조건 | 권장 Model | 예시 |
|--------|------|-----------|------|
| **LOW** | 단순 계획, 명확한 변경 | sonnet/haiku | 파일 수정, 설정 변경 |
| **MEDIUM** | 일반 계획, 로직 추가 | sonnet | 기능 추가, 버그 수정 |
| **HIGH** | 복잡한 계획, 아키텍처 변경 | opus | 시스템 재설계, 대규모 리팩토링 |

**Model 선택 가이드:**

```text
✅ haiku: 빠른 탐색, 파일 목록, 구조 파악
✅ sonnet: 일반 분석, 코드 리뷰, 패턴 도출
✅ opus: 복잡한 설계, 아키텍처 결정, 체계적 계획
```

---

### Practical Examples

**예시 1: 인증 시스템 재설계 (탐색 + 아키텍처 병렬)**

```typescript
// 1단계: 현재 상태 탐색 (병렬)
Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: '인증 UI 분석',
  prompt: '로그인/회원가입 UI, 폼 검증, 에러 처리 분석'
})

Task({
  subagent_type: 'explore',
  model: 'sonnet',
  description: '인증 API 분석',
  prompt: 'API 엔드포인트, 미들웨어, 토큰 관리 방식 분석'
})

Task({
  subagent_type: 'explore',
  model: 'haiku',
  description: 'DB 스키마 분석',
  prompt: 'User 테이블, 세션 테이블, 관계 분석'
})

// 2단계: 아키텍처 분석 (탐색 결과 기반)
Task({
  subagent_type: 'architect',
  model: 'opus',
  description: '인증 아키텍처 평가',
  prompt: `
    탐색 결과 기반으로:
    1. 현재 아키텍처 문제점 도출
    2. 개선 방향 제시
    3. 마이그레이션 전략 수립
  `
})

// → 결과 취합 후 옵션 제시
```

**예시 2: 여러 모듈 리팩토링 계획 (계획 병렬)**

```typescript
// 독립적인 모듈들을 동시에 계획
Task({
  subagent_type: 'planner',
  model: 'opus',
  description: 'User 모듈 계획',
  prompt: `
    User 모듈 리팩토링:
    - 복잡도 감소
    - 타입 안정성 향상
    - 테스트 커버리지 증대
  `
})

Task({
  subagent_type: 'planner',
  model: 'opus',
  description: 'Payment 모듈 계획',
  prompt: `
    Payment 모듈 리팩토링:
    - 트랜잭션 안정성
    - 에러 핸들링 개선
    - 로깅 강화
  `
})

Task({
  subagent_type: 'planner',
  model: 'sonnet',
  description: 'Notification 모듈 계획',
  prompt: `
    Notification 모듈 리팩토링:
    - 템플릿 구조화
    - 다국어 지원
    - 전송 실패 재시도
  `
})

// → 각 모듈별 .claude/plans/ 문서 생성
```

**예시 3: 실시간 기능 기술 조사 (조사 병렬)**

```typescript
// 여러 기술 스택 동시 조사
Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'WebSocket 조사',
  prompt: `
    WebSocket 구현 조사:
    - Socket.io vs ws vs uWebSockets
    - 스케일링 방안
    - 장단점 분석
  `
})

Task({
  subagent_type: 'analyst',
  model: 'sonnet',
  description: 'SSE 조사',
  prompt: `
    Server-Sent Events 조사:
    - 브라우저 호환성
    - 재연결 처리
    - 제약사항
  `
})

Task({
  subagent_type: 'analyst',
  model: 'haiku',
  description: '폴링 조사',
  prompt: `
    폴링 방식 조사:
    - Short vs Long polling
    - 리소스 사용량
    - 적용 시나리오
  `
})

// → 결과 비교 후 기술 스택 추천
```

---

### 병렬 실행 시 고려사항

```text
✅ 독립적인 작업만 병렬 실행 (의존성 없는 경우)
✅ 결과 취합 후 통합 분석 수행
✅ 모델 선택 시 복잡도 고려 (haiku/sonnet/opus)
✅ 병렬 실행 수는 3-5개 권장 (너무 많으면 복잡)

❌ 순차 의존성이 있는 작업 병렬화 금지
❌ 결과 취합 없이 개별 결과만 사용
❌ 모든 작업에 opus 사용 (비용/시간 낭비)
```

</parallel_agent_execution>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 2. 코드베이스 탐색 | 현재 상태 파악, 관련 파일 탐색 | Task (Explore/planner) |
| 3. 옵션 도출 | 가능한 접근 4-5개 → 주요 2-3개 선정 | sequentialthinking (2-6단계) |
| 4. 옵션 제시 | 장단점, 영향 범위, 추천안 제시 | - |
| 5. 문서 생성 | 옵션 선택 대기 후 계획 문서 자동 생성 | Write |

### Agent 선택 기준

| 복잡도 | 조건 | 사용 Agent |
|--------|------|-----------|
| **매우 복잡** | 다중 시스템, 아키텍처 변경, 불확실성 높음 | Task (planner) 위임 |
| **복잡/보통** | 명확한 범위, 3-10 파일 | 직접 처리 (Task Explore 활용) |
| **간단** | 1-2 파일, 명확한 변경 | 직접 처리 |

### Sequential Thinking 가이드

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|----------|
| **간단** | 3 | 1-2 파일, 명확한 변경 | 복잡도 판단 → 현재 상태 → 옵션 도출 |
| **보통** | 5 | 3-5 파일, 로직 변경 | 복잡도 판단 → 현재 상태 → 접근 방식 탐색 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 다중 모듈, 아키텍처 변경 | 복잡도 판단 → 심층 분석 → 제약사항 → 접근 방식 → 비교 → 상세 분석 → 추천안 |

</workflow>

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

</option_presentation>

---

<document_generation>

## 계획 문서 자동 생성

사용자가 옵션을 선택하면 자동으로 `.claude/plans/[기능명].md`에 계획 문서를 생성합니다.

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

<examples>

## 실전 예시

### 예시 1: 인증 시스템 변경 (매우 복잡 - planner agent 위임)

```bash
사용자: /plan 사용자 인증을 JWT에서 세션 기반으로 변경

1. Sequential Thinking (1단계):
   thought 1: "인증 시스템 변경 - 매우 복잡함, 다중 시스템 영향,
              아키텍처 변경. planner agent로 위임하는 것이 적합"

2. planner agent 위임:
   Task({
     subagent_type: 'planner',
     description: '인증 시스템 재설계 계획',
     prompt: 'JWT 기반 인증을 세션 기반으로 전환하는 체계적 계획 수립',
     model: 'opus'
   })

3. planner agent 프로세스:
   - 인터뷰: 요구사항, 제약사항, 리스크 허용도 파악
   - 코드베이스 조사: Explore agent로 현재 구조 분석
   - 계획 생성: .claude/plans/session-auth.md
   - 사용자 확인 후 핸드오프

→ 복잡한 작업은 planner에게 위임하여 체계적으로 처리
```

### 예시 2: 실시간 알림 기능 (보통)

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

3. 옵션 제시:
   옵션 1: WebSocket (추천)
   - 장점: 양방향 통신, 실시간성 우수
   - 단점: 복잡도 증가, 인프라 고려

   옵션 2: Server-Sent Events
   - 장점: 구현 단순, HTTP 기반
   - 단점: 단방향만, 브라우저 제한

   옵션 3: Short Polling
   - 장점: 구현 매우 간단
   - 단점: 비효율적, 지연 발생

4. 사용자 선택: 1

5. 자동으로 .claude/plans/realtime-notification.md 생성
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

3. 옵션 제시:
   옵션 A: 점진적 전환 (파일별)
   - 장점: 리스크 낮음
   - 단점: 시간 소요

   옵션 B: 일괄 전환
   - 장점: 깔끔함
   - 단점: 테스트 필요

4. 사용자 선택 → 계획 문서 생성
```

</examples>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드베이스 탐색
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 영향 범위 및 예상 작업량 제시
```

절대 금지:

```text
❌ Edit 도구 사용 (코드 수정 금지)
❌ Sequential Thinking 3단계 미만
❌ 옵션 1개만 제시
❌ 코드 탐색 없이 추측으로 옵션 제시
❌ 사용자 선택 없이 구현 시작
❌ 장단점 없이 옵션만 나열
```

</validation>
