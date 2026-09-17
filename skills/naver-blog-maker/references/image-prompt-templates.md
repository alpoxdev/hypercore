# Image Prompt Templates (JSON)

> Korean version: [`image-prompt-templates.ko.md`](image-prompt-templates.ko.md)

Read this when the draft contains any `[이미지 생성: … | 프롬프트 #n]` marker ([`../rules/image-slots.md`](../rules/image-slots.md) §3-§4). Each generated image gets one JSON object built from the schema in §1, delivered as a fenced `json` block the user pastes into an image tool. The object describes the picture only.

**Authority**: this file owns the detailed schema and the role → template matrix. [`image-slots.md`](../rules/image-slots.md) §6 owns the compilation order and the field rules; §3 there owns what may never be generated. Where they disagree, `image-slots.md` §3 wins, then this file.

## 1. Schema

Fourteen fields are always present. Eight more appear only when they carry meaning; an inapplicable field is **absent**, never filled with `null`, `"N/A"`, `"없음"`, `"위와 동일"`, `"same as above"`, or a brace placeholder.

| Key | Status | Content |
|---|---|---|
| `id` | always | `"프롬프트 #n"`, matching the body marker one-to-one |
| `section_role` | always | one of the 14 roles in §2 |
| `template` | always | one template ID from that role's row in §2 |
| `use` | always | where it sits in the post and what it must make clear, one sentence |
| `hierarchy` | always | `{ "first": …, "second": …, "background": … }` — the order the viewer's eye must follow |
| `subject` | always | the principal thing with its distinguishing attributes; a brand, product, person, or real place appears only when the user supplied it as a brand fact and it is not a logo |
| `composition` | always | framing, viewpoint, scale, placement, depth, crop, and deliberately empty space |
| `style` | always | medium, drawing language, line and shape language. Palette belongs in `color`; surface and texture belong in `material_and_rendering` |
| `must_include` | always | 2-5 concrete visible elements the section's claim depends on |
| `must_exclude` | always | positive conditions where possible (`unbranded surfaces`, `no readable logos`, `no human faces`) plus anything the post must not imply |
| `inspection_checks` | always | 3-6 observable criteria to check against a returned artifact |
| `aspect` | always | `"4:3"`, `"16:9"`, `"1:1"`, `"3:4"` — a composition constraint, never a provider size flag |
| `caption_note` | always | copy of the marker caption, so image and caption stay consistent |
| `prompt` | always | the complete, paste-ready natural-language brief: the visual fields above (`use`, `hierarchy`, `subject`, `scene`, `composition`, `lighting`, `color`, `material_and_rendering`, `text`, `must_include`, `must_exclude`, `aspect`) written out as instruction, carrying each `text[].string` byte-identical. It does not restate the bookkeeping fields (`id`, `section_role`, `template`, `caption_note`). Adds no fact, brand, person, number, or provider parameter beyond them |
| `scene` | conditional | action or state, environment, time, weather — only when visually meaningful. Never a filler such as `"정적 표, 배경 없음"` |
| `lighting` | conditional | direction, softness, contrast, shadow behaviour, separation — photo-like or 3D rendering only |
| `color` | conditional | `{ "dominant": …, "support": …, "accent": …, "contrast": … }`; on monochrome output include only the members that apply |
| `material_and_rendering` | conditional | surface response, edge behaviour, texture, matte/gloss, vector/ink/paper |
| `text` | conditional | only when lettering is rendered inside the image |
| `series_invariants` | conditional | only when 2 or more images are intended as ONE visual series: the shared invariants repeat identically in every object of that series. Independent images of different roles omit it |
| `reference` | conditional | only when the user supplied a reference: `{ "role": "inspiration" \| "edit_source", "source": …, "preserve": …, "change": … }` |
| `assumptions` | conditional | reversible presentation choices adopted instead of asking the user |

### `text` item shape

```json
{
  "string": "정확히 그려질 문구",
  "role": "title | label | callout | axis | value",
  "placement": "캔버스 안 위치",
  "reading_order": 1,
  "priority": "primary | secondary",
  "scale": "캔버스 폭 대비 비율",
  "contrast": "글자와 배경의 대비 조건",
  "clearance": "글자 주위 여백"
}
```

Each `string` appears exactly once inside `text[]` — the same label is never listed twice — and `prompt` must carry every one of those strings byte-identical, so the paste-ready text renders exactly the labels `text[]` defines. Descriptive prose inside `prompt` may reuse those words while describing the scene, but `prompt` must never introduce a rendered label that `text[]` does not carry. Write the string in Korean exactly as it must appear; never translate, correct, shorten, or add to it.

### Rules for every object

- One object per generated image. No placeholders left anywhere.
- No provider, model, quality, tier, resolution, or API parameter — this is a portable descriptive brief, not a vendor payload.
- Never borrow a living artist, a real person, or a trademark as a style shortcut; describe the visible properties instead.
- Describe what is observable. `"premium"`, `"beautiful"`, and other empty praise are not instructions.
- A generated image is labelled as an illustration in its caption whenever it could be mistaken for a photograph.
- `prompt` is derived only from the structured fields: it may restate them and must not introduce a new fact.

## 2. Section roles and templates

Pick the role from the section's job in the post, then the template from that role's row. Pick `comparison-table` when the draft already carries row/column data, `comparison-split` when form or state side by side is the point, and `before-after-schematic` when the change is temporal.

| section_role | template ID(s) |
|---|---|
| `cover` | `cover-key-visual` |
| `first-screen` | `first-screen-key-takeaway` |
| `mechanism` | `mechanism-cutaway`, `mechanism-flow` |
| `comparison` | `comparison-table`, `comparison-split`, `before-after-schematic` |
| `process` | `process-flow` |
| `cost` | `cost-breakdown` |
| `checklist` | `checklist-card` |
| `caution` | `failure-caution` |
| `data` | `data-chart` |
| `timeline` | `timeline` |
| `route` | `route-schematic` |
| `scale` | `scale-dimension` |
| `closing` | `closing-next-step` |
| `concept` | `concept-mood` |

Two role limits worth repeating here. `route-schematic` covers a **logical** flow (신청 → 접수 → 방문) or a route the user supplied; real geography, entrances, and street relationships stay real-material `[이미지: …]` markers. `data-chart`, `cost-breakdown`, and `scale-dimension` render only numbers the draft already carries with a source; otherwise they express the structure without numerals.

### 2.1 cover — `cover-key-visual`

