# Refactor Skill

> 코드 품질 개선을 위한 리팩토링 계획 수립 및 실행 전략 제시

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **코드 품질 개선** | 복잡도 감소, 중복 코드 제거, 명명 개선 |
| **구조 개선** | 파일/모듈 구조 정리, 관심사 분리 |
| **점진적 개선** | 단계적 리팩토링 계획 필요 |
| **성능 최적화** | 코드 효율성 개선 (기능 유지) |
| **타입 안정성** | any 제거, 명시적 타입 정의 |

## 호출 방법

```bash
# 직접 처리 (명확한 범위)
/refactor src/utils/auth.ts - 너무 복잡함

# @refactor-advisor 위임 (코드 품질 개선)
Task({
  subagent_type: 'refactor-advisor',
  model: 'sonnet',
  description: '인증 모듈 리팩토링',
  prompt: '복잡도 감소, 중복 제거, 타입 안정성 향상'
})
```

## 결과물

- 2-3개 리팩토링 옵션 제시 (장단점, 영향 범위)
- 추천안 및 근거
- 선택 후 `.claude/plans/refactor-[이름].md` 자동 생성

</when_to_use>

---

<argument_validation>

## ARGUMENT 필수 확인

```
$ARGUMENTS 없음 → 즉시 질문:

"무엇을 리팩토링해야 하나요? 구체적으로 알려주세요.

예시:
- 특정 파일/모듈 개선
- 복잡도 감소
- 중복 코드 제거
- 구조 개선
- 성능 최적화"

$ARGUMENTS 있음 → 다음 단계 진행
```

</argument_validation>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 입력 확인 | ARGUMENT 검증, 없으면 질문 | - |
| 2. Agent 판단 | @refactor-advisor 사용 여부 결정 | - |
| 3. 복잡도 판단 | Sequential Thinking으로 분석 범위 결정 | sequentialthinking (1단계) |
| 4. 코드 분석 | 현재 코드 구조, 문제점 파악 | Task (Explore) + Read/Grep |
| 5. 개선 옵션 도출 | 가능한 접근 4-5개 → 주요 2-3개 선정 | sequentialthinking (2-6단계) |
| 6. 옵션 제시 | 장단점, 영향 범위, 추천안 제시 | - |
| 7. 계획 문서 작성 | 선택 시 리팩토링 계획 생성 | Write |

</workflow>

---

<agent_priority>

## @refactor-advisor Agent 우선 사용

**기본 원칙:**
```
리팩토링 요청 → @refactor-advisor 먼저 고려
```

### 사용 조건

| 조건 | 설명 |
|------|------|
| **코드 품질 개선** | 복잡도, 중복, 명명, 구조 개선 |
| **기능 변경 없음** | 동작은 유지하며 코드만 개선 |
| **점진적 개선** | 단계적 리팩토링 계획 필요 |

### Agent 활용 흐름

```
1. @refactor-advisor 호출
   → 코드 분석, 우선순위별 개선점 도출

2. 분석 결과 기반 옵션 정리
   → 사용자에게 2-3개 옵션 제시

3. 선택 후 계획 문서 작성
   → .claude/plans/refactor-[이름].md
```

### Agent 미사용 케이스

```
✅ @refactor-advisor 사용:
- 기존 코드 개선
- 복잡도/중복 감소
- 구조 개선

❌ 직접 처리:
- 아키텍처 변경
- 새 기능 추가와 함께 리팩토링
- 프레임워크 마이그레이션
```

</agent_priority>

---

<parallel_agent_execution>

## 병렬 Agent 실행

**복잡한 리팩토링은 여러 Agent를 병렬로 실행하여 효율 향상.**

### 권장 Agent

| Agent | Model | 역할 |
|-------|-------|------|
| **@refactor-advisor** | sonnet | 리팩토링 계획 수립, 우선순위 분석 |
| **@architect** | opus | 아키텍처 분석, 구조 개선 방향 제시 (READ-ONLY) |
| **@implementation-executor** | sonnet | 리팩토링 구현 실행 |
| **@code-reviewer** | opus | 리팩토링 후 품질 검증 |
| **@analyst** | sonnet | 코드 메트릭 분석, 엣지 케이스 검증 |
| **@explore** | haiku | 코드베이스 탐색, 의존성 파악 |
| **@document-writer** | haiku/sonnet | 리팩토링 계획 및 결과 문서화 |

