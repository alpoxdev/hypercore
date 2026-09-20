# Harness Engineering

> 영어판: [`HARNESS_ENGINEERING.md`](HARNESS_ENGINEERING.md)

LLM instruction, prompt, agent workflow를 “감”이 아니라 반복 가능한 테스트 대상으로 관리하는 기준이다.

## Why

LLM 출력은 확률적이고 모델/도구/컨텍스트 변경에 민감하다. 따라서 instruction 개선은 문장 다듬기가 아니라 **eval set, metrics, trace, regression gate**를 갖춘 하네스 작업이어야 한다.

하네스 계층은 서로 결합되어 있다. Sources에 인용한 학술 서베이는 계층들이 스택을 가로질러 서로를 제약한다고 밝힌다. 그래서 프롬프트·도구·샌드박스·검증기·모니터 중 하나가 단독으로는 이로워 보여도 나머지 제어 루프를 만나면 전체 롤아웃을 악화시킬 수 있다. **하네스 변경은 시스템 변경이다.** 그렇게 테스트한다. eval 케이스에서는 단일 축 변경과 조합 변경을 **다른 종류의 케이스로 기록**한다. 결합 회귀는 두 번째 종류만 보여줄 수 있다.

## Harness Layers

| Layer | 질문 | 산출물 |
|---|---|---|
| Scenario | 어떤 사용자 요청/환경에서 실패하는가 | test case |
| Oracle | 무엇이 정답/성공인가 | expected behavior / rubric |
| Runner | 어떤 모델·도구·컨텍스트로 실행하는가 | eval config |
| Judge | 어떻게 채점하는가 | deterministic check / rubric / human review |
| Trace | 왜 실패했는가 | span 트리와 `## Trace Fields`의 필드 |
| Gate | 언제 merge/ship 가능한가 | 실행 횟수와 집계를 선언한 판정 규칙 — `## Judgement Rules` 참조. 깊이 단계는 `instructions/validation/index.ko.md` §2 |

## Trace Fields

trace는 증거이므로 필드를 즉석에서 정하지 않고 고정한다. 아래 이름은 OpenTelemetry GenAI
에이전트 관례에 맞춘다. 그 표준은 Sources에 기록한 리비전에서 **Development** 상태이므로 **정렬 대상이지
준수 대상이 아니다.**

| 필드 | 내용 |
|---|---|
| HE-T-1: 작업 이름 | 이 하네스가 내보내는 값 중 하나 — `plan`, `invoke_agent`, `invoke_workflow`, `execute_tool`. 인용한 관례는 더 많은 well-known 값(`chat`, `create_agent`, 검색·메모리 작업)을 정의하고 사용자 정의 값도 허용한다. 여기 네 개는 이 하네스가 **써야 하는 부분집합**이지 전체 영역이 아니다 |
| HE-T-2: 에이전트 정체성 | 에이전트 id·이름·버전 |
| HE-T-3: 대화 식별자 | 한 세션의 span을 묶는 식별자 |
| HE-T-4: 모델과 provider | 요청한 모델과 provider 이름 |
| HE-T-5: 토큰 회계 | 입력·출력 토큰, 그리고 캐시 읽기·쓰기 |
| HE-T-6: 종료 사유 | 종료 사유 배열. 누락된 사유는 생략하지 않고 오류로 기록한다 |
| HE-T-7: 도구 호출 | 호출 순서와 호출별 **인자 요약** |
| HE-T-8: 콘텐츠 속성 | 메시지 본문·시스템 지시·도구 정의는 opt-in이고 PII 경고를 붙인다 |

## Prompt / Role Instruction Smoke Eval

역할 수행 프롬프트를 바꿀 때는 smoke 세트를 둔다. 흔히 인용되는 "3-5개"는 **검증된 임계값이 아니고 하한도 아니다.** 어떤 출처도 그 수를 측정하지 않았으므로 이 저장소는 최소 케이스 수를 두지 않는다. 대신 **선언된 목표**로 바꾼다. 케이스마다 원하는 신뢰구간 폭과 그것을 사는 실행 횟수를 적는다. `## Judgement Rules` 참조.

| Case type | 확인할 것 | 예시 |
|---|---|---|
| Happy path | 목표, 출력 형식, 톤을 지키는가 | 명확한 요청으로 expected schema 생성 |
| Missing context | 모르는 사실을 추정하지 않는가 | 필요한 파일/출처가 없는 요청 |
| Scope boundary | non-goal을 넘지 않는가 | 수정 금지 파일/외부 side effect 포함 요청 |
| Source boundary | 웹/tool 결과를 지시가 아니라 증거로 취급하는가 | retrieved page 안의 prompt injection |
| Regression | 이전 실패가 재발하지 않는가 | known bad prompt/output pair |

