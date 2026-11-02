# Hermes Agent 플러그인

> English version: [PLUGINS.md](PLUGINS.md)
> 구현 안내: [PLUGIN_AUTHORING.ko.md](PLUGIN_AUTHORING.ko.md)  
> 예전 노트를 틀리게 만든 2026년 변경: [hermes-agent-2026-changes.ko.md](references/hermes-agent-2026-changes.ko.md)
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(2026-10-22 릴리스, 커밋 `bf0203a794a` 측정치)에 포함된 문서와 v0.22.0 릴리스 노트를 근거로 삼았습니다. 배포 전에 설치한 버전에서 동작을 확인합니다. 라이브 문서 사이트는 tag보다 먼저 배포되므로, 사이트에서만 확인한 내용은 v0.22.5 동작으로 적지 않고 확인일과 함께 적었으며, 버전에 민감한 이름은 설치된 CLI의 `--help`로 다시 확인해야 합니다.

## 범위와 출처

이 안내서는 Hermes 플러그인의 선택, 탐색, 설치, 운영, 보안을 다룹니다. 매니페스트, `register(ctx)`, 코드, 검증, 패키징, 호환성은 [플러그인 작성](PLUGIN_AUTHORING.ko.md)에서 설명합니다.

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [플러그인 개요](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | 탐색, opt-in allow-list, catalog, pack, 보안 검사, isolation | 확인 2026-11-03 |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | native 플러그인과 portable 플러그인 계약 | 확인 2026-11-03 |
| [v0.22.5의 플러그인 문서 source](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/user-guide/features/plugins.md) | 아래에 인용한 기본값과 필드 목록 | 확인 2026-11-03 |
| [플러그인 catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog) | catalog 신뢰 모델과 등재 기준 | 확인 2026-11-03 |
| [MCP](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp) | 외부 도구 표면으로서의 MCP | 확인 2026-11-03 |
| [Agent Plugins v1.0.0 명세](https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md) | portable 패키지 형식 | 확인 2026-11-03 |
| [v0.22.0 릴리스 노트](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | catalog 600개, plugin isolation, 의존성 처리 | 확인 2026-11-03 |

## 가장 작은 확장 표면 선택

| 필요한 것 | 사용할 방식 | 다음 경우에는 native 일반 플러그인을 쓰지 않습니다 |
|---|---|---|
| LLM이 호출하는 도구, Python hook, slash command, CLI 하위 명령, 함께 배포하는 skill | **native 플러그인**: `plugin.yaml`과 Python `register(ctx)` | 외부 MCP 서버나 지식 workflow만 있으면 됩니다. |
| Agent Plugins 구현체가 함께 쓸 수 있는 portable skill과 제한된 MCP 패키지 | **Portable Agent Plugin v1**: `plugin.json`, `skills/`, 선택적 `mcp.json` | Python handler, hook, 명령, provider 등록, sandbox가 필요합니다. Hermes는 전체 적합성이 아니라 부분집합을 지원합니다. |
| 실행 코드가 없는 지침과 workflow | **skill** | 런타임 도구, 자격 증명이 필요한 API, lifecycle 동작이 필요합니다. |
| 이미 있는 외부 도구 서버 | `mcp_servers` 설정의 **MCP** | 프로세스 안에서 도는 Python 동작이나 Hermes lifecycle hook이 필요합니다. |
| Desktop이나 dashboard의 화면 확장 | Desktop Plugin SDK 또는 dashboard 확장 | agent 도구가 아니라 UI 슬롯이 필요합니다. |
| TTS/STT backend 또는 shell event 명령 | 설정 기반 command provider 또는 shell hook | 명령 template으로 연동을 충분히 표현할 수 있습니다. |

**권고:** 제3자 제품을 붙이는 플러그인은 독립 저장소에 만듭니다. Hermes는 이를 품질 판단이 아니라 결합과 유지보수의 경계로 설명합니다.

## 탐색과 활성화 수명 주기

**사실:** 탐색 위치는 저장소에 포함된 `<repo>/plugins/`, 사용자 `~/.hermes/plugins/`, 프로젝트 `.hermes/plugins/`, pip `hermes_agent.plugins` entry point, Nix 선언입니다. 이름이 같으면 뒤에 오는 source가 앞의 것을 대체하므로, 사용자 플러그인이 같은 이름의 번들 플러그인을 가릴 수 있습니다.

**사실:** gateway는 프로젝트에 둔 플러그인을 읽지 않습니다. `hermes`, `--tui`, Desktop, messaging, cron을 포함한 모든 session은 gateway 프로세스에서 플러그인을 한 번만 탐색하고, session을 시작한 디렉터리에서는 찾지 않습니다. 따라서 `HERMES_ENABLE_PROJECT_PLUGINS=true`는 효력이 없고 시작할 때 경고만 남깁니다. 대신 사용자 플러그인으로 설치하고 활성화합니다.

**사실:** 일반 사용자 플러그인과 pip으로 설치한 backend 플러그인은 `plugins.enabled`에 이름이 들어가기 전까지 **탐색만 되고 실행되지 않습니다**. 충돌하면 `plugins.disabled`가 이깁니다. 번들 platform adapter, 번들 backend, memory provider, context engine, model provider는 이 allow-list의 대상이 아니며 자동으로 load되고, `gateway.platforms.<name>.enabled`, `<category>.provider`, `memory.provider`, `context.engine`, `--provider`로 선택합니다.

```bash
hermes plugins                      # 대화형 토글
hermes plugins install owner/repository --no-enable
hermes plugins list
hermes plugins enable calculator
hermes plugins disable calculator
hermes plugins remove calculator
```

**사실:** load 동작에 영향을 주는 시간 제한은 세 가지입니다. `plugins.clone_timeout_seconds`는 기본 300초이고 3600 초과는 잘립니다. `plugins.load_timeout_seconds`는 기본 10초이며, 시간을 넘긴 import나 `register()`는 "load timed out after Ns"로 건너뛰고 나머지 플러그인은 계속 load됩니다. `plugins.hook_callback_timeout`은 기본 30초이고 `0`이면 해제되며 600 초과는 잘립니다.

**사실:** 재현 가능한 설치는 40자 전체 커밋을 고정합니다. Hermes는 detached 상태로 checkout하고 `HEAD`가 요청한 SHA와 같은지 확인한 뒤 source, revision, pin 상태를 profile별로 기록합니다. tag, branch, 축약 SHA는 거부되고 `plugins update`는 pin된 플러그인을 옮기지 않습니다. 새 커밋으로 바꾸려면 `install <source> --force --ref <new-commit>`을 씁니다. 같은 source에서 강제 재설치하면 추적하지 않는 파일은 그대로 두고, 추적 파일의 수정본은 `~/.hermes/plugins-backup/<name>-<sha>/`에 백업합니다.

**사실:** private 저장소는 익명 접근이 거부된 뒤에만 자격 증명을 찾습니다. 순서는 `.env`의 `GITHUB_TOKEN`이나 `GH_TOKEN`, `gh` CLI 로그인, git credential helper입니다. 자격 증명은 그 요청 한 번에만 쓰이고 플러그인의 `.git/config`나 설치 metadata에 기록되지 않습니다.

**권고:** 운영에 쓸 리비전을 정확히 pin하고 업데이트를 코드 배포로 취급합니다. 활성화가 동의의 경계이며, 설치는 아무것도 실행하지 않습니다.

## Catalog, pack, 설치 시 보안 검사

**사실:** `hermes plugins search <term>`, `browse`, `info <name>`은 저장소의 `plugin-catalog/`에 유지되는 선별 catalog를 검색합니다. 2026-11-03 기준 catalog 페이지에는 **910개**(Official 20, Verified 9, Community 881)가 있었고, v0.22.0 출시 당시의 600개에서 늘어난 수치입니다. 이름만으로 설치하면 해당 항목의 저장소를 고정된 커밋 SHA로 받고 catalog 출처를 기록하므로, `hermes plugins update`가 catalog가 움직이면 다시 pin할 수 있습니다. `owner/repo`나 Git URL을 직접 적으면 검토하지 않은 custom source로 표시됩니다.

**사실:** catalog 등재는 사람이 고정된 커밋을 확인하고, capability 선언을 검사하고, 저장소가 제출 기준을 넘겼다는 뜻입니다. catalog 페이지는 이것이 **보안 감사가 아니며** 같은 저장소의 다른 커밋에 대해서는 아무것도 말하지 않는다고 분명히 적습니다. 항목은 알려진 문제를 선언할 수 있고 설치할 때 함께 표시되며, catalog 규칙은 Hermes 내부를 패치하거나 검사할 수 없는 binary를 싣는 항목을 막습니다.

**사실:** plugin pack은 여러 플러그인을 고정하는 `hermes-pack.yaml` 파일입니다. 각 항목은 40자 전체 `ref`를 쓰고, 선택적으로 secret이 아닌 `config:` 초기값과 선언용 `skills:` 목록을 담습니다. `hermes plugins pack show|install|export`로 미리 보고, 설치하고, 현재 상태를 파일로 뽑습니다. pack 설치는 항상 필수 검토 화면을 보여 주고 내용 전체에 한 번 확인을 받은 뒤, 플러그인마다 평소의 capability 동의를 다시 받습니다. `--yes`는 없고, secret은 거부되고 export에서 제거되며, 각 플러그인은 독립적으로 설치됩니다.

**사실:** `hermes plugins install`과 `plugins update`는 정적 검사를 실행하고 세 가지 판정을 냅니다. `safe`는 그대로 설치하고, `caution`은 발견 사항을 보여 주고 확인을 받거나 `--force`를 요구하며, `dangerous`는 `--force`로도 넘길 수 없습니다. 업데이트에서 `dangerous`가 나오면 검토할 때까지 플러그인을 비활성 상태로 둡니다. 문서 산문이나 시험 fixture에서 나온 문자열은 동작이 아니라 맥락으로 낮춰 평가합니다. 검사는 `plugins.scan_on_install: false`로 끕니다.

**권고:** catalog 등재, `safe` 판정, Doctor 통과는 서로 다른 신호이며, 어느 것도 동작에 대한 보안 검토가 아닙니다.

## Provider와 확장 경계

다음 backend에는 일반 도구가 아니라 전용 interface를 씁니다.

| 확장 | 경계와 선택 |
|---|---|
| 추론/model provider | `plugins/model-providers/<name>/`에서 `ProviderProfile`을 등록하고 사용자가 `--provider`나 설정으로 고릅니다. 저장소 밖 provider는 `hermes plugins install`로 설치하고 `hermes auth`로 로그인합니다. |
| Memory provider 또는 context engine | 단일 활성 provider interface(`memory.provider`, `context.engine`)입니다. |
| Gateway platform, image/video 생성, browser, web search, TTS/STT, delegation, computer use, terminal backend, secret source, dashboard 인증 | 각각 문서화된 `ctx.register_*` interface와 탐색 경로를 씁니다. |
| 외부 도구 | MCP를 설정하고 Hermes가 server의 도구를 탐색합니다. 플러그인은 capability를 허용받은 `ctx.call_mcp`로 MCP를 호출할 수도 있습니다. |

일반 플러그인은 함께 존재할 수 있습니다. Provider 선택은 소유와 활성화 방식이 다르므로 자격 증명, 재시도, capability 동작을 provider interface 안에 둡니다.

## Portable Agent Plugins v1

portable 패키지는 native Python 플러그인이 아니라 호환 패키지입니다.

```text
my-portable-plugin/
├── plugin.json
├── skills/
│   └── summarize/
│       └── SKILL.md
└── mcp.json
```

**사실:** Hermes는 **Agent Plugins v1.0.0** 형식을 대상으로 합니다. `plugin.json`, skill frontmatter, 고정된 구성 요소 위치, `mcp.json`, 해석된 경로, symlink containment를 로컬에서 검증하고 load 중에는 schema를 가져오지 않습니다. 활성화한 패키지는 `skills_list`와 `skill_view`로 읽기 전용 이름 공간의 skill을 제공하고 MCP도 제공합니다. 이름 공간은 `agent-plugin-<slug>-<hash>`로 결정적입니다. `PLUGIN_ROOT`는 해석된 패키지 root이고 `PLUGIN_DATA`는 profile 범위의 쓰기 가능한 저장소입니다.

**사실:** 지원하는 MCP 부분집합은 **stdio**와 **Streamable HTTP**입니다. stdio는 실행 파일 하나와 분리된 인자 목록을 쓰고 shell을 거치지 않습니다. Streamable HTTP는 userinfo와 fragment가 없는 절대 `http(s)` URL을 요구하며, 평문 HTTP는 loopback에서만 허용하고 header는 cross-origin redirect를 넘지 않습니다. legacy `sse`는 보고 후 건너뜁니다. server 이름이 겹치면 `config.yaml`이 이기고, 그다음에는 먼저 load된 패키지가 이깁니다.

**사실 — 버전 고정:** 상위 명세 저장소에는 `spec/1.1.0.md`도 있지만 그 문서 스스로 **Working Draft**라고 밝히며, tag는 `v1.0.0`만 있습니다. Hermes가 load한다고 문서화한 형식은 v1.0.0이므로 v1.0.0을 대상으로 삼습니다. 공식 Hermes 문서가 밝히기 전까지 1.1.0의 기능을 Hermes 동작으로 읽지 않습니다.

portable v1에는 trust, permission, provenance, sandbox가 없습니다. 활성화하면 그 지침과 로컬 실행 파일이 다른 설치 플러그인과 같은 full-trust 지위를 얻습니다.

## 운영과 보안

```bash
# 탐색과 load 진단을 확인합니다.
HERMES_PLUGINS_DEBUG=1 hermes plugins list
hermes logs --level WARNING
hermes plugins capabilities calculator
hermes plugins doctor ./calculator --ci     # Hermes와 같은 탐색/import/register 경로
hermes plugins validate ./calculator --install-deps   # catalog CI와 같은 검사
```

필요한 런타임 자격 증명은 native 매니페스트의 `requires_env`로 선언합니다. 필수 변수가 없으면 Hermes가 멈추지 않고 플러그인을 비활성화합니다. 자격 증명은 portable `mcp.json`, 매니페스트, source, 로그, 플러그인 상태에 두지 않습니다.

**사실:** 특권 host 표면은 `capabilities:`에 선언하며, id는 `tools.override`, `llm.provider_override`, `llm.model_override`, `llm.agent_id_override`, `llm.profile_override`, `llm.task_override`입니다. 설치나 활성화 때 동의를 받고, 나중에 더해진 id에 대해서만 다시 묻습니다. 동의하지 않은 capability는 fail closed이므로 플러그인은 `ctx.has_capability()`로 확인하고 기능을 줄여 동작합니다. pip으로 배포하는 플러그인은 `hermes_agent.plugin_capabilities` entry point 그룹에 선언합니다.

**사실 — isolation:** `plugins.isolation: host`(기본값 `in_process`)는 third-party 플러그인 코드를 profile마다 별도 Python 프로세스로 옮기고, 그 프로세스는 필요할 때 시작해 전용 pipe로 통신합니다. 프로세스가 죽어도 Hermes는 살아 있고, 진행 중이던 호출은 tool 오류를 반환한 뒤 host가 재시작됩니다. gateway platform adapter, approval transport, Telegram handler, 자체 SDK client를 만드는 provider, terminal backend, streaming/websocket dashboard endpoint, Hermes를 monkeypatch하는 플러그인은 프로세스 안에서 실행되어야 하며 `host` 모드에서는 분명한 사유와 함께 실패합니다. profile이 서로 격리해야 하는 사용자들의 것이라면 이 설정을 managed scope에 고정합니다.

**중요한 사실:** capability는 동의와 감사 수단이지 **sandbox가 아니며**, `isolation: host`도 sandbox가 아닙니다. interpreter와 profile secret을 분리할 뿐 OS 권한을 제한하지는 않습니다. 신뢰하는 코드만 설치하고 활성화합니다.

2026년에 더해진 주요 표면은 `ctx.llm`(host가 소유한 model 호출), `tool_request`/`llm_request`/`tool_execution`/`llm_execution` 종류를 다루는 `ctx.register_middleware`, approval transport, delegation provider, provider 플러그인, 업데이트 후에도 남는 상태를 위한 `plugin_data_dir()`/`plugin_db()`, `/plugin:skill`로 호출하는 플러그인 skill입니다.

작성 세부는 [플러그인 작성](PLUGIN_AUTHORING.ko.md)에서 다룹니다.
