# 근거와 평가

> 영어판: [`evidence-and-evaluation.md`](evidence-and-evaluation.md)

**목적**: 에이전트 instruction 파일에 대해 *측정된 것*과 *벤더 권고*를 분리해, 휴리스틱을 검증된 사실처럼 쓰지 않게 한다.

"도움이 될 것 같아서" 규칙을 추가하기 전에 읽는다. 이 분야의 가장 강한 단일 결과는, 잘못 쓴 context 파일이 에이전트를 중립이 아니라 **더 나쁘게** 만든다는 것이다.

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

### 2.1 context 파일은 task 성공률을 떨어뜨릴 수 있다

*Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* — AGENTbench 138개 task와 SWE-bench Lite 300개 task, 코딩 에이전트 4종, 세 조건(파일 없음 / LLM 생성 / 개발자 작성).

> "Context files tend to reduce task success rates compared to providing no repository context, while also increasing inference cost by over 20%."

- LLM 생성 파일: SWE-bench Lite 해결률 **-0.5%**, AGENTbench **-2%**, 평균 비용 **+20%/+23%**.
- 개발자 작성 파일: 파일 없음 대비 평균 **+4%**. 다만 단계 수와 비용은 함께 증가.
- 에이전트는 지시를 대체로 *따랐다*. 그 지시가 더 많은 테스트·검색·파일 읽기·추론을 유발했다.

저자 권고:

> "Human-written context files should describe only minimal requirements."

**범위 한계**: Python 편중 벤치마크, 설정당 1회 샘플링, 생성된 task 설명과 테스트. 모든 모델·저장소에 대한 보편 주장이 아니다.

<https://arxiv.org/html/2602.11988v1> (확인 2026-09-19)

### 2.2 파일의 존재는 실행 시간과 토큰을 줄일 수 있다

*On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents* — 저장소 10개, PR 124개, OpenAI Codex(GPT-5.2), 루트 `AGENTS.md` 유무만 바꾼 동일 task.

> "The presence of AGENTS.md is associated with a lower median runtime (Δ 28.64%) and reduced output token consumption (Δ 16.58%), while maintaining a comparable task completion behavior."

**범위 한계**: 정확성과 의미 품질은 명시적으로 **범위 밖**이며, 50개 task에 대한 수동 sanity check만 수행했다. "좋은 파일은 탐색 비용을 줄인다"는 뒷받침하지만, `AGENTS.md`가 **정확성**을 높인다는 근거는 아니다.

<https://arxiv.org/html/2601.20404v2> (확인 2026-09-19)

### 2.3 두 결과를 함께 읽기

둘은 모순이 아니며, 조합이 실무 교훈이다.

- instruction 파일은 에이전트가 상황 파악에 **얼마나 많은 작업을 하는지**를 안정적으로 바꾼다.
- **정답을 맞히는지 여부**는 안정적으로 바꾸지 못한다.
- 성공률이 오른 것은 *개발자가 쓴 최소한의* 파일뿐이었다. 생성된 포괄적 파일은 손실을 보였다.

따라서 instruction 파일의 가치 논거는 **비용과 일관성**이고, 위험 논거는 **틀리거나 비대한 내용이 결과를 실제로 악화시킨다**는 것이다. 규칙은 적게, 각각은 근거를 갖고 쓴다.

---

## 3. 기술적 근거 (D)

*Agent READMEs: An Empirical Study of Context Files for Agentic Coding* — 저장소 1,925개의 instruction 파일 2,303개. 가장 흔한 내용:

| 내용 범주 | 비율 |
|---|---|
| 구현 세부 | 69.9% |
| 아키텍처 | 67.7% |
| 빌드·실행 명령 | 62.3% |
| 보안 | 14.5% |
| 성능 | 14.5% |

이는 **효과가 아니라 관행**의 측정이다. 두 방향의 경고로 읽는다. 구현 세부는 과대 대표되어 있으며(그리고 정확히 에이전트가 스스로 찾을 수 있는 것이다), 반대로 에이전트가 추론할 수도 안전하게 추측할 수도 없는 보안·성능 제약은 일곱 파일 중 하나 꼴로만 등장한다.

<https://arxiv.org/html/2511.12884v1> (확인 2026-09-19)

---

## 4. 길이 제한에 대하여

**엄밀한 용량-반응 근거는 없다.** 검토한 어떤 연구도 최적 줄 수나 토큰 수를 확립하지 않았다. 그럼에도 벤더는 숫자를 제시하며, 그 숫자는 기본값으로 따를 가치가 있다 — task 성공률에 대해 측정되었기 때문이 아니라, 각 런타임의 자체 로딩 비용을 반영하기 때문이다.

| 주장 | 유형 | 출처 |
|---|---|---|
| "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." | V | Claude Code memory 문서 |
| "Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on-demand." | V | Claude Code features overview |
| "Instructions must be no longer than 2 pages" | V | GitHub Copilot 문서 — 독립 규칙이 아니라 생성 프롬프트 예시의 `<Limitations>` 안에 등장 |
| "Keep rules under 500 lines" | V | Cursor 문서, rules 전반에 대한 서술 |
| 관측된 파일 평균 641 단어(24–2,003 범위) | D | AGENTbench 연구 |

