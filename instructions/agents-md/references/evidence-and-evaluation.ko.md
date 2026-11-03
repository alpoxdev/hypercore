# 근거와 평가

> 영어판: [`evidence-and-evaluation.md`](evidence-and-evaluation.md)

**목적**: 에이전트 instruction 파일에 대해 *측정된 것*과 *벤더 권고*를 분리해, 휴리스틱을 검증된 사실처럼 쓰지 않게 한다.

"도움이 될 것 같아서" 규칙을 추가하기 전에 읽는다. 이 분야의 가장 강한 단일 결과는, 잘못 썼거나 낡은 context 파일이 에이전트를 중립이 아니라 **더 나쁘게** 만든다는 것이다.

---

## 1. 근거 등급

| 등급 | 의미 | 충돌 시 가중치 |
|---|---|---|
| **M** 측정 | 효과 크기가 보고된 통제·대응 실험 | 명시된 범위 안에서 최상위 |
| **D** 기술 | 사람들이 실제로 무엇을 쓰는지에 대한 관찰 연구 | 관행을 알려줄 뿐 효과는 말하지 않음 |
| **V** 벤더 권고 | 해당 런타임 팀의 공식 문서·블로그 | *그 런타임의 동작*에는 권위, 품질에는 휴리스틱 |
| **C** 커뮤니티 의견 | 블로그, "상위 파일 분석" 류 | 근거 아님. 가설 용도로만 |

벤더가 **자기 제품의 로딩 동작**(탐색 순서, 크기 상한, import 깊이)에 대해 말한 것은 사실이다. 같은 벤더가 **무엇이 좋은 파일인가**에 대해 말한 것은 휴리스틱이다. 둘을 섞지 않는다.

---

## 2. 측정된 근거 (M)

### 2.1 context 파일은 대체로 task 성공률을 높이지 못한다

*Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* — 개발자가 context 파일을 커밋해 둔 비주류 저장소 12곳에서 뽑은 CTXbench 138개 instance, 그리고 SWE-bench Lite, 에이전트·모델 조합 4종(Claude Code + Sonnet-4.5, Codex + GPT-5.2, Codex + GPT-5.1 mini, Qwen Code + Qwen3-30b-coder), 세 조건(파일 없음 / LLM 생성 / 개발자 작성).

> "providing context files does not generally improve task success rates, while increasing inference cost by over 20% on average."

- LLM 생성 파일: 해결률 **-0.5%**(SWE-bench)와 **-2%**(CTXbench)로 유의미한 효과 없음(p=87%, p=37%). 반면 단계 수는 2.45, 3.92 늘고 비용은 평균 **20%**, **23%** 증가(p<0.001%).
- 개발자 작성 파일: 평균 **+2.4%**로 이 역시 유의미하지 않고(p=21%), 비용은 최대 19%, 단계 수는 3.34 늘었다.
- 에이전트는 지시를 대체로 *따랐다*. 그 지시가 더 많은 테스트·검색·파일 읽기·추론을 유발했다.
- 작성자에게 중요한 ablation 두 가지: "the length of context files has no significant impact"이고, "repository overviews, although popular and recommended by model providers, are not helpful"이다.

저자 결론:

> "while context files are useful for specifying non-standard coding practices, any attempts to improve performance should be rigorously evaluated before deployment."

**범위 한계**: "The current evaluation is focused on Python"이고, 설정당 1회 샘플링에 생성된 task 설명과 테스트를 썼다. 모든 모델·저장소에 대한 보편 주장이 아니다.

<https://arxiv.org/html/2602.11988v3> (2026-02-12 제출, 최종 개정 2026-09-29, 확인 2026-11-03)

### 2.2 파일의 존재는 실행 시간과 토큰을 줄일 수 있다

*On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents* — 저장소 10개, PR 124개, OpenAI Codex(GPT-5.2), 루트 `AGENTS.md` 유무만 바꾼 동일 task.

> "The presence of AGENTS.md is associated with a lower median runtime (Δ 28.64%) and reduced output token consumption (Δ 16.58%), while maintaining a comparable task completion behavior."

