# Agent Delegation Patterns (에이전트 위임 패턴)

**목적**: 스킬에서 공통으로 사용하는 에이전트 위임/병렬 실행 패턴 통합 참조

---

## Recommended Agents

### Tier 1: 계획 및 분석

| Agent | 기본 모델 | 복잡 시 | 병렬 | 역할 |
|-------|----------|--------|------|------|
| **planner** | opus | opus | ❌ | 계획 수립, 검증 승인 |
| **analyst** | sonnet | opus | ✅ | 요구사항 분석, 가정 검증, 엣지 케이스 |
| **architect** | sonnet | opus | ✅ | 아키텍처 분석/설계 (READ-ONLY) |
| **critic** | opus | opus | ❌ | 계획 리뷰, OKAY/REJECT 판정 |

### Tier 2: 실행 및 구현

| Agent | 기본 모델 | 복잡 시 | 병렬 | 역할 |
|-------|----------|--------|------|------|
| **implementation-executor** | sonnet | opus | ✅ | 기능 구현, 버그 수정 |
| **designer** | sonnet | opus | ✅ | UI/UX 구현 (Tailwind CSS) |
| **lint-fixer** | sonnet | sonnet | ✅ | tsc/eslint 오류 수정 |

### Tier 3: 검증 및 지원

| Agent | 기본 모델 | 복잡 시 | 병렬 | 역할 |
|-------|----------|--------|------|------|
| **code-reviewer** | opus | opus | ✅ | 코드 품질/보안/성능 검토 (READ-ONLY) |
| **deployment-validator** | sonnet | sonnet | ❌ | typecheck/lint/build 검증 |
| **refactor-advisor** | sonnet | opus | ✅ | 리팩토링 조언 (READ-ONLY) |

### Tier 4: 유틸리티

| Agent | 기본 모델 | 복잡 시 | 병렬 | 역할 |
|-------|----------|--------|------|------|
| **explore** | haiku | sonnet | ✅ | 코드베이스 탐색, 구조 파악 |
| **document-writer** | haiku | sonnet | ✅ | 기술 문서 작성 |
| **git-operator** | haiku | sonnet | ❌ | Git 커밋/푸시 (순차 필수) |
| **researcher** | sonnet | sonnet | ✅ | 외부 문서/API 조사 |
| **scientist** | sonnet | sonnet | ✅ | 데이터 분석, 통계 연구 |
| **dependency-manager** | sonnet | sonnet | ❌ | 의존성 분석/업데이트 (순차) |
| **ko-to-en-translator** | haiku | sonnet | ✅ | 한글→영어 번역 |
| **qa-tester** | sonnet | sonnet | ✅ | CLI/서비스 테스트 |
| **security-reviewer** | opus | opus | ✅ | 보안 취약점 검토 |
| **vision** | sonnet | sonnet | ✅ | 이미지/PDF 분석 |

---

## Agent Selection Decision Tree

### 작업 유형별 에이전트 매핑

```
작업 유형                     → 적합한 에이전트 (기본 모델)
───────────────────────────────────────────────────────
코드베이스 탐색              → explore (haiku)
기능 구현 (CRUD/로직)        → implementation-executor (sonnet)
UI/UX 구현                   → designer (sonnet)
보안/성능 검토               → code-reviewer (opus)
계획 수립/검증               → planner (opus)
문서 작성 (단순)             → document-writer (haiku)
문서 작성 (복잡)             → document-writer (sonnet)
아키텍처 분석/설계           → architect (sonnet/opus)
요구사항 분석                → analyst (sonnet)
외부 조사                    → researcher (sonnet)
Git 작업                     → git-operator (haiku)
린트/타입 오류 수정          → lint-fixer (sonnet)
```

### 복잡도별 모델 선택

