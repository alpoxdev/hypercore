# Artifact Spec

Use this reference when creating or reviewing the experiment workspace for an autoresearch-code run.

## Workspace Shape

```text
.hypercore/autoresearch-code/[codebase-name]/
|-- dashboard.html
|-- results.json
|-- results.js        # Required file:// browser fallback after rendering
|-- results.tsv
|-- changelog.md
|-- baseline.md
|-- code-explanation.md   # Required for completed runs unless results.json.code_explanation exists
|-- final-report.md       # Required for completed runs
|-- run-contract.md       # Required when assumptions/defaults were inferred
|-- trace-summary.md      # Required when trace-backed evals or runtime traces were used
|-- source-ledger.md      # Required when external/current claims influenced code choices
`-- details/             # Optional long logs, proof snippets, JSON/TSV/log diagnostics
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
experiment\tscore\tmax_score\tpass_rate\tstatus\tdescription
```

Example:

```text
experiment\tscore\tmax_score\tpass_rate\tstatus\tdescription
0\t12\t20\t60.0%\tbaseline\t원본 코드베이스 - 수정 없음
1\t15\t20\t75.0%\tkeep\t빌드 단계의 반복 파일 읽기를 배치 처리
2\t15\t20\t75.0%\tdiscard\t측정 가능한 이득 없는 메모이제이션 추가
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
      "description": "원본 코드베이스 - 수정 없음",
      "delta": 0,
      "guard": "not-run",
      "guard_metric": "baseline",
      "changed_files": [],
      "proof_command": "pnpm --filter web build",
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
      "name": "임계값 이하 빌드",
      "pass_count": 3,
      "total": 5
    }
  ],
  "code_explanation": {
    "summary_ko": "기준 60.0%에서 최고 85.0%로 +25.0%p 상승했습니다.",
    "baseline_score": 60.0,
    "final_score": 85.0,
    "delta": 25.0,
    "best_experiment": 3,
    "most_effective_change_ko": "반복 파일 읽기를 배치 처리했습니다.",
    "changed_files": ["src/build/collect-files.ts"],
    "metric_movements": [
      {
        "metric_ko": "빌드 시간",
        "direction": "lower_is_better",
        "before": "42.0s",
        "after": "31.5s",
        "delta_ko": "-10.5s",
        "evidence_ko": "`pnpm build` 5회 평균"
      }
    ],
    "code_changes": [
      {
        "file": "src/build/collect-files.ts",
        "change_ko": "동기 파일 읽기를 배치 처리로 바꿨습니다.",
        "why_kept_ko": "빌드 임계값 eval과 guard가 모두 통과했습니다.",
        "guard_ko": "`pnpm test` 통과"
      }
    ],
    "proof_commands_ko": ["`pnpm build` 통과"],
    "guard_results_ko": ["`pnpm test` 통과"],
    "remaining_failures_ko": ["없음"]
  }
}
```

Top-level status values:

- `running`
- `idle`
- `complete`

Experiment status values:

- `baseline`
- `keep`
- `keep-reworked`
- `discard`
- `crash`
- `no-op`
- `hook-blocked`
- `metric-error`
- `reset`

Promotion status values:

- `hold`
- `promote`
- `rollback`

Completed runs must include `results.json.code_explanation` or a `code-explanation.md` file so the dashboard can explain score movement without relying on the final chat response.

## Detail Files and `results.js`

The renderer writes `results.js` with two browser globals:

- `window.__AUTORESEARCH_CODE_RESULTS__`: serialized `results.json`
- `window.__AUTORESEARCH_CODE_DETAILS__`: serialized detail files

The renderer must include known detail files when present:

- `changelog.md`
- `code-explanation.md`
- `final-report.md`
- `baseline.md`
- `run-contract.md`
- `source-ledger.md`
- `trace-summary.md`

It must also include readable files below `details/` with suffixes `.md`, `.txt`, `.json`, `.tsv`, or `.log`.

## `dashboard.html`

Generate one self-contained HTML file with inline CSS and JavaScript and no external CDN.

Do not hand-build an arbitrary different dashboard for each run. Materialize `dashboard.html` from the canonical template, and keep the layout and loading behavior stable.

Required behavior:

- Auto-refresh every 10 seconds
- Read `results.json` when served over HTTP and use `results.js` for `file://`
- Render score trends as a line chart with the built-in Canvas API
- Show 기준 점수, 최신 통과율, 최고 점수, 현재 실험
- Show score delta, best experiment, metric movements, changed files, proof commands, guard results, remaining failures, and promotion state
- Show scope, eval pack, environment, and current promotion state
- Show the experiment table with escaped dynamic values
- Show per-experiment dimension scores when present
- Show pass counts per eval
- Show current run status
- Reflect the `running`, `idle`, and `complete` states from `results.json`
- Render Markdown detail logs through a safe subset after raw HTML escaping
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
- Keep `results.js` synchronized with `results.json` and detail files

## `changelog.md`

Add one Korean entry for each experiment:

```markdown
## Experiment [N] - [keep/discard/reset]

**점수:** [X]/[max] ([percent]%)  
**변화량:** [+/-delta]  
**수정:** [변이 한 줄 요약]  
**어디서 올랐나:** [metric/eval before -> after]  
**왜 유지/폐기했나:** [score, complexity, guard evidence]  
**수정 파일:** `[path]`, `[path]`  
**Proof command:** `[command]` -> [result]  
**Guard:** [result]  
**롤백 조건:** [condition]  
**남은 실패:** [record remaining failures if any]
```

## `code-explanation.md` and `final-report.md`

Use [reporting-and-code-improvement.md](reporting-and-code-improvement.md) for templates. These files must be Korean unless the user explicitly requests another language.

## Worked Example

Example build-speed optimization summary:

- Baseline: `10/20 (50%)`
- Experiment 1 keep: repeated filesystem work was batched and build-threshold pass rate improved
- Experiment 2 discard: extra caching only increased complexity and produced no measurable gain
- Experiment 3 keep: dead plugin removed and bundle size decreased
- Experiment 4 keep: flaky test helper simplified and reliability improved

Leave reasoning in the changelog so later agents do not repeat the same dead ends.
