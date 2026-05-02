---
name: gemini
description: "[Hyper] Use when the user wants to invoke Google Gemini CLI (`gemini`) for reasoning, research, or AI assistance. Trigger phrases: \"use gemini\", \"ask gemini\", \"run gemini\", \"call gemini\", \"gemini cli\", \"Google AI\", \"Gemini reasoning\", or when users request Google's Gemini models, research with web search, plan-mode review, or want to resume a previous Gemini session. Do not use for generic writing, runbook cleanup, or local edits that do not require the Gemini CLI."
compatibility: Requires Google Gemini CLI (`gemini`) v0.21.1 or later. Targets v0.40.0 behavior. Works only in environments where that CLI is installed and authenticated.
---

@rules/routing.md

# Gemini Skill

Wrap the official Google Gemini CLI for reasoning, research, plan-mode review, and session continuation. The CLI must be invoked headlessly with `-p` / `--prompt` — positional prompts open the interactive REPL.

## Defaults

| Parameter | Default |
|-----------|---------|
| Model selection | Use the Gemini CLI default (`-m auto`) unless the user explicitly asks for `-m pro`, `-m flash`, `-m flash-lite`, or a specific id |
| Approval mode | `--approval-mode default` (prompts on every tool call) |
| Headless mode | `-p` / `--prompt` |
| Resume target | `gemini --resume latest` (or `gemini -r` for the most recent) |
| Output format | `text` (use `--output-format json` only when the caller needs structured output) |

Do NOT specify `-m` unless the user explicitly requested a model. Auto routing picks Pro for reasoning and Flash for execution.

## Routing

Use this skill only when the request actually needs the Gemini CLI or a Gemini session.

- Read [rules/routing.md](rules/routing.md) before building a command when the request might be out of scope.
- Route away to direct editing or another skill when the user wants generic writing, runbook cleanup, or local edits without needing the Gemini CLI.

## CRITICAL: Headless Mode

**Always use `-p` / `--prompt`** for non-interactive Gemini runs. A positional prompt drops into the interactive REPL and blocks automation.

```bash
# Correct — non-interactive
gemini --approval-mode default -p "your prompt here"

# Interactive (do not use for automation)
gemini "your prompt here"
```

If you need to seed the prompt and then keep talking interactively, use `-i` / `--prompt-interactive` instead. `-p` is for one-shot, automated runs.

## Running a Task

Read [references/recipes.md](references/recipes.md) for concrete command recipes before changing approval modes, adding sandboxing, picking a model, or resuming a session.

### Approval Mode Selection

| Flag | When to use |
|------|-------------|
| `--approval-mode default` | General research, reasoning, and standard Gemini usage |
| `--approval-mode auto_edit` | Only when the user explicitly asks Gemini to edit files |
| `--approval-mode plan` | Read-only planning or analysis with no code modifications (write is restricted to Markdown in the plans directory) |
| `--approval-mode yolo` | Only after the user explicitly approves a full-auto run. Prefer this spelling — the bare `--yolo` flag is deprecated. |

### Command Discipline

- Start from `gemini --approval-mode default -p "your prompt here"`.
- Add `-m <pro|flash|flash-lite|auto|model-id>` only when the user explicitly asks for a specific Gemini model.
- Use `--approval-mode auto_edit` for normal edits instead of full auto-approve.
- Ask before using `--approval-mode yolo`. Prefer `--approval-mode auto_edit` or `--sandbox` first.
- Add `--sandbox` (`-s`) when the task is higher-risk or you want tighter local constraints.
- Pass extra workspaces with `--include-directories /path/a,/path/b` when Gemini needs context outside the current folder.
- Use `--output-format json` only when the caller will parse the response programmatically.

### Resuming a Session

```bash
gemini --resume latest -p "your follow-up prompt"
gemini --list-sessions
gemini --delete-session 2
```

`--resume` accepts `latest`, an index from `--list-sessions`, or a full session UUID. Inside an interactive session, use `/resume` to open the Session Browser and `/rewind` to step backward.

When resuming, keep the existing session behavior and do not change model or approval mode unless the user asks.

### After Completion

- Summarize the result, including any warnings or partial output.
- Tell the user they can resume with `gemini --resume latest` (or `gemini -r`).
- Ask whether to continue, adjust the prompt, or switch back to direct work.

## Critical Evaluation

Treat Gemini as a **colleague, not an authority**.

- **Trust your knowledge** when confident. Push back on incorrect claims directly.
- **Research disagreements** using current sources or docs before accepting Gemini's claims.
- **Remember knowledge cutoffs** — Gemini may not know about recent releases or API changes.
- When freshness matters, ask Gemini for current sources and verify important claims against docs or primary sources.
- Let the user decide when there is genuine ambiguity.

## Preflight Check

Before building any command, verify the CLI is installed and on PATH:

```bash
command -v gemini >/dev/null 2>&1 || { echo "gemini CLI not found"; exit 1; }
```

If the check fails, route to the install handler in **Error Handling** below instead of constructing a `gemini ...` command.

## Error Handling

- `command not found: gemini`: tell the user to install with `npm install -g @google/gemini-cli` (or `brew install gemini-cli`).
- Auth errors: run `gemini` and complete the sign-in flow, or set `GEMINI_API_KEY`. For Vertex AI, set `GOOGLE_API_KEY` and `GOOGLE_GENAI_USE_VERTEXAI=true`.
- 429 / rate limit: free tier is 60 req/min, 1000 req/day on Gemini 3 — wait or upgrade.
- 404 / model not found: retry without `-m`, or pick `pro`/`flash`/`flash-lite` from `gemini --help` and the official docs.
- 403 / access denied: check the active auth path and retry with a supported model or account configuration.
- Session not found: run `gemini --list-sessions`.
- Exit code `42` means input error (bad flag/prompt); `53` means turn limit exceeded.

## Version Notes

- Targets Gemini CLI v0.40.0 behavior; minimum supported v0.21.1 (Gemini 3 routing).
- `--yolo` is deprecated; the canonical form is `--approval-mode yolo`.
- Plan Mode is enabled by default; trigger explicitly with `--approval-mode plan` or `/plan` in-session.
- Headless mode auto-activates in non-TTY environments and whenever `-p` is supplied.
