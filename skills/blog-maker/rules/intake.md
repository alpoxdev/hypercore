# Intake Questions

> Korean version: [`intake.ko.md`](intake.ko.md)

**Purpose**: The one message this skill sends before any research or drafting. It collects the six facts that change the post's shape and cannot be researched; everything else comes from [`topic-research.md`](topic-research.md). Ask once, in a single message, then proceed with whatever was answered.

## 1. When to ask

Before research, ask unanswered intake items in one message and await the reply. Do not repeat supplied or explicitly waived items. Optional omissions do not block work; use the defaults below.

## 2. The message

Use the following six items, asking only unanswered ones in one Korean list.

```
글을 쓰기 전에 여섯 가지만 확인할게요.

1. 네이버 블로그 URL (예: https://blog.naver.com/아이디) — 블로그의 기존 주제 레인과 말투를 맞추려고 봅니다.
2. 이 글의 목표 — 유입(검색으로 들어오게) / 신뢰(전문성·경험을 보이게) / 문의·예약·구매 / 재방문 중 가장 중요한 것. 글 유형(체크리스트·사례·FAQ·비교 등)은 검색 의도를 보고 제가 정해서 알려드립니다.
3. (선택) 홍보할 업체·제품명과의 관계 — 자사 / 협찬 / 제휴 / 없음.
4. (선택) 업체·제품을 볼 수 있는 URL이나 자료 — 홈페이지, 스마트스토어, 카탈로그, 가격표 등.
5. 글 양식 — plain(서식 없는 텍스트) / rich(서식 있는 HTML 본문) 중 하나. rich는 렌더링된 내용을 HTML 클립보드로 복사하며 제목·태그는 따로 입력합니다. 선택하지 않으면 plain으로 진행합니다.
6. (선택) 톤앤매너 — 쓰시는 말투를 알려주시면 그 목소리로 글을 씁니다. 짧게 적어주셔도 되고(예: 해요체로 짧게, 농담 없이), 가지고 계신 톤 문서나 기존 글 1~3편을 붙여주셔도 됩니다. 안 주시면 블로그를 보고 글 유형 기본값으로 맞춥니다.
```

## 3. What each answer feeds

| Item | Required | Feeds | If missing |
|---|---|---|---|
| 1. Blog URL | yes | topic lane check (`topic-research.md` §1), register match (read 3 recent posts as a visitor: ending style, image density, ornament habit) | lane becomes `[확인 필요]`; register defaults to the mode's row in `human-prose.md` §4 |
| 2. Goal | yes | `post-workflow.md` §0 (mode) and §2 (type + decision line) | infer the mode from item 3 plus this goal; the type is inferred from the search intent and the goal, then stated in the decision line |
| 3. Brand / product + relationship | optional | brand facts block, CTA target, disclosure sentence, mode derivation | without it: treat the post as 정보/경험형, ignore the brand block, and ask no follow-up question |
| 4. Brand URL / material | optional | verbatim 가치입증 facts (read as a visitor; quote, never paraphrase numbers) | brand facts limited to what the user typed; every other brand claim is a slot |
| 5. Format | yes | delivery shape in `post-workflow.md` §5 and [`../references/format-options.md`](../references/format-options.md) | plain |
| 6. Tone and manner | optional | voice card in [`tone-manner.md`](tone-manner.md) §2: endings, sentence length, preferred and forbidden lexis, ornament habit | the blog read fills what it can, then the chosen row's default in `human-prose.md` §4 (`tone-manner.md` §3) |

Reading the blog URL or brand URL is a visitor read of public pages only (no login, no scraping beyond the pages needed). If a page cannot be fetched, say so in the publish note and continue.

## 4. After the answer

- Restate the six answers in one line (`블로그 / 목표 / 업체·관계 / 자료 / 양식 / 톤앤매너`) at the top of the reply, then run `post-workflow.md` from §0 without further questions. The mode (정보/전환) is derived there from the relationship and the goal, not asked here.
- A brief that already contains all six (for example a returning user pasting the line above) skips the message entirely.
- Do not ask about keywords, audience, length, or images: research and the mode row decide those. Tone is asked once, as item 6, and is never re-asked.

## Sources

> No external sources; content checked 2026-09-21.

This file states this package's own intake message and what each of its six answers feeds. It makes no external claim, so no external source is cited.
