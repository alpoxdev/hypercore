---
name: seo-maker
description: "[Hyper] Create integrated SEO, AEO, GEO, and LLMO audits and optimization reports. Use for on-page, technical, content, Core Web Vitals, answer-engine, generative-engine, AI search visibility, metadata, citation readiness, or score-improvement loops saved under `.hypercore/seo-maker/[slug]/`."
compatibility: Works best with live web access, browser inspection, local source search, Lighthouse or Core Web Vitals data when available, and read/write access for report artifacts.
---

@rules/seo-workflow.md
@rules/validation.md

# SEO Maker

> Audit and improve a project's search visibility across traditional search engines and AI answer engines.

<purpose>

- Audit website or project SEO in a systematic way.
- Cover on-page SEO, technical SEO, content SEO, and Core Web Vitals.
- Evaluate AEO readiness for featured snippets, voice search, and direct-answer surfaces.
- Evaluate GEO readiness for citation likelihood in generative AI responses.
- Evaluate LLMO readiness for AI crawler access, freshness, and model-readable context.
- Save prioritized recommendations and evidence under `.hypercore/seo-maker/[slug]/`.
- Update existing reports so SEO improvement history remains traceable.
- If the user asks for highest score, max score, maximum score, perfect score, or continuous improvement, run an audit to fix/recommendation to re-audit loop and keep the best result.

</purpose>

<routing_rule>

Use `seo-maker` when the main outcome is an SEO/AEO/GEO/LLMO audit, optimization report, or evidence-backed search visibility improvement plan.

Route neighboring work elsewhere:

- Page or product UI design: use `designer` or the relevant frontend design skill.
- Competitor or market research without site audit: use `research`.
- Pre-release build and deployment checks: use `pre-deploy`.
- Pure performance engineering without search context: use the relevant performance or optimization workflow.
- Broad AI search trend research without a target site or content set: use `research`.

</routing_rule>

<trigger_conditions>

Positive examples:

- "Audit this site's SEO."
- "Check metadata and structured data."
- "Create an SEO audit report."
- "Review search-engine optimization status and give improvement recommendations."
- "Summarize how to improve Core Web Vitals scores."
- "Optimize our content so AI search engines can cite it."
- "Check whether ChatGPT or Perplexity can surface our brand."
- "Analyze this site from AEO and GEO perspectives."
- "Keep iterating fixes until the SEO score is as high as possible."
- "Audit, fix, and re-verify until the search optimization score is close to perfect."

Negative examples:

- "Design this landing page." -> use `designer`.
- "Research competitor market positioning." -> use `research`.
- "Check the pre-deploy checklist." -> use `pre-deploy`.

Boundary examples:

- "Optimize this page's performance."
  Use `seo-maker` only when performance is evaluated through SEO/Core Web Vitals impact.
- "Research AI search trends."
  Use `seo-maker` only when the output is tied to a target site, page, or content inventory.

</trigger_conditions>

<modes>

| Situation | Mode |
|------|------|
| Full SEO audit for a new project or site | create |
| On-page SEO review for a specific page | create |
| Add a new analysis to an existing SEO report | update |
| Focused Core Web Vitals or technical SEO analysis | create |
| Re-check after SEO improvements | update |
| Iterative improvement toward best or perfect score | optimize |
| AEO/GEO citation readiness analysis | create |
| Add AEO/GEO analysis to an existing report | update |

</modes>

<supported_targets>

- Metadata and SEO elements in HTML pages and Next.js/React components.
- `robots.txt`, `sitemap.xml`, `llms.txt`, canonical tags, and structured data.
- Core Web Vitals signals such as LCP, INP, and CLS.
- `<head>` elements including title, meta description, Open Graph, and Twitter Card.
- Heading hierarchy from `h1` through `h6`.
- Image alt text and internal link structure.
- Schema.org JSON-LD markup, including AI trust signals.
- AEO elements such as Q&A formats, direct-answer structure, and featured-snippet optimization.
- GEO elements such as citable sentence structure, statistics with sources, and entity authority.
- LLMO elements such as `llms.txt`, AI crawler accessibility, and content freshness.

</supported_targets>

<complexity_routing>

| Complexity | Signals | Handling |
|------|------|------|
| **Simple** | Single-page review, one SEO element, quick metadata audit | **Direct**: write `report.md` immediately |
| **Complex** | Full-site audit, many pages, technical SEO plus content SEO plus Core Web Vitals, competitor comparison | **Tracked**: use `flow.json` for phase tracking |

Before starting, record:

```text
Complexity: [simple/complex] — [one-line reason]
Mode: [create/update/optimize]
Target: [site/page/project path]
Proof surface: [commands, browser checks, web sources, or local files]
```

</complexity_routing>

<universal_intake>

Before scoring any project, classify the audit context so this skill works across stacks:

- `target_type`: `live-url`, `local-static`, `nextjs`, `react-spa`, `docs-site`, `ecommerce`, `blog`, or `app-with-marketing-pages`
- `access_level`: live URL, local files only, Search Console available, analytics available, field Core Web Vitals available, or AI citation probe available
- `allowed_action`: `audit-only`, `recommend`, `edit-code`, or `optimize-loop`
- `measurement_confidence`: lower confidence when live URL, Search Console, field Core Web Vitals, or AI citation probes are unavailable

Do not hide missing evidence. If a recommendation is based on static files, lab data, synthetic probes, or heuristics, label it that way in `results.json`.

</universal_intake>

<artifact_contract>

Create or update `.hypercore/seo-maker/[slug]/`.