### 병렬 실행 패턴

#### 1. 독립적 모듈 병렬 리팩토링

```typescript
// ✅ 여러 모듈을 동시에 리팩토링
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "User 모듈 리팩토링: 복잡도 감소, 중복 제거"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Product 모듈 리팩토링: 타입 안정성 개선"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Order 모듈 리팩토링: 함수 분리"
})
```

#### 2. 분석 + 계획 병렬

```typescript
// ✅ 아키텍처 분석과 리팩토링 계획을 동시에
Task({
  subagent_type: "architect",
  model: "opus",
  prompt: "현재 아키텍처 문제점 및 개선 방향 분석 (READ-ONLY)"
})

Task({
  subagent_type: "refactor-advisor",
  model: "sonnet",
  prompt: "리팩토링 우선순위 계획 및 단계별 전략"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "코드 복잡도, 중복률, 결합도 메트릭 분석"
})
```

#### 3. 의존성 분석 + 수정 병렬

```typescript
// ✅ 의존성 파악과 독립 모듈 리팩토링 동시 진행
Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "모듈 간 의존성 그래프 분석 및 순환 의존성 탐지"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "독립 유틸리티 함수 리팩토링 (의존성 없음)"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "타입 정의 개선 (다른 모듈에 영향 없음)"
})
```

#### 4. 리팩토링 + 테스트 + 문서 병렬

```typescript
// ✅ 구현, 테스트, 문서를 동시에
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "API 레이어 리팩토링 실행"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "리팩토링된 함수에 대한 단위 테스트 작성"
})

Task({
  subagent_type: "document-writer",
  model: "haiku",
  prompt: "리팩토링 변경 사항 및 마이그레이션 가이드 문서화"
})
```

#### 5. 다중 관점 코드 리뷰 (병렬)

```typescript
// ✅ 리팩토링 후 여러 관점에서 동시 검증
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "성능 검토: 불필요한 리렌더, N+1 쿼리, 메모이제이션"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "보안 검토: 타입 안정성, 입력 검증, 인증/인가 로직"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "가독성 검토: 명명 규칙, 함수 길이, 주석 품질"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "유지보수성 검토: 테스트 커버리지, 의존성 관리, 확장성"
})
```

#### 6. 점진적 마이그레이션 병렬화

```typescript
// ✅ 레거시 + 신규 시스템 공존 리팩토링
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "새 인증 시스템 구현 (기존과 독립)"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "레거시 API 어댑터 구현 (호환성 유지)"
})

Task({
  subagent_type: "implementation-executor",
  model: "haiku",
  prompt: "Feature flag 설정 및 점진적 전환 로직"
})

Task({
  subagent_type: "document-writer",
  model: "sonnet",
  prompt: "마이그레이션 플랜 및 롤백 가이드 작성"
})
```

### Model Routing (복잡도별)

| 복잡도 | 리팩토링 유형 | Model | Agent | 예시 |
|--------|--------------|-------|-------|------|
| **LOW** | 단순 개선 | haiku | implementation-executor | 변수명 변경, 코드 포맷팅, 주석 정리 |
| **MEDIUM** | 일반 리팩토링 | sonnet | implementation-executor, refactor-advisor | 함수 분리, 중복 제거, 타입 개선 |
| **HIGH** | 복잡한 구조 변경 | opus | architect, code-reviewer | 아키텍처 재설계, 모듈 분리, 디자인 패턴 적용 |

**Agent별 모델 선택 원칙:**

| Agent | 권장 모델 | 이유 |
|-------|----------|------|
| **architect** | **opus** | 아키텍처 분석은 높은 사고력 필요 |
| **implementation-executor** | **sonnet** | 균형 잡힌 품질/속도 (haiku: 단순 작업) |
| **code-reviewer** | **opus** | 품질 검증은 세밀한 분석 필요 |
| **refactor-advisor** | **sonnet** | 계획 수립은 중간 복잡도 |
| **explore** | **haiku** | 단순 탐색은 빠른 응답 우선 |
| **analyst** | **sonnet** | 메트릭 분석은 중간 복잡도 |
| **document-writer** | **haiku/sonnet** | 간단한 문서는 haiku, 상세 문서는 sonnet |

