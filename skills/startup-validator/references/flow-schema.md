# Startup Validator Flow Schema

> JSON schema for `.hypercore/startup-validator/[topic-slug]/flow.json`.

## Schema

```json
{
  "id": "sv-{topic-slug}-{YYYYMMDD-HHmmss}",
  "skill": "startup-validator",
  "status": "in_progress | completed",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "topic": "topic-slug",
  "request": {
    "idea": "startup idea description",
    "context": "additional context if any"
  },
  "current_phase": "frame | score | pmf | verdict",
  "phases": {
    "frame": {
      "status": "pending | in_progress | completed",
      "output_file": "thesis.md"
    },
    "score": {
      "status": "pending | in_progress | completed",
      "output_file": "thiel-scores.md"
    },
    "pmf": {
      "status": "pending | in_progress | completed",
      "output_file": "pmf-forces.md"
    },
    "verdict": {
      "status": "pending | in_progress | completed",
      "output_file": "verdict.md",
      "total_score": null,
      "grade": null
    }
  }
}
```

## Phase outputs

| Phase | File | Content |
|-------|------|---------|
| `frame` | `thesis.md` | One-line thesis, value hypothesis, growth hypothesis, key unknowns |
| `score` | `thiel-scores.md` | 7 questions: per-question score + rationale + improvement direction |
| `pmf` | `pmf-forces.md` | PMF checklist, Forces of Progress (Push/Pull/Habit/Anxiety), switching probability |
| `verdict` | `verdict.md` | Total score/grade, critical weaknesses with severity, improvement roadmap |

## Example: initial state

```json
{
  "id": "sv-ai-education-20260327-100000",
  "skill": "startup-validator",
  "status": "in_progress",
  "created_at": "2026-03-27T10:00:00Z",
  "updated_at": "2026-03-27T10:00:00Z",
  "topic": "ai-education",
  "request": {
    "idea": "AI 기반 교육 서비스",
    "context": "직장인 대상 마이크로러닝"
  },
  "current_phase": "frame",
  "phases": {
    "frame": { "status": "in_progress", "output_file": "thesis.md" },
    "score": { "status": "pending", "output_file": "thiel-scores.md" },
    "pmf": { "status": "pending", "output_file": "pmf-forces.md" },
    "verdict": { "status": "pending", "output_file": "verdict.md" }
  }
}
```
