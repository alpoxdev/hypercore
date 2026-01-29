---
name: ralph
description: 작업 완료까지 자기참조 루프. 플래너 검증 기반 완료 판단. 복잡한 작업의 완전한 구현과 검증이 필요한 경우 사용.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/workflow-patterns/phase-based-workflow.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Ralph Skill - Self-Referential Infinite Loop

**[RALPH MODE ON - ITERATION {{ITERATION}}]**

---

<quick_reference>

## 빠른 참조 (Ralph 핵심)

### Ralph = 무한 루프 스킬

```typescript
while (true) {
  // Phase 1: 작업 실행
  구현()

  // Phase 2: 자동 검증
  if (!검증통과()) {
    ITERATION++
    continue  // ← 즉시 다음 반복
  }

  // Phase 3: Planner 검증
  if (!플래너승인()) {
    ITERATION++
    continue  // ← 즉시 다음 반복
  }

  // Phase 4: 완료
  <promise>출력()
  break  // ← 유일한 탈출구
}
```

### 3가지 핵심 규칙

| # | 규칙 | 설명 |
|---|------|------|
| 1 | **무한 반복** | Phase 4 도달까지 자동 재시도. 수동 중단 불가. |
| 2 | **증거 기반** | 매 반복마다 **새로운** 검증 실행. 이전 결과 재사용 금지. |
| 3 | **Planner 필수** | Phase 3 우회 불가. 승인 없이 `<promise>` 출력 시 즉시 실패. |

### 루프 종료 유일 조건

```
✅ Phase 1: 모든 요구사항 100% 완료
✅ Phase 2: /pre-deploy (새로 실행) + TaskList (새로 조회) 통과
✅ Phase 3: Planner (새로 생성) 승인
✅ Phase 4: <promise> 출력
→ 루프 종료
```

**하나라도 실패 → ITERATION++ → Phase 1로 복귀**

### 상태 문서 (`.claude/ralph/{{SESSION}}/`)

| 파일 | 역할 | 업데이트 시점 |
|------|------|--------------|
| **ITERATION.md** | 반복 히스토리 추적 | 매 반복 끝 |
| **VERIFICATION.md** | 검증 결과 기록 | 매 검증 실행 시 |
| **TASKS.md** | 요구사항 체크리스트 | 요구사항 완료 시 |
| **PROCESS.md** | Phase 진행 상황 | Phase 전환 시 |

**문서 없이는 루프 지속 불가.**

</quick_reference>

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| **복잡한 구현** | 여러 단계의 작업이 필요한 기능 구현 |
| **완전성 필요** | 부분 구현이 아닌 100% 완성이 필요한 작업 |
| **검증 필수** | 테스트, 빌드, 린트 검증이 반드시 필요한 경우 |
| **멀티 에이전트** | 여러 전문 에이전트의 협업이 필요한 작업 |
| **병렬 실행** | 독립적인 작업을 동시에 처리해야 하는 경우 |

</when_to_use>

---

<loop_mechanism>

## 무한 루프 메커니즘 (Iron Law)

### 루프 진입 조건
`/ralph` 스킬 호출 시 즉시 진입. 세션 종료 또는 `<promise>` 출력까지 계속.

### 루프 종료 조건 (AND 조건)

**`<promise>{{PROMISE}}</promise>`를 출력하는 유일한 조건:**

| # | 단계 | 검증 방법 | 통과 기준 |
|---|------|----------|----------|
| 1 | 작업 완료 확인 | 원본 요구사항 체크리스트 | 100% 충족 |
| 2 | 코드 검증 | **새로 실행한** `/pre-deploy` 결과 | typecheck/lint/build 모두 통과 |
| 3 | TODO 확인 | **새로 실행한** TaskList 조회 | pending/in_progress = 0 |
| 4 | 플래너 검증 | **새로 생성한** Planner 에이전트 호출 | "승인" 응답 |
| 5 | 상태 정리 | `.claude/ralph/` 상태 문서 최종 업데이트 | 완료 시각 기록 |

**모든 5단계 통과 후에만 `<promise>` 출력. 하나라도 실패 시 루프 재개.**

### 루프 재개 트리거

다음 상황에서 **즉시** 루프 재개:
- 검증 실패 (typecheck/lint/build 중 하나라도 실패)
- TODO 존재 (pending/in_progress > 0)
- Planner 거절 (추가 작업 요청)
- 추측성 표현 발견 ("아마도", "probably", "should")

**재개 시 메시지:**
```
[RALPH MODE ON - 검증 실패, 재시도 {{ITERATION}}]
```

</loop_mechanism>

---

<completion_protocol>

## 완료 프로토콜 (절대 규칙)

### 증거 기반 검증 (Fresh Evidence Only)

**금지:** 이전 검증 결과 재사용, 추측, 가정
**필수:** 매 반복마다 새로운 검증 실행

```typescript
// ❌ 잘못된 완료 판단
"이전에 /pre-deploy 통과했으니 완료"
"아마 작동할 것 같다"

// ✅ 올바른 완료 판단
Skill("pre-deploy")  // 새로 실행
TaskList()           // 새로 조회
Task(subagent_type="planner", model="opus", ...)  // 새로 검증
```

### 상태 문서 정리

완료 직전 `.claude/ralph/{{SESSION}}/` 최종 업데이트:
- TASKS.md: 모든 체크박스 완료
- PROCESS.md: 완료 시각, 총 소요 시간
- VERIFICATION.md: 최종 검증 결과

**상태 파일은 유지 (삭제 금지). 세션 히스토리로 활용.**

</completion_protocol>

---

<loop_flow>

## 루프 플로우 (무한 반복 구조)

```
[시작] → Iteration 1
    ↓
┌───────────────────────────────────┐
│  Phase 1: 작업 실행               │
│  - 요구사항 구현                   │
│  - 에이전트 위임 (병렬)           │
│  - TASKS.md 업데이트              │
└───────────────┬───────────────────┘
                ↓
┌───────────────────────────────────┐
│  Phase 2: 자동 검증               │
│  - /pre-deploy (새로 실행)        │
│  - TaskList (새로 조회)           │
│  - VERIFICATION.md 업데이트       │
└───────┬───────────────────────────┘
        ↓
    ┌─[실패]─→ ITERATION.md 기록 → Iteration N+1 (Phase 1로 복귀) ─┐
    │                                                               │
    ↓[통과]                                                         │
┌───────────────────────────────────┐                              │
│  Phase 3: Planner 검증            │                              │
│  - Planner 에이전트 (새로 생성)   │                              │
│  - 승인/거절 판단                 │                              │
│  - VERIFICATION.md 업데이트       │                              │
└───────┬───────────────────────────┘                              │
        ↓                                                           │
    ┌─[거절]─→ ITERATION.md 기록 → Iteration N+1 (Phase 1로 복귀) ─┤
    │                                                               │
    ↓[승인]                                                         │
┌───────────────────────────────────┐                              │
│  Phase 4: 완료 출력               │                              │
│  - ITERATION.md 최종 업데이트     │                              │
│  - <promise> 출력                 │                              │
└───────────────┬───────────────────┘                              │
                ↓                                                   │
            [종료]                                                  │
                                                                    │
루프 재개 트리거 (즉시 다음 반복): ←───────────────────────────────┘
- Phase 2 실패 (typecheck/lint/build)
- TODO 존재 (pending/in_progress > 0)
- Phase 3 거절 (Planner 추가 작업 요청)
- 추측성 표현 발견
```

