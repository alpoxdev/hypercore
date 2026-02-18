# Fallback Strategy Reference

> Agent Teams 미가용 시 Subagent 폴백 전략

---

<availability_check>

## 환경 확인

### 확인 방법

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

### 스크립트 사용

```bash
${CLAUDE_SCRIPTS_ROOT}/agent-teams/check-availability.sh
```

</availability_check>

---

<fallback_decision>

## 폴백 결정 매트릭스

| 조건 | 모드 |
|------|------|
| Agent Teams 활성화 + tmux/iTerm2 | Agent Teams (split-pane) |
| Agent Teams 활성화 + 일반 터미널 | Agent Teams (in-process) |
| Agent Teams 비활성화 | Subagent 폴백 |

### 모드별 특징

| 항목 | Agent Teams | Subagent 폴백 |
|------|-------------|---------------|
| 팀원 간 통신 | ✅ Inbox 메시징 | ❌ Lead 경유만 |
| 공유 Task List | ✅ | ❌ |
| 독립 컨텍스트 | ✅ 각자 유지 | ✅ 각자 유지 |
| 비용 | 높음 (N × 세션) | 중간 |
| 복잡도 | 높음 | 낮음 |
| 조율 | 자기 조율 가능 | Lead가 관리 |

</fallback_decision>

---

<fallback_patterns>

## 패턴별 폴백 구현

### 병렬-리뷰 폴백

```typescript
// Agent Teams 모드
if (AGENT_TEAMS_AVAILABLE) {
  TeamCreate({ team_name: "review-team" })
  Task({ subagent_type: "security-reviewer", team_name: "review-team", ... })
  Task({ subagent_type: "code-reviewer", team_name: "review-team", ... })
  Task({ subagent_type: "qa-tester", team_name: "review-team", ... })
}

// Subagent 폴백
else {
  // 병렬 Subagent 호출 (team_name 없음)
  Task({ subagent_type: "security-reviewer", prompt: "..." })
  Task({ subagent_type: "code-reviewer", prompt: "..." })
  Task({ subagent_type: "qa-tester", prompt: "..." })

  // 결과 수집 후 Lead가 직접 종합
}
```

### 파이프라인 폴백

```typescript
// Agent Teams 모드
if (AGENT_TEAMS_AVAILABLE) {
  TeamCreate({ team_name: "pipeline-team" })
  // TaskCreate with blockedBy
  // Task spawn (순차)
}

// Subagent 폴백
else {
  // 순차 Subagent 호출
  const researchResult = await Task({ subagent_type: "researcher", ... })
  const planResult = await Task({ subagent_type: "planner", prompt: `조사 결과: ${researchResult}...` })
  const implResult = await Task({ subagent_type: "implementation-executor", prompt: `계획: ${planResult}...` })
  await Task({ subagent_type: "tdd-guide", prompt: `구현 결과: ${implResult}...` })
}
```

### 크로스-레이어 폴백

```typescript
// Agent Teams 모드
if (AGENT_TEAMS_AVAILABLE) {
  TeamCreate({ team_name: "crosslayer-team" })
  // frontend, backend 병렬 → integration 순차
}

// Subagent 폴백
else {
  // 병렬 호출
  Task({ subagent_type: "designer", prompt: "프론트엔드..." })
  Task({ subagent_type: "implementation-executor", prompt: "백엔드..." })
  // 두 결과 수집 후
  Task({ subagent_type: "qa-tester", prompt: "통합 테스트..." })
}
```

### 가설-검증 폴백

```typescript
// Agent Teams 모드
if (AGENT_TEAMS_AVAILABLE) {
  TeamCreate({ team_name: "hypothesis-team" })
  // analyst × 3 병렬 → synthesizer 순차
}

// Subagent 폴백
else {
  // 병렬 분석
  Task({ subagent_type: "analyst", prompt: "보수적 관점..." })
  Task({ subagent_type: "analyst", prompt: "혁신적 관점..." })
  Task({ subagent_type: "analyst", prompt: "실용적 관점..." })
  // 결과 수집 후 Lead가 직접 종합 또는 architect 위임
  Task({ subagent_type: "architect", prompt: "종합 분석..." })
}
```

