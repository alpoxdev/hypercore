# Elon Musk (First Principles) Flow Schema

> JSON schema for `.hypercore/elon-musk/[topic-slug]/flow.json`.

## Schema

```json
{
  "id": "fp-{topic-slug}-{YYYYMMDD-HHmmss}",
  "skill": "elon-musk",
  "status": "in_progress | completed",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "topic": "topic-slug",
  "request": {
    "problem": "problem description",
    "desired_outcome": "what success looks like"
  },
  "current_phase": "research | deconstruct | redesign | execute",
  "phases": {
    "research": {
      "status": "pending | in_progress | completed",
      "output_file": "research.md"
    },
    "deconstruct": {
      "status": "pending | in_progress | completed",
      "output_file": "assumptions.md",
      "assumptions_count": { "A": 0, "B": 0, "C": 0 }
    },
    "redesign": {
      "status": "pending | in_progress | completed",
      "output_file": "redesign.md",
      "alternatives_count": 0
    },
    "execute": {
      "status": "pending | in_progress | completed",
      "output_file": "execution.md"
    }
  }
}
```

## Phase outputs

| Phase | File | Content |
|-------|------|---------|
| `research` | `research.md` | Industry conventions, actual data/benchmarks, innovation cases (with URLs) |
| `deconstruct` | `assumptions.md` | A/B/C matrix, Socratic questioning, cross-verification |
| `redesign` | `redesign.md` | Current vs first-principles comparison, 3-5 alternative paths |
| `execute` | `execution.md` | Inversion scenarios, pre-mortem, prioritized action sequence |

## Example: initial state

```json
{
  "id": "fp-saas-infra-cost-20260327-100000",
  "skill": "elon-musk",
  "status": "in_progress",
  "created_at": "2026-03-27T10:00:00Z",
  "updated_at": "2026-03-27T10:00:00Z",
  "topic": "saas-infra-cost",
  "request": {
    "problem": "SaaS 인프라 비용이 매출의 40%",
    "desired_outcome": "비용 비율 15% 이하로 절감"
  },
  "current_phase": "research",
  "phases": {
    "research": { "status": "in_progress", "output_file": "research.md" },
    "deconstruct": { "status": "pending", "output_file": "assumptions.md" },
    "redesign": { "status": "pending", "output_file": "redesign.md" },
    "execute": { "status": "pending", "output_file": "execution.md" }
  }
}
```
