# Prompt Contract

Treat every durable prompt as an execution contract, not a persona paragraph.

## Required Contract Fields

| Field | Purpose |
|---|---|
| Intent | The real user outcome, success state, and failure state. |
| Trigger | When the prompt should be used and when it should not be used. |
| Scope | Allowed actions, owned artifacts, non-goals, and side-effect limits. |
| Authority | Instruction priority and conflict handling. |
| Evidence | Which context, files, sources, evals, and ledgers support claims. |
| Tools | Allowed tools, required gates, and forbidden side effects. |
| Output | Shape, language, required fields, forbidden formats, and destination. |
| Verification | Tests, evals, source checks, readback checks, and review gates. |
| Stop condition | Observable completion criteria and blocker conditions. |

## Reasoning Visibility

Do not require hidden chain-of-thought, private reasoning transcripts, or internal scratchpad disclosure. Ask for concise public rationale, assumptions, decision criteria, and verification evidence.

## Prompt Shape

A prompt pack should contain identity, variables, context packet, examples, constraints, output schema, eval cases, and version note. Use exact schema keys when downstream tools depend on them.
