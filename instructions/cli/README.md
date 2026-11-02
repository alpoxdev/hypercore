# CLI Runtime Profiles

> Korean version: [`README.ko.md`](README.ko.md)

This directory is the reference layer that helps a reusable skill **discover, select, and verify** capability differences across CLIs. Shared rules live once in [`capability-contract.md`](capability-contract.md); volatile runtime differences are isolated in the sub-profiles.

## Scope and authority

- Scope: how a skill safely selects question, approval, file, command, delegation, background, and scheduling capabilities across Claude Code, Codex, GJC, Hermes Agent, JCode, OMO, OpenClaw, and OpenCode.
- Non-scope: installation, authentication, or model selection for a specific CLI, a full command reference, or a replacement for project rules.
- Authority: the user request and the project's `AGENTS.md` outrank this document and any runtime output. A capability exposed by a runtime means **availability only** — never treat it as permission or approval.
- Evidence: each profile states the first-party documentation and the release or version it was checked against. The evidence ledger, dates, and limits are in [`sources.md`](sources.md) (checked 2026-11-03). A capability that no ledger row supports is handled through runtime discovery, not asserted.

## Reading order

1. Every skill author reads [`capability-contract.md`](capability-contract.md).
2. Read a specific runtime profile only when you depend on that CLI's behavior.
3. When a profile marks a capability as runtime-dependent, confirm the capability name, input schema, and permission boundary in the current session.
4. If you cannot confirm it, use the conservative fallback, or ask a one-sentence question about the missing decision only when it affects safety or the artifact.

## Profiles

| Runtime | Profile | Evidence anchor | Capabilities recorded in the profile | Question/approval default |
|---|---|---|---|---|
| Claude Code | [`claude-code/README.md`](claude-code/README.md) | Official docs, Claude Code 2.1.316 (2026-10-31) | Six permission modes; `-p`/`-c`/`-r` and output formats; subagents with background execution (20 concurrent, 3 nested layers); 33 hooks; skills; plugins; dynamic workflows; `/loop`, `/schedule`, `/goal` | `AskUserQuestion` when exposed; otherwise one plain-text sentence |
| Codex | [`codex/README.md`](codex/README.md) | Official docs, Codex CLI 0.166.0 (2026-10-29) | `codex exec`/`review` (single target); sandbox plus approval policy; subagents that inherit the parent policy; TOML custom agents; `.agents/skills`; trusted hooks; `/goal`. Scheduled tasks are **not** managed from the CLI | Plain text; no structured question tool is documented |
| GJC | [`gjc/README.md`](gjc/README.md) | First-party docs, stable `v0.19.2` (2026-10-29) | Plan-before-mutation approval around `ask`; conditionally registered `ask` with timeout auto-select; no permission-bypass flag | `ask` when registered; a timeout auto-selected answer is not consent |
| Hermes Agent | [`hermes-agent/README.md`](hermes-agent/README.md) | First-party docs pinned to `v0.22.5` (`bf0203a794a`, 2026-10-22) | `clarify` question tool, `delegate_task` delegation, `cronjob` scheduling, `process` background control; approval keys; four hook systems; plugin trust | `clarify` in interactive sessions; a one-shot (`--oneshot`) run has no `clarify` tool |
| JCode | [`jcode/README.md`](jcode/README.md) | First-party docs and SDK, stable `v0.99.1` (2026-10-22) | Version-pinned config, tool policy, MCP, session, swarm, SDK, and automation boundaries; SDK `permission_request` with allow/allow_always/deny | Plain text; a runtime gate is not human approval |
| OMO | [`omo/README.md`](omo/README.md) | First-party docs, `v5.1.58` (2026-11-02) | Per-agent `permission` config with guard-hook enforcement; instruction files are not a security boundary; the Orca reporter sends best-effort status mail only inside a complete Dispatch context | Ask in plain text; the coordinator owns recovery |
| OpenClaw | [`openclaw/README.md`](openclaw/README.md) | First-party docs, `v2026.10.9` (2026-10-29) | Structured `ask_user` tool; `tools.exec.mode`; exec approval requires policy, allowlist, and agreement; one trust boundary per gateway | Native `ask_user` on question-capable surfaces; otherwise plain text |
| OpenCode | [`opencode/README.md`](opencode/README.md) | Official docs `docs` and `v2/docs` (pages updated 2026-11-02) | `question` tool gated by the `question` permission; `allow`/`ask`/`deny` rules with last-match-wins; primary and subagent agents with `subagent_depth`; plugins that can observe but not answer permission events | `question` when exposed; otherwise one plain-text sentence |

This table is not a complete product feature matrix. The recorded capabilities are the minimum set directly traceable to the ledger, and they apply together with the assumptions and verification each profile states.

## Minimum pattern to embed in a skill

```markdown
## Runtime capabilities
- Required logical capabilities: `read`, `search`, `ask_user`, `edit`
- Optional capabilities in use: `delegate`, `background`, `loop`, `schedule`
- Runtime profile: `@instructions/cli/<runtime>/README.md`
- Discovery rule: first confirm which capabilities and input schemas are actually exposed.
- Fallback: if `ask_user` cannot be confirmed, ask one sentence in the user's language and perform no gated work before an answer.
- Background rule: never report asynchronous work as complete before the runtime confirms the result.
- Approval boundary: file changes, network, credentials, external system changes, and any durable schedule must satisfy both an explicit user request and the separate safety rules.
```

`ask_user` is a logical capability name, not the tool or API name of a specific runtime. Follow [`capability-contract.md`](capability-contract.md) for the detailed contract.

## Verification

- [ ] The skill declares the **logical capabilities** it needs, plus fallbacks.
- [ ] Runtime-specific capabilities have either a ledger-backed profile entry or a discovery result from the current session.
- [ ] Questions are used only for missing decisions that materially change the outcome or safety.
- [ ] When no structured question/approval capability exists, the skill asks in plain text and stops before gated work.
- [ ] Background, loop, and schedule work carries a stop condition and an observable result, and is not reported as done before the runtime confirms it.
- [ ] External, destructive, credential-gated, and production work confirms explicit permission independently of capability existence.