| 복잡도 | 파일 수 | 권장 모델 | 예시 |
|--------|---------|-----------|------|
| 낮음 | 1-3 | haiku | 단일 파일 탐색, 단순 문서 |
| 중간 | 4-10 | sonnet | 일반 기능 구현, UI 개발 |
| 높음 | 10+ | opus | 아키텍처 설계, 계획 수립 |
| 매우 높음 | - | opus | 보안 검토, 복잡한 리팩토링 |

---

## 위임 결정 기준

### 에이전트에 위임하는 조건

다음 중 **하나라도** 해당 시 위임:

| 조건 | 예시 |
|------|------|
| 독립적인 작업 | 백엔드 API + 프론트엔드 UI 동시 |
| 새 컨텍스트 필요 | 대규모 코드베이스 탐색 |
| 전문 지식 필요 | 보안 검토, 아키텍처 설계 |
| 10분 이상 예상 | 복잡한 기능 구현 |

### 직접 처리하는 조건

| 조건 | 예시 |
|------|------|
| 간단한 파일 읽기/수정 | 1-2줄 Edit, 단일 Read |
| 즉각적인 명령어 | `git status`, `ls` |
| 순차 의존성 강한 작업 | A 결과가 B 입력 |

---

## Context Passing Standards

### 에이전트 호출 시 전달 정보

모든 에이전트 호출 시 다음 4가지 요소를 명확히 전달:

| 요소 | 설명 | 예시 |
|------|------|------|
| **목표 (What)** | 수행할 작업의 명확한 목적 | "인증 구조 분석", "User CRUD API 구현" |
| **범위 (Scope)** | 대상 디렉토리/파일/도메인 | `src/auth/`, `src/middleware/`, 최대 5개 파일 |
| **출력 (Output)** | 기대하는 결과 형식 | "핵심 파일 3개 + 500자 요약", "구현 코드 + 테스트" |
| **제약 (Constraints)** | 금지 사항, 제한 조건 | "구현 코드 수정 금지", "READ-ONLY", "기존 API 유지" |

### 표준 프롬프트 템플릿

```typescript
// ✅ 명확한 컨텍스트 전달
Task(subagent_type="explore",
     model="haiku",
     prompt=`
목표: 인증 구조 분석
범위: src/auth/, src/middleware/ (최대 10개 파일)
출력: 핵심 파일 3개 + 아키텍처 요약 500자
제약: 구현 코드 수정 금지, READ-ONLY
`)

// ✅ 구현 에이전트 호출
Task(subagent_type="implementation-executor",
     model="sonnet",
     prompt=`
목표: User CRUD API 구현
범위: src/api/users/, 신규 파일 생성 가능
출력: createUser, getUser, updateUser, deleteUser 함수 + Zod 스키마
제약: 기존 Prisma 스키마 유지, 트랜잭션 필수
`)

// ✅ 검토 에이전트 호출
Task(subagent_type="code-reviewer",
     model="opus",
     prompt=`
목표: 보안 검토
범위: src/api/users/mutations.ts (단일 파일)
출력: 취약점 목록 + 심각도 (HIGH/MEDIUM/LOW) + 수정 권장사항
제약: READ-ONLY, 구현 변경 금지
`)
```

### 잘못된 프롬프트 예시

```typescript
// ❌ 모호한 지시
Task(subagent_type="explore",
     prompt="인증 관련 코드 좀 봐줘")

// ❌ 범위 없음
Task(subagent_type="implementation-executor",
     prompt="User API 만들어줘")

// ❌ 출력 형식 없음
Task(subagent_type="analyst",
     prompt="이 코드 분석해줘")
```

### 컨텍스트 최적화 참조

상세한 컨텍스트 압축 전략:
- `@../context-optimization/sub-agent-distribution.md` (하위 에이전트 컨텍스트 분산)
- 압축된 결과 형식, 토큰 효율화 패턴

---

## 병렬 실행 패턴

### 패턴 1: 탐색 + 분석 병렬

여러 영역을 동시에 조사할 때:

