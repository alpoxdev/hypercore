# Codex CLI Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)

This is the runtime profile for skills executed on the Codex CLI (`codex`). Shared safety, question, and approval contracts follow [capability-contract.md](../capability-contract.md). The commands and policies here are checked against the official Codex documentation named in each row. The local `skills/codex/SKILL.md` this profile originally cited was removed from the distribution tree in commit `d4f79f9`, so it is no longer evidence.

## Applicable scope and contract

- Apply this profile only when the Codex CLI is explicitly required. Do not use it as a substitute for ordinary document writing or direct local editing.
- Use `codex exec` for non-interactive execution. Top-level `codex "prompt"` opens an interactive TUI and does not count as an automation call.
- Start analysis, review, and planning under `--sandbox read-only`. Choose `--sandbox workspace-write` only when the user explicitly asked for workspace file modification.
- Keep `codex review` a read-only flow; never combine it with a writable sandbox or a bypass flag.
- No capability or CLI option counts as approval for external, destructive, credential-using, or production side work.
- Ask the user only when a decision or approval that materially changes safety or the artifact is missing. Use a structured question/approval capability only after confirming the runtime exposes it. If you cannot confirm it, ask a single plain-text sentence and stop gated work until you receive an answer. Do not assume a question tool exists, and do not make the decision on the user's behalf.

## Behavior verified against official documentation

| Area | Verified rule | Evidence |
|---|---|---|
| Execution | `codex exec` (short form `codex e`) is the documented entry for scripted or CI-style runs that should finish without a prompt; add `--json` for newline-delimited JSON events | [Command line options](https://learn.chatgpt.com/docs/developer-commands.md?surface=cli) (checked 2026-09-19) |
| Review | `codex review` runs a review non-interactively and takes exactly one target — `--uncommitted`, `--base`, `--commit`, or a custom prompt; `--title` applies only with `--commit` | Same page, `codex review` (checked 2026-09-19) |
| Resume and fork | Non-interactive continuation is the `codex exec resume` subcommand, with `--last` scoped to the current working directory and `--all` to widen it; `codex resume` continues an interactive session and `codex fork` forks one | Same page, `codex exec` and `codex resume` (checked 2026-09-19) |
| Sandbox | `--sandbox workspace-write` is documented alongside `--ask-for-approval on-request`; prefer `--add-dir` over forcing `--sandbox danger-full-access` | Same page, plus [Agent approvals and security](https://learn.chatgpt.com/docs/agent-approvals-security.md) (checked 2026-09-19) |
| Approval flags | `-a`/`--ask-for-approval` is documented as a global option of the interactive client | Same page, global options (checked 2026-09-19) |
| Extra paths and roots | `--add-dir` adds a writable root; `-C`/`--cd` sets the working directory before the run | Same page, global options (checked 2026-09-19) |

The table above records vendor documentation, not a complete feature or tool list for the installed CLI. If something is not visible at runtime or behaves differently, discover and confirm it with `codex --help` or the relevant subcommand help, and do not describe it as supported before confirmation.

## Read, write, and command safety

- Read: the default command is `codex exec --sandbox read-only`, and review is likewise limited to read-only.
- Write: use `workspace-write` only when the user has stated an intent for Codex to modify the workspace. Do not use permission bypass for ordinary edits.
- Commands and permissions: keep model, profile, and approval policy at defaults unless the user requests otherwise. Use `--add-dir` only for required paths, and `--dangerously-bypass-approvals-and-sandbox` only after user confirmation and separate isolation.
- Report the cause and blocked state for authentication, sandbox, and session errors, and retry only within the scope the user wanted. Do not add `--skip-git-repo-check` for out-of-repository execution without explicit approval.

## Non-goals

- Do not infer or guarantee Codex's full option set, installation state, authentication method, or model list.
- Do not interpret a runtime capability as privilege escalation or user approval.
- Do not resume or fork a session, or modify files, without a user request.

## In-skill usage checklist

- [ ] Does the request explicitly require the Codex CLI or a separate Codex session?
- [ ] Is it `codex exec` when non-interactive, and `read-only` for analysis or review?
- [ ] Do writes, extra directories, and permission relaxation match user intent and the safety boundary?
- [ ] Are results, warnings, partial output, and authentication/session/sandbox blocks reported together?
- [ ] For an important undecided item, is only a confirmed structured capability used — otherwise one plain-text sentence followed by a stop?
