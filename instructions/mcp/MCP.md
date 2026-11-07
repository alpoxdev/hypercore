# MCP

Standards for building, connecting, and governing Model Context Protocol servers and clients against the current protocol revision, `2026-07-28`: when to build one, the protocol rules that break implementations when ignored, how to design a tool surface a model can use and a host can afford, and the security floor.

> Korean version: [`MCP.ko.md`](MCP.ko.md)

## Why

MCP is "an open-source standard for connecting AI applications to external systems" — data sources, tools, and workflows (MCP introduction, checked 2026-11-07). Three facts shape this document.

- **The current revision is a break.** `2026-07-28` is the current protocol version, and its release turned MCP "from a bidirectional stateful protocol into a request/response stateless protocol": no `initialize` handshake, no protocol sessions, no server-initiated requests (versioning docs and release post, checked 2026-11-07). Tutorials, SDK examples, and model memory written for `2025-11-25` or earlier describe mechanisms that no longer exist and still compile.
- **The protocol does not make a server safe.** The official local-server guide: "**no check proves what a server will do.**" A tool-poisoning benchmark across 45 live servers measured attack success up to 72.8% with refusals below 3% (arXiv 2508.14925, rev. 2026-09-29; both checked 2026-11-07). Safety comes from what the host and operator enforce around the server.
- **Tools cost context on every turn.** The maintainers' roadmap: "Connecting to a server with a hundred tools means the model pays for that entire surface before the user has asked a single question, and tool selection tends to get worse as the list grows" (2026-08-22, checked 2026-11-07).

Governance is stable: Anthropic donated MCP to the Agentic AI Foundation under the Linux Foundation on 2025-12-09, and the maintainers keep the technical direction through Specification Enhancement Proposals (SEPs) and a deprecation policy with a twelve-month minimum window (checked 2026-11-07).

## Definition