**핵심 원리:**
- 루프는 **자동으로** 재개 (수동 개입 불필요)
- Phase 4 도달 전까지 **무한 반복**
- 각 반복은 **독립적인 검증** 실행 (이전 결과 재사용 금지)

</loop_flow>

---

<forbidden>

## 금지 사항 (루프 탈출 방지)

### 조기 탈출 패턴 (절대 금지)

| 조기 탈출 패턴 | 설명 | 올바른 행동 |
|---------------|------|-----------|
| ❌ **추측 기반 완료** | "아마 완료된 것 같다" | 새로 `/pre-deploy` 실행 |
| ❌ **이전 검증 재사용** | "전에 통과했으니 완료" | 매 반복마다 새로 검증 |
| ❌ **부분 검증** | `/pre-deploy` 스킵 | 5단계 모두 실행 |
| ❌ **플래너 스킵** | 검증 없이 `<promise>` 출력 | Planner 호출 필수 |
| ❌ **만족감 표현** | "잘 작동하네요" | 증거 기반 검증 |
| ❌ **범위 축소** | "이 정도면 충분" | 원본 요구사항 100% |
| ❌ **테스트 삭제/수정** | 실패 테스트 제거 | 코드 수정으로 통과 |
| ❌ **에이전트 미활용** | 모든 작업 혼자 수행 | 적극적으로 에이전트 위임 |
| ❌ **루프 강제 종료** | "여기서 멈춘다" | Phase 4 도달까지 계속 |

### STOP 신호 (즉시 검증 실행)

다음 표현 사용 시 **즉시 중단하고 새로운 검증 실행:**

```text
❌ "~해야 한다" "probably" "should" "seems to"
❌ "아마도" "~것 같다" "대부분" "거의"
❌ "이 정도면" "충분히" "~만 하면 됨"
❌ "전에 통과했으니" "이전 검증 결과"
❌ "루프 종료" "여기서 멈춘다"
```

### 대신 사용해야 할 표현

```text
✅ "Skill('pre-deploy') 새로 실행"
✅ "/pre-deploy 결과 읽기: cat .claude/ralph/.../VERIFICATION.md"
✅ "TaskList() 새로 조회"
✅ "Task(subagent_type='planner', model='opus', ...) 새로 생성"
✅ "ITERATION.md 업데이트 후 다음 반복 시작"
```

### 루프 계속 조건

**루프는 다음 상황에서 자동 계속:**
- Phase 2 실패 → Iteration N+1 (Phase 1로)
- TODO 남음 → Iteration N+1 (Phase 1로)
- Planner 거절 → Iteration N+1 (Phase 1로)
- 추측 발견 → 즉시 검증 실행

**루프 종료 유일 조건:** Phase 4에서 `<promise>` 출력

</forbidden>

---

<required>

## 필수 검증 단계

### 1. 작업 완료 확인

원본 작업의 모든 요구사항을 체크리스트로 작성하고 하나씩 확인:

```markdown
- [ ] 요구사항 1: [구체적 설명]
- [ ] 요구사항 2: [구체적 설명]
- [ ] 요구사항 3: [구체적 설명]
```

**모든 항목 체크 완료 후 다음 단계 진행.**

### 2. 코드 검증

`/pre-deploy` 스킬을 사용하여 전체 검증 실행:

```typescript
Skill("pre-deploy")
```

**`/pre-deploy` 스킬은 다음을 자동으로 수행:**
- typecheck (tsc --noEmit 또는 해당 언어 타입 체크)
- lint (eslint, prettier 등)
- build (프로젝트 빌드)
- 모든 단계에서 에러 발견 시 자동 수정 시도

### 3. 검증 결과 확인

`/pre-deploy` 실행 결과를 읽고 기록:

```text
✅ Typecheck: 통과
✅ Lint: 에러 0개
✅ Build: 성공
```

**추측 금지. `/pre-deploy` 실제 출력만 기록. 모든 단계가 통과해야 다음 진행.**

### 3. TODO 확인

```typescript
TaskList() // pending/in_progress 작업 확인
```

**모든 작업이 completed 상태여야 다음 단계 진행.**

### 4. 플래너 검증

```typescript
Task(
  subagent_type="planner",
  model="opus",
  prompt=`다음 구현이 완료되었는지 검증:

원본 작업:
{{PROMPT}}

수행한 작업:
[구체적으로 무엇을 했는지]

검증 결과:
- /pre-deploy: ✅ 통과
- TODO: ✅ 0개
[기타 검증 결과]

완료 여부를 판단해주세요.`
)
```

**Planner의 "승인" 응답을 받은 후에만 `<promise>` 출력.**

### 5. 문서화 (각 단계마다)

각 Phase 완료 시 상태 문서 업데이트:

| Phase | 업데이트 파일 | 업데이트 내용 |
|-------|--------------|--------------|
| 1 | TASKS.md | 체크박스 체크, 완료율 업데이트 |
| 1 | PROCESS.md | Phase 1 완료 항목 기록, Phase 2 시작 표시 |
| 2 | VERIFICATION.md | `/pre-deploy` 결과, TODO 개수 기록 |
| 2 | PROCESS.md | Phase 2 완료, Phase 3 시작 |
| 3 | VERIFICATION.md | Planner 응답 기록 |
| 3 | PROCESS.md | Phase 3 완료, Phase 4 시작 |
| 4 | PROCESS.md | 완료 시각, 총 소요 시간 |

**문서 업데이트 시점:**
- Phase 전환 시 즉시 업데이트
- 주요 의사결정 시 NOTES.md 기록
- 블로커 발견 시 PROCESS.md에 기록

