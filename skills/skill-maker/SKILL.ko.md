---
name: skill-maker
description: 재사용 가능한 Codex 스킬을 새로 만들거나 기존 스킬 폴더를 리팩토링할 때 사용합니다. `SKILL.md`, `rules/`, `references/`, `scripts/`, `assets/` 전반에서 트리거 문구, 자원 배치, 검증 구조를 바로잡아야 하는 요청에 맞춥니다.
compatibility: 스킬 분석, 예시 수집, 검증 점검을 위해 read/edit/write 및 셸 검색 도구가 있는 환경에서 가장 잘 동작합니다.
---

@rules/skill-anatomy.ko.md
@rules/trigger-design.ko.md
@rules/progressive-disclosure.ko.md
@rules/resource-placement.ko.md
@rules/validation-and-iteration.ko.md
@rules/anti-patterns.ko.md

# Skill Maker

> 스킬을 단순 마크다운이 아니라 하나의 제품처럼 만들고 고칩니다.

<purpose>

- 사용자 의도에서 안정적으로 발동되는 새 스킬을 만듭니다.
- 기존 스킬의 범위, 트리거, 자원 배치, 검증 구조를 개선합니다.
- `SKILL.md`, `references/`, `scripts/`, `assets/`, 선택적 UI 메타데이터를 어디에 어떻게 둘지 가르칩니다.

</purpose>

<routing_rule>

출력이 스킬 폴더이거나 기존 스킬 리팩토링일 때 `skill-maker`를 사용합니다.

출력이 일반 문서, 런북, 명세, 프롬프트 산출물이고 스킬 구조가 아니라면 `docs-maker`를 사용합니다.

다음 경우에는 `skill-maker`를 쓰지 않습니다.

- 일반 문서가 필요할 뿐 스킬이 필요하지 않은 경우
- 결과물이 스킬 구조 없이 프롬프트, 계획, 명세만인 경우
- 일반 구조 문서 작업이므로 `docs-maker`면 충분한 경우

</routing_rule>

<activation_examples>

긍정 요청:

- "SQL 마이그레이션 리뷰용 Codex 스킬을 만들어줘."
- "이 브라우저 QA 스킬이 잘못 걸리니까 트리거와 검증을 다시 잡아줘."
- "이 스킬 폴더를 표준화해서 `SKILL.md`, rules, references 역할을 제대로 나눠줘."

부정 요청:

- "이 런북을 읽기 쉽게 다시 써줘."
- "이 OpenAI 문서를 요약해줘."

경계 요청:

- "스킬 작성 가이드를 만들어줘."
  결과물이 재사용 가능한 스킬 폴더여야 할 때만 `skill-maker`를 쓰고, 그렇지 않으면 `docs-maker`를 사용합니다.

</activation_examples>

<trigger_conditions>

| 상황 | 모드 |
|------|------|
| 새 스킬을 만들어야 함 | create |
| 기존 스킬이 너무 길거나, 범위가 약하거나, 잘 트리거되지 않음 | refactor |
| 스킬의 `description` 또는 트리거 문구를 개선해야 함 | refactor |
| 스킬의 `references/`, `scripts/`, `assets/` 배치를 바로잡아야 함 | create/refactor |
| 팀에 일관된 스킬 작성 형태가 필요함 | create/refactor |

</trigger_conditions>

<supported_targets>

- 새 스킬 폴더
- 기존 스킬 리팩토링
- `SKILL.md` 메타데이터와 본문
- 스킬 규칙 팩
- 스킬의 references, scripts, assets 배치
- 스킬 검증 체크리스트와 전방 테스트 계획

</supported_targets>

<skill_architecture>

기본적으로 다음 계층 구조를 사용합니다.

- 코어 스킬: 스킬이 무엇을 하고 언제 써야 하는지에 대한 지속 규칙
- 규칙: 재사용 가능한 정책과 워크플로 세부사항
- 참조: 필요할 때만 불러오는 상세 정보
- 스크립트/자산: 결정적 실행 헬퍼 또는 출력 자원

과도한 내용을 코어 `SKILL.md`에 몰아넣지 않습니다.

</skill_architecture>

<reference_routing>

다음 경우에는 공식 references를 읽습니다.

- 공급자 민감한 스킬 가이드가 코어 규칙에 영향을 줄 때
- 트리거 동작이나 평가 가이드가 vendor 문서에 의존할 때
- 유지보수나 드리프트 대응에 최신 공급자 정책이 필요할 때

다음 경우에는 로컬 `skill-creator` 요약을 읽습니다.

- 코어 스킬에 어느 정도 상세를 남길지 판단할 때
- scripts나 bundled resources 추가 여부를 판단할 때
- support file이 선택인지, 권장인지, 불필요한지 판단할 때

