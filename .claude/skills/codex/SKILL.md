---
name: codex
description: Claude와 OpenAI Codex 페어 프로그래밍. 자체 codex-mcp 서버로 자유 협업. Claude(창의적) + Codex(꼼꼼함) 강점 활용.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Codex Pair Programming Skill

> Claude와 자체 codex-mcp 서버를 통한 페어 프로그래밍. 상황에 따라 유동적으로 역할 분담.

---

<overview>

## 핵심 개념

**Claude + Codex 페어 프로그래밍:**
- **Claude**: 창의적 설계, 아키텍처, 새로운 접근법, 문제 재정의
- **Codex**: 꼼꼼한 구현, 엣지케이스 검증, 리뷰, 정확한 코드 생성

**자체 codex-mcp 서버:**
- Rust로 구현된 MCP 바이너리가 OpenAI Responses API를 직접 호출
- 외부 Codex CLI 불필요, 속도 빠름, 컨텍스트 트렁케이션 없음
- `thread_id` 기반 세션 연속성 (이전 대화 맥락 유지)

**협업 방식:**
- 자유 협업: 상황에 따라 유동적 역할 분담
- 분업 처리: 의견 다를 때만 사용자 선택
- Agent Teams: 복잡한 작업 시 팀 구성

</overview>

---

<prerequisites>

## 사전 요구사항

### codex-mcp 등록 필수

앱 설정 → **OpenAI / Codex** 탭에서:
1. OpenAI API 키 입력 및 저장
2. **등록** 버튼 클릭 (Claude Code에 codex-mcp 바이너리 자동 등록)

또는 수동 등록:
```bash
# codex-mcp 바이너리 빌드
cargo build -p codex-mcp --release

# Claude Code에 등록
claude mcp add -s user -e OPENAI_API_KEY=sk-... codex -- /path/to/target/release/codex-mcp
```

**미설정 시:** 스킬 실행 전 설정 안내 후 중단

</prerequisites>

---

<when_to_use>

## 사용 시점

| 상황 | 예시 |
|------|------|
| **복잡한 기능 구현** | "결제 시스템 리팩토링" |
| **코드 리뷰 + 개선** | "이 PR 리뷰하고 개선해줘" |
| **설계 + 구현 분리** | "아키텍처 설계 후 구현" |
| **병렬 작업** | "프론트/백엔드 동시 작업" |
| **세컨드 오피니언** | "이 접근법 괜찮은지 검토" |
| **엣지케이스 검증** | "이 코드 빈틈 찾아줘" |

## 호출 방법

```bash
/codex 사용자 인증 시스템 구현

/codex --review 최근 커밋 리뷰

/codex --design 실시간 알림 아키텍처 설계
```

</when_to_use>

---

<codex_mcp_tools>

## MCP 도구

### mcp__codex__codex — 새 태스크 시작

```typescript
mcp__codex__codex({
  prompt: "작업 지시",
  working_directory: "/path/to/project",
  model: "gpt-4o"  // 선택 (기본값: gpt-4o)
})
// 반환: 결과 텍스트 + thread_id
```

### mcp__codex__codex_reply — 세션 이어가기

```typescript
mcp__codex__codex_reply({
  thread_id: "이전 codex 호출에서 받은 thread_id",
  prompt: "후속 지시 또는 리뷰 요청"
})
// 반환: 결과 텍스트 (같은 thread_id로 계속 사용 가능)
```

### 리뷰 패턴 (codex → codex_reply 2단계)

```typescript
// 1단계: 코드 분석
const result = mcp__codex__codex({
  prompt: "이 프로젝트의 src/auth/ 코드를 읽고 분석해줘",
  working_directory: "/path/to/project"
})

// 2단계: 리뷰 요청 (세션 이어서)
mcp__codex__codex_reply({
  thread_id: result.thread_id,
  prompt: "분석한 코드 리뷰: 보안, 성능, 엣지케이스 집중"
})
```

</codex_mcp_tools>

---

<collaboration_modes>

## 협업 모드

| 모드 | 트리거 | Claude 역할 | Codex 역할 |
|------|--------|-------------|------------|
| **Solo+Review** | 단순 작업, 빠른 수정 | 전체 구현 | 최종 리뷰 |
| **Sequential** | 설계→구현 필요 | 아키텍처, 설계 | 구현, 테스트 |
| **Parallel** | 독립 작업 가능 | 창의적 부분 (A) | 꼼꼼한 부분 (B) |
| **Discussion** | 의견 필요, 트레이드오프 | 관점 A 제시 | 관점 B 제시 |
| **Teams** | 복잡한 멀티태스크 | 팀원으로 참여 | **Team Lead** |