**Context compaction 대비:**
- 최소 10분마다 문서 업데이트
- 복잡한 작업 완료 시 즉시 기록
- 의사결정은 PROCESS.md에 이유와 함께 기록

</required>

---

<ultrawork_mode>

## ULTRAWORK MODE (자동 활성화)

### 병렬 실행 규칙

| 원칙 | 실행 방법 |
|------|----------|
| **PARALLEL** | 독립 작업은 단일 메시지에서 동시 Tool 호출 |
| **READ_PARALLEL** | 독립적인 파일 읽기는 단일 메시지에서 여러 Read 동시 호출 |
| **EXPLORE_PARALLEL** | 복잡한 탐색은 여러 explore 에이전트 병렬 실행 |
| **BACKGROUND** | 10개 이상 동시 작업 시 `run_in_background=true` |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 |

### 파일 읽기 및 탐색 병렬화

**독립적인 파일 읽기는 반드시 병렬로:**

```typescript
// ❌ 순차 읽기 (느림)
Read(.claude/skills/skill1.md)
// 대기...
Read(.claude/skills/skill2.md)
// 대기...
Read(.claude/agents/agent1.md)

// ✅ 병렬 읽기 (빠름)
// 단일 메시지에서 모든 Read 동시 호출
Read(.claude/skills/skill1.md)
Read(.claude/skills/skill2.md)
Read(.claude/agents/agent1.md)
Read(.claude/agents/agent2.md)
Read(.claude/agents/agent3.md)
```

**복잡한 탐색은 explore 에이전트 병렬 활용:**

```typescript
// ❌ 직접 순차 탐색 (느림)
Glob('**/*.prisma')
// 대기...
Grep('createServerFn', '**/*.ts')
// 대기...
Bash('git log --grep="auth"')

// ✅ explore 에이전트 병렬 실행 (빠름)
Task(subagent_type="explore", model="haiku",
     prompt=".claude/skills/ 디렉토리 모든 파일 탐색 및 구조 분석")
Task(subagent_type="explore", model="haiku",
     prompt=".claude/agents/ 디렉토리 모든 파일 탐색 및 역할 분석")
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 루트 설정 파일 탐색 (package.json, tsconfig.json)")
```

**Sequential Thinking 중 탐색 병렬화:**

```typescript
// Thinking 중 탐색이 필요할 때
mcp__sequential-thinking(
  thought="파일 구조 파악 필요. explore 에이전트 3개 병렬 호출하여 빠르게 정보 수집",
  nextThoughtNeeded=true
)

// 다음 메시지에서 즉시 병렬 explore 실행
Task(subagent_type="explore", model="haiku",
     prompt="인증 관련 파일 및 구조 탐색")
Task(subagent_type="explore", model="haiku",
     prompt="데이터베이스 스키마 및 모델 탐색")
Task(subagent_type="explore", model="haiku",
     prompt="API 엔드포인트 및 라우팅 탐색")

// 다음 Thinking에서 결과 통합
mcp__sequential-thinking(
  thought="3개 explore 결과 통합: 인증은 middleware/, DB는 prisma/, API는 functions/",
  nextThoughtNeeded=true
)
```

**파일 읽기 vs explore 에이전트 선택:**

| 상황 | 도구 | 이유 |
|------|------|------|
| 특정 파일 3-5개 읽기 | Read 병렬 | 빠르고 간단 |
| 디렉토리 전체 탐색 | explore 에이전트 | 구조 분석 + 요약 |
| 패턴 검색 + 분석 | explore 에이전트 | 검색 + 해석 통합 |
| 여러 영역 동시 탐색 | explore 에이전트 병렬 | 독립 컨텍스트 |
| 10개 이상 파일 읽기 | explore 에이전트 | 컨텍스트 효율 |

### Smart Model Routing

| 복잡도 | 모델 | 작업 예시 |
|--------|------|----------|
| LOW | haiku | 함수 찾기, 정의 조회, 파일 읽기 |
| MEDIUM | sonnet | 기능 구현, 버그 수정, 리팩토링 |
| HIGH | opus | 아키텍처 설계, 복잡한 디버깅, 보안 분석 |

**에이전트 호출 시 항상 `model` 파라미터 명시:**

```typescript
Task(subagent_type="implementation-executor", model="sonnet", ...)
Task(subagent_type="planner", model="opus", ...)
```

### 티어별 에이전트

| 도메인 | 에이전트 | 권장 모델 | 용도 |
|--------|---------|----------|------|
| 계획/분석 | planner | opus | 아키텍처 설계, 검증 |
| 요구사항 분석 | analyst | sonnet | 계획 전 요구사항 분석, 가정 검증, 엣지 케이스 |
| 아키텍처 | architect | sonnet/opus | 아키텍처 분석, 디버깅 (READ-ONLY) |
| 실행 | implementation-executor | sonnet | 기능 구현, 버그 수정 |
| 탐색 | explore | haiku | 코드베이스 탐색 |
| 프론트엔드 | designer | sonnet/opus | UI/UX 구현 |
| 문서 작성 | document-writer | haiku/sonnet | 기술 문서, 상태 문서 관리 |
| 배포 검증 | deployment-validator | sonnet | typecheck/lint/build |
| 코드 리뷰 | code-reviewer | opus | 품질 검토 |
| 린트 수정 | lint-fixer | sonnet | tsc/eslint 오류 수정 |
| 리팩토링 | refactor-advisor | sonnet | 구조 개선 조언 |
| Git 작업 | git-operator | haiku | Git 커밋/푸시 |
| 의존성 관리 | dependency-manager | sonnet | 의존성 분석, 업데이트, 보안 스캔 |
| 번역 | ko-to-en-translator | haiku | 한글→영어 번역 |

### 백그라운드 실행

| 작업 유형 | 실행 모드 |
|----------|----------|
| 패키지 설치 (`npm install`, `pip install`) | Background |
| 빌드 (`npm run build`, `tsc`, `make`) | Background |
| 테스트 스위트 (`npm test`, `pytest`) | Background |
| Docker 작업 (`docker build`, `docker pull`) | Background |
| 파일 읽기/쓰기 | Foreground |
| 간단한 명령어 (`git status`, `ls`) | Foreground |

### Agent Delegation (적극 활용)

**에이전트에게 위임하는 조건:**

