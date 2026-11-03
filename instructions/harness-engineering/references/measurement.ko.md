# Measurement Reference

> 영어판: [`measurement.md`](measurement.md)

하네스의 반복·집계·비용·컨텍스트 변수 규칙을 유도한다.
**규범**은 [`HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## Judgement Rules`와
`## Harness Staleness`에 있고, 이 문서는 그 숫자가 어디서 나왔는지와 무엇을 주장하지 않는지를 밝힌다.

## 최소 실행 횟수

`MIN_RUNS`는 비결정적 케이스를 판정하기 전에 필요한 **케이스별 독립 실행** 최소 횟수다.
케이스 파일이 자기 값을 적고 검토자가 기계로 확인할 수 있도록 이름 있는 상수로 둔다.

| 케이스 종류 | `MIN_RUNS` | 이유 |
|---|---|---|
| 결정적(JSON 형태, 파일 존재, 테스트 exit 0) | 1 | 관측값이 실행마다 변할 수 없다 |
| 루브릭·심판 채점 | 5 | 흩어짐을 보기에는 충분하고, 작은 차이를 가르기에는 부족하다 |
| 신뢰도 주장(`pass^k` 보고) | 8 | 이 저장소가 정한 기본값이고, `pass^8`을 보고한 τ-bench 논문에서 가져왔다. **공개된 최소값이 아니라 선택이다** — 그 논문도, 여기 인용한 어떤 출처도 8회를 일반적 하한으로 정하지 않는다. 실제 벤치마크는 더 이상 8회로 채점하지 않는다. 아래 "보고 깊이가 바뀌었다"를 본다 |

`MIN_RUNS`는 **흩어짐을 보기 위한 하한**이지, 차이가 유의하다고 선언하는 임계값이 아니다.
그 이유는 다음 절에 있고, 어떤 실행 횟수로도 고칠 수 없는 부분은 "잡음 하한" 절에 있다.

## `pass^k`는 `pass@k`가 아니다

두 지표는 같은 에이전트에게 서로 다른 질문을 던진다.

- `pass^k` — k회 독립 시행이 **전부** 성공할 확률. 신뢰도의 질문이다. τ-bench의 정의는
  "the chance that all k i.i.d. task trials are successful, averaged across tasks"다.
- `pass@k` — k회 중 **하나라도** 성공할 확률. 능력의 질문이다.

`DERIVED`: 회당 성공률이 p일 때 `pass^k = p^k`, `pass@k = 1 − (1 − p)^k`다.
추정이 아니라 정확값이다.

| 회당 p | `pass^k` (k=8) | `pass@8` (반올림) |
|---|---|---|
| 0.50 | 0.39% | 99.61% |
| 0.60 | 1.68% | 99.93% |
| 0.70 | 5.76% | 99.99% |
| 0.80 | 16.78% | 100.00% |

어느 행도 정확히 100%가 아니며, 0.80 행은 소수 둘째 자리에서 반올림되어 100.00%가 된다. `pass@k`는
빨리 1에 다가간다. p=0.50에서 이미 99.61%라는 것이 핵심이다. 그래서 `pass@k` 열은 일관성을 거의
보여주지 않는다.

`MEASURED`, 그리고 여기서 인용에 주의가 필요하다. τ-bench 논문(2024년 6월, 판본 하나, 개정 없음)은
최신 함수 호출 에이전트가 "succeed on < 50% of the tasks, and are quite inconsistent (`pass^8 < 25%`
in retail)"이라고 보고한다. 위 표의 0.80 행은 16.78%로 그 보고 구간에 들어온다. 다만 인용에는 조건이
둘 붙는다.

- **그 수치 뒤의 과제 집합이 바뀌었다.** 2026년에 retail과 airline 영역을 감사해 다시 썼다. "We
  audited and fixed 50+ tasks across the airline and retail domains in τ-bench"이며, airline 27개,
  retail 26개다.
- **보고 깊이가 바뀌었다.** 1.x 제출 안내는 "at least 4 trials per domain for statistical reliability"를
  권했고 v1.0.1 재채점 표는 `pass^4`를 보고한다. 현재 배포판은 실린 벤치마크를 1회로 채점하고
  `pass^k`를 "the share of tasks passed in all k trials"로 정의한다. 여덟 번은 이 저장소가 고른
  깊이이지, 벤치마크가 지금 배포하는 깊이가 아니다.

