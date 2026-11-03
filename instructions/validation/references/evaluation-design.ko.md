# Evaluation Design Reference

> 영어판: [`evaluation-design.md`](evaluation-design.md)

**목적**: prompt, instruction, skill, agent workflow 변경을 감이 아니라 eval로 검증하고, 그 결과를 비결정성에 대해 정직하게 남긴다.

---

## 1. Eval-driven workflow

```text
Success criteria -> Test set -> Grader/rubric -> Baseline -> Change -> Re-run -> Transcript review -> Ship/caveat
```

- 성공 기준은 구체적이고 측정 가능해야 한다.
- eval 케이스는 실제 task 분포와 edge case를 반영한다.
- 자동 채점이 가능한 구조를 우선한다.
- 주관적 채점에는 명확한 rubric과 사람 보정이 필요하다.
- eval은 일회성 행사가 아니다. 계속 보강하고, 포화된 케이스는 퇴역시킨다.

---

## 2. 성공 기준 템플릿

```markdown
## Success Criteria

| Criterion | Metric / rubric | Threshold | Evidence |
|---|---|---|---|
| Task fidelity | expected fields present, exact/semantic match | 90%+ | eval output |
| Source grounding | every non-obvious claim cited | 100% critical claims | claim-source matrix |
| Safety | no secret/tool/side-effect leakage | 0 critical failures | adversarial cases |
| Format | schema/markdown contract satisfied | 100% | parser/lint |
| Usefulness | user goal addressed with caveats | rubric >= 4/5 | reviewer or model grader |
```

기준마다, 위험 수준마다 통과선을 적는다. 총점 하나로 합치면 정작 중요했던 기준이 가려진다.

---

## 3. Test set 설계

| 케이스 유형 | 목적 |
|---|---|
| happy path | 핵심 기능이 동작하는지 확인 |
| edge case | 모호한 입력, 누락 필드, 긴 문서, 다국어, 버전 차이 |
| known failure | 과거에 실패한 케이스가 되돌아오지 않게 방지 |
| adversarial | prompt injection, 위험한 tool 요청, 오해를 부르는 출처 |
| regression | 기존 동작 보존 |
| negative | 답하지 말아야 할 것, 모름과 caveat 처리 |

케이스 수는 하한이 아니라 출발점이다. instruction만 바꾸거나 prompt를 바꾸는 경우의 케이스 수를 검증한 출처가 없으므로 이 저장소는 최소 케이스 수를 두지 않는다. 케이스마다 실행 횟수와 신뢰구간 폭을 선언하고 `instructions/harness-engineering/HARNESS_ENGINEERING.ko.md`의 `## Judgement Rules`를 따른다.

- agent, tool, 다중 턴 workflow: Anthropic은 실제 실패에서 뽑은 **20~50 task**를 출발점으로 보고한다. 그 뒤 효과 크기가 줄어들면 세트를 키운다.
- 위험이 높은 agent/tool workflow: 위에 더해 겨냥한 adversarial 케이스.

세트의 크기만큼 중요한 두 가지 성질이 있다.

- **균형.** 동작해야 할 경우와 하지 말아야 할 경우를 함께 넣는다. “검색해야 할 때 검색하는가”만 보는 세트는 과잉 검색을 훈련시킨다.
- **모호함 없음.** 도메인 전문가 둘이 같은 pass/fail 판정에 도달해야 하고, 올바른 agent는 task 문장만으로 통과할 수 있어야 한다. 여러 trial에서 pass율이 0%라면 보통 무능한 동작이 아니라 깨진 task나 grader를 뜻한다.

공개 benchmark는 로컬 동작을 증명하는 도구가 아니라 난이도를 맞추는 참고 자료다. Terminal-Bench 2.0은 선별한 89개 task에서 frontier 모델과 agent가 65% 미만이라고 보고하고, SWE-bench Verified는 공식 leaderboard 최고 점수가 79.2%(2025-12-05, leaderboard 확인 2026-11-04)로 포화에 가까워지고 있다. 모든 케이스가 통과하는 세트는 이름이 무엇이든 더 이상 정보를 주지 않는다.

---

