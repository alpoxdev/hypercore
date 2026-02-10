# Agent Teams 활용 가이드

> 스킬에서 Agent Teams를 효과적으로 활용하는 방법

---

<availability_check>

## 환경 확인

### 스크립트 사용

```bash
# Agent Teams 사용 가능 여부 확인
.claude/scripts/agent-teams/check-availability.sh

# tmux 환경 세팅
.claude/scripts/agent-teams/setup-tmux.sh
```

### 프로그래매틱 확인

```bash
# 1. 환경변수 확인
if [[ "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" == "1" ]]; then
    AGENT_TEAMS_AVAILABLE=true
fi

# 2. settings.json 확인 (글로벌 + 프로젝트)
for f in ~/.claude/settings.json .claude/settings.json; do
    if grep -q '"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS".*"1"' "$f" 2>/dev/null; then
        AGENT_TEAMS_AVAILABLE=true
    fi
done

# 3. 에이전트 디렉토리 확인
if [[ -d ".claude/agents" ]] && [[ $(ls .claude/agents/*.md 2>/dev/null | wc -l) -gt 0 ]]; then
    AGENTS_AVAILABLE=true
fi
```

</availability_check>

---

<subagent_vs_teams>

## Subagent vs Agent Teams

| 항목 | Subagents | Agent Teams |
|------|-----------|-------------|
| **컨텍스트** | 자체 컨텍스트, 결과만 반환 | 자체 컨텍스트, 완전 독립 |
| **통신** | 메인 에이전트에게만 보고 | 팀원끼리 직접 메시징 |
| **조율** | 메인 에이전트가 모든 작업 관리 | 공유 태스크 리스트로 자기조율 |
| **토큰 비용** | 낮음 (결과 요약) | 높음 (각 팀원 별도 인스턴스) |
| **적합** | 결과만 필요한 집중 작업 | 토론과 협업이 필요한 복잡한 작업 |

### 선택 기준

| 상황 | 권장 |
|------|------|
| 결과만 필요, 집중된 작업 | Subagent |
| 조율/토론/독립적 결정 필요 | Agent Teams |
| 토큰 비용 민감 | Subagent 또는 단독 세션 |
| 병렬 연구/리뷰 | Agent Teams |
| 단순 작업 (1-2 파일) | 직접 처리 |

</subagent_vs_teams>

---

<decision_matrix>

## 사용 결정 매트릭스

| 조건 | 권장 방식 | 이유 |
|------|----------|------|
| Agent Teams 비활성화 | Task (subagent) | 환경 미지원 |
| 단순 작업 (1-2 파일) | 직접 처리 | 오버헤드 불필요 |
| 독립적 병렬 작업 | Agent Teams | 진정한 병렬 실행 |
| 팀원 간 소통 필요 | Agent Teams | 메시지 교환 가능 |
| 순차 의존성 있음 | blockedBy 또는 Subagent | 의존성 관리 |
| tmux/iTerm2 환경 | split-pane 모드 | 시각적 모니터링 |
| VS Code/일반 터미널 | in-process 모드 | 호환성 |

</decision_matrix>

---

<teammate_modes>

## teammateMode 설정

### 모드별 특징

| 모드 | 특징 | 권장 상황 |
|------|------|----------|
| **auto** | tmux 세션이면 split-pane, 아니면 in-process | 기본값 |
| **tmux** | 각 팀원 별도 pane (tmux/iTerm2 필요) | 3명+ 팀 |
| **in-process** | 단일 터미널, Shift+Up/Down 전환 | 2명 이하 팀, VS Code |

### 설정 방법

```json
// ~/.claude/settings.json
{
  "teammateMode": "auto",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### tmux 세션 시작

```bash
# 새 tmux 세션
tmux new -s claude

