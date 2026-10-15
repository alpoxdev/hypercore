# Platform Specs

> Korean version: [`platform-specs.ko.md`](platform-specs.ko.md)

Read before choosing a format. This file owns the image specs, the format presets, and the contrast benchmark. It separates the app path from the API path, and it separates a platform rule from this package's design default.

## 1. App vs API

Instagram documents the in-app post path and the publishing API separately, and the two differ. This skill composes images for the app path and does not publish.

| Item | App (in-app post) | API (content publishing) |
|---|---|---|
| Photo width | 320–1080 px | (API-specific) |
| Aspect ratio | 1.91:1 to 3:4 | 4:5 to 1.91:1 |
| Format | (app handles the upload) | JPEG |
| Size cap | (not stated for the app) | 8 MB |
| Carousel items | up to 20 media, one caption per carousel | up to 10 |

Do not treat a value from one column as if it governed the other. The API limits are not the app's limits and the app's limits are not the API's.

## 2. Format presets

| Preset | Size | Ratio | When |
|---|---|---|---|
| Default | 1080×1350 | 4:5 | The package default; a conservative, common choice. |
| Tall (app-only) | 1080×1440 | 3:4 | Only when the user asks or the evidence supports it; the app path accepts 3:4, the API path does not. |
| Square | 1080×1080 | 1:1 | Only when the user asks or the evidence supports it. |

Never call 4:5 the only Instagram format. It is this package's default, not a platform rule.

## 3. Contrast benchmark

This package uses the W3C Web Content Accessibility Guidelines contrast minimum (SC 1.4.3) as a design benchmark: a 4.5:1 contrast ratio for text and images of text, and 3:1 for large text.

- This is a web accessibility standard adopted here as a design target. It is not an Instagram rule and Instagram does not enforce it.
- The composer meets the target structurally: the text is white on a translucent black scrim (alpha 0.62) held constant under every text pixel, so contrast does not depend on the photo behind it and the photograph stays visible.

## 4. Typography and layout are defaults

The Korean font family, margins, blur amount, bottom-left cover, content-led body placement, and card count are this package's defaults and the user's preferences. None is a platform mandate. State them as defaults when the user asks for a rule.

## Sources

> External sources checked 2026-10-15.

| Claim | Source |
|---|---|
| App photo width 320–1080 px and aspect ratio 1.91:1 to 3:4 | <https://www.facebook.com/help/instagram/1631821640426723> (observed in a browser 2026-10-15) |
| Up to 20 media and one caption per carousel in the app | <https://www.facebook.com/help/instagram/269314186824048> (observed in a browser 2026-10-15) |
| API photo format JPEG, 8 MB cap, 4:5 to 1.91:1 ratio, up to 10 carousel items | Meta Content Publishing and media reference (second-hand; re-check before relying on it) |
| Contrast minimum 4.5:1 for text, 3:1 for large text | <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html> (observed in a browser 2026-10-15) |
| Pretendard is OFL-licensed | <https://github.com/orioncactus/pretendard/blob/main/LICENSE> |
