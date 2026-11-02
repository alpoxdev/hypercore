# Hermes Agent Discord 설정

> 영어판: [`DISCORD.md`](DISCORD.md)
>
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a` 측정치)에 포함된 문서와 Discord Developer Portal을 근거로 삼았습니다. 아래 **사실**은 Hermes의 Discord, Messaging Gateway, Security, Voice Mode 문서에서 추적할 수 있는 내용이고, **권고**는 이 안내서가 정한 운영 조언입니다. 아래 출처 목록의 URL은 2026-11-03에 모두 다시 읽었습니다(`확인 2026-11-03`). 라이브 문서 사이트는 tag보다 먼저 배포되므로, 사이트에서만 확인한 내용은 v0.22.5 동작으로 적지 않고 확인일과 함께 적었으며, 버전에 민감한 이름은 설치된 CLI의 `--help`로 다시 확인해야 합니다.

## 1차 출처
- [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord)
- [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging)
- [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security)
- [Use Voice Mode with Hermes](https://hermes-agent.nousresearch.com/docs/guides/use-voice-mode-with-hermes)
- [Discord Developer Portal](https://discord.com/developers/applications)

## 시작하기 전에
**사실:** bot을 연결하기 전에 동작하는 model provider가 필요합니다. model이 설정되지 않은 Discord adapter는 연결은 되지만 답하지 못합니다.

**사실:** Discord는 두 파일로 제어합니다. `~/.hermes/.env`는 자격 증명과 환경 토글을, `~/.hermes/config.yaml`은 구조화된 동작을 담으며, 같은 항목을 양쪽에 두면 환경 변수가 YAML 기본값을 이깁니다. `platforms.discord.enabled: false`는 자격 증명이 유효해도 adapter를 꺼 두는 별도의 우선 설정입니다. `gateway-config.yaml`은 만들지 않습니다. gateway는 `config.yaml`을 읽습니다.

## 1단계 — Discord application 만들기
[Discord Developer Portal](https://discord.com/developers/applications)에서 **New Application**을 만들고 Developer Terms에 동의한 뒤 **General Information**의 **Application ID**를 복사합니다. 수동 invite URL에 필요합니다.

## 2단계 — bot user 만들기
**사실:** **Bot** 페이지를 열면 Discord가 bot user를 자동으로 만들고, 공식 안내서는 **Public Bot = ON**, **Require OAuth2 Code Grant = OFF**를 권장합니다. Public Bot을 끄면 Discord가 제공하는 installation link가 동작하지 않으므로 5단계의 수동 OAuth2 URL을 써야 합니다.

## 3단계 — privileged gateway intent 켜기
**사실:** 가장 흔한 설정 실패 지점입니다. Hermes는 항상 message content를 요청하므로 **Message Content Intent**가 꺼져 있으면 Discord가 bot 연결을 **거부**하고 bot은 online 상태가 되지 않습니다. `gateway.log`에는 "Discord rejected the connection because privileged Gateway Intents are not enabled"가 남습니다. **Server Members Intent**가 없으면 allowlist에 쓴 username을 해석하지 못하고 누가 보낸 message인지 식별하지 못할 수 있습니다.

**Bot** 페이지의 **Privileged Gateway Intents**에서 다음을 설정합니다.

| Intent | 목적 | 필요 여부 |
| --- | --- | --- |
| Presence Intent | online/offline 상태 확인 | 선택 |
| Server Members Intent | member list 접근, username 해석 | 필요 |
| Message Content Intent | message 본문 읽기 | 필요 |

**Server Members Intent**와 **Message Content Intent**를 모두 켜고 **Save Changes**를 누릅니다.

**사실 — 문서에 적힌 차이:** Hermes는 항상 Message Content Intent를 요청하고, allowlist가 숫자 ID 대신 username을 쓰거나 `DISCORD_ALLOWED_ROLES`가 설정된 경우에만 Server Members를 **추가로** 요청합니다. 그래서 troubleshooting은 Server Members를 조건부로 적고 setup 표는 필요로 표시합니다. text 용도에는 Presence가 필요 없지만, Voice Mode 문서는 voice channel을 위해 세 intent를 모두 권장합니다.

**권고:** Server Members와 Message Content를 켜 둡니다. 이 차이는 처음 설정할 때보다 나중에 scope를 감사할 때 중요합니다. server가 100개 미만이면 intent를 자유롭게 바꿀 수 있고, 100개 이상이면 Discord가 privileged intent 사용을 위한 verification 신청을 요구합니다.

## 4단계 — bot token 받기
1. **Bot** 페이지의 **Token**에서 **Reset Token**을 선택합니다.
2. 계정에 2단계 인증이 켜져 있으면 2FA code를 입력합니다.
3. token을 곧바로 복사합니다.

**사실:** token은 **한 번만** 표시됩니다. 잃어버리면 reset해서 새로 만들어야 합니다. token을 가진 사람은 bot을 완전히 제어할 수 있습니다.

**권고:** 비밀번호 관리자에 보관하고, `~/.hermes/.env`에 넣은 뒤 `chmod 600 ~/.hermes/.env`를 실행합니다. 절대 commit하지 않습니다.

## 5단계 — invite URL 만들기
### 방법 A — Installation tab(권장)
**Installation** → **Installation Contexts: Guild Install** → **Install Link: Discord Provided Link**를 고르고 Default Install Settings를 설정합니다.

- **Scopes:** `bot`, `applications.commands`
- **최소 권한:** View Channels, Send Messages, Embed Links, Attach Files, Read Message History
- **권장 추가:** Create Public Threads, Send Messages in Threads, Add Reactions

### 방법 B — 수동 URL
Public Bot이 꺼져 있을 때 필요합니다.

```
https://discord.com/oauth2/authorize?client_id=YOUR_APP_ID&scope=bot+applications.commands&permissions=309237763136
```

**사실 — 권한 정수:**

| 구분 | 정수 | 포함 내용 |
| --- | --- | --- |
| 최소 | `117760` | View Channels, Send Messages, Embed Links, Attach Files, Read Message History |
| 권장 | `309237763136` | 최소 권한에 Create Public Threads, Send Messages in Threads, Add Reactions 추가 |
| 전체(`hermes gateway setup`이 출력하는 값) | `309240908864` | 권장 권한에 voice channel용 Connect와 Speak 추가 |

**권고:** 이 값들은 같은 권한 집합을 다르게 부른 것이 아닙니다. text bot에는 `309237763136`을 쓰고, voice channel을 실제로 추가할 때만 `309240908864`로 다시 초대합니다. 기존 설치는 나중에 요청된 권한을 자동으로 얻지 못하므로, Create Public Threads가 권장되기 전에 만든 설치는 다시 초대해야 합니다.

## 6단계 — bot 초대
**Add to Server**를 골라 server를 선택하고 **Continue** → **Authorize** → CAPTCHA를 마칩니다.

**사실:** 초대하는 계정에 **Manage Server** 권한이 있어야 합니다. 없으면 목록에 server가 나타나지 않습니다. Hermes gateway를 시작하기 전까지 bot은 offline으로 보이며, 이는 정상입니다.

## 7단계 — Discord user ID 찾기
**Discord Settings** → **Advanced**에서 **Developer Mode**를 켜고, 내 사용자를 오른쪽 클릭해 **Copy User ID**를 선택합니다.

## 8단계 — Hermes 설정
### 방법 A — 대화형(권장)
```bash
hermes gateway setup
```

**Discord**를 고르고 안내에 따라 bot token과 user ID를 넣습니다.

### 방법 B — 수동
`~/.hermes/.env`에 다음을 추가합니다.

```dotenv
DISCORD_BOT_TOKEN=your-bot-token
DISCORD_ALLOWED_USERS=284102345871466496
# 여러 사용자는 쉼표로 구분합니다.
# DISCORD_ALLOWED_USERS=284102345871466496,198765432109876543
```

그다음 gateway를 시작합니다.

```bash
hermes gateway
```

bot은 몇 초 안에 online이 됩니다. DM을 보내거나 channel에서 멘션해 시험합니다.

**사실 — adapter가 켜지는 방식:** gateway가 시작할 때 `.env`의 `DISCORD_BOT_TOKEN`이 bundled adapter를 활성화하고, `DISCORD_ALLOWED_USERS`는 활성화가 아니라 **인가**를 담당합니다. 명시적인 스위치는 `config.yaml`의 `platforms.discord.enabled: false` 하나이며, token이 `.env`에 남아 있어도 이 값이 우선합니다. adapter는 자동 load되는 bundled platform 플러그인이므로 `plugins.discord` 키나 `plugins.enabled: [discord]` 항목은 없습니다.

**사실 — 지금 `hermes gateway setup`이 Discord에서 하는 일:** token을 Discord에 확인하고, **Message Content Intent**가 꺼져 있으면 토글 링크와 함께 알려 주며, 해당 server용 invite link를 만들어 보여 주고, 운영자를 bot 소유자로 allowlist에 넣습니다. Developer Mode로 user ID를 직접 복사할 필요가 없습니다.

### 서비스로 실행
```bash
hermes gateway install              # Linux systemd user service / macOS launchd agent
sudo hermes gateway install --system  # Linux 부팅 시점 system service
hermes gateway start | stop | status
```

**사실:** Linux에서는 `sudo loginctl enable-linger $USER`를 주면 로그아웃 뒤에도 user service가 살아 있고, 로그는 `journalctl --user -u hermes-gateway -f`로 봅니다. macOS의 plist는 `~/Library/LaunchAgents/ai.hermes.gateway.plist`이고 로그는 `~/.hermes/logs/gateway.log`이며, PATH나 도구가 바뀌면 `hermes gateway install`을 다시 실행해 launchd가 새 PATH를 잡게 합니다. v0.22부터 gateway 하나가 모든 profile을 맡으므로 service 하나로 전체가 해결됩니다.

## 설정 참조
Discord 설정은 세 표면에 나뉩니다. root `discord:`는 동작 환경 변수를 그대로 비추므로 동등한 환경 변수가 있으면 그 값이 이기고 YAML은 기본값만 제공합니다. root `discord:`와 `gateway.platforms.discord.extra`는 문서화된 키 집합이 겹치지 않으며, 두 YAML 하위 트리 사이의 우선순위는 문서에 없습니다.

| 표면 | 담는 내용 |
| --- | --- |
| `~/.hermes/.env` | 자격 증명과 환경 토글(`DISCORD_*`) |
| `~/.hermes/config.yaml`의 root `discord:` | 멘션, thread, reaction, channel 필터, backfill, 첨부, voice 동작 |
| `~/.hermes/config.yaml`의 `gateway.platforms.discord.extra` | slash command 접근 제어와 등록 소유권 |

### 환경 변수
| 변수 | 필요 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `DISCORD_BOT_TOKEN` | **예** | — | bot token이며 adapter를 활성화합니다 |
| `DISCORD_ALLOWED_USERS` | 조건부 | — | 상호작용을 허용할 user ID 목록(쉼표 구분) |
| `DISCORD_ALLOWED_ROLES` | 아니오 | — | role ID 목록(쉼표 구분). 허용 user와 OR로 동작하고 Server Members Intent를 자동 활성화합니다 |
| `DISCORD_ALLOW_ALL_USERS` | 아니오 | `false` | 접근 가능한 모든 Discord user를 허용합니다 |
| `GATEWAY_ALLOW_ALL_USERS` | 아니오 | `false` | 모든 gateway platform에 같은 설정을 적용합니다 |
| `DISCORD_ALLOWED_CHANNELS` | 아니오 | — | 응답할 channel ID를 제한합니다. 단독으로도 guild 접근 범위를 정해 Discord 접근 정책을 충족합니다 |
| `DISCORD_IGNORED_CHANNELS` | 아니오 | — | 여기서는 절대 응답하지 않습니다. 우선순위가 가장 높습니다 |
| `DISCORD_REQUIRE_MENTION` | 아니오 | `true` | server channel에서 `@mention`에만 응답합니다 |
| `DISCORD_THREAD_REQUIRE_MENTION` | 아니오 | `false` | `true`이면 thread도 channel처럼 멘션을 요구합니다. multi-bot thread에 씁니다 |
| `DISCORD_FREE_RESPONSE_CHANNELS` | 아니오 | — | 멘션이 필요 없는 channel 목록 |
| `DISCORD_IGNORE_NO_MENTION` | 아니오 | `true` | 봇이 아닌 다른 사람만 멘션된 message에는 침묵합니다 |
| `DISCORD_AUTO_THREAD` | 아니오 | `true` | text channel의 `@mention`마다 thread를 만듭니다 |
| `DISCORD_FREE_RESPONSE_AUTO_THREAD` | 아니오 | `false` | free-response channel도 thread로 나눕니다. `DISCORD_AUTO_THREAD`가 필요합니다 |
| `DISCORD_NO_THREAD_CHANNELS` | 아니오 | — | thread 대신 channel에 바로 답합니다 |
| `DISCORD_REACTIONS` | 아니오 | `true` | 👀 처리 중, ✅ 성공, ❌ 오류 |
| `DISCORD_ALLOW_BOTS` | 아니오 | `"none"` | `none`, `mentions`, `all` |
| `DISCORD_BOTS_REQUIRE_INLINE_MENTION` | 아니오 | `true` | bot handoff에는 `<@BOT_ID>` 문자열이 필요합니다. reply ping만으로는 시작하지 않습니다 |
| `DISCORD_HISTORY_BACKFILL` | 아니오 | `true` | 멘션 시 놓친 channel 대화를 앞에 붙입니다 |
| `DISCORD_HISTORY_BACKFILL_LIMIT` | 아니오 | `50` | 거슬러 읽을 message 수 |
| `DISCORD_REPLY_TO_MODE` | 아니오 | `"first"` | `off`, `first`, `all` |
| `DISCORD_COMMAND_SYNC_POLICY` | 아니오 | `"safe"` | `safe`, `bulk`, `off` |
| `DISCORD_HOME_CHANNEL` | 아니오 | — | cron 출력 같은 능동 message를 보낼 channel |
| `DISCORD_ALLOW_MENTION_EVERYONE` | 아니오 | `false` | 봇이 `@everyone`/`@here`를 호출할 수 없습니다 |
| `DISCORD_ALLOW_MENTION_ROLES` | 아니오 | `false` | 봇이 role을 호출할 수 없습니다 |
| `DISCORD_ALLOW_MENTION_USERS` | 아니오 | `true` | 봇이 개별 user를 호출할 수 있습니다 |
| `DISCORD_ALLOW_MENTION_REPLIED_USER` | 아니오 | `true` | 답장할 때 원래 작성자를 호출합니다 |
| `DISCORD_HOME_CHANNEL_NAME` | 아니오 | `"Home"` | 로그와 상태 표시에 쓰는 home channel 이름 |
| `DISCORD_MAX_ATTACHMENT_BYTES` | 아니오 | `33554432` | 32 MiB이며 `0`은 무제한이고 memory에 buffering합니다 |
| `DISCORD_PROXY` | 아니오 | — | `http://`, `https://`, `socks5://`이며 `HTTPS_PROXY`보다 우선합니다 |

