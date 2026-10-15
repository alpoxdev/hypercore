# Rich HTML Assembly

> Korean version: [`rich-html-template.ko.md`](rich-html-template.ko.md)

Read for every rich deliverable. Use [`../assets/rich-post.html`](../assets/rich-post.html) as the output shell and [`../assets/rich-blocks.html`](../assets/rich-blocks.html) as the block library. Both are dependency-free HTML; no build, external CSS, or image service is required.

## 1. Assemble the file

1. Copy the shell to the requested output location as a new `.html` file; never overwrite the supplied example or the skill assets.
2. Set the platform on the shell with `data-platform` on `<body>`: `naver` (the shell default) or `inblog`. The shell shows the matching metadata fields and the matching paste note; the switch is pure CSS with no library.
3. Fill the metadata fields for that platform with escaped text. These are separate editor fields, never body content, and they stay outside `#sample`.
   - Naver: `#post-title`, `#post-category`, `#post-tags`.
   - inblog: `#post-title` (the H1 field), `#post-description`, the optional `#post-meta-title` and `#post-meta-description`, `#post-slug`, `#post-category-inblog`. Do not insert an unsupported metadata field into the body.
4. Replace only `#sample`'s children with the finished post. Copy the **contents** of the appropriate `template` in the block library; do not insert `template` wrappers, demo text, or unused examples.
5. Use the block profile for the platform. Naver uses the center-aligned rhythm blocks. inblog uses `inblog-paragraph` and `inblog-headings`: left-aligned natural paragraphs, `h2`/`h3`, no forced line breaks, and no duplicate H1.
6. Keep all copied styles inline. Table cells need their own border and padding; a class backed only by the page stylesheet will not travel with body-only HTML.
7. Use a real supplied/verified HTTPS URL for images and links. Without an image URL, use a real/generated image marker instead of an empty `img`, a demonstration URL, or Base64. Put generated-image JSON and publishing notes in `#author-notes`, outside `#sample`.
8. Retain the shell buttons and script. The body must contain no scripts, event handlers, or executable URLs. The trusted copy script belongs outside the body and is never selected for copying.

## 2. Block selection

| Template ID | Purpose | Platform |
|---|---|---|
| `paragraph` | Rhythm paragraphs: short explicit `br` line breaks, center alignment, `line-height:1.8` | Naver |
| `spacer` | Blank-paragraph spacing between text blocks (the only spacing mechanism that survives paste) | Naver observation |
| `highlight-box` | Emphasis box (`padding` + background + left border); pastes as a native one-cell table component | Naver observation |
| `headings` | `h2` / `h3` subheadings; not the title field | Naver |
| `alignment` | Left, center, right paragraphs (center is the Naver body default) | Naver |
| `inblog-paragraph` | Left-aligned natural paragraphs, no forced breaks, no center alignment | inblog |
| `inblog-headings` | `h2` / `h3` subheadings; the Title field is the H1, so the body starts at H2 | inblog |
| `inline-styles` | Bold, italic, underline, text/background color, font size | Shared |
| `quote-divider` | Native-compatible quote and divider markup | Shared |
| `lists` | Ordered or unordered lists | Shared |
| `link` | A normal link with a meaningful destination label | Shared |
| `table` | Basic table with inline cell borders/styles | Shared |
| `merged-table` | Valid two-column `colspan` / `rowspan` example | Shared |
| `image` | HTTPS photo, dimensions, centered caption | Shared |
| `image-slot` | Missing real material | Shared |
| `generated-image-slot` | Illustration placeholder paired with a JSON prompt | Shared |

Strike-through and the Naver source-code component are not guaranteed even by the supplied sample. Do not add them to the default library as working features. Emphasis boxes are handled by the `highlight-box` block (converts to a native one-cell table component, verified in the Naver editor); paragraph spacing is handled by the `spacer` block. The Naver center-aligned rhythm and its one-cell-table conversion are Naver editor observations; never force them onto an inblog post.

## 3. Copy contract

