# CLI 런타임 프로필 근거 원장

> 영어판: [`sources.md`](sources.md)

## 조사 범위와 한계

- 확인일: 2026-11-03. 아래 모든 행은 이 날짜에 직접 읽었다(확인 2026-11-03). 행에 다른 날짜가 적힌 경우만 예외다.
- 경로: Aside 브라우저 세션으로 1차 벤더 문서를 읽고, 인용한 모든 URL을 `read`/`curl`로 직접 확인했다. 자격 증명은 쓰지 않았고, 설치도 하지 않았으며, 로컬 설정이나 설치된 CLI의 help 출력을 권위로 삼지 않았다.
- 범위 규칙: skill이 무엇을 할 수 있는지는 여전히 저장소 로컬 규칙이 정한다. 벤더 문서는 런타임이 무엇을 노출하는지만 설명한다. 한 세션에서 확인한 capability는 그 실행의 증거이지 영구 기능 주장이 아니다.
- 날짜의 실제 사정: Claude Code, Codex, OpenCode, Hermes Agent 문서 페이지에는 눈에 보이는 최종 수정일이나 발행일이 없다. 그런 행의 날짜는 **읽은** 날짜이며, 버전 기준은 날짜가 있는 릴리스나 변경 기록에서 가져온다(Codex CLI 0.166.0 2026-10-29, Claude Code 변경 기록 2.1.316 2026-10-31, OpenCode 페이지 표기 "Last updated: Nov 2, 2026", Hermes Agent `v0.22.5` 2026-10-22).
- 34~48번과 49~73번 행은 해당 레인(`CliRuntimes`, `HermesA`, `HermesB`)이 2026-11-03에 제공했고, 내용은 그대로 병합했다. 각 레인은 같은 날 그 페이지를 다시 읽었다.
- 기본 제외: 홈 디렉터리 설정, 전역 skill, 설치된 CLI의 실시간 help.
- 결론: 이 원장은 완전한 제품 기능 목록이 아니라, 명시한 출처가 직접 뒷받침하는 최소 capability와 경계를 기록한다. 지원되지 않는 주장은 런타임 발견 절차와 [`capability-contract.ko.md`](capability-contract.ko.md)의 fallback으로 처리한다.
- 스키마: 저장소 유지보수용 원장이므로 [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md) §7이 허용하는 간략 스키마를 쓴다. 출처, 유형, 확인한 내용, 사용 위치를 적는다. 대부분 페이지에 발행일이 없어 행마다 검색 시각을 붙이면 정밀도를 거짓으로 표현하게 되므로, 절 단위 확인일로 대신한다.

## 출처 원장

