# Improve Flow Schema

> 복잡 경로에서만 사용하는 `.hypercore/improve/flow.json`용 JSON 스키마.

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
| `pending` | 아직 시작하지 않은 단계 |
| `in_progress` | 현재 진행 중인 단계 |
| `completed` | 성공적으로 완료된 단계 |
| `failed` | 실패한 단계(verify 전용) |
| `blocked` | 외부 입력을 기다리거나 승인 없이는 안전하지 않은 상태 |

## Rules

- `current_phase`는 `in_progress` 또는 `pending` 상태인 첫 단계로 설정한다.
- 매번 쓸 때 `updated_at`을 갱신한다.
- 모든 단계가 `completed`이면 최상위 `status`를 `completed`로 설정한다.
- `verify`가 실패하면 상태를 `failed`로 설정하고, 범위 내에서 수정한 뒤 검증을 재시도한다.
- `selection_mode: "agent_selected"`는 안전하고 되돌릴 수 있는 낮은 리스크 개선이거나 사용자가 agent에게 결정을 맡긴 경우에만 사용한다.
- 옵션이 영향이 크거나, 파괴적이거나, 외부에 노출되거나, 상호 배타적이면 `selection_mode: "user_selected"`를 사용한다.
- `id`는 생성 타임스탬프를 사용한다. 예: `improve-20260526-173000`.

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
