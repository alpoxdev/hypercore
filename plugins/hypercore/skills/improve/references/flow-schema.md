# Improve Flow Schema

> JSON schema for `.hypercore/improve/flow.json` — used in complex path only.

## Schema

```json
{
  "id": "improve-{YYYYMMDD-HHmmss}",
  "skill": "improve",
  "status": "in_progress | completed | blocked",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "request": {
    "target": "file, folder, URL, feature, document, skill, or artifact",
    "user_criteria": ["criteria explicitly provided by the user"],
    "inferred_criteria": ["criteria inferred when user did not provide specifics"],
    "constraints": ["project, safety, behavior, language, or scope constraints"]
  },
  "current_phase": "baseline | options | select | improve | verify",
  "phases": {
    "baseline": {
      "status": "pending | in_progress | completed",
      "evidence": ["local evidence about current state"],
      "quality_gaps": ["observed improvement opportunities"],
      "preserve": ["behavior, wording, APIs, or contracts that must remain stable"]
    },
    "options": {
      "status": "pending | in_progress | completed",
      "options": [
        {
          "id": 1,
          "summary": "improvement option",
          "impact": "low | medium | high",
          "risk": "low | medium | high",
          "scope": ["affected files or areas"],
          "validation": ["checks that would prove this option worked"],
          "recommended": true
        }
      ]
    },
    "select": {
      "status": "pending | completed",
      "selection_mode": "user_selected | agent_selected",
      "selected_option": 1,
      "reason": "why this path was selected"
    },
    "improve": {
      "status": "pending | in_progress | completed",
      "changed_files": ["list of modified files"],
      "notes": "what changed and why"
    },
    "verify": {
      "status": "pending | in_progress | completed | failed",
      "commands_run": ["validation commands executed"],
      "readback_checks": ["manual structural or usage checks"],
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
| `blocked` | Waiting on external input or unsafe without approval |

## Rules

- Set `current_phase` to the first phase with status `in_progress` or `pending`.
- Update `updated_at` on every write.
- When all phases are `completed`, set top-level `status` to `completed`.
- If `verify` fails, set its status to `failed`, fix within scope, and retry validation.
- Use `selection_mode: "agent_selected"` only for safe, reversible, low-risk improvements or when the user asked the agent to decide.
- Use `selection_mode: "user_selected"` when options are high-impact, destructive, externally visible, or mutually exclusive.
- The `id` uses the creation timestamp, for example `improve-20260526-173000`.

## Example: initial state

```json
{
  "id": "improve-20260526-173000",
  "skill": "improve",
  "status": "in_progress",
  "complexity": "complex",
  "created_at": "2026-05-26T17:30:00+09:00",
  "updated_at": "2026-05-26T17:30:00+09:00",
  "request": {
    "target": "skills/example/SKILL.md",
    "user_criteria": [],
    "inferred_criteria": ["clearer trigger", "leaner core", "stronger validation"],
    "constraints": ["preserve intended skill scope", "do not add dependencies"]
  },
  "current_phase": "baseline",
  "phases": {
    "baseline": {
      "status": "in_progress",
      "evidence": [],
      "quality_gaps": [],
      "preserve": []
    },
    "options": { "status": "pending", "options": [] },
    "select": { "status": "pending" },
    "improve": { "status": "pending", "changed_files": [] },
    "verify": { "status": "pending", "commands_run": [], "readback_checks": [] }
  }
}
```
