# Visual Quality Recipe

Read this reference before writing any brief. It fixes the failure this skill shipped with: a brief that described regions and then wrote "other text: neutral bars" produced wireframes, not screens. Six screens rendered with bars, then with complete content, on the same model and the same tokens, are the evidence behind every rule here (see `.hyper/uiux-design/quality-2026-11-15/`).

## Contents

1. Why a Bar Is a Failure
2. The Content Rule
3. Commercial-Grade Checklist
4. Prompt Structure That Renders
5. Screen-Type Patterns
6. Composition Rules
7. Density by Screen Type
8. What the Image Model Cannot Do
9. Fixed Terms and Idioms

## 1. Why a Bar Is a Failure

A bar in the text color is not a neutral abstraction. It is an instruction the image model follows exactly, and it produces three defects at once:

| Defect | What an implementer receives |
|---|---|
| No information | The screen shows a grey rectangle where a price, a count, or a category name belongs, so density, alignment, and truncation behaviour are all unknown |
| Wrong weight | Bars are drawn at one thickness, so the type hierarchy collapses: a caption and a total read as the same thing |
| Wireframe look | Regional layout without content reads as a wireframe regardless of how good the layout is |

The same applies to icons: "a simple outline icon" produces a different invented glyph on every render. Name the glyph, or name the shape it sits in.

A mockup with bars is a wireframe with a color palette. It is not what this skill exists to produce.

## 2. The Content Rule

Every text position on the mockup carries real, correctly spelled, realistic content. No exceptions.

| Always write out | Never write |
|---|---|
| Amounts with currency and grouping: `1,247,300원`, `-12,300원`, `+3,200,000원` | `[amount]`, a bar, `00,000` |
| Counts and units: `12건`, `21건`, `62% 사용` | A percentage as a bar |
| Category and item names: `식비`, `주거·통신`, `스타벅스 강남역점` | `카테고리 1`, `Item` |
| Dates and times in local form: `11월 15일 토요일`, `오늘 08:12` | `00/00`, `Date` |
| Chart axis and legend values | Unlabelled bars; an unlabelled bar is not a chart |
| Nav, tab, button, field, and section labels | Numbers standing in for labels |

Rules:

1. Invent the data. A plausible number is required content, not fake data dressed as real. It is marked `sample data` in the handoff and replaced in code.
2. Make numbers internally consistent: category amounts add up to the total; percentages sum to 100; a progress bar matches the percentage next to it. An implementer who finds `33% + 26% + 15% + 12% + 14%` is correct where `33% + 26%` is not, will trust the layout less.
3. Use realistic Korean names and merchants, invented ones, never a real person. `민지님`, `스타벅스 강남역점`, `GS25 편의점` are sample data.
4. Long text is written out at its real length, not shortened to fit. Whether a label truncates is information the implementer needs.
5. If a string cannot be rendered plausibly, cut the element from the brief rather than drawing a bar for it.

## 3. Commercial-Grade Checklist

A screen that reads as shipped has all of the following. Each is a line in the brief, not a hope.

| Quality | What it looks like in a brief |
|---|---|
| Density | The screen is full but not crowded. A real app rarely shows fewer than five content elements in the first viewport, and rarely more than nine. |
| Hierarchy | Exactly one element is the largest. One second tier. The rest is body and caption. State the pixel sizes so the ratio is real: `40 / 18 / 15 / 12`, not `large / medium / small`. |
| Colour discipline | Neutral surface and text carry about 60% of the area, a secondary neutral about 30%, and the single accent about 10%. The accent appears only on the primary action, the active state, and one badge. |
| Icon consistency | One style named once, one stroke weight, one size per role: `24 line icons at 2px stroke on a 24 grid`, and the same for the tab bar and tiles. |
| Meaningful empty space | Space separates groups; it never pads a missing element. Margins are one number used everywhere: `side padding 20`, `group gap 24`. |
| Real content | Per section 2. |
| Material detail | Cards have a stated fill, radius, and no shadow unless the brief asks for one. Hairlines are 1px and one colour. Elevation is used at most once per screen. |
| Device detail | Status bar with a real time, tab bar with a selected state marked by shape and colour, home indicator. Detail here is what separates a screenshot from a drawing. |
| Micro detail | Divider between rows, secondary line under each primary label, a badge or a count on a section header, a chevron on a navigable row. These are what make density feel intentional. |
| Photography | When the product is visual (travel, food, property, fashion), photography is the dominant element and is named per image: subject, light, framing, and the scrim over it. |
| One idea per screen | The screen has one job and its largest element states it. |