| 조건 | 예시 | 위임할 에이전트 |
|------|------|----------------|
| 요구사항 불명확 | 가정 검증, 엣지 케이스 분석 | analyst |
| 아키텍처 조언 필요 | 설계 검토, 패턴 분석 | architect |
| 독립적인 작업 | 코드 분석 + 리뷰 동시 | implementation-executor + code-reviewer |
| 새 컨텍스트 필요 | 대규모 코드베이스 탐색 | explore |
| 전문 지식 필요 | 린트/타입 오류 수정 | lint-fixer |
| 장기 실행 작업 | 배포 전 전체 검증 | deployment-validator |
| 병렬 처리 가능 | 여러 파일 동시 수정 | implementation-executor (여러 개) |
| Git 작업 필요 | 논리적 단위 커밋/푸시 | git-operator |
| 의존성 문제 | 패키지 업데이트, 보안 스캔 | dependency-manager |
| 번역 필요 | 한글→영어 문서/코드 번역 | ko-to-en-translator |

**에이전트 위임 원칙:**

```text
✅ 독립적인 작업 → 즉시 위임 (병렬 실행)
✅ 컨텍스트 분리 필요 → 위임
✅ 전문성 필요 → 해당 도메인 에이전트
✅ 10분 이상 예상 → 백그라운드 + 에이전트

❌ 간단한 파일 읽기 → 직접 실행
❌ 순차 의존성 → 직접 실행 후 다음 에이전트
```

### Phase별 에이전트 활용

| Phase | 작업 | 에이전트 | 모델 | 병렬 실행 |
|-------|------|---------|------|----------|
| **1** | 요구사항 분석 | analyst | sonnet | ✅ (독립 분석) |
| **1** | 아키텍처 분석 | architect | sonnet/opus | ✅ (READ-ONLY) |
| **1** | 상태 문서 생성 | document-writer | haiku | ✅ (여러 문서) |
| **1** | 코드베이스 탐색 | explore | haiku | ✅ (여러 영역) |
| **1** | 기능 구현 | implementation-executor | sonnet | ✅ (독립 기능) |
| **1** | UI 구현 | designer | sonnet/opus | ✅ (여러 컴포넌트) |
| **1** | 리팩토링 조언 | refactor-advisor | sonnet | ✅ (READ-ONLY) |
| **1-4** | 문서 업데이트 | document-writer | haiku | ✅ (Phase 전환 시) |
| **1-4** | 문서 번역 | ko-to-en-translator | haiku | ✅ (독립 작업) |
| **2** | 배포 검증 | deployment-validator | sonnet | ❌ (순차) |
| **2** | 린트 수정 | lint-fixer | sonnet | ❌ (순차) |
| **2** | 의존성 업데이트 | dependency-manager | sonnet | ❌ (순차) |
| **3** | 아키텍처 검증 | planner | opus | ❌ (필수) |
| **3** | 코드 리뷰 | code-reviewer | opus | ✅ (파일별) |
| **4** | Git 커밋/푸시 | git-operator | haiku | ❌ (순차) |

### 병렬 에이전트 실행 패턴

**패턴 1: 독립 작업 동시 처리**

```typescript
// ❌ 순차 실행 (느림)
Task(subagent_type="implementation-executor", model="sonnet", prompt="기능 A 구현")
// 대기...
Task(subagent_type="implementation-executor", model="sonnet", prompt="기능 B 구현")

// ✅ 병렬 실행 (빠름)
// 단일 메시지에서 두 Task 호출
Task(subagent_type="implementation-executor", model="sonnet", prompt="기능 A 구현")
Task(subagent_type="implementation-executor", model="sonnet", prompt="기능 B 구현")
```

**패턴 2: 도메인별 전문가 활용**

```typescript
// 동시에 실행
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="API 엔드포인트 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="UI 컴포넌트 구현")
Task(subagent_type="code-reviewer", model="opus",
     prompt="코드 리뷰 및 개선사항 도출")
```

**패턴 3: 탐색 + 구현 분리**

```typescript
// Phase 1 시작 시
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 구조 및 기존 패턴 분석")

// 탐색 결과 기반으로 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="분석된 패턴에 따라 [기능] 구현")
```

**패턴 4: 문서 병렬 작성 (Ralph 특화)**

```typescript
// Phase 시작/전환 시 여러 문서 동시 업데이트
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md 업데이트: 요구사항 1, 2 완료 체크")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md 업데이트: Phase 1 → Phase 2 전환 기록")
Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md 업데이트: /pre-deploy 결과 기록")
```

### 에이전트 호출 체크리스트

작업 시작 전 확인:

- [ ] 이 작업은 독립적인가? → 병렬 에이전트 고려
- [ ] 새 컨텍스트가 필요한가? → 에이전트 위임
- [ ] 전문 지식이 필요한가? → 도메인 에이전트 선택
- [ ] 10분 이상 소요될까? → 백그라운드 + 에이전트
- [ ] 여러 파일/영역 동시 작업? → 여러 executor 병렬 실행

**적극적으로 에이전트 활용. 혼자 하지 말 것.**

### 병렬 에이전트 실전 시나리오

**시나리오 1: 풀스택 기능 구현**

```typescript
// 사용자 관리 기능 구현 (API + UI + 문서)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="User API CRUD 엔드포인트 구현 (src/functions/user.ts)")
Task(subagent_type="designer", model="sonnet",
     prompt="User Profile UI 컴포넌트 구현 (src/routes/profile/)")
Task(subagent_type="document-writer", model="haiku",
     prompt="User API 문서 작성 (docs/api/user.md)")
```

**시나리오 2: 여러 독립 기능 동시 구현**

```typescript
// 3개의 독립적인 API 엔드포인트
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="/api/posts CRUD 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="/api/comments CRUD 구현")
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="/api/likes 구현")
```

**시나리오 3: 코드베이스 다중 영역 탐색**

```typescript
// 프로젝트 초기 분석 시
Task(subagent_type="explore", model="haiku",
     prompt="인증 구조 분석 (middleware, auth)")
Task(subagent_type="explore", model="haiku",
     prompt="데이터베이스 스키마 분석 (prisma)")
Task(subagent_type="explore", model="haiku",
     prompt="라우팅 구조 분석 (routes)")
```

**시나리오 4: 다중 검증**

```typescript
// 코드 완성 후 여러 관점에서 동시 검토
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 검토: SQL Injection, XSS, CSRF 취약점")
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토: N+1 쿼리, 불필요한 리렌더")
Task(subagent_type="code-reviewer", model="opus",
     prompt="접근성 검토: ARIA, 키보드 네비게이션")
```

**시나리오 5: 문서 병렬 업데이트 (Ralph 특화)**

```typescript
// Phase 전환 시 여러 문서 동시 업데이트
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md: 요구사항 1-3 완료 체크")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md: Phase 1 완료 → Phase 2 시작 기록")
Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md: 준비 상태로 초기화")
```