The user opens the completed HTML in a browser and clicks **서식 콘텐츠 복사**. In the click handler, `Range.selectNodeContents(sampleEl)` selects only the rendered body, then `document.execCommand('copy')` requests native formatted copying, matching the supplied working sample. Do not replace this with `writeText(innerHTML)`; that copies source text.

The legacy copy API can be blocked by a browser or sandbox. Report success only when it returns true. On false or exception, keep the body selected and show the manual Ctrl+C / ⌘C instruction. Never claim a failed copy succeeded. The optional **HTML 소스 복사** button is explicitly source-only: it uses `navigator.clipboard.writeText(sampleEl.innerHTML.trim())` and never becomes the rich-copy path; report its success and its permission-denied case honestly.

Only `#sample` is copied. The title, metadata, tags, buttons, status, author notes, and image prompts stay outside the selection.

The platform paste note stays separate from the body and is shown by the shell's `data-platform`:

- Naver: enter the title, category, and tags in the editor; paste the body with Ctrl+V / ⌘V. The paste-behavior rows are Naver editor observations ([`format-options.md`](format-options.md) §2).
- inblog: enter the title, description, optional meta fields, slug, and category in the editor. Copying the rendered body as rich `text/html` into inblog is **not verified**. The confirmed route is the editor's HTML embed block (paste the HTML source there); converting the same content into native editor blocks is a separate, optional path (convert to Markdown, then paste). Do not promise that CSS, tables, or images survive a rich paste ([`inblog-format.md`](inblog-format.md)).

If a ChatGPT preview blocks scripts, provide the completed downloadable HTML and instruct the user to open it in a browser. If file delivery is unavailable, return the complete HTML document for saving as `.html`; disclose that a code-fence copy button is not rich copying. Do not silently downgrade a rich request to a plain draft.

## 4. Verify the deliverable

- Open the file, inspect desktop and narrow layouts, and check the body for demo text, unresolved URLs, overflow, and valid table spans.
- Check the platform branch: on `naver` the body is center-aligned with explicit breaks and a blank-paragraph spacer; on `inblog` the body is left-aligned natural paragraphs starting at H2, with no forced breaks and no duplicate H1.
- Check the body rhythm: no line wraps into a stair-stepped shape, a visible gap between every two consecutive text blocks, `line-height:1.8` inline on Naver body paragraphs, and a blank-paragraph spacer (never `margin`) between blocks.
- Subscribe a `paste` listener on a separate editable region **before** clicking the rich button, then trigger a real paste (Ctrl+V / ⌘V) and inspect the resulting DOM for `text/html` (`strong`, `a[href]`, list, quote, table spans). Assigning `innerHTML` or synthesizing a `ClipboardEvent` is not paste evidence.
- Click the rich button and check that only `#sample` is selected, no title/tags/controls/prompts enter the selection, and the status matches the actual copy result.
- Check the blocked-copy branch separately: force `execCommand` to return false, then to throw, and confirm each shows the manual instruction and leaves the body selected.
- Check the source button's success and its permission-denied case; confirm it never claims to be rich copying.
- Naver and inblog live-editor paste remain user checks; no login, upload, or publication is part of assembling this template.

Maintenance: rich-copy handler contracts (selection scope, copy API, honest status, source-button separation) are regression cases in [`../assets/evals/blog-maker-cases.jsonl`](../assets/evals/blog-maker-cases.jsonl) — an agent statically re-judges the shell against them after any shell change, and the browser clipboard test in §4 stays the live check. This verification needs no executable test file, so the package runs in file-execution-free runtimes (ChatGPT web) and coding agents alike.

## Sources

> No external sources; content checked 2026-10-15 (the Naver paste rows come from the 2026-09-21 editor sessions).

The paste-behavior claims are this repository's own editor-session measurements, recorded in [`../rules/post-workflow.md`](../rules/post-workflow.md) §3. The copy-handler contract is verified against the shell itself, [`../assets/rich-post.html`](../assets/rich-post.html), with the regression cases in [`../assets/evals/blog-maker-cases.jsonl`](../assets/evals/blog-maker-cases.jsonl). The inblog HTML embed route and the unverified rich-paste limitation come from [`inblog-format.md`](inblog-format.md) and its own source ledger.
