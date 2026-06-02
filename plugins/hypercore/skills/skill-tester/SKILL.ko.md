---
name: skill-tester
description: "[Hyper] Codex/agent 스킬이 의도한 트리거와 동작을 하는지 현실적인 positive, negative, boundary, edge-case 시나리오로 테스트합니다. 스킬 폴더, SKILL.md, rules/references/scripts/assets, 트리거 정확도, 워크플로 정확성, 회귀 커버리지를 출시 전 검증할 때 사용하세요."
compatibility: 스킬 실행 하네스, read/search 도구, shell 명령, 발견된 문제를 고칠 edit 도구가 있으면 가장 잘 작동합니다.
---

@rules/test-matrix.md
@rules/scenario-design.md
@rules/evidence-reporting.md
@references/prompt-pack-template.md

# Skill Tester

> 스킬을 신뢰하기 전에 의도대로 작동한다는 증거를 만든다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- 스킬이 맞는 사용자 요청에는 켜지고 틀린 요청에는 꺼져 있는지 테스트한다.
- 스킬의 워크플로, 지원 파일 라우팅, scripts/assets, 검증 지시를 현실적인 사용 상황으로 확인한다.
- 애매한 요청, 누락 입력, 잘못된 리소스, 충돌 지시, 회귀 위험 같은 엣지 케이스 커버리지를 넓힌다.

</purpose>

<routing_rule>

사용자가 기존 스킬 또는 스킬 폴더를 테스트, 검증, QA, 회귀 테스트, 엣지 케이스 테스트하고 싶어 할 때 `skill-tester`를 사용한다.

새 스킬 생성 또는 구조적 리팩터링이 주목적이면 `skill-maker`를 사용한다.
반복 실험과 점수 기반 최적화가 주목적이면 `autoresearch-skill`을 사용한다.
대상이 스킬이 아니라 애플리케이션 기능이면 앱 QA 계열 스킬을 사용한다.

사용하지 않는 경우:

- 평가할 스킬 또는 스킬 초안이 없다.
- 일반 문서 리뷰만 원한다.
- 스킬 동작과 무관한 앱/브라우저 QA다.
- 이미 점수 기반 반복 실험과 mutation 루프를 요청했다.

</routing_rule>

<trigger_conditions>

Positive examples:

- "Test `skills/git-maker/` and tell me whether it triggers correctly."
- "이 스킬이 의도한 대로 작동하는지 엣지 케이스까지 검증해줘."
- "Create a regression test pack for this skill's trigger and workflow behavior."
- "Validate the `SKILL.md`, rules, references, and scripts before I ship this skill."

Negative examples:

- "브라우저 QA용 새 Codex 스킬을 만들어줘." → `skill-maker`.
- "내 웹앱 결제 플로우 QA 해줘." → 앱 QA, 이 스킬 아님.
- "이 스킬을 반복 벤치마크로 최적화해줘." → `autoresearch-skill`.

Boundary example:

- "이 스킬 리뷰하고 문제 있으면 고쳐줘."
  증거와 실패 분석이 핵심이면 `skill-tester`로 시작하고, 구조 수정이 필요할 때 `skill-maker`로 넘긴다.

</trigger_conditions>

<supported_targets>

- `SKILL.md`와 `SKILL.ko.md` 같은 선택적 지역화 파일을 포함한 스킬 폴더.
- 스킬 메타데이터, 트리거 설명, 라우팅 규칙, 예시.
- 직접 링크된 `rules/`, `references/`, `scripts/`, `assets/`.
- 트리거 프롬프트 팩, 워크플로 시뮬레이션, 검증 체크리스트, 회귀 리포트.
- 애매함, 누락 입력, 충돌 지시, 미지원 대상, 리소스 드리프트 관련 엣지 케이스.

</supported_targets>

<required_inputs>

최소 입력:

1. 대상 스킬 경로 또는 붙여넣은 스킬 내용.
2. 메타데이터만으로 명확하지 않은 경우, 해당 스킬의 의도한 역할.