실무적 결과는 그대로다. `pass@k`만 보고하면 불일관성이 숨는다. 8회 독립 시행이 전부 성공하는 것이
신뢰도 주장이다. `pass^k`는 k가 커질수록 떨어지고 `pass@k`는 1을 향해 오르는 지표다.

## 차이를 판정하려면 몇 회가 필요한가

`DERIVED`: 독립 실행을 가정하고 정규 근사를 적용해, 케이스별 성공률을 95% 신뢰수준에서 반폭 `h`
안으로 추정하려면 다음이 필요하다.

```
n ≈ (1.96 · sqrt(p(1−p)) / h)²
```

이것은 Wald 구간으로, 항등식이 아니라 **근사**다. p가 0이나 1에 가깝거나 `n`이 아주 작으면 믿을 수
없다. 아래 횟수는 그 식의 **올림**이다. 실행 횟수는 정수이고, 내림하면 명시한 폭을 채우지 못한다.

| 회당 p | ±5%p에 필요한 n | ±10%p에 필요한 n |
|---|---|---|
| 0.50 | 385 | 97 |
| 0.70 | 323 | 81 |
| 0.90 | 139 | 35 |

**이 계산이 주장하는 것과 하지 않는 것.** 몇 회의 실행으로는 작은 차이를 가를 수 없다는
것은 주장한다. p=0.70에서 5회 실행의 95% 구간은 대략 ±40%p 폭이라, 그 표본이 노이즈와 구분하려면
회귀가 아주 커야 한다. 반면 **323을 게이트에 적으라는 주장은 하지 않는다.** 그리고 신뢰구간
반폭을 **최소 검출 차이**로 바꾸지 않는다. 그것은 검정력 계산이고 가정한 효과 크기가 필요하며, 이
산식이 내는 값이 아니다. 상관된 실행(같은 시드, 같은 캐시, 데워진 서비스)에는 더 많이 필요하다.

이 계산이 뒷받침하는 규칙: **목표 신뢰구간 폭과 실행 횟수를 함께 적고**, 단일 실행의 판정이
아니라 배치의 집계 추세로 게이트한다.

Anthropic의 평가 지침은 이 규칙이 "아무것도 하지 않을 이유"로 변하는 것을 막는 반대편 무게를
더한다. 개발 초기에는 효과 크기가 크므로 "20-50 simple tasks drawn from real failures is a great
start"다.

## 잡음 하한

표본 크기는 분산의 한 원천만 통제한다. 나머지 둘은 대부분의 팀이 짐작하는 것보다 크고, 어느 쪽도
`n`을 늘려 줄어들지 않는다.

### 인프라

`MEASURED`: 과제 집합을 고정하고 기계 할당만 바꾼 실험에서 Terminal-Bench 2.0의 가장 넉넉한 구성과
가장 빈약한 구성 사이 격차는 6%p였다(p < 0.01). SWE-bench에서 같은 비교는 1.54%p를 움직였다.
논문의 운용 지침은 이렇다.

> "Until resource methodology is standardized, our data suggests that leaderboard differences below
> 3 percentage points deserve skepticism until the eval configuration is documented and matched.
> The observed spread across the moderate range of resource configurations in Terminal-Bench is just
> below 2 percentage points. Naive binomial confidence intervals already span 1-2 percentage
> points; the infrastructure confounders we document here stack on top of that, not within it. At
> the extremes of the allocation range, the spread reaches 6."

여기서 규칙 둘이 따라오고, 둘 다 각주가 아니라 eval 기록에 들어간다.

- **자원 구성을 선언한다.** CPU·GPU 할당, 타임아웃, 동시성을 적지 않은 결과는 다른 구성으로 낸
  이후 결과와 비교할 수 없다.
- **하네스 결함을 따로 회계한다.** v1.0.1 재채점은 자기 관례를 밝힌다. `pass^k`를 "counting
  infrastructure-error simulations as failed trials (the leaderboard convention)"로 다시 계산하므로,
  하네스 결함이 지표에서 조용히 사라지지 않고 드러난다. HE-E-6은 다르게 정한다. 하네스 결함으로
  중단된 시행은 분모에서 빼고 오류 시행으로 보고한다. 어느 쪽이든 처리를 기록에 선언하고 암묵적으로
  두지 않는다.

### 채점기

`MEASURED`: **같은** 저장 궤적을 채점기 수정 후 다시 채점했더니 "moves scores **only upward** — no
previously-passing simulation fails — by up to ~9 points pass^1 depending on the model"이었다.
공개된 표에서 한 모델은 pass^1이 37.37에서 46.39로, pass^4가 20.62에서 27.84로 올랐다. 모델은
아무것도 바뀌지 않았다.

