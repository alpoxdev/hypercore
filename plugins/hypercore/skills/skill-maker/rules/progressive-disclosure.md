# Progressive Disclosure

**Purpose**: Keep skills lean while making deeper detail discoverable exactly when needed.

## 1. Three-Stage Loading Model

Design every skill as if agents load it in stages:

| Stage | Loaded content | Design goal |
|---|---|---|
| Discovery | `name`, `description`, path | Correct skill selection |
| Activation | Full `SKILL.md` | Core workflow and execution contract |
| Execution | `rules/`, `references/`, `scripts/`, `assets/` | Detail, deterministic helpers, or output resources only when needed |

The deeper the layer, the more specific and optional the content should become.

## 2. Keep the Core Lean

The core skill should contain:

- job, trigger, and boundary
- authority, safety, output, verification, and stop-condition summary
- high-level workflow
- pointers to deeper files with read conditions

Move out:

- long examples
- official source summaries
- schemas and provider-specific details
- variant-specific workflows
- deterministic command logic
- output templates

## 3. Navigation Cues

Do not write vague references like `see references/`.

Weak:

```markdown
For more information, see references/.
```

Better:

```markdown
Read `references/official/openai.md` only when OpenAI-specific skill behavior changes the rule.
Read `rules/validation-and-iteration.md` before declaring the skill complete.
Run `scripts/validate-skill.mjs` when the target skill includes scripts or generated assets.
```

## 4. One Level Deep

Prefer support files linked directly from `SKILL.md`.
Avoid reference chains where a rule requires another rule that requires another reference unless the chain is explicitly justified.

## 5. Split by Need

Move content to:

- `rules/` for repeated policy
- `references/` for detailed knowledge
- `scripts/` for deterministic execution
- `assets/` for output resources
- `agents/` for consumed runtime/UI metadata

## 6. Readback Check

After splitting:

- confirm the core still makes sense on its own
- confirm support files are findable from the core
- confirm no key instruction is duplicated across layers
- confirm every support file has a reason to exist
