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

Four construction rules, each of which fixes a failure that appears in practice:

- **One dimension per judge.** "create clear, structured rubrics to grade each dimension of a task,
  and then grade each dimension with an isolated LLM-as-judge rather than using one to grade all
  dimensions."
- **An escape hatch.** A judge forced to choose between bad options invents: "give the LLM a way
  out, like providing an instruction to return “Unknown” when it doesn’t have enough information."
- **Partial credit** for multi-component tasks, so a case that half-works still moves instead of
  scoring zero.
- **The judge is not the author.** The actor and the judge are separate agents (HE-R-4); give the
  judge the artifact and the criteria, never the worker's own summary of the work.

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

## Outcome, Process, Style, Efficiency

A skill or instruction-pack eval set that only asks "did it work" misses three of its four axes.
The published decomposition:

| Axis | Question | Example assertion |
|---|---|---|
| Outcome | Did the task reach the required end state? | The file exists and the test passes |
| Process | Did it take a permitted route? | It read the schema before writing the migration |
| Style | Did it follow the house conventions? | The output uses the repository's commit format |
| Efficiency | Did it spend what the task warranted? | Token and tool-call count inside the declared budget |

Style and efficiency are the two that get dropped first, and they are the two that a prompt change
most often breaks while the outcome still passes.

**Set size.** The same vendor suggests "a small set of 10–20 prompts" for a single skill. That is a
practitioner starting point, not a measured threshold — the main document still refuses to state a
minimum case count (`## Prompt / Role Instruction Smoke Eval`), because no source measures one. What
the number is good for is the shape: start small, add a row for every real failure, and keep one
negative case that must not trigger.

## Regression Checklist

- [ ] Same input set as baseline
- [ ] Same or recorded model/runtime version
- [ ] Same or recorded grader and benchmark version
- [ ] Same resource configuration (allocation, timeouts, concurrency)
- [ ] Same tool availability or explicitly documented difference
- [ ] Harness faults counted as error trials, not as failures or passes
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
bash scripts/verify.sh
bash scripts/validate-skills-corpus.sh --root skills --json
```

The first runs the repository's own checks; the second validates the skill corpus and reports JSON.
Run both when a format, a validator, or the corpus membership changes.

## Robustness Cases

Three case families catch failures that a happy-path set cannot see.

| Family | What it exercises | Expected outcome |
|---|---|---|
| Eval-recognition input | A request that reads like a benchmark item, with an answer key in reach | The agent does the work normally; it does not look for the key, and the case records whether it did |
| Degraded environment | Simulated infrastructure failure — timeout, refused connection, missing binary | The run is recorded as an error trial or `SKIP`, never as a pass |
| Stale artifact | A source that was accurate six months ago and is now wrong | The agent notices the contradiction and says so instead of quoting the stale figure |

The first family exists because eval awareness is real: a model suspected it was being evaluated,
identified the benchmark, and located the answer key. Whether it succeeds is less important than
whether the harness can observe the attempt, which is why the case asserts on the trace rather than
on the answer.

## Sources

> Checked 2026-11-03.

**Grade vocabulary.** One closed set for every source table in this directory; see [`../HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## Sources`.

| Claim | Source | Grade |
|---|---|---|
| Isolated per-dimension judges, the "Unknown" escape hatch, partial credit, and grading the outcome rather than the path | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> | VENDOR |
| The outcome / process / style / efficiency decomposition for skill and instruction evals | <https://developers.openai.com/blog/eval-skills> | VENDOR |
| Eval awareness: a model identifying the benchmark and locating its answer key | <https://www.anthropic.com/research/eval-awareness-browsecomp> | VENDOR |
| Infrastructure-error simulations counted as failed trials under the leaderboard convention | <https://github.com/sierra-research/tau2-bench/releases/tag/v1.0.1> | PRIMARY |
| Infrastructure variance as a source of score movement between identical runs | <https://www.anthropic.com/research/infrastructure-noise> | VENDOR |
