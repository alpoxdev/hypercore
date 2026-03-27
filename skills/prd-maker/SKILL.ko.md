---
name: prd-maker
description: `.hypercore/prd/[slug]/` 아래에 살아있는 PRD를 생성하거나 갱신합니다. 근거 기반 요구사항, 범위, 비범위, 오픈 질문, 출처 추적까지 함께 정리합니다. 간단한 PRD는 바로 작성하고, 복잡한 PRD는 flow.json으로 진행 상황을 추적합니다.
compatibility: 로컬 파일 검색/편집 도구와, 최신 시장·사용자·제품·기술 근거가 필요할 때 라이브 웹 검색이 가능한 환경에서 가장 잘 동작합니다.
---

@rules/prd-workflow.ko.md
@rules/storage-and-updates.ko.md
@rules/validation.ko.md

# PRD Maker

> 이 저장소 안에서 살아있는 PRD를 만들고 유지합니다 — 복잡도를 먼저 판단한 뒤, 간단하면 바로 작성하고 복잡하면 단계별로 추적하며 진행합니다.

<purpose>

- 제품 아이디어, 기능 요청, 이니셔티브를 `.hypercore/prd/` 아래의 재사용 가능한 PRD 폴더로 바꿉니다.
- 개선 요청이면 처음부터 다시 쓰지 않고 기존 PRD를 제자리에서 갱신합니다.
- 제품 판단 근거, 범위 결정, 리스크, 출처를 검토 가능하게 남깁니다.

</purpose>

<routing_rule>

주된 결과물이 PRD이거나 기존 PRD 업데이트라면 `prd-maker`를 사용합니다.

아직 사실 조사 단계이고 PRD 산출물이 없다면 `research`를 사용합니다.

출력이 일반 문서, 스펙, 런북이고 PRD 폴더가 아니라면 `docs-maker`를 사용합니다.

사용자가 기획은 원하지만 결과를 `.hypercore/prd/` 아래의 PRD로 저장하길 원하지 않는다면 `plan`을 사용합니다.

다음 경우에는 `prd-maker`를 사용하지 않습니다.

- 문서 출력 없이 브레인스토밍만 원하는 경우
- PRD 작성 없이 시장 조사나 기술 조사만 원하는 경우
- 제품 요구사항이 아니라 구현, 코딩, 디버깅이 목표인 경우

</routing_rule>

<activation_examples>

긍정 요청:

- "팀 인박스 배정 기능 PRD 써줘."
- "새 결제 재시도 플로우용 product requirements doc 만들어줘."
- "기존 PRD에 최신 출시 범위랑 오픈 질문 반영해줘."

부정 요청:

- "경쟁사 온보딩 방식을 조사해줘."
- "결제 재시도 플로우 구현해줘."

경계 요청:

- "코딩 전에 이 기능 기획해줘."
  결과물이 `.hypercore/prd/` 아래의 저장된 PRD여야 할 때만 `prd-maker`를 사용합니다. 아니면 `plan` 또는 `docs-maker`로 라우팅합니다.

</activation_examples>

<trigger_conditions>

| 상황 | 모드 |
|------|------|
| 새 PRD를 만들어야 함 | create |
| 기존 PRD의 범위, 요구사항, 메트릭, 리스크를 갱신해야 함 | update |
| 제품 아이디어를 유지되는 요구사항 폴더로 바꿔야 함 | create |
| 릴리스나 이니셔티브의 근거 기반 요구사항을 갱신해야 함 | update |

</trigger_conditions>

<supported_targets>

- `.hypercore/prd/[slug]/` 아래의 새 PRD 폴더
- `.hypercore/prd/[slug]/` 아래의 기존 PRD 업데이트
- 살아있는 요구사항 문서 `prd.md`
- 근거 로그와 쿼리 로그 `sources.md`
- 복잡한 PRD의 단계 추적 `flow.json`
- 범위 변경, 가정, 리스크, 메트릭, 의존성, 오픈 질문

