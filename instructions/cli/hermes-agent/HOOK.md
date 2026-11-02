# Hermes Agent Hooks

> Korean version: [`HOOK.ko.md`](HOOK.ko.md)
>
> Companion guides: [overview](README.md), [extensions](EXTENSIONS.md), [configuration](CONFIGURATION.md), [plugins](PLUGINS.md), and [plugin authoring](PLUGIN_AUTHORING.md)  
> 2026 deltas that invalidate older notes: [hermes-agent-2026-changes.md](references/hermes-agent-2026-changes.md)
> **Research date:** 2026-11-03, against the official documentation shipped in Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`, 2026-10-22) and the release notes for v0.22.0 (2026-10-13). **Facts** trace to those sources. **Recommendations** are this guide's operating policy, not Hermes guarantees. Confirm version-sensitive behavior before operating. The live documentation site deploys ahead of the tag: anything observed only on the site is dated with its check date instead of being presented as v0.22.5 behavior, and version-sensitive names should be confirmed with `--help` on the installed CLI.

## Sources

| Source | What it supplies | Checked |
| --- | --- | --- |
| [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) | The four hook systems, gateway events, the shipped plugin-hook catalog, shell-hook wire protocol, outbound webhooks | 2026-11-03 |
| [Hooks source at v0.22.5](https://github.com/NousResearch/hermes-agent/blob/v0.22.5/website/docs/user-guide/features/hooks.md) | Exact defaults and field lists quoted below | 2026-11-03 |
| [Build a Hermes Plugin](https://hermes-agent.nousresearch.com/docs/developer-guide/plugins) | Plugin-hook registration and `ctx` surface | 2026-11-03 |
| [Plugins](https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins) | `plugins.hook_callback_timeout`, `plugins.enabled` scope | 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | Trusted-by-placement extension points | 2026-11-03 |
| [v0.22.0 release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.0) | New hook families, multiplexed gateway, guard hooks failing closed | 2026-11-03 |

## Scope and selection

**Fact:** Hermes documents four distinct lifecycle-hook systems. Choose the narrowest system whose execution and authority match the need; do not conflate outbound lifecycle notifications with inbound webhook routes.

| Need | System | Registration and scope | Can steer execution? |
| --- | --- | --- | --- |
| Gateway-only observation or integration | Gateway hook | `$HERMES_HOME/hooks/<name>/HOOK.yaml` + `handler.py`; Gateway only (never CLI, TUI, Desktop, or cron) | No: the catalog marks gateway hooks as unable to block a tool call |
| In-process tool, model, session, or transform policy | Plugin hook | `ctx.register_hook()` from a native plugin; CLI + Gateway | Event-specific; directive hooks can block, modify, or request approval |
| Configured command at a lifecycle boundary | Shell hook | `hooks.<event>` in the profile `config.yaml`; CLI + Gateway + Desktop/TUI/dashboard chat | Event-specific; `pre_tool_call` can block, modify args, or fail closed |
| HTTP notification to an external receiver | Outbound webhook | `hooks.outbound` in `$HERMES_HOME/config.yaml`; CLI + Gateway | No; notify-only, responses ignored |

**Fact:** plugin middleware is a separate registry and surface, not a fifth hook system. Inbound webhook gateway routes and route scripts are messaging surfaces whose authentication model must be evaluated separately.

## Runtime and trust boundary

**Fact:** hooks are trusted-code extension points, not a security sandbox. Gateway and plugin hooks run in-process inside Hermes. Shell hooks run as subprocesses under the Hermes OS user; that is process separation, not capability restriction. Callback exceptions are caught and logged at dispatch points, but Hermes does not generically isolate hangs, termination, resource exhaustion, or malicious behavior.

**Fact:** gateway hooks are **trusted by placement**. Any subdirectory of the profile home's `hooks/` holding a valid `HOOK.yaml` with a non-empty `events` list plus a `handler.py` is imported at gateway startup; there is no enable list, no first-use prompt, and `plugins.enabled`/`plugins.disabled` do not apply. `HERMES_SAFE_MODE` does not skip this loader. Under a multiplexed gateway, each served profile's own `hooks/` is loaded the first time an event fires in that profile.

**Recommendation:** run high-risk hooks under a dedicated non-admin OS account and isolate mutually untrusted deployments with separate processes, service accounts, containers, or hosts. Never cite `HERMES_SAFE_MODE` as a gateway-hook kill switch; removal or rename of `HOOK.yaml` is the documented opt-out.

## Gateway hooks

**Fact:** `HOOK.yaml` declares `name`, `description`, and `events`; `handler.py` must define `handle(event_type, context)` as `def` or `async def`. Wildcards such as `command:*` are supported. Handler errors are logged and never crash the agent.

| Event | Fires when | Notable context keys |
| --- | --- | --- |
| `gateway:startup` | the gateway process starts | `platforms` |
| `session:start` / `session:end` / `session:reset` | session created, ended, or explicitly reset | `platform`, `user_id`, `session_key` |
| `session:compress` | context compression completes | `session_id`, `old_session_id`, `in_place`, `compression_count` |
| `agent:start` / `agent:end` | a turn begins or finishes | `chat_id`, `thread_id`, `chat_type`, `session_id`, message or response truncated to 500 chars |
| `agent:step` | each tool-loop iteration | `iteration`, `tool_names` |
| `reaction:added` / `reaction:removed` | a reaction lands on a visible message (Slack adapter today) | `reaction`, `item_user_id`, `channel_id`, `message_ts` |
| `command:*` | any slash command runs | `command`, `args` |

**Fact:** at this revision the documentation states no timeout, retry, or fail-closed semantics for gateway hooks; handlers are awaited by the emitting path. Do not describe them as unable to delay it, and do not claim they can block a tool call.

**Recommendation:** use gateway hooks for fast observation or safely offloaded side effects. Bound external I/O inside the hook, make effects idempotent, and never treat an event name or registration order as a global ordering guarantee across turns, profiles, or processes.

## Plugin hooks

**Fact:** native plugins register callbacks with `ctx.register_hook(name, callback)` during `register(ctx)`; they fire in both CLI and gateway sessions. Payloads are keyword-based and additive: callbacks should accept `**kwargs`. `hermes_cli.plugins.VALID_HOOKS` is the runtime authority on which names are valid.

**Fact:** hot-path observers and `pre_tool_call` are timeout-bounded by `plugins.hook_callback_timeout` (default 30 seconds, `0` disables, values above 600 are clamped). A callback that overruns is abandoned so the agent loop continues; a timed-out `pre_tool_call` **fails closed** and blocks the tool, while other bounded hooks fail open. Hooks with a caller-thread contract such as `subagent_stop` are never moved onto a timeout worker.

**Fact:** the shipped catalog groups hooks by behavior. Representative entries:

| Category | Hooks | Authority |
| --- | --- | --- |
| Directive/control | `pre_tool_call`, `pre_llm_call`, `pre_verify`, `pre_gateway_dispatch`, `post_gateway_admission` | Return shapes steer the call; `pre_tool_call` accepts block, modify, or approval requests |
| Transform | `transform_tool_result`, `transform_terminal_output`, `transform_llm_output`, `pre_transcription`, `transform_api_error_classification` | First valid replacement wins |
| Observer | `post_tool_call`, `post_llm_call`, `pre_api_request`, `post_api_request`, `api_request_error`, `pre_auxiliary_call`, `post_auxiliary_call`, streaming and session hooks, `subagent_start`/`subagent_stop`, `pre_approval_request`/`post_approval_response`, `on_human_input_request`/`on_human_input_resolved`, `pre_command`, Kanban lifecycle hooks | Return value ignored |

**Fact:** 2026 additions relevant to scene design: `post_gateway_admission` lets a plugin claim an admitted inbound message and skip the agent turn (nothing else, including a raise or timeout, does); streaming hooks (`on_stream_start`, `on_stream_delta`, `on_stream_end`) are delivered off the token path through host-owned bounded queues so a stalled callback drops only its own oldest events; auxiliary-call hooks cover titling, compression, MoA, vision, and approval calls; `on_human_input_request`/`on_human_input_resolved` fire around password, clarify, and approval waits with the prompt force-redacted and the answer never passed.

**Fact:** durable always-on prompt guidance belongs in `ctx.register_system_prompt_section(id, text_or_callable, position="after_memory", max_chars=4000)` rather than a `pre_llm_call` injection every turn. The section renders once per new session, is frozen on compression, is recovered from the persisted system prompt after restart, and is capped at 4,000 characters per section and 8,000 across at most 32 sections. Use `pre_llm_call` for genuinely per-turn context.

**Recommendation:** treat a plugin hook like trusted application code. Grant only needed capabilities, review the source, and test the exact event contract instead of extrapolating one hook's authority to another. Do not rely on a hook to grant approval: Hermes owns hardline blocks, request binding, and final authorization.

## Shell hooks

**Fact:** shell hooks are declared under `hooks.<event>` in the profile `config.yaml` and run for plugin-hook event names, including in Desktop, TUI, and dashboard chat. Each entry takes `command` (required; split with `shlex.split`, `shell=False`), optional `matcher` for tool events, `timeout` (default 60 seconds; above 300 is clamped with a warning), and `fail_closed`/`failClosed` (`pre_tool_call` only).

**Fact:** the wire protocol is JSON on stdin (`hook_event_name`, `tool_name`, `tool_input`, `session_id`, `cwd`, `profile`, `extra`) and optional JSON on stdout: `{"decision":"block"|"modify","reason"|tool_input}` (Claude Code/Cursor shape), `{"action":"block"|"modify"|"approve"|"continue", ...}` (Hermes canonical), `{"context": "..."}` for `pre_llm_call`, or `{}` for a silent no-op. `profile` names the emitting profile behind a multiplexed gateway, and the subprocess runs with that profile's `HERMES_HOME`.

**Fact:** a `pre_tool_call` hook that exits **2** blocks the call even with no stdout JSON; the message resolves from stdout JSON, then the first 400 characters of stderr, then a generic default. For other events exit code 2 behaves like any non-zero exit.

| Failure | Default (fail open) | `fail_closed: true` |
| --- | --- | --- |
| Command missing or not executable | warn, proceed | **block** |
| Timeout | warn, proceed | **block** |
| Non-zero exit without a recognized directive | warn, proceed | **block** |
| Non-JSON stdout | warn, proceed | **block** |
| Clean exit with `{}` | proceed | proceed |

**Fact:** consent is per `(event, command)` pair, persisted to `~/.hermes/shell-hooks-allowlist.json` (per-profile equivalent under `profiles/<name>/`). Three escapes bypass the prompt: `--accept-hooks`, `HERMES_ACCEPT_HOOKS=1`, or `hooks_auto_accept: true`. Only a foreground `hermes chat`/`hermes rl` ever asks; the gateway, cron, ACP, and CI never prompt. Script edits are silently trusted because the allowlist keys on the command string, not a hash; `hermes hooks doctor` flags mtime drift. Allowlist or `hooks:` changes reach a running gateway within about 30 seconds.

**Fact:** `hermes hooks list`, `test <event>`, `revoke <command>`, and `doctor` inspect, execute, revoke, and audit configured hooks. `test` runs the real configured command.

**Recommendation:** inspect scripts before approving or testing them. Use `fail_closed: true` only for a tested `pre_tool_call` policy with a bounded timeout, and test the spawn-error, timeout, malformed-output, denial, and approval-timeout paths before treating a hook as a safety control.

## Outbound webhooks

**Fact:** `hooks.outbound` is a list of targets with `url`, `events`, optional `name`, `matcher`, `timeout` (1–60 seconds per attempt), and a secret supplied through `secret_env` (preferred) or inline `secret`. Any plugin-hook event name is valid. Malformed entries warn and are skipped; changes take effect on the next CLI session or gateway restart.

**Fact:** each firing POSTs the shell-hook payload shape plus `delivery_id`, `timestamp`, and `profile`, with headers `X-Hermes-Event`, `X-Hermes-Delivery`, and `X-Hermes-Signature-256` (`sha256=<hex>` HMAC over the raw body, present only when a secret resolves). A target without a secret is delivered unsigned and flagged `UNSIGNED` by `hermes hooks list`.

**Fact:** delivery is fire-and-forget on a background thread with a bounded queue that drops new events when backed up. Connection errors and 5xx are retried once with backoff; 4xx are not retried; 3xx are never followed and are logged as misconfiguration. Responses are ignored, so an outbound webhook can never veto an action.

**Recommendation:** use HTTPS, make receivers idempotent, verify the exact raw body with `hmac.compare_digest`, dedupe on `delivery_id`, and reject timestamps outside a short tolerance window. Use an external durable queue when the notification is an audit record or must survive process failure.

## Payload, privacy, and inbound boundary

**Fact:** payload sensitivity is event-specific. `pre_api_request` and `pre_auxiliary_call` intentionally carry raw `request_messages` and conversation history, and warn that a sanitized `request` field is preferable. `on_human_input_request` always force-redacts its prompt and never passes the typed answer. Hermes documents no blanket hook-payload redaction guarantee, and outbound signing does not make a payload private.

**Fact:** inbound webhook verification is route- and scheme-specific. Successful verification proves only that the request satisfied the configured shared-secret scheme; it does not establish that business fields are true, that the author is authorized, or that the text is safe for an agent.

**Recommendation:** treat every inbound message, webhook field, and externally supplied hook value as untrusted agent input, even when authenticated. Select minimum events and constrained toolsets, and review every receiver, log, template, and storage destination before enabling a hook.

## Failure and ordering model

**Fact:** there is no single global hook failure policy or ordering guarantee. Python plugin hooks are registered before shell hooks, and both flow through one dispatcher, so a plugin `pre_tool_call` decision wins a tie. A block anywhere outranks an `approve` returned earlier, and the dispatcher returns on the first valid block with a non-empty message.

| System/event | Bounded behavior at this revision |
| --- | --- |
| Gateway or plugin callback raises ordinary `Exception` | Logged and skipped; later callbacks continue |
| Plugin callback overruns `hook_callback_timeout` | Abandoned; `pre_tool_call` blocks, other bounded hooks skip |
| Shell `pre_tool_call` exits 2 or returns a block directive | Blocks that tool call |
| Shell spawn error, timeout, or malformed stdout | Allows by default; blocks only with `fail_closed: true` |
| Outbound serialization, queue, or HTTP failure | Logged or dropped; never vetoes the agent action |

**Recommendation:** document and test failure behavior for the exact system and event. Include causal metadata, tolerate gaps and duplicates, and do not infer transactionality or rollback from caught exceptions.

## Profiles and validation

**Fact:** a profile is a configuration and secret scope, not a security sandbox. Under the multiplexed gateway each profile keeps its own `hooks/`, allowlist, and `HERMES_HOME`, and `plugins.isolation: host` gives third-party plugin code a separate per-profile process; gateway hooks and shell hooks remain in-process or process-separate only as described above.

Before enabling a hook:

1. Identify the hook system, exact event, authority, payload fields, and failure behavior.
2. Review code, command arguments, inherited environment, outbound receiver, and secret source.
3. Confirm the active `$HERMES_HOME`, profile, and the relevant allowlist or consent state.
4. Exercise the happy path plus timeout, malformed output, receiver failure, and duplicate/retry behavior in a disposable environment.
5. Re-read the [Event Hooks](https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks) reference after every Hermes upgrade.

## EXPAND

- Add event-by-event payload tables only after pinning them to the installed Hermes version.
- Add a receiver implementation only with an explicit secret, retention, privacy, replay, and idempotency contract.
- Run `hermes hooks test` or `hermes hooks doctor` only after inspecting their configured scripts; both can execute hook code.