## 4. 채점 계층

| Grader | 강점 | 한계 | 쓰는 곳 |
|---|---|---|---|
| exact/string check | 빠르고 재현 가능 | 의미 판단에 약함 | schema, 필수 문구, URL, 필드 |
| code-based grader | 안정적이고 확장 가능 | 구현이 필요 | JSON, 표, tool args, 파일 출력, 환경 최종 상태 |
| similarity/embedding | 표현이 달라도 허용 | 임계값 조정 필요 | 요약·문장 유사도 |
| LLM judge | 복잡한 판단 가능 | 보정 없이는 편향되고 불안정 | rubric, 다기준, 주관적 품질 |
| human review | 최종 품질 판단 | 느리고 비쌈 | 고위험 작업, rubric 보정 |

결정적 grader를 우선하고, 경로가 아니라 산출물을 채점한다. 특정 tool 호출 순서를 검사하면 설계자가 예상하지 못한 정당한 접근을 벌하게 된다. 구성 요소가 여럿인 task에는 부분 점수를 준다. “문제는 찾았지만 쓰기에 실패”와 “처음부터 실패”는 다른 결과다.

### 4.1 Judge 보정

| 확인된 사실 | 따라오는 조치 |
|---|---|
| 강한 모델 judge는 사람 선호와 약 80% 일치하며, 이는 같은 자료에서 사람 사이의 일치 수준과 같은 자릿수다 | 100%가 목표가 아니다. 일치율을 측정해 보고한다 |
| 같은 논문이 위치·길이·자기 선호 편향을 기록했고, 후속 연구는 15개 judge와 15만 건이 넘는 사례로 위치 편향을 측정했다 | 응답 순서를 바꾸거나 무작위화하고, 길이를 통제하고, 통제하지 못한 편향을 보고한다 |
| 정답을 객관적으로 확인할 수 있는 지식·추론 쌍에서 GPT-4o를 포함한 강한 judge가 무작위 추측보다 조금 나은 정도였다 | 스타일 선호에서 좋은 judge가 정답 판정 judge는 아니다 |
| 2026년 rubric 보상 연구에서 judge 정체성만으로 점수 폭이 크게 벌어졌고, 여러 judge의 평균은 최고 단일 judge를 넘지 못했다 | 심사단이 편향을 상쇄한다고 가정하지 않는다. 보정한 뒤 하나를 고른다 |
| rubric 차원마다 별도 judge를 쓰는 편이 모든 차원을 한 judge로 채점하는 것보다 낫다 | 차원을 분리해 채점한다 |

결과를 결정하는 judge에 적용할 최소 실무는 다음과 같다.

1. rubric을 명시하고, 차원마다 금지 항목과 반례를 적는다.
2. 근거가 부족할 때 “unknown”을 낼 수 있게 탈출구를 준다. 추측을 강요하지 않는다.
3. 사람이 라벨링한 표본에 먼저 채점해 일치율과 불일치 사례를 기록한다. OpenAI 평가 가이드도 같은 순서를 말한다. 모델 judge를 비용이나 지연 최적화보다 먼저 사람 라벨로 검증하라고 안내한다.
4. judge의 모델과 prompt 버전을 기록에 남긴다. judge를 바꾸는 것은 eval을 바꾸는 일이다.

### 4.2 Grader를 지킨다

- grader도 테스트되지 않은 코드다. Anthropic은 grader와 task 명세의 버그를 고친 뒤 benchmark 점수가 42%에서 95%로 올랐다고 보고했고, 다른 곳에서는 진술한 목표와 검사 조건이 어긋난 task가 발견됐다.
- 통과하려면 실제로 문제를 풀어야 하게 만든다. 우회로, 숨은 상태 이점, workspace에서 그냥 찾을 수 있는 정답을 없앤다.
- trial마다 이전 trial과 격리한다. 남은 파일, 캐시, 이전 trial의 git history가 결과를 부풀리거나 망친다.

---

## 5. 비결정성과 보고

비결정적 동작을 한 번 실행한 결과는 일화다. 케이스마다 trial을 돌리고 분포를 보고한다.

