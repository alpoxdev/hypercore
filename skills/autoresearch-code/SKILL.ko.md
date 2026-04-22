---
name: autoresearch-code
description: "기존 코드베이스를 baseline-first 실험, 이진 평가(binary eval), 단일 변이 반복으로 최적화한다. Use when: 코드베이스 autoresearch, 반복 실험으로 병목 개선, benchmark code optimizations, measured code refactor."
compatibility: 읽기/수정/쓰기, 셸 실행, 코드 검증 도구를 함께 쓸 때 가장 잘 동작하며, 반복 평가와 아티팩트 기록에 적합하다.
---

@rules/experiment-loop.md
@rules/validation-and-exit.md

# 코드 오토리서치

> 한 번에 크게 뜯어고치지 말고, 측정 가능한 반복 실험으로 기존 코드베이스를 개선한다.

<purpose>

- 기존 코드베이스의 baseline을 먼저 잡고, 결과를 이진 평가로 점수화한 뒤, 점수를 올리는 변경만 남긴다.
- 실패 원인이 느린 경로, 불명확한 구조, 중복 로직, 과한 산출물 크기, 흔들리는 검증, 취약한 개발자 워크플로에 있을 때 이를 체계적으로 개선한다.
- 개선된 코드와 함께 `.hypercore/autoresearch-code/[codebase-name]/` 아래에 `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`, `baseline.md`를 남겨 이후 실행자가 이어서 최적화할 수 있게 한다.

</purpose>

<routing_rule>

사용자가 기존 코드베이스를 반복 실험과 평가 기반으로 최적화하려 할 때 `autoresearch-code`를 사용한다.

단일 버그 수정, 한 번의 리팩터, 작고 검증이 자명한 변경이면 직접 수정이 더 적절하다.

다음은 이웃 워크플로로 보낸다:

- 증상이 분명한 단일 버그: `bug-fix` 또는 직접 범위 수정
- 새 스킬 생성이나 스킬 폴더 리팩터링: `skill-maker`
- 주된 산출물이 런북, 스펙, 문서: `docs-maker`
- 버전 올리기나 버전 파일 동기화: `version-update`

다음 경우에는 `autoresearch-code`를 사용하지 않는다:

- 최적화할 기존 코드베이스가 없다
- 반복 최적화가 아니라 새 프로젝트 스캐폴딩이 목적이다
- baseline, eval, 반복 점수화 없이 단발성 수동 변경만 원한다

</routing_rule>

<trigger_conditions>

긍정 예시:

- "이 저장소에 autoresearch 돌려서 점수 오르는 최적화만 남겨줘."
- "빌드 시간, 번들 크기, 테스트 안정성을 벤치마크하고 반복 실험해줘."
- "이 코드베이스 병목을 찾아서 측정 가능한 실험으로 개선해줘."

부정 예시:

- "새 Vite 앱 하나 만들어줘."
- "이 테스트 하나만 고치고 끝내."

경계 예시:

- "이 코드베이스 한 번만 다듬고 리뷰해줘."
  반복 실험을 명시하지 않았다면 보통 직접 수정이 더 적절하다.

</trigger_conditions>

<supported_targets>

- 기존 저장소와 다중 파일 코드 영역
- 성능, 유지보수성, 신뢰성, DX, 비용과 관련된 코드 병목
- baseline 캡처, 실험 기록, 아티팩트 대시보드
- 측정 결과를 실질적으로 개선하는 구조 리팩터링

</supported_targets>

<required_inputs>

첫 변이 전에 다음을 수집한다:

1. 대상 범위. 기본값: 현재 저장소 루트
2. 최적화 목표. 예: 빌드 시간, 번들 크기, 지연 시간, flaky test, query 수, 중복, 메모리 사용량
3. 평가 팩. `generic`, `web`, `node`, `api`, `monorepo` 중 하나
4. 현재 동작을 증명할 proof command. 기존 build, test, typecheck, benchmark, smoke 명령을 우선한다
5. 테스트 프롬프트 또는 시나리오 3~5개
6. 이진 평가 3~6개
7. 실험당 실행 횟수. 기본값: `5`
8. 선택 예산 상한

입력 정책:

- 사용자가 명확한 목표를 이미 줬고 작업이 저위험이면 보수적인 기본값을 추론해 baseline 전에 기록한다.
- 빠진 정보 때문에 eval이 무의미해지거나 병목 방향을 잘못 잡게 될 때만 확인 질문을 한다.
- baseline 계획이 명시되기 전에는 코드베이스를 변이하지 않는다.

넓은 코드 최적화 요청인데 사용자가 프롬프트 팩을 주지 않았다면:

- 먼저 [references/self-test-pack.md](references/self-test-pack.md)에서 도메인 팩을 고른다
- 맞는 도메인 팩이 없을 때만 generic 팩으로 내린다
- 선택한 팩, 팩 버전, 하네스에서 벗어난 사항을 점수화 전에 실험 로그에 기록한다

