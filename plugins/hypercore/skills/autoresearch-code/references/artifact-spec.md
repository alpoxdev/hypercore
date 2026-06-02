# Artifact Spec

Use this reference when creating or reviewing the experiment workspace for an autoresearch run.

## Workspace Shape

```text
.hypercore/autoresearch-code/[codebase-name]/
|-- dashboard.html
|-- results.json
|-- results.js        # Optional but recommended file:// browser fallback
|-- results.tsv
|-- changelog.md
`-- baseline.md
```

Create this directory at the repository root, not inside the skill folder.

In `$autoresearch` runs, this `.hypercore` directory is the domain-specific result log, and the final completion gate is handled by a separate `.omx/specs/autoresearch-[codebase-name]/result.json` completion artifact. Record that `.omx/specs/.../result.json` path in `completion_artifact_path`, and record this file's `results.json` in `output_artifact_path`.

Canonical generated assets:

- template: `skills/autoresearch-code/assets/dashboard-template.html`
- renderer: `skills/autoresearch-code/scripts/render-dashboard.sh`
- renderer runtime: `python3` standard JSON library

## `baseline.md`

Record the unmodified state before experiment `0`.

Recommended sections:

- scope and owning package or module
- selected pack name, pack type, and pack version
- target scope
- optimization goal
- commands used for baseline measurement
- proof command hash or exact command list
- measured numbers or qualitative observations
- environment or runner information
- constraints that must not regress
- rollback conditions
- selected prompt pack and eval set

## `results.tsv`

Tab-separated file with this header:

```text
experiment	score	max_score	pass_rate	status	description
```

Example:

```text
experiment	score	max_score	pass_rate	status	description
0	12	20	60.0%	baseline	Original codebase - no changes
1	15	20	75.0%	keep	Batch repeated file reads during the build step
2	15	20	75.0%	discard	Add memoization with no measurable gain
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
  "scope": {
    "kind": "package",
    "label": "apps/web"
  },
  "eval_pack": {
    "name": "web",
    "type": "trace-backed",
    "version": "2026-03-24"
  },
  "proof_commands": {
    "hash": "sha256:...",
    "commands": ["pnpm --filter web build", "pnpm --filter web test"]
  },
  "environment": {
    "os": "macos",
    "runtime": "node 22"
  },
  "experiments": [
    {
      "id": 0,
      "score": 12,
      "max_score": 20,
      "pass_rate": 60.0,
      "status": "baseline",
      "promotion_state": "hold",
      "description": "Original codebase - no changes",
      "dimensions": {
        "quality": 3,
        "regression": 4,
        "resource": 2,
        "safety": 3
      }
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

Promotion status values:

- `hold`
- `promote`
- `rollback`

## `dashboard.html`

Generate one self-contained HTML file with inline CSS and JavaScript and no external CDN.

Do not hand-build an arbitrary different dashboard for each run. Materialize `dashboard.html` from the canonical template, and keep the layout and loading behavior stable.

Required behavior:

- Auto-refresh every 10 seconds
- Read `results.json`
- Render score trends as a line chart with the built-in Canvas API
- Render color bars per experiment
- Show scope, eval pack, environment, and current promotion state
- Show the experiment table
- Show per-experiment dimension scores when present
- Show pass counts per eval
- Show current run status
- Reflect the `running`, `idle`, and `complete` states from `results.json`
- Render correctly when opened directly through `file://` in browsers such as Chrome

Lifecycle rules:

- Render `dashboard.html` from `skills/autoresearch-code/assets/dashboard-template.html`
- Use `skills/autoresearch-code/scripts/render-dashboard.sh <artifact-dir>` as the default renderer
- After creating `dashboard.html`, open it immediately when the runtime makes that safe
- Update `results.tsv` and `results.json` after every experiment
- Keep `scope`, `eval_pack`, `proof_commands`, `environment`, and experiment `dimensions` synchronized with the current run
- Keep `results.json.status` as `running` while an experiment is running
- Set `results.json.status` to `complete` when the loop ends
- When opening the dashboard through `file://`, do not rely only on `fetch("./results.json")`
- Provide a file-based fallback such as `results.js` that assigns the same data to a browser global
- When the fallback file exists, always keep `results.js` synchronized with `results.json`

## `changelog.md`

Add one entry for each experiment:

```markdown
## Experiment [N] - [keep/discard]

**Score:** [X]/[max] ([percent]%)
**Change:** [one-line mutation summary]
**Reasoning:** [why this change was expected to help]
**Result:** [which evals improved, stayed stable, or worsened]
**Failing outputs:** [record remaining failures if any]
```

## Worked Example

Example build-speed optimization summary:

- Baseline: `10/20 (50%)`
- Experiment 1 keep: batched repeated filesystem work and improved the build-threshold pass rate
- Experiment 2 discard: extra caching only increased complexity and produced no measurable gain
- Experiment 3 keep: removed a dead plugin and reduced bundle size
- Experiment 4 keep: simplified a flaky test helper and improved reliability

Leave reasoning in the changelog so later agents do not repeat the same dead ends.
