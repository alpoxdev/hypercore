# Routing Rules

Use Gemini when the user explicitly wants Gemini CLI, a Gemini session, or Gemini as the collaborating model.

Route away when the task does not actually need Gemini CLI.

## In Scope

- Run Gemini CLI for research, reasoning, or AI assistance when the user asks for Gemini.
- Resume or inspect a Gemini session with `--resume` or `--list-sessions`.
- Ask Gemini to edit files only when the user explicitly wants Gemini to perform the edit.

## Route Away

- Generic runbook or prose cleanup when the user did not ask for Gemini.
- Direct local edits where Gemini adds no clear value.
- Skill creation or skill refactoring that does not require Gemini CLI itself.

Use direct editing or another skill when the request does not actually need Gemini CLI.

Do not build a Gemini CLI command for generic writing, runbook rewrites, or unrelated local edits.
Do not escalate to `auto_edit` or `--yolo` when Gemini is the wrong tool.
When Gemini is not the right tool, route away cleanly instead of running Gemini anyway.
