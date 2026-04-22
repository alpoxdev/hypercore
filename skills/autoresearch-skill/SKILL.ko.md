---
name: autoresearch-skill
description: "기존 Codex 스킬을 baseline-first 실험, 이진 평가(binary eval), 단일 변이 반복으로 최적화한다. Use when: 스킬을 반복 실험으로 개선하고 싶을 때, 스킬 autoresearch를 돌리고 싶을 때, self-optimize skill, benchmark a skill."
compatibility: 읽기/수정/쓰기와 셸 검색 도구를 함께 쓸 때 가장 잘 동작하며, 반복 평가와 아티팩트 기록에 적합하다.
---

@rules/experiment-loop.md
@rules/validation-and-exit.md

# 스킬 오토리서치

> 한 번에 크게 다시 쓰지 말고, 측정 가능한 반복 실험으로 기존 스킬을 개선한다.

<purpose>

- 기존 스킬의 baseline을 먼저 잡고, 이진 평가로 결과를 점수화한 뒤, 점수를 올리는 변경만 남긴다.
- 실패 원인이 애매한 트리거, 비대한 핵심 지침, 빈약한 지원 파일, 약한 검증 구조에 있을 때 스킬 구조까지 함께 보강한다.
- 개선된 스킬과 함께 `.hypercore/autoresearch-skill/[skill-name]/` 아래에 `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`, `SKILL.md.baseline`을 남겨 다음 에이전트가 이어서 작업할 수 있게 한다.

</purpose>

<routing_rule>

사용자가 기존 스킬을 반복 실험과 평가 기반으로 최적화하려 할 때 `autoresearch-skill`을 사용한다.

새 스킬 생성이나 한 번의 구조 리팩터링이 주된 작업이면 `skill-maker`를 사용한다.

다음 경우에는 `autoresearch-skill`을 사용하지 않는다:

- 최적화할 기존 스킬이 없다
- 일반 문서 개선이지 스킬 개선 워크플로가 아니다
- baseline, eval, 반복 점수화 없이 단발성 수동 수정만 원한다

</routing_rule>

<trigger_conditions>

긍정 예시:

- "`skills/web-clone/SKILL.md`에 autoresearch 돌려서 점수 오르는 수정만 남겨줘."
- "이 스킬을 binary eval로 벤치마크하고 `.hypercore`에 결과를 저장해."
- "이 스킬 프롬프트와 references를 반복 실험으로 개선해줘."

부정 예시:

- "브라우저 QA용 Codex 스킬 새로 만들어줘."
- "이 런북을 읽기 좋게만 다시 써줘."

경계 예시:

- "이 스킬 한 번만 다듬고 리뷰해줘."
  반복 실험을 명시하지 않았다면 보통 직접 수정이 더 적절하다.

</trigger_conditions>

<supported_targets>

- 기존 스킬 폴더 전체, 특히 `SKILL.md`와 연결된 `rules/`, `references/`
- 트리거 문구, 워크플로 명확성, 출력 규율, 검증 가이드
- 측정 결과를 실질적으로 개선하는 스킬 구조 리팩터링
- 다음 실행자가 그대로 이어받을 수 있는 실험 아티팩트

</supported_targets>

<required_inputs>

첫 변이 전에 다음을 수집한다:

1. 대상 스킬 경로
2. 테스트 프롬프트 또는 시나리오 3~5개
3. 이진 평가 3~6개
4. 실험당 실행 횟수. 기본값: `5`
5. 시간 기반 루프일 때 실행 간격. 기본값: `2 minutes`
6. 선택 예산 상한

입력 정책:

- 사용자가 핵심 의도와 범위를 이미 줬고 작업이 저위험이면 보수적인 기본값을 추론해 baseline 전에 기록한다.
- 빠진 정보 때문에 eval이 무의미해지거나 스킬을 잘못된 방향으로 밀 가능성이 있을 때만 확인 질문을 한다.
- baseline 계획이 명시되기 전에는 대상 스킬을 변이하지 않는다.