### config.yaml
```yaml
discord:
  require_mention: true           # server channel에서 @mention 요구
  thread_require_mention: false   # multi-bot thread이면 true
  bots_require_inline_mention: true  # bot handoff에 실제 @mention 필요
  free_response_channels: ""      # 쉼표 구분 ID 또는 YAML 목록
  free_response_auto_thread: false   # free-response channel도 thread로 분리
  auto_thread: true               # @mention마다 thread 생성
  reactions: true
  ignored_channels: []
  no_thread_channels: []
  history_backfill: true
  history_backfill_limit: 50
  missed_message_backfill:        # 긴 연결 끊김 뒤 선택적 재생
    enabled: false
    window_seconds: 21600
    limit: 100
    max_dispatches: 10
    max_attempts: 3
  channel_prompts:                # channel별 임시 system prompt
    "1234567890": |
      This channel is for research tasks. Prefer citations and concise synthesis.

group_sessions_per_user: true     # 전역: 사용자별 대화 기록 분리
```

**사실:** `channel_prompts`는 대화 기록에 저장하지 않고 매 turn 주입합니다. 정확한 thread나 channel ID가 우선하고, 항목이 없는 thread는 상위 channel ID로 물러납니다. 변경은 다음 turn부터 적용됩니다.

**사실:** `discord.missed_message_backfill`은 기본적으로 꺼져 있고, 재시작 중 Discord의 WebSocket resume 창이 만료되어 잃은 message를 복구합니다. `window_seconds`는 되돌아볼 범위(기본 21600초, 6시간)이고, `limit`은 재연결마다 전체 검색 상한, `max_dispatches`는 복구 dispatch 상한, `max_attempts`는 message당 평생 재dispatch 상한입니다. 복구된 message는 live event와 같은 인가, 멘션, 중복 제거 경로를 지나며, ledger는 profile별 `gateway/discord_message_recovery.db`에 있습니다.

