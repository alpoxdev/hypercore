# Autoresearch Instructions

이 문서는 autoresearch-style loop를 설계하거나 검토할 때 읽는 기본 문서다. 목적은 agent에게 “계속 알아서 해”라고 맡기는 것이 아니라, **목표·범위·측정·검증·가드·로그·rollback이 있는 자율 반복 하네스**를 만들게 하는 것이다.

## 핵심 정의

Autoresearch는 다음 primitives를 갖춘 반복형 개선/연구 패턴이다.

| Primitive | 질문 | 필수성 |
|---|---|---|
| Goal | 무엇을 개선하거나 발견할 것인가? | 필수 |
| Scope | 어떤 파일/모듈/자료만 바꿀 수 있는가? | 필수 |
| Metric | 결과를 비교할 숫자 또는 판정 기준은 무엇인가? | 필수 |
| Direction | 높을수록 좋은가, 낮을수록 좋은가? | 숫자 metric이면 필수 |
| Verify | metric을 추출하거나 판정하는 명령/절차는 무엇인가? | 필수 |
| Guard | 개선 중 절대 깨지면 안 되는 안전 검사는 무엇인가? | 권장 |
| Iterations | 몇 번 반복할 것인가? | 필수, bounded default |
| Log | 각 시도와 결과를 어디에 기록할 것인가? | 필수 |
| Keep/Discard | 무엇을 개선으로 인정하고 무엇을 되돌릴 것인가? | 필수 |
| Handoff | 다음 command/agent가 무엇을 이어받는가? | chain이 있으면 필수 |

## 공식/원본 근거 요약

- `uditgoenka/autoresearch`는 Karpathy의 autoresearch 원리를 Claude Code/OpenCode/OpenAI Codex용 범용 skill/command 체계로 일반화한다. README는 “goal, metric, loop”를 핵심으로 설명하고 Codex에서 `$autoresearch <command>` syntax를 사용한다고 설명한다. <https://github.com/uditgoenka/autoresearch>
- 해당 repo의 Codex skill은 `$autoresearch`, `$autoresearch plan`, `$autoresearch debug`, `$autoresearch fix`, `$autoresearch evals` 등 13개 command와 bounded default iterations, `handoff.json`, `*-results.tsv`를 명시한다. <https://github.com/uditgoenka/autoresearch>
- Karpathy 원형 repo는 `program.md`가 agent instruction layer이고, agent가 `train.py`만 수정하며, fixed 5-minute budget과 `val_bpb` metric으로 keep/discard하는 작은 ML 연구 loop를 제시한다. <https://github.com/karpathy/autoresearch>
- OpenAI의 skill eval 문서는 skill/agent behavior를 trigger, process, output, efficiency check로 관찰하라고 권장한다. <https://developers.openai.com/blog/eval-skills>

## 이 저장소의 해석

이 저장소에서 `instructions/autoresearch/`는 외부 `$autoresearch` runtime을 설치하거나 실행하라는 문서가 아니다. 다음을 위한 **런타임 중립 설계 기준**이다.

- 반복 개선 loop를 만들 때 필요한 최소 계약 정의
- metric/verify/guard 설계
- autonomous loop의 안전 경계 설정
- TSV/log/handoff 같은 관측 가능성 확보
- subjective task를 numeric metric 없이 다룰 때 judge/rubric/eval loop로 전환

## 언제 사용하나

사용한다:

- test coverage, lint error count, bundle size, latency, build time처럼 숫자 metric이 있는 목표
- 반복 실험이 작고 빠르며 rollback 가능한 경우
- agent가 여러 시도를 해도 scope가 제한되어 있고 guard가 있는 경우
- debug/fix/security/docs/ship처럼 command-specific loop로 나눌 수 있는 경우
- subjective decision이라도 judge rubric, blind comparison, convergence 기준을 만들 수 있는 경우

사용하지 않는다:

- 한 번 읽고 답하면 되는 research/report 작업
- metric이나 judge 기준이 전혀 없는 “좋게 만들어줘” 작업
- production deploy, publish, push, deletion, credential 사용처럼 명시 승인이 필요한 작업
- verify가 너무 느리거나 noisy해서 비교가 불가능한 작업
- scope가 너무 넓어 agent가 무엇을 바꿨는지 추적할 수 없는 작업
- 실패 시 되돌릴 방법이 없는 작업

