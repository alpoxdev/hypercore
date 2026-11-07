# Resource Placement

> Korean version: [`resource-placement.ko.md`](resource-placement.ko.md)

Resource placement is the rule set that gives each file in a skill folder an exact responsibility.

## 1. Placement matrix

| Resource | Where it belongs | Why |
|---|---|---|
| When to use the skill | `description`, `routing_rule` | Discovery and trigger signal |
| High-level execution order | `SKILL.md` | Always needed at activation |
| Recurring verification checklist | `rules/` or `SKILL.md` validation | Reused across every run |
| Official documentation summaries | `references/official/` | Separates provider drift and detail |
| Long examples | `references/examples.md` or `assets/` | Loaded only when needed |
| Iteration loop policy | `rules/loop.md` | Reuses feedback, guard, and stop condition |
| Prompt templates | `assets/prompts/` or `references/examples.md` | Assets if copied or filled, references if explanatory |
| Eval fixtures | `assets/evals/` | Keeps input and expected output runnable |
| Source ledger | `references/sources.md` or `references/official/` | Tracks external claims |
| Safety boundary | `rules/safety.md` or `references/safety.md` | Tool, network, credential, and destructive gates |
| Output templates | `assets/` | Copy-or-fill targets |
| Automated verification | `scripts/` | Guarantees determinism and repeatability |
| Runtime metadata | `agents/` | Platform-specific display, invocation policy, and dependencies |

## 2. Rules vs references

`rules/` holds judgment criteria and procedures.

Examples:

- "When to add a script"
- "In what order to fix things when verification fails"
- "How to grade research sources"
- "When a loop should continue and when it should stop"
- "When to gate network, credential, and destructive actions"

`references/` holds knowledge and detail.

Examples:

- A summary of the OpenAI Codex skill docs
- The Anthropic Claude Code skill lifecycle
- API schemas
- Domain-specific edge cases
- Source ledgers and vendor drift notes
- Summaries of paper and benchmark evidence

## 3. Criteria for adding a script

Add a script only when it satisfies at least one of the following.

- The same logic must repeat many times.
- The agent is likely to get the command wrong each time.
- The output must be verified machine-readably.
- The failure message matters for self-correction.
- Even when calling an existing tool, version pinning and parameter normalization are needed.

Required script documentation:

```markdown
## Available scripts

- `scripts/validate-skill.sh`
  - Purpose: validate frontmatter, local links, code fences, and support file references.
  - Usage: `bash scripts/validate-skill.sh skills/my-skill`
  - Requires: bash 3.2+ and jq
  - Output: JSON summary plus non-zero exit on failure.
```

## 4. Criteria for adding assets

Keep only files actually used in the artifact.

Good assets:

- Report templates
- CSV fixtures
- JSON schemas
- Style samples
- Image and reference mocks
- Prompt templates with blanks
- Eval input/expected-output pairs
- Golden output snapshots

Bad assets:

- Read-only explanatory documents
- Duplicated references
- Example files with no known usage

## 5. Placing official references

Do not embed long official-documentation evidence in the core. Split it out like this.

```text
references/
└── official/
    ├── openai.md
    ├── anthropic.md
    └── agent-skills-standard.md
```

Each file includes:

- The date checked
- The source URL
- The claims that affect this skill
- Drift caveats
- The summary that was promoted into a core rule

The `references/official/` folder name is a recommendation, not a required path; several skills already use it (for example `skills/hyper-skill/references/official/`). The rule that matters is that provider detail is separated from the core. When the evidence is a pinned snapshot of this repository's own documents, name the folder `references/local/`; `skills/hyper-skill/references/local/` is the existing example.

## 6. Placing eval resources

Split eval material into "explanations you read" and "fixtures you run or compare."

```text
assets/
└── evals/
    ├── trigger-cases.jsonl
    ├── workflow-cases.jsonl
    └── safety-cases.jsonl

references/
└── eval-rubric.md
```

- `assets/evals/*.jsonl` holds machine-readable cases a parser or runner can read.
- `references/eval-rubric.md` holds human-readable scoring criteria and caveats.
- When a deterministic runner exists, put it in `scripts/run-evals.*` and document its dependencies and expected output.
- When an eval case requires an external source, link the source URL, accessed date, and freshness caveat inside the case or in the source ledger.

### Compatibility with the packaged tooling

`assets/evals/` is **this repository's** convention, chosen because the existing skills already use it, and no packaged tool reads it. Anthropic's `skill-creator` reads `evals/evals.json` at the skill root, whose entries carry prompts, input files, expected behavior, and assertions. Claude Code's `claude plugin eval` uses its own case format, and the vendor states that the two formats "aren't interchangeable".

So the rule is: keep `assets/evals/` as the place a human or this repository's runner reads, and if a skill is also meant to be evaluated by one of those tools, add that tool's own case file **and** keep it in sync with `assets/evals/` — or generate it from `assets/evals/` in `scripts/`. A half-migrated pair is worse than one canonical set.

### Where execution results go

The fixtures above are inputs. The **results** of running them live outside the skill folder, because a shipped skill should not carry its own run history and because every other execution in this repository already writes there.

