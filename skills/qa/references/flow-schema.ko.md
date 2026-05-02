# QA Flow Schema

> 복잡 경로에서만 사용하는 `.hypercore/qa/flow.json`용 JSON schema.

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
    "original": "stakeholder 원문 메시지",
    "requester": "client | executive | PM | etc",
    "context": "추가 context가 있으면 기록"
  },
  "current_phase": "analyze | present | confirm | implement | verify",
  "phases": {
    "analyze": {
      "status": "pending | in_progress | completed",
      "affected_areas": ["파일 또는 component 경로"],
      "scope_estimate": "small | medium | large"
    },
    "present": {
      "status": "pending | in_progress | completed",
      "candidates": [
        {
          "id": 1,
          "summary": "기술 요약",
          "changes": ["구체적인 파일과 수정 사항"],
          "risks": ["깨질 수 있는 것"],
          "recommended": true
        }
      ],
      "issues": ["stakeholder가 고려하지 않았을 수 있는 문제"]
    },
    "confirm": {
      "status": "pending | completed",
      "selected_candidate": 1,
      "adjustments": "사용자가 제공한 조정 사항이 있으면 기록"
    },
    "implement": {
      "status": "pending | in_progress | completed",
      "changed_files": ["수정된 파일 목록"]
    },
    "verify": {
      "status": "pending | in_progress | completed | failed",
      "commands_run": ["실행한 검증 명령"],
      "result": "pass | fail",
      "notes": "검증 세부 사항"
    }
  }
}
```

## Status values

| Status | Meaning |
|--------|---------|
| `pending` | 아직 시작하지 않은 phase |
| `in_progress` | 현재 진행 중인 phase |
| `completed` | 성공적으로 완료된 phase |
| `failed` | 실패한 phase (`verify` 전용) |
| `blocked` | 외부 입력을 기다리는 중 (전체 status 전용) |

## Rules

- `current_phase`는 status가 `in_progress` 또는 `pending`인 첫 phase로 설정한다.
- 쓸 때마다 `updated_at`을 갱신한다.
- 모든 phase가 `completed`이면 최상위 `status`를 `completed`로 설정한다.
- `verify`가 실패하면 status를 `failed`로 설정하고 범위 안에서 수정한 뒤 다시 시도한다.
- `id`는 생성 timestamp를 사용한다: `qa-20260327-100000`.

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