### Codex Team Lead 원칙

> **Agent Teams 모드에서 Codex가 Team Lead 역할 담당**

**Codex Lead 강점:**
- 태스크 분해 및 추적 정밀
- 엣지케이스 누락 방지
- 코드 품질 게이트키핑
- 병합 충돌 사전 감지

### 자동 모드 선택

```
복잡도 판단 (Sequential Thinking)
    │
    ├─ 단순 (1-2 파일) ────────→ Solo+Review
    │
    ├─ 보통 (3-5 파일) ────────→ Sequential 또는 Parallel
    │
    ├─ 복잡 (6+ 파일) ─────────→ Teams
    │
    └─ 의견 분기 ──────────────→ Discussion → 사용자 선택
```

</collaboration_modes>

---

<workflow>

## 실행 흐름

| Phase | 작업 | 도구 |
|-------|------|------|
| **0** | MCP 확인 + 복잡도 분석 | ToolSearch, sequentialthinking |
| **1** | 협업 모드 결정 | sequentialthinking |
| **2** | 역할 분담 + 작업 배분 | TodoWrite |
| **3** | 협업 실행 | Task (codex agent) + 직접 작업 |
| **4** | 결과 통합 + 충돌 해소 | 필요 시 AskUserQuestion |
| **5** | 최종 검증 + 커밋 | code-reviewer, git |

### Phase 0: 환경 확인

```typescript
// MCP 확인
ToolSearch("codex")
→ mcp__codex__codex 가용 여부 확인
→ 미설정 시 설정 안내 후 중단

// 복잡도 분석
sequentialthinking({
  thought: "작업 복잡도 판단: 파일 수, 모듈 범위, 아키텍처 변경 여부"
})
```

### Phase 2-3: 역할 분담 및 실행

**Solo+Review 모드:**
```typescript
// Claude가 구현
Edit/Write → 코드 작성

// Codex가 리뷰 (MCP 2단계)
const result = mcp__codex__codex({
  prompt: "git diff 결과를 분석해줘: [diff 내용]",
  working_directory: cwd
})
mcp__codex__codex_reply({
  thread_id: result.thread_id,
  prompt: "엣지케이스, 버그, 보안 취약점 리뷰"
})
```

**Sequential 모드:**
```typescript
// Phase A: Claude 설계
sequentialthinking → 아키텍처 설계
→ 인터페이스 정의, 데이터 플로우

// Phase B: Codex 구현 (MCP)
Task({
  subagent_type: 'codex',
  prompt: `
    Claude 설계 기반 구현:
    ${설계문서}

    구현 요구사항:
    - 모든 엣지케이스 처리
    - 타입 안정성 보장
    - 테스트 포함
  `
})
```

**Parallel 모드:**
```typescript
// 동시 실행
Task({
  subagent_type: 'codex',
  prompt: '백엔드 API 구현: [상세 요구사항]'
})

// Claude: 프론트엔드 구현 (직접)
Edit/Write → 컴포넌트, 훅 작성
```

**Discussion 모드:**
```typescript
// Codex 의견 수집
Task({
  subagent_type: 'codex',
  prompt: '이 접근법의 장단점 분석: [접근법 A]'
})

// Claude 의견 제시
sequentialthinking → 접근법 B 분석

// 충돌 시 사용자 선택
AskUserQuestion({
  questions: [{
    question: "어떤 접근법을 선택하시겠습니까?",
    header: "Approach",
    options: [
      { label: "접근법 A (Codex)", description: "[장점/단점]" },
      { label: "접근법 B (Claude)", description: "[장점/단점]" },
      { label: "하이브리드", description: "두 접근법 조합" }
    ]
  }]
})
```

**Teams 모드 (Codex Lead):**
```typescript
if (AGENT_TEAMS_AVAILABLE) {
  TeamCreate({
    team_name: "pair-codex",
    description: "페어 프로그래밍",
    agent_type: "codex"
  })

  Task({
    subagent_type: 'implementation-executor',
    team_name: 'pair-codex',
    name: 'claude-impl',
    prompt: '창의적 설계 + 구현: [범위 A]'
  })

  Task({
    subagent_type: 'architect',
    team_name: 'pair-codex',
    name: 'claude-arch',
    prompt: '아키텍처 설계: [범위 B]'
  })

  // 완료 후 정리
  SendMessage({ type: 'shutdown_request', recipient: 'claude-impl' })
  SendMessage({ type: 'shutdown_request', recipient: 'claude-arch' })
  TeamDelete()
}
```

### Phase 5: 최종 검증