**범위 한계**: 정확성과 의미 품질은 명시적으로 **범위 밖**이며, 50개 task에 대한 수동 sanity check만 수행했다. "좋은 파일은 탐색 비용을 줄인다"는 뒷받침하지만, `AGENTS.md`가 **정확성**을 높인다는 근거는 아니다.

<https://arxiv.org/html/2601.20404v2> (2026-01-28 제출, 최종 개정 2026-03-30, 확인 2026-11-03)

### 2.3 그림을 정교하게 만든 2026년 결과 넷

"파일이 정확성을 돕지 않는다"는 결론은 이제 반복 검증되었지만, 같은 기간에 *왜* 그런지 말해주는 결과와, 작은 변경으로 큰 효과를 낸 결과가 나왔다.

| 연구 | 설계 | 결과 |
|---|---|---|
| *Do Context Files Help Coding Agents? A Two-Agent Ablation Study on Real Repositories* (Khatri, REALM 2026 워크숍, ACL Anthology `2026.realm-1.5`) | Claude Code·Codex, 실제 저장소 3곳의 task 17개, 288회 실행, gold test | "Context strategy does not measurably move correctness on either agent (bounded to ≤10–15pp via equivalence testing)." 실패는 context가 아니라 구현 역량에서 나왔다 |
| *Probe-and-Refine Tuning of Repository Guidance for Coding Agents* (Shepard, Albrecht, arXiv:2606.20512) | 저장소를 반복 탐색해 파일을 *도출* | 평균 해결률 33.0%로, 정적 지식 기반 28.3%, 무지침 25.5%를 앞섰다(p < 0.001). 이득은 파일의 존재가 아니라 내용을 만든 방식에서 왔다 |
| *Why Does CLAUDE.md Keep Growing? Catastrophic Remembering in Agentic Coding* (Chakrabarti, arXiv:2608.11095) | 저장소 1,867곳의 instruction 수명 247,694개 | 파일이 "more than tripling over their lifetime (+226%), gaining +4.9 net instructions every commit"만큼 자란다. 잠재 추론을 적은 항목을 걸러내면 "remove 99.3% of excess instructions" |
| *Stale Instruction Files Override the Code in Coding Agents: A One-Sentence Fix* (Xu, Wu, arXiv:2610.30571) | 파일이 코드와 모순되는 저장소에서 320회 실행 | "Without the sentence, 90.1% of the agents' choices followed the stale file". 문장을 넣자 "raised the share of choices that follow the code from 4.2% to 91.4%"가 되고 테스트 통과율이 89.4%에서 100%가 되었다 |

작성에 대한 두 가지 귀결은 벤더 문서의 어떤 서술보다 강하다.

- **낡은 instruction 파일은 코드보다 우선한다.** 에이전트는 읽을 수 있는 소스보다 문서를 신뢰하므로, 낡은 명령이나 뒤처진 아키텍처 설명은 중립적 잡음이 아니라 실제 결함이다. 둘이 어긋날 때 코드가 이긴다고 파일에 분명히 적는다. 네 번째 연구가 고친 것이 바로 그 한 문장이다.
- **증가는 사고가 아니라 기본 궤적이다.** 그대로 두면 파일은 커밋당 약 5개 instruction을 얻으며 세 배가 된다. 정리는 일정을 가진 유지보수 작업이고, 효과가 있었던 정리 기준은 에이전트가 스스로 도출할 수 있는 추론을 다시 적은 항목을 지우는 것이었다.

표의 출처는 모두 2026-11-03에 확인했다: <https://aclanthology.org/2026.realm-1.5/> (2026년 10월 proceedings, preprint <https://arxiv.org/abs/2607.27250>, 2026-07-28), <https://arxiv.org/abs/2606.20512> (2026-06-18), <https://arxiv.org/abs/2608.11095> (2026-08-11), <https://arxiv.org/abs/2610.30571> (2026-10-22). 동료 심사를 거친 것은 REALM 논문뿐이므로 나머지 효과 크기는 임계값이 아니라 징후로 다룬다.