Do not add a quality the product does not have. A settings screen has no photography; a utilitarian ledger has no hero image. Match the checker to the screen type.

## 4. Prompt Structure That Renders

The image model is a prompt-to-image model, not a layout engine. These structures were measured to work.

**Open with the artifact, not the request.** `A full-screen mobile app UI screenshot, portrait, 393x852 logical at @2x, flat and straight on, edge to edge.` This sentence alone prevents the device-on-a-desk look and the perspective tilt.

**Give the frame in pixels.** A logical viewport size plus a scale reads as a screenshot. Vague ratios produce a different canvas each time, so also state the requested ratio to the image tool and record what came back.

**Write one continuous block, in this order:**

1. Artifact and frame.
2. Product and screen, in one line, with the audience implied.
3. Visual language in one or two sentences: the register (`calm, precise, information-dense`), plus the negative list (`no gradients, no glow, no decorative blobs`).
4. Colour with hex values, each with its role.
5. Type with sizes and weights, as a scale.
6. Layout as a numbered list of regions, top to bottom, each with its own sizes, gaps, and contents inline.
7. A closing line that repeats the two hard requirements: every string rendered correctly, nothing a placeholder.

**Put the content inside the region list.** `5. Category list: five rows, each 64 tall with a 12 gap…` followed by the exact rows with their values is what makes the model produce rows. A separate "text to render" list detached from its region produces labels floating without structure.

**Quote every string, and give it a place and a size.** `"이번 달 총지출" in secondary at 13` renders. `a caption about spending` does not.

**State what must not appear.** Models add gratuitous elements: signal bars that were not asked for, a Wi-Fi glyph, a second tab bar, a social login row. A closing negative list removes them.

**One screen per generation.** Several screens in one prompt produce a triptych or a collage with one merged layout.

**Do not use reference images of other products.** The style is carried by description. A reference image of a competitor's screen is both a copying risk and a source of its brand colour.

**Reuse the invariant block word for word across a set.** Tokens, type scale, component shapes, and system bars repeated identically are what make four screens look like one product.

**Correct a wrong render by changing the brief, never by describing the previous image.** "Like before but bigger" produces drift.

## 5. Screen-Type Patterns

The region order a screen type is expected to have. Each is a default to start from, not a rule the image must prove.

| Screen type | Region order | What carries the density |
|---|---|---|
| Home or dashboard | Status bar, header with greeting and actions, one summary card with the headline number, quick actions or a KPI row, a section header with a count, a list of four or five rows, an insight strip, tab bar | The list rows and the secondary line under each |
| List or inbox | Status bar, title with a filter control, search or segmented filter, grouped rows with a leading avatar or icon, a trailing meta and amount, tab bar | Group headers, row secondary text, unread markers |
| Detail | Status bar, nav bar with back and one action, hero media or header block, title and meta line, primary facts in a two- or three-column key-value row, a section of longer text, a sticky bottom action bar | The key-value row and the section headers |
| Form | Status bar, sheet header with cancel, title, save, a segmented control if the form has modes, the hero field, grouped fields with labels, a picker row, an inline keypad or a keyboard, a submit action | Field grouping, helper text, the enabled or disabled submit state |
| Statistics | Status bar, title with a period control, a segmented period selector, a summary card with the total and a delta, a section header with a count, five category rows each with a two-line text block and a share bar, tab bar | Percentages, per-row counts, the delta line |
| Settings | Status bar, large title, a profile row, grouped lists under section captions, rows with a value and a chevron, a destructive row at the end, tab bar | Group captions, right-aligned current values, toggles with real state |
| Onboarding | Status bar, skip at top right, a large illustration or photo block, a headline, a body line, a page indicator, a primary button, a secondary text link | One idea per screen; density comes from the illustration area |

