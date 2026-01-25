# Refactor Skill - Agents

## refactor-advisor

**역할:** 코드 품질 개선을 위한 리팩토링 계획 수립 및 조언 (READ-ONLY)

**도구:**
- Read: 코드 파일 읽기
- Grep: 코드 패턴 검색
- Glob: 파일 목록 조회
- Bash: git, 메트릭 도구 실행 (읽기 전용)
- sequentialthinking: 분석 사고 과정

**금지:**
- Edit: 코드 수정 금지
- Write: 파일 생성 금지
- Task: 하위 에이전트 호출 금지

**특징:**
- 읽기 전용 에이전트
- 코드 분석 및 개선 방향 조언만 제공
- 실제 구현은 implementation-executor에게 위임

**사용 시점:**
- 코드 복잡도, 중복률, 타입 안정성 분석 필요 시
- 리팩토링 우선순위 결정 필요 시
- 점진적 개선 전략 수립 필요 시

**권장 모델:** sonnet

---

## implementation-executor

**역할:** 리팩토링 계획을 실제로 구현

**도구:**
- Read, Edit, Write: 파일 읽기/수정/생성
- Bash: 테스트, 빌드, git 실행
- sequentialthinking: 구현 사고 과정

**사용 시점:**
- refactor-advisor의 계획을 실제로 코드로 구현
- PLAN.md 기반 단계별 리팩토링 실행

**권장 모델:**
- 단순 작업 (변수명 변경, 포맷팅): haiku
- 일반 작업 (함수 분리, 중복 제거): sonnet
- 복잡한 작업 (아키텍처 변경): opus

---

## code-reviewer

**역할:** 리팩토링 후 품질 검증

**도구:**
- Read: 변경된 코드 읽기
- Bash: 테스트, 린트, 타입 체크 실행
- sequentialthinking: 검토 사고 과정

**금지:**
- Edit/Write: 검토만 수행, 수정은 하지 않음

**사용 시점:**
- 리팩토링 완료 후 품질 검증
- 다중 관점 코드 리뷰 (성능, 보안, 가독성, 유지보수성)

**권장 모델:** opus (세밀한 검토 필요)

---

## architect

**역할:** 아키텍처 분석 및 구조 개선 방향 제시 (READ-ONLY)

**도구:**
- Read, Grep, Glob: 코드베이스 탐색
- Bash: 의존성 분석 도구 실행 (읽기 전용)
- sequentialthinking: 아키텍처 분석

**금지:**
- Edit/Write: 분석만 수행, 수정은 하지 않음

**사용 시점:**
- 아키텍처 문제점 분석
- 모듈 구조 개선 방향 제시
- 레이어드 아키텍처 전환 전략

**권장 모델:**
- 일반 분석: sonnet
- 복잡한 설계: opus

---

## analyst

**역할:** 코드 메트릭 분석, 엣지 케이스 검증

**도구:**
- Read, Grep, Glob: 코드 분석
- Bash: 메트릭 도구 실행 (복잡도, 중복률 등)
- sequentialthinking: 분석 사고 과정

**사용 시점:**
- 복잡도, 중복률, 타입 안정성 메트릭 수집
- Before/After 비교 분석
- 리팩토링 우선순위 결정

**권장 모델:** sonnet

---

## explore

**역할:** 코드베이스 탐색, 의존성 파악

**도구:**
- Read, Grep, Glob: 파일 탐색
- Bash: find, tree 등 탐색 명령

**사용 시점:**
- 중복 코드 패턴 탐색
- 모듈 간 의존성 그래프 생성
- any 타입 사용 지점 전수 조사

**권장 모델:** haiku (빠른 탐색)

---

## document-writer

**역할:** 리팩토링 계획 및 결과 문서화

**도구:**
- Read: 기존 문서 읽기
- Write: 문서 생성
- sequentialthinking: 문서 구조화

**사용 시점:**
- ANALYSIS.md, PLAN.md, METRICS.md 생성
- 리팩토링 가이드, 마이그레이션 문서 작성

**권장 모델:**
- 간단한 문서 (ANALYSIS.md, METRICS.md): haiku
- 복잡한 문서 (PLAN.md, 상세 가이드): sonnet

---

## Model Routing

| 복잡도 | 리팩토링 유형 | Model | Agent | 예시 |
|--------|--------------|-------|-------|------|
| **LOW** | 단순 개선 | haiku | implementation-executor, explore, document-writer | 변수명 변경, 코드 포맷팅, 파일 탐색 |
| **MEDIUM** | 일반 리팩토링 | sonnet | refactor-advisor, implementation-executor, analyst, architect, document-writer | 함수 분리, 중복 제거, 타입 개선, 메트릭 분석 |
| **HIGH** | 복잡한 구조 변경 | opus | architect, code-reviewer | 아키텍처 재설계, 모듈 분리, 품질 검증 |

---

## Agent 조합 패턴

### 패턴 1: 분석 + 계획

```typescript
// 코드 분석과 리팩토링 계획 동시 진행
Task({
  subagent_type: "refactor-advisor",
  model: "sonnet",
  prompt: "코드 분석 및 리팩토링 계획 수립"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "복잡도, 중복률 메트릭 수집"
})

Task({
  subagent_type: "architect",
  model: "opus",
  prompt: "아키텍처 문제점 분석 (READ-ONLY)"
})
```

### 패턴 2: 탐색 + 실행

```typescript
// 의존성 파악과 독립 모듈 리팩토링 동시 진행
Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "모듈 간 의존성 그래프 생성"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "독립 유틸리티 함수 리팩토링 (의존성 없음)"
})
```

### 패턴 3: 구현 + 검증 + 문서

```typescript
// 리팩토링, 검증, 문서화 동시 진행
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "함수 분리 리팩토링 실행"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "리팩토링 후 품질 검증"
})

Task({
  subagent_type: "document-writer",
  model: "haiku",
  prompt: "리팩토링 변경 사항 문서화"
})
```

### 패턴 4: 다중 관점 검증

```typescript
// 리팩토링 후 여러 관점에서 동시 검증
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "성능 검토: 불필요한 리렌더, N+1 쿼리"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "보안 검토: 타입 안정성, 입력 검증"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "가독성 검토: 명명 규칙, 함수 길이"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "유지보수성 검토: 테스트 커버리지, 확장성"
})
```

---

## 주의사항

```text
✅ 권장:
- refactor-advisor: READ-ONLY, 조언만 제공
- 독립적인 모듈/파일 → 병렬 실행
- 분석 작업 (읽기 전용) → 병렬 실행
- 다중 관점 검증 → 병렬 실행

❌ 금지:
- refactor-advisor에서 Edit/Write 사용
- 같은 파일 동시 수정 (충돌 발생)
- 순차 의존성 있는 작업 병렬화
```
