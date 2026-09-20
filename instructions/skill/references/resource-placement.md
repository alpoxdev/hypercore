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
| UI/runtime metadata | `agents/` | Platform-specific display and dependency information |

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

- `scripts/validate-skill.mjs`
  - Purpose: validate frontmatter, local links, code fences, and support file references.
  - Usage: `node scripts/validate-skill.mjs skills/my-skill`
  - Requires: Node.js 20+
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

### Where execution results go

The fixtures above are inputs. The **results** of running them live outside the skill folder, because a shipped skill should not carry its own run history and because every other execution in this repository already writes there.

```text
.omo/evidence/<skill>/iteration-N/
├── benchmark.json
└── eval-<case>/
    ├── with_skill/
    │   ├── outputs/
    │   ├── timing.json
    │   └── grading.json
    └── without_skill/
        ├── outputs/
        ├── timing.json
        └── grading.json
```

This repository already had two competing placements for eval material; adding a third would leave no single answer. The layout above was chosen over the alternative of a workspace beside the skill folder, because the sibling-workspace form has no precedent here and the evidence directory does. The trade-off is real: results do not travel with a distributed skill, so a reader outside this repository cannot see them.

- SK-E-1: Keep execution results **outside the skill folder**, under the evidence path shown above. A shipped skill does not carry its own run history.
- SK-E-2: Every run leaves `timing.json` (tokens and wall time) and `grading.json` (per-assertion pass/fail **plus the evidence string**). A `passed: true` with no evidence string is not evidence.
- SK-E-3: Run each execution in an **independent session**. Reusing one session lets the earlier run's context contaminate the next.
- SK-E-4: Check mechanical assertions (valid JSON, row counts, file existence) with a **script**, not an LLM judge. Reserve the judge for what a script cannot decide.

## 7. Forbidden patterns

- `SKILL.md` becoming a reference knowledge base
- A `references/` file requiring several further reference hops
- Creating scripts without stating their usage condition in `SKILL.md`
- Assets not connected to the actual workflow
- Copying long passages of official documentation verbatim
- Leaving eval fixtures as a prose checklist so they cannot be re-run
- Writing the safety boundary only as a final-answer tone rule without connecting it to a tool gate

## 8. Completion criteria

- [ ] Every support file has a reason for its location.
- [ ] Every support file is directly or clearly discoverable from `SKILL.md`.
- [ ] Scripts and assets have usage and validation.
- [ ] Provider-sensitive content is isolated in references.
- [ ] Prompt templates, eval fixtures, source ledgers, and safety notes each sit in the correct place among prose, reference, asset, and script.
- [ ] Content that loads into every session keeps volatile values (dates, versions, counts, machine paths) out of its loaded head — see [`../../cache/CACHE.md`](../../cache/CACHE.md).
- [ ] Eval execution results are written outside the skill folder, with per-run timing and grading records.

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| Claim | Source |
|---|---|
| Execution results kept outside the skill folder, per-run `timing.json` and `grading.json` with evidence strings, independent sessions per run, and mechanical assertions checked by script — the basis of `SK-E-1` to `SK-E-4` | <https://agentskills.io/skill-creation/evaluating-skills> |

### Evidence grade

The placement and cost-recording rules above are `PRIMARY` — the specification site states them directly. The specific directory layout is a **repository decision**, not a sourced one: the delta flagged it as an unresolved conflict and this file records the choice and its trade-off.
