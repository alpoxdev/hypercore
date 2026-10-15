# inblog Format

> Korean version: [`inblog-format.ko.md`](inblog-format.ko.md)

Read only when the resolved platform is `inblog`, before delivery, from [`format-options.md`](format-options.md). This file carries the inblog layout, metadata, and editor facts. It never describes Naver behavior: the Naver editor observations stay in [`format-options.md`](format-options.md) §2, and the Naver ranking references are not read for an inblog post.

## 1. Delivery

- Body HTML is the default and plain text is used only on an explicit request, the same as Naver ([`format-options.md`](format-options.md) §1).
- The confirmed inblog route for the default HTML is the editor's **HTML embed block**: type `/` in the body, choose the HTML embed block, and paste the HTML. Per the official docs, content added this way **stays an HTML block and is not automatically converted into inblog's normal editor blocks** (headings, paragraphs), so it cannot be edited block by block while it stays an HTML block.
- Editing the same content as **native editor blocks** is a separate, optional path: convert the HTML to Markdown first (an online HTML-to-Markdown converter works), then paste; the pasted Markdown becomes editable inblog blocks, heading by heading and paragraph by paragraph. This is an auxiliary route for a user who wants native blocks — it is not the default and it is not the styled-copy path.
- Copying the **rendered** body as rich `text/html` and pasting it into inblog is **not verified** in this package. Do not promise that CSS, tables, or images survive that paste. Only the documented HTML embed route is a confirmed path.

## 2. Body layout

inblog is not Naver; the Naver rhythm contract does not apply.

- Body paragraphs are **left-aligned natural paragraphs**. Do not force 12-25-character line breaks and do not center-align the body.
- Subheadings are `h2` and `h3` (the editor's heading blocks cover H2-H4).
- The `Title` field is the H1, so the body carries **no duplicate H1**: start at H2 and never repeat the title as a heading.

## 3. Metadata separate from the body

Keep every metadata field out of the body HTML.

| Field | Where it lives | Note |
|---|---|---|
| Title | The `Title` field | Functions as the H1; the visible heading |
| Description | The `Description` field | Shown under the title on the post |
| Meta title (optional) | The gear button on the title field | Sets the `<title>`; empty falls back to the post title |
| Meta description (optional) | The gear button on the description field | Empty falls back to the post description |
| Slug | The editor's top area | A human-readable URL slug; generated from the title by default, customizable |
| Category | The `+Categories` button | Organizes the post |

The outer `Description` box is the reader-facing description even though its placeholder reads "Write meta description..."; the separate meta description is the inner box revealed by the gear. Do not insert an unsupported metadata field into the body.

An inblog post has **no hashtag requirement and no editor topic lane**. Do not carry Naver's hashtag rule, its ranking or algorithm references, its DataLab demand check, or its editor 주제 selection onto inblog. For an inblog post, topic research is generic public research plus the topic's own primary sources.

## 4. Documented editor blocks (not a clipboard guarantee)

The official docs list these editor blocks: headings (H2, H3, H4), tables, lists, quotes, code snippets, dividers, callouts, emojis, bookmarks, images (max 10 MB; JPG, PNG, GIF, WebP; **SVG unsupported**), HTML embeds, and form embeds (HubSpot, Tally, Google Forms, Typeform). Slash commands insert a block, and an August 2026 update adds keyboard navigation of the slash menu, per-language command search, `Tab` movement between table cells, and formatting several selected cells at once.

These are **documented editor capabilities, not the results of a clipboard-paste test**. A supported block type does not mean that external HTML pastes into it with its styling intact. Treat the list as what the editor can hold, not as what survives a paste from outside.

## 5. Sources

> External sources; checked 2026-10-15.

| Claim | Source |
|---|---|
| §1 HTML embed stays an HTML block and is not auto-converted; Markdown paste becomes editable blocks; image max 10 MB and SVG unsupported; the editor block list; CTA configuration | <https://inblog.ai/docs/write-contents/creating-content> (official; page updated 2026-09-08) |
| §2 the Title field functions as an H1 | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (official) |
| §3 separate Description and optional Meta title / Meta description; slug; category | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (official) |
| §4 table cell movement and multi-cell formatting; slash-command keyboard navigation | <https://inblog.io/changelog/faster-tables-and-slash-commands> (official; dated 2026-08-21) |

Not verified: signing in to inblog and pasting rendered HTML. CSS, merged cells, images, and special-block preservation across that paste are therefore unclaimed.
