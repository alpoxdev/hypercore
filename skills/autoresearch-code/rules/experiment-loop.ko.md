# 실험 루프

**목적**: 코드 오토리서치 실행을 측정 가능하고, 되돌릴 수 있고, 다음 실행자가 배울 수 있게 유지한다.

## 1. Baseline First

- 실험 `0`이 기록되기 전에는 대상 코드베이스를 변이하지 않는다.
- eval 자체가 잘못됐다는 증거가 없는 한 baseline과 후속 실험에서 같은 테스트 프롬프트와 eval 세트를 유지한다.
- eval 세트, proof command, 범위, 점수 방향을 바꿔야 한다면 점수를 섞지 말고 별도 `reset` 이벤트로 기록한다.
- 수정 전에 baseline 지표 값, proof command, guard 점검, 롤백 조건, 환경을 기록한다.

## 2. 수정 전 실패 진단

변이를 고르기 전에 지배적인 실패를 분류한다:

- 느린 build 또는 startup time
- 과도한 bundle 또는 artifact size
- 느린 query, request, render path
- 중복 로직 또는 dead code
- flaky test 또는 불안정한 validation
- 작고 안전한 변경을 막는 구조적 friction
- 반복 작업의 높은 개발자 비용

점수를 가장 많이 잃거나 가장 자주 나타나는 실패를 먼저 고른다. 수정 전에 target metric/eval을 이름 붙인다.

## 3. 한 번에 하나만 바꾸기

좋은 변이:

- hot path 하나 단순화
- 측정 가능한 병목에 cache, batch, guard 하나 추가
- duplicate branch 또는 dead dependency 하나 제거
- 비싼 연산 하나를 critical path 밖으로 이동
- 재작업을 막는 validation 단계 하나를 강화
- 측정 가능한 부담만 만드는 configuration 또는 abstraction 삭제

나쁜 변이:

- 고립된 가설 없는 broad rewrite
- 무관한 여러 편집을 한 실험에 묶기
- 측정 근거 없이 tool 또는 dependency 추가
- 사용자가 실제로 신경 쓰지 않는 metric만 개선하기

## 4. Keep, Rework, Discard

- 총점이 오르고 모든 필수 guard가 통과하면 **KEEP**.
- 총점은 올랐지만 필수 guard가 실패하면 **DISCARD** 또는 **REWORK**하고 promotable이라고 부르지 않는다.
- 총점이 그대로인데 복잡도가 늘면 **DISCARD**.
- 총점이 떨어지면 **DISCARD**.
- 점수는 그대로지만 코드베이스가 실질적으로 단순해졌다면 단순화 이유, 수정 파일, no-regression proof가 명시된 경우에만 유지한다.
- 측정 hook이 crash하거나 metric을 신뢰할 수 없으면 `crash`, `hook-blocked`, `metric-error`로 표시하고 baseline과 비교하지 않는다.

## 5. 코드 최적화 규칙

코드베이스를 최적화할 때:

- 새 layer보다 삭제를 우선한다
- broad cleanup 전에 targeted validation으로 동작을 보호한다
- 새 abstraction보다 기존 코드베이스 패턴을 재사용한다
- 각 실험은 왜 점수가 바뀌었는지 설명 가능한 크기로 유지한다
- proof command를 재현 가능하게 유지하고 최종화 전에 같은 guard 세트를 다시 실행한다

## 6. 로깅 규칙

모든 실험은 다음을 기록해야 한다:

- 실험 번호
- 점수와 최대 점수
- 통과율과 baseline 또는 이전 best 대비 점수 변화량
- 상태: `baseline`, `keep`, `keep-reworked`, `discard`, `crash`, `no-op`, `hook-blocked`, `metric-error`, `reset`
- 변이를 설명하는 한국어 한 문장
- 이 변이가 도움이 될 것으로 본 이유
- target metric/eval과 이전/이후 값 또는 pass count
- 수정 파일
- proof command와 요약 출력
- guard 결과와 guard metric
- promotion state: `hold`, `promote`, `rollback`
- 롤백 조건
- eval 결과에서 실제로 바뀐 점
- 남은 실패 또는 명시적 “없음”

## 7. 종료 조건

다음 중 하나가 참이면 멈춘다:

- 사용자가 실행을 멈춘다
- budget ceiling에 도달한다
- guard가 통과한 keep 실험 3개 연속에서 `95%+` 통과율을 기록한다
- 남은 실패가 코드베이스가 아니라 나쁜 eval 설계에서 온다고 판단된다

최종 응답 전에 `code-explanation.md`/`results.json.code_explanation`, `final-report.md`, `results.js`, `dashboard.html`을 작성 또는 갱신해 사용자가 점수 이동과 Markdown 렌더링 상세를 로컬에서 볼 수 있게 한다.

Eval이 통과해도 실제 결과가 여전히 약하면 더 많은 변이를 추가하기 전에 eval을 고친다.
