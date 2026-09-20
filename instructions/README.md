# Instructions Base

This folder is the LLM working-instruction layer for this project. Its purpose is to make agents such as Codex, Claude Code, Cursor, and GitHub Copilot share the same project intent and verification standards so they work consistently.

> Korean version: [`README.ko.md`](README.ko.md). Every document in this base is paired — `X.md` is English and `X.ko.md` is Korean, matching the convention already used under `skills/`. Keep both sides in sync when you change either.

## Areas

| Area | File | Purpose |
|---|---|---|
| Context Engineering | [`context-engineering/CONTEXT_ENGINEERING.md`](context-engineering/CONTEXT_ENGINEERING.md) | Design prompt, context, and tool instructions in a runtime-neutral way |
| CLI Runtime Profiles | [`cli/README.md`](cli/README.md) | Let a skill safely select question, approval, and tool capabilities across Claude Code, Codex, GJC, Hermes Agent, JCode, OMO, OpenClaw, and OpenCode |
| Prompt Authoring | [`context-engineering/references/prompt-authoring.md`](context-engineering/references/prompt-authoring.md) | Practical template for writing a role prompt as an execution contract |
| Prompt & Skill Caching | [`cache/CACHE.md`](cache/CACHE.md) | Keep the reusable prefix of a prompt or skill stable so provider prompt caching can serve it |
| AGENTS.md / CLAUDE.md | [`agents-md/AGENTS_MD.md`](agents-md/AGENTS_MD.md) | Author repository agent instruction files as a small, evidenced, portable contract |
| Skill Authoring | [`skill/SKILL_AUTHORING.md`](skill/SKILL_AUTHORING.md) | Design a reusable skill folder as a triggerable, structured, verifiable execution package |
| Skill Prompt/Loop/Eval | [`skill/references/prompt-loop-eval.md`](skill/references/prompt-loop-eval.md) | Design a skill as a small iterable, verifiable program rather than a single prompt |
| Autoresearch | [`autoresearch/AUTORESEARCH.md`](autoresearch/AUTORESEARCH.md) | Design an autonomous iteration harness with goal, scope, metric, verification, guard, log, and rollback |
| Harness Engineering | [`harness-engineering/HARNESS_ENGINEERING.md`](harness-engineering/HARNESS_ENGINEERING.md) | Manage prompts, agents, and tool use as a testable harness |
| Sourcing | [`sourcing/reliable-search.md`](sourcing/reliable-search.md) | Standards for research, search, and source verification |
| Validation | [`validation/index.md`](validation/index.md) | Standards to satisfy before claiming a task is complete |

## Source management

External sources are cited **inline with the URL and the date it was checked** — in a `Sources` section where a document has one, and next to the claim otherwise. A repository-maintenance ledger such as [`cli/sources.md`](cli/sources.md) is the one allowed exception, defined in [`sourcing/reliable-search.md`](sourcing/reliable-search.md) §7; keeping every other claim next to its evidence costs less than centralizing it.

```bash
bash scripts/check-sources.sh             # date format + document length strict, links advisory
bash scripts/check-sources.sh --strict    # gate on moved links too (before a release)
bash scripts/check-sources.sh --offline   # structural checks only, no network
bash scripts/check-sources.sh --self-test # prove the checks actually catch failures
bun run --cwd scripts lint:sh        # static analysis of the checker itself (needs shellcheck)
```