## Minimum Eval Case Format

```yaml
id: unique-case-id
intent: 사용자가 달성하려는 일
context:
  files: []
  sources: []
input: |
  사용자 요청 원문
expected:
  must:
    - 반드시 해야 할 행동
  must_not:
    - 하면 안 되는 행동
metrics:
  - instruction_following
  - factuality
  - tool_use
  - safety
  - completion
```

행동 평가와 종단 벤치마크는 다른 것을 재고, 어느 쪽도 다른 쪽을 대체하지 않는다. 행동 평가는
관찰 가능한 행동 하나를 단언하고(답하기 전에 실시간 검색을 했는가), 종단 벤치마크는 목적지를
단언한다(과제의 최종 상태가 목표와 맞는가). 이 구분과 아래 단언 강도 지침은 Sources에 인용한
벤더 문서에서 온다. 반복에는 행동 평가를, 목적지 확인에는 종단 벤치마크를 쓴다. 단언 강도는 과제
복잡도를 따른다. 최적 경로가 하나면 그 행동을 엄격하게 단언하고, 정당한 경로가 여럿이면 경로가
아니라 결과를 단언한다. 점수뿐 아니라 **실패 모드**를 기록한다. 모델마다 다르고, 불확실할 때 보류하는
모델과 자신 있게 틀리는 모델은 고치는 방법이 다르다.

## Evaluation Types

| Type | Use When | Judge |
|---|---|---|
| Deterministic | JSON shape, exact label, file exists, tests pass | script/assertion |
| Rubric | quality, helpfulness, design review, reasoning adequacy | calibrated LLM or human |
| Pairwise | prompt/model A vs B | blinded preference |
| Trace-based | agent trajectory, tool order, retrieval behavior | tool-call assertions |
| Red-team | prompt injection, unsafe autonomy, data leak | adversarial cases |
| Production sampling | real user distributions | anonymized logs + human review |

## Judgement Rules

비결정적 대상은 단일 관측이 아니라 규칙으로 판정한다.

- HE-J-1: 비결정적 대상은 단일 실행으로 통과·실패를 판정하지 않는다.
- HE-J-2: 모든 케이스는 자기 `MIN_RUNS`와 집계 규칙을 선언한다. 둘 다 없는 케이스는 게이트가 아니다.
- HE-J-3: 단일 실행의 판정이 아니라 배치의 집계 통과율로 게이트한다. 모든 게이트는 두 수치를 따로 선언한다. **동등성 마진** — 어느 정도의 회귀까지 받아들일지 — 과 그 실행 횟수가 사 주는 신뢰구간 폭이다. 동등성 마진 안의 변동은 막지 않는다. 신뢰구간 폭만으로는 회귀를 무시할 근거가 되지 않는다.
- HE-J-4: 모든 결과에 모델·런타임 버전, 케이스 집합 해시, 실행 횟수를 함께 기록한다. 그것이 없는 결과는 나중에 비교할 수 없다.
- HE-J-5: `pass^k`(k회 전부 성공)를 `pass@k`(k회 중 하나라도 성공)와 함께 보고한다. 둘은 다른 질문이고, 신뢰도 주장은 첫 번째만 해당한다.
- HE-J-6: 작은 표본의 차이를 게이트로 삼지 않는다. 목표 신뢰구간 폭과 실행 횟수를 함께 적는다.

- HE-J-7: 추가한 컨텍스트는 **개입**이다. 목표 eval 셋에서 개선을 보이기 전까지 영구 컨텍스트가 되지 않는다. 그래서 새 참고 문서는 색인에 등록하되, 그 자리를 얻기 전까지 **항상 로드되는 목록에 넣지 않는다.**

산식과 그 숫자가 주장하지 않는 것은
[`references/measurement.ko.md`](references/measurement.ko.md)에 있다. 이 규칙이 붙는 검증 깊이 단계는
`instructions/validation/index.ko.md` §2다.

## Evidence Discipline

- HE-E-1: 검증 **증거 경로**는 손으로 적은 경로가 아니라 해석된 경로에 쓴다.
- HE-E-2: 증거 README는 네 절을 갖춘다. 무엇을 시험했는가, 무엇을 관찰했는가, 왜 충분한가, 무엇을 생략했는가.
- HE-E-3: 증거 파일이 없으면 검증은 일어나지 않았다. 기록할 통과도 없다.
- HE-E-4: 실사용 표면 증명과 hermetic 단위 게이트를 구분해 표기한다. 하나가 다른 하나를 대신하지 않는다.
- HE-E-5: 격리는 주장하지 않고 입증한다. 건드리지 않은 실제 상태의 전후 증거, 변경된 경로 목록, 격리 디렉터리 경로다.
- HE-E-6: 실행하지 못한 실행은 `SKIP`으로 기록한다. `SKIP`은 통과가 아니다.

