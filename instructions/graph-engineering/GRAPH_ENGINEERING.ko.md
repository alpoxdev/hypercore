# Graph Engineering

에이전트 시스템을 노드·엣지·공유 상태의 명시적인 그래프로 설계하고, 각 단계에서 코드와 모델과 사람 중 누가 다음 실행을 결정하는지 정하는 일이다.

> 영어판: [`GRAPH_ENGINEERING.md`](GRAPH_ENGINEERING.md)

## Why

이름은 새롭고 대상은 오래되었다. LangChain의 회고는 이 표현이 2026년 7월 어느 주말, 게시물 하나에서 시작되었다고 기록하고, 같은 채널에서 나온 prompt engineering, context engineering, harness engineering, loop engineering 옆에 놓는다([LangChain, 2026-07-22](https://www.langchain.com/blog/3-years-of-graph-engineering-with-langgraph)). Google Cloud는 열 주 뒤에 자체 정의를 냈고([Google Cloud, 2026-09-30](https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know)), 저자 35명의 프리프린트는 그보다 앞선 8월에 이미 이 개념을 하나의 패러다임으로 정식화했다([arXiv 2608.21156](https://arxiv.org/abs/2608.21156)). LangChain은 실천 자체가 이름보다 앞선다고 말한다. "에이전트 시스템을 그래프로 표현하는 일은 새롭지 않으며, 우리는 3년째 그렇게 해 왔다"([LangChain, 2026-07-22](https://www.langchain.com/blog/3-years-of-graph-engineering-with-langgraph)). PuppyGraph는 구조 자체가 오래되었다고 적는다. "상태 기계, DAG, 워크플로 엔진은 수십 년 동안 같은 방식으로 일을 모델링해 왔다"([PuppyGraph, 2026-08-24](https://www.puppygraph.com/learn/graph-engineering)). Anthropic은 2024년 12월에 반복되는 모양들에 이름을 붙였지만 그것을 하나의 분야로 부르지는 않았다([Anthropic, 2024-12-19](https://www.anthropic.com/research/building-effective-agents)).

그래도 이 이름이 자리를 얻는 이유는, 그동안 암묵적으로 남아 있던 결정을 이름으로 드러내기 때문이다. **에이전트 시스템의 어느 부분까지 모델이 결정하게 두고, 어느 부분은 반드시 코드여야 하는가.** 시스템이 루프 하나를 넘어서면 프롬프트 문구와 루프 조정은 더 큰 구조 안의 국소 결정이 되고, 그 구조는 자기 기준으로 설계해야 한다([PuppyGraph, 2026-08-24](https://www.puppygraph.com/learn/graph-engineering)).

## Definition

**GE-1.** 그래프 엔지니어링은 에이전트 시스템을 노드로 분해하고, 노드를 엣지로 연결하고, 엣지를 따라 이동하는 상태를 규정하는 설계 작업이다. 각 단계에서 코드와 모델과 사람 중 누가 다음 실행을 결정하는지도 여기에서 정한다.

이 문장은 2026년의 정의 두 가지를 이 저장소에서 종합한 것이지, 어느 하나를 그대로 인용한 것이 아니다. Google Cloud는 이 분야를 "작업을 노드로 나누고, 엣지로 연결하고, 코드와 모델과 사람 중 누가 다음 단계를 통제하는지 정하는 일"로 정의한다. PuppyGraph는 "에이전트 시스템이 실행하는 그래프, 즉 일을 하는 노드, 노드 사이로 작업을 보내는 엣지, 그 엣지를 따라 이동하는 공유 상태를 설계하는 실천"으로 정의한다. 첫 번째는 라우팅 권한을 다루고 상태를 빼놓으며, 두 번째는 상태를 다루고 라우팅 권한을 빼놓는다. 둘 다 필요하다.

**GE-2.** 그래프는 그림이 아니라 계약이다. 실제로 배포되는 산출물은 노드의 입력·출력 스키마, 허용된 엣지 집합, 필드마다 병합 규칙을 붙인 상태 스키마다. 그림은 그 계약을 그린 것이며, 스키마 없는 다이어그램은 의도의 기록일 뿐이다.

## Three senses of the term

이 표현은 서로 다른 세 갈래로 쓰인다. 셋을 섞으면 검토가 불가능한 시스템이 된다. 한 문서에서는 "다음에 무엇이 도는가"를 뜻하던 단어가 다른 문서에서는 "모델이 무엇을 읽었는가"를 뜻하게 되기 때문이다.

| 갈래 | 대상 | 수명 | 이렇게 부르는 쪽 | 이 문서에서의 지위 |
|---|---|---|---|---|
| 1. 실행 토폴로지 | 한 번의 실행에서 쓰는 노드·엣지·공유 상태 | 실행 1회 | LangChain, Google Cloud, 이 문서 | **주 계약** |
| 2. 루프의 구성 | 루프가 몇 개이고 어떻게 연결되는가. 루프 하나는 노드 하나 또는 사이클 하나 | 실행 1회 | PuppyGraph가 이 관점으로 분야를 설명한다. LangChain은 "루프는 단순한 그래프"라고 말한다 | 갈래 1과 같은 대상을 루프 쪽에서 본 것 |
| 3. 맥락으로서의 그래프 | 말뭉치 위에 만든 개체·관계 색인을 문맥으로 가져오는 것 | 실행을 넘어 유지 | GraphRAG, 저장소 코드 그래프 | **이 계약에서 제외**: [`references/graph-as-context.ko.md`](references/graph-as-context.ko.md) 참조 |

**GE-3.** 갈래 1과 2는 같은 대상의 두 진입점이므로 이 저장소는 둘을 하나로 다룬다. 루프는 그래프의 사이클이므로 루프 엔지니어링은 부분 그래프를 설계하는 일이다. 갈래 3은 수명도, 실패 방식도, 검토자도 다르다. 실행 그래프는 순서에 대해서만 틀릴 수 있고, 맥락 그래프는 사실에 대해서 틀릴 수 있다. 한쪽 근거로 다른 쪽을 정당화하지 않는다.

이름에 관해 덧붙인다. Microsoft는 타입이 지정된 executor를 엣지와 조건으로 연결하는 그래프 기반 워크플로를 이미 제공하지만, 문서에서는 "graph-based workflows"라고만 쓰고 "graph engineering"이라는 표현은 쓰지 않는다([Microsoft Learn](https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/)). 이 용어를 Microsoft에 귀속시키지 않는다.

## Where it sits

| 분야 | 소유하는 것 | 답하는 질문 |
|---|---|---|
| Prompt engineering | 한 번의 호출에 들어가는 지시 | 이 단계에서 모델은 무엇을 읽는가 |
| Context engineering | 무엇이, 어디서, 어떤 권위로 문맥에 들어가는가 | 이 시점에 모델은 무엇을 아는가 |
| Harness engineering | 모델 작업을 감싸는 도구·평가자·trace·게이트 | 모델이 제대로 움직이는지 어떻게 아는가 |
| Loop engineering | 반복 단위 하나: 트리거, 작업 원천, 종료 조건, 예산 | 이 단위는 언제 반복을 멈추는가 |
| **Graph engineering** | 루프를 담는 토폴로지와 그 위를 지나는 상태 | 다음에 무엇이 도는가, 그리고 누가 정하는가 |

인용한 프리프린트는 Graph Engineering을 prompt, context, harness, loop engineering 다음 자리에 놓는다. 작업이 이질적인 전문성, 서로 의존하는 하위 작업, 병렬 실행, 독립 검증, 지속 상태를 요구하는 순간 에이전트 하나의 수용력이 먼저 바닥나기 때문이다([arXiv 2608.21156](https://arxiv.org/abs/2608.21156)). LangChain은 더 약하고 더 쓸모 있는 주장을 한다. 그래프 엔지니어링은 loop engineering, harness engineering과 "같은 발상"이며, 각 단계에서 모델의 추론을 올바른 자리에 올바른 문맥과 함께 두는 일이라는 것이다.

**GE-4.** 사이클은 그래프 수준에서 자기 한도를 선언한다. 실행 한 번에 back-edge를 몇 번까지 지날 수 있는지 정하며, 이는 노드 내부의 종료 조건과 별개다. ADK 문서는 "그래프 사이클은 자동으로 한정되지 않는다"고 밝히고, 루프 자체를 "back-edge, 곧 하류 노드가 앞선 노드로 되돌아가는 것"으로 정의한다. 한도가 노드가 아니라 엣지에 속하는 이유가 여기에 있다([ADK, graph routes](https://adk.dev/graphs/routes/)). [`instructions/loop-engineering/LOOP_ENGINEERING.ko.md`](../loop-engineering/LOOP_ENGINEERING.ko.md)의 짝 규칙은 올바르게 멈추는 노드도 다시 진입할 수 있다는 것이다.

**GE-5.** 사이클이 끝났는지 판정하는 검사는 일을 하는 주체가 아니라 다른 주체나 결정적 oracle이 수행한다. 루프 수준에서는 이것이 loop engineering 계약이고, 그래프 수준에서는 검증자가 노드가 되고 그 판정이 엣지가 된다는 뜻이다.

## Graph contract

| 결정 | 반드시 적어야 하는 것 | 적지 않았을 때 생기는 일 |
|---|---|---|
| 노드 경계 | 입력 스키마, 출력 스키마, 노드가 상태에 쓸 수 있는 범위 | 처음부터 끝까지 한 번에만 시험할 수 있는 덩어리가 된다 |
| 허용 엣지 | 오류·중단 경로까지 포함한 전체 전이 집합 | 아무도 검토하지 않은 경로를 모델이 만든다 |
| 라우팅 권한 | 엣지마다 코드·모델·사람 중 무엇인지 | 정책이 조용히 프롬프트로 옮겨 간다 |
| 상태 | 스키마와, 분기가 쓸 수 있는 모든 필드의 병합 규칙 | 동시 쓰기가 오류 없이 데이터를 잃는다 |
| 한도 | 노드별 예산, fan-out 상한, back-edge 통과 횟수 | 요청 하나가 그달 예산을 쓴다 |
| 지속성 | 체크포인트 경계와 재개 시 다시 실행되는 범위 | 9단계에서 실패하면 1단계부터 다시 시작한다 |
| 승인 지점 | 어떤 부작용이 사람의 결정을 기다리는가 | 검토되지 않은 동작이 운영에 도달한다 |

## Nodes

노드는 일의 단위이자 시험의 단위다. LangChain의 예시는 세 가지를 한 눈금 위에 놓는다. **고정 단계**(코드나 API 호출, 모델 없음), **모델 단계**(도구 없는 LLM 호출 한 번), **에이전트 단계**(자체 내부 루프를 가진 완전한 에이전트)다. 노드는 라우터, 검증자, 사람 승인 지점이 될 수도 있다.

- **GE-N-1.** 노드는 해석이 필요한 일에만 모델을 쓴다. 이 분야에서 가장 값싼 신뢰성 개선은 장부 정리만 하던 모델 호출을 함수로 바꾸는 일이다.
- **GE-N-2.** 노드 경계는 시험 경계다. 입력과 출력만으로 노드의 동작을 단정할 수 없다면 분해가 틀렸다.
- **GE-N-3.** 그 자체가 에이전트인 노드는 내부 종료 조건을 선언하며, 그래프는 전체 실행의 한도를 그 조건에 맡기지 않는다(GE-4 참조).
- **GE-N-4.** 검토할 가치가 있는 이름을 가진 가장 작은 노드가 이긴다. 노드 입자는 프레임워크 기본값이 아니라 검토 결정이다.

## Edges

| 종류 | 결정 주체 | 쓰는 자리 | 근거 |
|---|---|---|---|
| 고정 | 코드 | 정책·비용·승인을 지고 가는 순서 | Google Cloud: "연결이 분명해지는 자리에서는 엣지 목록을 쓴다" |
| 조건부 | 상태를 읽는 코드 | 이미 가진 사실에 따른 분기 | LangGraph의 조건부 엣지 |
| 모델 선택 경로 | 경로 값을 내는 모델 | 규칙으로 붙잡기 어려운 의미 | Google Cloud: "모델이 의도를 식별하고, 그래프가 가능한 목적지를 정의한다" |
| 동적 | 실행 중의 코드 | 입력이 와야 개수를 아는 작업 | LangGraph `Send`, ADK 동적 노드, Claude Code 워크플로 스크립트 |

- **GE-E-1.** 정책·비용·승인 요구를 지고 가는 엣지는 그래프에 고정하며, 모델이 고르게 두지 않는다. PuppyGraph의 표현이 운영 형태다. 정책과 비용과 승인을 지고 가는 토폴로지 부분은 고정하고, 작업이 실제로 달라지는 부분에만 실행 시점의 유연성을 남긴다.
- **GE-E-2.** 노드 하나에는 라우팅 방식 하나만 쓴다. LangGraph의 지침은 분명하다. 같은 노드에서 일반 엣지와 동적 라우팅을 섞으면 두 경로가 모두 실행될 수 있어 동작을 추론하기 어려워진다.
- **GE-E-3.** 동적 엣지는 자기가 만든 전이를 기록한다. 분기 개수가 기록되지 않은 map-reduce식 fan-out은 실패했을 때 버그와 구별되지 않는다.
- **GE-E-4.** 엣지가 발동했을 때 누가 통제를 유지하는지 정한다. OpenAI SDK는 *agents as tools*(관리자가 대화를 쥐고 제한된 하위 작업만 전문가에게 맡긴다)와 *handoff*(전문가가 그 턴의 남은 부분을 넘겨받는다)를 구분한다. 잘못 고르면 관리자에서 병목이 생기거나, 전문가가 넘겨받은 대화를 끝내 돌려주지 않는다([OpenAI Agents SDK](https://openai.github.io/openai-agents-python/multi_agent/)).

## State

- **GE-S-1.** 병렬 분기가 쓸 수 있는 모든 필드는 쓰기 두 개가 어떻게 합쳐지는지 선언한다. LangGraph의 방식은 상태 키마다 reducer를 두고, 지정하지 않으면 덮어쓰기를 기본으로 한다([LangGraph Graph API](https://docs.langchain.com/oss/python/langgraph/graph-api)).
- **GE-S-2.** 상태는 노드 사이의 유일한 통로다. 전역 변수, 모듈 수준 캐시, 선언되지 않은 파일은 재실행과 검토에서 보이지 않는다.
- **GE-S-3.** 상태는 스키마 버전을 지니고, 재개된 실행은 어느 버전에서 재개했는지 기록한다. 스키마 변경 전에 쓰인 체크포인트는 다른 프로그램의 상태다.

## Durability

- **GE-D-1.** 체크포인트는 선언된 경계에서 남긴다. LangGraph에서는 그래프 단계가 끝날 때, Microsoft Agent Framework에서는 슈퍼스텝이 끝날 때, 즉 그 슈퍼스텝의 executor가 모두 완료되었을 때다.
- **GE-D-2.** 재개 의미를 "무엇이 다시 실행되는가"로 선언한다. LangGraph는 재개할 때 노드를 처음부터 다시 실행하므로 `interrupt()` 앞의 코드가 다시 돈다. ADK의 동적 노드는 완료된 자식 호출을 이력에서 재생한다. 둘 다 성립하는 설계지만, 선언되지 않은 쪽은 성립하지 않는다. 부작용은 재실행이 안전한 노드에 둔다.
- **GE-D-3.** 체크포인트 저장소는 신뢰 경계다. Microsoft 문서는 신뢰할 수 없거나 변조 가능성이 있는 출처의 체크포인트를 절대 읽지 말라고 명시한다.

## Human-in-the-loop

- **GE-H-1.** 승인은 들어오는 엣지가 있는 노드이지, 프롬프트 안의 지시가 아니다. PuppyGraph는 그 차이를 정확히 쓴다. 승인 요구를 지시문으로 표현하면 제안이지만, 들어오는 엣지가 있는 체크포인트 노드로 표현하면 실행이 우회할 수 없는 구조적 제약이 된다.
- **GE-H-2.** 대기 중인 요청은 체크포인트의 일부다. Microsoft Agent Framework에서는 대기 요청이 체크포인트와 함께 저장되고, 워크플로를 복원할 때 이벤트로 다시 나온다.
- **GE-H-3.** 병렬 분기는 동시에 interrupt될 수 있으므로, 재개할 때는 위치에 기대지 않고 interrupt 식별자마다 값을 대응시킨다(LangGraph가 이 패턴과 실패 사례를 함께 문서화한다).

## Fan-out and fan-in

- **GE-F-1.** join의 출력 형태를 선언한다. ADK의 `JoinNode`는 노드 이름을 키로 하는 사전을 돌려주고, `parallel_worker`는 입력 순서를 지킨 목록을 돌려준다. 다른 쪽을 전제로 쓴 소비자는 조용히 실패한다.
- **GE-F-2.** fan-out은 노드별로, 실행별로 상한을 둔다. Anthropic은 초기 버전이 단순한 질의에 subagent 50개를 만들었다고 밝히고, 자체 확장 지침도 명시적이다. 단순한 사실 확인은 도구 호출 몇 번을 쓰는 에이전트 하나, 비교는 subagent 몇 개, 복잡한 조사에만 열 개를 넘긴다.
- **GE-F-3.** 부분 실패 정책을 선언하고, "없음"과 "빈 값"을 구별한다. ADK는 출력 없이 끝난 선행 노드가 그 분기의 값을 비워 두어 실패가 원인 노드에서 멀어진 하류에서 드러난다고 경고한다. Claude Code의 조사 워크플로는 확인하지 못한 주장을 반박된 것으로 세지 않고 미검증으로 표시한다.
- **GE-F-4.** sectioning과 voting은 모양도 eval도 다르다. sectioning은 작업을 쪼개고, voting은 같은 작업을 여러 번 돌리므로 집계 규칙이 필요하다. Anthropic이 둘을 나눠 두는 이유가 여기에 있다.

## Verification nodes

- **GE-V-1.** 검증자는 생산자와 다른 노드다. PuppyGraph는 자기 채점을, 팀을 루프 하나에서 여러 개로 밀어내는 네 가지 한계 중 하나로 꼽는다. 자기 출력을 평가하는 모델은 약한 판정자이고, 루프 하나에는 검증자를 둘 자리가 없다.
- **GE-V-2.** 검증자의 판정은 라우팅 결정의 입력이다. 판정이 다음 실행을 바꾸지 않는다면 그 노드는 검증이 아니라 기록이다.
- **GE-V-3.** 기준을 코드로 표현할 수 있으면 결정적 oracle을, 표현할 수 없으면 rubric 판정자를 쓴다. [`instructions/harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md)가 결정적 검사와 rubric 채점 사이에서 내리는 선택과 같은 선택이다.

## Worked example

답변으로 끝나거나, 상담원에게 넘어가거나, 환불로 이어질 수 있는 지원 요청이다. 이 예의 요점은 업무 영역이 아니라, 모든 엣지에 권한 주체가 이름으로 적혀 있다는 점이다.

| 단계 | 노드 종류 | 라우팅 권한 | 이유 |
|---|---|---|---|
| 주문 조회 | 고정 단계 | 코드 | 조회 한 번, ID 하나, 판단 없음 |
| 의도 분류 | 구조화 출력을 내는 모델 단계 | 모델이 경로 값 생성 | 의미는 규칙으로 붙잡기 어렵다 |
| 환불 정책 적용 | 함수 노드 | 코드 | 같은 사실은 같은 결정을 내려야 하고, 모델 호출 없이 시험할 수 있어야 한다 |
| 지급 전 승인 | 사람 노드 | 사람 | 부작용을 되돌릴 수 없다 |
| 답변 작성 | 모델 단계 | 결정 이후의 코드 | 문구이지 정책이 아니다 |

Google Cloud의 환불 예시가 이 모양이다. 결정적 정책 함수, 의도 판별용 agent router, 세 조회를 fan-out하고 join하는 구조, 수동 검토 분기를 받는 사람 노드로 이루어진다. 가장 작은 교훈은 정책 단계에 모델 호출이 0회, 의도 단계에 1회 필요하다는 것이고, 그래프는 그 구분을 검사 가능하게 만드는 자리다.

## When not to use a graph

- **GE-A-1.** 그래프가 없애는 한계를 이름으로 댄다. PuppyGraph는 문맥 고갈, 직렬화된 지연, 격리 부재, 자기 채점 네 가지를 든다. 어느 것도 없애지 못하는 그래프는 장식이다.
- **GE-A-2.** 입력이 오기 전에 가능한 워크플로를 그릴 수 없다면 agent harness에서 시작한다. Google Cloud의 판별 질문이 정확히 그것이고, LangChain은 초기 deep research를 미리 정의한 그래프에서 에이전트 중심 루프로 옮겼다고 밝히며, GPT Researcher도 같은 이동을 했다.
- **GE-A-3.** 참여자 모두가 같은 문맥을 필요로 하거나 하위 작업이 서로 강하게 의존하면 fan-out은 손해다. Anthropic은 대부분의 코딩 작업이 이 범주에 든다고 말한다.
- **GE-A-4.** 착수 전에 값을 계산한다. Anthropic은 에이전트가 채팅 상호작용의 약 4배, 다중 에이전트 시스템이 약 15배의 토큰을 쓴다고 측정했고, 다중 에이전트 조사는 내부 eval에서 90.2% 더 나았다. 그 이득은 값을 치를 만큼 중요한 작업에서만 성립한다.
- **GE-A-5.** 루프 하나의 의미를 그대로 재현하는 그래프가 이 분야에서 가장 흔한 실패이며, 그런 그래프는 작업이 필요로 하지도 않은 병렬성에 조정 비용을 치른다.

질문 순서를 갖춘 판단 절차는 [`references/when-not-to-use-graphs.ko.md`](references/when-not-to-use-graphs.ko.md)에 있다.

## Anti-patterns

| 안티패턴 | 증상 | 고치는 방법 |
|---|---|---|
| 루프 하나짜리 그래프 | 모든 노드가 같은 에이전트의 단계 | 루프로 접는다. loop engineering 참조 |
| 프롬프트 속 정책 | 규칙이 지시문 문자열에 산다 | 고정 엣지나 함수 노드로 만든다 |
| 모델이 고르는 파괴적 동작 | 삭제·결제·발송 여부를 모델이 정한다 | 승인 노드를 거치게 한다 |
| 무제한 fan-out | 토큰 지출이 필요가 아니라 입력 크기를 따라 늘어난다 | 노드별·실행별 상한(GE-F-2) |
| 병합 규칙 없는 상태 | 부하가 걸리면 결과가 조용히 사라진다 | 공유 필드마다 reducer 선언(GE-S-1) |
| 생산자가 자기 채점 | 품질 주장이 납품과 어긋난 적이 없다 | 검증자 노드 분리(GE-V-1) |
| 재개 시험 없는 체크포인트 | 복구를 가정만 하고 시험하지 않는다 | 하네스에서 재개를 시험한다 |
| DAG 가정 | 재시도와 확인 루프가 재작성을 강요한다 | 처음부터 사이클을 설계한다 |
| 기록 없는 동적 경로 | 실패를 재현할 수 없다 | 전이를 기록한다(GE-E-3) |

## Observability

- **GE-O-1.** 노드별, 엣지별로 trace를 남기고 각 경로를 어떤 규칙이나 모델이 골랐는지 기록한다. 그래프의 특징적인 실패는 비결정적 라우팅이며, 한 번 실패한 실행이 다음에는 다른 경로를 지날 수 있다.
- **GE-O-2.** 비용을 노드에 귀속시킨다. 합산 지출은 예산 대부분을 쓰는 작업자 하나를 가린다.
- **GE-O-3.** 노드 경계에서, 그리고 처음부터 끝까지 평가하되 둘을 구분해 표시한다. 계약이 분명한 노드는 따로 시험할 수 있고, 전체 실행이 토폴로지를 증명한다.
- **GE-O-4.** 그려진 토폴로지와 배포된 계약을 같은 상태로 유지한다. Microsoft가 워크플로 시각화를 기능으로 제공하는 이유가 이것이다. 엣지 목록에서 벗어난 다이어그램은 없는 것보다 나쁘다.

## References

- [`references/graph-patterns.ko.md`](references/graph-patterns.ko.md) — 반복되는 토폴로지, join 의미론, 각 패턴의 eval.
- [`references/when-not-to-use-graphs.ko.md`](references/when-not-to-use-graphs.ko.md) — 판별 절차, 비용 모델, agent harness 대안.
- [`references/framework-mapping.ko.md`](references/framework-mapping.ko.md) — LangGraph, Microsoft Agent Framework, Google ADK, OpenAI Agents SDK, Claude Code 워크플로가 같은 기본 요소를 어떻게 부르는지.
- [`references/graph-as-context.ko.md`](references/graph-as-context.ko.md) — 갈래 3을 오케스트레이션과 분리해 둔 문서.

## Related documents

- [`instructions/loop-engineering/LOOP_ENGINEERING.ko.md`](../loop-engineering/LOOP_ENGINEERING.ko.md) — 사이클의 몸체: 트리거, 작업 원천, 종료 조건, 예산, 에스컬레이션.
- [`instructions/context-engineering/CONTEXT_ENGINEERING.ko.md`](../context-engineering/CONTEXT_ENGINEERING.ko.md) — 각 노드가 무엇을 읽도록 받는가.
- [`instructions/harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md) — 노드와 그래프 전체의 trace, eval, 게이트.
- [`instructions/validation/index.ko.md`](../validation/index.ko.md) — 토폴로지 변경이 배포되기 전에 무엇이 증거인가.

## Sources

> 모든 링크는 확인 2026-11-03에 직접 열어 전체를 읽었고, 이전(redirect) 없이 응답한다.

| 주장 | 출처 | 발행·갱신 |
|---|---|---|
| 용어의 기원, "루프는 단순한 그래프", 노드가 완전한 에이전트 실행이 될 수 있음, 그래프를 쓰지 말아야 할 때, 월 6,500만 회 다운로드 | <https://www.langchain.com/blog/3-years-of-graph-engineering-with-langgraph> | 2026-07-22 |
| 정의(노드·엣지·누가 결정하는가), 결정적 라우터와 agent router, 정적·동적 구분, fan-out과 join, 조사 범위 한정 | <https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know> | 2026-09-30 |
| 공유 상태를 포함한 정의, 루프 대 그래프 비교표, 네 가지 한계, 토폴로지, 실행 그래프와 지식 그래프, 실패 모드, 관측 | <https://www.puppygraph.com/learn/graph-engineering> | 2026-08-24 |
| prompt·context·harness·loop engineering 다음 자리의 패러다임으로서의 Graph Engineering, System Intelligence | <https://arxiv.org/abs/2608.21156> | v1 2026-08-21, v2 2026-08-26 |
| executor, 엣지, 그래프 기반·함수형 API, 슈퍼스텝 체크포인트, 체크포인트에 저장되는 요청 | <https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/> | 2026-10-22, 갱신 2026-10-28 |
| 체크포인트 신뢰 경계, 슈퍼스텝 종료 시 체크포인트, human-in-the-loop 요청·응답 | <https://learn.microsoft.com/en-us/agent-framework/workflows/checkpoints> | 갱신 2026-11-01 |
| 노드, 엣지, 상태 키별 reducer, `Command(goto)`, map-reduce용 `Send`, 노드당 라우팅 방식 하나 | <https://docs.langchain.com/oss/python/langgraph/graph-api> | 날짜 표기 없음 |
| 동적 interrupt, `Command(resume=...)`로 재개, 재개 시 노드가 처음부터 다시 실행됨, 병렬 interrupt | <https://docs.langchain.com/oss/python/langgraph/interrupts> | 날짜 표기 없음 |
| agents as tools와 handoff, LLM 오케스트레이션과 코드 오케스트레이션 | <https://openai.github.io/openai-agents-python/multi_agent/> | 날짜 표기 없음 |
| 워크플로와 에이전트의 구분, 다섯 가지 워크플로 패턴, 단순성 원칙, sectioning과 voting | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, 갱신 2026-10-09 |
| 90.2% 개선, 약 4배·약 15배 토큰, subagent 50개, 적합성 기준, 노력 배분 | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13, 갱신 2026-10-09 |
| `JoinNode` 의미론, 자동으로 한정되지 않는 사이클, route 값, 동적 워크플로 | <https://adk.dev/graphs/routes/> | 날짜 표기 없음 |
| 노드 종류, edges 배열, `DEFAULT_ROUTE`, 그래프·동적 분류 | <https://adk.dev/graphs/> | 날짜 표기 없음 |
| 계획을 코드로 옮기는 동적 워크플로, 확인하지 못한 주장을 미검증으로 두는 검증자 | <https://code.claude.com/docs/en/workflows> | 날짜 표기 없음 |
