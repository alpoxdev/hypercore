#!/bin/bash

# Ralph Loop Setup Script
# Creates state file + ensures Stop hook is registered in User settings

set -euo pipefail

# --- Hook auto-registration (User settings only, never Project) ---
ensure_stop_hook() {
  local USER_SETTINGS="$HOME/.claude/settings.json"
  local HOOK_CMD=".claude/hooks/ralph-stop-hook.sh"

  # Create ~/.claude/ if needed
  mkdir -p "$HOME/.claude"

  # If no settings file, create with hook
  if [[ ! -f "$USER_SETTINGS" ]]; then
    cat > "$USER_SETTINGS" <<'HOOKEOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/ralph-stop-hook.sh"
          }
        ]
      }
    ]
  }
}
HOOKEOF
    echo "Created $USER_SETTINGS with Ralph stop hook"
    return
  fi

  # Check if ralph hook already registered (any path containing 'ralph')
  if jq -e '.hooks.Stop // [] | .. | .command? // empty | test("ralph")' "$USER_SETTINGS" >/dev/null 2>&1; then
    return  # Already registered
  fi

  # Add hook to existing settings (preserve all existing values)
  local TEMP_FILE="${USER_SETTINGS}.tmp.$$"

  # If Stop array exists, append to it; otherwise create it
  if jq -e '.hooks.Stop' "$USER_SETTINGS" >/dev/null 2>&1; then
    jq --arg cmd "$HOOK_CMD" '.hooks.Stop += [{"hooks": [{"type": "command", "command": $cmd}]}]' "$USER_SETTINGS" > "$TEMP_FILE"
  elif jq -e '.hooks' "$USER_SETTINGS" >/dev/null 2>&1; then
    jq --arg cmd "$HOOK_CMD" '.hooks.Stop = [{"hooks": [{"type": "command", "command": $cmd}]}]' "$USER_SETTINGS" > "$TEMP_FILE"
  else
    jq --arg cmd "$HOOK_CMD" '.hooks = {"Stop": [{"hooks": [{"type": "command", "command": $cmd}]}]}' "$USER_SETTINGS" > "$TEMP_FILE"
  fi

  mv "$TEMP_FILE" "$USER_SETTINGS"
  echo "Registered Ralph stop hook in $USER_SETTINGS"
}

ensure_stop_hook

# --- Argument parsing ---
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Ralph Loop - Interactive self-referential development loop

USAGE:
  /ralph-loop [PROMPT...] [OPTIONS]

OPTIONS:
  --max-iterations <n>           Maximum iterations (default: unlimited)
  --completion-promise '<text>'  Promise phrase (USE QUOTES for multi-word)
  -h, --help                     Show this help

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise 'DONE' --max-iterations 20
  /ralph-loop --max-iterations 10 Fix the auth bug
  /ralph-loop Refactor cache layer  (runs forever)

STOPPING:
  Only by reaching --max-iterations or detecting --completion-promise

MONITORING:
  grep '^iteration:' .claude/ralph-loop.local.md
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

PROMPT="${PROMPT_PARTS[*]}"

if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided" >&2
  echo "Usage: /ralph-loop <PROMPT> [--max-iterations N] [--completion-promise TEXT]" >&2
  exit 1
fi

# --- Create state file ---
mkdir -p .claude

if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

cat > .claude/ralph-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

cat <<EOF
Ralph loop activated!

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "$COMPLETION_PROMISE"; else echo "none (runs forever)"; fi)

The stop hook blocks exit and re-feeds the same prompt each iteration.

EOF

echo "$PROMPT"

if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo ""
  echo "To complete: output <promise>$COMPLETION_PROMISE</promise> (ONLY when TRUE)"
fi