</required_inputs>

<language_support>

- 한국어 요청, 한국어 평가 문구, 한국어 대시보드 라벨을 기본적으로 허용한다.
- 명령어, 파일명, JSON 키, 코드 식별자처럼 기계가 소비하는 문자열은 기존 ASCII 계약을 유지한다.
- core와 self-test-pack에는 한국어 요청 예시를 포함해 실제 사용자 입력 언어를 평가할 수 있어야 한다.

</language_support>

<scope_contract>

실험 `0` 전에:

- 실행이 저장소 루트, 하위 디렉터리, 또는 큰 코드베이스 안의 패키지 하나를 소유하는지 확정한다
- 한 실험 루프에 여러 저장소를 섞지 않는다
- 소유 범위와 패키지/모듈 경계를 `baseline.md`에 기록한다
- 소유 범위가 중간에 바뀌면 다시 점수화하기 전에 baseline을 초기화한다

</scope_contract>

<baseline_contract>

실험 `0` 전에:

- 실행 전체에서 재사용할 proof command를 고른다
- 어떤 코드도 수정하기 전에 `baseline.md`를 쓴다
- 현재 지표, pass/fail 관찰, 비회귀 제약을 기록한다
- proof command나 점수 조건이 바뀌면 suite reset으로 로그에 남기고 다시 baseline을 잡는다

baseline 형태가 불명확하면 [references/code-baseline-guide.md](references/code-baseline-guide.md)를 사용한다.

</baseline_contract>

<autonomy_contract>

baseline 계획이 명시된 뒤에는:

- 같은 프롬프트 팩과 eval 묶음을 실험 전체에서 재사용한다
- 막힘, 안전 이슈, 잘못 설계된 eval 세트가 아니면 실험 사이에 멈추지 않는다
- 한 번에 하나의 변이만 적용한다
- eval 세트 변경이나 점수 방식 변경은 계속하기 전에 명시적 이벤트로 로그에 남긴다

</autonomy_contract>

<skill_architecture>

핵심 스킬은 트리거, 맡은 일, 워크플로, 변이 규율에만 집중한다.

지원 파일은 의도적으로 로드한다:

- 초기 지표와 제약 수집은 [references/code-baseline-guide.md](references/code-baseline-guide.md)를 사용한다.
- 코드 최적화용 이진 평가는 [references/eval-guide.md](references/eval-guide.md)를 사용한다.
- 대시보드, 결과 파일, 변경 로그, 워크스페이스 스키마는 [references/artifact-spec.md](references/artifact-spec.md)를 사용한다.
- 사용자가 넓은 최적화 요청만 줬다면 [references/self-test-pack.md](references/self-test-pack.md)에서 적절한 도메인 팩을 고른다.
- 병목 형태가 이미 분명하면 아래 도메인 팩 중 하나를 직접 쓴다:
  - [references/self-test-pack.web.md](references/self-test-pack.web.md)
  - [references/self-test-pack.node.md](references/self-test-pack.node.md)
  - [references/self-test-pack.api.md](references/self-test-pack.api.md)
  - [references/self-test-pack.monorepo.md](references/self-test-pack.monorepo.md)
- `scripts/render-dashboard.sh`로 정식 대시보드 템플릿에서 `dashboard.html`과 `results.js`를 생성한다.

아티팩트 생명주기 요구사항:

- `.hypercore/autoresearch-code/[codebase-name]/` 아래에 워크스페이스를 만든다
- 매 실험 뒤 `results.tsv`와 `results.json`을 동기화한다
- 소유 범위, 선택한 팩, 환경, 롤백 조건을 아티팩트에 기록한다
- `dashboard.html`은 `results.json`을 기반으로 하는 실시간 보기로 취급한다
- 루프 중에는 `results.json.status`를 `running`, 종료 시에는 `complete`로 둔다
- 로컬 브라우저에서 `file://`로 직접 열어도 대시보드가 정상 렌더되어야 한다
- 런타임이 안전하게 로컬 HTML을 열 수 있으면 대시보드를 즉시 연다

코드베이스 구조가 약할 때는:

- 새 추상화보다 dead code 삭제를 우선한다
- 코드베이스가 이미 지원하는 구조일 때만 반복 정책을 기존 로컬 문서나 룰로 옮긴다
- 각 실험은 설명과 검증이 가능한 범위로 충분히 작게 유지한다

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | 대상 범위와 현재 검증 표면을 읽는다 | Baseline 이해 |
| 1 | 성공 조건을 이진 평가로 바꾼다 | Eval 세트 |
| 2 | 실험 워크스페이스와 아티팩트를 초기화한다 | `.hypercore/autoresearch-code/[codebase-name]/` |
| 3 | 수정 전 코드베이스로 실험 `0`을 돌린다 | Baseline 점수 |
| 4 | 한 번에 하나의 변이만 적용하는 실험을 반복한다 | Keep/Discard 결정 |
| 5 | 최종 결과를 검증하고 실험을 요약한다 | 최종 보고 |

