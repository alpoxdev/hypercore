---
name: gemini
description: >-
  Use when the user wants to invoke Google Gemini CLI for reasoning tasks, research, and AI assistance.
  Trigger phrases: "use gemini", "ask gemini", "run gemini", "call gemini", "gemini cli", "Google AI",
  "Gemini reasoning", or when users request Google's AI models, research with web search, or want to
  continue a previous Gemini session.
---

@rules/routing.md

# Gemini Skill

## Defaults

| Parameter | Default |
|-----------|---------|
| Model selection | Use the Gemini CLI default unless the user explicitly asks for `-m` |
| Approval mode | `--approval-mode default` |
| Headless mode | `-p` / `--prompt` |
| Resume target | `gemini --resume latest` |

Do NOT ask the user for model unless explicitly requested.

## Routing

Use this skill when the request actually needs Gemini CLI or a Gemini session.

- Read [rules/routing.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/gemini/rules/routing.md) before building a command when the request might be out of scope.
- Route away to direct editing or another skill when the user wants generic writing, runbook cleanup, or local edits without needing Gemini CLI.

## CRITICAL: Headless Mode

**Always use `-p` / `--prompt`** for non-interactive Gemini runs. Positional prompts start interactive mode.

```bash
# Correct
gemini --approval-mode default -p "your prompt here"

# Interactive mode
gemini "your prompt here"
```

## Running a Task

Read [references/recipes.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/gemini/references/recipes.md) for concrete command recipes before changing approval modes, adding sandboxing, or resuming a session.

### Approval Mode Selection

| Flag | When to use |
|------|-------------|
| `--approval-mode default` | General research, reasoning, and standard Gemini usage |
| `--approval-mode auto_edit` | Only when the user explicitly wants Gemini to edit files |
| `--approval-mode plan` | Read-only planning or analysis with no file modifications |
| `--yolo` | Only after the user explicitly approves a full-auto run |

### Command Discipline

- Start from `gemini --approval-mode default -p "your prompt here"`.
- Add `-m <model>` only when the user explicitly asks for a specific Gemini model.
- Use `--approval-mode auto_edit` for normal file edits instead of `--yolo`.
- Ask before using `--yolo`. Prefer `--approval-mode auto_edit` or `--sandbox` first.
- When the task is higher-risk or you want tighter local constraints, add `--sandbox` instead of jumping straight to `--yolo`.

### Resuming a Session

```bash
gemini --resume latest -p "your follow-up prompt"
gemini --list-sessions
```

When resuming, keep the existing session behavior and do not change model or approval mode unless the user asks.

### After Completion

- Summarize the result, including any warnings or partial output.
- Tell the user they can resume with `gemini --resume latest`.
- Ask whether to continue, adjust the prompt, or switch back to direct work.

## Critical Evaluation

Treat Gemini as a **colleague, not an authority**.

- **Trust your knowledge** when confident. Push back on incorrect claims directly.
- **Research disagreements** using current sources or docs before accepting Gemini's claims.
- **Remember knowledge cutoffs** — Gemini may not know about recent releases or API changes.
- When freshness matters, ask Gemini for current sources and verify important claims against docs or primary sources.
- Let the user decide when there's genuine ambiguity.

## Error Handling

- `command not found: gemini`: tell user to install Gemini CLI.
- Auth errors: start `gemini` and complete the sign-in flow, or configure `GEMINI_API_KEY` / `GOOGLE_API_KEY`.
- 429 / rate limit: free tier is 60 req/min, 1000 req/day — wait or upgrade.
- 404 / model not found: retry without `-m` or choose a supported model from `gemini --help` or the official docs.
- 403 / access denied: check the active auth path and retry with a supported model or account configuration.
- Session not found: run `gemini --list-sessions`.
