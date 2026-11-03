# Framework Mapping

다섯 런타임이 같은 그래프 기본 요소를 어떻게 부르는지, 문서에 적힌 범위 안에서 정리한다. 이것은 번역표이지 동등성 주장이 아니다.

> 영어판: [`framework-mapping.md`](framework-mapping.md)

## How to use this

모든 행은 **문서화된** 기본 요소를 기록한다. 인용한 문서에 없는 기능은 형제 프레임워크의 동작에서 유추하지 않고 그렇다고 적는다. 어휘 차이가 커서 한 문서의 "node"는 함수이고, 다른 문서에서는 타입이 지정된 포트를 가진 executor이며, 세 번째에서는 에이전트 실행 전체다. 이 셋을 동의어로 다루면 이 영역이 다루는 설계 결정이 가려진다.

"graph engineering"이라는 표현을 쓰는 곳은 다섯 중 둘이다. LangChain이 이 용어를 퍼뜨렸고, Google Cloud의 ADK 글이 정의한다. Microsoft는 용어 없이 "graph-based workflows"를 문서화하고, OpenAI와 Anthropic의 문서는 이 용어보다 앞선다. 용어의 부재를 기능의 부재로 읽지 않는다.

## Primitive names

| 개념 | LangGraph | Microsoft Agent Framework | Google ADK | OpenAI Agents SDK | Claude Code workflows |
|---|---|---|---|---|---|
| 작업 단위 | node. `state`, `config`, `runtime`을 받는 함수 | executor: 입력을 받아 일을 하고 출력을 낸다 | node: Agent, 도구, 사람 입력 작업, 또는 코드 함수 | agent(지시 + 도구 + handoff) | 스크립트가 호출하는 subagent |
| 고정 전이 | `add_edge(a, b)` | edge | `START`로 시작하는 엣지 행. 순서대로 실행 | 코드: 다음 에이전트 호출 | 순차 문장 |
| 조건부 전이 | `add_conditional_edges` | 조건이 붙은 edge | 노드가 `route`를 내고 엣지 행이 경로 값을 대응시킨다. `DEFAULT_ROUTE` | 코드: 구조화 출력으로 분기 | 스크립트의 `if` |
| 모델이 고르는 전이 | 함수가 모델을 호출하는 조건부 엣지 | agent executor | 경로 값을 내는 agent router | handoff | 런타임 기본 요소가 아니다. 스크립트가 에이전트 결과로 분기할 수는 있다 |
| 통제의 이전과 반환 | `Command(goto=...)` 와 값 반환 | 엣지가 값을 라우팅, sub-workflow는 executor | `Event(route=...)` 와 출력 전달 | handoff 와 `Agent.as_tool()` | 스크립트 함수 호출과 대기한 결과 |
| 공유 상태 | 키마다 reducer를 둔 `State` 스키마 | 지속·실행 범위로 나뉜 상태 관리 | `ctx.state` 와 `Event(output=...)` | 실행 단위 대화 상태 | 스크립트 변수 |
| 병렬 fan-out | 여러 나가는 엣지, map-reduce에는 `Send` | 병렬 엣지 그룹, fan-out/fan-in | 엣지 행의 튜플, `parallel_worker` | 코드의 `asyncio.gather` | 스크립트 수준 동시성 |
| join | 다음 노드가 병합된 상태를 읽는다 | fan-in 그룹 | `JoinNode`(노드 이름 키 사전) 또는 `parallel_worker`(입력 순서 목록) | `gather` 이후의 코드 | 스크립트가 결과를 모은다 |
| 지속성 | checkpointer와 `thread_id` | 슈퍼스텝 종료 시 체크포인트 | `RequestInput`으로 일시 정지, 완료된 호출은 세션 이력에서 재생 | 인용한 문서에 없음 | 같은 세션에서 재개 가능 |
| human in the loop | `interrupt()` 후 `Command(resume=...)` | `RequestInfoExecutor` / `RequestInfo` | `rerun_on_resume`을 붙인 `RequestInput` / `ctx.resume_inputs` | 인용한 문서에 없음 | 실행 전 계획 승인 프롬프트 |
| 관측 | 스트리밍 중 단계별 스냅샷 | span, 지표, 이벤트, 전달 상태, 시각화 | 노드별 이벤트 스트림 | SDK tracing | 단계와 에이전트별 진행 보기 |

## Execution model differences that change design

| 차이 | LangGraph | Microsoft Agent Framework | 설계에 미치는 영향 |
|---|---|---|---|
| 재개 의미론 | 노드가 처음부터 다시 실행되므로 `interrupt()` 앞 코드가 다시 돈다 | 슈퍼스텝 종료 시 체크포인트, 대기 요청은 복원 후 다시 나온다 | 부작용은 재실행에 안전해야 하며, 아니면 멱등한 자식 노드로 옮긴다 |
| 스케줄링 | 노드 단위, reducer가 갱신을 병합 | 벌크 동기 병렬. 슈퍼스텝 경계에서 모든 executor가 동기화된다 | 느린 분기는 자기 소비자만이 아니라 슈퍼스텝 전체를 지연시킨다 |
| 한 노드에서의 라우팅 | 방식 하나만. 일반 엣지와 동적 라우팅을 섞으면 두 경로가 모두 실행된다 | 조건이 붙은 엣지와 fan-out 그룹 | 조건부 엣지 *또는* `Command`/`Send` 중 하나만 쓴다 |
| 동적 토폴로지 | 조건부 엣지가 `Send`를 반환하고 전송마다 별도 상태를 넘긴다 | fan-out 그룹을 빌더에 선언한다 | 데이터에 따라 달라지는 분기 개수는 어느 쪽이든 trace에 기록해야 한다 |

