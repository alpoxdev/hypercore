# Claude Code 런타임 프로필

> 영어판: [`README.md`](README.md)

## 범위

이 문서는 **Claude Code CLI(`claude`)를 명시적으로 요청한 skill**의 실행 프로필이다. 일반 문서 작성이나 직접 로컬 편집의 기본 프로필이 아니다. 공통 계약은 [`../capability-contract.ko.md`](../capability-contract.ko.md)를 따른다.

## 권위와 근거

- **권위:** 사용자 의도와 프로젝트 로컬 규칙이 우선한다. 이 문서는 권한을 부여하지 않고, 각 논리적 capability가 어디에 대응하며 무엇을 먼저 확인해야 하는지만 적는다.
- **검증된 근거:** 아래의 플래그, 권한 모드, 명령, subagent, hook, skill, plugin, workflow, 스케줄은 [`../sources.ko.md`](../sources.ko.md)에 정리한 공식 문서로 확인했다(확인 2026-11-03). 이 프로필이 처음 인용한 로컬 `skills/claude-code/SKILL.md`는 커밋 `d4f79f9`에서 제거되었으므로 더 이상 근거가 아니다.
- **런타임 의존 사항:** 설치 여부, 인증, 플랜과 관리자 정책, 실제 사용 가능한 플래그, 구조화 질문·승인 표면은 실행 세션에서 확인해야 한다. `claude --help`는 모든 플래그를 나열하지 않으며, CLI reference는 `--help`에 없다고 해서 사용할 수 없는 것은 아니라고 밝힌다.
- 런타임 출력은 **증거**이지 권위가 아니다. 사용자 의도나 로컬 규칙과 충돌하면 멈추고 보고한다.

## 진입 표면

| 논리적 capability | Claude Code의 구현 | 실행 전 확인 |
|---|---|---|
| 비대화형 실행 | `claude -p "<프롬프트>"`(`--print`), `--output-format text\|json\|stream-json`, `--input-format text\|stream-json` | 설치·인증·작업 디렉터리, 그리고 래퍼가 `-p` 없이 위치 인수 프롬프트를 덧붙이지 않는지(그 경우 대화형 REPL이 열린다) |
| 세션 계속 | 최근 대화는 `claude -c`(`--continue`), 특정 세션은 `claude -r <id\|이름>`(`--resume`), `--fork-session`은 재개 사본에 새 ID를 준다 | 대상 세션의 존재 여부와 재개가 설정을 바꾸는지. `--continue`는 `-p`, Agent SDK, 첫 프롬프트가 `/loop`인 세션을 건너뛰며, `-p`를 함께 주면 포함한다 |
| 출력 형태 | 검증된 JSON은 `--json-schema`, 부분 스트리밍은 `--include-partial-messages`, 상세 로그는 `--verbose`, subagent 텍스트는 `--forward-subagent-text`(v2.1.211 이후) | 설치된 버전이 지원하는 출력 모드 |
| 실행 상한 | `--max-turns`, `--max-budget-usd`(print 모드 전용, subagent 지출도 상한에 포함) | 정책상 턴·비용 상한이 필요한지 |
| 격리 | `--restricted`(v2.1.248 이후), `--bare`, `--safe-mode`, `--worktree`/`-w`, `--tmux` | 실행을 어느 환경에 가둬야 하는지 |

## 권한 모드

문서화된 모드는 여섯 가지이며 폐기된 모드는 없다. Manual은 UI 표시 이름이고, 설정값은 `default`이며 `manual`은 별칭이다(v2.1.200 이후).

| 모드 | 묻지 않고 실행하는 범위 | 비고 |
|---|---|---|
| `default` | 읽기만 | CLI가 **Manual**로 표시하는 모드 |
| `acceptEdits` | 읽기, 파일 편집, 작업 디렉터리나 `additionalDirectories` 안의 흔한 파일 시스템 명령(`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`) | 자동 승인은 그 경로 밖으로 확장되지 않는다 |
| `plan` | 읽기, 그리고 auto 모드를 쓸 수 있으면 classifier가 승인한 명령 | 계획을 승인할 때까지 편집이 막힌다 |
| `auto` | classifier 모델이 먼저 검토한 뒤 모든 동작 | v2.1.283부터 대화형 터미널과 VS Code 세션의 내장 시작 모드다. 문서는 프롬프트를 줄여 주지만 **안전을 보장하지는 않는다**고 밝힌다 |
| `dontAsk` | 작업 디렉터리 안의 읽기와 미리 승인된 도구. 프롬프트가 필요할 호출은 거부 | Shift+Tab 순환에 나타나지 않으며 CI 용도다 |
| `bypassPermissions` | 보호 경로 쓰기를 포함한 모든 동작 | 이 모드로 시작하지 않은 세션에서는 진입할 수 없다. 문서는 격리된 컨테이너와 VM 전용으로 적는다 |