</supported_targets>

<complexity_classification>

## 복잡도 분류

작업 시작 전에 분류:

| 복잡도 | 신호 | 경로 |
|--------|------|------|
| **간단** | 단일 기능, 범위 명확, 조사 최소, 이해관계자 소수, 작은 PRD (요구사항 섹션 3개 이하) | **직접 작성** — `prd.md` + `sources.md`만 생성 |
| **복잡** | 다중 기능 이니셔티브, 광범위한 조사 필요, 이해관계자 다수, 큰 범위, 팀 간 의존성, 단계적 출시 | **추적 모드** — PRD 폴더에 `flow.json` 추가 |

분류 결과 발표:

```
복잡도: [간단/복잡] — [한 줄 근거]
```

판단이 애매하면 복잡으로 분류한다. 큰 PRD에서 진행 상황을 잃는 것보다 추적하는 비용이 낮다.

</complexity_classification>

<document_shape>

기본 출력 형태:

```text
.hypercore/prd/[slug]/
├── prd.md
├── sources.md
└── flow.json       (복잡 경로만)
```

- `prd.md`는 살아있는 제품 요구사항 문서입니다.
- `sources.md`는 PRD 생성/갱신에 사용한 근거를 기록합니다.
- `flow.json`은 복잡한 PRD의 단계 진행을 추적합니다. 전체 스키마는 `references/flow-schema.md` 참조.
- 버전 이력은 별도 파일이 아니라 `prd.md` 안의 변경 이력 섹션에 둡니다.
- 폴더가 아직 없으면 [assets/prd.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/prd.template.md) 와 [assets/sources.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/sources.template.md) 를 기준으로 파일을 만듭니다.

</document_shape>

<flow_tracking>

## 플로우 추적 (복잡 경로만)

복잡으로 분류되면 PRD 폴더 안에 `flow.json`을 작성하고 각 단계 완료 시 업데이트한다. 전체 스키마는 `references/flow-schema.md` 참조.

### 단계 진행

| 단계 | 설명 | 다음 |
|------|------|------|
| `brief` | 최소 작업 브리프 수집 (문제, 사용자, 목표, 제약) | `research` |
| `research` | 필요 시 라이브 조사 수행, 또는 건너뛰기로 표시 | `draft` |
| `draft` | 섹션 reference와 템플릿으로 `prd.md` 작성/갱신 | `sources` |
| `sources` | 근거 로그로 `sources.md` 작성/갱신 | `validate` |
| `validate` | 검증 체크리스트 실행, 마무리 | 완료 |

### 재개 지원

PRD 폴더에 `flow.json`이 이미 존재하면 먼저 읽고 마지막 미완료 단계부터 이어간다. 완료된 단계를 재시작하지 않는다. 대규모 이니셔티브의 다중 세션 PRD 작성을 지원한다.

</flow_tracking>

<support_file_read_order>

다음 순서로 읽습니다.

1. 이 코어 `SKILL.ko.md`에서 작업이 PRD 생성인지 갱신인지 먼저 확정합니다.
2. [rules/prd-workflow.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/rules/prd-workflow.ko.md)에서 create/update 판단과 조사 필요 여부를 결정합니다.
3. [rules/storage-and-updates.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/rules/storage-and-updates.ko.md)에서 폴더, 파일, slug, 병합 규칙을 적용합니다.
4. 본문 작성이나 수정 시에는 [references/prd-sections.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/references/prd-sections.ko.md)를 읽습니다. 출시 게이트가 있는 요청이라면 release criteria 같은 선택 섹션도 여기서 확인합니다.
5. 새 PRD 폴더를 만들 때는 [assets/prd.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/prd.template.md) 와 [assets/sources.template.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/assets/sources.template.md) 를 읽습니다.
6. 외부 조사 필요 시 [instructions/sourcing/reliable-search.md](/Users/alpox/Desktop/dev/kood/hypercore/instructions/sourcing/reliable-search.md)를 읽어 중복 검색과 종료 조건을 맞춥니다.
7. 완료 선언 전에는 [rules/validation.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/rules/validation.ko.md)를 확인합니다.

