# Hermes Agent Messaging Gateway

> English version: [`MESSAGING.md`](MESSAGING.md)
>
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a` 측정치)에 포함된 문서와 v0.22.0 릴리스 노트를 근거로 삼았습니다. 아래 **사실**은 Hermes의 Messaging Gateway, Security, multiplexing, platform별 문서를 추적할 수 있는 내용이고, **권고**는 이 안내서가 정한 운영 조언입니다. Discord 설정은 [`DISCORD.ko.md`](DISCORD.ko.md), 설정 파일은 [`CONFIGURATION.ko.md`](CONFIGURATION.ko.md)에서 다루고, 2026년 변경 목록은 [references/hermes-agent-2026-changes.ko.md](references/hermes-agent-2026-changes.ko.md)에 있습니다. 라이브 문서 사이트는 tag보다 먼저 배포되므로, 사이트에서만 확인한 내용은 v0.22.5 동작으로 적지 않고 확인일과 함께 적었으며, 버전에 민감한 이름은 설치된 CLI의 `--help`로 다시 확인해야 합니다.

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging) | 프로세스 모델, 명령, session, 전달, platform 표 | 확인 2026-11-03 |
| [v0.22.5의 gateway 문서 source](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/user-guide/messaging/index.md) | 아래에 인용한 기본값 | 확인 2026-11-03 |
| [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway) | 모든 profile을 하나의 프로세스로 | 확인 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | 인가 순서, pairing, DM 처리 | 확인 2026-11-03 |
| [Slash commands reference](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) | gateway 명령 동작 | 확인 2026-11-03 |
| [v0.22.0 릴리스 노트](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | multiplex 이전, 폐기된 session reset | 확인 2026-11-03 |

## Gateway 프로세스 모델

**사실:** gateway는 machine마다 하나 도는 background 프로세스이며, 설정된 모든 platform에 연결하고 각 message를 chat별 session store로 보낸 뒤 cron scheduler(60초 tick)를 함께 실행합니다. cron이 gateway 안에 있으므로 gateway가 꺼져 있으면 예약 작업은 그냥 실행되지 않습니다.

**사실:** v0.22.0부터 gateway 하나가 기본으로 **모든 profile**을 맡습니다(`gateway.multiplex_profiles`, 기본 `true`). 각 profile은 자기 자격 증명, allowlist, session, cron job, hook을 유지하고, 프로세스는 event loop, HTTP listener, 상태 표면을 하나만 씁니다. 충돌이 없으면 `hermes update`가 profile별 gateway를 기본 gateway로 합치고, `hermes gateway migrate --multiplex`로 직접 할 수 있습니다. webhook platform은 profile마다 `/p/<profile>/`로 받고, `hermes -p <name> gateway stop|start`는 특정 profile만 멈추거나 켭니다. `gateway.standalone: true`는 임시 opt-out입니다.

```bash
hermes gateway                         # 전경 실행
hermes gateway setup                   # 대화형 platform 설정
hermes gateway install                 # Linux systemd user service / macOS launchd agent
sudo hermes gateway install --system   # Linux 부팅 시점 system service
hermes gateway start | stop | restart | status
hermes gateway status --system         # Linux system service 확인
```

### 서비스 운영과 상태

| Platform | 로그 | 참고 |
| --- | --- | --- |
| Linux user service | `journalctl --user -u hermes-gateway -f` | `sudo loginctl enable-linger $USER`를 주면 로그아웃 뒤에도 유지됩니다 |
| Linux system service | `journalctl -u hermes-gateway -f` | |
| macOS | `tail -f ~/.hermes/logs/gateway.log` | plist는 `~/Library/LaunchAgents/ai.hermes.gateway.plist` |

**사실:** 문서는 `ExecStopPost` kill drop-in이 재시작 반복을 만든다고 경고하고, user unit과 system unit을 함께 두지 말라고 합니다. macOS에서 PATH나 도구가 바뀌면 `hermes gateway install`을 다시 실행해 launchd가 새 PATH를 잡게 합니다. `gateway.systemd_watchdog_seconds: 120`과 `hermes gateway install --force`는 Linux 서비스를 `Type=notify` watchdog 복구로 전환하고, `0`이면 `Type=simple`을 유지합니다.

**사실:** 상태 신호는 두 가지입니다. event loop 밖의 watchdog이 `gateway.loop_watchdog_probe_interval_s`(기본 30초)마다 loop를 확인하고, `gateway.loop_watchdog_max_strikes`(기본 3)만큼 연속으로 응답이 없으면 모든 스레드 stack을 기록하고 `gateway_state: degraded`를 남긴 뒤 종료 코드 75로 끝나 supervisor가 재시작하게 합니다. housekeeping은 60초마다 `gateway_state.json`을 갱신하므로, 이 시각이 120초보다 오래되면 `hermes gateway status`가 heartbeat 지연을 알립니다. `kill -USR2 <pid>`는 재시작 없이 stack만 덤프합니다.

## 공통 설정 순서

1. 동작하는 model과 tool provider를 먼저 확인합니다. model이 없는 bot은 연결은 되고 답을 못 합니다.
2. platform 자격 증명은 `~/.hermes/.env`에, 구조화된 동작 설정은 `~/.hermes/config.yaml`에 둡니다.
3. `hermes gateway setup`이나 문서화된 환경 필드로 adapter를 설정합니다.
4. `hermes gateway install`과 `hermes gateway start`, 또는 전경 `hermes gateway`로 시작합니다.
5. allowlist, 승인된 DM pairing, 명시적 allow-all 중 하나로 인가를 정하고 link, invite, QR 단계를 마칩니다.
6. `hermes gateway status`와 실제 message로 확인합니다.

**사실:** `config.yaml`의 `platforms.<name>.enabled: false`는 `.env`에 자격 증명이 남아 있어도 우선합니다. 키를 두지 않으면 자격 증명이 있을 때 켜지는 기존 동작을 유지합니다. 이전 릴리스는 이 키와 무관하게 자격 증명만으로 12개 platform을 다시 켰는데, 지금은 해당 platform마다 경고를 한 번 남기고 시작하지 않습니다.

## 지원 platform

**사실:** 비교 표에 나오는 platform은 Telegram, Discord, Slack, Google Chat, WhatsApp, WhatsApp Cloud API, Signal, SMS, Email, Home Assistant, Mattermost, Matrix, DingTalk, Feishu/Lark, WeCom, WeCom Callback, Weixin, BlueBubbles(iMessage), Photon(iMessage), QQ, Yuanbao, Microsoft Teams, LINE, ntfy, Raft, IRC, Buzz, SimpleX이고 browser도 포함됩니다. 별도 문서로 A2A, Microsoft Graph webhook, Open WebUI, Teams meetings도 다룹니다.

**사실:** Hermes Relay는 chat platform이 아닙니다. 외부 connector를 앞에 두고 handshake에서 connector별 capability를 협상합니다.

## Adapter 차이

Discord는 [`DISCORD.ko.md`](DISCORD.ko.md)에서 따로 다룹니다. 아래 다섯 개는 구조가 얼마나 다른지 보여 줍니다.

### Telegram

자격 증명은 `TELEGRAM_BOT_TOKEN`, `TELEGRAM_ALLOWED_USERS`이고 BotFather에서 만듭니다.

**사실:** 기본 transport는 outbound long polling입니다. webhook mode는 `TELEGRAM_WEBHOOK_URL`과 **필수** `TELEGRAM_WEBHOOK_SECRET`을 요구하고 선택적으로 `TELEGRAM_WEBHOOK_PORT`(기본 8443)를 받으며, 유휴 시 잠드는 host를 겨냥합니다. group에서 message를 보려면 BotFather privacy mode를 끄거나 bot을 group admin으로 둡니다. **하나의 bot token을 여러 gateway에서 동시에 쓰지 않습니다.** 동시 polling은 거부됩니다.

### Slack

자격 증명은 `SLACK_BOT_TOKEN`(`xoxb-`), `SLACK_APP_TOKEN`(`xapp-`), `SLACK_ALLOWED_USERS`입니다.

**사실:** Bolt Socket Mode를 WebSocket으로 쓰므로 공인 URL이 필요 없습니다. workspace마다 앱을 설치하거나 초대합니다. bot token을 쉼표로 나열하면 gateway 하나가 여러 workspace를 맡을 수 있고, app-level token 하나가 Socket Mode를 처리하며 첫 bot token이 대표가 됩니다. thread는 session 연속으로 동작하고, Slack이 thread 안의 native slash command를 막기 때문에 Hermes는 그 자리에서 `!` 접두사를 받습니다(`!stop`, `!new`, `!status`).

### Signal

자격 증명은 `SIGNAL_HTTP_URL`(예: `http://127.0.0.1:8080`), `SIGNAL_ACCOUNT`, 되도록 `SIGNAL_ALLOWED_USERS`입니다.

