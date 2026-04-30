# Evaluation Patterns

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
