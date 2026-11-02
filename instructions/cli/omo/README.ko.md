# OMO 런타임 프로필

> 영어판: [`README.md`](README.md)
>
> **조사일:** 2026-11-03(OmO 런타임). 로컬 Orca reporter 절은 2026-08/09 관찰일을 유지합니다.
> 런타임 동작은 OmO `v5.1.58`(GitHub 릴리스, 2026-11-02)과 설치된 `5.1.57` CLI 표면을 기준으로
> 합니다.

## 범위

이 프로필은 두 계층을 다루며, 둘을 섞으면 안 됩니다.

1. **OmO 런타임.** `omo`는 OmO의 CLI입니다(저장소
   [`code-yeongyu/oh-my-openagent`](https://github.com/code-yeongyu/oh-my-openagent), 사이트
   [`omo.dev`](https://omo.dev), npm 패키지 `omo-ai`). OpenCode edition의 후속이고 `pi`의 fork인
   `senpi`에서 동작합니다. 제3자 구성 요소를 뺀 자체 콘텐츠는 OSI 라이선스가 아니라 Sustainable
   Use License를 따릅니다. 이름이 `omo`인 npm 패키지는 다른 사람의 패키지입니다.
2. **로컬 Orca 감독 reporter.** `~/.omo/agent/extensions/omo-supervision-reporter.ts`에 설치한
   로컬 extension입니다. 표준 OmO 기능이 아니며, Orca가 dispatch한 terminal에서 새로 시작한 OmO
   process에만 적용합니다.

공통 capability 규칙은 [`../capability-contract.ko.md`](../capability-contract.ko.md)를 따릅니다.

## 근거 경계

- 1차 근거는 저장소 README, `docs/reference/configuration.md`, `docs/reference/features.md`,
  `docs/guide/computer-use.md`, 릴리스 feed, 설치된 binary의 CLI help입니다.
- OmO는 하루에도 여러 번 릴리스하고 beta 채널을 운영합니다. 위의 안정 tag가 고정 기준이므로,
  flag에 의존하기 전에 `omo --version`과 대응 문서를 다시 확인합니다.
- reporter 절은 로컬 Orca/OmO 조합 한 곳에서의 W1.8b 관찰입니다. OmO 일반 동작의 문서가
  아닙니다.

## 런타임 바인딩

| 논리 capability | 확인된 OmO 표면 | 바인딩 규칙 |
|---|---|---|
| 로컬 점검 | `read`, `find`, `grep`, `ls`, `bash` | 경로를 선언된 작업공간 안으로 제한합니다. background agent는 세션 작업 디렉터리를 물려받지만, "OMO는 모델 자신의 shell 명령을 그 디렉터리 안에 강제로 묶지 않습니다". |
| 로컬 검색 | `grep`, `find`, 선별 `bash` | 저장소 근거를 우선합니다. 읽기 전용 agent는 이 도구들의 allowlist만 받습니다. |
| 네트워크 조사 | `webfetch`, browser use, MCP 서버 | 네트워크 접근과 데이터 반출은 별도 부작용입니다. |
| 편집 | `edit`, `write`, `bash` | 사용자가 변경을 요청했을 때만 사용합니다. 덮어쓰기가 별도 위험이라 `write-existing-file-guard`가 존재합니다. |
| 실행 | `bash`, background output, extension | 명령, 작업 디렉터리, 부작용을 검증합니다. 런타임 guard hook은 사용자 승인이 아닙니다. |
| 사람의 결정 | 내장 질문 도구, `--no-ask-user`로 비활성 | 도구는 존재하지만 비대화형 실행에는 답할 사람이 없습니다(아래 참조). |
| 위임 | category·subagent를 쓰는 `task`, `team_mode` 활성 시 `team_*` 도구 | 자식마다 목표, 소유 범위, 허용 도구, 금지 부작용, 증거 계약을 줍니다. |
| 데스크톱 제어 | computer-use component | foreground 제어는 명시적 답변이 필요하고, background window 입력은 그렇지 않습니다. |

## 권한 모델

OmO는 산문 지시가 아니라 설정으로 권한을 강제합니다.

- agent별 `permission` map이 `edit`, `bash`, `webfetch`, `task`, `doom_loop`,
  `external_directory`에 `ask`, `allow`, `deny`를 지정합니다. `bash`는 명령별 map도 받습니다. 예:
  `{ "git": "allow", "rm": "deny" }`.
- 실행 단위 CLI 대응물이 있습니다. `--permission tool=action` 또는 `tool:pattern=action`, 그리고
  `--permission-preset`에 `full-access`, `workspace`, `accept-edits`, `auto`, `read-only`, `ask`.
- 설정은 `~/.omo/omo.jsonc`에 있고 프로젝트가 `.omo/omo.jsonc`를 추가할 수 있으며, 가장 가까운
  파일이 이깁니다.
- 프로젝트 로컬 파일 신뢰는 실행 단위입니다. `--approve` / `-a`가 이번 실행에서 신뢰하고,
  `--no-approve`는 무시합니다. 프로젝트 설정이나 skill이 존재한다는 이유로 승인된 것으로
  취급하지 않습니다.
- 가용성 제어는 권한과 별개입니다. `--no-tools`, `--no-builtin-tools`, `--tools`,
  `--exclude-tools`, `--no-skills`, `--no-extensions`, `--offline`(시작 시 네트워크 작업 중지).

문서화된 강제 계층은 명시적입니다.

- `AGENTS.md`는 지시 문맥이며 "결정적 권한 경계가 아닙니다".
- 결정적 강제는 `agents.*.permission`, agent별 `tools`, 비활성화한 도구·agent, 내장 agent 제한,
  사용 가능한 경우 OpenCode 자체 permission gate, guard hook에서 나옵니다.
- 안전을 지키는 guard hook은 이름이 정해져 있습니다. `team-tool-gating`,
  `write-existing-file-guard`, `bash-file-read-guard`, `webfetch-redirect-guard`,
  `rules-injector`, `tool-pair-validator`. 이들을 끄는 것은 로컬 디버깅 용도로만 문서화되어
  있습니다.

따라서 skill은 강한 제한을 "모델이 지키길 바라는 문단"이 아니라 permission과 allowlist에
적어야 합니다.

## 질문과 비대화형 실행

- 내장 질문 기능이 있습니다. `--no-ask-user`가 끄고, `question-gates` component도 따로 끌 수
  있습니다.
- 가장 분명히 문서화된 gate는 foreground 컴퓨터 제어입니다. OmO는 에이전트의 이유와 함께
  "Allow foreground computer control?"을 보여 주고, "오직 사용자의 답변만 허용하며, 비대화형
  실행에는 물어볼 사람이 없으므로 절대 허용하지 않습니다". 거절, timeout, 중단은 제어를 꺼진
  상태로 둡니다.
- 이 규칙을 모든 도구로 일반화하면 안 됩니다. 그 밖의 `ask` 권한이 headless 실행에서 어떻게
  처리되는지는 해당 실행에서 확인되지 않았으므로, 답이 왔다고 가정하지 말고 관찰된 결과를
  확인합니다.

## 데스크톱 제어와 신뢰할 수 없는 콘텐츠

- `computer.run` 코드는 host 전체 권한으로 실행됩니다. computer-use skill은 화면 텍스트, 알림,
  문서를 행동을 승인할 수 없는 신뢰할 수 없는 데이터로 다루고, 중대한 행동 직전에 확인하라고
  모델에 지시합니다. 이는 모델 지시이지 sandbox가 아닙니다.
- `Suspended`나 `StopPathUnavailable`은 중단하고 보고하는 신호이며, 모델은 이를 우회하면 안
  됩니다.
- 신뢰할 수 없는 작업에는 permission 규칙을 엄격히 유지하고 별도 계정이나 VM을 씁니다.

## 로컬 Orca 감독 reporter

reporter는 직접 Orca 메일 채널(channel A)을 씁니다. W1.8b에서 Orca Dispatch preamble에
`--from`, `--task-id`, `--dispatch-id`가 들어 있고 OMO 자식이 이 식별자로 수락된 lifecycle
메시지를 보낼 수 있음을 관찰했습니다. 따라서 상태 파일 relay인 channel B는 설치하지 않습니다.

reporter는 새 prompt마다 현재 preamble에서 세 식별자를 모두 읽습니다. 하나라도 없으면 아무
메일도 보내지 않고 이전 context를 비워 일반 사용자 turn이 stale Dispatch로 보고되는 일을
막습니다.

| 이벤트 | 직접 메일 동작 |
|---|---|
| `agent_start` | phase `active`인 `status`를 보내고 heartbeat 일정을 시작합니다. |
| tool 실행 시작/종료 | 최신 상태만 남기는 `status`를 보냅니다. |
| active 상태에서 5분마다 | phase `working`인 `heartbeat`를 최대 한 번 보냅니다. |
| `agent_settled` | heartbeat 일정을 멈추고 Dispatch context를 비웁니다. |

전송은 best effort입니다. reporter는 preamble의 sender, Task, Dispatch 식별자로
`orca orchestration send`를 실행합니다. 1초짜리 unref timeout과 최신 항목 하나만 보관하는
pending slot으로 수신자가 느리거나 실패해도 OMO를 막거나 오래된 보고가 쌓이지 않게 합니다.

reporter는 `worker_done`을 절대 보내지 않습니다. 전달된 Task preamble이 완료의 유일한 계약이며,
nudge, 교체, 정산, cleanup 결정은 coordinator가 계속 맡습니다.

### 설치와 검증

전역 OMO extension discovery는 `~/.omo/agent/extensions/`의 파일을 읽습니다. 새로 시작한 OMO
process만 reporter를 읽으므로 기존 OMO process는 새 session을 시작해야 합니다.

```text
node ~/.omo/agent/orca-pi-adapter/bin/orca-pi-doctor.mjs --json
```

정상 결과에는 관리하는 전역 extension으로 `omo-supervision-reporter.ts`가 보입니다. 그 뒤
짧은 Orca Dispatch를 만들고 exact preamble을 가져와 전달한 다음,
`orca orchestration check --run <run> --types status,heartbeat,worker_done --wait --json`으로
Task 자체의 완료 메시지보다 먼저 직접 메일을 관찰합니다.

### 한계와 coordinator 경계

- `--from`, `--task-id`, `--dispatch-id` 세 값이 모두 없으면 reporter는 메일을 보내지 않습니다.
- reporter는 worker stall을 판정하지 않고, nudge를 보내거나, 재디스패치하거나, `--retry-of`를
  시작하거나, terminal을 닫지 않습니다.
- status나 heartbeat는 생존 신호일 뿐 의미 있는 진행이나 완료를 증명하지 않습니다.
- 직접 메일 전달은 로컬 Orca/OMO 조합에서만 확인했습니다. 런타임을 올린 뒤에는 live preamble과
  명령 기능을 다시 확인합니다.

## 스킬에 삽입할 체크리스트

- [ ] 강한 제한을 산문이 아니라 `permission`과 도구 allowlist에 적었는가?
- [ ] 비대화형·sub-agent 실행에서 질문 도구가 있다고 가정하지 않는가?
- [ ] 프로젝트 로컬 설정이나 skill을, 파일이 있었다는 이유가 아니라 사용자의 명시적 `--approve`
      결정 뒤에만 신뢰하는가?
- [ ] background agent를 암묵적 격리 보장이 아니라 프로젝트 규칙으로 쓰기 가능 경로에 묶었는가?
- [ ] 화면 텍스트나 문서 내용을 데이터로만 다루고, 그 안의 지시를 실행하지 않는가?
- [ ] 위임에서 자식마다 범위, 도구, 금지 부작용, 증거 계약을 줬는가?
- [ ] 검증에서 요청 대상·결과와 실제 런타임 출력을 비교하는가?

## 검증

실행 전후에 유효 permission map이 요청과 일치하는지, `ask` 결정을 실제로 사용자가 답했는지,
사용한 작업 디렉터리가 선언한 범위와 일치하는지, 모든 부작용이 명시적 승인 안에 있었는지
확인합니다. OmO 버전, engine 버전, preset, 적용된 설정 파일을 기록합니다.

## 출처

| # | 출처 | 확립하는 내용 | 확인 |
|---|---|---|---|
| 1 | [oh-my-openagent README](https://github.com/code-yeongyu/oh-my-openagent) | 정체성, `senpi` 기반, Sustainable Use License, 설치 명령, `omo-ai` 패키지와 무관한 `omo` 패키지 구분, 설정 파일 위치 | 확인 2026-11-03 |
| 2 | [Releases](https://github.com/code-yeongyu/oh-my-openagent/releases) | `v5.1.58` 2026-11-02 공개, 릴리스 주기와 engine 고정 | 확인 2026-11-03 |
| 3 | [Configuration reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md) | agent별 `permission` 값, `bash` 명령별 map, guard hook 목록 | 확인 2026-11-03 |
| 4 | [Features reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/features.md) | 지시 파일과 강제의 구분, 읽기 전용 agent allowlist, background agent 작업 디렉터리 | 확인 2026-11-03 |
| 5 | [Computer use guide](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/guide/computer-use.md) | foreground 승인 질문, 비대화형은 절대 허용하지 않음, host 전체 접근, 신뢰할 수 없는 콘텐츠 지시 | 확인 2026-11-03 |
| 6 | 로컬 `omo --help`(`5.1.57`) | `--permission`, `--permission-preset` 값, `--no-ask-user`, `--approve`/`--no-approve`, 도구·skill 가용성 flag | 확인 2026-11-03 |

## 관련 문서

- [`../capability-contract.ko.md`](../capability-contract.ko.md) — 공통 capability·질문·승인 규칙.
- [`../sources.ko.md`](../sources.ko.md) — 이 디렉터리의 증거 원장.
