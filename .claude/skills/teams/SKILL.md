---
name: teams
description: Agent Teams 자동 오케스트레이션. 작업 분석 → 팀 구성 → 실행 → 정리. 복잡한 작업을 팀 단위로 병렬 처리.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Team Skill - Agent Teams 자동 오케스트레이션

> 작업 설명 하나로 팀 구성 → 실행 → 정리 자동화

---

<quick_reference>

## 핵심 요약

| 항목 | 설명 |
|------|------|
| **입력** | `/teams [작업 설명] [--pattern=패턴명]` |
| **출력** | 팀 협업 결과 + 종합 보고 |
| **자동화** | TeamCreate → Task × N → shutdown → TeamDelete |

### 4가지 팀 패턴

| 패턴 | 팀원 | 적합 작업 | 키워드 |
|------|------|----------|--------|
| **병렬-리뷰** | security + code + qa | PR 리뷰, 코드 감사 | 리뷰, 검토, PR |
| **파이프라인** | researcher → planner → implementer → tester | 기능 개발 | 구현, 개발, 기능 |
| **크로스-레이어** | frontend + backend + tester | 풀스택 구현 | API, 엔드포인트 |
| **가설-검증** | analyst × 3 + synthesizer | 버그 조사, 아키텍처 | 버그, 원인, 분석 |

</quick_reference>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| `/teams [작업 설명]` | 자동 패턴 선택 → 팀 실행 |
| `/teams --pattern=병렬-리뷰 [작업]` | 지정 패턴으로 팀 실행 |
| `/teams --members=a,b,c [작업]` | 지정 팀원으로 팀 실행 |
| "팀으로 [작업] 해줘" | `/teams` 자동 호출 |
| "Agent Teams로 [작업]" | `/teams` 자동 호출 |

**ARGUMENT 없음 → 즉시 질문: "어떤 작업을 팀으로 처리할까요?"**

</trigger_conditions>

---

<workflow>

## 실행 흐름

```
/teams [작업 설명]

┌─────────────────────────────────────────────────────────────┐
│  Phase 0: 환경 감지                                          │
│  - Agent Teams 가용성 확인                                   │
│  - 미가용 → Subagent 폴백 모드                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: 작업 분석 (Sequential Thinking)                    │
│  - 작업 유형 파악 (구현/리뷰/연구/디버깅)                     │
│  - 복잡도 평가 (LOW/MEDIUM/HIGH)                            │
│  - 필요 전문성 식별                                          │
│  - 팀 패턴 자동 선택 또는 사용자 지정 적용                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Phase 2: 팀 구성                                            │
│  - TeamCreate({ team_name, description })                   │
│  - TaskCreate × N (작업 분해)                               │
│  - 팀원 역할 및 모델 결정                                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Phase 3: 팀원 스폰 및 실행                                  │
│  - Task({ subagent_type, team_name, name, model, ... })    │
│  - 병렬 스폰 (독립 작업) / 순차 스폰 (의존성)               │
│  - Lead가 delegate 모드로 조율                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Phase 4: 진행 관리                                          │
│  - TaskList() 주기적 확인                                   │
│  - 팀원 idle 시 다음 작업 할당                              │
│  - 블로커 해결 또는 에스컬레이션                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  Phase 5: 정리                                               │
│  - 모든 Task 완료 확인                                      │
│  - shutdown_request → shutdown_response 대기                │
│  - TeamDelete()                                             │
│  - 결과 종합 보고                                            │
└─────────────────────────────────────────────────────────────┘
```

</workflow>

---

<phase_details>

## Phase 0: 환경 감지

```typescript
// Agent Teams 가용성 확인
const AGENT_TEAMS_AVAILABLE = await checkAvailability()

// 확인 방법:
// 1. 환경변수: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
// 2. settings.json: "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
// 3. .claude/agents/ 디렉토리 존재

if (!AGENT_TEAMS_AVAILABLE) {
  // Subagent 폴백 모드
  // @./references/fallback-strategy.md 참조
}
```

---

## Phase 1: 작업 분석

```typescript
// Sequential Thinking 2단계
mcp__sequential-thinking__sequentialthinking({
  thought: `작업 분석:
    1. 작업 유형: ${detectType(prompt)} // 구현/리뷰/연구/디버깅
    2. 복잡도: ${evaluateComplexity(prompt)} // LOW/MEDIUM/HIGH
    3. 필요 전문성: ${identifyExpertise(prompt)}
    4. 추천 패턴: ${recommendPattern(prompt)}`,
  thoughtNumber: 1,
  totalThoughts: 2
})

mcp__sequential-thinking__sequentialthinking({
  thought: `팀 구성 결정:
    패턴: ${pattern}
    팀원: ${teammates.join(', ')}
    모델: ${modelRouting}
    예상 작업 수: ${taskCount}`,
  thoughtNumber: 2,
  totalThoughts: 2
})
```

### 패턴 자동 선택 매트릭스