```typescript
// 코드 리뷰
Task({ subagent_type: 'code-reviewer', prompt: '최종 변경사항 리뷰' })

// 테스트 실행
Bash('npm test')

// 커밋
git commit -m "feat: [작업 설명] (Claude+Codex pair)"
```

</workflow>

---

<examples>

## 실전 예시

### 예시 1: 단순 작업 (Solo+Review)

```bash
사용자: /codex 이 함수에 null 체크 추가해줘

# Phase 0: 복잡도 - 단순 (1 파일)
# Phase 1: 모드 - Solo+Review

# Claude 구현
Edit: src/utils/parser.ts
+ if (input == null) return null;

# Codex 리뷰 (MCP)
mcp__codex__codex: "변경사항 분석"
mcp__codex__codex_reply: "리뷰: undefined도 체크 필요"
→ "== 로 undefined도 처리됨, OK"

# 완료
git commit -m "fix: parser에 null 체크 추가"
```

### 예시 2: 설계→구현 (Sequential)

```bash
사용자: /codex 사용자 인증 시스템 구현

# Phase A: Claude 설계
sequentialthinking:
  - JWT + httpOnly 쿠키 방식
  - 인터페이스: AuthService, TokenManager

# Phase B: Codex 구현 (codex agent)
Task(codex): "Claude 설계 기반 구현"
→ src/auth/AuthService.ts
→ src/auth/TokenManager.ts
→ tests/auth.test.ts

# Phase 5: 커밋
git commit -m "feat: JWT 기반 인증 시스템 구현"
```

### 예시 3: 복잡한 작업 (Teams)

```bash
사용자: /codex 결제 시스템 전체 리팩토링

# Teams 모드
TeamCreate("pair-codex")

Task(codex, team): "결제 로직 리팩토링 + 테스트"
Task(claude, team): "아키텍처 개선 + 새 인터페이스 설계"

# 결과 통합 → 충돌 시 사용자 선택

# 팀 정리
shutdown_request → TeamDelete
git commit -m "refactor: 결제 시스템 전면 리팩토링"
```

</examples>

---

<validation>

## 검증 체크리스트

### 실행 전

```text
- codex MCP 가용 확인 (ToolSearch)
- 복잡도 분석 (sequentialthinking)
- 협업 모드 결정
- 역할 분담 명확화
```

### 실행 중

```text
- 각 역할별 작업 범위 준수
- 파일 충돌 방지 (한 파일 = 한 담당)
- 진행 상황 추적 (TodoWrite)
- 중간 검증 수행
```

### 완료 후

```text
- 결과 통합 완료
- 충돌 해소 (필요 시 사용자 선택)
- 코드 리뷰 완료
- 테스트 통과
- Teams 사용 시 정리 (shutdown + TeamDelete)
```

## 금지 사항

```text
- MCP 미설정 상태로 진행
- 복잡도 분석 없이 모드 선택
- 같은 파일을 Claude/Codex 동시 수정
- 충돌 무시하고 임의 선택
- Teams 사용 후 정리 없이 종료
- Codex 결과 검증 없이 수용
- Claude 설계 없이 복잡한 작업 시작
```

</validation>

---

<strengths>

## 역할별 강점 활용

### Claude 강점 (우선 위임)

| 영역 | 예시 |
|------|------|
| **아키텍처 설계** | 시스템 구조, 모듈 분리 |
| **창의적 해결책** | 새로운 접근법, 패턴 제안 |
| **문제 재정의** | 요구사항 분석, 본질 파악 |
| **통합 설계** | 여러 시스템 연결, 데이터 플로우 |
| **문서화** | 설계 문서, API 문서 |

### Codex 강점 (우선 위임)

| 영역 | 예시 |
|------|------|
| **정밀 구현** | 복잡한 알고리즘, 로직 |
| **엣지케이스** | 예외 처리, 경계 조건 |
| **코드 리뷰** | 버그 탐지, 보안 취약점 |
| **테스트 작성** | 단위 테스트, 통합 테스트 |
| **디버깅** | 버그 원인 분석, 수정 |

</strengths>

---

<troubleshooting>

## 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| MCP 연결 실패 | codex-mcp 미등록 | 앱 설정 → OpenAI/Codex에서 등록 |
| API 키 오류 | OPENAI_API_KEY 미설정 | 앱 설정 → OpenAI/Codex에서 API 키 입력 |
| Codex 응답 지연 | 네트워크/API 부하 | 재시도 또는 Claude 단독 진행 |
| 결과 충돌 | 다른 접근법 | Discussion 모드 → 사용자 선택 |
| Teams 팀원 미응답 | 세션 문제 | shutdown → 재스폰 |
| 파일 충돌 | 동시 수정 | 작업 범위 재분배 |

</troubleshooting>
