# Craft Floor

Read before building and before judging any finding against a number. This file owns the numeric floor every designed, restyled, or mocked-up screen meets. `MUST` rows are conformance requirements and fail the run. `DEFAULT` rows are the starting value when the project, the brief, or the platform says nothing; a documented project value replaces them.

## 1. Contrast and Color

| Rule | Value | Level |
|---|---|---|
| Body text against its background | at least 4.5:1, computed without rounding | MUST (WCAG 2.2 AA) |
| Large text (about 24px, or about 18.5px bold) | at least 3:1 | MUST |
| Icons, control boundaries, state indicators, chart marks needed to understand content | at least 3:1 against adjacent colors | MUST |
| Text over an image or video | a solid or gradient scrim so the worst-case pixel pair still passes 4.5:1 | MUST |
| Muted and placeholder text | still 4.5:1; hierarchy comes from size and weight, not from gray below the floor | MUST |
| Both color schemes | every pair passes in light and dark when both ship | MUST |
| Accent share | one accent hue; accent fills stay a small share of a screen (KRDS: at most 5%) | DEFAULT |
| Neutral tint | tint neutrals toward the brand hue instead of pure gray when the brand allows | DEFAULT |

WCAG 3 is a Working Draft and APCA is not normative anywhere; keep WCAG 2.2 AA as the contrast baseline.

## 2. Targets and Focus

| Rule | Value | Level |
|---|---|---|
| Pointer target (web) | at least 24×24 CSS px, or the WCAG spacing exception | MUST |
| Touch target | 44×44 CSS px or pt on touch surfaces; Android 48×48 dp | DEFAULT (WCAG AAA, Apple default, Android guidance) |
| Apple control minimum | 28×28 pt is the stated minimum; 44×44 pt is the default to aim for | platform |
| Focus visible | every keyboard-operable control shows a focus indicator; never `outline: none` without a replacement | MUST |
| Focus indicator contrast | at least 3:1 against the adjacent background | MUST |
| Focus not obscured | sticky headers, footers, and non-modal panels never fully cover the focused control (`scroll-padding`) | MUST |
| Focus style | keep the user agent ring or the project's documented ring; a custom ring is at least 2px | DEFAULT |

## 3. Type

| Rule | Value | Level |
|---|---|---|
| Web body size | 16px minimum; 16-18px typical (Korean body: §6) | DEFAULT |
| Smallest UI text | 12px; 11pt on iOS, 10pt on macOS are platform minimums, not defaults | DEFAULT |
| Line length | 45-75 characters for running text; never full-width paragraphs on wide screens | DEFAULT |
| Line height, Latin body | 1.4-1.6; headings 1.1-1.3 | DEFAULT |
| Text-spacing tolerance | layout survives user overrides of line height 1.5, paragraph spacing 2em, letter spacing 0.12em, word spacing 0.16em | MUST |
| Resize | text resizes to 200% without loss of content | MUST |
| Families | one family, or two with fixed jobs (display, text); never three | DEFAULT |
| Weights | body 400-500; avoid ultralight and thin for UI text | DEFAULT |
| Heading levels | at most three visible levels in one view; no skipped semantic levels | DEFAULT |
| Headings | sentence case; no all-caps body or headings; tracking only on display sizes (slightly negative) and small labels (slightly positive) | DEFAULT |
| Numbers | tabular figures in tables, prices, and counters | DEFAULT |
| Font supply | every declared face is loaded by the project (`@font-face`, a package, or a system stack); never a face the build does not ship | MUST |

## 4. Space, Layout, Shape, Depth

| Rule | Value | Level |
|---|---|---|
| Space scale | one 4px-based scale (4, 8, 12, 16, 24, 32, 48, 64, 96) or the project's own; no one-off values | DEFAULT |
| Grouping | space inside a group is smaller than space between groups; more space above a heading than below it | DEFAULT |
| Reflow | no two-dimensional scrolling at 320 CSS px width, except tables, maps, and editors | MUST |
| Check widths | the project's breakpoints, otherwise 375, 768, and 1280 (Korean public-sector: 360, 768, 1024, 1280) | DEFAULT |
| Content width | a maximum content width (about 1200-1280px) with one consistent gutter | DEFAULT |
| Radius | a scale tied to element size (for example 4 / 8 / 12 / 16 and full); nested radius = outer minus padding | DEFAULT |
| Depth | a few elevation steps; a layered shadow (ambient plus direct) or a border, not both at full strength on every card | DEFAULT |
| Containers | a card only when the content is a separable object; never a card inside a card for decoration | DEFAULT |

## 5. Motion

| Rule | Value | Level |
|---|---|---|
| Reduced motion | honor `prefers-reduced-motion: reduce`: replace movement with fades or nothing; no parallax | MUST |
| Interaction feedback | 100-200 ms | DEFAULT |
| State and overlay transitions | 150-300 ms; one authored focal entrance may take up to about 500 ms | DEFAULT |
| Easing | ease-out family for entrances (for example `cubic-bezier(0.2, 0, 0, 1)`); no ease-in on entrances; no bounce or elastic by reflex | DEFAULT |
| Properties | animate `transform` and `opacity`; never `transition: all`; never layout properties | DEFAULT |
| Entrances | never from `scale(0)` (start near 0.95 with opacity); one entrance per container; stagger 30-80 ms with the group under about 300 ms | DEFAULT |
| Frequency | actions repeated many times a session get no animation; keyboard-triggered actions do not animate | DEFAULT |
| Autoplay | moving content longer than 5 seconds has a pause control | MUST |

## 6. Korean Text