**시나리오 6: 계획 수립 전 분석 (analyst + architect)**

```typescript
// 복잡한 기능 구현 전 요구사항 및 아키텍처 분석
Task(subagent_type="analyst", model="sonnet",
     prompt="사용자 인증 기능 요구사항 분석: 가정 검증, 엣지 케이스 도출")
Task(subagent_type="architect", model="opus",
     prompt="현재 인증 아키텍처 분석 및 개선 방향 제시")
Task(subagent_type="explore", model="haiku",
     prompt="기존 인증 구현 코드 탐색 (middleware, session)")
```

**시나리오 7: 프로젝트 유지보수 (dependency + git + translation)**

```typescript
// 프로젝트 전체 유지보수 작업
Task(subagent_type="dependency-manager", model="sonnet",
     prompt="의존성 분석 및 보안 취약점 스캔 후 업데이트 제안")
Task(subagent_type="refactor-advisor", model="sonnet",
     prompt="코드베이스 리팩토링 우선순위 분석")
Task(subagent_type="ko-to-en-translator", model="haiku",
     prompt="한글 주석 및 문서를 영어로 번역 (README.md, CLAUDE.md)")
```

</ultrawork_mode>

---

<state_management>

## 상태 관리 (루프 지속성 보장)

### 문서화 폴더 구조

**필수:** 세션 시작 시 `.claude/ralph/{{YYMMDD}}-{{N}}-{{작업명}}/` 폴더 생성

```
.claude/ralph/260129-01-사용자_인증_구현/
├── TASKS.md          # 작업 체크리스트
├── PROCESS.md        # 진행 단계 및 의사결정
├── VERIFICATION.md   # 검증 결과 기록 (매 반복마다 업데이트)
├── ITERATION.md      # 반복 히스토리 (매 루프마다 추가)
└── NOTES.md          # 추가 메모
```

**폴더명 형식:** `YYMMDD-N-작업명` (날짜 + 시퀀스 + 한글 설명)
- 날짜: 오늘 날짜 (YYMMDD)
- 시퀀스: 같은 날 여러 세션 시 증가 (01, 02, 03...)
- 작업명: 한글 설명 (언더스코어로 구분)

**생성 시점:** Ralph 루프 진입 즉시 (첫 반복 시작 전)

### 루프 추적 파일: ITERATION.md

**목적:** 매 반복의 결과를 기록하여 무한 루프 진행 상황 추적

```markdown
# Iteration History

## Iteration 1 - 2026-01-29 14:30:15
**Phase:** Phase 1 (작업 실행)
**완료:** 요구사항 1, 2
**미완료:** 요구사항 3
**다음 액션:** 요구사항 3 구현

## Iteration 2 - 2026-01-29 14:45:22
**Phase:** Phase 2 (검증)
**완료:** /pre-deploy 통과
**미완료:** TODO 1개 남음
**다음 액션:** TODO 완료

## Iteration 3 - 2026-01-29 15:00:10
**Phase:** Phase 3 (Planner 검증)
**완료:** /pre-deploy, TODO 0개
**미완료:** Planner 거절 (성능 개선 필요)
**다음 액션:** N+1 쿼리 수정 후 재검증

## Iteration 4 - 2026-01-29 15:20:33
**Phase:** Phase 4 (완료)
**완료:** 모든 검증 통과
**Planner 응답:** "승인, 완료"
**다음 액션:** <promise> 출력
```

**업데이트 시점:** 매 반복의 끝 (다음 반복 시작 전)

### 문서 역할

| 파일 | 내용 | 업데이트 시점 |
|------|------|--------------|
| **TASKS.md** | 요구사항 체크리스트, 진행 상태 | 요구사항 추가/완료 시 |
| **PROCESS.md** | 현재 Phase, 다음 단계, 의사결정 기록 | Phase 전환 시 |
| **VERIFICATION.md** | `/pre-deploy` 결과, Planner 응답 | 검증 실행 시 |
| **NOTES.md** | 기술적 결정, 블로커, 해결책 | 필요 시 |

### 문서 작성/수정

**우선순위: document-writer 에이전트 사용 (병렬 실행 가능)**

| 작업 | 방법 | 사용 시점 |
|------|------|----------|
| 새 문서 작성 | `Task(subagent_type="document-writer", model="haiku", ...)` | 초기 TASKS.md, PROCESS.md 생성 |
| 문서 업데이트 | `Task(subagent_type="document-writer", model="haiku", ...)` | Phase 전환, 검증 결과 기록 |
| 복잡한 문서 | `Task(subagent_type="document-writer", model="sonnet", ...)` | 아키텍처 문서, 상세 가이드 |

**대안: 스킬 사용 (순차 실행)**
- 새 문서: `Skill("docs-creator")`
- 문서 수정: `Skill("docs-refactor")`

**병렬 실행 패턴:**

```typescript
// ✅ 여러 문서 동시 작성 (빠름)
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md 생성: 요구사항 체크리스트 작성")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md 생성: Phase 1 시작 기록")
Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md 생성: 초기 상태")

// ❌ 순차 실행 (느림)
Skill("docs-creator")  // 대기...
Skill("docs-refactor") // 대기...
```

### 문서 템플릿

#### TASKS.md

```markdown
# Tasks - {{PROMPT}}

생성: {{TIMESTAMP}}
상태: Phase {{CURRENT_PHASE}}/4

## 요구사항 체크리스트

- [ ] 요구사항 1: [설명]
- [ ] 요구사항 2: [설명]
- [ ] 요구사항 3: [설명]

## 완료 상태

- 완료: 0 / 총 3
- 진행률: 0%
```

#### PROCESS.md

```markdown
# Process Log

## 현재 상태

- Phase: 1 (작업 실행)
- 진행 중: [현재 작업]
- 다음: [다음 작업]

## Phase 1: 작업 실행

**시작:** {{TIMESTAMP}}

### 완료 항목
- 항목 1

### 진행 중
- 항목 2

### 의사결정
- 결정 1: [이유]

## Phase 2: 검증

**대기 중**

## Phase 3: Planner 검증

**대기 중**

## Phase 4: 완료

**대기 중**
```

#### VERIFICATION.md

```markdown
# Verification Results

## /pre-deploy 검증

**실행 시각:** 미실행

**결과:**
- Typecheck: 대기
- Lint: 대기
- Build: 대기

## TODO 확인

**실행 시각:** 미실행

**결과:** pending/in_progress = ?

## Planner 검증

**실행 시각:** 미실행

**응답:** 대기 중
```

### Context Recovery Protocol

Context compaction 후 세션 재개 시:

