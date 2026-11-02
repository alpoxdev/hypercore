# Codex CLI Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)

This is the runtime profile for skills executed on the Codex CLI (`codex`). Shared safety, question, and approval contracts follow [capability-contract.md](../capability-contract.md). Every rule here is checked against the official Codex documentation named in each row and listed in [`../sources.md`](../sources.md) (checked 2026-11-03). The local `skills/codex/SKILL.md` this profile once cited was removed in commit `d4f79f9` and is not evidence.

## Applicable scope and contract

- Apply this profile only when the Codex CLI is explicitly required. It is not a substitute for ordinary document writing or direct local editing.
- Use `codex exec` (`codex e`) for non-interactive work; top-level `codex "prompt"` opens the interactive TUI and is not an automation call.
- Start analysis, review, and planning under `--sandbox read-only`. Choose `--sandbox workspace-write` only when the user asked for workspace file modification.
- Keep `codex review` read-only; never combine it with a writable sandbox or a bypass flag.
- No capability or CLI option is approval for external, destructive, credential-using, or production work.
- Ask the user only when a decision or approval that materially changes safety or the artifact is missing, through a question surface confirmed in the session, or one plain-text sentence followed by a stop.

## Behavior verified against official documentation

| Area | Verified rule |
|---|---|
| Execution | `codex exec` is documented for "scripted or CI-style runs that should finish without human interaction"; `--json` prints newline-delimited events; `-o`/`--output-last-message` writes the final message to a file; `--output-schema` validates the final response against a JSON Schema; `--ephemeral` skips persisting session files |
| Review | `codex review` runs non-interactively and takes **exactly one** target: `--uncommitted`, `--base <branch>`, `--commit <sha>`, or a custom prompt. `--title` requires `--commit`. The CLI page states that review reports findings "without modifying your working tree" |
| Resume and fork | `codex exec resume [SESSION_ID]` continues non-interactively; `--last` picks the most recent session from the current directory and `--all` widens the search; `codex exec fork <SESSION_ID> [PROMPT]` copies a session into a new one; `codex resume` and `codex fork` do the same for interactive sessions |
| Sandbox | `--sandbox`/`-s` accepts `read-only`, `workspace-write`, `danger-full-access`; `--add-dir` adds writable roots; `-C`/`--cd` sets the working directory; sandboxing applies to every spawned command, not only built-in file operations |
| Approval flags | `-a`/`--ask-for-approval` accepts `on-request` or `never` only. `--approve-for-me`/`--not-so-yolo` enables automatic approval review with `on-request` plus `workspace-write` and conflicts with `--sandbox` and `--yolo`. `--yolo`/`--dangerously-bypass-approvals-and-sandbox` runs without approvals or sandboxing and is documented for externally hardened environments only |
| Worktrees | `--worktree` starts a managed Git worktree and is rejected for `resume`, `review`, `--ephemeral`, and `--ignore-user-config` |
| Plugins and MCP | `codex plugin` installs and lists plugins from configured marketplaces; `codex mcp` manages servers stored in `~/.codex/config.toml`; `codex plugin marketplace` manages sources |

The table records vendor documentation, not a complete feature or tool list for the installed CLI. If behavior differs at runtime, discover it with `codex --help` or the subcommand help and do not describe it as supported before confirmation.

## Approval model

Two layers, both required before gated work:

- **Sandbox mode** sets what is technically possible: where writes land and whether commands reach the network. The default `workspace-write` mode keeps network access off until `[sandbox_workspace_write] network_access = true` is set.
- **Approval policy** sets when Codex stops and asks: leaving the sandbox, using the network, or running commands outside a trusted set.

| Fact | Consequence for a skill |
|---|---|
| `approval_policy = "untrusted"` is retired: "Codex and ChatGPT Work no longer support" it, and the retired setting can prevent either client from starting | Never generate or recommend `untrusted`; use `on-request` plus a project `trust_level = "untrusted"` entry when stricter command approval is wanted |
| The `Auto` preset is `--sandbox workspace-write --ask-for-approval on-request` | This is the documented low-friction local default, not a permission grant |
| Destructive app/MCP tool calls always require approval when the tool advertises a destructive annotation, unless it advertises a read annotation | A capability being visible is still not consent |
| In-session `/permissions` changes the mode and shows the active sandbox and writable roots | Read it rather than guessing the current boundary |
| In non-interactive runs, an action that needs new approval fails and surfaces an error to the workflow | A scripted run must pre-approve what it needs or accept the failure; it cannot answer a prompt |

## Delegation and background work

