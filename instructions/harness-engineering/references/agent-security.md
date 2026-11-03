# Agent Security Reference

> Korean version: [`agent-security.ko.md`](agent-security.ko.md)

The threat enumeration behind the minimum security assertions in
[`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## Agentic Security Minimums`.

**Attribution.** The ten risks below are **OWASP's**, published as the *OWASP Top 10 for Agentic
Applications for 2026* — edition "Version 2026", cover dated December 2025, released 2025-12-09.
This file reports OWASP's list and adds one column of **harness controls**, which is this
repository's mapping and not a quotation of OWASP. As of 2026-11-03 the resource page carries a
single edition and no revision.

**Attribution integrity.** OWASP states two ideas in its opening letter — `Least-Agency` and
`strong observability` — but never calls them "principles"; the word does not appear anywhere in
the document. The "two core principles" framing comes from secondary write-ups. Quote the ideas,
not the framing.

**Do not cite a "v2.01" edition.** Several 2026 blog posts claim a June 2026 revision of this
list. That version number belongs to a different OWASP document, *State of Agentic AI Security and
Governance 2.01*. The agentic Top 10 itself was not revised. (The companion *Agentic AI Threats and
Mitigations* taxonomy did move to 1.1 at launch.)

## What OWASP says, verbatim

From the Letter from the Agentic Top 10 Leaders, signed by John Sotiropoulos (Agentic Top 10
Chair), Keren Katz, and Ron F. Del Rosario:

> "We expand on the concepts of Least-Privilege and Excessive Agency by citing Least-Agency. This
> captures our advice to organizations to avoid unnecessary autonomy; deploying agentic behavior
> where it is not needed expands the attack surface without adding value. Similarly, strong
> observability becomes non-negotiable: without clear visibility into what agents are doing, why
> they are doing it, and which tools they are invoking, unnecessary autonomy can quietly expand
> the attack surface and turn minor issues into system-wide failures."

The pair is load-bearing because neither half survives alone:

- **Least agency without observability** is blind risk reduction: autonomy is withdrawn on
  intuition and nobody can show whether the withdrawal helped.
- **Observability without least agency** is surveillance of an unconstrained agent: the logs are
  complete and the authority is still unbounded.

OWASP's own example of applied least agency, from the ASI02 mitigation list:

> "Least Agency and Least Privilege for Tools. Define per-tool least-privilege profiles (scopes,
> maximum rate, and egress allowlists)..."

## The ten risks (official headings)

Quoted from the document's section headings and its "Agentic Top 10 At A Glance" page. The control
column is this repository's mapping to the `HE-S-*` rules and to the harness layers that carry it.

| id | OWASP heading | Harness control | Rule |
|---|---|---|---|
| ASI01 | Agent Goal Hijack | External input is data; the plan is validated against a permitted-action allowlist; a hijacked goal cannot reach production | HE-S-2 |
| ASI02 | Tool Misuse and Exploitation | Per-tool scope, rate, and egress limits; schema validation on arguments; policy on every invocation, including composed chains | HE-S-1 |
| ASI03 | Identity and Privilege Abuse | A distinct agent identity per role, time-bound scopes, an audit record linking agent, user, and action | HE-S-1, HE-T-2 |
| ASI04 | Agentic Supply Chain Vulnerabilities | Pinned versions and authenticated sources for external agents, MCP servers, plugins, templates, and tool descriptors | HE-S-3 |
| ASI05 | Unexpected Code Execution (RCE) | Generated code never runs with production credentials; sandboxed runtime; allowlist before execution | HE-S-1 |
| ASI06 | Memory & Context Poisoning | Sanitize before persistence, integrity-check stores, scope memory per agent, keep a rollback path | HE-S-2, HE-L-1 |
| ASI07 | Insecure Inter-Agent Communication | Authenticate every message; authorize the delegation chain; no privilege escalation across agents | HE-S-1, HE-S-3 |
| ASI08 | Cascading Failures | Chain-depth and runtime limits, validation between plan and execute, rollback | HE-S-4 |
| ASI09 | Human-Agent Trust Exploitation | Distinguish agent content from verified data in the UI; human approval for high-stakes actions; provenance on recommendations | HE-S-4 |
| ASI10 | Rogue Agents | Behavioral baseline per verified identity, drift monitoring, kill switch, session isolation | HE-S-4, HE-T-2 |

## Naming and quoting notes

The document is inconsistent with itself, so a quotation that looks wrong may be faithful.

| Observation | Detail |
|---|---|
| `&` versus `and` | The "At A Glance" grid writes `ASI02: Tool Misuse & Exploitation` and `ASI03: Identity & Privilege Abuse`; the body headings and contents use `and` |
| ASI05 parenthesis | The heading and the grid both carry `Unexpected Code Execution (RCE)` |
| ASI10 typos | ASI10's body text refers to other entries as `AS01` and `AS04` |
| Heading case | Headings are title case; do not lowercase them into a "canonical" list |

## What the risks have in common

Across ASI01–ASI10 one pattern repeats: many failures are identity and authorization problems in
disguise. Goal hijacking succeeds when the agent cannot distinguish trusted orchestration from
untrusted data. Tool misuse succeeds when authorization is checked at the agent rather than at the
tool. Rogue agents succeed when no behavioral baseline is tied to a verified identity.

Three questions at every trust boundary:

1. **Who is acting?** A distinct agent identity, not a borrowed human session.
2. **What is it authorized to do?** Scoped, time-bound, revocable permissions.
3. **Can we prove it later?** An audit trail linking identity, policy decision, and outcome.

The composition point is the one the harness rules encode directly: each tool may be authorized
while the chain is not.

## What the 2026 harness sources add

OWASP enumerates the risks; the vendor harness work of 2026 supplies two controls that the list
names only obliquely.

- **Separate the harness from the compute** (ASI01, ASI05). OpenAI's Agents SDK announcement:

  > "Agent systems should be designed assuming prompt-injection and exfiltration attempts.
  > Separating harness and compute helps keep credentials out of environments where model-generated
  > code executes."

  This is the structural version of HE-S-1: the process that holds credentials is not the process
  that runs model-authored code, so a hijacked goal cannot spend what it cannot reach.

- **Externalize state so a lost sandbox is not a lost run** (ASI08, ASI10):

  > "It also enables durable execution. When the agent's state is externalized, losing a sandbox
  > container does not mean losing the run."

  A containment control that destroys the work when it fires will be disabled by the people who
  need it, which makes durability part of the security argument rather than a separate concern.

## Sources

> Checked 2026-11-03.

**Grade vocabulary.** One closed set for every source table in this directory; see
[`../HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## Sources`.

| Claim | Source | Grade |
|---|---|---|
| The ten risk headings, the two ideas quoted above, the `Least Agency and Least Privilege for Tools` mitigation item, and the note that ASI02/ASI03 use `&` in the summary grid | <https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/> (the document's PDF is linked from this page; the page and the PDF both answer without login) | PRIMARY |
| Edition "Version 2026", cover date December 2025, release 2025-12-09, and the absence of any revision | <https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/> | PRIMARY |
| The companion *Agentic AI Threats and Mitigations* taxonomy and its separate versioning | <https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/> | PRIMARY |
| Harness/compute separation, credential isolation, and durable execution by externalized state | <https://openai.com/index/the-next-evolution-of-the-agents-sdk> | VENDOR |

An earlier revision of this file treated the principle statements and the risk list as single-sourced
from a third-party summary because the OWASP page was read as abstract-only. The document is
retrievable without login, so the summary is no longer needed for the headings or the quoted ideas.
