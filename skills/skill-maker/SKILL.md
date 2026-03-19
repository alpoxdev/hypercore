---
name: skill-maker
description: Create and refactor Codex skills that are easy to trigger, easy to understand, and easy to maintain, including SKILL.md, rules, references, scripts, assets, and validation guidance.
compatibility: Works best with read/edit/write and shell search tools for skill analysis, example gathering, and validation checks.
---

@rules/skill-anatomy.md
@rules/trigger-design.md
@rules/progressive-disclosure.md
@rules/resource-placement.md
@rules/validation-and-iteration.md
@rules/anti-patterns.md

# Skill Maker

> Create and refactor skills as first-class products, not just markdown files.

<purpose>

- Build new skills that trigger reliably from user intent and metadata.
- Refactor existing skills to improve scope clarity, resource placement, and validation.
- Teach the right split between `SKILL.md`, `references/`, `scripts/`, `assets/`, and optional UI metadata.

</purpose>

<routing_rule>

Use `skill-maker` when the output is a skill folder or a refactor of an existing skill.

Use `docs-maker` instead when the output is a general document, runbook, spec, or prompt artifact without a skill structure.

Do not use `skill-maker` when:

- the user wants general documentation rather than a skill
- the output is only a prompt, plan, or spec without a skill structure
- `docs-maker` is sufficient because the task is about generic structured documentation

</routing_rule>

<trigger_conditions>

| Situation | Mode |
|------|------|
| A new skill needs to be created | create |
| An existing skill is too long, weakly scoped, or hard to trigger | refactor |
| A skill needs better `description` or trigger wording | refactor |
| A skill needs better `references/`, `scripts/`, or `assets/` placement | create/refactor |
| A team wants one consistent skill-authoring shape | create/refactor |

</trigger_conditions>

<supported_targets>

- New skill folders
- Existing skill refactors
- `SKILL.md` metadata and body
- Skill rule packs
- Skill references, scripts, and assets placement
- Skill validation checklists and forward-test plans

</supported_targets>

<skill_architecture>

Use this layering model by default:

- Core skill: durable instructions for what the skill does and when to use it
- Rules: reusable policy and workflow details
- References: detailed information loaded only when needed
- Scripts/assets: deterministic execution helpers or output resources

Do not overload the core `SKILL.md` with information that belongs in rules or references.

</skill_architecture>

<reference_routing>

Read official references when:

- provider-sensitive skill guidance affects the core rule
- trigger behavior or evaluation guidance depends on vendor docs
- maintenance or drift handling requires current vendor policy

Read the local `skill-creator` summary when:

- deciding how much detail belongs in the core skill
- deciding whether to add scripts or bundled resources
- deciding whether a support file is optional, recommended, or unnecessary

</reference_routing>

<mandatory_reasoning>

## Mandatory Sequential Thinking

- Always use `sequential-thinking` before major skill creation or refactor work.
- In create mode: design the trigger, anatomy, resource split, and validation strategy first.
- In refactor mode: identify weak triggering, mixed concerns, poor resource placement, and missing validation before editing.
- Do not write or refactor a skill until the structure plan is clear.

</mandatory_reasoning>

<design_defaults>

Apply these defaults to every major skill edit:

- Optimize first for triggerability, then readability.
- Keep the core skill lean and push detail downward.
- Prefer concrete examples of user utterances over abstract claims about when the skill is useful.
- Treat validation as part of the skill, not an afterthought.
- Keep provider-sensitive guidance in references, not in the core skill.

</design_defaults>

<modes>

## create mode

- Start from the smallest viable skill shape.
- Add only the rules, references, scripts, and examples that materially improve the skill.
- Include enough validation to prove the skill would trigger and operate correctly.

## refactor mode

- Preserve the skill's intended job unless the current scope is clearly wrong.
- Improve trigger wording, anatomy, and resource placement before adding more content.
- Remove duplication, vague guidance, and unused resources.

</modes>

<default_outputs>

Default output shapes:

- create mode: new skill folder + core `SKILL.md` + needed rules/references/scripts/assets + validation checklist
- refactor mode: updated skill + better resource split + explicit simplification summary + validation notes

