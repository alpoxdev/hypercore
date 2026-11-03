# Content Contract

> Korean version: [`content-contract.ko.md`](content-contract.ko.md)

**Purpose**: decide what earns a line in an instruction file and what must stay out.

The governing question is not "is this true about the project?" but **"would the agent get this wrong without being told?"** Most of what people write into these files fails that test.

---

## 1. The admission test

Every candidate line must pass all four gates. One failure means it does not belong.

| Gate | Question | Fails when |
|---|---|---|
| **Non-obvious** | Can the agent discover this by reading the repo? | Restating the directory tree, framework defaults, or what `package.json` already shows |
| **Load-bearing** | Would removing it cause a mistake? | "Write clean code", "follow best practices", "be careful" |
| **Durable** | Will it still be true next month? | Sprint notes, current ticket, in-flight migration state |
| **Advisory-appropriate** | Is prose the right enforcement mechanism? | Anything that must happen *every* time — that is a hook, CI check, lint rule, or schema |

Anthropic states the second gate as an admission rule plus a pruning rule:

> "Add to it when: Claude makes the same mistake a second time"

> "the file works best when it only holds what Claude couldn't work out from the code itself"

Apply it destructively. The default outcome of the test is deletion, and the current docs even automate the judgment: "`/doctor` suggests cuts for anything Claude can already work out from the code."

---

## 2. What belongs in

Ordered roughly by value per token.

1. **Gotchas and non-obvious constraints** — the things that burned a human. This is the single highest-value category, and Anthropic's own guidance says so: "spend most of the tokens on gotchas inside of the codebase".
2. **Verified commands** — install, dev, test, lint, typecheck, build. Exact, copy-pasteable, with the working directory stated. Never a command you did not run.
3. **Project-specific conventions that differ from defaults** — if it matches the framework default, it is noise.
4. **Architecture and boundaries the code does not announce** — module ownership, what may not import what, generated paths that must not be hand-edited.
5. **Testing and verification requirements** — which runner, what must pass before a change is considered done.
6. **Security and safety constraints** — credential handling, network boundaries, destructive/production gates. Agents cannot infer these and will guess. Descriptive study data shows only ~14.8% of real files include security content, which makes this the most common dangerous omission.
7. **A brief statement of project purpose** — one paragraph, enough to orient. Not a README.
8. **A loading map** — links to deeper local docs instead of inlining them.

Anthropic's current guidance names four things to include: how to confirm work in the repository (the exact test, typecheck, and lint commands), places where the code misleads, decisions that are not in the repo, and anything already corrected twice.

---

## 3. What stays out

| Excluded | Why |
|---|---|
| Standard conventions the model already knows | Pure context cost |
| Detailed API documentation | Belongs in docs, loaded on demand |
| Frequently changing information | Goes stale, then actively misleads |
| Long explanations and tutorials | Not decision-changing |
| File-by-file codebase descriptions | The agent can read the tree |
| Self-evident rules ("write clean code") | Unfalsifiable, changes nothing |
| Task-specific or temporary notes | Misapplies to unrelated work |
| Response style, tone, verbosity preferences | User settings, not project knowledge |
| Unverified commands | Worse than absence |
| Secrets, credentials, sensitive vulnerability detail | Instruction files are committed and widely readable |
| Rules better enforced by CI, hooks, permissions, or schemas | Prose cannot guarantee anything |

GitHub's documentation names three of these explicitly as things to avoid:

> "Requests to refer to external resources when formulating a response"
> "Instructions to answer in a particular style"
> "Requests to always respond with a certain level of detail"

and characterizes effective content as short and self-contained:

> "Custom instructions consist of natural language instructions and are most effective when they are short, self-contained statements."

---

## 4. Writing at the right altitude

Anthropic's framing of the central authoring failure mode:

