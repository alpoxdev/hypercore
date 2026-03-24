# Command Recipes

Use these recipes after the routing decision is already clear.

## Default Headless Analysis

Use `-p/--print` for non-interactive runs.

```bash
claude --permission-mode default \
  -p "Review the latest diff in this repository and summarize the main risks."
```

## Explicit File Edit

Only use this when the user explicitly asked Claude Code to modify files.

```bash
claude --permission-mode acceptEdits \
  -p "Patch src/app.ts to fix the failing build and explain the change."
```

## Read-Only Planning

Use this when the user wants planning or analysis without file changes or shell execution.

```bash
claude --permission-mode plan \
  -p "Analyze this architecture and list the main risks."
```

## Continue the Latest Session

Use this for the most recent conversation in the current directory.

```bash
claude --continue \
  -p "Continue the previous task and summarize the next decision."
```

## Resume a Specific Session

Use this when the user wants a specific session ID or the current-directory session is not the right one.

```bash
claude --resume <session-id> \
  -p "Continue from this session and apply the follow-up request."
```

## Fork From an Existing Session

Use this when the user wants to branch instead of reusing the original session.

```bash
claude --resume <session-id> \
  --fork-session \
  -p "Continue from this point, but explore an alternative fix."
```

## Additional Directories

Use this when the Claude Code run needs files outside the launch directory.

```bash
claude --add-dir ../shared \
  --permission-mode default \
  -p "Inspect this repo and the shared directory, then summarize the integration points."
```

## Structured JSON Output

Only use this when the user explicitly wants machine-readable output.

```bash
claude --permission-mode default \
  --output-format json \
  -p "Return a JSON object with keys summary, risks, and next_steps for this diff."
```

## Dangerous Bypass Only With Explicit Approval

Only use this after explicit user approval, and only in isolated environments.

```bash
claude --dangerously-skip-permissions \
  -p "Apply the requested patch and run the requested checks."
```