# iTerm2 (macOS)
tmux -CC
```

### 터미널 지원 현황

| 터미널 | Split Panes |
|--------|-------------|
| tmux | ✅ |
| iTerm2 | ✅ |
| WezTerm | ❌ (요청 중) |
| Zellij | ❌ (요청 중) |
| VS Code | ❌ |
| Windows Terminal | ❌ |
| Ghostty | ❌ |

</teammate_modes>

---

<usage_patterns>

## 활용 패턴

### 패턴 1: 환경 감지 후 분기

```typescript
if (AGENT_TEAMS_AVAILABLE && 복잡한_병렬_작업) {
    TeamCreate({ team_name: "feature-x", description: "..." })
    Task({ subagent_type: "...", team_name: "feature-x", name: "worker-1" })
    Task({ subagent_type: "...", team_name: "feature-x", name: "worker-2" })
} else {
    // Subagent 폴백
    Task({ subagent_type: "...", ... })
}
```

### 패턴 2: 팀 생성 + 태스크 분배

```typescript
// 1. 팀 생성
TeamCreate({ team_name: "review-team", description: "코드 리뷰" })

// 2. 태스크 생성
TaskCreate({ subject: "보안 검토", description: "...", activeForm: "보안 검토 중" })
TaskCreate({ subject: "성능 검토", description: "...", activeForm: "성능 검토 중" })

// 3. 팀원 스폰 (병렬)
Task({ subagent_type: "security-reviewer", team_name: "review-team", name: "security" })
Task({ subagent_type: "code-reviewer", team_name: "review-team", name: "performance" })

// 4. 완료 대기 후 종합
TaskList()
```

### 패턴 3: Plan-First (비용 최적화)

```typescript
// Phase 1: 계획 (저렴)
EnterPlanMode()
// 코드베이스 탐색 + 구현 계획 수립

// Phase 2: 실행 (고비용, 고속)
TeamCreate({ team_name: "impl-team" })
// 승인된 계획을 팀에 전달하여 병렬 실행
```

</usage_patterns>

---

<send_message>

## SendMessage 사용법

### 메시지 타입

| 타입 | 용도 |
|------|------|
| **message** | 특정 팀원에게 DM |
| **broadcast** | 모든 팀원에게 전송 (비용 높음) |
| **shutdown_request** | 팀원에게 종료 요청 |
| **shutdown_response** | 종료 요청에 응답 |
| **plan_approval_response** | 계획 승인/거부 |

### 사용 예시

```json
// DM
{ "type": "message", "recipient": "researcher",
  "content": "...", "summary": "Brief status" }

// 브로드캐스트 (신중히!)
{ "type": "broadcast", "content": "...", "summary": "Critical" }

// 종료 요청
{ "type": "shutdown_request", "recipient": "researcher", "content": "완료" }

// 종료 응답
{ "type": "shutdown_response", "request_id": "abc-123", "approve": true }
```

**중요**: 텍스트 출력은 팀원에게 보이지 않음. 반드시 SendMessage 사용.

</send_message>

---

<keyboard_shortcuts>

## 키보드 단축키 (in-process)

| 단축키 | 기능 |
|--------|------|
| `Shift+Up/Down` | 팀원 선택 |
| `Enter` | 선택된 팀원 세션 보기 |
| `Escape` | 현재 턴 중단 |
| `Ctrl+T` | 태스크 목록 토글 |
| `Shift+Tab` | Delegate mode 전환 |

</keyboard_shortcuts>

---

<best_practices>

## 베스트 프랙티스

| 원칙 | 설명 |
|------|------|
| **환경 감지 우선** | Agent Teams 사용 전 항상 가용성 확인 |
| **폴백 준비** | Subagent 방식으로 폴백 로직 구현 |
| **풍부한 컨텍스트** | 팀원은 Lead 대화 기록 미상속. spawn 시 상세 프롬프트 필수 |
| **적절한 태스크 크기** | 팀원당 5-6개 태스크 권장 |
| **파일 충돌 방지** | 한 파일은 한 팀원만 수정 |
| **모델 라우팅** | Lead: Opus, Teammates: Sonnet |
| **팀 정리** | 작업 완료 후 shutdown → TeamDelete |
| **Delegate Mode** | Lead가 직접 구현 방지, 조율에 집중 |
| **Plan Approval** | 위험한 작업 전 계획 승인 요구 |

### Context 제공 예시

```
❌ "인증 모듈 검토해"
✅ "src/auth/ 인증 모듈을 보안 취약점 관점으로 검토해.
   토큰 핸들링, 세션 관리, 입력 검증에 집중해.
   JWT 토큰을 httpOnly 쿠키에 저장함."
