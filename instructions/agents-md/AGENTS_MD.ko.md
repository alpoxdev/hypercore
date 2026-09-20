# AGENTS.md와 CLAUDE.md 작성

> 영어판: [`AGENTS_MD.md`](AGENTS_MD.md)

저장소의 에이전트 instruction 파일을 만들거나, 리팩터링하거나, 리뷰할 때 읽는 베이스 문서다. 목적은 `AGENTS.md`와 `CLAUDE.md`를 조언 더미가 아니라 **작고, 근거 있고, 이식 가능한 계약**으로 만드는 것이다.

실행 절차는 `agent-md-maker` 스킬에 있다. 이 문서는 그 절차가 딛고 선 출처 기반 지식이다.

---

## 핵심 정의

instruction 파일은 **에이전트가 task가 무엇인지 알기 전에** 주어지는 context다. 이 한 가지 성질이 아래 모든 규칙을 결정한다. 즉 미리 로드되고, 매 세션 비용을 치르며, 그 파일을 염두에 두지 않은 작업에도 적용된다.

공식 정의:

> "Think of AGENTS.md as a README for agents: a dedicated, predictable place to provide the context and instructions to help AI coding agents work on your project."

> "README.md files are for humans: quick starts, project descriptions, and contribution guidelines. AGENTS.md complements this by containing the extra, sometimes detailed context coding agents need: build steps, tests, and conventions that might clutter a README or aren't relevant to human contributors."

포맷은 그 외에 아무것도 강제하지 않는다 — "AGENTS.md is just standard Markdown. Use any headings you like." 규율은 저자가 만들어야 한다.

---

## 작성법을 바꿔야 할 다섯 가지 사실

1. **나쁜 파일은 없느니만 못하다.** AGENTbench 138개와 SWE-bench Lite 300개 task에서 측정: "Context files tend to reduce task success rates compared to providing no repository context, while also increasing inference cost by over 20%." 성능이 오른 것은 개발자가 쓴 최소 파일(약 +4%)뿐이고, LLM이 생성한 포괄적 파일은 손실을 보였다.
2. **믿을 만한 이득은 정확성이 아니라 비용이다.** PR 124개 대응 연구에서 루트 `AGENTS.md`가 있을 때 중앙값 실행 시간 약 28.6%, 출력 토큰 약 16.6% 감소 — 다만 정확성은 명시적으로 범위 밖이었다.
3. **"가장 가까운 파일이 이긴다"는 대체로 사실이 아니다.** Codex는 루트→말단으로 concatenate하고, Claude Code는 "rather than overriding each other" concatenate하며, Cursor는 부모와 결합한다. 단순 해석과 일치하는 것은 Copilot뿐이다. 중첩 파일은 두 방식 모두에서 옳아야 한다.
4. **Claude Code는 v2.1.277부터 `AGENTS.md`를 직접 읽는다.** `AGENTS.md`만 둔 저장소도 `CLAUDE.md`나 import, 설정 없이 Claude Code에 지시를 전달한다. 다만 두 가지 조건은 여전히 중요하다. 작업 디렉토리나 그 위에 `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md` 중 하나가 있으면 기본 **Project instructions** 설정에서 `AGENTS.md`가 억제되고, `AGENTS.md` 지원이 불가능한 세션은 `CLAUDE.md`만 읽는다(네 가지 조건 전체는 [`references/discovery-and-precedence.ko.md`](references/discovery-and-precedence.ko.md) §2에 있다).
5. **한 런타임에서는 크기가 하드 리밋이다.** Codex는 "stops adding files once the combined size reaches the limit defined by `project_doc_max_bytes` (32 KiB by default)" — 루트→말단 순서이므로, 비대한 루트 파일이 정작 지금 수정 중인 코드를 관장하는 중첩 파일을 조용히 굶길 수 있다.

세부와 인용: [`references/evidence-and-evaluation.ko.md`](references/evidence-and-evaluation.ko.md), [`references/discovery-and-precedence.ko.md`](references/discovery-and-precedence.ko.md).

---

## 기본 원칙