```text
1. pwd 실행 → 작업 디렉토리 확인
2. ls .claude/ralph/ → 최신 세션 폴더 식별 (가장 큰 번호)
3. TASKS.md 읽기 → 요구사항 및 진행 상태 파악
4. PROCESS.md 읽기 → 현재 Phase 및 다음 단계 확인
5. VERIFICATION.md 읽기 → 검증 결과 확인
6. git log --oneline -10 → 최근 커밋 확인
7. 중단된 지점부터 작업 재개
```

</state_management>

---

<verification_workflow>

## 검증 워크플로우 (단계별 체크포인트)

### Phase 1: 작업 실행

```text
1. 원본 작업 요구사항 분석
2. 넘버링 결정 (ls .claude/ralph/)
3. .claude/ralph/00.[작업명]/ 폴더 생성 (한글 설명)
4. TASKS.md 작성 (체크리스트)
5. PROCESS.md 작성 (Phase 1 시작 기록)
6. 구현 실행 (병렬/백그라운드 활용)
7. 각 요구사항 완료 시 TASKS.md 업데이트
8. 주요 의사결정 시 PROCESS.md 기록
```

**병렬 에이전트 활용 예시:**

```typescript
// 문서 초기화 (동시 실행)
Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md 생성: 요구사항 체크리스트")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md 생성: Phase 1 시작 기록")

// 독립적인 기능 병렬 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="백엔드 API 구현")
Task(subagent_type="designer", model="sonnet",
     prompt="프론트엔드 UI 구현")
Task(subagent_type="document-writer", model="haiku",
     prompt="기술 문서 작성")
```

**Phase 1 완료 조건:** 모든 체크리스트 항목 완료 + 문서 업데이트

### Phase 2: 자동 검증

```text
1. PROCESS.md 업데이트 (Phase 2 시작)
2. Skill("pre-deploy") 실행 → typecheck/lint/build 검증
3. VERIFICATION.md 업데이트 (/pre-deploy 결과)
4. TaskList 조회 → pending/in_progress 확인
5. VERIFICATION.md 업데이트 (TODO 개수)
6. PROCESS.md 업데이트 (Phase 2 완료)
```

**병렬 에이전트 활용 예시:**

```typescript
// /pre-deploy 통과 후 다양한 관점에서 병렬 검토
Task(subagent_type="code-reviewer", model="opus",
     prompt="보안 검토: 인증/인가, 입력 검증, SQL Injection")
Task(subagent_type="code-reviewer", model="opus",
     prompt="성능 검토: DB 쿼리 최적화, 불필요한 리렌더")
Task(subagent_type="code-reviewer", model="opus",
     prompt="접근성 검토: ARIA 속성, 키보드 네비게이션, 색상 대비")

// 문서 업데이트 (병렬)
Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md: /pre-deploy 결과 + TODO 개수 기록")
Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md: Phase 2 완료 → Phase 3 시작 기록")
```

**Phase 2 완료 조건:** `/pre-deploy` 전체 통과 + TODO 0개 + 문서 업데이트

### Phase 3: 플래너 검증

```text
1. PROCESS.md 업데이트 (Phase 3 시작)
2. Planner 에이전트 생성 (model="opus")
3. 검증 요청 전송 (작업 내용 + 검증 결과 포함)
4. Planner 응답 대기
5. VERIFICATION.md 업데이트 (Planner 응답)
6. 승인/거절 확인
7. PROCESS.md 업데이트 (Phase 3 완료 또는 재작업)
```

**Phase 3 완료 조건:** Planner "승인" 응답 + 문서 업데이트

### Phase 4: 완료 출력

```text
1. PROCESS.md 업데이트 (완료 시각, 총 소요 시간)
2. TASKS.md 최종 확인 (모든 체크박스 체크)
3. <promise>{{PROMISE}}</promise> 출력
```

**Phase 4 조건:** Phase 1, 2, 3 순차적 완료 + 최종 문서 업데이트

### 실패 시 처리

| 실패 Phase | 조치 |
|-----------|------|
| Phase 1 | 미완료 항목 계속 구현 |
| Phase 2 | 에러 수정 후 재검증 |
| Phase 3 | Planner 피드백 반영 후 Phase 2부터 재실행 |

**절대 건너뛰지 말 것. 실패 시 수정 → 재검증 반복.**

</verification_workflow>

---

<architect_verification>

## 플래너 검증 (우회 불가)

### 호출 시점

Phase 1, 2 완료 후에만 호출:

```text
✅ 모든 요구사항 체크
✅ /pre-deploy 통과 (typecheck/lint/build)
✅ TODO 리스트 0개
→ 이제 Planner 호출
```

### 호출 방법

```typescript
Task(
  subagent_type="planner",
  model="opus",
  prompt=`구현 완료 검증 요청

【원본 작업】
{{PROMPT}}

【수행 내용】
- 요구사항 1: 완료 (구체적 설명)
- 요구사항 2: 완료 (구체적 설명)
- ...

【검증 결과】
- /pre-deploy: ✅ 통과 (typecheck/lint/build)
- TODO: ✅ 0개

완료 여부를 판단하고, 미흡한 점이 있다면 구체적으로 지적해주세요.`
)
```

### 응답 처리

| Planner 응답 | 조치 |
|---------------|------|
| "승인", "완료", "문제없음" | `<promise>` 출력 |
| "수정 필요", "미흡", "추가 작업" | 피드백 반영 → Phase 2부터 재실행 |

**Planner 검증 없이 `<promise>` 출력 시 즉시 작업 실패 처리.**

</architect_verification>

---

<multi_agent_examples>

## 멀티 에이전트 실전 예시

### Phase 1: 병렬 구현

**예시 1: 사용자 인증 기능 구현**

```typescript
// 백엔드 + 프론트엔드 + 문서를 동시에 구현
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`User 인증 API 구현:
- src/functions/auth.ts: login, logout, signup Server Functions
- inputValidator로 Zod 스키마 검증
- middleware로 세션 체크`)

Task(subagent_type="designer", model="sonnet",
     prompt=`로그인/회원가입 UI 구현:
- src/routes/login/-components/LoginForm.tsx
- src/routes/signup/-components/SignupForm.tsx
- TanStack Query로 Server Function 호출`)

Task(subagent_type="document-writer", model="haiku",
     prompt=`인증 API 문서 작성:
- docs/api/auth.md
- 엔드포인트, 파라미터, 응답 형식 기록`)
```

**예시 2: 여러 독립 기능 동시 구현**

