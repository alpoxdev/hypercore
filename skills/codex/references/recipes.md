# Command Recipes

Use these recipes after the routing decision is already clear.

## Read-Only Review

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  "review the latest diff in this repo" 2>/dev/null
```

## Local Edit

Only use this when the user explicitly asked Codex to edit files.

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox workspace-write \
  "patch src/app.ts to fix the failing build" 2>/dev/null
```

Ask before adding `--full-auto`.

## Networked Research Or Patch

Only use this when the task really needs network access or broad system access.

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox danger-full-access \
  "check the latest Next.js docs and patch the code if needed" 2>/dev/null
```

Ask before adding `--full-auto`.
Confirm before using `--sandbox danger-full-access`.

## Resume

```bash
echo "continue the previous task" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

Keep flags between `exec` and `resume`.
