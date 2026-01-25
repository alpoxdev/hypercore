# Agent Patterns

에이전트 활용 및 협업 패턴 - 효율적인 멀티 에이전트 시스템 운영

---

## 파일 구조

| 파일 | 설명 | 토큰 효율 |
|------|------|---------|
| [parallel-execution.md](./parallel-execution.md) | 병렬 실행 패턴 - 독립 작업 동시 처리 | 빠른 결정 |
| [read-parallelization.md](./read-parallelization.md) | Read 도구 병렬화 - 파일 읽기 최적화 | 67-90% 단축 |
| [model-routing.md](./model-routing.md) | 모델 라우팅 - haiku/sonnet/opus 선택 | 40-60% 절감 |
| [agent-coordination.md](./agent-coordination.md) | 에이전트 협업 - 역할 분류 및 패턴 | 체계화된 구조 |

---

## Quick Reference

### 병렬화 기본 원칙

```text
독립 작업 → 병렬 (단일 메시지)
의존성 있음 → 순차 (대기 필요)
```

### 모델 선택 (복잡도)

| 복잡도 | 모델 | 용도 | 예시 |
|--------|------|------|------|
| **Low** | haiku | 탐색, 문서, Git | Explore, DocumentWriter |
| **Med** | sonnet | 구현, 수정, 테스트 | ImplementationExecutor |
| **High** | opus | 설계, 리뷰, 검증 | Planner, CodeReviewer |

### 에이전트 Tier

```
Tier 1 [계획/분석] → Tier 2 [실행] → Tier 3 [검증]
Tier 4 [유틸리티 - 모든 단계에서 사용 가능]
```

---

## 사용 패턴

### 패턴 1: 분석 → 실행 → 검증 (3단계)

```typescript
// Step 1: 분석 [병렬]
Task(analyst, sonnet, "요구사항 분석")
Task(architect, opus, "아키텍처 설계")
Task(explore, haiku, "코드 탐색")

// Step 2: 실행 [병렬]
Task(implementation-executor, sonnet, "기능 구현")
Task(designer, sonnet, "UI 구현")
Task(document-writer, haiku, "문서 작성")

// Step 3: 검증 [병렬]
Task(code-reviewer, opus, "품질 검토")
Task(deployment-validator, sonnet, "빌드 검증")
```

### 패턴 2: 탐색 → 분석 → 구현 (병렬 최적화)

```typescript
// [병렬] Haiku 탐색 (저비용)
Task(explore, haiku, "인증 구조 분석")
Task(explore, haiku, "DB 스키마 분석")

// [순차] Sonnet/Opus 분석 (결과 필요)
Task(analyst, sonnet, "현재 상태 분석")

// [병렬] 구현 (독립)
Task(implementation-executor, sonnet, "개선 적용")
```

### 패턴 3: 동시 다발 작업 (Full-Stack)

```typescript
// 백엔드 + 프론트엔드 + 문서 [병렬]
Task(implementation-executor, sonnet, "API 구현")
Task(designer, sonnet, "UI 구현")
Task(document-writer, haiku, "API 문서")
```

---

## 체크리스트

### 병렬 실행 전 확인

- [ ] 독립적인 작업인가? (A의 결과가 B의 입력이 아닌가)
- [ ] 같은 파일 수정하지 않는가?
- [ ] 순서가 중요하지 않은가?
- [ ] 각 작업의 컨텍스트 분리 가능한가?

### 모델 선택 전 확인

- [ ] 파일 몇 개 다루는가? (1-3:haiku, 4-10:sonnet, 10+:opus)
- [ ] 로직 복잡도는? (CRUD:haiku, 일반:sonnet, 아키텍처:opus)
- [ ] 보안/성능 중요한가? → opus
- [ ] 비용 효율은? (haiku 먼저 시도)

### 에이전트 위임 기준

위임 필요한 경우:
- [ ] 작업이 독립적인가?
- [ ] 새 컨텍스트 필요한가?
- [ ] 전문 지식 필요한가?
- [ ] 10분 이상 소요될 예상인가?

위임 불필요:
- ❌ 간단한 파일 읽기 (직접 Read)
- ❌ 1-2줄 수정 (직접 Edit)
- ❌ 단순 Bash 명령

---

## 성능 개선 수치

### Read 병렬화

| 파일 수 | 순차 | 병렬 | 개선율 |
|--------|------|------|--------|
| 3개 | 6초 | 2초 | 67% |
| 5개 | 10초 | 2초 | 80% |
| 10개 | 20초 | 2초 | 90% |

### 에이전트 협업

| 시나리오 | 순차 | 병렬 | 개선 |
|---------|------|------|------|
| 3개 에이전트 | 3T | T | 66% |
| 5개 에이전트 | 5T | T | 80% |

### 비용 최적화