### 병렬 실행 전략

#### 언제 병렬 실행하는가

| 조건 | 병렬 실행 | 순차 실행 |
|------|----------|----------|
| **독립성** | ✅ 서로 다른 파일/모듈 | ❌ 같은 파일 수정 |
| **의존성** | ✅ 의존성 없음 | ❌ 순차 의존성 있음 |
| **작업 유형** | ✅ 읽기 전용 (분석/탐색) | ❌ 결과가 다음 입력 |
| **컨텍스트** | ✅ 독립 컨텍스트 | ❌ 공유 컨텍스트 필요 |

#### 병렬 실행 체크리스트

실행 전 확인:

```text
- [ ] 이 작업들은 독립적인가? (서로 다른 파일/모듈)
- [ ] 순차 의존성이 없는가? (A 결과 → B 입력 아님)
- [ ] 같은 파일을 동시에 수정하지 않는가?
- [ ] 컨텍스트 분리가 가능한가? (각 에이전트가 독립적으로 작업)
- [ ] 적절한 모델을 선택했는가? (복잡도에 맞게)
```

**모든 항목 ✅ → 병렬 실행 / 하나라도 ❌ → 순차 실행**

### 실전 시나리오

#### 시나리오 1: 레거시 → 최신 프레임워크 전환

**배경:** 레거시 React 클래스 컴포넌트를 TanStack Start로 전환

```typescript
// 1단계: 분석 (병렬)
Task({
  subagent_type: "architect",
  model: "opus",
  prompt: "레거시 아키텍처 분석 및 TanStack Start 전환 전략"
})

Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "레거시 컴포넌트 목록 및 의존성 파악"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "전환 리스크 분석: 상태 관리, 라우팅, 데이터 페칭 차이점"
})

// 2단계: 점진적 전환 (병렬 - 독립 컴포넌트)
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Profile 페이지 전환: createFileRoute + Server Functions"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Settings 페이지 전환: createFileRoute + Server Functions"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Dashboard 페이지 전환: createFileRoute + Server Functions"
})

// 3단계: 검증 + 문서 (병렬)
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "전환된 코드 품질 검증: 라우팅, 상태, 데이터 페칭"
})

Task({
  subagent_type: "document-writer",
  model: "sonnet",
  prompt: "마이그레이션 가이드 작성: 패턴 비교, 주의사항, 롤백 절차"
})
```

#### 시나리오 2: 아키텍처 개선 (모놀리식 → 레이어드)

**배경:** 모든 로직이 혼재된 파일을 레이어드 아키텍처로 분리

```typescript
// 1단계: 현재 상태 분석 (병렬)
Task({
  subagent_type: "architect",
  model: "opus",
  prompt: "현재 아키텍처 문제점 분석: 순환 의존성, 결합도, 테스트 어려움"
})

Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "모듈 간 의존성 그래프 생성 및 순환 의존성 식별"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "복잡도 메트릭 분석: 파일 크기, 함수 길이, 중첩 깊이"
})

// 2단계: 레이어 분리 계획
Task({
  subagent_type: "refactor-advisor",
  model: "sonnet",
  prompt: "레이어드 아키텍처 전환 계획: Presentation → Service → Domain → Data"
})

// 3단계: 레이어별 구현 (순차적 - 의존성 있음)
// 먼저 Domain Layer (의존성 없음)
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Domain Layer 분리: 엔티티, Value Object, 비즈니스 로직"
})

// 이후 상위 레이어 (병렬 가능)
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Data Layer 구현: Repository, Prisma 연동"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Service Layer 구현: 비즈니스 로직 조율, 트랜잭션 관리"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Presentation Layer 구현: Server Functions, 입력 검증"
})

// 4단계: 다중 관점 검증 (병렬)
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "아키텍처 검증: 레이어 분리 원칙 준수, 의존성 방향"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "테스트 용이성 검증: 단위 테스트 가능성, Mock 필요성"
})
```

#### 시나리오 3: 성능 최적화 리팩토링

**배경:** 느린 렌더링, N+1 쿼리 문제 해결

