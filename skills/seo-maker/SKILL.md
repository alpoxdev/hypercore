---
name: seo-maker
description: "[Hyper] Create integrated SEO, AEO, GEO, and LLMO audits and optimization reports. Use for on-page, technical, content, Core Web Vitals, answer-engine, generative-engine, AI search visibility, metadata, citation readiness, or score-improvement loops saved under `.hyper/seo-maker/[slug]/`."
compatibility: Works best with live web access, browser inspection, local source search, Lighthouse or Core Web Vitals data when available, and read/write access for report artifacts.
---

@rules/seo-workflow.md
@rules/validation.md

# SEO Maker

> Audit and improve a project's search visibility across traditional search engines and AI answer engines.

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Produce an evidence-graded SEO/AEO/GEO/LLMO audit and a prioritized, actionable optimization report for a named target, and drive a bounded score-improvement loop when the user asks for the best achievable score. |
| Scope | Owns target classification, measurement-method selection, on-page/technical/content/Core Web Vitals/AEO/GEO/LLMO assessment, scoring, findings, recommendations, and the report workspace. Does not own implementation outside the audited target, release gating, page or product design, or broad market research that has no target site or content set. |
| Authority | System/harness and user instructions > the audited target's own files and live observations > official platform documentation > this skill > heuristic preference. A tool, lab, synthetic, or heuristic observation is never promoted to an official requirement. |
| Evidence | Read the target's own files, rendered pages, and live responses before scoring, and cite the command, URL, file path, or probe result behind every critical and warning finding. Record unavailable checks as `unknown` and irrelevant checks as `not-applicable`; never invent a score, a ranking, an inclusion, or a citation. |
| Tools | Use available read/search/browser tools, and render the dashboard with `scripts/render-dashboard.mjs <artifact-dir>`. Web search, browser inspection, field Core Web Vitals, Search Console, or an AI citation probe are used only when actually available; when one is missing, state the capability limit and fall back to the strongest lower-grade method. |
| Loop | Optimize mode only: a bounded `audit -> fix or recommendation -> re-audit` cycle, default budget three iterations. Feedback = comparable re-audit evidence; metric = the 100-point score with `unknown` and `not-applicable` categories excluded; guard = no comparable-category regression and no evidence-grade promotion; stop = target reached, budget spent, plateau, guard failure, or work that needs external credentials or a business decision. |
| Output | `.hyper/seo-maker/[slug]/` holding `results.json`, `results.js`, `dashboard.html`, `report.md`, `sources.md`, and `flow.json` for complex or optimize mode; simple mode keeps `report.md` and `sources.md` as the minimum. `sources.md` is a source ledger of URL, date, applicable claim, evidence class, and limitation. |
| Verification | Apply `rules/validation.md` at completion: every critical or warning finding carries evidence, scores derive from observed evidence with `unknown` and `not-applicable` handled explicitly, and optimize mode records baseline, evaluator, budget, guards, discarded iterations, stop reason, and the best comparable verified result. Package changes additionally run the focused corpus validator, the repository standard gate, and the package tests. |
| Stop condition | Stop when the requested audit or report is complete with graded evidence and no unresolved critical gap, or when optimize mode reaches its target, budget, plateau, guard, or an external dependency. Never stop by asserting a ranking, AI-feature inclusion, or citation the evidence does not support. |

</instruction_contract>

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Audit website or project SEO in a systematic way.
- Cover on-page SEO, technical SEO, content SEO, and Core Web Vitals.
- Evaluate AEO readiness for featured snippets, voice search, and direct-answer surfaces.
- Evaluate GEO readiness for citation likelihood in generative AI responses.
- Evaluate LLMO readiness for AI crawler access, freshness, and model-readable context.
- Save prioritized recommendations and evidence under `.hyper/seo-maker/[slug]/`.
- Update existing reports so SEO improvement history remains traceable.
- If the user asks for highest score, max score, maximum score, perfect score, or continuous improvement, run an audit to fix/recommendation to re-audit loop and keep the best result.

</purpose>

<routing_rule>

Use `seo-maker` when the main outcome is an SEO/AEO/GEO/LLMO audit, optimization report, or evidence-backed search visibility improvement plan.

Route neighboring work elsewhere:

- Page or product UI design: use `designer` or the relevant frontend design skill.
- Competitor or market research without site audit: use `research`.
- Release-gate checks whose only output is a go/no-go deployment verdict rather than a search-visibility audit: not this skill's output.
- Pure performance engineering without search context: use the relevant performance or optimization workflow.
- Broad AI search trend research without a target site or content set: use `research`.

</routing_rule>

