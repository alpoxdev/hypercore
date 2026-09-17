# Image Slots and Generation Prompts

> Korean version: [`image-slots.ko.md`](image-slots.ko.md)

**Purpose**: How many images a post carries, where each one sits, which ones the author must shoot and which ones may be AI-generated, and the copy-paste prompt that goes with every generated one. Marker syntax is fixed here; [`topic-research.md`](topic-research.md) §5 decides what each image must prove, and [`../references/image-prompt-templates.md`](../references/image-prompt-templates.md) holds the JSON templates.

## 1. Density (observed default)

Two reference posts the user supplied as the target feel (2026-09, 전환형 B2B, `evidence-digest.md` T4/T10 note) measured 28 images over 1,477자 and 25 images over 1,012자, grouped into 15-16 image blocks each: text runs of 25-250자 (2-4 short centered lines), then an image block, repeated to the end. Blocks mix a single photo, a 2-8 photo collage, and one explanatory diagram at the point where the mechanism is explained.

Defaults derived from that (observed, non-blocking; `naver-ranking-contract.md` folklore rules still apply):

| Post length | Image blocks | Placement rhythm |
|---|---|---|
| ≤ 1,000자 | 8-12 | one block per 80-120자 of body |
| 1,000-2,000자 | 12-18 | one block after every 2-4 line paragraph |
| 2,000-3,000자 | 16-24 | same; never more than 300자 without a block |

Plan a cover and useful visuals per section, including the downside section. Do not add meaningless images to satisfy a count; explain justified lower density in the publish note.

## 2. Marker syntax

Every block is one inline marker at the exact position in the body. Two kinds:

```
[이미지: 무엇을 찍을지 | 캡션]                      ← the author shoots or already has it
[이미지 생성: 무엇을 그릴지 | 캡션 | 프롬프트 #n]     ← AI-generated; JSON prompt #n follows the post block
```

- A collage is one marker naming the shots inside it: `[이미지: 콜라주 3장 — 바닥 물고임 / 천장 얼룩 / 벗겨진 도장면 | 같은 주차장 B2층, 2026년 8월]`.
- Captions state the fact the picture backs, never a label.
- The sentence after a marker may refer to it (`위 단면도처럼…`).

## 3. What may be generated

| Generate (`이미지 생성`) | Never generate (`이미지`) |
|---|---|
| Section-break illustrations of the mechanism (cross-section, flow, before/after schematic) | The product, place, receipt, 견적서, instrument reading, or result the post claims as real |
| Cover art when the post has no real cover photo, labeled as illustration in the caption | Any brand logo, certificate, license, or document |
| Comparison tables rendered as an image, icon rows, checklists | People presented as the author, staff, or customers |
| Mood or concept visuals for abstract sections (risk, timing, cost structure) | Anything a reader would take as photographic evidence of a fact |

A generated image never replaces a proof photo; if the proof photo does not exist, the marker stays `[이미지: …]` and the publish note lists it. Conversion posts require the proof photos their real claims need, not a fixed real-photo percentage. List missing evidence in the publish note.

## 4. Prompt block

After the post block, deliver one block per `이미지 생성` marker, numbered to match `프롬프트 #n`, built from the templates in `../references/image-prompt-templates.md`. The block's opening fence must carry the `json` language tag; a bare, untagged fence is not an acceptable delivery, because a consumer cannot reliably find the block inside a plain fence. Each is a complete brief for tools accepting structured natural-language requests, not a universally compatible API payload: no provider flags, no model names, no placeholders. Rendered Korean text inside the image (labels on a diagram) is written once, exactly as it must appear.

Order of delivery in `post-workflow.md` §5: titles → post block → **prompt blocks** → keyword line → slot list → publish note.

## 5. Register match

When the intake blog URL was readable, count images per post in the 3 most recent posts and pick the closest row in §1; the blog's own habit beats the default. Note the measured number in the publish note.

## 6. Compile a complete visual brief