</default_outputs>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Confirm the target scope and whether this is a skill, not just a document | Scope decision |
| 1 | Read the target skill or representative comparable skills | Baseline |
| 2 | Build the structure plan with `sequential-thinking` | Section/resource plan |
| 3 | Write or refactor the core `SKILL.md` | Updated core skill |
| 4 | Place supporting detail into rules, references, scripts, or assets | Supporting files |
| 5 | Run trigger, anatomy, and validation readback checks | Review notes |
| 6 | Finalize with explicit validation and remaining risks | Finalized skill |

### Phase 3 authoring rules

- Make the `description` specific about both capability and trigger conditions.
- Keep the first screen of `SKILL.md` enough to explain the skill's job and boundary.
- Use one term per concept across the skill.
- Prefer examples of real user requests that should trigger the skill.
- Put skill-specific structure rules into `rules/`, not into a swollen core body.
- Keep the core skill durable across provider and model churn.

</workflow>

<forbidden>

| Category | Avoid |
|------|------|
| Triggering | Generic descriptions that could match many unrelated requests |
| Structure | Huge `SKILL.md` bodies that duplicate references |
| Resources | Deeply nested references or unused scripts/assets |
| Validation | Declaring a skill complete without trigger and usage checks |
| Drift | Time-sensitive provider details in canonical core instructions |

</forbidden>

<required>

| Category | Required |
|------|------|
| Triggerability | Specific `name` and `description` that reflect real user wording |
| Anatomy | Clear split between `SKILL.md`, rules, references, scripts, and assets |
| Actionability | Concrete workflow steps and validation checks |
| Examples | Trigger examples and folder-shape examples |
| Maintainability | Progressive disclosure and low-duplication design |
| Validation | Trigger tests, resource-placement checks, and forward-test guidance |

</required>

<structure_blueprint>

Use this layout unless a better skill-specific structure is required:

1. Purpose
2. Trigger conditions
3. Supported targets
4. Skill architecture
5. Workflow
6. Examples
7. Validation checklist
8. References when provider-sensitive guidance exists

</structure_blueprint>

<usage_examples>

### Example: create a new skill

- Define what job the skill owns.
- Write the trigger description from realistic user requests.
- Decide what stays in `SKILL.md` and what moves to `rules/` or `references/`.
- Add scripts only if deterministic execution is better than prose.
- Add validation for trigger quality and real-use coverage.

### Example: refactor an overgrown skill

- Read the current `SKILL.md`, rules, and references.
- Mark duplicated content and misplaced detail.
- Rewrite the description so it triggers on the right requests.
- Split long detail into references or scripts.
- Re-read the skill as if you were a new maintainer and a trigger model.

### Example: requests that should not trigger skill-maker

- "Rewrite this product requirements document"
- "Research the best React state libraries"
- "Refactor this runbook for readability"

</usage_examples>

<validation>

| Check | Rule |
|------|------|
| Trigger quality | `description` states what the skill does and when to use it |
| Scope clarity | The skill boundary is obvious in the first screen |
| Resource placement | Core body, rules, references, scripts, and assets each hold the right content |
| Density | Repetition is removed and the core body stays lean |
| Examples | Trigger examples match likely user requests |
| Safety | Time-sensitive or provider-sensitive guidance is isolated into references |
| Validation | The skill includes realistic checks, not only prose review |

Completion checklist:
- [ ] Mode decided (`create` or `refactor`)
- [ ] Sequential-thinking plan created first
- [ ] Trigger wording reviewed (`rules/trigger-design.md`)
- [ ] Skill anatomy reviewed (`rules/skill-anatomy.md`)
- [ ] Progressive disclosure reviewed (`rules/progressive-disclosure.md`)
- [ ] Resource placement reviewed (`rules/resource-placement.md`)
- [ ] Validation and forward-test checks reviewed (`rules/validation-and-iteration.md`)
- [ ] Anti-pattern checks reviewed (`rules/anti-patterns.md`)
- [ ] Core skill remains lean and coherent
- [ ] Validation checks completed

Must-pass thresholds:
- [ ] At least 3 positive trigger examples
- [ ] At least 2 negative trigger examples
- [ ] At least 1 boundary trigger example
- [ ] No reference chain deeper than one level from `SKILL.md`
- [ ] Core `SKILL.md` body stays under roughly 300 lines unless explicitly justified
- [ ] No duplicated definitions across core and references

</validation>
