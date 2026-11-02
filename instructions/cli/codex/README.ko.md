# Codex CLI 런타임 프로필

> 영어판: [`README.md`](README.md)

이 문서는 Codex CLI(`codex`)에서 실행되는 skill의 런타임 프로필이다. 공통 안전·질문·승인 계약은 [capability-contract.ko.md](../capability-contract.ko.md)를 따른다. 각 행의 규칙은 행에 적은 공식 Codex 문서로 확인했고 근거 목록은 [`../sources.ko.md`](../sources.ko.md)에 있다(확인 2026-11-03). 이 프로필이 처음 인용한 로컬 `skills/codex/SKILL.md`는 커밋 `d4f79f9`에서 제거되었으므로 더 이상 근거가 아니다.

## 적용 범위와 계약

- Codex CLI가 명시적으로 필요할 때만 이 프로필을 적용한다. 일반 문서 작성이나 직접 로컬 편집의 대체 수단으로 쓰지 않는다.
- 비대화형 작업에는 `codex exec`(`codex e`)를 쓴다. 최상위 `codex "프롬프트"`는 대화형 TUI이므로 자동화 호출로 보지 않는다.
- 분석·리뷰·계획은 `--sandbox read-only`에서 시작한다. 사용자가 워크스페이스 파일 수정을 요청했을 때만 `--sandbox workspace-write`를 고른다.
- `codex review`는 읽기 전용으로 유지하고, writable sandbox나 우회 플래그와 결합하지 않는다.
- 어떤 capability나 CLI 옵션도 외부·파괴적·자격 증명 사용·프로덕션 작업의 승인이 아니다.
- 안전이나 산출물을 실질적으로 바꾸는 결정·승인이 빠졌을 때만, 세션에서 확인한 질문 표면으로 묻거나 평문 한 문장으로 물은 뒤 멈춘다.

## 공식 문서로 확인된 동작

| 영역 | 확인된 규칙 |
|---|---|
| 실행 | `codex exec`는 "사람의 개입 없이 끝나야 하는 스크립트나 CI 실행"에 문서화된 진입점이다. `--json`은 줄 단위 이벤트를 출력하고, `-o`/`--output-last-message`는 마지막 메시지를 파일로 쓰며, `--output-schema`는 최종 응답을 JSON Schema로 검증하고, `--ephemeral`은 세션 파일을 남기지 않는다 |
| 리뷰 | `codex review`는 비대화형으로 실행되고 대상은 정확히 하나만 고른다. `--uncommitted`, `--base <branch>`, `--commit <sha>`, 사용자 프롬프트 중 하나이며 `--title`은 `--commit`과 함께여야 한다. CLI 문서는 리뷰가 작업 트리를 수정하지 않고 발견 사항만 보고한다고 적는다 |
| 재개·분기 | `codex exec resume [SESSION_ID]`는 비대화형으로 이어가고, `--last`는 현재 디렉터리의 최근 세션을, `--all`은 검색 범위를 넓힌다. `codex exec fork <SESSION_ID> [PROMPT]`는 세션을 새 세션으로 복사하며, 대화형 세션에는 `codex resume`과 `codex fork`를 쓴다 |
| 샌드박스 | `--sandbox`/`-s` 값은 `read-only`, `workspace-write`, `danger-full-access`다. `--add-dir`는 쓰기 가능한 루트를 더하고 `-C`/`--cd`는 작업 디렉터리를 정한다. 샌드박스는 내장 파일 작업뿐 아니라 실행되는 모든 명령에 적용된다 |
| 승인 플래그 | `-a`/`--ask-for-approval` 값은 `on-request`와 `never`뿐이다. `--approve-for-me`/`--not-so-yolo`는 `on-request`와 `workspace-write` 조합으로 자동 승인 리뷰를 쓰며 `--sandbox`, `--yolo`와 충돌한다. `--yolo`/`--dangerously-bypass-approvals-and-sandbox`는 승인과 샌드박스를 모두 끄며 외부에서 강화된 환경 전용으로 문서화되어 있다 |
| worktree | `--worktree`는 관리되는 Git worktree에서 시작하고 `resume`, `review`, `--ephemeral`, `--ignore-user-config`와 함께 쓸 수 없다 |
| plugin·MCP | `codex plugin`은 설정된 marketplace에서 plugin을 설치·조회하고, `codex mcp`는 `~/.codex/config.toml`에 저장된 서버를 관리하며, `codex plugin marketplace`는 소스를 관리한다 |

위 표는 벤더 문서를 기록한 것이지 설치된 CLI의 완전한 기능·도구 목록이 아니다. 런타임 동작이 다르면 `codex --help`나 해당 서브커맨드 help로 확인하고, 확인 전에는 지원 사실로 서술하지 않는다.