## bot과 대화할 수 있는 사람
**사실:** 접근은 **fail-closed**입니다. 정책을 하나도 설정하지 않으면 모든 inbound user가 거부되고 로그에 `No Discord access policy configured; inbound Discord messages will be denied by default.`가 남습니다. `DISCORD_ALLOWED_CHANNELS` 자체가 정책입니다. user나 role allowlist가 없어도 guild 접근 범위를 명시적으로 정할 수 있습니다. DM은 여전히 user 정책, pairing, 명시적 allow-all 중 하나가 필요합니다.

**사실 — 문서화된 우선순위:** platform allow-all → 승인된 DM pairing → platform allowlist → 전역 allowlist → 전역 allow-all → 기본 거부.

**사실:** 모르는 DM 사용자는 8자 pairing code를 받습니다. 운영자는 `hermes pairing approve discord <code>`로 승인하고, `hermes pairing list`로 대기 code를 확인하며, `hermes pairing revoke discord <user-id>`로 철회합니다. code는 1시간 뒤 만료되고 요청 빈도가 제한됩니다.

**사실:** `DISCORD_IGNORED_CHANNELS`는 다른 모든 channel 설정보다 우선합니다. `DISCORD_ALLOWED_CHANNELS`는 guild channel을 제한하고 DM은 user 인가를 따르며, 위에서 적은 대로 channel 목록 자체가 guild 쪽 접근 정책 요건을 충족합니다.

