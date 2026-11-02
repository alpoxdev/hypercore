# Hermes Agent Discord Setup

> Korean version: [`DISCORD.ko.md`](DISCORD.ko.md)
>
> **Research date:** 2026-11-03, against the documentation shipped with Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`) and Discord's own developer portal. **Facts** trace to Hermes's Discord, Messaging Gateway, Security, and Voice Mode pages. **Recommendations** are this guide's operational advice. Every URL in the source list below was re-read on 2026-11-03 (`checked 2026-11-03`). The live documentation site deploys ahead of the tag: anything observed only on the site is dated with its check date instead of being presented as v0.22.5 behavior, and version-sensitive names should be confirmed with `--help` on the installed CLI.

## Primary sources
- [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord)
- [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging)
- [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security)
- [Use Voice Mode with Hermes](https://hermes-agent.nousresearch.com/docs/guides/use-voice-mode-with-hermes)
- [Discord Developer Portal](https://discord.com/developers/applications)

## Before you start
**Fact:** the bot needs a working model provider first. A Discord adapter with no configured model connects and then fails to answer.

**Fact:** two files control Discord. `~/.hermes/.env` holds credentials and environment toggles; `~/.hermes/config.yaml` holds structured behavior, and an equivalent environment variable always wins over the YAML default. `platforms.discord.enabled: false` is a separate, authoritative switch that keeps the adapter off even with valid credentials. Do not create a `gateway-config.yaml`; the gateway reads `config.yaml`.

## Step 1 — Create the Discord application
Open the [Discord Developer Portal](https://discord.com/developers/applications), create a **New Application**, accept the Developer Terms, and copy the **Application ID** from **General Information** — the manual invite URL needs it.

## Step 2 — Create the bot user
**Fact:** Discord creates the bot user automatically when you open the **Bot** page, and the official guide recommends **Public Bot = ON** and **Require OAuth2 Code Grant = OFF**. If you keep Public Bot **OFF**, the Discord-provided installation link will not work and you must use the manual OAuth2 URL in Step 5.

## Step 3 — Enable privileged gateway intents
**Fact:** this is the most common setup failure. Hermes always requests message content, so with **Message Content Intent** off, Discord **refuses the bot's connection** and the bot never comes online; `gateway.log` shows "Discord rejected the connection because privileged Gateway Intents are not enabled". Without **Server Members Intent**, the bot cannot resolve usernames for allowlists and may not identify who is messaging it.

On the **Bot** page, under **Privileged Gateway Intents**:

| Intent | Purpose | Required |
| --- | --- | --- |
| Presence Intent | See online/offline status | Optional |
| Server Members Intent | Access the member list, resolve usernames | Required |
| Message Content Intent | Read the text content of messages | Required |

Toggle both **Server Members Intent** and **Message Content Intent** on, then select **Save Changes**.

**Fact — a documented nuance.** Hermes always requests Message Content Intent, and requests Server Members **additionally** when the allowlist uses usernames instead of numeric IDs or when `DISCORD_ALLOWED_ROLES` is set; that is why the troubleshooting section lists Server Members as conditional while the setup table marks it required. Presence is never required for text, though the Voice Mode guide recommends all three for voice channels.

**Recommendation:** enable Server Members and Message Content. The nuance matters when auditing scopes later, not during first setup. Below 100 servers intents toggle freely; at 100 or more Discord requires a verification application.

## Step 4 — Get the bot token
1. On the **Bot** page, under **Token**, select **Reset Token**.
2. Enter your 2FA code if your account has two-factor authentication.
3. Copy the token immediately.

**Fact:** the token is displayed **once**. If you lose it you must reset and generate a new one. Anyone holding it has full control of the bot.

**Recommendation:** store it in a password manager, then place it in `~/.hermes/.env` and run `chmod 600 ~/.hermes/.env`. Never commit it.

## Step 5 — Generate the invite URL
### Option A — Installation tab (recommended)
**Installation** → **Installation Contexts: Guild Install** → **Install Link: Discord Provided Link**, then set Default Install Settings:

- **Scopes:** `bot`, `applications.commands`
- **Minimum permissions:** View Channels, Send Messages, Embed Links, Attach Files, Read Message History
- **Recommended additions:** Create Public Threads, Send Messages in Threads, Add Reactions

### Option B — Manual URL
Required when Public Bot is OFF:

```
https://discord.com/oauth2/authorize?client_id=YOUR_APP_ID&scope=bot+applications.commands&permissions=309237763136
```

**Fact — permission integers:**

| Set | Integer | Contents |
| --- | --- | --- |
| Minimal | `117760` | View Channels, Send Messages, Embed Links, Attach Files, Read Message History |
| Recommended | `309237763136` | Minimal plus Create Public Threads, Send Messages in Threads, Add Reactions |
| Full (what `hermes gateway setup` prints) | `309240908864` | Recommended plus Connect and Speak for voice channels |

**Recommendation:** these are not interchangeable descriptions of one permission set. Use `309237763136` for a text bot, and re-invite with `309240908864` only when you add voice channels. Existing installations do not gain newly requested permissions automatically, so an install created before Create Public Threads was recommended needs a re-invite.

## Step 6 — Invite the bot
Choose **Add to Server**, select the server, then **Continue** → **Authorize** → complete the CAPTCHA.

**Fact:** the inviting account needs **Manage Server**, otherwise the server does not appear in the dropdown. The bot stays offline until the Hermes gateway starts — that is expected, not a failure.

## Step 7 — Find your Discord user ID
**Discord Settings** → **Advanced** → enable **Developer Mode**, then right-click your user and choose **Copy User ID**.

## Step 8 — Configure Hermes
### Option A — Interactive (recommended)
```bash
hermes gateway setup
```

Select **Discord**, then paste the bot token and your user ID when prompted.

### Option B — Manual
Add to `~/.hermes/.env`:

```dotenv
DISCORD_BOT_TOKEN=your-bot-token
DISCORD_ALLOWED_USERS=284102345871466496
# Multiple users are comma-separated:
# DISCORD_ALLOWED_USERS=284102345871466496,198765432109876543
```

Then start the gateway:

```bash
hermes gateway
```

The bot should come online within a few seconds. Send it a DM or mention it in a channel to test.

**Fact — how the adapter turns on.** `DISCORD_BOT_TOKEN` in `.env` is what activates the bundled adapter when the gateway starts; `DISCORD_ALLOWED_USERS` governs **authorization**, not activation. The one explicit switch is the generic `platforms.discord.enabled: false` in `config.yaml`, which is authoritative even while the token remains in `.env`. There is no `plugins.discord` key and no `plugins.enabled: [discord]` entry, because the adapter is a bundled platform plugin that auto-loads.

**Fact — what `hermes gateway setup` now does for Discord:** it checks the token with Discord, tells you when **Message Content Intent** is off and links straight to the toggle, prints a ready-made invite link for your server, and allowlists you as the bot's owner, so Developer Mode and a manual user-ID copy are no longer required.

### Run it as a service
```bash
hermes gateway install              # systemd user service (Linux) / launchd agent (macOS)
sudo hermes gateway install --system  # Linux boot-time system service
hermes gateway start | stop | status
```

**Fact:** on Linux, `sudo loginctl enable-linger $USER` keeps a user service alive after logout, and logs are read with `journalctl --user -u hermes-gateway -f`. On macOS the plist is `~/Library/LaunchAgents/ai.hermes.gateway.plist` and logs are at `~/.hermes/logs/gateway.log`; re-run `hermes gateway install` after PATH or tool changes so launchd captures the new PATH. Since v0.22 a single gateway serves every profile, so one service covers all of them.

## Configuration reference
Discord configuration lives in three surfaces. The root `discord:` section mirrors the behavior environment variables, so an equivalent environment variable wins and YAML supplies only the default. Root `discord:` and `gateway.platforms.discord.extra` have disjoint documented key sets, and the docs state no precedence between those two YAML subtrees.

| Surface | Holds |
| --- | --- |
| `~/.hermes/.env` | Credentials and environment toggles (`DISCORD_*`) |
| `~/.hermes/config.yaml`, root `discord:` | Behavior: mentions, threads, reactions, channel filters, backfill, attachments, voice |
| `~/.hermes/config.yaml`, `gateway.platforms.discord.extra` | Slash-command access control and registration ownership |

### Environment variables
| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `DISCORD_BOT_TOKEN` | **Yes** | — | Bot token; also activates the adapter |
| `DISCORD_ALLOWED_USERS` | Conditional | — | Comma-separated user IDs allowed to interact |
| `DISCORD_ALLOWED_ROLES` | No | — | Comma-separated role IDs; OR semantics with allowed users; auto-enables Server Members Intent |
| `DISCORD_ALLOW_ALL_USERS` | No | `false` | Opt-in to allow every reachable Discord user |
| `GATEWAY_ALLOW_ALL_USERS` | No | `false` | Same, across every gateway platform |
| `DISCORD_ALLOWED_CHANNELS` | No | — | Restrict responses to these channel IDs; alone it can explicitly scope guild access and therefore satisfy the Discord access policy |
| `DISCORD_IGNORED_CHANNELS` | No | — | Never respond here; highest priority |
| `DISCORD_REQUIRE_MENTION` | No | `true` | Only respond to `@mention` in server channels |
| `DISCORD_THREAD_REQUIRE_MENTION` | No | `false` | `true` gates threads like channels — use for multi-bot threads |
| `DISCORD_FREE_RESPONSE_CHANNELS` | No | — | Channels that need no mention |
| `DISCORD_IGNORE_NO_MENTION` | No | `true` | Stay silent when others, but not the bot, are mentioned |
| `DISCORD_AUTO_THREAD` | No | `true` | Create a thread per `@mention` in a text channel |
| `DISCORD_FREE_RESPONSE_AUTO_THREAD` | No | `false` | Also thread free-response channels; needs `DISCORD_AUTO_THREAD` |
| `DISCORD_NO_THREAD_CHANNELS` | No | — | Reply inline instead of threading |
| `DISCORD_REACTIONS` | No | `true` | 👀 processing, ✅ success, ❌ error |
| `DISCORD_ALLOW_BOTS` | No | `"none"` | `none`, `mentions`, or `all` |
| `DISCORD_BOTS_REQUIRE_INLINE_MENTION` | No | `true` | A bot handoff needs a literal `<@BOT_ID>`; a reply ping alone does not start one |
| `DISCORD_HISTORY_BACKFILL` | No | `true` | Prepend missed channel scrollback on mention |
| `DISCORD_HISTORY_BACKFILL_LIMIT` | No | `50` | Messages scanned backwards |
| `DISCORD_REPLY_TO_MODE` | No | `"first"` | `off`, `first`, or `all` |
| `DISCORD_COMMAND_SYNC_POLICY` | No | `"safe"` | `safe`, `bulk`, or `off` |
| `DISCORD_HOME_CHANNEL` | No | — | Channel for proactive messages such as cron output |
| `DISCORD_ALLOW_MENTION_EVERYONE` | No | `false` | Bot cannot ping `@everyone`/`@here` |
| `DISCORD_ALLOW_MENTION_ROLES` | No | `false` | Bot cannot ping roles |
| `DISCORD_ALLOW_MENTION_USERS` | No | `true` | Bot may ping individual users |
| `DISCORD_ALLOW_MENTION_REPLIED_USER` | No | `true` | Replying pings the original author |
| `DISCORD_HOME_CHANNEL_NAME` | No | `"Home"` | Display name for the home channel in logs and status |
| `DISCORD_MAX_ATTACHMENT_BYTES` | No | `33554432` | 32 MiB; `0` is unlimited and buffers in memory |
| `DISCORD_PROXY` | No | — | `http://`, `https://`, or `socks5://`; overrides `HTTPS_PROXY` |

