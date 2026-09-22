# 감독 루프 상세

감독형 워커가 실행 중일 때 이 참조를 읽습니다. 감독 계약 reporter, Run 단위 웨이터,
Dispatch별 진행 주기, stall 분류, 하네스 연계, 복구 사다리, 감독 기록 필드를 담고 있습니다.

## 목차

- [감독 범위](#감독-범위)
- [브랜치 A — 감독 계약과 Run 단위 웨이터](#브랜치-a--감독-계약과-run-단위-웨이터)
- [브랜치 B — 네이티브 감독 워커](#브랜치-b--네이티브-감독-워커)
- [복구 사다리](#복구-사다리)
- [질문 무응답과 다중 stall 우선순위](#질문-무응답과-다중-stall-우선순위)
- [stall 분류](#stall-분류)
- [하네스 연계](#하네스-연계)
- [감독 기록](#감독-기록)
- [Sources](#sources)

## 감독 범위

감독은 `prompt_delivered`부터 라이프사이클 종료 신호(`worker_done`, `escalation`, `question`,
명시적 실패)까지 실행됩니다. 롤링 대기는 체크포인트이지 복구가 아닙니다. 대기 타임아웃과
`{count:0}`은 실패가 아닙니다. 정상 작업은 15-60분이 걸리므로 조용함 자체는 신호가 아닙니다.

## 브랜치 A — 감독 계약과 Run 단위 웨이터

실행 전에 Task spec에 감독 계약을 포함합니다. 네이티브 `worker-start --agent <id>` 워커
(OMO는 `pi`)는 이를 네이티브 실행의 일부로 전달하고, custom-dispatch 폴백은 정확한 preamble
안에 담아 전달합니다. `dispatch-show --preamble`이 이미 전체 Task를 돌려줬다면 나중에 계약을
덧붙이지 않습니다.

```text
SUPERVISION CONTRACT
1. On accepting the task, send one status message with the current phase.
2. While working, send a heartbeat at least every 5 minutes.
3. When blocked, use the ask/question path instead of going silent.
4. Send worker_done exactly once with outcome succeeded or failed, then idle.
```

워커 쪽 status와 heartbeat 메일은 managed OMO extension인
[`../assets/extensions/omo-supervision-reporter.ts`](../assets/extensions/omo-supervision-reporter.ts)가
만듭니다. `worker_active`를 기록하기 전에 이 스킬 디렉터리에서
`bun assets/extensions/install-extensions.ts --check --json`을 실행하고, 검사가 누락 또는 불일치를
보고하면 `--check` 없이 같은 명령을 실행해 프로비저닝합니다. reporter는 절대 `worker_done`을
보내지 않으며, 완료 판정 권한은 수락된 Task 계약에 유지됩니다.

Run 단위 웨이터 하나를 사용합니다:

```text
orca orchestration check --run <run> --wait --types worker_done,escalation,question,status,heartbeat --timeout-ms 900000 --json
```

Delivery 배치 전체를 처리한 뒤 `check --ack <delivery_id>`로 ack합니다. bound Run은 `--ack`
전까지 같은 Delivery를 다시 재생합니다. progress-only Delivery(`status` 또는 `heartbeat`만)는
기록하고 ack한 뒤 계속 대기합니다.

Dispatch별 진행 신호는 독립적으로 관리합니다: heartbeat ≤10분, status ≤15분,
`terminal read --cursor` 델타 또는 terminal list `lastOutputAt` ≤10분,
`terminal read --screen`의 Working 마커. 렌더링 조각 재편집은 활동을 증명할 뿐 의미 있는
진행이 아닙니다.

## 브랜치 B — 네이티브 감독 워커

새 워커의 1급 경로입니다. 새 OMO 워커를 `worker-start --agent pi`로 띄우는 경우와 다른 등록
에이전트의 기본 경로입니다. `worker-show` 상태를 사용합니다. `ready`: 계속 대기하거나
`worker-read --dispatch <id> --limit 50`을 실행합니다. `failed` 또는 `stopped`: 복구 사다리
3단. `outcome_unknown`: 사용자 승인 필요. 이 브랜치를 커스텀 디스패치에 적용하지 않습니다.
`unsupervised`/`context_only`는 그 경로에서 예상되는 소유권입니다.

## 복구 사다리

두 브랜치 공통: (1) bounded read로 확인 — 무제한·무료; (2) Dispatch당 nudge 최대 1회 —
네이티브는 `orchestration send --to dispatch:<id>` 구조 메일, 커스텀은 read-before-send가 수신
가능한 화면 상태(draft 없음, 대기 question 없음)를 확인한 뒤에만 `terminal send`로 상태 질의
1건(2분 성공 창). nudge는 Task/preamble 재전달이 아닙니다; (3) `worker-show`가 `failed` 또는
`stopped`를 보고할 때만 네이티브 전용 자동 교체:
`worker-start --task <task> --retry-of <dispatch_id>` 1회(placement를 상속하지 않으며
`--on`/worktree와 `--agent`/terminal 선택을 반복합니다); (4) 사용자 에스컬레이션 — 증거
번들(stall 타임라인, nudge receipt, 마지막 출력, 분류) 포함. 자동 조치는 여기서 끝납니다.

## 질문 무응답과 다중 stall 우선순위

question 수신 후 답변 지연이 5분이면 `coordinator_blocked`로 분류하고(워커 stall 아님)
사용자에게 에스컬레이션합니다. 다중 stall 우선순위: question > `terminal_gone` > 임계경로
idle > 기타 idle > `busy-unverified`.

## stall 분류

stall 분류는 부모가 관측한 조건들의 집합입니다:

- 진단 시작: 모든 신호가 20분 동안 무변화, 또는 15분 대기창 타임아웃 2회 연속.
- `stalled-idle` 선언에는 다음 전부가 필요합니다: Task/Dispatch active;
  `worker_done`, `question`, `escalation` 부재; cursor/`lastOutputAt` 30분 무변화;
  status/heartbeat 30분 부재; 대기창 타임아웃 2회; 1분 간격 화면 스냅샷 3회 동일; 각
  스냅샷이 idle 프롬프트(Working 마커 부재); 런타임 healthy·터미널 존재.
- `busy-unverified`: Working 마커 지속. 의미 있는 진행 없이 30분이면 진단, 60분이면
  에스컬레이션. 화면이 바쁨을 증명하면 텍스트를 주입하지 않습니다.
- `waiting-for-input`: question 메일이 권위입니다. 메일이 없으면 화면 폴백에 6조건 전부
  필요: `source=screen`, `tui-idle` 성공, 프롬프트 존재, Working 마커 부재, 질문 텍스트
  존재, 스냅샷 2장 동일.
- `terminal_gone`: 런타임 healthy + 정확한 handle 부재뿐입니다. 런타임 장애와 혼동하지
  않습니다.

## 하네스 연계

하네스 연계는 능력 용어로 기술합니다. 영구 세션과 출력 감시가 있는 하네스는 대기를 영구
세션으로 감싸고 actionable 타입(`worker_done`, `question`, `escalation`, 또는 알 수 없는
타입)에서만 부모를 깨웁니다. 일반 셸 하네스는 30초 대기창 경계로 감독하고 lease/하네스/세션
만료를 부모 프로세스 체크포인트로 취급합니다: 사용자에게 상태 요약을 보고한 뒤 재무장(re-arm)
하고 계속하거나 사용자 지시로 감독을 종료합니다. 라이프사이클 종료 신호 없이 worker를
실패로 분류하거나 release·정산하지 않습니다.

## 감독 기록

`workerKind`(`custom-dispatch` 또는 `native-supervised`), 터미널
소유권(`parent-created`, `reused`, 또는 `user-owned`), Run/Task/Dispatch/handle/worktree,
전송 receipt, 감독 계약 포함 여부 yes/no, 상태 전이 타임스탬프, Delivery ID와 ack 시각,
최신 신호 시각, nudge receipt와 응답 증거, 최종 Task/Dispatch 상태, 정산 선택과 receipt를
기록합니다. 증거 루트:
`<state-root>/runs/<run-id>/tasks/<task-id>/attempts/<dispatch-id>/`.

## Sources

> 외부 출처를 사용하지 않았습니다. 위 조건은 모두 [`runtime-cli-evidence.ko.md`](runtime-cli-evidence.ko.md)에
> 기록된 로컬 Orca/OMO CLI 관측을 그대로 옮긴 것이며, 그 원장을 확인 2026-09-21.