```typescript
// Posts, Comments, Likes 기능을 각각 다른 executor에게
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Posts CRUD Server Functions 구현 (src/functions/posts.ts)")

Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Comments CRUD Server Functions 구현 (src/functions/comments.ts)")

Task(subagent_type="implementation-executor", model="sonnet",
     prompt="Likes 토글 Server Function 구현 (src/functions/likes.ts)")

Task(subagent_type="designer", model="sonnet",
     prompt="Post 목록/상세 UI 구현 (src/routes/posts/)")
```

**예시 3: 코드베이스 탐색 + 구현 병렬**

```typescript
// 기존 구조 파악과 동시에 문서 작업 시작
Task(subagent_type="explore", model="haiku",
     prompt="기존 인증 구조 분석: middleware, session, auth 관련 파일")

Task(subagent_type="explore", model="haiku",
     prompt="Prisma 스키마 분석: User, Session 모델 확인")

Task(subagent_type="document-writer", model="haiku",
     prompt="TASKS.md 초기화: 요구사항 체크리스트 작성")

Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md 초기화: Phase 1 시작 기록")
```

**예시 4: 계획 수립 전 분석 (analyst + architect + explore)**

```typescript
// 복잡한 기능 구현 전 요구사항과 아키텍처를 먼저 분석
Task(subagent_type="analyst", model="sonnet",
     prompt=`결제 시스템 요구사항 분석:
- 놓친 엣지 케이스 식별
- 가정 검증 (환불, 부분 결제, 구독 등)
- 범위 확장 위험 방지`)

Task(subagent_type="architect", model="opus",
     prompt=`결제 아키텍처 분석 및 제안:
- 현재 시스템 한계점
- 트랜잭션 처리 패턴
- 확장성 고려사항`)

Task(subagent_type="explore", model="haiku",
     prompt="기존 결제 관련 코드 탐색 및 의존성 파악")
```

### Phase 2: 병렬 검증

**예시 1: 다중 관점 코드 리뷰**

```typescript
// /pre-deploy 통과 후 여러 측면에서 동시 검토
Task(subagent_type="code-reviewer", model="opus",
     prompt=`보안 검토:
- SQL Injection 취약점
- XSS 취약점
- CSRF 보호 확인
- 인증/인가 로직 검증
- 민감 정보 노출 체크`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`성능 검토:
- N+1 쿼리 문제
- 불필요한 리렌더
- 메모이제이션 누락
- 번들 크기 최적화`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`접근성 검토:
- ARIA 속성 적절성
- 키보드 네비게이션
- 색상 대비 (WCAG AA)
- 스크린 리더 호환성`)
```

**예시 2: 검증 + 문서화 병렬**

```typescript
// 코드 리뷰와 동시에 검증 결과 문서화
Task(subagent_type="code-reviewer", model="opus",
     prompt="전체 코드 품질 검토")

Task(subagent_type="document-writer", model="haiku",
     prompt="VERIFICATION.md 업데이트: /pre-deploy 결과 기록")

Task(subagent_type="document-writer", model="haiku",
     prompt="PROCESS.md 업데이트: Phase 2 진행 상황 기록")
```

**예시 3: 특화 검증**

```typescript
// 특정 영역별 전문 검토
Task(subagent_type="code-reviewer", model="opus",
     prompt="Prisma 스키마 및 쿼리 최적화 검토")

Task(subagent_type="code-reviewer", model="opus",
     prompt="TanStack Query 사용 패턴 검토 (캐싱, invalidation)")

Task(subagent_type="code-reviewer", model="opus",
     prompt="TypeScript 타입 안정성 검토 (any 사용, 타입 가드)")
```

### 멀티 에이전트 전략

**언제 병렬 실행하는가:**

| 조건 | 병렬 실행 | 순차 실행 |
|------|----------|----------|
| 작업 독립성 | ✅ 독립적 | ❌ 의존성 있음 |
| 컨텍스트 | ✅ 분리 가능 | ❌ 공유 필요 |
| 결과 활용 | ✅ 개별 활용 | ❌ 다음 작업 입력 |

**병렬 실행 원칙:**

```text
✅ DO:
- API + UI + 문서 동시 구현
- 여러 파일/모듈 독립 작업
- 다양한 관점의 코드 리뷰
- 여러 문서 동시 업데이트
- 코드베이스 다중 영역 탐색

❌ DON'T:
- 순차 의존성 있는 작업
- 같은 파일 동시 수정
- 결과가 다음 작업 입력인 경우
```

**모델 선택 전략:**

```typescript
// 간단한 작업 → haiku (빠르고 저렴)
Task(subagent_type="explore", model="haiku", ...)
Task(subagent_type="document-writer", model="haiku", ...)

// 일반 구현 → sonnet (균형)
Task(subagent_type="implementation-executor", model="sonnet", ...)
Task(subagent_type="designer", model="sonnet", ...)

// 복잡한 분석/설계 → opus (고품질)
Task(subagent_type="planner", model="opus", ...)
Task(subagent_type="code-reviewer", model="opus", ...)
```

</multi_agent_examples>

---

<instructions>

## 작업 지침 (Loop-First Approach)

### 루프 진입 (첫 실행)

```
[RALPH MODE ON - ITERATION 1]
```

**즉시 실행 (순차):**
1. 원본 작업(`{{PROMPT}}`) 읽기
2. 세션 폴더 생성: `.claude/ralph/{{YYMMDD}}-{{N}}-{{작업명}}/`
   - `ls .claude/ralph/` → 오늘 날짜 폴더 찾기 → 다음 시퀀스 결정
3. 상태 문서 초기화 (병렬):
   ```typescript
   Task(subagent_type="document-writer", model="haiku",
        prompt="TASKS.md 생성: 요구사항 체크리스트")
   Task(subagent_type="document-writer", model="haiku",
        prompt="PROCESS.md 생성: Phase 1 시작 기록")
   Task(subagent_type="document-writer", model="haiku",
        prompt="VERIFICATION.md 생성: 초기 상태")
   Task(subagent_type="document-writer", model="haiku",
        prompt="ITERATION.md 생성: Iteration 1 시작")
   ```
4. Phase 1 시작 (작업 실행)

### 루프 재개 (다음 반복)

```
[RALPH MODE ON - ITERATION {{N}}]
```

**즉시 실행 (순차):**
1. ITERATION.md 읽기 → 이전 반복 결과 확인
2. VERIFICATION.md 읽기 → 마지막 검증 결과
3. TASKS.md 읽기 → 미완료 항목 확인
4. 실패 원인 파악 후 다음 액션 결정
5. ITERATION.md 업데이트 (새 반복 시작 기록)
6. 작업 계속

### Context Compaction 후 복구