### config.yaml
```yaml
discord:
  require_mention: true           # Require @mention in server channels
  thread_require_mention: false   # true for multi-bot threads
  bots_require_inline_mention: true  # bot handoffs need a literal @mention
  free_response_channels: ""      # Comma-separated IDs or a YAML list
  free_response_auto_thread: false   # thread free-response channels too
  auto_thread: true               # Auto-create threads on @mention
  reactions: true
  ignored_channels: []
  no_thread_channels: []
  history_backfill: true
  history_backfill_limit: 50
  missed_message_backfill:        # opt-in replay after a long disconnect
    enabled: false
    window_seconds: 21600
    limit: 100
    max_dispatches: 10
    max_attempts: 3
  channel_prompts:                # Ephemeral per-channel system prompts
    "1234567890": |
      This channel is for research tasks. Prefer citations and concise synthesis.

group_sessions_per_user: true     # Global: isolate each user's transcript
```

**Fact:** `channel_prompts` are injected every turn without being persisted to transcript history; exact thread or channel IDs win, and a thread with no entry falls back to its parent channel ID. Changes take effect on the next turn.

**Fact:** `discord.missed_message_backfill` (disabled by default) recovers messages lost when Discord's WebSocket resume window expires during a restart. `window_seconds` bounds the look-back (default 21600, six hours), `limit` caps the global scan per reconnect, `max_dispatches` caps recovery dispatches, and `max_attempts` caps lifetime re-dispatch per message. Recovered messages pass through the same authorization, mention, and deduplication path as live events, and the ledger lives per profile at `gateway/discord_message_recovery.db`.

