# Layout And Typography

Use this rule file when a slide is crowded, when type looks wrong, or when a deck must read from the back of a room. The geometry itself lives in `assets/runtime/layout.jq`; this file explains the decisions a spec author has to make inside it.

## 1. The Grid

| Value | EMU | Inches |
|---|---|---|
| slide | 12192000 × 6858000 | 13.333 × 7.5 |
| margin | 609600 | 0.667 |
| text column | 10972800 | 12.0 |
| title baseline area | y 533400, height 838200 | 0.583, 0.917 |
| body top | y 1600200 | 1.75 |
| body bottom | y 6248400 | 6.833 |
| footer | y 6355080 | 6.95 |

Left edge is one margin for every element, including cards and tables. Nothing is centred horizontally except the image slide, because a centred column that does not match the title's left edge reads as a mistake.

## 2. Type Scale

| Role | Points | Why |
|---|---|---|
| title slide headline | 44 | the only 40+ element in a deck |
| section number | 15, accent colour | a label, not a heading |
| section title | 36 | |
| slide title | 30 | one line, about 20 Korean characters |
| lead line | 17 | one sentence under the title |
| body bullet | 18 to 22, grown from the block | the size a room reads; capped below the 30-point title |
| sub-bullet | 16 | derived: body minus 2 |
| column heading | 17, accent colour | |
| column bullet | 15 | |
| stat value | 46 | |
| stat label | 15 | |
| stat note | 12, muted | |
| table text | 13 | |
| caption | 12, muted | |
| quote | 32 | |
| footer and page number | 11, muted | |

Two rules follow. Body is never smaller than 15 points, because below that a projector turns text into texture. Emphasis comes from weight and colour, not from size: a 30-point title and an 18-point body differ enough that a 24-point "important" bullet only looks inconsistent.

A bullets slide grows its text to the block, not past it: the block is tried at 18, 19, 20, 21 and 22 points and the largest size that fits the body wins. The cap is 22 (`T_BODY_MAX`), so a four-bullet slide never renders its body larger than two thirds of the title. When the block still leaves room, the leftover is spread as extra space before each paragraph, up to 18 points per paragraph, rather than left as one dead strip at the bottom of the page.

## 3. Spacing

- `spaceBefore` is in points, and the default 6 is a paragraph gap, not a line gap. Line spacing is left to the reader and the font.
- Cards and stats use a 304800 EMU gap (0.333 inch). A wider gap breaks the row into separate things; a narrower one fuses them.
- A lead line pushes the body down by 640080 EMU. Do not also add space to the first bullet; the layout already moved the box.
- Vertical centring is for single-line boxes only. A multi-line box anchored to centre moves when text is edited, which makes two versions of the same slide look different.
- A columns card is only as tall as its tallest column needs, measured from the heading band, the wrapped bullets, and the bottom pad. A card fixed to a share of the body leaves a large empty panel under three short bullets, and a card that grows past the body is reported as `LAYOUT_OVERFLOW` instead of being cropped silently.

## 4. Colour

- One accent colour per deck. It marks the one thing per slide the eye should hit first: a stat value, a column heading, the table header, the chart's first series.
- Muted colour is for text that supports: captions, notes, footer, sub-bullets. Never for a claim.
- Dark slides (title, section, quote) use the palette's dark tokens. Mixing a light body colour onto a dark background produces text that vanishes on a bad projector.
- Contrast: body text on background at least 4.5:1, and large text at least 3:1. The `ink` and `mono` palettes clear this; a custom `accent` must be checked before use as text.

## 5. Tables And Charts

- Table: header row filled with the accent, body rows alternating with the surface colour. Six columns maximum; the column width is equal, so a column of long sentences will wrap and push the row height.
- A table row height is derived from the body area divided by the row count and clamped to 0.35-0.8 inch. The 0.35 floor wins from 15 rows including the header (14 with a caption), the table then runs past the body bottom, and the renderer reports it as an overflow. Split the table before that.
- Chart: the first series takes the accent, the rest fall back to muted, line, and surface. A pie with more than five slices is unreadable; use a bar chart.
- Chart values must be numbers. A string value renders as a category label and silently produces a flat chart.
- Two units on one page take a `combo`: bars read the left axis, lines read a second axis on the right with no gridlines. Putting a rate and a volume on one axis flattens the rate onto the baseline, which reads as zero.
- A horizontal chart is for long category names; a vertical one rotates them. A stacked chart shows composition only when the total means something.
- A scatter's category is its x when it parses as a number. Do not plot the value on both axes: it draws a diagonal through the origin.

## 6. Images

- `fit` decides what is lost. `contain` keeps the whole picture and letterboxes the box, which is right when the picture is evidence such as a screenshot. `fill` keeps the box and crops the centre through `srcRect`, which is right for texture and for `hero`.
- Set `aspect` to the real width divided by height only when the file's size cannot be read. The layout reads pixel dimensions from the file header first, and a wrong `aspect` crops the wrong band or letterboxes a correct crop.
- Every picture carries `alt`. It is written as `descr`, announced by a screen reader, and shown when the image fails to load; a delivery without it is reported as `IMAGE_NO_ALT`.
- A caption reserves its own band above the picture's height, so it can never land on the picture it describes.
- `gallery` takes one to four pictures with a caption under each. Two pictures beside a paragraph of text is a layout problem, not a picture problem: use `imagetext` for one and `gallery` for the set.
- A photograph under text takes a flat scrim, `0.55` by default. Raise it for a busy picture, lower it for a dark one. A gradient scrim is invisible over a picture with its own light gradient and cannot be checked by reading a value.

## 7. What To Check Before Delivering

- Title on one line; if it wrapped, shorten it rather than shrinking the type.
- No bullet reaching past the text column, and no bullet ending in an ellipsis that came from truncation.
- Every caption directly under the thing it names, not under the next thing.
- The footer present on every slide except the title slide, with the correct page number.

## Sources

> Checked 2026-11-13.

| Claim | Source |
|---|---|
| Slide dimensions, EMU, and the 16:9 geometry | <https://learn.microsoft.com/en-us/office/open-xml/presentation/structure-of-a-presentationml-document> |
| Contrast ratios for text | <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html> |
| Type size and line length for projected text | <https://www.w3.org/WAI/tutorials/images/complex/> |
| Chart series colour assignment and cached values | <https://learn.microsoft.com/en-us/office/open-xml/presentation/working-with-charts> |

### Evidence grade

`LOCAL` — the grid, the type scale, and the clamps are read from `assets/runtime/layout.jq` and were rendered and inspected slide by slide on 2026-11-13. The contrast floor is the WCAG 2.2 minimum.