```json
{
  "id": "프롬프트 #1",
  "section_role": "cover",
  "template": "cover-key-visual",
  "use": "커버. 실제 현장 사진이 없을 때 주제를 한 장면으로 요약하되 사진으로 오해되지 않게 일러스트로 남긴다.",
  "hierarchy": {
    "first": "지게차 앞 바닥의 반원형 감지 영역",
    "second": "멈춰 선 지게차와 그 앞을 지나는 보행자 실루엣",
    "background": "양옆으로 늘어선 창고 선반"
  },
  "subject": "지게차 한 대와 그 앞을 지나는 얼굴 없는 보행자 실루엣. 브랜드 표기가 없는 일반 장비",
  "composition": "약간 높은 3/4 시점. 지게차는 왼쪽 1/3, 보행자는 오른쪽 1/3, 상단 1/4은 제목을 얹을 빈 공간으로 비워 둔다",
  "style": "soft flat illustration, 단순한 형태 언어, 외곽선 없음, 사진 질감 없음",
  "color": {
    "dominant": "연회색 바닥과 배경",
    "support": "진회색 지게차와 선반",
    "accent": "주황색 감지 영역",
    "contrast": "감지 영역과 바닥의 명도 차"
  },
  "lighting": "부드러운 확산광, 긴 그림자 없음, 매트한 표면",
  "material_and_rendering": "평면 벡터, 균일한 채도, 질감 없는 매트 마감",
  "text": [
    {
      "string": "보행자 감지 정지장치",
      "role": "title",
      "placement": "상단 중앙 한 줄",
      "reading_order": 1,
      "priority": "primary",
      "scale": "캔버스 폭의 40%",
      "contrast": "연회색 배경 위 진회색 글자",
      "clearance": "좌우 10% 여백"
    }
  ],
  "must_include": ["바닥의 반원형 감지 영역", "보행자 실루엣", "선반 배경", "지게차 앞코"],
  "must_exclude": ["얼굴 있는 사람", "브랜드 로고", "읽을 수 있는 다른 글자", "사진 같은 질감"],
  "inspection_checks": ["감지 영역이 첫 시선으로 읽히는가", "실루엣에 얼굴이 없는가", "상단 1/4이 비어 있는가", "문구가 정확히 한 번, 철자 그대로인가"],
  "aspect": "16:9",
  "caption_note": "보행자 감지 정지장치 개념 (일러스트)",
  "assumptions": "커버에 제목 문구가 필요하다고 가정했다. 불필요하면 text와 prompt의 문구를 함께 생략한다.",
  "prompt": "물류창고 통로를 약간 높은 3/4 시점에서 본 평면 벡터 일러스트. 먼저 눈에 들어와야 하는 것은 지게차 앞 바닥에 그려진 주황색 반원형 감지 영역이고, 그다음이 멈춰 선 지게차와 그 앞을 지나는 얼굴 없는 보행자 실루엣, 배경은 양옆으로 늘어선 창고 선반이다. 지게차는 왼쪽 1/3, 보행자는 오른쪽 1/3에 두고 상단 1/4은 글자를 얹을 빈 공간으로 남긴다. 색은 연회색 바닥과 배경이 주, 진회색 지게차와 선반이 보조, 주황 감지 영역이 강조이며 감지 영역과 바닥 사이에 명도 차를 둔다. 부드러운 확산광에 긴 그림자 없이, 질감 없는 매트한 평면 벡터로 그린다. 상단 중앙 한 줄에 '보행자 감지 정지장치'를 정확히 한 번, 연회색 배경 위 진회색으로 캔버스 폭의 40% 크기로 선명하고 철자가 맞게 쓴다. 얼굴 있는 사람, 브랜드 로고, 읽을 수 있는 다른 글자, 사진 같은 질감은 넣지 않는다."
}
```

### 2.2 first-screen — `first-screen-key-takeaway`

```json
{
  "id": "프롬프트 #2",
  "section_role": "first-screen",
  "template": "first-screen-key-takeaway",
  "use": "첫 화면. 제목이 약속한 답을 한 장으로 먼저 보여 주고, 본문이 그 답을 설명하게 한다.",
  "hierarchy": {
    "first": "결론을 담은 큰 숫자 카드",
    "second": "조건을 표시한 작은 라벨 두 개",
    "background": "옅은 격자 배경"
  },
  "subject": "결론 수치를 담은 둥근 사각형 카드 하나와 그 아래 조건 라벨 두 개. 브랜드 표기 없는 일반 그래픽",
  "composition": "정면, 카드는 캔버스 중앙 60% 폭, 라벨은 카드 아래 좌우로 나란히, 상하 여백을 넉넉히 둔다",
  "style": "flat vector infographic, 굵은 산세리프, 얇은 외곽선",
  "color": {
    "dominant": "흰 배경",
    "support": "연회색 격자와 카드 테두리",
    "accent": "결론 수치의 진남색",
    "contrast": "수치와 배경의 큰 명도 차"
  },
  "material_and_rendering": "평면 벡터, 그림자 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "탐지 후 미발견 시 비용 0원",
      "role": "title",
      "placement": "카드 중앙",
      "reading_order": 1,
      "priority": "primary",
      "scale": "카드 폭의 70%",
      "contrast": "흰 카드 위 진남색 글자",
      "clearance": "카드 안쪽 여백 10%"
    }
  ],
  "must_include": ["결론 수치 카드", "조건 라벨 두 개", "옅은 격자 배경"],
  "must_exclude": ["실제 사진처럼 보이는 질감", "로고", "숫자와 무관한 장식 아이콘"],
  "inspection_checks": ["결론이 첫 시선에 읽히는가", "조건 라벨이 수치보다 작은가", "문구가 철자 그대로인가", "여백이 충분한가"],
  "aspect": "4:3",
  "caption_note": "제목이 약속한 결론 요약 (설명 그림)",
  "assumptions": "결론 수치는 사용자가 제공한 가치입증 문구를 그대로 썼다고 가정했다. 다른 수치를 쓰려면 사용자 확인이 필요하다.",
  "prompt": "흰 배경 위에 결론을 한 장으로 요약한 평면 벡터 인포그래픽. 먼저 눈에 들어와야 하는 것은 캔버스 중앙 60% 폭의 둥근 사각형 카드 안 진남색 큰 글씨이고, 그다음이 카드 아래 좌우로 나란히 놓인 작은 조건 라벨 두 개, 배경은 옅은 연회색 격자다. 정면 시점, 상하 여백을 넉넉히 두고 그림자 없이 굵은 산세리프와 균일한 선 굵기로 그린다. 카드 중앙에 '탐지 후 미발견 시 비용 0원'을 정확히 한 번, 흰 카드 위 진남색으로 카드 폭의 70% 크기로 선명하고 철자가 맞게 쓴다. 사진 같은 질감, 로고, 수치와 무관한 장식 아이콘은 넣지 않는다."
}
```

### 2.3 mechanism — `mechanism-cutaway`, `mechanism-flow`

