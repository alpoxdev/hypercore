# Evaluation Patterns

> Korean version: [`evaluation-patterns.ko.md`](evaluation-patterns.ko.md)

## Deterministic Assertions

Use when output can be checked exactly.

```yaml
assert:
  - type: is-json
  - type: contains
    value: "status"
  - type: javascript
    value: output.changed_files.length > 0
```

## Rubric Judge

Use when quality requires judgment.

```markdown
Score 0-3:
3 = fully answers, cites sources, states caveats
2 = mostly answers, minor missing caveat
1 = partial answer or weak support
0 = unsupported or wrong
```

## Trace Assertions

Use for agents.

```yaml
must_call:
  - repo_search_before_edit
  - test_after_edit
must_not_call:
  - external_post_without_permission
  - destructive_shell_without_approval
```

## Source-Grounded Answer Eval

```yaml
metrics:
  context_recall: "does answer use all required source facts?"
  context_precision: "are cited sources actually relevant?"
  citation_accuracy: "does source support claim?"
  stale_source_rate: "are current claims backed by current sources?"
```

## Regression Checklist

- [ ] Same input set as baseline
- [ ] Same or recorded model/runtime version
- [ ] Same tool availability or explicitly documented difference
- [ ] Failures categorized by root cause
- [ ] New failures turned into permanent eval cases

## Negative Fixtures

A format is proven by the inputs it must reject, not by the ones it accepts. Each malformed case is a
tiny file committed next to the validator, and each one asserts a specific rejection.

Minimum set for an instruction or manifest format:

- [ ] a required header or frontmatter block missing entirely
- [ ] a name that does not match its directory
- [ ] a character the format forbids
- [ ] a value past its length limit
- [ ] an unknown field
- [ ] a root that must not be loadable at all — a fixture whose expected outcome is "never loads"

The last one is the security case. A loader that accepts everything it is given will pass every
positive test, so a "never loads" fixture is what makes the rejection path observable.

A corpus contract test complements the fixtures. It pins the properties of the whole instruction set
rather than one file: the entry count, required members, forbidden members (retired entries must not
be advertised), and link resolution.

This repository's execution points:

```bash
bun run --cwd scripts verify
node skills/skill-tester/scripts/validate-skills-corpus.mjs --root skills --json
```

The first runs the repository's own checks; the second validates the skill corpus and reports JSON.
Run both when a format, a validator, or the corpus membership changes.
