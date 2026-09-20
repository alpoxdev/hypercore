# Prompt and Skill Caching

> Korean version: [`CACHE.ko.md`](CACHE.ko.md)

**Purpose**: when a runtime re-sends a prompt, a skill, or an instruction file on each turn, structure them so the part that never changes stays at the front and the part that changes every turn goes last. The provider's prompt cache can then serve the repeated work instead of re-processing it.

This document is about **authoring for cacheability**. It is not about storing research artifacts; local research caches are covered in [`../README.md`](../README.md).

## 1. The mechanism

Most provider prompt caching reuses a **prefix** of the request: tool definitions, system content, and message history. A hit requires the rendered prefix up to a cache breakpoint to match what the provider cached earlier. Two consequences follow, and they drive every rule below.

- **Reuse is positional.** A change early in the request can cost you reuse for everything after it. Editing the system prompt costs more than editing the last message.
- **Order is part of the content.** The same items in a different order can render differently, so reordering is a potential miss rather than a no-op.

Two limits on that model:

- **Explicit cache objects are provider-specific.** Google's explicit caching, for example, has you create a cache object and reference it by id instead of relying on prefix matching, so the rules below apply to it only loosely.
- **Only the reused region matters.** A change does not necessarily invalidate what came before it.

Minimum cacheable lengths, TTLs, and pricing differ per provider and model. The current numbers live in [`references/provider-cache-facts.md`](references/provider-cache-facts.md) rather than here, because they change faster than this contract.

## 2. Authoring rules for prompts

| Rule | Practice |
|---|---|
| Stable first | Role, rules, tool schemas, and reference material at the front; the current user turn, retrieved documents, and freshly read files at the end |
| Keep related calls close in time | A cached prefix expires on a TTL. Cluster requests that share a prefix instead of spreading them across the day |
| No volatile interpolation in the prefix | Never place a timestamp, "current date", request ID, session ID, item count, or environment path in the system or role text |
| Deterministic ordering | Keep ordering deterministic where the order carries no meaning, and never depend on map or set iteration order. Preserve an order that is meaningful to the task |
| Stable tool surface | Adding, removing, reordering, or re-describing a tool invalidates the prefix for the whole session. Treat the tool list as a frozen contract within a run |
| No mid-session rewrite | Do not re-inject updated state at the top of the context. Append the update as a later message instead |
| One canonical block | Two near-identical system blocks are two different prefixes. Keep one home per rule and reference it |

A useful test: if you diff the request for turn 1 and turn 5 of the same session, the only differences should be at the end.

## 3. Authoring rules for skills

When a runtime loads a skill's `SKILL.md` and a system-level skill list into every session, that text becomes part of the reused prefix. The rules below apply to whichever part a given runtime actually re-sends.

| Rule | Practice |
|---|---|
| Keep the loaded head stable | Where a runtime carries skill names and trigger descriptions in every session, that text is part of the prefix. Edit it deliberately and in batches, not per session |
| Move volatile values out of the head | "Last verified" dates, version pins, counts, and machine paths belong at the bottom of the file or in a `references/` file |
| Deterministic resource order | List bundled files in a stable order and reference them by stable names |
| Split by stability, not only by length | Put stable contract text in `SKILL.md` and fast-moving detail in `references/`, so refreshing detail does not disturb the prefix |
| Do not churn the trigger | Renaming a skill or rewording its description invalidates the cached prefix of every session that loads it |

## 4. What invalidates a cache

- An edit to the system prompt, the skill text, or any earlier message.
- A tool-list or tool-schema change, including an MCP server reconnect that alters the schema. This repository already records the consequence: Hermes Agent asks before `/reload-mcp` by default because a changed MCP schema invalidates model prompt caching ([`../cli/hermes-agent/EXTENSIONS.md`](../cli/hermes-agent/EXTENSIONS.md)).
- Reordering content that is otherwise identical.
- TTL expiry between requests.
- A different cache scope or routing key — a shared prefix is not automatically a shared cache.

## 5. Harness-level reuse

A harness multiplies one prompt into many requests: workers, subagents, retries, and resumed sessions. Reuse follows the same prefix contract.

| Rule | Practice |
|---|---|
| Give every worker the same head | Parallel workers that share a system prompt and tool set become eligible for shared-prefix reuse. Vary only the task text at the end, and measure the hit rather than assuming it |
| No per-worker preamble | A worker name, worker id, or start timestamp at the top turns one shared prefix into N cold ones. Put that identity in the task text instead |
| Same model for shared work | A cache belongs to a model and a routing scope. Assume no cross-model reuse unless the provider documents it |
| A rewrite is not always a full reset | Compaction, summarization, or history rewriting changes earlier bytes, so reuse can be lost after the rewritten region. An unchanged prefix before it can still hit |
| Resume is not reuse | A resumed, forked, or continued session keeps its prefix only if nothing before the breakpoint changed |

## 6. Measure, do not assume

- Read cached-token counts from the response usage rather than inferring a hit. Provider field names differ; see the reference file.
- On some providers a cache **write** costs more than an ordinary input token (OpenAI documents 1.25× from GPT-5.6 on). Writing a prefix once and reading it once is not automatically cheaper.
- A minimum cacheable prefix length exists and varies by model. A short prompt may never cache at all.
- A resumed or continued session is not a guaranteed hit. Session continuity and cache reuse are different mechanisms.

## 7. Where caching must not decide the design

- Never weaken a validation, a safety boundary, a permission gate, or a source citation to keep a prefix stable.
- Never place credentials, tokens, or one user's private content in a prefix that another user or tenant can share.
- When stability and correctness conflict, correctness wins. Record the miss instead of hiding it.

## 8. Verification

- [ ] The request diff between two turns of a session differs only at the end.
- [ ] No timestamp, date, count, ID, or environment path appears in the system or role text.
- [ ] Tool definitions do not change within a session.
- [ ] A skill keeps its trigger wording and loaded head stable, with volatile values pushed to the bottom or a reference file.
- [ ] Cache reuse was measured from usage fields, not assumed.
- [ ] Any deliberate cache-hostile choice (a fresh nonce, per-request ordering) is intentional and documented.

## Sources

| Source | URL | Checked |
|---|---|---|
| Anthropic — prompt caching | <https://platform.claude.com/docs/en/build-with-claude/prompt-caching> | 2026-09-19 |
| OpenAI — prompt caching | <https://developers.openai.com/api/docs/guides/prompt-caching> | 2026-09-19 |
| Google — context caching, generateContent API | <https://ai.google.dev/gemini-api/docs/generate-content/caching> | 2026-09-19 |
| Google — context caching, Interactions API | <https://ai.google.dev/gemini-api/docs/caching> | 2026-09-19 |
| Google — GenerateContent API reference | <https://ai.google.dev/api/generate-content> | 2026-09-19 |
| Hermes Agent — extensions and MCP reload | [`../cli/hermes-agent/EXTENSIONS.md`](../cli/hermes-agent/EXTENSIONS.md) | 2026-09-19 |

## Related documents

- [`references/provider-cache-facts.md`](references/provider-cache-facts.md)
- [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md)
- [`../context-engineering/references/prompt-authoring.md`](../context-engineering/references/prompt-authoring.md)
- [`../skill/SKILL_AUTHORING.md`](../skill/SKILL_AUTHORING.md)
- [`../skill/references/resource-placement.md`](../skill/references/resource-placement.md)