**기본 전략:** Haiku(탐색) → Sonnet(구현) → Opus(검증)

**예상 절감:** 40-60%

---

## 에이전트 역할 매트릭스

| Agent | 모델 | 주 역할 | READ-ONLY | 병렬 가능 |
|-------|------|--------|-----------|---------|
| **planner** | opus | 계획 검증 | ❌ | ⚠️ |
| **analyst** | sonnet | 요구사항 분석 | ✅ | ✅ |
| **architect** | sonnet/opus | 아키텍처 분석 | ✅ | ✅ |
| **implementation-executor** | sonnet | 기능 구현 | ❌ | ✅* |
| **designer** | sonnet/opus | UI 구현 | ❌ | ✅* |
| **code-reviewer** | opus | 품질 검토 | ✅ | ✅ |
| **deployment-validator** | sonnet | 빌드 검증 | ❌ | ⚠️ |
| **explore** | haiku | 코드 탐색 | ✅ | ✅ |
| **document-writer** | haiku/sonnet | 문서 작성 | ❌ | ✅* |
| **git-operator** | haiku | Git 작업 | ❌ | ❌ |
| **lint-fixer** | sonnet | 오류 수정 | ❌ | ⚠️ |
| **refactor-advisor** | sonnet | 리팩토링 조언 | ✅ | ✅ |
| **dependency-manager** | sonnet | 의존성 관리 | ❌ | ⚠️ |
| **ko-to-en-translator** | haiku | 번역 | ❌ | ✅ |

**범례:** ✅ 완전 가능, ⚠️ 제약 있음, ❌ 불가능
- *: 다른 파일/도메인 다룰 때만 병렬

---

## 의존성 흐름

### 데이터 의존성

```
[탐색] (explore, haiku)
   ↓
[분석] (analyst/architect, sonnet/opus)
   ↓
[구현] (implementation-executor/designer, sonnet) [병렬]
   ↓
[검증] (code-reviewer/deployment-validator, opus/sonnet) [병렬]
   ↓
[배포] (git-operator, haiku)
```

### 파일 의존성

- **같은 파일** → 순차 필수
- **다른 파일** → 병렬 안전
- **다른 모듈** → 병렬 권장
- **다른 도메인** (백/프론) → 병렬 필수

---

## 문제 해결

| 상황 | 원인 | 해결책 |
|------|------|--------|
| 병렬 작업 충돌 | 같은 파일 수정 | 순차 실행으로 변경 |
| 느린 성능 | 순차 읽기 | 병렬 읽기로 변경 |
| 높은 비용 | Opus 과다 사용 | Haiku/Sonnet으로 변경 |
| 낮은 품질 | Haiku로 복잡 작업 | Sonnet/Opus 상향 |
| 무한 대기 | 의존성 누락 | 데이터 흐름 재검토 |

---

## 통합 사용법

### 실전 예시: User CRUD API

```typescript
// Phase 1: 분석 [병렬, 5분]
Task(analyst, sonnet, "User 요구사항 분석")
Task(explore, haiku, "현재 User 관련 코드 탐색")
// → 요구사항 명확화, 구현 전략 수립

// Phase 2: 구현 [병렬, 15분]
Task(implementation-executor, sonnet, "User API CRUD 구현")
Task(designer, sonnet, "User 관리 페이지 UI 구현")
Task(document-writer, haiku, "API 문서 작성")
// → 백엔드 + 프론트엔드 + 문서 동시 완성

// Phase 3: 검증 [병렬, 10분]
Task(code-reviewer, opus, "보안/성능 검토")
Task(deployment-validator, sonnet, "빌드/타입 검증")
// → 품질 확인

// Phase 4: 배포 [순차, 2분]
Task(git-operator, haiku, "변경사항 커밋")
// → 완료
```

**총 소요 시간:** 약 32분 (순차면 60+분)

---

## References

### 추가 학습

- @.claude/instructions/agent-patterns/parallel-execution.md - 병렬화 상세 규칙
- @.claude/instructions/agent-patterns/read-parallelization.md - Read 도구 최적화
- @.claude/instructions/agent-patterns/model-routing.md - 모델 선택 가이드
- @.claude/instructions/agent-patterns/agent-coordination.md - 에이전트 역할 정의

### 관련 지침

- @.claude/instructions/workflow-patterns/
- @.claude/instructions/context-engineering/
- @.claude/instructions/validation/

---

## 요약

**3가지 핵심 원칙:**

1. **병렬화**: 독립 작업은 단일 메시지에서 동시 호출
2. **모델 선택**: 복잡도별 최적 모델 (haiku→sonnet→opus)
3. **협업 구조**: Tier 기반 역할 분류 (계획→실행→검증)

**결과:**
- 성능: 67-90% 시간 단축
- 비용: 40-60% 절감
- 품질: 각 전문 에이전트 활용