### slash command 접근 제어
```yaml
gateway:
  platforms:
    discord:
      extra:
        allow_from:
          - "123456789012345678"
          - "999888777666555444"
        allow_admin_from:            # admin은 모든 slash command 실행
          - "123456789012345678"
        user_allowed_commands:       # 비admin은 이 목록과 /help, /whoami만
          - status
          - model
          - history
        group_allow_admin_from:      # server channel용 별도 목록
          - "123456789012345678"
        group_user_allowed_commands:
          - status
```

**사실:** `/help`와 `/whoami`는 항상 허용됩니다. 일반 대화는 영향을 받지 않으므로 비admin도 계속 대화할 수 있습니다. 어떤 scope에 `allow_admin_from`이 없으면 그 scope의 gating은 꺼진 상태이므로 기존 설치가 그대로 동작합니다. **DM admin이 server channel admin을 뜻하지는 않습니다.** 현재 scope와 등급은 `/whoami`로 확인합니다.

## 실행 동작
| 상황 | 동작 |
| --- | --- |
| DM | 인가를 통과하면 멘션 없이 모든 message에 답하고, DM마다 session이 따로 있습니다 |
| server channel | 기본으로 `@mention`이 필요합니다 |
| thread | bot이 참여한 뒤에는 `thread_require_mention`이 `true`가 아니면 멘션이 필요 없습니다 |
| free-response channel | 멘션이 필요 없고, thread를 만들지 않고 바로 답합니다 |
| forum channel | 전송할 때마다 별도 thread post를 만듭니다 |

