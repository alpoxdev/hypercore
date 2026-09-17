# Image Prompt Templates (JSON)

> Korean version: [`image-prompt-templates.ko.md`](image-prompt-templates.ko.md)

Read this when the draft contains any `[이미지 생성: … | 프롬프트 #n]` marker ([`../rules/image-slots.md`](../rules/image-slots.md) §3-§4). Each generated image gets one JSON object built from the schema below, delivered as a fenced `json` block the user pastes into an image tool. The object describes the picture only; it carries no provider, model, size flag, or report prose.

## 1. Schema

| Key | Required | Content |
|---|---|---|
| `id` | yes | `"프롬프트 #n"`, matching the marker |
| `use` | yes | Where it sits in the post and what it must make clear, one sentence |
| `subject` | yes | The principal thing with its distinguishing attributes; no brand names, no real people |
| `scene` | yes | Action or state, environment, time, weather when visible |
| `composition` | yes | Framing, viewpoint, scale, order of elements, deliberately empty space (for text or caption overlay) |
| `style` | yes | Medium and finish: `flat vector infographic`, `clean isometric cutaway`, `documentary photo look`, `soft watercolor`…; palette family; line weight |
| `lighting` | photo-like only | Direction, contrast, shadows, materials |
| `text` | when labels are rendered | Array of `{ "string": exact text, "role": title/label/callout, "placement": … }`; each string once, Korean exactly as it must appear; `"legible, correctly spelled"` |
| `must_include` | yes | 2-5 concrete visible elements the section's claim depends on |
| `must_exclude` | yes | Phrased as positive conditions where possible (`unbranded surfaces`, `no readable logos`, `no human faces`) plus anything the post must not imply |
| `aspect` | yes | `"4:3"`, `"16:9"`, `"1:1"`, `"3:4"` — 4:3 or 1:1 body and 16:9 cover are adjustable composition defaults, not platform requirements |
| `caption_note` | yes | Copy of the marker caption, so the image and caption stay consistent |

Rules: one object per image; no placeholders left; `text.string` values are the exact rendered strings; describe exclusions concretely; never borrow a living artist, person, or trademark as a style shortcut; a generated image is labeled as illustration in its caption when it could be mistaken for a photo.

## 2. Templates by section role

### 2.1 Mechanism cutaway (원리 단면도)

```json
{
  "id": "프롬프트 #2",
  "use": "'왜 생기나' 섹션 첫 이미지. 물이 화단 흙 → 방수층 틈 → 콘크리트 → 주차장 천장으로 내려오는 경로를 한눈에 보여준다.",
  "subject": "지하주차장 위 화단의 수직 단면. 위에서부터 흙층, 비노출 방수층, 콘크리트 슬래브, 주차장 천장 순서",
  "scene": "비가 온 뒤 흙이 젖어 있고 방수층 틈으로 물이 스며 아래 천장에 물방울과 흰 석회 자국이 맺힌 상태",
  "composition": "정면 단면, 4개 층이 같은 두께로 쌓인 수평 밴드, 왼쪽 여백에 층 이름 라벨, 물길은 파란 점선 화살표 하나",
  "style": "flat vector infographic, 얇은 검은 외곽선, 흙은 갈색·방수층은 진회색·콘크리트는 연회색·물은 하늘색, 흰 배경",
  "text": [
    { "string": "화단", "role": "label", "placement": "맨 위 층 왼쪽" },
    { "string": "비노출 방수층", "role": "label", "placement": "두 번째 층 왼쪽" },
    { "string": "콘크리트층", "role": "label", "placement": "세 번째 층 왼쪽" },
    { "string": "지하주차장 누수의 원인", "role": "title", "placement": "상단 중앙, 한 줄" }
  ],
  "must_include": ["방수층의 갈라진 틈 하나", "틈을 통과하는 물 화살표", "천장 아래 물방울과 흰 석회 자국", "각 층 라벨"],
  "must_exclude": ["사람", "회사 로고", "읽을 수 있는 다른 글자", "사진 같은 질감"],
  "aspect": "4:3",
  "caption_note": "물은 화단 흙에서 방수층 틈을 지나 천장까지 내려온다 (설명 그림)"
}
```

### 2.2 Before / after schematic (전후 도식)

