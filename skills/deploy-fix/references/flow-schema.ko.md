# Deploy Fix Flow 스키마

> `.hyper/deploy-fix/flow.json`의 형태이며 complex 경로에서만 씁니다. 재개한 세션이 이미 시도한 내용을 다시 하지 않도록 기록을 남깁니다. 정식 JSON Schema 문서가 아니라 문서화한 계약입니다.

## 목차

- 스키마
- 상태 값
- 규칙
- 예시: 초기 상태

## 스키마

```json
{
  "id": "deploy-fix-{YYYYMMDD-HHmmss}",
  "skill": "deploy-fix",
  "status": "in_progress | completed | blocked | exhausted",
  "complexity": "complex",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "request": {
    "failure": "에러 문구 또는 실패한 단계",
    "scope": "repo-wide | workspace:name | ci-step:name | deploy-target:name",
    "build_command": "실패한 명령, 해당할 때",
    "ci_provider": "GitHub Actions | Vercel | GitLab CI | other",
    "target": "해당할 때 provider 프로젝트, 환경, target",
    "related_files": ["접수 시점에 아는 설정 또는 코드 경로"]
  },
  "current_phase": "investigate | options | confirm | fix | verify",
  "phases": {
    "investigate": {
      "status": "pending | in_progress | completed",
      "root_cause": "확인한 원인",
      "failure_class": "scope | implementation | test | source | environment | unresolved",
      "evidence": ["인용한 로그 줄, 경로, 버전"],
      "hypotheses": [
        { "description": "한 문장 가설", "confidence": "high | medium | low", "verified": false }
      ]
    },
    "options": {
      "status": "pending | in_progress | completed",
      "options": [
        {
          "id": 1,
          "summary": "이 선택지가 바꾸는 내용",
          "pros": ["장점"],
          "cons": ["비용 또는 위험"],
          "risk": "low | medium | high",
          "files": ["영향받는 경로"],
          "recommended": true
        }
      ]
    },
    "confirm": {
      "status": "pending | completed",
      "selected_option": 1,
      "notes": "사용자의 발언 또는 그 요약"
    },
    "fix": {
      "status": "pending | in_progress | completed",
      "changed_files": ["수정한 경로"]
    },
    "verify": {
      "status": "pending | in_progress | completed | failed",
      "commands_run": ["순서대로 실행한 검증 명령"],
      "result": "pass | fail | skipped",
      "notes": "핵심 결과 줄과 미검증으로 남은 항목",
      "attempts": [
        {
          "n": 1,
          "hypothesis": "이 시도가 검사한 내용",
          "change": "수정한 경로와 그 이유",
          "check": "명령과 종료 상태",
          "verdict": "fixed | not_fixed | skipped",
          "reason": "결과가 보여 준 것"
        }
      ],
      "external_action": {
        "requested": false,
        "authorized_action": "정확한 재시도, deploy, publish, rollback 또는 null",
        "authorized_target": "정확한 provider, 프로젝트, 환경, target 또는 null",
        "preflight": "pass | fail | not_run",
        "rollback_or_stop": "rollback 또는 중단 조건, 없으면 null",
        "post_check": "정한 사후 검사, 없으면 null"
      }
    }
  }
}
```

## 상태 값

| 상태 | 의미 |
|---|---|
| `pending` | 시작하지 않음 |
| `in_progress` | 진행 중 |
| `completed` | 정상 완료 |
| `failed` | 검증 실패, 반복이 아직 열려 있음 |
| `blocked` | 입력, 권한, 외부 시스템을 기다리는 중 |
| `exhausted` | 시도 상한에 닿음. 무엇이 아직 실패하는지와 그 이유를 보고서에 적습니다. |

## 규칙

- `current_phase`는 상태가 `in_progress` 또는 `pending`인 첫 단계로 두고, 기록할 때마다 `updated_at`을 갱신합니다.
- 모든 단계가 `completed`이면 최상위 status를 `completed`로 둡니다. 검증이 시도 상한에 닿았으면 `exhausted`로 적고 `completed`로 적지 않습니다.
- 시도마다 `attempts` 항목을 판정과 이유와 함께 하나씩 덧붙입니다. 상한, 진전 없음의 중단, 재개 gate는 `rules/diagnosis-resume-and-safety.md`가 소유하며 이 파일은 다시 적지 않습니다.
- 이 파일은 프로젝트가 보통 무시하는 디렉터리 아래의 임시 상태입니다. 커밋하지 않고, 내용을 권한으로 취급하지 않습니다. 재개한 flow는 현재 요청과 다시 대조합니다.
- `id`는 생성 시각을 씁니다. 예를 들어 `deploy-fix-20260327-100000`입니다.

## 예시: 초기 상태

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

> 확인 2026-11-03. 이 날짜에 모든 행을 직접 읽었습니다.

| 주장 | 출처 |
|---|---|
| 반복한 수정을 처음부터 다시 하지 않게 하는 단계와 시도 기록, 별도 결과로 두는 `exhausted` | `instructions/loop-engineering/references/stop-conditions-and-verification.md` |

### Evidence grade

이 행은 저장소 내부 문서이고 2026-11-03에 읽었으므로 이 패키지에 대해 `PRIMARY`입니다. 이 파일은 외부 주장을 하지 않고 vendor 페이지를 인용하지 않습니다.
