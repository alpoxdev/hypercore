# Artifact Spec

Use this reference when creating or reviewing the experiment workspace for an autoresearch run.

## Workspace Shape

```text
.hypercore/autoresearch-code/[codebase-name]/
|-- dashboard.html
|-- results.json
|-- results.js        # optional but recommended for file:// browser fallback
|-- results.tsv
|-- changelog.md
`-- baseline.md
```

Create this directory at the repository root, not inside the skill folder.

Canonical generation assets:

- template: `skills/autoresearch-code/assets/dashboard-template.html`
- renderer: `skills/autoresearch-code/scripts/render-dashboard.sh`

## `baseline.md`

Record the unmodified state before experiment `0`.

Suggested sections:

- target scope
- optimization goals
- commands used for baseline measurement
- measured numbers or qualitative observations
- constraints that must not regress
- chosen prompt pack and eval suite

## `results.tsv`

Tab-separated with this header:

```text
experiment	score	max_score	pass_rate	status	description
```

Example:

```text
experiment	score	max_score	pass_rate	status	description
0	12	20	60.0%	baseline	original codebase - no changes
1	15	20	75.0%	keep	batched repeated file reads in build step
2	15	20	75.0%	discard	added memoization with no measurable gain
```

## `results.json`

Recommended shape:

```json
{
  "codebase_name": "my-repo",
  "status": "running",
  "current_experiment": 3,
  "baseline_score": 60.0,
  "best_score": 85.0,
  "experiments": [
    {
      "id": 0,
      "score": 12,
      "max_score": 20,
      "pass_rate": 60.0,
      "status": "baseline",
      "description": "original codebase - no changes"
    }
  ],
  "eval_breakdown": [
    {
      "name": "Build under threshold",
      "pass_count": 3,
      "total": 5
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

Do not hand-roll a different dashboard on each run. Materialize `dashboard.html` from the canonical template and keep layout and loading behavior stable across runs.

Required behavior:

- auto-refresh every 10 seconds
- fetch `results.json`
- render a score progression line chart
- render a colored bar per experiment
- show a table of experiments
- show per-eval pass counts
- show the current run status
- reflect `running`, `idle`, and `complete` states from `results.json`
- render correctly when opened directly from the local filesystem in Chrome or another browser using `file://`

Lifecycle rules:

- render `dashboard.html` from `skills/autoresearch-code/assets/dashboard-template.html`
- use `skills/autoresearch-code/scripts/render-dashboard.sh <artifact-dir>` as the default renderer
- create `dashboard.html`, then open it immediately when the runtime can safely open local HTML
- update `results.tsv` and `results.json` after every experiment
- set `results.json.status` to `running` while experiments are executing
- set `results.json.status` to `complete` when the loop finishes
- if the dashboard is opened via `file://`, do not rely only on `fetch("./results.json")`
- provide a file-backed fallback such as `results.js` that assigns the same data to a browser global
- keep `results.js` synchronized with `results.json` whenever the fallback file exists

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

Example outcome summary for a build-speed run:

- Baseline: `10/20 (50%)`
- Experiment 1 keep: batch repeated file-system work and improve build threshold pass rate
- Experiment 2 discard: extra caching adds complexity with no measurable gain
- Experiment 3 keep: remove dead plugin and reduce bundle size
- Experiment 4 keep: simplify a flaky test helper and improve reliability

Use the changelog to preserve this reasoning so later agents can continue without redoing the same dead ends.
