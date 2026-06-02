# Reporting and Code Improvement Explanation

Use this reference when an autoresearch-code run must explain how code changes moved scores, which proof commands passed, and why the final code is safe to keep.

## 1. Language contract

All human-readable outputs are Korean by default:

- experiment `description` values in `results.tsv` and `results.json`
- dashboard labels and dashboard-visible summaries
- `changelog.md`, `code-explanation.md`, `final-report.md`, and files under `details/`
- final user-facing response, handoff notes, and validation notes

Keep machine contracts in their required tokens:

- JSON keys such as `code_explanation`, `experiments`, `status`, `proof_commands`, and `eval_breakdown`
- enum values such as `running`, `complete`, `baseline`, `keep`, `discard`, and `rollback`
- file paths, commands, package names, schema keys, and code identifiers

## 2. Required code-explanation fields

Completed runs must include a dashboard-visible code improvement explanation, either as `results.json.code_explanation` or as `code-explanation.md` loaded through `results.js`.

Recommended `results.json.code_explanation` shape:

```json
{
  "summary_ko": "기준 60.0%에서 최고 85.0%로 +25.0%p 상승했고, 빌드 검증도 통과했습니다.",
  "baseline_score": 60.0,
  "final_score": 85.0,
  "delta": 25.0,
  "best_experiment": 3,
  "most_effective_change_ko": "반복 파일 읽기를 한 번의 배치 처리로 합쳐 빌드 임계값 평가를 개선했습니다.",
  "changed_files": [
    "src/build/collect-files.ts",
    "src/build/cache.ts"
  ],
  "metric_movements": [
    {
      "metric_ko": "빌드 시간",
      "direction": "lower_is_better",
      "before": "42.0s",
      "after": "31.5s",
      "delta_ko": "-10.5s",
      "evidence_ko": "`pnpm build` 5회 반복 평균 기준"
    }
  ],
  "code_changes": [
    {
      "file": "src/build/collect-files.ts",
      "change_ko": "파일별 동기 읽기를 수집 단계의 배치 읽기로 변경했습니다.",
      "why_kept_ko": "build-threshold eval이 3/5에서 5/5로 상승하고 guard test가 통과했습니다.",
      "guard_ko": "`pnpm test` 통과"
    }
  ],
  "proof_commands_ko": [
    "`pnpm build` 통과",
    "`pnpm test` 통과"
  ],
  "guard_results_ko": [
    "회귀 방지 테스트 42개 통과"
  ],
  "remaining_failures_ko": [
    "cold cache 첫 실행은 여전히 목표보다 느립니다."
  ]
}
```

## 3. `code-explanation.md` template

Create this file when code movement needs more detail than `results.json.code_explanation` should carry.

```markdown
# 코드 개선 설명

## 요약

- 기준 점수: [baseline]/[max] ([baseline_percent]%)
- 최종/최고 점수: [final]/[max] ([final_percent]%)
- 변화량: [+/-delta]점 ([+/-delta_percent]%p)
- 최고 실험: Experiment [N]
- 유지된 변이 수: [kept]/[total]

## 어디서 어떻게 올랐나

| 지표/Eval | 이전 | 이후 | 변화 | 근거 |
|---|---|---|---:|---|
| [metric/eval] | [baseline finding] | [final finding] | [+N or -N] | [command/eval/changelog evidence] |

## 어떤 코드를 수정했나

| 파일 | 수정 내용 | 유지한 이유 | Guard/Proof |
|---|---|---|---|
| `[path]` | [change] | [why score improved] | [command/eval/artifact evidence] |

## 롤백·승격 상태

- Promotion state: [hold/promote/rollback]
- Rollback condition: [condition]
- Guard result: [result]

## 남은 실패와 Caveat

- [remaining failure or none]
```

## 4. `final-report.md` template

```markdown
# 최종 보고

## 완료 결과

- [사용자 요청에 맞춘 한 문장 결과]

## 점수 변화

- Baseline: [score]/[max] ([percent]%)
- Final/Best: [score]/[max] ([percent]%)
- Delta: [+/-score] ([+/-percent]%p)
- 가장 효과가 컸던 변경: [change]

## 지표별 변화

| 지표 | 이전 | 이후 | 변화 | 근거 |
|---|---|---|---:|---|
| [metric] | [before] | [after] | [delta] | [proof] |

## 수정 내역

| 파일 | 변경 | 이유 | 검증 |
|---|---|---|---|
| `[path]` | [change] | [reason] | [proof/guard] |

## 검증

- [eval/check command]: [result]
- Dashboard: `[path]`
- Artifacts: `[path]`
- Completion artifact: `[path]`

## 남은 리스크

- [none or caveat]
```

## 5. Changelog entry requirements

Every kept or reworked experiment must explain score and code movement in Korean:

```markdown
## Experiment [N] - [keep]

**점수:** [score]/[max] ([percent]%)  
**변화량:** [+/-delta]  
**수정:** [one-sentence mutation in Korean]  
**어디서 올랐나:** [metric/eval and before -> after]  
**왜 유지했나:** [score improvement + guard pass evidence]  
**수정 파일:** `[path]`, `[path]`  
**Proof command:** `[command]` -> [result]  
**Guard:** [result]  
**롤백 조건:** [condition]  
**남은 실패:** [none or list]
```

Discarded experiments still need a Korean reason, especially when the score stayed flat, complexity rose, or a guard failed.

## 6. Dashboard display requirements

The dashboard must show, in Korean:

- 기준 점수, 최신 통과율, 최고 점수, 현재 실험
- 점수 변화량과 최고 실험
- metric movement: before, after, delta, evidence
- changed files and the reason each kept change is safe
- proof commands, guard results, rollback/promotion state, and remaining failures
- experiment description, guard result, status, and score delta when present
- detailed logs rendered through a safe Markdown subset after raw HTML escaping, not interpreted as arbitrary HTML

Do not hardcode per-run explanation into `dashboard-template.html`; store run-specific content in `results.json.code_explanation`, `code-explanation.md`, `final-report.md`, or `details/` and rerun the renderer. Markdown files should render as formatted Markdown in the dashboard, but raw HTML inside them must remain escaped.

## 7. Final response checklist

Before answering the user, confirm the report includes:

- baseline and final score
- exact score delta and pass-rate delta
- where the score rose by metric/eval/category
- changed files and why each change was kept
- proof commands and guard results
- rollback or promotion state
- dashboard path and artifact path
- verification commands/results
- remaining failures or explicit “없음”
