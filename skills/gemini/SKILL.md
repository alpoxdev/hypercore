---
name: gemini
description: >-
  Use when the user wants to invoke Google Gemini CLI for reasoning tasks, research, and AI assistance.
  Trigger phrases: "use gemini", "ask gemini", "run gemini", "call gemini", "gemini cli", "Google AI",
  "Gemini reasoning", or when users request Google's AI models, research with web search, or want to
  continue a previous Gemini session.
---

# Gemini Skill

## Defaults

| Parameter | Default | Notes |
|-----------|---------|-------|
| Model | `gemini-3.1-pro-preview` | Use for ALL tasks |
| Approval mode | `default` | Prompts before edits |
| Sandbox | Disabled | Claude Code is trusted |
| Output | `text` | Use `--output-format json` for parsing |

**Fallback chain**: `gemini-3.1-pro-preview` → `gemini-2.5-pro` → `gemini-2.5-flash`

Do NOT ask the user for model unless they explicitly request a change.

## CRITICAL: Headless Mode

**Always use `-p`/`--prompt`** for non-interactive (headless) execution in Claude Code.

As of Gemini CLI v0.29.0+, positional prompts default to **interactive mode**. The `-p` flag is the correct headless flag.

```bash
# Correct: headless mode
gemini -m gemini-3.1-pro-preview -p "Design a microservices architecture"

# Wrong: opens interactive terminal
gemini -m gemini-3.1-pro-preview "Design a microservices architecture"
```

## Preview Features Warning

If `previewFeatures: true` in `~/.gemini/settings.json` with OAuth free tier, all requests route to Gemini 3.1 Pro, causing 404 errors. Fix:

```json
{ "general": { "previewFeatures": false } }
```

This skill automatically falls back to `gemini-2.5-flash` on 404 errors.

## Running a Task

### Command Template

```bash
gemini -m gemini-3.1-pro-preview -p "your prompt here"
```

### Approval Mode

| Mode | Flag | When to use |
|------|------|-------------|
| `default` (default) | _(none)_ | All tasks — safe default |
| `auto_edit` | `--approval-mode auto_edit` | User explicitly requests file editing |
| `plan` | `--approval-mode plan` | Read-only, no file modifications |
| `yolo` | `--approval-mode yolo` | Full auto-approval (confirm with user first) |

### Model Version Mapping

| User request | Model |
|--------------|-------|
| "use 3" / no version specified | `gemini-3.1-pro-preview` |
| "use 2.5" | `gemini-2.5-pro` |
| "use flash" | `gemini-2.5-flash` |

## Session Management

```bash
# Resume most recent session
gemini -r latest

# Resume with new prompt (headless)
gemini -r latest -p "Continue our discussion"

# Resume by index
gemini -r 3

# List sessions
gemini --list-sessions
```

After every command, use `AskUserQuestion` to confirm next steps or whether to resume.

## File Context

Pass file paths to Gemini instead of embedding content in prompts.

```bash
# Explicit @ syntax
gemini -m gemini-3.1-pro-preview -p "Analyze @src/auth.ts and @src/session.ts"

# Include additional directories
gemini -m gemini-3.1-pro-preview \
  --include-directories /shared/libs \
  -p "Review how auth module uses shared utilities"
```

See `references/file-context.md` for full guide.

## Error Handling

| Error | Action |
|-------|--------|
| `command not found: gemini` | Tell user to install Gemini CLI |
| "auth" / "authentication" | Run `gemini login` |
| 429 / "quota" / "rate limit" | Wait or upgrade; free tier: 60 req/min, 1000 req/day |
| 404 / "model not found" | Retry with fallback model |
| Session not found (`-r`) | Run `gemini --list-sessions` |
| 403 / "preview access required" | Disable `previewFeatures` or use `gemini-2.5-pro` |

## Critical Evaluation

Treat Gemini as a **colleague, not an authority**.

- Trust your own knowledge; push back on incorrect claims with evidence.
- Research disagreements via WebSearch before accepting Gemini's claims.
- Knowledge cutoffs apply — Gemini may not know recent API changes.
- Let the user decide when there's genuine ambiguity.

## Reference Files

| File | Contents |
|------|----------|
| `references/file-context.md` | File and directory context passing |
| `references/model-selection.md` | Model selection, fallback logic, access requirements |
| `references/command-patterns.md` | Command templates by use case |
| `references/session-workflows.md` | Multi-turn conversation patterns |
| `references/gemini-help.md` | Full CLI flag reference (v0.29.5) |
