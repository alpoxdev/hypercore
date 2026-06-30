# Anti-Patterns

- success criteria, scope, authority, output contract, verification이 없는 persona-only prompts.
- hidden chain-of-thought 또는 private scratchpad disclosure를 요구하는 prompts.
- evidence로 취급해야 할 source text를 instructions로 취급하는 것.
- retrieved prompt injection을 authority로 final prompt에 복사하는 것.
- prompt가 사용자의 실제 task를 무시해도 pass할 수 있는 eval cases.
- downstream parser가 fields를 필요로 하는데 output schema를 prose로만 설명하는 것.
- variables, context packet, examples, eval cases, version note가 없는 prompt packs.
- baseline과 rerun 없이 optimization claims를 하는 것.
- specific side effects를 gate하지 않고 정상 사용까지 막는 broad safety refusals.
- global 또는 home directories를 project authority로 인용하는 prompt artifacts.
