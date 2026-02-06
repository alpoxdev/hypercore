# Sub-Agent Distribution (서브 에이전트 컨텍스트 분산)

**목적**: Task 에이전트 활용으로 컨텍스트를 분산하고 효율적으로 관리

---

## 핵심 문제

### Usage Report 분석 결과

| 문제 | 빈도 | 원인 |
|------|------|------|
| **Rate Limiting** | 8건 | 단일 에이전트 과도한 작업 |
| **Context Window Exceeded** | 3건 | 메인 에이전트에 모든 탐색 결과 축적 |
| **컨텍스트 소진** | 반복 | 전체 파일 읽기 + 상세 분석 누적 |

### 핵심 원칙

**"각 에이전트는 독립적인 컨텍스트를 보유하며, 압축된 결과만 전달한다"**

```
❌ Main Agent
   └─ Read 20 files (전체 탐색 수행)
   └─ 컨텍스트 누적 → Context Window Exceeded

✅ Main Agent
   ├─ Task(explore) → 압축 결과 수신
   ├─ Task(implementation) → 실행
   └─ Task(verifier) → 검증 결과 수신
```

---

## 에이전트 컨텍스트 분산 원칙

### 원칙 1: 독립 컨텍스트 보유

| 에이전트 | 컨텍스트 | 메인으로 전달 |
|---------|----------|-------------|
| **Analyzer** | 전체 코드베이스 탐색 | 핵심 파일 3-5개 + 요약 |
| **Transformer** | 변경 대상 파일만 | 변경 완료 확인 |
| **Verifier** | 검증 결과만 | ✅/❌ + 에러 요약 |

### 원칙 2: 압축된 정보만 전달

```typescript
// ❌ 금지: 전체 탐색 결과 전달
Task(subagent_type="explore", model="haiku",
     prompt="프론트엔드 인증 구조 분석")
// → 결과: 50개 파일 목록 + 전체 코드 구조 (2000줄)
// → 메인 에이전트: 2000줄 수신 → 컨텍스트 소진

// ✅ 올바름: 압축된 결과 요청
Task(subagent_type="explore", model="haiku",
     prompt=`프론트엔드 인증 구조 분석

     결과 형식:
     1. 핵심 파일 3개 (경로만)
     2. 아키텍처 요약 (500자 이내)
     3. 주요 이슈 (3개 이내)`)
// → 결과: 핵심 정보만 (100줄)
```

### 원칙 3: 재탐색 금지

```typescript
// ❌ 금지: 에이전트 결과 무시 후 재탐색
Task(subagent_type="explore", ...)
// → 결과: "인증 관련 파일 3개: auth.ts, login.ts, middleware.ts"
Read("src/auth.ts")  // 재탐색 금지!
Read("src/login.ts")
Read("src/middleware.ts")

// ✅ 올바름: 에이전트 결과 직접 활용
Task(subagent_type="explore", ...)
// → 결과: "인증 관련 파일 3개: auth.ts, login.ts, middleware.ts"
Task(subagent_type="implementation-executor",
     prompt=`auth.ts, login.ts, middleware.ts 수정
     (에이전트가 파일 읽기)`)
```

---

## DAG 기반 에이전트 파이프라인

### 기본 파이프라인

```
Analyzer Agent (explore/analyst)
    ↓
    압축된 분석 결과
    (핵심 파일 3-5개, 아키텍처 요약 500자)
    ↓
Transformer Agent (implementation-executor)
    ↓
    변경 완료 확인
    (수정된 파일 목록만)
    ↓
Verifier Agent (deployment-validator/code-reviewer)
    ↓
    검증 결과
    (✅/❌ + 에러 요약)
```

### 병렬 파이프라인 (풀스택)

```
Main Agent
    ├─ Analyzer 1 (백엔드) → 압축 결과 A
    ├─ Analyzer 2 (프론트) → 압축 결과 B
    ├─ Analyzer 3 (DB) → 압축 결과 C
    ↓
    결과 A + B + C 통합 (500줄 이내)
    ↓
    ├─ Transformer 1 (백엔드)
    ├─ Transformer 2 (프론트)
    ├─ Transformer 3 (DB)
    ↓
    ├─ Verifier 1 (보안)
    ├─ Verifier 2 (성능)
    └─ Verifier 3 (빌드)
```

---

## 에이전트별 역할 분리

### Analyzer (explore/analyst)

**역할:** 코드베이스 탐색 → 핵심 정보만 추출

```typescript
Task(subagent_type="explore", model="haiku",
     prompt=`인증 관련 코드 분석

     출력 형식:
     1. 핵심 파일 (최대 5개)
        - 경로
        - 역할 (1줄)
     2. 아키텍처 요약 (500자 이내)
     3. 주요 이슈 (최대 3개)

     불필요한 정보 제외:
     - 전체 코드 내용
     - 모든 파일 목록
     - 상세한 함수 분석`)
```

**컨텍스트 절약:**
- 전체 탐색: 2000줄
- 압축 결과: 100줄
- 절감: 95%

### Transformer (implementation-executor)

