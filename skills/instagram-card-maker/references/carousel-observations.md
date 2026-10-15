# Observed Carousel Patterns

> Korean version: [`carousel-observations.ko.md`](carousel-observations.ko.md)

Read when choosing scenes and body layouts or when someone asks whether a design rule is supported by public reaction. These are bounded observations, not a ranking model or a promise of engagement.

## 1. Observed sample

Public posts were opened in a browser on 2026-10-15. Financial examples were traversed by a dedicated observer; the lead inspected selected cards and four reaction-bar captures. Educational covers/body cards and reaction bars were additionally read by the lead. Dates below preserve the supplied UTC `time` attribute rather than guessing a local date.

| Account / post | UTC date | Cards reported | Public reaction snapshot | Observed composition |
|---|---|---|---|---|
| [toss.im / dining event](https://www.instagram.com/toss.im/p/Dc4u2Dyn0zv/) | 2026-09-05 | 5 | likes `1천` (rounded), comments987 | Full-photo scenes, bottom-centered cover, participation instructions |
| [toss.im / financial education](https://www.instagram.com/toss.im/p/DdBUM4nHyel/) | 2026-09-08 | 10 | likes304, comments87 | Photo cover; numbered upper-left title, central visual, lower caption |
| [toss.im / mentoring](https://www.instagram.com/toss.im/p/Dddo25yn0O3/) | 2026-09-19 | 9 | likes321, comments2 | Portraits, event photos and quotation cards |
| [tossbank.official / K-pass](https://www.instagram.com/tossbank.official/p/DddUwHtmhFl/) | 2026-09-19 | 10 | likes238, comments3 | Stable upper-left title with changing illustrations, tables and app views |
| [tossbank.official / business account](https://www.instagram.com/tossbank.official/p/DdYikPsmsyT/) | 2026-09-17 | 9 | likes164, comments0 | Related app views and 3D illustrations; consistent title position |
| [kakaopay.official / security](https://www.instagram.com/kakaopay.official/p/DcPsxWxkzex/) | 2026-08-20 | 5 | likes857, comments31 | Message/notification mockups and explanatory labels |
| [kakaopay.official / music collaboration](https://www.instagram.com/kakaopay.official/p/DcLo7bRk2cc/) | 2026-08-18 | 12 | likes818, comments1 | Different event photos; upper brand lockup. Inspected body cards6/11 have no headline |
| [tededucation / Q&A](https://www.instagram.com/tededucation/p/DecJiSiEcfd/) | 2026-10-13 | 6 | likes85, reposts3; numeric comment count not displayed | Centered cover, repeated question/answer blocks |
| [tededucation / books](https://www.instagram.com/tededucation/p/DeMrRYZkWp3/) | 2026-10-07 | 12 | likes `4.1천` (rounded), comments26, reposts301 | Upper title, changing work image and lower quotation |

This is nine examples from four accounts, not a representative sample. Counts can change after observation. The observer and the lead reading the same screenshot are not independent sources.

## 2. Adopted decisions and counterexamples

- **Plan the visual job per card.** Financial explanations change among tables, comparisons and interface views; event stories change photographic scenes. Choose `scene` and `visualType` from the information role instead of repeating one background by default.
- **Separate scene variation from layout variation.** Q&A and list cards can keep a consistent body template. A scene change does not require random text alignment. The music example also contains image-only body cards, not a title on every slide. This composer still requires title/body text; it does not implement image-only cards.
- **Cover alignment is a preference.** Centered and left-aligned covers both occur. This package keeps the user's bottom-left cover, not a supposed Instagram requirement.
- **Do not import incompatible surfaces.** Some observed cards use opaque panels or small-print legal sheets. Those observations do not override this package's full-bleed image, translucent scrim, readable text and overflow checks.

## 3. Two within-account comparisons

Toss dining-event comments987 versus financial-education comments87 cannot identify a layout effect: the event caption requires participants to comment with companions and party size. Topics and posting dates also differ. Keep the likes display `1천` as rounded; it is neither an exact1,000 nor a proven lower bound.

KakaoPay security likes857/comments31 versus music likes818/comments1 does not support a claim that photography always wins. It also does not prove diagrams win: topic, collaboration, age and exposure are uncontrolled.

## 4. Metric and causal limits

- Read numbers beside their actual reaction icons. In TED Q&A, `3` belongs to reposts, not comments. Do not label an unlabeled number from a page-text dump.
- Metadata/snippet counts differed from the visible reaction bar in several cases. Preserve both when investigating disagreement, use the actual visible bar for the snapshot, and do not invent a cache-update explanation.
- Preserve UTC attributes and displayed dates separately. Public comments also contain `time` elements; do not mistake a comment timestamp for the post date.
- Save, share and reach totals were not publicly observed. Do not substitute reposts for shares or infer missing totals.
- Rounded followers are not an exact denominator. Public reactions cannot isolate the effect of alignment, photography, slide count or color.

## Sources

> External sources checked 2026-10-15.

The primary URLs in the table were checked on 2026-10-15. This reference records visual observations and the limits of those observations; it makes no medical, financial-product or platform-policy claims from the cards' subject matter.