## 승인 모델

게이트된 작업 전에는 두 계층이 모두 필요하다.

- **샌드박스 모드**는 기술적으로 가능한 범위를 정한다. 쓰기가 어디에 떨어지는지, 명령이 네트워크에 닿는지가 여기에 속한다. 기본 `workspace-write` 모드는 `[sandbox_workspace_write] network_access = true`를 설정하기 전까지 네트워크를 끈 상태로 둔다.
- **승인 정책**은 언제 멈추고 묻는지를 정한다. 샌드박스를 벗어나는 행동, 네트워크 사용, 신뢰 집합 밖 명령 실행이 여기에 해당한다.

| 사실 | skill에 주는 결과 |
|---|---|
| `approval_policy = "untrusted"`는 폐기되었다. 문서는 "Codex와 ChatGPT Work가 더 이상 지원하지 않으며" 폐기된 설정이 클라이언트 시작을 막을 수 있다고 적는다 | `untrusted`를 만들거나 권하지 않는다. 더 엄격한 명령 승인이 필요하면 `on-request`와 프로젝트 `trust_level = "untrusted"` 항목을 쓴다 |
| `Auto` 프리셋은 `--sandbox workspace-write --ask-for-approval on-request`다 | 문서화된 저마찰 로컬 기본값이며 권한 부여가 아니다 |
| 앱·MCP 도구 호출이 destructive 애노테이션을 표시하면 항상 승인이 필요하다. read 애노테이션이 있으면 그쪽이 우선한다 | capability가 보인다는 사실은 여전히 동의가 아니다 |
| 세션 중 `/permissions`는 모드를 바꾸고 활성 샌드박스와 쓰기 가능 루트를 보여 준다 | 경계를 추측하지 말고 이 명령으로 확인한다 |
| 비대화형 실행에서 새 승인이 필요한 행동은 실패하고 오류가 워크플로로 전달된다 | 스크립트 실행은 필요한 승인을 미리 갖추거나 실패를 받아들여야 한다. 프롬프트에 답할 수 없다 |

## 위임과 백그라운드

| 표면 | 확인된 동작 |
|---|---|
| subagent 워크플로 | 현재 릴리스는 agent를 병렬로 띄우고 결과를 한 응답으로 모은다. CLI에서는 `/subagents`로 agent 스레드를 전환한다. subagent 활동은 기본으로 켜져 있다(`agents.enabled = true`) |
| 병렬 상한 | `agents.max_concurrent_threads_per_session`이 열린 agent 스레드 수를 제한하며, 설정하지 않으면 Codex가 기본값을 고른다 |
| 승인 상속 | "Subagent는 `/permissions`나 `--yolo`로 바꾼 것을 포함해 부모 턴의 현재 샌드박스와 승인 설정을 상속한다. 커스텀 agent 파일은 그 설정을 대체할 수 없다" |
| subagent의 승인 요청 | 대화형 세션에서는 비활성 스레드의 승인 요청이 출처 라벨과 함께 뜬다. 비대화형 흐름에서는 그 행동이 실패한다 |
| 커스텀 agent | `~/.codex/agents/`(개인)나 `.codex/agents/`(프로젝트) 아래의 독립 TOML 파일이며 `name`, `description`, `developer_instructions`가 필수다. 파일의 `model`과 `model_reasoning_effort`는 부모 값보다 우선한다 |
| 내장 agent | `default`, `worker`, `explorer`가 있고, 같은 이름의 커스텀 agent가 우선한다 |

따라서 위임 분량은 부모 세션이 소유한 상한에 맞춰 정하고, subagent가 권한을 넓힐 수 있다고 가정하지 않는다. 위임된 단위가 부모가 주지 않은 승인을 필요로 하면 프롬프트가 아니라 실패가 돌아온다.

## skill, plugin, hook

| 표면 | 확인된 동작 |
|---|---|
| skill 구조 | skill은 `SKILL.md`(`name`과 `description` 필수)와 선택 사항인 `scripts/`, `references/`, `assets/`, `agents/openai.yaml`을 담은 디렉터리다 |
| skill 위치 | `$CWD/.agents/skills`, `$CWD/../.agents/skills`, `$REPO_ROOT/.agents/skills`, `$HOME/.agents/skills`, `/etc/codex/skills`, 그리고 Codex에 묶인 시스템 skill이다. 심볼릭 링크 폴더도 따라간다 |
| 호출 | 명시 호출은 CLI의 `$` 멘션이나 `/skills`이고, 암시 호출은 `description` 일치로 이뤄진다. `agents/openai.yaml`의 `allow_implicit_invocation: false`가 암시 호출을 끈다 |
| skill 컨텍스트 예산 | 최초 목록은 컨텍스트 창의 최대 2%, 창을 알 수 없으면 8,000자다. `skills.max_context_tokens`로 최대 10,000토큰까지 늘린다 |
| skill 끄기 | `~/.codex/config.toml`의 `[[skills.config]]`에 항목당 선택자(`path` 또는 `name`)를 정확히 하나 둔다. 일치하는 항목 중 마지막이 이긴다 |
| plugin | plugin은 하나 이상의 skill을 담고 MCP 서버 연결과 표현 자산을 선택으로 묶는다. `codex plugin add <plugin[@marketplace]>`로 marketplace에서 설치한다 |
| hook | `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`, `SubagentStop`, `Stop`, `PreModelRequest`, `PostModelRequest`, `Interrupt`, `SessionStart`, `SubagentStart`, `SessionEnd`에서 스크립트나 MCP 도구를 실행한다. 설정 위치는 `~/.codex/hooks.json`, `<repo>/.codex/hooks.json`, config 계층, plugin이다 |

