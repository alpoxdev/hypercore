# Claude Code Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)

## Scope

This is the execution profile for **a skill that explicitly requested the Claude Code CLI (`claude`)**. It is not the default profile for ordinary document writing or direct local editing. Shared contracts follow [`../capability-contract.md`](../capability-contract.md).

## Authority and evidence

- **Authority:** user intent and project-local rules win. This document does not grant permissions; it names where each logical capability lands and what must be confirmed first.
- **Verified evidence:** the flags, permission modes, commands, subagents, hooks, skills, plugins, workflows, and scheduling below are checked against the official pages listed in [`../sources.md`](../sources.md) (checked 2026-11-03). The local `skills/claude-code/SKILL.md` this profile once cited was removed in commit `d4f79f9` and is not evidence.
- **Runtime-dependent items:** installation, authentication, plan and admin policy, the flags actually available, and every structured question/approval surface must be confirmed in the execution session. `claude --help` does not list every flag, and the CLI reference states that a flag's absence from `--help` does not mean it is unavailable.
- Runtime output is **evidence**, not authority. If it conflicts with user intent or local rules, stop and report.

## Entry surface

| Logical capability | Implementation on Claude Code | Confirm before use |
|---|---|---|
| Non-interactive run | `claude -p "<prompt>"` (`--print`); `--output-format text\|json\|stream-json`, `--input-format text\|stream-json` | Installation, authentication, working directory, and that the wrapper does not append a positional prompt without `-p` (that opens an interactive REPL) |
| Session continuation | `claude -c` (`--continue`) for the most recent conversation in the current directory; `claude -r <id\|name>` (`--resume`) for a specific one; `--fork-session` gives the resumed copy a new ID | Whether the target session exists and whether resuming changes settings; `--continue` skips sessions created by `-p`, the Agent SDK, and sessions whose first prompt was `/loop` unless `-p` is also passed |
| Output shape | `--json-schema` for validated JSON, `--include-partial-messages`, `--verbose`, `--forward-subagent-text` (v2.1.211+) | Which output modes the installed version supports |
| Bounded run | `--max-turns`, `--max-budget-usd` (print mode only; subagent spend counts toward the cap) | Whether a spend or turn cap is required by policy |
| Isolation | `--restricted` (v2.1.248+), `--bare`, `--safe-mode`, `--worktree`/`-w`, `--tmux` | Which environment the run must be confined to |

## Permission modes

Six modes are documented, with no mode deprecated. Manual is the UI label; `default` is the config value and `manual` is an alias (v2.1.200+).

| Mode | Runs without asking | Notes |
|---|---|---|
| `default` | Reads only | The mode the CLI labels **Manual** |
| `acceptEdits` | Reads, file edits, and common filesystem commands (`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`) inside working directories or `additionalDirectories` | Auto-approval does not extend outside those paths |
| `plan` | Reads, plus classifier-approved commands when auto mode is available | Edits stay blocked until the plan is approved |
| `auto` | Everything, with a classifier model reviewing actions first | The built-in starting mode for interactive terminal and VS Code sessions from v2.1.283; the docs state it reduces prompts but **does not guarantee safety** |
| `dontAsk` | Reads inside working directories and pre-approved tools; anything that would prompt is denied | Never appears in the Shift+Tab cycle; intended for CI |
| `bypassPermissions` | Everything, including writes to protected paths | Cannot be entered from a session that did not start with it enabled; documented for isolated containers and VMs only |

- Start mode precedence: `--permission-mode`/`--dangerously-skip-permissions`, then `permissions.defaultMode`, then the built-in default. `"auto"` and `"bypassPermissions"` in project settings files do not take effect; the session falls back to the built-in default or Manual.
- From v2.1.302, `claude -p` and Agent SDK runs with no mode set start in Manual, and calls needing approval are **denied** unless approved by an allow rule, a hook, a `canUseTool` callback, or `--permission-prompt-tool`.
- Layered rules override the mode: deny rules block in every mode including `bypassPermissions`; allow rules have no effect in `bypassPermissions`.
- No mode auto-approves ask rules, organization ask-set connector tools, tools that require user interaction, recognized critical-path `rm`/`rmdir`, cross-session messaging safeguards, or reads outside working directories when `permissions.blockReadsOutsideWorkingDirectories` is on.

## Question and approval gate

- **Structured question capability exists.** The permission-mode documentation names the built-in `AskUserQuestion` tool as a tool that requires user interaction and is not auto-approved in any mode. Treat it as the `ask_user` implementation, but confirm exposure in the session before relying on the name.
- **Non-interactive approval routing.** `--permission-prompt-tool mcp__<server>__<tool>` delegates permission prompts to an MCP tool; `--permission-prompts none` (v2.1.259+) denies prompts when nobody can answer; `--allowedTools` pre-approves patterns. A prompt tool cannot approve an MCP tool marked as requiring user interaction — that result is converted to a deny.
- **Gated work still needs separate approval.** A visible capability, an allow rule, or an auto-mode classifier is not the user's approval for external, destructive, credential-using, or production work.
- If no structured surface is confirmed, ask one plain-text sentence and stop before the gated action.

