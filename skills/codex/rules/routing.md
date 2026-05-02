# Routing Rules

Use Codex when the user explicitly wants the `codex` CLI, a separate Codex session, or Codex's non-interactive, review, or resume flows.

Route away when the request does not actually need Codex CLI.

## In Scope

- Run `codex exec` for analysis, review, planning, or structured output.
- Run `codex review` for diff-based code review against a base branch, commit, or uncommitted changes.
- Resume or continue a Codex session with `codex exec resume --last`, `codex exec resume <session-id>`, or `codex resume --last`.
- Ask Codex to inspect or patch code when the `codex` CLI is part of the requested workflow.
- Use `--add-dir` when the requested Codex run needs extra repository paths.

## Route Away

- Create or refactor a skill without needing the `codex` CLI.
- Rewrite generic prose, docs, or runbooks.
- Perform direct local edits when the user did not ask for Codex and it adds no clear value.
- Do OpenAI product research when the main job is fact-finding rather than running Codex.

Use another skill or direct editing when the request does not actually need the `codex` CLI.

Do not build a Codex command for generic writing, skill creation, or local edits that are easier to do directly.
Do not escalate to `--sandbox danger-full-access` or `--dangerously-bypass-approvals-and-sandbox` just to force Codex into a task it does not own.
When Codex is the wrong tool, route away cleanly instead of running it anyway.
