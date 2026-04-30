# 저장과 갱신

스킬이 패키지 파일을 만들거나 바꿀 때 이 규칙 파일을 사용합니다.

## 1. 폴더 위치

각 기획 패키지는 여기에 저장합니다.

`.hypercore/prd/[slug]/`

새 패키지 기본 파일:

- `prd.md`
- `diagram.md`
- `diagram.data.json`
- `diagram.svg`
- `feature-spec.md`
- `user-flow.md`
- `wireframe.md`
- `preview.html`
- `sources.md`

복잡 패키지는 추가로 포함합니다.

- `flow.json`

## 2. Slug 규칙

- 짧은 ASCII kebab-case slug를 우선합니다.
- 전체 요청 문장 말고 이니셔티브나 기능 이름을 기준으로 만듭니다.
- 같은 주제를 갱신하는 요청이면 기존 slug를 재사용합니다.

좋은 예:

- `billing-retry-flow`
- `team-inbox-assignment`
- `ai-planning-assistant`

피할 것:

- 문장 전체를 slug로 쓰는 것
- 날짜가 제품 개념의 일부가 아닌데 날짜를 넣는 것
- 같은 이니셔티브에 폴더를 여러 개 만드는 것

## 3. 파일 역할

- `prd.md`: 제품 결정 기록과 요구사항
- `diagram.md`: 시각 기획 맵 설명과 Mermaid/text 원본
- `diagram.data.json`: 결정적 SVG 렌더링을 위한 노드 데이터
- `diagram.svg`: `scripts/render-planning-map.mjs`로 생성한 카드/커넥터 형태의 시각 맵
- `feature-spec.md`: 기능 동작, 수락 기준, 상태, 권한, 분석 이벤트, 출시 메모
- `user-flow.md`: 사용자 여정, 분기, 결정 지점, 빈/오류 상태, 진입/종료 지점
- `wireframe.md`: 저충실도 화면 목록과 텍스트 와이어프레임
- `preview.html`: `assets/preview.template.html`에서 `scripts/build-preview.mjs`로 생성하는 로컬 브라우저 뷰어
- `sources.md`: 제공된 맥락, 조사 쿼리, 출처 메모, 근거 공백
- `flow.json`: 복잡 패키지 전용 단계 상태

사용자가 명시적으로 요구하지 않는 한 README, notes, changelog 같은 추가 파일은 만들지 않습니다.

## 4. 생성 흐름

폴더가 없을 때는:

- 폴더를 만듭니다
- 각 마크다운 파일은 대응 템플릿 자산으로 만들고 `diagram.data.json`은 JSON 템플릿으로 만듭니다
- 모르는 내용은 조용히 비우지 말고 명시적 가정 또는 오픈 질문으로 남깁니다
- `scripts/render-planning-map.mjs`로 `diagram.data.json`에서 `diagram.svg`를 렌더링합니다
- 패키지 콘텐츠 작성 후 `scripts/build-preview.mjs`로 `preview.html`을 만듭니다
- 복잡하면 `references/flow-schema.md`를 기준으로 `flow.json`을 초기화합니다

## 5. 갱신 흐름

폴더가 이미 있으면:

- 현재 패키지 파일을 먼저 읽습니다
- 누락된 기본 파일은 템플릿으로 만든 뒤 종속 내용을 갱신합니다
- 바뀐 섹션만 수정합니다
- 기존 링크, 기존 결정, 유용한 맥락은 보존합니다
- `prd.md` 변경 이력 섹션에 날짜가 있는 항목을 추가합니다
- 명확히 폐기된 경우가 아니면 기존 근거를 지우지 않고 `sources.md`에 새 조사/맥락을 추가합니다
- 패키지 콘텐츠, 다이어그램, 출처 로그가 바뀌면 `preview.html`을 다시 생성합니다

## 6. 폴더가 없을 때의 복구

사용자가 패키지 갱신을 요구했는데 맞는 폴더가 없으면:

- 새 폴더를 만듭니다
- 기준 문서가 없었다는 점을 `prd.md` 변경 이력에 가정으로 남깁니다
- `create` 모드로 계속 진행합니다