자기 자신이나 다른 스킬을 오토리서치하는데 사용자가 프롬프트 팩을 주지 않았다면:

- [references/self-test-pack.md](references/self-test-pack.md)를 기본 프롬프트/평가 하네스로 사용한다
- 한국어 요청을 기본으로 포함하고, 필요하면 영어 요청도 함께 유지한다
- 해당 하네스에서 벗어난 점은 점수화 전에 실험 로그에 먼저 기록한다

</required_inputs>

<language_support>

- 한국어 요청, 한국어 평가 문구, 한국어 아티팩트 설명을 기본적으로 허용한다.
- 파일명, 키 이름, 경로, 코드 식별자처럼 기계가 소비하는 문자열은 기존 ASCII 계약을 유지한다.
- 핵심 스킬과 self-test-pack에는 최소 한 개 이상의 한국어 긍정 예시와 한국어 비대상 예시가 있어야 한다.

</language_support>

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

- 이진 평가 설계는 [references/eval-guide.md](references/eval-guide.md)를 사용한다.
- 실패 원인이 잘못된 스킬 구조, 약한 지원 파일, 나쁜 트리거 문구일 때는 [references/skill-refactor-guide.md](references/skill-refactor-guide.md)를 사용한다.
- 대시보드, 결과 파일, 변경 로그, 워크스페이스 스키마는 [references/artifact-spec.md](references/artifact-spec.md)를 사용한다.
- 다른 스킬을 대상으로 하면서 기본 self-eval 하네스가 필요하면 [references/self-test-pack.md](references/self-test-pack.md)를 사용한다.
- `scripts/render-dashboard.sh`로 정식 대시보드 템플릿에서 `dashboard.html`과 `results.js`를 생성한다.

아티팩트 생명주기 요구사항:

- `.hypercore/autoresearch-skill/[skill-name]/` 아래에 워크스페이스를 만든다
- 매 실험 뒤 `results.tsv`와 `results.json`을 동기화한다
- `dashboard.html`은 `results.json`을 기반으로 하는 실시간 보기로 취급한다
- 루프 중에는 `results.json.status`를 `running`, 종료 시에는 `complete`로 둔다
- 로컬 브라우저에서 `file://`로 직접 열어도 대시보드가 정상 렌더되어야 한다
- 런타임이 안전하게 로컬 HTML을 열 수 있으면 대시보드를 즉시 연다

대상 스킬 자체의 구조가 약할 때는:

- 핵심 `SKILL.md`는 가볍게 유지한다
- 반복 정책은 `rules/`로 내린다
- 긴 예시와 세부 지식은 `references/`로 내린다
- 결정적 실행이 필요한 경우가 아니면 `scripts/`를 늘리지 않는다

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | 대상 스킬과 연결된 지원 파일을 읽는다 | Baseline 이해 |
| 1 | 성공 조건을 이진 평가로 바꾼다 | Eval 세트 |
| 2 | 실험 워크스페이스와 아티팩트를 초기화한다 | `.hypercore/autoresearch-skill/[skill-name]/` |
| 3 | 수정 전 스킬로 실험 `0`을 돌린다 | Baseline 점수 |
| 4 | 한 번에 하나의 변이만 적용하는 실험을 반복한다 | Keep/Discard 결정 |
| 5 | 최종 결과를 검증하고 실험을 요약한다 | 최종 보고 |

### Phase details

#### Phase 0: 대상 이해

- 대상 `SKILL.md` 전체를 읽는다.
- 직접 연결된 `rules/`와 `references/`를 읽는다.
- 실패가 동작 문제인지, 구조 문제인지, 둘 다인지 식별한다.

#### Phase 1: Eval 세트 구성

