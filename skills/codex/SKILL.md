---
name: codex
description: Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing
---

@rules/routing.md

# Codex Skill

## Defaults

| Parameter | Default |
|-----------|---------|
| Model | `gpt-5.3-codex` |
| Reasoning effort | `high` |
| Sandbox | `read-only` |

Do NOT ask the user for model or reasoning effort unless explicitly requested.

## Routing

Use this skill when the request actually needs Codex CLI or a Codex session.

- Read [rules/routing.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/codex/rules/routing.md) before building a command when the request might be out of scope.
- Route away to another skill or direct editing when the user wants generic writing, runbook cleanup, or skill creation without needing Codex CLI itself.

## Running a Task

Read [references/recipes.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/codex/references/recipes.md) for concrete command recipes before switching sandboxes or resuming a session.

### Sandbox Mode Selection

| Mode | When to use |
|------|-------------|
| `read-only` (default) | Analysis, review, no file changes |
| `workspace-write` | User explicitly requests file edits |
| `danger-full-access` | Network or broad access needed |

### Command

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  "your prompt here" 2>/dev/null
```

**Always**:
- Use `--skip-git-repo-check`
- Append `2>/dev/null` to suppress thinking tokens (show stderr only when debugging)
- Confirm with user before using `--full-auto` or `--sandbox danger-full-access`

### Resuming a Session

```bash
echo "your prompt here" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

All flags go between `exec` and `resume`. Omit configuration flags when resuming unless the user requests them.
A resumed session inherits the original model, reasoning effort, and sandbox unless you intentionally change them.

### After Completion

- Inform the user: "You can resume this Codex session by saying 'codex resume'."
- Use `AskUserQuestion` to confirm next steps or whether to resume.
- When output includes warnings or partial results, summarize and ask how to adjust.

## Critical Evaluation

Treat Codex as a **colleague, not an authority**.

- **Trust your knowledge** when confident. Push back on incorrect claims directly.
- **Research disagreements** using WebSearch or docs before accepting Codex's claims.
- **Remember knowledge cutoffs** — Codex may not know about recent releases or API changes.

### When Codex is Wrong

1. State your disagreement clearly to the user
2. Provide evidence (your knowledge, web search, docs)
3. Optionally resume to discuss:
   ```bash
   echo "This is Claude following up. I disagree with [X] because [evidence]. What's your take?" | codex exec --skip-git-repo-check resume --last 2>/dev/null
   ```
4. Frame disagreements as discussions — either AI could be wrong
5. Let the user decide when there's genuine ambiguity

## Error Handling

- Report failures whenever `codex --version` or `codex exec` exits non-zero.
- When output includes warnings or partial results, summarize and ask how to adjust.