**사실:** `group_sessions_per_user`는 기본 `true`여서 같은 channel의 두 사람이 각자의 대화를 유지합니다. `false`로 두면 방 전체가 하나의 대화 기록, token budget, interrupt 상태, 실행 slot을 공유합니다.

**사실 — bot끼리 대화는 지원하지 않지만 일부는 막혀 있습니다.** `DISCORD_ALLOW_BOTS`는 신뢰하는 relay나 webhook bot 하나의 입력을 받기 위한 설정이고, 이 리비전부터 handoff에는 `<@BOT_ID>` 문자열이 있어야 합니다(`bots_require_inline_mention`, 기본 `true`). reply metadata만으로는 시작하지 않습니다. 승인된 멘션 뒤에는 같은 bot이 같은 channel에서 보내는 짧은 무멘션 후속 message가 계속 창(기본 2초) 동안 그 handoff에 묶여 처리됩니다. loop guard는 5분 안에 bot 작성 message가 20개 쌓이면 그 channel의 추가 bot message를 10분 동안 버립니다(`gateway.bot_loop_guard`). 기본값 `"none"`을 유지합니다. 여러 profile이 서로 대화하게 배선하는 구성은 여전히 지원하지 않습니다.

## slash command
**사실:** Discord chat에서 동작하는 내장 명령은 `/new`, `/reset`, `/status`, `/model`, `/personality`, `/retry`, `/undo`, `/stop`, `/whoami`, `/approve`, `/deny`, `/sethome`, `/compress`, `/title`, `/resume`, `/sessions`, `/usage`, `/reasoning`, `/voice`, `/rollback`, `/bg`, `/btw`, `/branch`, `/reload-mcp`, `/platform`, `/commands`, `/insights`, `/update`, `/help`입니다. `/verbose`는 `display.tool_progress_command: true`일 때만 동작합니다. `/clear`와 `/history`는 CLI 전용이므로 chat에서 기대하지 않습니다.

