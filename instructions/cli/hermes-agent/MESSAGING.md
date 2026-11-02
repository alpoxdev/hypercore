# Hermes Agent Messaging Gateway

> Korean version: [`MESSAGING.ko.md`](MESSAGING.ko.md)
>
> **Research date:** 2026-11-03, against the documentation shipped with Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`) plus the v0.22.0 release notes. **Facts** trace to Hermes's Messaging Gateway, Security, multiplexing, and per-platform pages. **Recommendations** are this guide's operating advice. For the Discord walkthrough see [`DISCORD.md`](DISCORD.md); for configuration files see [`CONFIGURATION.md`](CONFIGURATION.md). 2026 deltas are listed in [references/hermes-agent-2026-changes.md](references/hermes-agent-2026-changes.md). The live documentation site deploys ahead of the tag: anything observed only on the site is dated with its check date instead of being presented as v0.22.5 behavior, and version-sensitive names should be confirmed with `--help` on the installed CLI.

| Source | Supplies | Checked |
| --- | --- | --- |
| [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging) | Process model, commands, sessions, delivery, platform table | 2026-11-03 |
| [Gateway source at v0.22.5](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/user-guide/messaging/index.md) | Exact defaults quoted below | 2026-11-03 |
| [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway) | One process for every profile | 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | Authorization chain, pairing, DM handling | 2026-11-03 |
| [Slash commands reference](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) | Gateway command behavior | 2026-11-03 |
| [v0.22.0 release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | Multiplex migration, retired session reset | 2026-11-03 |

## The gateway process model

**Fact:** the gateway is one background process per machine that connects every configured platform, routes each message into a per-chat session store, and runs the cron scheduler (a 60-second tick). Because cron lives in the gateway, a scheduled job simply does not fire while the gateway is down.

**Fact:** since v0.22.0 one gateway serves **every profile by default** (`gateway.multiplex_profiles`, default `true`). Each served profile keeps its own credentials, allowlists, sessions, cron jobs, and hooks; the process shares one event loop, one HTTP listener, and one status surface. `hermes update` folds per-profile gateways into the default one when nothing conflicts, `hermes gateway migrate --multiplex` does it by hand, webhook platforms serve each profile at `/p/<profile>/`, and `hermes -p <name> gateway stop|start` parks a single profile. `gateway.standalone: true` is a temporary opt-out.

```bash
hermes gateway                         # Foreground
hermes gateway setup                   # Interactive platform wizard
hermes gateway install                 # systemd user service (Linux) / launchd agent (macOS)
sudo hermes gateway install --system   # Linux boot-time system service
hermes gateway start | stop | restart | status
hermes gateway status --system         # Linux system service
```

### Service operation and health

| Platform | Log | Notes |
| --- | --- | --- |
| Linux, user service | `journalctl --user -u hermes-gateway -f` | `sudo loginctl enable-linger $USER` keeps it alive after logout |
| Linux, system service | `journalctl -u hermes-gateway -f` | |
| macOS | `tail -f ~/.hermes/logs/gateway.log` | Plist at `~/Library/LaunchAgents/ai.hermes.gateway.plist` |

**Fact:** the docs warn against an `ExecStopPost` kill drop-in (restart loops) and against keeping user and system units installed together. Re-run `hermes gateway install` on macOS after PATH or tool changes so launchd captures the new PATH. `gateway.systemd_watchdog_seconds: 120` plus `hermes gateway install --force` opts a Linux service into `Type=notify` watchdog recovery; `0` keeps `Type=simple`.

**Fact:** two independent health signals exist. An out-of-loop watchdog probes the event loop (`gateway.loop_watchdog_probe_interval_s`, default 30 s) and, after `gateway.loop_watchdog_max_strikes` consecutive misses (default 3), dumps thread stacks, writes `gateway_state: degraded`, and exits with code 75 for the supervisor to restart. Housekeeping re-stamps `gateway_state.json` every 60 s, so a stamp older than 120 s makes `hermes gateway status` report a stale heartbeat. `kill -USR2 <pid>` dumps stacks without restarting.

## The common setup sequence

1. Confirm a working model and tool provider — a bot with no model connects and then fails.
2. Put platform credentials in `~/.hermes/.env`; put structured behavior in `~/.hermes/config.yaml`.
3. Configure the adapter through `hermes gateway setup`, or with the documented environment fields.
4. Start it: `hermes gateway install` and `hermes gateway start`, or `hermes gateway` in the foreground.
5. Establish authorization — allowlist, approved DM pairing, or explicit allow-all — and finish any link, invite, or QR step.
6. Verify with `hermes gateway status` and a real message.

**Fact:** `platforms.<name>.enabled: false` in `config.yaml` is authoritative even when credentials remain in `.env`; omitting the key keeps the credentials-present behavior. Earlier releases let credentials re-enable twelve platforms regardless of that key, and the gateway now logs one warning per affected platform instead of starting it.

## Supported platforms

**Fact:** the comparison table names Telegram, Discord, Slack, Google Chat, WhatsApp, WhatsApp Cloud API, Signal, SMS, Email, Home Assistant, Mattermost, Matrix, DingTalk, Feishu/Lark, WeCom, WeCom Callback, Weixin, BlueBubbles (iMessage), Photon (iMessage), QQ, Yuanbao, Microsoft Teams, LINE, ntfy, Raft, IRC, Buzz, and SimpleX, plus the browser. Dedicated pages also cover A2A, Microsoft Graph webhooks, Open WebUI, and Teams meetings.

**Fact:** Hermes Relay is **not** a chat platform. It fronts external connectors and negotiates capabilities per connector at handshake.

## Adapter differences

Discord is documented separately in [`DISCORD.md`](DISCORD.md). The five below show how much the structural model varies.

### Telegram

Credentials: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_ALLOWED_USERS`. Created through BotFather.