```json
{
  "id": "프롬프트 #3",
  "section_role": "mechanism",
  "template": "mechanism-cutaway",
  "use": "'왜 생기나' 섹션 첫 이미지. 물이 화단 흙에서 방수층 틈을 지나 천장까지 내려오는 경로를 한눈에 보여 준다.",
  "hierarchy": {
    "first": "방수층의 갈라진 틈과 그 틈을 지나는 물 화살표",
    "second": "층별 이름 라벨",
    "background": "같은 두께로 쌓인 수평 밴드 구조"
  },
  "subject": "지하주차장 위 화단의 수직 단면. 위에서부터 흙층, 비노출 방수층, 콘크리트 슬래브, 주차장 천장 순서",
  "composition": "정면 단면, 네 층이 같은 두께로 쌓인 수평 밴드, 왼쪽 여백에 층 이름 라벨, 물길은 파란 점선 화살표 하나",
  "style": "flat vector infographic, 얇은 검은 외곽선, 도형 중심",
  "color": {
    "dominant": "흰 배경",
    "support": "흙은 갈색, 방수층은 진회색, 콘크리트는 연회색",
    "accent": "물의 하늘색",
    "contrast": "방수층 틈과 주변 회색의 명도 차"
  },
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "화단",
      "role": "label",
      "placement": "맨 위 층 왼쪽",
      "reading_order": 2,
      "priority": "secondary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "층 경계에서 4px 이상"
    },
    {
      "string": "비노출 방수층",
      "role": "label",
      "placement": "두 번째 층 왼쪽",
      "reading_order": 3,
      "priority": "secondary",
      "scale": "캔버스 폭의 18%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "층 경계에서 4px 이상"
    },
    {
      "string": "콘크리트층",
      "role": "label",
      "placement": "세 번째 층 왼쪽",
      "reading_order": 4,
      "priority": "secondary",
      "scale": "캔버스 폭의 15%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "층 경계에서 4px 이상"
    },
    {
      "string": "지하주차장 누수의 원인",
      "role": "title",
      "placement": "상단 중앙 한 줄",
      "reading_order": 1,
      "priority": "primary",
      "scale": "캔버스 폭의 45%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "좌우 10% 여백"
    }
  ],
  "must_include": ["방수층의 갈라진 틈 하나", "틈을 통과하는 물 화살표", "천장 아래 물방울과 흰 석회 자국", "각 층 라벨"],
  "must_exclude": ["사람", "회사 로고", "읽을 수 있는 다른 글자", "사진 같은 질감"],
  "inspection_checks": ["틈이 첫 시선으로 읽히는가", "물 화살표가 위에서 아래로 향하는가", "라벨 네 개가 정확히 한 번씩인가", "천장에 물방울이 보이는가"],
  "aspect": "4:3",
  "caption_note": "물은 화단 흙에서 방수층 틈을 지나 천장까지 내려온다 (설명 그림)",
  "prompt": "흰 배경의 평면 벡터 단면도. 먼저 눈에 들어와야 하는 것은 비노출 방수층의 갈라진 틈과 그 틈을 통과해 아래로 향하는 파란 점선 화살표이고, 그다음이 층별 이름 라벨, 배경은 같은 두께로 쌓인 수평 밴드 구조다. 위에서부터 흙층, 비노출 방수층, 콘크리트 슬래브, 지하주차장 천장 순서로 정면 단면을 그리고, 왼쪽 여백에 층 이름을 둔다. 흙은 갈색, 방수층은 진회색, 콘크리트는 연회색, 물은 하늘색으로 하고 방수층 틈과 주변 회색 사이에 명도 차를 둔다. 얇은 검은 외곽선, 질감 없는 평면 벡터로 그린다. 위에서 아래 순서로 '지하주차장 누수의 원인'을 상단 중앙 한 줄에, '화단'을 맨 위 층 왼쪽에, '비노출 방수층'을 두 번째 층 왼쪽에, '콘크리트층'을 세 번째 층 왼쪽에 각각 정확히 한 번씩 선명하고 철자가 맞게 쓴다. 사람, 회사 로고, 읽을 수 있는 다른 글자, 사진 같은 질감은 넣지 않는다."
}
```

```json
{
  "id": "프롬프트 #4",
  "section_role": "mechanism",
  "template": "mechanism-flow",
  "use": "'어떻게 막나' 섹션. 주입재가 틈으로 들어가 굳어 물길을 끊는 세 단계를 화살표로 잇는다.",
  "hierarchy": {
    "first": "왼쪽에서 오른쪽으로 이어지는 세 단계 상자",
    "second": "상자 사이 화살표",
    "background": "단면 위에 겹쳐 그린 주입 지점"
  },
  "subject": "같은 콘크리트 단면 위에 표시한 주입 지점 세 곳과, 그 아래 나란히 놓인 세 단계 상자",
  "composition": "가로 3분할, 각 상자 상단에 단계 번호, 하단 1/5은 캡션을 얹을 빈 공간",
  "style": "clean isometric cutaway, 균일한 선 굵기, 그림자 없음",
  "material_and_rendering": "평면 벡터, 부드러운 파스텔 채도",
  "text": [
    {
      "string": "주입",
      "role": "label",
      "placement": "1단계 상자 중앙",
      "reading_order": 2,
      "priority": "primary",
      "scale": "상자 폭의 40%",
      "contrast": "연회색 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    },
    {
      "string": "충전",
      "role": "label",
      "placement": "2단계 상자 중앙",
      "reading_order": 3,
      "priority": "primary",
      "scale": "상자 폭의 40%",
      "contrast": "연회색 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    },
    {
      "string": "차단",
      "role": "label",
      "placement": "3단계 상자 중앙",
      "reading_order": 4,
      "priority": "primary",
      "scale": "상자 폭의 40%",
      "contrast": "연회색 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    }
  ],
  "must_include": ["세 단계 상자", "상자를 잇는 화살표 두 개", "단면 위 주입 지점 표시", "마지막 단계에서 멈춘 물"],
  "must_exclude": ["제품명이나 브랜드 표기", "사람", "실제 사진처럼 보이는 질감"],
  "inspection_checks": ["세 단계가 왼쪽에서 오른쪽으로 읽히는가", "화살표가 두 개인가", "마지막 단계에서 물이 멈춘 것이 보이는가", "라벨 세 개의 철자가 정확한가"],
  "aspect": "16:9",
  "caption_note": "주입재가 틈을 채워 물길을 끊는 순서 (설명 그림)",
  "prompt": "부드러운 파스텔 색의 평면 아이소메트릭 단면도. 먼저 눈에 들어와야 하는 것은 왼쪽에서 오른쪽으로 이어지는 세 단계 상자이고, 그다음이 상자를 잇는 화살표 두 개, 배경은 단면 위에 겹쳐 그린 주입 지점 표시다. 같은 콘크리트 단면을 그리고 그 아래에 세 단계 상자를 가로 3분할로 나란히 두며, 하단 1/5은 캡션용 빈 공간으로 남긴다. 균일한 선 굵기, 그림자 없는 매트한 평면 벡터로 그린다. 왼쪽부터 '주입', '충전', '차단'을 각 상자 중앙에 정확히 한 번씩, 연회색 상자 위 진회색으로 상자 폭의 40% 크기로 선명하고 철자가 맞게 쓴다. 제품명이나 브랜드 표기, 사람, 사진 같은 질감은 넣지 않는다."
}
```

### 2.4 comparison — `comparison-table`, `comparison-split`, `before-after-schematic`

```json
{
  "id": "프롬프트 #5",
  "section_role": "comparison",
  "template": "comparison-table",
  "use": "'방법별 비교' 섹션. 초안의 표를 이미지로 만들어 모바일 한 화면에서 읽히게 한다.",
  "hierarchy": {
    "first": "헤더 행",
    "second": "본문 셀",
    "background": "옅은 격자선"
  },
  "subject": "3열 2행 비교표. 값은 초안에 있는 글자만 쓴다",
  "composition": "표가 캔버스 90%를 채우고, 헤더 행은 진한 배경, 첫 열은 항목명, 셀 글자는 크게, 하단 1/10은 캡션용 여백",
  "style": "flat vector, 흰 배경, 얇은 연회색 격자",
  "color": {
    "dominant": "흰 배경",
    "support": "연회색 격자선",
    "accent": "진남색 헤더 배경",
    "contrast": "헤더 흰 글자와 진남색 배경"
  },
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "구분",
      "role": "label",
      "placement": "헤더 첫 열",
      "reading_order": 1,
      "priority": "primary",
      "scale": "셀 폭의 60%",
      "contrast": "진남색 배경 위 흰 글자",
      "clearance": "셀 안쪽 여백"
    },
    {
      "string": "경고등",
      "role": "label",
      "placement": "헤더 두 번째 열",
      "reading_order": 2,
      "priority": "primary",
      "scale": "셀 폭의 60%",
      "contrast": "진남색 배경 위 흰 글자",
      "clearance": "셀 안쪽 여백"
    },
    {
      "string": "감지 정지장치",
      "role": "label",
      "placement": "헤더 세 번째 열",
      "reading_order": 3,
      "priority": "primary",
      "scale": "셀 폭의 70%",
      "contrast": "진남색 배경 위 흰 글자",
      "clearance": "셀 안쪽 여백"
    },
    {
      "string": "운전자 주의에 의존",
      "role": "value",
      "placement": "2행 2열",
      "reading_order": 5,
      "priority": "secondary",
      "scale": "셀 폭의 70%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "셀 안쪽 여백"
    },
    {
      "string": "장비를 직접 정지",
      "role": "value",
      "placement": "2행 3열",
      "reading_order": 6,
      "priority": "secondary",
      "scale": "셀 폭의 70%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "셀 안쪽 여백"
    }
  ],
  "must_include": ["모든 셀에 글자", "헤더 행 강조", "3열 2행 구조"],
  "must_exclude": ["아이콘", "장식 이미지", "로고", "초안에 없는 수치"],
  "inspection_checks": ["헤더가 첫 시선으로 읽히는가", "모든 셀이 채워졌는가", "글자가 모바일에서 읽히는 크기인가", "초안에 없는 숫자가 없는가"],
  "aspect": "4:3",
  "caption_note": "경고등과 감지 정지장치의 차이 (요약표)",
  "prompt": "흰 배경의 평면 벡터 비교표 이미지. 먼저 눈에 들어와야 하는 것은 진남색 배경의 헤더 행이고, 그다음이 본문 셀, 배경은 옅은 연회색 격자선이다. 3열 2행 구조로 표가 캔버스 90%를 채우게 하고, 첫 열은 항목명, 셀 글자는 크게, 하단 1/10은 캡션용 여백으로 남긴다. 질감 없이 얇은 격자선과 균일한 선 굵기로 그린다. 헤더 첫 열에 '구분', 두 번째 열에 '경고등', 세 번째 열에 '감지 정지장치'를, 2행 2열에 '운전자 주의에 의존', 2행 3열에 '장비를 직접 정지'를 각각 정확히 한 번씩 진남색 배경 위 흰 글자 또는 흰 배경 위 검은 글자로 선명하고 철자가 맞게 쓴다. 아이콘, 장식 이미지, 로고, 초안에 없는 수치는 넣지 않는다."
}
```

