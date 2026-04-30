# Parallel Workflows and Subagents

이 문서는 Codex, Claude Code, Cursor 같은 에이전트 런타임에서 병렬 작업과 서브에이전트를 안전하게 쓰기 위한 공통 기준이다. 특정 제품의 호출 문법보다 **독립성, 소유권, 격리, 통합, 검증**을 우선한다.

## Core Rule

병렬화는 “많이 띄우기”가 아니라 **서로 막지 않는 작업을 분리해 총 wall-clock time과 컨텍스트 오염을 줄이는 기법**이다. 리더 에이전트는 전체 계획, 충돌 조정, 결과 통합, 최종 검증을 끝까지 소유한다.

## When To Spawn

| Spawn if | 이유 | 예시 |
|---|---|---|
| 독립적인 조사 경로 | 결과를 나중에 합성할 수 있음 | auth/database/API 모듈을 각각 조사 |
| 서로 다른 검토 렌즈 | 같은 diff도 다른 oracle로 볼 수 있음 | security/performance/test coverage 리뷰 |
| disjoint write set | 파일 충돌 없이 병렬 구현 가능 | frontend route, backend handler, docs를 각각 담당 |
| 장황한 출력 격리 | 로그/검색결과가 메인 컨텍스트를 오염시키지 않음 | test failure triage, large grep, docs lookup |
| 반복 배치 작업 | 동일 schema로 결과를 모을 수 있음 | 컴포넌트별 audit, package별 migration check |

## When Not To Spawn

| Do not spawn if | 대체 |
|---|---|
| 바로 다음 단계가 그 결과에 막혀 있음 | 리더가 직접 처리하고 critical path를 줄인다 |
| 여러 에이전트가 같은 파일을 고칠 가능성이 큼 | 먼저 write ownership을 쪼개거나 단일 에이전트로 처리 |
| 작업 정의가 모호하고 성공 기준이 없음 | 먼저 plan/interview로 scope와 oracle을 만든다 |
| 외부 side effect, credential, production 변경이 필요함 | 사용자 권한/승인 gate를 별도로 둔다 |
| 단순 조회라서 spawn overhead가 더 큼 | 현재 런타임의 search/read 도구로 직접 처리 |

## Leader Contract

리더는 spawn 전후에 아래를 보장한다.

1. **분해**: 각 하위 작업이 독립적인지 확인한다.
2. **소유권**: read-only인지, write 가능이면 파일/디렉터리 범위를 명시한다.
3. **권한**: 필요한 최소 도구만 허용하고 destructive/external 행동은 금지한다.
4. **동시성**: 토큰/비용/충돌 위험을 고려해 필요한 수만 띄운다.
5. **통합**: 결과를 그대로 붙여넣지 않고, 충돌·중복·누락을 정리한다.
6. **검증**: 하위 에이전트의 “완료”를 신뢰만 하지 말고 리더가 최종 테스트/eval/source-check를 실행한다.

## Subagent Contract

하위 에이전트 프롬프트에는 최소한 아래 필드를 포함한다.

```markdown
Objective: [한 문장 목표]
Scope: [대상 파일/모듈/출처]
Mode: [read-only | edit-own-files | verify-only]
Ownership: [수정 가능 파일 또는 금지 파일]
Allowed tools: [repo search, official docs, tests 등 capability 기준]
Forbidden: [destructive, external side effect, unrelated refactor, 다른 에이전트 변경 되돌리기]
Output: [요약, 근거 파일/링크, 변경 파일, 검증 결과, blocker]
Stop condition: [완료/차단/시간/소스 바닥값]
```

## Runtime Spawn Map

