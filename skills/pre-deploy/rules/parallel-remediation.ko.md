# Parallel Remediation

**목적**: 통합 위험을 숨기지 않으면서 pre-deploy 작업 시간을 줄일 수 있을 때만 위임 lane을 사용합니다.

**읽는 조건**: 분류에서 실패 두 개 이상이 스택이나 파일 기준으로 겹치지 않는다고 판정했고 위임 기능이 있을 때 읽습니다. 그 밖의 경우에는 같은 작업을 순차 실행하고 이 파일을 건너뜁니다.

## lane을 쓸 수 있는 경우

다음 중 하나 이상이 참일 때만 띄우거나 넘깁니다.

- 실패가 스택(`node`, `rust`, `python`) 기준으로 독립적입니다.
- 한 lane은 읽기 전용 진단이고 leader는 겹치지 않는 수정을 계속합니다.
- 편집 소유권을 파일이나 디렉터리 단위로 깔끔하게 나눌 수 있습니다.
- 긴 로그나 의존성 체인을 메인 맥락에서 분리할 수 있습니다.

다음 경우에는 띄우지 않습니다.

- leader의 다음 단계가 그 결과에 막혀 있습니다.
- 두 lane이 같은 파일, lockfile, 매니페스트, 빌드 설정, 공유 CI·배포 설정을 건드립니다.
- 작업에 확인 가능한 성공 조건이 없습니다.
- 작업에 외부, 자격 증명, 파괴적, 운영 측 부수 효과가 필요합니다.
- 조율 비용이 수정 비용보다 큽니다.

동시에 최대 세 lane을 운영하고, 각 lane은 `rules/tracked-remediation.md`의 실패 그룹별 `MAX_FIX_ATTEMPTS` 한도를 그대로 물려받습니다.

## leader 계약

위임 전에 다음을 정합니다.

1. 목표: lane 결과를 한 문장으로 적습니다.
2. 범위: 스택, 명령, 파일, 대상 루트를 적습니다.
3. 소유권: 읽기 전용인지, 쓸 수 있는 파일 집합이 정확히 무엇인지 적습니다.
4. 금지 행동: 파괴적 명령, 외부 부수 효과, 무관한 리팩터, 소유권 밖 편집입니다.
5. 출력: 확인하거나 바꾼 파일, 명령 출력, 검증 결과, blocker입니다.
6. 중단 조건: 완료, 막힘, 재현되는 실패 없음, 소유권 충돌입니다.

위임 중:

- 기다리지만 말고 겹치지 않는 작업을 계속합니다.
- 같은 파일에 동시에 쓰는 일을 만들지 않습니다.
- lockfile, 매니페스트, 빌드 설정, CI·배포 설정은 에스컬레이션을 요구합니다.

위임 후:

- lane 결과에서 충돌, 중복 수정, 빠진 검사를 비교합니다.
- 증명 실행 전에 바뀐 파일을 모두 확인합니다.
- leader 맥락에서 최종 `bash skills/pre-deploy/scripts/deploy-check.sh`를 실행합니다.
- 사용한 lane을 보고하고, 검증하지 않은 lane 출력은 caveat로 표시합니다.

## lane 템플릿

### 읽기 전용 진단 lane

```markdown
Objective: Diagnose the [node|rust|python|tooling] pre-deploy failure from the captured output.
Scope: [target root], [stack], [failing command/output].
Mode: read-only.
Ownership: no file edits.
Forbidden: destructive commands, external side effects, unrelated refactors, editing files.
Output: root-cause hypothesis, evidence files and commands, recommended targeted check, blockers.
Stop condition: root cause identified, no reproducible cause found, or scope conflict.
```

### 서로 겹치지 않는 편집 lane

```markdown
Objective: Fix the reproduced [stack] blocker without touching other lanes.
Scope: [target root], [stack], [failing command/output].
Mode: edit-own-files.
Ownership: may edit only [file or directory list].
Forbidden: editing shared configs, lockfiles, or manifests unless listed in Ownership; destructive commands; external side effects; unrelated cleanup.
Output: changed files, rationale, targeted validation command and result, remaining blockers.
Stop condition: targeted check passes, blocked, ownership conflict, or a broader fix is required.
```

## lane 분할

| 실패 형태 | 안전한 분할 |
|---|---|
| Node, Rust, Python 실패 | 스택별 lane 하나, 공유 설정 편집 없음 |
| Node typecheck와 Node lint | 나누지 않음. `lint-check.sh`가 이미 둘을 동시에 실행합니다 |
| 도구 실패와 애플리케이션 실패 | 읽기 전용 도구 lane 하나와 애플리케이션 수정 lane 하나 |
| lockfile이나 패키지 매니저 문제 | leader 단독, 또는 한 명의 전용 소유자 |
| 공유 빌드 설정 실패 | 소유권을 배타적으로 만들 수 있을 때만 나누고, 아니면 leader 단독 |

## 검증 확인 항목

- [ ] 각 lane이 목표, 범위, 소유권, 출력, 중단 조건을 받았습니다.
- [ ] lane이 독립적이었거나 순서를 명시했습니다.
- [ ] 쓰기 lane의 소유권이 겹치지 않았습니다.
- [ ] 어느 lane도 자기 실패 그룹의 시도 한도를 넘지 않았습니다.
- [ ] leader가 결과를 그대로 넘기지 않고 통합했습니다.
- [ ] leader가 최종 증명을 직접 실행했습니다.
- [ ] 배포 준비 판정을 lane에 위임하지 않았습니다.

## Sources

> 확인 2026-11-03. 이 규칙은 이 패키지 자체의 절차이며, 스크립트 경로를 같은 날짜에 다시 읽었습니다.

| 주장 | 출처 |
|---|---|
| 위임에는 목표, 범위, 소유권, 출력, 중단 조건이 붙고 쓰기 주체가 겹치지 않는다 | `instructions/validation/index.md` |
| 상위 agent가 lane 결과를 통합하고 최종 검증을 직접 실행한다 | `instructions/harness-engineering/HARNESS_ENGINEERING.md` |
| 위임은 기능이며, 게이트된 부수 효과에는 여전히 승인이 필요하다 | `instructions/cli/capability-contract.md` |