## 6. Composition Rules

- One primary action per screen. It is the largest filled element and the only thing in the accent colour at full strength.
- Two text columns align to a single left edge; nothing is centred except a sheet title and a modal caption.
- Rows inside a list share one height and one internal alignment. A list where each row is a different height reads as unfinished.
- A right-aligned numeric column shares one right edge across every row; use tabular figures so the digits line up.
- Section headers appear above every group of three or more items.
- The first viewport shows the screen's main job without scrolling. Content that continues below is implied by a partially visible row, never by a fade.

## 7. Density by Screen Type

| Screen | Elements in the first viewport | Photography |
|---|---|---|
| Transactional (ledger, banking, settings) | 9 to 14 | None |
| Content (travel, shopping, media) | 6 to 10 | Dominant, 2 to 5 images |
| Dashboard (analytics, admin) | 10 to 18 | None; charts instead |
| Form | 5 to 9 fields plus the keypad or keyboard | None |
| Onboarding | 4 to 6 | One large block |

Too few elements is the most common failure after bars. A screen with a title, one card, and a button is a sketch of a screen.

## 8. What the Image Model Cannot Do

Measured limits, to plan around rather than fight:

| Limit | Response |
|---|---|
| Canvas ratio drifts; a requested 9:19.5 returns about 2:3 | State the ratio to the image tool, then record the returned pixel size in the notes and treat the frame as illustrative |
| Hangul is usually correct but not guaranteed | Read every string character by character; one error is one `fail` (see section 9) |
| Exact pixel alignment is approximate | Take spacing from the brief, never from the image |
| Long body copy is invented | Write short real lines instead of paragraphs |
| More than about 18 fine elements gets muddled | Split the screen into two, or cut an element |
| Brand marks are invented if requested, and a named shape becomes the real mark | Never request one, and never point at a brand-adjacent shape: "a bird-ish mark" rendered a recognizable social-platform bird, while "a plain circle" stayed neutral. Use a geometric tile or an envelope, chat bubble, or circle that no product owns |

## 9. Fixed Terms and Idioms

Use these exact spellings in briefs. They rendered correctly on the first attempt and they are the terms the model handles reliably.

| Element | Write | Never |
|---|---|---|
| Screenshot framing | `flat straight on, edge to edge, no device frame, no hand, no desk` | `mockup`, `wireframe`, `sketch` |
| Placeholder text | `every string rendered fully and correctly, no placeholder bars, no blurred text, no lorem ipsum` | `other text: neutral bars` |
| Status bar | `status bar: "9:41" at left, cellular, wifi and battery at right` | `system bars` alone |
| Selected tab | `the third item active in the accent color with a soft rounded tint pill behind its icon` | `highlighted` |
| Card | `fill <hex>, radius 16, no border, no shadow` | `card` alone |
| Divider | `1px hairline in <hex>` | `separator` |
| Numeric column | `right aligned, tabular figures` | `aligned` |
| Photo card | `photo of <subject> in <light>, 16 radius, a scrim at the bottom with two lines of white text` | `an image` |
| Amount | `"1,247,300원" in 40 bold with tabular figures` | `amount text` |

## Sources

> Checked 2026-11-15.

| Claim | Source |
|---|---|
| Bars in the text color produce a wireframe; complete content produces a shipped-app look; the six-screen before-and-after comparison on one model and one token set | this package's own experiment, `.hyper/uiux-design/quality-2026-11-15/`, 2026-11-15 |
| The artifact-first opening, the pixel viewport, the numbered region list with inline content, the closing negative list, one screen per generation | the same experiment, prompts A through E |
| Density ranges, the 60-30-10 area rule, and the region orders per screen type | this package's synthesis of the observed pattern summaries, stated as defaults and not as measured platform requirements |
| The image model's ratio drift and Hangul unreliability | observed in this package's runs on 2026-11-15; a working observation, not a published rate |

### Evidence grade

`LOCAL` for the content rule, the quality table, the pattern table, the density ranges, and the limits. The before-and-after comparison is `PRIMARY` for this package: five screens were rendered on the same model with the same tokens and only the brief changed. The density numbers and the 60-30-10 split are this package's chosen defaults, not standards.