**역할:** 실제 변경 수행 (Analyzer 결과 기반)

```typescript
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`Analyzer 결과 기반 구현

     분석 결과:
     - auth.ts: 인증 로직
     - login.ts: 로그인 UI
     - middleware.ts: 인증 미들웨어

     작업:
     JWT 토큰 갱신 로직 추가

     출력 형식:
     1. 수정된 파일 목록
     2. 주요 변경 사항 (3줄 이내)`)
```

**컨텍스트 절약:**
- 파일 자체 읽기 (컨텍스트 내부)
- 메인에는 변경 확인만 전달 (20줄)

### Verifier (deployment-validator/code-reviewer)

**역할:** 검증 및 피드백

```typescript
Task(subagent_type="deployment-validator", model="sonnet",
     prompt=`변경 사항 검증

     출력 형식:
     1. 결과: ✅/❌
     2. 에러 요약 (있는 경우만, 최대 5개)
     3. 해결 방법 (1줄 이내)

     불필요한 정보 제외:
     - 전체 빌드 로그
     - 모든 테스트 결과
     - 상세 스택트레이스`)
```

**컨텍스트 절약:**
- 전체 빌드 로그: 5000줄
- 압축 결과: 50줄
- 절감: 99%

---

## 압축된 결과 형식

### 형식 1: 파일 인벤토리

```markdown
## 인증 관련 파일

| 파일 | 역할 | 우선순위 |
|------|------|---------|
| auth.ts | JWT 토큰 발급 | HIGH |
| login.ts | 로그인 UI | MEDIUM |
| middleware.ts | 인증 미들웨어 | HIGH |

**아키텍처 요약:**
JWT 기반 인증. 토큰은 auth.ts에서 발급, middleware.ts에서 검증.

**주요 이슈:**
1. 토큰 갱신 로직 없음
2. 에러 처리 미흡
```

### 형식 2: 검증 결과

```markdown
## 검증 결과

**결과:** ❌ 실패

**에러 요약:**
1. TypeScript: auth.ts:45 - Type 'string | undefined'
2. ESLint: login.ts:12 - Unused variable 'user'

**해결:**
1. auth.ts:45 → Optional chaining 추가
2. login.ts:12 → 변수 제거
```

### 형식 3: 변경 확인

```markdown
## 변경 완료

**수정된 파일:**
- auth.ts
- middleware.ts

**주요 변경:**
- JWT 토큰 갱신 로직 추가
- 만료 시간 검증 개선
```

---

## 병렬 연구 에이전트 패턴 (Research Swarm)

### 패턴: 3-5개 Researcher 병렬 실행

```typescript
// 각 researcher가 다른 측면 조사
Task(subagent_type="researcher", model="sonnet",
     prompt=`WebSocket 성능 조사 (2026)

     출력 파일: .claude/research/websocket-performance.md
     형식:
     - 핵심 요약 (200자)
     - 주요 지표 3개
     - 참고 링크 3개`)

Task(subagent_type="researcher", model="sonnet",
     prompt=`SSE 성능 조사 (2026)

     출력 파일: .claude/research/sse-performance.md
     형식:
     - 핵심 요약 (200자)
     - 주요 지표 3개
     - 참고 링크 3개`)

Task(subagent_type="researcher", model="sonnet",
     prompt=`WebRTC 성능 조사 (2026)

     출력 파일: .claude/research/webrtc-performance.md
     형식:
     - 핵심 요약 (200자)
     - 주요 지표 3개
     - 참고 링크 3개`)

// 메인 에이전트: 요약 파일만 읽음
Read(".claude/research/websocket-performance.md")  // 20줄
Read(".claude/research/sse-performance.md")         // 20줄
Read(".claude/research/webrtc-performance.md")      // 20줄
// → 총 60줄 (개별 조사 결과 수천 줄 vs 요약 60줄)
```

### 결과 통합

```typescript
// 통합 결과
Write(".claude/research/realtime-comparison.md", `
# 실시간 통신 기술 비교

| 기술 | 성능 | 복잡도 | 추천 |
|------|------|--------|------|
| WebSocket | 높음 | 중간 | ✅ |
| SSE | 중간 | 낮음 | ⚠️ |
| WebRTC | 매우 높음 | 높음 | ❌ |

**결정:** WebSocket 채택
`)
```

---

## 컨텍스트 절약 예시

### 예시 1: 인증 구조 분석

```typescript
// ❌ 메인 에이전트가 직접 탐색 (컨텍스트 소모)
Glob("**/auth*.ts")  // 20개 파일
Read("src/auth.ts")
Read("src/middleware/auth.ts")
Read("src/utils/auth.ts")
Read("src/routes/login.ts")
// ... (20개 파일 읽기)
// 컨텍스트: 10,000줄 소모

// ✅ 에이전트에 탐색 위임 + 압축 결과만 수신
Task(subagent_type="explore", model="haiku",
     prompt=`인증 관련 파일 분석

     결과 형식:
     - 핵심 파일 3개 (경로 + 역할)
     - 아키텍처 요약 500자 이내`)
// → 결과: 100줄
// 컨텍스트: 100줄 (99% 절감)
```

