---
name: deep-interview
description: Socratically clarify vague requests through one-question-at-a-time interviewing, ambiguity scoring, and saved spec crystallization before implementation.
compatibility: Works best in environments with repository search, file writing, and optional structured questioning, but should remain usable as a plain-text interview workflow.
---

# Deep Interview Skill

> Reduce ambiguity before execution by asking one high-leverage question at a time, scoring clarity after every answer, and saving a reusable spec under `.hypercore/deep-interview/`.

<purpose>

- Turn vague ideas into concrete, testable specifications before implementation starts.
- Surface hidden assumptions instead of jumping straight to feature lists.
- Use explicit ambiguity thresholds so the agent knows when clarification is sufficient and when more questioning is still needed.
- Save a reusable spec artifact that another execution-oriented workflow can implement later.

</purpose>

<request_routing>

## Positive triggers

- The user has a vague or half-formed product, feature, or workflow idea and wants the agent to understand it deeply first.
- The user says things like `deep interview`, `don't assume`, `interview me first`, `ask one question at a time`, or `make sure you understand before building`.
- The request is broad enough that immediate implementation would likely create rework.
- The user wants a specification artifact before handing work to planning or execution.

## Out-of-scope

- A concrete bug fix, single-file change, or tightly scoped implementation request with clear acceptance criteria.
- Open-ended brainstorming where the job is idea generation rather than requirement narrowing.
- Direct execution requests such as `just do it`, `skip the questions`, or `implement this now`.
- Existing PRD/spec refinement when the main job is editing a document rather than interviewing for clarity.

Route-away defaults:

- concrete implementation or bug-fix work → execution / bug-fix lane
- open brainstorming or idea expansion → planning / ideation lane
- editing an existing PRD or saved spec → PRD or document-update lane

## Boundary cases

- If the request starts vague but already includes explicit files, exact behavior, and testable acceptance criteria, stop interviewing early and hand off to execution or planning.
- If the user wants options first and commitment later, use the interview to identify the decision boundary, then summarize the options instead of pretending the scope is already fixed.
- If the user asks to continue despite high ambiguity, warn clearly about the unresolved gaps before handing off.

## Trigger examples

Positive:
- `I have a rough idea for an internal ops dashboard, but don't assume anything. Deep interview me first.`
- `이거 바로 만들지 말고 질문으로 요구사항부터 좁혀줘.`
- `Ask one question at a time until you can write a spec.`

Negative:
- `Fix the null error in src/auth/session.ts.`
- `브라우저 QA용 새 스킬 만들어줘.`

Boundary:
- `I want a habit tracker, but I already know it needs offline sync, reminders, and a weekly summary. Do we still need a deep interview?`

</request_routing>

<interview_contract>

## Mandatory behavior

- Ask **exactly one** focused question per round.
- Target the **weakest clarity dimension** each round instead of asking generic follow-up questions.
- Explain why that dimension is the current bottleneck before asking the question.
- For brownfield work, inspect the repository first and cite the code evidence that triggered the question.
- Never ask the user to rediscover facts already available in the repository.
- Score clarity after every answer and show the current ambiguity state transparently.
- Do not hand off to implementation until ambiguity is below threshold or the user explicitly accepts the residual risk.

## Forbidden behavior

- Batching multiple unrelated questions into one turn.
- Asking repo-fact questions like `where is auth implemented?` before checking the codebase.
- Pretending the scope is clear when the key entities, constraints, or acceptance criteria are still moving.
- Starting implementation directly inside the deep-interview workflow.

</interview_contract>

<clarity_model>

## Clarity dimensions

Score each dimension from `0.0` to `1.0` after every round:

1. **Goal clarity** — is the primary objective unambiguous?
2. **Constraint clarity** — are boundaries, limitations, and non-goals clear?
3. **Success criteria clarity** — can success be tested concretely?
4. **Context clarity** — for brownfield work, do the desired changes map cleanly to the existing codebase?

## Ambiguity formula

Use these default weighted formulas:

- **Greenfield**: `ambiguity = 1 - (goal × 0.40 + constraints × 0.30 + criteria × 0.30)`
- **Brownfield**: `ambiguity = 1 - (goal × 0.35 + constraints × 0.25 + criteria × 0.25 + context × 0.15)`

