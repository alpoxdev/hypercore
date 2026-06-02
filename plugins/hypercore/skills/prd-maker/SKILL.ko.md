---
name: prd-maker
description: "러프한 제품 아이디어를 ManyFast 스타일의 AI 기획 패키지로 생성하거나 갱신합니다: PRD, 시각 기획 다이어그램, 기능 명세서, 유저 플로우, 저충실도 와이어프레임, HTML 미리보기 뷰어, 출처 로그, 선택적 flow 추적을 `.hypercore/prd/[slug]/` 아래에 저장합니다. 구현 전 PRD와 다이어그램/스펙/플로우/와이어프레임이 필요할 때 사용합니다."
compatibility: 로컬 파일 검색/편집 도구와, 최신 시장·사용자·제품·법무·기술 근거가 필요할 때 라이브 웹 검색이 가능한 환경에서 가장 잘 동작합니다.
---

@rules/package-workflow.ko.md
@rules/storage-and-updates.ko.md
@rules/validation.ko.md
@references/planning-package.ko.md
@references/prd-sections.ko.md

# PRD Maker

> 러프한 제품 아이디어를 검토 가능한 AI 기획 패키지로 바꿉니다: PRD, 기획 다이어그램, 기능 명세서, 유저 플로우, 와이어프레임, 미리보기 뷰어, 출처 로그.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- 짧은 제품 아이디어, 기능 요청, 이니셔티브 메모를 `.hypercore/prd/[slug]/` 아래의 기획 폴더로 생성하거나 갱신합니다.
- 구현 전 팀이 검토할 수 있는 핵심 산출물인 PRD, 시각 기획 맵, 기능 상세, 유저 플로우, 저충실도 와이어프레임, 브라우저 미리보기를 만듭니다.
- 아이디어가 완전히 정해진 척하지 않고 가정, 오픈 질문, 범위 결정, 근거를 드러냅니다.

</purpose>

<routing_rule>

주된 결과물이 저장되는 제품 기획 패키지, 기획 다이어그램, PRD, 기능 명세, 유저 플로우, 와이어프레임, 미리보기 뷰어면 `prd-maker`를 사용합니다.

아직 사실 조사만 필요하고 기획 패키지를 작성하지 않는다면 `research`를 사용합니다.

출력이 제품 요구사항이 아닌 일반 문서, 런북, 가이드, 기술 스펙이면 `docs-maker`를 사용합니다.

사용자가 파일 저장 없이 논의나 작업 계획만 원하면 `plan`을 사용합니다.

다음 경우에는 `prd-maker`를 사용하지 않습니다.

- 저장 산출물 없는 브레인스토밍만 원하는 경우
- 구현, 코딩, 디버깅이 목표인 경우
- 제품 요구사항/기획 산출물이 아니라 일반 마크다운 문서만 원하는 경우

</routing_rule>

<activation_examples>

긍정 요청:

- "팀 인박스 배정 기능 PRD랑 플로우 만들어줘."
- "결제 재시도 기능을 ManyFast 비슷한 기획 산출물로 만들어줘."
- "이 앱 아이디어를 PRD, 다이어그램, 기능명세서, 유저 플로우, 와이어프레임 문서로 바꿔줘."
- "기존 온보딩 PRD에 새 플로우랑 수락 기준 반영해줘."

부정 요청:

- "경쟁사 온보딩 방식을 조사해줘."
- "결제 재시도 플로우 구현해줘."
- "지원팀 런북을 다시 써줘."

경계 요청:

- "코딩 전에 이 기능 기획해줘."
  결과물이 `.hypercore/prd/` 아래의 저장된 기획 패키지여야 할 때만 `prd-maker`를 사용합니다. 아니면 `plan`으로 라우팅합니다.

</activation_examples>

<trigger_conditions>

| 상황 | 모드 |
|------|------|
| 러프한 제품 아이디어를 완성형 기획 패키지로 만들어야 함 | create |
| PRD에 다이어그램, 기능 명세, 유저 플로우, 와이어프레임을 보강해야 함 | update |
| 기존 기획 문서의 범위, 요구사항, 메트릭, 리스크, 플로우를 갱신해야 함 | update |
| 릴리스나 이니셔티브가 구현 전 근거 기반 요구사항을 필요로 함 | create/update |

</trigger_conditions>

<supported_targets>

- `.hypercore/prd/[slug]/` 아래의 새 기획 패키지 폴더
- `.hypercore/prd/[slug]/` 아래의 기존 패키지 갱신
- 제품 요구사항 `prd.md`
- ManyFast 같은 가지형 기획 맵 원본 `diagram.md`, 노드 데이터 `diagram.data.json`, 렌더링된 `diagram.svg`
- 기능 동작과 수락 기준 `feature-spec.md`
- 액터 여정, 상태, 예외 흐름 `user-flow.md`
- 텍스트 기반 저충실도 와이어프레임 `wireframe.md`
- 패키지 파일과 `assets/preview.template.html`에서 생성되는 브라우저 뷰어 `preview.html`
- 근거, 쿼리, 컨텍스트 로그 `sources.md`
- 복잡한 다중 세션 패키지의 단계 추적 `flow.json`

