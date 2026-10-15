# Caption and Alt Text

> Korean version: [`caption-and-alt.ko.md`](caption-and-alt.ko.md)

Read while writing the caption and the alt text. This file owns both, plus their sidecar format.

## 1. Caption

The caption is the post's single Korean caption, written in posting order with the cards. It is one `caption.txt`.

- Open with the hook the first card carries; do not restate every card.
- Disclose a sponsorship or own-brand relationship in plain words near the start when one exists.
- Keep the claims that appear in the caption grounded the same way the cards are; a first-hand claim comes only from the user.
- Put hashtags on their own lines at the end, only where they help; no hashtag inventory and no invented counts.
- Do not promise a reach, a metric, or an engagement number.

## 2. Alt text

Write one Korean alt string per card. The count and order must match the cards.

- Describe what the card shows and says: the photo's subject and the card's message.
- Do not repeat the caption and do not write a label such as "카드 1".
- Do not describe a generated photo as a real place, product, or result.

## 3. Sidecar format

The composer builds both from the document.

- `caption.txt`: the `caption` string verbatim.
- `alt-text.json`: an array of `{ "file": "NN.png", "alt": "…" }`, one per card, in order.

## 4. Order and count

Keep the caption's card references, the alt-text entries, and the exported PNGs in one order. A mismatch is a validation failure.

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own caption and alt-text rules.