| Runtime | Spawn surface | Isolation model | Best use | 주의 |
|---|---|---|---|---|
| Claude Code | `/agents`, project `.claude/agents/*.md`, `Agent`/legacy `Task` tool, experimental agent teams | subagent는 자체 context window; 필요 시 `isolation: worktree`; agent teams는 별도 세션 | 고출력 조사 격리, 명명된 specialist, 3-5명 팀 리뷰 | Agent teams는 실험적이며 coordination overhead가 큼 |
| Codex | native subagents, `.codex/agents/*.toml`, `spawn_agent`/`send_input`/`wait_agent`/`close_agent` surface, CSV fan-out where available | forked context 또는 별도 agent thread; config로 동시성 제한 | 코드베이스 탐색, PR 리뷰 분할, docs researcher, disjoint implementation | Codex는 명시 요청이 있을 때 subagent를 spawn하며 토큰 비용 증가 |
| Cursor | Background Agents, editor/CLI subagents, `.cursor/rules`, `.cursor/environment.json` | background agent는 remote isolated machine/branch; subagent는 자체 context | 비동기 장기 작업, branch 기반 handoff, parallel work streams | remote agent는 GitHub 권한/인터넷/자동 명령 실행으로 보안 경계가 커짐 |
| Generic MCP/agent client | capability-discovered tools/prompts/resources | client 구현에 따름 | 도구/자료 접근 표준화 | tool result와 resource content는 untrusted evidence로 취급 |

## Prompt Patterns

### Parallel research

```markdown
Spawn parallel research only for independent questions.
- Agent A: official docs and version-specific behavior for [topic A]. Read-only. Return links and caveats.
- Agent B: repo usage map for [module B]. Read-only. Return files/symbols and risks.
- Agent C: security/eval implications for [area C]. Read-only. Return concrete checks.
Leader: continue non-overlapping work while they run, then synthesize conflicts and update the plan.
```

### Parallel implementation

```markdown
Use parallel implementation only after the write sets are disjoint.
- Agent A owns: src/server/** only.
- Agent B owns: src/components/[feature]/** only.
- Agent C owns: docs/tests for [feature] only.
All agents must not edit shared config, package files, or each other's files without escalating.
Leader runs final lint/typecheck/test and resolves integration conflicts.
```

### Verification fan-out

```markdown
Run independent verification lanes:
- tests/build lane: run deterministic checks and report exact output.
- security lane: inspect trust boundaries and unsafe tool/data flow.
- docs/source lane: verify docs claims against official sources.
Leader decides completion only after all lanes are reconciled.
```

## Integration Checklist

- [ ] 각 subagent 결과가 원래 Objective에 답했는가?
- [ ] 서로 충돌하는 파일/주장/권고가 있는가?
- [ ] 하위 결과의 근거 파일, 링크, 테스트 출력이 남아 있는가?
- [ ] 리더가 최종 diff와 검증을 직접 확인했는가?
- [ ] 실패/차단/미검증 항목을 최종 보고에 숨기지 않았는가?

## Harness Assertions

Trace 기반 eval에는 아래 assertion을 둔다.

| Assertion | Pass condition |
|---|---|
| bounded_spawn | spawn prompt에 objective/scope/output/stop condition이 있다 |
| independent_work | 병렬 작업 간 입력 의존성이 없거나 명시적으로 sequencing되었다 |
| ownership_declared | edit 가능 작업은 파일/디렉터리 소유권을 가진다 |
| no_conflicting_edits | 둘 이상이 같은 파일을 동시에 수정하지 않는다 |
| parent_integrates | 리더가 결과를 요약·비교·통합한다 |
| parent_verifies | 리더가 최종 테스트/eval/source-check를 직접 실행하거나 출력 확인한다 |
| no_idle_wait | non-blocking subagent 실행 중 리더가 가능한 다른 작업을 진행한다 |

## Sources

- [Claude Code subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code agent teams](https://code.claude.com/docs/en/agent-teams)
- [OpenAI Codex subagents](https://developers.openai.com/codex/subagents)
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli)
- [Cursor Background Agents](https://docs.cursor.com/en/background-agents)
- [Cursor 2.4 subagents changelog](https://cursor.com/changelog/2-4)
- [Cursor Rules](https://docs.cursor.com/en/context)
- [MCP tools specification](https://modelcontextprotocol.io/specification/2025-06-18/server/tools)
- [MCP prompts specification](https://modelcontextprotocol.io/specification/2025-06-18/server/prompts)
- [OpenAI agent builder safety](https://platform.openai.com/docs/guides/agent-builder-safety)