```text
.omo/evidence/<skill>/iteration-N/
├── grading.json          # required — SK-E-2
├── timing.json           # required — SK-E-2
├── feedback.json         # required once a human reviews — SK-E-5
├── run-notes.json        # optional — runner, model, baseline caveats
├── trajectory.md         # optional — readback trace of the run
├── benchmark.json        # optional — only with a benchmark claim
└── eval-<case>/
    ├── with_skill/       # SK-V-1 pair — required whenever the baseline runs
    │   ├── outputs/
    │   ├── timing.json
    │   └── grading.json
    └── without_skill/    # or old_skill/ when the baseline is a previous version
        ├── outputs/
        ├── timing.json
        └── grading.json
```

| File or directory | Status | Basis |
|---|---|---|
| `grading.json` | Required for every run | SK-E-2 — per-assertion pass/fail plus the evidence string |
| `timing.json` | Required for every run | SK-E-2 — tokens and wall time |
| `feedback.json` | Required once a human review happens | SK-E-5 |
| `eval-<case>/with_skill/` and `eval-<case>/without_skill/` (or `old_skill/`) | Required whenever the paired baseline runs; the deterministic-skill exception is recorded instead | SK-V-1, SK-E-6 |
| `benchmark.json` | Optional — only when the run makes a benchmark or leaderboard claim | [`validation.md`](validation.md) §7 |
| `run-notes.json` | Optional — runner, model, and baseline caveats for the iteration | This repository's practice |
| `trajectory.md` | Optional — what the run read and did, kept for readback | This repository's practice |

The optional files are diagnostic. A run that omits `run-notes.json` or `trajectory.md` loses context a later reader wants, but a run that omits `grading.json`, `timing.json`, or the paired baseline cannot be read as evidence at all. Aggregating is allowed: a runner that emits one grade map may keep `grading.json` at the iteration root keyed by eval id, as `.omo/evidence/hyper-mass/iteration-1/grading.json` does, as long as every case's assertions still carry their evidence string.

When the baseline is a previous version rather than "no skill", replace `without_skill/` with `old_skill/` and keep the snapshot the run pointed at.

This repository already had two competing placements for eval material; adding a third would leave no single answer. The layout above was chosen over the alternative of a workspace beside the skill folder, because the sibling-workspace form has no precedent here and the evidence directory does. The trade-off is real: results do not travel with a distributed skill, so a reader outside this repository cannot see them.

- SK-E-1: Keep execution results **outside the skill folder**, under the evidence path shown above. A shipped skill does not carry its own run history.
- SK-E-2: Every run leaves `timing.json` (tokens and wall time) and `grading.json` (per-assertion pass/fail **plus the evidence string**). A `passed: true` with no evidence string is not evidence.
- SK-E-3: Run each execution in an **independent session**. Reusing one session lets the earlier run's context contaminate the next.
- SK-E-4: Check mechanical assertions (valid JSON, row counts, file existence) with a **script**, not an LLM judge. Reserve the judge for what a script cannot decide.
- SK-E-5: Human review lives in `feedback.json` beside the eval directories, keyed by eval id: a specific complaint string per case, an empty string when the case passed review. It is written by the reviewer, never generated from the grades.
- SK-E-6: When comparing versions, keep the previous version as `old_skill/` inside the iteration directory and record which snapshot commit or copy it came from, so the comparison can be repeated.

## 7. Forbidden patterns

- `SKILL.md` becoming a reference knowledge base
- A `references/` file requiring several further reference hops
- Creating scripts without stating their usage condition in `SKILL.md`
- Assets not connected to the actual workflow
- Copying long passages of official documentation verbatim
- Leaving eval fixtures as a prose checklist so they cannot be re-run
- Writing the safety boundary only as a final-answer tone rule without connecting it to a tool gate
- Keeping two eval sets that have drifted apart

## 8. Completion criteria

- [ ] Every support file has a reason for its location.
- [ ] Every support file is directly or clearly discoverable from `SKILL.md`.
- [ ] Scripts and assets have usage and validation.
- [ ] Provider-sensitive content is isolated in references.
- [ ] Prompt templates, eval fixtures, source ledgers, and safety notes each sit in the correct place among prose, reference, asset, and script.
- [ ] If the skill is evaluated by `skill-creator` or `claude plugin eval`, that tool's own case file exists and matches the fixtures the runner reads.
- [ ] Content that loads into every session keeps volatile values (dates, versions, counts, machine paths) out of its loaded head — see [`../../cache/CACHE.md`](../../cache/CACHE.md).
- [ ] Eval execution results are written outside the skill folder, with per-run timing, grading, and human feedback records.

## Sources

> Links re-read and re-checked 2026-11-03.

| Claim | Source |
|---|---|
| Execution results kept outside the skill directory, per-run `timing.json` and `grading.json` with evidence, independent sessions per run, mechanical assertions checked by script, the `with_skill`/`without_skill`/`old_skill` naming, and `feedback.json` — the basis of `SK-E-1` to `SK-E-6` | <https://agentskills.io/skill-creation/evaluating-skills> |
| `evals/evals.json` as the hand-authored `skill-creator` input, and `claude plugin eval` using a different, non-interchangeable format | <https://code.claude.com/docs/en/skills> |
| Scripts should be self-contained or document dependencies, include helpful error messages, and handle edge cases | <https://agentskills.io/specification> |

### Evidence grade

The placement and cost-recording rules are `PRIMARY` — the specification site states them. The specific directory layout (`.omo/evidence/...`) is a **repository decision**, not a sourced one: the source uses a sibling `<name>-workspace/iteration-N/` directory instead, and this file records both the choice and its trade-off. `SK-E-5` and `SK-E-6` extend the source's `feedback.json` and `old_skill/` conventions into a placement rule; the filenames come from the source, the location from this repository.