## 기본 loop

```text
0. Plan: Goal, Scope, Metric, Direction, Verify, Guard, Iterations를 고정한다.
1. Baseline: Verify를 실행해 현재 metric을 기록한다.
2. Review: 이전 log, git history, 실패/성공 패턴을 읽는다.
3. Modify: 한 번에 하나의 atomic change만 만든다.
4. Checkpoint: commit 또는 안전한 patch snapshot을 남긴다.
5. Verify: metric을 다시 측정한다.
6. Guard: guard command 또는 safety check를 실행한다.
7. Decide: metric이 개선되고 guard가 통과하면 keep, 아니면 discard/revert.
8. Log: TSV/markdown/handoff에 결과를 기록한다.
9. Evals: plateau, regression, success pattern을 분석한다.
10. Stop/Handoff: iteration cap, goal 달성, plateau, blocker, user interrupt, downstream chain 조건을 처리한다.
```

세부 loop 설계는 [`references/core-loop.md`](references/core-loop.md)를 읽는다.

## 최소 설정 템플릿

```yaml
Goal: "무엇을 개선할지"
Scope:
  include:
    - "src/**/*.ts"
  exclude:
    - "src/generated/**"
Metric:
  name: "coverage_percent"
  direction: "higher_is_better"
Verify: "npm test -- --coverage | grep 'All files'"
Guard: "npm test && npm run typecheck"
Iterations: 10
OutputDir: "autoresearch/loop-{YYMMDD}-{HHMM}/"
Stop:
  goal_met: "coverage >= 90"
  max_iterations: 10
  plateau: "3 consecutive eval checkpoints without improvement"
  unsafe: "destructive, credential, production, network side effect without approval"
```

Metric과 verify 설계는 [`references/config-and-metrics.md`](references/config-and-metrics.md)를 읽는다.

## Command family 해석

`uditgoenka/autoresearch`의 command surface는 다음처럼 볼 수 있다.

| 목적 | Pattern |
|---|---|
| metric 최적화 | core loop: modify → verify → keep/discard |
| goal을 실행 config로 변환 | plan: Goal → Scope → Metric → Verify → dry-run |
| 버그 찾기 | debug: hypothesis → test → classify → log |
| 오류 줄이기 | fix: one error → one fix → verify → keep/revert |
| 보안 점검 | security: read-only audit 기본, fix는 opt-in |
| 배포/릴리스 | ship: checklist/dry-run/verify 중심, 외부 side effect gate 필요 |
| edge case 탐색 | scenario: dimension coverage |
| 주관적 판단 | reason: candidates → critique → blind judges → convergence |
| 요구사항 탐색 | probe: adversarial personas until constraint saturation |
| 문서화 | learn: scout → generate → validate → fix |
| 결과 분석 | evals: TSV trends, plateaus, regressions, recommendation |

자세한 command family 기준은 [`references/command-family.md`](references/command-family.md)를 읽는다.

## Safety invariants

Autoresearch loop는 자동으로 command를 실행하고 파일을 바꿀 수 있으므로 다음은 불변 조건이다.

- bounded by default: unbounded loop는 명시 opt-in일 때만.
- no external side effects: push, publish, deploy, purchase, email, production write는 명시 승인 없이는 금지.
- scope bounded: agent가 바꿀 수 있는 파일/모듈을 제한.
- one atomic change per iteration: 여러 가설을 한 commit에 섞지 않음.
- guard before keep: metric이 좋아져도 guard가 깨지면 discard.
- log every attempt: 성공뿐 아니라 실패, crash, no-op, metric-error도 기록.
- reversible: commit/revert 또는 patch snapshot으로 되돌릴 수 있어야 함.
- source/results are evidence: agent narration보다 verify output과 logs를 우선.

안전과 관측 가능성은 [`references/safety-and-observability.md`](references/safety-and-observability.md)를 읽는다.

## 함께 읽을 문서

- [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md)
- [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md)
- [`../validation/index.md`](../validation/index.md)
- [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md)
- 리서치 보고서: 저장소 루트 기준 `.hypercore/research/2026-06-02-autoresearch-instructions.md`
