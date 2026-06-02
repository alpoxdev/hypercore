# 보고와 코드 개선 설명

`autoresearch-code` 실행에서 코드 변경이 점수와 지표를 어떻게 움직였는지, 어떤 proof command가 통과했는지, 최종 코드를 왜 유지해도 되는지 설명할 때 이 레퍼런스를 사용한다.

## 1. 언어 계약

사람이 읽는 산출물은 기본적으로 한국어로 작성한다:

- `results.tsv`, `results.json`의 실험 `description`
- 대시보드 라벨과 대시보드에 보이는 요약
- `changelog.md`, `code-explanation.md`, `final-report.md`, `details/` 아래 파일
- 최종 사용자 응답, 인수인계 메모, 검증 메모

기계 계약은 필요한 토큰을 유지한다:

- `code_explanation`, `experiments`, `status`, `proof_commands`, `eval_breakdown` 같은 JSON 키
- `running`, `complete`, `baseline`, `keep`, `discard`, `rollback` 같은 enum 값
- 파일 경로, 명령어, 패키지명, 스키마 키, 코드 식별자

## 2. 필수 코드 설명 필드

완료된 실행은 대시보드에서 볼 수 있는 코드 개선 설명을 포함해야 한다. 방식은 `results.json.code_explanation` 또는 `results.js`가 로드하는 `code-explanation.md` 중 하나다.

권장 `results.json.code_explanation` 형태:

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

## 3. `code-explanation.md` 템플릿

`results.json.code_explanation`에 담기에는 코드 이동 설명이 긴 경우 이 파일을 만든다.

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

## 4. `final-report.md` 템플릿

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

## 5. Changelog 항목 요구사항

유지되거나 재작업된 실험은 점수와 코드 이동을 한국어로 설명해야 한다:

```markdown
## Experiment [N] - [keep]

**점수:** [score]/[max] ([percent]%)  
**변화량:** [+/-delta]  
**수정:** [한국어 한 문장 변이 요약]  
**어디서 올랐나:** [metric/eval and before -> after]  
**왜 유지했나:** [점수 상승 + guard 통과 근거]  
**수정 파일:** `[path]`, `[path]`  
**Proof command:** `[command]` -> [result]  
**Guard:** [result]  
**롤백 조건:** [condition]  
**남은 실패:** [none or list]
```

폐기된 실험도 점수 정체, 복잡도 증가, guard 실패 등 한국어 사유를 남긴다.

## 6. 대시보드 표시 요구사항

대시보드는 한국어로 다음을 보여야 한다:

- 기준 점수, 최신 통과율, 최고 점수, 현재 실험
- 점수 변화량과 최고 실험
- 지표 이동: 이전, 이후, 변화량, 근거
- 변경 파일과 각 유지 변경이 안전한 이유
- proof command, guard 결과, 롤백/승격 상태, 남은 실패
- 실험 설명, guard 결과, 상태, 가능한 경우 score delta
- 원시 HTML을 먼저 이스케이프한 뒤 안전한 Markdown 부분집합으로 렌더한 상세 로그

실행별 설명을 `dashboard-template.html`에 하드코딩하지 않는다. 실행별 내용은 `results.json.code_explanation`, `code-explanation.md`, `final-report.md`, `details/`에 저장한 뒤 렌더러를 다시 실행한다. Markdown 파일은 대시보드에서 Markdown처럼 보이되, 그 안의 원시 HTML은 HTML로 해석되면 안 된다.

## 7. 최종 응답 체크리스트

사용자에게 답하기 전에 보고에 다음이 포함됐는지 확인한다:

- 기준 점수와 최종 점수
- 정확한 점수 변화량과 통과율 변화량
- 어떤 지표/eval/category에서 점수가 올랐는지
- 수정 파일과 각 변경을 유지한 이유
- proof command와 guard 결과
- 롤백 또는 승격 상태
- 대시보드 경로와 아티팩트 경로
- 검증 명령과 결과
- 남은 실패 또는 명시적 “없음”
