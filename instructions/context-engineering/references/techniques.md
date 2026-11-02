# Techniques

> Korean version: [`techniques.ko.md`](techniques.ko.md)

## 1. Decomposition

For complex work, decomposition is more reliable than "doing it well in one shot."

| Work | Decomposition |
|---|---|
| Code change | explore -> plan -> edit -> test -> review |
| Research | questions -> source plan -> collect -> synthesize -> validate |
| UX/docs | audience -> task -> examples -> output contract -> QA |
| Agent harness | scenario -> expected behavior -> metrics -> regression run |

## 2. Few-shot examples

Examples are stronger than rules. But too many examples pollute the context.

```markdown
<examples>
  <good>one instance of the desired shape</good>
  <bad>one instance of the shape to avoid</bad>
</examples>
```

- Use them to fix format, tone, or API shape.
- Do not hide domain facts inside examples. Facts belong in the evidence section.
- When examples go stale, the instruction goes stale with them.
- When an example conflicts with a rule in the body, the model may follow the example pattern more strongly, so keep only representative examples of the current rules.

## 3. Structured output

For output that downstream tools or verification must read, prefer a schema over Markdown.

```json
{
  "status": "pass|fail|blocked",
  "evidence": [{ "claim": "...", "source": "..." }],
  "next_actions": ["..."]
}
```

## 4. Reasoning control

- For complex problems, require planning, review, and comparison of alternatives.
- Emit as much rationale and verification result in the final answer as is needed.
- Do not demand the verbatim hidden chain of thought; demand decision rationale, evidence links, and test results.
- Give reasoning models a clear goal, constraints, success criteria, and iteration/verification conditions rather than an unconditional "think step by step." When per-model reasoning or effort parameters exist, isolate them in a runtime profile.

Current vendor guidance converges on this. OpenAI states that instructing a reasoning model to "think step by step" "may not enhance performance (and can sometimes hinder it)", and its current-generation guidance asks for persistence instead: "bias towards action and carry the user's intended task to completion," while completing "the work that is already authorized from context" before asking a clarifying question (checked 2026-11-03). Anthropic's lever is section structure plus explicit success criteria, not a magic phrase. Write reasoning control as goal, constraints, and verification, and let the runtime own effort settings.

Verbosity is a parameter before it is a sentence. OpenAI exposes `text.verbosity` (`low` / `medium` / `high`) and calls it "the main lever for balancing brevity against completeness"; its migration note warns that broad "be concise" instructions may no longer be useful after a model upgrade. Prefer the parameter, keep the instruction for shape (structure, ordering, what to omit) rather than length.

| Need | Instruction |
|---|---|
| Quick factual answer | Answer directly and show only source and date |
| Multi-stage analysis | Write the plan, alternatives, and verification criteria |
| High-risk judgment | Check material, search for counter-evidence, state caveats |
| Code change | Read the files, make a minimal diff, report test results |

## 5. Tool use

Write tool instructions as capabilities, not product names.

| Capability | Good instruction |
|---|---|
| repo search | "Search and read the relevant files and symbols before editing" |
| web/source lookup | "Verify volatile information against a live source" |
| browser/visual QA | "Confirm UI changes with screenshots or interaction" |
| shell/test | "Run the minimum verification command the claim needs and read the output" |
| subagents | "Delegate in parallel only independent, bounded investigation or verification"; see [`parallel-workflows.md`](parallel-workflows.md) for detail |

Tool count is part of the instruction, not a separate configuration detail. Anthropic names "bloated tool sets that cover too much functionality" as one of the most common failure modes and gives the test to apply: if a human engineer cannot definitively say which tool applies in a situation, the model cannot either (checked 2026-11-03). When a tool must be withdrawn mid-task, mask it rather than removing its definition, because the definition sits in the cached prefix ([`context-management.md`](context-management.md) §3).

## 6. Long-context ordering

Both major vendors converge on the same ordering: documents first, question last.

- Anthropic: "Place your long documents and inputs near the top of your prompt, above your query, instructions, and examples"; queries placed at the end "can improve response quality by up to 30 percent in tests."
- Google: "When providing large amounts of context (e.g., documents, code), supply all the context first. Place your specific instructions or questions at the very end of the prompt," plus an explicit transition phrase such as "Based on the information above…" to bridge the material and the query.

Rules:

1. Give each block an id and a source, then require the answer to name the ids it used.
2. Ask for the evidence extract before the final answer when the corpus is large, so the second step reads a short, checkable set.
3. Do not treat ordering as a substitute for selection. Chroma found shuffled haystacks scoring better than coherently ordered ones, so placement helps only after the material is already relevant.

## 7. Eval-backed prompt optimization

Even when using a prompt optimizer, meta-prompt, or LLM-as-prompt-writer, do not adopt the result as-is.

1. Preserve the original prompt and its failure cases.
2. Include a task-specific dataset, good/bad annotations, and grader criteria in the optimization input.
3. Compare the optimized result against the same smoke eval and edge cases.
4. Record both what improved and what regressed.
5. Apply to production or shared instructions only after manual review.

## 8. Prompt diffing

Treat an instruction change like code: look at the diff and the regression risk.

- What did it make more explicit?
- Which statement is true only on a particular runtime?
- Is it a prohibition or requirement change that breaks an existing workflow?
- Did it improve on the eval cases?

## Sources

> Sources checked 2026-11-03.

| Claim | Source | Published / updated |
|---|---|---|
| Avoid chain-of-thought prompts for reasoning models; "think step by step" can hinder | <https://developers.openai.com/api/docs/guides/reasoning-best-practices> | undated page, checked 2026-11-03 |
| Persistence and "bias towards action" guidance, `text.verbosity` as the brevity lever | <https://developers.openai.com/api/docs/guides/latest-model> | undated page, checked 2026-11-03 |
| Long documents first, query at the end, up to 30 percent improvement | <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices> | undated page, checked 2026-11-03 |
| Context first, instructions last, transition phrase | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/prompts/prompt-design-strategies?hl=en> | updated 2026-10-30 |
| Shuffled haystacks beat coherent ones; selection before ordering | <https://www.trychroma.com/research/context-rot> | 2025-07-14 |
