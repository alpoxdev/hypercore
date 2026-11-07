# Autoresearch Instructions

> 영어판: [`AUTORESEARCH.md`](AUTORESEARCH.md)

Autoresearch는 각 시도를 비교할 수 있고, 소유한 상태 안에서 되돌릴 수 있으며, 감사를 남기는 제한된 개선 loop다. 단순히 “계속 시도하기”를 뜻하지 않는다. 이 문서는 runtime-neutral 설계 표준이며 외부 autoresearch runtime의 설치나 실행을 요구하지 않는다.

## 핵심 계약

| Primitive | 필수 규칙 |
|---|---|
| Goal | 결과 또는 질문과 stop predicate를 명시한다. |
| Scope | 소유한 path/resource와 제외 범위를 선언한다. 기존 변경은 명시적으로 할당되지 않는 한 사용자 소유다. |
| Metric | 측정 결과, 방향, 비교 규칙, evidence 형태를 정의한다. |
| Verify | 실제 결과를 충실하게 측정하거나 평가하는 procedure를 실행한다. |
| Guard | 상태나 resource를 변경하는 mutating loop에서는 필수다. 개선 decision과 독립적으로 판정하고, 적용할 guard가 없으면 이유를 기록한다. |
| Budget | iteration을 제한하고, 필요하면 wall time, cost, resource도 제한한다. |
| Log | invalid, blocked, failed, tied, inconclusive 결과를 포함해 모든 시도를 기록한다. |
| Decision | evidence가 사전 정의한 acceptance rule을 만족하고 모든 mandatory guard가 통과할 때만 frontier를 전진시킨다. |
| Recovery | coverage를 선언한 checkpoint에서 실험 소유 candidate 상태만 복구하며 사용자 소유 작업을 덮어쓰지 않는다. |
| Handoff | 안전하게 중단하고, 약속한 경우 revalidation 뒤 재개할 수 있는 typed state를 저장한다. |

한 iteration은 하나의 falsifiable hypothesis를 검증한다. 하나의 가설이 여러 파일을 바꿀 수는 있지만 관련 없는 edit가 섞이면 attribution은 무효다.

## 근거 snapshot

> 출처 확인 2026-11-03. Upstream behavior는 아래 revision에 고정했다. Floating repository page는 탐색에는 쓸 수 있지만 stable interface의 근거가 아니다.

