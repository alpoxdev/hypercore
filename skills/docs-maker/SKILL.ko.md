---
name: docs-maker
description: 어떤 도메인에도 적용 가능한 AI 읽기/회상 최적화 구조 문서를 생성/리팩토링하는 통합 문서 스킬입니다.
compatibility: 문서 분석과 품질 검증을 위해 read/edit/write 및 셸 검색 도구 사용 환경에서 가장 잘 동작합니다.
---

@rules/sequential-thinking.ko.md
@rules/context-engineering.ko.md
@rules/forbidden-patterns.ko.md
@rules/required-behaviors.ko.md

# Docs Maker Skill

> 문서 생성과 문서 리팩토링을 하나로 합친 통합 스킬.

<purpose>

- AI가 빠르게 파싱하고 기억할 수 있는 구조 문서를 생성합니다.
- 기존 문서를 더 압축되고 명확하며 검색 가능한 형태로 개선합니다.
- 규칙, 워크플로우, 검증이 분명한 실행 중심 문서를 만듭니다.

</purpose>

<trigger_conditions>

| 상황 | 모드 |
|------|------|
| 새 구조화 가이드가 필요함 | create |
| 기존 가이드가 길고 반복적임 | refactor |
| 기존 가이드가 모호하고 스캔이 어려움 | refactor |
| 팀 전체 문서 형태를 통일하고 싶음 | create/refactor |

</trigger_conditions>

<supported_targets>

- 정책 문서
- 플레이북/런북
- 기술 명세/설계 노트
- 워크플로우/프로세스 가이드
- 프롬프트/에이전트 운영 가이드

</supported_targets>

<mandatory_reasoning>

## Mandatory Sequential Thinking

- 문서 작성/수정 전에 반드시 `sequential-thinking`을 사용합니다.
- create 모드: 섹션 구조와 제약을 먼저 설계합니다.
- refactor 모드: 중복, 모호성, 압축 후보를 먼저 식별합니다.
- 계획 없이 바로 편집하지 않습니다.

</mandatory_reasoning>

<context_engineering_application>

모든 주요 문서 편집에서 Context Engineering 기본값을 적용합니다.

- Right Altitude 유지(과도한 분기/과도한 추상화 모두 회피)
- 토큰을 유한 자원으로 보고 핵심 문서는 압축, 상세는 `rules/`로 분리
- Claude 4.x 기준으로 명시적이고 관측 가능한 지시 사용
- XML 구획 + 표 압축으로 검색 안정성 확보
- Progressive Disclosure(메타데이터 -> 핵심 워크플로우 -> 상세 규칙) 적용

</context_engineering_application>

<modes>

## create 모드

- 최소 스켈레톤에서 시작합니다.
- 가치가 높은 규칙과 실행 가능한 예시만 추가합니다.
- 장문 설명보다 표/체크리스트를 우선합니다.

## refactor 모드

- 핵심 의도와 동작 규칙은 유지합니다.
- 중복과 모호한 표현을 제거합니다.
- 설명 위주 섹션을 표와 예시 중심으로 압축합니다.

</modes>

<workflow>

| Phase | 작업 | 결과물 |
|------|------|------|
| 1 | 대상 문서 읽기 + 모드 분류(`create`/`refactor`) | 범위 + 모드 |
| 2 | `sequential-thinking`으로 구조 계획 수립 | 섹션 계획 |
| 3 | 작성/리팩토링 실행 | 갱신된 문서 |
| 4 | 품질/일관성 검증 | 최종 문서 |

### Phase 3 작성 규칙

- 안정적인 헤딩 구조를 사용합니다.
- 부정형 나열보다 긍정형 지시(`Do X`)를 우선합니다.
- 예시는 복사-실행 가능하게 작성합니다.
- "적절히", "필요시" 같은 모호 표현은 기준과 함께 명시합니다.
- 같은 개념은 문서 전체에서 동일한 용어로 유지합니다.
- 컨텍스트 압박 상황에서도 검색되도록 섹션을 작고 스캔 가능하게 유지합니다.

</workflow>

<forbidden>

| 분류 | 금지 |
|------|------|
| 구조 | 관심사가 섞인 장문 단락 |
| 내용 | 같은 규칙의 섹션 간 반복 |
| 지시 | 판단 기준 없는 모호한 문장 |
| 품질 | 리팩토링 중 핵심 제약 삭제 |

</forbidden>

<required>

| 분류 | 필수 |
|------|------|
| 명확성 | 섹션 계층과 간결한 문장 |
| 실행성 | 단계별 워크플로우 + 검증 기준 |
| 예시 | 바로 재사용 가능한 예시 |
| 일관성 | 용어/규칙 표현 방식 통일 |

</required>

<structure_blueprint>

도메인 특화 구조가 필요하지 않다면 아래 기본 레이아웃을 사용합니다.

1. Objective
2. Scope and assumptions
3. Rules (`forbidden` / `required`)
4. Execution workflow (phase/step)
5. Examples (good/bad 또는 실행 예시)
6. Validation checklist

</structure_blueprint>

<validation>

| 점검 항목 | 기준 |
|------|------|
| 구조 | 주요 섹션이 명확히 분리됨 |
| 밀도 | 중복 제거, 필요한 곳에 표 사용 |
| 실행성 | 추측 없이 단계 실행 가능 |
| 예시 | 실제 워크플로우/도구와 일치 |
| 안전성 | 리팩토링 후 핵심 제약 유지 |
| 컨텍스트 품질 | Right Altitude + 명시성 + 중복 최소화 |

완료 체크리스트:
- [ ] 모드 결정(`create` 또는 `refactor`)
- [ ] `sequential-thinking` 계획 선행
- [ ] Context Engineering 점검(`rules/context-engineering.ko.md`) 적용
- [ ] 문서 구조 압축/정리 완료
- [ ] 검증 항목 점검 완료

</validation>