## Who is allowed to talk to the bot
**Fact:** access is **fail-closed**. With no policy configured, every inbound user is denied and the log records `No Discord access policy configured; inbound Discord messages will be denied by default.` `DISCORD_ALLOWED_CHANNELS` is itself a policy: it can explicitly scope guild access even when no user/role allowlist is present. DMs still require a user policy, pairing, or explicit allow-all.

**Fact — the documented priority chain:** platform allow-all → approved DM pairing → platform allowlist → global allowlist → global allow-all → default deny.

**Fact:** an unknown DM user receives an 8-character pairing code. The operator approves it with `hermes pairing approve discord <code>`, lists pending codes with `hermes pairing list`, and revokes with `hermes pairing revoke discord <user-id>`. Codes expire after one hour and are rate-limited.

**Fact:** `DISCORD_IGNORED_CHANNELS` takes priority over every other channel setting. `DISCORD_ALLOWED_CHANNELS` restricts guild channels while DMs remain governed by user authorization; as above, the channel list also satisfies the guild-side access-policy requirement.

### Slash-command access control
```yaml
gateway:
  platforms:
    discord:
      extra:
        allow_from:
          - "123456789012345678"
          - "999888777666555444"
        allow_admin_from:            # Admins can run every slash command
          - "123456789012345678"
        user_allowed_commands:       # Non-admins get only these, plus /help and /whoami
          - status
          - model
          - history
        group_allow_admin_from:      # Separate lists for server channels
          - "123456789012345678"
        group_user_allowed_commands:
          - status
```

