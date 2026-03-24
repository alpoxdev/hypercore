# Routing Rules

Use Claude Code when the user explicitly wants the `claude` CLI, a separate Claude Code session, or Claude Code's non-interactive or resume flows.

Route away when the request does not actually need Claude Code CLI.

## In Scope

- Run `claude -p` for analysis, review, planning, or structured output.
- Resume or continue a Claude Code session with `--continue` or `--resume`.
- Ask Claude Code to inspect or patch code when the `claude` CLI is part of the requested workflow.
- Use `--add-dir` when the requested Claude Code run needs extra repository paths.

## Route Away

- Create or refactor a skill without needing the `claude` CLI.
- Rewrite generic prose, docs, or runbooks.
- Perform direct local edits when the user did not ask for Claude Code and it adds no clear value.
- Do Anthropic product research when the main job is fact-finding rather than running Claude Code.

Use another skill or direct editing when the request does not actually need the `claude` CLI.

Do not build a Claude Code command for generic writing, skill creation, or local edits that are easier to do directly.
Do not escalate to `--dangerously-skip-permissions` just to force Claude Code into a task it does not own.
When Claude Code is the wrong tool, route away cleanly instead of running it anyway.
