# Progressive Disclosure

**Purpose**: Keep skills lean while still making deeper detail discoverable.

## 1. Three Layers

Use this loading model:

1. metadata
2. core `SKILL.md`
3. rules, references, scripts, assets

The deeper the layer, the more specific and optional the content should become.

## 2. Keep the Core Lean

The core skill should contain:

- the job
- the trigger
- the workflow
- pointers to deeper files

Move out:

- long examples
- official source summaries
- domain schemas
- variant-specific details

## 3. One Level Deep

Prefer references linked directly from `SKILL.md`.
Avoid deeply nested chains of references.

## 4. Split by Need

Move content to:

- `rules/` for repeated policy
- `references/` for detailed knowledge
- `scripts/` for deterministic execution
- `assets/` for output resources

## 5. Readback Check

After splitting:

- confirm the core still makes sense on its own
- confirm support files are findable
- confirm no key instruction is duplicated across layers