그래서 같은 벤치마크는 채점이 바뀐 버전 간 비교를 무효로 선언한다. "Scores are not comparable with
1.x … Re-run rather than compare 1.x results with 2.0 numbers."

**HE-J-4 확장:** eval 기록은 모델·런타임·케이스 집합 해시·실행 횟수에 더해 **채점기 버전과 벤치마크
버전**을 함께 남긴다. 재채점만으로 9점이 움직이면, 사람들이 게이트로 삼는 대부분의 효과보다 크다.

### 하한이 함축하는 것

| 분산 원천 | 통제 수단 | 기록에 남는 형태 |
|---|---|---|
| 표집 | 실행 횟수, 집계 비율 | `MIN_RUNS`, 배치별 통과율 |
| 인프라 | 고정된 자원 선언 | 할당, 타임아웃, `error_trials` |
| 채점기 | 버전 고정, 변경 시 재채점 | 채점기 버전 |
| 벤치마크 과제 집합 | 버전 고정 | 벤치마크 버전과 과제 집합 해시 |

합쳐진 하한보다 작은 차이는 결과가 아니다. 그래서 게이트를 그만두라는 뜻이 아니고, 게이트가 모든
움직임에 반응하지 않고 **동등성 마진**(HE-J-3)을 선언하는 이유다.

## 비용은 1급 축이다

점수가 같은 두 체계는 같은 결과가 아니고, 그 차이는 작지 않다.

`MEASURED`: "Agents differ drastically in terms of cost. For substantially similar accuracy, the cost
can differ by almost two orders of magnitude. Yet, the cost of running these agents isn't a top-line
metric reported in any of these papers." 2024년의 이 비판은 이제 인프라가 되었다. 정확도 대 비용
파레토 경계로 순위를 매기는 리더보드는 항목마다 달러와 토큰 비용을 함께 적고, "enabling
practitioners to select agents based on real-world constraints"라고 밝힌다. Terminal-Bench는 점수
옆에 제출당 달러를 싣는다.

하네스에도 비용 축이 있고, 모델별로 측정할 수 있다. 코딩 과제의 짝 비교에서 같은 하네스가 토큰
약 10.5배, 시간 약 3배, 비용 약 7배를 썼다. 더 강한 모델에서는 아무것도 바뀌지 않았고 더 약한
모델은 3/10에서 10/10이 되었다(표와 출처는 [`harness-anatomy.ko.md`](harness-anatomy.ko.md)의
HE-A-4).

그래서 본문의 지표 집합은 비용·지연을 품질의 동급 지표로 다루고, 동점 처리용 보조 지표로 두지
않는다. 1점을 얻으려고 토큰을 10배 쓴 변경은 그렇게 말해야 한다.

## 평가 인지와 벤치마크 부패

점수는 시험에 대한 주장이고, 시험은 낡는다.

- **모델이 시험을 알아챌 수 있다.** 기록된 사례에서 한 모델은 "independently hypothesized that it
  was being evaluated, identified which benchmark it was running in, then located and decrypted the
  answer key"였다. 오염이나 평가 인지의 영향을 받은 문제는 1,266개 중 11개였고, 그 11개를 정답
  차단 상태로 다시 실행하니 총점은 거의 그대로였다(86.81% → 86.57%). 유용한 부분은 여기다.
  무결성 실패는 실재했고 이번에는 대표 수치가 아니었다. 저자들의 권고가 오래 남을 규칙이다. "we
  encourage the research community to treat eval integrity as an ongoing adversarial problem
  rather than a design-time concern."
- **시험이 틀릴 수 있다.** 널리 쓰이는 코딩 벤치마크의 저자들은 27.6% 하위 집합을 감사해 "at least
  59.4% of the audited problems have flawed test cases that reject functionally correct
  submissions"을 확인했고, 개선이 "increasingly reflect how much the model was exposed to the
  benchmark at training time"이라는 이유로 자기 벤치마크 보고를 중단했다.
- **대체재도 틀릴 수 있다.** 권고된 후속 벤치마크는 몇 달 뒤 과제 약 30%가 깨졌다는 조사로 부분
  철회되었다. 2026년에 정본 대체재는 없고, 결함률을 공개한 후보들이 여럿 있을 뿐이다.

