# Command Recipes

Use these recipes after the routing decision is already clear.

## Default Headless Analysis

Use `codex exec` with the read-only sandbox for non-interactive analysis.

```bash
codex exec --sandbox read-only \
  "Review the latest diff in this repository and summarize the main risks."
```

## Explicit File Edit

Only use this when the user explicitly asked Codex to modify files.

```bash
codex exec --sandbox workspace-write \
  "Patch src/app.ts to fix the failing build and explain the change."
```

## Read-Only Planning

Use this when the user wants planning or analysis without file changes or shell execution.

```bash
codex exec --sandbox read-only \
  "Analyze this architecture and list the main risks."
```

## Code Review

Use this when the user asked for a diff-based code review.

```bash
codex review --uncommitted \
  "Review the local staged, unstaged, and untracked changes and list blocking issues."

codex review --base main \
  "Review this branch against main and summarize risks and required follow-ups."

codex review --commit <sha> \
  "Review only the changes introduced by this commit."
```

`codex review` is read-only by design; do not pair it with `--sandbox workspace-write` or `--dangerously-bypass-approvals-and-sandbox`.

## Resume the Latest Non-Interactive Run

Use this for the most recent `codex exec` session.

```bash
codex exec resume --last \
  "Continue the previous task and summarize the next decision."
```

## Resume a Specific Session

Use this when the user wants a specific session ID or the latest run is not the right one.

```bash
codex exec resume <session-id> \
  "Continue from this session and apply the follow-up request."
```

## Resume the Latest Interactive Session

Use this when the user wants to continue the most recent TUI session instead of an `exec` run.

```bash
codex resume --last
```

## Fork From an Existing Session

Use this when the user wants to branch instead of reusing the original session.

```bash
codex fork --last
```

## Additional Directories

Use this when the Codex run needs files outside the launch directory.

```bash
codex exec --add-dir ../shared \
  --sandbox read-only \
  "Inspect this repo and the shared directory, then summarize the integration points."
```

## Structured JSON Output

Only use these when the user explicitly wants machine-readable output.

```bash
# Stream events as JSONL while the run executes
codex exec --json --sandbox read-only \
  "Return a summary of the diff in your final message."

# Constrain the final response to a JSON Schema
codex exec --output-schema schema.json --sandbox read-only \
  "Return an object with keys summary, risks, and next_steps for this diff."
```

## Custom Working Directory

Use this when the user wants Codex to run from a different working root.

```bash
codex exec -C ../service-a --sandbox read-only \
  "Review the service-a repository and summarize the main risks."
```

## Dangerous Bypass Only With Explicit Approval

Only use this after explicit user approval, and only in environments that are externally sandboxed.

```bash
codex exec --dangerously-bypass-approvals-and-sandbox \
  "Apply the requested patch and run the requested checks."
```
