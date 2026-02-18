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

> Claude + codex-mcp 페어 프로그래밍. Claude(설계/창의) + Codex(구현/검증) 역할 분담.

---

<overview>

**codex-mcp 서버:** Rust MCP 바이너리 → OpenAI Responses API 직접 호출

| 특성 | 상세 |
|------|------|
| **인증** | Codex CLI OAuth (`~/.codex/auth.json`), 토큰 자동 갱신, 401시 강제 갱신+재시도 |
| **에이전트 루프** | `read_file`, `write_file`, `list_files`, `shell_exec` 자율 실행 |
| **세션** | `thread_id` 기반 컨텍스트 유지, 모델 세션간 자동 보존 |
| **보안** | 경로순회 방지, 프로세스그룹 격리, 동시요청 방지 |

</overview>

---

<prerequisites>

## 사전 요구사항

```bash
# 1. Codex CLI OAuth 로그인
codex auth login

# 2. 빌드 + Claude Code 등록
cargo build -p codex-mcp --release
claude mcp add -s user codex -- /path/to/target/release/codex-mcp
```

또는 앱 설정 → **OpenAI / Codex** 탭 → **등록** 버튼.

**인증:** `~/.codex/auth.json` (OAuth 토큰, 자동 갱신)

</prerequisites>

---

<codex_mcp_tools>

## MCP 도구

### mcp__codex__codex — 새 태스크

```typescript
mcp__codex__codex({
  prompt: "작업 지시",
  working_directory: "/path/to/project",
  model: "gpt-5.3-codex high"  // 선택 (세션에 저장, 생략 시 Codex CLI 기본값)
})
// → JSON { thread_id, result }
```

### mcp__codex__codex_reply — 세션 이어가기

```typescript
mcp__codex__codex_reply({
  thread_id: "이전 thread_id",
  prompt: "후속 지시 또는 리뷰 요청"
})
// → JSON { thread_id, result }
// 세션 모델 자동 유지
```

### 리뷰 패턴 (2단계)

```typescript
// 1단계: 분석
const r = mcp__codex__codex({
  prompt: "src/auth/ 코드 읽고 분석해줘",
  working_directory: cwd
})
// 2단계: 리뷰
mcp__codex__codex_reply({
  thread_id: r.thread_id,
  prompt: "보안, 성능, 엣지케이스 리뷰"
})
```

</codex_mcp_tools>

---

<collaboration_modes>

## 협업 모드

| 모드 | 트리거 | Claude | Codex |
|------|--------|--------|-------|
| **Solo+Review** | 1-2 파일 | 구현 | 리뷰 |
| **Sequential** | 설계→구현 | 아키텍처 | 구현+테스트 |
| **Parallel** | 독립 작업 | 창의적 부분 | 꼼꼼한 부분 |
| **Discussion** | 트레이드오프 | 관점 A | 관점 B |
| **Teams** | 6+ 파일 | 팀원 | **Team Lead** |

**모드 선택:** sequentialthinking으로 복잡도 판단 → 자동 선택

</collaboration_modes>

---

<workflow>

## 실행 흐름

| Phase | 작업 |
|-------|------|
| **0** | MCP 가용 확인 + 복잡도 분석 |
| **1** | 협업 모드 결정 |
| **2** | 역할 분담 (TodoWrite) |
| **3** | 협업 실행 (Task codex agent + 직접 작업) |
| **4** | 결과 통합 (충돌 시 AskUserQuestion) |
| **5** | 검증 + 커밋 |

### Solo+Review

```typescript
// Claude 구현 → Codex 리뷰
Edit/Write → 코드 작성
const r = mcp__codex__codex({ prompt: "git diff 분석: [diff]", working_directory: cwd })
mcp__codex__codex_reply({ thread_id: r.thread_id, prompt: "버그, 보안, 엣지케이스 리뷰" })
```

### Sequential

```typescript
// Claude 설계 → Codex 구현
sequentialthinking → 아키텍처
Task({ subagent_type: 'codex', prompt: `Claude 설계 기반 구현: ${설계문서}` })
```

### Teams (Codex Lead)

```typescript
TeamCreate({ team_name: "pair-codex", agent_type: "codex" })
Task({ subagent_type: 'implementation-executor', team_name: 'pair-codex', name: 'claude-impl', prompt: '...' })
// 완료 후
SendMessage({ type: 'shutdown_request', recipient: 'claude-impl' })
TeamDelete()
```

</workflow>

---

<strengths>

## 역할별 강점

| Claude 우선 | Codex 우선 |
|-------------|-----------|
| 아키텍처 설계 | 정밀 구현 |
| 창의적 해결책 | 엣지케이스 |
| 문제 재정의 | 코드 리뷰 |
| 통합 설계 | 테스트 작성 |
| 문서화 | 디버깅 |

</strengths>

---

<validation>

## 검증

**실행 전:** MCP 가용 확인 → Codex 로그인 확인 → 복잡도 분석 → 모드/역할 결정
**실행 중:** 역할 범위 준수, 파일 충돌 방지 (한 파일 = 한 담당), TodoWrite 추적
**완료 후:** 결과 통합 → 코드 리뷰 → 테스트 통과 → Teams 정리

</validation>

---

<forbidden>

| 금지 | 대안 |
|------|------|
| MCP 미설정으로 진행 | 설정 안내 후 중단 |
| 같은 파일 동시 수정 | 작업 범위 분리 |
| 충돌 시 임의 결정 | AskUserQuestion |
| Codex 결과 무검증 수용 | 리뷰 + 테스트 |

</forbidden>

---

<troubleshooting>

| 에러 | 해결 |
|------|------|
| MCP 연결 실패 | 앱 설정 → OpenAI/Codex → 등록 |
| 401 인증 오류 | `codex auth login` |
| 토큰 갱신 실패 | `codex auth login` 재실행 |
| 타임아웃 | 재시도 |
| 세션 not found | 새 `codex` 세션 시작 |
| 동시 요청 에러 | 이전 요청 완료 대기 |

</troubleshooting>
