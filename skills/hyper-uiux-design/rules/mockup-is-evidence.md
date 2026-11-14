# Mockup Is Evidence

Read this rule before reviewing an image and before writing the handoff. A generated mockup is a picture of an intention. This rule decides what the picture may be trusted for, what must be replaced in code, how Korean text is handled, and which accessibility checks are done where.

## Contents

1. What the Mockup Proves
2. Text, Numbers, and Marks in the Image
3. Korean Text Rendering
4. Accessibility Checks
5. What the Handoff Carries

## 1. What the Mockup Proves

| The image is evidence for | The image is not evidence for |
|---|---|
| Which regions exist and their order | Exact pixel sizes, spacing values, or font metrics |
| What is emphasized and what the primary action is | Real copy, real data, or real brand marks |
| Which components appear and how they group | Behavior, states, motion, or responsiveness |
| The overall density and tone under the tokens | Contrast ratios or touch target sizes |

Label each review item with one of three labels and never upgrade one by wording:

- `seen`: observed in the returned image.
- `computed`: derived from token values, not from the picture.
- `not checkable in an image`: the picture cannot show it; it becomes a handoff requirement.

## 2. Text, Numbers, and Marks in the Image

- Every string in the image is a placeholder until the user's copy replaces it in code, including strings that rendered correctly.
- Every number, chart value, date, price, name, and avatar in the image is invented and is listed as sample data.
- Every logo, app icon, illustration, and photo in the image is a stand-in. The project's own assets, or assets the user has the right to use, replace them in code.
- Icons in the image show where an icon goes and roughly what it means. The implementation uses the project's icon set.
- The handoff lists these replacements in a table, so nothing from the image is transcribed as content.

## 3. Korean Text Rendering

Generated images do not render Hangul reliably, and a wrong syllable can look right at a glance. Treat it as a known limit, not as a defect to fight.

Before the call:

- Render only the strings that carry the hierarchy: the screen title, the primary action, field and tab labels. Keep each one short.
- Use the user's real copy for those strings when it exists. When it does not, write plain working copy and mark it `working copy` in the notes.
- Describe longer body text as short neutral lines of text-colored bars rather than as sentences, so the image does not invent paragraphs.
- Give each rendered string once, in quotes, with its role and its place on the screen, and say how many times it appears.

After the call:

- Read each rendered string character by character against the brief. A missing, extra, or malformed syllable is a `fail` for that string.
- On a failure, regenerate with a revised brief: fewer rendered strings first, then shorter ones. Do not patch the image.
- When the cap is reached and a string is still wrong, keep the image for layout, record the string as `not rendered correctly`, and carry the correct string in the handoff copy table. The mockup remains usable because its text was never content.

## 4. Accessibility Checks

Two checks are computed or specified here because a picture cannot prove them.

Contrast, computed from tokens with the WCAG contrast-ratio formula:

| Pair | Minimum |
|---|---|
| Body text on its background | 4.5:1 |
| Large text (at least 18 point, or 14 point bold) on its background | 3:1 |
| Text on a filled button, a badge, or a colored surface | The same as above for its size |

- Compute every text and background pair in both themes before the first brief, and record the ratios in the notes as `computed`.
- Do not sample colors from the returned image; a generated image does not reproduce token values exactly.
- Text placed over a photo or a gradient is specified with a solid or scrim layer behind it, and the pair is computed against that layer.

Touch and pointer targets, written as requirements in the handoff:

| Surface | Requirement |
|---|---|
| Web | At least 24 by 24 CSS px for every pointer target (WCAG 2.2 AA); 44 by 44 CSS px as the goal for primary actions (AAA) |
| iOS and iPadOS | 44 by 44 pt as the default control size |
| Android | A touch target of at least 48 by 48 dp |

Also check in the image, as `seen`:

- State is not carried by color alone: an error, a selection, or a required field has a text, an icon, or a shape as well.
- One primary action per screen, visibly distinct from secondary actions.
- Reading order follows the visual order from top to bottom.

## 5. What the Handoff Carries

The handoff section of the notes is what an implementer receives. It holds:

| Part | Content |
|---|---|
| Contract | Region order, hierarchy, component inventory, and the tokens |
| Not a contract | Pixel values measured off the image, rendered text, numbers, logos, icons, and photos |
| Copy table | Region, the string to use in code, and its status (`user copy`, `working copy`, or `needed from user`) |
| States not shown | Loading, empty, error, disabled, focus, long text, and any state the flow needs |
| Accessibility requirements | The computed contrast pairs and the target sizes for the platform |
| Open questions | Decisions the mockup did not settle, such as responsive behavior between sizes |

The implementer builds from the contract and the project's own components. A mismatch between the picture and the tokens is resolved in favor of the tokens.

## Sources

> Checked 2026-11-15.

| Claim | Source |
|---|---|
| The mockup is evidence and not the product; text, numbers, and logos in the image are replaced in code; Korean rendering limits and contrast and touch-size checks are handled | user instruction, 2026-11-15 (new skill request) |
| Text contrast of at least 4.5:1, large text 3:1, and large text as at least 18 point or 14 point bold | <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html> |
| Pointer targets of at least 24 by 24 CSS pixels (AA) | <https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html> |
| Targets of at least 44 by 44 CSS pixels (AAA) | <https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html> |
| Color is not the only visual means of conveying information | <https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html> |
| 44x44 pt default control size on iOS and iPadOS | <https://developer.apple.com/design/human-interface-guidelines/accessibility> |
| A touch target of at least 48dp by 48dp is recommended on Android | <https://developer.android.com/guide/topics/ui/accessibility/apps> |
| Rendered text is quoted once with its role and place, and a wrong character is fixed by regenerating | this package's image-generation skill contract, restated for screens |

### Evidence grade

`LOCAL` for the evidence table, the three labels, and the Korean rendering procedure; the statement that Hangul rendering is unreliable is this package's working assumption, not a measured rate, and the procedure holds even when a runtime renders it well. The WCAG, Apple, and Android values are `PRIMARY` and were read on the date above.