```

</best_practices>

---

<common_mistakes>

## 흔한 실수와 해결책

| 문제 | 원인 | 해결책 |
|------|------|--------|
| Lead가 직접 구현 | 위임 대신 본인이 작업 | `Shift+Tab` delegate mode |
| 팀원 안 보임 | in-process 전환 안 함 | `Shift+Down` 팀원 순환 |
| 과도한 권한 프롬프트 | 매번 승인 요청 | permission settings 사전 승인 |
| 팀원 에러 정지 | 예외 처리 실패 | 추가 지시 또는 대체 팀원 spawn |
| Lead 조기 종료 | 팀원 완료 전 마무리 | "모든 팀원 완료까지 대기" 명시 |
| 고아 tmux 세션 | 정리 안 됨 | `tmux ls` → `tmux kill-session` |
| 4+ 팀원 동시 spawn | tmux race condition | 2-3개씩 순차 spawn |

</common_mistakes>

---

<limitations>

## 제한사항 및 주의사항

### 아키텍처 제한

| 제한 | 설명 |
|------|------|
| 세션 재개 불가 | `/resume` 시 in-process 팀원 복원 안 됨 |
| 세션당 한 팀 | 중첩 팀 불가 |
| 리더십 고정 | 팀 생성 세션이 전체 수명 동안 리더 |
| 권한 상속 | 팀원별 개별 권한 설정 불가 |
| 종료 지연 | 현재 작업 완료까지 대기 |
| Working Dir 공유 | 팀원에 다른 repo 할당 불가 |

### 알려진 버그

| 버그 | 영향 | 워크어라운드 |
|------|------|-------------|
| 컨텍스트 압축 시 팀 손실 | Lead가 팀 인식 상실 | 200K 토큰 전 작업 완료 |
| tmux split-pane race | `send-keys` corruption | 2-3개씩 순차 spawn |
| PermissionRequest hook 미작동 | 서브에이전트 권한 hook 무시 | 사전 승인 또는 수동 확인 |
| TaskUpdate 상태 비동기 | TeamDelete 후 상태 손실 | TeamDelete 후 재확인 |

</limitations>

---

<cost_optimization>

## 비용 최적화

### 토큰 비용 구조

- 솔로 세션: ~200k tokens
- 3인 팀: ~800k tokens (4x)
- 각 팀원 별도 컨텍스트 윈도우

### 비용 절감 팁

| 전략 | 효과 |
|------|------|
| 모델 혼합 (Opus Lead + Sonnet Teammates) | ~40% 절감 |
| Plan-First 패턴 | 계획에서 실패 조기 발견 |
| 적절한 범위 지정 | 과도한 탐색 방지 |
| 단순 작업은 단독 세션 | 조율 오버헤드 제거 |

</cost_optimization>

---

<ideal_use_cases>

## 이상적인 사용 사례

| 패턴 | 설명 |
|------|------|
| **경쟁 가설 디버깅** | 여러 버그 원인 병렬 검증 |
| **다각도 코드 리뷰** | 보안/성능/테스트 동시 검토 |
| **Cross-Layer 개발** | 프론트엔드/백엔드/테스트 분리 |
| **연구 및 탐색** | 여러 접근법 병렬 탐색 |
| **QA Swarm** | 다양한 품질 관점 동시 테스트 |

### 부적합한 경우

- 순차 작업
- 같은 파일 편집
- 의존성 많은 작업
- 단순 단일 파일 수정

</ideal_use_cases>

---

<reference>

## 참조

| 문서 | 경로 |
|------|------|
| 공식 문서 | https://code.claude.com/docs/en/agent-teams |
| 환경 확인 스크립트 | `.claude/scripts/agent-teams/check-availability.sh` |
| tmux 세팅 스크립트 | `.claude/scripts/agent-teams/setup-tmux.sh` |
| agent-teams-setup 스킬 | `.claude/skills/agent-teams-setup/SKILL.md` |

</reference>