| 키워드 | 패턴 | 이유 |
|--------|------|------|
| 리뷰, 검토, PR, 감사 | 병렬-리뷰 | 다각도 동시 검토 |
| 구현, 개발, 기능, 추가 | 파이프라인 | 순차적 구현 흐름 |
| API, 엔드포인트, 풀스택 | 크로스-레이어 | 프론트/백 동시 |
| 버그, 원인, 분석, 조사 | 가설-검증 | 경쟁적 분석 |

---

## Phase 2: 팀 구성

```typescript
// 1. 팀 생성
TeamCreate({
  team_name: `team-${taskType}-${Date.now()}`,
  description: prompt
})

// 2. 작업 분해 (TaskCreate × N)
TaskCreate({
  subject: "보안 검토",
  description: "OWASP Top 10, 인증/인가, 입력 검증",
  activeForm: "보안 검토 중"
})
TaskCreate({
  subject: "코드 품질 검토",
  description: "가독성, 유지보수성, 패턴 준수",
  activeForm: "코드 품질 검토 중"
})
// ...추가 작업
```

---

## Phase 3: 팀원 스폰

```typescript
// 병렬 스폰 (독립 작업)
Task({
  subagent_type: "security-reviewer",
  team_name: "team-review-1234",
  name: "security",
  model: "opus",
  prompt: "보안 취약점 분석..."
})
Task({
  subagent_type: "code-reviewer",
  team_name: "team-review-1234",
  name: "quality",
  model: "sonnet",
  prompt: "코드 품질 검토..."
})
Task({
  subagent_type: "qa-tester",
  team_name: "team-review-1234",
  name: "testing",
  model: "sonnet",
  prompt: "테스트 커버리지 분석..."
})

// 순차 스폰 (의존성 있는 작업 - 파이프라인)
Task({ ..., name: "researcher" })  // 먼저 실행
// researcher 완료 대기
Task({ ..., name: "planner" })     // 다음 실행
```

### 모델 라우팅

| 복잡도 | 모델 | 역할 | 비용 |
|--------|------|------|------|
| **LOW** | haiku | explore, document-writer | 💰 |
| **MEDIUM** | sonnet | implementer, reviewer, tester | 💰💰 |
| **HIGH** | opus | analyst, planner, security | 💰💰💰 |

---

## Phase 4: 진행 관리

```typescript
// 주기적 상태 확인
TaskList()

// 팀원 메시지 처리
// - idle 알림 → 다음 작업 할당 또는 대기
// - 블로커 보고 → 해결 또는 에스컬레이션
// - 완료 보고 → 결과 수집

// 팀원 간 조율 (필요 시)
SendMessage({
  type: "message",
  recipient: "implementer",
  content: "researcher 결과: ...",
  summary: "조사 결과 전달"
})
```

---

## Phase 5: 정리

```typescript
// 1. 모든 Task 완료 확인
TaskList()  // pending/in_progress = 0

// 2. 팀원별 shutdown 요청
SendMessage({
  type: "shutdown_request",
  recipient: "security",
  content: "작업 완료, 종료 요청"
})
SendMessage({
  type: "shutdown_request",
  recipient: "quality",
  content: "작업 완료, 종료 요청"
})
// ...모든 팀원

// 3. shutdown_response 대기

// 4. 팀 해산
TeamDelete()

// 5. 결과 종합 보고
```

</phase_details>

---

<patterns>

## 팀 패턴 상세

@./references/patterns.md

### 패턴 1: 병렬-리뷰

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

**사용 예시:**
```bash
/teams PR #123 리뷰해줘
/teams --pattern=병렬-리뷰 코드 감사 진행
```

---

### 패턴 2: 파이프라인

```
researcher → planner → implementer → tester
   │           │           │           │
[Task 1]  → [Task 2]  → [Task 3]  → [Task 4]
           blockedBy   blockedBy   blockedBy
```

**사용 예시:**
```bash
/teams 사용자 인증 기능 구현
/teams --pattern=파이프라인 결제 시스템 리팩토링
```

---

### 패턴 3: 크로스-레이어

```
          ┌── frontend (sonnet) ──┐
API Spec ─┼── backend (sonnet)  ──┼─► integration (tester)
          └── explore (haiku) ────┘
```

**사용 예시:**
```bash
/teams 결제 API 엔드포인트 추가
/teams --pattern=크로스-레이어 사용자 프로필 페이지
```

---

### 패턴 4: 가설-검증

```
     ┌── analyst-1 (opus, 보수적)
     ├── analyst-2 (opus, 혁신적)
Lead ┼── analyst-3 (opus, 실용적)
     └── synthesizer (sonnet, 종합)
```

**사용 예시:**
```bash
/teams 메모리 누수 원인 조사
/teams --pattern=가설-검증 성능 병목 분석
```

</patterns>

---

<fallback>

## Subagent 폴백

@./references/fallback-strategy.md

**Agent Teams 미가용 시:**

```typescript
// 병렬 Subagent로 대체
Task({
  subagent_type: "security-reviewer",
  // team_name 없음
  prompt: "보안 취약점 분석..."
})
Task({
  subagent_type: "code-reviewer",
  prompt: "코드 품질 검토..."
})
Task({
  subagent_type: "qa-tester",
  prompt: "테스트 커버리지 분석..."
})

// 결과 수집 후 종합
```