**Fact:** `/help` and `/whoami` are always allowed. Plain chat is unaffected — a non-admin can still converse. If `allow_admin_from` is unset for a scope, gating is disabled for that scope, so existing installs keep working. **DM admin status does not imply server-channel admin status.** Use `/whoami` to see the active scope and tier.

## Runtime behavior
| Context | Behavior |
| --- | --- |
| DMs | Responds to every message, no mention needed; each DM has its own session — after authorization |
| Server channels | Requires `@mention` by default |
| Threads | After the bot participates, follow-ups need no mention, unless `thread_require_mention` is true |
| Free-response channels | No mention required; replies inline and skips auto-threading |
| Forum channels | Each send creates a separate thread post |

**Fact:** `group_sessions_per_user` defaults to `true`, so two people in one channel hold separate conversations. Setting it to `false` shares one transcript, one token budget, one interrupt state, and one running-agent slot for the whole room.

**Fact — bot-to-bot conversation is unsupported but partially guarded.** `DISCORD_ALLOW_BOTS` exists to accept input from one trusted relay or webhook bot, and since this revision a handoff must carry a literal `<@BOT_ID>` token (`bots_require_inline_mention`, default `true`) because reply metadata alone does not start one. After an admitted mention, brief untagged follow-ups from the same bot in the same channel are batched into that handoff during the continuation window (2 seconds with defaults). A loop guard drops further bot-authored messages in a channel for 10 minutes after 20 arrive within 5 minutes (`gateway.bot_loop_guard`). Keep the default `"none"`; wiring several profiles to converse is still an unsupported topology.

