# Validation

Use this rule before saving and in every `review`. It owns the per-mode completion evidence, the pre-save checklist, the blocking-question handling, and the optional no-context reader test.

## 1. Completion evidence per mode

| Mode | Evidence that the run is done | What is not evidence |
|---|---|---|
| `create` | `prd.md` saved at `.hyper/prd/<slug>/prd.md`, and every pre-save checklist item passes | A chat message describing the document |
| `update` | The changed sections, a change-history row with the date and what changed, and every checklist item passing | Rewriting the whole file while claiming a section edit |
| `review` | A pass/fail table per checklist item, with the failing item named and its location | Editing the file, or a prose verdict without a table |

`review` never edits. When a review finds a fix, it names the fix and stops; applying it is an `update`.

## 2. Pre-save checklist

Run each item over the saved text, not over the intention behind it.

| # | Check | Fails when |
|---|---|---|
| 1 | Every `FR-###` maps to a goal or a `P1`/`P2`/`P3` story | A requirement cites nothing, or cites only a non-goal |
| 2 | Every metric has a target, a measurement means, and a measurement time | One of the three is missing, or the target has no unit |
| 3 | Non-goals actually cut scope | A non-goal restates a goal, or could be removed without changing what is built |
| 4 | No vague word remains | `빠르게`, `쉽게`, `적절히`, `충분히`, `사용자 친화적`, `fast`, `easy`, `appropriate`, `robust`, `seamless` appear as a requirement |
| 5 | No implementation mechanism appears | A file path, function or type name, newly chosen library, or invented schema name is named outside an existing external constraint |
| 6 | Every story has a happy path and a failure-or-edge scenario citing `FR-###` ids | One path is missing, or a scenario cites no requirement |
| 7 | Every `A-###` has an evidence grade and a consequence | An assumption sits in the body as fact, or has no "if wrong" line |
| 8 | `[확인 필요: …]` appears at most 3 times | A fourth marker exists |
| 9 | No empty or `N/A` section remains | A heading has no content, or says `N/A`/`TBD` |
| 10 | The handoff block is complete | It lacks platforms, size, P1 scope, remaining blocking questions, or next-stage inputs |
| 11 | The meta block carries status, platforms, size, and the updated date | One field is missing |
| 12 | The must-not-change behavior is stated or explicitly declared absent | The change touches an existing flow and the section is missing |

Fix a failure in place and re-run only the failing item. Do not re-run the whole checklist to feel finished.

## 3. Blocking questions

- Any `Q-###` with `Blocking: yes` and no answer keeps `status: draft`.
- A `draft` document is still saved and reported; it is not withheld and not reported as complete.
- The completion report names each remaining blocking question and who must answer it.
- A document may pass every checklist item and still be `draft`; the checklist measures the text, the status measures whether a scope decision is missing.

## 4. Optional no-context reader test

Run this only when a subagent is available and the user has not forbidden it. It is never a required step, and a skipped test is stated as skipped rather than passed.

1. Write five expected questions the document must answer for a build stage: what is being built, for whom, what is out of scope, how success is measured, and what decision is still open.
2. Give a fresh subagent only the saved `prd.md` and ask those five questions.
3. Count the answers the document supports. A question the document cannot answer from its own text is a defect in that section, not in the reader.
4. Fold the defects back into the document and re-run the affected checklist items.

Record the outcome as `reader test: passed <n>/5` or `reader test: skipped (<reason>)`. Never claim a pass that was not run.

## 5. Review output shape

```text
| # | Check | Result | Location / note |
|---|---|---|---|
| 1 | FR maps to goal or story | pass | |
| 2 | Metric target and measurement | fail | Section 5, FR-007 has no target |
```

One row per checklist item, in checklist order. After the table, one line naming the blocking questions and one line stating that no file was edited.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| Independent testability as a gate on every story | [spec-kit spec-template](https://raw.githubusercontent.com/github/spec-kit/main/templates/spec-template.md) - "Each user story/journey must be INDEPENDENTLY TESTABLE" |
| Removing a non-applicable section instead of writing N/A | [spec-kit specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md) - "When a section doesn't apply, remove it entirely (don't leave as 'N/A')." |
| A clarification cap as a readiness gate | [spec-kit specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md) - "Maximum 3 [NEEDS CLARIFICATION] markers total" |
| A no-context reader test before other readers | [anthropics doc-coauthoring](https://github.com/anthropics/skills) - "Test the doc with a fresh Claude (no context) to catch blind spots before others read it" |
| Assumptions kept out of body fact | [phuryn create-prd](https://github.com/phuryn/pm-skills) - "Don't invent. What you don't know goes to 7.4 Assumptions and open questions, clearly marked, not into the body as fact." |
| Counter-metrics as part of a measurable goal set | [TerminalSkills prd-writing](https://github.com/TerminalSkills/skills) - "Counter-metrics: [Metrics we don't want to hurt]" |
| The implementation-mechanism audit | [ai-conductor prd](https://github.com/jstoup111/ai-conductor) - "It MUST NOT name the new internal mechanism by which this feature is built." |
| Output proportional to the problem, so the checklist stays short | [Martin Fowler, SDD tool comparison](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) - "it quickly became clear that the workflow was like using a sledgehammer to crack a nut" |

### Evidence grade

`LOCAL` - the twelve checklist items and the review table shape are this package's design. The marker cap and the removal rule are quoted from the cited specification guidance; the reader test is quoted from the cited authoring guidance.
