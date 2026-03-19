# Skill Anti-Patterns

**Purpose**: Prevent common failures in skill authoring.

## Avoid

- descriptions that are too vague to trigger reliably
- `SKILL.md` bodies that become mini-wikis
- duplicated detail across core and references
- references nested so deeply they are hard to discover
- extra docs like `README.md`, `CHANGELOG.md`, or `QUICK_REFERENCE.md` inside the skill
- time-sensitive provider details in canonical core instructions
- scripts added without a clear reliability justification
- too many options when the skill should recommend a path

## Red Flags

- "This skill helps with many things"
- "See these five different approaches" without guidance
- multiple files repeating the same definitions
- old provider guidance mixed into current core rules
- validation omitted because "the structure looks good"
