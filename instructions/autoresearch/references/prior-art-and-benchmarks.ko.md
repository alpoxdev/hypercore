# Autoresearch 선행 사례와 벤치마크

> 영어판: [`prior-art-and-benchmarks.md`](prior-art-and-benchmarks.md)

이 문서는 공개된 시스템과 benchmark가 metric 기반 자율 반복에 대해 확립한 것과 확립하지 않은 것을 정리한다. 이는 설계 근거이며, 보증이나 도입 대상, 무인 loop가 프로젝트에서 유효한 결과를 낸다는 증명이 아니다.

## 1. 공통 outer loop

여기서 다루는 모든 시스템은 같은 얕은 loop를 돈다. 후보를 제안하고, 자동 evaluator로 점수를 매기고, 선택하거나 거부하고, 반복한다. 차이는 탐색 폭과 후보 하나의 비용이다.

| System | Candidate surface | Evaluation | Selection memory |
|---|---|---|---|
| AlphaEvolve (white paper, 2025-06) | 프로그램의 소스 코드 | 하나 이상의 자동 evaluator | evolutionary algorithm을 구현한 programs database |
| ShinkaEvolve (2025-09) | 프로그램 코드, LLM은 mutation operator | 후보당 evaluator | 평가된 프로그램의 archive |
| Darwin Gödel Machine (2025-05, ICLR 2026) | agent 자신의 scaffolding 코드 | coding benchmark(SWE-bench, Polyglot) | 자기 수정 agent의 archive |
| `karpathy/autoresearch` (2026-03) | `train.py` 한 파일 | 고정 5분 training run, `val_bpb` | 전진한 branch 하나와 `results.tsv` log |
| OpenEvolve (open source) | 프로그램 코드 | 문제가 정의한 scorer | MAP-Elites와 island population |

설계 표준에 주는 두 가지 결론이다.

- Loop의 모양은 서술하기 쉽고 신뢰할 수 있게 만들기는 어렵다. 위 시스템은 탐색을 시작하기 전에 세 가지를 고정한다. 후보 surface(어떤 파일을 바꿀 수 있는가), evaluator(어떤 코드가 후보를 채점하는가), 후보당 비용이다. 이 셋 중 하나를 암묵적으로 두면 비교할 수 없는 시도가 나온다.
- Selection memory는 취향이 아니라 예산 결정이다. 평가 하나가 비싸고 metric이 매끄러우면 frontier 하나로 충분하다. 탐색에 비해 평가가 싸고 metric에 local optimum이 많으면 archive나 population이 그 비용을 회수한다. 계보를 여러 개 유지하면 각 계보에 frontier identity, restore 경로, attribution이 따로 필요하며, 이것이 frontier 하나가 피하는 비용이다.

## 2. Benchmark는 점수가 아니라 예산으로 정규화한다

| Benchmark | Scale | Scoring | 발표 시점 대표 결과 |
|---|---|---|---|
| MLE-bench (OpenAI, 2024-10) | Kaggle ML 엔지니어링 대회 75개 | 사람 leaderboard로 보정한 medal 기준 | o1-preview와 AIDE scaffolding 조합이 대회의 16.9%에서 최소 bronze medal 수준에 도달 |
| RE-Bench (METR, 2024-11) | 공개형 ML 연구 엔지니어링 환경 7개, 사람 전문가 61명의 8시간 시도 71회 | 정규화 점수, 사람 baseline | 2시간 예산에서 최고 agent가 사람 전문가의 약 4배 점수, 8시간에서는 사람이 최고 agent를 근소하게 앞서고 총 32시간에서는 사람이 최고 agent의 약 2배 점수 |

RE-Bench는 agent 순위가 시간 예산의 함수라는 점을 공개적으로 보여준 가장 분명한 사례다. 같은 비교가 2시간과 32시간 사이에서 뒤집힌다. 예산 세 요소(agent, 시간, 연산)를 함께 적지 않은 benchmark 점수는 측정이 아니다. 프로젝트 loop 안에서도 규칙은 같다. 후보당 측정 예산은 scheduler가 아니라 metric 정의에 속한다. 이 값을 조용히 바꾸면 저장된 모든 frontier 값의 비교 가능성이 무효가 된다.

MLE-bench는 외부 보정의 한계도 보여준다. Benchmark 자체가 공개 대회로 만든 대리 지표이므로, 그런 보정이 없는 프로젝트 metric에서는 “개선”의 프로젝트 간 비교가 의미를 갖지 않는다.

## 3. 장기 자율 연구 agent

- **AI Scientist-v2**(2025-04)는 가설 설정, 실험, 분석, 원고 작성을 end-to-end로 수행하고, workshop peer review 기준을 통과한 최초의 완전 AI 생성 논문을 보고한다. 이는 workshop 수준의 채택이며 그 시스템의 과학적 주장에 대한 검증이 아니다.
- **Kosmos**(2025-11)는 목표 하나에 최대 약 12시간, 약 200회의 agent rollout을 보고하고, 단계 사이 정보를 나르는 structured world model을 쓴다. 저자가 밝힌 제약은 agent가 일관성을 잃기 전까지 수행할 수 있는 행동 수다.
- **Co-Scientist**(2025-02)는 multi-agent tournament로 가설을 생성하고 순위를 매기며, 저자는 선별한 가설의 in-vitro 검증 결과를 보고한다.

설계 교훈은 “더 오래 돌린다”가 아니다. 장기 자율 실행은 일관성과 사람의 결과 검증으로 제한되므로 실행은 checkpoint를 남겨야 한다. frontier를 저장하지 않고 재개 상태도 없는 무중단 다시간 loop는 실패 시 복구할 수 없고, 그 발견을 스스로의 표류와 분리할 수도 없다.

