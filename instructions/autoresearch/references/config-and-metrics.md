# Autoresearch Config and Metrics

Autoresearch의 품질은 config 품질에서 대부분 결정된다. 특히 metric과 verify가 약하면 agent가 열심히 반복해도 잘못된 방향으로 최적화한다.

## 1. Required config fields

| Field | 설명 | 좋은 기준 |
|---|---|---|
| Goal | 개선하려는 결과 | 수치 threshold 또는 명확한 상태 포함 |
| Scope | 수정 가능한 파일/모듈 | glob과 exclude가 명시됨 |
| Metric | 비교할 값 | 숫자 하나 또는 명확한 판정 기준 |
| Direction | higher/lower is better | metric 해석이 모호하지 않음 |
| Verify | metric을 얻는 명령/절차 | non-interactive, 재실행 가능, output parse 가능 |
| Guard | 깨지면 안 되는 검사 | exit code로 pass/fail 확인 가능 |
| Iterations | 반복 한도 | 기본 bounded, 예산과 위험에 맞음 |

## 2. 좋은 metric 조건

좋은 metric은 다음을 만족한다.

- 빠르게 측정 가능하다.
- 숫자 또는 안정적인 판정으로 나온다.
- 목표와 직접 연결된다.
- noise가 낮거나 median/min-delta 같은 완충 장치가 있다.
- gaming하기 어렵다.
- guard와 역할이 다르다.

예:

| 목표 | Metric | Direction | Guard |
|---|---|---|---|
| 테스트 커버리지 증가 | coverage % | higher | full test suite |
| lint error 제거 | error count | lower | typecheck/build |
| bundle size 감소 | KB | lower | unit/e2e tests |
| API latency 개선 | p95 ms | lower | correctness tests |
| 문서 품질 개선 | broken link count + required section coverage | lower/higher | markdown lint |

## 3. 나쁜 metric 패턴

- agent가 스스로 점수를 매기는 metric
- “더 좋아 보임” 같은 주관 평가만 있는 metric
- verify output에서 숫자를 안정적으로 뽑을 수 없음
- 개선 metric과 guard가 같은 명령이라 tradeoff를 볼 수 없음
- 목표와 무관한 proxy만 최적화
- 너무 느려서 iteration cost가 큰 metric

## 4. Verify command 기준

Verify는 다음 조건을 만족해야 한다.

- non-interactive
- deterministic 또는 noise-handled
- stdout/stderr에서 metric 추출 가능
- credentials를 출력하지 않음
- network write, publish, deploy, delete를 하지 않음
- 실패 시 원인 파악 가능한 output을 남김

명령 안전 screen에서 차단할 것:

- `rm -rf` 같은 파괴 명령
- `curl | sh` 같은 remote execution
- credential이 inline으로 들어간 명령
- production write/deploy/publish
- fork bomb 또는 resource exhaustion 패턴

## 5. Guard 설계

Guard는 “최적화 target”이 아니라 “깨지면 안 되는 기본선”이다.

예:

```yaml
Metric: "bundle_kb"
Verify: "npm run build 2>&1 | grep 'First Load JS'"
Guard: "npm test && npm run typecheck"
```

metric이 좋아져도 guard가 실패하면 keep하지 않는다.

## 6. Subjective goals

숫자 metric이 없으면 억지 metric을 만들기보다 다음으로 전환한다.

- rubric scoring
- blind judge comparison
- pairwise candidate tournament
- convergence threshold
- human review gate

예:

```yaml
Task: "이 아키텍처 결정을 평가"
Fitness: "5명 judge의 blind majority vote"
Convergence: "같은 candidate가 3회 연속 승리"
Guard: "보안/운영 제약 위반 없음"
```