### Phase details

#### Phase 0: 대상 이해

- 관련 코드 영역, build/test 명령, 시스템을 정의하는 기존 문서를 읽는다.
- 명령을 고르기 전에 소유 저장소 또는 하위 범위를 확정한다.
- 주요 실패가 성능, 신뢰성, DX, 구조, 출력 크기 중 무엇인지 식별한다.
- eval을 쓰기 전에 병목에 맞는 도메인 팩을 고른다.
- 비회귀 제약과 이를 증명할 명령을 먼저 기록한다.
- 어떤 수정도 하기 전에 초기 지표를 캡처한다.

#### Phase 1: Eval 세트 구성

- 성공 조건을 이진 pass/fail 체크로 바꾼다.
- eval은 서로 겹치지 않고 관찰 가능하며 속이기 어려워야 한다.
- 최소 하나는 일반 코드 품질이 아니라 사용자의 실제 병목을 직접 검사해야 한다.

#### Phase 2: 워크스페이스 준비

- 저장소 루트에 `.hypercore/autoresearch-code/[codebase-name]/`를 만든다.
- 원래 상태를 `baseline.md`에 기록한다.
- [references/artifact-spec.md](references/artifact-spec.md)를 따라 `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`을 초기화한다.
- 정식 템플릿을 `scripts/render-dashboard.sh`로 렌더한다.

#### Phase 3: Baseline 확정

- 어떤 수정도 하기 전에 현재 코드베이스를 실행한다.
- 모든 실행을 모든 eval에 대해 점수화한다.
- 실험 `0`을 `baseline`으로 기록한다.

#### Phase 4: 실험 루프

- 실패한 출력에서 가장 가치가 큰 실패 패턴을 찾는다.
- 하나의 가설만 세운다.
- 하나의 변이만 적용한다.
- 같은 eval 세트를 다시 돌린다.
- 점수가 오르면 유지한다. 점수가 같거나 나빠지면, 무회귀 단순화가 아니라면 버린다.
- 버린 실험도 포함해 모든 실험을 기록한다.

#### Phase 5: 종료 및 전달

- [rules/validation-and-exit.md](rules/validation-and-exit.md)에 따라 사용자 중단, 예산 한도, 안정적 고득점 중 하나가 충족되면 멈춘다.
- 점수 변화, 총 실험 수, keep 비율, 가장 효과적이었던 변경, 남은 실패 패턴, 최적 실험이 `keep`에 머무는지 `promote` 가능한지까지 보고한다.

</workflow>

<mutation_defaults>

선호하는 변이 유형:

- hot path의 중복 로직 제거
- 측정 가능한 병목에 캐시, 배치, 가드 하나 추가
- 중복 브랜치나 죽은 의존성 하나 제거
- 비싼 연산 하나를 critical path 밖으로 이동
- 재작업을 줄이는 검증 단계 하나를 앞쪽으로 당김
- 측정 가능한 부담만 늘리는 설정이나 추상화 삭제

피해야 할 변이 유형:

- 코드베이스 전체를 처음부터 다시 쓰기
- 무관한 변경 여러 개를 한 실험에 묶기
- 측정 근거 없이 의존성 추가
- 사용자가 중요하게 보지 않는 surrogate metric만 최적화하기

</mutation_defaults>

<deliverables>

실행이 끝나면 다음이 남아 있어야 한다:

- 개선된 코드 변경
- `.hypercore/autoresearch-code/[codebase-name]/dashboard.html`
- `.hypercore/autoresearch-code/[codebase-name]/results.json`
- `.hypercore/autoresearch-code/[codebase-name]/results.js` 또는 이에 준하는 파일 기반 브리지
- `.hypercore/autoresearch-code/[codebase-name]/results.tsv`
- `.hypercore/autoresearch-code/[codebase-name]/changelog.md`
- `.hypercore/autoresearch-code/[codebase-name]/baseline.md`

파일 스키마와 예시는 [references/artifact-spec.md](references/artifact-spec.md)를 따른다.

</deliverables>

<validation>

한국어 지원을 포함해 다음을 만족해야 한다:

- core와 self-test-pack에서 한국어 요청 예시를 통해 트리거 경계를 검증할 수 있다
- baseline-first, one-mutation-at-a-time, explicit stop condition이 유지된다
- 범위, 팩, proof command, 환경, 롤백 조건이 아티팩트에 명시된다
- 대시보드와 지원 문서가 한국어로 읽혀도 데이터 계약은 깨지지 않는다

</validation>
