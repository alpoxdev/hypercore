# AEO/GEO/LLMO Strategy Guide

**Purpose**: AI search optimization reference for AEO/GEO phases.
**Last verified**: 2026-04-29 from Google Search Central, OpenAI crawler docs, web.dev, arXiv GEO research, and llms.txt reference material.

## Evidence Discipline

Label every AEO/GEO recommendation by evidence tier:

| Tier | Meaning | Examples |
|------|---------|----------|
| `official` | Platform/vendor documentation or policy | Google AI features guidance, OpenAI crawler docs |
| `field` | Real user/search data from Search Console, analytics, server logs, or verified AI citations | Search Console performance, AI referral logs |
| `tool` | Deterministic tool output | Rich Results Test, PageSpeed Insights, schema validator |
| `lab` | Controlled but simulated measurement | Lighthouse, local crawler, static render checks |
| `synthetic` | Prompt/citation probes against AI engines | Repeated ChatGPT/Perplexity/Gemini citation prompt set |
| `heuristic` | Best-practice inference or industry observation | 40-80 word answer blocks, table/list extraction patterns |

Do not present heuristic or synthetic findings as guaranteed ranking/citation factors. Record confidence (`high`, `medium`, `low`) separately from severity.

## Official Caveats

- Google says AI Overviews and AI Mode use the same foundational SEO practices as Search; there are no extra technical requirements, special schema.org types or special schema.org markup, or AI text files required for inclusion.
- A page still needs to be indexed and snippet-eligible to appear as a supporting link in Google AI features.
- OpenAI separates `OAI-SearchBot` for ChatGPT Search inclusion from `GPTBot` for model training. These should be audited and recommended separately.
- `llms.txt` is useful as a machine-readable content map, but it is not a W3C/IETF standard and is not a guaranteed major-provider fetch contract as of 2026-04-29.

## Terminology

| Term | Full Name | Definition |
|------|-----------|------------|
| **AEO** | Answer Engine Optimization | Making visible page content easy to extract as a direct answer |
| **GEO** | Generative Engine Optimization | Improving the chance that AI-generated answers cite, mention, or ground on a source |
| **LLMO** | Large Language Model Optimization | Making content easier for LLMs and retrieval systems to parse, understand, and reuse accurately |
| **AIO** | AI Optimization | Umbrella term; avoid using it when AEO/GEO is more precise |

## SEO vs AEO vs GEO

| Criteria | SEO | AEO | GEO |
|----------|-----|-----|-----|
| **Goal** | Crawlability, indexability, ranking, search appearance, CTR | Direct answer/snippet/voice-style extraction | AI answer citation, brand mention, source selection |
| **Best evidence** | Search Console, crawl/index status, field CWV, structured data validation | Snippet controls, visible Q&A/answer blocks, FAQ/QAPage validity | Query/prompt probes, citation frequency, official crawler access, source diversity |
| **Risk** | No ranking/indexing guarantee | FAQ rich results are limited by site type | Black-box systems vary; results need confidence labels |

## AEO Strategy

### Direct answer blocks (`heuristic`)

- Put a concise answer near the top of sections that target question-like queries.
- Use question-matching H2/H3 headings when natural.
- Favor visible text, short paragraphs, lists, comparison tables, and definition/procedure blocks.
- Treat fixed answer length rules as heuristic. A 40-80 word direct answer is a useful working range, not a platform guarantee.

### FAQ and Q&A (`official` + `heuristic`)

- Use visible FAQ content when the page genuinely answers common questions.
- FAQPage eligibility is limited for Google rich results; `FAQPage` eligibility is limited to well-known authoritative government or health-focused sites. For general sites, FAQ content may still help users and answer extraction, but do not promise Google FAQ rich results.
- Use `QAPage` instead of `FAQPage` when users can submit multiple answers to one question.
- Structured data must match visible content and must not mark up hidden, irrelevant, or misleading information.

## GEO Strategy

GEO is partly experimental and should be measured with query sets or citation probes when possible.

### GEO CORE Framework

