# Hermes Agent: 예전 노트를 틀리게 만드는 2026년 변경

> English version: [`hermes-agent-2026-changes.md`](hermes-agent-2026-changes.md)
>
> 함께 읽을 문서: [hook](../HOOK.ko.md), [플러그인](../PLUGINS.ko.md), [플러그인 작성](../PLUGIN_AUTHORING.ko.md), [확장](../EXTENSIONS.ko.md), [messaging](../MESSAGING.ko.md), [Discord](../DISCORD.ko.md)
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a`) 문서와 v0.22.0 릴리스 노트를 근거로 삼았습니다.

2025년과 2026년 초에 쓰인 Hermes 자료 중 상당수가 지금 동작과 정반대를 적고 있어서 이 문서를 따로 둡니다. 각 행은 예전 노트를 틀리게 만든 변경, 대신 해야 할 일, 근거입니다.

| 영역 | 바뀐 내용 | 대신 할 일 | 근거 |
| --- | --- | --- | --- |
| Gateway 구조 | gateway 프로세스 하나가 기본으로 **모든 profile**을 맡습니다(`gateway.multiplex_profiles`, 기본 `true`). 예전의 profile당 프로세스 하나가 아닙니다. | service는 하나만 띄우고, 이전은 `hermes gateway migrate --multiplex`로 하며, 특정 profile만 다룰 때는 `hermes -p <name> gateway stop\|start`를 씁니다. `gateway.standalone: true`는 임시 opt-out입니다. | [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway), v0.22.0 노트 |
| Session 수명 | 유휴 시간과 날짜 기준 `session_reset` mode가 **폐기**됐습니다. 새 대화를 시작하는 방법은 `/new`와 `/reset`뿐이고, 옛 키는 시작할 때 경고를 냅니다. | `session_reset.mode: idle\|daily\|both`를 지웁니다. 시간 기준 reset이 꼭 필요하면 catalog 플러그인 `hermes-session-reset-policy`를 설치합니다. | [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging), v0.22.0 노트 |
| Slash command | `/clear`와 `/history`는 CLI 전용입니다. `/branch`(별칭 `/fork`)는 Discord, Telegram, Slack, Matrix에서 형제 thread를 열고, `/btw`, `/bg`, `/sessions search`는 chat에서도 동작합니다. | messaging 문서에서 CLI 전용 명령을 약속하지 않습니다. 현재 chat을 분기로 옮길 때는 `/branch --here`를 씁니다. | [Slash commands](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) |
| 프로젝트 플러그인 | gateway는 session을 시작한 디렉터리의 `.hermes/plugins/`를 **읽지 않으며**, `HERMES_ENABLE_PROJECT_PLUGINS=true`도 session에 효력이 없습니다. | 사용자 플러그인으로 설치하고 `hermes plugins enable <name>`을 실행합니다. | [플러그인](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) |
| 플러그인 catalog | 출시 당시 600개에서 2026-11-03 기준 **910개**(Official 20, Verified 9, Community 881)로 늘었고, 이름만으로 설치하면 고정된 커밋을 받습니다. 등재는 **보안 감사가 아니라고** 명시합니다. | 출처 추적은 catalog 이름으로 하고, 코드는 여전히 직접 확인하며, custom 설치는 40자 전체 SHA로 pin합니다. | [플러그인 catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog) |
| 공급망 | 설치와 업데이트가 `safe`/`caution`/`dangerous` 판정을 내리는 정적 검사를 실행하고, `dangerous`는 `--force`로도 넘길 수 없습니다. plugin pack은 `hermes-pack.yaml`로 고정된 묶음을 설치합니다. | 업데이트를 코드 배포로 다룹니다. pack은 `hermes plugins pack show`로 먼저 확인합니다. | [플러그인](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) |
| 플러그인 isolation | `plugins.isolation: host`는 third-party 코드를 profile마다 별도 프로세스로 옮기고 그 profile의 secret만 넘깁니다. | 공유 배포에서 켜고 managed scope에 고정합니다. gateway adapter와 monkeypatch 플러그인은 in-process로 둡니다. | [플러그인](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) |
| 플러그인 의존성 | `python_dependencies`는 더 이상 선언만 하지 않습니다. package manager가 core, extras, 다른 활성 플러그인과 함께 해석하고 환경을 한 번에 교체합니다. `pyproject.toml`이 매니페스트보다 우선합니다. | 상한을 적고, 의존성 동의 질문을 예상하며, 자동 설치에는 `--no-deps`/`--yes-deps`를 씁니다. sidecar는 `python_runtime: external`입니다. | [Build a Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) |
| 내부 import | 2026년 9월 이전 내부 import 경로의 호환 계층이 **2026-09-14**에 만료됐고, 옛 import는 이제 `ImportError`로 실패합니다. | 이름을 정의한 모듈에서 import하거나 `ctx`와 문서화된 ABC를 씁니다. core를 monkeypatch하지 않습니다. | [Build a Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) |
| Hook callback | hot-path observer와 `pre_tool_call`은 `plugins.hook_callback_timeout`(기본 30초, 최대 600) 뒤 버려지고, 시간을 넘긴 `pre_tool_call`은 **fail closed**입니다. | callback을 짧고 멱등하게 유지하고, hot-path hook에 느린 네트워크 호출을 두지 않습니다. | [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) |
| 새 hook 계열 | streaming(`on_stream_*`), provider 시도(`pre_api_request`/`post_api_request`/`api_request_error`, `pre_auxiliary_call`/`post_auxiliary_call`), human input, gateway admission(`post_gateway_admission`), `pre_command`, session finalize/delete, `post_compaction`, `agent_loop_stopped`, skill lifecycle hook이 있습니다. | 로그를 긁거나 내부를 감싸지 말고 해당 hook을 씁니다. 정확한 payload는 catalog에서 확인합니다. | [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) |
| Shell hook | Desktop, TUI, dashboard chat에서도 실행되고, 동의는 `(event, command)` 쌍마다 `shell-hooks-allowlist.json`에 저장됩니다. 종료 코드 `2`는 `pre_tool_call`을 막고, 변경은 실행 중인 gateway에 약 30초 안에 반영됩니다. | 업그레이드 뒤 `fail_closed` 정책을 다시 확인하고 `hermes hooks doctor`를 실행합니다. | [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) |
| 플러그인 API | `ctx.llm`, `ctx.register_middleware`, `register_system_prompt_section`, approval transport, delegation/computer-use/dashboard 인증 provider, `plugin_data_dir()`/`plugin_db()`, `ctx.ask_choice`, `ctx.has_plugin`, `ctx.profile_name`이 더해졌습니다. | gateway와 Kanban worker에서 `None`인 `ctx._cli_ref` 같은 private 속성 대신 이 API를 씁니다. | [Build a Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) |
| Portable 패키지 | Hermes가 대상으로 하는 형식은 **Agent Plugins v1.0.0**입니다. 명세 저장소에는 **Working Draft** 1.1.0도 있지만 Hermes가 지원한다고 문서화하지 않았습니다. | v1.0.0 패키지를 계속 만들고, 1.1.0 기능이 load된다고 가정하지 않습니다. | [Agent Plugins 1.0.0](https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md) |
| Discord 권한 | 권장 정수가 `309237763136`(Create Public Threads 추가)으로 바뀌었고, `309240908864`는 voice용 Connect/Speak를 더합니다. | Create Public Threads가 권장되기 전에 만든 bot은 다시 초대합니다. | [Discord 설정](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Discord bot handoff | bot handoff에는 `<@BOT_ID>` 문자열이 필요하고(`bots_require_inline_mention`, 기본 `true`), 계속 창과 함께 5분에 20개가 쌓이면 10분 동안 추가 bot message를 버리는 loop guard가 있습니다. | `DISCORD_ALLOW_BOTS="none"`을 유지합니다. 예전의 "circuit breaker가 없다"는 서술은 더 이상 맞지 않습니다. | [Discord 설정](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Discord 복구 | `discord.missed_message_backfill`이 옵션 묶음(`window_seconds`, `limit`, `max_dispatches`, `max_attempts`)이 되었고 기본은 꺼져 있습니다. | 단일 스위치로 가정하지 말고 범위와 상한을 직접 정합니다. | [Discord 설정](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Discord 상태 | socket이 heartbeat는 ACK하면서 event를 하나도 전달하지 않을 수 있어 `websocket_event_max_silence_seconds`(기본 14400)가 더해졌습니다. | 평소 guild traffic을 알고 있을 때만 조정합니다. | [Discord 설정](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| 실행 환경 | 관리형 설치는 **Python 3.14**를 쓰고, 통합 package manager(`hermes pm`)가 고정되고 hash로 검증한 도구와 Python 환경을 세대 단위로 관리합니다. | 관리형 설치에 Python이나 의존성을 손으로 넣지 않고 `hermes pm`이 다시 만들게 합니다. | v0.22.0 릴리스 노트 |

## 업그레이드 확인 목록

1. 현재 버전과 목표 버전 사이의 릴리스 노트를 모두 읽습니다.
2. hook과 플러그인 문서를 다시 읽고, 2026년 9월 이전 내부 경로를 import하는 플러그인이 없는지 확인합니다.
3. `config.yaml`을 폐기 항목과 대조합니다. 흔한 것은 `session_reset`, profile별 gateway unit, 자격 증명만으로 켜지던 platform입니다.
4. `hermes doctor`, `hermes plugins doctor <path>`, `hermes hooks doctor`를 다시 실행합니다.
5. thread 생성이나 voice를 쓰는 Discord bot은 다시 초대합니다.
6. 두 번째 gateway를 띄우기 전에 구조를 확인합니다. service는 하나이고 모든 profile을 맡습니다.

## 출처

| 출처 | 확인 |
| --- | --- |
| [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) | 확인 2026-11-03 |
| [플러그인](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | 확인 2026-11-03 |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | 확인 2026-11-03 |
| [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging) | 확인 2026-11-03 |
| [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) | 확인 2026-11-03 |
| [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway) | 확인 2026-11-03 |
| [플러그인 catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog) | 확인 2026-11-03 |
| [Slash commands](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) | 확인 2026-11-03 |
| [v0.22.0 릴리스 노트](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | 확인 2026-11-03 |
