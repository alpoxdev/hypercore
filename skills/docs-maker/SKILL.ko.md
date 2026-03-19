---
name: docs-maker
description: 프롬프트, 도구, 평가, 안전, 컨텍스트 워크플로우를 위한 AI 친화적 문서와 하네스 규칙 팩을 생성하고 리팩토링합니다.
compatibility: 문서 분석, 출처 검증, 품질 점검을 위해 read/edit/write 및 셸 검색 도구가 있는 환경에서 가장 잘 동작합니다.
---

@rules/sequential-thinking.ko.md
@rules/context-engineering.ko.md
@rules/harness-engineering.ko.md
@rules/forbidden-patterns.ko.md
@rules/required-behaviors.ko.md

# Docs Maker 스킬

> 구조화 문서와 하네스 가이드를 생성하고 리팩토링하는 통합 스킬.

<purpose>

- AI 시스템이 안정적으로 파싱, 검색, 실행할 수 있는 구조 문서를 만듭니다.
- 기존 문서를 더 압축되고, 명확하고, 출처 기반이며, 유지보수 안전한 형태로 개선합니다.
- 프롬프트 자산, 도구 계약, 평가 루프, 안전 게이트, 컨텍스트 관리를 지원하는 규칙 팩을 설계합니다.

</purpose>

<trigger_conditions>

| 상황 | 모드 |
|------|------|
| 새 구조화 가이드가 필요함 | create |
| 기존 가이드가 길고, 반복적이거나, 모호함 | refactor |
| 팀에 하나의 canonical 문서 형태가 필요함 | create/refactor |
| 프롬프트, 도구, 평가, 안전용 하네스 규칙이 비어 있음 | create/refactor |

</trigger_conditions>

<supported_targets>

- 정책 문서
- 플레이북과 런북
- 기술 명세와 설계 노트
- 워크플로우와 프로세스 가이드
- 프롬프트 및 에이전트 운영 가이드
- 프롬프트, 도구, 평가, 안전, 컨텍스트용 하네스 문서

</supported_targets>

<documentation_architecture>

기본적으로 다음 계층 구조를 사용합니다.

- 표준 코어: provider와 model 변화에도 살아남아야 하는 지속 규칙
- 공급자 참조: 날짜가 붙은 Anthropic/OpenAI 사실, migration 노트, 동작 차이
- 로컬 오버레이: 프로젝트별 규칙이나 로컬 선호

이 경계를 명시하지 않은 채 한 섹션에 섞지 않습니다.

</documentation_architecture>

<reference_routing>

다음 조건에 해당하면 공식 reference 파일로 분리합니다.

- 규칙이 변경 가능한 vendor 동작에 의존함
- migration, snapshot, release 민감한 세부사항을 포함함
- 하나의 provider나 하나의 tool 계열에만 맞는 규칙임

여러 provider와 여러 model 세대에 걸쳐 유지되는 규칙만 표준 코어에 둡니다.

</reference_routing>

<mandatory_reasoning>

## 필수 Sequential Thinking

- 주요 create/refactor 작업 전에는 항상 `sequential-thinking`을 사용합니다.
- create 모드에서는 섹션 구조, 제약, 검증 방식을 먼저 설계합니다.
- refactor 모드에서는 중복, 모호성, 오래된 참조, 혼합 관심사를 먼저 식별합니다.
- 구조 계획이 끝나기 전에는 문서를 수정하지 않습니다.

</mandatory_reasoning>

<context_engineering_application>

모든 주요 편집에서 다음 Context Engineering 기본값을 적용합니다.

- 적절한 지시 고도를 선택합니다.
- 토큰을 유한 자원으로 보고 핵심 문서는 압축하고, 상세 내용은 `rules/`와 `references/`로 보냅니다.
- 관측 가능한 검증을 동반한 명시적 지시를 사용합니다.
- 관심사가 뒤섞인 장문 대신 안정적인 섹션 구조와 progressive disclosure를 우선합니다.
- 가능하면 canonical 가이드는 provider-neutral로 유지하고, provider 민감한 내용은 reference나 adapter 섹션으로 격리합니다.

</context_engineering_application>

<modes>

## 생성 모드

- 최소 스켈레톤에서 시작합니다.
- 가치가 높은 규칙, 예시, 검증 게이트만 추가합니다.
- 장문 설명보다 표, 체크리스트, 압축된 패턴을 우선합니다.

## 리팩토링 모드

- 핵심 의도와 운영 동작은 유지합니다.
- 반복, 모호한 표현, stale한 provider 결합을 제거합니다.
- 설명 위주 섹션을 압축된 규칙, 예시, reference 중심으로 바꿉니다.

</modes>

<default_outputs>

기본 출력 형태:

- 생성 모드: 새 canonical 문서 + 필요한 rule/reference 파일 + 검증 체크리스트
- 리팩토링 모드: 갱신된 canonical 문서 + 압축된 규칙 + 이동된 references + 명시적 단순화 요약

</default_outputs>

<workflow>