> "System prompts should be extremely clear and use simple, direct language that presents ideas at the right altitude for the agent. The right altitude is the Goldilocks zone between two common failure modes. At one extreme, we see engineers hardcoding complex, brittle logic in their prompts to elicit exact agentic behavior. This approach creates fragility and increases maintenance complexity over time. At the other extreme, engineers sometimes provide vague, high-level guidance that fails to give the LLM concrete signals for desired outputs or falsely assumes shared context. The optimal altitude strikes a balance: specific enough to guide behavior effectively, yet flexible enough to provide the model with strong heuristics to guide behavior."

In practice:

| Too low (brittle) | Right altitude | Too high (vague) |
|---|---|---|
| "If the file is under `src/api` and the method is POST and the handler returns a promise, then wrap it in `withRetry`" | "All outbound API handlers go through `withRetry`; see `src/api/client.ts`" | "Handle errors properly" |
| Enumerating every forbidden import pair | "`core/` must not import from `features/`" | "Keep the architecture clean" |
| A decision tree for choosing a test runner | "Run `bun test`; integration tests need `--preload ./test/setup.ts`" | "Test your changes" |

The test for correct altitude: **a competent new contributor could act on it without asking a follow-up question, and it would not break the moment an unforeseen case appears.**

---

## 5. Phrasing rules

- Prefer `Run <verified command>` over "test thoroughly".
- Prefer `Do not edit <evidenced generated path>` over "be careful with generated files".
- Name a scope or an observable check in every rule.
- Use one term per concept, and keep the project's existing vocabulary.
- Give a reason only when it changes judgment. Skip motivational prose.
- Distinguish MUST / SHOULD / MAY only where the distinction actually changes behavior.
- State the working directory whenever a command is not run from the repository root.

---

## 6. Newer models need fewer rules

Current Anthropic guidance warns against over-constraining and recommends giving models room for judgment rather than rigid rules: "Then: Give Claude rules Now: Let Claude use judgement". The stated evidence is large: "We removed over 80% of Claude Code's system prompt for models like Claude Opus 5 and Claude Fable 5 with no measurable loss on our coding evaluations." The same post names repetition across surfaces as a failure mode, and warns that an instruction file should not become "a central repository for every known practice that you might run into".

Two consequences for authoring:

1. **Do not repeat a rule to make it stronger.** One canonical home per rule. Repetition produces drift, not emphasis.
2. **Prefer progressive disclosure to completeness.** Put specialized procedures in a skill or a linked document and reference it, rather than growing the always-loaded file. Anthropic's stated escape hatch is exactly this: "Move reference material to skills, which load on-demand."

---

## 7. Quality gate

- [ ] Every line passes the four admission gates.
- [ ] Commands are exact, evidenced, and were actually run.
- [ ] Paths exist, or are explicitly labeled as outputs to be created.
- [ ] No rule restates what the repository already shows.
- [ ] Security, safety, and destructive-action boundaries are present.
- [ ] Nothing that requires a guarantee is left to prose.
- [ ] No secrets, response-style preferences, or temporary task notes.
- [ ] Deeper material is linked, not inlined.
- [ ] Each rule has exactly one canonical home.

---

## Sources

| Source | URL | Checked |
|---|---|---|
| Anthropic — Claude Code best practices | <https://code.claude.com/docs/en/best-practices> | 2026-11-03 |
| Anthropic — effective context engineering | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2026-11-03 |
| Claude Code memory documentation | <https://code.claude.com/docs/en/memory> | 2026-11-03 |
| Claude Code features overview | <https://code.claude.com/docs/en/features-overview> | 2026-11-03 |
| New rules of context engineering (Claude 5) | <https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/> | 2026-11-03 |
| GitHub Copilot custom instructions | <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> | 2026-11-03 |

## Related documents

- [`../AGENTS_MD.md`](../AGENTS_MD.md)
- [`discovery-and-precedence.md`](discovery-and-precedence.md)
- [`evidence-and-evaluation.md`](evidence-and-evaluation.md)
- [`../../context-engineering/references/prompt-authoring.md`](../../context-engineering/references/prompt-authoring.md)
