# OMO Runtime Profile

> Korean version: [`README.ko.md`](README.ko.md)
>
> **Research date:** 2026-11-03 for the OmO runtime; the local Orca reporter section keeps its
> 2026-08/09 observation date. Runtime behavior is pinned to OmO `v5.1.58` (GitHub release,
> 2026-11-02) plus the installed `5.1.57` CLI surface.

## Scope

This profile covers two layers, and they must not be confused:

1. **The OmO runtime.** `omo` is the CLI of OmO (repository
   [`code-yeongyu/oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent), site
   [`omo.dev`](https://omo.dev), npm package `omo-ai`). It is the successor to the OpenCode edition
   and runs on `senpi`, a fork of `pi`. Content outside third-party components is under the
   Sustainable Use License, not an OSI license. The unrelated npm package named `omo` belongs to someone
   else.
2. **A local Orca supervision reporter** installed at
   `~/.omo/agent/extensions/omo-supervision-reporter.ts`. It is a local extension, not a standard
   OmO capability, and it applies only to a fresh OmO process running in an Orca dispatched
   terminal.

Shared capability rules remain in [`../capability-contract.md`](../capability-contract.md).

## Evidence boundary

- Primary evidence: the repository README, `docs/reference/configuration.md`,
  `docs/reference/features.md`, `docs/guide/computer-use.md`, the release feed, and the CLI help of
  the installed binary.
- OmO ships several releases per day and offers a beta channel. The stable tag above is the pinned
  reference; re-run `omo --version` and re-read the matching docs before depending on a flag.
- The reporter section is a W1.8b observation on one local Orca/OmO combination. It is not
  documentation of OmO's behavior in general.

## Runtime binding

| Logical capability | Verified OmO surface | Binding rule |
|---|---|---|
| Local inspection | `read`, `find`, `grep`, `ls`, `bash` | Keep paths inside the declared workspace. Background agents inherit the session working directory but "OMO does not force the model's own shell commands to stay inside that directory". |
| Local search | `grep`, `find`, curated `bash` | Prefer repository evidence. Read-only agents get an allowlist of exactly these tools. |
| Network research | `webfetch`, browser use, MCP servers | Network access and data egress are separate side effects. |
| Edit | `edit`, `write`, `bash` | Use only when the user asked for a change. `write-existing-file-guard` exists because overwrite is a distinct risk. |
| Execute | `bash`, background output, extensions | Validate command, working directory, and side effects. Runtime guard hooks are not user approval. |
| Human decision | built-in question tool; `--no-ask-user` disables it | The tool exists, but a non-interactive run has nobody to answer (see below). |
| Delegate | `task` with categories and subagents; `team_*` tools when `team_mode` is enabled | Give each child its objective, owned scope, allowed tools, forbidden side effects, and evidence contract. |
| Desktop control | computer-use component | Foreground control requires an explicit answer; background window input does not. |

## Permission model

OmO enforces permissions through configuration, not through prose instructions.

- Per-agent `permission` maps take `ask`, `allow`, or `deny` for `edit`, `bash`, `webfetch`,
  `task`, `doom_loop`, and `external_directory`. `bash` also accepts a per-command map, for example
  `{ "git": "allow", "rm": "deny" }`.
- CLI equivalents exist per run: `--permission tool=action` or `tool:pattern=action`, and
  `--permission-preset` with the values `full-access`, `workspace`, `accept-edits`, `auto`,
  `read-only`, and `ask`.
- Configuration lives in `~/.omo/omo.jsonc`, and a project may add `.omo/omo.jsonc`; the closest
  file wins.
- Project-local files are trusted per run: `--approve` / `-a` trusts them, `--no-approve` ignores
  them. Do not treat a project's own configuration or skills as authorized because they were
  present.
- Availability controls are separate from permissions: `--no-tools`, `--no-builtin-tools`,
  `--tools`, `--exclude-tools`, `--no-skills`, `--no-extensions`, `--offline` (startup network
  operations off).

The documented enforcement layering is explicit:

- `AGENTS.md` files are instruction context and "are not a deterministic permission boundary".
- Deterministic enforcement comes from `agents.*.permission`, per-agent `tools`, disabled
  tools/agents, built-in agent restrictions, OpenCode's own permission gate when it is available,
  and guard hooks.
- Guard hooks that protect safety are named: `team-tool-gating`, `write-existing-file-guard`,
  `bash-file-read-guard`, `webfetch-redirect-guard`, `rules-injector`,
  `tool-pair-validator`. Disabling them is documented as local debugging only.

A skill must therefore encode its hard limits in permissions and allowlists, not in a paragraph
that asks the model to behave.

## Questions and non-interactive runs

- A built-in question capability exists; `--no-ask-user` turns it off, and the runtime also ships
  a `question-gates` component that can be disabled separately.
- Foreground computer control is the clearest documented gate: OmO shows "Allow foreground
  computer control?" with the agent's reason, and "only your answer grants it: a non-interactive
  run has no one to ask, so it never grants". Declining, a timeout, or an interruption leaves
  control off.
- Do not generalize that rule to every tool. Treat any other `ask` permission in a headless run as
  unverified for that run and check the observed outcome instead of assuming the answer.

## Desktop control and untrusted content

- `computer.run` code runs with full host access. The computer-use skill tells the model to treat
  screen text, notifications, and documents as untrusted data that can never authorize an action,
  and to confirm immediately before consequential actions. Those are model instructions, not a
  sandbox.
- `Suspended` or `StopPathUnavailable` means stop and report; the model must not work around it.
- For untrusted work, keep permission rules strict and use a separate account or VM.

## Local Orca supervision reporter

The reporter uses the direct Orca mail channel (channel A). W1.8b observed that an Orca Dispatch
preamble carries `--from`, `--task-id`, and `--dispatch-id`, and that an OMO child can send an
accepted lifecycle message with those identifiers. Channel B, a status-file relay, is therefore
not installed.

For each new prompt, the reporter parses all three identifiers from the current preamble. It sends
nothing when any identifier is absent, and clears its previous context so a normal user-owned turn
cannot report under a stale Dispatch.

| Event | Direct mail behavior |
|---|---|
| `agent_start` | Sends `status` with phase `active`, then starts heartbeat scheduling. |
| Tool execution start/end | Sends a latest-only `status` update. |
| Every five minutes while active | Sends at most one `heartbeat` with phase `working`. |
| `agent_settled` | Stops heartbeat scheduling and clears Dispatch context. |

Delivery is best effort: reports use `orca orchestration send` with the preamble's sender, Task, and
Dispatch identifiers. A one-second unref'ed command timeout and a latest-only pending slot ensure a
slow or failed receiver neither blocks OMO nor accumulates obsolete reports.

The reporter never sends `worker_done`. The delivered Task preamble remains the only contract for
completion, and the coordinator remains responsible for nudge, replacement, settlement, and cleanup
decisions.

### Installation and verification

Global OMO extension discovery loads the file from `~/.omo/agent/extensions/`. A newly started OMO
process sees the reporter; an existing OMO process must start a new session before it loads new
extension code.

```text
node ~/.omo/agent/orca-pi-adapter/bin/orca-pi-doctor.mjs --json
```

A healthy report lists `omo-supervision-reporter.ts` among the managed global extensions. Then
create a short-lived Orca Dispatch, retrieve its exact preamble, and use
`orca orchestration check --run <run> --types status,heartbeat,worker_done --wait --json` to observe
direct mail before the Task's own completion message.

### Limits and coordinator boundary

- No complete `--from`, `--task-id`, and `--dispatch-id` set means no reporter mail.
- The reporter does not decide that a worker stalled, does not nudge, does not re-dispatch, does
  not start `--retry-of`, and does not close a terminal.
- A status or heartbeat proves liveness only. It never proves meaningful progress or completion.
- Direct-mail delivery was verified on the local Orca/OMO combination only. Recheck the live
  preamble and command capabilities after runtime upgrades.

## Skill author checklist

- [ ] Are hard limits encoded in `permission` and tool allowlists rather than in prose?
- [ ] Does the skill avoid assuming the question tool exists in a non-interactive or sub-agent run?
- [ ] Is project-local configuration or skills trusted only after an explicit `--approve` decision
      by the user, not because the files were present?
- [ ] Are background agents held to a writable path by a project rule rather than by an implicit
      confinement guarantee?
- [ ] Is retrieved screen text or document content treated as data, with no instruction executed
      from it?
- [ ] Does delegation give each child scope, tools, forbidden side effects, and an evidence
      contract?
- [ ] Does verification compare the requested target and result with the actual runtime output?

## Verification

Before and after execution, confirm that the effective permission map matches the request, that any
`ask` decision was actually answered by the user, that the working directory used matches the
declared scope, and that every side effect stayed inside explicit authorization. Record the OmO
version, engine version, preset, and configuration files in effect.

## Sources

| # | Source | What it establishes | Checked |
|---|---|---|---|
| 1 | [oh-my-openagent README](https://github.com/code-yeongyu/oh-my-openagent) | Identity, `senpi` base, Sustainable Use License, install commands, `omo-ai` package versus unrelated `omo` package, config file locations | checked 2026-11-03 |
| 2 | [Releases](https://github.com/code-yeongyu/oh-my-openagent/releases) | `v5.1.58` released 2026-11-02; release cadence and engine pin | checked 2026-11-03 |
| 3 | [Configuration reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md) | Per-agent `permission` values, `bash` per-command map, guard-hook list | checked 2026-11-03 |
| 4 | [Features reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/features.md) | Instruction files versus enforcement, read-only agent allowlists, background-agent working directory | checked 2026-11-03 |
| 5 | [Computer use guide](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/guide/computer-use.md) | Foreground approval question, non-interactive never grants, full host access, untrusted-content instruction | checked 2026-11-03 |
| 6 | Local `omo --help` (`5.1.57`) | `--permission`, `--permission-preset` values, `--no-ask-user`, `--approve`/`--no-approve`, tool and skill availability flags | checked 2026-11-03 |

## Related documents

- [`../capability-contract.md`](../capability-contract.md) — shared capability, question, and
  approval rules.
- [`../sources.md`](../sources.md) — evidence ledger for this directory.