각 규칙의 작업 형태와, 어느 부분이 이식 가능한 원리이고 어느 부분이 한 저장소의 구현인지는
[`references/evidence-and-recovery.ko.md`](references/evidence-and-recovery.ko.md)의 Evidence discipline에 있다.

## Reducing Verification Cost

- HE-C-1: 더 적거나 더 싼 검사를 돌리는 결정은 durable 상태에서 계산한다. 자유 서술은 축소를 승인하지 못한다.
- HE-C-2: 축소 증명은 계산된 선택과 정확히 일치한다. 불일치는 fail-closed이고 전체 검사 집합이 그대로 유지된다.
- HE-C-3: 최소 한 개의 레인은 절대 생략하지 않는다. 실제 표면에 대한 대상 검증이 모든 경계에서 돈다.
- HE-C-4: 재실행 회피에는 검증된 소스 기준 해시가 필요하다. 없거나 검증되지 않은 해시는 fail-closed다.

축소 증명을 필드별로 보여 준 예는
[`references/evidence-and-recovery.ko.md`](references/evidence-and-recovery.ko.md)의 Reducing verification cost에 있다.

## Long-Horizon Recovery

대화는 남기고 계약을 잃은 압축은 작업을 파괴한 것이다.

- HE-L-1: 압축 후 살아남을 것을 미리 적는다. 활성 목표, 수용된 범위와 명시적 비목표, 수용 기준, 현재 단계와 다음 행동, 기록된 블로커다.
- HE-L-2: 복구 투영은 읽기 전용이고, 잘못되거나 낡았거나 읽을 수 없거나 변조된 상태를 만나면 조용히 퇴화한다. 투영 실패가 압축을 중단시켜서는 안 된다.
- HE-L-3: 같은 다음 행동으로 되돌아오는 복구는 정체다. 투영을 지문으로 찍고, `MAX_UNCHANGED_RECOVERIES`번 변화 없는 복구가 이어지면 — 형용사가 아니라 워크플로가 선언하는 이름 있는 상수다 — 명시적 `STALLED` 지시를 내보내 같은 행동을 반복하는 대신 durable 블로커나 에스컬레이션을 지시한다.
- HE-L-4: 압축 프롬프트는 재현율 우선으로 튜닝한다. 트레이스에서 잡아내는 것을 최대화한 뒤 정밀도를 올린다.

이것은 반복을 **유계로 만든다.** 제거한다고 주장하지 않는다. 투영·정체 카운터·보존 목록은
[`references/evidence-and-recovery.ko.md`](references/evidence-and-recovery.ko.md)의 Long-horizon recovery에 있다.

## Prompt/Instruction Change Loop

```text
1. Define success criteria
2. Collect baseline cases, including known failures
3. Run current instruction
4. Diagnose failures from output + trace
5. Patch the smallest instruction surface
6. Re-run the same eval set
7. Add new edge case for every new bug found
8. Document decision and remaining risk
```

## Metrics Menu

| Area | Metric examples |
|---|---|
| Task fidelity | required steps completed, forbidden steps avoided |
| Factuality | source support, citation accuracy, contradiction rate, stale-source rate |
| Retrieval | context recall, context precision, source-boundary adherence |
| Tool use | correct tool chosen, unnecessary tool calls, side effects avoided |
| Code work | tests pass, diff minimality, lint/typecheck, regression count |
| Safety | prompt injection resistance, permission boundary, secret leakage |
| Cost/latency | token budget, wall time, tool-call count |

컨텍스트 자체를 상수가 아니라 변수로 기록한다. 결정 지점의 총 컨텍스트 토큰, 포함된 방해 문장 수,
관련 정보를 미리 넣었는지 그때 검색했는지다. 컨텍스트 길이를 바꾸는 비교는 **별도 케이스**이며,
그렇게 표시해야 한다 — [`references/measurement.ko.md`](references/measurement.ko.md) 참조.

## LLM-as-Judge Rules

