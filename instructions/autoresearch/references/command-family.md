# Autoresearch Command Family

이 문서는 `uditgoenka/autoresearch`의 command surface를 이 저장소에서 instruction pattern으로 해석하기 위한 기준이다. 실제 외부 skill을 설치하거나 실행하라는 뜻이 아니다.

## 1. Core loop

사용 조건:

- scalar metric이 있다.
- verify command가 있다.
- scope가 제한되어 있다.
- rollback 가능하다.

패턴:

```text
Goal → Scope → Metric → Verify → Guard → Iterations
Modify one thing → Verify → Keep/Discard → Log → Repeat
```

## 2. Plan

사용 조건:

- Goal은 있지만 Scope/Metric/Verify가 불분명하다.
- 바로 반복을 돌리면 metric이 잘못될 위험이 크다.

출력:

- 실행 가능한 config block
- verify dry-run 결과
- handoff payload

## 3. Debug

사용 조건:

- 증상은 있지만 root cause가 불분명하다.
- 여러 hypothesis를 체계적으로 테스트해야 한다.

패턴:

```text
symptom → recon → hypothesis → test → confirmed/disproven/inconclusive → log → repeat
```

검증:

- 모든 confirmed finding은 file:line, reproduction, evidence를 가져야 한다.
- disproven hypothesis도 기록한다.

## 4. Fix

사용 조건:

- test/type/lint/build error count를 줄이는 것이 목표다.
- error list가 command로 재현된다.

패턴:

```text
run target → count errors → pick one → fix one → verify → guard → keep/revert
```

금지:

- 여러 error category를 한 번에 고치기
- error count가 줄지 않았는데 keep하기
- guard failure를 무시하기

## 5. Evals

사용 조건:

- 반복 결과 TSV/log가 있다.
- trend, plateau, regression, success pattern을 분석해야 한다.

출력:

- kept/discarded rate
- metric trajectory
- plateau 여부
- 가장 효과적인 change type
- 계속/중단/전략 변경 권고

## 6. Reason

사용 조건:

- numeric metric이 없는 주관/전략/설계 결정이다.
- blind judge/rubric/convergence를 fitness function으로 만들 수 있다.

패턴:

```text
candidate A → critique → candidate B → synthesis → blind judge panel → incumbent → convergence
```

주의:

- judge 기준이 없으면 reasoning loop가 취향 싸움이 된다.
- candidate label을 blind/randomize해야 평가 편향을 줄일 수 있다.

## 7. Probe

사용 조건:

- 요구사항이 흐릿하거나 숨은 제약이 많다.
- 자동 반복 전에 Goal/Scope/Metric/Verify를 더 캐야 한다.

출력:

- constraint list
- ambiguity list
- ready-to-run config 또는 plan handoff

## 8. Learn

사용 조건:

- codebase 문서 생성/갱신/검증이 목표다.

패턴:

```text
scout codebase → generate/update docs → validate links/coverage → fix → repeat
```

주의:

- docs loop도 metric/coverage/required sections/broken links 같은 검증 기준이 필요하다.

## 9. Security and Ship

Security는 기본 read-only audit로 시작한다. fix는 opt-in이다.

Ship은 외부 side effect가 생길 수 있으므로 다음이 필수다.

- explicit user approval before deploy/publish/push
- dry-run
- rollback plan
- post-verify
- environment boundary
