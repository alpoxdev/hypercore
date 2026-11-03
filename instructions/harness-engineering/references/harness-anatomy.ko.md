# Harness Anatomy and Staleness

> 영어판: [`harness-anatomy.md`](harness-anatomy.md)

하네스가 무엇이고 어떤 부품으로 이루어지는지, 그리고 그 부품이 자기가 맞춰 만든 모델보다 오래 살아남지
않게 하는 생애주기 규칙을 다룬다. **규범**은 [`HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## What a Harness Is`와 `## Harness Staleness`에 있고, 이 파일에는 정의와 부품 목록, 근거를 둔다.

## 작업 정의

2025~2026년의 1차 출처는 모두 같은 모양으로 수렴했다. 하네스는 한 실행에서 모델이 아닌 전부다.

| 출처 | 진술 |
|---|---|
| Anthropic 문서 | "Claude Code is the layer around the model that provides the tools and manages the context the model sees. This surrounding layer is what the term agentic harness refers to." |
| OpenAI | "A capable agent is more than a prompt and a model response. It needs a way to understand a task, maintain context over time, inspect relevant information, call tools, expose progress, handle failures, request human approval when necessary, and return a useful result. That surrounding execution system is the harness." |
| 실무자 정의 | "Agent = Model + Harness. If you're not the model, you're the harness." |
| 실무자 정의 | "A raw model is not an agent. It becomes one once a harness gives it state, tool execution, feedback loops, and enforceable constraints." |

**HE-A-1.** 하네스는 모델을 둘러싼 실행 시점의 체계다. 모델이 읽는 지시, 호출할 수 있는 도구,
컨텍스트를 조립하고 압축하는 방식, 코드가 실행되는 장소, 출력을 검사하는 장치, 행동을 기록하는
수단, 그리고 산출물이 나가도 되는지 정하는 게이트가 모두 여기 들어간다. 에이전트의 행동을 바꾸면서
모델 가중치가 아닌 구성 요소는 하네스의 일부이고, 이 문서의 적용 대상이다.

이 정의에는 날카로운 귀결이 따라온다. OpenAI의 표현대로 "From the agent's point of view, anything it
can't access in-context while running effectively doesn't exist."이다. 위키에 있는 지시, 아무도 적지
않은 관례, 검토자의 기억은 약한 하네스가 아니라 **없는** 하네스다.

## 부품 목록

각 행은 부품, 그 부품이 맡는 결정, 그리고 그것이 빠졌을 때 나타나는 실패다. 마지막 열은 이 저장소가
그 부품을 어디서 시험하는지 밝힌다.

| 부품 | 맡는 결정 | 빠졌을 때의 실패 | 시험 지점 |
|---|---|---|---|
| 지시 계층 | 목표·범위·형식에 관해 모델이 듣는 것 | 에이전트가 엉뚱한 목표를 자신 있게 최적화한다 | smoke eval, `## Prompt / Role Instruction Smoke Eval` |
| 도구 표면 | 어떤 행동이 있고 어떤 스키마와 부작용을 갖는지 | 엉뚱한 도구로 즉흥 처리하거나 게이트를 우회한다 | trace assertion, `must_call` / `must_not_call` |
| 컨텍스트 관리자 | 무엇이 언제 어느 경로로 창에 들어가는지(선로드, 검색, 압축) | 창이 차면서 회수율이 떨어지는 컨텍스트 부패 | [`measurement.ko.md`](measurement.ko.md)의 컨텍스트 변수 |
| 실행 경계 | 모델이 쓴 코드와 명령이 실제로 도는 장소 | 잘못된 단계가 프로덕션이나 자격증명에 닿는다 | 격리 증거, HE-E-5 |
| 검증기·센서 | 에이전트가 틀렸다는 사실을 행동 가능한 형태로 알려 주는 것 | 스스로를 긍정 평가하고 일찍 멈춘다 | HE-R-4, red-team 케이스 |
| trace·모니터 | 무엇을 어떤 순서로 어떤 인자로 시도했는지 | 실패가 보이지 않고 최종 답만 검토된다 | `## Trace Fields` |
| 게이트 | 언제 merge·ship이 가능한지 | 마지막 실행이 좋아 보인다는 이유로 회귀가 들어온다 | HE-J-1 ~ HE-J-7 |
| 예산·상한 | 얼마나 오래, 얼마나 깊게, 몇 토큰까지 | 열린 요청 하나가 몇 시간을 쓴다 | 반복 상한, [`instructions/loop-engineering/LOOP_ENGINEERING.ko.md`](../../loop-engineering/LOOP_ENGINEERING.ko.md) |

## 가이드와 센서

검토에 가장 쓸모 있는 구분은 Birgitta Böckeler의 것이다. 하네스 통제는 **피드포워드**(행동 전에
조종한다)이거나 **피드백**(행동 후에 관찰해 스스로 고치게 한다)이다.

> "Guides (feedforward controls) - anticipate the agent's behaviour and aim to steer it before it
> acts." … "Sensors (feedback controls) - observe after the agent acts and help it self-correct.
> Particularly powerful when they produce signals that are optimised for LLM consumption, e.g.
> custom linter messages that include instructions for the self-correction - a positive kind of
> prompt injection."

실무적으로 두 가지를 읽는다.

- 지시 파일의 규칙은 가이드다. 구조상 권고일 수밖에 없다. 모델이 읽지 않을 수 있고, 잘못 읽을 수
  있고, 다른 지시와 견주어 trade-off할 수 있다.
- 훅, 실패하는 검사, 호출을 거부하는 도구는 이가 달린 센서다. 결과를 되돌릴 수 없을 때 이 구분이
  결정적이다. 산문은 강제하지 못하고, 훅은 강제한다.

Böckeler는 이 파일의 나머지가 의존하는 경계 조건도 밝힌다. "Not every codebase is equally amenable to
harnessing." 하네스는 이식 가능한 산출물이 아니다. 특정 실패 이력에 대한 응답이다.

## 정체(staleness) 규칙

모든 부품은 모델이 혼자 하지 못할 일에 대한 내기를 담고 있고, 모델은 그 내기 아래에서 바뀐다.

> "every component in a harness encodes an assumption about what the model can't do on its own,
> and those assumptions are worth stress testing, both because they may be incorrect, and because
> they can quickly go stale as models improve."

한 달 뒤 Anthropic은 구체적인 사례를 보고했다. 한 모델에서 필요했던 컨텍스트 리셋 부품이 후속
모델에서는 "dead weight"가 되었다. 그 부품이 보상하던 행동이 사라졌는데 부품은 남아 토큰을 쓰고
개선을 가렸다.

**HE-A-2.** 모든 하네스 부품은 자기 파일에 세 가지를 적는다. 담고 있는 가정("모델은 그렇지 않으면
X를 한다"), 재시험을 강제하는 계기(모델·런타임 변경), 그리고 자기를 삭제하는 관측(그 부품 없이도
eval 결과가 같다)이다.

보통 빠지는 것이 삭제 조건이고, 하네스가 민담이 되지 않게 막는 것도 그 조건이다. 삭제 조건이 없는
부품은 기본값으로 쌓인다. 남기는 데는 논증이 필요 없고 없애는 데는 논증이 필요하기 때문이다.

**HE-A-3.** 실패한 행동은 실행이 아니라 하네스에서 고친다. 수리는 지속되는 통제로 남는다. 그 실패에
추적되는 지시 한 줄, 에이전트가 그것을 감지하는 데 쓰는 도구, 또는 그것을 거부하는 검사다. 그리고
원래 실패를 재현하는 eval 케이스와 함께 들어간다.

이것이 이 용어가 만들어질 때 가리키던 실천이다. "anytime you find an agent makes a mistake, you take
the time to engineer a solution such that the agent never makes that mistake again"이며, 짝을 이루는
문장은 "the most sure-fire way to achieve this is to give the agent fast, high quality tools to
automatically tell it when it is wrong"이다. 반대편에서 같은 규칙을 적으면 이렇게 된다. "Every line
in a good AGENTS.md should be traceable back to a specific thing that went wrong."

**HE-A-4.** 하네스 비용은 가정하지 않고 측정한다. 각 부품은 자기가 부과하는 토큰·벽시계 시간·비용
차이를 보고하고, 결과는 모델별로 낸다. 같은 부품이 어떤 모델에서는 결정적이고 다른 모델에서는 무의미할
수 있기 때문이다.

규칙이 필요한 이유를 보여 주는 측정이다. 에이전트 코딩 과제를 조건당 10회, 인수 검사 178개로 짝지어
비교했다.

| 모델 | 하네스 없음 | 하네스 있음 | 부담 |
|---|---|---|---|
| 더 강한 모델 | 10/10 | 10/10 | 토큰 약 10.5배, 시간 약 3배, 비용 약 7배 |
| 더 약한 모델 | 3/10 | 10/10 | 토큰 약 3.9배, 시간 약 2.2배, 비용 약 3.2배 |

> "For GPT-6 Sol, the harness used about 10.5 times as many tokens, took nearly 3 times as long,
> and cost about 7 times more, yet both conditions succeeded in all 10 runs."

같은 비대칭이 Anthropic의 장기 실행 비용 보고에도 나온다. 단독 하네스는 같은 한 줄 프롬프트에 약
20분, 약 9달러를 썼고, planner/generator/evaluator 전체 하네스는 약 6시간, 약 200달러를 썼다. 둘 다
정당하다. 다만 모델과 과제를 밝히지 않으면 어느 쪽도 옳지 않다.

하네스는 점수도 바꾼다. 그래서 "모델이 좋아졌다"와 "하네스가 좋아졌다"는 따로 보고해야 한다.
ARC-AGI-3에서 추론 보존과 컨텍스트 압축이 한 모델의 점수를 13.3%에서 38.3%로 올리면서 출력 토큰을
6분의 1로 줄였다.

**HE-A-5.** 쓸모 있는 하네스의 공간은 닫히지 않고 이동한다. 모델이 좋아지면 그 약점을 보상하던
부품은 값을 잃고 새 능력을 활용하는 조합이 값을 얻는다. 따라서 하네스 검토는 한 번의 이관이 아니라
상시 활동이다.

> "From this work, my conviction is that the space of interesting harness combinations doesn't
> shrink as models improve. Instead, it moves, and the interesting work for AI engineers is to keep
> finding the next novel combination."

## 장기 실행의 형태

장기 실행 하네스마다 반복되는 부품이 둘 있고, 둘 다 정체되기 쉽다.

- **세션 부트스트랩.** 환경을 세팅하는 초기화 패스 뒤에, 증분 진전을 만들고 산출물을 남기는 작업
  패스가 이어진다. "an initializer agent that sets up the environment on the first run, and a coding
  agent that is tasked with making incremental progress in every session, while leaving clear
  artifacts for the next session." 지속되는 산출물이 기제다. 서술적인 커밋과 진행 파일이 그것이며,
  압축 이후 복구를 가능하게 하는 것도 같은 산출물이다(HE-L-1).
- **리셋과 인계.** 제자리에서 압축하는 대신 창을 완전히 비우고 구조화된 인계를 들고 새 에이전트를
  시작한다. 요약과는 다른 통제이고, 정체되는 주기도 다르다. 위의 dead weight 사례가 그 증거다.

둘 다 하는 일과 심판하는 일이 분리 가능하다는 데 기댄다. "Separating the agent doing the work from
the agent judging it proves to be a strong lever"이며, 이것이 HE-R-4의 근거다.

## 안티패턴

| 안티패턴 | 실패하는 이유 | 교정 |
|---|---|---|
| 지도 대신 설명서 | 긴 지시 파일은 매 턴 값을 치르는 컨텍스트이고 회수도 불안정하다 | "give Codex a map, not a 1,000-page instruction manual": 짧은 색인과 검색 가능한 문서 |
| 강제를 권고로 적기 | 산문은 호출을 거부하지 못한다 | 되돌릴 수 없는 결과는 훅·검사·도구 수준 정책으로 옮긴다 |
| 소유자·날짜·삭제 조건이 없는 부품 | dead weight가 쌓여 모델 개선을 가린다 | HE-A-2 |
| 하네스 대신 실행 고치기 | 같은 실패가 다음 과제에서 돌아온다 | HE-A-3 |
| 비용 없이 하네스 성과만 보고 | 측정된 이득 0에 토큰 10배를 쓰고도 진전으로 보인다 | HE-A-4 |
| 성공 로그를 길게 남기기 | 실패 신호가 묻힌다 | "success is silent, failures are verbose" |

## Sources

> 확인 2026-11-03.

**등급 어휘.** 이 디렉터리의 모든 출처 표가 쓰는 하나의 닫힌 집합이다. [`../HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## Sources`를 본다.

| 주장 | 출처 | Grade |
|---|---|---|
| "the layer around the model … the term agentic harness refers to" | <https://code.claude.com/docs/en/how-claude-code-works> | VENDOR |
| "That surrounding execution system is the harness", ARC-AGI-3 13.3% → 38.3%, 출력 토큰 6분의 1 | <https://developers.openai.com/blog/codex-as-a-platform> (2026-08-19 게시) | VENDOR |
| "Humans steer. Agents execute.", 지도 대 설명서 규칙, "anything it can't access in-context while running effectively doesn't exist" | <https://openai.com/index/harness-engineering> (2026-02-11) | VENDOR |
| "Agent = Model + Harness"와 부품 분류 | <https://www.vtrivedy.com/posts/the-anatomy-of-an-agent-harness> (2026-03-10) | PRACTITIONER |
| "A raw model is not an agent…", 래칫, 강제로서의 훅, "success is silent", 일하는 자와 심판의 분리 | <https://addyosmani.com/blog/agent-harness-engineering/> (2026-04-19) | PRACTITIONER |
| 가이드 대 센서, LLM이 소비하기 좋은 센서 출력, "not every codebase is equally amenable" | <https://martinfowler.com/articles/harness-engineering.html> (2026-04-02) | PRACTITIONER |
| 하네스 비용 짝 비교: 10회 실행, 인수 검사 178개, 토큰 10.5배·시간 3배·비용 7배, 모델별 격차 | <https://martinfowler.com/articles/are-harnesses-worth-the-cost.html> (2026-10-13) | PRACTITIONER |
| "anytime you find an agent makes a mistake…"와 에이전트에게 틀렸다고 알려 주는 빠른 도구 | <https://mitchellh.com/writing/my-ai-adoption-journey> (2026-02-05) | PRACTITIONER |
| 초기화 에이전트와 증분 세션, 서술적 커밋, 진행 파일 | <https://www.anthropic.com/research/effective-harnesses-for-long-running-agents> (2025-11-26) | VENDOR |
| "every component in a harness encodes an assumption…", 리셋과 구조화된 인계, 일하는 자와 심판의 분리, 20분·9달러 대 6시간·200달러 | <https://www.anthropic.com/research/harness-design-long-running-apps> (2026-03-24) | VENDOR |
| 모델 교체 후 컨텍스트 리셋이 dead weight가 된 사례, 하네스 가정을 자주 의심해야 한다는 지적 | <https://www.anthropic.com/research/managed-agents> (2026-04-08) | VENDOR |
| Radar 기법으로서의 피드백 센서와 그 주변의 하네스 평가 관행 | <https://www.thoughtworks.com/radar/techniques/feedback-sensors-for-coding-agents> | PRACTITIONER |

벤더 행의 날짜는 페이지에 표시된 게시일이다. Claude Code 문서 페이지에는 게시일이나 수정일이 보이지
않으므로 그 페이지에는 날짜를 주장하지 않는다.