**사실:** 설치한 skill은 다음 gateway 재시작 때 native application command로 자동 등록됩니다. **Discord는 bot당 application command를 100개로 제한**하고, 넘치는 skill은 로그 경고와 함께 건너뜁니다.

**사실:** `DISCORD_COMMAND_SYNC_POLICY`는 시작 시 sync를 제어합니다. `safe`는 기존 전역 command를 비교해 바뀐 것만 patch하고 Discord metadata를 patch로 바꿀 수 없으면 다시 만듭니다. `bulk`는 이전의 전체 sync 동작이고, `off`는 sync를 하지 않습니다.

**사실:** 여러 gateway가 하나의 Discord application을 공유하면 전역 등록은 정확히 하나만 맡아야 합니다. 나머지는 `gateway.platforms.discord.extra.slash_commands: false`(기본 `true`)를 설정합니다. 그렇지 않으면 마지막에 시작한 쪽이 이겨 command가 계속 바뀝니다.

**사실:** 인자 없이 `/model`을 보내면 Discord dropdown 한도에 맞춰 provider 25개, model 25개까지 보여 주는 picker가 열리고 120초 뒤 timeout됩니다. 인가된 사용자만 조작할 수 있습니다.

## Discord 안에서의 approval
**사실:** 흐름이 두 가지입니다.