```
[RALPH MODE ON - ITERATION {{N}} (재개)]
```

**복구 프로토콜 (순차):**
1. `pwd` → 작업 디렉토리 확인
2. `ls -lt .claude/ralph/` → 최신 세션 폴더 찾기 (날짜순 정렬)
3. `cat .claude/ralph/{{SESSION}}/ITERATION.md` → 반복 히스토리 확인
4. `cat .claude/ralph/{{SESSION}}/VERIFICATION.md` → 마지막 검증 결과
5. `cat .claude/ralph/{{SESSION}}/TASKS.md` → 미완료 항목
6. `git log --oneline -10` → 최근 커밋
7. 현재 Iteration 번호 식별 후 루프 재개

### 루프 실행 (각 반복마다)

**Phase 진행 (순차):**

**Phase 1: 작업 실행**
1. 병렬 실행 최대 활용 (독립 작업 동시 처리)
2. 백그라운드 실행 적극 사용 (빌드/테스트)
3. **에이전트 적극 위임 (혼자 하지 말 것)**
   - 독립 작업 → 즉시 에이전트 위임
   - 전문 지식 필요 → 도메인 에이전트 활용
   - 여러 작업 동시 → 병렬 에이전트 실행
   - 복잡도에 맞는 모델 선택 (haiku/sonnet/opus)
4. 요구사항 완료 시 → TASKS.md 체크박스 업데이트
5. Phase 완료 → PROCESS.md 업데이트

**Phase 2: 자동 검증**
1. **새로 실행:** `Skill("pre-deploy")` (이전 결과 재사용 금지)
2. **새로 조회:** `TaskList()` (pending/in_progress 확인)
3. VERIFICATION.md 업데이트 (검증 결과 + 시각 기록)
4. 실패 시 → ITERATION.md 업데이트 후 **즉시 다음 반복** (Phase 1로 복귀)

**Phase 3: Planner 검증**
1. Phase 2 통과 확인 (typecheck/lint/build + TODO 0개)
2. **새로 생성:** Planner 에이전트 (model="opus")
3. 검증 요청 (원본 작업 + 수행 내용 + 검증 결과 포함)
4. Planner 응답 대기
5. VERIFICATION.md 업데이트 (Planner 응답 기록)
6. 거절 시 → ITERATION.md 업데이트 후 **즉시 다음 반복** (Phase 1로 복귀)

**Phase 4: 완료 출력**
1. Phase 1, 2, 3 모두 통과 확인
2. ITERATION.md 최종 업데이트 (완료 시각, 총 반복 횟수)
3. PROCESS.md 최종 업데이트 (완료 시각, 총 소요 시간)
4. **완료 메시지 출력:**
```
[RALPH MODE - 작업 완료 (총 {{N}}회 반복)]
<promise>{{PROMISE}}</promise>
```

**문서 작성 에이전트 활용:**
- 새 문서 작성: `Task(subagent_type="document-writer", model="haiku", ...)`
- 기존 문서 업데이트: `Task(subagent_type="document-writer", model="haiku", ...)`
- 병렬 실행: 여러 문서 동시 업데이트 가능

### 루프 재개 (검증 실패 시)

```
[RALPH MODE ON - ITERATION {{N+1}} (이전 검증 실패)]
```

**즉시 실행:**
1. ITERATION.md 읽기 → 이전 실패 원인 확인
2. VERIFICATION.md 읽기 → 구체적 에러 확인
3. NOTES.md 업데이트 → 실패 원인 및 해결 방향 기록
4. Phase 1부터 재시작 (수정 작업)

**루프 종료 조건:** Phase 4에서 `<promise>` 출력할 때만

**절대 원칙:** 작업이 진정으로 완료될 때까지 루프 중단 불가

</instructions>

---

<core_loop_principle>

## 핵심 루프 원칙 (절대 규칙)

### 1. 무한 반복 = 완료 보장

Ralph는 **무한 루프 기반 스킬**. 작업이 진정으로 완료될 때까지 자동 반복.

```
Ralph = while (!완료) { 작업 실행 → 검증 → 실패 시 재시도 }
```

### 2. `<promise>` 출력 = 유일한 탈출구

루프 종료 조건:
- Phase 1: 모든 요구사항 100% 완료 ✅
- Phase 2: `/pre-deploy` + `TaskList` 통과 ✅
- Phase 3: Planner 승인 ✅
- Phase 4: `<promise>` 출력 → **루프 종료**

**하나라도 실패 → 즉시 다음 반복**

### 3. 매 반복 = 새로운 증거

**금지:** 이전 검증 결과 재사용
**필수:** 매 반복마다 새로운 검증 실행

```typescript
// ❌ 잘못된 패턴
"전에 /pre-deploy 통과했으니 완료"

// ✅ 올바른 패턴
Skill("pre-deploy")  // Iteration N에서 새로 실행
TaskList()           // Iteration N에서 새로 조회
Task(subagent_type="planner", ...) // Iteration N에서 새로 생성
```

### 4. ITERATION.md = 루프 추적

매 반복마다 ITERATION.md 업데이트:
- 반복 번호 (1, 2, 3, ...)
- 실패 원인 (typecheck 실패, TODO 남음, Planner 거절)
- 다음 액션 (무엇을 수정할 것인가)

**Context compaction 후에도 복구 가능.**

### 5. 루프 재개 = 자동

검증 실패 시 **자동으로** 다음 반복 시작:
- Phase 2 실패 → Iteration N+1
- Planner 거절 → Iteration N+1
- 추측 표현 발견 → 즉시 검증

**수동 중단 불가. Phase 4 도달까지 계속.**

### 6. 문서 = 루프 지속성

`.claude/ralph/{{SESSION}}/` 상태 문서:
- TASKS.md: 요구사항 체크리스트
- PROCESS.md: Phase 진행 상황
- VERIFICATION.md: 매 반복 검증 결과
- ITERATION.md: 반복 히스토리

**문서 없이는 루프 지속 불가.**

### 요약

| 원칙 | 설명 |
|------|------|
| **무한 반복** | 완료까지 자동 재시도 |
| **증거 기반** | 매 반복 새 검증 |
| **Planner 필수** | Phase 3 우회 불가 |
| **문서 추적** | ITERATION.md로 진행 기록 |
| **자동 재개** | 실패 시 즉시 다음 반복 |

</core_loop_principle>

---

**원본 작업:**
{{PROMPT}}

---

**루프 시작:**

[RALPH MODE ON - ITERATION 1]

작업을 시작합니다. Phase 4에서 `<promise>` 출력까지 계속 진행합니다.
