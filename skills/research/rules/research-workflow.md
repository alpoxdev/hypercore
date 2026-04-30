# Research Workflow

Use this rule file when you are actively running the research task.

## 1. Confirm The Request

- If the user gave no topic, ask for it immediately.
- Confirm depth only when the user already specified `--quick` or `--deep`; otherwise use the standard mode by default.
- Mark the request as date-sensitive when it includes wording such as `latest`, `current`, `today`, `this year`, `recent`, or similar relative-date language.

## 2. Build A Proportionate Plan

Use sequential thinking when any of these are true:

- the request is broad or ambiguous
- the request is high-stakes
- the user asked for `--deep`
- the answer needs a recommendation, not just raw facts

For quick, narrow tasks, a short written plan is enough:

- topic
- scope
- likely channels
- stop condition

## 3. Choose Channels In Priority Order

Start with the channel most likely to contain primary evidence:

- internal project question -> local repository search first
- library or package question -> official docs first, then GitHub or web sources if needed
- repository, product, or release-history question -> GitHub evidence first
- market, trend, or news question -> live web sources first
- academic or concept question -> primary papers or official references first

When a channel is unavailable, say so briefly and use the next-best local option rather than inventing a role or tool.

## 4. Parallelize Only After Planning

For default, deep, broad, comparative, or explicitly parallel research, read `rules/parallel-research.md` after the query plan exists.

- Do not parallelize `--quick` or narrow one-channel research.
- Split lanes by independent question, option, or source channel.
- Assign each lane a source floor, query angle, output schema, and stop condition.
- Keep synthesis, conflict resolution, and final recommendation with the lead agent.

## 5. Collect Evidence

- Keep every search query distinct.
- Follow the dedupe and stop rules in `instructions/sourcing/reliable-search.md`.
- Prefer primary or official sources before commentary.
- For time-sensitive claims, record exact publication or update dates.
- When sources disagree, note the disagreement and resolve it explicitly if possible.

## 6. Save The Report

Save the report under:

`.hypercore/research/[NN].slug.md`

Naming rules:

- `NN` is the next zero-padded sequence number in `.hypercore/research/`
- `slug` is a short ASCII summary of the topic
- keep the filename stable and readable

## 7. User-Facing Closeout

The final message should include:

- the main conclusion
- the saved report path
- the evidence quality or main caveat if confidence is limited