| Dimension | What to inspect | Evidence examples |
|-----------|-----------------|-------------------|
| Context | Complete background, definitions, related concepts | Topic coverage map, query fan-out gaps |
| Organization | Extractable hierarchy, tables/lists, short sections | H2/H3 scan, answer block detector |
| Reliability | Sources, dates, author/site trust, factual verifiability | Citations, author bio, organization schema, external references |
| Exclusivity | Original research, proprietary data, unique examples | First-party benchmarks, case studies, original screenshots/data |

### Citation-ready content (`synthetic`/`heuristic` unless probed)

- Write short, self-contained statements that can be cited without surrounding context.
- Add dates, source names, and links for factual claims.
- Prefer original data, comparisons, benchmark tables, and clearly scoped definitions.
- Avoid creating pages only to manipulate AI answers; keep people-first usefulness as the primary goal.

### Query fan-out simulator

When optimizing a topic for AI search, generate 10-30 subqueries across:

- definitions and beginner questions
- comparisons and alternatives
- pricing, risk, limitations, and implementation questions
- entity/brand/product questions
- local, industry, or YMYL-specific variants when relevant

Record uncovered subtopics in `results.json.query_fanout` and turn them into prioritized content recommendations.

### AI citation probe

If the runtime and user permissions allow it, run a stable prompt set across AI search engines and record:

- engine, date, region/language, prompt text, and sample size
- cited URLs, brand mentions, sentiment, and competitor share of voice
- repeated-run volatility and confidence

If probing is unavailable, save the prompt pack as `not-run` rather than pretending the signal exists.

## Platform Policy Matrix

| Platform / bot | Primary purpose | Optimization implication |
|----------------|-----------------|--------------------------|
| Googlebot | Google crawling/indexing/search snippets | Must allow important indexable pages and resources unless intentionally excluded |
| Google-Extended | Google AI product/training controls outside normal Search crawling | Separate from Search visibility decisions |
| OAI-SearchBot | ChatGPT Search inclusion | Allow when ChatGPT Search visibility is desired |
| GPTBot | OpenAI model training | Can be allowed or blocked independently from OAI-SearchBot |
| ChatGPT-User | User-triggered fetches | Not a normal automatic search crawler; document separately |
| PerplexityBot / ClaudeBot | AI retrieval/crawling where documented or observed | Audit robots/server rules, but label recommendations by evidence tier |

## llms.txt

Use `llms.txt` as an optional, low-risk content map:

```text
# llms.txt
> Site: example.com
> Description: One-line site description

## Core pages
- /about: Company overview
- /docs: Technical documentation
- /blog/key-topic: Best overview of the topic
```

Rules:

- Do not mark missing `llms.txt` as critical by default.
- Recommend it most strongly for documentation sites, developer tools, API references, and content-heavy products.
- Keep it aligned with canonical URLs and sitemap priorities.

## Measurement KPIs

| KPI | Description | Preferred evidence |
|-----|-------------|--------------------|
| AI Citation Frequency | How often target URLs are cited in AI answers | Synthetic probes or AI visibility tools |
| Brand Mention Rate | How often the brand/entity is named | Synthetic probes, AI referrals, third-party tools |
| Share of Voice | Citation/mention share vs competitors | Repeated prompt set with competitors |
| AI Overview Inclusion | Whether Google AI features include links to the site | Search Console/Web performance plus manual SERP evidence |
| Citation Sentiment | Positive/neutral/negative framing | Manual or tool-assisted review |
| AI-referred Conversion | Conversions from AI/search referrers | Analytics/server logs |

## Practical Optimization Order

1. Ensure indexability, crawlability, canonical correctness, and snippet eligibility.
2. Verify visible content quality, trust signals, and structured data parity.
3. Add answer blocks and Q&A content where useful to humans.
4. Build citation-ready sections with sources, original data, and clear entities.
5. Audit platform crawler policies, including OAI-SearchBot vs GPTBot separation.
6. Optionally add `llms.txt` for content maps.
7. Run query fan-out and citation probes when access allows, then iterate using `score_history` and `best_run`.
