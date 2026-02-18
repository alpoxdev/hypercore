#!/bin/bash

# Session Environment Setup Hook
# Sets CLAUDE_SCRIPTS_ROOT based on where the command/skill is located
# - User scope (~/.claude/): CLAUDE_SCRIPTS_ROOT=~/.claude/scripts
# - Project scope (.claude/): CLAUDE_SCRIPTS_ROOT=.claude/scripts

set -euo pipefail

# Only run for SessionStart events
# The hook receives JSON input via stdin, but for SessionStart we just need to set env vars

# Determine the scripts root based on installation scope
# Check if user-level .claude exists and has scripts
USER_SCRIPTS_DIR="$HOME/.claude/scripts"
PROJECT_SCRIPTS_DIR=".claude/scripts"

# Priority: Project scope first (if exists), then User scope
if [[ -d "$PROJECT_SCRIPTS_DIR" ]]; then
  SCRIPTS_ROOT="$PROJECT_SCRIPTS_DIR"
elif [[ -d "$USER_SCRIPTS_DIR" ]]; then
  SCRIPTS_ROOT="$USER_SCRIPTS_DIR"
else
  # Fallback to project scope (default)
  SCRIPTS_ROOT="$PROJECT_SCRIPTS_DIR"
fi

# Write to CLAUDE_ENV_FILE (session-wide environment)
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  echo "CLAUDE_SCRIPTS_ROOT=$SCRIPTS_ROOT" >> "$CLAUDE_ENV_FILE"
fi

exit 0
