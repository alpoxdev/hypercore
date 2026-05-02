# QA Flow Schema

> JSON schema for `.hypercore/qa/flow.json` — used in complex path only.

## Schema

```json
{
  "id": "qa-{YYYYMMDD-HHmmss}",
  "skill": "qa",
  "status": "in_progress | completed | blocked",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "request": {
    "original": "raw stakeholder message",
    "requester": "client | executive | PM | etc",
    "context": "additional context if any"
  },
  "current_phase": "analyze | present | confirm | implement | verify",
  "phases": {
    "analyze": {
      "status": "pending | in_progress | completed",
      "affected_areas": ["file or component paths"],
      "scope_estimate": "small | medium | large"
    },
    "present": {
      "status": "pending | in_progress | completed",
      "candidates": [
        {
          "id": 1,
          "summary": "technical summary",
          "changes": ["specific files and modifications"],
          "risks": ["what could break"],
          "recommended": true
        }
      ],
      "issues": ["potential issues stakeholder didn't consider"]
    },
    "confirm": {
      "status": "pending | completed",
      "selected_candidate": 1,
      "adjustments": "user-provided adjustments if any"
    },
    "implement": {
      "status": "pending | in_progress | completed",
      "changed_files": ["list of modified files"]
    },
    "verify": {
      "status": "pending | in_progress | completed | failed",
      "commands_run": ["validation commands executed"],
      "result": "pass | fail",
      "notes": "verification details"
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
| `failed` | Phase failed (verify only) |
| `blocked` | Waiting on external input (overall status only) |

## Rules

- Set `current_phase` to the first phase with status `in_progress` or `pending`.
- Update `updated_at` on every write.
- When all phases are `completed`, set top-level `status` to `completed`.
- If `verify` fails, set its status to `failed` and fix within scope before retrying.
- The `id` uses the creation timestamp: `qa-20260327-100000`.

## Example: initial state

```json
{
  "id": "qa-20260327-100000",
  "skill": "qa",
  "status": "in_progress",
  "complexity": "complex",
  "created_at": "2026-03-27T10:00:00Z",
  "updated_at": "2026-03-27T10:00:00Z",
  "request": {
    "original": "고객사에서 결제 플로우에서 할인 적용이 안 된다고 합니다",
    "requester": "client",
    "context": "특정 쿠폰 코드 사용 시 발생"
  },
  "current_phase": "analyze",
  "phases": {
    "analyze": { "status": "in_progress" },
    "present": { "status": "pending" },
    "confirm": { "status": "pending" },
    "implement": { "status": "pending" },
    "verify": { "status": "pending" }
  }
}
```
