# Hermes Agent Hooks

> English version: [`HOOK.md`](HOOK.md)
>
> 함께 읽을 문서: [개요](README.ko.md), [확장](EXTENSIONS.ko.md), [설정](CONFIGURATION.ko.md), [플러그인](PLUGINS.ko.md), [플러그인 작성](PLUGIN_AUTHORING.ko.md)  
> 예전 노트를 틀리게 만든 2026년 변경: [hermes-agent-2026-changes.ko.md](references/hermes-agent-2026-changes.ko.md)
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(2026-10-22 릴리스, 커밋 `bf0203a794a` 측정치)에 포함된 공식 문서와 v0.22.0(2026-10-13) 릴리스 노트를 근거로 삼았습니다. 아래 **사실**은 해당 근거를 추적할 수 있는 내용이고, **권고**는 Hermes의 보장이 아니라 이 안내서가 정한 운영 정책입니다. 버전에 따라 달라지는 동작은 운영 전에 다시 확인합니다. 라이브 문서 사이트는 tag보다 먼저 배포되므로, 사이트에서만 확인한 내용은 v0.22.5 동작으로 적지 않고 확인일과 함께 적었으며, 버전에 민감한 이름은 설치된 CLI의 `--help`로 다시 확인해야 합니다.

## 출처

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) | 네 가지 hook system, gateway event, 배포되는 plugin-hook catalog, shell hook wire protocol, outbound webhook | 확인 2026-11-03 |
| [v0.22.5의 hooks source](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/user-guide/features/hooks.md) | 아래에 인용한 기본값과 필드 목록 | 확인 2026-11-03 |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | plugin hook 등록과 `ctx` 표면 | 확인 2026-11-03 |
| [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | `plugins.hook_callback_timeout`, `plugins.enabled`의 범위 | 확인 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | trusted-by-placement 확장 지점 | 확인 2026-11-03 |
| [v0.22.0 릴리스 노트](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | 새 hook 계열, multiplex gateway, guard hook의 fail-closed 동작 | 확인 2026-11-03 |

## 범위와 선택

**사실:** Hermes는 서로 다른 네 가지 lifecycle-hook system을 문서화합니다. 필요한 실행 방식과 권한에 가장 가까운 system을 고르고, outbound lifecycle notification과 inbound webhook route를 같은 것으로 보지 않습니다.

| 필요한 것 | System | 등록 위치와 범위 | 실행에 개입할 수 있는가? |
| --- | --- | --- | --- |
| Gateway에서만 하는 관찰이나 연동 | Gateway hook | `$HERMES_HOME/hooks/<name>/HOOK.yaml`과 `handler.py`; Gateway 전용이며 CLI, TUI, Desktop, cron은 읽지 않음 | 불가. catalog도 tool call을 막을 수 없다고 적습니다 |
| 프로세스 내부의 tool, model, session, transform 정책 | Plugin hook | native plugin의 `ctx.register_hook()`; CLI와 Gateway | event마다 다릅니다. directive hook은 차단, 수정, approval 요청이 가능합니다 |
| lifecycle 경계에서 실행하는 명령 | Shell hook | profile `config.yaml`의 `hooks.<event>`; CLI, Gateway, Desktop/TUI/dashboard chat | event마다 다릅니다. `pre_tool_call`은 차단, 인자 수정, fail closed가 가능합니다 |
| 외부 receiver로 보내는 HTTP notification | Outbound webhook | `$HERMES_HOME/config.yaml`의 `hooks.outbound`; CLI와 Gateway | 불가. 알림 전용이며 응답은 무시합니다 |

**사실:** plugin middleware는 다섯 번째 hook system이 아니라 별도 registry이자 별도 표면입니다. Inbound webhook gateway route와 route script는 인증 모델을 따로 평가해야 하는 messaging 표면입니다.

## 실행 환경과 신뢰 경계

**사실:** hook은 보안 sandbox가 아니라 trusted-code 확장 지점입니다. gateway hook과 plugin hook은 Hermes 프로세스 안에서 실행됩니다. shell hook은 Hermes OS 사용자 권한의 하위 프로세스로 실행되지만, 이것은 프로세스 분리일 뿐 권한 제한이 아닙니다. Hermes는 dispatch 지점에서 일반 callback 예외를 기록하고 넘어가지만, 멈춤, 종료, 자원 고갈, 악성 동작을 일반적으로 격리하지는 않습니다.

**사실:** gateway hook은 **파일을 놓는 것 자체가 동의**입니다(trusted by placement). profile home의 `hooks/` 아래에서 비어 있지 않은 `events` 목록을 가진 `HOOK.yaml`과 `handler.py`를 함께 가진 하위 디렉터리는 gateway 시작 시 import됩니다. enable 목록도, 최초 사용 확인도 없고, `plugins.enabled`와 `plugins.disabled`도 적용되지 않습니다. `HERMES_SAFE_MODE`도 이 loader를 건너뛰지 않습니다. multiplex gateway에서는 각 profile의 `hooks/`를 그 profile에서 event가 처음 발생할 때 읽습니다.

**권고:** 위험도가 높은 hook은 관리자 권한이 없는 전용 OS 계정에서 실행하고, 서로 신뢰하지 않는 배포는 프로세스, 서비스 계정, container, host 단위로 분리합니다. `HERMES_SAFE_MODE`를 gateway hook의 중지 수단으로 설명하지 않습니다. 문서가 밝힌 해제 방법은 `HOOK.yaml`이나 디렉터리를 지우거나 이름을 바꾸는 것입니다.

## Gateway hooks

**사실:** `HOOK.yaml`에 `name`, `description`, `events`를 적고, `handler.py`에는 `def` 또는 `async def`로 `handle(event_type, context)`를 정의합니다. `command:*` 같은 wildcard를 쓸 수 있습니다. handler에서 난 오류는 기록만 하고 agent를 멈추지 않습니다.

| Event | 발생 시점 | 주요 context key |
| --- | --- | --- |
| `gateway:startup` | gateway 프로세스 시작 | `platforms` |
| `session:start` / `session:end` / `session:reset` | session 생성, 종료, 명시적 reset | `platform`, `user_id`, `session_key` |
| `session:compress` | context 압축 완료 | `session_id`, `old_session_id`, `in_place`, `compression_count` |
| `agent:start` / `agent:end` | turn 시작과 종료 | `chat_id`, `thread_id`, `chat_type`, `session_id`, message 또는 response는 500자에서 잘림 |
| `agent:step` | tool loop의 각 반복 | `iteration`, `tool_names` |
| `reaction:added` / `reaction:removed` | 봇이 볼 수 있는 message에 reaction이 붙거나 빠질 때(현재 Slack adapter) | `reaction`, `item_user_id`, `channel_id`, `message_ts` |
| `command:*` | slash command 실행 | `command`, `args` |

**사실:** 이 리비전의 문서에는 gateway hook의 timeout, retry, fail-closed 규칙이 적혀 있지 않습니다. handler는 event를 내보내는 쪽에서 기다립니다. 따라서 gateway hook이 진행을 늦출 수 없다고 단정하지 않고, tool call을 막을 수 있다고도 말하지 않습니다.

**권고:** gateway hook은 빠른 관찰이나 안전하게 분리한 부수 효과에 씁니다. hook 안에서 외부 I/O 시간을 제한하고, 효과를 멱등하게 만들며, event 이름이나 등록 순서를 turn, profile, 프로세스를 넘는 전역 순서 보장으로 쓰지 않습니다.

## Plugin hooks

**사실:** native plugin은 `register(ctx)`에서 `ctx.register_hook(name, callback)`으로 callback을 등록하며, CLI와 gateway session 모두에서 실행됩니다. payload는 keyword 기반이고 앞으로 필드가 추가되므로 callback은 `**kwargs`를 받아야 합니다. 어떤 이름이 유효한지는 `hermes_cli.plugins.VALID_HOOKS`가 실행 시점의 기준입니다.

**사실:** hot-path observer와 `pre_tool_call`은 `plugins.hook_callback_timeout`의 제한을 받습니다(기본 30초, `0`이면 해제, 600 초과 값은 잘림). 제한을 넘긴 callback은 버려지고 agent loop는 계속됩니다. 이때 `pre_tool_call`은 **fail closed**로 tool을 막고, 나머지 제한 대상 hook은 fail open으로 건너뜁니다. `subagent_stop`처럼 호출 스레드 계약이 있는 hook은 timeout worker로 옮기지 않습니다.

**사실:** 배포되는 catalog는 hook을 동작 기준으로 나눕니다. 대표 항목은 다음과 같습니다.

| 분류 | Hook | 권한 |
| --- | --- | --- |
| Directive/control | `pre_tool_call`, `pre_llm_call`, `pre_verify`, `pre_gateway_dispatch`, `post_gateway_admission` | 반환값이 호출 흐름을 바꿉니다. `pre_tool_call`은 차단, 수정, approval 요청을 받습니다 |
| Transform | `transform_tool_result`, `transform_terminal_output`, `transform_llm_output`, `pre_transcription`, `transform_api_error_classification` | 처음으로 유효한 대체값이 이깁니다 |
| Observer | `post_tool_call`, `post_llm_call`, `pre_api_request`, `post_api_request`, `api_request_error`, `pre_auxiliary_call`, `post_auxiliary_call`, streaming과 session 계열, `subagent_start`/`subagent_stop`, `pre_approval_request`/`post_approval_response`, `on_human_input_request`/`on_human_input_resolved`, `pre_command`, Kanban lifecycle | 반환값을 무시합니다 |

**사실:** 2026년에 더해진 항목 중 운영에 영향이 큰 것은 다음과 같습니다. `post_gateway_admission`은 승인된 inbound message를 plugin이 가져가 agent turn을 건너뛰게 하며, 예외나 timeout을 포함해 그 밖의 결과는 모두 turn을 실행합니다. streaming hook(`on_stream_start`, `on_stream_delta`, `on_stream_end`)은 token 경로 밖에서 host가 소유한 bounded queue로 전달되므로, 멈춘 callback은 자기 queue의 가장 오래된 event만 버립니다. auxiliary-call hook은 제목 생성, 압축, MoA, vision, approval 호출을 다룹니다. `on_human_input_request`와 `on_human_input_resolved`는 비밀번호, clarify, approval 대기 전후에 발생하며 prompt는 항상 마스킹되고 입력한 답은 전달되지 않습니다.

**사실:** 세션 내내 유지되는 지침은 매 turn `pre_llm_call`로 주입하지 말고 `ctx.register_system_prompt_section(id, text_or_callable, position="after_memory", max_chars=4000)`으로 등록합니다. 이 section은 새 session마다 한 번 렌더링되고, 압축 때 고정되며, 재시작 뒤에는 이미 저장된 system prompt에서 복원됩니다. section 하나는 4,000자, 전체는 최대 32개와 8,000자로 제한됩니다. turn마다 달라지는 문맥에는 `pre_llm_call`을 씁니다.

**권고:** plugin hook은 신뢰하는 응용 코드로 다룹니다. 필요한 capability만 허용하고 source를 검토하며, 한 hook의 권한을 다른 hook에 그대로 적용하지 말고 해당 event 계약을 직접 시험합니다. approval을 hook으로 대신 승인하지 않습니다. hardline 차단, 요청 결속, 최종 승인은 Hermes가 소유합니다.

## Shell hooks

**사실:** shell hook은 profile `config.yaml`의 `hooks.<event>`에 선언하고 plugin hook과 같은 event 이름으로 실행되며, Desktop, TUI, dashboard chat에서도 동작합니다. 각 항목은 `command`(필수, `shlex.split`으로 나누고 `shell=False`), tool event용 `matcher`, `timeout`(기본 60초, 300 초과는 경고와 함께 잘림), `fail_closed`/`failClosed`(`pre_tool_call` 전용)를 받습니다.

**사실:** 통신 형식은 stdin의 JSON(`hook_event_name`, `tool_name`, `tool_input`, `session_id`, `cwd`, `profile`, `extra`)과 stdout의 선택적 JSON입니다. stdout에는 `{"decision":"block"|"modify", ...}`(Claude Code/Cursor 형식), `{"action":"block"|"modify"|"approve"|"continue", ...}`(Hermes 표준 형식), `pre_llm_call`용 `{"context": "..."}`, 아무것도 하지 않을 때의 `{}`를 쓸 수 있습니다. `profile`은 multiplex gateway에서 event를 낸 profile이며, 하위 프로세스는 그 profile의 `HERMES_HOME`으로 실행됩니다.

**사실:** `pre_tool_call` hook이 종료 코드 **2**로 끝나면 stdout에 차단 JSON이 없어도 해당 호출을 막습니다. 차단 메시지는 stdout JSON, stderr 앞 400자, 일반 기본 문구 순서로 정해집니다. 그 밖의 event에서 종료 코드 2는 다른 비정상 종료와 같게 처리합니다.

| 실패 상황 | 기본(fail open) | `fail_closed: true` |
| --- | --- | --- |
| 명령이 없거나 실행 권한이 없음 | 경고 후 진행 | **차단** |
| timeout | 경고 후 진행 | **차단** |
| 인식 가능한 directive 없이 비정상 종료 | 경고 후 진행 | **차단** |
| stdout이 JSON이 아님 | 경고 후 진행 | **차단** |
| `{}`를 출력하고 정상 종료 | 진행 | 진행 |

**사실:** 동의는 `(event, command)` 쌍마다 한 번 확인하고 `~/.hermes/shell-hooks-allowlist.json`(profile이면 `profiles/<name>/` 아래)에 저장합니다. 확인을 건너뛰는 방법은 `--accept-hooks`, `HERMES_ACCEPT_HOOKS=1`, `hooks_auto_accept: true` 세 가지입니다. 확인 창은 전경 `hermes chat`이나 `hermes rl`에서만 뜨고, gateway, cron, ACP, CI는 묻지 않습니다. allowlist는 명령 문자열을 기준으로 하므로 script 내용을 고쳐도 동의가 유지되며, `hermes hooks doctor`가 mtime 변경을 알려 줍니다. allowlist나 `hooks:` 변경은 실행 중인 gateway에 약 30초 안에 반영됩니다.

**사실:** `hermes hooks list`, `test <event>`, `revoke <command>`, `doctor`로 설정을 확인하고, 실제로 실행하고, 동의를 철회하고, 점검합니다. `test`는 설정된 명령을 실제로 실행합니다.

**권고:** script는 확인한 뒤에 승인하고 시험합니다. `fail_closed: true`는 시간 제한을 둔 `pre_tool_call` 정책을 충분히 시험한 경우에만 쓰고, 안전 장치로 의존하기 전에 실행 실패, timeout, 잘못된 출력, 거부, approval timeout 경로를 모두 시험합니다.

## Outbound webhooks

**사실:** `hooks.outbound`는 target 목록이며 각 항목은 `url`, `events`, 선택적 `name`, `matcher`, `timeout`(시도당 1~60초), 그리고 `secret_env`(권장) 또는 inline `secret`으로 secret을 받습니다. event 이름은 plugin hook과 같은 집합을 씁니다. 형식이 잘못된 항목은 경고 후 건너뛰고, 변경 사항은 다음 CLI session이나 gateway 재시작 때 적용됩니다.

**사실:** event가 발생하면 shell hook payload 형식에 `delivery_id`, `timestamp`, `profile`을 더한 JSON을 POST하며, header로 `X-Hermes-Event`, `X-Hermes-Delivery`, `X-Hermes-Signature-256`(원문 body의 HMAC-SHA256, `sha256=<hex>`, secret이 있을 때만)을 보냅니다. secret이 없는 target은 서명 없이 전달되고 `hermes hooks list`가 `UNSIGNED`로 표시합니다.

**사실:** 전달은 background 스레드에서 보내고 기다리지 않으며, queue가 가득 차면 새 event를 버립니다. 연결 오류와 5xx는 backoff를 두고 한 번 재시도하고, 4xx는 재시도하지 않으며, 3xx는 따라가지 않고 설정 오류로 기록합니다. 응답은 무시하므로 outbound webhook이 동작을 막을 수는 없습니다.

**권고:** HTTPS를 쓰고 receiver를 멱등하게 만듭니다. 원문 body를 `hmac.compare_digest`로 검증하고, `delivery_id`로 중복을 걸러 내며, 짧은 허용 범위를 벗어난 `timestamp`는 거부합니다. 감사 기록이거나 프로세스 장애를 견뎌야 하는 알림은 외부의 내구성 있는 queue를 함께 씁니다.

## Payload, 개인정보, inbound 경계

**사실:** payload의 민감도는 event마다 다릅니다. `pre_api_request`와 `pre_auxiliary_call`은 의도적으로 원본 `request_messages`와 대화 기록을 전달하며, 정제된 `request` 필드를 쓰는 편이 낫다고 문서가 밝힙니다. `on_human_input_request`는 prompt를 항상 마스킹하고 입력한 답을 전달하지 않습니다. 모든 hook payload에 적용되는 redaction 보장은 없고, outbound 서명이 payload를 비공개로 만들지도 않습니다.

**사실:** inbound webhook 검증은 route와 방식에 따라 다릅니다. 검증이 성공해도 설정한 shared-secret 방식이 충족됐다는 뜻일 뿐이고, 업무 필드가 사실인지, 작성자가 권한이 있는지, 본문이 agent에게 안전한지는 증명하지 않습니다.

**권고:** 인증을 통과한 경우에도 inbound message, webhook 필드, 외부에서 들어온 hook 값을 모두 신뢰하지 않는 agent 입력으로 다룹니다. event와 toolset을 최소로 고르고, hook을 켜기 전에 receiver, 로그, template, 저장 위치를 모두 검토합니다.

## 실패와 순서 모델

**사실:** hook 전체에 적용되는 하나의 실패 정책이나 순서 보장은 없습니다. Python plugin hook이 먼저 등록되고 shell hook이 다음에 등록되며 둘은 같은 dispatcher를 지나므로, 동점이면 plugin의 `pre_tool_call` 결정이 이깁니다. 어디에 있든 block은 앞서 나온 `approve`보다 우선하고, dispatcher는 비어 있지 않은 message를 가진 첫 유효 block에서 반환합니다.

| System/event | 이 리비전의 제한 동작 |
| --- | --- |
| Gateway 또는 plugin callback이 일반 `Exception` 발생 | 기록 후 건너뛰고 다음 callback을 계속 실행 |
| Plugin callback이 `hook_callback_timeout` 초과 | 버려짐. `pre_tool_call`은 차단, 나머지 제한 대상은 건너뜀 |
| Shell `pre_tool_call`이 2로 종료하거나 block directive 반환 | 해당 tool call 차단 |
| Shell 실행 실패, timeout, 잘못된 stdout | 기본은 허용, `fail_closed: true`일 때만 차단 |
| Outbound 직렬화, queue, HTTP 실패 | 기록하거나 버리고, agent 동작을 막지 않음 |

**권고:** system과 event를 하나로 정해 실패 동작을 문서화하고 시험합니다. 원인을 추적할 metadata를 남기고, 누락과 중복과 순서 뒤바뀜을 견디게 만들며, 예외를 잡았다는 이유로 transaction이나 rollback이 있다고 보지 않습니다.

## Profile과 검증

**사실:** profile은 설정과 secret의 범위이지 보안 sandbox가 아닙니다. multiplex gateway에서 각 profile은 자기 `hooks/`, allowlist, `HERMES_HOME`을 유지하고, `plugins.isolation: host`는 third-party plugin 코드를 profile별 별도 프로세스로 옮깁니다. 다만 gateway hook과 shell hook의 실행 위치는 위에서 설명한 그대로입니다.

hook을 켜기 전에 다음을 확인합니다.

1. hook system, 정확한 event, 권한, payload 필드, 실패 동작을 확인합니다.
2. 코드, 명령 인자, 상속되는 환경 변수, outbound receiver, secret 출처를 검토합니다.
3. 현재 `$HERMES_HOME`, profile, allowlist나 동의 상태를 확인합니다.
4. 정상 경로와 timeout, 잘못된 출력, receiver 실패, 중복과 재시도 동작을 일회용 환경에서 시험합니다.
5. Hermes를 업그레이드할 때마다 [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) 문서를 다시 읽습니다.

## 확장 지점

- event별 payload 표는 설치한 Hermes 버전에 고정한 뒤에 추가합니다.
- receiver 구현은 secret, 보존 기간, 개인정보, 재전송, 멱등성 계약을 명시할 때만 추가합니다.
- `hermes hooks test`와 `hermes hooks doctor`는 설정된 script를 실행하므로 script를 확인한 뒤에만 실행합니다.
