# 보고 및 점수 상승 설명

오토리서치 스킬 실행에서 점수 변화, 유지된 변경, 대시보드 내용, 최종 전달 내용을 사람이 읽을 수 있게 설명해야 할 때 이 레퍼런스를 사용한다.

## 1. 언어 계약

사람이 읽는 산출물은 기본적으로 모두 한국어다:

- `results.tsv`와 `results.json`의 실험 `description` 값
- 대시보드 라벨과 대시보드에 보이는 요약
- `changelog.md`, `score-explanation.md`, `final-report.md`, `details/` 아래 파일
- 최종 사용자 응답, 인수인계 메모, 검증 메모

기계 계약은 필요한 토큰을 유지한다:

- `score_explanation`, `experiments`, `status`, `eval_breakdown` 같은 JSON key
- `running`, `complete`, `baseline`, `keep`, `discard` 같은 enum 값
- 파일 경로, 명령어, 패키지명, 스키마 key, 코드 식별자

## 2. 필수 점수 설명 필드

완료된 실행에는 대시보드에서 볼 수 있는 점수 설명이 있어야 한다. 위치는 `results.json.score_explanation` 또는 `results.js`로 로드되는 `score-explanation.md`다.

권장 `results.json.score_explanation` 형태:

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

## 3. `score-explanation.md` 템플릿

점수 변화 설명이 `results.json.score_explanation`에 넣기에는 길면 이 파일을 만든다.

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

## 5. Changelog 항목 요구사항

유지 또는 재작업 유지된 모든 실험은 점수 변화 이유를 한국어로 설명해야 한다:

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

폐기된 실험도 점수가 그대로였는지, 복잡성이 늘었는지, guard가 실패했는지 한국어 이유를 남긴다.

## 6. 대시보드 표시 요구사항

대시보드는 한국어로 다음을 보여야 한다:

- 기준 점수, 최신 통과율, 최고 점수, 현재 실험
- 점수 변화량과 최고 실험
- 실험 설명, 보호 검사 결과, 상태, 점수 변화량
- 사용 가능할 때 점수 상승 설명 요약
- 원시 HTML을 escape한 뒤 안전한 Markdown subset으로 렌더되는 상세 로그

실행별 설명을 `dashboard-template.html`에 하드코딩하지 않는다. 실행별 내용은 `results.json.score_explanation`, `score-explanation.md`, `final-report.md`, 또는 `details/`에 저장하고 렌더러를 다시 실행한다. Markdown 파일은 대시보드에서 서식 있는 Markdown으로 보여야 하지만, 그 안의 raw HTML은 escape된 상태로 남아야 한다.

## 7. 최종 응답 체크리스트

사용자에게 답하기 전에 보고서에 다음이 있는지 확인한다:

- baseline과 final 점수
- 정확한 점수 delta와 통과율 delta
- eval/category별로 어디서 점수가 올랐는지
- 변경 파일과 각 변경을 유지한 이유
- dashboard 경로와 artifact 경로
- 검증 명령/결과
- 남은 실패 또는 명시적 “없음”