## Delegation, background work, and loops

| Surface | What it is | Capability consequence |
|---|---|---|
| Subagents | Files in `.claude/agents/` (project) or `~/.claude/agents/` (user), `--agents` JSON for one session, plugin `agents/`, or managed settings; only `name` and `description` are required | `delegate` |
| Subagent concurrency | 20 concurrent subagents per session by default (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`); nesting up to three layers (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `1` disables) | A delegation fan-out must be sized against this cap; the docs say the error tells Claude not to retry |
| Background subagents | Subagents start in the background by default; their results arrive as a completion notification in a later turn. `/subtask` returns a result into the current conversation, `/fork` copies the conversation into a separate background session, `/batch` fans out into isolated worktrees | `delegate` plus `background` — never report a background result as complete before the notification |
| Hooks | 33 documented events with five handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`), configured in settings files, plugin `hooks/hooks.json`, skill frontmatter, or subagent frontmatter | An `Approval`-shaped event (`PermissionRequest`, `PermissionDenied`) exists, but a hook decision is **runtime policy**, not user consent |
| Dynamic workflows | A JavaScript script the runtime executes in the background, separate from the conversation: 16 concurrent agents by default (up to 256), 1,000 agents per run, no mid-run user input, no filesystem or shell access from the script itself | `delegate` at scale; not an approval channel and not interactive |
| Session loops | `/loop [interval] [prompt]` (alias `/proactive`): `s`/`m`/`h`/`d` units, 5-field cron underneath, at most 50 tasks per session, recurring tasks expire after 7 days; `loop.md` at `.claude/loop.md` then `~/.claude/loop.md` replaces the built-in prompt | `loop` — a repeating action needs an explicit stop condition and its own approval boundary |
| Cloud schedules | `/schedule` (alias `/routines`) saves a prompt, repositories, and connectors as a cloud scheduled task; it runs on Anthropic-managed infrastructure, is in research preview, and rejects cadences more often than hourly | `schedule` — a cloud task outlives the session, so it needs explicit approval before creation |
| Goal persistence | `/goal [condition\|clear]` keeps the agent working across turns until the condition is met | `persist` — a goal is a stop condition, not an approval |

## Extension surfaces

| Surface | Contract | Gate |
|---|---|---|
| Skills | `SKILL.md` under `.claude/skills/<name>/` (project), `~/.claude/skills/`, a `--add-dir` directory, or a plugin `skills/`; all frontmatter is optional; `disable-model-invocation: true` keeps a skill manual-only; `allowed-tools` grants tool use without asking for the invoking turn only | Installing a skill is not approval for what it instructs; read it before running |
| Commands | Custom commands have been merged into skills — `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy`; prefer a skill for new work | Same as skills |
| Plugins | A plugin is a directory of skills, agents, hooks, a hooks module ("mod"), MCP servers, and LSP servers, with `.claude-plugin/plugin.json`; most come from a marketplace, which is a repository with `.claude-plugin/marketplace.json`, not a hosted store; `--plugin-dir`/`--plugin-url` load a plugin for one session as `<name>@inline` | A plugin adds executable surface — hooks and MCP servers — so loading one is a scope change, not a convenience |
| Tool inventory | `--tools` restricts built-in tools (`""`, `default`, or a name list); `--allowedTools`/`--disallowedTools` set allow and deny rules; `--disallowedTools "mcp__*"` is needed to remove MCP tools | Confirm the effective inventory in the session; do not assert a fixed list |

## Read, write, and command safety

- Read: stay within the requested scope and allowed directories; use plan mode for analysis without file changes.
- Write: create, modify, move, or copy only when the user requested that change; `acceptEdits` is not a substitute for that request.
- Commands: keep commands minimal and use `-p` for automation. `--dangerously-skip-permissions` and `bypassPermissions` are not defaults; use them only under explicit approval and isolation.
- Report warnings, partial output, and authentication, session, or permission blockers with the result.

## Deprecated or removed surfaces

- `--remote` is a deprecated alias for `--cloud`; `--enable-auto-mode` was removed in v2.1.111 (use `--permission-mode auto`).
- `/pr-comments` was removed in v2.1.91, `/ultraplan` is removed in favour of plan mode, and `/vim` was removed in v2.1.92.
- `/usage-credits` was previously `/extra-usage`; `/schedule` was previously routines and keeps the `/routines` alias.

## Skill usage checklist

- [ ] Does the request explicitly require the Claude Code CLI or a separate session?
- [ ] For non-interactive use, is the call `claude -p`, with `--continue`/`--resume` chosen deliberately?
- [ ] Is the permission mode the minimum that satisfies the request, with deny rules and protected paths understood?
- [ ] Was a structured question surface confirmed before use, and does no gated action run before the answer?
- [ ] For delegation, are concurrency, background notification, and workflow limits accounted for rather than assumed?
- [ ] Does any loop, schedule, or goal carry an explicit stop condition and its own approval?
- [ ] Does the result include warnings, partial output, and authentication, session, or permission blockers?