| Surface | Verified behavior |
|---|---|
| Subagent workflows | Current releases spawn agents in parallel and collect their results into one response; `/subagents` switches between agent threads in the CLI. Subagent activity is enabled by default (`agents.enabled = true`) |
| Parallelism limit | `agents.max_concurrent_threads_per_session` caps open spawned-agent threads; leaving it unset lets Codex choose the default |
| Approval inheritance | "Subagents inherit the parent turn's current sandbox and approval settings, including changes made with `/permissions` or `--yolo`. A custom agent file can't replace those settings." |
| Approval from a subagent | In an interactive session an approval can arrive from an inactive thread and shows the source label; in non-interactive flows the action fails instead |
| Custom agents | Standalone TOML files in `~/.codex/agents/` (personal) or `.codex/agents/` (project); `name`, `description`, and `developer_instructions` are required; `model` and `model_reasoning_effort` in the file take precedence over the parent |
| Built-in agents | `default`, `worker`, `explorer`; a custom agent with the same name takes precedence |

Delegation must therefore be sized against a cap that the parent session owns, and a subagent cannot widen permissions. When a delegated unit needs approval that the parent did not grant, expect a failure, not a prompt.

## Skills, plugins, and hooks

| Surface | Verified behavior |
|---|---|
| Skill layout | A skill is a directory with `SKILL.md` (requires `name` and `description`) plus optional `scripts/`, `references/`, `assets/`, and `agents/openai.yaml` |
| Skill locations | `$CWD/.agents/skills`, `$CWD/../.agents/skills`, `$REPO_ROOT/.agents/skills`, `$HOME/.agents/skills`, `/etc/codex/skills`, and bundled system skills. Symlinked folders are followed |
| Invocation | Explicit: `$` mention in the CLI or `/skills`; implicit: matching on `description`, which `allow_implicit_invocation: false` in `agents/openai.yaml` disables |
| Skill context budget | The initial list uses at most 2% of the context window, or 8,000 characters when unknown; `skills.max_context_tokens` raises it to at most 10,000 |
| Disabling a skill | `[[skills.config]]` with exactly one selector (`path` or `name`) per entry in `~/.codex/config.toml`; the last matching entry wins |
| Plugins | A plugin bundles one or more skills, optionally with MCP server connections and presentation assets; `codex plugin add <plugin[@marketplace]>` installs from a marketplace |
| Hooks | Scripts or MCP tools at `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`, `SubagentStop`, `Stop`, `PreModelRequest`, `PostModelRequest`, `Interrupt`, `SessionStart`, `SubagentStart`, `SessionEnd`; configured in `~/.codex/hooks.json`, `<repo>/.codex/hooks.json`, config layers, or plugins |

- Non-managed hooks must be **reviewed and trusted** before they run, and trust is recorded against the hook's hash, so a changed hook is skipped until reviewed. `/hooks` performs that review; `--dangerously-bypass-hook-trust` skips it for one invocation.
- Project-local hooks load only when the project `.codex/` layer is trusted.
- A `PermissionRequest` hook can answer an approval request, which makes hooks a policy layer — not user consent. Report any hook that decides approvals.

## Goal mode and scheduling

- `/goal` in an interactive CLI session starts **Goal mode**: the goal text becomes both the first prompt and the completion criteria. Starting a goal does not grant broader access; it keeps the same sandbox and approval policy and pauses when it needs a decision.
- Scheduled tasks (formerly automations) are **not managed from the CLI**: the documentation states that the Codex CLI does not provide the Scheduled management interface and that creation and management happen in ChatGPT web or the desktop app. Do not claim a CLI scheduling flag.
- `codex cloud` browses and submits cloud chats from the terminal and `codex apply` applies the latest cloud diff locally, which is how work moves out of the local session rather than through a schedule.

## Read, write, and command safety

- Read: default to `codex exec --sandbox read-only`; review is likewise read-only.
- Write: use `workspace-write` only when the user stated an intent for Codex to modify the workspace. Do not use a bypass for ordinary edits.
- Commands: keep model, profile, and approval policy at defaults unless the user asks otherwise; add `--add-dir` only for required paths; use `--skip-git-repo-check` only outside a repository with explicit approval.
- Report authentication, sandbox, and session failures with the cause and the blocked state, and retry only within the scope the user wanted.

## Non-goals

- Do not infer or guarantee Codex's full option set, installation state, authentication method, or model list.
- Do not interpret a runtime capability as privilege escalation or user approval.
- Do not resume or fork a session, or modify files, without a user request.

## In-skill usage checklist

- [ ] Does the request explicitly require the Codex CLI or a separate session?
- [ ] Is the non-interactive call `codex exec`, and is analysis or review under `read-only`?
- [ ] Do writes, extra directories, and permission relaxation match user intent and the safety boundary, with no `untrusted` policy and no `--yolo` default?
- [ ] For delegation, is the concurrency cap respected and does the skill expect a failure instead of a prompt in non-interactive runs?
- [ ] Are newly added hooks and skills reviewed before use, with hook decisions reported rather than treated as consent?
- [ ] Are results, warnings, partial output, and authentication, session, or sandbox blocks reported together?
- [ ] For an important undecided item, is only a confirmed question surface used — otherwise one plain-text sentence followed by a stop?