- 시작 모드 결정 순서는 `--permission-mode`/`--dangerously-skip-permissions`, `permissions.defaultMode`, 내장 기본값이다. 프로젝트 설정 파일의 `"auto"`와 `"bypassPermissions"`는 적용되지 않고 내장 기본값이나 Manual로 돌아간다.
- v2.1.302부터 모드를 지정하지 않은 `claude -p`와 Agent SDK 실행은 Manual로 시작하며, 승인이 필요한 호출은 허용 규칙, hook, `canUseTool` 콜백, `--permission-prompt-tool` 중 하나로 승인하지 않으면 **거부**된다.
- 누적 규칙이 모드를 덮는다. 거부 규칙은 `bypassPermissions`를 포함한 모든 모드에서 막고, 허용 규칙은 `bypassPermissions`에서 효력이 없다.
- 어떤 모드도 ask 규칙, 조직이 ask로 지정한 connector 도구, 사용자 상호작용이 필요한 도구, 인식된 핵심 경로 `rm`/`rmdir`, 교차 세션 메시징 안전장치, `permissions.blockReadsOutsideWorkingDirectories`가 켜진 상태의 작업 디렉터리 밖 읽기를 자동 승인하지 않는다.

## 질문·승인 게이트

- **구조화 질문 capability가 있다.** 권한 모드 문서는 내장 `AskUserQuestion` 도구를 사용자 상호작용이 필요한 도구로 이름을 밝히고, 어떤 모드에서도 자동 승인하지 않는다고 적는다. `ask_user`의 구현으로 다루되, 의존하기 전에 세션에서 노출을 확인한다.
- **비대화형 승인 경로.** `--permission-prompt-tool mcp__<서버>__<도구>`는 권한 프롬프트를 MCP 도구로 넘기고, `--permission-prompts none`(v2.1.259 이후)은 응답할 사람이 없을 때 프롬프트를 거부하며, `--allowedTools`는 패턴을 미리 승인한다. 프롬프트 도구는 사용자 상호작용이 필요한 MCP 도구를 승인할 수 없고, 그 결과는 거부로 바뀐다.
- **게이트된 작업에는 별도 승인이 필요하다.** 노출된 capability, 허용 규칙, auto 모드 classifier는 외부·파괴적·자격 증명 사용·프로덕션 작업에 대한 사용자 승인이 아니다.
- 구조화 표면을 확인하지 못하면 평문으로 한 문장만 묻고 게이트된 행동 전에 멈춘다.

## 위임, 백그라운드, 루프