```typescript
// 프론트엔드 + 백엔드 + DB 동시 탐색
Task(subagent_type="explore", model="haiku",
     prompt="프론트엔드 인증 UI 및 상태 관리 구조 분석")
Task(subagent_type="explore", model="haiku",
     prompt="백엔드 인증 API 엔드포인트 및 미들웨어 분석")
Task(subagent_type="architect", model="sonnet",
     prompt="현재 인증 아키텍처 평가 및 개선점 도출")
```

### 패턴 2: 다중 옵션 병렬 분석

여러 옵션을 동시에 평가:

```typescript
// 옵션 A, B, C를 각각 다른 analyst에게
Task(subagent_type="analyst", model="sonnet",
     prompt="옵션 A (Zustand) 분석: 장단점, 리스크")
Task(subagent_type="analyst", model="sonnet",
     prompt="옵션 B (Jotai) 분석: 장단점, 리스크")
Task(subagent_type="analyst", model="sonnet",
     prompt="옵션 C (Context API) 분석: 장단점, 리스크")
// → 결과 비교 후 최적 옵션 추천
```

### 패턴 3: 풀스택 병렬 구현

백엔드 + 프론트엔드 + 문서를 동시에:

```typescript
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User API CRUD 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="User Profile UI 구현")
Task(subagent_type="document-writer", model="haiku",
     prompt="User API 문서 작성")
```

### 패턴 4: 다중 관점 검증

보안/성능/접근성을 동시에 검토:

```typescript
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 검토: XSS, SQL Injection, CSRF")
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토: N+1 쿼리, 불필요한 리렌더")
Task(subagent_type="code-reviewer", model="opus",
     prompt="접근성 검토: ARIA, 키보드 네비게이션")
```

### 패턴 5: 문서 병렬 생성

여러 문서를 동시에 작성:

```typescript
Task(subagent_type="document-writer", model="haiku",
     prompt="OVERVIEW.md 작성")
Task(subagent_type="document-writer", model="sonnet",
     prompt="IMPLEMENTATION.md 작성")  // 복잡한 문서는 sonnet
Task(subagent_type="document-writer", model="haiku",
     prompt="RISKS.md 작성")
Task(subagent_type="document-writer", model="haiku",
     prompt="REFERENCES.md 작성")
```

### 패턴 6: 기술 조사 병렬

외부 조사와 내부 분석을 동시에:

```typescript
Task(subagent_type="researcher", model="sonnet",
     prompt="WebSocket vs SSE 공식 문서 및 성능 비교 2026")
Task(subagent_type="analyst", model="sonnet",
     prompt="현재 프로젝트에서 실시간 통신 요구사항 분석")
Task(subagent_type="explore", model="haiku",
     prompt="기존 통신 관련 코드 탐색")
```

### 패턴 7: 리스크 평가 병렬

기술/일정/비용 리스크를 동시에 평가:

```typescript
Task(subagent_type="analyst", model="sonnet",
     prompt="기술적 리스크: 호환성, 데이터 무결성")
Task(subagent_type="planner", model="opus",
     prompt="일정 리스크: 병목 구간, 완충 시간")
Task(subagent_type="analyst", model="sonnet",
     prompt="비용 리스크: 인프라 전환, ROI")
```

### 패턴 8: 계획 후 검증

계획 완료 후 critic으로 검증:

```typescript
// 계획 수립
Task(subagent_type="planner", model="opus",
     prompt="인증 시스템 재설계 계획 수립")
// 계획 완료 후 → 검증
Task(subagent_type="critic", model="opus",
     prompt=".claude/plan/00.인증_시스템/IMPLEMENTATION.md 검증")
```

---

## 모델 선택 가이드

```
작업 시작
    ↓
파일 1-3개, 단순 CRUD? → haiku (explore, document-writer, git-operator)
파일 4-10개, 일반 로직? → sonnet (implementation-executor, designer, analyst)
파일 10개+, 아키텍처? → opus (planner, architect, code-reviewer)
    ↓
보안/성능 중요? → opus 승격
비용 절감 필요? → haiku 강등 (단, 품질 확인)
```

