# PRD Maker Flow Schema

> JSON schema for `.hypercore/prd/[slug]/flow.json` — used in complex path only.

## Schema

```json
{
  "id": "prd-{slug}-{YYYYMMDD-HHmmss}",
  "skill": "prd-maker",
  "mode": "create | update",
  "status": "in_progress | completed | blocked",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "slug": "kebab-case-slug",
  "request": {
    "summary": "brief description of the PRD initiative",
    "requester": "who requested it if known",
    "context": "additional context"
  },
  "current_phase": "brief | research | draft | sources | validate",
  "phases": {
    "brief": {
      "status": "pending | in_progress | completed",
      "product_name": "feature or product name",
      "problem": "problem to solve",
      "target_users": "who benefits",
      "desired_outcome": "business goal",
      "constraints": ["known constraints"],
      "unknowns": ["known unknowns"]
    },
    "research": {
      "status": "pending | in_progress | completed | skipped",
      "queries": ["distinct search queries used"],
      "sources_found": 0,
      "skip_reason": "reason if skipped (e.g. user provided sufficient context)"
    },
    "draft": {
      "status": "pending | in_progress | completed",
      "sections_written": ["overview", "problem", "scope", "requirements", "metrics"],
      "open_questions_count": 0
    },
    "sources": {
      "status": "pending | in_progress | completed",
      "entries_logged": 0
    },
    "validate": {
      "status": "pending | in_progress | completed | failed",
      "checks_passed": ["scope_clarity", "citations", "open_questions", "change_history"],
      "checks_failed": [],
      "notes": "validation details"
    }
  }
}
```

## Status values

| Status | Meaning |
|--------|---------|
| `pending` | Phase not yet started |
| `in_progress` | Phase currently active |
| `completed` | Phase finished successfully |
| `skipped` | Phase intentionally skipped (research only) |
| `failed` | Phase failed validation (validate only) |
| `blocked` | Waiting on external input (overall status only) |

## Rules

- Set `current_phase` to the first phase with status `in_progress` or `pending`.
- Update `updated_at` on every write.
- When all phases are `completed` (or `skipped`), set top-level `status` to `completed`.
- If `validate` fails, set its status to `failed`, fix the issues, then re-run validation.
- The `id` combines slug and creation timestamp: `prd-billing-retry-20260327-100000`.
- The `mode` reflects `create` or `update` from the PRD workflow.

## Example: initial state (create mode)

```json
{
  "id": "prd-billing-retry-20260327-100000",
  "skill": "prd-maker",
  "mode": "create",
  "status": "in_progress",
  "complexity": "complex",
  "created_at": "2026-03-27T10:00:00Z",
  "updated_at": "2026-03-27T10:00:00Z",
  "slug": "billing-retry",
  "request": {
    "summary": "결제 실패 시 자동 재시도 플로우 PRD 작성",
    "requester": "PM",
    "context": "현재 결제 실패 시 수동 재시도만 가능"
  },
  "current_phase": "brief",
  "phases": {
    "brief": { "status": "in_progress" },
    "research": { "status": "pending" },
    "draft": { "status": "pending" },
    "sources": { "status": "pending" },
    "validate": { "status": "pending" }
  }
}
```

## Example: update mode with research skipped

```json
{
  "id": "prd-billing-retry-20260328-140000",
  "skill": "prd-maker",
  "mode": "update",
  "status": "in_progress",
  "complexity": "complex",
  "created_at": "2026-03-28T14:00:00Z",
  "updated_at": "2026-03-28T14:30:00Z",
  "slug": "billing-retry",
  "request": {
    "summary": "출시 범위 축소 반영 및 오픈 질문 업데이트",
    "requester": "PM"
  },
  "current_phase": "draft",
  "phases": {
    "brief": { "status": "completed", "problem": "결제 재시도 자동화" },
    "research": { "status": "skipped", "skip_reason": "사용자가 충분한 맥락 제공" },
    "draft": { "status": "in_progress", "sections_written": ["scope"] },
    "sources": { "status": "pending" },
    "validate": { "status": "pending" }
  }
}
```