둘 중 하나가 빠졌다면 먼저 로컬 컨텍스트에서 추론한다. 대상 또는 의도 동작을 안전하게 추론할 수 없을 때만 질문한다.

</required_inputs>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | 대상 스킬, 의도 동작, 충돌 가능한 주변 스킬을 식별 | 테스트 범위 |
| 1 | `SKILL.md`와 필요한 직접 링크 지원 파일을 읽음 | 기준 동작 맵 |
| 2 | positive, negative, boundary, edge, regression 시나리오 매트릭스 작성 | 테스트 매트릭스 |
| 3 | 정적 구조 검사와 지원 파일 참조 검사 실행 | 정적 발견사항 |
| 4 | 각 시나리오의 라우팅과 워크플로 실행을 시뮬레이션 | pass/fail 표 |
| 5 | 실패를 trigger, scope, resource, workflow, validation, safety 유형으로 분류 | 순위화된 결함 |
| 6 | 최소 수정안 또는 `skill-maker`/`autoresearch-skill` 핸드오프 제안 | 증거 기반 리포트 |

</workflow>


<test_requirements>

의미 있는 스킬 테스트는 최소 다음을 포함한다.

- positive trigger 시나리오 3개.
- negative trigger 시나리오 2개.
- boundary 또는 ambiguous 시나리오 2개.
- 누락 입력, 잘못된 경로, 미지원 언어, 충돌 지시, 누락 지원 파일 같은 edge-case 시나리오 2개.
- 알려진 또는 가능성 높은 실패를 막는 regression 시나리오 1개.
- `SKILL.ko.md`가 있는 스킬은 한국어 positive 또는 boundary 요청 1개 이상.

사용자가 재사용 가능한 회귀 테스트팩 또는 프롬프트 팩을 요청하면 기본적으로 [references/prompt-pack-template.ko.md](references/prompt-pack-template.ko.md)의 한국어 템플릿을 사용한다. 사용자가 영어를 요청했거나 정확한 영어 템플릿 문구가 필요할 때만 [references/prompt-pack-template.md](references/prompt-pack-template.md)를 사용한다.

</test_requirements>

<failure_taxonomy>

각 문제는 다음 중 하나로 분류한다.

- `trigger-miss`: 대상 요청에서 스킬이 켜지지 않을 수 있음.
- `trigger-overreach`: 무관한 요청에서 스킬이 켜질 수 있음.
- `scope-conflict`: 주변 스킬 또는 워크플로가 더 적합함.
- `workflow-gap`: 다음 행동이 명확하지 않음.
- `resource-drift`: 링크된 파일이 누락, 중복, 낡음, 잘못 배치됨.
- `validation-gap`: 증거 없이 완료를 주장할 수 있음.
- `edge-case-gap`: 현실적인 경계 조건 처리가 빠짐.
- `safety-gap`: 위험하거나 되돌리기 어려운 행동에 안전장치가 부족함.

</failure_taxonomy>

<output_contract>

기본 보고 형식:

```markdown
## Skill Test Report

**Target**: `skills/example/`
**Intended behavior**: ...
**Verdict**: pass | pass-with-risks | fail

### Scenario results
| ID | Type | Prompt / condition | Expected | Observed | Result |
|----|------|--------------------|----------|----------|--------|

### Findings
1. [severity] [taxonomy] 증거가 있는 문제와 영향 파일/섹션.

### Edge cases covered
- ...

### Recommended fixes
- 최소 수정 또는 handoff 대상.

### Validation evidence
- 실행 명령, 읽은 파일, 완료한 체크.
```

</output_contract>

<validation_checklist>

완료 전 확인:

- [ ] 대상 스킬과 직접 링크 리소스를 검사했다.
- [ ] 의도 동작을 입력받거나 추론했다.
- [ ] positive, negative, boundary, edge, regression 시나리오를 포함했다.
- [ ] 주변 스킬과의 트리거 충돌을 고려했다.
- [ ] 폴더 경로가 있으면 정적 리소스 검사를 실행했다.
- [ ] 실패를 증거와 최소 수정 안내로 분류했다.
- [ ] 남은 위험과 미검증 영역을 명시했다.

</validation_checklist>