### 2.4 결과를 함께 읽기

서로 모순되지 않으며, 조합이 실무 교훈이다.

- instruction 파일은 에이전트가 상황 파악에 **얼마나 많은 작업을 하는지**를 안정적으로 바꾼다.
- **정답을 맞히는지 여부**는 안정적으로 바꾸지 못한다. 독립적인 설계 두 개가 동등성 검정과 유의성 검정으로 이를 확인했고, 측정 가능한 정확성 변화는 없었다.
- 결과를 실제로 바꾸는 것은 내용의 품질이다. 저장소를 탐색해 도출한 지침은 정적 파일과 무지침을 모두 앞섰고, 코드에 대한 우선순위를 밝힌 한 문장은 코드를 따르는 비율을 4.2%에서 91.4%로 끌어올렸다.

따라서 instruction 파일의 가치 논거는 **비용, 일관성, 그리고 코드가 스스로 말할 수 없는 것을 지정하는 일**이고, 위험 논거는 **틀리거나 낡거나 비대한 내용이 비용을 더 받으면서 결과를 악화시키는 것**이다. 규칙은 적게, 각각은 근거를 갖고 쓰되, 그중 하나는 충돌 시 코드가 이긴다는 문장이어야 한다.

---

## 3. 서술적 근거 (D)

*Agent READMEs: An Empirical Study of Context Files for Agentic Coding* — 저장소 1,925곳의 context 파일 2,303개, Claude Code·OpenAI Codex·GitHub Copilot 파일을 포함. 가장 흔한 내용(파일 비율):

| 내용 범주 | 비율 |
|---|---|
| 테스트 절차 | 75.9% |
| 구현 세부 | 70.8% |
| 아키텍처 | 68.1% |
| 보안 | 14.8% |
| 성능 | 14.5% |

이는 **효과가 아니라 관행**의 측정이다. 두 방향의 경고로 읽는다. 구현 세부는 과대 대표되어 있으며(정확히 에이전트가 스스로 찾을 수 있는 것이다), 반대로 에이전트가 추론할 수도 안전하게 추측할 수도 없는 보안·성능 제약은 일곱 파일 중 하나 꼴로만 등장한다.

<https://arxiv.org/html/2511.12884v2> (2025-11-17 제출, 최종 개정 2026-08-09, 확인 2026-11-03)

---

## 4. 길이 제한에 대하여

**엄밀한 용량-반응 근거는 없다.** 검토한 어떤 연구도 최적 줄 수나 토큰 수를 확립하지 않았고, 길이를 직접 바꾼 유일한 통제 ablation도 효과를 찾지 못했다. 해결률에 대해 "the length of context files has no significant impact"였다(§2.1). 그럼에도 벤더는 숫자를 제시하며, 그 숫자는 기본값으로 따를 가치가 있다. task 성공률에 대해 측정되었기 때문이 아니라 각 런타임의 자체 로딩 비용을 반영하기 때문이다.

| 주장 | 유형 | 출처 |
|---|---|---|
| "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." | V | Claude Code memory 문서 |
| "Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on demand." | V | Claude Code features overview |
| 시작 시 로드되는 `CLAUDE.md`가 4 MiB를 넘으면 통째로 건너뛰고, 중첩 파일은 자체 한도를 넘으면 앞부분만 로드된다 | V | Claude Code memory 문서 |
| "Instructions must be no longer than 2 pages" | V | GitHub Copilot 문서 — 문서화된 한도가 아니라 GitHub의 복사용 작성 프롬프트 안에만 등장 |
| "Keep rules under 500 lines" | V | Cursor 문서, rules 전반에 대한 서술 |
| 관측된 파일 평균 641 단어(24–2,003 범위) | D | CTXbench 연구 |
| 파일당 instruction이 수명 동안 +226%, 커밋당 순증 +4.9개 | M | Catastrophic-remembering 연구(§2.3) |

