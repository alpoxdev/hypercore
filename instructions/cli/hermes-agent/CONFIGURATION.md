# Hermes Agent Configuration Files

> Korean version: [`CONFIGURATION.ko.md`](CONFIGURATION.ko.md)
>
> **Research date:** 2026-11-03, against the official documentation shipped in Hermes Agent **v0.22.5** (commit `bf0203a794a`, released 2026-10-22). **Facts** below trace to those sources; **Recommendations** are this guide's operational advice. Defaults are documented values as retrieved on that date, not a guarantee about your installed version, so re-check the Configuration and Security references after an upgrade.

## Sources

| Source | What it supplies | Checked |
| --- | --- | --- |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | The `~/.hermes/` tree, precedence, and every section quoted below | checked 2026-11-03 |
| [Environment Variables Reference](https://hermes-agent.nousresearch.com/docs/reference/environment-variables) | Key-specific environment overrides | checked 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | `hermes config` subcommands and dot-escaped keys | checked 2026-11-03 |
| [Managed Scope](https://hermes-agent.nousresearch.com/docs/user-guide/managed-scope) | Pinned administrator values and their precedence | checked 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | Approval modes, YOLO, allowlists, redaction | checked 2026-11-03 |
| [Full documentation export](https://hermes-agent.nousresearch.com/docs/llms-full.txt) | Cross-checking defaults against every page at once | checked 2026-11-03 |

## Which file does what

**Fact — the official Configuration page documents exactly nine entries under `~/.hermes/`:**

| Path | Holds |
| --- | --- |
| `config.yaml` | Non-secret settings: model, terminal, TTS, compression, and so on |
| `.env` | API keys, bot tokens, passwords, and other secrets |
| `auth.json` | OAuth provider credentials (Nous Portal and others) |
| `SOUL.md` | Primary agent identity; slot #1 of the system prompt |
| `memories/` | `MEMORY.md` (learned facts) and `USER.md` (user profile) |
| `skills/` | Agent-created skills, managed through `skill_manage` |
| `cron/` | Scheduled jobs |
| `sessions/` | Gateway session artifacts; canonical data lives in `state.db`, while `sessions/sessions.json` is a legacy gateway-routing mirror |
| `logs/` | `errors.log`, `gateway.log`; secrets are auto-redacted |

**Fact:** other official pages name additional runtime paths — `state.db`, `plugins/`, `cache/`, `mcp-tokens/`, `backups/`, `state-snapshots/`, `checkpoints/`, `profiles/<name>/`, `active_profile` — but those are not entries in the Configuration page's canonical tree.

**Fact — the official split:** `config.yaml` is behavior, `.env` is credentials, `auth.json` is OAuth. `SOUL.md` is user-authored identity; `memories/USER.md` and `memories/MEMORY.md` are agent-written through the memory tool.

**Recommendation:** decide file ownership before writing anything. A value that would be embarrassing in a screenshot belongs in `.env` or a secret source, never in `config.yaml`.

## Configuration precedence

**Fact:** the Configuration page presents a simplified chain — CLI arguments, then `config.yaml`, then `.env`, then built-in defaults. That summary omits two real layers. The reconciled chain, highest to lowest, is:

1. **Managed values, for pinned leaves only.** `/etc/hermes/config.yaml` and `/etc/hermes/.env` (or the relocated `$HERMES_MANAGED_DIR`) override user config, user `.env`, **and the shell environment**, for exactly the keys they pin. The merge is leaf-level: pinning `model.default` does not freeze all of `model`.
2. **CLI per-invocation arguments**, for example `hermes chat --model ...`.
3. **Documented key-specific environment overrides**, for example `TERMINAL_*`, `HERMES_LANGUAGE`, `HERMES_VERIFY_ON_STOP`. Managed Scope explicitly describes its own behavior as an inversion of this "environment overrides config" convention.
4. **Profile `config.yaml`** for non-secret settings.
5. **Profile `.env` and inherited shell values** for secrets and legacy environment-driven settings. **The sub-order here is key-specific**: Docker forwarded variables put the shell first, while the managed-scope generic tier places user `.env` above a pre-existing shell value. Do not generalize either case.
6. **Built-in defaults.**

**Fact:** `hermes config set` refuses to change a managed-pinned key and names the managed source. A malformed managed file is logged loudly and ignored; startup continues. Confirm the effective policy with `hermes doctor`.

**Fact:** managed scope is enforced only by filesystem permissions. A user who can write the managed directory, or who can set `HERMES_MANAGED_DIR`, defeats it. The managed `.env` is documented as world-readable (`0644`), so it must not carry high-sensitivity secrets.

## Variable substitution in config.yaml

**Fact:**

- `${VAR_NAME}` and Cursor-style `${env:VAR_NAME}` resolve identically, including inside `mcp_servers` entries. Multiple references in one string work.
- An undefined variable **remains verbatim and logs a warning** — it does not become empty.
- Bare `$VAR` is **not** expanded.
- `${file:...}`, `${vault:...}`, and `${bitwarden:...}` are **not** inline resolvers. Secret backends populate the environment at startup; reference the result with `${env:NAME}`.
- An unknown prefix warns once and remains verbatim.
- MCP entries additionally support `${userHome}`, `${workspaceFolder}`, `${workspaceFolderBasename}`, `${pathSeparator}`, and `${/}`.

```yaml
mcp_servers:
  github:
    command: npx
    args: ["-y", "@modelcontextprotocol/server-github"]
    env:
      GITHUB_PERSONAL_ACCESS_TOKEN: "${env:GITHUB_TOKEN}"
```

**Recommendation:** when a substituted value appears to have no effect, check the log for the "remained verbatim" warning before changing anything else. That warning is the difference between a typo and a real configuration problem.

## The `hermes config` command family

**Fact:**

| Command | Behavior |
| --- | --- |
| `hermes config` / `hermes config show` | Show current resolved values; prints a managed header when managed scope applies |
| `hermes config edit` | Open `config.yaml` in an editor |
| `hermes config get <key> [--json]` | Read a dotted key, optionally as machine-readable JSON |
| `hermes config set <key> <value>` | Write a value; parses scalars plus quoted YAML/JSON flow lists and maps |
| `hermes config unset <key>` | Remove the user value and revert to default resolution |
| `hermes config path` | Print the `config.yaml` path |
| `hermes config env-path` | Print the `.env` path |
| `hermes config check` | Check for missing or stale config options |
| `hermes config migrate` | Interactively add newly introduced options and enabled-skill settings |

**Fact:** `hermes config set` routes recognized secrets and API keys to `.env` and everything else to `config.yaml`, so the caller does not choose the file.

**Fact — dots inside key names:** when navigating an existing mapping, an existing literal key wins over splitting, so `hermes config set providers.p.models.grok-4.6.supports_vision true` updates the real `grok-4.6` entry. Creating a **new** dotted key needs a backslash escape (`'providers.p.models.grok-4\.7.context_length'`). An unescaped write that would shadow an existing dotted sibling fails instead of creating an entry the runtime never reads.

**Fact:** `hermes config get` masks credential-shaped values (`api_key`, `*_TOKEN`, `*_SECRET`, `password`) because sessions' transcripts persist; `--raw` prints the real value. `hermes config set` refuses a known key written under the wrong prefix and names the intended one unless `--force` is given.

**Fact:** `config check` reports missing or stale options; the docs do not claim it repairs anything. `config migrate` adds newly introduced options and scans enabled skills for declared-but-unset settings; an update runs it after dependency installation.

**Fact — `_config_version` is undocumented.** The literal string does not appear anywhere in the official documentation export. The docs reference only internal schema milestones (v12 migrated `custom_providers` to `providers`; v17 moved `compression.summary_*` to `auxiliary.compression.*`; schema v21 grandfathered installed user plugins). The backup behavior of a general `config migrate` is likewise undocumented.

**Recommendation:** treat a `_config_version` field in your file as an internal marker. Use `hermes config check` and `hermes config migrate` rather than hand-editing it.

## Section reference

Only the operationally important keys are listed. `SILENT` means the docs name the key but do not state a default.

### `model`

| Key | Type | Documented default |
| --- | --- | --- |
| `provider` | string | Unconfigured before setup |
| `default` | string | Unconfigured before setup |
| `base_url` | string | SILENT |
| `api_mode` | string | SILENT |
| `context_length` | integer | Auto-detected |
| `aliases` | map | Empty; canonical top-level `model_aliases` wins |

Related: top-level `providers` (`api`, `api_key`, `extra_headers`, `discover_models: true`, `models`, timeout keys). Legacy `custom_providers` is still supported and auto-migrated.

### `approvals`

| Key | Documented default | Notes |
| --- | --- | --- |
| `mode` | `smart` | `smart` uses an auxiliary LLM; `manual` always prompts; `off` disables checks and equals YOLO |
| `timeout` | `300` seconds | No response means **denied** — fail-closed |
| `cron_mode` | `deny` | `approve` auto-approves every dangerous command in cron context |
| `single_query_mode` | `deny` | Same semantics for one-shot `hermes chat -q` |
| `unattended_mode` | `deny` | Same semantics for webhook, `msgraph_webhook`, and `api_server` sessions, which have no human to answer `/approve` |
| `discord_prompt_timeout` | `300` | Seconds Discord's approval, clarify, and update buttons stay clickable; minimum 30 |
| `smart_policy` | unset | Extra instructions appended to the smart-approval reviewer's system prompt |
| `deny` | No non-empty default | Case-insensitive whole-command fnmatch globs over normalized variants; evaluated **before** YOLO/off; mtime-reloaded without restart |
| `denial_breaker_threshold` | `3` | `0` disables |
| `destructive_slash_confirm` | Enabled | Native confirm dialog for `/clear`, `/new`, `/reset`, `/undo` |
| `mcp_reload_confirm` | `true` | Asks before `/reload-mcp` changes MCP tool schemas; an "always" choice persists the corresponding approval |

**Fact:** `command_allowlist` is a **top-level** key, not `approvals.command_allowlist`. Choosing "always" writes broad patterns there, and they are silently approved from then on. `hermes approvals suggest` is read-only; only `--apply` writes.

**Fact:** YOLO can be enabled through `--yolo`, the in-session `/yolo` toggle, or `HERMES_YOLO_MODE=1`. It bypasses dangerous-command prompts but not the hardline blocklist; it is not a sandbox or a substitute for a safe backend.

**Fact — the scope limit that matters most:** the deny and hardline guard stack applies to **host-reaching backends** (local, SSH, host-mounted Docker). Isolated backends — docker, singularity, modal, daytona, vercel_sandbox — **skip dangerous-command checks entirely**, because the container is treated as the boundary. Never describe `approvals.deny` as a universal execution guarantee.

**Recommendation:** use container isolation, not deny globs, as the security boundary. Deny rules are a guardrail on host-reaching backends.

### `terminal`

| Key | Documented default | Notes |
| --- | --- | --- |
| `backend` | `local` | `local`, `docker`, `ssh`, `modal`, `daytona`, `vercel_sandbox`, or a plugin backend. Singularity/Apptainer moved out of core into a plugin |
| `cwd` | `.` | Gateway and cron use it; the CLI uses its launch directory |
| `timeout` | `180` | Seconds |
| `home_mode` | `auto` | `auto`, `real`, `profile` |
| `env_passthrough` | `[]` | |
| `persistent_shell` | SSH true, local false | Backend environment variables override |
| `docker_network` | `true` | `false` air-gaps the container |
| `container_cpu` / `container_memory` / `container_disk` | `1` / `5120` MB / `51200` MB | |
| `container_persistent` / `docker_persist_across_processes` / `docker_orphan_reaper` | `true` | |
| `lifetime_seconds` | `300` | |
| `vercel_runtime` | `node24` | Also `node22`, `python3.13` |
| `temp_dir` | `""` | Empty honors `TMPDIR`, else `~/.hermes/cache/terminal`; idles 24 h are swept |
| `sync_back_max_bytes` | `2147483648` | Remote backends refuse a larger state archive |
| `modal_image` / `daytona_image` | `nousresearch/hermes-sandbox:desktop` | Sandbox image per cloud backend |

**Fact:** `home_mode: auto` preserves the real OS `HOME` on host installs, so ordinary `git`, `ssh`, `gh`, `az`, `npm`, Claude Code, and Codex credentials stay visible to subprocesses. `home_mode: profile` points `HOME` at `{HERMES_HOME}/home` and exports `HERMES_REAL_HOME`, at the cost of hiding `~/.ssh`, `~/.gitconfig`, and cloud CLI authentication until they are initialized there.

**Fact:** `docker_extra_args` is appended last and the docs warn it can silently weaken the intended hardening. Host mounts, cwd mounts, credential mounts, and environment forwarding can each reintroduce host reach.

### `skills`, `memory`, and `plugins`

| Key | Documented default |
| --- | --- |
| `skills.guard_agent_created` | `false` — the heuristic scanner is off |
| `skills.write_approval` | `false` — skill writes are not staged for approval |
| `skills.auto_load` | Empty — no skill is force-loaded at session start |
| `skills.create_dir` | Unset — new agent-created skills go to the profile-local directory |
| `skills.inline_shell` / `inline_shell_timeout` | `false` / `10` seconds per snippet |
| `skills.tier1_advisory` | Enabled when the optional scanner binaries are on `PATH` |
| `skills.ledger` / `ledger_max_bytes` | `true` / `5242880` |
| `skills.disabled` / `skills.platform_disabled` / `skills.external_dirs` | SILENT |
| `memory.memory_enabled` / `memory.user_profile_enabled` | `true` |
| `memory.memory_char_limit` / `memory.user_char_limit` | `2200` / `1375` characters |
| `memory.write_approval` | `false` |
| `memory.prefetch_spill_enabled` | `false` — oversized provider recall stays intact |
| `memory.provider` | Unset — built-in stores only |
| `plugins.enabled` / `plugins.disabled` | Arbitrary plugins are opt-in; `disabled` always wins |

**Fact:** plugin trust gates — `allow_tool_override`, `allow_gateway_injection`, `mcp_allowlist`, `llm.allow_provider_override`, `allow_model_override`, `allow_platform_actions`, and the related keys — all default to deny.

### Tools: there is no top-level `tools:` section

**Fact:** tool enablement is stored as `platform_toolsets` (a map of platform to toolset list, written by `hermes tools`) plus `agent.disabled_toolsets`, which removes toolsets globally after platform resolution. Do not invent a `tools:` mapping.

Related limits: `tool_output.max_bytes` `50000`, `max_lines` `2000`, `max_line_length` `2000`; `file_read_max_chars` `100000`; `tool_budget.mcp_result_size_chars` `50000`; `tool_loop_guardrails.warnings_enabled` `true`, `hard_stop_enabled` `false`, `non_interactive_hard_stop_enabled` `true`; `loop_caps.max_web_searches` and `max_subagents` `50` per turn.

**Fact — two different truncation strategies:** over-limit terminal output is cut to the first 40% and last 60% with an `[OUTPUT TRUNCATED]` notice, while an oversized *tool result* is spilled to `$HERMES_HOME/cache/spillover/` and replaced in context by a preview plus the file path. The generic spill threshold is 100,000 characters and `mcp_*` results spill at 50,000 by default, always capped at the generic threshold.

**Fact — where the hard stops apply:** interactive CLI, TUI, Desktop, ACP, and `api_server` sessions only warn, because a person can intervene; unattended gateway and cron surfaces hard-stop by default through `non_interactive_hard_stop_enabled`. `hard_stop_enabled` widens hard stops to every platform. Hard stops catch unchanged replays, not iteration: a successful mutating call resets the streak, and distinct failing commands are diagnosis rather than a loop.

### Other frequently tuned sections

`agent` (`api_max_retries: 3`, `stall_guards: true`, `clarify_timeout: 3600`) · `compression` (`enabled: true`, `threshold: 0.50`, `target_ratio: 0.20`, `tail_mode: lean`, `protect_last_n: 20`, `protect_first_n: 3`) · `code_execution` (`mode: project`, `timeout: 300`, `max_tool_calls: 50`) · `display` (`tool_progress: all`, `language: en`, `memory_notifications: on`) · `security` (`redact_secrets: true`, `website_blocklist.enabled: false`) · `updates` (`pre_update_backup: quick`, `backup_keep: 5`) · `delegation` (`max_concurrent_children: 3`, `max_spawn_depth: 1`, `oneshot_max_children: 2`) · `checkpoints` (`enabled: false`, `max_snapshots: 20`) · `curator` (`enabled: true`, `interval_hours: 168`, `stale_after_days: 14`, `archive_after_days: 30`, `consolidate: false`).

**Fact — `tirith_*` is gone.** Earlier releases bundled a command scanner under `security.tirith_enabled`; it was removed and upgrading drops the key with nothing enabled in its place. Content-level command checks are documented separately.

**Fact — `database:` exists.** It controls how `state.db` opens: `journal_mode` (`wal` default, `delete` for network mounts), an optional `synchronous` durability floor, and optional `wal_autocheckpoint` / `journal_size_limit` pragmas. An existing WAL database is never live-downgraded; `hermes sessions set-journal-mode delete` converts one after every process stops.

**Fact — `runtime:` exists.** `nofile_soft_limit` (default `4096`, clamped to the OS hard limit and never lowered) and `malloc_arena_max` (default `4` on glibc) tune long-running server processes. `0`, `false`, or `null` disables each.

## Contradictions that were reconciled

An earlier revision of this guide tracked three inconsistent pairs in the official documentation. All three now read consistently, so do not reintroduce the older readings:

| Topic | Once inconsistent | Current documented position |
| --- | --- | --- |
| `context_file_max_chars` | `null` dynamic cap versus a "default 20,000" sentence | `null` scales with the model window, floor 20,000 and ceiling 500,000 characters |
| `gateway.streaming.enabled` | A sample showed `true` beside prose saying `false` | The master switch is `false`; Telegram streams and Discord does not once it is on |
| `agent.clarify_timeout` | The settings material said `3600`, the Discord and Telegram pages said `600` | `3600` seconds, one value for the CLI modal, the TUI/Desktop card, and the gateway |

## Secrets and credentials

**Fact:** Hermes reads the process environment and the active home's `.env`. External secret sources run **after** `.env` loads: Bitwarden fetches after `.env`, 1Password resolves references after `.env`, and the command helper runs after `.env`.

**Fact:** existing `.env` and shell values win by default; a source can replace them only when its `override_existing` is true. Bitwarden and 1Password default to `override_existing: true`; the command helper defaults to `false`. A source cannot overwrite a bootstrap token or a value already claimed by another source. `secrets.preserve_existing` is the documented escape hatch for retaining already-present per-profile values during external secret injection.

| Source | Bootstrap credential | Configured under |
| --- | --- | --- |
| `.env` | — | `~/.hermes/.env` |
| Bitwarden Secrets Manager | `BWS_ACCESS_TOKEN` | `secrets.bitwarden` |
| 1Password | `OP_SERVICE_ACCOUNT_TOKEN` | `secrets.onepassword` with `op://` references |
| Command helper | — | `secrets.command` (stdout must be dotenv `KEY=VALUE` lines) |

**Fact:** credential pools rotate credentials only within their provider. `credential_pool_strategies` supports `fill_first` (default), `round_robin`, `least_used`, and `random`; do not infer credential isolation merely from using a separate bot or profile.

**Fact:** `security.redact_secrets` defaults to `true` and strips key-like patterns from tool output before it reaches context, logs, and chat responses. **Fact:** `terminal` and `execute_code` subprocesses have variables containing `KEY`, `TOKEN`, `SECRET`, `PASSWORD`, `CREDENTIAL`, `PASSWD`, or `AUTH` stripped unless explicitly allowed, and cron scripts do not inherit provider credentials.

**Fact:** Hermes blocks `write_file` and `patch` writes to its own credential stores, OS credential locations, and project secret files such as `.env`, `.env.local`, and `.envrc`.

**Recommendation:** redaction is defense in depth, not permission. Never paste a credential into a prompt, a skill, a commit, or a ticket on the assumption that it will be scrubbed.

## Backups and version control

**Fact:** `updates.pre_update_backup` defaults to `quick`, snapshotting critical state per profile into `state-snapshots/`; `full` adds a whole-home ZIP under `backups/`, and `off` disables it. `backup_keep` defaults to `5`. `hermes update --backup` forces a full backup and `--no-backup` disables it for that run.

**Fact:** `hermes backup` captures the entire Hermes home **including credentials**, and `hermes import` restores it. `hermes profile export` deliberately strips credentials and is therefore not a full backup.

**Fact — never commit these:** `.env`, `auth.json`, `.env.EXAMPLE`, `state.db*`, `gateway.pid`, `gateway_state.json`, `active_profile`, `memories/`, `sessions/`, `logs/`, `plans/`, `workspace/`, `home/`, `cache/`, `checkpoints/`, `sandboxes/`, `backups/`, `errors.log`, `.hermes_history`, and nested `profiles/`. The Security page additionally specifies `chmod 600 ~/.hermes/.env`.

**Recommendation:** `config.yaml` is committable only once every secret is referenced through `${env:NAME}` instead of inlined. That is precisely why the substitution syntax exists.

## Troubleshooting

| Symptom | Documented cause | Action |
| --- | --- | --- |
| A setting has no effect | A higher precedence layer wins, or managed scope pins the leaf | `hermes config show` and check for the managed header |
| `hermes config set` refuses a key | Managed scope pins it | The command names the managed source; change it there |
| A `${VAR}` reference appears literally | The variable is undefined | Check the warning in the log; define it in `.env` or a secret source |
| A new `.env` key is invisible to a running session | The process has not re-read `.env` | Run `/reload`, or restart the process |
| An API key seems ignored | A saved model/provider selection outranks normal environment resolution | Inspect `hermes config show`, rerun `hermes model` |
| `config get` shows `sk-o...7890` | Credential-shaped values are masked because session transcripts persist | Add `--raw`, or set `security.redact_secrets: false` |
| Options disappeared after an update | New schema options are not yet present | `hermes config check`, then `hermes config migrate` |
| Managed policy seems inactive | The managed file is malformed and was ignored | It is logged loudly; verify with `hermes doctor` |

## Verification checklist

- [ ] Secrets live in `.env`, `auth.json`, or a secret source — never in `config.yaml`.
- [ ] `~/.hermes/.env` is mode `600`.
- [ ] Every key name and default was confirmed against the official reference for the installed version, not copied from this page alone.
- [ ] Approval posture is stated together with the terminal backend, because the guard stack only runs on host-reaching backends.
- [ ] Before committing anything from a Hermes home, the never-commit list above was applied.