1. **모든 줄이 자격을 얻어야 한다.** "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it." 이 테스트의 기본 결론은 삭제다.
2. **완전함보다 비자명함.** 파일의 임무는 에이전트가 *틀릴* 것이지 *참인* 것이 아니다. 저장소에서 발견 가능한 것은 신호 없는 context 비용이다.
3. **올바른 고도.** 취약한 하드코딩 로직과 모호한 지침 사이. 행동을 이끌 만큼 구체적이되, 예상 못한 경우에서 살아남을 만큼 유연하게.
4. **산문은 권고다.** 매번 반드시 일어나야 하는 것은 그것을 요청하는 문장이 아니라 hook, CI 검사, lint 규칙, schema에 속한다.
5. **규칙마다 정본 위치는 하나.** 루트·중첩·런타임 파일에 걸친 반복은 강조가 아니라 충돌을 만든다.
6. **기본은 이식 가능하게.** 런타임 중립 규칙으로 쓰고, 실제 CLI 차이는 adapter나 [`../cli/`](../cli/README.ko.md) profile로 분리한다.
7. **Progressive disclosure.** 항상 로드되는 파일은 얇게 두고, 전문 절차는 필요할 때 로드되는 skill과 링크 문서로 옮긴다.
8. **근거 아니면 생략.** 모든 명령·경로·아키텍처 주장은 조사한 파일로 추적된다. 실행하지 않은 명령은 쓰지 않는다.
9. **capability는 승인이 아니다.** credential, 네트워크, publish, deploy, destructive action, production write는 명시적으로 게이트를 유지한다.

---

## 무엇을 넣는가

토큰당 가치 순:

| 우선순위 | 내용 | 비고 |
|---|---|---|
| 1 | gotcha와 비자명한 제약 | 최고 가치. 현재 Anthropic 지침은 파일 대부분을 여기 쓰라고 한다 |
| 2 | 검증된 명령 | 정확하고 복사 가능하며 작업 디렉터리 명시 |
| 3 | 기본값과 다른 관례 | 프레임워크 기본값과 같다면 잡음이다 |
| 4 | 코드가 스스로 알리지 않는 아키텍처 경계 | 소유권, 금지된 import, 생성 경로 |
| 5 | 테스트·검증 요구사항 | 변경이 완료되려면 무엇이 통과해야 하는가 |
| 6 | 보안·안전 제약 | 에이전트가 추론할 수 없음. 실제 파일의 약 14.5%만 포함 |
| 7 | 한 문단짜리 프로젝트 목적 | 방향 제시일 뿐 README가 아님 |
| 8 | 로딩 맵 | 인라인 대신 더 깊은 문서로 링크 |

그리고 빠져야 할 것 — 표준 관례, API 문서, 자주 바뀌는 세부, 튜토리얼, 파일별 목록, 자명한 규칙, 임시 task 메모, 응답 스타일 선호, 검증되지 않은 명령, 비밀값, 그리고 CI가 더 잘 강제할 수 있는 모든 것.

전체 admission test와 표현 규칙: [`references/content-contract.ko.md`](references/content-contract.ko.md).

---

## 구조

프로젝트 근거가 뒷받침하는 섹션만 고른다. 빈 헤딩은 지운다.

1. **범위** — 이 파일이 관장하는 트리, 필요 시 nearest-file 동작.
2. **프로젝트 맵** — 안정적인 source, test, package, 생성물, 문서 위치.
3. **권위와 근거** — 우선순위, 그리고 retrieved content는 지시가 아니라 근거라는 규칙.
4. **명령** — install, dev, test, lint, typecheck, build.
5. **작업 흐름** — 수정 전 읽기, 최소 변경, 검증 순서.
6. **관례** — 프로젝트 고유의 것만.
7. **안전과 부수 효과** — 명시적 게이트.
8. **완료** — 무엇을 실행하고, 실패를 어떻게 보고하며, 무엇이 완료를 막는가.
9. **로딩 맵** — 복사가 아니라 링크.

첫 화면은 실무적으로 유지한다. 범위, 프로젝트 형태, 핵심 명령, 결정적 제약.

---

## 중첩

하위 트리가 명령·소유권·생성물 경계·언어·아키텍처에서 실제로 다를 때만 중첩 파일을 추가한다. 그리고 merge 방식이 런타임마다 다르므로:

- **관장하는 하위 트리를 명시한다.**
- **올바른 규칙을 온전히 다시 진술해 override한다.** 부모를 부정하지 않는다("루트와 달리 …"는 부모가 로드되지 않으면 깨지고, 로드되면 모순을 만든다).
- **자기 완결적으로 유지한다** — 부모가 있든 없든 옳아야 한다.
- **루트 본문을 복사하지 않는다.** 중첩 파일은 delta를 담는다.

---

## CLAUDE.md와의 조율

기본은 정본 `AGENTS.md` 하나다. 실제 Claude 전용 차이가 있거나 `AGENTS.md`를 직접 읽지 못하는 세션을 위해서만 `CLAUDE.md`를 추가한다.

| 전략 | 방법 | 사용 시점 |
|---|---|---|
| native 단독 | `CLAUDE.md`를 아예 두지 않음 | 기본값: Claude 전용 차이가 없고, 지원해야 하는 모든 세션이 `AGENTS.md`를 읽을 수 있을 때 |
| 심볼릭 링크 | `ln -s AGENTS.md CLAUDE.md` | 공유 계약뿐, Claude 전용 규칙 없음 |
| import stub | `CLAUDE.md`에 `@AGENTS.md` | 같은 상황에서 심볼릭 링크가 곤란할 때 |
| 얇은 adapter | `@AGENTS.md` + 검증된 Claude 전용 규칙 | skill, hook, permission mode, MCP |
| 분리된 파일 | 독립 관리 파일 2개 | 거의 없음 — drift를 각오해야 함 |