Anthropic 숫자의 배경 동작은 *왜 상한이 존재하는가*를 설명하므로 체화할 가치가 있다.

Claude Code는 세션을 시작할 때 작업 디렉터리와 그 위 디렉터리에 있는 `CLAUDE.md` 파일을 로드한다. 하위 디렉터리의 파일은 Claude가 그 디렉터리의 다른 파일을 처음 읽거나 쓰거나 고칠 때 로드된다.

시작할 때 로드되는 파일은 그 비용을 **매 세션, 작업 시작 전에** 지불하며, 그 내용이 실제로 관련 있든 없든 마찬가지다. 이것이 instruction 파일을 에이전트가 필요할 때 읽는 문서와 구분하는 지점이고, 더 긴 파일 대신 "move reference material to skills, which load on demand"가 권장 탈출구인 이유다. 위의 측정된 증가 수치는 "몇 줄 더는 괜찮다"에 대한 반론이다. 파일이 세 배가 되는 경로가 정확히 그 몇 줄이다.

위 숫자는 모두 각 런타임에 묶인 벤더 휴리스틱으로 다루고, 검증된 품질 임계값으로 취급하지 않는다. 방어 가능한 기준은 줄 수가 아니라 **줄당 관련성**이다. Anthropic의 현재 기준은 예산이 아니라 받아들이는 규칙과 쳐내는 규칙이다.

> "Add to it when: Claude makes the same mistake a second time"

> "the file works best when it only holds what Claude couldn't work out from the code itself"

옛 표현 — "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it." — 은 더 이상 문서에 없다. 위 두 문장이 그것을 대체했고, 체크인된 `CLAUDE.md`에 대해서는 `/doctor`가 줄일 곳을 기계적으로 제안한다.

또한 "최소"는 "짧음"과 같지 않다.

> "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

같은 글은 최소가 반드시 짧음을 뜻하지는 않는다고 명시한다. 실제로 하중을 받는 제약으로 채운 긴 파일이 모호한 문장으로 채운 짧은 파일보다 낫다.

<https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> (2025-09-29 게시, 2026-10-18 최종 수정, 확인 2026-11-03)

---

## 5. 실패 모드 정리

| 실패 모드 | 왜 해로운가 | 근거 |
|---|---|---|
| 모든 것을 담은 파일 | context를 소모하고 정작 중요한 규칙의 준수율을 떨어뜨림 | V, M |
| 뻔한 사실로 채운 LLM 생성 파일 | 측정된 성공률 손실과 약 20% 비용 증가 | M |
| 취약한 if/then 로직 | 저자가 예상 못한 경우에서 무너짐 | V |
| 모호한 규칙("클린 코드를 작성하라") | 반증 불가하며 행동을 바꾸지 않음 | V |
| 예외 사례 나열 | 하중을 받는 제약을 밀어냄 | V |
| 저장소가 이미 보여주는 것의 재진술 | 순수 context 비용, 신호 0 | V, M |
| 저장소 전역 파일에 든 task 전용 메모 | 무관한 작업에 잘못 적용됨 | V |
| 응답 스타일·길이 선호 | 프로젝트 지식이 아니라 사용자 설정 | V |
| 전역·루트·중첩 파일 간 충돌 | 에이전트가 조용히 하나를 고름 | V |
| Markdown을 결정적 강제로 취급 | 지시는 권고일 뿐. 강제는 hook/CI만 가능 | V |
| 보안·성능 제약 누락 | 에이전트가 추론할 수 없어 추측함 | D |
| 낡은 명령·버전·아키텍처 설명 | 측정됨: 에이전트가 코드 대신 낡은 파일을 따름(선택의 90.1%) | M |
| instruction의 무한 누적 | 파일 수명 동안 +226%. 추가는 안전한 삭제보다 항상 싸다 | M |
| 코드베이스 개요를 파일의 임무로 삼기 | 벤더가 권하지만 측정상 도움이 되지 않음 | M |

강제에 관해 Anthropic은 산문이 권고일 뿐이며 결정적 요구는 다른 곳에 속한다고 명시한다.