| 표면 | 무엇인가 | capability 결과 |
|---|---|---|
| subagent | `.claude/agents/`(프로젝트), `~/.claude/agents/`(사용자), 한 세션용 `--agents` JSON, plugin `agents/`, 관리 설정에 정의하며 `name`과 `description`만 필수다 | `delegate` |
| subagent 동시성 | 세션당 기본 20개 동시 실행(`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`), 중첩은 세션 아래 3계층까지(`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, `1`이면 중첩 해제) | 위임 분량을 이 상한에 맞춰 정한다. 문서에 따르면 상한을 넘긴 호출은 재시도하지 말라는 오류가 난다 |
| 백그라운드 subagent | subagent는 기본적으로 백그라운드에서 시작하고 결과는 이후 턴의 완료 알림으로 도착한다. `/subtask`는 현재 대화로 결과를 돌려주고, `/fork`는 대화를 별도 백그라운드 세션으로 복사하며, `/batch`는 격리된 worktree로 나눠 실행한다 | `delegate`와 `background`. 알림을 받기 전에 백그라운드 결과를 완료로 보고하지 않는다 |
| hook | 문서화된 33개 이벤트와 다섯 가지 핸들러 유형(`command`, `http`, `mcp_tool`, `prompt`, `agent`)이 있고, 설정 파일, plugin `hooks/hooks.json`, skill frontmatter, subagent frontmatter에 설정한다 | 승인 형태의 이벤트(`PermissionRequest`, `PermissionDenied`)가 있지만 hook의 판단은 **런타임 정책**이지 사용자 동의가 아니다 |
| 동적 workflow | 런타임이 대화와 분리된 곳에서 백그라운드로 실행하는 JavaScript 스크립트다. 기본 동시 agent 16개(최대 256), 실행당 agent 1,000개, 실행 중 사용자 입력 없음, 스크립트의 파일 시스템·셸 직접 접근 없음 | 대규모 `delegate`. 승인 통로가 아니고 대화형이 아니다 |
| 세션 루프 | `/loop [간격] [프롬프트]`(별칭 `/proactive`). 단위는 `s`/`m`/`h`/`d`, 내부는 5필드 cron, 세션당 최대 50개, 반복 작업은 7일 뒤 만료된다. `loop.md`는 `.claude/loop.md`를 먼저 보고 다음 `~/.claude/loop.md`를 보며 내장 프롬프트를 대체한다 | `loop`. 반복 행동에는 명시적 종료 조건과 자체 승인 경계가 필요하다 |
| 클라우드 스케줄 | `/schedule`(별칭 `/routines`)은 프롬프트, 저장소, connector를 클라우드 예약 작업으로 저장한다. Anthropic 관리 인프라에서 실행되고 research preview이며, 1시간보다 잦은 주기는 거부한다 | `schedule`. 세션보다 오래 사는 작업이므로 만들기 전에 명시적 승인이 필요하다 |
| 목표 유지 | `/goal [조건\|clear]`는 조건이 충족될 때까지 턴을 넘어 계속 작업하게 한다 | `persist`. 목표는 종료 조건이지 승인이 아니다 |

## 확장 표면

| 표면 | 계약 | 게이트 |
|---|---|---|
| skill | `.claude/skills/<이름>/`(프로젝트), `~/.claude/skills/`, `--add-dir`로 넘긴 디렉터리, plugin `skills/` 아래의 `SKILL.md`. frontmatter는 모두 선택 사항이고, `disable-model-invocation: true`는 수동 호출 전용으로 만들며, `allowed-tools`는 skill을 호출한 턴에만 도구 사용을 허가한다 | skill 설치가 그 지시에 대한 승인은 아니다. 실행 전에 읽는다 |
| 명령 | 사용자 정의 명령은 skill로 통합되었다. `.claude/commands/deploy.md`와 `.claude/skills/deploy/SKILL.md`가 모두 `/deploy`를 만들며, 새 작업에는 skill을 권한다 | skill과 같다 |
| plugin | plugin은 skill, agent, hook, hook 모듈("mod"), MCP 서버, LSP 서버를 담은 디렉터리이고 `.claude-plugin/plugin.json`을 둔다. 대부분 marketplace에서 오며, marketplace는 호스팅 스토어가 아니라 `.claude-plugin/marketplace.json`을 가진 저장소다. `--plugin-dir`/`--plugin-url`은 한 세션용으로 `<이름>@inline`처럼 싣는다 | plugin은 hook과 MCP 서버라는 실행 표면을 더한다. 그래서 싣는 일은 편의가 아니라 범위 변경이다 |
| 도구 목록 | `--tools`는 내장 도구를 제한하고(`""`, `default`, 이름 목록), `--allowedTools`/`--disallowedTools`는 허용·거부 규칙을 정하며, MCP 도구까지 없애려면 `--disallowedTools "mcp__*"`가 필요하다 | 세션에서 실제 목록을 확인하고 고정 목록으로 단정하지 않는다 |

## 읽기·쓰기·명령 안전 경계

- 읽기: 요청 범위와 허용 디렉터리 안에서만 읽고, 파일 변경 없는 분석에는 plan 모드를 쓴다.
- 쓰기: 사용자가 그 변경을 요청했을 때만 생성·수정·이동·복사한다. `acceptEdits`는 그 요청을 대신하지 않는다.
- 명령: 명령은 최소 범위로 구성하고 자동화에는 `-p`를 쓴다. `--dangerously-skip-permissions`와 `bypassPermissions`는 기본값이 아니며, 명시적 승인과 격리 조건에서만 쓴다.
- 경고, 부분 출력, 인증·세션·권한 차단 사유를 결과와 함께 보고한다.

## 폐기되거나 제거된 표면

- `--remote`는 `--cloud`의 폐기된 별칭이고, `--enable-auto-mode`는 v2.1.111에서 제거되었다(`--permission-mode auto`를 쓴다).
- `/pr-comments`는 v2.1.91에서, `/vim`은 v2.1.92에서 제거되었고 `/ultraplan`은 plan 모드로 대체되어 제거되었다.
- `/usage-credits`는 이전 이름이 `/extra-usage`이고, `/schedule`은 이전 이름이 routines이며 `/routines` 별칭을 유지한다.

## skill 사용 체크리스트

- [ ] 요청이 Claude Code CLI나 별도 세션을 명시적으로 요구하는가?
- [ ] 비대화형이면 `-p`를 쓰고, `--continue`/`--resume`을 의도적으로 골랐는가?
- [ ] 권한 모드가 요청을 만족하는 최소값이고, 거부 규칙과 보호 경로를 파악했는가?
- [ ] 구조화 질문 표면을 사용 전에 확인했고, 답을 받기 전에 게이트된 행동을 하지 않았는가?
- [ ] 위임에서 동시성, 백그라운드 알림, workflow 상한을 가정하지 않고 반영했는가?
- [ ] 루프·스케줄·목표에 명시적 종료 조건과 별도 승인이 있는가?
- [ ] 결과에 경고, 부분 출력, 인증·세션·권한 차단 사유를 포함했는가?
