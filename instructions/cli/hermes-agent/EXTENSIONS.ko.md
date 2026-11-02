# Hermes Agent 확장과 운영 지도

> English version: [EXTENSIONS.md](EXTENSIONS.md)
> 함께 읽을 문서: [개요](README.ko.md), [설정](CONFIGURATION.ko.md), [Discord](DISCORD.ko.md), [messaging gateway](MESSAGING.ko.md), [skill](SKILLS.ko.md), [플러그인](PLUGINS.ko.md), [hook](HOOK.ko.md)
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a` 측정치)에 포함된 문서와 v0.22.0 릴리스 노트를 근거로 삼았습니다. 모든 서술은 이 공식 출처 범위를 넘지 않습니다. 라이브 문서 사이트는 tag보다 먼저 배포되므로, 사이트에서만 확인한 내용은 v0.22.5 동작으로 적지 않고 확인일과 함께 적었으며, 버전에 민감한 이름은 설치된 CLI의 `--help`로 다시 확인해야 합니다.

Hermes의 확장은 신뢰 경계를 넘습니다. MCP server는 로컬 프로그램을 실행하거나 원격 서비스를 호출하고, messaging gateway는 다른 platform에서 온 message를 받으며, tool provider는 입력과 자격 증명을 받습니다. 확장을 켜는 일은 UI 기능을 더하는 일이 아니라 capability를 주는 일로 다룹니다.

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [MCP](https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp) | server 종류, catalog, 필터링, 보안 | 확인 2026-11-03 |
| [플러그인](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | catalog, 보안 검사, isolation | 확인 2026-11-03 |
| [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging) | gateway 수명 주기와 전달 | 확인 2026-11-03 |
| [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway) | 모든 profile을 하나의 프로세스로 | 확인 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | approval 구조와 신뢰 경계 | 확인 2026-11-03 |
| [v0.22.0 릴리스 노트](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | Connectors, plugin isolation, catalog 규모 | 확인 2026-11-03 |

## 확장 표면 선택

| 필요한 것 | 주된 표면 | 운영 경계 |
| --- | --- | --- |
| 이미 있는 외부 도구, database, 내부 API | MCP(`mcp_servers`) | server 코드와 그 자격 증명이 Hermes에서 쓸 수 있게 됩니다. |
| Linear, Notion 같은 hosted 앱 도구 | Nous tool gateway를 통한 Connector | 로그인 신원과 앱 자체의 권한 범위가 접근을 결정합니다. |
| Hermes 자체 동작 확장 | native 플러그인 또는 provider 설정 | 기본은 프로세스 안 실행이며, provider는 작업 내용을 자기 서비스로 보냅니다. |
| Telegram, Discord, Slack, WhatsApp, Signal, Email에서 대화 | messaging gateway | platform 신원, pairing, 신뢰하지 않는 입력 문장입니다. |
| lifecycle event 처리나 로컬 정책 강제 | hook, shell hook, plugin hook | hook 코드가 설정된 프로세스 권한으로 실행됩니다. |
| 음성 입력과 출력 | STT/TTS provider | cloud 기반이면 음성과 텍스트가 host를 떠납니다. |
| GUI나 로컬 제어 화면 | Desktop 앱 또는 dashboard | bind와 접근 제어가 누가 조작할 수 있는지를 정합니다. |

native 플러그인 안내를 MCP의 대체로 쓰지 않고, catalog 등재 항목이 sandbox라고 가정하지 않습니다.

## MCP: 설정, 제한, 운영

**사실:** Hermes는 로컬 stdio server와 원격 HTTP server를 하나의 `mcp_servers`에 함께 설정하고, Nous가 검토해 catalog에 올린 server는 설치 전까지 비활성으로 둡니다. catalog 설치 card는 Desktop, TUI, CLI에 모두 나타나며 모든 설정 항목을 한 번에 보여 주고 secret은 가립니다. server가 token을 받아들인 뒤에만 설정과 token을 함께 저장하고, Hermes가 임의로 browser를 열지 않습니다.

```yaml
mcp_servers:
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"]
  remote_api:
    url: "https://mcp.example.com/mcp"
    headers:
      Authorization: "Bearer ${MCP_TOKEN}"
