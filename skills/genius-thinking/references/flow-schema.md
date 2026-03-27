# Genius Thinking Flow Schema

> JSON schema for `.hypercore/genius-thinking/[topic-slug]/flow.json`.

## Schema

```json
{
  "id": "gt-{topic-slug}-{YYYYMMDD-HHmmss}",
  "skill": "genius-thinking",
  "status": "in_progress | completed",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "topic": "topic-slug",
  "request": {
    "challenge": "problem or opportunity statement",
    "target": "target user or market",
    "constraints": "budget, team, timing, regulation"
  },
  "current_phase": "select | analyze | ideate | prioritize",
  "phases": {
    "select": {
      "status": "pending | in_progress | completed",
      "output_file": "frameworks.md",
      "selected_formulas": []
    },
    "analyze": {
      "status": "pending | in_progress | completed",
      "output_file": "analysis.md"
    },
    "ideate": {
      "status": "pending | in_progress | completed",
      "output_file": "ideas.md",
      "ideas_count": 0
    },
    "prioritize": {
      "status": "pending | in_progress | completed",
      "output_file": "priorities.md"
    }
  }
}
```

## Phase outputs

| Phase | File | Content |
|-------|------|---------|
| `select` | `frameworks.md` | Selected formulas + rationale + HMW reframing |
| `analyze` | `analysis.md` | Deep framework application (SCAMPER, TRIZ, JTBD), 1500+ chars |
| `ideate` | `ideas.md` | 10+ ideas: title, description, innovation point, JTBD, score |
| `prioritize` | `priorities.md` | ERRC validation, ranked shortlist, quick wins vs big bets, next steps |

## Example: initial state

```json
{
  "id": "gt-ai-education-20260327-100000",
  "skill": "genius-thinking",
  "status": "in_progress",
  "created_at": "2026-03-27T10:00:00Z",
  "updated_at": "2026-03-27T10:00:00Z",
  "topic": "ai-education",
  "request": {
    "challenge": "AI 기반 교육 서비스 아이디어",
    "target": "직장인",
    "constraints": "소규모 팀, 6개월 내 MVP"
  },
  "current_phase": "select",
  "phases": {
    "select": { "status": "in_progress", "output_file": "frameworks.md" },
    "analyze": { "status": "pending", "output_file": "analysis.md" },
    "ideate": { "status": "pending", "output_file": "ideas.md" },
    "prioritize": { "status": "pending", "output_file": "priorities.md" }
  }
}
```