The `lint:sh` task runs [ShellCheck](https://www.shellcheck.net/) over `scripts/check-sources.sh`. It is a separate opt-in task because ShellCheck is a system tool rather than a dependency of this repository; `bash-language-server` is declared in `scripts/package.json` for editor diagnostics.

- Last full sweep: **2026-07-29**. Targeted re-verification of the AGENTS.md discovery/precedence area, the CLI runtime profiles, the skill and context-engineering references, the harness-engineering source table, the Hermes Agent guides, and the new caching area: **2026-09-19**. Next full re-verification: **2026-10-29**.
- The link check reads inline citations only: it skips fenced code blocks and documentation example URLs on the RFC 2606 reserved domains (`example.com`, `example.net`, `example.org`, `*.example`) and loopback addresses (`localhost`, `127/8`, `[::1]`), and reports how many it skipped — including the URLs inside code blocks that it did not check, so nothing is dropped silently. Every other URL must resolve without a redirect.
- Keep the quarterly re-verification cadence as project policy: vendor documentation changes on its own schedule, and this cadence is our chosen review interval rather than a vendor guarantee. arXiv and standards documents decay differently, so a URL check is enough for those.
- `.hyper/` is covered by `.gitignore`. Research reports under it are a **local re-verification cache** and do not exist in another clone. Shareable evidence is always the URL inside the document.

## Authoring principles

1. **Runtime neutral**: keep model- or vendor-specific rules in a provider profile.
2. **Explicit priority**: always separate scope, authority, required/forbidden, and verification.
3. **Harness first**: for a significant instruction change, ten eval cases beat three examples.
4. **Contract over role**: fix intent, scope, authority, context, output, and verification before persona.
5. **Source grounded**: prefer official documentation, standards, and papers for claims about recency, tool behavior, and security.
6. **Short root, deep reference**: keep top-level documents within 200-300 lines and push detail into `references/`.
7. **Bilingual parity**: `X.md` and `X.ko.md` must carry the same contract. If they disagree, that is a defect, not a translation nuance.

## Recommended loading order

```markdown
@instructions/README.md
@instructions/context-engineering/CONTEXT_ENGINEERING.md
@instructions/context-engineering/references/prompt-authoring.md
@instructions/cache/CACHE.md
@instructions/skill/SKILL_AUTHORING.md
@instructions/skill/references/prompt-loop-eval.md
@instructions/autoresearch/AUTORESEARCH.md
@instructions/harness-engineering/HARNESS_ENGINEERING.md
@instructions/sourcing/reliable-search.md
@instructions/validation/index.md
```

Load the `.ko.md` counterpart instead when the working language is Korean. Do not load both — they carry the same contract and loading both only doubles context.

When you author or revise a prompt, a system message, a tool description, or a skill's loaded text, read [`cache/CACHE.md`](cache/CACHE.md) so the reusable prefix stays stable; its per-provider thresholds are in [`cache/references/provider-cache-facts.md`](cache/references/provider-cache-facts.md).

When work is bound to a specific runtime, also read [`context-engineering/references/runtime-profiles.md`](context-engineering/references/runtime-profiles.md). When using parallel work, subagents, background agents, or agent teams, also read [`context-engineering/references/parallel-workflows.md`](context-engineering/references/parallel-workflows.md). To use per-CLI question, approval, and tool capabilities inside a skill, read [`cli/README.md`](cli/README.md) together with the relevant runtime profile.

When creating, refactoring, or reviewing a repository's `AGENTS.md` or `CLAUDE.md`, read [`agents-md/AGENTS_MD.md`](agents-md/AGENTS_MD.md), then the documents under `agents-md/references/` as needed — `discovery-and-precedence.md` for runtime loading behavior, `content-contract.md` for what earns a line, `claude-md-adapter.md` for coordinating the two files, and `evidence-and-evaluation.md` for what is actually measured.

When creating a new skill or refactoring `skills/*`, read [`skill/SKILL_AUTHORING.md`](skill/SKILL_AUTHORING.md), and add [`skill/references/prompt-loop-eval.md`](skill/references/prompt-loop-eval.md) when prompt/loop/eval design is needed. Read the anatomy, trigger, progressive disclosure, resource placement, and validation documents under `skill/references/` as required.

When designing autoresearch-style iterative improvement, metric optimization, or an autonomous debug/fix/learn/reason loop, read [`autoresearch/AUTORESEARCH.md`](autoresearch/AUTORESEARCH.md), then read further under `autoresearch/references/` according to the metric, verify, guard, log, and rollback criteria you need.

For work where research, recency, and source traceability matter, read [`sourcing/reliable-search.md`](sourcing/reliable-search.md) first, then `sourcing/references/` when a source ledger, citation, or freshness handling is required. For work where completion claims, evals, and agent/tool verification matter, read [`validation/index.md`](validation/index.md) together with `validation/references/`.
