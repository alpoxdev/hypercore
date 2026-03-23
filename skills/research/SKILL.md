---
name: research
description: Research a topic and deliver a source-backed markdown report when the user needs fact-finding, comparisons, market or trend analysis, or evidence-backed recommendations across live web, official docs, GitHub, and local repository sources.
compatibility: Works best with live search or fetch tools, official-doc access such as Context7 when available, GitHub or repo search for code evidence, and local file search for project-only topics.
---

@rules/research-workflow.md
@rules/validation.md

# Research Skill

> Investigate a topic, verify the evidence, and save a reusable report.

<purpose>

- Turn a research question into a saved markdown brief under `.hypercore/research/`.
- Prefer evidence gathering and synthesis over freeform writing.
- Keep the core skill lean and load support files only when they change the search or reporting plan.

</purpose>

<routing_rule>

Use `research` when the main job is fact-finding, comparison, trend analysis, or an evidence-backed recommendation.

Do not use `research` when:

- the user only wants writing, rewriting, or presentation polish without new evidence gathering
- the user only needs a narrow library or API lookup with no synthesis; use direct official-doc lookup instead
- the main job is code modification, debugging, or implementation rather than gathering evidence

</routing_rule>

<activation_examples>

Positive requests:

- "Research AI agent framework tradeoffs for me."
- "Compare WebSocket and SSE for realtime notifications."
- "Look up the latest Korea SaaS market trends and summarize them."

Negative requests:

- "Rewrite this report so it sounds more executive."
- "Implement the migration after you read the docs."

Boundary requests:

- "`/research react useEffectEvent`"
  Use `research` only if the user wants synthesis across multiple sources; otherwise do a direct official-doc lookup.
- "`/research`"
  Ask immediately for the missing topic before doing any collection work.

</activation_examples>

<depth_modes>

| Mode | Query budget | Source floor | Second pass | Deliverable shape |
|------|------|------|------|------|
| `--quick` | 1-3 distinct searches | 3+ reviewed, 2+ cited | No | short answer or brief memo |
| default | 4-6 distinct searches | 6+ reviewed, 4+ cited | Only if gaps remain | standard report |
| `--deep` | 7-10 distinct searches | 10+ reviewed, 6+ cited | Yes | decision memo with caveats |

</depth_modes>

<support_file_read_order>

Read in this order:

1. This core `SKILL.md` to confirm that the job is research and to pick the depth.
2. [instructions/sourcing/reliable-search.md](/Users/alpox/Desktop/dev/kood/hypercore/instructions/sourcing/reliable-search.md) before running multiple live searches so query dedupe, recency handling, and stop conditions stay explicit.
3. [references/channel-selection.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/research/references/channel-selection.md) when choosing between local repo search, official docs, GitHub evidence, and live web sources.
4. [references/report-template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/research/references/report-template.md) when drafting or saving the report.
5. [rules/validation.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/research/rules/validation.md) before declaring the research complete.

</support_file_read_order>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Confirm topic, depth, scope, and whether the request is date-sensitive | Research plan |
| 1 | Choose channels and search questions | Query plan |
| 2 | Collect evidence in priority order | Source set |
| 3 | Synthesize a conclusion-first report with citations | Draft report |
| 4 | Save under `.hypercore/research/` and run validation | Final report + concise user summary |

### Phase rules

- If the topic is missing, ask for it before any search.
- If the request is broad, high-stakes, or `--deep`, use sequential thinking to define 3-5 research questions, scope, date constraints, and stop conditions before searching.
- If the request is narrow and low-risk, state a short plan and start collecting without turning the skill into a planning exercise.
- Prefer repo-local search for internal project questions, official docs for package or API questions, GitHub evidence for release or implementation history, and live web sources for market, news, or trend work.
- When the user asks for "latest", "current", "today", or similar wording, verify with live sources and write exact dates in the report instead of relative dates.
- Save before closing. Do not stop at a chat answer if the skill was invoked to produce a report.

</workflow>

<required>

- Keep search queries distinct and stop when the evidence is sufficient; do not repeat the same query across channels.
- Prefer primary or official sources first for technical and product claims.
- Attach a link to every non-obvious claim in the final report.
- Use comparison tables when judging alternatives.
- Record unresolved conflicts or missing evidence explicitly instead of smoothing them over.

</required>

<forbidden>

- Hardcoding a specific year into evergreen search or reasoning rules
- Claims without citations
- Comparison conclusions without a visible evidence basis
- Placeholder tool or role names when the local runtime already offers a clearer direct path

</forbidden>
