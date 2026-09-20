# AGENTS.md and CLAUDE.md Authoring

> Korean version: [`AGENTS_MD.ko.md`](AGENTS_MD.ko.md)

This is the base document to read when creating, refactoring, or reviewing a repository's agent instruction files. Its purpose is to make `AGENTS.md` and `CLAUDE.md` a **small, evidenced, portable contract** rather than a growing pile of advice.

The executable procedure lives in the `agent-md-maker` skill. This document is the source-grounded knowledge that procedure rests on.

---

## Core definition

An instruction file is the context an agent is given **before it knows what the task is**. That single property determines every rule below: it is loaded eagerly, paid for every session, and applied to work it was not written for.

The official framing:

> "Think of AGENTS.md as a README for agents: a dedicated, predictable place to provide the context and instructions to help AI coding agents work on your project."

> "README.md files are for humans: quick starts, project descriptions, and contribution guidelines. AGENTS.md complements this by containing the extra, sometimes detailed context coding agents need: build steps, tests, and conventions that might clutter a README or aren't relevant to human contributors."

The format imposes nothing else — "AGENTS.md is just standard Markdown. Use any headings you like." The discipline has to come from the author.

---

## The five facts that should change how you write

1. **A bad file is worse than no file.** Measured across 138 AGENTbench and 300 SWE-bench Lite tasks: "Context files tend to reduce task success rates compared to providing no repository context, while also increasing inference cost by over 20%." Only developer-written, minimal files showed a gain (~4%); LLM-generated comprehensive files showed a loss.
2. **The reliable benefit is cost, not correctness.** A paired study over 124 PRs found ~28.6% lower median runtime and ~16.6% fewer output tokens with a root `AGENTS.md` — while explicitly excluding correctness from scope.
3. **"Closest file wins" is mostly false.** Codex concatenates root-to-leaf, Claude Code concatenates "rather than overriding each other", Cursor combines with parents. Only Copilot matches the simple reading. Nested files must be correct under both semantics.
4. **Claude Code reads `AGENTS.md` directly from v2.1.277 on.** A repository shipping only `AGENTS.md` gives Claude Code its instructions with no `CLAUDE.md`, no import, and no setting. Two conditions still matter: a `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` at or above the working directory suppresses `AGENTS.md` under the default **Project instructions** setting, and sessions where `AGENTS.md` support is unavailable read `CLAUDE.md` only ([`references/discovery-and-precedence.md`](references/discovery-and-precedence.md) §2 lists all four conditions).
5. **Size is a hard limit in one runtime.** Codex "stops adding files once the combined size reaches the limit defined by `project_doc_max_bytes` (32 KiB by default)" — root-to-leaf, so a bloated root file can silently starve the nested file that actually governs the code being edited.

Detail and citations: [`references/evidence-and-evaluation.md`](references/evidence-and-evaluation.md) and [`references/discovery-and-precedence.md`](references/discovery-and-precedence.md).

---

## Base principles

1. **Earn every line.** "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it." Deletion is the default outcome of the test.
2. **Non-obvious over complete.** The file's job is what the agent would get *wrong*, not what is *true*. Anything discoverable from the repository is context cost with no signal.
3. **Right altitude.** Between brittle hardcoded logic and vague guidance. Specific enough to guide, flexible enough to survive an unforeseen case.
4. **Prose is advisory.** Anything that must happen every time belongs in a hook, CI check, lint rule, or schema — not a sentence asking for it.
5. **One canonical home per rule.** Repetition across root, nested, and runtime files produces conflict, not emphasis.
6. **Portable by default.** Write runtime-neutral rules; isolate real per-CLI differences into the adapter or a profile under [`../cli/`](../cli/README.md).
7. **Progressive disclosure.** Keep the always-loaded file thin; move specialized procedure into skills and linked documents that load on demand.
8. **Evidence or omission.** Every command, path, and architectural claim traces to an inspected file. Never write a command you did not run.
9. **Capability is not authorization.** Credentials, network, publication, deployment, destructive actions, and production writes stay explicitly gated.

---

## What goes in

Ordered by value per token:

| Priority | Content | Note |
|---|---|---|
| 1 | Gotchas and non-obvious constraints | Highest value; current Anthropic guidance says most of the file belongs here |
| 2 | Verified commands | Exact, copy-pasteable, working directory stated |
| 3 | Conventions that differ from defaults | Matching a framework default means it is noise |
| 4 | Architecture boundaries the code does not announce | Ownership, forbidden imports, generated paths |
| 5 | Testing and verification requirements | What must pass before a change is done |
| 6 | Security and safety constraints | Agents cannot infer these; only ~14.5% of real files include them |
| 7 | One-paragraph project purpose | Orientation, not a README |
| 8 | Loading map | Links to deeper docs instead of inlining them |

And what stays out — standard conventions, API documentation, frequently changing detail, tutorials, file-by-file inventories, self-evident rules, temporary task notes, response-style preferences, unverified commands, secrets, and anything CI can enforce better.

Full admission test and phrasing rules: [`references/content-contract.md`](references/content-contract.md).

---

