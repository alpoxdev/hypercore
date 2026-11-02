# GJC Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)
>
> **Research date:** 2026-11-03. Product behavior is pinned to Gajae-Code `v0.19.2`
> (GitHub release, 2026-10-29) and the first-party repository docs at that point on `main`.
> A nightly channel publishes ahead of the stable tag, so recheck `gjc --version` and the
> matching docs before relying on a command or default.

## Scope

This is the adapter rule for authoring and running skills on the `gjc` CLI, published as
**Gajae-Code**: repository [`Yeachan-Heo/gajae-code`](https://github.com/Yeachan-Heo/gajae-code),
site [`gajae-code.com`](https://gajae-code.com), npm package `gajae-code`, MIT licensed, and
described by its maintainers as an experimental, beta-stage project. It does not apply to other
tools that reuse the initials.

Shared capability, authority, question, and approval rules follow
[`../capability-contract.md`](../capability-contract.md). GJC's tool list and runtime guards do
not grant permission to act.

## Evidence boundary

- Primary evidence: the README, `docs/` in the repository, per-tool reference pages under
  `docs/tools/`, the customization/trust contract, and the release feed.
- The project ships nightly builds and moves quickly. A claim below is only as current as the
  pinned stable tag; re-read the matching source or `docs/` page before depending on it.
- Issue reports and third-party integration notes are observations, not confirmed behavior.
- This profile records capability and safety boundaries. It is not an install, provider, or
  command reference.

## Runtime binding

| Logical capability | Verified GJC surface | Binding rule |
|---|---|---|
| Local inspection | `read`, `find`, `search`, `bash` | Keep paths inside the declared repository scope. GJC resolves paths from the session working directory; the OS user's permissions are the outer boundary. |
| Local search | `search`, `find`, `ast-grep`, `bash` | Prefer non-network evidence; oversized shell output may be minimized and spilled to `artifact://` references, so retrieve the artifact when the excerpt is not enough. |
| Network research | `web_search`, `browser`, `ssh`, MCP tools | Treat network access and data egress as separate side effects; confirm the destination. |
| Edit | `write`, `edit`, `ast-edit`, `bash`, `python`, `eval` | Use only when the user asked for a change. Shell and interpreter tools can write files regardless of the file tools' policy. |
| Execute | `bash`, `job`, `cron`, `monitor`, `ssh` | Validate command, working directory, target host, and side effects before running. A blocked shell pattern is not an authorization decision. |
| Human decision | `ask`; workflow gates | Only when the runtime actually provides an answer surface (see below). |
| Delegate | `task` | Give each child its objective, owned scope, allowed tools, forbidden side effects, and evidence contract. Parent verification remains required. |
| Desktop control | `computer` | Supervisor-gated macOS input. Screenshots are read-only; click/type/keypress are global and unscoped. |

Discover the live tool schema before binding. Tool availability varies with `--tools`,
`--no-tools`, `--no-lsp`, `--no-pty`, MCP configuration, and session mode.

## Questions and approval

GJC has a real `ask` tool, but its availability is conditional.

- Shape: `questions[]`, each with `id`, `question`, `options[]` (labels only), optional `multi`,
  and optional `recommended` index. The UI appends `Other (type your own)`; callers must not add
  it. Prompt guidance asks for two to five options; the schema does not enforce it.
- Registration is conditional: the tool exists when the session has a UI, is workflow-gate
  eligible, or exposes a workflow-gate emitter. A plain headless session without any answer
  surface never gets it, so a skill must not assume it can ask.
- `ask.timeout` defaults to `0` (disabled). When set, a timeout **auto-selects the recommended
  option**, or the first option when no valid recommendation exists. Do not let an auto-selected
  answer stand in for a human decision on a gated action.
- In headless use, a registered answer source may answer instead; `GJC_ASK_ANSWER_DEADLINE_MS`
  bounds the wait and aborts the turn on expiry. User cancellation aborts the tool rather than
  returning a success result.
- Durable workflow gates are answered through the SDK control operation `workflow.gate_answer`
  with the durable gate ID and expected session ID. A transient `action_needed.id` is not durable
  authority, and the current host does not implement the protocol's general `ask.answer`.

Approval semantics belong to two places:

- **Plan before mutation.** `deep-interview`, `ralplan`, and `ultragoal` are explicitly invoked
  workflows, and planning "does not authorize implementation by themselves: execution requires
  explicit approval or an admitted `ralplan` runtime handoff".
- **Single-use approval.** For controller-driven work, show the exact operation and target before
  any mutating call and treat the approval as single-use: if the operation, input, or target
  changes, ask again.

When no answer surface exists, ask in plain text and stop before the gated action instead of
fabricating an interactive prompt.

## Command approval and filesystem

- No general per-command human approval gate is documented for `bash`. The documented command
  controls are availability (`--tools`, `--no-tools`), a command interceptor that redirects
  tool-better shell patterns to dedicated tools, and optional hooks.
- The interceptor is a usability rule, not a containment boundary. It can be disabled by
  settings, and it does not inspect what an interpreter one-liner does.
- Hooks are the enforceable seam: `tool_call` / `pre_tool_use` handlers run sequentially, fail
  closed, and the first `{ block: true }` stops later handlers. Post-tool handlers must never gain
  blocking authority.
- The tmux self-pane injection guard is best-effort static analysis. Direct SDK `executeBash()`
  bypasses it, and it does not mediate the Python or eval tools.
- `--allow-home` exists because starting in `~` otherwise switches to a temporary directory. That
  start-directory guard is a convenience boundary, not a sandbox.
- No sandbox mode is documented: commands run with the invoking user's OS permissions. Treat the
  shell and interpreter tools as host-level execution.

## Project trust and configuration

GJC has exactly two authoritative configuration scopes: project `<project>/.gjc/` and user
`~/.gjc/agent/`.

- **MCP**: native `~/.gjc/agent/mcp.json` and project `.gjc/mcp.json` registrations autoload;
  `--no-mcp` disables conventional autoload and `--mcp-config` supplies a tools-only file.
  Claude Code and Codex MCP files are import sources only, never implicit runtime authority.
  Project-level MCP is executable configuration: a server command starts without a project trust
  prompt, so inspect the command, arguments, environment, and source before opening an untrusted
  repository.
- **Skills**: project `.gjc/skills/<name>/SKILL.md` and user `~/.gjc/agent/skills/<name>/SKILL.md`
  load directly. `skills.trustProjectSkills` and `skills.trustUserSkills` default to on, and
  `skills.enabled` is the master switch. Project scope beats user scope, and the four bundled
  workflow skills cannot be replaced from disk.
- **Hooks**: ordinary sessions load user-agent `~/.gjc/agent/hooks/` modules. A repository
  `.gjc/hooks/` module is stored-only and does not execute automatically, so a project cannot
  install a start-up hook by being opened.
- **Instructions**: `AGENTS.md` is the instruction surface; `--no-rules` disables rules discovery
  for a session.
- **Settings** reload live in interactive sessions, and reloaded policies take effect in the
  running session. Reconfirm the effective tool set after a config change.

## Non-interactive use and the SDK

- `gjc -p "<prompt>"` runs one non-interactive turn; `--mode` selects `text`, `json`, or `acp`.
  Sessions can be continued, resumed by prefix or path, or forked.
- `--json` output uses a structured stdout envelope. Exit `2` means a usage error and exit `1` an
  operational failure, so a missing success envelope is not proof that nothing executed.
- The broker-bound SDK session CLI is the supported controller interface: discover and inspect
  sessions, then use the allowlisted lifecycle operations (`session.create`, `session.fork`,
  `session.resume`, `session.close`). `session.delete` is not allowed and endpoint reads are
  refused.
- Every logical prompt needs a fresh `op-ref`. `unknown` means uncertainty, never proof of
  non-execution: reconcile with the status lookup instead of replaying the prompt.
- A bounded wait that elapses reports a wait timeout and does not cancel the running turn. Long
  prompts are bounded by a progress-aware inactivity lease, not by heartbeats.
- Never scrape the TUI or open the raw session WebSocket. Pass values as argv items, not shell
  strings.

## Desktop control

`computer` is callable by default on Apple Silicon macOS and is supervisor-gated. It covers the
primary display only, has no window target, and its input is global and unscoped. A disabled or
suspended controller returns a stable `COMPUTER_*` error; a missing Accessibility or Screen
Recording permission returns `COMPUTER_PERMISSION_REQUIRED`. Control is not isolation: the kill
switch stops future input but does not restore focus or undo effects.

## Version drift and channels

- Stable `v0.19.2` is the pinned reference; nightly builds carry their own tags and may add or
  remove flags.
- Install with the installer pinned to a release tag rather than piping `main`, and record
  `gjc --version` in any automation or evidence bundle. Release assets cover Linux x64/arm64
  (glibc only), macOS arm64/x64, and Windows x64; the installer verifies published SHA-256
  checksums and runs a smoke test before replacing an existing binary.
- Integrate through the ACP provider (`gjc setup paseo`) or as a custom CLI agent in a host such
  as Orca. GJC ships no permission-bypass flag by design, so a host must not add one; its own
  gates stay in force.

## Skill author checklist

- [ ] Are required capabilities expressed as logical capabilities, then bound to tools that exist
      with the current flags and configuration?
- [ ] Does the skill treat planning output as a proposal that still needs explicit approval?
- [ ] Is the `ask` tool used only where an answer surface exists, with `ask.timeout`'s
      auto-selected answer never treated as consent?
- [ ] Is there a plain-text question and a stop when no answer surface exists?
- [ ] Are project MCP servers, project skills, hooks, and instructions inspected before trusting
      the repository?
- [ ] Are shell, interpreter, SSH, cron, and computer-control side effects gated separately from
      tool availability?
- [ ] Does controller-driven work use one fresh `op-ref` per prompt and treat `unknown` as
      uncertainty?
- [ ] Does verification compare the requested target and result with the actual runtime output?

## Verification

Before and after running a skill, confirm that (1) the discovered capabilities match the actual
calls, (2) questions cover only missing user-owned decisions, (3) the absence of an answer surface
leads to a plain-text question and a stop, and (4) side-effect boundaries before and after
approval were honored. Record the binary version, flags, configuration scope, and any capability
that could not be confirmed. This document alone cannot guarantee GJC's tool surface.

## Sources

| # | Source | What it establishes | Checked |
|---|---|---|---|
| 1 | [Gajae-Code README](https://github.com/Yeachan-Heo/gajae-code) | Identity, MIT license, beta status, plan-before-mutation approval wording, phone answers, controller and host integration, no permission-bypass flag | checked 2026-11-03 |
| 2 | [Releases](https://github.com/Yeachan-Heo/gajae-code/releases) | Stable `v0.19.2` on 2026-10-29; nightly channel | checked 2026-11-03 |
| 3 | [`docs/tools/ask.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/tools/ask.md) | `ask` schema, conditional registration, `ask.timeout` default and auto-select, headless deadline | checked 2026-11-03 |
| 4 | [`docs/tools/bash.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/tools/bash.md) | Working directory, timeout clamp, exclusive execution, interceptor rules, tmux guard limits | checked 2026-11-03 |
| 5 | [`docs/customization.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/customization.md) | Two authoritative scopes, MCP autoload, import-only Claude/Codex authority, hooks and skill precedence | checked 2026-11-03 |
| 6 | [`docs/hooks.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/hooks.md) | Fail-closed `tool_call`/`pre_tool_use` blocking | checked 2026-11-03 |
| 7 | [`docs/tools/computer.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/tools/computer.md) | Supervisor gating, primary-display scope, global input, stable error codes | checked 2026-11-03 |
| 8 | [`docs/install.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/install.md) | Install matrix, update channels, supported platforms | checked 2026-11-03 |

## Related documents

- [`../capability-contract.md`](../capability-contract.md) — shared capability, question, and
  approval rules.
- [`../sources.md`](../sources.md) — evidence ledger for this directory.
