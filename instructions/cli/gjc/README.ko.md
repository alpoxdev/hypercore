# GJC 런타임 프로필

> 영어판: [`README.md`](README.md)
>
> **조사일:** 2026-11-03. 제품 동작은 Gajae-Code `v0.19.2`(GitHub 릴리스, 2026-10-29)와 그 시점의
> `main` 브랜치 1차 저장소 문서를 기준으로 합니다. nightly 채널이 안정 tag보다 앞서 배포되므로,
> 명령이나 기본값을 신뢰하기 전에 `gjc --version`과 대응 문서를 다시 확인합니다.

## 범위

이 문서는 `gjc` CLI, 즉 **Gajae-Code**에서 스킬을 작성·실행하기 위한 어댑터 규칙입니다.
저장소는 [`Yeachan-Heo/gajae-code`](https://github.com/Yeachan-Heo/gajae-code), 사이트는
[`gajae-code.com`](https://gajae-code.com), npm 패키지는 `gajae-code`, 라이선스는 MIT이며,
관리자는 실험적 beta 단계 프로젝트라고 밝힙니다. 같은 이니셜을 쓰는 다른 도구에는 적용하지
않습니다.

공통 capability·권한·질문·승인 규칙은 [`../capability-contract.ko.md`](../capability-contract.ko.md)를
따릅니다. GJC에 도구가 있거나 런타임 방어 장치가 있다는 사실은 행동 권한을 부여하지 않습니다.

## 근거 경계

- 1차 근거는 README, 저장소 `docs/`, `docs/tools/`의 도구별 reference, 사용자 정의·신뢰 계약
  문서, 릴리스 feed입니다.
- 프로젝트는 nightly 빌드를 배포하며 빠르게 바뀝니다. 아래 주장은 고정한 안정 tag 기준으로만
  유효하므로, 의존하기 전에 대응 소스나 문서를 다시 읽습니다.
- issue 보고와 제3자 통합 기록은 관찰이지 확정된 동작이 아닙니다.
- 이 프로필은 capability와 안전 경계를 기록합니다. 설치·provider·명령 reference가 아닙니다.

## 런타임 바인딩

| 논리 capability | 확인된 GJC 표면 | 바인딩 규칙 |
|---|---|---|
| 로컬 점검 | `read`, `find`, `search`, `bash` | 경로를 선언된 저장소 범위로 제한합니다. GJC는 세션 작업 디렉터리 기준으로 경로를 해석하며, OS 사용자 권한이 바깥 경계입니다. |
| 로컬 검색 | `search`, `find`, `ast-grep`, `bash` | 네트워크를 쓰지 않는 근거를 우선합니다. 큰 shell 출력은 요약되고 `artifact://` 참조로 흘러나갈 수 있으므로, 발췌로 부족하면 artifact를 가져옵니다. |
| 네트워크 조사 | `web_search`, `browser`, `ssh`, MCP 도구 | 네트워크 접근과 데이터 반출을 별도 부작용으로 보고 목적지를 확인합니다. |
| 편집 | `write`, `edit`, `ast-edit`, `bash`, `python`, `eval` | 사용자가 변경을 요청했을 때만 사용합니다. 파일 도구의 정책과 무관하게 shell과 interpreter 도구가 파일을 쓸 수 있습니다. |
| 실행 | `bash`, `job`, `cron`, `monitor`, `ssh` | 실행 전에 명령, 작업 디렉터리, 대상 host, 부작용을 검증합니다. 차단된 shell 패턴은 승인 판단이 아닙니다. |
| 사람의 결정 | `ask`, workflow gate | 런타임이 실제로 답변 표면을 제공할 때만 사용합니다(아래 참조). |
| 위임 | `task` | 자식마다 목표, 소유 범위, 허용 도구, 금지 부작용, 증거 계약을 줍니다. 부모 검증은 그대로 필요합니다. |
| 데스크톱 제어 | `computer` | supervisor가 gate하는 macOS 입력입니다. screenshot은 읽기 전용이고, click·type·keypress는 전역이며 대상이 한정되지 않습니다. |

바인딩 전에 라이브 도구 schema를 발견합니다. 도구 가용성은 `--tools`, `--no-tools`, `--no-lsp`,
`--no-pty`, MCP 설정, 세션 모드에 따라 달라집니다.

## 질문과 승인

GJC에는 실제 `ask` 도구가 있지만 가용성이 조건부입니다.

- 구조는 `questions[]`이고 각 항목은 `id`, `question`, `options[]`(label만), 선택적 `multi`,
  선택적 `recommended` index를 갖습니다. UI가 `Other (type your own)`를 덧붙이므로 호출자가
  직접 넣으면 안 됩니다. prompt 지침은 선택지 2~5개를 권하지만 schema가 강제하지는 않습니다.
- 등록이 조건부입니다. 세션에 UI가 있거나, workflow gate 대상이거나, workflow gate emitter를
  노출할 때만 도구가 생깁니다. 답변 표면이 전혀 없는 순수 headless 세션에는 생기지 않으므로,
  skill은 질문할 수 있다고 가정하면 안 됩니다.
- `ask.timeout`의 기본값은 `0`(비활성)입니다. 값을 설정하면 timeout 시 **권장 선택지를 자동
  선택**하고, 유효한 권장 index가 없으면 첫 선택지를 고릅니다. gated action에서 자동 선택된
  답을 사람의 결정으로 대신하면 안 됩니다.
- headless에서는 등록된 answer source가 답할 수 있고, `GJC_ASK_ANSWER_DEADLINE_MS`가 대기
  시간을 제한하며 만료 시 turn을 중단합니다. 사용자가 취소하면 성공 결과 대신 tool이
  중단됩니다.
- durable workflow gate는 SDK control 연산 `workflow.gate_answer`로 durable gate ID와 기대
  session ID를 함께 넘겨 답합니다. 일시적인 `action_needed.id`는 durable 권한이 아니며, 현재
  host는 프로토콜의 일반 `ask.answer`를 구현하지 않습니다.

승인 의미는 두 곳에 있습니다.

- **변경 전 계획.** `deep-interview`, `ralplan`, `ultragoal`은 명시적으로 호출하는 workflow이고,
  계획은 "그 자체로 구현을 승인하지 않습니다. 실행에는 명시적 승인이나 승인된 `ralplan`
  런타임 handoff가 필요합니다".
- **일회성 승인.** controller가 구동하는 작업에서는 변경 호출 전에 정확한 연산과 대상을 보여
  주고, 승인을 일회성으로 취급합니다. 연산·입력·대상이 바뀌면 다시 묻습니다.

답변 표면이 없으면 상호작용 prompt를 흉내 내지 말고 평문으로 묻고 gated action 전에 멈춥니다.

## 명령 승인과 파일 시스템

- `bash`에 대해 일반적인 명령 단위 사람 승인 gate는 문서화되어 있지 않습니다. 문서화된 명령
  제어는 가용성(`--tools`, `--no-tools`), tool에 더 맞는 shell 패턴을 전용 도구로 돌리는
  interceptor, 선택적 hook입니다.
- interceptor는 사용성 규칙이지 격리 경계가 아닙니다. 설정으로 끌 수 있고, interpreter
  one-liner가 실제로 하는 일을 검사하지 않습니다.
- 강제 가능한 지점은 hook입니다. `tool_call` / `pre_tool_use` handler는 순차 실행되고 fail
  closed이며, 첫 `{ block: true }`가 이후 handler를 멈춥니다. post-tool handler는 차단 권한을
  가져서는 안 됩니다.
- tmux 자기 pane 주입 guard는 최선 노력 정적 분석입니다. SDK의 직접 `executeBash()`는 이를
  우회하고, Python·eval 도구는 이 guard의 대상이 아닙니다.
- `--allow-home`이 있는 이유는 `~`에서 시작하면 기본적으로 임시 디렉터리로 옮겨 가기
  때문입니다. 이 시작 디렉터리 guard는 편의 경계이지 sandbox가 아닙니다.
- sandbox 모드는 문서화되어 있지 않습니다. 명령은 실행 사용자의 OS 권한으로 동작합니다. shell과
  interpreter 도구는 host 수준 실행으로 취급합니다.

## 프로젝트 신뢰와 설정

GJC의 권위 있는 설정 범위는 정확히 두 개입니다. 프로젝트 `<project>/.gjc/`와 사용자
`~/.gjc/agent/`입니다.

- **MCP**: 사용자 `~/.gjc/agent/mcp.json`과 프로젝트 `.gjc/mcp.json` 등록이 자동 로드됩니다.
  `--no-mcp`가 관례적 자동 로드를 끄고 `--mcp-config`가 도구 전용 파일을 지정합니다. Claude Code와
  Codex의 MCP 파일은 import 소스일 뿐 암묵적 런타임 권위가 아닙니다. 프로젝트 MCP는 실행 가능한
  설정이므로, 서버 명령이 프로젝트 신뢰 prompt 없이 시작될 수 있습니다. 신뢰할 수 없는 저장소를
  열기 전에 명령·인자·환경·출처를 확인합니다.
- **스킬**: 프로젝트 `.gjc/skills/<name>/SKILL.md`와 사용자
  `~/.gjc/agent/skills/<name>/SKILL.md`가 직접 로드됩니다. `skills.trustProjectSkills`와
  `skills.trustUserSkills`의 기본값은 켜짐이고, `skills.enabled`가 상위 스위치입니다. 프로젝트
  범위가 사용자 범위를 이기며, 번들 workflow skill 네 개는 디스크 복사본으로 대체할 수 없습니다.
- **Hook**: 일반 세션은 사용자 agent의 `~/.gjc/agent/hooks/` 모듈을 로드합니다. 저장소
  `.gjc/hooks/` 모듈은 보관만 되고 자동 실행되지 않으므로, 저장소를 연다는 이유로 시작 hook이
  설치되지는 않습니다.
- **지시문**: `AGENTS.md`가 지시 표면이고, `--no-rules`가 세션의 rule 발견을 끕니다.
- **설정**은 대화형 세션에서 라이브로 reload되고, 다시 로드된 정책이 실행 중인 세션에
  적용됩니다. 설정 변경 뒤에는 유효 도구 집합을 다시 확인합니다.

## 비대화형 사용과 SDK

- `gjc -p "<prompt>"`는 비대화형 turn 하나를 실행하고, `--mode`가 `text`, `json`, `acp`를
  고릅니다. 세션은 continue, prefix·경로 기준 resume, fork가 가능합니다.
- `--json` 출력은 구조화된 stdout 봉투를 씁니다. 종료 코드 `2`는 사용법 오류, `1`은 운영
  실패이므로, 성공 봉투가 없다고 실행되지 않았다고 단정하면 안 됩니다.
- broker에 묶인 SDK session CLI가 지원되는 controller 인터페이스입니다. 세션을 발견·점검한 뒤
  허용된 lifecycle 연산(`session.create`, `session.fork`, `session.resume`, `session.close`)을
  씁니다. `session.delete`는 허용되지 않고 endpoint 조회는 거부됩니다.
- 논리 prompt마다 새 `op-ref`가 필요합니다. `unknown`은 불확실성이지 미실행의 증거가 아니므로,
  prompt를 재전송하지 말고 status 조회로 화해합니다.
- 유계 대기가 만료되면 wait timeout을 보고할 뿐 실행 중인 turn을 취소하지 않습니다. 긴
  prompt는 heartbeat가 아니라 진척을 반영하는 무활동 lease로 제한됩니다.
- TUI를 긁어 읽거나 raw session WebSocket을 열지 않습니다. 값은 shell 문자열이 아니라 argv
  항목으로 넘깁니다.

## 데스크톱 제어

`computer`는 Apple Silicon macOS에서 기본 호출 가능하고 supervisor가 gate합니다. 주 display만
다루고 window 대상 지정이 없으며, 입력은 전역이고 범위가 한정되지 않습니다. 비활성·일시정지된
controller는 안정적인 `COMPUTER_*` 오류를 반환하고, Accessibility나 화면 기록 권한이 없으면
`COMPUTER_PERMISSION_REQUIRED`를 반환합니다. 이 제어는 격리가 아닙니다. kill switch는 이후
입력을 막을 뿐 focus를 되돌리거나 효과를 취소하지 않습니다.

## 버전 차이와 채널

- 안정 `v0.19.2`를 기준으로 고정하며, nightly 빌드는 자체 tag를 쓰고 flag를 더하거나 없앨 수
  있습니다.
- `main`을 pipe하는 대신 릴리스 tag로 고정한 installer를 쓰고, 자동화와 증거 묶음에
  `gjc --version`을 기록합니다. 릴리스 asset은 Linux x64/arm64(glibc 전용), macOS arm64/x64,
  Windows x64를 대상으로 하며, installer는 공개 SHA-256 checksum을 검증하고 smoke test를 거친
  뒤 기존 binary를 교체합니다.
- ACP provider(`gjc setup paseo`)나 Orca 같은 host의 custom CLI agent로 통합합니다. GJC는 설계상
  permission-bypass flag를 제공하지 않으므로 host가 그것을 추가해서는 안 되고, GJC 자체 gate가
  그대로 유효합니다.

## 스킬에 삽입할 체크리스트

- [ ] 필요한 capability를 논리 capability로 적고, 현재 flag·설정에서 존재하는 도구에
      바인딩했는가?
- [ ] 계획 산출물을 제안으로 다루고, 실행 전 명시적 승인을 요구하는가?
- [ ] `ask` 도구를 답변 표면이 있는 곳에서만 쓰고, `ask.timeout`의 자동 선택 답을 동의로 쓰지
      않는가?
- [ ] 답변 표면이 없을 때 평문 질문과 중단으로 처리하는가?
- [ ] 프로젝트 MCP 서버, 프로젝트 스킬, hook, 지시문을 저장소를 신뢰하기 전에 점검했는가?
- [ ] shell, interpreter, SSH, cron, computer control 부작용을 도구 가용성과 별도로 gate했는가?
- [ ] controller 작업에서 prompt마다 새 `op-ref`를 쓰고 `unknown`을 불확실성으로 처리하는가?
- [ ] 검증에서 요청 대상·결과와 실제 런타임 출력을 비교하는가?

## 검증

스킬 실행 전후에 (1) 발견한 capability와 실제 호출이 일치하는지, (2) 질문이 사용자에게 속한
누락 결정만 다루는지, (3) 답변 표면 부재 시 평문 질문 후 중단하는지, (4) 승인 전후 부작용
경계가 지켜지는지를 확인합니다. binary 버전, flag, 설정 범위, 확인하지 못한 capability를
기록합니다. 이 문서만으로 GJC의 도구 표면을 보증할 수 없습니다.

## 출처

| # | 출처 | 확립하는 내용 | 확인 |
|---|---|---|---|
| 1 | [Gajae-Code README](https://github.com/Yeachan-Heo/gajae-code) | 정체성, MIT 라이선스, beta 상태, 변경 전 계획 승인 문구, 모바일 답변, controller·host 통합, permission-bypass flag 부재 | 확인 2026-11-03 |
| 2 | [Releases](https://github.com/Yeachan-Heo/gajae-code/releases) | 2026-10-29 안정 `v0.19.2`, nightly 채널 | 확인 2026-11-03 |
| 3 | [`docs/tools/ask.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/tools/ask.md) | `ask` schema, 조건부 등록, `ask.timeout` 기본값과 자동 선택, headless deadline | 확인 2026-11-03 |
| 4 | [`docs/tools/bash.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/tools/bash.md) | 작업 디렉터리, timeout 제한, 배타 실행, interceptor 규칙, tmux guard 한계 | 확인 2026-11-03 |
| 5 | [`docs/customization.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/customization.md) | 권위 있는 두 범위, MCP 자동 로드, Claude·Codex는 import 전용, hook·skill 우선순위 | 확인 2026-11-03 |
| 6 | [`docs/hooks.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/hooks.md) | fail closed인 `tool_call`·`pre_tool_use` 차단 | 확인 2026-11-03 |
| 7 | [`docs/tools/computer.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/tools/computer.md) | supervisor gate, 주 display 범위, 전역 입력, 안정적 오류 코드 | 확인 2026-11-03 |
| 8 | [`docs/install.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/install.md) | 설치 방식, sha256 검증, 설치 경로, 갱신 채널 | 확인 2026-11-03 |

## 관련 문서

- [`../capability-contract.ko.md`](../capability-contract.ko.md) — 공통 capability·질문·승인 규칙.
- [`../sources.ko.md`](../sources.ko.md) — 이 디렉터리의 증거 원장.