| Phase | 작업 | 결과물 |
|------|------|------|
| 1 | 대상 문서를 읽고 모드(`create`/`refactor`)를 분류 | 범위 + 모드 |
| 2 | `sequential-thinking`으로 구조 계획 수립 | 섹션 계획 |
| 3 | canonical 본문 작성/리팩토링 | 갱신된 문서 |
| 4 | provider 민감한 내용이 있으면 공식 reference 추가/갱신 | reference 계층 |
| 5 | 품질, 일관성, 출처 최신성 검증 | 최종 문서 |

### Phase 3 작성 규칙

- 안정적인 섹션과 헤딩 구조를 사용합니다.
- 가능하면 금지문 나열보다 긍정형 지시(`Do X`)를 우선합니다.
- 예시는 복사-재사용 가능하게 작성하고, 해당 규칙에 직접 연결합니다.
- "적절히", "필요시" 같은 표현은 기준으로 치환합니다.
- 같은 개념은 문서 전체에서 같은 용어로 씁니다.
- provider 차이가 실제 동작을 바꾸지 않는다면 canonical 규칙은 provider-neutral로 유지합니다.
- 정확도를 잃지 않는 가장 높은 안정성 계층에 내용을 배치합니다.
- provider 민감한 예외는 그 지점에서 명시적으로 라벨링합니다.
- 컨텍스트 압박 상황에서도 검색되도록 섹션을 작고 스캔 가능하게 유지합니다.

</workflow>

<forbidden>

| 분류 | 금지 |
|------|------|
| 구조 | 관심사가 섞인 장문 단락 |
| 내용 | 같은 규칙의 반복 |
| 지시 | 판단 기준 없는 모호한 문장 |
| Provider 결합 | canonical core 문서 안의 고정 모델명 |
| 품질 | 리팩토링 중 핵심 제약 삭제 |

</forbidden>

<required>

| 분류 | 필수 |
|------|------|
| 명확성 | 분명한 섹션 계층과 간결한 문장 |
| 실행성 | 구체적 단계와 검증 기준 |
| 예시 | 바로 재사용 가능한 예시 |
| 일관성 | 용어와 규칙 표현 방식 통일 |
| 출처 근거 | provider 민감한 지시에 대한 공식 reference |
| 유지보수성 | core 규칙, provider adapter, local preference 분리 |

</required>

<structure_blueprint>

도메인 특화 구조가 없으면 기본적으로 아래 레이아웃을 사용합니다.

1. 목표
2. 범위와 가정
3. 규칙 (`required` / `forbidden`)
4. 실행 워크플로우
5. 예시 또는 패턴
6. 검증 체크리스트
7. Provider-sensitive guidance가 있으면 references

</structure_blueprint>

<usage_examples>

### 예시: 오래된 스킬 리팩토링

- skill 본문과 기본 rule 파일을 모두 읽습니다.
- 내용을 core rules, provider references, local overlays로 분류합니다.
- canonical core에서 구현 누수와 mixed concern을 제거합니다.
- provider 민감한 주장에는 공식 reference 항목을 추가하거나 갱신합니다.
- 종료 전 grep과 readback으로 재검토합니다.

### 예시: 하네스 규칙 팩 생성

- prompt asset 계약을 정의합니다.
- tool contract와 approval 경계를 정의합니다.
- eval 기준과 failure handling을 정의합니다.
- context ordering과 compaction 정책을 정의합니다.
- vendor 동작 차이가 실제 규칙을 바꿀 때만 provider reference를 붙입니다.

</usage_examples>

<validation>

| 점검 항목 | 기준 |
|------|------|
| 구조 | 주요 섹션이 명확히 분리됨 |
| 밀도 | 반복 제거, 필요한 곳에 표 사용 |
| 실행성 | 추측 없이 단계 실행 가능 |
| 예시 | 실제 워크플로우와 도구에 맞음 |
| 안전성 | 리팩토링 후 핵심 제약 유지 |
| 컨텍스트 품질 | 적절한 고도 + 명시성 + 낮은 중복 |
| 출처 최신성 | provider 민감한 주장이 공식 문서와 검증 날짜를 가짐 |
| 모델 중립성 | canonical core 문서에 고정 모델명이 없음 |

완료 체크리스트:
- [ ] 모드 결정(`create` 또는 `refactor`)
- [ ] `sequential-thinking` 계획 선행
- [ ] Context engineering 점검(`rules/context-engineering.ko.md`) 적용
- [ ] 관련 시 harness engineering 점검(`rules/harness-engineering.ko.md`) 적용
- [ ] provider 민감한 지시를 reference 또는 adapter 섹션으로 이동
- [ ] 문서를 압축된 구조로 갱신
- [ ] readback pass로 워크플로우 일치 여부 확인
- [ ] 검증 항목 점검 완료

리뷰어 빠른 게이트:
- canonical 문서에 고정 모델명이 있으면 실패
- provider 민감한 주장에 공식 reference가 없으면 실패
- docs-maker 기본 로드 경로에 무관한 구현 스택 규칙이 남아 있으면 실패
- harness 문서인데 eval, tool, safety, context 경계가 빠져 있으면 실패

</validation>