```typescript
// 1단계: 성능 문제 분석 (병렬)
Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "성능 병목 지점 분석: React Profiler 데이터, DB 쿼리 로그"
})

Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "불필요한 리렌더 발생 컴포넌트 탐색"
})

Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "N+1 쿼리 발생 지점 탐색 (Prisma 쿼리 분석)"
})

// 2단계: 최적화 실행 (병렬 - 독립 영역)
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "React 최적화: useMemo, useCallback, React.memo 적용"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "Prisma 쿼리 최적화: include 정리, select 최소화, 배치 쿼리"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "TanStack Query 최적화: 캐싱 전략, staleTime/cacheTime 조정"
})

// 3단계: 성능 검증 (병렬)
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "성능 개선 검증: 렌더 횟수, 쿼리 실행 시간, 번들 크기"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "Before/After 메트릭 비교: 응답 시간, 메모리 사용량"
})

Task({
  subagent_type: "document-writer",
  model: "haiku",
  prompt: "성능 최적화 가이드 작성: 적용 패턴, 측정 방법"
})
```

#### 시나리오 4: 타입 안정성 개선 (any 제거)

**배경:** 프로젝트 전반에 any 타입 남용, 런타임 에러 빈발

```typescript
// 1단계: any 사용 분석 (병렬)
Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "any 타입 사용 지점 전수 조사 (ast-grep 활용)"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "any 사용 우선순위 분석: 영향 범위, 수정 난이도"
})

Task({
  subagent_type: "architect",
  model: "opus",
  prompt: "타입 설계 개선 방향: Generic, Utility Types, Type Guards"
})

// 2단계: 타입 정의 개선 (병렬 - 독립 모듈)
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "API 응답 타입 정의: Zod 스키마 → TypeScript 타입"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "이벤트 핸들러 타입 정의: React.MouseEvent, React.ChangeEvent"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "유틸리티 함수 타입 정의: Generic, Overload"
})

// 3단계: 타입 안정성 검증 (병렬)
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "타입 안정성 검토: unknown vs any, Type Guards 필요성"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "타입 에러 검증: tsc --noEmit, 런타임 에러 가능성"
})
```

#### 시나리오 5: 코드 중복 제거 (DRY 원칙)

**배경:** 여러 파일에 유사한 로직 반복, 유지보수 어려움

```typescript
// 1단계: 중복 패턴 분석 (병렬)
Task({
  subagent_type: "explore",
  model: "haiku",
  prompt: "중복 코드 패턴 탐색: 유사 함수, 중복 로직 (jscpd 등 활용)"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "중복률 분석 및 우선순위: 중복 라인 수, 파일 개수, 수정 빈도"
})

// 2단계: 공통 모듈 추출 계획
Task({
  subagent_type: "refactor-advisor",
  model: "sonnet",
  prompt: "공통 모듈 추출 전략: 유틸리티 vs 훅 vs 컴포넌트"
})

// 3단계: 모듈 추출 및 교체 (병렬 - 독립 영역)
Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "공통 유틸리티 함수 추출: src/lib/utils/ 구성"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "커스텀 훅 추출: src/hooks/ 구성"
})

Task({
  subagent_type: "implementation-executor",
  model: "sonnet",
  prompt: "공통 UI 컴포넌트 추출: src/components/ui/ 구성"
})

// 4단계: 기존 코드 교체 (병렬 - 독립 파일)
Task({
  subagent_type: "implementation-executor",
  model: "haiku",
  prompt: "components/ 내 중복 코드 → 공통 모듈 참조로 교체"
})

Task({
  subagent_type: "implementation-executor",
  model: "haiku",
  prompt: "routes/ 내 중복 코드 → 공통 모듈 참조로 교체"
})

Task({
  subagent_type: "implementation-executor",
  model: "haiku",
  prompt: "functions/ 내 중복 코드 → 공통 모듈 참조로 교체"
})

// 5단계: 검증 (병렬)
Task({
  subagent_type: "code-reviewer",
  model: "opus",
  prompt: "중복 제거 검증: 기존 기능 유지, 새로운 중복 발생 여부"
})

Task({
  subagent_type: "analyst",
  model: "sonnet",
  prompt: "Before/After 중복률 측정: 개선 효과 정량화"
})
```

### 병렬 실행 시 주의사항

