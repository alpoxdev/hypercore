# Command Recipes

Use these recipes after the routing decision is already clear. Targets Gemini CLI v0.40.0.

## Default Headless Research

Use `-p` / `--prompt` for non-interactive runs. Positional prompts open the interactive REPL.

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

## Read-Only Plan Mode

Use this when the user wants planning or analysis without code modifications. Plan Mode restricts writes to Markdown files in the configured plans directory.

```bash
gemini --approval-mode plan \
  -p "Review this architecture and list the main risks."
```

## Resume Latest Session

```bash
gemini --resume latest \
  -p "Continue the previous task and summarize the next decision."
```

`--resume` also accepts an index (`gemini -r 1`) or a full session UUID. Use `gemini --list-sessions` first when the target session is unclear, and `gemini --delete-session <index>` to drop one.

## Sandboxed Auto-Edit

When the task is higher-risk or you want tighter local constraints, add sandboxing instead of jumping straight to YOLO.

```bash
gemini --sandbox \
  --approval-mode auto_edit \
  -p "Inspect this repo, make the requested patch, and explain the result."
```

`-s` is the short form of `--sandbox`.

## YOLO Only With Explicit Approval

Only use this after the user explicitly approved a full-auto Gemini run. Prefer `--approval-mode yolo` over the deprecated bare `--yolo`.

```bash
gemini --approval-mode yolo \
  -p "Apply the requested patch and run the requested checks."
```

## Multi-Directory Context

Pull additional folders into Gemini's workspace when the task spans repos.

```bash
gemini --include-directories ../shared-libs,../docs \
  -p "Explain how the auth module uses the shared utilities."
```

## Structured JSON Output

Use `--output-format json` when the caller will parse the response programmatically. `stream-json` emits NDJSON events for streaming consumers.

```bash
gemini --approval-mode default \
  --output-format json \
  -p "Return a JSON list of risks for this PR."
```

## Specific Model Selection

Only when the user explicitly asks for a particular model. Aliases `pro`, `flash`, `flash-lite`, `auto` are accepted, as are full model ids.

```bash
gemini -m pro --approval-mode default \
  -p "Reason carefully about this design tradeoff."
```

## Seeded Interactive Prompt

When the user wants Gemini to start with a prompt and then keep talking interactively, use `-i` / `--prompt-interactive` instead of `-p`.

```bash
gemini --approval-mode default \
  -i "Walk me through the auth flow, then I will ask follow-up questions."
```

`-p` exits after one shot; `-i` seeds the prompt and stays in the REPL.

## Pass File Context with `@`

Inside the prompt, `@<path>` includes file or directory content with git-aware filtering.

```bash
gemini --approval-mode default \
  -p "Compare @src/auth.ts with @src/session.ts and list the differences."
```
