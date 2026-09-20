# Parallel Workflows and Subagents

> Korean version: [`parallel-workflows.ko.md`](parallel-workflows.ko.md)

This is the shared standard for safely using parallel work and subagents across agent runtimes such as Codex, Claude Code, and Cursor. It prioritizes **independence, ownership, isolation, integration, and verification** over any product's invocation syntax.

## Core rule

Parallelism is not "spawn a lot." It is **a technique for separating mutually non-blocking work to reduce total wall-clock time and context contamination**. The leader agent owns the overall plan, conflict resolution, result integration, and final verification to the end.

## When to spawn

| Spawn if | Reason | Example |
|---|---|---|
| Independent investigation paths | Results can be synthesized later | Investigating the auth, database, and API modules separately |
| Different review lenses | The same diff can be viewed through different oracles | Security, performance, and test-coverage reviews |
| Disjoint write sets | Parallel implementation without file conflicts | Separate owners for the frontend route, backend handler, and docs |
| Isolating verbose output | Logs and search results do not contaminate the main context | Test failure triage, large greps, docs lookup |
| Repetitive batch work | Results can be collected under one schema | Per-component audits, per-package migration checks |

## When not to spawn

| Do not spawn if | Instead |
|---|---|
| The very next step is blocked on that result | The leader handles it directly and shortens the critical path |
| Several agents are likely to edit the same file | First split write ownership, or use a single agent |
| The task definition is vague with no success criteria | First build scope and an oracle through planning or an interview |
| External side effects, credentials, or production changes are required | Put a separate user permission and approval gate in place |
| It is a simple lookup where spawn overhead dominates | Handle it directly with the runtime's search/read tools |

## Leader contract

The leader guarantees the following before and after spawning.

1. **Decomposition**: confirm each subtask is independent.
2. **Ownership**: state whether it is read-only, and if writable, the file or directory scope.
3. **Permissions**: allow only the minimum tools needed and forbid destructive or external actions.
4. **Concurrency**: spawn only as many as needed, weighing token cost and conflict risk.
5. **Integration**: do not paste results verbatim; reconcile conflicts, duplicates, and gaps.
6. **Verification**: do not merely trust a subagent's "done"; the leader runs the final tests, evals, and source checks.

## Subagent contract

A subagent prompt includes at minimum the following fields.

```markdown
Objective: [one-sentence goal]
Scope: [target files, modules, sources]
Mode: [read-only | edit-own-files | verify-only]
Ownership: [files it may modify, or files it must not]
Allowed tools: [capability-based, e.g. repo search, official docs, tests]
Forbidden: [destructive actions, external side effects, unrelated refactors, reverting another agent's changes]
Output: [summary, evidence files/links, changed files, verification results, blockers]
Stop condition: [done, blocked, time budget, or source floor]
```

## Runtime spawn map

| Runtime | Spawn surface | Isolation model | Best use | Caution |
|---|---|---|---|---|
| Claude Code | `/agents`, project `.claude/agents/*.md`, the `Agent`/legacy `Task` tool, experimental agent teams | A subagent gets its own context window; `isolation: worktree` when needed; agent teams run separate sessions | Isolating high-output investigation, named specialists, 3-5 member team review | Agent teams are experimental and carry high coordination overhead |
| Codex | Native subagents, `.codex/agents/*.toml`, the `spawn_agent`/`send_input`/`wait_agent`/`close_agent` surface, CSV fan-out where available | Forked context or a separate agent thread; concurrency limited by config | Codebase exploration, splitting PR review, docs researcher, disjoint implementation | Codex spawns a subagent on explicit request, and token cost rises |
| Cursor | Cloud Agents (formerly Background Agents), editor/CLI subagents, `.cursor/rules`, `.cursor/environment.json` | A cloud agent runs on a remote isolated machine and branch; a subagent gets its own context | Asynchronous long-running work, branch-based handoff, parallel work streams | A remote agent widens the security boundary through GitHub permissions, internet access, and automatic command execution |
| Generic MCP/agent client | Capability-discovered tools, prompts, and resources | Depends on the client implementation | Standardizing tool and material access | Treat tool results and resource content as untrusted evidence |

