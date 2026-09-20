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

## 2. Context is a budget

Context is not an unlimited knowledge store. Every sentence that gets read can conflict with other evidence or push out something important.

| Strategy | Method |
|---|---|
| JIT loading | Keep only a map at the root and load references on demand |
| Deduplication | Keep the same rule in exactly one place |
| Compression | Compress into tables, checklists, and examples |
| Separation | Separate project rule, runtime quirk, and task prompt |
| Compaction safety | For long work, record decisions, verification, and remaining tasks in a separate file |

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

## Related

- [`prompt-authoring.md`](prompt-authoring.md): the role prompt authoring template
- Official sources follow the Sources table in [`../CONTEXT_ENGINEERING.md`](../CONTEXT_ENGINEERING.md) (checked 2026-07-29; link resolution re-checked 2026-09-19).
- Local re-verification cache (untracked, covered by `.gitignore`): `.hyper/research/2026-06-02-official-llm-prompt-instructions-update.md`