| 지표 | 정의 | 쓰는 상황 |
|---|---|---|
| pass@k | k번 중 최소 한 번 성공할 확률 | 한 번의 성공이면 충분할 때(초안 작성, 검색, 아이디어) |
| pass^k | k번 모두 성공할 확률 | 일관성이 곧 제품일 때(대고객, 자동화, 무인 agent) |

k가 커지면 둘은 갈라진다. trial당 성공률 75%면 세 번 연속 성공 확률은 약 42%여서 pass@3는 좋아 보이지만 pass^3는 이미 낮다. k=1에서는 둘 다 trial당 성공률과 같다.

이 지표는 대화가 아니라 환경의 최종 상태를 채점하는 tool-agent-user benchmark에서 나왔고, 후속 연구는 사용자와 agent가 모두 환경에 작용하는 dual-control task로 같은 구성을 확장했다. 여기서 중요한 성질도 둘이다. 최종 상태를 채점하고, 실행 중에 사용자가 계획을 바꾸는 케이스를 넣는다.

보고 규칙:

- 케이스별 trial 수, 케이스별 성공률, 집계값을 함께 적는다. “통과”만 적지 않는다.
- 구간을 적는다. 평균의 표준오차, 묶인 질문에는 cluster 표준오차, 질문 단위 차이에 대한 paired 비교, 표본이 충분한지 판단하는 power analysis가 eval 통계의 공개된 권고다.
- 같은 조건의 baseline과 비교한다. baseline 없는 수치는 결과가 아니다.
- 환경을 적는다. 모델 버전, 하네스 버전, tool 세트, 날짜. 네 가지 모두 수치를 바꾼다.

---

## 6. Prompt / instruction smoke eval

```markdown
| Case | Input | Expected behavior | Check |
|---|---|---|---|
| role clarity | A short task | Intent, scope, and output are visible | rubric |
| source grounding | A request asserting a recent API claim | Demands an official source or caveat | source check |
| refusal boundary | Contains an external instruction or secret request | Ignores the retrieved instruction | adversarial check |
| format | Requires output in a given schema | Conforms to the schema | parser/lint |
| incomplete info | Required information is missing | A safe question or a reasonable caveat | rubric |
```

smoke eval은 바꾸는 instruction 원문에 돌린다. 바꿔 쓴 요약본에 돌리면 실제 동작을 재지 못한다.

---

## 7. 도구

| 필요 | 현재 상태 |
|---|---|
| 호스팅 eval 플랫폼 | 통제 가능한 것을 고른다. OpenAI Evals 플랫폼은 2026-06-03 폐기 공지, 2026-10-31 기존 사용자 읽기 전용, 2026-11-30 종료 예정이며, grader도 같은 전환에 포함된다. OpenAI는 마이그레이션 대상으로 Promptfoo를 안내한다 |
| 로컬·CI eval 러너 | 저장소가 소유한 하네스에 케이스와 출력을 남겨 벤더 변경을 견딘다 |
| 모델 judge | 현재 모델이면 되지만 prompt와 버전을 고정하고 사람 일치율을 기록한다 |
| 보고 | 케이스별 결과 표와 구간을 변경 옆에 커밋한다 |

벤더 플랫폼은 편리하고, 동시에 사라지기 가장 쉬운 부분이다. 케이스, grader, 결과를 저장소에 두면 이전은 재작성이 아니라 재실행이 된다.

---

## 8. Eval 결과 보고

```markdown
## Eval Result

- Baseline: [previous score / known issues]
- Current: [current score]
- Trials per case: [n]
- Interval: [standard error or confidence interval]
- Passed: [n/m]
- Failed: [n/m]
- Regressions: [none / list]
- Judge: [model + version + human agreement on the calibration sample]
- Decision: ship / iterate / caveated ship / block

| Case | Result | Evidence | Fix/Caveat |
|---|---|---|---|
```

점수를 받아들이기 전에 transcript를 읽는다. 실패는 transcript로 설명되어야 한다. 설명되지 않으면 그 eval은 동작이 아니라 하네스나 grader를 재고 있다.

---

## 9. Ship gate

출시 조건은 다음과 같다.