- 관리되지 않는 hook은 실행 전에 **검토와 신뢰**가 필요하고, 신뢰는 hook의 해시에 기록되므로 바뀐 hook은 다시 검토할 때까지 건너뛴다. `/hooks`가 그 검토를 수행하며 `--dangerously-bypass-hook-trust`는 한 번의 실행에서 이를 건너뛴다.
- 프로젝트 로컬 hook은 프로젝트 `.codex/` 계층을 신뢰할 때만 로드한다.
- `PermissionRequest` hook은 승인 요청에 답할 수 있다. 그래서 hook은 정책 계층이지 사용자 동의가 아니다. 승인을 결정하는 hook은 보고한다.

## 목표 모드와 스케줄

- 대화형 CLI 세션에서 `/goal`은 **Goal 모드**를 시작한다. 목표 문장이 첫 프롬프트이자 완료 기준이 된다. 목표를 시작해도 접근 범위가 넓어지지 않으며 같은 샌드박스와 승인 정책을 유지하고 결정이 필요할 때 멈춘다.
- 예약 작업(이전 이름 automations)은 **CLI에서 관리하지 않는다.** 문서는 Codex CLI가 Scheduled 관리 인터페이스를 제공하지 않으며 만들기와 관리는 ChatGPT 웹이나 데스크톱 앱에서 한다고 밝힌다. CLI 스케줄 플래그를 주장하지 않는다.
- `codex cloud`는 터미널에서 클라우드 대화를 조회·제출하고 `codex apply`는 최근 클라우드 diff를 로컬에 적용한다. 로컬 세션 밖으로 작업을 넘기는 경로가 스케줄이 아니라 이 두 명령이다.

## 읽기·쓰기·명령 안전

- 읽기: 기본은 `codex exec --sandbox read-only`이고 리뷰도 읽기 전용이다.
- 쓰기: 사용자가 Codex의 워크스페이스 수정 의도를 밝혔을 때만 `workspace-write`를 쓴다. 일반 수정에 우회 플래그를 쓰지 않는다.
- 명령: 사용자가 요구하지 않으면 모델·프로필·승인 정책을 기본값으로 두고, `--add-dir`는 필요한 경로에만 쓰며, `--skip-git-repo-check`는 저장소 밖 실행을 명시적으로 승인받았을 때만 쓴다.
- 인증·샌드박스·세션 실패는 원인과 차단 상태를 함께 보고하고, 사용자가 원한 범위 안에서만 재시도한다.

## 비목표

- Codex의 전체 옵션, 설치 상태, 인증 방식, 모델 목록을 추정하거나 보증하지 않는다.
- 런타임 capability를 권한 상승이나 사용자 승인으로 해석하지 않는다.
- 사용자 요청 없이 세션을 재개·분기하거나 파일을 수정하지 않는다.

## 스킬 내 사용 체크리스트

- [ ] 요청이 Codex CLI나 별도 세션을 명시적으로 요구하는가?
- [ ] 비대화형 호출이 `codex exec`이고, 분석·리뷰가 `read-only`인가?
- [ ] 쓰기·추가 디렉터리·권한 완화가 사용자 의도와 안전 경계에 맞고, `untrusted` 정책과 `--yolo` 기본값을 쓰지 않았는가?
- [ ] 위임에서 동시성 상한을 지켰고, 비대화형 실행에서 프롬프트가 아니라 실패가 돌아옴을 전제했는가?
- [ ] 새로 추가한 hook과 skill을 사용 전에 검토했고, hook의 판단을 동의로 취급하지 않고 보고했는가?
- [ ] 결과·경고·부분 출력·인증/세션/샌드박스 차단을 함께 보고하는가?
- [ ] 중요한 미결정 사항에 확인된 질문 표면만 쓰고, 아니면 평문 한 문장으로 묻고 중단하는가?
