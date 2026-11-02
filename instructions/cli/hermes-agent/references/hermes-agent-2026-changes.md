# Hermes Agent: 2026 changes that invalidate older notes

> Korean version: [`hermes-agent-2026-changes.ko.md`](hermes-agent-2026-changes.ko.md)
>
> Companion guides: [hooks](../HOOK.md), [plugins](../PLUGINS.md), [plugin authoring](../PLUGIN_AUTHORING.md), [extensions](../EXTENSIONS.md), [messaging](../MESSAGING.md), [Discord](../DISCORD.md)
> **Research date:** 2026-11-03, against Hermes Agent **v0.22.5** (commit `bf0203a794a`) documentation and the v0.22.0 release notes.

This page exists because a lot of otherwise reasonable Hermes material written in 2025 and early 2026 now states the opposite of current behavior. Each row is a change that makes an old note wrong, what to do instead, and where the evidence lives.

| Area | What changed | Do this instead | Evidence |
| --- | --- | --- | --- |
| Gateway topology | One gateway process now serves **every profile** by default (`gateway.multiplex_profiles`, default `true`) instead of one process per profile. | Run one service; migrate with `hermes gateway migrate --multiplex`; use `hermes -p <name> gateway stop\|start` for one profile; `gateway.standalone: true` only as a temporary opt-out. | [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway), v0.22.0 notes |
| Session lifetime | Idle and daily `session_reset` modes were **retired**. Only `/new` and `/reset` start a fresh conversation; legacy keys now warn at startup. | Delete `session_reset.mode: idle\|daily\|both`; install the catalog plugin `hermes-session-reset-policy` if time-based resets are required. | [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging), v0.22.0 notes |
| Slash commands | `/clear` and `/history` are CLI-only; `/branch` (alias `/fork`) opens a sibling thread on Discord, Telegram, Slack, and Matrix; `/btw`, `/bg`, `/sessions search` work in chat. | Do not promise CLI-only commands in messaging docs; use `/branch --here` to move the current chat onto the branch. | [Slash commands](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) |
| Project-local plugins | The gateway **does not load** `.hermes/plugins/` from a session's working directory, and `HERMES_ENABLE_PROJECT_PLUGINS=true` has no effect on sessions. | Install as a user plugin and `hermes plugins enable <name>`. | [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) |
| Plugin catalog | Grew from 600 reviewed entries at launch to **910** (20 Official, 9 Verified, 881 Community) on 2026-11-03; install by bare name resolves to a pinned commit. Catalog admission is explicitly **not** a security audit. | Prefer catalog names for provenance, still review the code, and pin custom installs to a full 40-character SHA. | [Plugin catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog) |
| Plugin supply chain | Installs and updates now run a static scan with `safe`/`caution`/`dangerous` verdicts, where `dangerous` cannot be overridden by `--force`; plugin packs install a pinned set from `hermes-pack.yaml`. | Treat an update as a code deployment; use `hermes plugins pack show` before installing a pack. | [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) |
| Plugin isolation | `plugins.isolation: host` runs third-party plugin code in one separate process per profile with only that profile's secrets. | Enable it for shared deployments and pin it in managed scope; keep gateway adapters and monkeypatching plugins in-process. | [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) |
| Plugin dependencies | `python_dependencies` are no longer declaration-only: Hermes resolves them with core, extras, and other enabled plugins through its package manager and publishes the environment atomically. `pyproject.toml` wins over the manifest. | Pin upper bounds; expect a dependency consent prompt; use `--no-deps`/`--yes-deps` for scripted installs; `python_runtime: external` for sidecars. | [Build a Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) |
| Internal imports | The compatibility layer for pre-September-2026 internal import paths expired on **2026-09-14**; old imports now fail with `ImportError`. | Import from the defining module or use `ctx` and the documented ABCs; never monkeypatch core. | [Build a Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) |
| Hook callbacks | Hot-path observers and `pre_tool_call` are abandoned after `plugins.hook_callback_timeout` (default 30 s, max 600); a timed-out `pre_tool_call` **fails closed**. | Keep callbacks fast and idempotent; do not put slow network calls on a hot-path hook. | [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) |
| New hook families | Streaming (`on_stream_*`), provider-attempt (`pre_api_request`/`post_api_request`/`api_request_error`, `pre_auxiliary_call`/`post_auxiliary_call`), human-input, gateway admission (`post_gateway_admission`), `pre_command`, session finalize/delete, `post_compaction`, `agent_loop_stopped`, and skill-lifecycle hooks exist. | Prefer the specific hook over scraping logs or wrapping internals; read the catalog for exact payloads. | [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) |
| Shell hooks | Now also run in Desktop, TUI, and dashboard chat; consent is per `(event, command)` pair in `shell-hooks-allowlist.json`; exit code `2` blocks `pre_tool_call`; changes reach a running gateway in about 30 seconds. | Re-check `fail_closed` policies after upgrades and run `hermes hooks doctor`. | [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) |
| Plugin API surface | New: `ctx.llm`, `ctx.register_middleware`, `register_system_prompt_section`, approval transports, delegation/computer-use/dashboard-auth providers, `plugin_data_dir()`/`plugin_db()`, `ctx.ask_choice`, `ctx.has_plugin`, `ctx.profile_name`. | Prefer these over private attributes such as `ctx._cli_ref`, which is `None` in the gateway and Kanban workers. | [Build a Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) |
| Portable packages | Hermes targets **Agent Plugins v1.0.0**; the specification repository also publishes a **Working Draft** 1.1.0, which Hermes does not document as supported. | Keep generating v1.0.0 packages; do not assume 1.1.0 features load. | [Agent Plugins 1.0.0](https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md) |
| Discord permissions | The recommended integer is now `309237763136` (adds Create Public Threads); `309240908864` adds Connect/Speak for voice. | Re-invite bots created before Create Public Threads was recommended. | [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Discord bot handoffs | Bot handoffs require a literal `<@BOT_ID>` (`bots_require_inline_mention`, default `true`), with a continuation window and a loop guard that drops further bot messages for 10 minutes after 20 in 5 minutes. | Keep `DISCORD_ALLOW_BOTS="none"`; the old "no circuit breaker" claim is obsolete. | [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Discord recovery | `discord.missed_message_backfill` is an option mapping (`window_seconds`, `limit`, `max_dispatches`, `max_attempts`), disabled by default. | Configure the window and caps explicitly instead of assuming a single switch. | [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Discord health | WebSocket liveness gained `websocket_event_max_silence_seconds` (default 14400) because a socket can ACK heartbeats while delivering no events. | Tune it only with knowledge of normal guild traffic. | [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) |
| Runtime | Managed installs run **Python 3.14** and a unified package manager (`hermes pm`) owns pinned, hash-checked tool and Python environments in generations. | Do not hand-install Python or dependencies into a managed install; let `hermes pm` rebuild. | v0.22.0 release notes |

## Upgrade checklist

1. Read the release notes for every version between the one you run and the target.
2. Re-read the hook and plugin references; check that no plugin imports a pre-September-2026 internal path.
3. Diff your `config.yaml` against deprecations — `session_reset`, per-profile gateway units, and credential-only platform activation are the common ones.
4. Re-run `hermes doctor`, `hermes plugins doctor <path>`, and `hermes hooks doctor`.
5. Re-invite Discord bots if you rely on thread creation or voice.
6. Re-check gateway topology: one service, every profile, before you start a second one.

## Sources

| Source | Checked |
| --- | --- |
| [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) | 2026-11-03 |
| [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | 2026-11-03 |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | 2026-11-03 |
| [Messaging Gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging) | 2026-11-03 |
| [Discord Setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord) | 2026-11-03 |
| [Multiplexing gateway](https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway) | 2026-11-03 |
| [Plugin catalog](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog) | 2026-11-03 |
| [Slash commands](https://hermes-agent.nousresearch.com/docs/reference/slash-commands) | 2026-11-03 |
| [v0.22.0 release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | 2026-11-03 |
