---
name: codex
description: Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing
---

# Codex Skill Guide

## Defaults

**Default model**: `gpt-5.3-codex`
**Default reasoning effort**: `high`
**Default sandbox**: `read-only`

Do NOT ask the user for model or reasoning effort unless they explicitly request a change.

## Running a Task

1. Use the defaults above unless the user specifies otherwise.
2. Select sandbox mode based on the task:
   - `read-only` (default): analysis, review, no file changes
   - `workspace-write`: when user explicitly requests file edits
   - `danger-full-access`: when network or broad access is needed
3. Assemble the command:
   ```bash
   codex exec --skip-git-repo-check \
     -m gpt-5.3-codex \
     --config model_reasoning_effort="high" \
     --sandbox read-only \
     "your prompt here" 2>/dev/null
   ```
4. Always use `--skip-git-repo-check`.
5. When continuing a previous session, use resume syntax:
   ```bash
   echo "your prompt here" | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
   All flags must be inserted between `exec` and `resume`. When resuming, do NOT add configuration flags unless the user explicitly requests them.
6. **IMPORTANT**: Always append `2>/dev/null` to suppress thinking tokens (stderr). Only show stderr if the user explicitly requests it or debugging is needed.
7. Run the command, capture output, and summarize the result.
8. **After Codex completes**, inform the user: "You can resume this Codex session at any time by saying 'codex resume' or asking me to continue."

### Quick Reference

| Use case | Sandbox mode | Key flags |
| --- | --- | --- |
| Read-only review or analysis | `read-only` | `--sandbox read-only 2>/dev/null` |
| Apply local edits | `workspace-write` | `--sandbox workspace-write --full-auto 2>/dev/null` |
| Network or broad access | `danger-full-access` | `--sandbox danger-full-access --full-auto 2>/dev/null` |
| Resume recent session | Inherited from original | `echo "prompt" \| codex exec --skip-git-repo-check resume --last 2>/dev/null` |
| Run from another directory | Match task needs | `-C <DIR>` plus other flags `2>/dev/null` |

## Following Up

- After every `codex` command, use `AskUserQuestion` to confirm next steps or decide whether to resume.
- When resuming, pipe the new prompt via stdin. The resumed session automatically uses the same model, reasoning effort, and sandbox from the original session.

## Critical Evaluation of Codex Output

Treat Codex as a **colleague, not an authority**.

### Guidelines

- **Trust your own knowledge** when confident. Push back directly on incorrect claims.
- **Research disagreements** using WebSearch or documentation before accepting Codex's claims.
- **Remember knowledge cutoffs** - Codex may not know about recent releases or API changes.
- **Don't defer blindly** - evaluate suggestions critically, especially regarding model names, library versions, and evolving best practices.

### When Codex is Wrong

1. State your disagreement clearly to the user
2. Provide evidence (your knowledge, web search, docs)
3. Optionally resume the session to discuss:
   ```bash
   echo "This is Claude (<your current model name>) following up. I disagree with [X] because [evidence]. What's your take?" | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
4. Frame disagreements as discussions — either AI could be wrong
5. Let the user decide when there's genuine ambiguity

## Error Handling

- Stop and report failures whenever `codex --version` or `codex exec` exits non-zero.
- Before using high-impact flags (`--full-auto`, `--sandbox danger-full-access`) ask for user confirmation unless already given.
- When output includes warnings or partial results, summarize and ask how to adjust.
