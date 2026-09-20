# CLI Runtime Profile Evidence Ledger

> Korean version: [`sources.ko.md`](sources.ko.md)

## Investigation scope and limits

- Date checked: 2026-09-19
- Default channel: documentation inside the project repository only.
- Claude Code and Codex exception: the local skills that carried these two profiles' evidence (`skills/claude-code`, `skills/codex`) were removed from the distribution tree in commit `d4f79f9`. These profiles now rest on the first-party vendor documentation listed below, re-verified 2026-09-19. No credentials were used, nothing was installed, and no local configuration was treated as authority.
- JCode exception: the user explicitly requested source-backed research for `jcode.sh`; its profile uses the version-pinned official source, release artifacts, rendered docs, executed `v0.81.1` help/tests, and dated counter-evidence listed below.
- Excluded by default: home-directory settings, global skills, and live help from an installed CLI.
- Conclusion: this ledger records not a complete product feature list but the minimum capabilities and boundaries directly supported by the declared evidence channel. OpenCode, GJC, Hermes Agent, and OpenClaw have no local evidence, so those profiles handle their capabilities through runtime discovery and fallback.
- Schema exception: this is a repository-maintenance ledger, so it uses the simplified schema [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md) §7 allows — source, type, what was verified, and where it is used, without retrieval metadata for material that never leaves the repository.

## Source ledger

