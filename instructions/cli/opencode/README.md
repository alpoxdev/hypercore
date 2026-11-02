# OpenCode Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)

## Scope

This is the adapter profile for user questions, approvals, tool discovery, and side-effect gating when a skill runs on OpenCode. Shared rules follow [`../capability-contract.md`](../capability-contract.md). The capabilities named here are the ones the first-party documentation states; anything else still needs runtime discovery.

## Authority and evidence

User and project instructions and the shared capability contract outrank this profile. Runtime observation is evidence for one run, not authority.

- Evidence: the official OpenCode documentation at `opencode.ai/docs` (pages last updated 2026-11-02, checked 2026-11-03) and the OpenCode 2 documentation tree at `opencode.ai/v2/docs`. The `skills/git-commit/SKILL.md` this profile once cited was removed in commit `d4f79f9`, so it is no longer evidence; the documentation below replaces the earlier "no evidence" state.
- OpenCode publishes two documentation trees with different config shapes. Treat `/docs` (OpenCode 1) as the default and read `/v2/docs` only when the installed major version is 2, because the names differ (`permission`/`bash`/`task` versus `permissions`/`shell`/`subagent`).

## Entry surface

| Logical capability | Implementation | Confirm before use |
|---|---|---|
| Non-interactive run | `opencode run [message..]`, with `--format json` for raw JSON events, `--model`/`-m`, `--agent`, `--file`/`-f`, `--variant`, `--dir`, `--port` | Installed version, authentication, provider, and working directory |
| Session continuation | `--continue`/`-c` for the last session, `--session`/`-s <id>`, `--fork` to branch when continuing | That the target session exists and is the intended one |
| Headless server | `opencode serve` exposes an HTTP API; `opencode run --attach <server-url>` reuses it to avoid MCP cold starts | Server address, auth (`--password`, `OPENCODE_SERVER_PASSWORD`), and whether a shared server is acceptable |
| Auto approval | `--auto` on the TUI or `opencode run` approves requests that no explicit `deny` rule covers | Explicit `deny` rules still apply, so this is a mode change, not an approval of gated work |

## Permission model

A permission rule resolves to `allow` (run without approval), `ask` (prompt), or `deny` (block).

| Item | OpenCode 1 (`/docs`) |
|---|---|
| Shape | `permission` object, with `*` for all tools and per-tool overrides; values may be a shorthand action or an object of pattern to action |
| Evaluation | Pattern match where "the last matching rule wins", so a catch-all `*` goes first and specific rules follow |
| Defaults | Permissive: most permissions default to `allow`, while `doom_loop` and `external_directory` default to `ask`. `read` allows by default but `.env`, `.env.*` ask and `.env.example` allows |
| Keys | `read`, `edit`, `glob`, `grep`, `bash`, `task`, `todowrite`, `skill`, `lsp`, `question`, `webfetch`, `websearch`, `external_directory`, `doom_loop` |
| Granularity | `read`, `edit`, `glob`, `grep`, `list`, `bash`, `task`, `external_directory`, `lsp`, `skill` accept pattern objects; the rest accept the shorthand only |
| Ask outcomes | `once` approves one request, `always` approves future matches for the rest of the session, `reject` denies |
| `.env` | `read` allows most paths but `.env`, `.env.*` ask and `.env.example` allows |

OpenCode 2 changes three things that matter to a skill: the array form `permissions: [{action, resource, effect}]` replaces the `permission` object; action names become `shell` and `subagent`; and the base policy is `{"action":"*","resource":"*","effect":"allow"}` followed by `.env` ask rules, while **a check with no matching rule resolves to `ask`**. Saved "Allow always" approvals become durable project-scoped allow rules that never override a configured `deny`, and "non-interactive clients must decide how to handle approval requests".

Consequences for a skill:

- A visible capability is not permission. The defaults are permissive, so gated work needs its own explicit user approval regardless of what the runtime would allow.
- `always` widens the boundary beyond the current request. Prefer `once` unless the user asked for the wider rule.
- `--auto` and a pre-existing `allow` rule remove the prompt, which means a gated action can run unattended. Check the effective rules with the current config before relying on the prompt.

## Question capability

