# 배포 수정 Flow Schema

> 복잡 경로에서만 사용하는 `.hypercore/deploy-fix/flow.json`용 JSON schema.

## Schema

```json
{
  "id": "deploy-fix-{YYYYMMDD-HHmmss}",
  "skill": "deploy-fix",
  "status": "in_progress | completed | blocked",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "request": {
    "failure": "오류 메시지 또는 실패 단계 설명",
    "scope": "repo-wide | workspace:name | ci-step:name | deploy-target:name",
    "build_command": "실패하는 명령 (해당하는 경우)",
    "ci_provider": "GitHub Actions | Vercel | GitLab CI | other (해당하는 경우)",
    "related_files": ["알고 있다면 config/code 파일 경로"]
  },
  "current_phase": "investigate | options | confirm | fix | verify",
  "phases": {
    "investigate": {
      "status": "pending | in_progress | completed",
      "root_cause": "확인된 근본 원인",
      "evidence": ["로그/config에서 얻은 근거 증거"],
      "failure_chain": [
        {
          "step": "실패 단계 이름",
          "error": "오류 메시지",
          "file": "해당하는 경우 파일 경로"
        }
      ],
      "hypotheses": [
        {
          "description": "가설 텍스트",
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
          "summary": "옵션 설명",
          "pros": ["장점"],
          "cons": ["단점"],
          "risk": "low | medium | high",
          "files": ["영향받는 파일"],
          "recommended": true
        }
      ]
    },
    "confirm": {
      "status": "pending | completed",
      "selected_option": 1,
      "notes": "사용자가 제공한 메모가 있으면 기록"
    },
    "fix": {
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
- `id`는 생성 timestamp를 사용한다: `deploy-fix-20260327-100000`.

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
    "failure": "TypeScript compilation error: Cannot find module '@repo/shared'",
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