## 4. 지시문의 eval 기반 최적화

**GEPA**(2025-07, ICLR 2026 oral)는 prompt나 program을 후보로 두고 trajectory feedback을 mutation 신호로 쓴다. 과제 6개에서 GRPO 대비 평균 6%, 최대 20% 개선을 최대 35배 적은 rollout으로 보고하며, held-out test split 결과도 함께 보고한다. 최적화 대상이 코드가 아니라 지시문 파일일 때도 계약은 같다. 후보는 텍스트이고, 컴파일 오류 자리에 eval 실패가 오며, optimizer가 development set에 직접 맞추므로 held-out split은 여전히 필요하다.

## 5. 이 근거가 뒷받침하지 않는 것

- 무인 loop가 생산 규모에서 검증된 과학적 발견을 낸다는 peer-reviewed 결과는 없다. 가장 강한 공개 주장은 workshop 수준의 채택이다.
- Benchmark 점수는 프로젝트 metric으로 전이되지 않는다. MLE-bench medal과 RE-Bench 정규화 점수는 공개 과제에서 사람 baseline에 대한 보정이며, 특정 workload에 대한 예측이 아니다.
- `karpathy/autoresearch` 실험은 저자 스스로 밝힌 대로 single-GPU이며 platform-specific하다. 시간당 12회, 하룻밤 100회는 추정치이고 결과는 연산 platform이 다르면 비교할 수 없다고 명시한다. README는 training 구성을 저자의 `nanochat`을 단순화한 single-GPU 구현으로 소개하며, 이를 대체하는 후속 저장소는 없다. 고정한 commit이 여전히 저장소 head다.
- ShinkaEvolve의 sample efficiency 결과는 문제 계열별 결과이며 universal evaluation budget이 아니다.
- AlphaEvolve 발표물은 스스로 white paper라 부르며, 재현된 결과(4×4 복소 행렬 곱을 48회 scalar 곱셈으로 수행, 이 설정에서 Strassen 이후 56년 만의 개선)는 입증한 표적 하나이지 일반 역량 주장이 아니다.
- 공급자 자신의 harness 안에서 자체 보고한 loop 개선은 그 harness에 대한 secondary evidence이며 방법 자체에 대한 근거가 아니다.

## 6. 선행 사례를 프로젝트 loop에 적용하기

1. 후보 surface를 명시적이고 작게 만든다. 조사한 모든 시스템이 그렇게 하며, 대부분은 바꿀 수 있는 artifact를 하나로 제한한다.
2. Evaluator를 변경 가능 집합 밖에 고정한다. `karpathy/autoresearch`는 `prepare.py`를 read-only로 표시하고 evaluation harness 수정을 금지한다. 이는 우리 guard 무결성 요구와 같은 규칙이다.
3. 첫 실행 전에 후보당 비용을 고정하고, frontier 값마다 함께 기록한다.
4. 계보별 관리 비용을 감수할 때만 archive를 둔다.
5. Benchmark 간 전이는 입증되지 않았으므로 의존한다면 따로 시험한다.
6. 개선이 아니라 발견을 주장하는 산출물에는 사람 검증을 별도 gate로 둔다.

## Sources

> 확인 2026-11-03.

| 주장 | 출처 | Grade |
|---|---|---|
| Evolutionary loop, programs database, 4×4 복소 행렬 곱 48회 scalar 곱셈 | <https://arxiv.org/abs/2506.13131> | PRIMARY (white paper, peer review 없음) |
| 평가된 프로그램 archive, sample efficiency 프레이밍 | <https://arxiv.org/abs/2509.19349> | PAPER |
| 자기 수정 agent, SWE-bench 20.0% → 50.0%, Polyglot 14.2% → 30.7% | <https://arxiv.org/abs/2505.22954> | PAPER (ICLR 2026) |
| MAP-Elites와 island를 쓰는 AlphaEvolve 계열 open source 구현 | <https://github.com/algorithmicsuperintelligence/openevolve> | PRACTITIONER |
| Kaggle 대회 75개, o1-preview와 AIDE의 16.9% bronze medal 수준 | <https://arxiv.org/abs/2410.07095> | PAPER |
| 환경 7개, 전문가 8시간 시도 71회, 2시간에서 4배, 8시간에서 사람이 근소하게 앞서고 32시간에서 사람이 약 2배 | <https://arxiv.org/abs/2411.15114> | PAPER |
| End-to-end agentic 연구 시스템, workshop 수준 채택 | <https://arxiv.org/abs/2504.08066> | PAPER |
| 최대 12시간 실행, rollout 약 200회, 일관성 한계 | <https://arxiv.org/abs/2511.02824> | PAPER |
| in-vitro 검증을 포함한 multi-agent 가설 tournament | <https://arxiv.org/abs/2502.18864> | PAPER |
| 반성적 prompt evolution, 과제 6개에서 GRPO 대비 평균 6%·최대 20%, rollout 최대 35배 절감(현재 초록, 확인 2026-11-04. v1은 과제 4개에서 10%로 보고) | <https://arxiv.org/abs/2507.19457> | PAPER (ICLR 2026 oral) |
| Single-GPU loop, 고정 5분 예산, `val_bpb`, `results.tsv`, platform 의존, `prepare.py` read-only | <https://github.com/karpathy/autoresearch/tree/228791fb499afffb54b46200aca536f79142f117> | PRIMARY (repository) |
| Command 14개 harness, runtime별 hook 범위, 기본이 유한 iteration | <https://github.com/uditgoenka/autoresearch/tree/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa> | PRIMARY (repository) |

위 시스템은 모두 자기 harness에 대한 제3자 근거다. 저장소 권한 체계, 이 프로젝트의 안전 규칙, 명시적 사용자 지시가 여전히 우선한다.
