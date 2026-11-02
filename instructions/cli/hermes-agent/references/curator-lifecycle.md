# Hermes Curator: Skill Lifecycle in Detail

> Korean version: [`curator-lifecycle.ko.md`](curator-lifecycle.ko.md)
>
> **Research date:** 2026-11-03, against the official documentation shipped in Hermes Agent **v0.22.5** (commit `bf0203a794a`, released 2026-10-22). **Facts** trace to those sources; **Recommendations** are this guide's operating policy. This file holds the operational detail behind the curator summary in [SKILLS.md](../SKILLS.md); it is version-sensitive.

## Sources

| Source | What it supplies | Checked |
| --- | --- | --- |
| [Curator](https://hermes-agent.nousresearch.com/docs/user-guide/features/curator) | States, defaults, CLI, ledger, backups, adoption, pin and lock | checked 2026-11-03 |
| [Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills) | Which writes count as agent-created, `skill_manage` actions | checked 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | `hermes curator` subcommand list | checked 2026-11-03 |

## What the curator may touch

**Fact:** a skill is in scope only when all three hold: its name is absent from `.bundled_manifest`, absent from `.hub/lock.json`, and its `.usage.json` entry carries `"created_by": "agent"` or `"agent_created": true`. Only the background self-improvement review sets that marker, through the `background_review` write origin.

**Fact:** skills the foreground agent creates with `skill_manage(action="create")`, including `/learn` results, are recorded as `created_by: learn` and the curator leaves them alone. Hand-written skills and skills found through `skills.external_dirs` have no marker and are never touched.

**Fact:** `hermes curator status` reports an unmanaged count split into `pre-dates marker` (records written before the field existed, authorship unknowable) and `foreground-created`. `hermes curator adopt <skill>` or `adopt --all-unmanaged` hands them over; `list-unmanaged` itemizes them.

## States and defaults

```yaml
curator:
  enabled: true
  interval_hours: 168        # 7 days between runs
  min_idle_hours: 2          # and the profile idle this long
  stale_after_days: 14
  archive_after_days: 30
  consolidate: false         # LLM umbrella pass, opt-in
  prune_builtins: false      # opt in to archiving unused bundled skills too
  archive_ttl_days: 0        # 0 = keep archives forever
```

**Fact:** the deterministic pass moves `active → stale` at 14 days without use and archives at 30. Never-used skills (`use_count == 0`) get a grace floor and are not archived before they are `stale_after_days` old. Pinned skills and skills referenced by any cron job's `skills:` list, including paused and disabled jobs, are skipped entirely.

**Fact:** `prune_builtins: true` only extends the deterministic archival pass to unused bundled skills; bundled skills are never patched, consolidated, or deleted, and hub-installed skills are always exempt. Archival moves a skill to `~/.hermes/skills/.archive/`, which `hermes curator restore <skill>` reverses unless a bundled or hub skill now holds the name.

**Fact:** the LLM consolidation pass costs an auxiliary-model run, typically 50–100 API calls per sweep, and is off by default. `hermes curator run --consolidate` forces it for one run. Its candidate list contains only skills it can read and write.

## Backups, ledger, and rollback

**Fact:** `hermes curator backup` snapshots `~/.hermes/skills/`, and `hermes curator rollback` restores the newest snapshot (`--list`, `--id <ts>`, `-y`).

**Fact:** every mutation — curator transitions, agent `skill_manage` calls, and your own CLI archive/restore/purge — appends one entry to `~/.hermes/skills/.curator_ledger.jsonl` with the actor (`curator`, `agent`, `user`), the action, evidence such as `absorbed_into` for consolidations, and per-file `{path, sha256}` before/after manifests. Contents are stored content-addressed under `~/.hermes/.curator_backups/blobs/`. `hermes curator ledger [--skill <name>] [--limit N]` reads it and `hermes curator rollback <entry-id>` restores exactly that one mutation, failing closed if the safety capture cannot be written. Because foreground deletes are ledgered too, a single-entry rollback can resurrect a hard-deleted skill.

**Fact:** the ledger is telemetry, never a gate: a failed entry does not block the mutation. `skills.ledger: false` disables it, and `skills.ledger_max_bytes` (default 5 MB) bounds it, compacting through the unchanged-file dedup and then dropping the oldest entries while always keeping the newest. `hermes curator ledger --compact` does the same by hand.

**Fact:** archives are kept forever by default. `hermes curator purge [--days N] [--dry-run]` is explicit only, never automatic, and captures each purged skill into the ledger first.

## Pin, lock, and cron protection

**Fact:** `pin` stores `"pinned": true` in `.usage.json`. The curator skips the skill in auto-transitions and instructs its LLM pass to leave it alone, and `skill_manage` refuses `delete` on it while still allowing patches and edits. Only agent-created skills can be pinned.

**Fact:** `lock` stores `"locked": true`. Every agent write path refuses: `skill_manage` patch/edit/write_file/remove_file/delete in single and batch form, `write_file` and `patch` for any path inside the skill directory, and terminal commands that write there (redirection, `tee`, `cp`/`mv`/`rm`/`touch`/`mkdir`/`chmod`, `sed -i`, `perl -i`, git changes, archive extraction, inline `python -c`). Reading the skill and running its scripts still work, the agent cannot unlock it, and your own edits are never gated. It is a policy check, not a sandbox: `execute_code` and a script that writes into the skill through its own logic are not inspected.

**Fact:** both flags are per profile because they live in the profile's `.usage.json`.

## CLI surface

```bash
hermes curator status
hermes curator run [--consolidate] [--background] [--dry-run]
hermes curator pause | resume
hermes curator pin <skill> | unpin <skill>
hermes curator lock <skill> | unlock <skill>
hermes curator adopt <skill> | adopt --all-unmanaged | list-unmanaged
hermes curator restore <skill> | list-archived | archive <skill>
hermes curator prune [--days N]
hermes curator backup | rollback [--list] [--id <ts>] [-y]
hermes curator ledger [--skill <name>] [--limit N] | rollback <entry-id>
hermes curator purge [--days N] [--dry-run]
```

**Fact:** the same subcommands exist as `/curator` inside a running session. A run's end-of-run summary names each transition and, after a consolidation, an explicit `old-name → new-name` rename map.

**Recommendation:** run `--dry-run` once after installing or upgrading, and pin the skills a routine or cron job depends on. Prefer `lock` for skills that must not drift while an unattended deployment is running, and remember that a lock does not stop `hermes update` from refreshing an unmodified bundled or hub skill, because that is your command, not an agent write.
