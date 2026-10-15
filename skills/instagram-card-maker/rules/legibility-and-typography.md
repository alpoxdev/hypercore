# Legibility and Typography

> Korean version: [`legibility-and-typography.ko.md`](legibility-and-typography.ko.md)

Read before composing cards. This file owns the Korean font strategy, the contrast check, the wrapping rule, and the overflow rule.

## 1. Font strategy

The composer's stack is `Pretendard, "Noto Sans KR", "Apple SD Gothic Neo", "Malgun Gothic", sans-serif`.

- No font binary ships with this package. The composer uses the system Korean sans fallback unless the environment already provides font data.
- When font data is available, pass it as the `fontData` data URI. A `fontData` face that fails to load is an error, not a silent fallback.
- Pretendard is OFL-licensed (<https://github.com/orioncactus/pretendard/blob/main/LICENSE>); if you embed it, keep that license with the distribution. Do not ship a binary from this package.

## 2. Glyph inspection

When the run uses the system fallback, inspect the exported Korean directly before delivery.

- Confirm the exported PNG shows the intended Hangul with no missing-glyph box or substituted look.
- If a glyph is missing, supply font data or choose a fallback the environment renders.
- Never export while the Korean is unverified.

## 3. Contrast

Keep the text on the opaque `#151515` panel with white text so contrast does not depend on the photo. The W3C 4.5:1 text / 3:1 large-text minimum is the design benchmark (see [`../references/platform-specs.md`](../references/platform-specs.md) §3); the panel meets it structurally.

## 4. Wrapping

The composer measures each character with the canvas `measureText` and wraps at the card's inner width (card width minus two 72 px margins).

- A `\n` in the title or body forces a line break; use it for a deliberate break.
- Wrap happens on measured width, not on a character count.

## 5. Overflow

The composer fails rather than shrink or truncate.

- Title over 3 lines, body over 5 lines, or a text panel taller than 69% of the card is an error.
- The fix is to split the card or shorten the text; never shrink the font to fit.

## 6. Loading gates

Export requires that fonts and photos are ready. `render` awaits `document.fonts.load` for the title and body sizes and `document.fonts.ready`, and awaits every photo with a 10-second timeout. A font or photo that fails blocks the export.

## Sources

> No external sources; content checked 2026-10-15.

The contrast benchmark and its source live in [`../references/platform-specs.md`](../references/platform-specs.md) §3.
