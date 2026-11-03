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
Inherited context: [decisions already made, constraints already discovered, and their reasons]
Output: [summary, evidence files/links, changed files, verification results, blockers]
Returns: [summary plus artifact paths; never the full transcript]
Stop condition: [done, blocked, time budget, or source floor]
```

`Inherited context` is the field that fails most often. Copying the task text is not enough, because the parent's earlier tool calls carried implicit decisions; a worker that only sees the sentence will re-decide them differently. `Returns` keeps the parent's context growth reasonable: the worker writes the long material to a file and passes the path.

## Context isolation economics

A subagent buys a second context window. It also buys a second bill, and a second decision-maker. Both costs are real and quantified.

| Cost | Evidence |
|---|---|
| Tokens | Anthropic reports agents typically use "about 4× more tokens than chat interactions, and multi-agent systems use about 15× more tokens than chats" (2025-06-13) |
| Benefit ceiling | In the same analysis, token usage alone explained 80% of performance variance on BrowseComp, and a lead-plus-subagent research system beat a single agent by 90.2% on an internal eval |
| Coordination | The lead agent could not steer running subagents, subagents could not coordinate with each other, and "the entire system can be blocked while waiting for a single subagent to finish searching" |
| Consistency | Cognition's opposing principle: "Actions carry implicit decisions, and conflicting decisions carry bad results." Parallel writers that cannot see each other's actions produce incompatible halves (2025-06-12) |

The vendor numbers are self-reported and measured on different tasks, so use them to set expectations rather than to justify a default. The decision rule that survives both positions:

1. **Isolate investigation, not decisions.** Breadth-first search, independent review lenses, and verbose triage merge cleanly as text. A decision that must stay globally consistent does not.
2. **Isolate what the parent does not need to read.** A subagent returns its final message; intermediate tool calls and results stay inside it, so the parent grows by a summary rather than by a transcript. That is the whole gain.
3. **Never isolate two writers of the same artifact** without a declared merge order or a single owner.
4. **Budget the 15×.** If the same result is reachable by one agent reading three files, the fan-out is a loss even when each subagent is fast.
5. **State the fix direction in the handoff.** "The constraint you found is wrong" is cheaper than letting the parent re-derive the constraint from a summary that lacks it.

For runtimes, isolation is implemented differently: a fork or fresh subagent context, a per-agent context branch, a sandbox that returns only values, or a remote branch. Details are in [`runtime-profiles.md`](runtime-profiles.md) and [`context-management.md`](context-management.md) §5.

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

> Sources checked 2026-11-03; the MCP pages were re-verified 2026-09-19 against the `2026-07-28` revision. Cursor's Background Agents were renamed Cloud Agents.

| Claim | Source | Published / updated |
|---|---|---|
| Subagent context isolation, `isolation: worktree`, project `.claude/agents/*.md` | <https://code.claude.com/docs/en/sub-agents> | undated page, checked 2026-11-03 |
| Agent teams run as separate sessions and remain experimental | <https://code.claude.com/docs/en/agent-teams> | undated page, checked 2026-11-03 |
| Codex native subagents, forked context or separate thread, config-limited concurrency | <https://learn.chatgpt.com/docs/agent-configuration/subagents> | undated page, checked 2026-11-03 |
| `spawn_agent`, `send_input`, `wait_agent`, `close_agent` invocation surface | <https://learn.chatgpt.com/docs/codex/cli> | undated page, checked 2026-11-03 |
| Cloud agents run on a remote isolated machine and branch; GitHub permissions, internet access, and automatic command execution widen the boundary | <https://cursor.com/docs/cloud-agent> | undated page, checked 2026-11-03 |
| Editor and CLI subagents in the 2.4 release | <https://cursor.com/changelog/2-4> | Cursor 2.4 release entry, checked 2026-11-03 |
| `.cursor/rules` and `.cursor/environment.json` configuration surfaces | <https://cursor.com/docs/rules> | undated page, checked 2026-11-03 |
| Tool annotations untrusted unless the server is trusted; `server/discover`, per-request `_meta`, `resultType: "input_required"` | <https://modelcontextprotocol.io/specification/2026-07-28/server/tools> | 2026-07-28 revision, checked 2026-09-19 |
| Prompt capability and the input-required (MRTR) flow | <https://modelcontextprotocol.io/specification/2026-07-28/server/prompts> | 2026-07-28 revision, checked 2026-09-19 |
| Tool results and resource content are untrusted evidence | <https://developers.openai.com/api/docs/guides/agent-builder-safety> | undated page, checked 2026-11-03 |
| ~4x and ~15x token multipliers, 80% of BrowseComp variance, 90.2% internal gain, coordination failures | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13, revised 2026-10-09 |
| "Actions carry implicit decisions"; single-threaded recommendation | <https://cognition.com/blog/dont-build-multi-agents> | 2025-06-12 |
| SDK subagents return a summary from their own context window | <https://code.claude.com/docs/en/agent-sdk/subagents> | undated page, checked 2026-11-03 |

## Related documents

- [`../CONTEXT_ENGINEERING.md`](../CONTEXT_ENGINEERING.md) — the contract a leader writes and a worker receives
- [`context-management.md`](context-management.md) — compaction, clearing, and the per-runtime context parameters that isolation depends on
- [`../../loop-engineering/LOOP_ENGINEERING.md`](../../loop-engineering/LOOP_ENGINEERING.md) — fan-out inside a loop iteration. A loop that spawns workers is a leader under this document, and the loop's stop condition does not transfer to its children.
- [`../../graph-engineering/GRAPH_ENGINEERING.md`](../../graph-engineering/GRAPH_ENGINEERING.md) — fan-out and fan-in edges, join semantics, and back-edge bounds belong to the graph; this document supplies the per-worker ownership, isolation, and integration contract those nodes execute.
- [`../../harness-engineering/HARNESS_ENGINEERING.md`](../../harness-engineering/HARNESS_ENGINEERING.md) — traces, gates, and evals that prove a delegated run actually finished