- [Karpathy `autoresearch` at `228791f`](https://github.com/karpathy/autoresearch/tree/228791fb499afffb54b46200aca536f79142f117)의 최신 commit은 여전히 이 병합(2026-03-26)이다. 이 실험은 좁은 연구 loop를 보여준다. Agent는 `train.py`만 수정하고, startup/compilation을 제외한 고정 5분 wall-clock **training** budget으로 `val_bpb`를 낮추며, `keep`/`discard`/`crash` 행을 `results.tsv`에 기록한다. `prepare.py`는 read-only로 남아 평가를 담당하므로 evaluator는 수정 가능 범위 밖에 있다. 시간당 약 12회와 overnight 약 100회는 추정치이고, 연산 platform이 다르면 결과를 비교할 수 없다고 밝힌다.
- [`uditgoenka/autoresearch` v2.3.0 at `7bddd05`](https://github.com/uditgoenka/autoresearch/tree/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa)(2026-10-31 release)는 command 14개를 제공하며 기본값이 유한하다. loop하는 모든 command에 기본 iteration 수가 있고 `Iterations: unlimited`는 opt-in이다. Hook guardrail은 Claude Code(native hooks)와 pi(extension events)에 제공되고, OpenCode, Codex, Muse는 hook parity 없이 skill, runtime, install surface만 제공한다. Chain command는 `handoff.json`을 쓰고 iteration 분석은 `*-results.tsv`를 읽는다.
- [OpenAI skill evaluation guidance](https://developers.openai.com/blog/eval-skills)의 제목은 “Testing Agent Skills Systematically with Evals”이며 outcome, process, style, efficiency 목표를 구분하고 check 목록을 작고 must-pass로 유지하라고 조언한다. 이는 평가 축이지 mandatory scalar score가 아니며, 별개의 legacy OpenAI Evals platform 계약도 아니다.

Runtime별 invocation syntax는 이식 가능하지 않다.

- Claude Code: `/autoresearch` and `/autoresearch:<name>`
- OpenCode: `/autoresearch_<name>`
- Codex: `$autoresearch <subcommand>`, for example `$autoresearch debug`
- pi: 밑줄 이름의 prompt template, `/autoresearch_debug`
- Muse: keyword subcommand, `autoresearch debug`

이 upstream interface는 근거와 예시다. 저장소 권한 체계, 안전 규칙, 명시적 사용자 지시가 우선한다.

## 기본 loop

1. **Preflight**: effective config, authority, scope, ownership, 관련 confounder, budget을 고정한다.
2. **Baseline**: immutable 시작 상태에서 Verify와 Guard를 실행한다. 어느 쪽이든 신뢰할 수 없으면 중단한다.
3. **Hypothesis**: falsifiable change 하나를 선택해 현재 frontier에 연결한다.
4. **Checkpoint**: ownership-scoped, restoration-tested candidate snapshot을 만든다. Commit은 명시적으로 승인된 경우에만 허용하며 사용자 history를 재작성해서는 안 된다.
5. **Execute**: 선언한 procedure를 실행하고 raw evidence를 보존한다.
6. **Guard**: non-compensable mandatory constraint를 평가한다.
7. **Decide**: 설정 profile에 따라 keep, tie, discard, inconclusive/error를 판정한다.
8. **Restore**: keep이 아니면 소유한 candidate 상태만 복원하고 restoration receipt를 검증한다.
9. **Record**: outcome, evidence identity, cleanup, frontier state를 atomic하게 저장한다.
10. **Stop or continue**: goal predicate, budget, plateau/failure rule, 사용자 interrupt, safety gate를 강제한다. 기본 flat-cycle 횟수와 cycle ceiling은 [`references/command-family.ko.md`](references/command-family.ko.md)에 있다.

상세 executable contract는 [`references/core-loop.ko.md`](references/core-loop.ko.md)에 있다.

## 최소 설정

```yaml
Goal: "Reduce p95 latency by 20% without changing responses"
Scope:
  Include: ["src/query/**"]
  Exclude: ["migrations/**", "secrets/**"]
Metric:
  Profile: "noisy-performance"
  Name: "p95_latency_ms"
  Direction: "lower_is_better"
  Decision: "predeclared paired comparison with inconclusive state"
Verify: "node scripts/measure-query.mjs --json"
Guard: "npm test && npm run typecheck"
Budget:
  MaxIterations: 12
Evidence: "autoresearch/query-latency-{run_id}/"
Authorization: "local-only; no external actions"
Acceptance: "improved only when the paired comparison beats the tie band and every guard passes"
Stop: "goal met, 12 iterations used, or no in-scope hypothesis remains"
```

이 measurement profile을 기계적으로 복사하지 않는다. Exact deterministic check, cold-start measurement, noisy performance benchmark, stochastic model run, subjective judge는 서로 다른 protocol이 필요하다. [`references/config-and-metrics.ko.md`](references/config-and-metrics.ko.md)를 따른다.

## 선행 사례, 2024-2026

공개된 시스템은 loop의 모양을 바꾸지 않고 탐색 폭을 넓힌다. AlphaEvolve는 하나 이상의 자동 evaluator 뒤에 채점된 프로그램 database를 두고, ShinkaEvolve는 archive를 두고 sample efficiency를 핵심 주장으로 내세우며, Darwin Gödel Machine은 agent 자신의 scaffolding을 변이시키고 각 변경을 coding benchmark로 검증한다. 연구 benchmark는 점수가 아니라 예산으로 정규화한다. RE-Bench는 2시간 예산과 32시간 예산 사이에서 agent와 전문가의 순위가 뒤집히므로, 시간과 연산 예산을 함께 적지 않은 점수는 측정이 아니다. 이들 가운데 무인 상태의 생산 규모 발견을 peer review로 입증한 사례는 없다. 수치와 근거 등급, 각 주장의 한계는 [`references/prior-art-and-benchmarks.ko.md`](references/prior-art-and-benchmarks.ko.md)에 정리했다.

## 이 표준이 채택하지 않는 upstream 기본값

- Upstream program file은 agent에게 멈추지 말고 계속할지 묻지도 말라고 지시한다. Loop는 사람이 중단할 때까지 돈다. 일회용 branch와 사람이 소유한 harness에서는 방어할 수 있는 지침이지만 프로젝트 기본값은 아니다. 이 표준은 첫 실행 전에 stop predicate와 budget을 요구한다.
- 같은 file은 진 후보를 branch를 `git reset`으로 되돌려 버린다. 이는 그 branch가 실행을 위해 만들어졌기 때문에 안전하다. 공유 workspace에서 같은 명령은 사용자 작업을 파괴하므로, 복구는 소유 path에 대한 compare-before-restore로 남긴다.
- Upstream은 자체 hook을 defense in depth라 부르고 security sandbox가 아니라고 밝힌다. 로컬 hook이나 extension 적용 범위는 결코 authorization 경계가 아니다.
- 자체 checklist를 통과하면 자동 승인하는 upstream `--auto` mode도 이 프로젝트가 gate로 막는 행동을 승인하지 않는다. [`references/safety-and-observability.ko.md`](references/safety-and-observability.ko.md)의 authorization matrix를 따른다.

## Command family 해석

Command family는 하나의 universal command namespace가 아니라 재사용 가능한 loop archetype 모음이다.

- Plan, Debug, Fix, Reason, Probe, Learn, Predict, Improve
- Scenario discovery and saturation
- Iteration analytics over recorded results
- Behavioral evals over artifacts and agent traces
- Regression verification and security review
- Ship readiness and separately approved finalization
- Bare-command routing among classic, goal-directed orchestration, and guided setup modes

현재 upstream surface에서 설계에 중요한 속성은 두 가지다. loop하는 모든 command에 기본 iteration 수가 있어 무제한 실행은 기본값이 아니라 명시적 opt-in이고, bare command는 평문 목표를 분류해 success predicate를 도출하고 한 번 확인한 뒤 subcommand를 넘나들며 수동 chaining 없이 loop를 돌 수 있다.

[`references/command-family.ko.md`](references/command-family.ko.md)를 참고한다. Scenario discovery는 구현 coverage를 증명하지 않는다. Retained scenario는 project-owned test나 acceptance check로 바꿔야 한다.

## 안전과 권한

- 정상적인 scoped local read, edit, verification은 저장소 정책을 따른다.
- Credential use, external data transmission, destructive action, commit/release, remote write, deploy/publish/push, production access는 controlling instruction이 정한 authorization을 요구한다. Upstream `--auto` flag는 사용자 승인이 아니다.
- Network read도 자동으로 안전하지 않다. Request가 repository나 secret data를 유출할 수 있으므로 destination/data policy를 명시한다.
- Linked worktree는 working file, index, `HEAD`를 분리하지만 대부분의 ref, 기본 repository config, hook, object database를 공유한다. Security boundary가 아니다.
- Detached `HEAD`는 read-only 또는 의도적으로 disposable한 작업에 유효하다. 보존할 상태에는 검증된 run-owned ref 또는 immutable snapshot이 필요하다.
- Irreversible external action은 iterative loop 안에서 실행하지 않는다. 정확히 승인된 action을 target verification과 post-check가 있는 별도 finalization gate로 옮긴다.
- Metric 개선은 failed, unavailable, malformed mandatory guard를 상쇄하지 못한다.
- Frontier model은 test나 scoring code를 고쳐 점수를 올릴 수 있다. Metric이 오르는데 guard 범위가 줄어드는 것은 개선이 아니라 조작 신호다([METR, 2025-06-05](https://metr.org/blog/2025-06-05-recent-reward-hacking/), 확인 2026-11-03).
- Loop가 자신의 harness를 수정할 수 있게 허용할 때는 evaluator, guard, log를 변경 가능 집합 밖에 두고, 변이 surface를 사람이 검토할 수 있어야 한다.

[`references/safety-and-observability.ko.md`](references/safety-and-observability.ko.md)를 따른다.

## 함께 읽을 문서

- [`references/core-loop.ko.md`](references/core-loop.ko.md)
- [`references/config-and-metrics.ko.md`](references/config-and-metrics.ko.md)
- [`references/command-family.ko.md`](references/command-family.ko.md)
- [`references/safety-and-observability.ko.md`](references/safety-and-observability.ko.md)
- [`references/prior-art-and-benchmarks.ko.md`](references/prior-art-and-benchmarks.ko.md)
- [`../context-engineering/CONTEXT_ENGINEERING.ko.md`](../context-engineering/CONTEXT_ENGINEERING.ko.md)
- [`../harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md)
- [`../loop-engineering/LOOP_ENGINEERING.ko.md`](../loop-engineering/LOOP_ENGINEERING.ko.md) — 이 metric 기반 loop보다 한 단계 위의 일반 loop 설계: loop 유형, stop condition, 비용, runtime primitive
- [`../validation/index.ko.md`](../validation/index.ko.md)
- [`../sourcing/reliable-search.ko.md`](../sourcing/reliable-search.ko.md)

로컬 연구 artifact는 ignored runtime directory에 있을 수 있지만, 이 문서는 특정 cache path가 ignored되거나 portable하다고 주장하지 않는다. 위 pinned URL과 repository evidence가 source record다.
