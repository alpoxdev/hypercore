# 내용 계약

> 영어판: [`content-contract.md`](content-contract.md)

**목적**: instruction 파일에서 어떤 줄이 자리를 얻고 어떤 줄이 빠져야 하는지 정한다.

기준 질문은 "이것이 프로젝트에 대해 참인가?"가 아니라 **"말해주지 않으면 에이전트가 이것을 틀리는가?"**다. 사람들이 이 파일에 쓰는 내용 대부분은 이 테스트를 통과하지 못한다.

---

## 1. Admission test

후보가 되는 모든 줄은 네 관문을 전부 통과해야 한다. 하나라도 실패하면 넣지 않는다.

| 관문 | 질문 | 실패하는 경우 |
|---|---|---|
| **비자명** | 에이전트가 저장소를 읽어 알아낼 수 있는가? | 디렉터리 트리, 프레임워크 기본값, `package.json`이 이미 보여주는 것의 재진술 |
| **하중** | 지우면 실수가 생기는가? | "클린 코드를 작성하라", "모범 사례를 따르라", "주의하라" |
| **지속** | 다음 달에도 참인가? | 스프린트 메모, 현재 티켓, 진행 중인 마이그레이션 상태 |
| **권고 적합** | 산문이 올바른 강제 수단인가? | *매번* 일어나야 하는 것 — 그것은 hook, CI 검사, lint 규칙, schema다 |

Anthropic은 두 번째 관문을 삭제 테스트로 표현한다:

> "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it."

파괴적으로 적용한다. 이 테스트의 기본 결론은 삭제다.

---

## 2. 넣을 것

토큰당 가치 순.

1. **gotcha와 비자명한 제약** — 사람이 데인 것들. 가치가 가장 높은 범주이며, 현재 Anthropic 지침은 파일 내용의 대부분을 여기에 쓰라고 말한다.
2. **검증된 명령** — install, dev, test, lint, typecheck, build. 정확하고 복사 가능하며 작업 디렉터리를 명시한다. 실행해보지 않은 명령은 절대 쓰지 않는다.
3. **기본값과 다른 프로젝트 고유 관례** — 프레임워크 기본값과 일치한다면 잡음이다.
4. **코드가 스스로 알리지 않는 아키텍처와 경계** — 모듈 소유권, 무엇이 무엇을 import하면 안 되는지, 손으로 고치면 안 되는 생성 경로.
5. **테스트·검증 요구사항** — 어떤 러너를 쓰는지, 변경이 완료로 간주되려면 무엇이 통과해야 하는지.
6. **보안·안전 제약** — credential 취급, 네트워크 경계, destructive/production 게이트. 에이전트는 이를 추론할 수 없고 추측한다. 기술적 연구에 따르면 실제 파일의 약 14.5%만 보안 내용을 포함하며, 이것이 가장 흔한 위험 누락이다.
7. **간단한 프로젝트 목적 서술** — 한 문단, 방향을 잡을 정도. README가 아니다.
8. **로딩 맵** — 인라인 대신 더 깊은 로컬 문서로 링크.

Anthropic의 include 목록도 같은 형태다. 기본값이 아닌 코드 스타일 규칙, 테스트 지침과 선호 러너, 저장소 예절, 프로젝트 고유 아키텍처, 환경 특이사항, 흔한 gotcha.

---

## 3. 빼야 할 것

| 제외 대상 | 이유 |
|---|---|
| 모델이 이미 아는 표준 관례 | 순수 context 비용 |
| 상세 API 문서 | 문서에 두고 필요할 때 읽는다 |
| 자주 바뀌는 정보 | 낡으면 적극적으로 오도한다 |
| 긴 설명과 튜토리얼 | 판단을 바꾸지 않는다 |
| 파일별 코드베이스 설명 | 에이전트가 트리를 읽을 수 있다 |
| 자명한 규칙("클린 코드를 작성하라") | 반증 불가하며 아무것도 바꾸지 않는다 |
| task 전용·임시 메모 | 무관한 작업에 잘못 적용된다 |
| 응답 스타일·톤·장황함 선호 | 프로젝트 지식이 아니라 사용자 설정 |
| 검증되지 않은 명령 | 없느니만 못하다 |
| 비밀값, credential, 민감한 취약점 세부 | instruction 파일은 커밋되고 널리 읽힌다 |
| CI, hook, permission, schema가 더 잘 강제하는 규칙 | 산문은 아무것도 보장하지 못한다 |

GitHub 문서는 이 중 셋을 피할 것으로 명시한다:

> "Requests to refer to external resources when formulating a response"
> "Instructions to answer in a particular style"
> "Requests to always respond with a certain level of detail"

그리고 효과적인 내용을 짧고 자기 완결적인 것으로 규정한다:

> "Custom instructions consist of natural language instructions and are most effective when they are short, self-contained statements."

---

## 4. 올바른 고도에서 쓰기

작성의 핵심 실패 모드에 대한 Anthropic의 서술:

> "System prompts should be extremely clear and use simple, direct language that presents ideas at the right altitude for the agent. The right altitude is the Goldilocks zone between two common failure modes. At one extreme, we see engineers hardcoding complex, brittle logic in their prompts to elicit exact agentic behavior. This approach creates fragility and increases maintenance complexity over time. At the other extreme, engineers sometimes provide vague, high-level guidance that fails to give the LLM concrete signals for desired outputs or falsely assumes shared context. The optimal altitude strikes a balance: specific enough to guide behavior effectively, yet flexible enough to provide the model with strong heuristics to guide behavior."

실무 대비:

| 너무 낮음 (취약) | 올바른 고도 | 너무 높음 (모호) |
|---|---|---|
| "파일이 `src/api` 아래이고 메서드가 POST이고 핸들러가 promise를 반환하면 `withRetry`로 감싸라" | "모든 외부 API 핸들러는 `withRetry`를 거친다. `src/api/client.ts` 참고" | "에러를 잘 처리하라" |
| 금지된 import 쌍을 전부 나열 | "`core/`는 `features/`에서 import하지 않는다" | "아키텍처를 깨끗하게 유지하라" |
| 테스트 러너 선택 결정 트리 | "`bun test`로 실행한다. 통합 테스트는 `--preload ./test/setup.ts`가 필요하다" | "변경 사항을 테스트하라" |

올바른 고도의 판별법: **유능한 신규 기여자가 되묻지 않고 실행할 수 있고, 예상 못한 경우가 나타나도 즉시 무너지지 않는다.**

---

## 5. 표현 규칙

- "철저히 테스트하라"보다 `<검증된 명령> 실행`을 쓴다.
- "생성 파일에 주의하라"보다 `<근거 있는 생성 경로>를 수정하지 않는다`를 쓴다.
- 모든 규칙에 범위나 관측 가능한 검사를 명시한다.
- 개념마다 용어 하나를 쓰고, 프로젝트의 기존 어휘를 유지한다.
- 판단을 바꿀 때만 이유를 적는다. 동기 부여성 산문은 뺀다.
- MUST / SHOULD / MAY는 그 구분이 실제로 행동을 바꿀 때만 나눈다.
- 저장소 루트에서 실행하지 않는 명령은 작업 디렉터리를 명시한다.

---

## 6. 최신 모델일수록 규칙은 적게

Claude 5 세대에 대한 현재 Anthropic 지침은 과도한 제약을 경고하며, 경직된 규칙보다 모델의 판단 여지를 넓히라고 권한다. 또한 표면 간 반복 자체를 실패 모드로 지목한다. 같은 지시를 시스템 프롬프트, skill, instruction 파일에 되풀이하면 강화가 아니라 충돌이 생긴다.

작성 측면의 두 가지 귀결:

1. **강조하려고 규칙을 반복하지 않는다.** 규칙마다 정본 위치는 하나다. 반복은 강조가 아니라 drift를 만든다.
2. **완전함보다 progressive disclosure.** 항상 로드되는 파일을 키우는 대신, 전문 절차는 skill이나 링크 문서에 두고 참조한다. Anthropic이 명시한 탈출구가 정확히 이것이다: "Move reference material to skills, which load on-demand."

---

## 7. 품질 게이트

- [ ] 모든 줄이 네 admission 관문을 통과한다.
- [ ] 명령이 정확하고 근거가 있으며 실제로 실행되었다.
- [ ] 경로가 존재하거나, 생성될 출력물로 명시되어 있다.
- [ ] 저장소가 이미 보여주는 것을 재진술하는 규칙이 없다.
- [ ] 보안·안전·destructive action 경계가 있다.
- [ ] 보장이 필요한 것이 산문에 남아 있지 않다.
- [ ] 비밀값, 응답 스타일 선호, 임시 task 메모가 없다.
- [ ] 더 깊은 자료는 인라인이 아니라 링크되어 있다.
- [ ] 각 규칙의 정본 위치가 정확히 하나다.

---

## 출처

| 출처 | URL | 확인일 |
|---|---|---|
| Anthropic — Claude Code best practices | <https://code.claude.com/docs/en/best-practices> | 확인 2026-09-19 |
| Anthropic — effective context engineering | <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> | 확인 2026-09-19 |
| Claude Code memory 문서 | <https://code.claude.com/docs/en/memory> | 확인 2026-09-19 |
| Claude Code features overview | <https://code.claude.com/docs/en/features-overview> | 확인 2026-09-19 |
| New rules of context engineering (Claude 5) | <https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models> | 확인 2026-09-19 |
| GitHub Copilot response customization | <https://docs.github.com/en/copilot/concepts/prompting/response-customization> | 확인 2026-09-19 |

## 함께 읽을 문서

- [`../AGENTS_MD.ko.md`](../AGENTS_MD.ko.md)
- [`discovery-and-precedence.ko.md`](discovery-and-precedence.ko.md)
- [`evidence-and-evaluation.ko.md`](evidence-and-evaluation.ko.md)
- [`../../context-engineering/references/prompt-authoring.ko.md`](../../context-engineering/references/prompt-authoring.ko.md)
