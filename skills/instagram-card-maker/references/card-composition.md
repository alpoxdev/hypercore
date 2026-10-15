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

## 2. Layers

The composer draws in this order: a blurred photo layer, an opaque text panel, the title and body text, the logo, and the top-left brand label. The photo and the text are separate layers, so the Korean stays crisp while only the photo is soft.

## 3. Blur

Blur only the photo background, and subtly. The composer applies a 2 px blur to the photo layer alone and never to the text, the title, or the logo. A subtle blur calms the photo without hiding it; it does not create contrast by itself.

## 4. Contrast surface

The text sits on a fully opaque `#151515` panel with white text, so contrast does not depend on the photo. The panel occupies at least 48% of the card height and grows with the text up to 69%. This is what keeps the Korean legible over a bright or busy photo.

## 5. Placement

- Title and body: left-bottom, inside a 72 px margin, left-aligned, top-aligned within the panel.
- Logo: top-right, drawn at its original aspect ratio, never filtered, recolored, or stretched.
- Brand label: top-left, white text on a small `#151515` chip, reading `brand  index/total`.

## 6. What not to do

- Do not blur the whole card or the text layer.
- Do not place the title anywhere but the left-bottom.
- Do not rely on the photo for contrast; keep the panel.
- Do not shrink or truncate text to fit — the composer fails instead, and the fix is to split the card.

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own composition defaults.
