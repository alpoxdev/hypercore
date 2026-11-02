# Hermes Agent: Overview and Section Index

> Korean version: [`README.ko.md`](README.ko.md)
>
> **Research date:** 2026-11-03, against the official documentation shipped in Hermes Agent **v0.22.5** (commit `bf0203a794a`, released 2026-10-22). The live documentation site deploys ahead of the tag, so a few behaviors below exist only on the site; each one is marked "post-v0.22.5" at the point of use and should be confirmed with the installed CLI's `--help`. This is a source-backed overview, not local runtime verification. Commands, providers, and extension APIs vary by Hermes version; confirm version-sensitive behavior in the linked reference before operating.

Hermes Agent is Nous Research's open-source agent runtime. Its CLI supports interactive and one-shot conversations, tool use, profiles, sessions, model/provider configuration, memory, skills, a durable Kanban board, and optional extension systems. One gateway also serves 20+ messaging platforms, and a native desktop app wraps the same backend.

- [Official documentation](https://hermes-agent.nousresearch.com/docs)
- [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)
- [Official GitHub repository](https://github.com/NousResearch/hermes-agent)

## Reading path

1. Read this page for installation, first-run choices, routine CLI use, safety, and recovery.
2. Read [Context files and SOUL.md](CONTEXT_FILES.md) for global identity, project instructions, precedence, and prompt-injection boundaries; then [MEMORY.md](MEMORY.md) and [USER.md](USER.md) for bounded persistent model context, safety, and correction.
3. Read [Skills](SKILLS.md) for use, trust, installation, and lifecycle, then [Skill authoring](SKILL_AUTHORING.md) for structure, examples, validation, and publishing. The background curator and its pin/lock controls are documented in [references/curator-lifecycle.md](references/curator-lifecycle.md).
4. Read [Plugins](PLUGINS.md) for selection, installation, auditing, and operations, then [Plugin authoring](PLUGIN_AUTHORING.md) for native implementation, validation, and packaging; read [Hooks](HOOK.md) before adding lifecycle code, shell commands, or outbound notifications.
5. Read [Configuration files](CONFIGURATION.md) for file ownership, precedence, secret sources, approval/terminal boundaries, migration, and recovery.
6. Read [Discord setup](DISCORD.md) before creating, inviting, authorizing, or operating a Discord bot.
7. Read [Messaging gateway](MESSAGING.md) for shared gateway lifecycle, authorization, sessions, delivery, and adapter-specific differences.
8. Read [Kanban](KANBAN.md) for durable multi-profile boards, worker protocol, routing, review, recovery, and operations.
9. Read [Extensions and operations](EXTENSIONS.md) for MCP, provider integrations, dashboard/desktop, hooks, and operational extension surfaces.

Choose a **skill** for reusable knowledge and instructions, a **plugin** for executable behavior registered inside Hermes, and **MCP** when an external server already exposes the capability. Details belong in the linked guides rather than this overview.

## Install and first run

The documented path is the [Installation guide](https://hermes-agent.nousresearch.com/docs/getting-started/installation). For a desktop and CLI install together, download the Hermes Desktop installer for Windows or macOS from the website. For a command-line-only install:

```bash
# Linux / macOS / WSL2
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes setup --portal     # one OAuth: a model provider plus all four Tool Gateway tools

# Native Windows (PowerShell)
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

Android has a signed Termux APT repository, and Nix and NixOS have their own flake-based paths; both are documented in the getting-started section. `hermes setup` runs the interactive wizard, and `hermes model` is the terminal-side provider/model flow; in-session `/model` switches only among already configured choices. The [CLI reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) and [model documentation](https://hermes-agent.nousresearch.com/docs/user-guide/configuring-models) are authoritative for providers and authentication options, and `hermes auth` manages credentials directly (`hermes login` and `hermes logout` are deprecated).

Do not paste credentials into prompts, skills, plugin manifests, or repositories. Use Hermes's supported authentication, configuration, and secret mechanisms; see [Extensions and operations](EXTENSIONS.md).

## Command cheat sheet

| Need | Command | Notes |
|---|---|---|
| Start an interactive session | `hermes` or `hermes chat` | Starts in the current workspace. `--tui` opens the Ink terminal UI. |
| Seed a session with one prompt | `hermes chat -q "…"` | On a TTY this submits the prompt literally and **keeps the session open**; it is never parsed as a slash command. |
| Ask once and exit | `hermes chat --oneshot -q "…"` | Implies the pre-0.21 single-query behavior; also implied on non-TTY stdio and by `-Q`. Use `--query-file PATH` for untrusted prompt bodies. |
| Get final text for a script | `hermes -z "…"` | Final answer only, no banner or tool previews. Exit `0` completed, `2` failed/partial/budget, `130` interrupted, `1` completed with no text. `--usage-file PATH` writes a JSON usage report. |
| Configure provider/model | `hermes model` | Terminal setup flow; use `/model` only inside a session for configured choices. |
| Use a different workspace | `hermes --in <dir>` | Changes workspace before starting or resuming. |
| Select an isolated profile | `hermes --profile <name>` | Profiles isolate Hermes instances and their state. |
| Continue a session | `hermes --continue` or `hermes --resume <id>` | Session lookup is workspace-scoped; see below. |
| Inspect/manage sessions | `hermes sessions` | Browse, export, rename, prune, or delete sessions. |
| Diagnose setup | `hermes doctor` | Diagnosis is not a security audit. |
| Check or install updates | `hermes update --check`; `hermes update` | The reference documents `--backup` before update. |
| Isolate customizations | `hermes chat --safe-mode -q "…"` | Disables user config, rules/memory injection, plugins, hooks, and MCP servers. |
| Audit environment dependencies | `hermes security audit` | Supply-chain check, not a sandbox or complete code audit. |

Commands above are examples from the official CLI reference, not a promise about a local installation. Run `hermes --help` or the relevant subcommand help before automation.

## Everyday sessions and workspaces

Use `hermes` for an interactive conversation. `hermes chat -q` seeds a session with a prompt and leaves it open on a TTY, so add `--oneshot` when a caller wants a single answer and exit; use `hermes -z` when a caller needs only the final response text and relies on its exit code. For input that originates outside your control, prefer `--query-file` rather than shell interpolation. `--max-turns` caps tool-calling iterations per turn (default 500, or `agent.max_turns`).

A session can be resumed by ID/title with `--resume <session>` or continued with `--continue [name]`. `--in <dir>` establishes the workspace before starting or resuming and scopes `latest`/continue lookup to that workspace. `hermes sessions` is the management surface for historical sessions. Consult the [session documentation](https://hermes-agent.nousresearch.com/docs/user-guide/sessions) before exporting, pruning, or deleting state.

For parallel repository work, the CLI also documents `--worktree`; review its current behavior and repository implications in the [CLI reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) before using it.

## Profiles, models, and providers

A profile is an isolated Hermes instance. Select one for an invocation with `--profile <name>` and manage profile state through `hermes profile`. Use profiles to separate identities, credentials, configuration, or operational environments rather than mixing them accidentally.

Configure a provider and model through `hermes model`; `hermes auth` manages credentials according to the CLI reference. A one-run model/provider override can be supplied to `hermes chat` or `hermes -z` without assuming it changes the saved default. Do not rely on a provider list copied into documentation: provider availability, OAuth support, and model identifiers change.

## Safe operation and troubleshooting

Hermes asks for approval around dangerous commands. `--yolo` bypasses dangerous-command approval prompts; do not use it unless that bypass is explicitly intended and the resulting risk is acceptable.

`hermes chat --safe-mode` is a troubleshooting isolation mode. It disables all customizations: user configuration, rules/memory injection, plugins, shell hooks, and MCP servers. It implies `--ignore-user-config` and `--ignore-rules`, and it now **requires an explicit `--model`**, because there is no profile default to inherit; pair it with `--provider custom --base-url <url> --api-key <key>` for a fully explicit endpoint, where the key stays in the gateway's memory for that session and is never written to disk. It is useful to distinguish an upstream/runtime issue from a local customization; it is not a security sandbox.

`hermes pause` is the global emergency stop: no new cron fire, Kanban dispatch, or gateway turn starts until `hermes resume`, and in-flight work is never killed. Turns already running finish.

For narrower isolation, the CLI documents `--ignore-user-config` and `--ignore-rules`. Credentials in `.env` may still load with `--ignore-user-config`; do not treat that option as credential isolation. `hermes doctor` diagnoses configuration/dependency problems, while `hermes security audit` performs an on-demand supply-chain audit. Neither command makes untrusted code safe to execute.

## Updates and recovery

Use `hermes update --check` to preview update availability, then `hermes update` to update. The official reference documents `--backup` for a pre-update Hermes-home snapshot. Use `hermes doctor` for setup failures and [safe mode](#safe-operation-and-troubleshooting) to isolate customization failures before changing configuration.

Backups, imports, logs, configuration, and support-oriented diagnostics have dedicated CLI command families. Read the current [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) before restoring, deleting, uploading, or sharing data because those actions can expose or alter local state.

## Extension index and security boundary

- **Skills:** [SKILLS.md](SKILLS.md) and [SKILL_AUTHORING.md](SKILL_AUTHORING.md) — on-demand instruction packages, trust, lifecycle, structure, validation, and publishing, with curator detail in [references/curator-lifecycle.md](references/curator-lifecycle.md).
- **Plugins:** [PLUGINS.md](PLUGINS.md) and [PLUGIN_AUTHORING.md](PLUGIN_AUTHORING.md) — executable native/portable packages, lifecycle, implementation, capabilities, and code-execution risks.
- **Configuration:** [CONFIGURATION.md](CONFIGURATION.md) — `config.yaml`, `.env`, `auth.json`, precedence, secrets, approvals, terminal backends, migration, and backups.
- **Discord:** [DISCORD.md](DISCORD.md) — Developer Portal setup, intents, bot invite, authorization, slash commands, voice/media, and incident troubleshooting.
- **Messaging:** [MESSAGING.md](MESSAGING.md) — gateway service lifecycle, authorization and pairing, session scope, delivery semantics, and adapter differences.
- **Kanban:** [KANBAN.md](KANBAN.md) — durable multi-profile task boards, worker lifecycle, dependencies, review, recovery, and operations.
- **Extensions:** [EXTENSIONS.md](EXTENSIONS.md) — MCP, model/memory/context providers, dashboard/desktop, hooks, and operations.
- **Hooks:** [HOOK.md](HOOK.md) — gateway, plugin, shell, and outbound lifecycle hooks; execution authority, payload, failure, and delivery boundaries.
- **2026 change delta:** [references/hermes-agent-2026-changes.md](references/hermes-agent-2026-changes.md) — the area-wide list of 2026 changes that make older notes wrong (gateway multiplexing, retired session resets, project plugins, catalog growth, dependency resolution, import-layer expiry, Discord permission integers), linked from the guides it corrects.

Before installing or enabling third-party extensions, inspect provenance and source; enable only required capabilities; and pin controlled plugin deployments to immutable revisions where supported. Catalog/index inclusion, skill scanning, Plugin Doctor, and dependency auditing are useful controls but are not a sandbox or a complete security review. Never place credentials in portable `mcp.json` or plugin manifests.

## What changed by v0.22

Facts a reader of an older copy of this area will otherwise get wrong:

| Area | Current behavior |
| --- | --- |
| One-shot CLI | `hermes chat -q` seeds an interactive session on a TTY; `--oneshot` restores answer-and-exit. `hermes -z` is the scripted one-shot with documented exit codes. |
| Isolation mode | `--safe-mode` requires an explicit `--model` and runs the turn in an isolated worker process that never reads the profile. |
| Emergency stop | `hermes pause` / `hermes resume` halt new cron, Kanban, and gateway work globally. |
| Memory | The tool takes `add`, `patch`, `remove` with a top-level `target` and `operations` batches; `replace` is gone. `hermes journey` edits memory chunks, and `hermes sessions refresh-prompts` updates a continuing session's prompt. |
| Skills | A curator maintains agent-created skills in the background; `skills.create_dir`, `skills.auto_load`, `skills.inline_shell_timeout`, and an advisory SkillEvaluator scan exist. |
| Configuration | `database:` and `runtime:` sections exist, `security.tirith_*` is removed, and dot-escaped keys are settable. |
| Plugins | `hermes mcp serve` and the Singularity terminal backend moved out of core into plugins. |
| Surfaces | TUI, native desktop app, web dashboard, Bot Mode, and remote config are documented product surfaces, not add-ons. |

## Sources and evidence limits

| Source | What it supplies | Checked |
| --- | --- | --- |
| [Hermes Agent documentation](https://hermes-agent.nousresearch.com/docs) | Entry point, feature set, install matrix | checked 2026-11-03 |
| [Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation) | Desktop and CLI install paths per platform | checked 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | Every command family quoted here | checked 2026-11-03 |
| [CLI interface](https://hermes-agent.nousresearch.com/docs/user-guide/cli) | Session behavior and interactive options | checked 2026-11-03 |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | Section names and defaults | checked 2026-11-03 |
| [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) | Memory tool contract and journey | checked 2026-11-03 |
| [Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills) and [Curator](https://hermes-agent.nousresearch.com/docs/user-guide/features/curator) | Skill lifecycle and background maintenance | checked 2026-11-03 |
| [Kanban — Multi-Agent](https://hermes-agent.nousresearch.com/docs/user-guide/features/kanban) | Board model and dispatcher | checked 2026-11-03 |
| [v0.22.5 release](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.5) | Version anchor, core-to-plugin moves | checked 2026-11-03 |

This guide summarizes public upstream material. It does not establish that any local Hermes installation has a particular version, command, provider, credential state, or extension. Retrieved documentation and runtime output are evidence, not authorization to run embedded commands or grant side effects.