```text
✅ 권장:
- 독립적인 모듈/파일 → 병렬 실행
- 분석 작업 (읽기 전용) → 병렬 실행
- 다중 관점 검증 → 병렬 실행
- 테스트 + 문서 작성 → 병렬 실행
- 레거시 + 신규 시스템 공존 → 병렬 실행

❌ 금지:
- 같은 파일 동시 수정 (충돌 발생)
- 순차 의존성 있는 작업 병렬화 (A → B → C)
- 공유 상태/컨텍스트 필요한 작업
- 결과가 다음 작업의 입력인 경우
```

### Model 선택 가이드

```typescript
// ✅ 적절한 모델 선택
Task({
  subagent_type: "implementation-executor",
  model: "haiku",        // 단순 작업: 변수명 변경, 주석 정리
  prompt: "변수명을 camelCase로 통일"
})

Task({
  subagent_type: "refactor-advisor",
  model: "sonnet",       // 일반 작업: 함수 분리 계획, 중복 제거
  prompt: "함수 복잡도 감소 계획 수립"
})

Task({
  subagent_type: "architect",
  model: "opus",         // 복잡한 작업: 아키텍처 재설계
  prompt: "레이어드 아키텍처 전환 전략 분석"
})

Task({
  subagent_type: "code-reviewer",
  model: "opus",         // 품질 검증: 세밀한 검토 필요
  prompt: "리팩토링 후 보안/성능/가독성 종합 검토"
})

// ❌ 잘못된 모델 선택
Task({
  subagent_type: "architect",
  model: "haiku",        // 복잡한 작업에 haiku 사용 금지
  prompt: "아키텍처 재설계..."
})

Task({
  subagent_type: "implementation-executor",
  model: "opus",         // 단순 작업에 opus 낭비
  prompt: "변수명 변경..."
})
```

### 병렬 실행 최적화 팁

| 팁 | 설명 | 예시 |
|----|------|------|
| **독립성 우선** | 의존성 없는 작업부터 병렬 실행 | 여러 모듈 동시 리팩토링 |
| **읽기 병렬화** | 분석/탐색 작업은 항상 병렬 | architect + explore + analyst |
| **쓰기 격리** | 파일 수정은 충돌 없도록 분리 | 각 모듈별로 다른 executor |
| **검증 병렬화** | 다중 관점 코드 리뷰 동시 실행 | 성능/보안/가독성/유지보수성 |
| **문서 병렬화** | 리팩토링과 문서 작성 동시 진행 | implementation + document-writer |
| **모델 적정화** | 복잡도에 맞는 모델 선택 | haiku(단순) / sonnet(일반) / opus(복잡) |

</parallel_agent_execution>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도 판단 (thought 1)

```
thought 1: 복잡도 판단
- 영향 범위: 파일 수, 함수 수
- 현재 문제: 복잡도, 중복, 명명, 구조
- 리스크: 기존 기능 영향, 테스트 커버리지
- 우선순위: High/Medium/Low
```

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 판단 기준 | 사고 패턴 |
|--------|----------|----------|------------|
| **간단** | 3 | 1-2 파일, 명확한 개선점 | 복잡도 판단 → 현재 분석 → 개선 방안 |
| **보통** | 5 | 3-5 파일, 구조 변경 | 복잡도 판단 → 현재 분석 → 문제점 → 옵션 비교 → 추천안 |
| **복잡** | 7+ | 다중 모듈, 점진적 변경 필요 | 복잡도 판단 → 심층 분석 → 우선순위 → 접근 방식 → 비교 → 단계별 계획 → 추천안 |

### 보통 복잡도 패턴 (5단계)

```
thought 1: 복잡도 판단 및 분석 범위 결정
thought 2: 현재 코드 분석 (복잡도, 중복, 구조)
thought 3: 가능한 개선 방법 열거 (4-5개)
thought 4: 주요 옵션 3개 선정 및 장단점 분석
thought 5: 최종 옵션 정리 및 추천안 도출
```

### 복잡한 경우 패턴 (7단계)

