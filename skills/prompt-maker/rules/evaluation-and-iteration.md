# Evaluation And Iteration

## Minimum Categories

Include positive, negative, boundary, source, safety, schema, regression, and adversarial cases when creating a JSONL prompt eval fixture.

## Anti-Tautology Rule

An eval must be able to fail under a plausible bad prompt. Do not count checks that only assert file existence, keyword presence unrelated to behavior, or a restatement of the implementation text.

## Case Shape

Each case should have a non-empty id, category, prompt, `expected.must`, and `expected.mustNot`. The expected arrays should describe observable behavior.

## Iteration Loop

1. Capture baseline behavior.
2. Run the same cases after each prompt change.
3. Diagnose failure as instruction gap, context gap, schema mismatch, source-boundary issue, safety issue, or model/runtime mismatch.
4. Patch the smallest prompt surface.
5. Add a regression case for every new failure pattern.
6. Record the version note and remaining risk.

## Stop

Stop optimizing when the target cases pass, the next change would broaden scope, or remaining failures need missing context, a different model/runtime, or user authority.
