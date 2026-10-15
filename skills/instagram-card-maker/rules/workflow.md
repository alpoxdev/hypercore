# Workflow

> Korean version: [`workflow.ko.md`](workflow.ko.md)

Read before starting a run. This file owns the end-to-end procedure from intake to delivery.

## 1. Intake and research

Ask together only the items the brief left open: the topic, the brand and its relationship to the user (own brand / sponsored / none), the reader and the goal, the photo source (supplied / generated / none), whether a logo is supplied, the format, and optional tone. Await the reply, then do not re-ask.

Research from the topic without demanding a fact pack. For each card, write the reader's question and the sourced answer.

- Expand query candidates and pick the one the card set will answer.
- Collect facts with `URL | accessed date`; label a first-party source and a second-hand source differently.
- A first-hand claim, a price paid, a result, a customer count, or a brand line comes only from the user. Leave it as a slot when absent.
- Record photo slots: what photo each card needs, whether it exists, and where it comes from.

## 2. Plan

- Choose the card count: at least 2 and at most 20, since the app carousel holds up to 20 items. Compose as many cards as the content needs and no more.
- Choose the format from [`../references/platform-specs.md`](../references/platform-specs.md). Default 1080×1350 (4:5).
- Order the ideas as hook → sourced explanation → relevant caveat → next step. Allocate cards according to the content; combine roles in a short set rather than forcing a fixed card count. Do not invent a downside when the subject has none.

## 3. Compose

- Build the input document per [`../references/output-contract.md`](../references/output-contract.md).
- Compose each card per [`../references/card-composition.md`](../references/card-composition.md) and [`legibility-and-typography.md`](legibility-and-typography.md).
- Keep the photo and the text as separate layers; keep the title and hook at the left-bottom.

## 4. Export

- Open [`../assets/card-studio.html`](../assets/card-studio.html), load the document, and run the composer's validation.
- A `render` rejection sets `#status[data-error="true"]` and blocks `exportCards`; fix the cause before exporting.
- Export through the API and collect one PNG per card, in posting order.

## 5. Caption and alt text

Write the Korean caption and the per-card alt text per [`../references/caption-and-alt.md`](../references/caption-and-alt.md). Keep the count and the order matching the cards.

## 6. Check and deliver

Run [`validation.md`](validation.md) and the composer's validation; fix hard failures in at most two rounds. Deliver under `.hyper/instagram-card-maker/<slug>/`: `index.html`, `cards/NN.png`, `caption.txt`, `alt-text.json`, `sources.md`, and `manifest.json`.

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own procedure; the platform facts it points at live in [`../references/platform-specs.md`](../references/platform-specs.md).