> "If the instruction is something that must run at a specific point, such as before every commit or after each file edit, write it as a hook instead. Hooks execute as shell commands at fixed lifecycle events and apply regardless of what Claude decides to do."

매번 반드시 일어나야 하는 동작이라면 그것을 요청하는 문장을 쓰지 않는다. hook, CI 검사, lint 규칙, schema로 강제한다. instruction 파일은 보장을 만드는 도구가 아니다.

---

## 6. 자기 instruction 파일의 변경을 평가하기

측정된 효과가 작고 음수일 수도 있으며 내용을 만든 방식에 달려 있으므로, 중요한 instruction 변경은 개선이 아니라 실험으로 다룬다.

1. **실패에서 출발한다.** 반복 관찰된 실수나 지속되는 발견 이후에만 규칙을 추가한다. 추측으로 넣지 않는다.
2. **그것을 막았을 최소 규칙을 쓴다.** 범위나 관측 가능한 검사를 명시한다.
3. **대표 task를 고른다.** 이 저장소의 실제 task 몇 개가 합성 세트보다 낫다.
4. **있을 때와 없을 때를 비교한다.** task 성공률, 실행 시간, 토큰, tool call, 회귀를 함께 추적한다. 성공률만 보면 비용 폭증을 놓치고, 비용만 보면 정확성 손실을 놓친다.
5. **효과가 없으면 정해진 주기로 지운다.** 행동을 바꾸지 않는 규칙은 순수 context 비용이고, 정리하지 않으면 파일은 커밋당 약 5개 instruction씩 자란다. 추가할 때만이 아니라 일정 간격으로 파일 전체를 다시 읽는다.

이는 [`../../harness-engineering/HARNESS_ENGINEERING.ko.md`](../../harness-engineering/HARNESS_ENGINEERING.ko.md)의 하네스 규율과 같다. 평가할 수 없는 규칙은 유지를 정당화할 수 없는 규칙이다.

---

## 출처

| 출처 | 등급 | URL | 확인일 |
|---|---|---|---|
| Evaluating AGENTS.md (CTXbench) | M | <https://arxiv.org/html/2602.11988v3> | 확인 2026-11-03 |
| Impact of AGENTS.md on Efficiency | M | <https://arxiv.org/html/2601.20404v2> | 확인 2026-11-03 |
| Agent READMEs 실증 연구 | D | <https://arxiv.org/html/2511.12884v2> | 확인 2026-11-03 |
| Two-agent context-file ablation (REALM 2026) | M | <https://aclanthology.org/2026.realm-1.5/> | 확인 2026-11-03 |
| Probe-and-refine repository guidance | M | <https://arxiv.org/abs/2606.20512> | 확인 2026-11-03 |
| Catastrophic remembering in CLAUDE.md | M | <https://arxiv.org/abs/2608.11095> | 확인 2026-11-03 |
| Stale instruction files override the code | M | <https://arxiv.org/abs/2610.30571> | 확인 2026-11-03 |
| Anthropic — effective context engineering | V | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 확인 2026-11-03 |
| Anthropic — Claude Code best practices | V | <https://code.claude.com/docs/en/best-practices> | 확인 2026-11-03 |
| Claude Code memory 문서 | V | <https://code.claude.com/docs/en/memory> | 확인 2026-11-03 |
| Claude Code features overview | V | <https://code.claude.com/docs/en/features-overview> | 확인 2026-11-03 |
| GitHub Copilot custom instructions | V | <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> | 확인 2026-11-03 |
| GitHub Copilot repository instructions | V | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 확인 2026-11-03 |
| Cursor rules 문서 | V | <https://cursor.com/en-US/docs/rules> | 확인 2026-11-03 |

## 함께 읽을 문서

- [`../AGENTS_MD.ko.md`](../AGENTS_MD.ko.md)
- [`content-contract.ko.md`](content-contract.ko.md)
- [`discovery-and-precedence.ko.md`](discovery-and-precedence.ko.md)
- [`../../validation/index.ko.md`](../../validation/index.ko.md)
