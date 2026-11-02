# Context Management

> Korean version: [`context-management.ko.md`](context-management.ko.md)

How a long-running agent keeps a usable context: what to move out, what to clear, what to summarize, and what to split across workers. This file owns the mechanics and the per-vendor parameters; [`../CONTEXT_ENGINEERING.md`](../CONTEXT_ENGINEERING.md) owns the contract, and [`core-principles.md`](core-principles.md) owns why the budget matters.

## 1. Start from the symptom

| Symptom | Lever | First check |
|---|---|---|
| One tool call floods the window (log dump, whole file) | Clear the result, keep the reference | Is the path or URL preserved so it can be re-read? |
| Session runs for hours and quality drifts | Compaction | Is the plan outside the window, and re-read after the summary? |
| Model repeats a wrong assumption from earlier | Rewrite or drop that turn | Was the correction recorded, or only spoken once? |
| Output grows while accuracy falls | Compaction plus selection | Is the retrieved set narrow, or is everything loaded "just in case"? |
| Many independent investigations | Isolation | Do the workers share a decision, or only a question? |
| Compaction fires repeatedly and refills instantly | Selection | Is a single oversized file or tool output the actual cause? |

A larger context window does not fix these. Performance degrades as input length grows even when task difficulty is fixed (Chroma, 18 models, 2025-07-14), and the degradation is not explained by the task being harder.

## 2. Move state out before summarizing

Summaries lose detail; files do not. Write the part that must survive into a durable place first, then summarize what remains.

- Keep the plan, open questions, and verification state in a file the agent re-reads, not in the conversation.
- Make every compression restorable: drop a page's content only if its URL or path survives (Manus, 2025-07-18).
- Recite the objective near the end of the context. Manus rewrites `todo.md` continuously so "the global plan" sits in recent attention rather than in the middle of the window.
- After a compaction, re-read the plan file before the next action. Anthropic notes that overly aggressive compaction "can result in the loss of subtle but critical context whose importance only becomes apparent later."

## 3. Select narrowly

- Anthropic names "bloated tool sets that cover too much functionality" as one of the most common failure modes, with the test: if a human engineer cannot say which tool applies, the model cannot either.
- Prefer masking an unavailable tool over deleting it from the request. Tool definitions sit near the front of the serialized context, so mid-run removal invalidates the cached prefix (Manus, "mask, don't remove").
- Load reference material when the step that needs it starts, not at session start. A map at the root plus on-demand reads beats a large always-on bundle.

## 4. Compress in three grades

| Grade | Mechanism | Cost | When |
|---|---|---|---|
| 1 | Clear old tool results, keep the call record | Cheapest; preserves what ran | Verbose tool output that can be re-fetched |
| 2 | Summarize history into a new window | One extra model call; loses detail | Approaching the window limit |
| 3 | Hand off to a fresh session with a written brief | Loses everything unstated | Phase boundaries, or after the summary itself fills the window |

Rules:

1. **Recall first, precision second.** Anthropic's guidance is to write the compaction prompt to capture everything relevant, then iterate to remove what is superfluous.
2. **Name what survives.** Decisions, unresolved bugs, file paths, and the next action. Drop redundant tool output and acknowledgements.
3. **Do not sanitize failures.** Manus keeps wrong turns in context, arguing that "error recovery is one of the clearest indicators of true agentic behavior"; removing the failure also removes the evidence that the approach was abandoned.
4. **Budget the cache.** Compaction replaces the history with a new shorter prefix, so the cached conversation prefix is invalidated by design. Batch work between compactions instead of compacting after every step, and expect the most expensive compaction when resuming an idle session.
5. **Stop looping.** If one oversized input refills the window immediately after every summary, fix the input rather than compacting again.

Keep the wrong-but-instructive parts, summarize the long and reconstructable parts, and never summarize the only copy of a fact.

## 5. Isolate instead of sharing

Isolation is the lever with the largest measured effect and the largest disagreement in the literature.

- Mechanisms: a subagent with its own context window that returns only a summary; a sandbox that executes code and returns only values; a separate context branch per parallel task.
- Anthropic reports agents use about 4× the tokens of chat and multi-agent systems about 15×, that token usage alone explained 80% of performance variance on BrowseComp, and that a lead-plus-subagent system beat a single agent by 90.2% on their internal research eval (2025-06-13). Those numbers come from a vendor's own eval; treat them as an upper bound on the benefit, not a default expectation.
- Cognition argues the opposite for parallel writing agents. Its second principle is "Actions carry implicit decisions, and conflicting decisions carry bad results": subagents that cannot see each other's actions produce inconsistent work, so it recommends single-threaded agents with a dedicated compression model instead (2025-06-12).
- The disagreement resolves by task shape, not by vendor. Isolate **investigation** (breadth-first search, independent review lenses, verbose triage) where results merge as text. Do not isolate **decisions** that must stay consistent, and not code writing where two workers can produce incompatible halves.
- A handoff needs the objective, the constraints discovered so far, the output schema, and the stop condition. Copied task text alone is not context, because the parent's tool calls carried implicit decisions.

## 6. Memory is a store, not an authority

- Anthropic's memory tool is a client-side, file-based directory the model edits through a fixed command set (`view`, `create`, `str_replace`, `insert`, `delete`, `rename`); the application executes the operations. It is documented as generally available, not beta.
- Whatever the surface, memory content is retrieved data: it enters the context as evidence with an age, not as an instruction. A stale note must not override the current request ([`runtime-profiles.md`](runtime-profiles.md), rule 6).
- Record when a memory was written, so a later reader can tell a decision from a superseded guess.