</fallback_patterns>

---

<fallback_limitations>

## 폴백 제한사항

| 기능 | Agent Teams | Subagent 폴백 |
|------|-------------|---------------|
| 팀원 간 DM | ✅ SendMessage | ❌ |
| 브로드캐스트 | ✅ | ❌ |
| 공유 Task List | ✅ | ❌ |
| 의존성 관리 | ✅ blockedBy | 수동 순차 호출 |
| 팀원 상태 확인 | ✅ TeamStatus | 결과 대기만 |
| 중간 조율 | ✅ 메시지 중계 | Lead 직접 관리 |
| 정리 | ✅ shutdown + TeamDelete | 자동 종료 |

### 폴백 시 추가 작업

| 작업 | 설명 |
|------|------|
| 컨텍스트 전달 | 각 Subagent에 이전 결과 명시적 포함 |
| 결과 수집 | Lead가 각 결과 수동 종합 |
| 순서 관리 | await로 순차 실행 보장 |

</fallback_limitations>

---

<fallback_best_practices>

## 폴백 베스트 프랙티스

### 1. 컨텍스트 전달

```typescript
// ❌ 잘못된 방식 (컨텍스트 부족)
Task({ subagent_type: "planner", prompt: "계획 수립" })

// ✅ 올바른 방식 (충분한 컨텍스트)
Task({
  subagent_type: "planner",
  prompt: `계획 수립:

    【조사 결과】
    ${researchResult}

    【요구사항】
    ${requirements}

    【제약사항】
    ${constraints}`
})
```

### 2. 결과 종합

```typescript
// 병렬 결과 수집
const [securityResult, qualityResult, testResult] = await Promise.all([
  Task({ subagent_type: "security-reviewer", ... }),
  Task({ subagent_type: "code-reviewer", ... }),
  Task({ subagent_type: "qa-tester", ... })
])

// Lead가 직접 종합
const summary = `
## 리뷰 종합

### 보안
${securityResult}

### 품질
${qualityResult}

### 테스트
${testResult}

### 권장사항
[Lead 분석 기반 권장사항]
`
```

### 3. 에러 처리

```typescript
try {
  const result = await Task({ subagent_type: "implementer", ... })
} catch (error) {
  // 재시도 또는 대체 에이전트
  const result = await Task({ subagent_type: "general-purpose", ... })
}
```

### 4. 비용 최적화

| 전략 | 적용 |
|------|------|
| 모델 티어링 | 탐색=haiku, 구현=sonnet, 분석=opus |
| 병렬 최대화 | 독립 작업 동시 실행 |
| 불필요 호출 제거 | 간단한 작업은 Lead 직접 처리 |

</fallback_best_practices>

---

<migration_guide>

## Agent Teams 전환 가이드

### Subagent → Agent Teams

| Subagent | Agent Teams |
|----------|-------------|
| `Task({ ... })` | `Task({ ..., team_name: "...", name: "..." })` |
| 결과 직접 수집 | TaskList + 메시지 |
| 자동 종료 | shutdown_request + TeamDelete |

### 코드 변환 예시

```typescript
// Before: Subagent
Task({ subagent_type: "researcher", prompt: "..." })
Task({ subagent_type: "implementer", prompt: "..." })

// After: Agent Teams
TeamCreate({ team_name: "feature-team" })
Task({ subagent_type: "researcher", team_name: "feature-team", name: "r1", prompt: "..." })
Task({ subagent_type: "implementer", team_name: "feature-team", name: "impl1", prompt: "..." })
// ...작업 완료 후
SendMessage({ type: "shutdown_request", recipient: "r1" })
SendMessage({ type: "shutdown_request", recipient: "impl1" })
TeamDelete()
```

</migration_guide>
