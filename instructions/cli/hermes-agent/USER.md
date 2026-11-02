# Hermes Agent `USER.md`

> Korean version: [`USER.ko.md`](USER.ko.md)
>
> **Research date:** 2026-11-03, against the official documentation shipped in Hermes Agent **v0.22.5** (measured at commit `bf0203a794a`, released 2026-10-22). **Facts** below trace to those sources; **Recommendations** are this guide's operating policy, not Hermes guarantees. The store is written through the `memory` tool, so confirm its actions and approval flags on the installed version.

## Sources

| Source | What it supplies | Checked |
| --- | --- | --- |
| [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) | The `user` target, limits, approval surfaces, journey editing | checked 2026-11-03 |
| [Which File Does What](https://hermes-agent.nousresearch.com/docs/user-guide/which-file-does-what) | What `USER.md` holds versus `SOUL.md`, `MEMORY.md`, and project files | checked 2026-11-03 |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | `memory.user_char_limit`, `memory.write_approval`, `display.memory_notifications` | checked 2026-11-03 |
| [Profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles) | Per-profile memory scope and `hermes profile list` | checked 2026-11-03 |
| [Profile Distributions](https://hermes-agent.nousresearch.com/docs/user-guide/profile-distributions) | What a shared profile carries and excludes | checked 2026-11-03 |
| [FAQ](https://hermes-agent.nousresearch.com/docs/reference/faq) | Reported "it forgot my name" symptoms | checked 2026-11-03 |

## Purpose and boundary

**Fact:** `USER.md` is Hermes-managed profile context about a user: stable identity details, communication preferences, expectations, workflow habits, and technical skill level. It is not an agent persona, a project instruction file, a transcript, or a security tier.

| Need | Correct surface |
| --- | --- |
| The user's stable preferences and expectations | `USER.md` |
| Agent environment facts and learned workarounds | [`MEMORY.md`](MEMORY.md) |
| Agent identity and voice | `SOUL.md` |
| Repository instructions and architecture | `AGENTS.md`, `.hermes.md`, or project context files |
| Prior conversation detail | retained sessions and `session_search` |

**Fact:** the canonical path is `$HERMES_HOME/memories/USER.md`, so `~/.hermes/memories/USER.md` is the default-profile shorthand. One profile can serve many interactions or people, so the file is neither a per-person record nor a confidentiality boundary.

**Fact:** `SOUL.md` and `USER.md` never feed each other. `SOUL.md` is a file you edit; `USER.md` is written by the agent through the `memory` tool with `target: "user"`. Editing the persona does not populate the profile, and a profile entry does not change the persona.

## Lifecycle and capacity

**Fact:** Hermes renders `USER.md` into the system prompt as a frozen snapshot at session start. A successful write persists immediately and tool feedback is live, but the existing prompt keeps the session-start copy. `hermes sessions refresh-prompts` rebuilds the stored prompt for continuing sessions on their next turn; it is a post-v0.22.5 site addition, so confirm it with `hermes sessions --help`.

**Fact:** the documented default `memory.user_char_limit` is 1,375 characters (about 500 tokens). Hermes rejects overflow rather than compacting, checking the limit on the result of one `operations` batch; exact duplicates are successful no-ops.

**Recommendation:** keep about 5–10 durable, user-correctable statements. Run `/new` at a natural boundary on messaging platforms, because a gateway chat is one continuous session and the next session is what actually re-reads the updated profile.

## What belongs here

**Recommendation:** store only non-sensitive, durable preferences that improve later interactions:

- Preferred name, stable role, and a coarse timezone when it genuinely helps.
- Response depth, language, formatting, accessibility needs, and communication style.
- Stable workflow habits, technical skill level, and specific behaviors to avoid.
- Expectations that are clearly attributable and easy for the user to correct.

Do not use `USER.md` for project or tool facts, agent lessons, persona instructions, one-off task state, raw logs, full conversation details, vague inferences, or anything cheaply rediscovered. A procedure that should load only when relevant belongs in a skill, not in always-on profile context.

## Consent, accuracy, and correction

**Fact:** the agent saves profile facts automatically by default, including from the post-turn background self-improvement review. `memory.write_approval: true` prompts inline on interactive CLI turns and stages writes everywhere else for `/memory pending` review; `/memory approve <id>` and `/memory reject <id>` decide, and `/memory approval on|off` toggles the gate.

**Fact:** `hermes journey edit <node>` opens a memory chunk in `$EDITOR`, and `hermes journey delete <node>` removes it. `hermes journey list` prints the ids, including `memory:user:…` chunks. `display.memory_notifications` only changes how loudly the gateway chat announces an automatic save.

**Recommendation:** treat every profile assertion as correctable, and never record an agent inference as a user-confirmed identity fact. Enable approval when generated inferences need a person to review them, and keep one writing agent per Hermes home.

## Safety, privacy, and sharing

**Fact:** `USER.md` is persistent profile-scoped model context, not a secret vault. It can enter a model prompt, profile exports, and backups; external memory providers and retained sessions are additional data flows. Hermes documents pattern scanning for entries accepted through the memory path but promises no encryption at rest, no complete erasure, and no provider-specific retention guarantee.

**Recommendation:** never store passwords, API keys, tokens, cookies, private keys, recovery codes, financial or health identifiers, precise location, confidential third-party information, private infrastructure detail, or copied instructions from untrusted content.

**Recommendation:** keep shared-profile content minimal. A profile isolates Hermes state, not the OS account or every participant in a shared gateway. Before exporting or sharing a profile, inspect the archive: filename-based credential exclusions do not make memories, sessions, or persona content safe to distribute.

## Deletion and validation

**Recommendation:** deleting a `USER.md` entry removes that built-in record only. Assess the current frozen prompt, retained sessions, external provider data, exports, backups, and the model provider's policies separately.

Before relying on an entry:

1. Confirm the active profile and `$HERMES_HOME`.
2. Confirm the fact is stable, non-sensitive, necessary, and belongs in `USER.md` rather than [MEMORY.md](MEMORY.md) or a skill.
3. Confirm the wording is attributable and user-correctable rather than an unreviewed inference.
4. Review generated or automatic changes before adopting them for a sensitive workflow.
5. Start a fresh test session to observe injected context, or run `hermes sessions refresh-prompts` for a continuing one.
