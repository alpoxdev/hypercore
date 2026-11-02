# Hermes Agent `MEMORY.md`

> Korean version: [`MEMORY.ko.md`](MEMORY.ko.md)
>
> **Research date:** 2026-11-03, against the official documentation shipped in Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`, released 2026-10-22). **Facts** below trace to those sources; **Recommendations** are this guide's operating policy, not Hermes guarantees. Memory behavior is tied to the `memory` tool contract, so confirm the actions and approval flags on the installed version before automating.

## Sources

| Source | What it supplies | Checked |
| --- | --- | --- |
| [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) | Store limits, frozen snapshot, tool actions, `write_approval`, background review, journey | checked 2026-11-03 |
| [Which File Does What](https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what) | Ownership split between `SOUL.md`, `USER.md`, `MEMORY.md`, and project files | checked 2026-11-03 |
| [Memory Providers](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory-providers) | External providers, `memory.provider`, built-in stores staying active | checked 2026-11-03 |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | `memory.*`, `display.memory_notifications`, `auxiliary.background_review` defaults | checked 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | `hermes memory`, `hermes journey`, `hermes sessions refresh-prompts` | checked 2026-11-03 |
| [v0.22.5 release](https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.5) | Version anchor for the behavior above | checked 2026-11-03 |

## Purpose and boundary

**Fact:** `MEMORY.md` is the agent-managed note store for durable environment facts, project conventions, workflow lessons, and reusable operational knowledge. It is not the user's preference profile, an identity file, or a transcript archive:

| Need | Correct surface |
| --- | --- |
| Project rules, commands, and architecture | `AGENTS.md`, `.hermes.md`, or other project context files |
| Agent identity and durable persona | `SOUL.md` |
| User preferences and communication expectations | `USER.md` |
| Durable agent operational notes | `MEMORY.md` |
| A procedure that should load only when relevant | a skill; a memory entry competes for a 2,200-character budget |
| Details from a previous conversation | retained sessions and `session_search` (FTS5 over `state.db`) |

**Fact:** the canonical location is `$HERMES_HOME/memories/MEMORY.md`. The default profile usually makes that `~/.hermes/memories/MEMORY.md`; named profiles keep their own `HERMES_HOME`, so the default path is a shorthand, not a universal location.

## Frozen snapshot and session boundaries

**Fact:** both memory stores are rendered into the system prompt at session start and never change mid-session. The header shows the store name, the usage percentage, and the character counts; entries are separated by `§`. Accepted writes persist to disk immediately and tool responses show live state, but the already-built prompt keeps the session-start copy. Hermes documents this as deliberate: a stable prefix preserves the provider's prompt cache.

**Fact:** `hermes sessions refresh-prompts` makes continuing sessions rebuild their stored system prompt from the current `SOUL.md`, skills, and context files on their next turn, keeping history and session ids. `--session ID` limits it to one session, `-p/--profile` targets another profile, and each refreshed session pays one prompt-cache miss. It is documented on the current site but is **not** in the v0.22.5 tag's CLI reference (post-v0.22.5): verify with `hermes sessions --help`.

**Recommendation:** on messaging platforms a chat is one continuous session that survives restarts, so memory only pays off at a boundary. Run `/new` at a finished task, a topic change, or the start of a day; otherwise the learning loop never fires and compaction keeps working over an ever-longer history.

## Capacity, overflow, and duplicates

**Fact:** the documented defaults are `memory.memory_char_limit: 2200` (about 800 tokens) for `MEMORY.md` and `memory.user_char_limit: 1375` for `USER.md`. Memory does not auto-compact: a write that would exceed the limit returns an error naming the overflow, the current entries, and how many characters must be freed.

**Fact:** the limit is checked on the result of one `operations` batch, so freeing space and adding the new entry in the same call is the documented path. `patch` is bound by the same limit: a patch that lengthens an entry can still overflow. An exact duplicate `add` succeeds with a "no duplicate added" message.

**Recommendation:** treat roughly 8–15 compact entries as the practical shape and consolidate overlapping facts once usage passes 80%, which the system-prompt header always shows.

## Tool contract: `add`, `patch`, `remove`

**Fact:** the `memory` tool exposes three actions and no read action, because memory is already in the prompt:

| Action | Behavior |
| --- | --- |
| `add` | Append a new entry |
| `patch` | Replace one span (`old_text`) inside an existing entry and keep the rest; the span must occur exactly once in that entry |
| `remove` | Delete the entry matched by a short unique `old_text` substring |

**Fact:** `replace` no longer exists. It overwrote the whole matched entry and models used it as a find-and-swap, wiping the other facts in multi-fact entries; a `replace` call now returns an error pointing at `patch`. Writes staged for approval before the change still apply as staged.

**Fact:** every call carries a top-level `target` of `"memory"` or `"user"`, and one batch uses that target for every operation. A missing or null target, or an operation-level target that differs from the top-level one, fails before writing or staging. Exact whole-entry `old_text` wins over a substring match.

## Approval and review surfaces

**Fact:** `memory.write_approval` defaults to `false`, so the agent saves freely, including from the background self-improvement review. With `true`, foreground writes prompt inline in the interactive CLI and are staged everywhere else — messaging platforms, scripts, and the background review:

```text
/memory pending            # staged writes, automatic ones tagged [auto]
/memory approve <id>       # or 'all'
/memory reject <id>        # or 'all'
/memory approval on|off    # toggle and persist the gate
```

**Fact:** a staged `patch` or `remove` pins the full entry it targets; if that entry changes before approval, the write is refused and stays pending. `approve` lists the full text of every entry it overwrites or removes.

**Fact:** `display.memory_notifications` controls only the gateway chat line (`off`, `on` default, `verbose`); the review still runs and still writes. The review itself is configured under `auxiliary.background_review`: `enabled`, a different `provider`/`model` (which switches the fork to a compact digest replay), `max_input_tokens`, `defer` for a managed local GPU, and a narrow `extra_tools` allowlist. A same-model review inherits the parent's reasoning effort. `memory.nudge_interval` and `skills.creation_nudge_interval` set how often the nudges fire.

**Recommendation:** enable write approval when generated inferences need human review, but do not treat it as a backup of the store. It gates writes, not retention, and it does not remove the session-start copy already sent to the provider.

## Correcting entries outside a session

**Fact:** `hermes journey` (aliases `hermes learning`, `hermes memory-graph`) lists what Hermes has learned. `hermes journey list` prints skill names and `memory:<source>:<index>:<fingerprint>` ids, `hermes journey edit <node>` opens a memory chunk in `$EDITOR`, and `hermes journey delete <node>` removes a memory chunk. The same subcommands exist as `/journey` on the CLI and in the desktop panel.

**Recommendation:** prefer `journey edit` over hand-editing the file. It keeps the record attached to the id the agent already knows, and it does not risk a partial write while a session is running.

## Safety and trust boundary

**Fact:** `MEMORY.md` is profile-scoped persistent model context, not a secret store. It is injected into the prompt, so a remote model provider processes it. Sessions, external providers, profile exports, and backups are separate disclosure surfaces.

**Fact:** entries accepted through the memory tool are scanned for prompt-injection, credential-exfiltration, SSH-backdoor, and invisible-Unicode patterns and are blocked on a match. This is defense in depth and does not cover direct file edits, imports, restores, or provider content.

**Recommendation:** never store credentials, tokens, cookies, private keys, sensitive personal or third-party data, exploitable infrastructure detail, or verbatim untrusted instructions. Keep one writing agent per Hermes home: two processes on one home compound each other's entries, so give a second agent its own profile or use an external provider for deliberate sharing.

## External memory providers

**Fact:** `memory.provider` selects one external provider — bundled RetainDB or ByteRover, or Honcho, Hindsight, Supermemory, Mem0, OpenViking, or Holographic from the plugin catalog. Only one runs at a time, and it runs alongside the built-in files rather than replacing them. `hermes memory setup`, `hermes memory status`, and `hermes memory off` manage it.

**Fact:** setting both `memory_enabled` and `user_profile_enabled` to `false` drops the `memory` tool and its guidance from the prompt; an external provider keeps its own tools. Listing `memory` under `agent.disabled_toolsets` is the heavier switch and hides provider tools too. `memory.prefetch_spill_enabled` opts into head/tail previews of oversized provider recall.

## Privacy and deletion

**Recommendation:** treat deletion as scoped cleanup. Removing an entry changes this store but may not reach the frozen prompt already sent for the current session, session history, provider copies, external-provider data, exports, or backups. A profile isolates Hermes state, not the OS account or the humans behind one gateway.

## Failure triage

| Symptom | Documented cause | Action |
| --- | --- | --- |
| "I told it to remember" and the next session forgot | The model said it saved but never called the `memory` tool | Inspect the file; ask explicitly for a `memory` tool save; small or weak-tool-calling models do this |
| A write never reaches the file | `write_approval: true` staged it | `/memory pending`, then approve |
| A different store than expected | Memory is per profile | `hermes profile list`; check which profile the process runs |
| The tool is missing entirely | `memory_enabled: false` and `user_profile_enabled: false`, or `memory` under `agent.disabled_toolsets` | Fix the config; the model cannot save what has no tool |
| A fact is invisible in a running session | Frozen snapshot | Start a new session, or `hermes sessions refresh-prompts` for a continuing one |

## Validation

1. Confirm the active `HERMES_HOME` and profile before editing or automating memory.
2. Check that each entry belongs here rather than in `USER.md`, `SOUL.md`, project context, or a skill.
3. Review the entry for secrets, sensitive data, untrusted directives, and stale facts.
4. Start a fresh test session before relying on a change as injected prompt context.
5. Re-read the [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) reference after upgrading; the tool actions and approval flags have changed across releases.