<activation_examples>

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
- "Check the release checklist before deploying." -> a deployment gate verdict, not a search-visibility audit.

Boundary examples:

- "Optimize this page's performance."
  Use `seo-maker` only when performance is evaluated through SEO/Core Web Vitals impact.
- "Research AI search trends."
  Use `seo-maker` only when the output is tied to a target site, page, or content inventory.

</activation_examples>

<trigger_conditions>

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

</trigger_conditions>

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
- Naver search surfaces only when the target set includes them: `Yeti` crawler access, Search Advisor ownership verification, RSS and sitemap ownership-domain match, `og:image` conditions, and `nosourceinfo` scope.
- Bing surfaces only when the target set includes them: IndexNow change notification (a receipt code, never index or citation evidence), key-file ownership proof, the per-POST submission limit, and Bing sitemap field handling.

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
- `evaluator`: comparable target set, scoring rubric, tools/versions, dates, and evidence channels

Classify every finding and score input as exactly one of `official`, `live`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`. Do not treat one class as evidence from another: a local scan is not live or field evidence, and a tool/lab result is not an official requirement.

Record unavailable checks as `unknown` and irrelevant checks as `not-applicable`; exclude `not-applicable` checks from category denominators. Do not hide missing evidence. If a recommendation is based on static files, lab data, synthetic probes, or heuristics, label it that way in `results.json`.

When live browsing, Search Console, field data, AI probes, or a named tool is unavailable, use the strongest available lower-grade method, state the capability limitation and fallback, and do not make live-performance, ranking, inclusion, or citation claims.

</universal_intake>

<artifact_contract>

Create or update `.hyper/seo-maker/[slug]/`.

Expected files:

```text
.hyper/seo-maker/[slug]/
├── dashboard.html      # Browser-readable dashboard
├── results.json        # Structured audit results
├── results.js          # File URL fallback for browser rendering
├── report.md           # Markdown report
├── sources.md          # Source and evidence log
└── flow.json           # Required for complex or optimize mode
```

For simple mode, `report.md` and `sources.md` are the minimum. For complex or optimize mode, all files are expected.

Follow [references/artifact-spec.md](references/artifact-spec.md) for the file schema.

For new reports, use [assets/report.template.ko.md](assets/report.template.ko.md) by default. Use [assets/report.template.md](assets/report.template.md) only when English is explicitly required.

Render order:

1. Gather evidence and write/update `results.json`.
2. Generate `results.js` for direct local browser viewing.
3. Render `dashboard.html` from the current results.
4. Write `report.md` and `sources.md` with links or file references. `sources.md` is a source ledger: for every external or official claim, record its URL, accessed or published date, applicable claim, evidence class, and any scope/availability limitation.

When `results.json` is finalized, render the dashboard with `scripts/render-dashboard.mjs <artifact-dir>`.

For complex or optimize mode, `flow.json` tracks phases in order: `scope` → `measurement` → `technical` → `platform_policy` → `onpage` → `content` → `aeo` → `geo` → `report`.

</artifact_contract>

<support_file_read_order>

Read in this order:

1. Core `SKILL.md` to confirm the task is an SEO/AEO/GEO audit, optimization report, or score loop.
2. [rules/seo-workflow.md](rules/seo-workflow.md) for the execution phases.
3. [references/seo-fundamentals.md](references/seo-fundamentals.md) for E-E-A-T, Core Web Vitals, ranking factors, entity SEO, and schema markup criteria.
4. [references/aeo-geo-guide.md](references/aeo-geo-guide.md) for AEO/GEO/LLMO strategy, the GEO CORE framework, platform benchmarks, and `llms.txt` guidance.
5. [references/seo-checklist.md](references/seo-checklist.md) for the practical audit checklist.
6. [references/artifact-spec.md](references/artifact-spec.md) for `results.json`, dashboard lifecycle, and workspace schema.
7. For new reports, read [assets/report.template.ko.md](assets/report.template.ko.md) by default; read [assets/report.template.md](assets/report.template.md) only when English is explicitly required.
8. When rendering a dashboard, read [assets/dashboard-template.html](assets/dashboard-template.html).
9. Before completion, read [rules/validation.md](rules/validation.md).

</support_file_read_order>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Determine target, mode, complexity, proof surface, and universal intake fields | Execution brief |
| 1 | Establish measurement methods and confidence limits | `measurement_methods` |
| 2 | Collect evidence from local code, pages, browser checks, and web sources | Evidence log |
| 3 | Audit technical SEO, platform policy, AEO, GEO, LLMO, Core Web Vitals, and structured data | Structured findings |
| 4 | Separate official requirements from field/tool/lab/synthetic/heuristic findings | Evidence-graded findings |
| 5 | Prioritize issues by impact, confidence, effort, and source tier | Recommendation set |
| 6 | Write artifacts and dashboard | `.hyper/seo-maker/[slug]/` |
| 7 | If optimize mode, apply or recommend fixes and re-audit | Best verified result |
| 8 | Summarize score, wins, confidence limits, risks, and next actions | Final report |

</workflow>

<audit_dimensions>

Audit these dimensions when relevant to the target: technical SEO (crawlability, indexability, canonicalization, sitemap, robots directives, response status, redirects, duplicate pages); platform policy (Googlebot, Google-Extended, OAI-SearchBot, GPTBot, and ChatGPT-User as separate controls, snippet controls and X-Robots-Tag, plus the target-gated Naver and Bing/IndexNow modules); on-page SEO (title, description, heading hierarchy, keyword alignment, URL readability, internal links); content SEO (intent match, depth, topical coverage, freshness, uniqueness, readability); Core Web Vitals (LCP, INP, CLS, render-blocking resources, image sizing, interaction latency); structured data (JSON-LD validity, Schema.org fit, visible-content parity, entity identifiers, breadcrumbs, FAQ, product, article, and organization markup); AEO (visible answer blocks, Q&A structure, snippet-ready summaries, voice-search phrasing, direct-answer clarity); GEO (citable claims, statistics with sources, entity authority, author and brand trust signals, safely quotable content); and LLMO (optional `llms.txt`, AI crawler access, clean markdown or semantic HTML, clear entity relationships, fresh canonical content).

Per-dimension criteria and the conditional platform modules live in [rules/seo-workflow.md](rules/seo-workflow.md) phases 3-8, [references/seo-checklist.md](references/seo-checklist.md), [references/seo-fundamentals.md](references/seo-fundamentals.md), and [references/aeo-geo-guide.md](references/aeo-geo-guide.md).

Treat character counts, heading counts, link density, answer length, word counts, and platform content preferences as context-dependent heuristics, never official pass/fail conditions; do not imply that structured data, `llms.txt`, or ordinary index/snippet eligibility guarantees rich results, ranking, AI inclusion, or citation. Evaluate Google AI features through ordinary SEO fundamentals without prescribing special AI schema or text files.

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

If evidence is incomplete, mark affected categories as `unknown`; mark irrelevant categories as `not-applicable` and exclude them from the score denominator. Do not invent certainty or convert heuristics into official failures.

Each finding should include:
- Severity: `critical`, `warning`, or `info` (use impact/effort fields for prioritization beyond severity).
- Confidence: high, medium, or low.
- `evidence_grade`: `official`, `live`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`.
- `measurement_method`: scan, tool, probe, source, or command used.
- `source_tier`: `official-doc`, `observed-file`, `live-observation`, `field-data`, `tool-output`, `lab-result`, `synthetic-probe`, or `research-backed-heuristic`.
- Evidence: command output, URL, local file path, browser observation, or saved probe result.
- Recommendation: specific action and expected impact.
- Owner surface: code, content, infrastructure, analytics, or external platform.

