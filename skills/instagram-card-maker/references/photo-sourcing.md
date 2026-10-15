# Photo Sourcing

> Korean version: [`photo-sourcing.ko.md`](photo-sourcing.ko.md)

Read while sourcing photos. This file owns photo provenance, generated-photo labeling, and logo handling.

## 1. Provenance

Every card's photo carries a `photoSource` string and a `generated` flag. Record both in `manifest.json` and `sources.md`.

- A supplied photo: name where it came from and the permission or license, in `photoSource`.
- A generated photo: `generated: true`, and the same flag surfaces in `manifest.json`.
- A photo whose source or permission is unknown is a slot, not a card.

## 2. Generated photos

A generated photo is an illustration.

- Label it as generated in `photoSource` and in the caption where it appears.
- Never present it as a real site, product, place, receipt, certificate, instrument reading, result, or before/after photo.
- Do not use a generated image as proof of a real event.

## 3. Logo

A supplied logo is placed exactly as supplied.

- Never redraw, recolor, crop into, stretch, or restyle it.
- Pass it as the `logo` data URI; the composer draws it at its original aspect ratio.
- Do not blur it; only the photo background is blurred.

## 4. Data URI rule

The composer accepts a photo, a logo, or font data only as a `data:` URI of the matching type. Embed the bytes; do not pass a remote URL. This keeps `index.html` self-contained with no network dependency.

## 5. When no photo exists

When a card needs a photo and an image-generation capability is available, compile a concrete scene brief and invoke it; do not stop at a prompt. Keep the series' lighting, palette, and subject consistent while varying each card's scene to support its role. Ask for no lettering or logos in the generated background; compose the exact Korean text and supplied logo afterward. Inspect every generated file, record its provenance, and convert its actual bytes into the `photo` data URI.

If a card needs a photo that does not exist and the environment exposes no image tool, leave the photo as a slot and say so. Never deliver a gradient-only placeholder as if it were the photo, and never claim a photo was generated when it was not.

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own sourcing and labeling rules.
