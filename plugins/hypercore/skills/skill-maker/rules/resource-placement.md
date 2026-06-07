# Resource Placement

**Purpose**: Put each piece of skill content in the file type that matches its responsibility.

## 1. Placement Matrix

| Content | Placement | Reason |
|---|---|---|
| When to use the skill | `description`, routing rule | Discovery and trigger signal |
| Job, boundary, top-level workflow, stop condition | `SKILL.md` | Always needed after activation |
| Reusable policies and repeated decisions | `rules/` | Applies across runs |
| Official docs, schemas, domain details, long examples | `references/` | Load only when needed |
| Deterministic validation or transformation | `scripts/` | More reliable than prose |
| Templates, fixtures, static output resources | `assets/` | Copied, filled, or embedded into output |
| UI/runtime metadata | `agents/` | Only when a runtime consumes it |

## 2. Decision Order

Ask these in order:

1. Is this the core identity, trigger, boundary, or stop condition?
2. Is this reusable policy or repeated decision guidance?
3. Is this detailed knowledge loaded only when needed?
4. Is this better as deterministic execution?
5. Is this an output resource rather than reasoning context?
6. Is this platform metadata consumed by a runtime or UI?

## 3. Rules vs References

Use `rules/` for judgment:

- when to add scripts
- how to validate trigger examples
- how to handle source-sensitive claims
- how to split core and references

Use `references/` for knowledge:

- official documentation summaries
- API schemas
- long examples
- provider-specific edge cases
- domain glossary

## 4. Scripts

Add scripts only when one or more is true:

- the same check or transform repeats often
- a command sequence is fragile
- machine-readable output is needed
- failure messages help the agent self-correct
- version pinning or parameter normalization improves reliability

Document every script with purpose, usage, dependencies, expected output, and failure behavior.

## 5. Assets

Use assets for files that support output generation:

- report templates
- prompt templates
- JSON schemas
- fixtures
- examples that are copied or filled

Do not use assets for reasoning-only documentation.

## 6. Quality Gate

- [ ] Every support file has a placement reason.
- [ ] Every support file is discoverable from `SKILL.md` or a directly linked rule.
- [ ] Scripts/assets have usage and validation notes.
- [ ] Provider-sensitive content is isolated into references.
- [ ] Core trigger logic is not hidden in references.