```json
{
  "id": "프롬프트 #6",
  "section_role": "comparison",
  "template": "comparison-split",
  "use": "'어느 쪽이 맞나' 섹션. 두 방식의 형태 차이를 같은 시점과 같은 크기로 나란히 놓아 비교한다.",
  "hierarchy": {
    "first": "두 패널의 형태 차이",
    "second": "패널 상단 라벨",
    "background": "같은 회색 배경"
  },
  "subject": "같은 장비 두 대를 좌우로 나란히 배치. 브랜드 표기 없는 일반 장비",
  "composition": "좌우 2분할, 가운데 얇은 세로 구분선, 각 패널 상단에 라벨, 하단 1/5은 빈 여백",
  "style": "flat vector, 동일한 선 굵기, 그림자 없음",
  "color": {
    "dominant": "연회색 배경",
    "support": "진회색 장비",
    "accent": "왼쪽 패널의 주황 경고 표시",
    "contrast": "왼쪽 경고 표시와 오른쪽 감지 영역의 색 대비"
  },
  "material_and_rendering": "평면 벡터, 무광 표면, 질감 없음",
  "text": [
    {
      "string": "경고등",
      "role": "label",
      "placement": "왼쪽 패널 상단",
      "reading_order": 1,
      "priority": "primary",
      "scale": "패널 폭의 30%",
      "contrast": "연회색 배경 위 검은 글자",
      "clearance": "패널 상단에서 5%"
    },
    {
      "string": "감지 정지장치",
      "role": "label",
      "placement": "오른쪽 패널 상단",
      "reading_order": 2,
      "priority": "primary",
      "scale": "패널 폭의 40%",
      "contrast": "연회색 배경 위 검은 글자",
      "clearance": "패널 상단에서 5%"
    }
  ],
  "must_include": ["좌우 두 패널", "왼쪽의 경고 표시", "오른쪽의 바닥 감지 영역", "동일한 시점"],
  "must_exclude": ["사람", "로고", "사진 같은 질감", "좌우 크기 차이"],
  "inspection_checks": ["두 패널의 시점과 크기가 같은가", "형태 차이가 첫 시선에 읽히는가", "라벨 두 개가 정확한가", "하단이 비어 있는가"],
  "aspect": "16:9",
  "caption_note": "경고등 방식과 감지 정지장치 방식의 형태 차이 (설명 그림)",
  "prompt": "연회색 배경의 평면 벡터 비교 도식. 먼저 눈에 들어와야 하는 것은 좌우 두 패널의 형태 차이이고, 그다음이 각 패널 상단 라벨, 배경은 동일한 회색 면이다. 같은 장비 두 대를 같은 시점과 같은 크기로 좌우 2분할 배치하고 가운데에 얇은 세로 구분선을 두며, 하단 1/5은 빈 여백으로 남긴다. 진회색 장비에 왼쪽은 주황 경고 표시, 오른쪽은 바닥 감지 영역을 강조하고 둘 사이의 색 대비를 분명히 한다. 그림자 없이 균일한 선 굵기의 무광 평면 벡터로 그린다. 왼쪽 패널 상단에 '경고등', 오른쪽 패널 상단에 '감지 정지장치'를 각각 정확히 한 번씩 연회색 배경 위 검은 글자로 선명하고 철자가 맞게 쓴다. 사람, 로고, 사진 같은 질감, 좌우 크기 차이는 넣지 않는다."
}
```

```json
{
  "id": "프롬프트 #7",
  "section_role": "comparison",
  "template": "before-after-schematic",
  "use": "'시공 후 달라지는 것' 섹션. 같은 단면을 좌우로 놓고 시공 전 물길과 시공 후 막힌 물길을 대비한다.",
  "hierarchy": {
    "first": "오른쪽 패널에서 멈춘 물",
    "second": "왼쪽 패널의 통과하는 물 화살표",
    "background": "동일한 콘크리트 단면"
  },
  "subject": "같은 콘크리트 단면 두 개를 좌우로 나란히 배치",
  "composition": "좌우 2분할, 가운데 얇은 세로 구분선, 각 패널 상단에 라벨, 하단 1/5은 빈 여백",
  "style": "clean isometric cutaway, 부드러운 파스텔, 굵기 균일한 선, 그림자 없음",
  "material_and_rendering": "평면 벡터, 무광, 질감 없음",
  "text": [
    {
      "string": "시공 전",
      "role": "label",
      "placement": "왼쪽 패널 상단",
      "reading_order": 1,
      "priority": "primary",
      "scale": "패널 폭의 30%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "패널 상단에서 5%"
    },
    {
      "string": "시공 후",
      "role": "label",
      "placement": "오른쪽 패널 상단",
      "reading_order": 2,
      "priority": "primary",
      "scale": "패널 폭의 30%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "패널 상단에서 5%"
    }
  ],
  "must_include": ["왼쪽의 통과하는 물 화살표", "오른쪽의 채워진 틈", "오른쪽 위에서 멈춘 물"],
  "must_exclude": ["제품명이나 브랜드 표기", "사람", "실제 사진처럼 보이는 질감"],
  "inspection_checks": ["좌우 단면이 같은 구조인가", "오른쪽에서 물이 멈춘 것이 보이는가", "라벨 두 개가 정확한가", "틈이 채워진 것이 보이는가"],
  "aspect": "16:9",
  "caption_note": "시공 전후 물길 차이 (설명 그림)",
  "prompt": "부드러운 파스텔 색의 평면 아이소메트릭 단면 도식. 먼저 눈에 들어와야 하는 것은 오른쪽 패널에서 위에서 멈춘 물이고, 그다음이 왼쪽 패널에서 틈을 통과하는 물 화살표, 배경은 양쪽에 같은 구조로 그린 콘크리트 단면이다. 같은 단면 두 개를 좌우 2분할로 나란히 두고 가운데에 얇은 세로 구분선을 넣으며, 하단 1/5은 빈 여백으로 남긴다. 그림자 없이 굵기가 균일한 무광 평면 벡터로 그린다. 왼쪽 패널 상단에 '시공 전', 오른쪽 패널 상단에 '시공 후'를 각각 정확히 한 번씩 흰 배경 위 검은 글자로 선명하고 철자가 맞게 쓴다. 제품명이나 브랜드 표기, 사람, 실제 사진처럼 보이는 질감은 넣지 않는다."
}
```