**Fact:** the default transport is outbound long polling. Webhook mode requires `TELEGRAM_WEBHOOK_URL` and a **mandatory** `TELEGRAM_WEBHOOK_SECRET`, with optional `TELEGRAM_WEBHOOK_PORT` (default 8443), and is aimed at hosts that sleep when idle. For group visibility, BotFather privacy mode must be off or the bot must be a group admin. **Never reuse one bot token across running gateways** — concurrent polling is rejected.

### Slack

Credentials: `SLACK_BOT_TOKEN` (`xoxb-`), `SLACK_APP_TOKEN` (`xapp-`), `SLACK_ALLOWED_USERS`.

**Fact:** Slack uses Bolt Socket Mode over WebSockets and needs no public URL. Install or invite the app per channel. One gateway can serve multiple workspaces through comma-separated bot tokens; one app-level token handles Socket Mode and the first bot token is primary. Threads act as session continuation, and because Slack blocks native slash commands inside threads, Hermes accepts a `!` prefix there (`!stop`, `!new`, `!status`).

### Signal

Credentials: `SIGNAL_HTTP_URL` (for example `http://127.0.0.1:8080`), `SIGNAL_ACCOUNT`, and ideally `SIGNAL_ALLOWED_USERS`.

**Fact:** Signal runs through a `signal-cli` daemon in HTTP mode, streaming inbound messages over SSE and sending replies over JSON-RPC, with an account linked as a secondary device (`signal-cli link -n "HermesAgent"`). Group messages are ignored unless `SIGNAL_GROUP_ALLOWED_USERS` lists group IDs or `*`, and the adapter cannot edit sent messages, so it suppresses tool-progress updates.

### Email

Credentials: `EMAIL_ADDRESS`, `EMAIL_PASSWORD` (an app password), `EMAIL_IMAP_HOST`, `EMAIL_SMTP_HOST`, `EMAIL_ALLOWED_USERS`.

**Fact:** email uses IMAP polling for unseen mail (`EMAIL_POLL_INTERVAL`, default 15 seconds) plus SMTP replies; there is no bot API. Replies preserve the thread through `In-Reply-To`/`References` and a `Re:` subject. Unknown senders are ignored by default; set `platforms.email.unauthorized_dm_behavior: pair` to opt into pairing, because inboxes carry unrelated unread mail. **Run only one gateway instance against an inbox.**