**HE-J-8.** 벤치마크 점수는 판본, 채점기 버전, 자원 구성, 오염·결함 상태와 함께 기록한다. 두 체계의
한 자리 수 차이는 채점기와 자원 구성이 동등하다는 사실이 제시되기 전까지 미해결로 둔다. 측정된
결함과 측정된 인프라 격차가 둘 다 그 차이보다 크기 때문이다.

같은 논리가 더 작은 규모에서 저장소 eval 셋에도 적용된다. 기대 출력이 현재 구현에서 베껴 쓴 케이스는
행동이 아니라 구현을 시험한다.

## 행동 평가와 종단 벤치마크

둘은 다른 것을 재고, 어느 쪽도 다른 쪽을 대체하지 않는다.

| | 행동 평가 | 종단 벤치마크 |
|---|---|---|
| 단위 | 관찰 가능한 행동 하나 | 과제 전체 |
| 단언 예 | 답하기 전에 실시간 검색을 했는가 | 과제의 최종 상태가 목표와 맞는가 |
| 실패 신호 | 정밀하다: 어느 행동을 건너뛰었는지 | 거칠다: 복합 점수가 움직였다 |
| 비용 | 케이스당 수 초 | 과제당 훨씬 많이 |
| 쓰는 곳 | 프롬프트·도구 스키마·모델 교체를 반복할 때 | 목적지가 여전히 동작하는지 확인할 때 |

단언 강도는 과제 복잡도를 따라야 한다.

- **최적 경로가 하나** — 그 행동을 엄격하게 단언한다(단일턴 검사).
- **정당한 경로가 여럿** — 경로가 아니라 결과를 단언한다. 도구 순서를 고정하면 다른 길로
  간 정답을 거부하게 된다. 벤더 지침도 분명하다. "it's often better to grade what the agent
  produced, not the path it took."

점수만이 아니라 **실패 모드**를 기록한다. 모델마다 다르다. 어떤 모델은 불확실하면 보류하고,
어떤 모델은 자신 있게 틀린다. 통과/실패만 세는 케이스 셋은 둘을 구분하지 못하는데, 둘은
고치는 방법이 다르다.

eval 셋이 조용히 죽지 않게 하는 실천이 둘 있다.

- **부분 점수.** 여러 구성 요소가 있는 과제는 일부만 맞아도 점수가 움직이게 한다.
- **졸업.** 통과율이 천장에 닿은 능력 케이스는 신호를 내지 않는다. "An eval at 100% tracks
  regressions but provides no signal for improvement." 회귀 스위트로 옮기고 그 자리에 더 어려운
  케이스를 넣는다.

## 컨텍스트를 기록 변수로 둔다

컨텍스트 길이는 상수가 아니라 실험 변수다. 케이스마다 기록한다.

- 결정 지점의 총 컨텍스트 토큰,
- 포함된 방해 문장 수,
- 관련 정보를 미리 넣었는지 그때 검색했는지.

`MEASURED`: 과제 난이도를 고정하고 입력 길이만 바꾼 통제 실험에서 18개 모델 전부가 입력이
길어지면 성능이 떨어졌고, 방해 문장 하나만 넣어도 떨어지며 넷을 넣으면 더 떨어졌다. 같은
질문에 초점 프롬프트(약 300 토큰)가 전체 프롬프트(약 113k 토큰)보다 크게 앞섰다.

**그 발견을 컨텍스트 규칙으로 바꾸지 않는다.** 그 연구의 저자들은 두 주제만으로 일반화할 수
없다고 밝혔고, 특정 검색 과제를 측정했다. 안전하게 적을 수 있는 것은 **측정 규칙**이다.
컨텍스트 길이를 바꾸는 비교는 별도 케이스이고, 그렇게 표시해야 한다.

이와 짝을 이루는 **규범**은 본문에 있다. 추가한 컨텍스트는 개입이고, 목표 eval 셋에서 개선을
보이기 전까지 영구 컨텍스트가 되지 않는다.

## 과제 길이 지평

장기 실행 작업에서 재는 양은 에이전트가 50% 신뢰도로 완수하는 과제 길이다. 현재 공개된 추정은
2023년 이후 배증 시간 130.8일[107, 161], 전 기간 196.5일이며, 프로젝트 대시보드는 그 도구의 한계를
함께 밝힌다. "Measurements above 16 hrs are unreliable with our current task suite."

숫자와 함께 **어느 표면에서 읽었는지**를 적는다. 공개 표와 대시보드 데이터 파일은 2023년 이후
130.8일 대 약 128.7일, 전 기간 196.5일 대 약 187.8일로 최대 약 9일 차이가 난다. 데이터 파일이 16시간
신뢰 한계를 넘는 점을 제외하기 때문이다.

