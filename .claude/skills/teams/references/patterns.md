# Team Patterns Reference

> 4가지 팀 패턴 상세 정의

---

<pattern_selection>

## 패턴 선택 매트릭스

| 키워드 | 패턴 | 팀원 수 | 실행 방식 |
|--------|------|---------|----------|
| 리뷰, 검토, PR, 감사, 코드리뷰 | 병렬-리뷰 | 3명 | 병렬 |
| 구현, 개발, 기능, 추가, 만들어 | 파이프라인 | 4명 | 순차 |
| API, 엔드포인트, 풀스택, 프론트백 | 크로스-레이어 | 3명 | 병렬 |
| 버그, 원인, 분석, 조사, 디버깅 | 가설-검증 | 4명 | 병렬 |

### 복잡도별 팀 규모

| 복잡도 | 기본 팀원 | 추가 옵션 |
|--------|----------|----------|
| LOW | 2명 | - |
| MEDIUM | 3-4명 | document-writer |
| HIGH | 4-5명 | architect, security |

</pattern_selection>

---

<pattern_parallel_review>

## 패턴 1: 병렬-리뷰

```
변경사항
    │
    ├──► security-reviewer (opus)    → 보안 취약점
    ├──► code-reviewer (sonnet)      → 코드 품질
    └──► qa-tester (sonnet)          → 테스트 커버리지
              │
              ▼
         Lead (종합 판정)
```

### 팀 구성

| 역할 | 에이전트 | 모델 | 포커스 |
|------|---------|------|--------|
| 보안 | security-reviewer | opus | OWASP, 인증, 입력검증 |
| 품질 | code-reviewer | sonnet | 가독성, 패턴, 유지보수 |
| 테스트 | qa-tester | sonnet | 커버리지, 엣지케이스 |

### 실행 코드

```typescript
TeamCreate({
  team_name: "team-review-" + Date.now(),
  description: "병렬 코드 리뷰"
})

// 병렬 스폰
Task({
  subagent_type: "security-reviewer",
  team_name: teamName,
  name: "security",
  model: "opus",
  prompt: `보안 관점 코드 리뷰:
    - OWASP Top 10 취약점
    - 인증/인가 로직
    - 입력 검증 및 출력 인코딩
    - 민감 정보 노출

    대상: ${targetFiles}`
})

Task({
  subagent_type: "code-reviewer",
  team_name: teamName,
  name: "quality",
  model: "sonnet",
  prompt: `코드 품질 리뷰:
    - 가독성 및 명명 규칙
    - 패턴 준수 여부
    - 중복 코드
    - 복잡도

    대상: ${targetFiles}`
})

Task({
  subagent_type: "qa-tester",
  team_name: teamName,
  name: "testing",
  model: "sonnet",
  prompt: `테스트 관점 리뷰:
    - 테스트 커버리지
    - 엣지 케이스 누락
    - 테스트 품질

    대상: ${targetFiles}`
})
```

### 결과 종합 템플릿

```markdown
## 리뷰 종합

### 보안 (security)
- [보안 이슈 요약]

### 품질 (quality)
- [품질 이슈 요약]

### 테스트 (testing)
- [테스트 이슈 요약]

### 권장사항
1. [우선순위 높은 수정]
2. [권장 개선]
3. [선택적 개선]
```

</pattern_parallel_review>

---

<pattern_pipeline>

## 패턴 2: 파이프라인

```
researcher → planner → implementer → tester
   │           │           │           │
[Task 1]  → [Task 2]  → [Task 3]  → [Task 4]
           blockedBy   blockedBy   blockedBy
```

### 팀 구성

| 순서 | 역할 | 에이전트 | 모델 | 산출물 |
|------|------|---------|------|--------|
| 1 | 조사 | researcher | sonnet | 조사 결과 |
| 2 | 계획 | planner | opus | 구현 계획 |
| 3 | 구현 | implementation-executor | sonnet | 코드 |
| 4 | 테스트 | tdd-guide | sonnet | 테스트 |

### 실행 코드