adapter에는 다른 런타임에서 거짓이거나 없는 내용만 담는다. 공유 계약을 다시 진술하거나, 요약하거나, 완화하지 않는다. 세부: [`references/claude-md-adapter.ko.md`](references/claude-md-adapter.ko.md).

---

## 작성 흐름

| 단계 | 작업 | 완료 근거 |
|---|---|---|
| 0 | create / refactor / split / reconcile 분류, 대상 파일과 제외 범위 확정 | 범위 결정 |
| 1 | 기존 instruction, manifest, lockfile, task 정의, CI, 대표 source·test 조사 | 근거 맵 |
| 2 | 루트/중첩 경계, 정본 소유권, 대상 런타임, 출력 언어 결정 | 설계 계약 |
| 3 | 모든 주장이 조사된 근거로 매핑되는 최소 규칙 집합 초안 | 후보 파일 |
| 4 | 작성한 명령을 실제로 실행하고 경로 존재 확인 | 검증된 명령 |
| 5 | admission test를 줄 단위로 파괴적으로 적용 | 축소된 파일 |
| 6 | 모든 대상 런타임에 대해 이식성 점검 | 이식성 패스 |
| 7 | 프로젝트가 유지하는 이중 언어 문서 정합 | 정렬된 쌍 |
| 8 | 변경 파일, 근거, 실행한 검사, 남은 위험 보고 | handoff |

---

## 검증

- [ ] 모든 줄이 admission test를 통과한다 — 비자명, 하중 있음, 지속적, 권고에 적합.
- [ ] 모든 명령을 실제로 실행했고, 모든 경로가 존재하거나 출력물로 표시되어 있다.
- [ ] 저장소가 이미 보여주는 것을 재진술하는 규칙이 없다.
- [ ] 보안·안전·destructive action 경계가 명시적으로 존재한다.
- [ ] 보장이 필요한 것이 산문에 맡겨져 있지 않다.
- [ ] 규칙마다 정본 위치가 하나이며, 루트와 중첩 파일이 반복되지 않는다.
- [ ] 중첩 파일이 merge와 nearest-wins 양쪽에서 옳은 자기 완결적 delta다.
- [ ] Claude Code가 대상이면 저장소가 자체 `AGENTS.md` 읽기(v2.1.277+, 작업 디렉토리나 그 위에 판정에 포함되는 `CLAUDE.md`·`CLAUDE.local.md` 없음)에 기대거나, `AGENTS.md`를 import 또는 심볼릭 링크하는 `CLAUDE.md`를 함께 제공한다.
- [ ] `@path` import가 4 hop 이내이며 import한 파일 기준 상대 경로로 해석된다.
- [ ] 32 KiB 합산 상한에서 중첩 파일 몫이 남을 만큼 루트 파일이 작다.
- [ ] 비밀값, 응답 스타일 선호, 임시 task 메모가 없다.
- [ ] 최신성·벤더 주장에 source URL과 확인 날짜가 있다.

---

## 유지보수

이 영역의 사실은 벤더 동작이며 분기 단위로 바뀐다. [`references/discovery-and-precedence.ko.md`](references/discovery-and-precedence.ko.md)를 먼저 재검증한다. 파일명, 크기 상한, 우선순위 순서가 가장 바뀌기 쉬운 항목이다.

중요한 instruction 변경은 개선이 아니라 실험으로 다룬다. 관찰된 반복 실패 이후에만 규칙을 추가하고, 대표 task에서 있을 때와 없을 때를 비교하며, 성공률*과* 비용을 함께 추적하고, 측정 가능한 효과가 없으면 지운다.

---

## 함께 읽을 문서

- [`references/discovery-and-precedence.ko.md`](references/discovery-and-precedence.ko.md)
- [`references/content-contract.ko.md`](references/content-contract.ko.md)
- [`references/claude-md-adapter.ko.md`](references/claude-md-adapter.ko.md)
- [`references/evidence-and-evaluation.ko.md`](references/evidence-and-evaluation.ko.md)
- [`../context-engineering/CONTEXT_ENGINEERING.ko.md`](../context-engineering/CONTEXT_ENGINEERING.ko.md)
- [`../context-engineering/references/prompt-authoring.ko.md`](../context-engineering/references/prompt-authoring.ko.md)
- [`../cli/README.ko.md`](../cli/README.ko.md)
- [`../validation/index.ko.md`](../validation/index.ko.md)
