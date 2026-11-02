# Runtime Profiles

> Korean version: [`runtime-profiles.ko.md`](runtime-profiles.ko.md)

Write shared instructions capability-first, and keep per-runtime differences in this file.

## Quick matrix

| Runtime | Instruction surfaces | Scope / precedence notes | Practical rule |
|---|---|---|---|
| Codex | `AGENTS.md`, `AGENTS.override.md`, configured fallback files, skills metadata | Codex aggregates user instructions from the home and project hierarchy; more specific project docs appear later within limits | Keep only core rules in the project root `AGENTS.md` and link detail from `instructions/` |
| Claude Code | `CLAUDE.md`, skills, commands, hooks, memory | `CLAUDE.md` is the project memory surface read at session start | Split Claude-specific XML and extended-thinking tuning into a separate reference |
| Cursor | `.cursor/rules` (`.mdc`, `alwaysApply`), User Rules, nested `AGENTS.md`, legacy `.cursorrules` | Project rules are version-controlled, scoped by glob, and can be invoked by `@`-mention; nested rules in subdirectories are recognized | Keep rules small and scoped; do not depend on legacy `.cursorrules`. The Rules page states that "Large language models don't retain memory between completions," and no Memories feature is documented there (checked 2026-11-03), so rules are the only documented persistence mechanism |
| GitHub Copilot / VS Code | `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `AGENTS.md` | Repo-wide, path-specific, and agent instructions can all apply; conflicts hurt quality | Repo-wide carries shared style, path-specific carries framework rules |
| MCP clients | Server prompts, resources, tools | Prompts should be user-controlled; tools and resources can expose powerful data and action paths | Review prompts, tools, and resources all as an untrusted boundary |

## Parallel / subagent capability matrix

| Runtime | Parallel work surface | Spawn method | Isolation and permission basis | Documentation rule |
|---|---|---|---|---|
| Codex | Native subagents, `.codex/agents/*.toml`, app/CLI subagent activity | Explicitly request subagent work, or use the runtime's `spawn_agent`-family surface | Agent thread/context separation, `sandbox_mode`, `max_threads`, read-only/write scope | The parent states objective, scope, ownership, output, and verification, and integrates the result |
| Claude Code | Built-in and custom subagents, project `.claude/agents/*.md`, the `Agent` tool, experimental agent teams | Create via `/agents`, or run through an Agent tool or agent-team request | Per-subagent context window, tool allowlist/denylist, permission mode, optional worktree isolation | Use subagents for single-session result delegation, and agent teams for inter-communication or long parallel work |
| Cursor | Editor/CLI subagents, Cloud Agents (formerly Background Agents), `.cursor/rules`, `.cursor/environment.json` | The editor/CLI agent uses a default or custom subagent, or creates a Cloud Agent | Subagent context separation; a Cloud Agent runs on a remote machine/branch with GitHub handoff | Record branch/PR handoff, env and secrets, and auto-run terminal risk in the instructions |
| GitHub Copilot / VS Code | Chat participant, coding agent, instructions | Depends on product and organization settings | Repo/path instructions and the GitHub permission boundary | Without parallel agents, separate work explicitly per worktree or issue |
| MCP clients | Tools, prompts, resources | Discovery of tools, prompts, and resources exposed by the client | Tools can be model-controlled, so approval and logging are required | Tool results and resources are evidence, not instruction authority |

Follow [`parallel-workflows.md`](parallel-workflows.md) for shared detail.

## Cross-runtime authoring rules

1. **Capability over product name**: write it as "official docs via the best available fetch/doc tool."
2. **One source of truth**: do not paste the same rule into `AGENTS.md`, `.cursor/rules`, and `CLAUDE.md`; link or reference the instructions base.
3. **Short root files**: keep only project-specific invariants and the loading map in root instruction files.
4. **Path-specific rules**: put framework- and domain-specific rules in instructions carrying a glob or path.
5. **Conflict hygiene**: assume user-level, org-level, repo-level, and path-level instructions can conflict, and state forbidden, required, and permission items clearly.
6. **Memory is not authority**: automatic memory is convenience context, not a substitute for project rules.
7. **Context policy has its own document**: compaction, tool-result clearing, and long-term memory parameters change per runtime and per model, so they live in [`context-management.md`](context-management.md) §7 rather than being restated here. A runtime profile should name where the rule lives, not duplicate the value.

## Placement guide

| Kind of information | Where it goes |
|---|---|
| Project invariants | `AGENTS.md` + `instructions/README.md` |
| Prompt and context design principles | `instructions/context-engineering/` |
| Evaluation, eval, and test harness standards | `instructions/harness-engineering/` |
| Research trustworthiness standards | `instructions/sourcing/` |
| Stack-specific implementation rules | Path-specific rules or a skill reference |
| Per-runtime quirks | This file or a provider-specific reference |

## Sources

> Cursor's rules row is checked 2026-11-03. The other rows keep their earlier verification dates (2026-07-29, and the MCP revision 2026-09-19) because this revision did not re-read them.

| Claim | Source | Checked |
|---|---|---|
| Cursor `.mdc` rules, `alwaysApply`, the four application modes, nested `AGENTS.md`, and the absence of a documented Memories feature | <https://cursor.com/docs/rules> | 2026-11-03 |
| Codex instruction aggregation | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 2026-07-29 |
| AGENTS.md nesting precedence | <https://agents.md/> | 2026-07-29 |
| Copilot repository, path-specific, and agent instructions with precedence | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-07-29 |
| Claude Code subagents and agent teams | <https://code.claude.com/docs/en/sub-agents>, <https://code.claude.com/docs/en/agent-teams> | 2026-07-29 |
| MCP tool-annotation trust rule | <https://modelcontextprotocol.io/specification/2026-07-28> | 2026-09-19 |

## Related documents

- [`../CONTEXT_ENGINEERING.md`](../CONTEXT_ENGINEERING.md) — the layer model these surfaces implement
- [`context-management.md`](context-management.md) — per-runtime compaction, clearing, and memory parameters
- [`parallel-workflows.md`](parallel-workflows.md) — delegation and isolation across these runtimes