</support_file_read_order>

<workflow>

## 간단 경로

| Phase | 작업 | 결과물 |
|-------|------|--------|
| 0 | PRD 결과물 확인, `create`/`update` 선택, 간단으로 분류 | 모드 + 복잡도 |
| 1 | 최소 제품 맥락 수집 | 작업 브리프 |
| 2 | `.hypercore/prd/[slug]/` 생성 또는 찾기 | 저장 대상 |
| 3 | `prd.md` + `sources.md` 작성 또는 갱신 | 살아있는 PRD |
| 4 | 범위, 인용, 오픈 질문 검증 | 최종 PRD 폴더 |

## 복잡 경로

| Phase | 작업 | 결과물 |
|-------|------|--------|
| 0 | PRD 결과물 확인, `create`/`update` 선택, 복잡으로 분류 | 모드 + 복잡도 |
| 1 | `.hypercore/prd/[slug]/` 생성/찾기, `flow.json` 작성 (`brief: in_progress`) | 저장 대상 + 플로우 |
| 2 | 제품 맥락 수집 → 플로우 `brief: completed` 업데이트 | 작업 브리프 |
| 3 | 필요 시 라이브 조사 → 플로우 `research: completed` (또는 `skipped`) | 근거 |
| 4 | `prd.md` 작성/갱신 → 플로우 `draft: completed` | 살아있는 PRD |
| 5 | `sources.md` 작성/갱신 → 플로우 `sources: completed` | 근거 로그 |
| 6 | 검증 및 마무리 → 플로우 `validate: completed`, status: `completed` | 최종 PRD 폴더 |

### Phase 규칙

- 요청이 개선이면 새 문서를 만들기보다 기존 PRD를 우선 갱신합니다.
- 현재 시장, 사용자, 법무, 기술, 경쟁 정보에 의존하면 작성 전에 서로 다른 쿼리로 라이브 조사를 수행합니다.
- 사용자가 이미 신뢰 가능한 맥락을 충분히 제공했다면 외부 조사를 억지로 추가하지 않습니다.
- 메인 PRD는 압축해서 유지합니다. 원시 근거 누적은 `sources.md`에 둡니다.
- 새 정보가 기존 결정을 명확히 뒤집지 않는 한 기존 결정은 보존합니다.

</workflow>

<required>

- 복잡도 분류 완료 (간단/복잡) 후 작업을 시작합니다.
- 모든 PRD는 `.hypercore/prd/[slug]/` 아래에 저장합니다.
- slug는 ASCII kebab-case를 우선합니다.
- 목표, 범위, 비범위, 요구사항, 메트릭, 리스크/의존성, 오픈 질문, 변경 이력 섹션을 명시합니다.
- 조사 근거가 들어간 비자명한 주장에는 링크를 붙입니다.
- 갱신 시에는 중요한 결정을 조용히 덮어쓰지 말고 날짜가 있는 변경 이력 행을 추가합니다.
- 복잡 경로: `flow.json`을 유지하고 각 단계 완료 후 업데이트합니다.

</required>

<forbidden>

- 폴더를 저장하지 않고 채팅에만 PRD를 쓰는 것
- 한 섹션만 바꾸면 되는데 PRD 전체를 갈아엎는 것
- 해결되지 않은 질문이나 가정을 숨기는 것
- 원시 조사 메모를 메인 PRD 본문에 섞는 것
- PRD 폴더 안에 불필요한 README나 changelog 파일을 만드는 것
- 복잡 경로에서 `flow.json` 업데이트를 누락하는 것

</forbidden>
