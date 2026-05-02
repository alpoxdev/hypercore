# Routing Rules

Use Claude Code when the user explicitly wants the `claude` CLI, a separate Claude Code session, or one of Claude Code's non-interactive (`-p`), `--bare`, or session-resume flows.

Route away when the request does not actually need the `claude` CLI.

## In Scope

- Run `claude -p` for analysis, review, planning, or structured (`json` / `stream-json` / `--json-schema`) output.
- Resume or continue a Claude Code session with `--continue` (`-c`), `--resume` (`-r`) by ID or display name, `--from-pr`, `--session-id` (UUID), or `--fork-session`.
- Ask Claude Code to inspect or patch code when the `claude` CLI is part of the requested workflow, including pre-approved tool sets via `--allowedTools` / `--disallowedTools` / `--tools`.
- Use `--bare` for a CI / scripted run that must not pick up local hooks, plugins, MCP servers, auto memory, or CLAUDE.md.
- Use `--add-dir` when the requested Claude Code run needs extra repository paths (file access only — `.claude/` config beyond `.claude/skills/` is not loaded from added directories).
- Choose a permission mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions`.
- Authenticate or rotate credentials with `claude auth login`, `claude auth status`, `claude auth logout`, or `claude setup-token` (long-lived OAuth for CI).

## Route Away

- Create or refactor a skill without needing the `claude` CLI.
- Rewrite generic prose, docs, or runbooks.
- Perform direct local edits when the user did not ask for Claude Code and it adds no clear value.
- Do Anthropic product research when the main job is fact-finding rather than running Claude Code.

Use another skill or direct editing when the request does not actually need the `claude` CLI.

Do not build a Claude Code command for generic writing, skill creation, or local edits that are easier to do directly.
Do not escalate to `--dangerously-skip-permissions` (or `--permission-mode bypassPermissions`) just to force Claude Code into a task it does not own; both require explicit user approval and an isolated environment such as a container or VM.
When Claude Code is the wrong tool, route away cleanly instead of running it anyway.
