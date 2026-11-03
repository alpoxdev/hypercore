# Source Ledger Reference

> Korean version: [`source-ledger.ko.md`](source-ledger.ko.md)

**Purpose**: preserve source traceability of a research artifact as `query -> source -> claim -> caveat`.

---

## 1. Ledger principles

- The source list is a **verification log**, not a bibliography.
- A search snippet may be recorded as a `lead`, but it can never be primary evidence for a final claim.
- Separate `reviewed` from `cited`. For a reviewed source not used in the conclusion, record why it was excluded.
- Keep recency fields separate: `published/updated`, `accessed_at`, `retrieved_at`, `page_age`, and `tool/API version`.
- Record the **edition** of a versioned standard in the `Source` title, for example "OWASP Top 10 for LLM Applications 2026" rather than "OWASP Top 10". The edition is part of the identity, not a detail.
- Record the artifact you opened, not the page that pointed at it. A landing page, a PDF, and a per-entry HTML page can carry different editions of the same standard.
- Write the row only after reading the artifact. A row copied from an agent summary, a search snippet, or another ledger is unverified until someone opens it.

---

## 2. Source ledger template

```markdown
| # | Source | URL/path | Publisher | Published/updated | Accessed/retrieved | Version/freshness | Channel | Grade | Role | Relevant claim | Used? | Caveat |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  | official docs/web/github/local | S/A/B/C | lead/primary-evidence/supporting/conflict/rejected |  | yes/no |  |
```

### Field definitions

| Field | Criterion |
|---|---|
| `Source` | A human-identifiable title |
| `URL/path` | Canonical URL, GitHub permalink, or local path |
| `Publisher` | OpenAI, Anthropic, NIST, OWASP, repo owner, and so on |
| `Published/updated` | The page, document, or release date. `not stated` when absent |
| `Accessed/retrieved` | The date the researcher accessed it, the fetch timestamp, or a tool-provided `retrieved_at` |
| `Version/freshness` | API mode, tool version, release tag, standard edition, `page_age`, cache caveat |
| `Channel` | web, official docs, GitHub, local repo, paper, standard |
| `Grade` | S/A/B/C, or `S (repo)` for an internal repository standard |
| `Role` | lead, primary-evidence, supporting, conflict, rejected |
| `Relevant claim` | One sentence naming the claim this source supports or refutes |
| `Used?` | Whether it was cited in the final answer |
| `Caveat` | Inaccessible, outdated, vendor bias, method gap, scope mismatch |

---

## 3. Claim-source matrix template

```markdown
| Claim | Primary source(s) | Supporting/conflict source(s) | Verification | Confidence | Caveat |
|---|---|---|---|---|---|
|  |  |  | date/version checked, cross-checked, local test, etc. | high/medium/low |  |
```

### Usage criteria

- A non-obvious claim must have at least one primary source.
- A comparison or recommendation claim must show a source per criterion.
- A recency claim must carry an absolute date and source freshness.
- For a high-stakes claim without a primary source, lower the confidence and limit the scope.

---

## 4. Query log template

```markdown
| # | Query / command | Channel | Why this query | Result | Follow-up |
|---:|---|---|---|---|---|
```

Duplicate-prevention criteria:

- Do not repeat an identical or semantically equivalent query.
- Change the angle for additional queries: official, changelog, security, benchmark, counter-evidence, region, date.
- Once the source floor is met, stop searching and move to verification.

---

## 5. Rejected / conflict table

```markdown
| Source | Reason | Better source / resolution |
|---|---|---|
```

Exclusion reasons that must be recorded:

- A vendor blog older than the official documentation
- Only a search snippet, with the original inaccessible
- A different applicable version
- Unclear methodology or sample
- High likelihood of promotional content or bias
- Conflict with another S/A source

---

## 6. Minimum floors

| Research mode | Reviewed | Cited | Matrix |
|---|---:|---:|---|
| quick | 3+ | 2+ | Key claims only |
| default | 6+ | 4+ | Required |
| deep/parallel | 10+ | 6+ | Required + conflict/rejected table |
| official-doc update | 4+, prefer grade S | 3+, prefer grade S | Required |