This section owns the compilation policy. [`../references/image-prompt-templates.md`](../references/image-prompt-templates.md) owns the field descriptions, the 14 section roles, and the 17 template IDs. **§3 outranks every schema and template decision below**: no role or template ever authorizes generating what §3 forbids. This section does not change §7's prompt-only default.

Classify every slot as real material or generated explanation and fix its role and template first (§3, [`topic-research.md`](topic-research.md) §5), then compile in this order:

`use → section_role / template → hierarchy → subject → scene → composition → lighting → color → material_and_rendering → text → series_invariants → must_include / must_exclude → inspection_checks → aspect → caption_note → prompt`

- **One purpose, one reading order.** Give each image one purpose and an explicit first → second → background reading order in `hierarchy`. Describe subject traits, action, environment, viewpoint, scale, crop, depth, and empty space instead of saying “premium” or “beautiful.”
- **Route each property to its own field.** `style` carries medium, drawing language, and line/shape language only. Palette roles (dominant/support/accent, plus the contrast needed for reading) belong in `color`; surface response, edge behaviour, and texture belong in `material_and_rendering`; light direction, softness, shadows, and separation belong in `lighting`. Omit inapplicable fields rather than filling them with placeholders — never `null`, `"N/A"`, `"없음"`, or `"위와 동일"`.
- **Preserve requested lettering exactly.** Each `text[].string` appears exactly once inside `text[]` — never listed twice — and `prompt` carries every one of them byte-identical so the paste-ready text renders exactly those labels; descriptive prose in `prompt` may reuse the same words, but `prompt` must not introduce a label `text[]` does not carry. Specify placement, reading order, priority, size, contrast, and clearance. Never translate, abbreviate, or correct a string. Inside `text[]` the same label is never listed twice; inside `prompt` every string must appear verbatim and the surrounding prose may reuse its words freely, but `prompt` must never carry a rendered label that `text[]` does not define. A spelling instruction is not proof that the generated lettering is correct.
- **Series invariants only for a real series.** When two or more images are intended as ONE visual series, repeat that series' invariants (palette roles, drawing style, line weight, typography, lighting and material behaviour) identically in every object of the series. Independent images covering different roles omit `series_invariants` entirely. Each object must work independently when copied; never say “same as above.” Vary only the image-specific subject or composition.
- **State the reference boundary.** For a supplied reference, distinguish inspiration from an editing source in `reference.role`. An editing prompt must identify the source, the preserved elements, and the allowed changes; never invent missing identity or preservation requirements. Keep unresolved source requirements outside the ready-to-use prompt.
- **Separate a blocking gap from a reversible assumption.** If the subject, the exact rendered text, or an edit's preserve/change boundary is missing, do not emit a finished prompt for that image — ask, or leave the slot open. A reversible presentation choice (crop, palette pressure, empty space) is decided by the executor and recorded in `assumptions`. A fact the post itself is missing stays a `[확인 필요]` slot.
- **Record what to inspect.** `inspection_checks` holds 3-6 observable criteria that can be checked against a returned artifact: reading order, subject facts, exact lettering, palette roles, material, and series consistency.
- **Keep the compilation boundary.** Tool names, model names, API parameters, provider flags, file paths, status reports, and capability claims stay outside the visual brief. The JSON here is a portable descriptive brief, not a universal image API schema. `prompt` is derived only from the structured fields and adds no fact.

## 7. Prompt delivery is not image generation

This workflow delivers prompts, not generated images. Do not invoke an image service merely because a marker exists. If generation is separately requested, first check the currently available generate/edit action and authorization; a reference URL grants neither. Generation cannot substitute for a source-preserving edit, and the original must remain unchanged.

Claim an image exists only after an actual returned artifact is observed. Before claiming visual success, inspect hierarchy, subject facts, composition, light, palette, material, exact lettering, and series consistency. If inspection is unavailable, state that those properties remain unverified. Do not infer current capability from a provider name or an earlier run.

Observed references: [leak post](https://m.blog.naver.com/greenbirdiebest/224406174599), [forklift post](https://m.blog.naver.com/greenbirdiebest/224403853347). Counts describe DOM image elements and body text, not verified unique photos or ranking effects.