```json
{
  "id": "프롬프트 #4",
  "use": "'시공 후 달라지는 것' 섹션. 같은 단면을 좌우로 놓고 시공 전 물길과 시공 후 막힌 물길을 대비한다.",
  "subject": "같은 콘크리트 단면 두 개를 좌우로 나란히 배치",
  "scene": "왼쪽은 틈으로 물이 통과하는 상태, 오른쪽은 틈이 주입재로 채워져 물이 위에서 멈춘 상태",
  "composition": "좌우 2분할, 가운데 얇은 세로 구분선, 각 패널 상단에 라벨, 하단 1/5는 빈 여백",
  "style": "clean isometric cutaway, 부드러운 파스텔, 굵기 균일한 선, 그림자 없음",
  "text": [
    { "string": "시공 전", "role": "label", "placement": "왼쪽 패널 상단" },
    { "string": "시공 후", "role": "label", "placement": "오른쪽 패널 상단" }
  ],
  "must_include": ["왼쪽의 통과하는 물 화살표", "오른쪽의 채워진 틈", "오른쪽 위에서 멈춘 물"],
  "must_exclude": ["제품명이나 브랜드 표기", "사람", "실제 사진처럼 보이는 질감"],
  "aspect": "16:9",
  "caption_note": "시공 전후 물길 차이 (설명 그림)"
}
```

### 2.3 Comparison table as image (비교표)

```json
{
  "id": "프롬프트 #6",
  "use": "'방법별 비교' 섹션. 표를 이미지로 만들어 모바일에서 한 화면에 읽히게 한다.",
  "subject": "3열 2행 비교표",
  "scene": "정적 표, 배경 없음",
  "composition": "표가 캔버스 90%를 채우고 헤더 행은 진한 배경, 첫 열은 항목명, 셀 내부 글자는 큰 크기",
  "style": "flat vector, 흰 배경, 헤더 진남색·본문 검정, 얇은 연회색 격자",
  "text": [
    { "string": "구분", "role": "label", "placement": "헤더 1열" },
    { "string": "경고등", "role": "label", "placement": "헤더 2열" },
    { "string": "감지 정지장치", "role": "label", "placement": "헤더 3열" },
    { "string": "작동 방식", "role": "label", "placement": "1행 1열" },
    { "string": "운전자 주의에 의존", "role": "label", "placement": "1행 2열" },
    { "string": "장비를 직접 정지", "role": "label", "placement": "1행 3열" }
  ],
  "must_include": ["모든 셀에 글자", "헤더 행 강조"],
  "must_exclude": ["아이콘", "장식 이미지", "로고"],
  "aspect": "4:3",
  "caption_note": "경고등과 감지 정지장치의 차이 (요약표)"
}
```

Fill every cell string from the draft's actual table; never leave example values.

### 2.4 Illustrated cover (커버 일러스트, only when no real cover photo)

```json
{
  "id": "프롬프트 #1",
  "use": "커버. 주제를 한 장면으로 보여주되 실제 현장 사진으로 오해되지 않게 일러스트 느낌을 유지한다.",
  "subject": "지게차 한 대와 그 앞을 지나는 보행자 실루엣, 지게차 앞쪽 바닥에 반원형 감지 영역",
  "scene": "물류창고 통로, 낮, 선반이 양옆에 늘어선 배경",
  "composition": "약간 높은 시점의 3/4 뷰, 지게차는 왼쪽 1/3, 보행자는 오른쪽 1/3, 상단 1/4는 제목을 얹을 빈 공간",
  "style": "soft flat illustration, 제한된 4색 팔레트(주황·진회색·연청·흰색), 얼굴 없는 실루엣",
  "lighting": "부드러운 확산광, 긴 그림자 없음",
  "must_include": ["바닥의 반원형 감지 영역", "보행자 실루엣", "선반 배경"],
  "must_exclude": ["얼굴", "브랜드 로고", "읽을 수 있는 글자", "사진 질감"],
  "aspect": "16:9",
  "caption_note": "보행자 감지 정지장치 개념 (일러스트)"
}
```

### 2.5 Concept / mood (추상 섹션)

```json
{
  "id": "프롬프트 #5",
  "use": "'비용 구조' 섹션 도입. 작은 보수를 미루면 큰 공사가 되는 관계를 은유 없이 크기 대비로 보여준다.",
  "subject": "왼쪽에 작은 균열 하나와 작은 동전 더미, 오른쪽에 넓게 벌어진 균열과 큰 동전 더미",
  "scene": "회색 콘크리트 벽면, 정면",
  "composition": "좌우 대칭 2분할, 가운데 오른쪽 방향 화살표, 위아래 여백 넉넉히",
  "style": "flat vector, 2색(회색·주황), 외곽선 없음",
  "must_include": ["작은 균열과 큰 균열의 크기 차이", "동전 더미 크기 차이", "방향 화살표"],
  "must_exclude": ["숫자", "통화 기호", "사람"],
  "aspect": "1:1",
  "caption_note": "미룰수록 커지는 보수 범위 (설명 그림)"
}
```

## 3. Checks before delivery

- Every `이미지 생성` marker has exactly one JSON block with a matching `id`; no JSON block without a marker.
- No `text.string` contains a fact the post marks `[확인 필요]`.
- No object names a brand, product, person, or real place unless the user supplied it as a brand fact and it is not a logo.
- Cover and cutaway objects have an `aspect`; body images default to `4:3`.