Microsoft가 스스로 정리한 맞바꿈도 기억할 만하다. 함수형 API는 순차 파이프라인과 사용자 정의 루프에, 그래프 API는 고정 그래프와 fan-out/fan-in, 타입 검증 라우팅에 맞으며, 둘은 "같은 관측 가능한 워크플로 결과"를 낸다.

## What is portable

다섯 모두에 해당하므로 런타임 중립 계약에 넣어도 안전한 것들이다.

- 작업 단위는 입력과 출력을 선언하고, 그 선언이 시험 경계가 된다.
- 전이는 고정이거나 결정되며, 결정 주체가 설계의 일부다.
- 병렬 분기에는 명시적인 병합 규칙이 필요하다.
- 긴 실행에는 체크포인트 경계와 재개 의미론이 필요하다.
- 사람의 결정은 지시가 아니라 들어오는 엣지가 있는 단계다.
- trace는 실행이 지난 경로를 기록해야 한다.

## What is vendor-specific

개념인 것처럼 런타임 사이로 옮기면 안 되는 것들이다.

- **모든 것의 이름.** node, executor, agent, step, stage.
- **상태 모델.** reducer 사전, 실행 범위 상태 객체, 스크립트 변수는 같은 문제를 풀지만 정렬과 지속성에 대한 보장이 다르다.
- **재개 동작.** LangGraph의 노드는 다시 시작하고, ADK의 동적 노드는 완료된 자식 호출을 재생한다. 한쪽을 전제로 한 설계는 다른 쪽에서 틀린다.
- **그래프가 제품인지 여부.** Anthropic은 런타임 없이 패턴을 공개하고, Claude Code는 스크립트 런타임을, Microsoft는 시각화가 붙은 워크플로 런타임을, LangGraph와 ADK는 그래프 빌더를 제공한다.
- **버전 표면.** ADK는 2.0부터 Python, TypeScript, Go에서 그래프 기반 워크플로를 지원한다([ADK routes](https://adk.dev/graphs/routes/)). Microsoft의 함수형 워크플로 API는 Python에서 실험 단계로 표시된다. 동작을 인용할 때는 버전을 고정하는 것이 인용의 일부다.

## Feature claims worth re-checking before a decision

| 주장 | 중요한 이유 | 구현 시 확인할 것 |
|---|---|---|
| 슈퍼스텝 경계에서의 체크포인트 | 복구의 입도 | 런타임이 부작용 전후 어디에서 체크포인트를 남기는가 |
| 재개 시 노드 재시작과 재생 | 멱등성 요구 | 런타임이 노드 본문을 다시 실행하는가 |
| join 출력 형태(사전과 목록) | 하류 파싱 | 사용하는 join 기본 요소의 실제 반환 타입 |
| 병렬 interrupt 재개 | 다중 승인 흐름 | 재개 값이 interrupt id로 키가 되는가 |
| 사이클 한도 | 종료 보장 | 런타임이 통과 상한을 강제하는가(ADK는 자동 한정이 없다고 밝힌다) |

## Sources

> 링크는 확인 2026-11-03에 모두 직접 열어 전체를 읽었고, 이전(redirect) 없이 응답한다.

| 주장 | 출처 | 발행·갱신 |
|---|---|---|
| 노드, 엣지, reducer, `Command`, `Send`, 노드당 라우팅 방식 하나 | <https://docs.langchain.com/oss/python/langgraph/graph-api> | 날짜 표기 없음 |
| `interrupt()`, `Command(resume=...)`, 재개 시 노드가 처음부터 실행됨, 병렬 interrupt, 지속 커서로서의 checkpointer와 `thread_id` | <https://docs.langchain.com/oss/python/langgraph/interrupts> | 날짜 표기 없음 |
| executor, 엣지, 이벤트, 상태, 그래프 API와 함수형 API, 슈퍼스텝 체크포인트, `RequestInfoExecutor` | <https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/> | 2026-10-22, 갱신 2026-10-28 |
| 대기 요청을 포함한 체크포인트 내용, 복원 시 요청 재발행 | <https://learn.microsoft.com/en-us/agent-framework/workflows/checkpoints> | 갱신 2026-11-01 |
| 노드 종류, edges 배열, 경로 값, `DEFAULT_ROUTE`, `JoinNode` | <https://adk.dev/graphs/routes/> | 날짜 표기 없음 |
| `RequestInput`, `rerun_on_resume`, `ctx.resume_inputs` | <https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know> | 2026-09-30 |
| agents as tools와 handoff, LLM 오케스트레이션과 코드 오케스트레이션 | <https://openai.github.io/openai-agents-python/multi_agent/> | 날짜 표기 없음 |
| JS 스크립트로서의 동적 워크플로, 재개 가능, 진행 보기 | <https://code.claude.com/docs/en/workflows> | 날짜 표기 없음 |
| 용어가 생기기 전에 이름 붙은 다섯 워크플로 패턴 | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, 갱신 2026-10-09 |