- **위험한 terminal 명령.** Hermes가 명령 내용을 올리고 `yes`, `y`, `approve`, `ok`, `go` 또는 `no`, `n`, `deny`, `cancel` 답장을 기다립니다. `/approve`와 `/deny`도 동작합니다. gateway가 `HERMES_EXEC_ASK=1`을 자동으로 설정하고, `approvals.timeout`(기본 300초)이 지나면 **거부**합니다.
- **파괴적 session 명령**(`/clear`, `/new`, `/reset`, `/undo`)에 `approvals.destructive_slash_confirm`이 켜져 있으면 **Approve Once / Always Approve / Cancel** 세 선택지 dialog가 뜹니다. "Always"를 고르면 해당 설정이 false로 바뀝니다.

**사실:** clarify 질문도 선택지 버튼을 그리지만 위험 명령 approval과는 다릅니다. `agent.clarify_timeout`은 공식 문서에서 설정 절이 3600초, platform 설명이 600초로 엇갈리므로, 문서가 정리될 때까지 설정 절 값을 따릅니다.

**사실:** `approvals.mode` 값은 `smart`(기본), `manual`, `off`이고 hardline 차단 목록은 YOLO와 `off`에서도 유지됩니다. 다만 위험 명령 guard stack은 host에 닿는 backend(local, SSH, host-mounted Docker)에서만 돌기 때문에 격리 container backend는 이 검사를 완전히 건너뜁니다.

**권고:** 다른 사용자가 대기 중인 approval에 답할 수 있는지는 문서에 없습니다. 그 내용이 문서화되기 전까지 `group_sessions_per_user: true`를 유지하고 allowlist를 좁게 관리합니다.

## 첨부, voice, media
**사실:** 나가는 media는 `MEDIA:/path`를 씁니다. 이미지는 본문에 미리 보기로, MP4/MOV는 player로, audio는 가능하면 voice message로, 문서는 첨부로 전달됩니다. Discord 등급별 한도(무료 25 MB에서 최대 500 MB)가 적용되고, HTTP 413이 오면 local cache 링크로 대체합니다.

**사실:** 들어오는 첨부는 **파일 형식과 무관하게** 받습니다. 접근을 가르는 기준은 파일 확장자가 아니라 사용자 인가입니다. 파일은 `~/.hermes/cache/documents/`에 통째로 저장되고, 알려진 형식은 MIME을 유지하며, 모르는 형식은 보고된 content type이나 `application/octet-stream`으로 처리합니다. UTF-8로 읽히는 text 성격 내용은 최대 100 KiB까지 prompt에 주입하고, binary는 경로로 알려 줍니다. 들어오는 쪽 유일한 한도는 `max_attachment_bytes`(기본 32 MiB, `0`은 무제한)입니다. 공식 문서에는 아직 정리되지 않은 불일치가 하나 있습니다. 환경 변수 표는 `DISCORD_ALLOW_ANY_ATTACHMENT`를 모르는 형식에 대한 opt-in으로 적지만, 수신 절은 모든 형식을 받는다고 적습니다.

**사실:** 들어오는 Discord voice message는 local `faster-whisper`, Groq(`GROQ_API_KEY`), OpenAI(`VOICE_TOOLS_OPENAI_KEY`)로 자동 전사합니다. `/voice on`은 voice로 온 message에 답할 때 음성으로 말하고, `/voice tts`는 모든 답을 음성으로 보냅니다.

**사실:** live voice channel은 `/voice join`, `/voice leave`, `/voice status`로 다룹니다. Hermes는 전사 내용을 join을 요청한 text channel에 올립니다. ffmpeg와 opus, Discord의 Connect와 Speak 권한, voice 권한 정수가 포함된 재초대가 필요합니다. bot은 300초 유휴 뒤 스스로 나가며, `voice_channel_inactivity_timeout_seconds: 0`이면 명시적으로 나갈 때까지 남습니다.

