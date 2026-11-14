# Mockup Brief

Read this reference when settling minimal tokens or writing a brief for a screen. A brief is the complete description of one screen in one theme, written so that the image skill can render it without seeing a reference.

## Contents

1. What a Brief Holds
2. Canvas by Platform
3. Brief Skeleton
4. Minimal Token Set
5. Light and Dark
6. Revision Briefs

## 1. What a Brief Holds

| Holds | Never holds |
|---|---|
| The screen's purpose in one line | A product, brand, or designer name |
| The platform frame and the canvas shape in words | A reference URL or a reference image |
| Token values: colors as hex, type sizes, radius, spacing | A model name or a model option |
| Regions from top to bottom with their components | Real personal data |
| The exact strings to render, each once, with role and place | Long body copy |
| What must not appear | A request for several screens in one image |

One brief is one screen in one theme and produces one image.

## 2. Canvas by Platform

The frame is the logical screen the mockup represents. The canvas is the shape requested from the image skill. Describe the shape in words inside the brief, and pass the actual ratio or size only through the image skill's structured canvas value.

| Platform | Logical frame to design for | Canvas shape | Frame notes |
|---|---|---|---|
| `mobile` | 390 by 844, portrait | Tall portrait, about 9:19.5 | Status bar at the top, home indicator at the bottom, bottom navigation inside the safe area |
| `tablet` | 1024 by 1366 portrait, or 1366 by 1024 landscape | About 3:4 portrait or 4:3 landscape | State the orientation; a landscape tablet usually carries a side rail or two panes |
| `web` | 1440 by 900 desktop viewport | Landscape, about 16:10 | Show the page inside the viewport only, without browser chrome, unless the user asks for it |

- When the runtime offers only a few shapes, take the nearest one in the same orientation, say in the notes which shape was requested and which came back, and do not crop or resize the returned image.
- A long page is drawn as its first viewport. Further sections are separate briefs, each one viewport tall.
- Draw the screen flat and straight on, edge to edge. No device photo, no perspective, no hand, no desk, and no drop shadow around the screen, because those hide the layout.
- A narrow web layout is a `mobile` brief with the web frame notes.

## 3. Brief Skeleton

Fill every line. Lines marked invariant are repeated word for word in every brief of a set.

```text
Screen: <name> - <one-line purpose>
Platform and frame: <mobile | tablet portrait | tablet landscape | web desktop>, flat straight-on UI screen, edge to edge  [invariant]
Canvas shape: <words only, e.g. tall portrait>  [invariant]
Theme: <light | dark>

Tokens  [invariant per theme]
- Background <hex>, surface <hex>, border <hex>
- Text primary <hex>, text secondary <hex>
- Accent <hex>, text on accent <hex>, danger <hex>
- Typeface character: <e.g. a clean neutral sans-serif with Hangul support>
- Type sizes: title <n>, body <n>, caption <n>
- Corner radius: controls <n>, cards <n>
- Spacing unit <n>; screen side padding <n>; gap between groups <n>

Shared components  [invariant]
- Buttons: <shape, height, fill rule>
- Fields: <shape, label position>
- Icons: <one style, e.g. simple outlined line icons, one weight>
- System bars: <status bar and navigation treatment>

Regions, top to bottom
1. <region>: <components, alignment, relative size>
2. ...

Primary action: <one, with its place>

Text to render (exact, each once)
- "<string>" - <role>, <place by region or by top/middle/bottom and left/center/right>
- ...
Other text: short neutral bars in the text color, no readable sentences

Must not appear: brand logos or names, real app icons, watermarks, device frame, extra screens, invented statistics
```

Checks to write beside the brief before the call:

- the regions are present in the stated order
- each rendered string appears once and matches character by character
- one primary action, in the accent color
- no logo, brand name, or device frame
- the canvas orientation matches

## 4. Minimal Token Set

Use this only when the project has no design document or tokens. It is the smallest set that keeps several mockups consistent, and it is recorded as `provisional`.

| Group | Tokens | How to choose |
|---|---|---|
| Color | background, surface, border, text primary, text secondary, accent, text on accent, danger | One accent only. Take the accent from the user's stated color when one exists; otherwise choose one and say it was chosen. Neutrals carry everything else. |
| Type | one typeface character; sizes for title, body, caption; two weights | Name the character, not a licensed font, unless the project already uses one. Body size no smaller than 16 on web and 15 on mobile in logical units. |
| Radius | one value for controls, one for cards | Two values at most. |
| Spacing | one base unit and the multiples used for side padding and group gaps | A base of 4 or 8, used as multiples only. |

Rules:

- Compute the contrast of text primary, text secondary, and text on accent against their backgrounds before use, and adjust the token until each passes its minimum.
- A requirement stated by the user, such as a brand color, enters the set as given; when it fails contrast as a text color, keep it for fills and choose a passing text color, and say so.
- Do not add a second accent, a gradient, or a decorative style to the minimal set. Those belong to a visual direction, which is a different deliverable.
- Hand the provisional set over as provisional. The implementer does not treat it as the project's design system until the user accepts it.

## 5. Light and Dark

- Each theme is a separate brief and image with its own token column.
- Dark tokens are chosen, not inverted: a dark background that is not pure black, a surface one step lighter than the background, borders that stay visible, and an accent adjusted so that text on it still passes contrast.
- Between the two briefs only the Theme line and the Tokens block change. Regions, strings, and components stay identical, so the two images can be compared.
- With `both`, the light version is generated and reviewed first.

## 6. Revision Briefs

- Copy the previous brief in full.
- Change one thing and add one line at the top: `Revision <n>: <what changed and why>`.
- When the failure was rendered text, reduce the number of rendered strings before changing anything else.
- When the failure was drift between screens of a set, the change is to restate the drifting invariant more exactly, not to describe the other image.

## Sources

> Checked 2026-11-15.

| Claim | Source |
|---|---|
| Mobile, tablet, and web targets, light and dark themes, tokens from the project first and a minimal set of color, type, radius, and spacing otherwise | user instruction, 2026-11-15 (new skill request) |
| Shape described in words with the actual ratio or size in a structured value, exact quoted strings with role and place, one image per brief, shared invariants repeated across a series | this package's image-generation skill contract, restated for screens |
| Contrast minimums applied to the token set | <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html> |

### Evidence grade

`LOCAL`: the three logical frames, the canvas shapes, the skeleton, the minimal token table, and the body-size floors are this package's chosen defaults for a mockup and are not platform requirements. A project's own frame sizes and tokens replace them.
