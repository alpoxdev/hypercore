# Agent Teams 활용 가이드

> **Agent Teams를 기본으로 사용한다.** 토큰 비용(5-7x)은 Model Routing으로 최적화.

---

<tool_primitives>

## 7가지 Tool Primitives

| 도구 | 역할 | 토큰 영향 |
|------|------|----------|
| **TeamCreate** | 팀 생성, config.json + task 디렉토리 | 낮음 |
| **TaskCreate** | 작업 단위 정의 (JSON) | 낮음 |
| **TaskUpdate** | 상태 변경 (pending→in_progress→completed) | 낮음 |
| **TaskList** | 사용 가능한 작업 조회 | 낮음 |
| **Task** (team_name) | 팀원 스폰 | **높음** (~200k/팀원) |
| **SendMessage** | 팀원 간 메시징 | 중간 |
| **TeamDelete** | 팀 정리 | 낮음 |

### 실행 흐름

```
SETUP:     TeamCreate → TaskCreate × N → Task(team_name) × N
EXECUTION: TaskList → TaskUpdate(claim) → 작업 → TaskUpdate(complete) → SendMessage
TEARDOWN:  shutdown_request × N → TeamDelete
```

</tool_primitives>

---

<mandatory_rules>

## 필수 사용 규칙

| 상황 | 행동 |
|------|------|
| **기본 (대부분 작업)** | Agent Teams 사용 |
| Agent Teams 미가용 | Task 병렬 호출 (폴백) |
| 단일 파일 읽기/수정 | 직접 처리 (예외) |
| 단순 질문 응답 | 직접 처리 (예외) |

> **"굳이 Agent Teams 안 써도 될 것 같은데" 판단 금지.**

### 수명주기 필수 관리

```typescript
// 시작
TeamCreate({ team_name: "...", description: "..." })
Task({ subagent_type: "...", team_name: "...", name: "worker-1", model: "sonnet" })

// 완료 후 정리 (필수)
SendMessage({ type: "shutdown_request", recipient: "worker-1", ... })
TeamDelete()
```

</mandatory_rules>

---

<subagent_vs_teams>

## Subagent vs Agent Teams

| 항목 | Subagent (Task) | Agent Teams (기본) |
|------|-----------------|-------------------|
| **통신** | 메인에게만 보고 | 팀원 간 직접 메시징 |
| **조율** | 메인이 관리 | 공유 TaskList로 자기조율 |
| **토큰** | 낮음 | Model Routing으로 최적화 |

### 선택 기준

```
기본 (대부분 작업)          → Agent Teams
단일 파일 읽기/수정         → 직접 처리
```

**Subagent 대신 Agent Teams를 쓴다.** 토큰 비용은 Model Routing(Sonnet/Haiku)으로 해결.

</subagent_vs_teams>

---

<cost_optimization>

## 토큰 비용 최적화

### 비용 구조

| 구성 | 토큰 | 배수 |
|------|------|------|
| Solo Session | ~200k | 1x |
| 3 Subagents | ~440k | 2.2x |
| 3-Person Team | ~800k | **4x** |
| Plan Mode Team | - | **7x** |

### 절약 전략 (우선순위순)

| 전략 | 효과 | 방법 |
|------|------|------|
| **Model Routing** | 40% 절감 | Lead: Opus, Teammates: Sonnet/Haiku |
| **Plan-First** | 낭비 방지 | 계획(10k) → 승인 → 실행 |
| **팀 즉시 정리** | 유휴 비용 제거 | 완료 즉시 shutdown + TeamDelete |
| **message > broadcast** | N배 절감 | broadcast = 팀원 수 × 비용 |
| **스폰 프롬프트 간결** | 초기 비용 감소 | CLAUDE.md/MCP/Skills 자동 로드됨 |

### Model Routing 패턴

```typescript
// Lead: Opus (복잡한 조율)
// Teammates: Sonnet (대부분 작업)
Task({ subagent_type: "researcher", model: "sonnet", team_name: "...", ... })

// 단순 탐색: Haiku
Task({ subagent_type: "explore", model: "haiku", ... })
```

</cost_optimization>

---

<usage_patterns>

## 활용 패턴

### Plan-First (권장)

```typescript
// Phase 1: 계획 (~10k 토큰, 저렴)
EnterPlanMode()
// 코드베이스 탐색 + 구현 계획 수립
// 사용자 승인

// Phase 2: 실행 (고비용, 고속)
TeamCreate({ team_name: "impl-team" })
Task({ ..., model: "sonnet" })  // 승인된 계획을 병렬 실행
```

### 팀 + 태스크 분배

