# OpenCode 런타임 프로필

> 영어판: [`README.md`](README.md)

## 범위

이 문서는 OpenCode에서 실행되는 skill의 사용자 질문, 승인, 도구 발견, 부작용 게이트를 다루는 어댑터 프로필이다. 공통 규칙은 [`../capability-contract.ko.md`](../capability-contract.ko.md)를 따른다. 여기 적은 capability는 1차 문서가 밝힌 것뿐이며, 그 밖의 기능은 여전히 런타임에서 확인해야 한다.

## 권위와 근거

사용자·프로젝트 지시와 공통 capability contract가 이 프로필보다 우선한다. 런타임 관찰은 한 번의 실행에 대한 증거이지 권위가 아니다.

- 근거: 공식 OpenCode 문서 `opencode.ai/docs`(문서별 최종 수정 2026-11-02, 확인 2026-11-03)와 `opencode.ai/v2/docs`의 OpenCode 2 문서 트리다. 이 프로필이 처음 인용한 `skills/git-commit/SKILL.md`는 커밋 `d4f79f9`에서 제거되었으므로 더 이상 근거가 아니며, 아래 문서가 이전의 "근거 없음" 상태를 대체한다.
- OpenCode는 설정 형식이 다른 두 문서 트리를 함께 공개한다. `/docs`(OpenCode 1)를 기본으로 보고, 설치된 주 버전이 2일 때만 `/v2/docs`를 읽는다. 이름이 다르기 때문이다(`permission`/`bash`/`task` 대 `permissions`/`shell`/`subagent`).

## 진입 표면

| 논리적 capability | 구현 | 실행 전 확인 |
|---|---|---|
| 비대화형 실행 | `opencode run [message..]`, 원시 JSON 이벤트는 `--format json`, 그리고 `--model`/`-m`, `--agent`, `--file`/`-f`, `--variant`, `--dir`, `--port` | 설치 버전, 인증, provider, 작업 디렉터리 |
| 세션 계속 | 최근 세션은 `--continue`/`-c`, 특정 세션은 `--session`/`-s <id>`, 이어갈 때 분기는 `--fork` | 대상 세션이 존재하고 의도한 세션인지 |
| 헤드리스 서버 | `opencode serve`가 HTTP API를 열고, `opencode run --attach <server-url>`가 이를 재사용해 MCP 콜드 스타트를 줄인다 | 서버 주소, 인증(`--password`, `OPENCODE_SERVER_PASSWORD`), 공유 서버 사용이 허용되는지 |
| 자동 승인 | TUI나 `opencode run`의 `--auto`는 명시적 `deny` 규칙에 걸리지 않는 요청을 승인한다 | 명시적 `deny`는 그대로 적용된다. 이는 모드 변경이지 게이트된 작업의 승인이 아니다 |

## 권한 모델

권한 규칙은 `allow`(승인 없이 실행), `ask`(질문), `deny`(차단) 중 하나로 결정된다.

