# Gemini CLI Session Workflows

**Version**: v0.29.5+ | **Last Updated**: 2026-02-16

## Overview

Gemini CLI supports session persistence for multi-turn conversations. Sessions maintain conversation history and context across multiple invocations.

## Session Commands

```bash
# List sessions
gemini --list-sessions

# Resume most recent
gemini -r latest

# Resume with new prompt (headless)
gemini -r latest -p "Continue our discussion about microservices"

# Resume by index
gemini -r 3

# Delete session
gemini --delete-session 0
```

**Important**: When resuming with a new prompt in Claude Code, always use `-p` for headless mode. The resumed session inherits the original model and settings.

## Session Workflows

### Iterative Development

```bash
# Session 1: Design
gemini -m gemini-3.1-pro-preview -p "Design a user authentication system"

# Resume to implement
gemini -r latest -p "Now help me implement the login component"

# Resume to review
gemini -r latest -p "Review the implementation for security issues"
```

### Multi-Day Research

```bash
# Day 1: Start research
gemini -m gemini-3.1-pro-preview -e web_search -p "Research GraphQL best practices"

# Day 2: Continue
gemini -r latest -p "Compare GraphQL with REST for our use case"

# Day 3: Decide
gemini -r latest -p "Based on our research, recommend the best approach"
```

### Code Review Across Files

```bash
# Start with first module
gemini -m gemini-3.1-pro-preview -p "Review @src/auth/login.ts"

# Resume for next file (context preserved)
gemini -r latest -p "Now review @src/auth/session.ts"
gemini -r latest -p "Now review @src/auth/permissions.ts"
```

### Collaborative Debugging

```bash
# Initial investigation
gemini -m gemini-3.1-pro-preview -p "Help debug this memory leak: [details]"

# After implementing a fix
gemini -r latest -p "The leak still occurs. New log output: [logs]"

# Resolution
gemini -r latest -p "Confirmed fixed. Summarize what we found."
```

## When to Use Sessions

**Good use cases**: Multi-step tasks, iterative design, long-running research, code review across multiple files, debugging over multiple attempts.

**Poor use cases**: Quick one-off queries, unrelated tasks, simple factual questions.

## Session Management Tips

1. Use `gemini --list-sessions` before resuming to verify which session you need
2. Use numeric index (`-r 1`) when there are multiple sessions to avoid resuming the wrong one
3. Very long sessions may hit context window limits — start fresh if context seems lost
4. Sessions are stored locally in `~/.gemini/` and are not synced to the cloud

## Troubleshooting

### Session Not Found

```bash
$ gemini -r 5
Error: Session 5 not found

# Solution: list available sessions
gemini --list-sessions
```

### Lost Session Context

```bash
# Verify you're resuming the right session
gemini --list-sessions

# Resume with a summary prompt
gemini -r 2 -p "Summarize what we discussed so far"

# If context is truly lost, start fresh
gemini -m gemini-3.1-pro-preview -p "Let's restart our discussion about..."
```

## See Also

- `gemini-help.md` — Full CLI reference
- `command-patterns.md` — Common command templates
- `model-selection.md` — Model selection guidance