</reference_routing>

<support_file_read_order>

다음 순서로 읽습니다.

1. 코어 `SKILL.md`에서 현재 작업이 `create`인지 `refactor`인지와 스킬이 책임질 출력물을 확정합니다.
2. 트리거 문구, 구조, 파일 분리를 바꿀 때는 `rules/trigger-design.ko.md`, `rules/skill-anatomy.ko.md`, `rules/progressive-disclosure.ko.md`, `rules/resource-placement.ko.md`를 읽습니다.
3. 완료 선언 전에는 `rules/validation-and-iteration.ko.md`와 `rules/anti-patterns.ko.md`로 검증과 안티패턴을 다시 확인합니다.
4. 코어에 얼마만큼 남길지, scripts/assets가 정당한지 판단할 때는 `references/local/skill-creator.ko.md`를 읽습니다.
5. 공급자 민감한 가이드가 실제 규칙을 바꿀 때만 공식 references를 읽습니다.

</support_file_read_order>

<mandatory_reasoning>

## 필수 Sequential Thinking

- 주요 스킬 생성이나 리팩토링 전에는 항상 `sequential-thinking`을 사용합니다.
- create 모드에서는 트리거, 구조, 자원 분리, 검증 전략을 먼저 설계합니다.
- refactor 모드에서는 약한 트리거, 혼합 관심사, 잘못된 자원 배치, 빠진 검증을 먼저 찾습니다.
- 구조 계획이 분명해지기 전에는 스킬을 쓰거나 고치지 않습니다.

</mandatory_reasoning>

<design_defaults>

모든 주요 스킬 편집에 다음 기본값을 적용합니다.

- 먼저 트리거 가능성을 최적화하고, 그 다음 가독성을 다듬습니다.
- 코어 스킬은 얇게 유지하고, 상세 내용은 아래 계층으로 내립니다.
- 추상적인 설명보다 실제로 스킬을 부를 사용자 요청 예시를 우선합니다.
- 검증은 부속 작업이 아니라 스킬 본체의 일부로 봅니다.
- 공급자 민감 가이드는 코어가 아니라 참조 파일로 보냅니다.

</design_defaults>

<modes>

## 생성 모드

- 가장 작은 유효 스킬 형태에서 시작합니다.
- 실제로 도움이 되는 규칙, 참조, 스크립트, 예시만 추가합니다.
- 스킬이 제대로 발동하고 작동하는지 보여줄 만큼의 검증을 포함합니다.

## 리팩토링 모드

- 현재 스킬의 본래 역할이 분명히 틀리지 않는 한 그 의도를 유지합니다.
- 내용을 더 추가하기 전에 트리거 문구, 구조, 자원 배치를 먼저 개선합니다.
- 중복, 모호한 지시, 사용되지 않는 자원을 제거합니다.

</modes>

<default_outputs>

기본 출력 형태:

- 생성 모드: 새 스킬 폴더 + 얇은 코어 `SKILL.md` + 꼭 필요한 규칙/참조/스크립트/자산 + 트리거 예시 + 검증 체크리스트
- 리팩토링 모드: 갱신된 스킬 + 더 단순한 자원 분리 + 명시적 단순화 요약 + 검증 메모 + 유지보수자용 handoff 단서

</default_outputs>

<workflow>

| Phase | 작업 | 결과물 |
|------|------|------|
| 0 | 이 작업이 일반 문서가 아니라 스킬인지 범위를 확인 | 범위 결정 |
| 1 | 대상 스킬과 선택한 모드에 직접 필요한 연결 support file을 읽음 | 기준선 |
| 2 | `sequential-thinking`으로 구조 계획 수립 | 섹션/자원 계획 |
| 3 | 코어 `SKILL.md` 작성 또는 리팩토링 | 갱신된 코어 스킬 |
| 4 | 상세 내용을 rules, references, scripts, assets로 배치 | 보조 파일 |
| 5 | 트리거, 구조, 검증 관점에서 재독 | 검토 메모 |
| 6 | 명시적 검증과 남은 리스크를 정리하고 마무리 | 최종 스킬 |

### Phase 3 작성 규칙

- `description`은 스킬이 무엇을 하고 언제 써야 하는지 둘 다 구체적으로 말해야 합니다.
- `SKILL.md` 첫 화면만 봐도 스킬의 역할과 경계가 드러나야 합니다.
- 한 개념에는 한 용어만 씁니다.
- 실제로 스킬을 부를 사용자 요청 예시를 우선합니다.
- 스킬 전용 구조 규칙은 비대해진 코어 본문이 아니라 `rules/`로 보냅니다.
- 코어 스킬은 공급자와 모델 변화에도 버티도록 유지합니다.

