# Format Options: plain vs rich

> Korean version: [`format-options.ko.md`](format-options.ko.md)

Read after the format choice in [`../rules/intake.md`](../rules/intake.md). This reference defines delivery, not authorization to operate or publish in Naver.

## 1. Delivery

For rich output, follow [`rich-html-template.md`](rich-html-template.md) and deliver a **complete HTML file with a formatted-copy button**. Replace the shell’s #sample body and retain its copy behavior.

- `plain`: one fenced `text` draft with title, body markers, and hashtags. Explain that the title field and tag controls still require separate entry.
- `rich`: separate title, category (if known), and tags from body-only HTML. Deliver an HTML artifact with a rendered preview when file delivery is available; otherwise deliver fenced `html` source explicitly labeled as source, not a styled clipboard.
- Rich paste requires rendered content copied with HTML clipboard data (`text/html`), not copying literal tags from a code block. Do not promise that a fenced block's copy button preserves styling. When no rendered/HTML clipboard route is available, explain the limitation and provide source plus a plain fallback.
- Keep image-generation JSON prompts and publishing notes outside the body HTML. Unknown image sources remain visible instructions; never invent a URL or claim a prompt is an image.

## 2. Supported features and limits

| Feature | Reported result | Delivery rule |
|---|---|---|
| Bold, text color, background highlight, underline | Preserved | `strong`, `em`, `span` with inline color/background styles, `u` |
| Center/right alignment | Preserved | Inline `text-align` |
| Paragraph `line-height` inline (e.g. `1.8`) | Preserved; propagated to sibling paragraphs in the same text component | Inline on each `p`; the rhythm contract's default |
| Paragraph `margin-top`/`margin-bottom` | Not preserved — removed by the editor's conversion; no visible gap remains | Never use `margin` for spacing; use the blank-paragraph spacer instead |
| Blank-paragraph spacer (`<p>&nbsp;</p>`) | Preserved as a visible blank line | The spacing mechanism of the body rhythm contract |
| Highlight box (`padding` + `background-color` + `border-left`) | Preserved via conversion into a native one-cell table component (cell background, left border 4px, ~40px height) | `highlight-box` block in `rich-blocks.html`; lands as an editable single-cell table |
| Quote, divider | Native quote/divider components | `blockquote`, `hr` |
| Ordered/unordered lists | Preserved | `ol`, `ul`, `li` |
| Links | Converted to `se-link`, URL retained in `data-href` | Supply ordinary `a href`; do not generate Naver internal markup |
| Public HTTPS images | Photo components; alignment and width retained | `img` with a real accessible HTTPS source |
| Tables | Editable native table components | Borders, cell backgrounds, headers, inline cell styling, 100% width, cell alignment, `colspan`, `rowspan` |
| Data/Base64 images | Removed; surrounding text remained | Do not use `data:image` |
| Strike-through `s` | Normalized to ordinary text (live editor test confirmed) | Leave as a manual editor action |
| `pre/code` | Ordinary text, not a source-code component | Leave as a manual editor action |

Grades above: the Preserved/Not preserved/Removed rows carry live editor paste evidence (aside editor session; evidence paths listed in `../rules/post-workflow.md` §3 body rhythm contract). Rows without a live note are prior observed reports. Table conversion exposed row/column addition, merging, row/column splitting, and width/height controls. This is evidence of editable tables, not a guarantee for arbitrarily nested HTML.

## 3. HTML authoring boundaries

Use the user's recommended subset: `p`, `br`, `h2`, `h3`, `strong`, `em`, `u`, `span`, `ul`, `ol`, `li`, `blockquote`, `hr`, `table`, `thead`, `tbody`, `tr`, `th`, `td`, `img`, `a`. Prefer inline styles and simple sibling blocks over deeply nested structures.

Paragraph defaults follow the body rhythm contract in [`../rules/post-workflow.md`](../rules/post-workflow.md) §3: `line-height:1.8` inline on every paragraph, body paragraphs center-aligned, tables/lists/captions left-aligned, blank-paragraph spacers between blocks (not `margin`). The subset remains a recommendation: exact heading sizes were not individually reported as tested.

Escape text and attribute values; exclude scripts, event handlers, and executable URL schemes. Use valid table spans and consistent cell counts. Apply the prose ornament budget; supported styling is not a quota to fill.

Public HTTPS image URLs require supplied or verified sources. Local images need manual upload or separately authorized upload work; this skill does not silently host files externally. Never substitute Base64. For long posts, offer ordered body fragments that can be pasted sequentially and checked for duplicate or missing blocks.

## 4. Separate editor actions

Body paste does not populate title, category, tags, visibility, comments, likes, scheduling, or publication. Keep those fields in the handoff, never imply body HTML sets them.

Video, stickers, files, schedules, equations, places/maps, books, 글감, external-content components, and source-code components remain manual editor actions unless separately requested and supported. User-recommended automation is not authorization to add it here.

Before publication, the user checks the rendered body or editor DOM for missing/duplicated blocks, links, table spans, image placement, and title/tag separation. Publication remains the user's action.