| # | Source | URL/path | Type | Verified content | Used in |
|---:|---|---|---|---|---|
| 1 | Project scope rules | [`../../AGENTS.md`](../../AGENTS.md) | Local rules | Restrict investigation and references to inside the repository; do not use global settings as evidence | Evidence scope of every document |
| 2 | Instructions Base | [`../README.md`](../README.md) | Local guide | Separate the runtime-neutral core from runtime profiles, and describe tools by capability | `README.md`, `capability-contract.md` |
| 3 | Runtime Profiles | [`../context-engineering/references/runtime-profiles.md`](../context-engineering/references/runtime-profiles.md) | Local reference | Shared rules are capability-centric; per-runtime differences live in a separate profile | Layers and terminology |
| 4 | Skill Authoring | [`../skill/SKILL_AUTHORING.md`](../skill/SKILL_AUTHORING.md) | Local guide | A skill separates intent, scope, authority, tools, and verification, and sets safety boundaries | Skill authoring patterns and verification |
| 5 | Claude Code CLI reference | [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference) | First-party live docs | `-p`/`--print`, `--continue`/`--resume`, `--output-format`, `--add-dir`, `--bare`, and global flags | `claude-code/README.md` |
| 6 | Claude Code permission modes | [code.claude.com/docs/en/permission-modes](https://code.claude.com/docs/en/permission-modes) | First-party live docs | `default` (Manual), `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`, and the `manual` alias | `claude-code/README.md` |
| 7 | Codex command line options | [developer-commands.md?surface=cli](https://learn.chatgpt.com/docs/developer-commands.md?surface=cli) | First-party live docs | `codex exec`/`e`, `exec resume --last`/`--all`, the four `codex review` targets, `codex resume`, `codex fork`, `--sandbox`, `-a`/`--ask-for-approval`, `--add-dir`, `-C`/`--cd` | `codex/README.md` |
| 8 | Codex agent approvals and security | [learn.chatgpt.com/docs/agent-approvals-security.md](https://learn.chatgpt.com/docs/agent-approvals-security.md) | First-party live docs | Sandboxing, approvals, and network controls | `codex/README.md` |
| 9 | JCode official docs | [jcode.sh/docs](https://jcode.sh/docs) | First-party live docs | Install, providers, config, MCP, remote, skills, commands, and SDK discovery surface | `jcode/README.md` |
| 10 | JCode v0.81.1 source | [`1jehuang/jcode@cae6d2a`](https://github.com/1jehuang/jcode/tree/cae6d2a573ebfdbfaca085a82abb1f0b72faac69) | Version-pinned first-party source | Config precedence, tool policy, command-risk, path, MCP, session, memory, swarm, SDK, gateway, hooks, and automation behavior | `jcode/README.md` |
| 11 | JCode v0.81.1 release | [v0.81.1](https://github.com/1jehuang/jcode/releases/tag/v0.81.1) | First-party release | Release date, assets, checksums, and source boundary | `jcode/README.md` |
| 12 | JCode onboarding | [jcode.sh/onboarding](https://jcode.sh/onboarding) | First-party rendered page | Test-backed onboarding states and existing-login import claim | `jcode/README.md` |
| 13 | JCode telemetry contract | [`TELEMETRY.md@v0.81.1`](https://github.com/1jehuang/jcode/blob/cae6d2a573ebfdbfaca085a82abb1f0b72faac69/TELEMETRY.md) | Version-pinned policy/source document | Aggregate telemetry, opt-out controls, transcript opt-in, content, retention, and redaction caveat | `jcode/README.md` |
| 14 | JCode issue counter-search | [`1jehuang/jcode` issues](https://github.com/1jehuang/jcode/issues) | User reports plus linked source/PRs | Version drift and limits for approvals, MCP, sessions, swarms, providers, installers, and remote behavior | `jcode/README.md` caveats only |
| 15 | Anthropic authentication policy | [Legal and compliance](https://code.claude.com/docs/en/legal-and-compliance#authentication-and-credential-use) | Provider primary policy | Subscription OAuth boundaries for third-party products and the unmodified Claude Code binary exception | `jcode/README.md` provider warning |

> `AGENTS.md` and `AGENTS.ko.md` are version controlled. `CLAUDE.md` is covered by `.gitignore:45` and is therefore **not** version controlled (checked 2026-09-19: `git ls-files` lists `AGENTS.md`, and `git check-ignore` reports only `CLAUDE.md`). Evidence #1 of this ledger therefore exists in every clone, and only a `CLAUDE.md`-specific reference would break.

## Claim-source matrix

| Claim | Source(s) | Confidence | Caveat |
|---|---|---|---|
| Shared skill rules are capability-centric and per-runtime differences are separated into profiles | 2, 3 | High | This is this project's document design rule, not a claim about a common product standard. |
| The Claude Code bridge covers non-interactive execution, session resume, and permission modes | 5, 6 | High | First-party documentation for the CLI and its permission modes, not a guarantee about the installed version. |
| The Codex bridge covers `exec`, `review`, resume, fork, and sandbox flows | 7, 8 | High | First-party documentation for the CLI and its approval/sandbox model, not a guarantee about the installed version. |
| Plain-text questions are used on Codex | 7 | Medium | This is an operating rule of this project's profiles. No reviewed first-party page documents a structured question tool for `codex exec`, so this is an absence finding within the reviewed pages only. |
| OpenCode's question and approval capabilities cannot be established from evidence in this repository | Searches of `instructions`, `skills`, and `README.md` in the repository | High | The one local skill that carried the precedent was removed in `d4f79f9`; the profile now states it as a convention and requires runtime discovery. |
| GJC's static tool list cannot be settled from evidence in this repository | Searches of `instructions`, `skills`, and `README.md` in the repository | High | Proof of absence is limited to the repository scope. |
| Hermes Agent and OpenClaw product-specific capabilities cannot be established from this repository | Searches of `instructions`, `skills`, and `README.md` in the repository | High | The absence finding is limited to the repository; no first-party documentation was consulted for these two runtimes. |
| JCode v0.81.1 exposes broad tools but ordinary interactive execution has no verified general human-approval or workspace-sandbox boundary | 10, 14 | High | Tool profiles and catastrophic Bash denial are limited runtime defenses; availability is still not authorization. |
| JCode project MCP configuration is executable stdio configuration and can start without a project trust prompt | 9, 10, 14 | High | HTTP/SSE entries are skipped in v0.81.1; inspect every project MCP command and environment before use. |
| JCode sessions, memory, swarms, background work, SDK, and non-interactive run are implemented but version-sensitive | 9, 10, 11, 14 | High | Active issues, stale documentation, registry/source version differences, and auto-poke multi-turn behavior require runtime verification. |
| JCode telemetry and transcript sharing have different consent boundaries | 13 | High | Aggregate telemetry is documented as enabled unless disabled; full transcripts are separately opt-in and heuristic redaction is not a guarantee. |
| JCode's `claude` subscription OAuth route is not aligned with Anthropic's published third-party authentication policy | 10, 14, 15 | High | Technical functionality is not policy authorization; prefer the distinct `anthropic-api` route and recheck policy at runtime. |

## Update conditions

Update this ledger when any of the following happens.

- A version-pinned official CLI reference or a verified runtime profile is added to the project.
- A skill newly depends on a specific CLI's question, approval, or tool capability.
- CLI command or permission behavior changes, making an existing profile's fallback or safety gate inaccurate.
- JCode publishes a release that changes config precedence, approval/tool policy, MCP trust, gateway transport, automation output, credential import, telemetry, or SDK protocol behavior.

When updating, add the evidence first, then modify the relevant profile and shared contract, and finally re-check links, the claim-source matrix, and the smoke eval.