| Rule | Value | Level |
|---|---|---|
| Line breaking | `word-break: keep-all` with `overflow-wrap: anywhere` (or `break-word`) for long tokens | DEFAULT |
| Body size | 16px minimum; 17px is the KRDS default with Pretendard GOV | DEFAULT |
| Line height | at least 150% for body; 160-170% is a reasonable choice for long reading | DEFAULT |
| Tracking | 0 on Hangul body and labels; never positive tracking for "style" | DEFAULT |
| Font stack | the project's font, or an OFL Hangul family such as Pretendard (keep the reserved name rules) with `"Apple SD Gothic Neo", "Noto Sans KR", "Malgun Gothic", sans-serif` fallbacks | DEFAULT |
| Weights | regular and bold are enough; avoid thin Hangul weights in UI | DEFAULT |

## 7. States, Feedback, Forms, Copy

| Rule | Value | Level |
|---|---|---|
| Feedback timing | under 0.1 s feels instant; under 1 s keeps flow; over 10 s needs progress and a way out | DEFAULT |
| Loading | none under about 1 s; skeleton (page) or spinner (module) for 2-10 s; a skeleton mirrors the final layout; progress over 10 s | DEFAULT |
| Empty state | never blank: status, what fills it, and one direct action | DEFAULT |
| Error message | next to the source, plain language, no blame words, a fix, input preserved, more than color alone | MUST (color alone) / DEFAULT |
| Error summary | multi-field forms show a summary that receives focus and links to each field, worded like the inline messages | DEFAULT |
| Forms | one column; visible labels above fields; placeholder is never the label; mark optional fields; no reset button; never asterisk-only required markers | DEFAULT |
| Disabled controls | still legible; the reason is reachable when it is not obvious | DEFAULT |
| Copy | specific verbs and nouns of this product; no slogan filler ("seamless", "supercharge", "next-gen"); no invented numbers | DEFAULT |
| Icons | one set; an icon-only button has an accessible name; emoji are content, never icons | DEFAULT |

## 8. Checklist

Run per changed screen and record each item `pass`, `fail`, `n/a`, or `not run` with the reason:

1. Contrast pairs from the token plan computed for both schemes.
2. Focus visible and not obscured on every interactive element, by keyboard.
3. Target sizes at the smallest width.
4. Reflow at 320px and text at 200%.
5. Every value in changed code belongs to the token plan or the project's tokens.
6. Line length, heading levels, and font supply.
7. Reduced-motion path and no `transition: all`.
8. Every listed state rendered or implemented.
9. Korean rules when the product language is Korean.

A static run can pass items 5 and 6 and the source half of 7. Items that need rendering are `static_only` without a rendered capture.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| 4.5:1, 3:1, non-text 3:1, reflow 320px, text spacing, resize 200%, target 24×24 (AA) and 44×44 (AAA), focus visible and not obscured, animation from interactions | <https://www.w3.org/TR/2024/REC-WCAG22-20241212/> and its Understanding pages |
| WCAG 3 is a Working Draft and its contrast algorithm is undecided; APCA is not normative | <https://www.w3.org/TR/2026/WD-wcag-3.0-20260910/>, <https://readtech.org/ARC/> |
| Apple text and control sizes (44×44 pt default, 28×28 pt minimum), "make motion optional" | <https://developer.apple.com/design/human-interface-guidelines/accessibility> |
| Android touch target 48×48 dp | <https://developer.android.com/guide/topics/ui/accessibility/apps> |
| Material token values (type scale, shape 0/4/8/12/16/28/full, elevation steps, `cubic-bezier(0.2, 0, 0, 1)`) | <https://github.com/material-components/material-web/tree/main/tokens/versions/v0_192> (Apache-2.0) |
| Line length 45-90 characters, line spacing 120-145%, at most three heading levels | <https://practicaltypography.com/line-length.html> |
| Hit targets, `transition: all`, nested radii, autoplay pause | <https://github.com/vercel-labs/web-interface-guidelines/blob/434b7f91364665f2f733b310ec54809bf8f37937/AGENTS.md> (MIT) |
| UI motion under 300 ms, no ease-in, no `scale(0)`, stagger 30-80 ms, frequency rule | <https://github.com/emilkowalski/skills> (commit `c8a7962`) (MIT) |
| Response-time limits, loading indicators, empty states, error messages, form rules | <https://www.nngroup.com/articles/response-times-3-important-limits/>, <https://www.nngroup.com/articles/skeleton-screens/>, <https://www.nngroup.com/articles/empty-state-interface-design/>, <https://www.nngroup.com/articles/error-message-guidelines/>, <https://www.nngroup.com/articles/web-form-design/> |
| Error summary, one question per page, no asterisk-only required markers | <https://design-system.service.gov.uk/components/error-summary/>, <https://design-system.service.gov.uk/patterns/question-pages/> (OGL v3.0) |
| Korean body 17px default with a 16px floor, line height at least 150%, `keep-all`, breakpoints 360/768/1024/1280, accent at most 5% | <https://www.krds.go.kr/html/site/style/style_03.html> and its sibling style pages |
| `word-break: keep-all` behavior | <https://developer.mozilla.org/en-US/docs/Web/CSS/word-break> |
| Pretendard is SIL OFL 1.1 with a reserved font name | <https://github.com/orioncactus/pretendard> |

### Evidence grade

`MUST` rows restate WCAG 2.2 AA and Level A requirements and are as strong as the standard. `DEFAULT` rows pick one value from ranges the sources give; where sources disagree (Apple 28 pt versus 44 pt, Butterick 120-145% versus KRDS 150% for Korean), the table states which applies. The Korean 160-170% range is this package's choice for long reading, not a sourced number.