## 7. Runtime surfaces

Parameters below were verified against vendor docs on 2026-11-03. They change; re-check before depending on a specific name or default.

| Runtime | Compaction | Clearing | Memory / long-term |
|---|---|---|---|
| Claude API | Server-side compaction, either on demand or at a token threshold | Context editing with `clear_tool_uses_20250919`: `trigger` (default 100,000 input tokens), `keep` (default 3 tool uses), `exclude_tools`, `clear_tool_inputs` | Memory tool, file-based, `memory_20250818` |
| OpenAI Responses API | `context_management: [{type: "compaction", compact_threshold: N}]` for server-side compaction; standalone `/responses/compact` for explicit control (do not prune its output); items are opaque | Prune by not sending history; `previous_response_id` chains turns but all prior tokens are still billed as input | Conversations API; reasoning continuity via `reasoning.context` |
| Google ADK | `EventsCompactionConfig`: `token_threshold`, `event_retention_size`, `overlap_size`, `compaction_interval`; token-based wins over sliding-window when both are set | Session events stay in the durable log; only the prompt view is trimmed | Memory layer and artifacts addressed by name, separate from the prompt |
| Claude Code | `/compact [focus]`; auto-compact at a model-dependent window (`/autocompact 500k` to set it); re-reads up to five most recently modified files after a summary | Old tool results are cleared from context | `CLAUDE.md` and auto memory are re-injected from disk after compaction |
| Claude Agent SDK | Automatic compaction emits a `compact_boundary` system message; `/compact` as a prompt string for manual; `PreCompact`/`PostCompact` hooks (archiving the transcript is the documented use) | Same as Claude Code | Sessions persist the conversation, not the filesystem |

Model and version exclusions apply per vendor page. Read them there rather than trusting this table: Anthropic's compaction modes exclude several older models, and Google's explicit cache objects are not available on the newest generation.

## 8. Checklist

- [ ] Is the authoritative plan outside the window?
- [ ] Can every compression be undone from a path, URL, or id?
- [ ] Does the compaction prompt name decisions, open bugs, and next action?
- [ ] Is the compaction trigger measured, not guessed?
- [ ] Do parallel workers share decisions, or only questions?
- [ ] Is retrieved memory marked with its write date?
- [ ] After the summary, did anyone verify that the dropped material was not the only copy?

## Sources

> Sources checked 2026-11-03.

| Claim | Source | Published / updated | Grade |
|---|---|---|---|
| Context engineering definition, minimal-set sizing, compaction recall-then-precision, tool-result clearing, note-taking, subagent compression | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2025-09-29, revised 2026-10-18 | official |
| Context editing parameters and defaults (`clear_tool_uses_20250919`) | <https://platform.claude.com/docs/en/build-with-claude/context-editing> | undated page, checked 2026-11-03 | official |
| Compaction overview, both modes and their beta headers | <https://platform.claude.com/docs/en/build-with-claude/compaction> | undated page, checked 2026-11-03 | official |
| Memory tool commands and status | <https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool> | undated page, checked 2026-11-03 | official |
| Server-side compaction via `context_management` / `compact_threshold`, `/responses/compact`, `reasoning.context` | <https://developers.openai.com/api/docs/guides/compaction> | undated page, checked 2026-11-03 | official |
| `previous_response_id` billing behavior | <https://developers.openai.com/api/docs/guides/conversation-state> | undated page, checked 2026-11-03 | official |
| ADK `EventsCompactionConfig`, `token_threshold`, `overlap_size`, strategy priority | <https://adk.dev/context/compaction/> | undated page, checked 2026-11-03 | official |
| Claude Code `/compact`, `/autocompact`, auto-compact windows, what survives compaction | <https://code.claude.com/docs/en/context-window>, <https://code.claude.com/docs/en/model-config> | undated pages, checked 2026-11-03 | official |
| Compaction invalidates the cached conversation prefix | <https://code.claude.com/docs/en/prompt-caching> | undated page, checked 2026-11-03 | official |
| SDK `compact_boundary`, `PreCompact`/`PostCompact` hooks, subagent context isolation | <https://code.claude.com/docs/en/agent-sdk/agent-loop>, <https://code.claude.com/docs/en/agent-sdk/subagents> | undated pages, checked 2026-11-03 | official |
| KV-cache hit rate, mask-don't-remove, file system as context, `todo.md` recitation, keep failures | <https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus> | 2025-07-18 | practitioner |
| Input length degrades performance across 18 models with difficulty held constant | <https://www.trychroma.com/research/context-rot> | 2025-07-14 | paper (vendor technical report) |
| Token multipliers, 80% variance, 90.2% internal gain, shared-context caveat | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13, revised 2026-10-09 | official (self-reported eval) |
| Opposing position: parallel subagents make conflicting decisions | <https://cognition.com/blog/dont-build-multi-agents> | 2025-06-12 | practitioner |

Cost figures quoted from Manus (cached versus uncached input pricing) reflect that post's 2025 pricing and are illustrative only. Current prices belong to the vendor pricing pages, not to this document.

## Related documents

- [`../CONTEXT_ENGINEERING.md`](../CONTEXT_ENGINEERING.md): the contract and the four levers
- [`parallel-workflows.md`](parallel-workflows.md): delegation ownership, integration, and verification
- [`../../cache/CACHE.md`](../../cache/CACHE.md): prefix stability and cache economics