```
thought 1: 복잡도 판단
thought 2: 현재 코드 심층 분석 (메트릭, 패턴)
thought 3: 개선 우선순위 정리 (High/Medium/Low)
thought 4: 가능한 접근 방식 탐색
thought 5: 각 접근 방식 비교 분석
thought 6: 옵션 3개 선정 및 상세 장단점
thought 7: 단계별 계획 및 추천안
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

<refactoring_areas>

## 리팩토링 영역

### 6가지 개선 영역

| 영역 | 문제 | 개선 방향 |
|------|------|----------|
| **복잡도** | 긴 함수, 깊은 중첩 | 함수 분리, Early Return |
| **중복** | 동일/유사 코드 반복 | 공통 함수/모듈 추출 |
| **명명** | 모호한 변수/함수명 | 의도 명확한 이름 |
| **구조** | 파일/모듈 구조 불명확 | 관심사 분리, 계층화 |
| **패턴** | 안티패턴 사용 | 디자인 패턴 적용 |
| **타입** | any 남용, 타입 불안정 | 명시적 타입 정의 |

### 체크리스트

```text
✅ 함수 길이: 20줄 이하 목표
✅ 중첩 깊이: 3단계 이하 목표
✅ 파일 길이: 200-300줄 권장
✅ 순환 의존성: 제거
✅ 매직 넘버: 상수화
✅ 주석: 코드로 설명 불가능한 것만
```

</refactoring_areas>

---

<option_presentation>

## 옵션 제시 형식

### 옵션 3개 제시 (표준)

```markdown
## 분석 결과

### 현재 상태
- 문제점 1
- 문제점 2
- 개선 필요 영역

---

### 옵션 1: [옵션 이름] (추천)

**개선 방법:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/module/`
- 예상 작업량: 중간
- 리스크: 낮음
- 테스트 영향: 최소

---

### 옵션 2: [옵션 이름]

**개선 방법:**
...

| 장점 | 단점 |
|------|------|
| ... | ... |

**영향 범위:**
...

---

### 옵션 3: [옵션 이름]

**개선 방법:**
...

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션을 선택하시겠습니까? (1/2/3)
```

### 옵션 2개 제시 (개선점이 명확한 경우)

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

## 계획 문서 작성

### 문서 작성 질문

```
옵션 [N]을 선택하셨습니다.

리팩토링 계획 문서를 작성할까요?
- Y: .claude/plans/refactor-[이름].md 생성
- N: 바로 구현 시작

선택해주세요. (Y/N)
```

### 리팩토링 계획 문서 템플릿

**파일 위치:** `.claude/plans/refactor-[이름].md`

```markdown
# [모듈명] 리팩토링 계획

## 개요

**목표:** [무엇을 개선할 것인가]
**선택된 접근 방식:** [옵션 N]
**예상 영향 범위:** [파일/모듈 목록]

## 현재 상태

### 문제점

| 문제 | 영향 | 우선순위 |
|------|------|---------|
| 문제 1 | 설명 | High |
| 문제 2 | 설명 | Medium |

### 메트릭

- 복잡도: [현재 값]
- 중복률: [현재 값]
- 테스트 커버리지: [현재 값]

## 개선 단계

### 1단계: [단계 이름]

**목표:** [이 단계에서 달성할 것]

**작업:**
- [ ] 작업 1
- [ ] 작업 2

**변경 파일:**
- `src/file1.ts`
- `src/file2.ts`

**검증:**
- 테스트 통과
- 빌드 성공

### 2단계: [단계 이름]

**목표:** [이 단계에서 달성할 것]

**작업:**
- [ ] 작업 3

**변경 파일:**
- `src/file3.ts`

### 3단계: [단계 이름]
...

## 개선 후 기대 효과

| 메트릭 | Before | After | 개선율 |
|--------|--------|-------|--------|
| 복잡도 | X | Y | -Z% |
| 중복률 | X | Y | -Z% |
| 코드 라인 | X | Y | -Z% |

## 리스크 관리

### 리스크

| 리스크 | 영향도 | 완화 방안 |
|--------|--------|----------|
| 리스크 1 | High | 방안 1 |
| 리스크 2 | Medium | 방안 2 |

### 롤백 계획

문제 발생 시:
1. 단계별 커밋 활용
2. 이전 단계로 되돌리기
3. 테스트 재실행

## 검증 방법

### 기능 검증
- [ ] 기존 기능 동작 확인
- [ ] 회귀 테스트 통과
- [ ] 통합 테스트 통과

### 품질 검증
- [ ] 복잡도 감소 확인
- [ ] 중복 제거 확인
- [ ] 타입 안정성 확인

## 참조

- 관련 문서 링크
- 참고 패턴
```

</document_generation>

