# Adapter로서의 CLAUDE.md

> 영어판: [`claude-md-adapter.md`](claude-md-adapter.md)

**목적**: 저장소에 `CLAUDE.md`가 필요한지 판단하고, 필요하다면 그것이 공유 계약의 두 번째 사본이 되어 drift하지 않게 유지한다.

기본 답은 **정본 `AGENTS.md` 하나, 그리고 실제 Claude 전용 차이가 있거나 `AGENTS.md`를 직접 읽지 못하는 세션을 위해서만 `CLAUDE.md`**다.

---

## 1. 왜 이 질문이 생기는가

`AGENTS.md`는 널리 채택되었고, Claude Code는 v2.1.277부터 그것을 직접 읽는다. 따라서 `AGENTS.md`만 둔 저장소가 더 이상 Claude에게 보이지 않는 것은 아니다. 질문은 두 가지 좁은 이유로 남는다.

- 기본 **Project instructions** 설정에서 작업 디렉터리나 그 위에 `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md` 중 하나가 있으면 Claude는 `AGENTS.md` 대신 `CLAUDE.md` 파일을 읽는다.
- 일부 세션은 `AGENTS.md`를 아예 읽을 수 없다. v2.1.277 이전 버전, 기능 플래그를 가져오지 않는 세션(Bedrock 등 서드파티 프로바이더, telemetry 비활성화), 업그레이드 뒤 첫 세션, `disableAllHooks`나 `allowManagedHooksOnly`가 설정된 세션, 내장 `agents-md` 플러그인을 끈 세션이다.

그런 경우를 위한 문서화된 대체 경로는 import이며, 두 파일을 함께 두는 저장소는 여전히 둘이 갈라질 위험을 진다. 두 실패 모드 모두 전략을 의식적으로 고르는 것보다 나쁘다. 전체 동작은 [`discovery-and-precedence.ko.md`](discovery-and-precedence.ko.md) §2에 있다.

---

## 2. 전략 선택

| 전략 | 방법 | 사용 시점 |
|---|---|---|
| **A. native 단독** | `CLAUDE.md`를 아예 두지 않음 — Claude Code가 v2.1.277+에서 `AGENTS.md`를 직접 읽는다 | 기본값. 실제 Claude 전용 차이가 없고, 지원해야 하는 모든 세션이 `AGENTS.md`를 읽을 수 있을 때 |
| **B. 심볼릭 링크** | `ln -s AGENTS.md CLAUDE.md` | A와 같지만 지원 대상 세션 중 일부가 `CLAUDE.md` fallback을 필요로 할 때. 다만 Edit·Write 도구는 심볼릭 링크를 통해 쓰기를 거부하고, `core.symlinks`가 꺼진 Windows 체크아웃은 커밋된 심볼릭 링크를 일반 텍스트 파일로 바꾼다 |
| **C. import stub** | `CLAUDE.md`에 `@AGENTS.md` 한 줄만 | B와 같지만 심볼릭 링크에 의존할 수 없을 때(Windows checkout, 링크를 잘 못 다루는 도구) |
| **D. 얇은 adapter** | `@AGENTS.md` import 후 검증된 Claude 전용 규칙만 추가 | 실제 Claude 전용 차이 존재: skill, hook, permission mode, plugin metadata |
| **E. 분리된 파일** | 독립적으로 관리하는 두 파일 | 거의 없음. 명시적 이유가 있을 때만, drift를 각오하고 |

E는 유지보수 부채다. 모든 공유 규칙이 두 집을 갖게 되고, 둘을 같게 유지해줄 장치는 없다.

> native 경로가 기본인 이유는 Claude Code가 `AGENTS.md`를 스스로 읽기 때문이다. 기존 심볼릭 링크나 import가 틀린 것은 아니며 두 번 읽히지도 않지만, 이제는 `AGENTS.md`를 직접 읽지 못하는 세션을 위한 fallback이지 요구 사항이 아니다.

### 이 저장소

`hypercore`는 **D**를 쓴다. `CLAUDE.md`는 `@AGENTS.md`로 시작하는 얇은 adapter이며, 정본 계약은 그 import를 통해 로드되고 그 아래에 Claude 전용 규칙만 덧붙인다. 이 선택의 상충은 의도적이며 이해할 가치가 있다. import는 계약 로드를 보장하지만 매 세션 비용을 내고, 산문 포인터는 앞단 비용이 없지만 조언에 그쳐 에이전트가 정본 파일을 읽지 않고 진행할 수 있다.

두 번째 차이가 더 중요하다. `AGENTS.md`는 version-controlled이고 `CLAUDE.md`는 gitignore 대상이므로, `CLAUDE.md`는 공유 산출물이 아니라 *로컬 clone adapter*다. 그래서 "공유 계약은 `AGENTS.md`에 정본으로 남는다"는 규칙이 단순한 스타일 문제가 아니다. `CLAUDE.md`에만 쓴 내용은 다른 사람에게 존재하지 않으며 리뷰될 수도 없다.

---

## 3. adapter에 들어갈 것

**다른 런타임에서 거짓이거나 없는** 내용만.

- Claude Code skill, 그리고 어떤 task에 어떤 skill을 로드할지.
- hook, 그리고 그것이 결정적으로 강제하는 동작.
- 이 저장소에 실제로 노출된 permission mode, plugin metadata 경로, MCP 서버.
- *읽지 말아야 할 것*에 대한 명시(예: 프로젝트 근거로 사용하면 안 되는 전역 `~/.claude/` 설정).
- import 배선: `@AGENTS.md` 줄과 `@path` 참조.