When the user specifies a different floor, the user-specified value wins.

---

## 7. Citation chains

A page that asserts what a paper, standard, or release note says is evidence of **that page's claim**, not of the cited work's content.

| Step | Record |
|---|---|
| 1 | The secondary page as its own row, role `lead` |
| 2 | The cited artifact as its own row, role `primary-evidence`, with the edition or version you opened |
| 3 | Whether the artifact actually supports the sentence the secondary page attributed to it: `confirmed`, `partly`, or `misattributed` |
| 4 | A `misattributed` result in the rejected table, with the corrected claim |

Common chain failures worth checking explicitly:

- The secondary source quotes a **previous edition** of a standard that has since been republished.
- The secondary source reports a preliminary or vendor-reported number as final.
- The secondary source drops a qualifier ("in non-adaptive tests", "on our internal suite"), which changes the strength of the claim.
- The cited URL resolves to a different document than the one named, for example a landing page that now fronts a newer release.

---

## 8. Standards, editions, and synthetic material

| Material | Grade | Ledger treatment |
|---|---|---|
| Standard or framework, cited with its edition, artifact opened | S | Put the edition in `Source`; `Version/freshness` carries the edition and revision status |
| Framework that is announced as under revision | S for the current text | Record the revision notice as its own dated row so the reader sees both |
| Vendor overview or marketing page | B or C | Prefer the technical doc for behavior claims and record which row the conclusion used |
| Model-written summary, generated comparison table, undated aggregator page | C | `role: lead`, with the artifact you opened as a separate primary row |
| Search snippet, `page_age` only, cache suspected | C | `role: lead` until the original is opened |

Two traps to write into the caveat column rather than silently fixing:

- A per-entry page and the published PDF of the same framework carrying different editions.
- A DOI or short link that redirects, so the row names a landing page while the claim came from a PDF.

---

## 9. Rows gathered by agents

When a subagent, browser agent, or tool collects sources, the parent writes the ledger.

- A row is `unverified` until the parent opens the artifact or the agent returns the exact URL, edition, and quoted span.
- Quote spans travel with the row, because "the page says X" is not reproducible later.
- Never merge an agent's summary into a row that already has a verified span. Add a second row and mark the relationship.
- If the artifact cannot be reopened, keep the row as `lead` and say so; a ledger that hides this becomes a bibliography.

---

## Sources

| # | Source | Publisher | URL | Published/updated | Checked | Grade |
|---:|---|---|---|---|---|---|
| 1 | Reliable Search Guide, §5–§7 (grades, citations, ledger schema) | This repository | [`../reliable-search.md`](../reliable-search.md) | repository HEAD | checked 2026-11-03 | S (repo) |
| 2 | OWASP Top 10 for LLM Applications 2026 (edition-in-title practice) | OWASP GenAI Security Project | <https://genai.owasp.org/resource/owasp-genai-llm-top-10-2026/> | 2026-08-03 | checked 2026-11-03 | S |
| 3 | LLM01: Prompt Injection page still serving the 2025 body | OWASP GenAI Security Project | <https://genai.owasp.org/llmrisk/llm01-prompt-injection/> | body labelled LLM01:2025 | checked 2026-11-03 | S |
| 4 | Artificial Intelligence Risk Management Framework: Generative AI Profile (NIST AI 600-1), landing page with publication and update dates | NIST | <https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence> | 2024-07-26; page updated 2026-04-08 | checked 2026-11-03 | S |
| 5 | Web search tool citation annotations (`url_citation`, consulted-sources list) | OpenAI | <https://developers.openai.com/api/docs/guides/tools-web-search> | not stated | checked 2026-11-03 | S |
| 6 | Citations, span-based citation blocks | Anthropic | <https://platform.claude.com/docs/en/build-with-claude/citations> | not stated | checked 2026-11-03 | S |

The edition example in §8 was observed directly: the 2026 OWASP LLM Top 10 was published on 2026-08-03 while the per-entry page still served the 2025 body and the 2026 slug returned 404 (checked 2026-11-03).