## Slash commands
**Fact:** built-ins that work in a Discord chat include `/new`, `/reset`, `/status`, `/model`, `/personality`, `/retry`, `/undo`, `/stop`, `/whoami`, `/approve`, `/deny`, `/sethome`, `/compress`, `/title`, `/resume`, `/sessions`, `/usage`, `/reasoning`, `/voice`, `/rollback`, `/bg`, `/btw`, `/branch`, `/reload-mcp`, `/platform`, `/commands`, `/insights`, `/update`, and `/help`; `/verbose` works only with `display.tool_progress_command: true`. `/clear` and `/history` are CLI-only commands, so do not expect them in chat.

**Fact:** installed skills register automatically as native application commands on the next gateway restart. **Discord's hard limit is 100 application commands per bot**; excess skills are skipped with a log warning.

**Fact:** `DISCORD_COMMAND_SYNC_POLICY` controls startup sync — `safe` diffs and patches existing global commands (recreating them when Discord metadata cannot be patched), `bulk` restores the older full-sync behavior, and `off` skips sync entirely.

**Fact:** when several gateways share one Discord application, exactly one must own global registration. Followers set `gateway.platforms.discord.extra.slash_commands: false` (default `true`), or the last one to start wins and commands flap.

**Fact:** `/model` with no arguments opens a picker limited to 25 providers and 25 models by Discord's dropdown limits, with a 120-second timeout; only authorized users may interact with it.

## Approvals inside Discord
**Fact:** two distinct flows exist.

- **Dangerous terminal commands.** Hermes posts the command details and waits for a text reply of `yes`, `y`, `approve`, `ok`, or `go` — or `no`, `n`, `deny`, `cancel`. `/approve` and `/deny` also work. The gateway sets `HERMES_EXEC_ASK=1` automatically. `approvals.timeout` (default 300 seconds) **denies on timeout**.
- **Destructive session commands** (`/clear`, `/new`, `/reset`, `/undo`) with `approvals.destructive_slash_confirm` enabled use a native three-option dialog: **Approve Once / Always Approve / Cancel**. Choosing "Always" flips that config to false.

**Fact:** clarify questions also render choice buttons, but those are not dangerous-command approval. The official material disagrees on `agent.clarify_timeout` — 3600 seconds in the settings section, 600 in platform prose — so follow the settings section until upstream reconciles it.

**Fact:** `approvals.mode` values are `smart` (default), `manual`, and `off`; the hardline blocklist survives YOLO and `off`. The dangerous-command guard stack, however, runs only on host-reaching backends (local, SSH, host-mounted Docker), so isolated container backends skip it entirely.

**Recommendation:** the docs do not state which authorized participant may answer another user's pending approval prompt. Until they do, keep `group_sessions_per_user: true` and keep allowlists tight.

## Attachments, voice, and media
**Fact:** outbound media uses `MEDIA:/path` — images preview inline, MP4/MOV get a player, audio becomes a voice message where possible, and documents attach. Discord tier limits apply (25 MB free through 500 MB); an HTTP 413 falls back to a local-cache link.

**Fact:** inbound attachments of **any file type** are accepted; user authorization, not file extension, is the gate. The whole file is cached under `~/.hermes/cache/documents/`: known types keep their MIME, unknown ones fall back to the reported content type or `application/octet-stream`, text-like UTF-8 content is auto-injected up to 100 KiB, and binaries are surfaced as a path. `max_attachment_bytes` (default 32 MiB, `0` unlimited) is the only inbound limit. One unresolved inconsistency remains in the official text: the environment table still describes `DISCORD_ALLOW_ANY_ATTACHMENT` as an opt-in for unknown types, while the receiving section says every type is accepted.

