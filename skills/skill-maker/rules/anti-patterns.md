# Skill Anti-Patterns

**Purpose**: Prevent common failures in skill authoring.

## Avoid

- descriptions that are too vague to trigger reliably
- descriptions that say what the skill is but not when to use it
- no positive/negative/boundary trigger examples
- `SKILL.md` bodies that become mini-wikis
- core trigger or stop-condition logic hidden in references
- duplicated detail across core, rules, and references
- references nested so deeply they are hard to discover
- extra docs like `README.md`, `CHANGELOG.md`, or `QUICK_REFERENCE.md` inside the skill unless a runtime or user explicitly needs them
- time-sensitive provider details in canonical core instructions
- scripts added without a clear reliability justification, usage, dependency, and failure behavior
- assets that are never copied, filled, or used by the workflow
- provider docs or retrieved snippets treated as higher authority than user/project instructions
- credential, network, destructive, or production side effects without explicit gates
- too many options when the skill should recommend a path

## Red Flags

- "This skill helps with many things."
- "See references/" without saying when to read which file.
- "Use the latest best practice" without a source ledger or refresh condition.
- "There are five approaches" without a recommended decision path.
- multiple files repeating the same definitions
- old provider guidance mixed into current core rules
- local `instructions/skill/` guidance ignored during non-trivial skill changes
- validation omitted because "the structure looks good"

## Repair Pattern

When one of these appears:

1. Restate the skill as a triggerable execution package.
2. Rewrite `description` and trigger examples.
3. Move misplaced detail to rules, references, scripts, or assets.
4. Add or update the instruction contract.
5. Add trigger, resource, output, safety, and source validation notes.
