# SEO Audit Artifact Spec

Use this reference when creating or reviewing the result workspace for an SEO audit run.

## Workspace Shape

```text
.hypercore/seo-maker/[slug]/
├── dashboard.html       # browser-openable dashboard
├── results.json         # structured audit results
├── results.js           # fallback for file:// browsers
├── report.md            # Markdown report (existing)
├── sources.md           # source log (existing)
└── flow.json            # complex path only (existing)
```

Create this directory at the repository root, not inside the skill folder.

Canonical generated assets:

- template: `skills/seo-maker/assets/dashboard-template.html`
- renderer: `skills/seo-maker/scripts/render-dashboard.sh`

## `results.json`

```json
{
  "project_name": "my-website",
  "date": "2026-03-27",
  "scope": "Full site audit",
  "status": "complete",
  "overall_grade": "B",
  "categories": [
    { "name": "Technical SEO", "score": 85 },
    { "name": "On-Page SEO", "score": 72 },
    { "name": "Content SEO", "score": 68 },
    { "name": "Core Web Vitals", "score": 90 },
    { "name": "Structured Data", "score": 88 },
    { "name": "AEO Readiness", "score": 45 },
    { "name": "GEO Readiness", "score": 38 }
  ],
  "measurement_methods": {
    "search_console": { "status": "unavailable", "confidence_impact": "medium" },
    "pagespeed_insights": { "status": "lab-only", "tool": "Lighthouse", "confidence": "medium" },
    "rich_results_test": { "status": "not-run", "fallback_method": "schema_static_scan", "confidence": "medium" },
    "ai_citation_probe": { "status": "not-run", "reason": "no engine access" },
    "crawler_policy_scan": { "status": "completed", "method": "robots/meta/header scan", "confidence": "high" }
  },
  "platform_policy": {
    "oai_searchbot": { "status": "allowed", "purpose": "ChatGPT Search inclusion", "evidence_grade": "official", "confidence": "high", "source_tier": "official-doc" },
    "gptbot": { "status": "blocked", "purpose": "OpenAI model training", "evidence_grade": "official", "confidence": "high", "source_tier": "official-doc" },
    "llms_txt": { "status": "missing", "severity": "info", "evidence_grade": "heuristic", "confidence": "medium", "source_tier": "research-backed-heuristic" }
  },
  "query_fanout": {
    "status": "not-run",
    "queries": [],
    "missing_topics": []
  },
  "citation_probe": {
    "status": "not-run",
    "engines": [],
    "sample_size": 0,
    "confidence": "low"
  },
  "findings": [
    {
      "id": "T1",
      "severity": "critical",
      "category": "Technical SEO",
      "finding": "robots.txt blocks /blog/ path",
      "location": "/robots.txt:3",
      "evidence_grade": "lab",
      "confidence": "high",
      "measurement_method": "static robots.txt scan",
      "source_tier": "observed-file",
      "recommendation": "Remove Disallow: /blog/ line"
    },
    {
      "id": "A1",
      "severity": "warning",
      "category": "AEO Readiness",
      "finding": "No direct answer in first paragraph",
      "location": "/blog/what-is-seo.html",
      "evidence_grade": "heuristic",
      "confidence": "medium",
      "measurement_method": "answer block detector",
      "source_tier": "research-backed-heuristic",
      "recommendation": "Add a concise visible answer block near the top of the section"
    }
  ],
  "quick_wins": [
    {
      "action": "Add meta descriptions to 12 pages missing them",
      "impact": "High",
      "effort": "Low"
    }
  ],
  "score_history": [
    {
      "iteration": 0,
      "score": 66,
      "grade": "C",
      "critical_count": 1,
      "decision": "baseline",
      "evidence": "Initial audit before optimization changes"
    },
    {
      "iteration": 1,
      "score": 78,
      "grade": "B",
      "critical_count": 0,
      "decision": "kept",
      "changed": "Removed robots.txt block for /blog/",
      "evidence": "Re-audit confirmed indexability restored"
    }
  ],
  "best_run": {
    "iteration": 1,
    "score": 78,
    "grade": "B",
    "reason": "Highest kept score with zero critical findings"
  },
  "validator": {
    "status": "passed",
    "summary": "Target passed or plateau condition verified"
  },
  "actions": [
    {
      "priority": 1,
      "category": "Technical SEO",
      "action": "Fix robots.txt blocking blog content",
      "impact": "High",
      "effort": "Low"
    },
    {
      "priority": 2,
      "category": "GEO Readiness",
      "action": "Add statistics and citations to top 10 pages",
      "impact": "High",
      "effort": "Medium"
    }
  ]
}
```