### 2.5 process — `process-flow`

```json
{
  "id": "프롬프트 #8",
  "section_role": "process",
  "template": "process-flow",
  "use": "'진행 순서' 섹션. 독자가 실제로 밟는 네 단계를 순서대로 보여 준다.",
  "hierarchy": {
    "first": "단계를 잇는 흐름선",
    "second": "각 단계 상자와 번호",
    "background": "옅은 격자"
  },
  "subject": "네 단계 상자와 화살표. 단계 이름은 초안에 있는 절차만 쓴다",
  "composition": "위에서 아래로 4단계, 상자 폭은 같게, 왼쪽에 번호, 오른쪽에 짧은 설명, 하단 1/6은 빈 여백",
  "style": "flat vector infographic, 굵은 화살표, 둥근 사각형 상자",
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "문의",
      "role": "label",
      "placement": "1단계 상자 왼쪽",
      "reading_order": 2,
      "priority": "primary",
      "scale": "상자 폭의 25%",
      "contrast": "흰 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    },
    {
      "string": "방문",
      "role": "label",
      "placement": "2단계 상자 왼쪽",
      "reading_order": 3,
      "priority": "primary",
      "scale": "상자 폭의 25%",
      "contrast": "흰 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    },
    {
      "string": "탐지",
      "role": "label",
      "placement": "3단계 상자 왼쪽",
      "reading_order": 4,
      "priority": "primary",
      "scale": "상자 폭의 25%",
      "contrast": "흰 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    },
    {
      "string": "보수",
      "role": "label",
      "placement": "4단계 상자 왼쪽",
      "reading_order": 5,
      "priority": "primary",
      "scale": "상자 폭의 25%",
      "contrast": "흰 상자 위 진회색 글자",
      "clearance": "상자 안쪽 여백"
    }
  ],
  "must_include": ["네 단계 상자", "단계를 잇는 화살표 세 개", "단계 번호", "같은 크기의 상자"],
  "must_exclude": ["사람 얼굴", "로고", "사진 같은 질감", "초안에 없는 단계"],
  "inspection_checks": ["단계 순서가 위에서 아래로 읽히는가", "화살표가 세 개인가", "상자 크기가 같은가", "문구 네 개의 철자가 정확한가"],
  "aspect": "4:3",
  "caption_note": "문의부터 보수까지의 진행 순서 (설명 그림)",
  "prompt": "옅은 격자 배경의 평면 벡터 흐름도. 먼저 눈에 들어와야 하는 것은 단계를 잇는 굵은 화살표이고, 그다음이 각 단계 상자와 번호, 배경은 옅은 격자다. 같은 크기의 둥근 사각형 상자 네 개를 위에서 아래로 배치하고 그 사이를 화살표로 잇고, 왼쪽에 번호를, 오른쪽에 짧은 설명을 두며 하단 1/6은 빈 여백으로 남긴다. 질감 없이 균일한 선 굵기로 그린다. 1단계부터 순서대로 '문의', '방문', '탐지', '보수'를 각 상자 왼쪽에 정확히 한 번씩 흰 상자 위 진회색으로 선명하고 철자가 맞게 쓴다. 사람 얼굴, 로고, 사진 같은 질감, 초안에 없는 단계는 넣지 않는다."
}
```

### 2.6 cost — `cost-breakdown`

```json
{
  "id": "프롬프트 #9",
  "section_role": "cost",
  "template": "cost-breakdown",
  "use": "'비용 구조' 섹션. 총액이 무엇으로 이루어지는지 비중으로 나눠 보여 준다.",
  "hierarchy": {
    "first": "구성 항목의 비중 차이",
    "second": "항목 이름",
    "background": "전체를 나타내는 가로 막대"
  },
  "subject": "가로 누적 막대 하나와 구성 항목 구간. 금액은 초안에 출처가 있는 값만 쓴다",
  "composition": "정면, 가로 막대가 캔버스 폭의 80%, 각 구간 위에 항목 이름, 아래에 비중, 하단 1/5은 빈 여백",
  "style": "flat vector infographic, 구간 경계는 얇은 흰 선",
  "color": {
    "dominant": "연회색 전체 막대",
    "support": "진회색 큰 구간",
    "accent": "주황 작은 구간",
    "contrast": "인접 구간 사이의 명도 차"
  },
  "material_and_rendering": "평면 벡터, 질감 없음",
  "text": [
    {
      "string": "탐지비",
      "role": "label",
      "placement": "첫 구간 위",
      "reading_order": 1,
      "priority": "primary",
      "scale": "구간 폭의 60%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "막대에서 3px 이상"
    },
    {
      "string": "보수비",
      "role": "label",
      "placement": "둘째 구간 위",
      "reading_order": 2,
      "priority": "primary",
      "scale": "구간 폭의 60%",
      "contrast": "흰 배경 위 검은 글자",
      "clearance": "막대에서 3px 이상"
    }
  ],
  "must_include": ["가로 누적 막대", "구간을 나누는 흰 경계선", "항목 이름 라벨", "비중 차이"],
  "must_exclude": ["초안에 없는 금액", "통화 기호", "사람", "로고"],
  "inspection_checks": ["비중 차이가 첫 시선에 읽히는가", "구간 경계가 분명한가", "금액이 초안 출처와 일치하는가", "라벨 철자가 정확한가"],
  "aspect": "4:3",
  "caption_note": "총액을 이루는 항목별 비중 (설명 그림)",
  "prompt": "흰 배경의 평면 벡터 인포그래픽. 먼저 눈에 들어와야 하는 것은 구성 항목의 비중 차이이고, 그다음이 항목 이름, 배경은 전체를 나타내는 가로 막대다. 캔버스 폭의 80%를 차지하는 가로 누적 막대를 그리고 그 위에 항목 이름, 아래에 비중을 두며 하단 1/5은 빈 여백으로 남긴다. 연회색을 주로, 진회색을 큰 구간, 주황을 작은 구간에 쓰고 인접 구간 사이에 명도 차를 두며 경계는 얇은 흰 선으로 나눈다. 질감 없는 평면 벡터로 그린다. 왼쪽부터 '탐지비', '보수비'를 각 구간 위에 정확히 한 번씩 흰 배경 위 검은 글자로 선명하고 철자가 맞게 쓴다. 초안에 없는 금액, 통화 기호, 사람, 로고는 넣지 않는다."
}
```

### 2.7 checklist — `checklist-card`

