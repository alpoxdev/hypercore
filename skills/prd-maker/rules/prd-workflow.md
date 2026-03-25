# PRD Workflow

Use this rule file to turn a request into a create or update PRD flow.

## 1. Choose the mode first

- `create`: no existing PRD folder matches the initiative, or the user explicitly wants a new PRD
- `update`: an existing PRD already exists and the request is refinement, expansion, correction, or refresh

Prefer `update` when the user is clearly iterating on an established initiative.

## 2. Gather the minimum working brief

Before writing, identify:

- product or feature name
- problem to solve
- target users or operators
- desired outcome or business goal
- current constraints or deadlines
- known unknowns

If these are missing, infer only low-risk basics and leave the rest as explicit open questions.

## 3. Decide whether research is required

Run live research when the PRD depends on:

- current market or competitor claims
- fresh product or user evidence
- date-sensitive technical, legal, or platform constraints
- specific numbers the user did not provide

Research rules:

- Use distinct queries only.
- Prefer official or primary sources first.
- Stop when the evidence is sufficient to support the PRD.
- Record links and retrieval dates in `sources.md`.

## 4. Draft the PRD

The main document should stay concise and decision-oriented.

Always cover:

- overview and status
- problem and objective
- users and use cases
- scope and non-goals
- requirements
- metrics
- assumptions, risks, and dependencies
- open questions
- change history

Add optional sections only when they materially reduce ambiguity.

## 5. Update instead of rewrite

When updating:

- preserve decisions that still hold
- revise only the affected sections
- note what changed and why
- keep unresolved conflicts visible

## 6. Keep linked detail outside the main body

- Put raw notes, query logs, and source summaries in `sources.md`.
- Link designs, tickets, interviews, or external docs from the PRD instead of copying them in full.