### 예시 2: 풀스택 기능 구현

```typescript
// ❌ 메인 에이전트가 모든 영역 탐색
Read("backend/api/...")  // 50개 파일
Read("frontend/pages/...")  // 30개 파일
Read("db/schema/...")  // 10개 파일
// 컨텍스트: 20,000줄 소모 → Context Window Exceeded

// ✅ 영역별 에이전트 병렬 위임
Task(subagent_type="explore", model="haiku",
     prompt="백엔드 API 구조 분석 → 핵심 파일 3개 + 요약 500자")
Task(subagent_type="explore", model="haiku",
     prompt="프론트엔드 UI 구조 분석 → 핵심 파일 3개 + 요약 500자")
Task(subagent_type="explore", model="haiku",
     prompt="DB 스키마 분석 → 핵심 테이블 3개 + 요약 500자")
// → 각각 100줄씩, 총 300줄
// 컨텍스트: 300줄 (98.5% 절감)
```

### 예시 3: 대규모 리팩토링

```typescript
// ❌ 메인 에이전트가 모든 파일 읽기 + 수정
Glob("**/*.ts")  // 500개 파일
Read(...)  // 100개 파일 읽기
Edit(...)  // 50개 파일 수정
// 컨텍스트: 50,000줄 → Rate Limiting

// ✅ 배치별 에이전트 위임
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`파일 1-10: any → unknown 변환

     출력: 변경 완료 확인 (10줄 이내)`)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`파일 11-20: any → unknown 변환

     출력: 변경 완료 확인 (10줄 이내)`)
// ... (5개 배치 병렬 실행)
// → 각각 10줄씩, 총 50줄
// 컨텍스트: 50줄 (99.9% 절감)
```

---

## 에이전트 결과 활용

### 규칙 1: 에이전트 결과 직접 참조

```typescript
// ✅ 올바름: 에이전트 결과 기반 작업
Task(subagent_type="explore", ...)
// → 결과: "핵심 파일: auth.ts, login.ts, middleware.ts"

Task(subagent_type="implementation-executor",
     prompt=`auth.ts, login.ts, middleware.ts 수정
     (에이전트 결과 기반, 재탐색 불필요)`)

// ❌ 금지: 결과 무시 후 재탐색
Task(subagent_type="explore", ...)
// → 결과 무시
Read("auth.ts")  // 재탐색 금지!
```

### 규칙 2: 파일로 저장하여 다음 Phase에서 활용

```typescript
// Phase 1: 분석 (에이전트)
Task(subagent_type="analyst", model="sonnet",
     prompt=`요구사항 분석

     결과 파일: .claude/analysis/requirements.md`)

// Phase 2: 구현 (다음 세션)
Read(".claude/analysis/requirements.md")  // 100줄
// → 전체 분석 과정 재수행 불필요
```

### 규칙 3: 의사결정은 요약 기반

```typescript
// ✅ 올바름: 요약 기반 결정
Task(subagent_type="explore", ...)
// → 결과: "WebSocket 추천, SSE 차선책"
// 결정: WebSocket 채택

// ❌ 금지: 전체 조사 재수행
Read("external/websocket-docs.html")  // 10,000줄
Read("external/sse-docs.html")  // 8,000줄
// → 에이전트 결과 무시
```

---

## 체크리스트

### 작업 시작 전 확인

```
[ ] 탐색/분석 필요? → explore/analyst 에이전트 위임
[ ] 결과 형식 명시? → 압축된 형식 (500자 이내)
[ ] 병렬 실행 가능? → 여러 에이전트 동시 호출
[ ] 결과 파일로 저장? → .claude/analysis/ 활용
```

### 작업 중 확인

```
[ ] 에이전트 결과 재탐색? → 금지!
[ ] 전체 로그 출력? → 요약만 출력
[ ] 메인 컨텍스트 크기? → 500줄 이하 유지
```

### 작업 완료 후 확인

```
[ ] Context Window Exceeded 발생? → 에이전트 위임 증가
[ ] Rate Limiting 발생? → 배치 크기 축소
[ ] 컨텍스트 절감? → 90% 이상 목표
```

---

## 핵심 요약

| 원칙 | 설명 | 효과 |
|------|------|------|
| **독립 컨텍스트** | 각 에이전트가 별도 컨텍스트 보유 | 메인 에이전트 부담 감소 |
| **압축 전달** | 핵심 정보만 메인으로 전달 | 95-99% 컨텍스트 절감 |
| **DAG 파이프라인** | Analyzer → Transformer → Verifier | 명확한 흐름, 재사용 |
| **병렬 연구** | 3-5개 researcher 동시 실행 | 시간 단축, 컨텍스트 격리 |
| **결과 직접 활용** | 에이전트 결과 재탐색 금지 | 중복 작업 제거 |
| **파일 저장** | 분석 결과 파일로 보존 | 다음 Phase 재사용 |

**"Each produce compressed artifacts, eliminating the context exhaustion"**