```json
{
  "id": "프롬프트 #10",
  "section_role": "checklist",
  "template": "checklist-card",
  "use": "'확인할 것' 섹션. 독자가 문의 전에 스스로 점검할 항목을 한 장에 모은다.",
  "hierarchy": {
    "first": "체크 표시가 있는 항목 행",
    "second": "항목 문구",
    "background": "카드 테두리"
  },
  "subject": "체크박스 네 개와 항목 문구가 든 카드 한 장. 브랜드 표기 없음",
  "composition": "정면, 카드가 캔버스 85%, 항목은 세로로 같은 간격, 상단에 짧은 제목, 하단 1/8은 빈 여백",
  "style": "flat vector, 둥근 모서리 카드, 얇은 외곽선",
  "material_and_rendering": "평면 벡터, 그림자 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "문의 전 확인",
      "role": "title",
      "placement": "카드 상단 중앙",
      "reading_order": 1,
      "priority": "primary",
      "scale": "카드 폭의 50%",
      "contrast": "흰 카드 위 진회색 글자",
      "clearance": "카드 안쪽 여백 8%"
    },
    {
      "string": "탐지 장비 종류",
      "role": "label",
      "placement": "첫째 항목",
      "reading_order": 3,
      "priority": "secondary",
      "scale": "카드 폭의 40%",
      "contrast": "흰 카드 위 진회색 글자",
      "clearance": "체크박스에서 8px"
    },
    {
      "string": "비용 산정 기준",
      "role": "label",
      "placement": "둘째 항목",
      "reading_order": 4,
      "priority": "secondary",
      "scale": "카드 폭의 40%",
      "contrast": "흰 카드 위 진회색 글자",
      "clearance": "체크박스에서 8px"
    }
  ],
  "must_include": ["체크박스 네 개", "항목 문구", "카드 테두리", "같은 간격의 항목"],
  "must_exclude": ["실제 사진처럼 보이는 질감", "로고", "사람 얼굴"],
  "inspection_checks": ["항목이 위에서 아래로 읽히는가", "체크박스가 네 개인가", "글자가 모바일에서 읽히는가", "제목과 항목의 위계가 분명한가"],
  "aspect": "4:3",
  "caption_note": "문의 전에 확인할 항목 (설명 그림)",
  "prompt": "흰 카드 한 장을 정면에서 본 평면 벡터 일러스트. 먼저 눈에 들어와야 하는 것은 체크 표시가 있는 항목 행이고, 그다음이 항목 문구, 배경은 카드의 얇은 테두리다. 카드가 캔버스 85%를 차지하게 하고 항목을 세로로 같은 간격으로 배치하며, 상단에 짧은 제목을 두고 하단 1/8은 빈 여백으로 남긴다. 그림자 없이 둥근 모서리와 균일한 선 굵기로 그린다. 카드 상단 중앙에 '문의 전 확인'을, 첫째 항목에 '탐지 장비 종류'를, 둘째 항목에 '비용 산정 기준'을 각각 정확히 한 번씩 흰 카드 위 진회색으로 선명하고 철자가 맞게 쓴다. 실제 사진처럼 보이는 질감, 로고, 사람 얼굴은 넣지 않는다."
}
```

### 2.8 caution — `failure-caution`

```json
{
  "id": "프롬프트 #11",
  "section_role": "caution",
  "template": "failure-caution",
  "use": "'안 맞는 경우' 섹션. 실패 조건과 예방 조건을 나란히 두어 독자가 자기 상황을 판단하게 한다.",
  "hierarchy": {
    "first": "왼쪽의 실패 조건",
    "second": "오른쪽의 예방 조건",
    "background": "가운데 구분선"
  },
  "subject": "두 열로 나뉜 조건 목록. 조건 문구는 초안에 있는 내용만 쓴다",
  "composition": "좌우 2분할, 왼쪽 상단에 실패 표제, 오른쪽 상단에 예방 표제, 각 열에 항목 두 개, 하단 1/6은 빈 여백",
  "style": "flat vector infographic, 열 구분은 얇은 세로선",
  "material_and_rendering": "평면 벡터, 질감 없음",
  "text": [
    {
      "string": "안 맞는 경우",
      "role": "title",
      "placement": "왼쪽 열 상단",
      "reading_order": 1,
      "priority": "primary",
      "scale": "열 폭의 45%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "열 상단에서 4%"
    },
    {
      "string": "이렇게 하면 예방",
      "role": "title",
      "placement": "오른쪽 열 상단",
      "reading_order": 2,
      "priority": "primary",
      "scale": "열 폭의 45%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "열 상단에서 4%"
    }
  ],
  "must_include": ["두 열 구조", "가운데 세로 구분선", "각 열의 항목 두 개", "양쪽 표제"],
  "must_exclude": ["공포를 유발하는 표정이나 사고 장면", "로고", "실제 피해 사진처럼 보이는 질감", "사람 얼굴"],
  "inspection_checks": ["좌우 대비가 첫 시선에 읽히는가", "두 열의 항목 수가 같은가", "공포를 유발하는 요소가 없는가", "표제 철자가 정확한가"],
  "aspect": "4:3",
  "caption_note": "안 맞는 조건과 예방 조건의 대비 (설명 그림)",
  "prompt": "흰 배경의 평면 벡터 도식. 먼저 눈에 들어와야 하는 것은 왼쪽의 실패 조건이고, 그다음이 오른쪽의 예방 조건, 배경은 가운데 얇은 구분선이다. 화면을 좌우 2분할하고 각 열에 항목을 두 개씩 같은 간격으로 두며 하단 1/6은 빈 여백으로 남긴다. 질감 없이 균일한 선 굵기로 그린다. 왼쪽 열 상단에 '안 맞는 경우', 오른쪽 열 상단에 '이렇게 하면 예방'을 각각 정확히 한 번씩 흰 배경 위 진회색으로 선명하고 철자가 맞게 쓴다. 공포를 유발하는 표정이나 사고 장면, 로고, 실제 피해 사진처럼 보이는 질감, 사람 얼굴은 넣지 않는다."
}
```

### 2.9 data — `data-chart`

```json
{
  "id": "프롬프트 #12",
  "section_role": "data",
  "template": "data-chart",
  "use": "'수치로 보는 변화' 섹션. 초안에 출처가 있는 값만 막대로 옮겨 추세를 보여 준다.",
  "hierarchy": {
    "first": "막대 높이 차이",
    "second": "축과 값 라벨",
    "background": "옅은 가로 기준선"
  },
  "subject": "막대 네 개와 두 축. 값은 초안에 출처가 있는 수치만 쓴다",
  "composition": "정면, 세로 막대 네 개가 같은 폭, 왼쪽에 눈금, 아래에 라벨, 상단 1/8은 제목용 빈 여백",
  "style": "flat vector chart, 축은 얇은 선, 막대는 채움",
  "color": {
    "dominant": "연회색 막대",
    "support": "진회색 축과 눈금",
    "accent": "마지막 막대의 주황",
    "contrast": "강조 막대와 나머지 막대의 색 대비"
  },
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "탐지 건수",
      "role": "value",
      "placement": "마지막 막대 위",
      "reading_order": 2,
      "priority": "primary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "막대에서 4px"
    },
    {
      "string": "2026년 8월",
      "role": "axis",
      "placement": "가로축 마지막 눈금",
      "reading_order": 3,
      "priority": "secondary",
      "scale": "캔버스 폭의 14%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "축에서 4px"
    }
  ],
  "must_include": ["막대 네 개", "가로축 라벨", "세로축 눈금", "값 라벨"],
  "must_exclude": ["초안에 없는 수치", "추세선", "로고", "3D 효과"],
  "inspection_checks": ["막대 높이가 값과 일치하는가", "출처 없는 숫자가 없는가", "축 라벨이 읽히는가", "강조 막대가 구분되는가"],
  "aspect": "4:3",
  "caption_note": "기간별 탐지 건수 추이 (요약 그림)",
  "prompt": "흰 배경의 평면 벡터 막대 차트. 먼저 눈에 들어와야 하는 것은 막대 높이 차이이고, 그다음이 축과 값 라벨, 배경은 옅은 가로 기준선이다. 같은 폭의 세로 막대 네 개를 정면으로 배치하고 왼쪽에 눈금, 아래에 라벨을 두며 상단 1/8은 제목용 빈 여백으로 남긴다. 연회색을 기본 막대로, 진회색을 축과 눈금으로, 주황을 마지막 막대 강조로 쓰고 강조 막대와 나머지 사이에 색 대비를 둔다. 질감 없이 균일한 선 굵기로 그린다. 마지막 막대 위에 '탐지 건수'를, 가로축 마지막 눈금에 '2026년 8월'을 각각 정확히 한 번씩 흰 배경 위 진회색으로 선명하고 철자가 맞게 쓴다. 초안에 없는 수치, 추세선, 로고, 3D 효과는 넣지 않는다."
}
```