- The `question` tool is documented: "This tool allows the LLM to ask the user questions during a task", and "Each question includes a header, the question text, and a list of options. Users can select from the provided options or type a custom answer." Multiple questions can be navigated before submitting.
- It is gated by the `question` permission key, so a `deny` hides it and `ask` prompts before use. The built-in `Plan` agent "Allows the question tool, so it can ask you clarifying questions"; in OpenCode 2 the `general` subagent denies questions.
- Availability caveat: `OPENCODE_ENABLE_QUESTION_TOOL` exists to "Enable the question tool for clients other than the CLI, app, and desktop". On those other clients the tool may be absent, so confirm exposure and fall back to one plain-text sentence.

## Delegation and background work

| Surface | Documented behavior |
|---|---|
| Agent types | Two types: primary agents (Build, Plan) and subagents (General, Explore); primary agents cycle with Tab |
| Custom agents | Markdown files in `~/.config/opencode/agents/` (global) or `.opencode/agents/` (project), or an `agent` object in `opencode.json`; the markdown file name becomes the agent name and `description` is required |
| Agent frontmatter | `description`, `mode` (`primary`/`subagent`/`all`), `model`, `temperature`, `permission`, and `steps` for the agentic iteration cap |
| Invocation | Automatically by a primary agent based on descriptions, or manually with `@<subagent>` |
| Delegation permission | `task` gates launching subagents; in OpenCode 2 the action is `subagent` |
| Nesting depth | `subagent_depth` defaults to `1`, which lets primary agents launch subagents but prevents further nesting; `0` disables subagent launches |
| Background subagents | Only behind `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS` ("Enable background subagent tasks"); not a default capability |

A skill that relies on parallel delegation must check `subagent_depth`, the `task` permission, and whether background subagents are enabled, rather than assuming the fan-out the plan describes.

## Plugins and skills

- A plugin is a JavaScript/TypeScript module that exports hook functions. Local files load from `.opencode/plugins/` (project) or `~/.config/opencode/plugins/` (global); npm packages are listed in `plugin` and installed with Bun at startup.
- Documented hooks are `tool.execute.before`, `tool.execute.after`, `shell.env`, `experimental.session.compacting`, plus `event` and `tool` for custom tools.
- Permission events (`permission.asked`, `permission.replied`) are **observable** through the `event` hook. No documented hook answers an approval, so a plugin cannot approve on the user's behalf. A plugin that throws in `tool.execute.before` blocks the call, which is a policy layer, not consent.
- OpenCode 2 moves plugins to a `plugins` array with `opencode plugin add|list|check|update|remove`, and two built-in policy plugins (`opencode.config.policy`, `opencode.provider.opencode`) ignore removal so a repository cannot switch policy enforcement off.
- Skills are `SKILL.md` folders found in `.opencode/skills/<name>/`, `~/.config/opencode/skills/<name>/`, `.claude/skills/<name>/`, `~/.claude/skills/<name>/`, `.agents/skills/<name>/`, and `~/.agents/skills/<name>/`; `name` and `description` are required and the name must match the directory. Loading is gated by the `skill` permission, where `deny` hides the skill and `ask` prompts.

## Side-effect gating

1. Derive the needed capability and scope from the shared contract and the current request.
2. Read the effective permission rules from the current config rather than assuming defaults; the defaults allow most actions, `.env` reads ask, and `--auto` or a saved `always` can remove the remaining prompt.
3. Treat `deny` as final: it is enforced even in auto mode, and no approval widens it.
4. Require explicit user approval for external, destructive, credential, and production side effects even when the runtime would permit them.
5. Record which rules were in force and which approval outcome (`once`, `always`, `reject`) was used in the final note.

## Skill author checklist

- [ ] Did you separate `scope`, `authority`, `evidence`, and `verification`, and link them to [`../capability-contract.md`](../capability-contract.md)?
- [ ] Is a question limited to a missing decision that materially affects safety or output, and did you confirm the `question` tool is exposed?
- [ ] When the question tool is unavailable, is there a plain-text fallback that stops before the gated action?
- [ ] Did you check the effective permission rules and avoid treating a permissive default or `--auto` as approval?
- [ ] Are delegation depth, the `task` permission, and background subagent availability checked before promising parallel work?
- [ ] Is every external, destructive, credential, or production effect approved separately and then re-verified against the target?
