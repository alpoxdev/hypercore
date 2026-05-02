---
name: codex
description: "[Hyper] Use when the user explicitly wants OpenAI Codex CLI (`codex`) for an isolated session, non-interactive run, code review, or session resume. Trigger phrases: 'use codex', 'ask codex', 'run codex', 'codex exec', 'codex review', 'continue the last codex session', or 'use OpenAI CLI to inspect or fix this repo'."
compatibility: Requires OpenAI Codex CLI (`codex`) and works only in environments where that CLI is installed.
---

@rules/routing.md

# Codex Skill

## Defaults

| Parameter | Default |
|-----------|---------|
| Model selection | Use Codex CLI default unless the user explicitly asks for `-m` / `--model` |
| Profile | Use CLI default unless the user explicitly asks for `-p` / `--profile` |
| Sandbox | `--sandbox read-only` for analysis, `--sandbox workspace-write` only when the user asks Codex to edit |
| Approval policy | Interactive mode only — use CLI default unless the user explicitly asks for `-a` / `--ask-for-approval` |
| Headless mode | `codex exec` |
| Resume target | `codex exec resume --last` for the latest non-interactive run, `codex resume --last` for the latest interactive session |

Do NOT ask the user for model, profile, or approval policy unless explicitly requested.

## Routing

Use this skill when the request actually needs Codex CLI or a separate Codex session.

- Read [rules/routing.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/codex/rules/routing.md) before building a command when the request might be out of scope.
- Route away to direct editing or another skill when the user wants generic writing, documentation cleanup, or local edits without needing the `codex` CLI itself.

## Examples

Positive triggers:

- "Use Codex to review this repository and summarize the risks."
- "Run `codex exec` and analyze this architecture."
- "Continue the last Codex session and ask it to finish the patch."
- "Run `codex review` against the base branch and list the blocking issues."

Negative triggers:

- "Rewrite this runbook for readability."
- "Create a new skill for our repo."

Boundary trigger:

- "Research Codex sandbox modes and tell me what they do."
  Use this skill only if the user wants the `codex` CLI involved; otherwise route to research or direct documentation work.

## Critical: Non-Interactive Mode

Always use the `codex exec` subcommand for non-interactive Codex runs.
Calling `codex "prompt"` without a subcommand starts the interactive TUI.

```bash
# Non-interactive
codex exec --sandbox read-only "your prompt here"

# Interactive TUI
codex "your prompt here"
```

`codex exec` reads the prompt from the argument or stdin and prints the result to stdout when finished.

## Running a Task

Read [references/recipes.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/codex/references/recipes.md) for concrete command recipes before changing sandbox mode, resuming a session, or adding extra directories.

### Sandbox Mode Selection

| Flag | When to use |
|------|-------------|
| `--sandbox read-only` | General analysis, review, planning, or structured output with no file writes |
| `--sandbox workspace-write` | Only when the user explicitly wants Codex to modify files in the workspace |
| `--sandbox danger-full-access` | Only after explicit approval, and only in isolated environments |
| `--dangerously-bypass-approvals-and-sandbox` | Only after explicit approval, and only in environments that are externally sandboxed |

### Approval Policy Selection (Interactive Mode Only)

`-a` / `--ask-for-approval` is only available on the top-level interactive `codex` command, not on `codex exec`. For non-interactive runs, control safety through `--sandbox` instead.

| Flag | When to use |
|------|-------------|
| `-a untrusted` | Interactive only — Codex must escalate to the user for any non-trusted command |
| `-a on-request` | Interactive only — Codex asks for approval when it decides it needs to |
| `-a never` | Interactive only — Codex never asks; pair only with a restrictive `--sandbox` |

When the user does not specify, omit `-a` and let the CLI default apply.

### Command Discipline

- Start from `codex exec --sandbox read-only "your prompt here"`.
- Add `-m <model>` or `-p <profile>` only when the user explicitly asks.
- Use `--json` only when the user wants machine-readable JSONL output.
- Use `--output-schema <FILE>` when the user wants the final response to follow a JSON schema.
- Use `--add-dir <path>` when the task needs files outside the launch directory; pair with a writable sandbox only when edits are explicitly requested.
- Use `-C <dir>` / `--cd <dir>` to set the working root when the user names a different directory.
- Ask before using `--dangerously-bypass-approvals-and-sandbox`.
- Prefer `--sandbox workspace-write` over bypassing approvals for normal file edits.

### Resuming a Session

```bash
codex exec resume --last "continue the previous task"
codex exec resume <session-id> "continue with this follow-up"
codex resume --last       # interactive picker for the latest TUI session
```

Use `codex exec resume --last` for the latest non-interactive run.
Use `codex exec resume <session-id>` when the user wants a specific session or the latest run is not the right one.
When resuming, keep the existing session behavior unless the user explicitly asks to change the model, profile, sandbox, or approval policy.
Use `codex fork --last` only when the user wants to branch from the existing session instead of reusing it.

### Code Review

```bash
codex review --uncommitted "review the local changes and list blocking issues"
codex review --base main "review this branch against main and summarize risks"
codex review --commit <sha> "review only the changes in this commit"
```

`codex review` is read-only by design; do not pair it with `--sandbox workspace-write` or `--dangerously-bypass-approvals-and-sandbox`.

### After Completion

- Summarize the result, including any warnings or partial output.
- Tell the user they can resume with `codex exec resume --last` or `codex exec resume <session-id>`.
- Ask whether to continue, adjust the prompt, or switch back to direct work.

## Critical Evaluation

Treat Codex as a colleague, not an authority.

- Trust your own grounded knowledge when you are confident.
- Verify disagreements with current docs or primary sources before accepting a claim.
- Remember that a separate Codex session can still be wrong or stale.
- Let the user decide when there is genuine ambiguity.

## Error Handling

- `command not found: codex`: tell the user OpenAI Codex CLI is not installed.
- Auth errors: use `codex login` or check the configured OpenAI credential path.
- Sandbox blocks: retry with the appropriate `--sandbox` only when the user wants that behavior.
- Approval blocks (interactive `codex` only): retry with a less restrictive `-a` only when the user wants that behavior.
- Session not found: run `codex exec resume` (without `--last`) to use the picker, or switch to `codex resume --last` for the latest interactive session.
- Invalid flag or model errors: check `codex --help` or `codex exec --help` and retry with supported options.
- Outside a Git repo: add `--skip-git-repo-check` only when the user has accepted that the run will operate without repo guardrails.