### WhatsApp

**Fact:** the WhatsApp adapter is a Baileys-based Node.js bridge (`Node.js 18+`) with two modes: `bot` (a separate bot account) and `self-chat` (you message yourself). `WHATSAPP_ENABLED=true` and `WHATSAPP_MODE` select it; access is `WHATSAPP_ALLOWED_USERS` (country code, no `+`, or `*`) or `WHATSAPP_ALLOW_ALL_USERS=true`. `hermes whatsapp` runs the wizard, installs bridge dependencies, and shows a QR code to scan from Linked Devices.

**Recommendation:** the page states this bridge carries **account-ban risk**. For a business bot use the WhatsApp Business Cloud API adapter, which is the Meta-supported path and needs a Meta Business account plus a public webhook URL.

## Authorization and pairing

**Fact — documented check order:** per-platform allow-all → approved DM pairing → platform allowlist → global allowlist (`GATEWAY_ALLOWED_USERS`) → global allow-all (`GATEWAY_ALLOW_ALL_USERS`, or `gateway.allow_all_users: true`) → **default deny**. Per-platform allowlists follow `<PLATFORM>_ALLOWED_USERS` across Telegram, Discord, Slack, Signal, SMS, Email, Mattermost, Matrix, DingTalk, Feishu, WeCom, WeCom Callback, and Teams.

**Fact — unauthorized DMs:** `unauthorized_dm_behavior` is `pair` by default for chat-style platforms, `ignore` to drop silently, or `decline` to send one polite refusal and ignore that sender for 24 hours (customizable with `unauthorized_dm_decline_message`). Platform sections override the global value.

**Fact — pairing:** an unknown user receives an 8-character code from a 32-character unambiguous alphabet, generated with `secrets.choice()`, valid for one hour, rate-limited to one request per user per 10 minutes with at most 3 pending codes per platform. The operator approves with `hermes pairing approve <platform> <CODE>`, inspects with `hermes pairing list`, and revokes with `hermes pairing revoke <platform> <user-id>`.

**Fact — admin tier is separate from reachability.** Under `gateway.platforms.<platform>.extra`, `allow_from` grants access while `allow_admin_from`, `user_allowed_commands`, `group_allow_admin_from`, and `group_user_allowed_commands` govern slash commands. `/help` and `/whoami` are always allowed, and DM and group scopes have independent admin lists. `/sessions all` is admin-only.

## Session scoping

**Fact:** session keys derive from the message source:

| Surface | Key |
| --- | --- |
| DM | `agent:main:<platform>:dm:<chat_id>` |
| WhatsApp DM | `agent:main:whatsapp:dm:<canonical_identifier>` |
| Group | `agent:main:<platform>:group:<chat_id>:<user_id>` |
| Group thread/topic | `agent:main:<platform>:group:<chat_id>:<thread_id>`; Telegram DM topics use `agent:main:telegram:dm:<chat_id>:<thread_id>` |
| Channel | `agent:main:<platform>:channel:<chat_id>:<user_id>` |

**Fact:** `group_sessions_per_user` defaults to `true`, isolating each participant's transcript. Setting it to `false` gives the room one conversation and therefore one token budget, one interrupt state, and one running-agent slot. Threads stay separate from their parent, but a group thread is shared by all participants unless `thread_sessions_per_user: true`. When a participant ID is unavailable, the platform falls back to a single shared room session.

**Fact — no timer resets:** gateway conversations no longer reset after inactivity or at a daily boundary. `/new` or `/reset` starts a fresh conversation, context compression stays automatic, and core ignores legacy `session_reset` settings; a config that still sets `session_reset.mode` to `idle`, `daily`, or `both` triggers a warning at startup and in `hermes doctor`. The catalog plugin `hermes-session-reset-policy` restores time-based resets. A `/model` switch persists across gateway restarts for that session (`--global` writes it to `config.yaml`, `--once` applies to a single turn), and `/sessions [search <query>]` finds earlier sessions.

**Fact:** `/branch [--here] [name]` (alias `/fork`) opens the branch in a new sibling thread on Discord, Telegram, Slack, and Matrix while the current chat stays on the original; `--here` switches this chat instead. Platforms without threads branch in place.