```

**사실:** `${VAR}`와 `${env:VAR}`는 `~/.hermes/.env`를 포함한 환경에서 연결 시점에 해석됩니다. 정의되지 않은 변수는 문자 그대로 남고 경고를 기록합니다. stdio server는 걸러진 환경을 받으므로 넘길 변수는 명시해야 합니다. OAuth server는 discovery, PKCE, refresh, step-up 인증을 처리하고 token은 server별로 제한된 권한의 파일에 저장됩니다. 화면이 없는 host에서는 `hermes mcp login <server>`로 다시 인가합니다.

**사실:** 필터 우선순위는 deny 목록, allow 목록, `mcp_servers.<name>.tools`의 glob pattern 순서입니다. utility tool은 따로 걸러지고, tool이 모두 걸러진 server는 조용히 사라지지 않고 보고됩니다.

**사실:** `lazy: true`인 server는 디스크의 schema cache로 등록하고 첫 호출 때 프로세스를 띄웁니다. `notifications/tools/list_changed`가 오면 registry를 자동으로 갱신하고, 나머지는 `/reload-mcp`로 다시 확인합니다. 실행 중인 gateway는 `config.yaml`을 지켜보다가 바뀐 항목을 약 1분 안에 연결하거나 정리합니다.

**권고:** 필요한 tool만 고르고, 특히 파괴적이거나 관리자 권한을 쓰는 동작은 뺍니다. 설치 전에 catalog manifest의 source, bootstrap 명령, transport, endpoint, 인증을 검토합니다. catalog 검토는 근거일 뿐이고 사용자의 공급망 검토를 대신하지 않습니다.

## Hosted Connectors

**사실:** Connector는 Nous tool gateway를 통해 hosted 앱에서 agent가 동작하게 합니다. 앱을 처음 쓰면 무료 connectors 전용 신원이 만들어지므로 시작에 Nous 계정이 필요하지 않습니다. 같은 앱의 계정을 이름을 붙여 여러 개 연결할 수 있고 `/connectors`나 `hermes connectors`로 관리합니다. Desktop의 **Connectors** 페이지는 hosted 앱과 로컬 MCP server를 한 목록에 보여 주며 기존 MCP tab을 대체했습니다.

**권고:** `tools.connectors.enabled: false`로 connector를 끄고 `nous.guest: false`로 guest 신원을 막을 수 있습니다. MCP server와 같은 수준으로 자격 증명과 권한 범위를 검토합니다. Connector는 별도 sandbox가 아니라 사용자의 앱 권한을 사용합니다.

## Provider 지도: 무엇을 확장하고 데이터가 어디로 가는가

현재 provider ID, model 이름, 자격 증명의 기준은 공식 [provider 안내](https://hermes-agent.nousresearch.com/docs/integrations/providers)입니다. [Tool Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/features/tool-gateway)는 Nous Portal을 통해 web search, image 생성, TTS, cloud browser backend를 제공할 수 있고, 개별 backend는 자체 자격 증명을 쓸 수도 있습니다. model provider는 이제 저장소 밖 플러그인으로 설치하고 `hermes auth`로 인증할 수 있습니다.

| Capability | 정할 것 | 데이터와 자격 증명 경계 |
| --- | --- | --- |
| Model | provider, model, fallback, endpoint | prompt, tool schema, 모델이 보는 문맥이 선택한 provider로 갑니다. |
| Memory/context | 지속 기억과 프로젝트 문맥을 쓸지 | 로컬 상태는 Hermes home에 남고, 가져온 텍스트가 그 자체로 신뢰받지는 않습니다. |
| Web search | backend와 query 처리 | query와 검색 결과가 해당 provider로 가고, web 내용은 신뢰하지 않는 입력입니다. |
| Browser | 로컬 또는 cloud backend, 인증 browsing 정책 | cloud browser는 탐색과 page 데이터를 받습니다. session cookie는 가치가 높은 자격 증명입니다. |
| Image/video | 생성 또는 분석 provider와 보존 정책 | prompt와 media가 해당 provider로 갑니다. |
| Secret | `.env`, OAuth, 외부 주입 | 필요한 구성 요소에만 주입하고 prompt나 저장소에 커밋한 YAML에는 넣지 않습니다. |
| TTS/STT | 음성 backend와 동의 | cloud backend는 음성과 전사문을 받습니다. |

## Messaging gateway와 adapter

**사실:** 이제 한 machine에 하나의 gateway 프로세스가 기본으로 모든 profile을 맡습니다(`gateway.multiplex_profiles`, 기본 `true`). 각 profile은 자기 자격 증명, allowlist, session, cron job을 그대로 유지합니다. `hermes update`가 profile별 설치를 옮기고, `hermes gateway migrate --multiplex`로 직접 할 수 있으며, webhook platform은 profile마다 `/p/<profile>/`로 라우팅합니다. `gateway.standalone: true`는 임시 opt-out입니다. profile을 만들면 재시작 없이 그 profile의 bot이 살아납니다.

**사실:** `platforms.<name>.enabled: false`는 `.env`에 자격 증명이 남아 있어도 우선합니다. 키를 아예 두지 않으면 자격 증명이 있을 때 켜지는 기존 동작을 유지합니다. 인가, session 범위, 전달 규칙, adapter 차이는 [messaging gateway](MESSAGING.ko.md)에서, Developer Portal과 접근 정책은 [Discord 설정](DISCORD.ko.md)에서 다룹니다.

```bash
hermes gateway setup
hermes gateway install
hermes gateway start
```

**권고:** bot token은 `.env`에 두고, pairing이나 allowlist로 대화할 수 있는 사람을 제한하며, 운영에는 별도 신원을 씁니다. chat에서의 위험 명령 approval은 올바르게 pairing된 대화에서만 의미가 있습니다. adapter가 있다는 이유로 headless 자동 승인을 켜지 않습니다.

## Hook과 shell hook

**사실:** gateway hook, plugin hook, shell hook, outbound webhook 네 system은 등록 방식과 범위, 권한이 다릅니다. shell hook은 이제 Desktop, TUI, dashboard chat에서도 실행되고, 최초 동의는 `(event, command)` 쌍마다 저장됩니다. plugin callback은 `plugins.hook_callback_timeout`(기본 30초)의 제한을 받고, 시간을 넘긴 `pre_tool_call`은 fail closed로 차단합니다.

hook을 설정하기 전에 [Hook](HOOK.ko.md)을 읽습니다. hook 설정은 실행 코드로 다룹니다. script는 검토한 위치에 두고, 신뢰하지 않는 텍스트를 shell 문법에 넣지 않고, 실행 시간을 제한하며, secret을 남기지 않으면서 실패를 진단할 만큼 기록합니다. hook이 성공했다고 입력이 안전해지는 것은 아닙니다.

## Dashboard, desktop, profile, 상태

**사실:** 기본 Hermes home은 `~/.hermes/`이고 `config.yaml`, `.env`, 인증 자료, 기억, skill, cron job, session, log, plugin 데이터, MCP token이 여기 있습니다. `HERMES_HOME`이 profile 상태를 고르고, multiplex gateway는 secret 범위를 지키면서 여러 profile을 한 프로세스에서 맡깁니다.

```bash
hermes config
hermes config get model
hermes config set terminal.backend docker
hermes config unset terminal.backend
hermes config check
hermes config migrate
```

**사실:** `hermes config set`은 API key를 `.env`로, secret이 아닌 값은 `config.yaml`로 보냅니다. 외부 secret system은 지원하지 않는 inline vault 참조에 기대지 말고 시작 시 환경 값으로 주입합니다.

**사실:** profile 격리가 host의 일반 자격 증명까지 자동으로 격리하지는 않습니다. 로컬 backend에서 `terminal.home_mode: auto`는 실제 OS `HOME`을 유지하므로 하위 프로세스가 `ssh`, GitHub CLI, cloud, package manager 자격 증명을 볼 수 있습니다. 신뢰하지 않는 작업에는 Docker, Modal, Daytona, Vercel Sandbox, Singularity 같은 격리 backend가 더 안전한 기본값입니다. host mount 하나로 경계가 무너지므로 mount, egress, 환경 변수 전달을 확인합니다.

## 설치 시점의 플러그인 신뢰

**사실:** 플러그인 코드 앞에는 서로 독립적인 세 가지 통제가 있습니다. 설치와 업데이트는 `safe`, `caution`, `dangerous` 판정을 내리는 정적 검사를 실행하고, `dangerous`는 `--force`로도 넘길 수 없습니다. `plugins.isolation: host`는 third-party 코드를 해당 profile의 secret만 가진 별도 프로세스로 옮깁니다. catalog는 항목을 검토한 커밋에 고정하지만 스스로 코드 감사가 아니라고 밝힙니다.

**권고:** 세 가지를 함께 씁니다. 검토한 source, 이해한 검사 판정, 온전히 신뢰하지 않는 코드에 대한 host isolation입니다. 어느 것도 코드를 읽는 일이나 capability 없는 설계를 대신하지 않습니다.

## 보안 감사, approval, 안전한 운영

확장을 켜거나 바꾸기 전에 source와 릴리스, 실행 위치, tool 목록과 변경 범위, 자격 증명과 OAuth scope, 접근 가능한 파일과 네트워크, 허용된 gateway 사용자, log 보존, 제거 방법을 확인합니다. `hermes doctor`는 제품 진단을, `hermes plugins validate`는 catalog 검사를 로컬에서 수행하고, 설치와 업데이트는 정적 보안 검사를 실행합니다. 어느 것도 설정과 코드 검토를 대신하지 않습니다.

approval mode는 `approvals.mode`에 있고 값은 `smart`(기본), `manual`, `off`입니다. 검토한 자동화가 필요하지 않다면 `cron_mode: deny`, `single_query_mode: deny`, `unattended_mode: deny`를 유지하고, 무인 programmatic 표면(webhook, msgraph webhook, API server)은 approval timeout을 기다리지 않고 즉시 차단한다는 점을 함께 기억하며, 위험 명령 guard stack은 host에 닿는 backend에서만 동작한다는 점도 함께 고려합니다. `hermes --yolo`, `hermes chat --yolo`, `/yolo`, `HERMES_YOLO_MODE=1`은 해당 session의 확인만 건너뛰고 항상 켜진 hardline 차단 목록은 그대로입니다. 영구 "always" 승인은 `command_allowlist` 항목이 되므로 주기적으로 확인합니다.

## 판단 표와 사고 대응

| 상황 | 선택 | 피하거나 먼저 확인할 것 |
| --- | --- | --- |
| 검토된 제3자 연동이 필요 | tool을 최소로 고른 MCP catalog 항목 | manifest와 bootstrap을 보기 전 설치 |
| hosted SaaS 앱이 필요 | 이름 붙인 계정의 Connector | connector 접근이 앱 권한보다 좁다고 가정 |
| 사내 또는 로컬 서비스가 필요 | stdio MCP 또는 통제된 내부 HTTP MCP | host 환경 전체나 넓은 파일 시스템 root 전달 |
| messaging 제어가 필요 | gateway adapter와 pairing 또는 allowlist | channel 참여자를 운영자로 취급 |
| 무인 자동화가 필요 | 검토를 거친 cron과 최소 권한 | 운영 secret이 있는 host에서 `cron_mode: approve` |
| 신뢰하지 않는 내용을 처리 | 별도 profile과 격리 backend | 실제 HOME, host mount, 전달된 자격 증명을 쓰는 로컬 backend |
| 제3자 플러그인이 필요 | catalog 항목, 검사 판정, host isolation | catalog 등재를 코드 감사로 가정 |
| 변경 뒤 tool이 실패 | 설정, 자격 증명, endpoint, 필터 순서로 확인 | 무작정 재로딩하거나 권한 넓히기 |

자격 증명 노출이 의심되면 영향받은 gateway, provider, MCP 연결을 멈추고, 발급처에서 자격 증명을 폐기하고 교체하며, 관련 `.env`나 OAuth 상태와 영구 allowlist를 정리합니다. log와 adapter 인가를 확인한 뒤 설정과 scope를 검토한 다음에만 다시 켭니다. log의 redaction은 민감한 입력을 기록해도 된다는 근거가 아닙니다.