**사실:** Signal은 `signal-cli` daemon을 HTTP mode로 돌리고, 들어오는 message는 SSE로, 답장은 JSON-RPC로 주고받으며, 계정은 보조 기기로 연결합니다(`signal-cli link -n "HermesAgent"`). `SIGNAL_GROUP_ALLOWED_USERS`에 group ID나 `*`를 두지 않으면 group message는 무시하고, 보낸 message를 수정할 수 없어 tool 진행 표시를 생략합니다.

### Email

자격 증명은 `EMAIL_ADDRESS`, `EMAIL_PASSWORD`(앱 비밀번호), `EMAIL_IMAP_HOST`, `EMAIL_SMTP_HOST`, `EMAIL_ALLOWED_USERS`입니다.

**사실:** email은 읽지 않은 mail을 IMAP으로 polling하고(`EMAIL_POLL_INTERVAL`, 기본 15초) SMTP로 답장합니다. bot API는 없습니다. 답장은 `In-Reply-To`/`References`와 `Re:` 제목으로 thread를 유지합니다. 모르는 발신자는 기본적으로 무시하며, `platforms.email.unauthorized_dm_behavior: pair`로 pairing을 켤 수 있습니다. 받은편지함에는 관계없는 mail이 섞이기 때문입니다. **하나의 inbox에는 gateway 하나만 붙입니다.**

