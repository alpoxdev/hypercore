---
name: claude-code
description: "[Hyper] Use when the user explicitly wants Anthropic Claude Code CLI (`claude`) for an isolated session, non-interactive (`-p`) run, session resume by ID or name, or a CI-friendly `--bare` invocation. Trigger phrases: \"use claude code\", \"ask claude\", \"run claude\", \"continue the last claude session\", \"resume the auth-refactor claude session\", or \"use Anthropic's CLI to inspect or fix this repo\"."
compatibility: Requires Claude Code CLI (`claude`) and works only in environments where that CLI is installed.
---

@rules/routing.md

# Claude Code Skill

Source of truth: <https://code.claude.com/docs/en/cli-reference>.

## Defaults

| Parameter | Default |
|-----------|---------|
| Model selection | Use Claude Code CLI default unless the user explicitly asks for `--model` |
| Effort | Use CLI default unless the user explicitly asks for `--effort` |
| Permission mode | `--permission-mode default` |
| Headless mode | `-p` / `--print` |
| CI / scripted run | Add `--bare` so the call ignores local hooks, plugins, MCP, and CLAUDE.md |
| Resume target | `claude --continue` (`-c`) for the latest session in the current directory; `claude --resume` (`-r`) for a session by ID or display name |

Do NOT ask the user for model or effort unless explicitly requested.

## Routing

Use this skill when the request actually needs the `claude` CLI or a separate Claude Code session.

- Read [rules/routing.md](rules/routing.md) before building a command when the request might be out of scope.
- Route away to direct editing or another skill when the user wants generic writing, documentation cleanup, or local edits without needing the `claude` CLI itself.

## Examples

Positive triggers:

- "Use Claude Code to review this repository and summarize the risks."
- "Run `claude` in print mode and analyze this architecture."
- "Continue the last Claude Code session and ask it to finish the patch."
- "Resume the `auth-refactor` claude session and apply the next fix."
- "Use `claude --bare -p` so this CI step does not pick up local hooks."

Negative triggers:

- "Rewrite this runbook for readability."
- "Create a new skill for our repo."

Boundary trigger:

- "Research Claude Code permissions and tell me what they do."
  Use this skill only if the user wants the `claude` CLI involved; otherwise route to research or direct documentation work.

## Critical: Print Mode

Always use `-p` / `--print` for non-interactive Claude Code runs. Positional prompts without `-p` start the interactive REPL instead, so a script that omits `-p` will hang waiting for a TTY.

```bash
# Non-interactive (headless / SDK)
claude --permission-mode default -p "your prompt here"

# Interactive REPL (initial prompt only — does NOT exit)
claude "your prompt here"
```

`-p` is the canonical SDK/CI entrypoint. The CLI was previously called "headless mode"; the `-p` flag is unchanged.

## Bare Mode for CI and Scripts

Add `--bare` for any scripted or CI invocation. It skips auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md so the call returns the same result on every machine. Bare mode also skips the OAuth keychain, so it requires `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, or an `apiKeyHelper` passed through `--settings`.

```bash
ANTHROPIC_API_KEY=$KEY claude --bare -p "Summarize the diff" --allowedTools "Read"
```

For pipelines that need a long-lived OAuth token instead of an API key, generate one with `claude setup-token` and export it as `CLAUDE_CODE_OAUTH_TOKEN` (note: bare mode does NOT read `CLAUDE_CODE_OAUTH_TOKEN` — use `ANTHROPIC_API_KEY` or `apiKeyHelper` when `--bare` is set).

## Running a Task

Read [references/recipes.md](references/recipes.md) for concrete command recipes before changing permission modes, resuming a session, restricting tools, or adding extra directories.

### Permission Mode Selection

Six modes are supported. Pick the loosest mode the task safely allows.

| Flag | When to use |
|------|-------------|
| `--permission-mode default` | General Claude Code usage with normal approval prompts |
| `--permission-mode plan` | Read-only analysis or planning with no file changes or shell execution |
| `--permission-mode acceptEdits` | The user explicitly wants Claude Code to write files (also auto-approves common filesystem commands like `mkdir`, `mv`, `cp`) |
| `--permission-mode auto` | Long autonomous tasks where prompt fatigue matters; a server-side classifier blocks risky actions but does not replace review |
| `--permission-mode dontAsk` | Locked-down CI: only `permissions.allow` rules and the read-only command set may run; everything else is auto-denied |
| `--permission-mode bypassPermissions` | Containers / VMs only — equivalent to `--dangerously-skip-permissions`, requires explicit user approval, and offers no protection against prompt injection |

Auto mode requires Claude Code v2.1.83+ and is gated by plan, admin policy, model, and provider; if the CLI reports it as unavailable, do not retry.

### Command Discipline

- Start from `claude --permission-mode default -p "your prompt here"`.
- Add `--model <model>` or `--effort <level>` only when the user explicitly asks.
- Use `--output-format` only when the user wants something other than `text`. Supported values: `text` (default), `json`, `stream-json`.
- For schema-validated structured output, pair `--output-format json` with `--json-schema '<JSON Schema>'`.
- Add `--max-turns <N>` and/or `--max-budget-usd <dollars>` for autonomous print-mode runs that must not loop forever.
- Use `--fallback-model <name>` in print mode when a graceful degrade beats a hard failure on overload.
- Use `--add-dir <path>` when the task needs files outside the launch directory. (`--add-dir` grants file access; it does NOT load `.claude/` configuration from the added directory, except for `.claude/skills/`.)
- Restrict tools with `--allowedTools`, `--disallowedTools`, or `--tools` (use `--tools ""` to disable all built-ins, `--tools "default"` for all, or a comma list like `"Bash,Edit,Read"`).
- Add to / replace the system prompt with `--append-system-prompt`, `--append-system-prompt-file`, `--system-prompt`, or `--system-prompt-file`.
- Load MCP servers with `--mcp-config <file-or-json>`; add `--strict-mcp-config` to ignore every other MCP source.
- Ask before using `--dangerously-skip-permissions`. Prefer `--permission-mode acceptEdits` for normal file edits.

### Resuming a Session

```bash
# Latest session in the current directory
claude --continue -p "continue the previous task"   # short: claude -c -p "..."

