---
name: claude-code
description: "[Hyper] Use when the user explicitly wants Anthropic Claude Code CLI (`claude`) for an isolated session, non-interactive run, or session resume. Trigger phrases: \"use claude code\", \"ask claude\", \"run claude\", \"continue the last claude session\", or \"use Anthropic's CLI to inspect or fix this repo\"."
compatibility: Requires Claude Code CLI (`claude`) and works only in environments where that CLI is installed.
---

@rules/routing.md

# Claude Code Skill

## Defaults

| Parameter | Default |
|-----------|---------|
| Model selection | Use Claude Code CLI default unless the user explicitly asks for `--model` |
| Effort | Use CLI default unless the user explicitly asks for `--effort` |
| Permission mode | `--permission-mode default` |
| Headless mode | `-p` / `--print` |
| Resume target | `claude --continue` for the latest session in the current directory, `claude --resume` for a specific session |

Do NOT ask the user for model or effort unless explicitly requested.

## Routing

Use this skill when the request actually needs Claude Code CLI or a separate Claude Code session.

- Read [rules/routing.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/claude-code/rules/routing.md) before building a command when the request might be out of scope.
- Route away to direct editing or another skill when the user wants generic writing, documentation cleanup, or local edits without needing the `claude` CLI itself.

## Examples

Positive triggers:

- "Use Claude Code to review this repository and summarize the risks."
- "Run `claude` in print mode and analyze this architecture."
- "Continue the last Claude Code session and ask it to finish the patch."

Negative triggers:

- "Rewrite this runbook for readability."
- "Create a new skill for our repo."

Boundary trigger:

- "Research Claude Code permissions and tell me what they do."
  Use this skill only if the user wants the `claude` CLI involved; otherwise route to research or direct documentation work.

## Critical: Print Mode

Always use `-p` / `--print` for non-interactive Claude Code runs.
Positional prompts start the interactive REPL instead.

```bash
# Non-interactive
claude --permission-mode default -p "your prompt here"

# Interactive REPL
claude "your prompt here"
```

`-p` skips the workspace trust dialog, so use it only in directories you trust.

## Running a Task

Read [references/recipes.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/claude-code/references/recipes.md) for concrete command recipes before changing permission modes, resuming a session, or adding extra directories.

### Permission Mode Selection

| Flag | When to use |
|------|-------------|
| `--permission-mode default` | General Claude Code usage with normal approval prompts |
| `--permission-mode acceptEdits` | Only when the user explicitly wants Claude Code to modify files |
| `--permission-mode plan` | Read-only analysis or planning with no file changes or shell execution |
| `--dangerously-skip-permissions` | Only after explicit approval, and only in isolated environments |

### Command Discipline

- Start from `claude --permission-mode default -p "your prompt here"`.
- Add `--model <model>` or `--effort <level>` only when the user explicitly asks.
- Use `--output-format json` only when the user wants structured machine-readable output.
- Use `--add-dir <path>` when the task needs files outside the launch directory.
- Ask before using `--dangerously-skip-permissions`.
- Prefer `--permission-mode acceptEdits` over bypassing permissions for normal file edits.

### Resuming a Session

```bash
claude --continue -p "continue the previous task"
claude --resume <session-id> -p "continue with this follow-up"
```

Use `--continue` for the latest conversation in the current directory.
Use `--resume` when the user wants a specific session or the current-directory session is not the right one.
When resuming, keep the existing session behavior unless the user explicitly asks to change the model, effort, or permission mode.
Add `--fork-session` only when the user wants to branch from the existing session instead of reusing it.

### After Completion

- Summarize the result, including any warnings or partial output.
- Tell the user they can resume with `claude --continue` or `claude --resume <session-id>`.
- Ask whether to continue, adjust the prompt, or switch back to direct work.

## Critical Evaluation

Treat Claude Code as a colleague, not an authority.

- Trust your own grounded knowledge when you are confident.
- Verify disagreements with current docs or primary sources before accepting a claim.
- Remember that a separate Claude Code session can still be wrong or stale.
- Let the user decide when there is genuine ambiguity.

## Error Handling

- `command not found: claude`: tell the user Claude Code CLI is not installed.
- Auth errors: use `claude auth` or the configured Anthropic credential path.
- Permission blocks: retry with an appropriate `--permission-mode` or adjust allowed/disallowed tools only when the user wants that behavior.
- Session not found: use `claude --resume` without an ID to pick a session, or switch to `claude --continue` for the current directory.
- Invalid flag or model errors: check `claude --help` and retry with supported options.
