# Card Composition

> Korean version: [`card-composition.ko.md`](card-composition.ko.md)

Read while composing cards. This file owns the card narrative, the layers, the blur, the scrim, and the placement.

## 1. Card narrative

Order the cards so the sequence builds one argument.

- Hook card: the promise or the question the set answers.
- Evidence cards: one idea each, as many as needed, each carrying a sourced fact.
- Relevant caveat: name a real limit or a case where the advice does not hold, when applicable.
- Closing card: the next step or the takeaway.

These are narrative roles, not a mandatory minimum number of separate cards. Combine a hook with its answer or a closing step in a short set. One card carries one main idea; split overloaded cards.

Plan each card's `scene`, `visualType`, `layout`, and `layoutReason` before acquiring images. Change the scene or visual type when the information changes: a situation photograph, explanatory illustration, comparison diagram, or relevant interface screenshot. Keep a coherent palette and photographic direction, not one repeated photo across several cards. Reuse needs an explicit `reuseReason` and a meaningful narrative purpose. The same information type may keep its layout; do not randomize alignment to manufacture variety.

## 2. Layers

The composer draws in this order: a full-bleed photo layer, a translucent scrim, the title and body text, the logo, and the top-left brand label. The photo covers 100% of the card and the text is a separate layer drawn on top, so the Korean stays crisp while only the photo is soft and the photograph stays visible under the text.

## 3. Blur

Blur only the photo background, and subtly. The composer draws the photo overscanned by 16 px and applies a 2 px blur to the photo layer alone, never to the text, the title, or the logo. A subtle blur calms the photo without hiding it; it does not create contrast by itself.

## 4. Contrast surface

The text sits on a translucent black scrim over the photo, with white text on top. The scrim holds one constant alpha (0.62) across the text block with 24 px padding, so white text clears the 4.5:1 minimum even over a pure white photo while the photograph remains visible beneath. It fades outside the block; bottom layouts extend the solid band to the bottom edge. Top and center layouts protect their own text region, not only the bottom. There is no opaque text panel or full-card fill.

## 5. Placement

- Cover title and body: `bottom-left`, inside a 72 px margin.
- Body title and body: choose `top-left`, `top-right`, `center`, `bottom-left`, or `bottom-right` to suit the image and information role. Top layouts start at 200 px to clear the brand/logo area. Center layouts center the text block vertically and horizontally. Right layouts right-align both title and body.
- Logo: top-right, drawn at its original aspect ratio, never filtered, recolored, or stretched.
- Brand label: top-left, white text on a small translucent black chip, reading `brand  index/total`.

## 6. What not to do

- Do not blur the whole card or the text layer.
- Do not move the cover away from `bottom-left` or apply that fixed position to every body card by default.
- Do not rely on the raw photo for contrast; keep the scrim, and never cover the whole card with an opaque or near-opaque fill that hides the photograph.
- Do not shrink or truncate text to fit — the composer fails instead, and the fix is to split the card.

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own composition defaults.