```typescript
TeamCreate({
  team_name: "team-pipeline-" + Date.now(),
  description: "순차 파이프라인"
})

// Task 생성 (의존성 포함)
TaskCreate({
  subject: "조사",
  description: "요구사항 및 기존 코드 분석",
  activeForm: "조사 중"
})
TaskCreate({
  subject: "계획",
  description: "구현 계획 수립",
  activeForm: "계획 수립 중",
  blockedBy: ["조사"]
})
TaskCreate({
  subject: "구현",
  description: "코드 구현",
  activeForm: "구현 중",
  blockedBy: ["계획"]
})
TaskCreate({
  subject: "테스트",
  description: "테스트 작성 및 검증",
  activeForm: "테스트 중",
  blockedBy: ["구현"]
})

// 순차 스폰
Task({
  subagent_type: "researcher",
  team_name: teamName,
  name: "researcher",
  model: "sonnet",
  prompt: `조사 수행:
    - 요구사항: ${requirements}
    - 기존 코드베이스 분석
    - 의존성 파악
    - 제약사항 식별

    결과를 .claude/plans/에 저장`
})

// researcher 완료 대기 후
Task({
  subagent_type: "planner",
  team_name: teamName,
  name: "planner",
  model: "opus",
  prompt: `구현 계획 수립:
    - 조사 결과 참조: .claude/plans/...
    - 단계별 구현 계획
    - 파일 구조
    - 인터페이스 설계

    계획을 .claude/plans/에 저장`
})

// planner 완료 대기 후
Task({
  subagent_type: "implementation-executor",
  team_name: teamName,
  name: "implementer",
  model: "sonnet",
  prompt: `구현 실행:
    - 계획 참조: .claude/plans/...
    - 코드 구현
    - 린트/타입체크 통과`
})

// implementer 완료 대기 후
Task({
  subagent_type: "tdd-guide",
  team_name: teamName,
  name: "tester",
  model: "sonnet",
  prompt: `테스트 작성:
    - 구현된 코드 테스트
    - 엣지 케이스
    - 80%+ 커버리지`
})
```

### 산출물 경로

```
.claude/plans/
├── research-[timestamp].md   # 조사 결과
├── plan-[timestamp].md       # 구현 계획
└── implementation-notes.md   # 구현 노트
```

</pattern_pipeline>

---

<pattern_cross_layer>

## 패턴 3: 크로스-레이어

```
          ┌── frontend (sonnet) ──┐
API Spec ─┼── backend (sonnet)  ──┼─► integration (tester)
          └── explore (haiku) ────┘
```

### 팀 구성

| 역할 | 에이전트 | 모델 | 담당 |
|------|---------|------|------|
| 프론트 | designer | sonnet | UI/UX, 컴포넌트 |
| 백엔드 | implementation-executor | sonnet | API, 비즈니스 로직 |
| 탐색 | explore | haiku | 기존 코드 분석 |
| 통합 | qa-tester | sonnet | E2E 테스트 |

### 실행 코드

```typescript
TeamCreate({
  team_name: "team-crosslayer-" + Date.now(),
  description: "크로스 레이어 협업"
})

// API Spec 작성 (Lead가 직접 또는 planner 위임)
const apiSpec = `
  POST /api/users
  - body: { name, email }
  - response: { id, name, email, createdAt }
`

// 병렬 스폰
Task({
  subagent_type: "explore",
  team_name: teamName,
  name: "explorer",
  model: "haiku",
  prompt: `기존 코드 분석:
    - 유사 기능 위치
    - 사용 패턴
    - 공통 유틸리티

    결과를 팀에 공유`
})

Task({
  subagent_type: "designer",
  team_name: teamName,
  name: "frontend",
  model: "sonnet",
  prompt: `프론트엔드 구현:
    API Spec: ${apiSpec}

    - UI 컴포넌트
    - API 호출 로직
    - 상태 관리
    - 에러 처리`
})

Task({
  subagent_type: "implementation-executor",
  team_name: teamName,
  name: "backend",
  model: "sonnet",
  prompt: `백엔드 구현:
    API Spec: ${apiSpec}

    - API 엔드포인트
    - 비즈니스 로직
    - DB 스키마/쿼리
    - 유효성 검사`
})

// frontend + backend 완료 후
Task({
  subagent_type: "qa-tester",
  team_name: teamName,
  name: "integration",
  model: "sonnet",
  prompt: `통합 테스트:
    - E2E 테스트 작성
    - API 통합 검증
    - 에러 시나리오`
})
```