## 문제 해결
| 증상 | 원인 | 조치 |
| --- | --- | --- |
| bot이 offline | gateway가 실행 중이 아님. 첫 시작 전에는 정상 | `hermes gateway status`로 확인하고 `start`, gateway log 확인 |
| online인데 어디서도 응답 없음 | Message Content Intent가 꺼졌거나 접근 정책이 없음 | intent를 켜고 저장, allowlist 설정, 재시작, log에서 `No Discord access policy configured` 검색 |
| 시작 시 `PrivilegedIntentsRequired` | 필요한 intent가 꺼져 있음 | Message Content를 켜고, username allowlist나 role을 쓰면 Server Members도 켠 뒤 재시작 |
| DM에서는 답하지만 channel에서는 답 없음 | 기본으로 `@mention`이 필요 | `DISCORD_REQUIRE_MENTION`, free-response channel, ignored/allowed channel, channel 권한 확인 |
| slash command가 보이지 않음 | scope 누락, 오래된 sync, 충돌 | invite에 `applications.commands`가 있었는지 확인, skill 설치 뒤 재시작, 100개 경고 확인, sync policy가 `off`가 아닌지 확인, 등록을 맡은 gateway가 하나인지 확인 |
| token 거부 | 유효하지 않거나 폐기된 token | token을 reset하고 `DISCORD_BOT_TOKEN` 갱신 후 재시작. 실패는 `discord_auth_error`로 나타남 |
| 실행 중 권한 오류 | channel 권한 부족 | View Channels, Send Messages, Embed Links, Attach Files, Read Message History가 필요하고, thread에는 Send Messages in Threads, reaction에는 Add Reactions가 필요 |
| 네트워크 장애 뒤 adapter가 조용해짐 | adapter별 circuit breaker가 열림 | `/platform list`, log에서 `circuit breaker|paused|disabled` 검색, Discord 상태 확인 후 `/platform resume discord`. **자동으로 풀리지 않음** |
| 연결된 것 같은데 message를 놓침 | REST는 200인데 WebSocket이 오래됨 | `discord.websocket_liveness_interval_seconds`, `websocket_liveness_failure_threshold`, `websocket_heartbeat_ack_max_age_seconds`, `websocket_max_latency_seconds`, `websocket_event_max_silence_seconds`(기본 14400. heartbeat는 ACK하면서 event를 하나도 전달하지 않는 상태가 가능) 조정 |
| voice에 들어갔는데 들리지 않음 | 인가, mute, intent, 권한 중 하나 | user ID가 허용됐는지, 음소거가 풀렸는지, intent가 켜졌는지, Connect/Speak가 있는지 확인 |
| 새 forum channel을 인식하지 못함 | gateway 시작 뒤에 만들어짐 | gateway를 재시작하거나 `/channels refresh` 실행 |

## 보안 경계
**사실:** 들어오는 모든 message, 첨부, URL, 인용된 지시는 신뢰하지 않는 입력입니다. 인증과 allowlist는 **누가** agent를 깨울 수 있는지를 확인할 뿐 **문장**을 신뢰할 수 있게 만들지 않습니다. Hermes는 차단 목록으로 신뢰하지 않는 텍스트를 안정적으로 정화하지 못하며, 문서도 그렇게 밝힙니다.

**권고:** 인가, 최소 capability toolset, approval 유지, 격리 terminal backend, 자격 증명 분리, 좁은 prompt로 피해 범위를 줄입니다. Discord gateway는 agent capability로 들어오는 공개 입구로 다룹니다.

## 확인 목록
- [ ] Message Content Intent가 켜져 있고, role이나 username allowlist를 쓰면 Server Members도 켜져 있습니다.
- [ ] token은 mode `600`의 `~/.hermes/.env`에 있고 commit되지 않았습니다.
- [ ] invite가 `bot`, `applications.commands` scope와 권한 정수 `309237763136`을 사용했습니다.
- [ ] 접근 정책이 최소 하나 설정되어 있습니다. 기본값은 모두 거부입니다.
- [ ] YAML은 `~/.hermes/config.yaml`에 있고 `platforms.discord.enabled`가 `false`로 남아 있지 않습니다.
- [ ] 특정한 신뢰 relay가 필요하지 않다면 `DISCORD_ALLOW_BOTS`는 `"none"`입니다.
- [ ] 격리 backend가 위험 명령 검사를 건너뛰므로 approval 태도는 terminal backend와 함께 정했습니다.