| 항목 | OpenCode 1(`/docs`) |
|---|---|
| 형식 | `permission` 객체에 `*`로 전체를 정하고 도구별로 덮는다. 값은 축약 동작이거나 패턴→동작 객체다 |
| 평가 | 패턴 일치이며 "마지막으로 일치하는 규칙이 이긴다". 그래서 포괄 `*` 규칙을 먼저 두고 구체 규칙을 뒤에 둔다 |
| 기본값 | 관대하다. 대부분 `allow`이고 `doom_loop`와 `external_directory`만 `ask`다. `read`는 기본 허용이지만 `.env`와 `.env.*`는 ask, `.env.example`은 allow다 |
| 키 | `read`, `edit`, `glob`, `grep`, `bash`, `task`, `todowrite`, `skill`, `lsp`, `question`, `webfetch`, `websearch`, `external_directory`, `doom_loop` |
| 세분화 | `read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `external_directory`, `lsp`, `skill`은 패턴 객체를 받고 나머지는 축약 동작만 받는다 |
| ask 결과 | `once`는 이번 요청만, `always`는 세션의 남은 기간 동안 일치하는 요청을, `reject`는 거부한다 |
| `.env` | `read`는 대부분 경로를 허용하지만 `.env`와 `.env.*`는 ask, `.env.example`은 allow다 |

OpenCode 2는 skill에 영향을 주는 세 가지를 바꾼다. `permission` 객체 대신 `permissions: [{action, resource, effect}]` 배열을 쓰고, 동작 이름이 `shell`과 `subagent`로 바뀌며, 기본 정책은 `{"action":"*","resource":"*","effect":"allow"}`와 `.env` ask 규칙이고 **일치하는 규칙이 없는 검사는 `ask`로 처리된다.** "항상 허용" 승인은 프로젝트 범위의 지속 허용 규칙이 되지만 설정된 `deny`를 덮지 못하며, "비대화형 클라이언트는 승인 요청을 어떻게 처리할지 스스로 정해야 한다".

skill에 주는 결과는 다음과 같다.

- capability가 보인다는 사실은 허가가 아니다. 기본값이 관대하므로 게이트된 작업은 런타임이 허용하더라도 별도의 명시적 사용자 승인이 필요하다.
- `always`는 경계를 현재 요청 밖으로 넓힌다. 사용자가 넓은 규칙을 요청하지 않았다면 `once`를 쓴다.
- `--auto`나 이미 있는 `allow` 규칙은 질문 자체를 없애므로 게이트된 작업이 무인으로 실행될 수 있다. 질문에 기대기 전에 현재 설정의 실제 규칙을 확인한다.

## 질문 capability

- `question` 도구가 문서화되어 있다. "이 도구는 LLM이 작업 중 사용자에게 질문하도록 한다"고 적혀 있고, "각 질문에는 헤더, 질문 본문, 선택지 목록이 포함된다. 사용자는 제시된 선택지를 고르거나 직접 답을 입력할 수 있다." 질문이 여러 개면 제출 전에 이동할 수 있다.
- `question` 권한 키로 제어되므로 `deny`면 도구가 숨겨지고 `ask`면 사용 전에 질문한다. 내장 `Plan` agent는 "질문 도구를 허용해 명확화 질문을 할 수 있고", OpenCode 2의 `general` subagent는 질문을 거부한다.
- 사용 가능 범위의 주의점이 있다. `OPENCODE_ENABLE_QUESTION_TOOL`은 "CLI, 앱, 데스크톱 외 클라이언트에서 질문 도구를 켜는" 변수다. 그 외 클라이언트에서는 도구가 없을 수 있으므로 노출을 확인하고 평문 한 문장으로 대체한다.

## 위임과 백그라운드

| 표면 | 문서화된 동작 |
|---|---|
| agent 유형 | primary agent(Build, Plan)와 subagent(General, Explore) 두 가지이며 primary agent는 Tab으로 순환한다 |
| 커스텀 agent | `~/.config/opencode/agents/`(전역)나 `.opencode/agents/`(프로젝트)의 마크다운 파일, 또는 `opencode.json`의 `agent` 객체. 파일 이름이 agent 이름이 되고 `description`이 필수다 |
| agent frontmatter | `description`, `mode`(`primary`/`subagent`/`all`), `model`, `temperature`, `permission`, 그리고 agentic 반복 상한인 `steps` |
| 호출 | primary agent가 설명을 보고 자동으로 부르거나, 사용자가 `@<subagent>`로 직접 부른다 |
| 위임 권한 | subagent 실행은 `task`가 제어하고, OpenCode 2에서는 동작 이름이 `subagent`다 |
| 중첩 깊이 | `subagent_depth` 기본값은 `1`이라 primary agent가 subagent를 띄울 수는 있지만 그 subagent가 또 띄우지는 못한다. `0`이면 subagent 실행이 모두 막힌다 |
| 백그라운드 subagent | `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS`("백그라운드 subagent 작업 사용") 뒤에만 있으며 기본 기능이 아니다 |

병렬 위임에 의존하는 skill은 계획에 적힌 분량을 가정하지 말고 `subagent_depth`, `task` 권한, 백그라운드 subagent 활성화 여부를 확인해야 한다.

## plugin과 skill

- plugin은 hook 함수를 내보내는 JavaScript/TypeScript 모듈이다. 로컬 파일은 `.opencode/plugins/`(프로젝트)나 `~/.config/opencode/plugins/`(전역)에서 로드하고, npm 패키지는 `plugin`에 적으면 시작할 때 Bun이 설치한다.
- 문서화된 hook은 `tool.execute.before`, `tool.execute.after`, `shell.env`, `experimental.session.compacting`이고, 커스텀 도구용 `event`와 `tool`이 더 있다.
- 권한 이벤트(`permission.asked`, `permission.replied`)는 `event` hook으로 **관찰**할 수 있다. 승인에 답하는 hook은 문서에 없으므로 plugin이 사용자를 대신해 승인할 수 없다. `tool.execute.before`에서 예외를 던지면 호출이 막히는데, 이는 정책 계층이지 동의가 아니다.
- OpenCode 2는 plugin을 `plugins` 배열과 `opencode plugin add|list|check|update|remove`로 옮겼고, 내장 정책 plugin(`opencode.config.policy`, `opencode.provider.opencode`)은 제거를 무시해 저장소가 정책 적용을 끌 수 없게 한다.
- skill은 `.opencode/skills/<이름>/`, `~/.config/opencode/skills/<이름>/`, `.claude/skills/<이름>/`, `~/.claude/skills/<이름>/`, `.agents/skills/<이름>/`, `~/.agents/skills/<이름>/`의 `SKILL.md` 폴더다. `name`과 `description`이 필수이고 이름은 디렉터리와 같아야 한다. 로딩은 `skill` 권한이 제어하며 `deny`면 숨기고 `ask`면 질문한다.

## 부작용 게이트

1. 필요한 capability와 범위를 공통 계약과 현재 요청에서 도출한다.
2. 기본값을 가정하지 말고 현재 설정의 실제 권한 규칙을 읽는다. 기본값은 대부분 허용하고 `.env` 읽기만 질문하며, `--auto`나 저장된 `always`는 남은 질문도 없앤다.
3. `deny`는 최종으로 취급한다. auto 모드에서도 적용되고 어떤 승인도 이를 넓히지 못한다.
4. 런타임이 허용하더라도 외부·파괴적·자격 증명·프로덕션 부작용은 명시적 사용자 승인을 요구한다.
5. 어떤 규칙이 적용 중이었고 어떤 승인 결과(`once`, `always`, `reject`)를 썼는지 최종 기록에 남긴다.

## Skill author 체크리스트

- [ ] `scope`, `authority`, `evidence`, `verification`을 분리하고 [`../capability-contract.ko.md`](../capability-contract.ko.md)에 연결했는가?
- [ ] 질문을 안전성이나 출력에 중대한 빠진 결정으로 제한했고, `question` 도구의 노출을 확인했는가?
- [ ] 질문 도구를 쓸 수 없을 때 게이트된 행동 전에 멈추는 평문 fallback이 있는가?
- [ ] 실제 권한 규칙을 확인했고, 관대한 기본값이나 `--auto`를 승인으로 취급하지 않았는가?
- [ ] 병렬 작업을 약속하기 전에 위임 깊이, `task` 권한, 백그라운드 subagent 가용성을 확인했는가?
- [ ] 모든 외부·파괴적·자격 증명·프로덕션 효과를 별도로 승인받고 대상과 다시 대조했는가?
