# Core Principles

> Korean version: [`core-principles.ko.md`](core-principles.ko.md)

## 1. Right altitude

An instruction that sits too low becomes an edge-case dump; one that sits too high is not executable.

| Too low | Right altitude | Too high |
|---|---|---|
| Enumerating every conditional | Principle + representative example + verification criteria | "Just handle it well" |
| Pasting per-tool command detail | Naming a capability and a fallback | No mention of tools |
| Assuming a specific model version's behavior | Split into a runtime profile | Ignoring model differences |

### Pattern

```markdown
## Rule
[the principle in one sentence]

## Apply When
[when it applies]

## Example
[one or two good examples]

## Verify
[pass/fail criteria]
```

Anthropic describes the same target as the "Goldilocks zone" between hardcoded brittle logic and vague guidance that "falsely assumes shared context," and pairs it with a sizing rule: aim for "the minimal set of information that fully outlines your expected behavior," noting that "minimal does not necessarily mean short" (checked 2026-11-03). Minimal means every sentence carries a signal, not that the document is short.

## 2. Context is a budget

Context is not an unlimited knowledge store. Every sentence that gets read can conflict with other evidence or push out something important.

| Strategy | Method |
|---|---|
| JIT loading | Keep only a map at the root and load references on demand |
| Deduplication | Keep the same rule in exactly one place |
| Compression | Compress into tables, checklists, and examples |
| Separation | Separate project rule, runtime quirk, and task prompt |
| Compaction safety | For long work, record decisions, verification, and remaining tasks in a separate file |

This is measured, not assumed. Chroma tested 18 models from four families and found that performance degrades as input length grows even when task difficulty is held constant. Adding a single topically related distractor already hurt accuracy, and adding four compounded it; models performed better on shuffled haystacks than on coherently structured ones, so relevance and ordering do not rescue a long prompt (2025-07-14). The practical reading: a longer window buys room, not accuracy, and every low-signal token spends attention that the load-bearing rule needed.

The levers that act on this budget — write, select, compress, isolate — are specified in [`context-management.md`](context-management.md).

## 3. Explicit contract

A good prompt is a contract, not a request. A role prompt likewise must be a work contract with goal, scope, authority, evidence, output, and verification — not "act like an expert."

```xml
<contract>
  <goal>the success state</goal>
  <scope>targets and exclusions</scope>
  <constraints>prohibitions, permissions, security</constraints>
  <evidence>trusted evidence</evidence>
  <actions>permitted tools and actions</actions>
  <verification>proof of completion</verification>
  <output>artifact format</output>
</contract>
```

## 4. Evidence before confidence

- Always look up recent or volatile information.
- Prefer official documentation or repo evidence for technical and API behavior.
- Record research results in a source ledger and a claim-source matrix.
- Do not erase uncertainty; record it as a caveat.

## 5. Eval before optimization

Collect current failure cases before changing an instruction to "look better." Even when using an official prompt optimizer or meta-prompt, confirm regression against the same eval set before shipping to production.

```text
Define -> Test -> Diagnose -> Patch -> Re-run -> Document
```

## Summary

| Principle | Core idea |
|---|---|
| Right altitude | Principle + representative example + verification |
| Context budget | Short root, deep reference |
| Explicit contract | State goal, scope, authority, verification |
| Evidence | Evidence before assertion |
| Eval loop | Prove improvement with tests |

## Sources

> Sources checked 2026-11-03.

| Claim | Source | Published / updated |
|---|---|---|
| Right-altitude definition, "minimal does not necessarily mean short", compaction and note-taking rationale | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2025-09-29, revised 2026-10-18 |
| Input length degrades performance across 18 models with difficulty held constant; distractors compound; coherent haystacks score worse than shuffled ones | <https://www.trychroma.com/research/context-rot> | 2025-07-14 |
| Compaction, clearing, and isolation levers with per-vendor parameters | [`context-management.md`](context-management.md) | checked 2026-11-03 |

## Related

- [`prompt-authoring.md`](prompt-authoring.md): the role prompt authoring template
- [`context-management.md`](context-management.md): the mechanisms that spend or reclaim the budget
- Official sources follow the Sources table in [`../CONTEXT_ENGINEERING.md`](../CONTEXT_ENGINEERING.md) (checked 2026-07-29 for instruction surfaces; link resolution re-checked 2026-11-03).