### 2.10 timeline — `timeline`

```json
{
  "id": "프롬프트 #13",
  "section_role": "timeline",
  "template": "timeline",
  "use": "'언제 무엇을 하나' 섹션. 상담부터 완료까지의 시간 순서를 한 줄에 놓는다.",
  "hierarchy": {
    "first": "가로 시간축 위의 점",
    "second": "각 점의 시점 라벨",
    "background": "얇은 축선"
  },
  "subject": "가로 축과 시점 표시 네 개. 시점 문구는 초안에 있는 일정만 쓴다",
  "composition": "가로 한 줄, 축은 캔버스 폭의 85%, 점은 같은 간격, 라벨은 위아래로 번갈아, 하단 1/5은 빈 여백",
  "style": "flat vector infographic, 축은 얇은 선, 점은 채운 원",
  "material_and_rendering": "평면 벡터, 질감 없음",
  "text": [
    {
      "string": "상담",
      "role": "label",
      "placement": "첫째 점 위",
      "reading_order": 1,
      "priority": "primary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "점에서 5px"
    },
    {
      "string": "탐지",
      "role": "label",
      "placement": "둘째 점 아래",
      "reading_order": 2,
      "priority": "primary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "점에서 5px"
    }
  ],
  "must_include": ["가로 축선", "시점 표시 네 개", "번갈아 놓인 라벨", "같은 간격"],
  "must_exclude": ["초안에 없는 날짜", "시계 아이콘", "로고", "사진 같은 질감"],
  "inspection_checks": ["시간 순서가 왼쪽에서 오른쪽으로 읽히는가", "점이 네 개인가", "간격이 같은가", "없는 날짜가 들어가지 않았는가"],
  "aspect": "16:9",
  "caption_note": "상담부터 완료까지의 진행 시점 (설명 그림)",
  "prompt": "흰 배경의 평면 벡터 타임라인. 먼저 눈에 들어와야 하는 것은 가로 시간축 위의 점이고, 그다음이 각 점의 시점 라벨, 배경은 얇은 축선이다. 캔버스 폭의 85%를 차지하는 가로 한 줄 축을 그리고 그 위에 같은 간격으로 점 네 개를 두고, 라벨을 위아래로 번갈아 놓으며 하단 1/5은 빈 여백으로 남긴다. 질감 없이 균일한 선 굵기와 채운 원으로 그린다. 첫째 점 위에 '상담'을, 둘째 점 아래에 '탐지'를 각각 정확히 한 번씩 흰 배경 위 진회색으로 선명하고 철자가 맞게 쓴다. 초안에 없는 날짜, 시계 아이콘, 로고, 사진 같은 질감은 넣지 않는다."
}
```

### 2.11 route — `route-schematic`

```json
{
  "id": "프롬프트 #14",
  "section_role": "route",
  "template": "route-schematic",
  "use": "'진행 동선' 섹션. 신청에서 완료까지의 논리적 단계 이동을 도식으로 보여 준다. 실제 지도가 아니다.",
  "hierarchy": {
    "first": "출발에서 도착으로 이어지는 경로",
    "second": "각 지점 이름",
    "background": "옅은 영역 구분"
  },
  "subject": "세 지점을 잇는 논리 동선 도식. 실제 도로나 건물 형태는 그리지 않는다",
  "composition": "왼쪽 아래에서 오른쪽 위로 이어지는 대각 경로, 지점은 같은 크기, 상단 1/6은 빈 여백",
  "style": "flat vector schematic, 경로는 굵은 선, 지점은 원",
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "신청",
      "role": "label",
      "placement": "첫 지점 옆",
      "reading_order": 1,
      "priority": "primary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "지점에서 6px"
    },
    {
      "string": "접수",
      "role": "label",
      "placement": "둘째 지점 옆",
      "reading_order": 2,
      "priority": "primary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "지점에서 6px"
    },
    {
      "string": "방문",
      "role": "label",
      "placement": "셋째 지점 옆",
      "reading_order": 3,
      "priority": "primary",
      "scale": "캔버스 폭의 12%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "지점에서 6px"
    }
  ],
  "must_include": ["세 지점", "경로를 잇는 굵은 선", "지점 이름 라벨", "진행 방향 표시"],
  "must_exclude": ["실제 도로나 건물 형태", "지도 타일", "좌표나 거리 수치", "로고"],
  "inspection_checks": ["논리 동선으로 읽히는가", "실제 지도처럼 보이지 않는가", "지점 세 개가 같은 크기인가", "라벨 철자가 정확한가"],
  "aspect": "16:9",
  "caption_note": "신청에서 방문까지의 논리 동선 (개념도)",
  "prompt": "흰 배경의 평면 벡터 개념도. 먼저 눈에 들어와야 하는 것은 출발에서 도착으로 이어지는 굵은 경로이고, 그다음이 각 지점 이름, 배경은 옅은 영역 구분이다. 왼쪽 아래에서 오른쪽 위로 이어지는 대각 경로를 그리고 같은 크기의 원 세 개를 지점으로 두며, 상단 1/6은 빈 여백으로 남긴다. 질감 없이 균일한 선 굵기로 그린다. 순서대로 첫 지점 옆에 '신청', 둘째 지점 옆에 '접수', 셋째 지점 옆에 '방문'을 각각 정확히 한 번씩 흰 배경 위 진회색으로 선명하고 철자가 맞게 쓴다. 실제 도로나 건물 형태, 지도 타일, 좌표나 거리 수치, 로고는 넣지 않는다."
}
```

### 2.12 scale — `scale-dimension`

```json
{
  "id": "프롬프트 #15",
  "section_role": "scale",
  "template": "scale-dimension",
  "use": "'규모 비교' 섹션. 두 대상의 크기 차이를 같은 기준선 위에 놓아 보여 준다.",
  "hierarchy": {
    "first": "두 대상의 크기 차이",
    "second": "치수 표시선",
    "background": "같은 가로 기준선"
  },
  "subject": "같은 기준선 위에 놓인 작은 대상과 큰 대상. 치수는 초안에 출처가 있는 값만 쓴다",
  "composition": "정면, 두 대상을 좌우로 배치하고 같은 기준선에 맞춤, 치수선은 대상 위, 하단 1/6은 빈 여백",
  "style": "flat vector diagram, 치수선은 얇은 화살표",
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 선 굵기",
  "text": [
    {
      "string": "기준",
      "role": "label",
      "placement": "기준선 왼쪽 끝",
      "reading_order": 1,
      "priority": "primary",
      "scale": "캔버스 폭의 10%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "기준선에서 5px"
    },
    {
      "string": "비교 대상",
      "role": "label",
      "placement": "오른쪽 대상 위",
      "reading_order": 2,
      "priority": "primary",
      "scale": "캔버스 폭의 16%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "대상에서 5px"
    }
  ],
  "must_include": ["공통 기준선", "두 대상의 크기 차이", "치수 표시선", "대상 라벨"],
  "must_exclude": ["출처 없는 치수", "사람", "로고", "사진 같은 질감"],
  "inspection_checks": ["두 대상이 같은 기준선에 놓였는가", "크기 차이가 과장되지 않았는가", "치수가 출처와 일치하는가", "라벨 철자가 정확한가"],
  "aspect": "4:3",
  "caption_note": "기준 대비 대상의 크기 차이 (설명 그림)",
  "prompt": "흰 배경의 평면 벡터 치수 도식. 먼저 눈에 들어와야 하는 것은 두 대상의 크기 차이이고, 그다음이 치수 표시선, 배경은 같은 가로 기준선이다. 정면에서 두 대상을 좌우로 배치하고 같은 기준선에 맞추며, 치수선을 대상 위에 두고 하단 1/6은 빈 여백으로 남긴다. 질감 없이 균일한 선 굵기와 얇은 화살표로 그린다. 기준선 왼쪽 끝에 '기준'을, 오른쪽 대상 위에 '비교 대상'을 각각 정확히 한 번씩 흰 배경 위 진회색으로 선명하고 철자가 맞게 쓴다. 출처 없는 치수, 사람, 로고, 사진 같은 질감은 넣지 않는다."
}
```