Expected files:

```text
.hypercore/seo-maker/[slug]/
├── dashboard.html      # Browser-readable dashboard
├── results.json        # Structured audit results
├── results.js          # File URL fallback for browser rendering
├── report.md           # Markdown report
├── sources.md          # Source and evidence log
└── flow.json           # Required for complex or optimize mode
```

For simple mode, `report.md` and `sources.md` are the minimum. For complex or optimize mode, all files are expected.

Follow [references/artifact-spec.md](references/artifact-spec.md) for the file schema.

Render order:

1. Gather evidence and write/update `results.json`.
2. Generate `results.js` for direct local browser viewing.
3. Render `dashboard.html` from the current results.
4. Write `report.md` and `sources.md` with links or file references.

</artifact_contract>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Determine target, mode, complexity, proof surface, and universal intake fields | Execution brief |
| 1 | Establish measurement methods and confidence limits | `measurement_methods` |
| 2 | Collect evidence from local code, pages, browser checks, and web sources | Evidence log |
| 3 | Audit technical SEO, platform policy, AEO, GEO, LLMO, Core Web Vitals, and structured data | Structured findings |
| 4 | Separate official requirements from field/tool/lab/synthetic/heuristic findings | Evidence-graded findings |
| 5 | Prioritize issues by impact, confidence, effort, and source tier | Recommendation set |
| 6 | Write artifacts and dashboard | `.hypercore/seo-maker/[slug]/` |
| 7 | If optimize mode, apply or recommend fixes and re-audit | Best verified result |
| 8 | Summarize score, wins, confidence limits, risks, and next actions | Final report |

</workflow>

<audit_dimensions>

Check these dimensions when relevant to the target:

- Technical SEO: crawlability, indexability, canonicalization, sitemap, robots directives, response status, redirects, and duplicate pages.
- Platform policy: Googlebot, Google-Extended, OAI-SearchBot, GPTBot, ChatGPT-User, PerplexityBot/ClaudeBot when present, snippet controls, X-Robots-Tag, and optional `llms.txt`.
- On-page SEO: title, description, heading hierarchy, keyword alignment, URL readability, and internal links.
- Content SEO: intent match, depth, freshness, topical coverage, uniqueness, and readability.
- Core Web Vitals: LCP, INP, CLS, render-blocking resources, image sizing, and interaction latency.
- Structured data: JSON-LD validity, Schema.org fit, visible-content parity, entity identifiers, breadcrumbs, FAQs, products, articles, or organization markup. Do not imply structured data guarantees rich results or AI citations.
- AEO: concise visible answer blocks, Q&A structure, snippet-ready summaries, voice-search phrasing, and direct-answer clarity. Treat fixed answer lengths as heuristic.
- GEO: citable claims, statistics with sources, entity authority, author or brand trust signals, and content that AI systems can quote safely.
- LLMO: optional `llms.txt`, AI crawler access, clean markdown or semantic HTML, clear entity relationships, and updated canonical content. Missing `llms.txt` is not critical by default.

</audit_dimensions>

<scoring>

Use a transparent 100-point score when enough evidence exists:

- Technical SEO: 20
- On-page SEO: 20
- Content SEO: 15
- Core Web Vitals: 15
- Structured data: 10
- AEO readiness: 10
- GEO/LLMO readiness: 10

If evidence is incomplete, mark affected categories as `unknown` instead of inventing certainty.

Each finding should include:

- Severity: critical, high, medium, low, or informational.
- Confidence: high, medium, or low.
- `evidence_grade`: `official`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`.
- `measurement_method`: scan, tool, probe, source, or command used.
- `source_tier`: `official-doc`, `observed-file`, `field-data`, `tool-output`, `synthetic-probe`, or `research-backed-heuristic`.
- Evidence: command output, URL, local file path, browser observation, or saved probe result.
- Recommendation: specific action and expected impact.
- Owner surface: code, content, infrastructure, analytics, or external platform.

</scoring>

<optimize_loop>

Use optimize mode when the user requests a maximum score, perfect score, continuous iteration, or "keep fixing until it passes" behavior.

Loop rules:

1. Run a baseline audit and write the score.
2. Pick the highest-impact fix or recommendation with the best confidence/effort ratio.
3. Apply safe local code/content fixes when they are in scope; otherwise record an actionable recommendation.
4. Re-run the relevant audit checks.
5. Keep the change only if the score or verified evidence improves without regression.
6. Stop when the score target is met, no safe local fixes remain, or further work requires external credentials or business decisions.

Do not fake a perfect score. If external evidence is unavailable, report the unknowns and the best verified score.

</optimize_loop>

<validation>

At completion, `.hypercore/seo-maker/[slug]/` should contain:

- `results.json` with structured audit results and status `complete` for complex or optimize mode.
- `dashboard.html` rendered from the latest results when dashboard output is expected.
- `results.js` for local browser fallback when dashboard output is expected.
- `report.md` with prioritized findings, score, and recommendations.
- `sources.md` with the evidence log.

Validate:

- Every high or critical finding has evidence.
- Recommendations are specific enough for an engineer, marketer, or content owner to act on.
- Scores are derived from observed evidence, not assumptions.
- Google AI features are not described as requiring special schema, AI text files, or magic markup.
- FAQPage recommendations distinguish Google rich-result eligibility from answer-friendly visible FAQ content.
- Unknowns are explicitly marked.
- Optimize mode records baseline score, changes/recommendations, re-audit evidence, and the best verified result.

</validation>
