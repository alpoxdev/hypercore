# Validation

> Korean version: [`validation.ko.md`](validation.ko.md)

Read before delivery and whenever this package changes. This file owns the pre-delivery checklist and the failure handling.

## 1. Pre-delivery checklist

- [ ] Intake answered; delivery matches the chosen format; the format is stated and is 4:5 by default unless the user asked otherwise.
- [ ] Research ran when the brief lacked facts: sourced facts with URL and date, a reader question per card, no fabricated experience.
- [ ] Card count is 2–20.
- [ ] Every card keeps the title and hook at the left-bottom; photo and text are separate layers; a supplied logo is unchanged.
- [ ] Only the photo background is blurred, and subtly; the text sits on the opaque `#151515` panel.
- [ ] `window.cardStudio.render` resolved; `#status[data-error]` is not `true`.
- [ ] Real PNGs exist at the chosen size, one per card, in posting order.
- [ ] `caption.txt` is in posting order; `alt-text.json` matches the card count and order.
- [ ] Every photo's provenance is recorded; every generated photo is labeled an illustration.
- [ ] `index.html` embeds all images and any font data as data URIs, with no remote script and no network dependency.
- [ ] The Korean glyphs were inspected when the system fallback was used.
- [ ] No other skill is named, required, or read; no publish, schedule, or upload path is used.

## 2. Composer failure handling

The composer throws on the failures in [`../references/output-contract.md`](../references/output-contract.md) §4 and sets `#status[data-error="true"]`.

- On a schema or dimension error, fix the input document.
- On a missing or broken image, fix the `photo` value.
- On an overflow error, split the card or shorten the text; never shrink the font.
- On a `fontData` load error, supply valid font data or drop `fontData` to use the system fallback.
- Editing the JSON after a render clears the output; render again before exporting.

## 3. Loop and stop

Compose → run this checklist and the composer's validation → fix hard failures. At most two rounds. After two rounds, deliver with the remaining items named. Stop and name the missing sources when a required fact cannot be grounded. Never publish, schedule, or upload.

## 4. Package-change checklist

Only when this package changes:

- [ ] KO/EN parity holds for every Markdown file.
- [ ] The repository corpus validator passes for this package: run it with `--root skills --only instagram-card-maker --json`.
- [ ] The package authoring validator passes with `--require-self-containment` and this package's eval file passed as `--evals`; it reports no error for this package.
- [ ] `bun run --cwd scripts verify` passes.
- [ ] `README.md`'s skill count and catalog row are updated because this change adds a skill.

## Sources

> No external sources; content checked 2026-10-15.

This file states this package's own checklist; the platform and contrast facts it points at live in [`../references/platform-specs.md`](../references/platform-specs.md).
