---
name: codex
description: Claude와 OpenAI Codex 페어 프로그래밍. 자유 협업으로 복잡한 작업을 분업 처리. Claude(창의적) + Codex(꼼꼼함) 강점 활용.
user-invocable: true
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# Codex Pair Programming

> Claude + Codex CLI 페어 프로그래밍. codex-mcp 서버가 Codex CLI를 래핑.

---

<overview>

**codex-mcp:** Codex CLI 래퍼 MCP 서버 (Rust)

| 특성 | 상세 |
|------|------|
| **인증** | Codex CLI OAuth (`codex login`) |
| **세션** | `thread_id` 기반 멀티턴, cwd/model 세션간 보존 |
| **도구** | `codex`, `codex_reply`, `codex_review`, `list_sessions`, `ping` |

</overview>

---

<setup>

## 설정

```bash
# Codex CLI 로그인
codex login

# codex-mcp 등록 확인
# 앱 설정 → OpenAI / Codex 탭 → 등록 버튼
```

</setup>

---

<tools>

## MCP 도구

### codex — 새 태스크

```typescript
mcp__codex__codex({
  prompt: "작업 지시",
  working_directory: "/path/to/project",  // 선택
  session_id: "my-session",               // 선택 (멀티턴용)
  model: "gpt-5.3-codex",                 // 선택
  reasoning_effort: "high"                // 선택: none|minimal|low|medium|high|xhigh
})
// → { thread_id, result }
```

### codex_reply — 세션 이어가기

```typescript
mcp__codex__codex_reply({
  thread_id: "이전 thread_id",
  prompt: "후속 지시"
})
// 세션 cwd/model 자동 유지
```

### codex_review — 코드 리뷰

```typescript
mcp__codex__codex_review({
  working_directory: "/path/to/project",
  uncommitted: true,    // 기본값
  base: "main",         // 선택: 비교 브랜치
  commit: "abc123"      // 선택: 특정 커밋
})
```

### list_sessions / ping

```typescript
mcp__codex__list_sessions()  // 활성 세션 목록
mcp__codex__ping()           // 헬스체크
```

</tools>

---

<collaboration>

## 협업 모드

| 모드 | 트리거 | Claude | Codex |
|------|--------|--------|-------|
| **Solo+Review** | 1-2 파일 | 구현 | 리뷰 |
| **Sequential** | 설계→구현 | 아키텍처 | 구현+테스트 |
| **Parallel** | 독립 작업 | 창의적 부분 | 꼼꼼한 부분 |

</collaboration>

---

<patterns>

## 사용 패턴

### 구현 후 리뷰

```typescript
// Claude가 구현
Edit/Write → 코드 작성

// Codex가 리뷰
mcp__codex__codex_review({ uncommitted: true })
```

### 멀티턴 대화

```typescript
const r = mcp__codex__codex({
  prompt: "src/auth/ 분석해줘",
  session_id: "auth-work"
})

mcp__codex__codex_reply({
  thread_id: r.thread_id,
  prompt: "보안 취약점 있어?"
})
```

### 설계 → 구현

```typescript
// Claude 설계
sequentialthinking → 아키텍처

// Codex 구현
Task({ subagent_type: 'codex', prompt: '설계 기반 구현' })
```

</patterns>

---

<strengths>

## 역할별 강점

| Claude | Codex |
|--------|-------|
| 아키텍처 설계 | 정밀 구현 |
| 창의적 해결책 | 엣지케이스 |
| 문제 재정의 | 코드 리뷰 |

</strengths>

---

<forbidden>

| 금지 | 대안 |
|------|------|
| MCP 미설정 상태로 진행 | 설정 안내 후 중단 |
| 같은 파일 동시 수정 | 작업 범위 분리 |
| Codex 결과 무검증 수용 | 리뷰 + 테스트 |

</forbidden>

---

<errors>

| 에러 | 해결 |
|------|------|
| MCP 연결 실패 | 앱 설정 → OpenAI/Codex → 등록 |
| 401 인증 오류 | `codex login` |
| 세션 not found | 새 `codex` 세션 시작 |
| 동시 요청 에러 | 이전 요청 완료 대기 |

</errors>
