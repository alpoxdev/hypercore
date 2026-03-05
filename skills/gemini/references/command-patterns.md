# Gemini CLI Command Patterns

**Version**: v0.29.5+ | **Last Updated**: 2026-02-16

## Basic Invocation (Headless)

```bash
# Standard headless invocation — always use -p in Claude Code
gemini -m gemini-3.1-pro-preview -p "Explain the observer pattern"

# With stdin
echo "function add(a, b) { return a + b; }" | gemini -m gemini-3.1-pro-preview -p "Explain this code"
```

**Note**: Positional prompts default to interactive mode. Always use `-p`/`--prompt` for headless execution in Claude Code.

## Model Selection

```bash
# Default (all tasks)
gemini -m gemini-3.1-pro-preview -p "Design a microservices architecture"

# Fallback 1
gemini -m gemini-2.5-pro -p "Review this API design"

# Fallback 2 (always available)
gemini -m gemini-2.5-flash -p "Quick refactor"
```

**Version mapping**: "use 3" → `gemini-3.1-pro-preview` | "use 2.5" → `gemini-2.5-pro` | "use flash" → `gemini-2.5-flash`

## Output Formatting

```bash
# Text (default)
gemini -m gemini-3.1-pro-preview -p "What is dependency injection?"

# JSON (programmatic)
gemini -m gemini-3.1-pro-preview --output-format json -p "List top 5 design patterns"

# Streaming JSON (real-time)
gemini -m gemini-3.1-pro-preview --output-format stream-json -p "Explain async/await"
```

## Approval Modes

```bash
# Default: prompts for all actions (use for all tasks)
gemini -m gemini-3.1-pro-preview -p "Refactor this code"

# Auto-edit: auto-approve edits only (only when user explicitly requests file editing)
gemini -m gemini-3.1-pro-preview --approval-mode auto_edit -p "Fix bugs in this file"

# Plan: read-only, no modifications
gemini -m gemini-3.1-pro-preview --approval-mode plan -p "Analyze this module"

# YOLO: auto-approve all (confirm with user first)
gemini -m gemini-3.1-pro-preview --approval-mode yolo -p "Deploy to production"
```

## Session Management

```bash
# List sessions
gemini --list-sessions

# Resume most recent (no new prompt)
gemini -r latest

# Resume with new prompt (headless)
gemini -r latest -p "Continue from where we left off"

# Resume by index
gemini -r 3

# Delete session
gemini --delete-session 5
```

## Extensions & MCP

```bash
# List extensions
gemini --list-extensions

# Use specific extension
gemini -m gemini-3.1-pro-preview -e web_search -p "Research React best practices"

# Comma-separated extensions
gemini -m gemini-3.1-pro-preview -e web_search,code_analysis -p "Research with analysis"
```

## Workspace Context

```bash
# Include additional directory
gemini -m gemini-3.1-pro-preview --include-directories ./lib,./tests -p "Analyze the full project"

# Multiple flags
gemini -m gemini-3.1-pro-preview --include-directories ./lib --include-directories ./tests -p "Analyze project"
```

## Combined Patterns

```bash
# Code review (safe default)
gemini -m gemini-3.1-pro-preview -p "Review this PR for security issues"

# Code editing (explicit user request)
gemini -m gemini-3.1-pro-preview --approval-mode auto_edit -p "Refactor for performance"

# Research with web search
gemini -m gemini-3.1-pro-preview -e web_search -p "Latest GraphQL trends"

# File analysis with @ syntax
gemini -m gemini-3.1-pro-preview -p "Analyze @src/auth.ts and @src/session.ts"

# JSON output for parsing
gemini -m gemini-3.1-pro-preview --output-format json -p "Review this pull request"
```

## Skills & Hooks (v0.29.5+)

```bash
# Skills
gemini skills list
gemini skills install <source>
gemini skills enable <name>
gemini skills disable <name>

# Hooks
gemini hooks migrate
gemini hooks --help

# Extensions
gemini extensions list
gemini extensions install <source>
gemini extensions update --all
```

## Anti-Patterns

```bash
# Wrong: positional prompt in headless mode (opens interactive terminal)
gemini -m gemini-3.1-pro-preview "prompt"

# Correct: use -p for headless
gemini -m gemini-3.1-pro-preview -p "prompt"

# Wrong: YOLO mode without user confirmation
gemini --approval-mode yolo "task"

# Wrong: no fallback when gemini-3.1-pro-preview may be unavailable
# Always have fallback logic ready
```

## Error Handling Pattern

```bash
# Check CLI availability
if ! command -v gemini &> /dev/null; then
    echo "Error: Gemini CLI not installed"
    exit 1
fi

# Execute with error capture
gemini -m gemini-3.1-pro-preview -p "task" 2>&1 || echo "Gemini CLI failed"
```

## Best Practices

1. Always use `-p`/`--prompt` for non-interactive (headless) execution in Claude Code
2. Specify model explicitly with `-m` for predictable behavior
3. Use `default` approval mode; `auto_edit` only when user explicitly requests file editing
4. Use `--output-format json` when processing results programmatically
5. Resume sessions with `-r latest -p "prompt"` for multi-turn conversations
6. Validate CLI availability with `command -v gemini` before invocation

## See Also

- `gemini-help.md` — Full CLI reference
- `session-workflows.md` — Session continuation patterns
- `model-selection.md` — Model selection guidance