</supported_targets>

<complexity_classification>

파일 작성 전에 분류합니다.

| 복잡도 | 신호 | 경로 |
|--------|------|------|
| **간단** | 단일 기능, 명확한 대상, 미지수 적음, 조사 최소, 작은 산출물 | 직접 패키지 — flow 추적 없이 핵심 마크다운 파일과 출처 로그 작성 |
| **복잡** | 다중 기능 이니셔티브, 모호하거나 고위험 범위, 외부 조사, 여러 페르소나, 팀 간 의존성, 단계적 출시 | 추적 패키지 — `flow.json` 추가 및 유지 |

분류 결과를 알립니다.

```text
복잡도: [간단/복잡] — [한 줄 근거]
```

애매하면 복잡으로 분류합니다. 작은 flow 파일을 유지하는 비용보다 단계 상태를 잃는 비용이 큽니다.

</complexity_classification>

<output_shape>

기본 패키지 형태:

```text
.hypercore/prd/[slug]/
├── prd.md
├── diagram.md
├── diagram.data.json
├── diagram.svg
├── feature-spec.md
├── user-flow.md
├── wireframe.md
├── preview.html
├── sources.md
└── flow.json          (복잡 경로만)
```

- `prd.md`는 문제, 목표, 범위, 요구사항, 메트릭, 리스크, 오픈 질문 같은 제품 결정을 설명합니다.
- `diagram.md`는 중앙 아이디어에서 PRD/스펙/플로우/와이어프레임 가지로 뻗는 ManyFast 같은 기획 맵과 핵심 하위 노드/공백을 담습니다.
- `diagram.data.json`은 `scripts/render-planning-map.mjs`의 입력이며, 이 스크립트는 의존성 추가 없이 카드/커넥터 형태의 `diagram.svg`를 렌더링합니다.
- `feature-spec.md`는 PRD를 기능 동작, 수락 기준, 상태, 예외 케이스로 풀어냅니다.
- `user-flow.md`는 핵심 경로, 분기점, 빈/오류 상태, 핸드오프를 캡처합니다.
- `wireframe.md`는 시각 작업 전에 구조를 검토할 수 있도록 화면과 레이아웃 블록을 텍스트로 묘사합니다.
- `preview.html`은 빠른 검토를 위해 패키지 콘텐츠와 `diagram.svg`를 로컬 브라우저 뷰어로 임베드합니다.
- `sources.md`는 제공된 맥락, 조사 쿼리, 링크, 근거 공백을 기록합니다.
- `flow.json`은 복잡 패키지의 단계 진행을 추적합니다. `references/flow-schema.md`를 봅니다.

처음 폴더를 만들 때는 `assets/` 안의 템플릿을 사용합니다. 다이어그램은 `diagram.md`, `diagram.data.json`, `diagram.svg`를 만들고, 새 의존성 없이 렌더링되는 `scripts/render-planning-map.mjs`를 우선 사용합니다.

</output_shape>

<support_file_read_order>

다음 순서로 읽습니다.

1. 이 코어 `SKILL.ko.md`에서 요청이 기획 패키지에 해당하는지 확인합니다.
2. `rules/package-workflow.ko.md`에서 create/update, 복잡도, 조사 필요 여부, 패키지 단계 순서를 결정합니다.
3. `rules/storage-and-updates.ko.md`에서 폴더, slug, 파일, 병합 규칙을 적용합니다.
4. `diagram.md`, `feature-spec.md`, `user-flow.md`, `wireframe.md` 작성 시 `references/planning-package.ko.md`를 봅니다.
5. `prd.md` 작성/갱신 시 `references/prd-sections.ko.md`를 봅니다.
6. 누락된 패키지 파일을 만들 때 `assets/`의 관련 템플릿을 봅니다. `diagram.data.template.ko.json`도 포함합니다.
7. `diagram.data.json`에서 `diagram.svg`를 렌더링할 때 `scripts/render-planning-map.mjs`를 사용합니다.
8. `preview.html` 생성 시 `assets/preview.template.html`과 `scripts/build-preview.mjs`를 사용합니다.
9. 라이브 조사가 필요하고 패키지에 출처 기록이 필요하면 `assets/sources.template.ko.md`를 봅니다.
10. 복잡 패키지이거나 `flow.json`이 이미 있으면 `references/flow-schema.md`를 봅니다.
11. 완료 선언 전에는 `rules/validation.ko.md`를 봅니다.

</support_file_read_order>

<workflow>

## 직접 패키지 경로

