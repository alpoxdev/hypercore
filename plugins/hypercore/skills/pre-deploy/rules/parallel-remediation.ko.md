# Parallel Remediation

**목적**: 통합 리스크를 숨기지 않으면서 pre-deploy wall-clock time을 줄일 때만 subagent/background agent를 사용합니다.

## Parallel lane을 사용할 때

초기 full `skills/pre-deploy/scripts/deploy-check.sh`가 실패를 캡처하고 leader가 실패를 그룹화한 뒤에만 parallel lane을 사용합니다.

다음 조건 중 하나 이상이면 spawn 또는 handoff합니다.

- 실패가 stack별(`node`, `rust`, `python`)로 독립적임
- 한 lane은 read-only diagnosis이고 leader는 겹치지 않는 다른 fix를 계속할 수 있음
- edit ownership을 겹치지 않는 파일/디렉터리로 나눌 수 있음
- 긴 log, dependency chain, test output을 main context에서 분리하는 편이 유리함

다음 경우에는 spawn하지 않습니다.

- leader의 다음 단계가 바로 그 결과에 막혀 있음
- 두 lane이 같은 파일, lockfile, package manifest, build config, shared CI/deploy config를 건드릴 가능성이 있음
- 구체적인 성공 기준이 없음
- 외부, credential-gated, destructive, production side effect가 필요함
- 실패가 단순해서 조정 비용이 수정 비용보다 큼

## Leader contract

위임 전 leader는 아래를 정의해야 합니다.

1. Objective: lane 결과를 한 문장으로 설명.
2. Scope: stack, command, files, target root.
3. Ownership: read-only 또는 정확한 writable file set.
4. Forbidden actions: destructive command, external side effect, unrelated refactor, ownership 밖 수정.
5. Output: 읽거나 변경한 파일, evidence, command output, validation result, blocker.
6. Stop condition: complete, blocked, no reproducible failure, ownership conflict.

위임 중:

- 안전하면 무의미하게 기다리지 말고 겹치지 않는 작업을 계속합니다.
- subagent들이 겹치는 파일이나 shared config를 동시에 수정하게 하지 않습니다.
- lockfile, package manifest, build config, CI/deploy config, scope expansion은 escalation을 요구합니다.

위임 후:

- lane finding의 충돌, 중복 수정, 누락 check를 비교합니다.
- final validation 전 모든 changed file을 확인합니다.
- leader context에서 final `skills/pre-deploy/scripts/deploy-check.sh`를 직접 실행합니다.
- subagent 사용 여부와 미검증 lane output을 caveat로 보고합니다.

## Lane templates

### Read-only diagnosis lane

```markdown
Objective: 캡처된 출력에서 [node|rust|python|tooling] pre-deploy failure를 진단한다.
Scope: [target root], [stack], [failing command/output].
Mode: read-only.
Ownership: no file edits.
Forbidden: destructive commands, external side effects, unrelated refactors, editing files.
Output: root-cause hypothesis, evidence files/commands, recommended targeted check, blockers.
Stop condition: root cause identified, no reproducible cause found, or scope conflict.
```

### Disjoint edit lane

```markdown
Objective: 다른 lane을 건드리지 않고 재현된 [stack] blocker를 수정한다.
Scope: [target root], [stack], [failing command/output].
Mode: edit-own-files.
Ownership: may edit only [file or directory list].
Forbidden: Ownership에 없으면 shared configs/lockfiles/package manifests 수정 금지; destructive commands; external side effects; unrelated cleanup.
Output: changed files, rationale, targeted validation command and result, remaining blockers.
Stop condition: targeted check passes, blocked, ownership conflict, or broader fix required.
```

## 권장 lane split

| Failure shape | Safe lane split |
|------|------|
| Node + Rust + Python 실패 | stack당 한 lane, shared config edit 금지 |
| Node typecheck + Node lint | 보통 나누지 않음; `lint-check.sh`가 이미 동시에 실행함 |
| Tooling/script failure + application failure | read-only tooling lane + 하나의 application-fix lane |
| Lockfile/package manager issue | leader 또는 단일 owner lane 하나만 |
| Shared build config failure | ownership을 독점시킬 수 없으면 leader가 처리 |

## Validation assertions

- [ ] 각 lane에 objective, scope, ownership, output, stop condition이 있음
- [ ] parallel lane이 독립적이거나 명시적으로 순차화됨
- [ ] writable lane의 ownership이 겹치지 않음
- [ ] leader가 결과를 그대로 붙이지 않고 통합함
- [ ] leader가 final verification을 직접 실행하거나 출력 확인함
- [ ] final readiness를 subagent에 위임하지 않음
