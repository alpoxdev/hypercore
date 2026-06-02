# Reporting and Score Explanation

Use this reference when an autoresearch-skill run must explain its score movement, kept changes, dashboard content, and final handoff to a human reader.

## 1. Language contract

All human-readable outputs are Korean by default:

- experiment `description` values in `results.tsv` and `results.json`
- dashboard labels and dashboard-visible summaries
- `changelog.md`, `score-explanation.md`, `final-report.md`, and files under `details/`
- final user-facing response, handoff notes, and validation notes

Keep machine contracts in their required tokens:

- JSON keys such as `score_explanation`, `experiments`, `status`, and `eval_breakdown`
- enum values such as `running`, `complete`, `baseline`, `keep`, and `discard`
- file paths, commands, package names, schema keys, and code identifiers

## 2. Required score-explanation fields

Completed runs must include a dashboard-visible score explanation, either as `results.json.score_explanation` or as `score-explanation.md` loaded through `results.js`.

Recommended `results.json.score_explanation` shape:

```json
{
  "summary_ko": "기준 72.2%에서 최고 88.9%로 +16.7%p 상승했습니다.",
  "baseline_score": 72.2,
  "final_score": 88.9,
  "delta": 16.7,
  "best_experiment": 3,
  "most_effective_change_ko": "트리거 경계 예시를 한국어 요청 기준으로 보강했습니다.",
  "changed_files": [
    "skills/example-skill/SKILL.md",
    "skills/example-skill/rules/validation.md"
  ],
  "improvements": [
    {
      "area_ko": "트리거 경계",
      "score_delta": 2,
      "before_ko": "단발성 polish 요청과 반복 실험 요청이 분리되지 않았습니다.",
      "after_ko": "긍정/부정/경계 예시가 분리되어 오작동 가능성이 줄었습니다.",
      "evidence_ko": "EVAL 1이 4/6에서 6/6으로 상승했습니다.",
      "files": ["skills/example-skill/SKILL.md"]
    }
  ],
  "remaining_failures_ko": [
    "외부 provider claim 검증이 필요한 케이스는 이번 실행 범위 밖이었습니다."
  ]
}
```

## 3. `score-explanation.md` template

Create this file when the score movement needs more detail than `results.json.score_explanation` should carry.

```markdown
# 점수 상승 설명

## 요약

- 기준 점수: [baseline]/[max] ([baseline_percent]%)
- 최종/최고 점수: [final]/[max] ([final_percent]%)
- 변화량: [+/-delta]점 ([+/-delta_percent]%p)
- 최고 실험: Experiment [N]
- 유지된 변이 수: [kept]/[total]

## 어디서 점수가 올랐나

| 영역 | 이전 | 이후 | 점수 변화 | 근거 |
|---|---|---|---:|---|
| [eval/category] | [baseline finding] | [final finding] | [+N] | [eval output / changelog row] |

## 무엇을 수정했나

| 파일 | 수정 내용 | 유지한 이유 | 검증 |
|---|---|---|---|
| `[path]` | [change] | [why score improved] | [command/eval/artifact evidence] |

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

## 수정 내역

| 파일 | 변경 | 이유 |
|---|---|---|
| `[path]` | [change] | [reason] |

## 검증

- [eval/check command]: [result]
- Dashboard: `[path]`
- Artifacts: `[path]`

## 남은 리스크

- [none or caveat]
```

## 5. Changelog entry requirements

Every kept or reworked experiment must explain the score movement in Korean:

```markdown
## Experiment [N] - [keep]

**점수:** [score]/[max] ([percent]%)  
**변화량:** [+/-delta]  
**수정:** [one-sentence mutation in Korean]  
**어디서 올랐나:** [eval/category and before -> after]  
**왜 유지했나:** [score improvement + guard pass evidence]  
**수정 파일:** `[path]`, `[path]`  
**남은 실패:** [none or list]
```

Discarded experiments still need a Korean reason, especially when the score stayed flat, complexity rose, or a guard failed.

## 6. Dashboard display requirements

The dashboard must show, in Korean:

- 기준 점수, 최신 통과율, 최고 점수, 현재 실험
- 점수 변화량과 최고 실험
- experiment description, guard result, status, and score delta
- score explanation summary when available
- detailed logs rendered through the safe Markdown subset after raw HTML escaping, not interpreted as arbitrary HTML

Do not hardcode per-run explanation into `dashboard-template.html`; store run-specific content in `results.json.score_explanation`, `score-explanation.md`, `final-report.md`, or `details/` and rerun the renderer. Markdown files should render as formatted Markdown in the dashboard, but raw HTML inside them must remain escaped.

## 7. Final response checklist

Before answering the user, confirm the report includes:

- baseline and final score
- exact score delta and pass-rate delta
- where the score rose by eval/category
- changed files and why each change was kept
- dashboard path and artifact path
- verification commands/results
- remaining failures or explicit “없음”