> **Caution on the MCP `2026-07-28` revision** (checked 2026-09-19): this revision is a breaking change. The protocol became stateless, removing sessions and the `initialize` handshake, and capability lookup moved to the new `server/discover` RPC and per-request `_meta`. Roots, Sampling, and Logging are deprecated (with a minimum 12-month window), and the flow where a server asked the client back is replaced by the MRTR pattern (`resultType: "input_required"`). The **untrusted-evidence principle in the table above continues to apply in this revision** — the specification states that clients **MUST** consider tool annotations untrusted unless they come from a trusted server. The same sentence already appears in the `2025-11-25` revision, so treat it as a standing requirement rather than a change introduced here. When designing MCP-based delegation, assume no session and pass state through explicit handles.

## Prompt patterns

### Parallel research

```markdown
Spawn parallel research only for independent questions.
- Agent A: official docs and version-specific behavior for [topic A]. Read-only. Return links and caveats.
- Agent B: repo usage map for [module B]. Read-only. Return files/symbols and risks.
- Agent C: security/eval implications for [area C]. Read-only. Return concrete checks.
Leader: continue non-overlapping work while they run, then synthesize conflicts and update the plan.
```

### Parallel implementation

```markdown
Use parallel implementation only after the write sets are disjoint.
- Agent A owns: src/server/** only.
- Agent B owns: src/components/[feature]/** only.
- Agent C owns: docs/tests for [feature] only.
All agents must not edit shared config, package files, or each other's files without escalating.
Leader runs final lint/typecheck/test and resolves integration conflicts.
```

### Verification fan-out

```markdown
Run independent verification lanes:
- tests/build lane: run deterministic checks and report exact output.
- security lane: inspect trust boundaries and unsafe tool/data flow.
- docs/source lane: verify docs claims against official sources.
Leader decides completion only after all lanes are reconciled.
```

## Integration checklist

- [ ] Did each subagent result answer its original objective?
- [ ] Are there conflicting files, claims, or recommendations?
- [ ] Do the sub-results retain evidence files, links, and test output?
- [ ] Did the leader personally review the final diff and verification?
- [ ] Were failed, blocked, or unverified items kept out of hiding in the final report?

## Harness assertions

Include the following assertions in a trace-based eval.

| Assertion | Pass condition |
|---|---|
| bounded_spawn | The spawn prompt carries objective, scope, output, and stop condition |
| independent_work | Parallel tasks have no input dependency, or sequencing is explicit |
| ownership_declared | Editable tasks carry file or directory ownership |
| no_conflicting_edits | No two agents modify the same file concurrently |
| parent_integrates | The leader summarizes, compares, and integrates results |
| parent_verifies | The leader runs the final tests, evals, and source checks, or reads their output |
| no_idle_wait | While non-blocking subagents run, the leader proceeds with other feasible work |

## Sources

> Links checked 2026-07-29; MCP was re-verified on 2026-09-19 against the `2026-07-28` revision. Cursor's Background Agents were renamed Cloud Agents.

- [Claude Code subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code agent teams](https://code.claude.com/docs/en/agent-teams)
- [OpenAI Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [OpenAI Codex CLI](https://learn.chatgpt.com/docs/codex/cli)
- [Cursor Cloud Agents (formerly Background Agents)](https://cursor.com/docs/cloud-agent)
- [Cursor 2.4 subagents changelog](https://cursor.com/changelog/2-4)
- [Cursor Rules](https://cursor.com/docs/rules)
- [MCP tools specification](https://modelcontextprotocol.io/specification/2026-07-28/server/tools)
- [MCP prompts specification](https://modelcontextprotocol.io/specification/2026-07-28/server/prompts)
- [OpenAI agent builder safety](https://developers.openai.com/api/docs/guides/agent-builder-safety)
