# Artifact Spec

Use this reference when creating or reviewing the experiment workspace for an autoresearch run.

## Workspace Shape

```text
.hypercore/autoresearch-[skill-name]/
|-- dashboard.html
|-- results.json
|-- results.tsv
|-- changelog.md
`-- SKILL.md.baseline
```

Create this directory at the repository root, not inside the skill folder.

## `results.tsv`

Tab-separated with this header:

```text
experiment	score	max_score	pass_rate	status	description
```

Example:

```text
experiment	score	max_score	pass_rate	status	description
0	14	20	70.0%	baseline	original skill - no changes
1	16	20	80.0%	keep	added explicit anti-pattern for numbered steps
2	16	20	80.0%	discard	moved layout guidance earlier with no measurable gain
```

## `results.json`

Recommended shape:

```json
{
  "skill_name": "diagram-generator",
  "status": "running",
  "current_experiment": 3,
  "baseline_score": 70.0,
  "best_score": 90.0,
  "experiments": [
    {
      "id": 0,
      "score": 14,
      "max_score": 20,
      "pass_rate": 70.0,
      "status": "baseline",
      "description": "original skill - no changes"
    }
  ],
  "eval_breakdown": [
    {
      "name": "Text legibility",
      "pass_count": 8,
      "total": 10
    }
  ]
}
```

Status values:

- `running`
- `idle`
- `complete`

## `dashboard.html`

Generate a single self-contained HTML file with inline CSS and JavaScript.

Required behavior:

- auto-refresh every 10 seconds
- fetch `results.json`
- render a score progression line chart
- render a colored bar per experiment
- show a table of experiments
- show per-eval pass counts
- show the current run status

Preferred styling:

- white or near-white background
- soft accent colors
- clean sans-serif typography
- clear status colors for baseline, keep, and discard

Chart guidance:

- use Chart.js from CDN
- X axis: experiment number
- Y axis: pass rate percent

## `changelog.md`

Append one entry per experiment:

```markdown
## Experiment [N] - [keep/discard]

**Score:** [X]/[max] ([percent]%)
**Change:** [One-sentence mutation summary]
**Reasoning:** [Why this change was expected to help]
**Result:** [Which evals improved, held, or declined]
**Failing outputs:** [What still failed, if anything]
```

## Worked Example

Example outcome summary for a diagram skill:

- Baseline: `32/40 (80%)`
- Experiment 1 keep: explicit anti-numbering rule improves numbering failures
- Experiment 2 discard: font-size requirement adds complexity with weak gain
- Experiment 3 keep: concrete pastel palette improves color compliance
- Experiment 4 discard: redundant anti-color rule has no effect
- Experiment 5 keep: worked example improves consistency and reaches `97.5%`

Use the changelog to preserve this reasoning so later agents can continue without redoing the same dead ends.