### WhatsApp

**사실:** WhatsApp adapter는 Baileys 기반 Node.js bridge(`Node.js 18+`)이고 `bot`(별도 bot 계정)과 `self-chat`(자신에게 message) 두 mode가 있습니다. `WHATSAPP_ENABLED=true`와 `WHATSAPP_MODE`로 켜고, 접근은 `WHATSAPP_ALLOWED_USERS`(국가번호, `+` 없이, 또는 `*`)나 `WHATSAPP_ALLOW_ALL_USERS=true`로 정합니다. `hermes whatsapp`이 wizard를 실행하고 bridge 의존성을 설치한 뒤 Linked Devices에서 스캔할 QR code를 보여 줍니다.

**권고:** 문서가 이 bridge에 **계정 정지 위험**이 있다고 밝힙니다. business bot에는 Meta가 지원하는 WhatsApp Business Cloud API adapter를 씁니다. Meta Business 계정과 공인 webhook URL이 필요합니다.

## 인가와 pairing

**사실 — 문서화된 확인 순서:** platform allow-all → 승인된 DM pairing → platform allowlist → 전역 allowlist(`GATEWAY_ALLOWED_USERS`) → 전역 allow-all(`GATEWAY_ALLOW_ALL_USERS` 또는 `gateway.allow_all_users: true`) → **기본 거부**. platform allowlist는 Telegram, Discord, Slack, Signal, SMS, Email, Mattermost, Matrix, DingTalk, Feishu, WeCom, WeCom Callback, Teams에서 `<PLATFORM>_ALLOWED_USERS` 형식을 씁니다.

**사실 — 승인되지 않은 DM:** `unauthorized_dm_behavior`는 대화형 platform에서 기본 `pair`이고, `ignore`는 조용히 버리며, `decline`은 정중한 거절을 한 번 보내고 그 발신자를 24시간 무시합니다(`unauthorized_dm_decline_message`로 문구 변경). platform 절이 전역 값을 덮습니다.

**사실 — pairing:** 모르는 사용자는 혼동하기 쉬운 글자를 뺀 32자 alphabet에서 `secrets.choice()`로 만든 8자 code를 받습니다. 유효 시간은 1시간이고, 사용자당 10분에 1회로 제한되며 platform마다 대기 code는 최대 3개입니다. 운영자는 `hermes pairing approve <platform> <CODE>`로 승인하고, `hermes pairing list`로 확인하며, `hermes pairing revoke <platform> <user-id>`로 철회합니다.