</workflow>

<forbidden>

| 분류 | 금지 |
|------|------|
| 트리거 | 너무 일반적이라 여러 스킬에 다 걸릴 description |
| 구조 | references를 복제하는 거대한 `SKILL.md` |
| 자원 | 깊게 중첩된 references 또는 쓰이지 않는 scripts/assets |
| 검증 | 트리거와 사용 검증 없이 완료 선언 |
| 드리프트 | 코어 본문에 시간 민감한 공급자 세부사항 넣기 |

</forbidden>

<required>

| 분류 | 필수 |
|------|------|
| 트리거 가능성 | 실제 사용자 표현을 반영한 구체적 `name`과 `description` |
| 구조 | `SKILL.md`, rules, references, scripts, assets의 역할 분리 |
| 실행성 | 구체적 워크플로 단계와 검증 기준 |
| 예시 | 트리거 예시와 폴더 구조 예시 |
| 유지보수성 | 점진적 공개와 낮은 중복 |
| 검증 | 트리거 테스트, 자원 배치 점검, 전방 테스트 가이드 |

</required>

<structure_blueprint>

특별한 이유가 없으면 다음 구조를 사용합니다.

1. 목적
2. 트리거 조건
3. 지원 대상
4. 스킬 구조
5. 워크플로
6. 예시
7. 검증 체크리스트
8. 공급자 민감한 가이드가 있으면 references

</structure_blueprint>

<usage_examples>

### 예시: 새 스킬 만들기

- 스킬이 맡을 일을 정의합니다.
- 실제 사용자 요청을 기준으로 트리거 description을 씁니다.
- 무엇을 `SKILL.md`에 두고, 무엇을 `rules/` 또는 `references/`로 내릴지 정합니다.
- 결정적 실행이 필요할 때만 scripts를 추가합니다.
- 트리거 품질과 실제 사용 범위를 검증하는 체크를 넣습니다.

### 예시: 비대해진 스킬 리팩토링

- 현재 `SKILL.md`, rules, references를 읽습니다.
- 중복된 내용과 잘못 놓인 상세 정보를 표시합니다.
- description을 다시 써서 맞는 요청에만 걸리게 만듭니다.
- 긴 상세 내용은 references나 scripts로 옮깁니다.
- 새로운 유지보수자와 트리거 모델의 시선으로 다시 읽어봅니다.

</usage_examples>

<validation>

| 점검 항목 | 기준 |
|------|------|
| 트리거 품질 | `description`이 스킬의 역할과 사용 시점을 모두 말함 |
| 범위 명확성 | 첫 화면에서 스킬 경계가 드러남 |
| 자원 배치 | 코어 본문, rules, references, scripts, assets가 올바른 내용을 가짐 |
| 밀도 | 반복이 제거되고 코어 본문이 얇게 유지됨 |
| 예시 | 트리거 예시가 실제 사용자 요청과 맞음 |
| 작업 단서 | 다음에 읽을 파일과 다음 상세를 둘 위치가 명확함 |
| 안전성 | 시간 민감 또는 공급자 민감 가이드는 references로 격리됨 |
| 검증 | 단순 prose review가 아니라 실제 사용 검증이 포함됨 |

완료 체크리스트:
- [ ] 모드 결정(`create` 또는 `refactor`)
- [ ] `sequential-thinking` 계획 선행
- [ ] 트리거 문구 점검(`rules/trigger-design.ko.md`)
- [ ] 스킬 구조 점검(`rules/skill-anatomy.ko.md`)
- [ ] 점진적 공개 점검(`rules/progressive-disclosure.ko.md`)
- [ ] 자원 배치 점검(`rules/resource-placement.ko.md`)
- [ ] 검증 및 반복 점검(`rules/validation-and-iteration.ko.md`)
- [ ] 안티패턴 점검(`rules/anti-patterns.ko.md`)
- [ ] 코어 스킬이 얇고 일관되게 유지됨
- [ ] support-file 읽기 순서가 충분히 명시됨
- [ ] 검증 항목 점검 완료

반드시 통과해야 하는 기준:
- [ ] 긍정 트리거 예시 3개 이상
- [ ] 부정 트리거 예시 2개 이상
- [ ] 경계 트리거 예시 1개 이상
- [ ] `SKILL.md`에서 한 단계보다 깊은 참조 체인이 없음
- [ ] 코어 `SKILL.md` 본문은 특별한 이유가 없으면 대략 300줄 이하
- [ ] 코어와 references 사이에 정의 중복이 없음

</validation>