| Phase | 작업 | 결과물 |
|-------|------|--------|
| 0 | 패키지 산출물 확인, create/update 선택, 간단으로 분류 | 모드 + 복잡도 |
| 1 | 최소 브리프를 추출/추론하고 미해결 공백은 오픈 질문으로 남김 | 작업 브리프 |
| 2 | `.hypercore/prd/[slug]/` 생성 또는 찾기 | 저장 대상 |
| 3 | `prd.md`, `diagram.md`, `feature-spec.md`, `user-flow.md`, `wireframe.md`, `preview.html`, `sources.md` 작성/갱신 | 검토 가능한 패키지 |
| 4 | 일관성, 범위, 근거, 미지수 검증 | 최종 패키지 |

## 추적 패키지 경로

| Phase | 작업 | 결과물 |
|-------|------|--------|
| 0 | 패키지 산출물 확인, create/update 선택, 복잡으로 분류 | 모드 + 복잡도 |
| 1 | 폴더 생성/탐색 후 `flow.json` 초기화 또는 재개 | 저장 대상 + 단계 상태 |
| 2 | 최소 브리프 수집 후 `flow.json` 갱신 | 작업 브리프 |
| 3 | 필요 시 라이브 조사 또는 생략 사유 기록 | 근거 기반 |
| 4 | PRD, 다이어그램, 기능 명세, 유저 플로우, 와이어프레임, 미리보기, 출처를 단계별 작성/갱신 | 기획 패키지 |
| 5 | 검증 후 flow 완료 처리 | 최종 패키지 |

### 운영 규칙

- 사용자의 러프한 아이디어에서 시작하고, 저위험 기본값만 추론하며 나머지는 가정 또는 오픈 질문으로 표시합니다.
- 누락된 답이 제품 방향을 크게 갈라놓을 때만 질문합니다.
- 최신 시장, 경쟁사, 법무, 플랫폼, 기술 사실이 요구사항에 영향을 주면 최종 주장 전에 라이브 조사를 수행합니다.
- 기존 패키지는 외과적으로 갱신합니다. 유효한 결정은 보존하고 전체 재작성 대신 날짜 있는 변경 이력을 추가합니다.
- 원시 조사와 맥락은 PRD 본문이 아니라 `sources.md`에 둡니다.
- 다이어그램은 장식 이미지가 아니라 탐색 가능한 제품 맵으로 취급합니다.
- 패키지 콘텐츠가 바뀌면 `preview.html`을 다시 생성해 뷰어가 낡지 않게 합니다.
- 와이어프레임은 완성 디자인이 아니라 구조 검토 산출물로 취급합니다.

</workflow>

<required>

- 파일 작성 전 복잡도를 분류합니다.
- 모든 패키지는 `.hypercore/prd/[slug]/` 아래에 저장하고 ASCII kebab-case slug를 우선합니다.
- 새 패키지는 `prd.md`, `diagram.md`, `diagram.data.json`, `diagram.svg`, `feature-spec.md`, `user-flow.md`, `wireframe.md`, `preview.html`, `sources.md`를 포함합니다.
- PRD에는 목표, 범위, 비목표, 요구사항, 메트릭, 리스크/의존성, 오픈 질문, 변경 이력이 있습니다.
- 다이어그램에는 중앙 이니셔티브 노드, 1차 기획 가지, 2차 요구사항/플로우/화면 노드, 오픈 공백이 있습니다.
- 기능 명세에는 기능 요구사항, 수락 기준, 상태, 오류, 권한, 분석 이벤트, 필요 시 출시 메모가 있습니다.
- 유저 플로우에는 액터, 정상 경로, 대안 경로, 예외/오류 상태, 진입/종료 지점이 있습니다.
- 와이어프레임에는 화면 목록, 레이아웃 블록, 컴포넌트 메모, 미해결 시각/제품 질문이 있습니다.
- HTML 미리보기는 로컬 브라우저에서 열리며 다이어그램과 텍스트 산출물을 포함합니다.
- `sources.md`에는 제공된 맥락과 서로 다른 조사 쿼리 또는 외부 조사가 불필요했던 이유가 있습니다.
- 복잡 패키지는 `flow.json`을 유지하고 각 단계 후 갱신합니다.

</required>

<forbidden>

- 기획 패키지를 파일로 저장하지 않고 채팅에만 반환하는 것.
- 새 패키지를 만들면서 PRD만 만들고 다이어그램, 기능 명세, 플로우, 와이어프레임, 미리보기를 누락하는 것.
- 가정이나 미해결 질문을 숨기는 것.
- 원본 자료를 요약/링크하지 않고 PRD에 그대로 복사하는 것.
- 사용자가 명시하지 않았는데 README, notes, changelog 같은 추가 파일을 만드는 것.
- 다이어그램을 최종 아키텍처처럼 취급하거나 와이어프레임을 최종 UI 디자인/구현 코드처럼 취급하는 것.

</forbidden>
