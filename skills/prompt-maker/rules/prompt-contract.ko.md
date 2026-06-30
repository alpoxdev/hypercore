# Prompt Contract

지속적으로 사용할 prompt는 persona paragraph가 아니라 execution contract로 다룬다.

## Required Contract Fields

| Field | Purpose |
|---|---|
| Intent | 실제 사용자 outcome, success state, failure state. |
| Trigger | prompt를 사용할 때와 사용하지 않을 때. |
| Scope | 허용 actions, owned artifacts, non-goals, side-effect limits. |
| Authority | instruction priority와 conflict handling. |
| Evidence | claims를 뒷받침하는 context, files, sources, evals, ledgers. |
| Tools | allowed tools, required gates, forbidden side effects. |
| Output | shape, language, required fields, forbidden formats, destination. |
| Verification | tests, evals, source checks, readback checks, review gates. |
| Stop condition | 관찰 가능한 completion criteria와 blocker conditions. |

## Reasoning Visibility

hidden chain-of-thought, private reasoning transcripts, internal scratchpad 공개를 요구하지 않는다. 대신 concise public rationale, assumptions, decision criteria, verification evidence를 요구한다.

## Prompt Shape

prompt pack에는 identity, variables, context packet, examples, constraints, output schema, eval cases, version note가 있어야 한다. downstream tools가 의존하면 정확한 schema keys를 사용한다.