**차이점:**

| 항목 | Agent Teams | Subagent 폴백 |
|------|-------------|---------------|
| 팀원 간 통신 | ✅ Inbox | ❌ Lead 경유 |
| 공유 Task List | ✅ | ❌ |
| 비용 | 높음 | 중간 |
| 복잡도 | 높음 | 낮음 |

</fallback>

---

<cost_guardrails>

## 비용 가드레일

| 규칙 | 임계값 | 행동 |
|------|--------|------|
| 팀 규모 | 5명 초과 | 사용자 확인 필요 |
| 실행 시간 | 30분 초과 | 중간 보고 필수 |
| 브로드캐스트 | 3회 초과 | 경고 로그 |
| 실패 반복 | 3회 연속 | 에스컬레이션 |

### 비용 최적화

| 전략 | 효과 |
|------|------|
| 모델 티어링 (haiku/sonnet/opus) | ~40% 절감 |
| 작업 그래뉼래리티 (2-4시간 단위) | 병렬성 향상 |
| 조기 종료 (maxTurns 설정) | 불필요 세션 방지 |

</cost_guardrails>

---

<examples>

## 실행 예시

### 예시 1: 자동 패턴 선택

```bash
/teams PR #123 코드 리뷰해줘

# 자동 분석:
# - 키워드: "리뷰" → 병렬-리뷰 패턴
# - 팀원: security-reviewer, code-reviewer, qa-tester
# - 모델: opus(보안), sonnet(품질/테스트)

# 실행:
TeamCreate({ team_name: "team-review-pr123" })
Task({ subagent_type: "security-reviewer", ... })
Task({ subagent_type: "code-reviewer", ... })
Task({ subagent_type: "qa-tester", ... })
# ...결과 종합 후 정리
```

---

### 예시 2: 패턴 명시

```bash
/teams --pattern=파이프라인 사용자 알림 시스템 구현

# 실행:
TeamCreate({ team_name: "team-pipeline-notify" })

# 순차 실행:
Task({ subagent_type: "researcher", name: "researcher", ... })
# 완료 대기
Task({ subagent_type: "planner", name: "planner", ... })
# 완료 대기
Task({ subagent_type: "implementation-executor", name: "implementer", ... })
# 완료 대기
Task({ subagent_type: "tdd-guide", name: "tester", ... })
# ...결과 종합 후 정리
```

---

### 예시 3: 팀원 직접 지정

```bash
/teams --members=architect,security-reviewer,designer API 설계 검토

# 지정된 팀원으로 구성:
Task({ subagent_type: "architect", ... })
Task({ subagent_type: "security-reviewer", ... })
Task({ subagent_type: "designer", ... })
```

</examples>

---

<validation>

## 검증 체크리스트

| 단계 | 체크 |
|------|------|
| **Phase 0** | Agent Teams 가용성 확인 |
| **Phase 1** | Sequential Thinking으로 분석 |
| **Phase 2** | TeamCreate + TaskCreate 완료 |
| **Phase 3** | 모든 팀원 스폰 완료 |
| **Phase 4** | TaskList 확인, 블로커 해결 |
| **Phase 5** | shutdown → TeamDelete 완료 |

## 금지 사항

| 금지 | 이유 |
|------|------|
| 팀 정리 없이 종료 | 고아 세션 발생 |
| 5명+ 무조건 생성 | 비용 폭증 |
| 브로드캐스트 남발 | 비용 × 팀원 수 |
| 한 파일 여러 팀원 수정 | 충돌 발생 |
| 팀원 컨텍스트 가정 | spawn 시 상세 프롬프트 필수 |

</validation>

---

<instructions>

## 실행 지침

### 1. ARGUMENT 파싱

```typescript
const args = parseArguments(ARGUMENTS)
// args.prompt: 작업 설명
// args.pattern: 패턴 (선택)
// args.members: 팀원 (선택)
```

### 2. 환경 확인

```bash
# Agent Teams 가용성 체크
${CLAUDE_SCRIPTS_ROOT}/agent-teams/check-availability.sh
```

### 3. 작업 분석

```typescript
mcp__sequential-thinking__sequentialthinking({
  thought: `작업 "${args.prompt}" 분석:
    - 유형: ${type}
    - 복잡도: ${complexity}
    - 전문성: ${expertise}
    - 패턴: ${args.pattern || autoPattern}`,
  thoughtNumber: 1,
  totalThoughts: 2
})
```

### 4. 팀 실행

- Agent Teams 가용 → Phase 2-5 실행
- Agent Teams 미가용 → Subagent 폴백

### 5. 결과 보고

```markdown
## 팀 작업 완료

**패턴:** ${pattern}
**팀원:** ${teammates}
**소요 시간:** ${duration}

### 결과 요약
- [팀원별 결과 종합]

### 다음 단계
- [권장 후속 작업]
```

</instructions>