**사실 — admin 등급은 접근 가능 여부와 별개입니다.** `gateway.platforms.<platform>.extra`에서 `allow_from`은 접근을 주고, `allow_admin_from`, `user_allowed_commands`, `group_allow_admin_from`, `group_user_allowed_commands`는 slash command를 통제합니다. `/help`와 `/whoami`는 항상 허용되고, DM과 group은 admin 목록이 따로입니다. `/sessions all`은 admin 전용입니다.

## Session 범위

**사실:** session key는 message 출처에서 나옵니다.

| 표면 | Key |
| --- | --- |
| DM | `agent:main:<platform>:dm:<chat_id>` |
| WhatsApp DM | `agent:main:whatsapp:dm:<canonical_identifier>` |
| Group | `agent:main:<platform>:group:<chat_id>:<user_id>` |
| Group thread/topic | `agent:main:<platform>:group:<chat_id>:<thread_id>`이고 Telegram DM topic은 `agent:main:telegram:dm:<chat_id>:<thread_id>`입니다 |
| Channel | `agent:main:<platform>:channel:<chat_id>:<user_id>` |

**사실:** `group_sessions_per_user`는 기본 `true`여서 참가자마다 대화 기록이 분리됩니다. `false`로 두면 방 전체가 하나의 대화를 공유하고, 따라서 token budget, interrupt 상태, 실행 slot도 하나가 됩니다. thread는 상위와 분리되지만 group thread는 `thread_sessions_per_user: true`가 아니면 참가자 모두가 공유합니다. 참가자 ID를 알 수 없으면 platform은 방 하나의 공유 session으로 물러납니다.

**사실 — 시간에 따른 reset 없음:** gateway 대화는 유휴 시간이나 날짜 경계에서 더 이상 reset되지 않습니다. `/new`나 `/reset`이 새 대화를 시작하고, context 압축은 자동으로 계속되며, core는 옛 `session_reset` 설정을 무시합니다. `session_reset.mode`를 `idle`, `daily`, `both`로 둔 설정은 시작할 때와 `hermes doctor`에서 경고를 냅니다. catalog 플러그인 `hermes-session-reset-policy`를 설치하면 시간 기반 reset이 돌아옵니다. `/model` 전환은 그 session에서 gateway 재시작 뒤에도 유지되고(`--global`은 `config.yaml`에 기록, `--once`는 한 turn만), `/sessions [search <query>]`로 이전 session을 찾습니다.

**사실:** `/branch [--here] [name]`(별칭 `/fork`)은 Discord, Telegram, Slack, Matrix에서 새 형제 thread에 분기를 열고 현재 chat은 원래 session에 남습니다. `--here`를 주면 이 chat이 분기로 옮겨 갑니다. thread가 없는 platform은 제자리에서 분기합니다.

## 여러 adapter 운영

**사실:** gateway 하나가 보통 여러 adapter를 함께 돌립니다. 전체를 재시작하지 않고 개별로 멈추고 다시 켭니다.

```
/platform list
/platform pause <name>
/platform resume <name>
```

**사실:** pause된 adapter는 연결과 background loop를 유지하지만 들어오는 message를 버립니다. `/platform list`는 `running`, `paused`, `paused-by-breaker`를 보여 줍니다.

**사실:** adapter마다 circuit breaker가 있고, 재시도 가능한 실패(네트워크 오류, rate limit, 5xx, WebSocket 장애)가 반복되면 열리며 다른 살아 있는 platform의 home channel로 알립니다. **자동으로 풀리지 않으므로** provider가 회복된 뒤 `/platform resume <name>`으로 직접 해제합니다.

**사실:** `gateway_restart_notification`(기본 `true`)은 platform home channel마다 재시작이나 중단 안내를 한 번 보내고, `typing_indicator`(기본 `true`)는 입력 중 표시를 제어합니다. `gateway.trust_env: false`는 주변 proxy를 상속하지 않으면서 platform별 proxy 변수는 그대로 존중합니다.

**사실 — 문서가 밝힌 충돌:** user unit과 system unit을 함께 쓰지 않고, 하나의 Telegram bot token을 여러 gateway에서 공유하지 않으며, email inbox 하나에는 gateway 하나만 붙입니다. multiplex gateway에서는 profile 분리가 예전의 "profile당 프로세스 하나" 규칙을 대신합니다.