</scoring>

<optimize_loop>

Use optimize mode only when the user requests a maximum, perfect, or continuously improved score, and treat it as a bounded `audit -> fix or recommendation -> re-audit` cycle: before changing anything, record the baseline, stable evaluator, target, finite budget (default three iterations), and regression guards; keep an iteration only when comparable evidence improves without tripping a guard, otherwise revert it where possible or mark it `discarded`; stop at the target, budget, plateau, guard failure, no safe local fix, or work that needs an external credential or a business decision. The full loop rules are in [rules/seo-workflow.md](rules/seo-workflow.md) phase 9.

Never fake a perfect score or promise a ranking, AI-feature inclusion, or a citation; report the unknowns and the best comparable verified result.

</optimize_loop>

<validation>

Apply [rules/validation.md](rules/validation.md) before declaring an audit complete. It requires evidence on every critical and warning finding; recommendations specific enough for an engineer, marketer, or content owner to act on; scores derived from observed evidence with `unknown` and `not-applicable` handled explicitly rather than assumed; Google AI features described through ordinary SEO fundamentals, with FAQPage recommendations that separate Google rich-result eligibility from answer-friendly visible FAQ content; a `sources.md` source ledger carrying URL, date, applicable claim, evidence class, and limitations; and, in optimize mode, the recorded baseline, evaluator, finite budget, guards, changes and recommendations, re-audit evidence, discarded iterations, stop reason, and best comparable verified result. The `.hyper/seo-maker/[slug]/` artifacts that must exist are listed in `<artifact_contract>`.

</validation>
