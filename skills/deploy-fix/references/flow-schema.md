# Deploy Fix Flow Schema

> Shape of `.hyper/deploy-fix/flow.json`, used on the complex path only. It exists so a resumed session reads what was tried instead of repeating it. This is a documented contract, not a formal JSON Schema document.

## Contents

- Schema
- Status values
- Rules
- Example: initial state

## Schema

```json
{
  "id": "deploy-fix-{YYYYMMDD-HHmmss}",
  "skill": "deploy-fix",
  "status": "in_progress | completed | blocked | exhausted",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "request": {
    "failure": "error text or failing step",
    "scope": "repo-wide | workspace:name | ci-step:name | deploy-target:name",
    "build_command": "the failing command, when applicable",
    "ci_provider": "GitHub Actions | Vercel | GitLab CI | other",
    "target": "provider project, environment, or target when applicable",
    "related_files": ["config or code paths known at intake"]
  },
  "current_phase": "investigate | options | confirm | fix | verify",
  "phases": {
    "investigate": {
      "status": "pending | in_progress | completed",
      "root_cause": "identified cause",
      "failure_class": "scope | implementation | test | source | environment | unresolved",
      "evidence": ["quoted log lines, paths, versions"],
      "hypotheses": [
        { "description": "one-sentence hypothesis", "confidence": "high | medium | low", "verified": false }
      ]
    },
    "options": {
      "status": "pending | in_progress | completed",
      "options": [
        {
          "id": 1,
          "summary": "what the option changes",
          "pros": ["advantage"],
          "cons": ["cost or risk"],
          "risk": "low | medium | high",
          "files": ["affected paths"],
          "recommended": true
        }
      ]
    },
    "confirm": {
      "status": "pending | completed",
      "selected_option": 1,
      "notes": "the user's words or a summary of them"
    },
    "fix": {
      "status": "pending | in_progress | completed",
      "changed_files": ["modified paths"]
    },
    "verify": {
      "status": "pending | in_progress | completed | failed",
      "commands_run": ["validation commands in order"],
      "result": "pass | fail | skipped",
      "notes": "key result lines and anything left unverified",
      "attempts": [
        {
          "n": 1,
          "hypothesis": "what this attempt tested",
          "change": "paths changed and why",
          "check": "command and exit status",
          "verdict": "fixed | not_fixed | skipped",
          "reason": "what the result showed"
        }
      ],
      "external_action": {
        "requested": false,
        "authorized_action": "exact retry, deploy, publish, or rollback, or null",
        "authorized_target": "exact provider, project, environment, target, or null",
        "preflight": "pass | fail | not_run",
        "rollback_or_stop": "rollback or stop condition, or null",
        "post_check": "defined post-action check, or null"
      }
    }
  }
}
```

## Status values

| Status | Meaning |
|---|---|
| `pending` | Not started |
| `in_progress` | Currently active |
| `completed` | Finished successfully |
| `failed` | Verification failed, and the loop is still open |
| `blocked` | Waiting on an input, a permission, or an external system |
| `exhausted` | The attempt cap was reached; the report says what is still failing and why |

## Rules

- Set `current_phase` to the first phase whose status is `in_progress` or `pending`, and update `updated_at` on every write.
- When every phase is `completed`, set the top-level status to `completed`. When verification exhausted the attempt cap, write `exhausted`, never `completed`.
- Append one `attempts` entry per attempt, with its verdict and reason. The cap, the no-progress stop, and the resume gate live in `rules/diagnosis-resume-and-safety.md`; this file does not restate them.
- The file is scratch state under a directory that projects normally ignore. Never commit it and never treat its contents as authority: a resumed flow is rechecked against the current request.
- `id` uses the creation timestamp, for example `deploy-fix-20260327-100000`.

## Example: initial state

```json
{
  "id": "deploy-fix-20260327-150000",
  "skill": "deploy-fix",
  "status": "in_progress",
  "complexity": "complex",
  "created_at": "2026-03-27T15:00:00Z",
  "updated_at": "2026-03-27T15:00:00Z",
  "request": {
    "failure": "TypeScript: Cannot find module '@repo/shared'",
    "scope": "workspace:apps/web",
    "build_command": "turbo build --filter=apps/web",
    "ci_provider": "GitHub Actions",
    "related_files": ["apps/web/tsconfig.json", "packages/shared/package.json"]
  },
  "current_phase": "investigate",
  "phases": {
    "investigate": { "status": "in_progress" },
    "options": { "status": "pending" },
    "confirm": { "status": "pending" },
    "fix": { "status": "pending" },
    "verify": { "status": "pending" }
  }
}
```

## Sources

> Checked 2026-11-03. Every row was read on that date.

| Claim | Source |
|---|---|
| The phase and attempt record that keeps a repeated repair from restarting, and `exhausted` as a distinct outcome | `instructions/loop-engineering/references/stop-conditions-and-verification.md` |

### Evidence grade

The row is repository-local and was read on 2026-11-03, so it is `PRIMARY` for this package. The file makes no external claim and cites no vendor page.