---

## 병렬 vs 순차 결정

| 조건 | 실행 방식 |
|------|----------|
| 독립적인 작업 | ✅ 병렬 |
| 다른 파일/영역 | ✅ 병렬 |
| 다른 도메인 (백엔드/프론트) | ✅ 병렬 |
| READ-ONLY 에이전트 여러 개 | ✅ 병렬 (안전) |
| 순차 의존성 (A→B) | ❌ 순차 |
| 같은 파일 수정 | ❌ 순차 |
| Git 작업 | ❌ 순차 |

---

## Failure Recovery

### 에이전트 실패 시 복구 전략

| 실패 유형 | 증상 | 복구 전략 | 예시 |
|----------|------|----------|------|
| **타임아웃** | 작업 시간 초과 | 작업 범위 축소 후 재시도 | 10개 파일 → 3개 파일로 분할 |
| **잘못된 결과** | 요구사항 미충족, 오류 코드 | 다른 모델로 재시도 | haiku → sonnet → opus |
| **컨텍스트 초과** | 토큰 한계 도달 | 작업 분할 후 순차 실행 | 전체 탐색 → 도메인별 순차 탐색 |
| **병렬 충돌** | 같은 파일 동시 수정 | 순차 실행으로 전환 | 병렬 3개 → 순차 3번 |
| **의존성 오류** | A 작업 실패로 B 블록 | A 재시도 또는 수동 처리 | planner 실패 → 직접 계획 수립 |
| **모델 오버로드** | 너무 많은 병렬 작업 | 배치 크기 축소 (5개 → 3개) | 10개 병렬 → 3+3+4 순차 배치 |

### 복구 흐름도

```
에이전트 실패 감지
    ↓
실패 유형 분석
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│ 타임아웃/초과   │ 잘못된 결과     │ 충돌            │
│ → 범위 축소     │ → 모델 승격     │ → 순차 전환     │
└─────────────────┴─────────────────┴─────────────────┘
    ↓
재시도 (최대 2회)
    ↓
실패 시 → 직접 처리 또는 사용자에게 보고
```

### 재시도 전략

```typescript
// 1차 시도 (haiku)
Task(subagent_type="explore", model="haiku",
     prompt="대규모 코드베이스 탐색")
// 실패 시 → 2차 시도 (sonnet + 범위 축소)
Task(subagent_type="explore", model="sonnet",
     prompt="src/core/ 디렉토리만 탐색 (최대 5개 파일)")
// 실패 시 → 직접 처리
Read("src/core/index.ts")
Grep("export", glob="src/core/**/*.ts")
```

### 품질 검증

에이전트 결과를 받은 후 즉시 검증:

| 항목 | 검증 방법 | 실패 시 조치 |
|------|----------|-------------|
| **파일 존재** | Read로 확인 | 재생성 요청 |
| **문법 오류** | tsc/eslint 실행 | lint-fixer 호출 |
| **요구사항** | 체크리스트 대조 | 구체적 피드백 + 재시도 |
| **충돌** | Git status 확인 | 수동 병합 |

---

## 체크리스트

작업 시작 전 확인:

```
[ ] 이 작업은 독립적인가? → 병렬 에이전트 고려
[ ] 새 컨텍스트 필요한가? → 에이전트 위임
[ ] 전문 지식 필요한가? → 도메인 에이전트 선택
[ ] 적절한 모델 선택했는가? (haiku/sonnet/opus)
[ ] 병렬 실행 수 3-5개 범위인가?
[ ] 결과 통합 계획 있는가?
[ ] 컨텍스트 전달 (목표/범위/출력/제약) 명확한가?
[ ] 실패 시 복구 전략 준비되었는가?
```