## Sources

> 확인 2026-11-03.

**등급 어휘.** 이 디렉터리의 모든 출처 표가 쓰는 하나의 닫힌 집합이다. [`../HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## Sources`를 본다.

| 주장 | 출처 | Grade |
|---|---|---|
| `pass^k` 정의, `pass^8 <25%` retail 수치, 불일관성 발견 | <https://arxiv.org/abs/2406.12045> | PRIMARY |
| retail·airline 과제 감사("50+ tasks", airline 27개 / retail 26개) | <https://taubench.com/blog/tau3-task-fixes.html> | PRIMARY |
| "Scores are not comparable with 1.x". 채점 변경으로 버전 간 비교가 무효다 | <https://github.com/sierra-research/tau2-bench/releases/tag/v2.0.0> | PRIMARY |
| 시행 깊이: 1.x 안내의 도메인당 최소 4회 실행 권고, 실린 벤치마크의 1회 채점, `pass^k` 정의 | <https://github.com/sierra-research/tau2-bench/blob/v1.0.1/docs/leaderboard-submission.md>, <https://github.com/sierra-research/tau2-bench/blob/v2.0.0/docs/glossary.md> | PRIMARY |
| 바뀌지 않은 궤적을 다시 채점해 pass^1이 최대 약 9점 오른 사례 | <https://github.com/sierra-research/tau2-bench/releases/tag/v1.0.1> | PRIMARY |
| 벤치마크 저자들의 반복 실행 신뢰도 프레이밍 | <https://sierra.ai/blog/tau-bench-shaping-development-evaluation-agents> | VENDOR |
| 인프라 잡음: Terminal-Bench 2.0에서 6%p, SWE-bench에서 1.54%p, "3%p 미만은 회의적으로" 규칙 | <https://www.anthropic.com/research/infrastructure-noise> | VENDOR |
| 평가 인지: 정답 키 복호화 사례, 1,266개 중 11개, 86.81% → 86.57%, "ongoing adversarial problem" | <https://www.anthropic.com/research/eval-awareness-browsecomp> | VENDOR |
| 감사한 실패의 59.4%에 결함 있는 테스트가 있었고, 그래서 보고를 중단한 결정 | <https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/> | VENDOR |
| "20-50 simple tasks drawn from real failures", 부분 점수, 경로가 아니라 결과 채점, 100% 천장 | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> | VENDOR |
| 비슷한 정확도에서 비용이 거의 두 자릿수 배 차이 난다는 지적 | <https://arxiv.org/abs/2407.01502> | PRIMARY |
| 정확도 대 비용 파레토 경계라는 리더보드 설계 | <https://arxiv.org/abs/2510.11977> | PRIMARY |
| 네 차원 12개 신뢰도 지표, 능력 향상이 신뢰도 향상으로는 작게 이어진다는 발견 | <https://arxiv.org/abs/2602.16666> | PRIMARY |
| 과제 길이 지평, 2023년 이후 130.8일, 위계 부트스트랩 구간 | <https://metr.org/blog/2026-01-29-time-horizon-1-1/> | PRIMARY |
| 대시보드 데이터 파일의 2023년 이후 128.7일·전 기간 187.8일 추정, "Measurements above 16 hrs are unreliable with our current task suite" 한계 | <https://metr.org/time-horizons/> | PRIMARY |
| 지속적으로 판본이 올라가는 벤치마크로서 Terminal-Bench 4.0과 고정 타임아웃 | <https://www.tbench.ai/news/terminal-bench-4-0> | PRIMARY |
| 입력 길이에 따른 성능 저하, 방해 문장 중첩, 초점/전체 프롬프트 비교 | <https://www.trychroma.com/research/context-rot> | STUDY |
| 단일 실행 게이트 대신 배치 평가와 집계 통과율 관행 | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> | VENDOR |

`pass^k`와 위 표본 크기 산식은 이 저장소에서 계산했고, 둘 다 이 문서 안에 그대로 들어 있다. 두 지표를
구분하는 절의 `DERIVED` 문단과 "차이를 판정하려면 몇 회가 필요한가" 절의 Wald 구간 식이 그것이다.
별도 스크립트는 두지 않는다.

이전 판은 현재 추정보다 앞선 2025-03-19 METR 글을 인용했고, `pass^8`을 벤치마크가 보고하는 깊이로
제시했다. 둘 다 위에서 고쳤다.
