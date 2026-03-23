# Command Recipes

Use these recipes after the routing decision is already clear.

## Default Headless Research

Use `-p/--prompt` for non-interactive runs.

```bash
gemini --approval-mode default \
  -p "Research the latest React 19 changes and summarize the current sources you use."
```

## Explicit File Edit

Only use this when the user explicitly asked Gemini to edit files.

```bash
gemini --approval-mode auto_edit \
  -p "Patch src/app.ts to fix the failing build."
```

## Read-Only Planning

Use this when the user wants planning or analysis without file modifications.

```bash
gemini --approval-mode plan \
  -p "Review this architecture and list the main risks."
```

## Resume Latest Session

```bash
gemini --resume latest \
  -p "Continue the previous task and summarize the next decision."
```

Use `gemini --list-sessions` before resuming by index or when the session identifier is unclear.

## YOLO Only With Explicit Approval

Only use this after the user explicitly approved a full-auto Gemini run.

```bash
gemini --yolo \
  -p "Apply the requested patch and run the requested checks."
```

## Safer Sandboxed Edit

When the task is higher-risk or you want tighter local constraints, add sandboxing instead of jumping straight to `--yolo`.

```bash
gemini --sandbox \
  --approval-mode auto_edit \
  -p "Inspect this repo, make the requested patch, and explain the result."
```