### 2.13 closing — `closing-next-step`

```json
{
  "id": "프롬프트 #16",
  "section_role": "closing",
  "template": "closing-next-step",
  "use": "마무리. 독자가 내릴 결정 하나와 그다음 행동 하나를 여백 중심으로 정리한다. 시각적 가치가 없으면 이미지를 만들지 않는다.",
  "hierarchy": {
    "first": "다음 행동 한 줄",
    "second": "결정 조건 한 줄",
    "background": "넓은 여백"
  },
  "subject": "문구 두 줄과 넓은 여백. 브랜드 표기나 로고는 넣지 않는다",
  "composition": "정면, 문구는 캔버스 중앙 60% 폭, 위아래 여백을 크게, 장식 요소 없음",
  "style": "flat vector, 타이포그래피 중심, 장식 없음",
  "color": {
    "dominant": "흰 배경",
    "support": "연회색 구분선 하나",
    "accent": "다음 행동 문구의 진남색",
    "contrast": "두 문구 사이의 크기와 굵기 차"
  },
  "material_and_rendering": "평면 벡터, 질감 없음",
  "text": [
    {
      "string": "지금 확인할 것",
      "role": "title",
      "placement": "상단 문구",
      "reading_order": 1,
      "priority": "primary",
      "scale": "캔버스 폭의 45%",
      "contrast": "흰 배경 위 진남색 글자",
      "clearance": "좌우 20% 여백"
    },
    {
      "string": "비용 기준을 먼저 물어보세요",
      "role": "callout",
      "placement": "하단 문구",
      "reading_order": 2,
      "priority": "secondary",
      "scale": "캔버스 폭의 35%",
      "contrast": "흰 배경 위 진회색 글자",
      "clearance": "좌우 20% 여백"
    }
  ],
  "must_include": ["두 줄 문구", "넓은 여백", "얇은 구분선 하나"],
  "must_exclude": ["로고", "연락처", "과장된 강조 문구", "장식 아이콘"],
  "inspection_checks": ["두 문구의 위계가 분명한가", "여백이 충분한가", "장식이 없는가", "문구 철자가 정확한가"],
  "aspect": "1:1",
  "caption_note": "마무리에서 안내할 다음 행동 (설명 그림)",
  "prompt": "흰 배경의 타이포그래피 중심 평면 벡터 이미지. 먼저 눈에 들어와야 하는 것은 다음 행동 한 줄이고, 그다음이 결정 조건 한 줄, 배경은 넓은 여백이다. 문구를 캔버스 중앙 60% 폭에 놓고 위아래 여백을 크게 두며 장식 요소를 넣지 않는다. 질감 없는 평면 벡터로 그린다. 상단 문구에 '지금 확인할 것'을 진남색으로, 하단 문구에 '비용 기준을 먼저 물어보세요'를 진회색으로 각각 정확히 한 번씩 좌우 20% 여백을 두고 선명하고 철자가 맞게 쓴다. 로고, 연락처, 과장된 강조 문구, 장식 아이콘은 넣지 않는다."
}
```

### 2.14 concept — `concept-mood`

```json
{
  "id": "프롬프트 #17",
  "section_role": "concept",
  "template": "concept-mood",
  "use": "'비용 구조' 섹션 도입. 작은 보수를 미루면 큰 공사가 되는 관계를 은유 없이 크기 대비로 보여 준다.",
  "hierarchy": {
    "first": "작은 균열과 큰 균열의 크기 차이",
    "second": "동전 더미 높이 차이",
    "background": "회색 콘크리트 벽면"
  },
  "subject": "왼쪽에 작은 균열 하나와 낮은 동전 더미, 오른쪽에 넓게 벌어진 균열과 높은 동전 더미",
  "composition": "좌우 대칭 2분할, 가운데 오른쪽 방향 화살표, 위아래 여백 넉넉히",
  "style": "flat vector, 2색 구성, 외곽선 없음",
  "color": {
    "dominant": "회색 벽면",
    "support": "진회색 균열",
    "accent": "주황 화살표",
    "contrast": "균열과 벽면의 명도 차"
  },
  "material_and_rendering": "평면 벡터, 질감 없음, 균일한 채도",
  "must_include": ["작은 균열과 큰 균열의 크기 차이", "동전 더미 높이 차이", "오른쪽 방향 화살표", "좌우 대칭 구도"],
  "must_exclude": ["숫자", "통화 기호", "사람", "로고"],
  "inspection_checks": ["크기 대비가 첫 시선에 읽히는가", "좌우 구도가 대칭인가", "숫자나 통화 기호가 없는가", "화살표 방향이 오른쪽인가"],
  "aspect": "1:1",
  "caption_note": "미룰수록 커지는 보수 범위 (설명 그림)",
  "prompt": "회색 톤의 평면 벡터 개념 그림. 먼저 눈에 들어와야 하는 것은 작은 균열과 큰 균열의 크기 차이이고, 그다음이 동전 더미 높이 차이, 배경은 회색 콘크리트 벽면이다. 좌우 대칭 2분할로 나누고 가운데에 오른쪽 방향 주황 화살표를 두며 위아래 여백을 넉넉히 남긴다. 외곽선 없이 두 색 중심으로, 질감 없이 균일한 채도로 그린다. 숫자, 통화 기호, 사람, 로고는 넣지 않는다."
}
```

## 3. Checks before delivery

- Every `이미지 생성` marker has exactly one JSON object with a matching `id`; no object without a marker.
- Every object carries all 14 always-fields; every conditional field is present only when it carries meaning, and an inapplicable field is absent rather than empty.
- `section_role` is one of the 14 roles; `template` is one of that role's template IDs.
- Each `text[].string` appears exactly once inside `text[]`, and `prompt` carries every one of them byte-identical.
- `series_invariants`, when used, repeats identically in every object of that series.
- No `text.string` and no `prompt` sentence carries a fact the post marks `[확인 필요]`.
- No object names a brand, product, person, or real place unless the user supplied it as a brand fact and it is not a logo.
- No object carries a provider, model, quality, or resolution flag; the brief stays portable.
- `data-chart`, `cost-breakdown`, and `scale-dimension` render only numbers the sourced draft already carries.
- `route-schematic` never depicts real geography; real places stay `[이미지: …]` markers.
- Cover and cutaway objects carry an `aspect`; body images default to `4:3`.
- A generated image that could be mistaken for a photograph is labelled as an illustration in its caption.
