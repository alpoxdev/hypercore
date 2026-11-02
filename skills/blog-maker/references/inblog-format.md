# inblog Format

> Korean version: [`inblog-format.ko.md`](inblog-format.ko.md)

Read only when the resolved platform is `inblog`, before delivery, from [`format-options.md`](format-options.md). This file carries the inblog layout, metadata, editor facts, and the measured paste results. It never describes Naver behavior: the Naver editor observations stay in [`format-options.md`](format-options.md) §2, and the Naver ranking references are not read for an inblog post.

## Contents

- 1. Delivery
- 2. Body layout
- 3. Metadata separate from the body
- 4. Native schema
- 5. Paste observations
- 6. Documented editor blocks and images
- 7. Sources

## 1. Delivery

- Body HTML is the default and plain text is used only on an explicit request, the same as Naver ([`format-options.md`](format-options.md) §1).
- **The route is the rich paste.** Press `서식 콘텐츠 복사` (copy formatted content) in the output shell, which puts the rendered body on the clipboard as `text/html`, then paste with `Ctrl+V` / `⌘V` into the inblog **normal editor body**. Do not open a block first and do not use the slash menu. In the 2026-11-03 measurement the body arrived as editable inblog blocks: links, bold, italic, underline, strikethrough, inline code, highlight, text color, H2-H4, nested lists, quote, divider, tables with merged cells, a code block with a detected language, a small external image, and centered alignment (§5).
- If the browser blocks automatic copy, the shell leaves the body selected; press `Ctrl+C` / `⌘C` yourself, then paste that same body.
- **`HTML 소스 복사` (copy HTML source) is not a body route.** It puts the markup on the clipboard as plain text, so the normal editor body shows literal tags instead of formatted blocks.
- **The HTML embed block is for third-party embeds only** (maps, video, widgets). Per the official docs, content placed there stays one HTML block and is not converted into normal editor blocks, so the post body must never go in it.
- **Markdown is not a route.** The official doc says pasted Markdown becomes editable inblog blocks; on the 2026-11-03 measurement this editor build parsed only inline marks (bold, italic, strikethrough, inline code). Headings, lists, quotes, dividers, tables, code fences, and Markdown links stayed literal text (§5, Markdown column: 4/16 formatting rows; underline, highlight, and text color are lost). The package therefore delivers an inblog body only through the rich paste and does not offer a Markdown path.
- Three block types never come from a paste: callouts, bookmarks, and link buttons. Add them in the editor with the `/` command when the post needs them (§5).

## 2. Body layout

inblog is not Naver; the Naver rhythm contract does not apply.

