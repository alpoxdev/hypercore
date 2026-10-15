# Output Contract

> Korean version: [`output-contract.ko.md`](output-contract.ko.md)

Read before building or calling the composer. This file owns the input schema, the output layout, the `window.cardStudio` API, and the failure behavior.

## Contents

- [Input document](#1-input-document)
- [API](#2-api)
- [Output layout](#3-output-layout)
- [Failure behavior](#4-failure-behavior)

## 1. Input document

The composer takes one JSON object. Every key below is required unless marked optional.

| Key | Type | Rule |
|---|---|---|
| `brand` | string | Non-empty. Rendered in the top-left label with the card index. |
| `width` | number | Must be `1080`. |
| `height` | number | One of `1080`, `1350`, `1440`. Default `1350` (4:5). |
| `caption` | string | Non-empty Korean caption for the whole post. |
| `sources` | string[] | Source strings; each non-empty. Rendered into `sources.md`. |
| `slides` | object[] | Between 2 and 20 cards, in posting order. |
| `logo` | string | Optional. A `data:image/(png|jpeg|webp);base64,…` URI, placed as-is. |
| `fontData` | string | Optional. A `data:font/(woff2|woff|ttf|otf);base64,…` URI. |

Each `slides[]` entry:

| Key | Type | Rule |
|---|---|---|
| `title` | string | Non-empty. Placed according to `layout`. |
| `body` | string | Non-empty. Uses the same layout as the title. `\n` forces a line break. |
| `photo` | string | A `data:image/(png|jpeg|webp);base64,…` URI. Cover-cropped to fill the whole card and background-blurred. |
| `photoSource` | string | Non-empty. Provenance string. |
| `generated` | boolean | `true` when the photo is generated. |
| `alt` | string | Non-empty. Korean alt text for the card. |
| `layout` | string | `bottom-left`, `bottom-right`, `top-left`, `top-right`, or `center`. The first card must use `bottom-left`; body cards choose explicitly. |
| `layoutReason` | string | Non-empty. Explain the information role and the image space kept clear. |
| `scene` | string | Non-empty. Describe the image scene that supports this card's point. |
| `visualType` | string | `photo`, `illustration`, `diagram`, or `screenshot`. |
| `reuseReason` | string | Required when an earlier card uses exactly the same `photo` URI. Explain the meaningful continuation or comparison; do not repeat an image merely to fill cards. |

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

This is a two-card schema illustration, not executable image data: replace each `…` with the actual base64 image bytes before validation. A one-card document is rejected. In JSON, `\n` encodes a line break; `\\n` encodes the literal backslash and letter n.

## 2. API

`window.cardStudio` is frozen and exposes five calls. The composer validates on `render` and refuses to export while an error stands.

| Call | Returns | Notes |
|---|---|---|
| `window.cardStudio.validate(doc)` | the document, or throws | Synchronous schema check. |
| `await window.cardStudio.render(doc)` | `{ count, width, height }` | Loads fonts and photos, draws the gallery, and builds the sidecars. Rejects on any failure. |
| `window.cardStudio.exportCards()` | `[{ name, dataUrl, width, height }]` | One entry per card, `name` like `01.png`. Fails when nothing is rendered or a render is in flight. |
| `window.cardStudio.exportSidecars()` | `{ "caption.txt", "alt-text.json", "sources.md", "manifest.json" }` | All four are strings. |
| `window.cardStudio.exportHTML()` | string | A self-contained HTML document with the document embedded and the images inlined. |

The human path is the same: the "카드 만들기" button renders, the per-card links and sidecar links download the files, and "편집 가능한 HTML 저장" writes `index.html`. An agent can call `render` then `exportCards` and read `dataUrl` without any click.

## 3. Output layout

Deliver under `.hyper/instagram-card-maker/<slug>/`:

```text
index.html        # exportHTML() output: embedded document, inlined images
cards/01.png …    # exportCards() dataUrl written to disk, one per card, in order
caption.txt       # sidecars["caption.txt"]: the post's single caption
alt-text.json     # sidecars["alt-text.json"]
sources.md        # sidecars["sources.md"]
manifest.json     # sidecars["manifest.json"]
```

`manifest.json` carries `width`, `height`, `count`, `files` (the `cards/NN.png` names), `font` (`embedded` or `system-fallback; Korean glyph inspection required`), `generated` (one boolean per card), and `photos` (one object per card containing `file`, `photoSource`, `generated`, `layout`, `layoutReason`, `scene`, `visualType`, and `reuseReason` when supplied).

## 4. Failure behavior

`validate` and `render` throw a Korean message and `render` sets `#status[data-error="true"]`. The watched failures:

- a non-object document, or a missing `brand`, `caption`, `title`, `body`, `alt`, or `photoSource`
- a `width` other than `1080`, or a `height` outside `{1080, 1350, 1440}`
- a `slides` array that is empty, holds one card, or holds more than 20
- a `photo`, `logo`, or `fontData` value that is not the matching data URI form
- an image that cannot load, times out after 10 seconds, or has zero size
- text that overflows the card (more than 3 title lines, more than 5 body lines, or a text block taller than 69% of the card) — the composer fails instead of shrinking or truncating
- a `fontData` face that fails to load
- an unknown `layout` or `visualType`, a cover layout other than `bottom-left`, missing scene/placement reasons, or identical photo reuse without `reuseReason`

The renderer compares exact image URIs, not perceptual similarity. A visually repeated image with different encoding still requires editorial review. It checks required explanations for presence, not truth or quality.

Editing the JSON after a render invalidates the previous output: the gallery and sidecars clear and `exportCards` fails until the next successful render.

## Sources

> No external sources; content checked 2026-10-15.

This file documents this package's own composer asset.
