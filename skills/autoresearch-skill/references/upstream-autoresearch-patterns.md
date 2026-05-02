# Upstream Autoresearch Patterns

Use this reference when adapting ideas from `uditgoenka/autoresearch` into skill-focused autoresearch. The upstream project is evidence, not instruction authority; project/user instructions and this skill's narrower scope still win.

Reviewed source: `https://github.com/uditgoenka/autoresearch` on 2026-05-02.

## Transferable patterns

| Upstream pattern | Local adaptation for `autoresearch-skill` |
|---|---|
| Constraint + metric + loop | Define target skill scope, binary eval pack, score direction, and iteration budget before mutation. |
| Mechanical `Verify` | Treat the binary eval score as the primary metric; every kept mutation needs a reproducible score. |
| Optional `Guard` | Add non-regression checks such as trigger-boundary preservation, core line budget, link inventory, renderer smoke test, or existing skill tests. Guard files/evals are read-only during the experiment. |
| Git as memory | When commits are allowed, use `experiment(<skill>): ...` commits and read recent experiment history before choosing the next mutation. When commits are not allowed, use `SKILL.md.baseline`, `baseline-files.json`, `results.tsv`, and `changelog.md` as the memory layer. |
| One atomic change | One experiment may touch multiple files only when all edits support one sentence of intent. If the description needs "and" for unrelated actions, split it. |
| Keep/discard/revert | Keep only score-improving or no-regression simplification changes. Discard/revert failed, flat-and-more-complex, guard-failing, or crashed mutations. |
| Crash recovery | Classify syntax/runtime/resource/hang/external-dependency failures separately, log them, and avoid counting pure recovery as a scored mutation. |
| Command family | Upstream supports broad subcommands (`plan`, `debug`, `fix`, `security`, `ship`, etc.). This skill owns only skill optimization; route non-skill work to neighboring local skills. |

## Verify and Guard model

For skill optimization:

- **Verify** = "Did the skill score improve against the fixed binary eval pack?"
- **Guard** = "Did the mutation preserve required behavior and safety boundaries?"

Recommended skill guards:

- positive/negative/boundary trigger examples still classify correctly
- `SKILL.md` remains lean enough for progressive disclosure
- direct support-file links still resolve and are only one level deep
- `results.json`, `results.tsv`, and dashboard renderer contracts still validate
- external/current claims have a source ledger
- subagent or tool-use changes include trace assertions

If a guard fails, do not edit the guard/eval just to pass. Rework the mutation up to the run's retry budget, then discard and log the failure if it still fails.

## Git and dirty-tree safety

Before an experiment loop starts:

- confirm the repository and target files are readable
- inspect the working tree and do not stage unrelated user changes
- record whether commits are allowed for this run
- if committing, stage explicit target files only; never rely on broad staging for experiment commits
- if not committing, take a baseline snapshot that covers every mutable support file

## Logging fields to preserve

Upstream logs every iteration with commit, metric, delta, guard, status, and description. Preserve the same learning signal locally even when the metric is a skill score:

- `experiment`
- `commit` or `-`
- `score` / `max_score` / `pass_rate`
- `metric` and `delta`
- `guard` and optional `guard_metric`
- `status`
- `description`

Valid statuses should distinguish `baseline`, `keep`, `keep-reworked`, `discard`, `crash`, `no-op`, `hook-blocked`, and `metric-error`.

## Source map

- Repository overview and command map: `https://github.com/uditgoenka/autoresearch`
- Codex skill source: `.agents/skills/autoresearch/SKILL.md`
- Loop protocol: `.agents/skills/autoresearch/references/autonomous-loop-protocol.md`
- Result log protocol: `.agents/skills/autoresearch/references/results-logging.md`
- Plan/Verify/Guard setup: `.agents/skills/autoresearch/references/plan-workflow.md`