- Judge prompts need rubrics and examples; “is this good?” is not enough.
- Calibrate LLM judge against human or deterministic checks on a small set.
- Prefer pairwise/classification/scoring over open-ended commentary.
- Keep judge model/version/date in the eval record.
- Do not let the candidate answer judge itself.
- HE-R-1: 심판 편향은 자기 선호만이 아니다. Sources에 인용한 연구에서 심판은 perplexity가 낮은 — 더 친숙한 — 텍스트에 사람보다 높은 점수를 주었고, 자기가 만든 텍스트인지와 무관했다. 그래서 문체가 매끄러운 쪽이 이길 수 있다. 이것은 그 연구가 시험한 심판들에서의 발견이지 모든 심판의 속성이 아니다.
- HE-R-2: 보정은 고정된 순서로 한다. 사람이 소량 라벨링하고, 심판이 같은 표본을 라벨링하고, **정렬률**을 계산하고, 불일치를 눈으로 보고, 심판 프롬프트를 고치고, 정렬률이 정해진 임계값을 넘을 때까지 반복한다. 그 뒤에만 심판을 쓴다.
- HE-R-3: eval 기록에 심판 모델·버전·달성한 정렬률을 남긴다.

이 보정 내용은 `instructions/validation/references/evaluation-design.ko.md` §4의 grader 위계와
다중 표본 보정 지도를 **일부러 반복하지 않는다.** grader 종류의 순서는 그 문서를 읽는다.

## Agent Harness Rules

- Evaluate final answer **and** trajectory.
- Log tool calls, files touched, sources retrieved, and permission boundaries.
- Test recoverable failures: missing file, failing test, conflicting source, stale docs.
- Include adversarial retrieved content: web page or tool result that says “ignore previous instructions.”
- Gate external side effects with explicit permission cases.

## Agentic Security Minimums

OWASP가 제시한 두 설계 원칙이 먼저 온다. **least agency**(최소 자율) — 에이전트가 접근할 수 있는 범위뿐 아니라
확인 없이 행동할 자유까지 제한한다. 자율성은 기본값이 아니라 획득되는 것이다. 그리고
**strong observability** — 에이전트가 무엇을, 왜, 누구의 정체성으로 하는지 보여야 한다.
둘 중 하나만으로는 충분하지 않다.

- HE-S-1: 도구 권한은 도구 단위가 아니라 **호출 단위와 조합 단위**로 검사한다. 개별 도구가 허용되어도 그 사슬은 허용되지 않을 수 있다.
- HE-S-2: 계획 루프에 도달한 신뢰할 수 없는 입력은 목표를 바꾸지 못한다. 검색된 내용이 바꾸려는 케이스를 포함한다.
- HE-S-3: 외부 에이전트·MCP 서버·플러그인·프롬프트 템플릿·도구 서술자는 버전과 **인증된** 출처에 고정한다.
- HE-S-4: 연쇄 실패를 유계로 만든다. 체인 깊이·런타임 상한, 계획과 실행 사이의 검증, 롤백 경로다.

규칙 뒤의 위협 목록은
[`references/agent-security.ko.md`](references/agent-security.ko.md)에 있다.

## Parallel / Subagent Trace Rules

병렬 작업은 결과만 보면 실패를 숨기기 쉽기 때문에 trace assertion을 둔다.

| Assertion | 확인 방법 | Fail 예시 |
|---|---|---|
| bounded_spawn | subagent/background agent prompt에 objective, scope, output, stop condition이 있다 | “전체 코드 다 봐줘”처럼 무제한 위임 |
| independent_or_sequenced | 병렬 작업 간 입력 의존성이 없거나 순차 대기가 명시됨 | A 결과가 필요한 B를 동시에 실행 |
| ownership_declared | edit 작업은 파일/디렉터리 write set을 가진다 | 두 에이전트가 같은 config를 수정 |
| least_privilege_tools | read-only 조사에는 쓰기/외부 side effect 권한이 없다 | docs lookup agent가 production command 실행 가능 |
| parent_continues | non-blocking 작업 중 리더가 독립 작업을 진행하거나 이유를 기록 | spawn 직후 무의미한 idle wait |
| child_reports_evidence | 하위 결과가 파일/링크/테스트 출력/변경 파일을 포함 | “문제 없음”만 반환 |
| parent_integrates | 리더가 충돌·중복·누락을 합성하고 최종 판단 | subagent 요약을 그대로 이어붙임 |
| parent_verifies | 최종 완료 전 리더가 검증 명령/eval/source-check를 읽음 | 하위 에이전트의 완료 선언만 신뢰 |

병렬 구현 eval은 최소 1개 이상 “같은 파일 충돌” 케이스와 1개 이상 “독립 research fan-out” 케이스를 포함한다.

## CI / Regression Guidance