- 성공 조건을 이진 pass/fail 체크로 바꾼다.
- eval은 서로 겹치지 않고 관찰 가능하며 속이기 어려워야 한다.
- 대상이 스킬이면 문체가 아니라 트리거나 구조 품질을 확인하는 eval을 최소 하나 포함한다.

#### Phase 2: 워크스페이스 준비

- 저장소 루트에 `.hypercore/autoresearch-skill/[skill-name]/`를 만든다.
- 원본 파일을 `SKILL.md.baseline`으로 백업한다.
- [references/artifact-spec.md](references/artifact-spec.md)를 따라 `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`을 초기화한다.
- 정식 템플릿을 `scripts/render-dashboard.sh`로 렌더한다.

#### Phase 3: Baseline 확정

- 어떤 수정도 하기 전에 현재 스킬을 실행한다.
- 모든 실행을 모든 eval에 대해 점수화한다.
- 실험 `0`을 `baseline`으로 기록한다.

#### Phase 4: 실험 루프

- 실패한 출력에서 가장 가치가 큰 실패 패턴을 찾는다.
- 하나의 가설만 세운다.
- 하나의 변이만 적용한다.
- 같은 eval 세트를 다시 돌린다.
- 점수가 오르면 유지한다. 점수가 같거나 나빠지면 복잡성 증가 여부까지 보고 버린다.
- 버린 실험도 포함해 모든 실험을 기록한다.

#### Phase 5: 종료 및 전달

- [rules/validation-and-exit.md](rules/validation-and-exit.md)에 따라 사용자 중단, 예산 한도, 안정적 고득점 중 하나가 충족되면 멈춘다.
- 점수 변화, 총 실험 수, keep 비율, 가장 효과적이었던 변경, 남은 실패 패턴을 보고한다.

</workflow>

<mutation_defaults>

선호하는 변이 유형:

- 애매한 지침 하나를 더 명확히 한다
- 반복적으로 실패하는 패턴에 좁은 anti-pattern 하나를 추가한다
- 묻혀 있던 중요한 지침 하나를 앞쪽으로 옮긴다
- 부족한 동작을 보여 주는 worked example 하나를 추가하거나 개선한다
- 점수 상승 없이 복잡성만 키우는 프롬프트 무게를 덜어낸다
- 핵심에 과도하게 실린 내용을 `rules/` 또는 `references/`로 재배치한다

피해야 할 변이 유형:

- 스킬 전체를 처음부터 다시 쓰기
- 무관한 변경 여러 개를 한 실험에 묶기
- 측정 근거 없이 긴 설명 블록을 추가하기
- 실제 품질과 관계없는 형식 규칙만 최적화하기

</mutation_defaults>

<deliverables>

실행이 끝나면 다음이 남아 있어야 한다:

- 개선된 대상 스킬
- `.hypercore/autoresearch-skill/[skill-name]/dashboard.html`
- `.hypercore/autoresearch-skill/[skill-name]/results.json`
- `.hypercore/autoresearch-skill/[skill-name]/results.js` 또는 이에 준하는 파일 기반 브리지
- `.hypercore/autoresearch-skill/[skill-name]/results.tsv`
- `.hypercore/autoresearch-skill/[skill-name]/changelog.md`
- `.hypercore/autoresearch-skill/[skill-name]/SKILL.md.baseline`

파일 스키마와 예시는 [references/artifact-spec.md](references/artifact-spec.md)를 따른다.

</deliverables>

<validation>

한국어 지원을 포함해 다음을 만족해야 한다:

- 트리거 예시에 한국어 긍정 예시 최소 1개, 한국어 비대상 예시 최소 1개가 있다
- core만 읽어도 이 스킬이 반복 실험 기반 스킬 최적화용이라는 점이 분명하다
- support file 포인터가 명확하고 한 단계 이상 깊어지지 않는다
- baseline-first, one-mutation-at-a-time, explicit stop condition이 유지된다

</validation>