들어가면 **안 되는** 것:

- Codex, Cursor, Copilot에도 참인 규칙. 그것은 `AGENTS.md`에 속한다.
- 공유 계약의 재진술, 요약, "빠른 버전". 중복은 이 파일이 피하려고 존재하는 실패 모드다.
- 공유 규칙의 완화. adapter는 런타임 세부를 더할 뿐 정본 계약을 약화하지 않는다.

현재 Anthropic 지침은 표면 간 반복 자체를 안티패턴으로 지목한다. 같은 지시를 시스템 프롬프트, skill, instruction 파일에 되풀이하면 강조가 아니라 충돌이 생긴다.

---

## 4. Import 동작

`CLAUDE.md`는 다른 파일을 끌어올 수 있다:

> "CLAUDE.md files can import additional files using `@path/to/import` syntax."

> "Both relative and absolute paths are allowed. Relative paths resolve relative to the file containing the import, not the working directory."

> "Imported files can recursively import other files, with a maximum depth of four hops."

실무적 귀결:

- **4 hop은 실재하는 천장이다.** `CLAUDE.md` → `AGENTS.md` → instructions 인덱스 → 영역 문서 → reference 문서 같은 사슬이면 도달한다. 깊은 사슬을 만들지 말고 말단 문서를 직접 import한다.
- **상대 경로는 import한 파일 기준으로 해석된다.** 대상이 그대로 있어도 파일을 옮기면 import가 깨진다.
- **import는 즉시 로드다.** import된 파일은 인라인 텍스트와 똑같이 세션 시작 시 context 비용을 치른다. 매 세션 필요한 것만 import하고, 나머지는 링크만 걸어 에이전트가 필요할 때 읽게 한다.

마지막 항목이 실무 분기선이다. 항상 필요한 자료는 `@import`, 관련 있을 때 읽을 자료는 일반 markdown 링크.

---

## 5. 크기

> "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."

adapter는 그보다 훨씬 작아야 한다. 보통 stub 하나에 짧은 런타임 섹션이면 충분하다. 200줄에 근접한다면 그 내용은 거의 확실히 `AGENTS.md`나 skill에 속한다.

Anthropic이 밝힌 성장 시 탈출구는 더 긴 파일이 아니다:

> "Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on-demand."

또한 200줄은 절단이 아니라 권고다. `CLAUDE.md`는 "are loaded in full regardless of length". 초과해도 내용이 눈에 띄게 잘리는 것이 아니라 준수율이 조용히 떨어지며, 그래서 아무 경고도 뜨지 않는다.

---

## 6. 로컬·개인 내용

`CLAUDE.local.md`는 "personal project-specific preferences"용으로 문서화되어 있고 gitignore 대상이다. 샌드박스 URL, 선호하는 테스트 데이터, 개인 작업 습관에 쓴다.

개인 선호를 공유 파일에 넣지 않고, 공유 프로젝트 규칙을 로컬 파일에 넣지 않는다. GitHub 지침도 반대 방향에서 같은 경계에 도달해, 응답 스타일과 장황함 선호를 instruction에 담지 말아야 할 것으로 나열한다.

별개로 Claude Code는 프로젝트별 자동 memory를 `~/.claude/projects/<project>/memory/`에 유지한다. 이는 `CLAUDE.md`와 다른 장치이며 공유 프로젝트 규칙을 작성할 곳이 아니다. 다른 clone에는 존재하지 않는다.

---

## 7. 검증

- [ ] 전략(A–E)이 우연이 아니라 의식적 선택이다.
- [ ] `CLAUDE.md`가 존재한다면 해석된다 — 심볼릭 링크 대상 또는 `@AGENTS.md` import가 실제로 존재한다. native 전략에서는 해석할 대상이 없다.
- [ ] `AGENTS.md`와 `CLAUDE.md`에 동시에 나오는 규칙이 없다.
- [ ] `CLAUDE.md`의 모든 규칙이 실제로 Claude 전용이며 현재 런타임에서 확인되었다.
- [ ] adapter가 공유 안전·권위 규칙을 약화하지 않는다.
- [ ] import 사슬이 4 hop 이내이고, 상대 경로가 import한 파일 기준으로 해석된다.
- [ ] 항상 필요한 자료만 import되고 나머지는 링크다.
- [ ] 개인 선호는 gitignore된 `CLAUDE.local.md`에 있다.
- [ ] `CLAUDE.md`가 gitignore 대상이면, 공유 계약 내용이 거기에만 존재하지 않는다.
- [ ] 언급한 skill, hook, MCP 서버, plugin 경로가 이 저장소에 실재함을 확인했다.

---

## 출처

| 출처 | URL | 확인일 |
|---|---|---|
| Claude Code memory | <https://code.claude.com/docs/en/memory> | 확인 2026-09-19 |
| Claude Code features overview | <https://code.claude.com/docs/en/features-overview> | 확인 2026-09-19 |
| Claude 5 context engineering | <https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models> | 확인 2026-09-19 |
| AGENTS.md 표준 | <https://agents.md/> | 확인 2026-09-19 |
| GitHub Copilot response customization | <https://docs.github.com/en/copilot/concepts/prompting/response-customization> | 확인 2026-09-19 |

## 함께 읽을 문서

- [`../AGENTS_MD.ko.md`](../AGENTS_MD.ko.md)
- [`discovery-and-precedence.ko.md`](discovery-and-precedence.ko.md)
- [`content-contract.ko.md`](content-contract.ko.md)
- [`../../cli/claude-code/README.ko.md`](../../cli/claude-code/README.ko.md)
