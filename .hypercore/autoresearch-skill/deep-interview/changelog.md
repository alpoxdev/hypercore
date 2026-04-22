## Experiment 0 - baseline

**Score:** 23/25 (92.0%)
**Change:** Initial deep-interview skill created from the saved plan with bilingual core files.
**Reasoning:** Establish a clean baseline before any optimization. The first version already covers one-question interviewing, ambiguity scoring, ontology tracking, brownfield evidence-first behavior, and `.hypercore` artifact storage.
**Result:** Strong baseline. Remaining misses were trigger-boundary clarity for route-away neighbors in some boundary prompts and the lack of an explicit self-contained support-file note.
**Failing outputs:**
- Boundary prompts imply handoff, but the neighboring lane is not named explicitly enough.
- The skill is self-contained, but the core file does not yet say so directly.

## Experiment 1 - keep

**Score:** 25/25 (100.0%)
**Change:** Added explicit route-away defaults for out-of-scope/boundary prompts and a self-contained support-files section in both `SKILL.md` and `SKILL.ko.md`.
**Reasoning:** The baseline's remaining misses were not about the interview mechanics; they were about what neighboring lane should own route-away cases and whether maintainers could tell that no extra support files were needed.
**Result:** Trigger-boundary and next-action ambiguity for brainstorming and already-scoped prompts disappeared. The skill now states its neighboring lanes and support-file posture directly in core.
**Failing outputs:** None in the current eval set.
