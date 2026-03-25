# Validation

Use this checklist before declaring the PRD work complete.

## Required checks

- The request really called for a PRD and not a general plan, doc, or research memo.
- The folder exists under `.hypercore/prd/[slug]/`.
- Both `prd.md` and `sources.md` exist.
- The PRD includes explicit goals, scope, non-goals, requirements, metrics, risks or dependencies, open questions, and change history.
- Any research-backed non-obvious claim in the PRD has a link.
- `sources.md` contains distinct queries or an explicit note that no external research was needed.
- When the PRD was updated, the change history shows what changed and why.
- Unknowns are visible as open questions or assumptions, not silently omitted.

## Quality checks

- The PRD is concise enough to scan quickly.
- The main document contains decisions; the evidence log contains source accumulation.
- The scope is narrow enough that engineering and design can tell what is in and out.
- Requirements are described as product behavior or outcomes, not implementation mandates unless that constraint is genuinely required.

## Forward-test questions

- Would a new teammate understand what problem this initiative solves?
- Could engineering tell what is required versus intentionally out of scope?
- Could someone revisit the PRD next month and see what changed?
- If the evidence shifts, is there a nearby source log that can be refreshed without rewriting everything?
