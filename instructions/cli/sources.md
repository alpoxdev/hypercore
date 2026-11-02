# CLI Runtime Profile Evidence Ledger

> Korean version: [`sources.ko.md`](sources.ko.md)

## Investigation scope and limits

- Date checked: 2026-11-03. Every row below was read on that date (checked 2026-11-03) unless the row says otherwise.
- Channel: first-party vendor documentation read in a browser session through Aside, plus direct `read`/`curl` confirmation of each cited URL. No credentials were used, nothing was installed, and no local configuration or installed-CLI help output was treated as authority.
- Scope rules: repository-local rules still govern what a skill may do; vendor documentation only describes what a runtime exposes. A capability confirmed in one session is evidence for that run, not a permanent feature claim.
- Date reality: the Claude Code, Codex, OpenCode, and Hermes documentation pages publish no visible last-updated or publication stamp. For those rows the recorded date is the **read** date, and version anchoring comes from a dated release or changelog entry where one exists (Codex CLI 0.166.0 on 2026-10-29; Claude Code changelog 2.1.316 on 2026-10-31; OpenCode pages show "Last updated: Nov 2, 2026"; Hermes Agent `v0.22.5` on 2026-10-22).
- Rows 34-48 and 49-73 were supplied by the owning lanes (`CliRuntimes`, `HermesA`, `HermesB`) on 2026-11-03 and merged here unchanged in substance; each lane re-read its pages that day.
- Excluded by default: home-directory settings, global skills, and live help from an installed CLI.
- Conclusion: this ledger records the minimum capabilities and boundaries the named sources directly support, not a complete product feature list. An unsupported claim is handled through runtime discovery and the fallback in [`capability-contract.md`](capability-contract.md).
- Schema: this is a repository-maintenance ledger, so it uses the simplified schema [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md) §7 allows — source, type, what was verified, and where it is used. Because most pages carry no publication date, a per-row retrieval timestamp would misrepresent precision; the section-level read date covers it.

## Source ledger

