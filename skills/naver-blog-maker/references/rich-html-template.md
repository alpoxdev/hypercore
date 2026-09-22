# Rich HTML Assembly

> Korean version: [`rich-html-template.ko.md`](rich-html-template.ko.md)

Read for every rich deliverable. Use [`../assets/rich-post.html`](../assets/rich-post.html) as the output shell and [`../assets/rich-blocks.html`](../assets/rich-blocks.html) as the block library. Both are dependency-free HTML; no build, external CSS, or image service is required.

## 1. Assemble the file

1. Copy the shell to the requested output location as a new `.html` file; never overwrite the supplied example or the skill assets.
2. Fill `#post-title`, `#post-category`, and `#post-tags` with escaped text. These are separate editor fields, not body content.
3. Replace only `#sample`'s children with the finished post. Copy the **contents** of the appropriate `template` in the block library; do not insert `template` wrappers, demo text, or unused examples.
4. Keep all copied styles inline. Table cells need their own border and padding; a class backed only by the page stylesheet will not travel with body-only HTML.
5. Use a real supplied/verified HTTPS URL for images and links. Without an image URL, use a real/generated image marker instead of an empty `img`, a demonstration URL, or Base64. Put generated-image JSON and publishing notes in `#author-notes`, outside `#sample`.
6. Retain the shell buttons and script. The body must contain no scripts, event handlers, or executable URLs. The trusted copy script belongs outside the body and is never selected for copying.

## 2. Block selection

| Template ID | Purpose |
|---|---|
| `paragraph` | Rhythm paragraphs: short explicit `br` line breaks, center alignment, `line-height:1.8` |
| `spacer` | Blank-paragraph spacing between text blocks (the only spacing mechanism that survives paste) |
| `highlight-box` | Emphasis box (`padding` + background + left border); pastes as a native one-cell table component |
| `headings` | `h2` / `h3` subheadings; not the Naver title field |
| `inline-styles` | Bold, italic, underline, text/background color, font size |
| `alignment` | Left, center, right paragraphs |
| `quote-divider` | Native-compatible quote and divider markup |
| `lists` | Ordered or unordered lists |
| `link` | A normal link with a meaningful destination label |
| `table` | Basic table with inline cell borders/styles |
| `merged-table` | Valid two-column `colspan` / `rowspan` example |
| `image` | HTTPS photo, dimensions, centered caption |
| `image-slot` | Missing real material |
| `generated-image-slot` | Illustration placeholder paired with a JSON prompt |

Strike-through and the Naver source-code component are not guaranteed even by the supplied sample. Do not add them to the default library as working features. Emphasis boxes are handled by the `highlight-box` block (converts to a native one-cell table component, verified in the editor); paragraph spacing is handled by the `spacer` block.

## 3. Copy contract

The user opens the completed HTML in a browser and clicks **서식 콘텐츠 복사**. In the click handler, `Range.selectNodeContents(sampleEl)` selects only the rendered body, then `document.execCommand('copy')` requests native formatted copying, matching the supplied working sample. Do not replace this with `writeText(innerHTML)`; that copies source text.

The legacy copy API can be blocked by a browser or sandbox. Report success only when it returns true. On false or exception, keep the body selected and show the manual Ctrl+C / ⌘C instruction. Never claim a failed copy succeeded. The optional **HTML 소스 복사** button is explicitly source-only.

If a ChatGPT preview blocks scripts, provide the completed downloadable HTML and instruct the user to open it in a browser. If file delivery is unavailable, return the complete HTML document for saving as `.html`; disclose that a code-fence copy button is not rich copying. Do not silently downgrade a rich request to a plain draft.

## 4. Verify the deliverable

- Open the file, inspect desktop and narrow layouts, and check the body for demo text, unresolved URLs, overflow, and valid table spans.
- Check the body rhythm: no line wraps into a stair-stepped shape, a visible gap between every two consecutive text blocks, `line-height:1.8` inline on body paragraphs, and a blank-paragraph spacer (never `margin`) between blocks.
- Click the rich button and check that only `#sample` is selected, no title/tags/controls/prompts enter the selection, and the status matches the actual copy result.
- Paste into a disposable local editable region to inspect preserved `strong`, links, and table spans when browser input permits. This verifies local clipboard behavior, not Naver's conversion.
- Check the blocked-copy branch separately and ensure the manual instruction appears.
- Naver paste remains a user check; no login, upload, or publication is part of assembling this template.

Maintenance: rich-copy handler contracts (selection scope, copy API, honest status, source-button separation) are regression cases in [`../assets/evals/naver-blog-maker-cases.jsonl`](../assets/evals/naver-blog-maker-cases.jsonl) — an agent statically re-judges the shell against them after any shell change, and the browser clipboard test below stays the live check. This verification needs no executable test file, so the package runs in file-execution-free runtimes (ChatGPT web) and coding agents alike.

## Sources

> No external sources; content checked 2026-09-21.

The paste-behavior claims are this repository's own editor-session measurements, recorded in [`../rules/post-workflow.md`](../rules/post-workflow.md) §3. The copy-handler contract is verified against the shell itself, [`../assets/rich-post.html`](../assets/rich-post.html), with the regression cases in [`../assets/evals/naver-blog-maker-cases.jsonl`](../assets/evals/naver-blog-maker-cases.jsonl).
