# Review Checklist

Read this reference for every review pass, once an image is back. It lists what to check in a generated screen mockup, how to record each item, and what makes an image a candidate for approval.

## Contents

1. How to Record
2. Brief Fidelity
3. Readability
4. Generated-Image Tells
5. Accessibility
6. Set Consistency
7. Reference Independence
8. Verdict

## 1. How to Record

Open the returned image and look at it; a successful tool call is not a review. Record one row per item:

| Column | Content |
|---|---|
| Item | The check, by its id below |
| Result | `pass`, `fail`, or `not checkable in an image` |
| Label | `seen` or `computed` |
| Note | What was observed, in a few words; for a `fail`, what the next brief changes |

A `not checkable in an image` item is copied into the handoff as a requirement. It is never counted as a pass.

## 2. Brief Fidelity

| Id | Check |
|---|---|
| F1 | Every region in the brief is present, in the stated order |
| F2 | The single primary action is present, in the stated place, in the accent color |
| F3 | The components are the ones named: no extra tab bar, banner, card, or step |
| F4 | The canvas orientation and the platform frame match: system bars for mobile, no browser chrome for web unless asked |
| F5 | The theme matches the brief's token column: background, surface, and accent read as the stated colors |
| F6 | The screen is flat, straight on, and edge to edge, with no device, hand, or scene around it |

## 3. Readability

| Id | Check |
|---|---|
| R1 | Each rendered string matches the brief character by character, including every Hangul syllable, and appears once |
| R2 | No readable text exists beyond the listed strings; other text is neutral bars |
| R3 | The hierarchy reads in order: title, then content, then the primary action |
| R4 | Text does not overlap, clip at an edge, or collide with an icon |
| R5 | The smallest text is still legible at the image's native size |

## 4. Generated-Image Tells

These are the marks that make a mockup look machine-made, and they mislead an implementer.

| Id | Check |
|---|---|
| G1 | No invented logo, brand name, mascot, or app icon |
| G2 | No decoration the tokens do not contain: gradient washes, glow, glass blur, floating blobs, stock-style illustration |
| G3 | No fake data dressed as real: large statistics, testimonials, ratings, or names that the brief did not ask for |
| G4 | Icons share one style and one weight, and each sits where a real control would be |
| G5 | Spacing is regular: equal gaps between like items, one side padding, aligned edges |
| G6 | Repeated components are identical in shape: every card, row, and field matches its siblings |
| G7 | No duplicated or half-drawn element, and no second screen in the same image |

## 5. Accessibility

| Id | Check | Label |
|---|---|---|
| A1 | Each text and background pair in the tokens meets its contrast minimum | `computed` |
| A2 | Text over a photo or gradient has a solid or scrim layer behind it | `seen` |
| A3 | State is not carried by color alone | `seen` |
| A4 | Controls are drawn large enough to plausibly meet the platform target size; the exact size is a handoff requirement | `not checkable in an image` |
| A5 | Focus, screen-reader names, and keyboard order | `not checkable in an image` |

Never sample a color from the image for A1. The ratio comes from the token values.

## 6. Set Consistency

Run these across all images of a set together, after each image passed on its own.

| Id | Check |
|---|---|
| S1 | Background, surface, and accent look the same on every screen |
| S2 | The type treatment is the same: one typeface character, the same title and body scale |
| S3 | Shared components are the same on every screen: button shape and height, field shape, card radius |
| S4 | System bars and navigation sit in the same place and style |
| S5 | A light and a dark version of one screen differ only in color |

A screen that drifts is regenerated with the drifting invariant restated; the anchor screen is not changed to match it.

## 7. Reference Independence

| Id | Check |
|---|---|
| I1 | The mockup cannot be mistaken for any one reference: its composition was built from the pattern summary, not traced |
| I2 | No name, logo, illustration, copy, or signature color-and-type pairing of a referenced product appears |
| I3 | The brief contains no product name, reference URL, or reference image |

## 8. Verdict

- Candidate: no `fail` in sections 2 to 7.
- Regenerate: any `fail`, while the screen has briefs left under the cap. The next brief changes one thing, chosen from the highest failing section in this order: reference independence, brief fidelity, readability, generated-image tells, set consistency.
- Stop: the cap is reached. Keep the attempt with the fewest failing items and list them.

A candidate is not an approved mockup. Approval is the user's.

## Sources

> Checked 2026-11-15.

| Claim | Source |
|---|---|
| The review covers generated-image tells, readability, accessibility, and consistency, with a regeneration cap | user instruction, 2026-11-15 (new skill request) |
| Contrast is computed against stated minimums, and color is not the only means of conveying state | <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html>, <https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html> |
| A returned image is inspected rather than trusted from the tool call, and a wrong character is fixed by regenerating | this package's image-generation skill contract, restated for screens |

### Evidence grade

`LOCAL`: the item list, the ids, and the order in which a failing section is fixed are this package's chosen review. The list of generated-image tells is a working list, not a measured taxonomy.