| # | Source | URL/path | Type | Verified content | Used in |
|---:|---|---|---|---|---|
| 1 | Project scope rules | [`../../AGENTS.md`](../../AGENTS.md) | Local rules | Scope and evidence rules for this repository | Evidence scope of every document |
| 2 | Instructions Base | [`../README.md`](../README.md) | Local guide | Runtime-neutral core separated from runtime profiles; tools described by capability | `README.md`, `capability-contract.md` |
| 3 | Runtime Profiles reference | [`../context-engineering/references/runtime-profiles.md`](../context-engineering/references/runtime-profiles.md) | Local reference | Shared rules are capability-centric; per-runtime differences live in a profile | Layers and terminology |
| 4 | Skill Authoring | [`../skill/SKILL_AUTHORING.md`](../skill/SKILL_AUTHORING.md) | Local guide | A skill separates intent, scope, authority, tools, and verification | Skill authoring patterns |
| 5 | Claude Code CLI reference | <https://code.claude.com/docs/en/cli-reference> | First-party docs | All 80 documented flags, including `-p/--print`, `-c/--continue`, `-r/--resume`, `--output-format`, `--permission-mode`, `--allowedTools`, `--tools`, `--agents`, `--bg`, `--exec`, `--worktree`, `--restricted`; removed `--enable-auto-mode`, deprecated `--remote` | `claude-code/README.md` |
| 6 | Claude Code permission modes | <https://code.claude.com/docs/en/permission-modes> | First-party docs | Six modes (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`), the Manual label with `manual` alias, start-mode precedence, the list no mode auto-approves, and the `AskUserQuestion` tool reference | `claude-code/README.md` |
| 7 | Claude Code commands | <https://code.claude.com/docs/en/commands> | First-party docs | 121 command entries incl. `/goal`, `/loop`, `/schedule`, `/subtask`, `/fork`, `/batch`, `/tasks`, `/list-agents`, `/hooks`, `/skills`, `/plugin`, `/workflows`; removals of `/pr-comments`, `/ultraplan`, `/vim` | `claude-code/README.md` |
| 8 | Claude Code subagents | <https://code.claude.com/docs/en/sub-agents> | First-party docs | Definition locations and priority, required `name`/`description`, full frontmatter set, background-by-default, 20 concurrent default, 3 nesting layers, `isolation: worktree` | `claude-code/README.md` |
| 9 | Claude Code hooks reference | <https://code.claude.com/docs/en/hooks> | First-party docs | 33 events, five handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`), config locations, mod hook surface | `claude-code/README.md` |
| 10 | Claude Code skills | <https://code.claude.com/docs/en/skills> | First-party docs | `SKILL.md` layout, seven load locations, optional frontmatter, and that custom commands were merged into skills | `claude-code/README.md` |
| 11 | Claude Code plugins overview | <https://code.claude.com/docs/en/plugins/overview> | First-party docs | Plugin as a unit of skills/agents/hooks/mods/MCP/LSP, marketplace as a catalog repository, install scopes | `claude-code/README.md` |
| 12 | Claude Code dynamic workflows | <https://code.claude.com/docs/en/workflows> | First-party docs | Background script orchestration, 16 concurrent agents default (max 256), 1,000 agents per run, no mid-run input, save and resume behavior | `claude-code/README.md` |
| 13 | Claude Code session scheduling | <https://code.claude.com/docs/en/scheduled-tasks> | First-party docs | `/loop` interval syntax, 5-field cron, 50 tasks per session, 7-day expiry, `loop.md` precedence | `claude-code/README.md` |
| 14 | Claude Code cloud scheduled tasks | <https://code.claude.com/docs/en/routines> | First-party docs | `/schedule` with `/routines` alias, research preview, hourly minimum, cloud execution | `claude-code/README.md` |
| 15 | Codex command line reference | <https://learn.chatgpt.com/docs/developer-commands?surface=cli> | First-party docs | Global flags, the full subcommand list, `codex exec` and its resume/fork forms, `codex review` single-target rule, `codex plugin`/`codex mcp` | `codex/README.md` |
| 16 | Codex agent approvals and security | <https://learn.chatgpt.com/docs/agent-approvals-security> | First-party docs | Sandbox-versus-approval layering, retirement of `approval_policy = "untrusted"`, the `Auto` preset, network off by default, destructive app/MCP calls always needing approval | `codex/README.md` |
| 17 | Codex sandbox | <https://learn.chatgpt.com/docs/sandboxing> | First-party docs | Sandbox applies to spawned commands, platform enforcement, platform prerequisites | `codex/README.md` |
| 18 | Codex subagents | <https://learn.chatgpt.com/docs/agent-configuration/subagents> | First-party docs | Parallel delegation, `/subagents`, sandbox/approval inheritance, TOML custom agents in `~/.codex/agents/` and `.codex/agents/`, `[agents]` keys, non-interactive approval failure | `codex/README.md` |
| 19 | Codex skills | <https://learn.chatgpt.com/docs/build-skills> | First-party docs | `.agents/skills` scan locations, required `name`/`description`, `agents/openai.yaml` policy, `[[skills.config]]`, context budget | `codex/README.md` |
| 20 | Codex hooks | <https://learn.chatgpt.com/docs/hooks> | First-party docs | Event list, `hooks.json` locations, hash-pinned trust review, `/hooks`, `--dangerously-bypass-hook-trust` | `codex/README.md` |
| 21 | Codex scheduled tasks | <https://learn.chatgpt.com/docs/automations> | First-party docs | Scheduled tasks run in ChatGPT web or the desktop app; the CLI has no Scheduled management interface | `codex/README.md` |
| 22 | Codex long-running work | <https://learn.chatgpt.com/docs/long-running-work> | First-party docs | `/goal` Goal mode in the CLI, goal text as first prompt and completion criteria, no broader access | `codex/README.md` |
| 23 | Codex CLI overview | <https://learn.chatgpt.com/docs/codex/cli> | First-party docs | Entry points, `/permissions`, `codex resume`, `codex --search`, `codex mcp`, review pointer | `codex/README.md` |
| 24 | ChatGPT and Codex changelog | <https://learn.chatgpt.com/docs/changelog> | First-party changelog | Newest Codex CLI entry 0.166.0 on 2026-10-29; GPT-5.5 retirement on 2026-10-14 | Version anchor for `codex/README.md` |
| 25 | OpenCode permissions | <https://opencode.ai/docs/permissions/> | First-party docs | `allow`/`ask`/`deny`, object syntax with last-match-wins, key list incl. `question` and `doom_loop`, permissive defaults, `once`/`always`/`reject`, `--auto` | `opencode/README.md` |
| 26 | OpenCode agents | <https://opencode.ai/docs/agents/> | First-party docs | Primary versus subagent, agent markdown in `~/.config/opencode/agents/` and `.opencode/agents/`, frontmatter set, `@` invocation, built-in agents | `opencode/README.md` |
| 27 | OpenCode tools | <https://opencode.ai/docs/tools/> | First-party docs | Built-in tool inventory and the `question` tool contract (header, text, options, custom answer) | `opencode/README.md` |
| 28 | OpenCode plugins | <https://opencode.ai/docs/plugins/> | First-party docs | Local and npm loading, `tool.execute.before/after`, `shell.env`, compaction hook, and `permission.asked`/`permission.replied` as events only | `opencode/README.md` |
| 29 | OpenCode skills | <https://opencode.ai/docs/skills/> | First-party docs | `SKILL.md` discovery paths incl. `.claude/skills` and `.agents/skills`, required fields, `skill` permission behavior | `opencode/README.md` |
| 30 | OpenCode CLI | <https://opencode.ai/docs/cli/> | First-party docs | `opencode run` flags (`--format json`, `-c`, `-s`, `--fork`, `--agent`, `--attach`, `--auto`), `serve`, and `OPENCODE_ENABLE_QUESTION_TOOL` | `opencode/README.md` |
| 31 | OpenCode config | <https://opencode.ai/docs/config/> | First-party docs | Plural config subdirectories with singular fallback, `subagent_depth` default 1, deprecated `tools`/`maxSteps` | `opencode/README.md` |
| 32 | OpenCode 2 permissions | <https://opencode.ai/v2/docs/permissions/> | First-party docs | `permissions` array with action/resource/effect, `shell`/`subagent` names, base allow policy, no-match resolves to `ask`, saved approvals never override `deny` | `opencode/README.md` |
| 33 | OpenCode 2 plugins | <https://opencode.ai/v2/docs/plugins/> | First-party docs | `plugins` array, `opencode plugin` CLI, and built-in policy plugins that ignore removal | `opencode/README.md` |
| 34 | OpenClaw documentation | <https://docs.openclaw.ai/> | First-party docs | Self-hosted gateway, built-in tool categories incl. `ask_user`, `tools.exec.mode`, exec-approval agreement, sandbox/policy/elevated layers | `openclaw/README.md` |
| 35 | OpenClaw `v2026.10.9` release | <https://github.com/openclaw/openclaw/releases> | First-party release | Latest stable tag published 2026-10-29; docs carry no per-page dates | `openclaw/README.md` |
| 36 | Gajae-Code repository | <https://github.com/Yeachan-Heo/gajae-code> | First-party source/docs | `gjc` identity, plan-before-mutation approval wording, no permission-bypass flag | `gjc/README.md` |
| 37 | Gajae-Code releases | <https://github.com/Yeachan-Heo/gajae-code/releases> | First-party release | Stable `v0.19.2` on 2026-10-29; nightly channel ahead of stable | `gjc/README.md` |
| 38 | GJC tool and trust references | [`docs/tools`](https://github.com/Yeachan-Heo/gajae-code/tree/main/docs/tools), [`customization.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/customization.md), [`hooks.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/hooks.md) | First-party docs | `ask` conditional registration with timeout auto-select, bash interceptor limits, project MCP autoload, fail-closed hooks | `gjc/README.md` |
| 39 | OmO documentation set | [configuration](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md), [features](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/features.md), [computer use](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/guide/computer-use.md) | First-party docs | Per-agent `permission`, guard-hook enforcement, instruction files are not a boundary, foreground computer approval | `omo/README.md` |
| 40 | OmO `v5.1.58` release | <https://github.com/code-yeongyu/oh-my-openagent/releases> | First-party release | Latest version 2026-11-02; `senpi` engine pin; `omo-ai` npm identity | `omo/README.md` |
| 41 | JCode docs and SDK | <https://jcode.sh/docs>, <https://jcode.sh/sdk> | First-party live docs | Install/provider/config/MCP/skills/remote/gateway surface, `permission_request` + `respondToPermission`, isolation is not a sandbox, telemetry payload | `jcode/README.md` |
| 42 | JCode releases | <https://github.com/1jehuang/jcode/releases> | First-party releases | Stable `v0.99.1` on 2026-10-22; `v1.0.0-preview.*` channel; `v0.97.0` telemetry option; `v0.98.1` `user_response` | `jcode/README.md` |
| 43 | JCode v0.81.1 source | [`1jehuang/jcode@cae6d2a`](https://github.com/1jehuang/jcode/tree/cae6d2a573ebfdbfaca085a82abb1f0b72faac69) | Version-pinned source | Config precedence, tool policy, command risk, path, MCP, session, memory, swarm, SDK, gateway, hooks, automation | `jcode/README.md` |
| 44 | JCode v0.81.1 release | <https://github.com/1jehuang/jcode/releases/tag/v0.81.1> | First-party release | Release date, assets, checksums, source boundary | `jcode/README.md` |
| 45 | JCode onboarding | <https://jcode.sh/onboarding> | First-party page | Test-backed onboarding states, existing-login import claim | `jcode/README.md` |
| 46 | JCode telemetry contract | [`TELEMETRY.md@v0.81.1`](https://github.com/1jehuang/jcode/blob/cae6d2a573ebfdbfaca085a82abb1f0b72faac69/TELEMETRY.md) | Version-pinned policy | Aggregate telemetry, opt-outs, transcript opt-in, retention, redaction caveat | `jcode/README.md` |
| 47 | JCode issue counter-search | <https://github.com/1jehuang/jcode/issues> | User reports plus linked source | Version drift and limits for approvals, MCP, sessions, swarms, providers, installers, remote | `jcode/README.md` caveats |
| 48 | Anthropic authentication policy | <https://code.claude.com/docs/en/legal-and-compliance#authentication-and-credential-use> | Provider primary policy | Subscription OAuth boundaries for third-party products | `jcode/README.md` warning |
| 49 | Hermes Agent documentation | <https://hermes-agent.nousresearch.com/docs> | First-party docs | Docs home, navigation, canonical no-trailing-slash form | `hermes-agent/README.md` |
| 50 | Hermes Agent full docs export | <https://hermes-agent.nousresearch.com/docs/llms-full.txt> | First-party docs export | 247-page corpus used to re-read every Hermes page in one pass | `hermes-agent/**` |
| 51 | Hermes CLI commands reference | <https://hermes-agent.nousresearch.com/docs/reference/cli-commands> | First-party docs | `hermes chat -q`/`--oneshot`, `--safe-mode` requirements, dot-escaped config keys | `hermes-agent/README.md` |
| 52 | Hermes Configuration | <https://hermes-agent.nousresearch.com/docs/user-guide/configuration> | First-party docs | Approvals keys, terminal backends, `database:`, tool-loop guardrails defaulting to hard stop | `hermes-agent/CONFIGURATION.md` |
| 53 | Hermes Security | <https://hermes-agent.nousresearch.com/docs/user-guide/security> | First-party docs | Approval model, removed `tirith` key, `SOUL.md` scanner exception | `hermes-agent/CONFIGURATION.md` |
| 54 | Hermes Persistent Memory | <https://hermes-agent.nousresearch.com/docs/user-guide/features/memory> | First-party docs | `add`/`patch`/`remove` with no `replace`, top-level `target`, approval surfaces | `hermes-agent/MEMORY.md` |
| 55 | Hermes Context Files | <https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files> | First-party docs | Truncation percentages, 32,000-char hint cap, 5 s read timeout | `hermes-agent/CONTEXT_FILES.md` |
| 56 | Hermes Skills System | <https://hermes-agent.nousresearch.com/docs/user-guide/features/skills> | First-party docs | Four-tier precedence, `auto_load`/`create_dir`, curator interaction | `hermes-agent/SKILLS.md` |
| 57 | Hermes Creating Skills | <https://hermes-agent.nousresearch.com/docs/developer-guide/creating-skills> | First-party docs | Inline-shell trust scoping and timeout, `[[as_document]]`, credential-file mounts | `hermes-agent/SKILL_AUTHORING.md` |
| 58 | Hermes Kanban | <https://hermes-agent.nousresearch.com/docs/user-guide/features/kanban> | First-party docs | `scheduled_at` instead of a `scheduled` status, PR completion contracts, respawn guard, concurrency keys | `hermes-agent/KANBAN.md` |
| 59 | Hermes Curator | <https://hermes-agent.nousresearch.com/docs/user-guide/features/curator> | First-party docs | Curator states, defaults, backups, ledger, pin/lock | `hermes-agent/references/curator-lifecycle.md` |
| 60 | Hermes Event Hooks | <https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks> | First-party docs | Four hook systems with authority, gateway event payloads, `hook_callback_timeout` 30 s, fail-closed `pre_tool_call` | `hermes-agent/HOOK.md` |
| 61 | Hermes plugin authoring | <https://hermes-agent.nousresearch.com/docs/developer-guide/plugins> | First-party docs | Manifest v2, PM dependency lifecycle, `ctx.ask_choice`, middleware kinds | `hermes-agent/PLUGIN_AUTHORING.md` |
| 62 | Hermes Plugins | <https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins> | First-party docs | Catalog, packs, isolation, timeouts, project-local plugins never loading in the gateway | `hermes-agent/PLUGINS.md` |
| 63 | Hermes plugin catalog | <https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog> | First-party docs | Reviewed-commit catalog (910 entries, live count) explicitly not a security audit | `hermes-agent/PLUGINS.md` |
| 64 | Hermes Messaging Gateway | <https://hermes-agent.nousresearch.com/docs/user-guide/messaging> | First-party docs | Retired `session_reset` modes, `platforms.<name>.enabled` authority, adapter status | `hermes-agent/MESSAGING.md` |
| 65 | Hermes Discord setup | <https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord> | First-party docs | Intents failure mode, permission integers, loop guard, backfill object shape | `hermes-agent/DISCORD.md` |
| 66 | Hermes multiplexing gateway | <https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway> | First-party docs | One gateway for all profiles, `/p/<profile>/` routes, `gateway.standalone` opt-out | `hermes-agent/MESSAGING.md` |
| 67 | Hermes slash commands | <https://hermes-agent.nousresearch.com/docs/reference/slash-commands> | First-party docs | CLI-only versus chat-available commands | `hermes-agent/DISCORD.md` |
| 68 | Hermes MCP and Tool Gateway | <https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp>, <https://hermes-agent.nousresearch.com/docs/user-guide/features/tool-gateway> | First-party docs | MCP server configuration and tool gating | `hermes-agent/EXTENSIONS.md` |
| 69 | Hermes Agent `v0.22.5` release | <https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.5> | First-party release | Version pin: commit `bf0203a794a`, 2026-10-22 (tag timestamp 2026-10-23) | Version anchor for `hermes-agent/**` |
| 70 | Hermes Agent repository | <https://github.com/NousResearch/hermes-agent> | First-party source | Last commit 2026-11-02; source of the tag-pinned docs under `website/docs/` | Tag/site reconciliation |
| 71 | Agent Skills specification | <https://agentskills.io/specification> | Vendor-neutral standard | `SKILL.md` frontmatter standard that Claude Code, Codex, and OpenCode follow | Skill layout rows |
| 72 | Agent Plugins specification 1.0.0 | <https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md> | Standard (released tag) | Plugin manifest contract Hermes pins to | `hermes-agent/PLUGINS.md` |
| 73 | Agent Plugins specification 1.1.0 | <https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.1.0.md> | Standard (Working Draft) | Upstream draft newer than the pin; not adopted | `hermes-agent/PLUGINS.md` caveat |

> `AGENTS.md` and `AGENTS.ko.md` are version controlled. `CLAUDE.md` is covered by `.gitignore:45` and is therefore **not** version controlled (checked 2026-11-03: `git ls-files` lists `AGENTS.md`, and `git check-ignore` reports only `CLAUDE.md`). Evidence #1 therefore exists in every clone.

## Claim-source matrix

| Claim | Source(s) | Confidence | Caveat |
|---|---|---|---|
| Shared skill rules are capability-centric and per-runtime differences are separated into profiles | 2, 3 | High | This is this project's document design rule, not a product standard. |
| Claude Code exposes six permission modes with no deprecated mode; Manual is the UI label for the `default` value and `manual` is an alias | 5, 6 | High | Deprecation scan of the page returned nothing; the only documented naming change is Manual/`default`. |
| A `claude -p` run with no permission mode starts in Manual from v2.1.302 and denies calls that need approval unless an allow rule, hook, `canUseTool`, or `--permission-prompt-tool` approves them | 5, 6 | High | Version-gated; an older installed CLI behaves differently. |
| Claude Code has a built-in structured question tool (`AskUserQuestion`) that no permission mode auto-approves | 6 | High | The tool is named in the permission documentation; exposure and schema still need session confirmation. |
| Claude Code delegation is capped at 20 concurrent subagents and three nesting layers by default, starts subagents in the background, and runs workflows at 16 concurrent agents | 8, 12 | High | Cap defaults are configurable through environment variables and platform CPU count. |
| Claude Code `/loop` is session-scoped and `/schedule` creates cloud tasks in research preview | 7, 13, 14 | High | Sessions whose first prompt was `/loop` are skipped by `--continue` unless `-p` is passed. |
| Codex retired `approval_policy = "untrusted"`, and `-a`/`--ask-for-approval` accepts only `on-request` or `never` | 15, 16 | High | The retired value can prevent the client from starting; stricter command approval now needs a project `trust_level`. |
| Codex subagents inherit the parent's sandbox and approval settings, and a custom agent file cannot widen them | 18 | High | Approval from a subagent surfaces only in interactive sessions. |
| In non-interactive Codex runs an action needing new approval fails instead of prompting | 18 | High | A scripted workflow must pre-approve what it needs. |
| Codex loads local skills from `.agents/skills`, not a `.codex/skills` directory, and requires `name` and `description` | 19 | High | Symlinked skill folders are followed; duplicate names are not merged. |
| Codex scheduled tasks are managed in ChatGPT web or the desktop app; the CLI has no Scheduled interface | 21 | High | Absence finding within the reviewed CLI page; recheck on a new release. |
| Codex `/goal` starts Goal mode in the CLI and does not grant broader access | 22 | High | Goal mode keeps the same sandbox and approval policy. |
| OpenCode exposes a `question` tool with header, text, options, and a custom answer, gated by the `question` permission | 25, 27 | High | On clients other than the CLI, app, and desktop the tool may need `OPENCODE_ENABLE_QUESTION_TOOL`. |
| OpenCode 1 defaults to permissive permissions, while OpenCode 2 resolves an unmatched check to `ask` | 25, 32 | High | The two documentation trees describe different config shapes; read the one matching the installed major version. |
| OpenCode plugins can observe `permission.asked` and `permission.replied` but no documented hook answers an approval | 28 | Medium | Absence finding inside the reviewed plugin pages; a plugin that throws in `tool.execute.before` blocks a call but is still not consent. |
| OpenCode delegation depth defaults to 1 and background subagents are experimental and opt-in | 26, 30, 31 | High | `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS` must be enabled. |
| OpenClaw exposes a structured `ask_user` tool whose answers never grant permissions | 34 | High | Only on question-capable surfaces; several channels fall back to plain text. |
| OpenClaw host exec requires policy plus allowlist plus approval agreement and is not a per-user auth boundary | 34 | High | The deployed approvals document decides the effective mode. |
| GJC has no documented general per-command approval gate and ships no permission-bypass flag | 36, 38 | Medium | Negative finding inside the reviewed first-party docs; approval lives in plan/workflow gates and `ask`. |
| GJC `ask` is conditionally registered and `ask.timeout` auto-selects the recommended option | 38 | High | A headless session without an answer surface never gets the tool; an auto-selected answer is not consent. |
| OmO enforces permissions through config (`agents.*.permission`) and treats `AGENTS.md` as instruction only | 39 | High | Guard hooks are part of enforcement; disabling them is debugging-only. |
| JCode's current SDK emits `permission_request` with allow/allow_always/deny | 41 | High | Supersedes the v0.81.1 finding that the bridge emitted no permission requests. |
| JCode's interactive CLI approval behavior is undocumented on the current site | 41 | Medium | Absence finding; the profile requires observing the installed version. |
| Hermes Agent content is pinned to `v0.22.5` and the live docs site deploys slightly ahead of that tag | 69, 70 | High | Site-only behaviors were not asserted; each load-bearing claim was spot-checked against the tag's `website/docs/`. |
| Hermes shell hooks also run in Desktop/TUI/dashboard, and gateway hooks are trusted by placement | 60 | High | `HERMES_SAFE_MODE` does not skip gateway hooks. |
| Hermes plugins pin Agent Plugins 1.0.0 while upstream publishes a 1.1.0 Working Draft | 61, 62, 72, 73 | High | A draft is not an adopted contract. |
| A vendor page with no date means the recorded date is the read date | all vendor rows | High | Version anchors come from dated release and changelog entries instead. |

## Update conditions

Update this ledger when any of the following happens.

- A runtime publishes a release that changes permissions, approvals, delegation, or scheduling behavior.
- A profile starts depending on a capability this ledger does not yet cover.
- A vendor documentation URL moves or starts redirecting.
- A new runtime profile is added to `instructions/cli/`.
- A cited page gains a publication date, at which point the row should record the page's own date instead of the read date.

When updating, add the evidence first, then modify the profile and the shared contract, and finally re-check links, the claim-source matrix, and the smoke eval.