### Evidence and confidence fields

Every non-obvious finding should include:

- `evidence_grade`: `official`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`.
- `confidence`: `high`, `medium`, or `low`.
- `measurement_method`: the scan, tool, probe, or source used to produce the finding.
- `source_tier`: `official-doc`, `observed-file`, `field-data`, `tool-output`, `synthetic-probe`, or `research-backed-heuristic`.

Use high confidence for official docs, direct file/header observations, or field data. Use lower confidence for local-only static scans, lab-only performance, synthetic AI prompt probes, and heuristic AEO/GEO advice.

### Measurement and platform fields

- `measurement_methods` records which evidence channels were available and how they affected confidence.
- `platform_policy` records search/AI crawler and snippet controls by platform or bot. Separate `OAI-SearchBot` search inclusion from `GPTBot` training policy.
- `query_fanout` records generated subqueries and missing topical coverage.
- `citation_probe` records AI engine, prompt set, cited URLs, brand mentions, sample size, date, and confidence when run. If not run, store `status: "not-run"` and the reason.

### Optimize mode fields

When `mode` is `optimize` or the user asked for highest/max/perfect score, add these fields to `results.json`:

- `target_score` — numeric goal, default `95` unless the user specified another target.
- `score_history[]` — ordered iteration log. Each item includes `iteration`, `score`, `grade`, `critical_count`, `decision`, `changed`, and `evidence`.
- `best_run` — the highest-scoring kept iteration. Required before completion.
- `validator` — artifact-gated completion evidence, such as `{ "status": "passed" }` or an architect review verdict.
- `plateau` — optional object with `consecutive_iterations` and `reason` when completion is due to no further score gains.

Rules:

1. `score_history[0]` is always the baseline before changes.
2. Later scores are comparable only when the evaluator stayed stable. If scoring changes, record a reset event.
3. `best_run` must not point to a discarded iteration.
4. If code changes were made, validator evidence should include the relevant test/build/lint command output summary.

### Status values

- `running` — audit in progress
- `idle` — waiting
- `complete` — audit complete

### Default category list

Seven categories, each scored from 0-100. Report `measurement_confidence` separately from the score:

1. Technical SEO
2. On-Page SEO
3. Content SEO
4. Core Web Vitals
5. Structured Data
6. AEO Readiness
7. GEO Readiness

### Finding ID rules

- `T1`, `T2`... — Technical SEO
- `O1`, `O2`... — On-Page SEO
- `C1`, `C2`... — Content SEO
- `W1`, `W2`... — Core Web Vitals
- `S1`, `S2`... — Structured Data
- `A1`, `A2`... — AEO Readiness
- `G1`, `G2`... — GEO Readiness

### Severity values

- `critical` — blocks indexing or severely harms ranking
- `warning` — degrades ranking or UX
- `info` — improvement opportunity

## `results.js`

Fallback for browsers where `fetch` does not work when opened via `file://`:

```javascript
window.__SEO_RESULTS__ = { /* same content as results.json */ };
```

Always keep it synchronized with `results.json`.

## `dashboard.html`

Copy it from `skills/seo-maker/assets/dashboard-template.html`.

Required behavior:

- Auto-refresh every 10 seconds
- Read `results.json` (fall back to `results.js` for `file://`)
- Radar chart for seven category scores
- Severity distribution donut chart
- Category score bars
- Findings table with severity color coding
- Quick Wins table
- Prioritized Actions table
- Overall Grade display (A/B/C/D/F)

## `report.md`

Generate it from the existing `assets/report.template.md`. It is a Markdown rendering of the data in `results.json`.

## Lifecycle Rules

1. Create `.hypercore/seo-maker/[slug]/` when the audit starts.
2. Set `status` in `results.json` to `running`.
3. Add findings to `results.json` as each phase completes.
4. After all phases finish, set `status` to `complete` and calculate `overall_grade`.
4-1. In Optimize mode, populate `score_history`, `best_run`, and `validator`, then record the evidence for the highest score or plateau.
5. Run `render-dashboard.sh` to generate `dashboard.html` and `results.js`.
6. Write `report.md` and `sources.md` as well.
7. Open `dashboard.html` in a browser if the runtime is safe.

### Grade Calculation

Average category score:

| Average | Grade |
|---------|-------|
| >= 90 | A |
| >= 75 | B |
| >= 60 | C |
| >= 40 | D |
| < 40 | F |

### Render Order

```bash
skills/seo-maker/scripts/render-dashboard.sh .hypercore/seo-maker/my-site
open .hypercore/seo-maker/my-site/dashboard.html
```