## Message 전달

**사실:** 최종 응답은 `state.db`의 내구성 있는 ledger를 거치고 at-least-once로 전달됩니다. 시작조차 하지 않은 전송은 그대로 다시 보내고, gateway가 죽는 순간 전송 중이던 응답은 "Recovered reply" 접두사를 붙여 다시 보냅니다. flood control로 거부된 최종 전송은 기록된 대기 시간이 지난 뒤 재시도 횟수를 쓰지 않고 다시 보내며, 그 밖의 거부는 30초, 2분으로 늘어나는 backoff로 재시도하고 마지막 시도는 다음 시작을 위해 남깁니다. 재전송은 24시간 안에서 3회로 제한되고, 전달된 행은 7일 뒤 정리됩니다. 영구히 닿을 수 없는 chat은 재시도하지 않습니다.

**사실:** `gateway.delivery_ledger: false`는 예전의 유실 가능한 동작으로 되돌립니다. 재시작으로 중단된 session은 다음 답장에서 자동 재개되고 `Scheduled auto-resume for N restart-interrupted session(s)`로 기록됩니다.

**사실:** 최종 응답 전체가 silence token(`[SILENT]`, `SILENT`, `NO_REPLY`, `NO REPLY`와 그 중국어 표기)이면 전달을 생략하고 turn은 대화 기록에 남깁니다. 사람이 보낸 message에 대한 답이면 필요한 응답이 사라지지 않도록 짧은 안내로 바꿔 보냅니다.

## 문제 해결

| 증상 | 조치 |
| --- | --- |
| gateway가 시작하지 않거나 실행 중이 아님 | `hermes gateway status`, service 로그 확인, `hermes gateway setup` 재실행, `hermes doctor` |
| 상태가 degraded 또는 stale | 재시작합니다. event loop watchdog이 종료했거나 housekeeping이 `gateway_state.json` 갱신을 멈춘 상태입니다 |
| gateway는 뜨는데 아무도 message를 못 보냄 | 대개 bot token, allowlist, platform 설정이 덜 끝난 경우입니다 |
| adapter가 조용해짐 | 로그에서 `circuit breaker|paused|disabled`를 찾고 `/platform list`와 provider 상태를 확인한 뒤 `/platform resume <name>` |
| 자격 증명이 맞는데 platform이 꺼져 있음 | `platforms.<name>.enabled: false`가 `.env`보다 우선합니다 |
| 답장이 중복됨 | 전송 중 crash 뒤의 정상적인 at-least-once 동작이거나, 하나의 inbox나 token에 gateway 둘이 붙은 경우입니다 |
| messaging 의존성이 없음 | 문서대로 messaging extra를 설치하고 gateway를 재시작합니다 |

## 보안 경계

**사실:** 들어오는 message는 신뢰하지 않는 데이터입니다. allowlist와 pairing은 **누가** agent를 깨울 수 있는지를 인증하고, webhook HMAC은 **보낸 주체**를 인증할 뿐 내용을 인증하지 않습니다. PR 제목, issue 본문, 전달된 message 같은 상류 텍스트는 공격자가 제어할 수 있고, 문서는 Hermes가 차단 목록으로 신뢰하지 않는 텍스트를 안정적으로 정화할 수 없다고 밝힙니다.

**권고:** 실제 경계는 capability 표면입니다. gateway platform에 노출하는 toolset을 줄이고, approval을 켜 두고, 신뢰하지 않는 작업에는 격리 terminal backend를 쓰고, 운영에는 별도 신원을 쓰며, messaging adapter가 있다는 이유로 headless 자동 승인을 켜지 않습니다.

## 확인 목록

- [ ] adapter를 켜기 전에 model과 tool provider가 동작합니다.
- [ ] 자격 증명은 mode `600`의 `~/.hermes/.env`에 있고 동작 설정은 `config.yaml`에 있습니다.
- [ ] 명시적인 인가 정책이 있습니다. gateway는 기본으로 모두 거부합니다.
- [ ] 하나의 bot token이나 inbox를 두 gateway가 공유하지 않습니다.
- [ ] 무인 운영 전에 service 로그와 gateway 상태를 확인했습니다.
- [ ] 공개 진입점에 맞게 노출 toolset과 approval mode를 의도적으로 골랐습니다.
