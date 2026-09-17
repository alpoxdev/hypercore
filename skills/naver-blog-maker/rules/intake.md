# Intake Questions

> Korean version: [`intake.ko.md`](intake.ko.md)

**Purpose**: The one message this skill sends before any research or drafting. It collects the five facts that change the post's shape and cannot be researched; everything else comes from [`topic-research.md`](topic-research.md). Ask once, in a single message, then proceed with whatever was answered.

## 1. When to ask

Before research, ask unanswered intake items in one message and await the reply. Do not repeat supplied or explicitly waived items. Optional omissions do not block work; use the defaults below.

## 2. The message

Use the following five items, asking only unanswered ones in one Korean list.

```
글을 쓰기 전에 다섯 가지만 확인할게요.

1. 네이버 블로그 URL (예: https://blog.naver.com/아이디) — 블로그의 기존 주제 레인과 말투를 맞추려고 봅니다.
2. 글 종류 — 정보형(경험·비교·가이드) / 전환형(업체·제품 문의나 방문이 목표) 중 하나.
3. (선택) 업체명 또는 홍보할 제품 — 아직 정하지 않았다면 비워도 됩니다.
4. (선택) 업체·제품을 볼 수 있는 URL이나 자료 — 홈페이지, 스마트스토어, 카탈로그, 가격표 등.
5. 글 양식 — plain(서식 없는 텍스트) / rich(서식 있는 HTML 본문) 중 하나. rich는 렌더링된 내용을 HTML 클립보드로 복사하며 제목·태그는 따로 입력합니다. 선택하지 않으면 plain으로 진행합니다.
```

## 3. What each answer feeds

| Item | Required | Feeds | If missing |
|---|---|---|---|
| 1. Blog URL | yes | topic lane check (`topic-research.md` §1), register match (read 3 recent posts as a visitor: ending style, image density, ornament habit) | lane becomes `[확인 필요]`; register defaults to the mode's row in `human-prose.md` §4 |
| 2. Mode | yes | `post-workflow.md` §0 | infer from item 3: a brand named means 전환형; state the inference in the mode line |
| 3. Brand / product | optional in both modes | brand facts block, CTA target, disclosure sentence | 전환형 without it: write the post with `[확인 필요: 업체명]` in the brand block and the CTA; 정보형: ignore |
| 4. Brand URL / material | optional | verbatim 가치입증 facts (read as a visitor; quote, never paraphrase numbers) | brand facts limited to what the user typed; every other brand claim is a slot |
| 5. Format | yes | delivery shape in `post-workflow.md` §5 and [`../references/format-options.md`](../references/format-options.md) | plain |

Reading the blog URL or brand URL is a visitor read of public pages only (no login, no scraping beyond the pages needed). If a page cannot be fetched, say so in the publish note and continue.

## 4. After the answer

- Restate the five answers in one line (`블로그 / 모드 / 업체 / 자료 / 양식`) at the top of the reply, then run `post-workflow.md` from §0 without further questions.
- A brief that already contains all five (for example a returning user pasting the line above) skips the message entirely.
- Do not ask about keywords, audience, length, tone, or images: research and the mode row decide those.
