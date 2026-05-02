# Command Recipes

Use these recipes after the routing decision is already clear. All flags follow the official CLI reference at <https://code.claude.com/docs/en/cli-reference>.

## Default Headless Analysis

`-p` / `--print` runs the SDK loop and exits.

```bash
claude --permission-mode default \
  -p "Review the latest diff in this repository and summarize the main risks."
```

## Bare Mode for CI / Scripts

`--bare` skips auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md so the same command produces the same result on every machine. It also skips the OAuth keychain — supply credentials via `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, or an `apiKeyHelper` in `--settings`.

```bash
ANTHROPIC_API_KEY=$KEY claude --bare -p "Summarize this file" \
  --allowedTools "Read"
```

For a long-lived CI token without bare mode:

```bash
# One-time: claude setup-token   (prints a token; copy it to your secret store)
export CLAUDE_CODE_OAUTH_TOKEN=...
claude -p "Summarize the diff" --output-format json
```

## Explicit File Edit

Only use this when the user explicitly asked Claude Code to modify files. `acceptEdits` also auto-approves common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed`).

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

## Locked-Down CI with `dontAsk`

`dontAsk` auto-denies anything that would otherwise prompt. Pre-approve exactly the tools the run needs.

```bash
claude --permission-mode dontAsk \
  --allowedTools "Read" "Bash(git diff *)" "Bash(git log *)" \
  -p "Summarize the staged changes only."
```

## Auto Mode for Long Tasks

Auto mode lets Claude work without per-action prompts; a server-side classifier blocks risky actions. Requires v2.1.83+, a supported model, and an admin-enabled plan.

```bash
claude --permission-mode auto \
  -p "Run the migration plan in MIGRATION.md, but never push to main."
```

State boundaries in the prompt itself ("never push to main") — the classifier reads them as block signals.

## Continue the Latest Session

Use this for the most recent conversation in the current directory. `-c` is the short form.

```bash
claude --continue \
  -p "Continue the previous task and summarize the next decision."
```

## Resume a Specific Session by Name or ID

`--resume` accepts a display name (set with `--name` / `-n`, or `/rename`) or a session ID.

```bash
claude --resume "auth-refactor" \
  -p "Continue from this session and apply the follow-up request."

claude --resume <session-id> \
  -p "Continue from this session and apply the follow-up request."
```

## Pin a UUID Session for Reproducible Scripts

`--session-id` requires a valid UUID. The same UUID across runs reuses the same conversation.

```bash
claude --session-id 550e8400-e29b-41d4-a716-446655440000 \
  -p "Append this turn to a stable conversation."
```

## Resume Sessions Linked to a Pull Request

```bash
claude --from-pr 123 \
  -p "Address the latest review comments."
```

## Fork From an Existing Session

Use this when the user wants to branch instead of reusing the original session.

```bash
claude --resume <session-id> \
  --fork-session \
  -p "Continue from this point, but explore an alternative fix."
```

## Additional Directories

`--add-dir` grants file access; it does NOT load `.claude/` configuration from added directories (except `.claude/skills/`).

```bash
claude --add-dir ../shared \
  --permission-mode default \
  -p "Inspect this repo and the shared directory, then summarize the integration points."
```

## Structured JSON Output

```bash
claude --permission-mode default \
  --output-format json \
  -p "Return a JSON object with keys summary, risks, and next_steps for this diff."
```

For schema-validated output, pair `--output-format json` with `--json-schema`. The validated result lands in the `structured_output` field of the JSON envelope.

```bash
claude -p "Extract the function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

## Real-Time Streaming

`stream-json` emits newline-delimited events; pair with `--verbose` and `--include-partial-messages` to see token deltas.

```bash
claude -p "Explain recursion" \
  --output-format stream-json --verbose --include-partial-messages
```

## Bounded Autonomous Run

Cap turns and dollars so an autonomous run cannot drift forever. Add a fallback model so a single overload does not abort the job.

```bash
claude -p "Triage open issues and draft replies." \
  --max-turns 8 \
  --max-budget-usd 5.00 \
  --fallback-model sonnet
```

## Restrict or Augment Tools

```bash
# Built-ins only, no Bash
claude -p "Refactor this module." --tools "Read,Edit"

# Pre-approve just what is needed
claude -p "Stage and commit the change." \
  --allowedTools "Bash(git add *)" "Bash(git commit *)" "Bash(git status *)"

# Block specific tools instead
claude -p "Refactor this module." --disallowedTools "Bash"
```

## Custom System Prompt

Prefer the append flags so Claude Code's defaults stay in place.

```bash
claude -p "Review this PR." \
  --append-system-prompt "You are a security engineer. Flag injection and authz bugs first."

claude -p "Review this PR." \
  --append-system-prompt-file ./prompts/security-reviewer.txt
```

Use the replacement flags only when total control of the system prompt is needed:

```bash
claude -p "..." --system-prompt "You are a Python expert."
claude -p "..." --system-prompt-file ./prompts/full-prompt.md
```

## Load MCP Servers

```bash
claude --mcp-config ./mcp.json \
  -p "Use the database MCP server to summarize the schema."

# Ignore every other MCP source for reproducibility
claude --strict-mcp-config --mcp-config ./mcp.json -p "..."
```

## Dangerous Bypass Only With Explicit Approval

`--dangerously-skip-permissions` is equivalent to `--permission-mode bypassPermissions`. Only use it after explicit user approval, and only in isolated environments such as containers or VMs without network access. It offers no protection against prompt injection — prefer `auto` mode when "fewer prompts" is the actual goal.

```bash
claude --dangerously-skip-permissions \
  -p "Apply the requested patch and run the requested checks."
```