- MCP-1: A **host** is the AI application; it runs one **client** per connected **server**. A server exposes primitives; a client may offer features back to the server.
- MCP-2: Each primitive has a controller. Tools are model-controlled, resources application-controlled, prompts user-controlled. Elicitation is the client feature a server can rely on; Roots and Sampling are deprecated.
- MCP-3: A revision is a date string. `2026-07-28` and later are **modern** (version and capabilities in every request's `_meta`); `2025-11-25` and earlier are **legacy** (handshake and session); an implementation serving both is **dual-era**.
- MCP-4: A transport is a binding with identical semantics: stdio or Streamable HTTP. HTTP+SSE is deprecated.
- MCP-5: Extensions (Apps, Tasks, Skills, authorization extensions) live outside the core, are named `{vendor-prefix}/{name}`, and are off unless both sides opt in.

## When to build a server

| Situation | Choice |
|---|---|
| The capability must work across several hosts or agents, or must act for a user against a remote system with that user's authorization | MCP server — remote Streamable HTTP for anything wrapping a cloud API |
| The capability needs the user's machine (files, local apps, hardware) | Local stdio server, isolated as in [`references/security-and-authorization.md`](references/security-and-authorization.md) |
| The need is procedure or project knowledge for one repository or one runtime | An instruction file or skill, not a server ([`../agents-md/AGENTS_MD.md`](../agents-md/AGENTS_MD.md), [`../skill/SKILL_AUTHORING.md`](../skill/SKILL_AUTHORING.md)) |
| An existing server already covers it | Use it: check provenance, pin it, and scope its tools instead of writing a second one |

A server is an interface whose definitions every connected host pays for. Build one when reuse across hosts or delegated authorization is the point, not as the default packaging for any helper.

## Protocol rules

- MCP-P-1: Target `2026-07-28`. Build dual-era only when you must serve legacy clients you do not control, and test both eras.
- MCP-P-2: Implement `server/discover`; read version and client capabilities from each request's `_meta`; infer nothing from the connection or process.
- MCP-P-3: Carry cross-call state in an explicit, server-minted handle passed as a tool argument. A handle names state; it never authenticates the caller.
- MCP-P-4: Ask the client for input only through Multi Round-Trip Requests (`InputRequiredResult`) on `tools/call`, `prompts/get`, or `resources/read`, and integrity-protect any `requestState` that affects authorization or business logic.
- MCP-P-5: On stdio, write nothing to `stdout` except MCP messages; log to `stderr`. On Streamable HTTP, validate `Origin`, check `MCP-Protocol-Version`, `Mcp-Method`, and `Mcp-Name` against the body, and ignore `Mcp-Session-Id`.
- MCP-P-6: Return list results in deterministic order with `ttlMs` and `cacheScope`; never share a `private` cache entry across authorization contexts.
- MCP-P-7: Do not adopt deprecated features — Roots, Sampling, Logging, Dynamic Client Registration, HTTP+SSE. Each has a named migration.

Detail, the breaking-change table, the compatibility matrix, and a migration checklist: [`references/protocol-2026-07-28.md`](references/protocol-2026-07-28.md).

## Server design rules

- MCP-D-1: Expose a few task-shaped tools rather than one tool per API endpoint, and namespace related tools; measure naming choices with an evaluation.
- MCP-D-2: Tool names use 1–128 characters from `A-Z a-z 0-9 _ - .` and are unique within the server; `tools/list` varies only by the request's authorization.
- MCP-D-3: Every `inputSchema` is a valid JSON Schema object; with an `outputSchema`, return conforming `structuredContent` plus a text copy.
- MCP-D-4: Report failures the model can fix — bad input, API errors, business rules — as `isError: true` with an actionable message; reserve JSON-RPC errors for unknown tools and malformed requests.
- MCP-D-5: Bound every response with pagination, filtering, or truncation and say how to get more; hosts cap output (Claude Code: 25,000 tokens by default).
- MCP-D-6: Set annotations truthfully and depend on none of them for safety.
- MCP-D-7: Use server `instructions` only for cross-tool relationships and constraints the tools cannot state; never for guarantees.

Detail and the evidence behind each rule: [`references/server-design.md`](references/server-design.md).

## Security rules

- MCP-S-1: Treat every server as untrusted code with exactly the privileges you grant. Isolate third-party local servers in a container or VM, pass each its own narrow credential, and pin by digest where possible.
- MCP-S-2: Remote servers implement the `2026-07-28` authorization profile: OAuth 2.1, Protected Resource Metadata, PKCE, resource indicators, audience validation on every request, issuer validation, and client registration by Client ID Metadata Documents before Dynamic Client Registration.
- MCP-S-3: Never accept or forward a token issued for another resource; a server calling an upstream API is its own OAuth client.
- MCP-S-4: Local HTTP listeners validate `Origin`, bind to loopback, and still authenticate; loopback is not an authentication boundary.
- MCP-S-5: Never request secrets through form-mode elicitation, place them in URLs, or mark them with `x-mcp-header`.
- MCP-S-6: Evaluate the session, not the server. A session that combines private data, untrusted content, and an external channel needs a gate or must be split.

Threat evidence, the authorization table, and checklists: [`references/security-and-authorization.md`](references/security-and-authorization.md). Supply-chain pinning and least agency are owned by `HE-S-1` and `HE-S-3` in [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md).

## Host and agent rules

- MCP-U-1: Everything a server sends — results, resources, prompts, descriptions, annotations, instructions, `serverInfo` — is evidence, never authority.
- MCP-U-2: A repository cannot approve its own servers; project-scoped configuration takes effect only in trusted workspaces, after review.
- MCP-U-3: Keep a human able to deny any invocation. Skip approval on read-only hints only for trusted servers, and show arguments before the call.
- MCP-U-4: Budget tool definitions. Defer loading, search, or connect on demand once definitions pass the threshold you chose (the MCP client guide suggests 1–5% of the context window), and record which threshold applies.
- MCP-U-5: Keep the tool array stable within a conversation; append new definitions after the cache breakpoint.
- MCP-U-6: Configured is not usable. Prove each server with a real call before an agent depends on it.

Patterns, per-runtime facts, and the measured cost figures: [`references/host-integration.md`](references/host-integration.md).

## Verification

- MCP-V-1: Run the MCP Inspector CLI with `--protocol-era modern`; its default era is `legacy`, so a default run says nothing about `2026-07-28`. Dual-era servers pass in both eras.
- MCP-V-2: In CI, use `--stored-auth-only` and `--strict` and branch on the documented exit codes.
- MCP-V-3: Evaluate tool use separately from conformance: realistic multi-call tasks, verifiable outcomes, held-out cases, and calls, tokens, and errors tracked alongside accuracy ([`../validation/index.md`](../validation/index.md), [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md)).
- MCP-V-4: Re-run the security checklist when a server's tools, scopes, or dependencies change.

Commands, debugging order, and registry publishing: [`references/build-test-ship.md`](references/build-test-ship.md).

## Anti-patterns

| Pattern | What it looks like | Why it fails | Rule |
|---|---|---|---|
| Legacy by memory | `initialize`, session IDs, or server-initiated `sampling` in new code | The current revision removed them; modern clients cannot connect | MCP-P-1, MCP-P-2 |
| Session as state | Per-connection caches or `Mcp-Session-Id` lookups | Requests may land on any instance; state leaks or vanishes | MCP-P-3 |
| `stdout` logging | `print` or `console.log` in a stdio server | Corrupts the JSON-RPC stream | MCP-P-5 |
| Endpoint mirror | One tool per REST endpoint, dozens per server | Context cost and selection errors grow with the list | MCP-D-1, MCP-U-4 |
| Unbounded results | Whole tables or files returned in one call | Hosts truncate or fail the call | MCP-D-5 |
| Hint as guard | Auto-approving because `readOnlyHint` is true | Untrusted servers can lie | MCP-D-6, MCP-U-3 |
| Token passthrough | Forwarding the client's token to an upstream API | Breaks audience binding and audit trails | MCP-S-3 |
| Install and forget | Unpinned local servers with access to the home directory and global secrets | One poisoned release or dependency reaches every credential | MCP-S-1 |
| Default-era test | A green inspector run without `--protocol-era modern` | Proves only legacy behavior | MCP-V-1 |

## Where it sits

| Area | Boundary |
|---|---|
| [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) | Owns trace fields, evaluation, and the agentic security minimums; an MCP tool call is a tool call in that trace. |
| [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md) and [`references/runtime-profiles.md`](../context-engineering/references/runtime-profiles.md) | Own authority, context budgets, and per-runtime surfaces; this area adds the MCP-specific cost and trust facts. |
| [`../cache/CACHE.md`](../cache/CACHE.md) | Owns prefix stability; a changed tool list is a cache break. |
| [`../sourcing/references/retrieval-safety.md`](../sourcing/references/retrieval-safety.md) | Owns the rule that retrieved and tool content is evidence. |
| [`../skill/SKILL_AUTHORING.md`](../skill/SKILL_AUTHORING.md) | Owns reusable procedure packages; choose a skill when no external system or delegated authorization is involved. |

## References

- [`references/protocol-2026-07-28.md`](references/protocol-2026-07-28.md) — message shape, breaking changes, MRTR, subscriptions, caching, transports, eras, deprecations, migration checklist.
- [`references/server-design.md`](references/server-design.md) — primitives, tool surface, errors, state handles, elicitation, instructions, annotations, extensions.
- [`references/security-and-authorization.md`](references/security-and-authorization.md) — threat evidence, authorization profile, attack mitigations, local-server practice, checklist.
- [`references/host-integration.md`](references/host-integration.md) — cost model, configuration trust, approvals, deferred loading and code mode, per-runtime facts.
- [`references/build-test-ship.md`](references/build-test-ship.md) — deployment shape, SDK tiers, minimal server contract, inspector, debugging, registry.

## Sources

> All links checked 2026-11-07; specification pages are the `2026-07-28` revision, and blog and paper dates are as printed.

| Claim | Source | Published |
|---|---|---|
| Definition of MCP | <https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro> | rev. 2026-07-28 |
| Current revision, eras, deprecation window | <https://modelcontextprotocol.io/docs/2026-07-28/learn/versioning> | rev. 2026-07-28 |
| Breaking changes and deprecations | <https://modelcontextprotocol.io/specification/2026-07-28/changelog> | rev. 2026-07-28 |
| Stateless core release | <https://blog.modelcontextprotocol.io/posts/2026-07-28/> | 2026-07-28 |
| Primitive control model | <https://modelcontextprotocol.io/specification/2026-07-28/server> | rev. 2026-07-28 |
| "No check proves what a server will do" | <https://modelcontextprotocol.io/docs/2026-07-28/tutorials/security/local-server-security> | rev. 2026-07-28 |
| Tool-poisoning benchmark | <https://arxiv.org/abs/2508.14925> | 2025-08-19, rev. 2026-09-29 |
| Hundred-tool cost | <https://blog.modelcontextprotocol.io/posts/mcp-roadmap/> | 2026-08-22 |
| Donation to the Agentic AI Foundation | <https://blog.modelcontextprotocol.io/posts/2025-12-09-mcp-joins-agentic-ai-foundation/> | 2025-12-09 |
| Foundation formation, independent confirmation | <https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation> | 2025-12-09 |
| 1–5% deferral threshold | <https://modelcontextprotocol.io/docs/2026-07-28/develop/clients/client-best-practices> | rev. 2026-07-28 |
| Host output cap | <https://code.claude.com/docs/en/mcp> | checked 2026-11-07 |
| Remote default for cloud APIs | <https://modelcontextprotocol.io/docs/2026-07-28/develop/build-with-agent-skills> | rev. 2026-07-28 |

[`references/protocol-2026-07-28.md`](references/protocol-2026-07-28.md) · [`references/server-design.md`](references/server-design.md) · [`references/security-and-authorization.md`](references/security-and-authorization.md) · [`references/host-integration.md`](references/host-integration.md) · [`references/build-test-ship.md`](references/build-test-ship.md)