# Specific session by ID or by display name
claude --resume "auth-refactor" -p "continue with this follow-up"   # short: -r
claude --resume <session-id> -p "continue with this follow-up"

# Pin a UUID so a script always reuses the same session
claude --session-id 550e8400-e29b-41d4-a716-446655440000 -p "..."   # must be a valid UUID

# Resume sessions linked to a pull request
claude --from-pr 123 -p "address review comments"
```

Use `--continue` for the latest conversation in the current directory.
Use `--resume` for a specific session by **ID or by display name** (set with `--name` / `-n`, or by `/rename` mid-session).
Use `--session-id` only with a real UUID — the CLI rejects other strings.
When resuming, keep the existing session's behavior unless the user explicitly asks to change the model, effort, or permission mode.
Add `--fork-session` only when the user wants to branch from the existing session instead of reusing it.

### After Completion

- Summarize the result, including any warnings or partial output.
- Tell the user they can resume with `claude --continue` (`-c`), `claude --resume <id-or-name>` (`-r`), or `claude --from-pr <pr>`.
- Ask whether to continue, adjust the prompt, or switch back to direct work.

## Critical Evaluation

Treat Claude Code as a colleague, not an authority.

- Trust your own grounded knowledge when you are confident.
- Verify disagreements with current docs or primary sources before accepting a claim.
- Remember that a separate Claude Code session can still be wrong or stale.
- Let the user decide when there is genuine ambiguity.

## Authentication

The CLI reads credentials in this precedence order: cloud provider env vars (`CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY`) → `ANTHROPIC_AUTH_TOKEN` → `ANTHROPIC_API_KEY` → `apiKeyHelper` → `CLAUDE_CODE_OAUTH_TOKEN` → subscription OAuth from `/login`.

- Browser login: run `claude` once and follow the prompt, or `claude auth login` (use `--console` for Console billing, `--sso` to force SSO).
- Inspect / sign out: `claude auth status` or `/status` from inside a session; `claude auth logout` or `/logout` to clear credentials.
- Long-lived OAuth for CI: `claude setup-token` prints a token; export it as `CLAUDE_CODE_OAUTH_TOKEN` (not read by `--bare`).
- Direct API: set `ANTHROPIC_API_KEY` for `X-Api-Key`, `ANTHROPIC_AUTH_TOKEN` for `Authorization: Bearer` through a gateway.

## Error Handling

- `command not found: claude`: tell the user Claude Code CLI is not installed; they can run `claude install stable` after setup.
- Auth errors: confirm precedence above (e.g. an unset `unset ANTHROPIC_API_KEY` may be needed when a subscription is active), then re-run `claude auth login` or `claude auth status` to confirm.
- Permission blocks: retry with an appropriate `--permission-mode` (`plan` for read-only, `acceptEdits` for file edits) or adjust `--allowedTools` / `--disallowedTools`. Do not escalate to `--dangerously-skip-permissions` without explicit user approval.
- Session not found: run `claude --resume` without an argument to pick from a list, or switch to `claude --continue` for the current directory; `--session-id` requires a UUID.
- Auto-mode unavailable: this is gated by plan, admin policy, model, and provider — it is not a transient outage; fall back to `default` or `acceptEdits`.
- Invalid flag or model errors: check `claude --help`, then re-run with supported options. `claude --help` does not list every flag — consult the CLI reference for the full list.