**Fact:** incoming Discord voice messages are transcribed automatically through local `faster-whisper`, Groq (`GROQ_API_KEY`), or OpenAI (`VOICE_TOOLS_OPENAI_KEY`). `/voice on` speaks replies to voice-origin messages; `/voice tts` speaks every reply.

**Fact:** live voice channels use `/voice join`, `/voice leave`, and `/voice status`. Hermes posts transcripts to the text channel where join was issued. This requires ffmpeg and opus, the Connect and Speak Discord permissions, and re-invitation with the voice permission integer. The bot auto-leaves after 300 idle seconds; `voice_channel_inactivity_timeout_seconds: 0` keeps it until an explicit leave.

## Troubleshooting
| Symptom | Cause | Action |
| --- | --- | --- |
| Bot is offline | The gateway is not running — expected before first start | `hermes gateway status`, then `start`; check the gateway log |
| Online but never responds anywhere | Message Content Intent disabled, or no access policy | Enable the intent and save; set an allowlist; restart; grep the log for `No Discord access policy configured` |
| `PrivilegedIntentsRequired` on startup | Required intent is off | Enable Message Content, plus Server Members for username allowlists or roles; restart |
| Responds in DM but not in a channel | `@mention` required by default | Check `DISCORD_REQUIRE_MENTION`, free-response channels, ignored/allowed channels, and channel permissions |
| Slash commands do not appear | Missing scope, stale sync, or a conflict | Ensure `applications.commands` was in the invite; restart after installing skills; check the 100-command warning; confirm sync policy is not `off`; ensure only one gateway owns registration |
| Token rejected | Invalid or revoked token | Reset the token, update `DISCORD_BOT_TOKEN`, restart; failures surface as a fatal `discord_auth_error` |
| Permission errors at runtime | Missing channel permissions | Needs View Channels, Send Messages, Embed Links, Attach Files, Read Message History; threads need Send Messages in Threads; reactions need Add Reactions |
| Adapter went quiet after network trouble | The per-adapter circuit breaker tripped | `/platform list`, grep the log for `circuit breaker|paused|disabled`, check Discord status, then `/platform resume discord` — it does **not** auto-resume |
| Bot appears connected but misses messages | Stale WebSocket while REST still returns 200 | Tune `discord.websocket_liveness_interval_seconds`, `websocket_liveness_failure_threshold`, `websocket_heartbeat_ack_max_age_seconds`, `websocket_max_latency_seconds`, and `websocket_event_max_silence_seconds` (default 14400; a socket can ACK heartbeats while delivering no events) |
| Joins voice but hears nothing | Authorization, mute, intents, or permissions | Verify the user ID is allowed, the user is unmuted, intents are on, and Connect/Speak are granted |
| A new forum channel is not detected | Created after gateway start | Restart the gateway, or run `/channels refresh` |

## Security boundary
**Fact:** every inbound message, attachment, URL, and quoted instruction is untrusted input. Authentication and allowlists verify **who** may trigger the agent; they do not make the **text** trustworthy. Hermes does not — and by its own documentation cannot reliably — sanitize untrusted text with a blocklist.

**Recommendation:** bound the blast radius through authorization, least-capability toolsets, approvals kept on, an isolated terminal backend, credential isolation, and narrow prompting. Treat a Discord gateway as a public entrance to your agent's capabilities.

## Verification checklist
- [ ] Message Content Intent is on; Server Members is on when using role or username allowlists.
- [ ] The token is in `~/.hermes/.env` at mode `600`, and never committed.
- [ ] The invite used scopes `bot` and `applications.commands` with permission integer `309237763136`.
- [ ] At least one access policy is configured — the default denies everyone.
- [ ] YAML lives in `~/.hermes/config.yaml`, and `platforms.discord.enabled` is not left `false`.
- [ ] `DISCORD_ALLOW_BOTS` is `"none"` unless one specific trusted, non-auto-replying bot must be accepted.
- [ ] The approval posture was chosen together with the terminal backend, since isolated backends skip dangerous-command checks.
