# Routing Rules

Use Codex when the user explicitly wants Codex CLI, a Codex resume flow, or Codex as a coding collaborator.

Route away when the request does not actually need Codex CLI.

## In Scope

- Run `codex exec` for analysis, review, or refactoring help.
- Resume the latest Codex session with `codex exec ... resume --last`.
- Ask Codex to inspect or patch code when Codex CLI is part of the requested workflow.

## Route Away

- Create or refactor a skill.
- Rewrite a runbook or generic prose.
- Perform direct local edits when the user did not ask for Codex and Codex adds no clear value.

Use another skill or direct editing when the request does not actually need Codex CLI.

Do not build a Codex CLI command for generic writing, runbook rewrites, or skill creation.
Do not escalate sandbox scope just to force Codex into a task it does not own.
When Codex is the wrong tool, route away cleanly instead of running Codex anyway.