- Body paragraphs are **left-aligned natural paragraphs**. Do not force 12-25-character line breaks and do not center-align the body.
- Subheadings are `h2` and `h3` (the editor's heading blocks cover H2-H4).
- The `Title` field is the H1, so the body carries **no duplicate H1**: start at H2 and never repeat the title as a heading.

## 3. Metadata separate from the body

Keep every metadata field out of the body HTML.

| Field | Where it lives | Note |
|---|---|---|
| Title | The `Title` field | Functions as the H1; the visible heading |
| Description | The `Description` field | Shown under the title on the post |
| Meta title (optional) | The gear button on the title field | Sets the `<title>`; empty falls back to the post title |
| Meta description (optional) | The gear button on the description field | Empty falls back to the post description |
| Slug | The editor's top area | A human-readable URL slug; generated from the title by default, customizable |
| Category | The `+Categories` button | Organizes the post |
| CTA button | The `+ Add CTA button` control below the body | Button text (30 characters or fewer recommended), destination URL, and button color; it does not display unless configured |

The outer `Description` box is the reader-facing description even though its placeholder reads "Write meta description..."; the separate meta description is the inner box revealed by the gear. Do not insert an unsupported metadata field into the body.

Set the single conversion CTA with `+ Add CTA button`, once. Keep the closing body sentence as plain text and do not build a body link button for it.

An inblog post has **no hashtag requirement and no editor topic lane**. Do not carry Naver's hashtag rule, its ranking or algorithm references, its DataLab demand check, or its editor 주제 selection onto inblog. For an inblog post, topic research is generic public research plus the topic's own primary sources.

## 4. Native schema

The API schema describes what the editor stores. It is the `content_html` field of `PostResource` in <https://inblog.ai/openapi.json> (checked 2026-11-03). The editor is TipTap-based and writes `editor.getHTML()`, so every node in the list is a normal editable block.

| Group | Nodes |
|---|---|
| Basic | `p`; `h2`, `h3`, `h4` (no `h1`, `h5`, `h6` block; the post H1 is the Title field); `ul`/`ol`/`li` with nesting; `strong`, `em`, `u`, `s`, `code`; `a` (no `rel` attribute, `nofollow` removed); `blockquote`; `hr`; `br` |
| Advanced | `mark` in several colors; `span style="color: #hex"`; `style="text-align: left\|center\|right"`; `pre > code.language-*` |
| Tables | `table`, `thead`, `tbody`, `tr`, `th`, `td`, `colwidth` on cells, wrapped for horizontal scroll |
| Custom blocks (`data-type`) | `img data-type="imageBlock"`; `div data-type="imageGrid"`; `div data-type="imageCarousel"`; `div data-type="callOut"`; `div data-type="linkButton"`; `div data-type="bookmark"` |
| Embeds | `div data-type="youtube"` with `data-youtube-video-id`; `div data-type="googleForm"`, `"hubspot"`, `"tally"`, `"typeform"`; raw HTML uses `section data-type="code-block"` with an inner `div` (a `div data-type="htmlCodeBlock"` does not match the schema) |

The same schema states that `script` tags are removed, images should come from the inblog CDN (`source.inblog.dev`), external stylesheets are restricted, and iframes are allowed only for the permitted embed services. The list names what the editor can hold; §5 records what a paste from this package actually produces.

## 5. Paste observations

Measured 2026-11-03 (KST) on the inblog editor of the dashboard blog `alpox`, with a real clipboard copy and `Ctrl+V`, reading `.ProseMirror` afterwards. `native` means the node or mark survived as an editable inblog block with the same meaning; `flattened` means only the text survived. The Markdown column comes from pasting Markdown from the same shell; it is recorded to state the limit and is not a delivery route.

| Row | Item | Rich paste | Markdown paste |
|---|---|---|---|
| P1 | Link `https://www.naver.com` in a paragraph | native (`a[href]`; inblog stores `https://www.naver.com/`) | flattened (link syntax stayed literal; the URL became an auto-link) |
| P2a | strong | native | native |
| P2b | em | native | native |
| P2c | u | native | flattened (Markdown has no underline) |
| P2d | s | native | native |
| P2e | inline code | native | native |
| P3 | mark | native | flattened |
| P4 | text color on `span` | native (`span` with `color: rgb(23, 63, 138)`) | flattened (color lost) |
| P5a | h2 | native | flattened (literal `## `) |
| P5b | h3 | native | flattened (literal `### `) |
| P5c | h4 | native | flattened (literal `#### `) |
| P6 | nested `ul` and `ol` | native (nesting kept) | flattened (each line a separate paragraph) |
| P7 | blockquote | native | flattened (literal `> `) |
| P8 | hr | native (`hr`) | flattened (literal `---`) |
| P9 | table with `thead` | native (`th` cells sit in `tbody`, `tableWrapper` added) | flattened (pipe table as text) |
| P10 | table with `colspan` and `rowspan` | native (merges kept) | flattened (pipe table as text) |
| P11 | `pre > code.language-javascript` | native (code block; language set to `Javascript`) | flattened (fence as text) |
| P12 | callOut | flattened (insert with the `/` command) | flattened (insert with the `/` command) |
| P13 | bookmark | flattened (insert with the `/` command) | flattened (insert with the `/` command) |
| P14 | link button | flattened (insert with the `/` command) | flattened (insert with the `/` command) |
| P15 | external image (one small PNG) | native (image block) | flattened (image syntax as text) |
| P16 | centered paragraph | native (`text-align: center`) | flattened (`text-align: left`) |

Rich paste: all 16 formatting rows native (P2a-P2e, P3, P4, P5a-P5c, P6-P11), and the P1 link native. Markdown paste: 4 of 16 formatting rows native (P2a, P2b, P2d, P2e).

- inblog normalizes link targets: `https://www.naver.com` is stored as `https://www.naver.com/`. The link stays live and the host and path are unchanged, so a raw string check for the exact original URL misses it.
- The code block arrives as the editor's code block node with the language read from `class="language-javascript"`.
- The P15 image is one small external PNG. Larger files and hot-linked images are outside this measurement; upload through the Image block instead (§6).

## 6. Documented editor blocks and images

The official docs list these editor blocks: headings (H2, H3, H4), tables, lists, quotes, code snippets, dividers, callouts, emojis, bookmarks, images (max 10 MB; JPG, PNG, GIF, WebP; **SVG unsupported**), HTML embeds, and form embeds (HubSpot, Tally, Google Forms, Typeform). Slash commands insert a block, and an August 2026 update adds keyboard navigation of the slash menu, per-language command search, `Tab` movement between table cells, and formatting several selected cells at once.

This list is what the editor can hold. §5 is what a paste from this package produces; a listed block type is not a paste guarantee.

### Images

- Image markers (`[이미지: 대상 | 캡션]`, `[이미지 생성: 대상 | 캡션 | 프롬프트 #n]`) are drafting aids, not body content. Remove the marker in the editor and upload the file through the Image block.
- The Image block accepts files up to 10 MB in JPG, PNG, GIF, or WebP, and SVG is unsupported. The schema asks for images on the inblog CDN (`source.inblog.dev`), which the block provides.
- A single small external https PNG survived the measured paste as an image block. Do not generalize that one row to large or hot-linked files.

## 7. Sources

> External sources checked 2026-11-03; the paste session is this package's own measurement.

| Claim | Source |
|---|---|
| §1 HTML embed stays one HTML block and is not converted to normal blocks; the doc's Markdown claim; CTA button text, URL, and color; image max 10 MB and SVG unsupported; the editor block list | <https://inblog.ai/docs/write-contents/creating-content> (official; page updated 2026-09-08) |
| §4 the stored HTML schema: TipTap `getHTML()`, the tag list, `data-type` blocks, the `code-block` section wrapper, script removal, the CDN, iframe limits | <https://inblog.ai/openapi.json>, `components.schemas.PostResource.properties.attributes.properties.content_html` (official; checked 2026-11-03) |
| §2 the Title field functions as an H1 | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (official) |
| §3 separate Description and optional Meta title / Meta description; slug; category | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (official) |
| §6 table cell movement and multi-cell formatting; slash-command keyboard navigation | <https://inblog.io/changelog/faster-tables-and-slash-commands> (official; dated 2026-08-21) |
| §1 and §5 paste results, route, and the Markdown limitation | This package's own paste session on the inblog editor, dashboard blog `alpox`, 2026-11-03 (22 measured rows; real clipboard and `Ctrl+V`) |

The Markdown sentence in the official doc and the 2026-11-03 measurement disagree: the doc says pasted Markdown becomes block-by-block editable content, the measurement found only inline marks parsed. This file records both and follows the measurement for the delivery contract.

Not measured: embeds (YouTube, forms), image grids and carousels, multi-color highlights, large images and CDN uploads, and the HTML embed block itself. None of those is claimed beyond what the sources state.
