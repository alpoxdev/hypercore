# Autoresearch Core Loop

Autoresearch core loop는 agent가 반복 실행할 수 있는 최소 폐쇄 루프다. 핵심은 “시도”가 아니라 “비교 가능한 시도”다.

## 1. Loop contract

| 단계 | 목적 | 산출 |
|---|---|---|
| Plan | Goal/Scope/Metric/Verify/Guard/Iterations를 고정 | config |
| Baseline | 현재 상태 metric을 측정 | iteration 0 row |
| Review | 이전 결과와 git/log history를 읽음 | 다음 가설 |
| Modify | 하나의 atomic change | patch/commit |
| Verify | metric을 다시 측정 | numeric result 또는 판정 |
| Guard | regression을 확인 | pass/fail |
| Decide | keep/discard/revert/no-op/crash 분류 | decision |
| Log | 결과를 TSV/markdown에 기록 | results row |
| Evals | trend/plateau/regression 분석 | recommendation |
| Stop/Handoff | 종료 또는 chain 연결 | summary/handoff |

## 2. Atomic change rule

한 iteration에는 하나의 논리 변경만 허용한다.

좋은 예:

- 테스트 누락 한 케이스 추가
- 하나의 lint rule 위반 패턴 제거
- 특정 hot path의 memoization 한 곳 적용
- 하나의 hypothesis를 검증하기 위한 작은 config 변경

나쁜 예:

- 성능 최적화, 리팩토링, 테스트 추가를 한 번에 섞음
- 여러 파일의 독립 문제를 한 commit에 해결
- metric이 좋아졌을 때 원인을 알 수 없는 큰 변경

## 3. Baseline and frontier

Autoresearch는 항상 현재 best known state를 frontier로 본다.

- baseline metric을 먼저 기록한다.
- keep된 변경만 frontier를 전진시킨다.
- discard된 변경은 학습 데이터로 기록하지만 현재 상태에는 남기지 않는다.
- 실패도 중요하다. 같은 방향을 반복하지 않도록 log에 남긴다.

## 4. Decision table

| 조건 | 결정 | 처리 |
|---|---|---|
| metric 개선 + guard pass | keep | commit 유지 |
| metric 악화 | discard | revert/reset |
| metric 개선 + guard fail | discard | revert, guard failure 기록 |
| verify crash | crash | revert, stderr 요약 기록 |
| metric parse 실패 | metric-error | revert 또는 human review |
| 변경 없음 | no-op | log 후 다음 가설 |
| hook/permission 차단 | hook-blocked | log 후 중단 또는 대체 경로 |

## 5. Stop conditions

반복은 무한히 도는 것이 기본이 아니다. 다음 중 하나에서 멈춘다.

- max iterations 도달
- goal threshold 달성
- 3개 이상 eval checkpoint에서 plateau
- 같은 failure class가 반복되어 의미 있는 새 가설이 없음
- verify/guard가 신뢰 불가능함
- scope 밖 변경이 필요함
- destructive/credential/production side effect가 필요함
- 사용자 interrupt

## 6. Loop output

권장 output directory:

```text
autoresearch/{mode}-{YYMMDD}-{HHMM}/
├── results.tsv
├── summary.md
├── handoff.json
└── evals-summary.md
```

최소 TSV column:

```tsv
iteration timestamp commit metric delta guard status description
```

Debug/reason/scenario 같은 command는 metric 대신 hypothesis, severity, candidate_label, judge_verdict 같은 column을 추가할 수 있다.