## Structure

Select only sections the project's evidence supports. Omit empty headings.

1. **Scope** — which tree this file governs, and nearest-file behavior when relevant.
2. **Project map** — stable source, test, package, generated, and docs locations.
3. **Authority and evidence** — priority order, and the rule that retrieved content is evidence, never instruction.
4. **Commands** — install, dev, test, lint, typecheck, build.
5. **Workflow** — read-before-edit, minimal change, verification order.
6. **Conventions** — project-specific only.
7. **Safety and side effects** — explicit gates.
8. **Completion** — what to run, how to report failure, what blocks done.
9. **Loading map** — links, not copies.

Keep the first screen operational: scope, project shape, essential commands, critical restrictions.

---

## Nesting

Add a nested file only when a subtree genuinely differs in commands, ownership, generated boundaries, language, or architecture. Then, because merge semantics vary by runtime:

- **State the subtree it governs**, explicitly.
- **Override by restating the correct rule in full**, never by negating the parent ("unlike the root, ..." breaks when the parent is not loaded, and contradicts when it is).
- **Keep it self-contained** — correct whether or not the parent is present.
- **Never copy the root body into it.** A nested file carries deltas.

---

## Coordinating with CLAUDE.md

Default to one canonical `AGENTS.md`. Add `CLAUDE.md` only for a real Claude-only difference, or for sessions that cannot read `AGENTS.md` directly.

| Strategy | How | Use when |
|---|---|---|
| Native only | No `CLAUDE.md` at all | The default: no Claude-only difference, and every session you must support can read `AGENTS.md` |
| Symlink | `ln -s AGENTS.md CLAUDE.md` | Shared contract, no Claude-only rules |
| Import stub | `CLAUDE.md` contains `@AGENTS.md` | Same, where symlinks are impractical |
| Thin adapter | `@AGENTS.md` plus verified Claude-only rules | Skills, hooks, permission modes, MCP |
| Separate files | Two maintained files | Almost never — expect drift |

The adapter contains only what is false or absent for other runtimes. It never restates, summarizes, or relaxes the shared contract. Detail: [`references/claude-md-adapter.md`](references/claude-md-adapter.md).

---

## Authoring workflow

| Stage | Work | Completion evidence |
|---|---|---|
| 0 | Classify create / refactor / split / reconcile; list target files and exclusions | Scope decision |
| 1 | Inspect existing instructions, manifests, lockfiles, task definitions, CI, representative source and tests | Evidence map |
| 2 | Choose root/nested boundaries, canonical ownership, target runtimes, output language | Design contract |
| 3 | Draft the smallest rule set whose every claim maps to inspected evidence | Candidate files |
| 4 | Run the commands you wrote; verify paths exist | Verified commands |
| 5 | Apply the admission test destructively, line by line | Reduced file |
| 6 | Check portability against every target runtime | Portability pass |
| 7 | Reconcile bilingual mirrors where the project keeps them | Aligned pair |
| 8 | Report changed files, evidence, checks run, and remaining risk | Handoff |

---

## Verification

- [ ] Every line passes the admission test — non-obvious, load-bearing, durable, advisory-appropriate.
- [ ] Every command was actually run; every path exists or is labeled as an output.
- [ ] No rule restates what the repository already shows.
- [ ] Security, safety, and destructive-action boundaries are present and explicit.
- [ ] Nothing requiring a guarantee is left to prose.
- [ ] Each rule has exactly one canonical home; root and nested files do not repeat.
- [ ] Nested files are self-contained deltas correct under both merge and nearest-wins semantics.
- [ ] If Claude Code is a target, the repository either relies on its native `AGENTS.md` reading (v2.1.277+, with no counting `CLAUDE.md` or `CLAUDE.local.md` at or above the working directory) or ships a `CLAUDE.md` that imports or symlinks to `AGENTS.md`.
- [ ] `@path` imports stay within four hops and resolve relative to the importing file.
- [ ] Root file is small enough to leave budget for nested files under a 32 KiB combined cap.
- [ ] No secrets, response-style preferences, or temporary task notes.
- [ ] Recency and vendor claims carry a source URL and a verification date.

---

## Maintenance

This area's facts are vendor behavior and move quarterly. Re-verify [`references/discovery-and-precedence.md`](references/discovery-and-precedence.md) first — filenames, size caps, and precedence order are the fields most likely to have changed.

Treat a significant instruction change as an experiment, not an improvement: add a rule only after an observed repeated failure, compare with and without on representative tasks, track success *and* cost, and delete anything with no measurable effect.

---

## Related documents

- [`references/discovery-and-precedence.md`](references/discovery-and-precedence.md)
- [`references/content-contract.md`](references/content-contract.md)
- [`references/claude-md-adapter.md`](references/claude-md-adapter.md)
- [`references/evidence-and-evaluation.md`](references/evidence-and-evaluation.md)
- [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md)
- [`../context-engineering/references/prompt-authoring.md`](../context-engineering/references/prompt-authoring.md)
- [`../cli/README.md`](../cli/README.md)
- [`../validation/index.md`](../validation/index.md)