```typescript
TeamCreate({ team_name: "review-team", description: "코드 리뷰" })
TaskCreate({ subject: "보안 검토", description: "...", activeForm: "보안 검토 중" })
TaskCreate({ subject: "성능 검토", description: "...", activeForm: "성능 검토 중" })
Task({ subagent_type: "security-reviewer", team_name: "review-team", name: "security", model: "sonnet" })
Task({ subagent_type: "code-reviewer", team_name: "review-team", name: "performance", model: "sonnet" })
```

</usage_patterns>

---

<send_message>

## SendMessage 타입

| 타입 | 용도 | 비용 |
|------|------|------|
| **message** | 특정 팀원에게 DM | 낮음 |
| **broadcast** | 모든 팀원에게 전송 | **높음** (N배) |
| **shutdown_request** | 종료 요청 | 낮음 |
| **shutdown_response** | 종료 응답 | 낮음 |

```json
// DM (권장)
{ "type": "message", "recipient": "researcher", "content": "...", "summary": "..." }

// 종료
{ "type": "shutdown_request", "recipient": "researcher", "content": "완료" }
```

</send_message>

---

<teammate_modes>

## teammateMode 설정

| 모드 | 특징 | 권장 |
|------|------|------|
| **auto** | tmux면 split-pane, 아니면 in-process | 기본값 |
| **tmux** | 각 팀원 별도 pane | 3명+ 팀 |
| **in-process** | 단일 터미널, Shift+Up/Down 전환 | VS Code |

```json
// ~/.claude/settings.json
{ "teammateMode": "auto", "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

### 키보드 단축키 (in-process)

| 단축키 | 기능 |
|--------|------|
| `Shift+Up/Down` | 팀원 선택 |
| `Shift+Tab` | Delegate mode |
| `Ctrl+T` | 태스크 목록 |

</teammate_modes>

---

<best_practices>

## 베스트 프랙티스

| 원칙 | 방법 |
|------|------|
| **일단 Agent Teams** | 단순 작업 아니면 무조건 사용 |
| **Model Routing** | Lead: Opus, Teammates: Sonnet/Haiku |
| **Plan-First** | 큰 작업은 계획 승인 후 실행 |
| **풍부한 컨텍스트** | 팀원은 Lead 대화 미상속, 상세 프롬프트 필수 |
| **적정 태스크** | 팀원당 5-6개, 명확한 결과물 |
| **파일 충돌 방지** | 한 파일 = 한 팀원 |
| **즉시 정리** | 완료 시 shutdown → TeamDelete |

### Context 예시

```
❌ "인증 모듈 검토해"
✅ "src/auth/ 인증 모듈 보안 검토. 토큰 핸들링/세션 관리/입력 검증 집중. JWT는 httpOnly 쿠키 저장."
```

</best_practices>

---

<common_mistakes>

## 흔한 실수

| 문제 | 해결책 |
|------|--------|
| Lead가 직접 구현 | `Shift+Tab` delegate mode |
| 팀원 안 보임 | `Shift+Down` 팀원 순환 |
| Lead 조기 종료 | "모든 팀원 완료까지 대기" 명시 |
| 고아 tmux 세션 | `tmux ls` → `tmux kill-session` |
| 4+ 동시 spawn | 2-3개씩 순차 spawn |

</common_mistakes>

---

<limitations>

## 제한사항

| 제한 | 설명 |
|------|------|
| 세션 재개 불가 | `/resume` 시 in-process 팀원 복원 안 됨 |
| 세션당 한 팀 | 중첩 팀 불가 |
| 리더십 고정 | 팀 생성 세션이 전체 수명 동안 리더 |
| 컨텍스트 압축 | 200K 전 작업 완료 권장 |

</limitations>

---

<use_cases>

## 활용 예시

| 작업 | 팀 구성 |
|------|--------|
| **리서치** | researcher 2-3 + explore 1 |
| **코드 리뷰** | security + performance + test 검토자 |
| **기능 개발** | 프론트 + 백엔드 + 테스트 |
| **디버깅** | 각 가설별 팀원 |
| **QA** | pages + links + seo + a11y |
| **리팩토링** | 파일/모듈별 팀원 분배 |

### 예외 (직접 처리)

- 단일 파일 읽기/수정
- 단순 질문 응답

</use_cases>

---

<reference>

## 참조

| 문서 | URL |
|------|-----|
| 공식 문서 | https://code.claude.com/docs/en/agent-teams |
| 비용 관리 | https://code.claude.com/docs/en/costs |
| 토큰 최적화 리서치 | .claude/research/08.Claude_Code_Agent_Teams_토큰_최적화_가이드.md |

</reference>
