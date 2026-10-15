# 출력 계약

> 영어 정본: [`output-contract.md`](output-contract.md)

컴포저를 만들거나 호출하기 전에 읽습니다. 이 파일은 입력 스키마, 출력 레이아웃, `window.cardStudio` API, 실패 동작을 다룹니다.

## 목차

- [입력 문서](#1-입력-문서)
- [API](#2-api)
- [출력 레이아웃](#3-출력-레이아웃)
- [실패 동작](#4-실패-동작)

## 1. 입력 문서

컴포저는 JSON 객체 하나를 받습니다. 아래 키는 선택으로 표시된 것을 빼고 모두 필수입니다.

| 키 | 형 | 규칙 |
|---|---|---|
| `brand` | 문자열 | 비어 있지 않아야 합니다. 왼쪽 위 라벨에 카드 번호와 함께 렌더링됩니다. |
| `width` | 숫자 | `1080`이어야 합니다. |
| `height` | 숫자 | `1080`, `1350`, `1440` 중 하나입니다. 기본 `1350`(4:5)입니다. |
| `caption` | 문자열 | 게시글 전체의 비어 있지 않은 한국어 캡션입니다. |
| `sources` | 문자열 배열 | 출처 문자열이며 각각 비어 있지 않아야 합니다. `sources.md`로 렌더링됩니다. |
| `slides` | 객체 배열 | 게시 순서대로 2~20장입니다. |
| `logo` | 문자열 | 선택. `data:image/(png|jpeg|webp);base64,…` URI이며 그대로 배치합니다. |
| `fontData` | 문자열 | 선택. `data:font/(woff2|woff|ttf|otf);base64,…` URI입니다. |

`slides[]`의 각 항목:

| 키 | 형 | 규칙 |
|---|---|---|
| `title` | 문자열 | 비어 있지 않아야 합니다. `layout`에 따라 배치합니다. |
| `body` | 문자열 | 비어 있지 않아야 합니다. 제목과 같은 배치를 사용합니다. `\n`은 줄바꿈입니다. |
| `photo` | 문자열 | `data:image/(png|jpeg|webp);base64,…` URI입니다. 카드 전체를 채우도록 커버 크롭하고 배경만 흐리게 합니다. |
| `photoSource` | 문자열 | 비어 있지 않아야 합니다. 출처 문자열입니다. |
| `generated` | 불리언 | 생성 사진이면 `true`입니다. |
| `alt` | 문자열 | 비어 있지 않아야 합니다. 카드의 한국어 대체 텍스트입니다. |
| `layout` | 문자열 | `bottom-left`, `bottom-right`, `top-left`, `top-right`, `center` 중 하나입니다. 첫 카드는 `bottom-left`이며 본문은 명시적으로 선택합니다. |
| `layoutReason` | 문자열 | 비어 있지 않아야 합니다. 정보 역할과 가리지 않을 이미지 영역을 설명합니다. |
| `scene` | 문자열 | 비어 있지 않아야 합니다. 이 카드의 요점을 뒷받침하는 이미지 장면을 설명합니다. |
| `visualType` | 문자열 | `photo`, `illustration`, `diagram`, `screenshot` 중 하나입니다. |
| `reuseReason` | 문자열 | 앞 카드와 `photo` URI가 완전히 같으면 필수입니다. 이어지는 장면이나 비교 등 재사용 이유를 설명하며 장수를 채우려고 반복하지 않습니다. |

```json
{
  "brand": "브랜드명",
  "width": 1080,
  "height": 1350,
  "caption": "게시글 전체의 한국어 캡션입니다. 카드 순서를 따라 한 번만 씁니다.",
  "sources": ["https://example.com/source | 2026-10-15"],
  "slides": [
    {
      "title": "첫 카드 훅 제목",
      "body": "첫 카드 내용입니다.\n줄바꿈은 \\n으로 넣습니다.",
      "photo": "data:image/png;base64,…",
      "photoSource": "사진 출처와 사용 허가",
      "generated": false,
      "alt": "첫 카드에 보이는 사진과 내용 설명",
      "layout": "bottom-left",
      "layoutReason": "오른쪽 인물을 가리지 않고 아래 여백에 질문 배치",
      "scene": "질문을 떠올리는 인물의 첫 장면",
      "visualType": "photo"
    },
    {
      "title": "둘째 카드 제목",
      "body": "둘째 카드 내용입니다.",
      "photo": "data:image/jpeg;base64,…",
      "photoSource": "생성 이미지 (일러스트)",
      "generated": true,
      "alt": "둘째 카드에 보이는 사진과 내용 설명",
      "layout": "top-left",
      "layoutReason": "아래쪽 설명 그림을 비워 두고 위에 답 배치",
      "scene": "첫 질문의 원리를 보여주는 새 설명 그림",
      "visualType": "illustration"
    }
  ]
}
```

위 예시는 2장짜리 스키마 설명이며 실행 가능한 이미지 데이터가 아닙니다. 검증 전에 각 `…`를 실제 이미지의 base64 바이트로 바꿉니다. 한 장짜리 문서는 거부됩니다. JSON에서 `\n`은 줄바꿈이며 `\\n`은 역슬래시와 문자 n 자체입니다.

## 2. API

`window.cardStudio`는 동결되어 있고 다섯 호출을 노출합니다. 컴포저는 `render`에서 검증하고 오류가 남아 있으면 내보내기를 거부합니다.

| 호출 | 반환 | 비고 |
|---|---|---|
| `window.cardStudio.validate(doc)` | 문서 또는 예외 발생 | 동기 스키마 점검입니다. |
| `await window.cardStudio.render(doc)` | `{ count, width, height }` | 글꼴과 사진을 불러오고 갤러리를 그리고 사이드카를 만듭니다. 실패하면 거부합니다. |
| `window.cardStudio.exportCards()` | `[{ name, dataUrl, width, height }]` | 카드마다 한 항목이며 `name`은 `01.png` 형식입니다. 렌더링된 것이 없거나 렌더링이 진행 중이면 실패합니다. |
| `window.cardStudio.exportSidecars()` | `{ "caption.txt", "alt-text.json", "sources.md", "manifest.json" }` | 네 값 모두 문자열입니다. |
| `window.cardStudio.exportHTML()` | 문자열 | 문서가 내장되고 이미지가 인라인된 자체 완결 HTML 문서입니다. |

사람이 쓰는 경로도 같습니다. "카드 만들기" 버튼이 렌더링하고, 카드별 링크와 사이드카 링크가 파일을 내려받으며, "편집 가능한 HTML 저장"이 `index.html`을 씁니다. 에이전트는 클릭 없이 `render`를 호출한 뒤 `exportCards`로 `dataUrl`을 읽을 수 있습니다.

## 3. 출력 레이아웃

`.hyper/instagram-card-maker/<slug>/`에 전달합니다.

```text
index.html        # exportHTML() 결과: 문서 내장, 이미지 인라인
cards/01.png …    # exportCards() dataUrl을 디스크에 쓴 것, 카드마다 순서대로
caption.txt       # sidecars["caption.txt"]: 게시글 전체의 단일 캡션
alt-text.json     # sidecars["alt-text.json"]
sources.md        # sidecars["sources.md"]
manifest.json     # sidecars["manifest.json"]
```

`manifest.json`은 `width`, `height`, `count`, `files`(`cards/NN.png` 이름), `font`(`embedded` 또는 `system-fallback; Korean glyph inspection required`), `generated`(카드마다 불리언 하나), `photos`(카드마다 `file`, `photoSource`, `generated`, `layout`, `layoutReason`, `scene`, `visualType`과 입력한 경우 `reuseReason`을 담은 객체)를 담습니다.

## 4. 실패 동작

`validate`와 `render`는 한국어 메시지를 던지고, `render`는 `#status[data-error="true"]`를 설정합니다. 감시하는 실패는 다음과 같습니다.

- 객체가 아닌 문서, 또는 `brand`, `caption`, `title`, `body`, `alt`, `photoSource` 누락
- `1080`이 아닌 `width`, 또는 `{1080, 1350, 1440}` 밖의 `height`
- 비었거나 한 장이거나 20장을 넘는 `slides` 배열
- `photo`, `logo`, `fontData`가 각 형식의 data URI가 아닌 경우
- 불러올 수 없거나 10초 뒤 시간 초과이거나 크기가 0인 이미지
- 카드를 넘치는 글자(제목 3줄 초과, 본문 5줄 초과, 텍스트 블록이 카드 높이의 69% 초과). 컴포저는 축소나 자르기 대신 실패합니다.
- 불러오기에 실패한 `fontData` 글꼴
- 알 수 없는 `layout`이나 `visualType`, `bottom-left`가 아닌 커버 배치, 장면·배치 사유 누락, `reuseReason` 없는 동일 사진 재사용

렌더러는 이미지 URI의 완전 일치를 비교하며 눈에 보이는 유사도는 검사하지 않습니다. 다른 방식으로 인코딩한 같은 사진은 사람이 다시 확인해야 합니다. 설명이 있는지는 검사하지만 진실성과 품질까지 판단하지 않습니다.

렌더링 뒤 JSON을 편집하면 이전 출력이 무효가 됩니다. 갤러리와 사이드카가 비워지고 다음 렌더링이 성공할 때까지 `exportCards`가 실패합니다.

## Sources

> 외부 출처 없음. 내용 확인 2026-10-15.

이 파일은 이 패키지 자체의 컴포저 자산을 문서화합니다.