| # | 출처 | URL/경로 | 유형 | 확인한 내용 | 사용 위치 |
|---:|---|---|---|---|---|
| 1 | 프로젝트 범위 규칙 | [`../../AGENTS.md`](../../AGENTS.md) | 로컬 규칙 | 이 저장소의 범위·근거 규칙 | 모든 문서의 근거 범위 |
| 2 | Instructions Base | [`../README.ko.md`](../README.ko.md) | 로컬 안내 | 런타임 중립 코어와 런타임 프로필의 분리, capability 단위 도구 서술 | `README.md`, `capability-contract.md` |
| 3 | Runtime Profiles 참조 | [`../context-engineering/references/runtime-profiles.md`](../context-engineering/references/runtime-profiles.md) | 로컬 참조 | 공통 규칙은 capability 중심, 런타임 차이는 프로필로 분리 | 계층과 용어 |
| 4 | Skill Authoring | [`../skill/SKILL_AUTHORING.md`](../skill/SKILL_AUTHORING.md) | 로컬 안내 | skill이 의도·범위·권위·도구·검증을 분리한다 | skill 작성 패턴 |
| 5 | Claude Code CLI reference | <https://code.claude.com/docs/en/cli-reference> | 1차 문서 | 문서화된 80개 플래그 전부. `-p/--print`, `-c/--continue`, `-r/--resume`, `--output-format`, `--permission-mode`, `--allowedTools`, `--tools`, `--agents`, `--bg`, `--exec`, `--worktree`, `--restricted`, 제거된 `--enable-auto-mode`, 폐기된 `--remote` | `claude-code/README.ko.md` |
| 6 | Claude Code 권한 모드 | <https://code.claude.com/docs/en/permission-modes> | 1차 문서 | 여섯 모드(`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`), Manual 표시와 `manual` 별칭, 시작 모드 결정 순서, 어떤 모드도 자동 승인하지 않는 목록, `AskUserQuestion` 도구 언급 | `claude-code/README.ko.md` |
| 7 | Claude Code 명령 | <https://code.claude.com/docs/en/commands> | 1차 문서 | 121개 항목. `/goal`, `/loop`, `/schedule`, `/subtask`, `/fork`, `/batch`, `/tasks`, `/list-agents`, `/hooks`, `/skills`, `/plugin`, `/workflows`, 제거된 `/pr-comments`·`/ultraplan`·`/vim` | `claude-code/README.ko.md` |
| 8 | Claude Code subagent | <https://code.claude.com/docs/en/sub-agents> | 1차 문서 | 정의 위치와 우선순위, 필수 `name`/`description`, 전체 frontmatter, 기본 백그라운드 실행, 동시 20개, 중첩 3계층, `isolation: worktree` | `claude-code/README.ko.md` |
| 9 | Claude Code hook 참조 | <https://code.claude.com/docs/en/hooks> | 1차 문서 | 33개 이벤트, 다섯 핸들러 유형(`command`, `http`, `mcp_tool`, `prompt`, `agent`), 설정 위치, mod hook 표면 | `claude-code/README.ko.md` |
| 10 | Claude Code skill | <https://code.claude.com/docs/en/skills> | 1차 문서 | `SKILL.md` 구조, 일곱 로드 위치, 선택 frontmatter, 사용자 명령이 skill로 통합된 사실 | `claude-code/README.ko.md` |
| 11 | Claude Code plugin 개요 | <https://code.claude.com/docs/en/plugins/overview> | 1차 문서 | skill·agent·hook·mod·MCP·LSP를 묶는 단위, marketplace는 카탈로그 저장소, 설치 범위 | `claude-code/README.ko.md` |
| 12 | Claude Code 동적 workflow | <https://code.claude.com/docs/en/workflows> | 1차 문서 | 백그라운드 스크립트 오케스트레이션, 기본 동시 agent 16개(최대 256), 실행당 1,000개, 실행 중 입력 없음, 저장·재개 | `claude-code/README.ko.md` |
| 13 | Claude Code 세션 스케줄 | <https://code.claude.com/docs/en/scheduled-tasks> | 1차 문서 | `/loop` 간격 문법, 5필드 cron, 세션당 50개, 7일 만료, `loop.md` 우선순위 | `claude-code/README.ko.md` |
| 14 | Claude Code 클라우드 예약 작업 | <https://code.claude.com/docs/en/routines> | 1차 문서 | `/schedule`과 `/routines` 별칭, research preview, 최소 1시간, 클라우드 실행 | `claude-code/README.ko.md` |
| 15 | Codex 명령줄 참조 | <https://learn.chatgpt.com/docs/developer-commands?surface=cli> | 1차 문서 | 전역 플래그, 전체 서브커맨드, `codex exec`와 resume/fork, `codex review` 단일 대상 규칙, `codex plugin`·`codex mcp` | `codex/README.ko.md` |
| 16 | Codex 승인과 보안 | <https://learn.chatgpt.com/docs/agent-approvals-security> | 1차 문서 | 샌드박스·승인 계층, `approval_policy = "untrusted"` 폐기, `Auto` 프리셋, 기본 네트워크 차단, 파괴적 앱·MCP 호출의 상시 승인 | `codex/README.ko.md` |
| 17 | Codex 샌드박스 | <https://learn.chatgpt.com/docs/sandboxing> | 1차 문서 | 샌드박스가 실행 명령 전체에 적용, 플랫폼별 강제, 준비물 | `codex/README.ko.md` |
| 18 | Codex subagent | <https://learn.chatgpt.com/docs/agent-configuration/subagents> | 1차 문서 | 병렬 위임, `/subagents`, 샌드박스·승인 상속, `~/.codex/agents/`와 `.codex/agents/`의 TOML agent, `[agents]` 키, 비대화형 승인 실패 | `codex/README.ko.md` |
| 19 | Codex skill | <https://learn.chatgpt.com/docs/build-skills> | 1차 문서 | `.agents/skills` 탐색 위치, 필수 `name`/`description`, `agents/openai.yaml` 정책, `[[skills.config]]`, 컨텍스트 예산 | `codex/README.ko.md` |
| 20 | Codex hook | <https://learn.chatgpt.com/docs/hooks> | 1차 문서 | 이벤트 목록, `hooks.json` 위치, 해시 고정 신뢰 검토, `/hooks`, `--dangerously-bypass-hook-trust` | `codex/README.ko.md` |
| 21 | Codex 예약 작업 | <https://learn.chatgpt.com/docs/automations> | 1차 문서 | 예약 작업은 ChatGPT 웹·데스크톱 앱에서 실행되고 CLI에는 Scheduled 관리 인터페이스가 없음 | `codex/README.ko.md` |
| 22 | Codex 장기 작업 | <https://learn.chatgpt.com/docs/long-running-work> | 1차 문서 | CLI의 `/goal` Goal 모드, 목표 문장이 첫 프롬프트이자 완료 기준, 접근 범위 확대 없음 | `codex/README.ko.md` |
| 23 | Codex CLI 개요 | <https://learn.chatgpt.com/docs/codex/cli> | 1차 문서 | 진입점, `/permissions`, `codex resume`, `codex --search`, `codex mcp`, 리뷰 안내 | `codex/README.ko.md` |
| 24 | ChatGPT·Codex 변경 기록 | <https://learn.chatgpt.com/docs/changelog> | 1차 변경 기록 | 최신 Codex CLI 항목 0.166.0(2026-10-29), GPT-5.5 2026-10-14 종료 | `codex/README.ko.md` 버전 기준 |
| 25 | OpenCode 권한 | <https://opencode.ai/docs/permissions/> | 1차 문서 | `allow`/`ask`/`deny`, 마지막 일치 우선 객체 문법, `question`·`doom_loop` 포함 키 목록, 관대한 기본값, `once`/`always`/`reject`, `--auto` | `opencode/README.ko.md` |
| 26 | OpenCode agent | <https://opencode.ai/docs/agents/> | 1차 문서 | primary·subagent 구분, `~/.config/opencode/agents/`와 `.opencode/agents/`의 agent 마크다운, frontmatter, `@` 호출, 내장 agent | `opencode/README.ko.md` |
| 27 | OpenCode 도구 | <https://opencode.ai/docs/tools/> | 1차 문서 | 내장 도구 목록과 `question` 도구 계약(헤더·본문·선택지·직접 입력) | `opencode/README.ko.md` |
| 28 | OpenCode plugin | <https://opencode.ai/docs/plugins/> | 1차 문서 | 로컬·npm 로드, `tool.execute.before/after`, `shell.env`, compaction hook, `permission.asked`·`permission.replied`가 이벤트일 뿐인 점 | `opencode/README.ko.md` |
| 29 | OpenCode skill | <https://opencode.ai/docs/skills/> | 1차 문서 | `.claude/skills`·`.agents/skills` 포함 탐색 경로, 필수 필드, `skill` 권한 동작 | `opencode/README.ko.md` |
| 30 | OpenCode CLI | <https://opencode.ai/docs/cli/> | 1차 문서 | `opencode run` 플래그(`--format json`, `-c`, `-s`, `--fork`, `--agent`, `--attach`, `--auto`), `serve`, `OPENCODE_ENABLE_QUESTION_TOOL` | `opencode/README.ko.md` |
| 31 | OpenCode 설정 | <https://opencode.ai/docs/config/> | 1차 문서 | 복수형 설정 하위 디렉터리와 단수형 호환, `subagent_depth` 기본 1, 폐기된 `tools`·`maxSteps` | `opencode/README.ko.md` |
| 32 | OpenCode 2 권한 | <https://opencode.ai/v2/docs/permissions/> | 1차 문서 | action/resource/effect 배열, `shell`·`subagent` 이름, 기본 allow 정책, 불일치 시 `ask`, 저장 승인은 `deny`를 덮지 않음 | `opencode/README.ko.md` |
| 33 | OpenCode 2 plugin | <https://opencode.ai/v2/docs/plugins/> | 1차 문서 | `plugins` 배열, `opencode plugin` CLI, 제거를 무시하는 내장 정책 plugin | `opencode/README.ko.md` |
| 34 | OpenClaw 문서 | <https://docs.openclaw.ai/> | 1차 문서 | 자체 호스팅 gateway, `ask_user` 포함 내장 도구 범주, `tools.exec.mode`, exec 승인 합의, 샌드박스·정책·elevated 계층 | `openclaw/README.ko.md` |
| 35 | OpenClaw `v2026.10.9` 릴리스 | <https://github.com/openclaw/openclaw/releases> | 1차 릴리스 | 최신 안정 태그 2026-10-29 공개, 문서에 페이지별 날짜 없음 | `openclaw/README.ko.md` |
| 36 | Gajae-Code 저장소 | <https://github.com/Yeachan-Heo/gajae-code> | 1차 소스·문서 | `gjc` 정체성, 변경 전 계획 승인 문구, 권한 우회 플래그 없음 | `gjc/README.ko.md` |
| 37 | Gajae-Code 릴리스 | <https://github.com/Yeachan-Heo/gajae-code/releases> | 1차 릴리스 | 안정 `v0.19.2`(2026-10-29), nightly 채널이 안정판보다 앞섬 | `gjc/README.ko.md` |
| 38 | GJC 도구·신뢰 참조 | [`docs/tools`](https://github.com/Yeachan-Heo/gajae-code/tree/main/docs/tools), [`customization.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/customization.md), [`hooks.md`](https://github.com/Yeachan-Heo/gajae-code/blob/main/docs/hooks.md) | 1차 문서 | `ask` 조건부 등록과 timeout 자동 선택, bash 인터셉터 한계, 프로젝트 MCP 자동 로드, fail-closed hook | `gjc/README.ko.md` |
| 39 | OmO 문서 묶음 | [configuration](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md), [features](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/features.md), [computer use](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/guide/computer-use.md) | 1차 문서 | agent별 `permission`, guard hook 집행, 지시 파일은 경계가 아니라는 문장, 전경 computer 승인 | `omo/README.ko.md` |
| 40 | OmO `v5.1.58` 릴리스 | <https://github.com/code-yeongyu/oh-my-openagent/releases> | 1차 릴리스 | 최신 버전 2026-11-02, `senpi` 엔진 고정, npm `omo-ai` 정체성 | `omo/README.ko.md` |
| 41 | JCode 문서·SDK | <https://jcode.sh/docs>, <https://jcode.sh/sdk> | 1차 실시간 문서 | 설치·provider·설정·MCP·skill·remote·gateway 표면, `permission_request`와 `respondToPermission`, 격리는 샌드박스가 아님, telemetry payload | `jcode/README.ko.md` |
| 42 | JCode 릴리스 | <https://github.com/1jehuang/jcode/releases> | 1차 릴리스 | 안정 `v0.99.1`(2026-10-22), `v1.0.0-preview.*` 채널, `v0.97.0` telemetry 옵션, `v0.98.1` `user_response` | `jcode/README.ko.md` |
| 43 | JCode v0.81.1 소스 | [`1jehuang/jcode@cae6d2a`](https://github.com/1jehuang/jcode/tree/cae6d2a573ebfdbfaca085a82abb1f0b72faac69) | 버전 고정 소스 | 설정 우선순위, 도구 정책, 명령 위험도, 경로, MCP, 세션, 메모리, swarm, SDK, gateway, hook, 자동화 | `jcode/README.ko.md` |
| 44 | JCode v0.81.1 릴리스 | <https://github.com/1jehuang/jcode/releases/tag/v0.81.1> | 1차 릴리스 | 릴리스 날짜, 자산, 체크섬, 소스 경계 | `jcode/README.ko.md` |
| 45 | JCode 온보딩 | <https://jcode.sh/onboarding> | 1차 페이지 | 테스트로 뒷받침된 온보딩 상태, 기존 로그인 가져오기 주장 | `jcode/README.ko.md` |
| 46 | JCode telemetry 계약 | [`TELEMETRY.md@v0.81.1`](https://github.com/1jehuang/jcode/blob/cae6d2a573ebfdbfaca085a82abb1f0b72faac69/TELEMETRY.md) | 버전 고정 정책 | 집계 telemetry, opt-out, 대화록 opt-in, 보존, redaction 한계 | `jcode/README.ko.md` |
| 47 | JCode 이슈 반대 검색 | <https://github.com/1jehuang/jcode/issues> | 사용자 보고와 연결 소스 | 승인·MCP·세션·swarm·provider·설치·remote의 버전 편차와 한계 | `jcode/README.ko.md` 주의 |
| 48 | Anthropic 인증 정책 | <https://code.claude.com/docs/en/legal-and-compliance#authentication-and-credential-use> | 제공자 1차 정책 | 제3자 제품에 대한 구독 OAuth 경계 | `jcode/README.ko.md` 경고 |
| 49 | Hermes Agent 문서 | <https://hermes-agent.nousresearch.com/docs> | 1차 문서 | 문서 홈, 내비게이션, 끝 슬래시 없는 정규 URL | `hermes-agent/README.ko.md` |
| 50 | Hermes Agent 전체 문서 export | <https://hermes-agent.nousresearch.com/docs/llms-full.txt> | 1차 문서 export | Hermes 페이지 전체를 한 번에 다시 읽는 데 쓴 247페이지 본문 | `hermes-agent/**` |
| 51 | Hermes CLI 명령 참조 | <https://hermes-agent.nousresearch.com/docs/reference/cli-commands> | 1차 문서 | `hermes chat -q`·`--oneshot`, `--safe-mode` 요구 사항, 점 포함 설정 키 | `hermes-agent/README.ko.md` |
| 52 | Hermes 설정 | <https://hermes-agent.nousresearch.com/docs/user-guide/configuration> | 1차 문서 | 승인 관련 키, 터미널 백엔드, `database:`, 기본 하드 스톱 가드레일 | `hermes-agent/CONFIGURATION.ko.md` |
| 53 | Hermes 보안 | <https://hermes-agent.nousresearch.com/docs/user-guide/security> | 1차 문서 | 승인 모델, 제거된 `tirith` 키, `SOUL.md` 스캐너 예외 | `hermes-agent/CONFIGURATION.ko.md` |
| 54 | Hermes 영구 메모리 | <https://hermes-agent.nousresearch.com/docs/user-guide/features/memory> | 1차 문서 | `replace` 없이 `add`/`patch`/`remove`, 최상위 `target`, 승인 표면 | `hermes-agent/MEMORY.ko.md` |
| 55 | Hermes 컨텍스트 파일 | <https://hermes-agent.nousresearch.com/docs/user-guide/features/context-files> | 1차 문서 | 잘라내기 비율, 32,000자 힌트 상한, 5초 읽기 제한 | `hermes-agent/CONTEXT_FILES.ko.md` |
| 56 | Hermes skill 시스템 | <https://hermes-agent.nousresearch.com/docs/user-guide/features/skills> | 1차 문서 | 4단계 우선순위, `auto_load`·`create_dir`, curator 연동 | `hermes-agent/SKILLS.ko.md` |
| 57 | Hermes skill 작성 | <https://hermes-agent.nousresearch.com/docs/developer-guide/creating-skills> | 1차 문서 | 인라인 셸 신뢰 범위와 timeout, `[[as_document]]`, 자격 증명 파일 마운트 | `hermes-agent/SKILL_AUTHORING.ko.md` |
| 58 | Hermes Kanban | <https://hermes-agent.nousresearch.com/docs/user-guide/features/kanban> | 1차 문서 | `scheduled` 상태 대신 `scheduled_at`, PR 완료 계약, respawn 가드, 동시성 키 | `hermes-agent/KANBAN.ko.md` |
| 59 | Hermes Curator | <https://hermes-agent.nousresearch.com/docs/user-guide/features/curator> | 1차 문서 | curator 상태, 기본값, 백업, 원장, pin/lock | `hermes-agent/references/curator-lifecycle.ko.md` |
| 60 | Hermes 이벤트 hook | <https://hermes-agent.nousresearch.com/docs/user-guide/features/hooks> | 1차 문서 | 권위가 다른 네 hook 시스템, gateway 이벤트 payload, `hook_callback_timeout` 30초, `pre_tool_call` fail-closed | `hermes-agent/HOOK.ko.md` |
| 61 | Hermes plugin 작성 | <https://hermes-agent.nousresearch.com/docs/developer-guide/plugins> | 1차 문서 | manifest v2, PM 의존성 수명주기, `ctx.ask_choice`, middleware 종류 | `hermes-agent/PLUGIN_AUTHORING.ko.md` |
| 62 | Hermes plugin | <https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins> | 1차 문서 | 카탈로그, pack, 격리, timeout, gateway가 프로젝트 로컬 plugin을 로드하지 않는 점 | `hermes-agent/PLUGINS.ko.md` |
| 63 | Hermes plugin 카탈로그 | <https://hermes-agent.nousresearch.com/docs/user-guide/features/plugin-catalog> | 1차 문서 | 검토 커밋 고정 카탈로그(실시간 910개), 보안 감사가 아니라는 명시 | `hermes-agent/PLUGINS.ko.md` |
| 64 | Hermes 메시징 gateway | <https://hermes-agent.nousresearch.com/docs/user-guide/messaging> | 1차 문서 | 폐기된 `session_reset` 모드, `platforms.<name>.enabled`의 권위, 어댑터 상태 | `hermes-agent/MESSAGING.ko.md` |
| 65 | Hermes Discord 설정 | <https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord> | 1차 문서 | 인텐트 실패 방식, 권한 정수, 루프 가드, backfill 객체 구조 | `hermes-agent/DISCORD.ko.md` |
| 66 | Hermes 멀티플렉싱 gateway | <https://hermes-agent.nousresearch.com/docs/developer-guide/multiplexing-gateway> | 1차 문서 | gateway 하나가 모든 프로필을 처리, `/p/<profile>/` 경로, `gateway.standalone` opt-out | `hermes-agent/MESSAGING.ko.md` |
| 67 | Hermes 슬래시 명령 | <https://hermes-agent.nousresearch.com/docs/reference/slash-commands> | 1차 문서 | CLI 전용과 채팅 사용 가능 명령의 구분 | `hermes-agent/DISCORD.ko.md` |
| 68 | Hermes MCP·Tool Gateway | <https://hermes-agent.nousresearch.com/docs/user-guide/features/mcp>, <https://hermes-agent.nousresearch.com/docs/user-guide/features/tool-gateway> | 1차 문서 | MCP 서버 설정과 도구 게이트 | `hermes-agent/EXTENSIONS.ko.md` |
| 69 | Hermes Agent `v0.22.5` 릴리스 | <https://github.com/NousResearch/hermes-agent/releases/tag/v0.22.5> | 1차 릴리스 | 버전 고정: 커밋 `bf0203a794a`, 2026-10-22(태그 시각 2026-10-23) | `hermes-agent/**` 버전 기준 |
| 70 | Hermes Agent 저장소 | <https://github.com/NousResearch/hermes-agent> | 1차 소스 | 최종 커밋 2026-11-02, `website/docs/`의 태그 고정 문서 원본 | 태그·사이트 대조 |
| 71 | Agent Skills 명세 | <https://agentskills.io/specification> | 벤더 중립 표준 | Claude Code·Codex·OpenCode가 따르는 `SKILL.md` frontmatter 표준 | skill 구조 행 |
| 72 | Agent Plugins 명세 1.0.0 | <https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md> | 표준(릴리스 태그) | Hermes가 고정한 plugin manifest 계약 | `hermes-agent/PLUGINS.ko.md` |
| 73 | Agent Plugins 명세 1.1.0 | <https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.1.0.md> | 표준(Working Draft) | 고정보다 새로운 상류 초안, 채택하지 않음 | `hermes-agent/PLUGINS.ko.md` 주의 |

> `AGENTS.md`와 `AGENTS.ko.md`는 버전 관리 대상이다. `CLAUDE.md`는 `.gitignore:45`에 걸려 **버전 관리되지 않는다**(확인 2026-11-03: `git ls-files`에 `AGENTS.md`가 있고, `git check-ignore`는 `CLAUDE.md`만 보고한다). 따라서 근거 #1은 어느 클론에도 존재한다.

## 주장-출처 매트릭스

| 주장 | 출처 | 신뢰도 | 주의 |
|---|---|---|---|
| 공통 skill 규칙은 capability 중심이고 런타임 차이는 프로필로 분리된다 | 2, 3 | 높음 | 이 저장소의 문서 설계 규칙이지 제품 표준 주장이 아니다. |
| Claude Code는 폐기된 모드 없이 여섯 권한 모드를 노출하고, Manual은 `default` 값의 UI 이름이며 `manual`이 별칭이다 | 5, 6 | 높음 | 페이지 폐기 검색 결과가 없었고, 문서화된 이름 변경은 Manual/`default`뿐이다. |
| 모드를 지정하지 않은 `claude -p` 실행은 v2.1.302부터 Manual로 시작하고, 승인이 필요한 호출은 허용 규칙·hook·`canUseTool`·`--permission-prompt-tool` 없이는 거부된다 | 5, 6 | 높음 | 버전에 종속된다. 이전 CLI는 다르게 동작한다. |
| Claude Code에는 어떤 모드도 자동 승인하지 않는 내장 구조화 질문 도구(`AskUserQuestion`)가 있다 | 6 | 높음 | 권한 문서가 도구 이름을 밝힌다. 노출과 스키마는 세션에서 확인해야 한다. |
| Claude Code 위임은 기본 동시 subagent 20개와 중첩 3계층으로 제한되고, subagent는 백그라운드로 시작하며 workflow는 동시 agent 16개로 실행된다 | 8, 12 | 높음 | 상한은 환경 변수와 CPU 수로 조정된다. |
| Claude Code의 `/loop`은 세션 범위이고 `/schedule`은 research preview 클라우드 작업을 만든다 | 7, 13, 14 | 높음 | 첫 프롬프트가 `/loop`인 세션은 `-p` 없이 `--continue`에서 제외된다. |
| Codex는 `approval_policy = "untrusted"`를 폐기했고 `-a`/`--ask-for-approval`은 `on-request`와 `never`만 받는다 | 15, 16 | 높음 | 폐기된 값은 클라이언트 시작을 막을 수 있다. 더 엄격한 명령 승인은 프로젝트 `trust_level`이 담당한다. |
| Codex subagent는 부모의 샌드박스·승인 설정을 상속하고 커스텀 agent 파일이 이를 넓힐 수 없다 | 18 | 높음 | subagent의 승인 요청은 대화형 세션에서만 표면화된다. |
| Codex 비대화형 실행에서 새 승인이 필요한 행동은 프롬프트가 아니라 실패로 끝난다 | 18 | 높음 | 스크립트 워크플로는 필요한 승인을 미리 갖춰야 한다. |
| Codex 로컬 skill은 `.codex/skills`가 아니라 `.agents/skills`에서 읽고 `name`과 `description`이 필수다 | 19 | 높음 | 심볼릭 링크 폴더를 따라가며, 같은 이름의 skill은 병합하지 않는다. |
| Codex 예약 작업은 ChatGPT 웹이나 데스크톱 앱에서 관리하고 CLI에는 Scheduled 인터페이스가 없다 | 21 | 높음 | 검토한 CLI 페이지 안에서의 부재 확인이며, 새 릴리스에서 다시 봐야 한다. |
| Codex `/goal`은 CLI에서 Goal 모드를 시작하고 접근 범위를 넓히지 않는다 | 22 | 높음 | Goal 모드는 같은 샌드박스와 승인 정책을 유지한다. |
| OpenCode에는 헤더·본문·선택지·직접 입력을 갖춘 `question` 도구가 있고 `question` 권한으로 제어된다 | 25, 27 | 높음 | CLI·앱·데스크톱 외 클라이언트에서는 `OPENCODE_ENABLE_QUESTION_TOOL`이 필요할 수 있다. |
| OpenCode 1의 권한 기본값은 관대하고, OpenCode 2는 일치 규칙이 없으면 `ask`로 처리한다 | 25, 32 | 높음 | 두 문서 트리는 설정 형식이 다르므로 설치된 주 버전에 맞는 쪽을 읽어야 한다. |
| OpenCode plugin은 `permission.asked`·`permission.replied`를 관찰할 수 있지만 승인에 답하는 hook은 문서에 없다 | 28 | 보통 | 검토한 plugin 페이지 안에서의 부재 확인이다. `tool.execute.before`에서 예외를 던지면 호출이 막히지만 그것은 동의가 아니다. |
| OpenCode 위임 깊이 기본값은 1이고 백그라운드 subagent는 실험이며 opt-in이다 | 26, 30, 31 | 높음 | `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS`를 켜야 한다. |
| OpenClaw는 답변이 권한을 부여하지 않는 구조화 `ask_user` 도구를 노출한다 | 34 | 높음 | 질문 가능 표면에서만 그렇고, 여러 채널은 평문으로 대체한다. |
| OpenClaw 호스트 exec은 정책·allowlist·승인 합의가 모두 필요하고 사용자별 인증 경계가 아니다 | 34 | 높음 | 실제 배포의 승인 문서가 유효 모드를 결정한다. |
| GJC에는 문서화된 일반 명령별 승인 게이트가 없고 권한 우회 플래그도 없다 | 36, 38 | 보통 | 검토한 1차 문서 안에서의 부재 확인이다. 승인 의미는 계획·워크플로 게이트와 `ask`에 있다. |
| GJC `ask`는 조건부로 등록되고 `ask.timeout`이 권장 선택지를 자동 선택한다 | 38 | 높음 | 답변 표면이 없는 헤드리스 세션은 도구를 받지 못한다. 자동 선택된 답은 동의가 아니다. |
| OmO는 설정(`agents.*.permission`)으로 권한을 집행하고 `AGENTS.md`를 지시로만 취급한다 | 39 | 높음 | guard hook이 집행의 일부이며, 끄는 것은 디버깅 전용으로 문서화되어 있다. |
| JCode의 현재 SDK는 allow/allow_always/deny와 함께 `permission_request`를 내보낸다 | 41 | 높음 | v0.81.1에서 브리지가 권한 요청을 내보내지 않는다는 이전 발견을 대체한다. |
| JCode 대화형 CLI의 승인 동작은 현재 사이트에 문서화되어 있지 않다 | 41 | 보통 | 부재 확인이며, 프로필은 설치된 버전의 관찰을 요구한다. |
| Hermes Agent 내용은 `v0.22.5`에 고정되어 있고 실시간 문서 사이트가 그 태그보다 약간 앞선다 | 69, 70 | 높음 | 사이트에만 있는 동작은 주장하지 않았고, 핵심 주장은 태그의 `website/docs/`와 대조했다. |
| Hermes 셸 hook은 Desktop/TUI/dashboard에서도 실행되고 gateway hook은 배치로 신뢰된다 | 60 | 높음 | `HERMES_SAFE_MODE`는 gateway hook을 건너뛰지 않는다. |
| Hermes plugin은 Agent Plugins 1.0.0을 고정하고 상류에는 1.1.0 Working Draft가 있다 | 61, 62, 72, 73 | 높음 | 초안은 채택된 계약이 아니다. |
| 날짜가 없는 벤더 페이지에서 기록한 날짜는 읽은 날짜다 | 모든 벤더 행 | 높음 | 버전 기준은 날짜가 있는 릴리스·변경 기록에서 가져온다. |

## 갱신 조건

다음 중 하나가 일어나면 이 원장을 갱신한다.

- 런타임이 권한, 승인, 위임, 스케줄 동작을 바꾸는 릴리스나 문서 변경을 공개할 때.
- 프로필이 이 원장이 다루지 않는 capability에 의존하기 시작할 때.
- 벤더 문서 URL이 이동하거나 이전(3xx)을 시작할 때.
- `instructions/cli/`에 새 런타임 프로필이 추가될 때.
- 인용한 페이지에 발행일이 생길 때. 그때는 읽은 날짜 대신 페이지 자신의 날짜를 기록한다.

갱신할 때는 근거를 먼저 추가하고, 그다음 프로필과 공통 계약을 고친 뒤, 마지막으로 링크, 주장-출처 매트릭스, 스모크 평가를 다시 확인한다.
