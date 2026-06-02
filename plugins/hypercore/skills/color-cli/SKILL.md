---
name: color-cli
description: "[Hyper] Convert colors between hex, rgb, and oklch using @kood/color-cli. Use when the user asks to convert colors, transform CSS file colors, or needs accurate oklch values. Trigger phrases — \"color convert\", \"hex to oklch\", \"oklch to hex\", \"rgb to oklch\", \"CSS color conversion\", \"color conversion\", \"tell me the oklch value\"."
compatibility: Requires Bash tool. @kood/color-cli must be installed globally (`npm i -g @kood/color-cli`).
---

# Color CLI

> Convert colors accurately between hex, rgb, and oklch using `@kood/color-cli`.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

AI models often produce incorrect oklch conversions due to matrix precision errors, missing gamut mapping, and degree/radian confusion. This skill delegates color conversion to `@kood/color-cli` (powered by culori) for CSS Color Level 4 compliant results.

<request_routing>

## Positive triggers

- "Convert #ff0000 to oklch"
- "What's the oklch value of rgb(0, 128, 255)?"
- "Convert all colors in styles.css to oklch"
- "hex to rgb", "oklch to hex", "convert this color"
- "Normalize the colors in this CSS file to hex"

## Out-of-scope

- Color palette generation or design suggestions — use a design skill instead.
- Color theory explanations — answer directly without this skill.
- Creating CSS from scratch — use an implementation skill instead.

## Boundary

- "What color is oklch(0.7 0.25 140)?" → Use this skill to get the hex/rgb equivalent.
- "Pick a good color for a button" → Do not use this skill; this is a design question.

</request_routing>

<prerequisites>

Install `@kood/color-cli` globally if not already available:

```bash
npm i -g @kood/color-cli
```

Verify installation:

```bash
color --help
```

If `color` command is not found, install it first before proceeding.

</prerequisites>

<workflow>

## Single Color Conversion

When the user asks to convert a specific color value:

```bash
color "<value>"
```

Examples:

```bash
color "#ff0000"
color "oklch(0.7 0.25 140)"
color "rgb(255, 0, 0)"
color "hsl(0, 100%, 50%)"
```

For JSON output (useful for programmatic use):

```bash
color --json "#ff0000"
```

For multiple colors at once:

```bash
color "#e63946" "oklch(0.7 0.25 140)" "rgb(0, 128, 255)"
```

## CSS File Color Conversion

When the user wants to convert all colors in a CSS file to a specific format:

**Preview first (dry run):**

```bash
color css <file> --to <format> --dry-run
```

**Apply changes (in-place):**

```bash
color css <file> --to <format>
```

Supported target formats: `hex`, `rgb`, `oklch`.

Examples:

```bash
# Preview oklch conversion
color css styles.css --to oklch --dry-run

# Apply hex conversion
color css src/global.css --to hex

# Convert to rgb
color css theme.css --to rgb
```

### CSS conversion behavior

- Automatically detects hex, rgb, rgba, oklch patterns in the file
- Skips colors already in the target format
- Preserves alpha values (e.g., `rgba(255,0,0,0.5)` → `oklch(0.628 0.258 29.23 / 0.5)`)
- Ignores colors inside CSS comments (`/* ... */`)
- Applies CSS Color Level 4 gamut mapping for out-of-gamut oklch values

</workflow>

<output_interpretation>

## Single color output

```
HEX:   #ff0000
RGB:   rgb(255, 0, 0)
OKLCH: oklch(0.6280 0.2577 29.23)
```

## Gamut mapping warning

When an oklch value is outside the sRGB gamut, the tool applies chroma-reduction and shows:

```
⚠ Color was outside sRGB gamut — CSS Color Level 4 chroma-reduction applied.
```

This means the original oklch chroma was reduced to fit sRGB while preserving lightness and hue.

## CSS conversion summary

```
styles.css: 12 colors found, 8 converted, 4 skipped
```

- **converted**: colors that were changed to the target format
- **skipped**: colors already in the target format

</output_interpretation>

<guidelines>

- Always use `--dry-run` first when converting CSS files, then apply if the user confirms.
- When the user provides an oklch value, always run the conversion rather than computing manually — AI models frequently produce incorrect oklch ↔ hex mappings.
- Report the full output (hex, rgb, oklch) to the user so they can pick the format they need.
- For CSS file operations, show the summary (converted/skipped counts) to the user.

</guidelines>
