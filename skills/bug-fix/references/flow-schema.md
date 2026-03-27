# Bug Fix Flow Schema

> JSON schema for `.hypercore/bug-fix/flow.json` — used in complex path only.

## Schema

```json
{
  "id": "bug-fix-{YYYYMMDD-HHmmss}",
  "skill": "bug-fix",
  "status": "in_progress | completed | blocked",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "request": {
    "symptom": "error message or failing behavior",
    "expected": "expected behavior",
    "reproduction": "steps to reproduce",
    "related_files": ["file paths if known"]
  },
  "current_phase": "diagnose | options | confirm | fix | verify",
  "phases": {
    "diagnose": {
      "status": "pending | in_progress | completed",
      "root_cause": "identified root cause",
      "evidence": ["supporting evidence"],
      "hypotheses": [
        {
          "description": "hypothesis text",
          "confidence": "high | medium | low",
          "verified": false
        }
      ]
    },
    "options": {
      "status": "pending | in_progress | completed",
      "options": [
        {
          "id": 1,
          "summary": "option description",
          "pros": ["advantages"],
          "cons": ["disadvantages"],
          "risk": "low | medium | high",
          "files": ["affected files"],
          "recommended": true
        }
      ]
    },
    "confirm": {
      "status": "pending | completed",
      "selected_option": 1,
      "notes": "user-provided notes if any"
    },
    "fix": {
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
- The `id` uses the creation timestamp: `bug-fix-20260327-100000`.

## Example: initial state

```json
{
  "id": "bug-fix-20260327-143000",
  "skill": "bug-fix",
  "status": "in_progress",
  "complexity": "complex",
  "created_at": "2026-03-27T14:30:00Z",
  "updated_at": "2026-03-27T14:30:00Z",
  "request": {
    "symptom": "Cannot read properties of undefined (reading 'map')",
    "expected": "User list renders without errors",
    "reproduction": "Navigate to /users with empty database",
    "related_files": ["src/components/UserList.tsx"]
  },
  "current_phase": "diagnose",
  "phases": {
    "diagnose": { "status": "in_progress" },
    "options": { "status": "pending" },
    "confirm": { "status": "pending" },
    "fix": { "status": "pending" },
    "verify": { "status": "pending" }
  }
}
```