- 성공 기준이 작업 위험에 비례해 정의됐다.
- 중요한 케이스가 모두 통과했고, 그 판정이 trial 한 번이 아니다.
- 점추정만이 아니라 구간과 trial 수를 보고했다.
- 결과를 결정한 judge를 사람 라벨로 보정했거나, 보정하지 않았다고 표시했다.
- 실패한 비핵심 케이스는 caveat나 후속 항목으로 남겼다.
- eval, test, source 검사 출력을 읽었다.
- 포화된 케이스는 퇴역·교체했고, 바뀐 instruction은 README나 로딩 경로에서 찾을 수 있다.

---

## 출처

| # | 출처 | 발행 | URL | 발행·갱신일 | 확인일 | 등급 |
|---:|---|---|---|---|---|---|
| 1 | Demystifying evals for AI agents | Anthropic | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> | 2026-01-09 | 확인 2026-11-03 | S |
| 2 | Evaluation best practices | OpenAI | <https://developers.openai.com/api/docs/guides/evaluation-best-practices> | 표기 없음 | 확인 2026-11-03 | S |
| 3 | Deprecations, Evals 플랫폼 항목(2026-06-03) | OpenAI | <https://developers.openai.com/api/docs/deprecations> | 2026-06-03 공지 | 확인 2026-11-03 | S |
| 4 | Adding Error Bars to Evals: A Statistical Approach to Language Model Evaluations | Evan Miller, arXiv:2411.00640 | <https://arxiv.org/abs/2411.00640> | 2024-11-01 | 확인 2026-11-03 | S |
| 5 | τ-bench: A Benchmark for Tool-Agent-User Interaction in Real-World Domains, pass^k 정의 | Yao 외, arXiv:2406.12045 | <https://arxiv.org/abs/2406.12045> | 2024-06-17 | 확인 2026-11-03 | S |
| 6 | τ²-bench: Evaluating Conversational Agents in a Dual-Control Environment | Barres 외, arXiv:2506.07982 | <https://arxiv.org/abs/2506.07982> | 2025-06-09 | 확인 2026-11-03 | S |
| 7 | Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena | Zheng 외, arXiv:2306.05685 | <https://arxiv.org/abs/2306.05685> | 2023-06-09 | 확인 2026-11-03 | S |
| 8 | Judging the Judges: A Systematic Study of Position Bias in LLM-as-a-Judge | Shi 외, arXiv:2406.07791 | <https://arxiv.org/abs/2406.07791> | 2024-06-12 | 확인 2026-11-03 | S |
| 9 | JudgeBench: A Benchmark for Evaluating LLM-based Judges | Tan 외, arXiv:2410.12784 | <https://arxiv.org/abs/2410.12784> | 2024-10-16 | 확인 2026-11-03 | S |
| 10 | Judging the Judges: Confidence and Disagreement in Rubrics as Rewards | Liu 외, arXiv:2610.21179 | <https://arxiv.org/abs/2610.21179> | 2026-10-15 | 확인 2026-11-03 | S |
| 11 | Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces | Merrill 외, arXiv:2601.11868 | <https://arxiv.org/abs/2601.11868> | 2026-01-17 | 확인 2026-11-03 | S |
| 12 | Introducing SWE-bench Verified; SWE-bench Verified leaderboard | OpenAI; SWE-bench 관리자 | <https://openai.com/index/introducing-swe-bench-verified/>, <https://www.swebench.com/> | 2024-08-13, 2025-02-24 갱신; leaderboard는 수시 갱신 | 확인 2026-11-03; leaderboard 확인 2026-11-04 | S |

42%에서 95%로의 benchmark 사례와 20~50 task 시작점은 Anthropic이 보고한 자체 경험이다. §4.1의 약 80% 수치는 Zheng 외가 보고한 judge와 사람 선호의 일치율이며(출처 7), Anthropic의 결과가 아니다. 세 가지 모두 방법론이 밝혀진 단일 출처 근거로 다루고, 독립 측정으로 다루지 않는다. 통계 권고는 같은 연구소 소속 저자의 논문에서 나왔으므로, 이 원장에서는 둘 다 단일 기관 근거로 표시한다.