### 파일 충돌 방지

| 영역 | 담당 | 파일 패턴 |
|------|------|----------|
| 프론트 | frontend | `src/components/**`, `src/pages/**` |
| 백엔드 | backend | `src/api/**`, `src/services/**` |
| 테스트 | integration | `tests/**` |
| 공유 | 협의 필요 | `src/types/**`, `src/utils/**` |

</pattern_cross_layer>

---

<pattern_hypothesis>

## 패턴 4: 가설-검증

```
     ┌── analyst-1 (opus, 보수적)
     ├── analyst-2 (opus, 혁신적)
Lead ┼── analyst-3 (opus, 실용적)
     └── synthesizer (sonnet, 종합)
```

### 팀 구성

| 역할 | 에이전트 | 모델 | 관점 |
|------|---------|------|------|
| 분석가 1 | analyst | opus | 보수적 (안정성) |
| 분석가 2 | analyst | opus | 혁신적 (성능) |
| 분석가 3 | analyst | opus | 실용적 (비용) |
| 종합 | architect | sonnet | 종합 판단 |

### 실행 코드

```typescript
TeamCreate({
  team_name: "team-hypothesis-" + Date.now(),
  description: "경쟁적 가설 검증"
})

const problem = "메모리 누수 원인 조사"

// 병렬 분석
Task({
  subagent_type: "analyst",
  team_name: teamName,
  name: "conservative",
  model: "opus",
  prompt: `보수적 관점 분석:
    문제: ${problem}

    - 안정성 우선
    - 검증된 해결책
    - 리스크 최소화
    - 점진적 접근

    가설과 근거를 제시`
})

Task({
  subagent_type: "analyst",
  team_name: teamName,
  name: "innovative",
  model: "opus",
  prompt: `혁신적 관점 분석:
    문제: ${problem}

    - 성능 극대화
    - 새로운 접근
    - 근본적 해결
    - 장기적 개선

    가설과 근거를 제시`
})

Task({
  subagent_type: "analyst",
  team_name: teamName,
  name: "pragmatic",
  model: "opus",
  prompt: `실용적 관점 분석:
    문제: ${problem}

    - 비용 효율
    - 구현 용이성
    - 즉시 적용 가능
    - 현실적 제약 고려

    가설과 근거를 제시`
})

// 분석 완료 후 종합
Task({
  subagent_type: "architect",
  team_name: teamName,
  name: "synthesizer",
  model: "sonnet",
  prompt: `분석 종합:
    - conservative 분석 결과
    - innovative 분석 결과
    - pragmatic 분석 결과

    각 가설의 장단점 비교
    권장안 도출
    실행 계획 수립`
})
```

### 결과 종합 템플릿

```markdown
## 가설 검증 결과

### 가설 비교

| 관점 | 가설 | 장점 | 단점 | 신뢰도 |
|------|------|------|------|--------|
| 보수적 | ... | ... | ... | ⭐⭐⭐ |
| 혁신적 | ... | ... | ... | ⭐⭐ |
| 실용적 | ... | ... | ... | ⭐⭐⭐ |

### 권장안
[종합 분석 기반 권장안]

### 실행 계획
1. [단계 1]
2. [단계 2]
3. [단계 3]
```

</pattern_hypothesis>

---

<custom_pattern>

## 커스텀 패턴

`--members` 옵션으로 직접 팀원 지정:

```bash
/team --members=architect,security-reviewer,designer API 설계 검토
```

### 사용 가능 에이전트

| 에이전트 | 역할 | 권장 모델 |
|---------|------|----------|
| analyst | 분석 | opus |
| architect | 아키텍처 | opus |
| security-reviewer | 보안 | opus |
| code-reviewer | 코드 리뷰 | sonnet |
| designer | UI/UX | sonnet |
| implementation-executor | 구현 | sonnet |
| tdd-guide | 테스트 | sonnet |
| researcher | 조사 | sonnet |
| planner | 계획 | opus |
| explore | 탐색 | haiku |
| document-writer | 문서 | haiku |

</custom_pattern>
