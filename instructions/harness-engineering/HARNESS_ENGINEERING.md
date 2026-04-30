# Harness Engineering

LLM instruction, prompt, agent workflow를 “감”이 아니라 반복 가능한 테스트 대상으로 관리하는 기준이다.

## Why

LLM 출력은 확률적이고 모델/도구/컨텍스트 변경에 민감하다. 따라서 instruction 개선은 문장 다듬기가 아니라 **eval set, metrics, trace, regression gate**를 갖춘 하네스 작업이어야 한다.

## Harness Layers

| Layer | 질문 | 산출물 |
|---|---|---|
| Scenario | 어떤 사용자 요청/환경에서 실패하는가 | test case |
| Oracle | 무엇이 정답/성공인가 | expected behavior / rubric |
| Runner | 어떤 모델·도구·컨텍스트로 실행하는가 | eval config |
| Judge | 어떻게 채점하는가 | deterministic check / rubric / human review |
| Trace | 왜 실패했는가 | tool calls, retrieved sources, logs |
| Gate | 언제 merge/ship 가능한가 | pass threshold / blocking criteria |

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

## Evaluation Types

| Type | Use When | Judge |
|---|---|---|
| Deterministic | JSON shape, exact label, file exists, tests pass | script/assertion |
| Rubric | quality, helpfulness, design review, reasoning adequacy | calibrated LLM or human |
| Pairwise | prompt/model A vs B | blinded preference |
| Trace-based | agent trajectory, tool order, retrieval behavior | tool-call assertions |
| Red-team | prompt injection, unsafe autonomy, data leak | adversarial cases |
| Production sampling | real user distributions | anonymized logs + human review |

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
| Factuality | source support, citation accuracy, contradiction rate |
| Retrieval | context recall, context precision, stale-source rate |
| Tool use | correct tool chosen, unnecessary tool calls, side effects avoided |
| Code work | tests pass, diff minimality, lint/typecheck, regression count |
| Safety | prompt injection resistance, permission boundary, secret leakage |
| Cost/latency | token budget, wall time, tool-call count |

## LLM-as-Judge Rules

- Judge prompts need rubrics and examples; “is this good?” is not enough.
- Calibrate LLM judge against human or deterministic checks on a small set.
- Prefer pairwise/classification/scoring over open-ended commentary.
- Keep judge model/version/date in the eval record.
- Do not let the candidate answer judge itself.

## Agent Harness Rules

- Evaluate final answer **and** trajectory.
- Log tool calls, files touched, sources retrieved, and permission boundaries.
- Test recoverable failures: missing file, failing test, conflicting source, stale docs.
- Include adversarial retrieved content: web page or tool result that says “ignore previous instructions.”
- Gate external side effects with explicit permission cases.

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

| Frequency | Eval set |
|---|---|
| Every instruction change | smoke eval: 5-20 fast cases |
| Every model/runtime change | regression eval: known failures + representative workflows |
| Before release | full eval: quality + safety + cost/latency |
| After incident | add reproduction case permanently |

## Sources

- OpenAI evaluation best practices and Evals API guidance
- Anthropic success criteria and evaluation tool guidance
- Google Vertex Gen AI evaluation adaptive rubrics
- LangSmith evaluation datasets/evaluators
- Promptfoo guides for factuality, LLM-as-judge, chains, agents, red teaming
- Google Responsible GenAI safety evaluation lifecycle
