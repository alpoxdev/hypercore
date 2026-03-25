# Self-Test Pack

코드 오토리서치를 돌리는데 사용자가 별도의 프롬프트 팩이나 eval 세트를 주지 않았을 때 이 레퍼런스를 사용한다.

이 파일은 이제 단일 팩이 아니라 팩 선택기다. 대상과 가장 잘 맞는 가장 좁은 도메인 팩을 먼저 고른다:

| 대상 형태 | 팩 |
|------|------|
| 프론트엔드 성능, 렌더링, 번들 작업 | [self-test-pack.web.md](self-test-pack.web.md) |
| Node 런타임, CLI, 백그라운드 작업 | [self-test-pack.node.md](self-test-pack.node.md) |
| API 지연 시간, query 수, 요청 경로 | [self-test-pack.api.md](self-test-pack.api.md) |
| 모노레포, 워크스페이스 레벨 정리 | [self-test-pack.monorepo.md](self-test-pack.monorepo.md) |
| 아직 명확한 분류가 없음 | 이 파일의 generic 팩 |

팩 선택 순서:

1. trace 기반 또는 incident 기반 팩이 있으면 우선 사용한다.
2. 병목 유형이 분명하면 도메인 팩을 사용한다.
3. 아직 탐색 단계라면 generic 팩으로 내린다.

## Generic 기본 테스트 프롬프트

명확한 도메인 팩이 없을 때만 아래 프롬프트를 사용한다:

1. `이 저장소에 autoresearch 돌려서 점수 오르는 최적화만 남겨줘.`
2. `이 코드베이스를 binary eval로 벤치마크하고 아티팩트를 .hypercore에 저장해줘.`
3. `이 코드베이스의 가장 큰 병목을 찾아서 측정 가능한 반복 실험으로 개선해줘.`
4. `이 버그 하나만 고치고 끝내.`
5. `Run autoresearch on this repo and keep only score-improving optimizations.`

예상 라우팅:

- 프롬프트 1, 2, 3, 5는 `autoresearch-code`를 트리거해야 한다
- 프롬프트 4는 경계 사례이며, 반복 실험을 명시하지 않았다면 보통 직접 수정이 더 적절하다

## Generic 기본 이진 Eval

generic 팩에서는 다음 eval을 기본으로 사용한다:

```text
EVAL 1: 트리거 경계
Question: 이 프롬프트가 스킬 범위 안인지, 밖인지, 경계 사례인지 core만 보고 분명하게 알 수 있는가?
Pass: core 스킬만 읽어도 범위 판정이 명확하다
Fail: 범위 판정이 추측에 의존하거나 core가 가리키지 않은 support file까지 뒤져야 한다

EVAL 2: 워크플로 준비도
Question: 에이전트가 이 스킬만 보고도 다음 행동을 추측 없이 시작할 수 있는가?
Pass: baseline-first 실행 또는 route-away 결정을 시작하기에 충분한 가이드가 있다
Fail: 다음 행동이 모호하거나, 빠져 있거나, 서로 충돌한다

EVAL 3: Baseline 규율
Question: 범위 안 프롬프트에 대해 코드 수정 전에 baseline 지표를 잡는 방식이 분명하게 정의되어 있는가?
Pass: baseline 위치, 입력, no-edit-before-baseline 규칙이 명시되어 있다
Fail: baseline 계약이 불완전하거나, 서로 안 맞거나, 빠져 있다

EVAL 4: 아티팩트 생명주기
Question: 아티팩트 위치와 업데이트 주기가 분명하게 정의되어 있는가?
Pass: `.hypercore` 위치, 필수 파일, 상태/업데이트 기대치가 명시되어 있다
Fail: 아티팩트 계약이 불완전하거나, 서로 안 맞거나, 빠져 있다

EVAL 5: 변이 규율
Question: 이 스킬이 baseline-first, one-mutation-at-a-time 루프를 안정적으로 유지하는가?
Pass: baseline 점수화, 단일 변경 실험, 명시적 종료 조건이 유지된다
Fail: eval drift, 묶음 변이, 불명확한 종료 동작을 허용한다
```

## 점수화 노트

- 기본 총점: `5 prompts x 5 evals = 25`
- baseline과 후속 실험에서 같은 프롬프트 팩과 eval 세트를 유지한다
- 이 팩을 교체하면 다음 실험을 점수화하기 전에 교체 사실을 로그에 남긴다

## Override가 필요한 경우

다음 경우 이 팩을 교체한다:

- 사용자가 더 나은 도메인 맞춤 프롬프트를 제공했다
- 코드베이스의 병목이 매우 좁아 generic 팩으로는 충분히 검증되지 않는다
- 현재 실패가 구조 문제가 아니라 명백히 도메인 특화 문제다
