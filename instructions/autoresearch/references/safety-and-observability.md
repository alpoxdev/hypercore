# Autoresearch Safety and Observability

Autoresearch는 반복 실행과 자동 수정을 전제로 하므로 안전성과 관측 가능성이 없으면 위험하다.

## 1. Safety invariants

항상 지킨다.

- bounded by default
- clean or acknowledged working tree
- explicit scope
- one atomic change per iteration
- no push/publish/deploy without explicit approval
- no destructive command without explicit approval
- no credential exposure
- no production write by default
- verify command safety screen
- guard before keep
- reversible changes

## 2. Precondition checks

루프 시작 전 확인:

- git repo인지
- working tree가 clean인지 또는 dirty state가 명시적으로 승인되었는지
- detached HEAD가 아닌지
- stale lock file이 없는지
- verify command가 dry-run에서 parseable metric을 내는지
- guard command가 baseline에서 통과하는지
- scope glob이 실제 파일로 resolve되는지

## 3. Dangerous verify patterns

차단 또는 사용자 승인 필요:

- delete/write outside scope
- deploy/publish/push
- email/send/payment/purchase
- `curl | sh`, remote script execution
- embedded secrets
- fork bomb, infinite background process
- production DB writes
- broad filesystem mutation

## 4. Observability artifacts

최소 artifact:

```text
autoresearch/{mode}-{YYMMDD}-{HHMM}/
├── results.tsv
├── summary.md
└── handoff.json
```

권장 TSV metadata:

```text
# metric_direction: higher_is_better|lower_is_better
iteration timestamp commit metric delta guard status description
```

상태 값 예:

- baseline
- keep
- discard
- crash
- no-op
- hook-blocked
- metric-error
- inconclusive
- confirmed
- disproven

## 5. Evals checkpoints

반복 중간에 다음을 본다.

- metric trend: up/flat/down
- keep/discard rate
- guard failure rate
- plateau 여부
- file hotspots
- repeated failure classes
- best/worst deltas
- strategy recommendation

권장 plateau stop:

- 3개 checkpoint 연속 개선 없음
- discard가 5회 이상 연속이고 새 가설이 없음
- guard failure가 반복되어 metric과 safety가 충돌

## 6. Handoff contract

chain이 있으면 `handoff.json`에 다음을 둔다.

```json
{
  "version": "1.0",
  "source": "loop|plan|debug|fix|reason|learn",
  "timestamp": "ISO-8601",
  "status": "COMPLETE|BOUNDED|CONVERGED|USER_INTERRUPT|ERROR",
  "results_tsv": "path/to/results.tsv",
  "config": {
    "goal": "...",
    "scope": ["..."],
    "metric": "...",
    "direction": "higher_is_better|lower_is_better",
    "verify": "...",
    "guard": "..."
  },
  "findings": []
}
```

## 7. Reporting rule

최종 보고는 agent의 서술이 아니라 evidence에 묶는다.

```markdown
결과:
- 시작 metric → 최종 metric
- kept/discarded/crash/no-op counts

효과 있던 변경:
- iteration, commit, delta, 설명

중단 이유:
- goal met / bounded / plateau / blocked / safety gate

주의:
- 미검증 항목, noisy metric, guard tradeoff, scope 밖 필요사항
```