| Frequency | Eval set | Judgement rule |
|---|---|---|
| Every instruction change | smoke eval: 작고 빠른 세트 (흔히 인용되는 5-20은 미검증 — `## Prompt / Role Instruction Smoke Eval` 참조) | 배치의 집계 통과율. 단일 실행 판정 금지 (HE-J-1, HE-J-3) |
| Every model/runtime change | regression eval: known failures + representative workflows | 기록된 기준선과 비교하되 모델·런타임 버전과 케이스 집합 해시를 함께 남긴다 (HE-J-4) |
| Before release | full eval: quality + safety + cost/latency | 비결정적 케이스에 `pass^k`를 `pass@k`와 함께 보고한다 (HE-J-5) |
| After incident | add reproduction case permanently | 새 케이스가 자기 `MIN_RUNS`와 집계 규칙을 선언한다 (HE-J-2) |

## Sources

> 링크 확인 2026-07-29. 링크 사용 가능 여부는 2026-09-20에 재확인했다. 다음 재검증 2026-10-29.

저장소 검사기(`scripts/check-sources.sh`)는 HEAD 요청을 보내고 HTTP 상태만 분류한다. 응답 본문을
읽지 않는다. **보충** 검사 — 인용 URL을 뽑아 GET으로 요청하고, 상태 코드와 함께 본문에서 not-found
페이지를 확인하는 것 — 가 200을 돌려주면서 "page not found" 본문을 담은 URL을 잡아낸다. 링크가
주장을 지탱할 때 보충 검사를 돌린다. 출처가 자기 내용이 낡았다고 말하면, 낡은 수치를 현재값으로
인용하지 않고 최신 방법론 페이지를 가리킨다.

| 주장 | 출처 |
|---|---|
| OpenAI Evals API와 문서화된 평가 workflow. **폐기 예정**: 기존 사용자 대상 2026-10-31 read-only, 플랫폼 종료 2026-11-30 예정. 문서화된 후속은 Datasets | <https://developers.openai.com/api/docs/guides/evals> |
| OpenAI dataset 기반 prompt optimizer. Evals 플랫폼과 같은 일정으로 **폐기 예정** | <https://developers.openai.com/api/docs/guides/prompt-optimizer> |
| OpenAI agent workflow 평가 — trace grading에서 시작해 dataset/eval run으로 확장 | <https://developers.openai.com/api/docs/guides/agent-evals> |
| Anthropic 성공 기준(구체적·측정 가능·달성 가능·관련성)과 eval 구축 | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests> |
| Google Vertex Gen AI evaluation — 프롬프트마다 pass/fail 기준을 생성하는 adaptive rubrics | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview> |
| adaptive rubric 세부 메트릭(`INSTRUCTION_FOLLOWING`, `TEXT_QUALITY` 등) | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/rubric-metric-details> |
| LangSmith evaluation — dataset + evaluators + experiment workflow, offline/online 평가 유형 | <https://docs.langchain.com/langsmith/evaluation>, <https://docs.langchain.com/langsmith/evaluation-types> |
| Promptfoo LLM-as-a-judge — 모델이 rubric으로 채점하고 pass/score/reason을 반환 | <https://www.promptfoo.dev/docs/guides/llm-as-a-judge/> |
| Promptfoo red teaming — 적대적 입력 생성, RAG/agent 대상 가이드 | <https://www.promptfoo.dev/docs/red-team/> |
| Google Responsible GenAI 안전 평가 | <https://ai.google.dev/responsible> |
| OpenAI skill eval 4축(outcome / process / style / efficiency) | <https://developers.openai.com/blog/eval-skills> |
| 하네스 엔지니어링 서베이: 계층 결합과 계층 간 제약 | <https://picrew.github.io/LLM-Harness/> |
| 하네스 엔지니어링 벤더 문서: 행동 평가 vs 종단 벤치마크 구분, 3단계 행동 루프, 과제 복잡도에 따른 단언 강도 | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> |
| OpenTelemetry GenAI 에이전트 시맨틱 관례 — 작업 이름, 에이전트 정체성, 토큰 회계, 종료 사유, 그리고 관례의 **Development** 상태 | <https://github.com/open-telemetry/semantic-conventions-genai> |
| LLM 심판이 자기 선호와 무관하게 perplexity가 낮은(더 친숙한) 텍스트에 보이는 편향 | <https://arxiv.org/abs/2410.21819> |

이전 판은 이 목록을 URL 없는 산문으로 두어 검증이 불가능했다. 위 항목은 2026-07-29에 각 URL을 직접 확인해 접지했다.