Default threshold: `0.20` ambiguity or lower means the spec is ready.

## Ontology tracking

Track the key nouns and relationships that define the problem domain.

For every round:
- list the main entities currently implied by the conversation
- note whether entities are stable, renamed, newly introduced, or removed
- if the core entity keeps changing, ask ontology-style questions before asking about features

Use ontology convergence as an extra signal:
- rising stability means the user and agent are converging on the same domain model
- repeated entity churn means ambiguity is still structural, not just incomplete

</clarity_model>

<workflow>

## Phase 0: Classify and initialize

- Parse the user's initial idea.
- Decide whether the work is **greenfield** or **brownfield**.
- If brownfield, inspect the relevant repository area before asking codebase-related questions.
- Establish the current ambiguity as `100%` unresolved at round 0.

## Phase 1: Ask the next best question

For each round:

1. Score the current dimensions.
2. Identify the weakest dimension.
3. State why it is the current bottleneck.
4. Ask one focused question aimed at improving that dimension.

Question style by target:

- **Goal clarity** → ask what the thing fundamentally is and what the user is trying to achieve.
- **Constraint clarity** → ask about boundaries, exclusions, required environments, or assumptions.
- **Success criteria** → ask what observable result would count as success.
- **Context clarity** → ask how the new behavior should fit the existing code path you found.

## Phase 2: Score and report

After every answer, report:

- round number
- dimension scores
- weighted ambiguity score
- key remaining gap
- next target dimension
- ontology stability summary if entities are shifting

Use a compact format like:

```text
Round 3 complete
Goal: 0.8
Constraints: 0.6
Success criteria: 0.5
Context: 0.7
Ambiguity: 0.34
Next target: Success criteria
Why now: we still cannot test success without guessing
```

## Phase 3: Challenge assumptions

If ambiguity remains high, deliberately change perspective:

- **Round 4+ Contrarian mode**: challenge a core assumption.
- **Round 6+ Simplifier mode**: ask what the smallest valuable version is.
- **Round 8+ Ontologist mode**: ask what the product or system fundamentally is when the core noun is still unstable.

Use each challenge mode once unless the conversation clearly requires a repeat.

## Phase 4: Crystallize the spec

When ambiguity is at or below threshold, or when the user explicitly accepts residual ambiguity:

- write a reusable spec
- summarize goal, constraints, non-goals, acceptance criteria, assumptions resolved, and relevant brownfield context
- include the interview transcript or a concise round-by-round summary
- clearly mark whether the spec passed threshold or exited early with unresolved risk

## Phase 5: Handoff without implementing

End by recommending the next lane:

- planning if architecture or tradeoffs still need refinement
- execution if the spec is already concrete enough to build
- continued interview if the user wants to reduce ambiguity further

The deep-interview skill owns clarification and crystallization, not coding.

</workflow>

<support_files>

This first version is intentionally self-contained.

- No extra `rules/`, `references/`, or `assets/` files are required to run the core workflow.
- If the skill is expanded later, keep support-file discovery to one hop from `SKILL.md`.
- Do not move the core trigger boundary, ambiguity model, or one-question rule into hidden support files.

</support_files>

<artifact_contract>

Save interview outputs under:

```text
.hypercore/deep-interview/[topic-slug]/
├── spec.md
├── transcript.md
└── flow.json
```

Minimum contract:

- `spec.md` — final crystallized spec
- `transcript.md` — Q/A rounds or condensed interview log
- `flow.json` — current round, ambiguity, threshold, and status for resumable runs

Recommended `flow.json` fields:
- `status`: `interviewing` | `ready` | `early_exit` | `handoff`
- `type`: `greenfield` | `brownfield`
- `current_round`
- `current_ambiguity`
- `threshold`
- `weakest_dimension`
- `challenge_modes_used`

</artifact_contract>

<validation>

Before closing, confirm all of the following:

- The use-vs-not-use boundary is clear from the core file.
- The workflow explicitly says one question per round.
- Brownfield questioning is evidence-first.
- The ambiguity threshold is visible and not implied.
- The final output shape under `.hypercore/deep-interview/[topic-slug]/` is clear.
- The final handoff does not silently become implementation.

</validation>
