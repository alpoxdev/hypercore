# Agent Security Reference

> Korean version: [`agent-security.ko.md`](agent-security.ko.md)

The threat enumeration behind the minimum security assertions in
[`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## Agentic Security Minimums`.

**Attribution.** These are **OWASP's** stated principles and risks, published as the *Top 10 for
Agentic Applications 2026*. This file reports what OWASP says; it does not claim that these are
the only principles of agentic security.

**Single-source exception.** The OWASP resource page returns its abstract only, so the two design
principles and the ASI01–ASI10 enumeration below were read from a **secondary** summary that cites
the release and links the official document. **Both the principle statements and the risk list are
therefore single-sourced in this repository**, and the PRIMARY row in Sources covers only the release
and its existence. Treat the risk *names* as OWASP's list and the *mitigation themes* as a summary,
and consult the official document before relying on any single item.

## The two principles

**Least agency** — the agentic evolution of least privilege. Limit not only what an agent can
access, but how much freedom it has to act without checking back. Autonomy should be earned, not
granted by default.

**Strong observability** — you must see what the agent is doing, why, and with whose identity.
Least agency without observability is blind risk reduction; observability without least agency is
surveillance of an unconstrained agent.

## The ten risks (ASI01–ASI10)

| id | Risk | Mitigation theme |
|---|---|---|
| ASI01 | Agent goal hijack | Treat external input as data, not instructions; validate plans against a permitted-action allowlist; sandbox so a hijacked goal cannot reach production |
| ASI02 | Tool misuse and exploitation | Tight tool scoping; schema validation on arguments; policy on every invocation; monitor anomalous tool chains; read-only where writes are unnecessary |
| ASI03 | Agent identity and privilege abuse | Dedicated agent identities with time-bound, least-privilege scopes; authorization at the tool level; audit trails linking agent, user, and action |
| ASI04 | Agentic supply chain vulnerabilities | Pin and verify tool versions; authenticate MCP and plugin sources; integrity-check templates; isolate third-party tools; audit transitive dependencies |
| ASI05 | Unexpected code execution | Never run generated code with production credentials; sandboxed runtimes with minimal permissions; allowlists before execution |
| ASI06 | Memory and context poisoning | Sanitize before persistence; integrity-check stores; scope memory per agent; monitor anomalous writes; keep a rollback path |
| ASI07 | Insecure inter-agent communication | Authenticate every inter-agent message; sign with agent-specific keys; nonces and timestamps; authorize delegation chains; no privilege escalation across agents |
| ASI08 | Cascading failures | Circuit breakers; validation between plan and execute; rollback; limits on chain depth and runtime; monitor self-reinforcing error patterns |
| ASI09 | Human–agent trust exploitation | Distinguish agent content from verified data in the UI; human approval for high-stakes actions; provenance on recommendations |
| ASI10 | Rogue agents | Behavioral baselines per agent identity; anomaly detection over time; kill switches; session isolation; drift monitoring |

## What the risks have in common

Across ASI01–ASI10 a pattern repeats: many failures are identity and authorization problems in
disguise. Goal hijacking succeeds when the agent cannot distinguish trusted orchestration from
untrusted data. Tool misuse succeeds when authorization is checked at the agent rather than at the
tool. Rogue agents succeed when there is no behavioral baseline tied to a verified identity.

Three questions to ask at every trust boundary:

1. **Who is acting?** A distinct agent identity, not a borrowed human session.
2. **What is it authorized to do?** Scoped, time-bound, revocable permissions.
3. **Can we prove it later?** An audit trail linking identity, policy decision, and outcome.

The composition point is the one the harness rules encode directly: each tool may be authorized while
the chain is not.

## Sources

> Checked 2026-09-20.

**Grade vocabulary.** `PRIMARY` = the document that states the claim. `SECONDARY` = a summary of
another document, used only where the primary is not retrievable. `VENDOR` = a first-party product or
vendor article. `STUDY` = an original experiment. `REPO` = a code repository used as evidence.

| Claim | Source | Grade |
|---|---|---|
| The release exists: OWASP Top 10 for Agentic Applications 2026, its title and publication. **Not** the principle statements or the risk list — see the single-source exception above | <https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/> | PRIMARY |
| The two design principles and the ASI01–ASI10 enumeration with their mitigation themes | <https://lineation.ai/owasp-top-10-agentic/> | SECONDARY |
| OWASP Agentic AI threats and mitigations series | <https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/> | PRIMARY |
