# Agent Coordination Patterns

**목적**: 여러 에이전트 간 효율적인 협업 전략

## 에이전트 역할 분류

### Tier 1: 계획 및 분석
| Agent | 모델 | 역할 | READ-ONLY |
|-------|------|------|-----------|
| planner | opus | 아키텍처 설계, 계획 검증 | ❌ |
| analyst | sonnet | 요구사항 분석, 가정 검증 | ✅ |
| architect | sonnet/opus | 아키텍처 분석, 디버깅 조언 | ✅ |

### Tier 2: 실행 및 구현
| Agent | 모델 | 역할 | READ-ONLY |
|-------|------|------|-----------|
| implementation-executor | sonnet | 기능 구현, 버그 수정 | ❌ |
| designer | sonnet/opus | UI/UX 구현 | ❌ |
| lint-fixer | sonnet | tsc/eslint 오류 수정 | ❌ |

### Tier 3: 검증 및 지원
| Agent | 모델 | 역할 | READ-ONLY |
|-------|------|------|-----------|
| code-reviewer | opus | 코드 품질/보안 검토 | ✅ |
| deployment-validator | sonnet | typecheck/lint/build 검증 | ❌ |
| refactor-advisor | sonnet | 리팩토링 조언 | ✅ |

### Tier 4: 유틸리티
| Agent | 모델 | 역할 | READ-ONLY |
|-------|------|------|-----------|
| explore | haiku | 코드베이스 탐색 | ✅ |
| document-writer | haiku/sonnet | 기술 문서 작성 | ❌ |
| git-operator | haiku | Git 커밋/푸시 | ❌ |
| dependency-manager | sonnet | 의존성 분석/업데이트 | ❌ |
| ko-to-en-translator | haiku | 한글→영어 번역 | ❌ |

## 협업 패턴

### 패턴 1: 계획 → 실행 → 검증

```typescript
// 1. 분석 및 계획 (병렬)
Task(subagent_type="analyst", model="sonnet",
     prompt="요구사항 분석 및 가정 검증")
Task(subagent_type="architect", model="opus",
     prompt="아키텍처 분석 및 설계 조언")

// 2. 구현 (병렬)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="백엔드 API 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="프론트엔드 UI 구현")

// 3. 검증 (병렬)
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 및 성능 검토")
Task(subagent_type="deployment-validator", model="sonnet",
     prompt="빌드 및 타입 검증")
```

### 패턴 2: 탐색 → 분석 → 구현

```typescript
// 1. 탐색 (병렬, haiku)
Task(subagent_type="explore", model="haiku",
     prompt="인증 관련 파일 탐색")
Task(subagent_type="explore", model="haiku",
     prompt="DB 스키마 분석")

// 2. 분석 (순차, sonnet/opus)
Task(subagent_type="analyst", model="sonnet",
     prompt="현재 구조 분석 및 개선 방향")

// 3. 구현 (병렬, sonnet)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="개선 사항 적용")
```

### 패턴 3: 동시 다발 작업 (풀스택)

```typescript
// 백엔드 + 프론트엔드 + 문서 동시 진행
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User API CRUD 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="User Profile UI 구현")
Task(subagent_type="document-writer", model="haiku",
     prompt="User API 문서 작성")
```

### 패턴 4: 다중 검토 (여러 관점)

```typescript
// 보안 + 성능 + 접근성 동시 검토
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 취약점 검토: XSS, SQL Injection, CSRF")
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토: N+1 쿼리, 불필요한 리렌더")
Task(subagent_type="code-reviewer", model="opus",
     prompt="접근성 검토: ARIA, 키보드 네비게이션")
```

## 병렬 vs 순차 결정

| 조건 | 실행 방식 | 이유 |
|------|----------|------|
| 독립적인 작업 | ✅ 병렬 | 시간 단축 |
| 다른 파일/영역 | ✅ 병렬 | 충돌 없음 |
| 다른 도메인 (백엔드/프론트) | ✅ 병렬 | 완전히 분리 |
| 순차 의존성 | ❌ 순차 | 이전 결과 필요 |
| 같은 파일 수정 | ❌ 순차 | 충돌 방지 |
| Git 작업 | ❌ 순차 | 커밋 순서 중요 |

## 에이전트 위임 원칙

### 언제 위임하는가

- [ ] 작업이 독립적인가?
- [ ] 새 컨텍스트가 필요한가?
- [ ] 전문 지식이 필요한가?
- [ ] 10분 이상 소요될까?

**하나라도 Yes → 에이전트 위임**

### 위임 금지 케이스

- 간단한 파일 읽기 (직접 Read)
- 1-2줄 수정 (직접 Edit)
- 즉각적인 Bash 명령어

## READ-ONLY 에이전트 활용

**READ-ONLY 에이전트**: analyst, architect, code-reviewer, refactor-advisor, explore

**특징:**
- 파일 수정 불가
- 조언 및 분석만 제공
- 병렬 실행 안전 (충돌 없음)

**활용 패턴:**
```typescript
// 여러 READ-ONLY 에이전트 병렬 실행 (안전)
Task(subagent_type="analyst", model="sonnet", ...)
Task(subagent_type="architect", model="opus", ...)
Task(subagent_type="code-reviewer", model="opus", ...)
Task(subagent_type="explore", model="haiku", ...)
```

## 실전 시나리오

### 시나리오 1: 새 기능 구현

```
Phase 1: 분석 (병렬)
  ├─ analyst: 요구사항 명확화
  ├─ architect: 아키텍처 분석
  └─ explore: 관련 코드 탐색

Phase 2: 구현 (병렬)
  ├─ implementation-executor: 백엔드
  ├─ designer: 프론트엔드
  └─ document-writer: 문서

Phase 3: 검증 (병렬)
  ├─ code-reviewer: 품질 검토
  └─ deployment-validator: 빌드 검증
```

### 시나리오 2: 버그 수정

```
Phase 1: 조사 (병렬)
  ├─ explore: 버그 관련 코드 탐색
  └─ architect: 원인 분석

Phase 2: 수정 (순차)
  └─ implementation-executor: 버그 수정

Phase 3: 검증 (순차)
  └─ deployment-validator: 테스트 실행
```

### 시나리오 3: 리팩토링

```
Phase 1: 분석 (병렬)
  ├─ refactor-advisor: 개선 방향 제시
  ├─ code-reviewer: 현재 문제점 식별
  └─ explore: 영향 범위 파악

Phase 2: 실행 (순차)
  └─ implementation-executor: 리팩토링

Phase 3: 검증 (병렬)
  ├─ code-reviewer: 품질 향상 확인
  └─ deployment-validator: 회귀 테스트
```

## 체크리스트

작업 시작 전:

- [ ] 어떤 에이전트가 필요한가?
- [ ] 병렬 실행 가능한가?
- [ ] 적절한 모델 선택했는가?
- [ ] READ-ONLY 제약 확인했는가?

**에이전트 협업으로 시간 단축 + 품질 향상**