Anthropic 숫자의 배경 동작 두 가지는 *왜 상한이 존재하는가*를 설명하므로 체화할 가치가 있다.

> "CLAUDE.md files are loaded into the context window at the start of every session, consuming tokens alongside your conversation."

비용은 **매 세션, 작업 시작 전에** 지불되며, 그 내용이 실제로 관련 있든 없든 마찬가지다. 이것이 instruction 파일을 에이전트가 필요할 때 읽는 문서와 구분하는 지점이고, 더 긴 파일 대신 "reference 자료는 on-demand 로드되는 skill로 옮기라"가 권장 탈출구인 이유다.

위 숫자는 모두 각 런타임에 묶인 벤더 휴리스틱으로 다루고, 검증된 품질 임계값으로 취급하지 않는다. 방어 가능한 기준은 줄 수가 아니라 **줄당 관련성**이다. Anthropic의 표현도 예산이 아니라 삭제 테스트다:

> "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it."

또한 "최소"는 "짧음"과 같지 않다:

> "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

같은 글은 최소가 반드시 짧음을 뜻하지는 않는다고 명시한다. 실제로 하중을 받는 제약으로 채운 긴 파일이 모호한 문장으로 채운 짧은 파일보다 낫다.

<https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> (2025-09-29 게시, 확인 2026-09-19)

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
| 낡은 명령·버전·아키텍처 설명 | 적극적으로 오도함. 없느니만 못함 | V |

강제에 관해 Anthropic은 산문이 권고일 뿐이며 결정적 요구는 다른 곳에 속한다고 명시한다:

> "If the instruction is something that must run at a specific point, such as before every commit or after each file edit, write it as a hook instead. Hooks execute as shell commands at fixed lifecycle events and apply regardless of what Claude decides to do."

매번 반드시 일어나야 하는 동작이라면 그것을 요청하는 문장을 쓰지 않는다. hook, CI 검사, lint 규칙, schema로 강제한다. instruction 파일은 보장을 만드는 도구가 아니다.

---

## 6. 자기 instruction 파일의 변경을 평가하기

측정된 효과가 작고 음수일 수도 있으므로, 중요한 instruction 변경은 개선이 아니라 실험으로 다룬다.

1. **실패에서 출발한다.** 반복 관찰된 실수나 지속되는 발견 이후에만 규칙을 추가한다. 추측으로 넣지 않는다.
2. **그것을 막았을 최소 규칙을 쓴다.** 범위나 관측 가능한 검사를 명시한다.
3. **대표 task를 고른다.** 이 저장소의 실제 task 몇 개가 합성 세트보다 낫다.
4. **있을 때와 없을 때를 비교한다.** task 성공률, 실행 시간, 토큰, tool call, 회귀를 함께 추적한다. 성공률만 보면 비용 폭증을 놓치고, 비용만 보면 정확성 손실을 놓친다.
5. **효과가 없으면 지운다.** 행동을 바꾸지 않는 규칙은 순수 context 비용이다. 삭제가 예외가 아니라 기본 결론이다.

이는 [`../../harness-engineering/HARNESS_ENGINEERING.ko.md`](../../harness-engineering/HARNESS_ENGINEERING.ko.md)의 하네스 규율과 같다. 평가할 수 없는 규칙은 유지를 정당화할 수 없는 규칙이다.

---

## 출처

| 출처 | 등급 | URL | 확인일 |
|---|---|---|---|
| Evaluating AGENTS.md (AGENTbench) | M | <https://arxiv.org/html/2602.11988v1> | 확인 2026-09-19 |
| Impact of AGENTS.md on Efficiency | M | <https://arxiv.org/html/2601.20404v2> | 확인 2026-09-19 |
| Agent READMEs 실증 연구 | D | <https://arxiv.org/html/2511.12884v1> | 확인 2026-09-19 |
| Anthropic — effective context engineering | V | <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> | 확인 2026-09-19 |
| Anthropic — Claude Code best practices | V | <https://code.claude.com/docs/en/best-practices> | 확인 2026-09-19 |
| Claude Code memory 문서 | V | <https://code.claude.com/docs/en/memory> | 확인 2026-09-19 |
| Claude Code features overview | V | <https://code.claude.com/docs/en/features-overview> | 확인 2026-09-19 |
| GitHub Copilot repository instructions | V | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 확인 2026-09-19 |
| GitHub Copilot response customization | V | <https://docs.github.com/en/copilot/concepts/prompting/response-customization> | 확인 2026-09-19 |
| Cursor rules 문서 | V | <https://cursor.com/en-US/docs/rules> | 확인 2026-09-19 |

## 함께 읽을 문서

- [`../AGENTS_MD.ko.md`](../AGENTS_MD.ko.md)
- [`content-contract.ko.md`](content-contract.ko.md)
- [`discovery-and-precedence.ko.md`](discovery-and-precedence.ko.md)
- [`../../validation/index.ko.md`](../../validation/index.ko.md)