---

<validation>

## 검증 체크리스트

실행 전 확인:

```text
✅ ARGUMENT 확인 (없으면 질문)
✅ @refactor-advisor 사용 여부 판단
✅ Sequential Thinking 최소 3단계
✅ Task (Explore)로 코드 분석
✅ 옵션 최소 2개, 권장 3개
✅ 각 옵션에 장단점 명시
✅ 영향 범위 및 예상 작업량 제시
✅ 기능 유지 원칙 강조
```

절대 금지:

```text
❌ ARGUMENT 없이 분석 시작
❌ Edit 도구 사용 (코드 수정 금지)
❌ Sequential Thinking 3단계 미만
❌ 옵션 1개만 제시
❌ 코드 분석 없이 추측으로 옵션 제시
❌ 사용자 선택 없이 구현 시작
❌ 기능 변경 포함
❌ 장단점 없이 옵션만 나열
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: 복잡한 함수 분리

```bash
사용자: /refactor src/utils/auth.ts - 너무 복잡함

1. @refactor-advisor 고려:
   → 단일 파일, 복잡도 감소 → Agent 활용 추천

2. Sequential Thinking (5단계):
   thought 1: "단일 파일, 함수 복잡도 - 보통 복잡도"
   thought 2: "auth.ts 분석: 200줄, 5단계 중첩, 여러 책임"
   thought 3: "접근 방식: 함수 분리, 책임 분리, 타입 개선"
   thought 4: "옵션 3개 선정 및 장단점"
   thought 5: "점진적 분리 추천 - 단계적 검증 가능"

3. 옵션 제시:
   옵션 1: 점진적 함수 분리 (추천)
   - 장점: 안전, 단계별 검증
   - 단점: 시간 소요

   옵션 2: 모듈 분리
   - 장점: 명확한 구조
   - 단점: 큰 변경

   옵션 3: 타입 개선 우선
   - 장점: 빠른 개선
   - 단점: 근본 해결 아님

4. 사용자 선택: 1

5. 문서 작성: Y

6. .claude/plans/refactor-auth.md 생성
```

### 예시 2: 중복 코드 제거

```bash
사용자: /refactor 여러 파일에 중복 코드가 많음

1. @refactor-advisor 활용:
   → 다중 파일, 중복 분석 → Agent 활용 적합

2. Sequential Thinking (5단계):
   thought 1: "다중 파일 중복 - 보통 복잡도"
   thought 2: "중복 패턴 분석: 3가지 유형"
   thought 3: "접근: 공통 함수, 유틸리티, 훅 추출"
   thought 4: "옵션 비교: 점진적 vs 일괄"
   thought 5: "점진적 추출 추천"

3. Task 탐색:
   Task (Explore): "중복 코드 패턴 분석"
   → src/components/, src/hooks/ 파악

4. 옵션:
   옵션 1: 점진적 공통 함수 추출 (추천)
   옵션 2: 새 유틸리티 모듈 생성
   옵션 3: 커스텀 훅 추출

5. 선택 후 계획 문서 생성
```

### 예시 3: 구조 개선

```bash
사용자: /refactor 프로젝트 구조를 더 명확하게

1. @refactor-advisor 판단:
   → 구조 변경, 다중 모듈 → 직접 처리 (Agent 미사용)

2. Sequential Thinking (7단계):
   thought 1: "구조 개선 - 복잡도 높음, 다중 모듈"
   thought 2: "현재 구조 분석: src/ 내 혼재"
   thought 3: "요구사항: 관심사 분리, 계층 명확화"
   thought 4: "접근: 모듈화, 디렉토리 재구성, 경로 정리"
   thought 5: "각 접근 비교: 영향 범위, 리스크"
   thought 6: "옵션 3개 선정 및 상세 분석"
   thought 7: "점진적 재구성 추천 - 단계적 이동"

3. Task 탐색 (병렬):
   Task (Explore): "현재 디렉토리 구조 분석"
   Task (Explore): "모듈 간 의존성 파악"
   Task (Explore): "import 경로 패턴 분석"

4. 옵션:
   옵션 1: 점진적 모듈 분리 (추천)
   옵션 2: 레이어 기반 재구성
   옵션 3: 기능별 도메인 분리

5. 계획 문서 작성 (필수)
```

</examples>
