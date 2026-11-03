# Parallel Workflows and Subagents

> 영어판: [`parallel-workflows.md`](parallel-workflows.md)

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
Inherited context: [이미 내린 결정, 이미 확인한 제약과 그 이유]
Output: [요약, 근거 파일/링크, 변경 파일, 검증 결과, blocker]
Returns: [요약과 산출물 경로. 트랜스크립트 전체는 돌려주지 않는다]
Stop condition: [완료/차단/시간/소스 바닥값]
```

가장 자주 빠지는 항목이 `Inherited context`다. 작업 문구만 복사하면 부족하다. 부모가 앞서 한 도구 호출이 암묵적 결정을 담고 있어서, 문장만 받은 작업자는 그 결정을 다르게 다시 내린다. `Returns`는 부모 컨텍스트의 증가를 억제한다. 긴 자료는 작업자가 파일로 쓰고 경로만 넘긴다.

## Context Isolation Economics

서브에이전트는 컨텍스트 창을 하나 더 얻는 대가로 계산서를 하나 더 받고, 결정권자도 하나 더 만든다. 두 비용 모두 실재하고 수치가 있다.

| 비용 | 근거 |
|---|---|
| 토큰 | Anthropic은 에이전트가 채팅의 “약 4배”, 멀티 에이전트 시스템이 채팅의 “약 15배” 토큰을 쓴다고 보고한다(2025-06-13) |
| 이득의 상한 | 같은 분석에서 BrowseComp 성능 분산의 80%가 토큰 사용량만으로 설명됐고, 리드 에이전트와 서브에이전트 조합은 내부 평가에서 단일 에이전트를 90.2% 앞섰다 |
| 조정 | 리드 에이전트가 실행 중인 서브에이전트를 조종할 수 없고, 서브에이전트끼리 협의할 수 없으며, “서브에이전트 하나가 검색을 마칠 때까지 전체 시스템이 막힐 수 있다” |
| 일관성 | Cognition의 반대 원칙은 “행동은 암묵적 결정을 동반하고, 상충하는 결정은 나쁜 결과를 낳는다”이다. 서로의 행동을 볼 수 없는 병렬 작성자는 양립하지 않는 반쪽을 만든다(2025-06-12) |

벤더 수치는 자체 보고이고 측정 과제도 서로 다르다. 기본값을 정당화하는 근거가 아니라 기대치를 잡는 데 쓴다. 두 입장을 모두 통과하는 판단 규칙은 이렇다.

1. **조사는 격리하고 결정은 격리하지 않는다.** 폭넓은 탐색, 서로 다른 검토 관점, 장황한 분류는 글로 합쳐도 깨끗하다. 전체에서 일관돼야 하는 결정은 그렇지 않다.
2. **부모가 읽을 필요가 없는 것을 격리한다.** 서브에이전트는 최종 메시지만 돌려주고 중간 도구 호출과 결과는 안에 남는다. 부모는 트랜스크립트가 아니라 요약만큼만 커진다. 이득은 전부 여기서 나온다.
3. **같은 산출물을 쓰는 두 작성자를 격리하지 않는다.** 병합 순서를 선언했거나 소유자가 하나일 때만 나눈다.
4. **15배를 예산에 넣는다.** 한 에이전트가 파일 세 개를 읽으면 되는 일이라면, 각 서브에이전트가 빨라도 분산은 손해다.
5. **인계에 수정 방향을 적는다.** “찾은 제약이 틀렸다”를 적어 보내는 편이, 그것이 빠진 요약을 받은 부모가 제약을 다시 유도하는 편보다 싸다.

런타임마다 구현은 다르다. 포크 또는 새 서브에이전트 컨텍스트, 에이전트별 컨텍스트 브랜치, 값만 돌려주는 샌드박스, 원격 브랜치 중 하나를 쓴다. 세부는 [`runtime-profiles.ko.md`](runtime-profiles.ko.md)와 [`context-management.ko.md`](context-management.ko.md) 5절에 있다.

## Runtime Spawn Map

| Runtime | Spawn surface | Isolation model | Best use | 주의 |
|---|---|---|---|---|
| Claude Code | `/agents`, project `.claude/agents/*.md`, `Agent`/legacy `Task` tool, experimental agent teams | subagent는 자체 context window; 필요 시 `isolation: worktree`; agent teams는 별도 세션 | 고출력 조사 격리, 명명된 specialist, 3-5명 팀 리뷰 | Agent teams는 실험적이며 coordination overhead가 큼 |
| Codex | native subagents, `.codex/agents/*.toml`, `spawn_agent`/`send_input`/`wait_agent`/`close_agent` 도구 표면 | forked context 또는 별도 agent thread; config로 동시성 제한 | 코드베이스 탐색, PR 리뷰 분할, docs researcher, disjoint implementation | Codex는 명시 요청이 있을 때 subagent를 spawn하며 토큰 비용 증가 |
| Cursor | Cloud Agents(구 Background Agents), editor/CLI subagents, `.cursor/rules`, `.cursor/environment.json` | cloud agent는 remote isolated machine/branch; subagent는 자체 context | 비동기 장기 작업, branch 기반 handoff, parallel work streams | remote agent는 GitHub 권한/인터넷/자동 명령 실행으로 보안 경계가 커짐 |
| Generic MCP/agent client | capability-discovered tools/prompts/resources | client 구현에 따름 | 도구/자료 접근 표준화 | tool result와 resource content는 untrusted evidence로 취급 |

> **MCP `2026-07-28` revision 주의** (확인 2026-09-19): 이 revision은 breaking change다. 프로토콜이 stateless로 바뀌어 세션과 `initialize` 핸드셰이크가 제거됐고, capability 조회는 새 `server/discover` RPC와 요청별 `_meta`로 옮겨졌다. Roots·Sampling·Logging은 deprecated(최소 12개월 유예)이며, 서버가 클라이언트에게 되묻던 흐름은 MRTR(`resultType: "input_required"`) 패턴으로 대체됐다. 위 표의 **untrusted evidence 원칙은 이 revision에서도 그대로 적용된다** — 명세는 클라이언트가 신뢰할 수 있는 서버에서 온 것이 아닌 한 tool annotation을 untrusted로 **간주해야 한다(MUST)**고 규정한다. 같은 문장이 `2025-11-25` revision에도 이미 있으므로, 이번 개정에서 새로 강화된 것이 아니라 상시 요구 사항으로 본다. MCP 기반 위임을 설계할 때는 세션 가정을 두지 말고 상태를 명시적 handle로 주고받는다.

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

> 출처는 2026-11-03에 확인했고, MCP 문서만 `2026-07-28` revision 기준으로 2026-09-19에 재확인했다. Cursor의 Background Agents는 Cloud Agents로 개명됐다.

| 주장 | 출처 | 발행·갱신 |
|---|---|---|
| 서브에이전트 문맥 격리, `isolation: worktree`, 프로젝트 `.claude/agents/*.md` | <https://code.claude.com/docs/en/sub-agents> | 날짜 표기 없음, 2026-11-03 확인 |
| agent teams는 별도 세션으로 돌며 아직 실험 단계 | <https://code.claude.com/docs/en/agent-teams> | 날짜 표기 없음, 2026-11-03 확인 |
| Codex 네이티브 서브에이전트, fork된 문맥 또는 별도 스레드, 설정으로 제한되는 동시성 | <https://learn.chatgpt.com/docs/agent-configuration/subagents> | 날짜 표기 없음, 2026-11-03 확인 |
| `spawn_agent`, `send_input`, `wait_agent`, `close_agent`가 `features.multi_agent`로 제공하는 도구 | <https://learn.chatgpt.com/docs/config-file/config-reference> | 날짜 표기 없음, 2026-11-04 확인 |
| cloud agent는 원격 격리 머신과 브랜치에서 돌고, GitHub 권한·인터넷 접근·자동 명령 실행이 경계를 넓힌다 | <https://cursor.com/docs/cloud-agent> | 날짜 표기 없음, 2026-11-03 확인 |
| 2.4 릴리스의 에디터·CLI 서브에이전트 | <https://cursor.com/changelog/2-4> | Cursor 2.4 릴리스 항목, 2026-11-03 확인 |
| `.cursor/rules` 프로젝트 규칙 | <https://cursor.com/docs/rules> | 날짜 표기 없음, 2026-11-03 확인 |
| `.cursor/environment.json` 환경 구성(Dockerfile 포함) | <https://cursor.com/docs/cloud-agent> | 날짜 표기 없음, 2026-11-04 확인 |
| 신뢰하는 서버가 아니면 도구 annotation을 신뢰하지 않는다. `server/discover`, 요청별 `_meta`, `resultType: "input_required"` | <https://modelcontextprotocol.io/specification/2026-07-28/server/tools> | 2026-07-28 revision, 2026-09-19 확인 |
| prompt 기능과 input-required(MRTR) 흐름 | <https://modelcontextprotocol.io/specification/2026-07-28/server/prompts> | 2026-07-28 revision, 2026-09-19 확인 |
| 도구 결과와 리소스 내용은 신뢰하지 않는 증거다 | <https://developers.openai.com/api/docs/guides/agent-builder-safety> | 날짜 표기 없음, 2026-11-03 확인 |
| 약 4배·약 15배 토큰 배수, BrowseComp 분산의 80%, 내부 eval 90.2% 개선, 조정 실패 | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13 발행, 2026-10-09 갱신 |
| "Actions carry implicit decisions", 단일 스레드 권고 | <https://cognition.com/blog/dont-build-multi-agents> | 2025-06-12 |
| SDK 서브에이전트는 자기 문맥 창에서 요약만 반환한다 | <https://code.claude.com/docs/en/agent-sdk/subagents> | 날짜 표기 없음, 2026-11-03 확인 |

## 함께 읽을 문서

- [`../CONTEXT_ENGINEERING.ko.md`](../CONTEXT_ENGINEERING.ko.md) — 리더가 쓰고 작업자가 받는 계약
- [`context-management.ko.md`](context-management.ko.md) — 격리가 의존하는 압축·비우기와 런타임별 컨텍스트 파라미터
- [`../../loop-engineering/LOOP_ENGINEERING.ko.md`](../../loop-engineering/LOOP_ENGINEERING.ko.md) — 루프 한 회차 안의 분산. 작업자를 띄우는 루프는 이 문서 기준의 리더이고, 루프의 중단 조건은 자식에게 넘어가지 않는다.
- [`../../graph-engineering/GRAPH_ENGINEERING.ko.md`](../../graph-engineering/GRAPH_ENGINEERING.ko.md) — 분산·수렴 엣지, 결합 방식, 되돌아가는 엣지의 한도는 그래프가 정한다. 이 문서는 그 노드가 실행할 작업자별 소유권·격리·통합 계약을 공급한다.
- [`../../harness-engineering/HARNESS_ENGINEERING.ko.md`](../../harness-engineering/HARNESS_ENGINEERING.ko.md) — 위임 실행이 실제로 끝났음을 증명하는 trace·gate·eval