## Running several adapters

**Fact:** one gateway usually runs several adapters at once. Pause and resume them without restarting everything:

```
/platform list
/platform pause <name>
/platform resume <name>
```

**Fact:** a paused adapter keeps its connection and background loops but drops incoming messages. `/platform list` reports `running`, `paused`, or `paused-by-breaker`.

**Fact:** each adapter has a circuit breaker that trips after repeated retryable failures — network errors, rate limits, 5xx, WebSocket faults — and notifies another live platform's home channel. **It does not auto-resume**; `/platform resume <name>` clears and rearms it once the provider is healthy.

**Fact:** `gateway_restart_notification` (default `true`) sends one restart or interruption notice per platform home channel, and `typing_indicator` (default `true`) controls the typing status. `gateway.trust_env: false` stops adapters from inheriting an ambient proxy while keeping explicit per-platform proxy variables.

**Fact — documented conflicts:** do not run user and system units together; never share one Telegram bot token across gateways; run one gateway per email inbox. Under the multiplexed gateway, profile separation replaces the old rule of one process per profile.

## Message delivery

**Fact:** final responses go through a durable `state.db` ledger with at-least-once semantics. A send that never started is redelivered as-is; a send that was mid-flight when the gateway died is redelivered with a visible "Recovered reply" prefix. A final send refused by flood control is retried after the recorded penalty without spending an attempt or re-running the agent, and other rejected sends retry on a growing backoff (30 s, then 2 min), leaving the last budgeted attempt for the next boot. Redelivery is bounded at 3 attempts within 24 hours; delivered rows are pruned after 7 days. A permanently unreachable chat is not retried.

**Fact:** `gateway.delivery_ledger: false` restores the older, loss-prone behavior. Sessions interrupted by a restart auto-resume on the next reply, logged as `Scheduled auto-resume for N restart-interrupted session(s)`.

**Fact:** an agent whose entire final response is a silence token (`[SILENT]`, `SILENT`, `NO_REPLY`, `NO REPLY`, and their Chinese renderings) suppresses delivery while keeping the turn in the transcript. On a message from a person a bare token is replaced by a short notice so a needed reply cannot vanish.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| Gateway will not start or is not running | `hermes gateway status`; read the service log; re-run `hermes gateway setup`; then `hermes doctor` |
| Status shows degraded or stale | Restart: the event-loop watchdog exited or housekeeping stopped refreshing `gateway_state.json` |
| Gateway starts but nobody can message it | Usually an incomplete bot token, allowlist, or platform setup |
| An adapter went quiet | Grep the log for `circuit breaker|paused|disabled`, run `/platform list`, check the provider status page, then `/platform resume <name>` |
| A platform stays off despite valid credentials | An explicit `platforms.<name>.enabled: false` overrides `.env` |
| Duplicate replies | Expected at-least-once behavior after a mid-send crash, or two gateways against one inbox/token |
| Missing messaging dependencies | Install the messaging extra as documented, then restart the gateway |

## Security boundary

**Fact:** an inbound message is untrusted data. Allowlists and pairing authenticate **who** may trigger the agent; webhook HMAC authenticates the **sender**, not the content. Upstream text — a PR title, an issue body, a forwarded message — remains attacker-controlled, and the docs state that Hermes cannot reliably sanitize untrusted text with a blocklist.

**Recommendation:** the real boundary is the capability surface. Reduce the toolset exposed to gateway platforms, keep approvals on, prefer an isolated terminal backend for untrusted work, use separate identities for production, and never enable headless auto-approval just because a messaging adapter exists.

## Verification checklist

- [ ] A model and tool provider work before any adapter is enabled.
- [ ] Credentials are in `~/.hermes/.env` at mode `600`; behavior is in `config.yaml`.
- [ ] An explicit authorization policy exists — the gateway denies by default.
- [ ] No bot token or inbox is shared between two running gateways.
- [ ] Service logs and gateway health were confirmed before relying on it unattended.
- [ ] The exposed toolset and approval mode were chosen deliberately for a public entry point.
