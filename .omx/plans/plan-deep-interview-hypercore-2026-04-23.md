# Deep-Interview Skill Plan

## Requirements Summary

- Create a new `deep-interview` skill modeled on the referenced `oh-my-claudecode` deep-interview skill, but adapt it to this repository's local skill-writing conventions and storage patterns.
- Store the deliverable under `.hypercore/deep-interview/[name]/` instead of `skills/` or `.omc/`; for this plan, assume `[name] = deep-interview` unless a different slug is requested later.
- Produce exactly two files in that folder: `SKILL.md` and `SKILL.ko.md`.
- Keep the skill self-contained: do not depend on extra `rules/`, `references/`, or `assets/` files unless the user later asks for a larger packaged skill.
- Preserve the core behavior of the source skill: one-question-at-a-time Socratic interviewing, ambiguity scoring, weakest-dimension targeting, brownfield-first codebase confirmation, spec crystallization, and explicit readiness gating.
- Replace OMC-specific storage and execution-bridge assumptions with hypercore-local wording and `.hypercore`-aligned artifact examples.

Evidence and references:
- Repo-local bilingual skill structure already uses paired `SKILL.md` / `SKILL.ko.md` files with mirrored sections at [skills/bug-fix/SKILL.md#L1-L156](/Users/alpox/Desktop/dev/kood/hypercore/skills/bug-fix/SKILL.md#L1-L156) and [skills/bug-fix/SKILL.ko.md#L1-L156](/Users/alpox/Desktop/dev/kood/hypercore/skills/bug-fix/SKILL.ko.md#L1-L156).
- Repo-local `.hypercore` folder contracts consistently use per-skill or per-topic slug folders at [skills/prd-maker/SKILL.md#L104-L201](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/SKILL.md#L104-L201), [skills/crawler/SKILL.md#L134-L172](/Users/alpox/Desktop/dev/kood/hypercore/skills/crawler/SKILL.md#L134-L172), and [skills/autoresearch-skill/SKILL.md#L166-L169](/Users/alpox/Desktop/dev/kood/hypercore/skills/autoresearch-skill/SKILL.md#L166-L169).
- Existing `.hypercore` contents in this repo already follow namespaced subfolders such as `.hypercore/autoresearch-skill/...` and `.hypercore/research/...`, confirmed by repository inspection on 2026-04-23.
- The referenced source skill emphasizes mathematical ambiguity gating, weakest-dimension targeting, ontology tracking, and brownfield exploration before user questions (GitHub raw reference: https://raw.githubusercontent.com/Yeachan-Heo/oh-my-claudecode/main/skills/deep-interview/SKILL.md, especially lines 1-8, 12-29, and 34-40).

## Acceptance Criteria

- `.hypercore/deep-interview/deep-interview/SKILL.md` exists.
- `.hypercore/deep-interview/deep-interview/SKILL.ko.md` exists.
- Both files share the same structure and intent, with Korean text being a real adaptation rather than a partial mirror.
- The English and Korean skill bodies both explain:
  - when to use the skill
  - when not to use it
  - one-question-at-a-time interviewing
  - ambiguity scoring and threshold gating
  - weakest-dimension targeting
  - brownfield codebase exploration before asking the user about repo facts
  - challenge/pressure-test rounds
  - final spec/output crystallization
- The skill body does not reference nonexistent repo-local support files.
- The skill body uses `.hypercore`-style storage examples instead of `.omc/specs/`.
- The generated skill remains understandable as a standalone artifact even when read outside the OMX runtime.

## Implementation Steps

1. Lock the storage contract
- Use the repository's established pattern of `.hypercore/<skill>/<slug>/...` rather than `.omc/...` or top-level `skills/...`, following [skills/prd-maker/SKILL.md#L108-L119](/Users/alpox/Desktop/dev/kood/hypercore/skills/prd-maker/SKILL.md#L108-L119), [skills/crawler/SKILL.md#L139-L167](/Users/alpox/Desktop/dev/kood/hypercore/skills/crawler/SKILL.md#L139-L167), and [skills/autoresearch-skill/SKILL.md#L166-L169](/Users/alpox/Desktop/dev/kood/hypercore/skills/autoresearch-skill/SKILL.md#L166-L169).
- Create `.hypercore/deep-interview/deep-interview/` as the initial folder unless the user later provides a different slug.

2. Define the adapted product boundary
- Reframe the source skill from OMC-specific pipeline language into a hypercore-local skill artifact.
- Keep the job as requirements clarification and spec crystallization, not direct implementation.
- Explicitly state that the skill should stop at the saved spec/handoff point, mirroring the requirements-agent boundary from the source reference.

3. Author the English canonical skill
- Create `.hypercore/deep-interview/deep-interview/SKILL.md` with repo-familiar sectioning similar to local skills: frontmatter, title, purpose, routing/trigger sections, workflow phases, required behaviors, forbidden behaviors, and output/storage contract, informed by [skills/bug-fix/SKILL.md#L1-L156](/Users/alpox/Desktop/dev/kood/hypercore/skills/bug-fix/SKILL.md#L1-L156).
- Adapt the remote deep-interview content into self-contained sections:
  - request routing / out-of-scope
  - interview initialization
  - ambiguity scoring model
  - ontology/entity stabilization guidance
  - challenge modes
  - crystallization and saved output contract
  - execution handoff guidance expressed generically rather than OMC-only `Skill()` calls

4. Localize the storage/output examples inside the skill
- Replace source examples like `.omc/specs/deep-interview-{slug}.md` with a hypercore-local artifact contract, for example:
  - `.hypercore/deep-interview/[topic-slug]/spec.md`
  - optional `.hypercore/deep-interview/[topic-slug]/transcript.md`
  - optional `.hypercore/deep-interview/[topic-slug]/flow.json` if resumability is described
- Keep the created deliverable for this task limited to `SKILL.md` and `SKILL.ko.md`, but make the skill text itself describe where future interview outputs should be saved.

5. Create the Korean mirror
- Write `.hypercore/deep-interview/deep-interview/SKILL.ko.md` as a faithful Korean adaptation of the finalized English structure.
- Mirror section ordering and operational rules so both files stay diff-friendly and maintainable, following the pattern visible in [skills/bug-fix/SKILL.md#L1-L156](/Users/alpox/Desktop/dev/kood/hypercore/skills/bug-fix/SKILL.md#L1-L156) and [skills/bug-fix/SKILL.ko.md#L1-L156](/Users/alpox/Desktop/dev/kood/hypercore/skills/bug-fix/SKILL.ko.md#L1-L156).

6. Validate the skill text before closing
- Check that both files are self-contained and contain no dangling references to absent `rules/`, `references/`, or external runtime-only helpers.
- Check that the storage path examples consistently use `.hypercore/deep-interview/...`.
- Check that the interviewing logic still preserves the source skill's strongest mechanics: weakest-dimension targeting, ambiguity gate, ontology convergence, and anti-batching.

## Risks and Mitigations

- Risk: the adapted skill stays too tied to OMC/Claude-specific runtime features like `AskUserQuestion`, `state_write`, or `Skill()`.
  Mitigation: rewrite those instructions into platform-agnostic behavior descriptions unless a local equivalent clearly exists in this repo.

- Risk: the skill becomes too large because the source file packs many advanced behaviors into one document.
  Mitigation: keep the first version self-contained but prune duplicated narrative, keeping durable rules and operational steps only.

- Risk: `.hypercore/deep-interview/[name]/` could be interpreted either as the skill-definition folder or the runtime artifact folder.
  Mitigation: make the plan explicit: this task creates the skill-definition folder at `.hypercore/deep-interview/deep-interview/`, and the skill text separately documents recommended runtime output paths.

- Risk: Korean and English files drift semantically.
  Mitigation: finalize the English canonical structure first, then mirror section order and verification checkpoints in Korean.

## Verification Steps

- Confirm the folder `.hypercore/deep-interview/deep-interview/` exists.
- Confirm both `SKILL.md` and `SKILL.ko.md` exist in that folder.
- Confirm both files include a clear use-when / do-not-use boundary.
- Confirm both files explicitly forbid batching multiple interview questions in one round.
- Confirm both files describe ambiguity scoring and a stop/go threshold.
- Confirm both files cite `.hypercore/deep-interview/...` as the storage pattern in examples.
- Confirm neither file references missing repo-local support files.

## Planned Files

- `.hypercore/deep-interview/deep-interview/SKILL.md`
- `.hypercore/deep-interview/deep-interview/SKILL.ko.md`

## Simplifications Planned

- Keep the first version as a two-file self-contained skill instead of creating a larger packaged skill tree.
- Use the existing bilingual skill structure already proven in this repo instead of inventing a new documentation format.
- Convert OMC-specific execution bridging into generic handoff guidance instead of reproducing the full external runtime contract.

## Remaining Risks

- The exact runtime output artifact set for future deep-interview runs (`spec.md` only vs `spec.md + transcript.md + flow.json`) will still need one implementation decision during authoring.
- If the user later wants this skill to be directly installable by Codex/Claude without copying, the storage location may need a second pass from `.hypercore/...` to a real local skill directory.
