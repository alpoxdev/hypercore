# Hermes Agent 설정 파일

> 영어판: [`CONFIGURATION.md`](CONFIGURATION.md)
>
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a`, 2026-10-22 배포)에 실린 공식 문서를 근거로 삼았다. 아래 **사실**은 그 근거를 추적하고, **권고**는 이 문서의 운영 조언이다. 기본값은 해당 날짜에 확인한 문서상의 값이며 설치된 버전을 보장하지 않으므로, 업그레이드 후에는 Configuration·Security reference를 다시 확인한다.

## 출처

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration) | `~/.hermes/` tree, 우선순위, 아래에 인용한 모든 섹션 | 확인 2026-11-03 |
| [Environment Variables Reference](https://hermes-agent.nousresearch.com/docs/reference/environment-variables) | Key별 환경 변수 override | 확인 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | `hermes config` 하위 명령과 점 escape key | 확인 2026-11-03 |
| [Managed Scope](https://hermes-agent.nousresearch.com/docs/user-guide/managed-scope) | 관리자가 고정한 값과 그 우선순위 | 확인 2026-11-03 |
| [Security](https://hermes-agent.nousresearch.com/docs/user-guide/security) | Approval 모드, YOLO, allowlist, redaction | 확인 2026-11-03 |
| [전체 문서 export](https://hermes-agent.nousresearch.com/docs/llms-full.txt) | 모든 page를 한 번에 대조할 때 | 확인 2026-11-03 |
- 공식 문서 전문 export: `https://hermes-agent.nousresearch.com/docs/llms-full.txt`

## 어떤 파일이 무엇을 담는가

**사실 — 공식 Configuration 페이지는 `~/.hermes/` 아래 정확히 아홉 개 항목을 문서화한다.**

| 경로 | 담는 내용 |
| --- | --- |
| `config.yaml` | 비밀이 아닌 설정: model, terminal, TTS, compression 등 |
| `.env` | API key, bot token, password 등 secret |
| `auth.json` | OAuth provider credential (Nous Portal 등) |
| `SOUL.md` | Agent의 주 정체성. System prompt slot #1 |
| `memories/` | `MEMORY.md`(학습한 사실)와 `USER.md`(사용자 프로필) |
| `skills/` | Agent가 만든 skill. `skill_manage`로 관리 |
| `cron/` | 예약 작업 |
| `sessions/` | Gateway session 산출물. 정본 데이터는 `state.db`에 있고 `sessions/sessions.json`은 legacy gateway-routing mirror다 |
| `logs/` | `errors.log`, `gateway.log`. Secret은 자동 마스킹된다 |

**사실:** 다른 공식 페이지는 `state.db`, `plugins/`, `cache/`, `mcp-tokens/`, `backups/`, `state-snapshots/`, `checkpoints/`, `profiles/<name>/`, `active_profile` 같은 런타임 경로를 추가로 언급하지만, 이들은 Configuration 페이지 정본 트리의 항목이 아니다.

**사실 — 공식 구분:** `config.yaml`은 동작, `.env`는 자격증명, `auth.json`은 OAuth를 담는다. `SOUL.md`는 사용자가 직접 쓰는 정체성이고, `memories/USER.md`와 `memories/MEMORY.md`는 memory tool을 통해 agent가 쓴다.

**권고:** 값을 쓰기 전에 파일 소유권부터 정한다. 스크린샷에 찍히면 곤란한 값은 `.env`나 secret source로 가야 하며 `config.yaml`에 두지 않는다.

## 설정 우선순위

**사실:** Configuration 페이지는 CLI 인자 → `config.yaml` → `.env` → 내장 기본값이라는 단순화된 체인을 제시한다. 이 요약은 실제 계층 두 개를 생략한다. 높은 것부터 정리하면 다음과 같다.

1. **Managed 값 — pinned leaf 한정.** `/etc/hermes/config.yaml`과 `/etc/hermes/.env`(또는 재지정된 `$HERMES_MANAGED_DIR`)는 pin한 키에 한해 사용자 config, 사용자 `.env`, **셸 환경까지** 덮어쓴다. 병합은 leaf 단위라서 `model.default`를 pin해도 `model` 전체가 고정되지는 않는다.
2. **CLI 호출별 인자** — 예: `hermes chat --model ...`.
3. **문서화된 키별 환경변수 override** — 예: `TERMINAL_*`, `HERMES_LANGUAGE`, `HERMES_VERIFY_ON_STOP`. Managed Scope 문서는 자기 동작을 "환경변수가 config를 이긴다"는 통상 규칙의 역전이라고 명시한다.
4. **프로필 `config.yaml`** — 비밀이 아닌 설정.
5. **프로필 `.env`와 상속된 셸 값** — secret과 레거시 환경변수 기반 설정. **이 계층 내부 순서는 키마다 다르다.** Docker forwarded 변수는 셸이 먼저이고, managed scope 문서의 일반 계층은 사용자 `.env`를 기존 셸 값보다 위에 둔다. 어느 쪽도 일반화하지 않는다.
6. **내장 기본값.**

**사실:** `hermes config set`은 managed로 pin된 키의 변경을 거부하고 managed 출처를 알려준다. 형식이 잘못된 managed 파일은 큰 소리로 로깅된 뒤 무시되며 기동은 계속된다. 실제 적용된 정책은 `hermes doctor`로 확인한다.

**사실:** managed scope는 파일시스템 권한으로만 강제된다. Managed 디렉터리에 쓸 수 있거나 `HERMES_MANAGED_DIR`를 설정할 수 있는 사용자는 이 장치를 무력화한다. Managed `.env`는 문서상 누구나 읽을 수 있는 `0644`이므로 민감도가 높은 secret을 담아서는 안 된다.

## config.yaml의 변수 치환

**사실:**

- `${VAR_NAME}`과 Cursor 스타일 `${env:VAR_NAME}`은 동일하게 해석되며 `mcp_servers` 항목 안에서도 동작한다. 한 문자열에 여러 참조를 써도 된다.
- 정의되지 않은 변수는 **그대로 남고 경고를 로깅한다.** 빈 값이 되지 않는다.
- 맨 `$VAR`는 확장되지 **않는다**.
- `${file:...}`, `${vault:...}`, `${bitwarden:...}`는 인라인 resolver가 **아니다**. Secret backend가 기동 시 환경을 채우고, 그 결과를 `${env:NAME}`으로 참조한다.
- 알 수 없는 prefix는 한 번 경고한 뒤 그대로 남는다.
- MCP 항목은 `${userHome}`, `${workspaceFolder}`, `${workspaceFolderBasename}`, `${pathSeparator}`, `${/}`도 지원한다.

```yaml
mcp_servers:
  github:
    command: npx
    args: ["-y", "@modelcontextprotocol/server-github"]
    env:
      GITHUB_PERSONAL_ACCESS_TOKEN: "${env:GITHUB_TOKEN}"
```

**권고:** 치환한 값이 먹지 않을 때는 다른 것을 건드리기 전에 로그에서 "그대로 남았다"는 경고부터 찾는다. 그 경고가 오타와 진짜 설정 문제를 가른다.

## `hermes config` 명령군

**사실:**

| 명령 | 동작 |
| --- | --- |
| `hermes config` / `hermes config show` | 현재 해석된 값 표시. Managed scope가 적용되면 managed 헤더를 함께 출력 |
| `hermes config edit` | 편집기로 `config.yaml` 열기 |
| `hermes config get <key> [--json]` | 점 표기 키 읽기. `--json`으로 기계 판독형 출력 |
| `hermes config set <key> <value>` | 값 쓰기. 스칼라와 따옴표로 감싼 YAML/JSON flow 리스트·맵을 파싱 |
| `hermes config unset <key>` | 사용자 값을 제거하고 기본 해석으로 되돌림 |
| `hermes config path` | `config.yaml` 경로 출력 |
| `hermes config env-path` | `.env` 경로 출력 |
| `hermes config check` | 누락되거나 오래된 설정 항목 점검 |
| `hermes config migrate` | 새로 도입된 옵션과 활성 skill 설정을 대화형으로 추가 |

**사실:** `hermes config set`은 인식된 secret과 API key를 `.env`로, 나머지를 `config.yaml`로 자동 배치한다. 호출자가 파일을 고르지 않는다.

**사실 — key 이름 안의 점:** 기존 mapping을 따라갈 때는 점으로 쪼개기보다 이미 있는 literal key가 우선한다. 그래서 `hermes config set providers.p.models.grok-4.6.supports_vision true`는 실제 `grok-4.6` 항목을 고친다. **새** 점 포함 key를 만들 때는 backslash로 escape해야 한다(`'providers.p.models.grok-4\.7.context_length'`). 기존 점 포함 형제를 가리는 escape 없는 쓰기는 runtime이 읽지 않을 항목을 만드는 대신 오류로 끝난다.

**사실:** `hermes config get`은 credential 형태 값(`api_key`, `*_TOKEN`, `*_SECRET`, `password`)을 session transcript가 남기 때문에 가린다. `--raw`가 실제 값을 출력한다. `hermes config set`은 알려진 key를 잘못된 prefix에 쓰려 하면 의도한 key를 알려 주고 거부하며, `--force`가 있어야 쓴다.

**사실:** `config check`는 누락·노후 옵션을 보고할 뿐이며 문서는 복구 기능을 주장하지 않는다. `config migrate`는 새 옵션을 추가하고 활성 skill에서 선언됐지만 설정되지 않은 값을 찾는다. Update는 의존성 설치 후 이를 실행한다.

**사실 — `_config_version`은 문서화되어 있지 않다.** 이 literal은 공식 문서 export 전체에서 한 번도 등장하지 않는다. 문서는 내부 schema 이정표만 언급한다(v12는 `custom_providers`를 `providers`로, v17은 `compression.summary_*`를 `auxiliary.compression.*`로 이전, schema v21은 설치된 사용자 plugin을 grandfathering). 일반 `config migrate`의 백업 동작도 문서화되어 있지 않다.

**권고:** 파일에 `_config_version`이 보이면 내부 마커로 취급한다. 손으로 고치지 말고 `hermes config check`와 `hermes config migrate`를 쓴다.

## 섹션 레퍼런스

운영상 중요한 키만 싣는다. `SILENT`는 문서가 키는 언급하지만 기본값을 명시하지 않는다는 뜻이다.

### `model`

| 키 | 타입 | 문서상 기본값 |
| --- | --- | --- |
| `provider` | string | Setup 전에는 미설정 |
| `default` | string | Setup 전에는 미설정 |
| `base_url` | string | SILENT |
| `api_mode` | string | SILENT |
| `context_length` | integer | 자동 감지 |
| `aliases` | map | 비어 있음. 최상위 `model_aliases`가 우선 |

연관: 최상위 `providers`(`api`, `api_key`, `extra_headers`, `discover_models: true`, `models`, timeout 키). 레거시 `custom_providers`도 지원되며 자동 이전된다.

### `approvals`

| 키 | 문서상 기본값 | 비고 |
| --- | --- | --- |
| `mode` | `smart` | `smart`는 보조 LLM 사용, `manual`은 항상 확인, `off`는 검사 해제이며 YOLO와 동등 |
| `timeout` | `300`초 | 무응답 시 **거부**. Fail-closed |
| `cron_mode` | `deny` | `approve`는 cron 컨텍스트의 모든 위험 명령을 자동 승인 |
| `single_query_mode` | `deny` | 일회성 `hermes chat -q`에도 동일 |
| `unattended_mode` | `deny` | Webhook, `msgraph_webhook`, `api_server` session에도 동일. `/approve`에 답할 사람이 없는 표면이다 |
| `discord_prompt_timeout` | `300` | Discord의 approval, clarify, update 버튼이 눌리는 시간(초), 최소 30 |
| `smart_policy` | unset | Smart approval reviewer의 system prompt에 덧붙이는 추가 지시 |
| `deny` | 비어 있지 않은 기본값 없음 | 정규화된 명령 전체에 대한 대소문자 무시 fnmatch glob. **YOLO/off보다 먼저** 평가되고 mtime 기반으로 재적재되어 재시작이 필요 없다 |
| `denial_breaker_threshold` | `3` | `0`이면 비활성 |
| `destructive_slash_confirm` | 활성 | `/clear`, `/new`, `/reset`, `/undo`에 네이티브 확인 대화상자 |
| `mcp_reload_confirm` | `true` | `/reload-mcp`가 MCP tool schema를 바꾸기 전에 묻는다. "항상" 선택은 해당 approval을 영구화한다 |

**사실:** `command_allowlist`는 `approvals.` 하위가 아니라 **최상위 키**다. "항상 허용"을 선택하면 넓은 패턴이 여기에 기록되고 이후 조용히 승인된다. `hermes approvals suggest`는 읽기 전용이며 `--apply`만 실제로 기록한다.

**사실:** YOLO는 `--yolo`, session 안의 `/yolo` toggle, `HERMES_YOLO_MODE=1`로 켤 수 있다. 위험 명령 prompt는 우회하지만 hardline blocklist는 우회하지 않는다. Sandbox가 아니며 안전한 backend를 대체하지 않는다.

**사실 — 가장 중요한 범위 제한:** deny와 hardline 가드 스택은 **호스트에 닿는 백엔드**(local, SSH, host-mounted Docker)에서만 동작한다. 격리 백엔드(docker, singularity, modal, daytona, vercel_sandbox)는 컨테이너를 경계로 보기 때문에 위험 명령 검사를 **아예 건너뛴다**. `approvals.deny`를 보편적 실행 보장으로 서술해서는 안 된다.

**권고:** 보안 경계는 deny glob이 아니라 컨테이너 격리다. Deny 규칙은 호스트에 닿는 백엔드용 guardrail이다.

### `terminal`

| 키 | 문서상 기본값 | 비고 |
| --- | --- | --- |
| `backend` | `local` | `local`, `docker`, `ssh`, `modal`, `daytona`, `vercel_sandbox`, `singularity` |
| `cwd` | `.` | Gateway와 cron이 사용. CLI는 실행 디렉터리를 쓴다 |
| `timeout` | `180` | 초 |
| `home_mode` | `auto` | `auto`, `real`, `profile` |
| `env_passthrough` | `[]` | |
| `persistent_shell` | SSH true, local false | 백엔드 환경변수가 우선 |
| `docker_network` | `true` | `false`면 컨테이너를 망에서 분리 |
| `container_cpu` / `container_memory` / `container_disk` | `1` / `5120` MB / `51200` MB | |
| `container_persistent` / `docker_persist_across_processes` / `docker_orphan_reaper` | `true` | |
| `lifetime_seconds` | `300` | |
| `vercel_runtime` | `node24` | `node22`, `python3.13`도 가능 |
| `temp_dir` | `""` | 비우면 `TMPDIR`, 아니면 `~/.hermes/cache/terminal`; 24시간 idle 항목은 정리됨 |
| `sync_back_max_bytes` | `2147483648` | Remote backend가 이보다 큰 state archive를 거부 |
| `modal_image` / `daytona_image` | `nousresearch/hermes-sandbox:desktop` | Cloud backend별 sandbox image |

**사실:** `home_mode: auto`는 호스트 설치에서 실제 OS `HOME`을 유지하므로 평소의 `git`, `ssh`, `gh`, `az`, `npm`, Claude Code, Codex 자격증명이 하위 프로세스에 그대로 보인다. `home_mode: profile`은 `HOME`을 `{HERMES_HOME}/home`으로 돌리고 `HERMES_REAL_HOME`을 내보내지만, 그 대가로 `~/.ssh`, `~/.gitconfig`, 클라우드 CLI 인증이 거기서 초기화되기 전까지 보이지 않는다.

**사실:** `docker_extra_args`는 가장 마지막에 덧붙으며, 문서는 이것이 의도한 hardening을 조용히 약화시킬 수 있다고 경고한다. 호스트 마운트, cwd 마운트, 자격증명 마운트, 환경변수 전달은 각각 호스트 도달성을 되살릴 수 있다.

### `skills`, `memory`, `plugins`

| 키 | 문서상 기본값 |
| --- | --- |
| `skills.guard_agent_created` | `false` — 휴리스틱 스캐너 꺼짐 |
| `skills.write_approval` | `false` — skill 쓰기를 승인 대기로 두지 않음 |
| `skills.auto_load` | 비어 있음 — session 시작 시 강제 로드하는 skill 없음 |
| `skills.create_dir` | Unset — 새 에이전트 작성 skill은 profile 로컬 디렉터리로 |
| `skills.inline_shell` / `inline_shell_timeout` | `false` / 조각당 `10`초 |
| `skills.tier1_advisory` | 선택 scanner binary가 `PATH`에 있으면 활성 |
| `skills.ledger` / `ledger_max_bytes` | `true` / `5242880` |
| `skills.disabled` / `skills.platform_disabled` / `skills.external_dirs` | SILENT |
| `memory.memory_enabled` / `memory.user_profile_enabled` | `true` |
| `memory.memory_char_limit` / `memory.user_char_limit` | `2200` / `1375`자 |
| `memory.write_approval` | `false` |
| `memory.prefetch_spill_enabled` | `false` — 과대한 provider recall을 그대로 유지 |
| `memory.provider` | Unset — 내장 store만 사용 |
| `plugins.enabled` / `plugins.disabled` | 일반 plugin은 opt-in이며 `disabled`가 항상 우선 |

**사실:** plugin 신뢰 게이트 — `allow_tool_override`, `allow_gateway_injection`, `mcp_allowlist`, `llm.allow_provider_override`, `allow_model_override`, `allow_platform_actions` 등 — 는 모두 거부가 기본이다.

### Tools: 최상위 `tools:` 섹션은 없다

**사실:** tool 활성화는 `platform_toolsets`(플랫폼별 toolset 목록 맵, `hermes tools`가 기록)와 `agent.disabled_toolsets`(플랫폼 해석 이후 전역 제거)로 저장된다. `tools:` 매핑을 만들어내지 않는다.

연관 한도: `tool_output.max_bytes` `50000`, `max_lines` `2000`, `max_line_length` `2000`, `file_read_max_chars` `100000`, `tool_budget.mcp_result_size_chars` `50000`, `tool_loop_guardrails.warnings_enabled` `true`, `hard_stop_enabled` `false`, `non_interactive_hard_stop_enabled` `true`, 그리고 turn당 `loop_caps.max_web_searches`와 `max_subagents` `50`.

**사실, truncation 전략은 두 가지다:** 한도를 넘은 terminal 출력은 앞 40%와 뒤 60%만 남기고 `[OUTPUT TRUNCATED]` 표시를 넣어 자른다. 반면 과대한 *tool result*는 `$HERMES_HOME/cache/spillover/`로 흘려보내고 문맥에는 미리보기와 file 경로를 남긴다. 일반 spill 한도는 100,000자이고 `mcp_*` 결과는 기본 50,000자로 흘리며, 항상 일반 한도가 상한이다.

**사실, hard stop이 적용되는 곳:** 대화형 CLI, TUI, Desktop, ACP, `api_server` session은 사람이 개입할 수 있어 경고만 남긴다. Unattended gateway와 cron 표면은 `non_interactive_hard_stop_enabled`로 기본 hard stop을 쓴다. `hard_stop_enabled`는 hard stop을 모든 platform으로 넓힌다. Hard stop은 반복이 아니라 변화 없는 재생을 잡는다. 성공한 변경 호출은 streak을 초기화하고, 서로 다른 실패 명령은 진단이지 loop가 아니다.

### 그 밖에 자주 조정하는 섹션

`agent`(`api_max_retries: 3`, `stall_guards: true`, `clarify_timeout: 3600`) · `compression`(`enabled: true`, `threshold: 0.50`, `target_ratio: 0.20`, `tail_mode: lean`, `protect_last_n: 20`, `protect_first_n: 3`) · `code_execution`(`mode: project`, `timeout: 300`, `max_tool_calls: 50`) · `display`(`tool_progress: all`, `language: en`, `memory_notifications: on`) · `security`(`redact_secrets: true`, `website_blocklist.enabled: false`) · `updates`(`pre_update_backup: quick`, `backup_keep: 5`) · `delegation`(`max_concurrent_children: 3`, `max_spawn_depth: 1`, `oneshot_max_children: 2`) · `checkpoints`(`enabled: false`, `max_snapshots: 20`) · `curator`(`enabled: true`, `interval_hours: 168`, `stale_after_days: 14`, `archive_after_days: 30`, `consolidate: false`).

**사실, `tirith_*`는 사라졌다:** 이전 release는 `security.tirith_enabled` 아래 명령 scanner를 묶어 두었지만 제거되었고, 업그레이드하면 그 key가 빠지며 그 자리에 켜지는 것도 없다. Content 단위 명령 검사는 따로 문서화되어 있다.

**사실, `database:` 섹션은 있다:** `state.db`를 여는 방식을 정한다. `journal_mode`(기본 `wal`, network mount면 `delete`), 선택적 `synchronous` durability 하한, 선택적 `wal_autocheckpoint`와 `journal_size_limit` pragma다. 이미 WAL인 database를 실행 중에 내리지는 않으며, 모든 process를 멈춘 뒤 `hermes sessions set-journal-mode delete`로 변환한다.

**사실, `runtime:` 섹션도 있다:** `nofile_soft_limit`(기본 `4096`, OS hard limit으로 clamp되고 이미 더 높은 process는 낮추지 않음)과 `malloc_arena_max`(glibc에서 기본 `4`)가 오래 도는 server process를 조정한다. `0`, `false`, `null`은 각각을 끈다.

## 정리된 모순

이전 revision은 공식 문서 안의 불일치 세 쌍을 추적했다. 지금은 셋 다 일관되게 읽히므로, 오래된 해석을 다시 들여오지 않는다.

| 항목 | 한때 어긋났던 내용 | 현재 문서화된 입장 |
| --- | --- | --- |
| `context_file_max_chars` | `null` 동적 상한과 "기본 20,000" 산문 | `null`은 model window에 맞춰 늘어나며 하한 20,000자, 상한 500,000자 |
| `gateway.streaming.enabled` | 예시는 `true`, 산문은 `false` | 마스터 스위치는 `false`. 켜면 Telegram은 stream하고 Discord는 stream하지 않는다 |
| `agent.clarify_timeout` | 설정 자료는 `3600`, Discord·Telegram page는 `600` | `3600`초. CLI modal, TUI/Desktop card, gateway에 같은 값 하나 |

## Secret과 자격증명

**사실:** Hermes는 프로세스 환경과 활성 home의 `.env`를 읽는다. 외부 secret source는 `.env` 적재 **이후** 실행된다. Bitwarden은 `.env` 다음에 가져오고, 1Password는 `.env` 다음에 참조를 해석하며, command helper도 `.env` 다음에 돈다.

**사실:** 기존 `.env`·셸 값이 기본적으로 이긴다. Source가 이를 대체하려면 `override_existing`이 true여야 한다. Bitwarden과 1Password는 `override_existing: true`가 기본이고 command helper는 `false`가 기본이다. Source는 bootstrap token이나 다른 source가 이미 확보한 값을 덮어쓸 수 없다. `secrets.preserve_existing`은 외부 secret injection 중에도 이미 있는 profile별 값을 유지하는 문서화된 escape hatch다.

| Source | Bootstrap 자격증명 | 설정 위치 |
| --- | --- | --- |
| `.env` | — | `~/.hermes/.env` |
| Bitwarden Secrets Manager | `BWS_ACCESS_TOKEN` | `secrets.bitwarden` |
| 1Password | `OP_SERVICE_ACCOUNT_TOKEN` | `secrets.onepassword` + `op://` 참조 |
| Command helper | — | `secrets.command` (stdout은 dotenv `KEY=VALUE` 형식) |

**사실:** Credential pool은 같은 provider 안에서만 credential을 rotate한다. `credential_pool_strategies`는 기본 `fill_first`, `round_robin`, `least_used`, `random`을 지원한다. 별도 bot이나 profile을 쓴다고 credential isolation이 자동으로 생긴다고 추론하지 않는다.

**사실:** `security.redact_secrets`는 기본 `true`이며, tool 출력이 context·로그·채팅 응답에 들어가기 전에 key 형태 패턴을 제거한다. **사실:** `terminal`과 `execute_code` 하위 프로세스는 `KEY`, `TOKEN`, `SECRET`, `PASSWORD`, `CREDENTIAL`, `PASSWD`, `AUTH`를 포함한 변수명을 명시 허용이 없는 한 제거하며, cron 스크립트는 provider 자격증명을 상속하지 않는다.

**사실:** Hermes는 자체 자격증명 저장소, OS 자격증명 위치, `.env`·`.env.local`·`.envrc` 같은 프로젝트 secret 파일에 대한 `write_file`·`patch` 쓰기를 차단한다.

**권고:** 마스킹은 심층 방어이지 허가가 아니다. 걸러질 것이라 믿고 prompt, skill, 커밋, 티켓에 자격증명을 붙여 넣지 않는다.

## 백업과 버전 관리

**사실:** `updates.pre_update_backup`은 기본 `quick`으로 프로필별 핵심 상태를 `state-snapshots/`에 스냅샷한다. `full`은 `backups/`에 home 전체 ZIP을 추가하고 `off`는 비활성화한다. `backup_keep`은 기본 `5`다. `hermes update --backup`은 전체 백업을 강제하고 `--no-backup`은 해당 실행에서 비활성화한다.

**사실:** `hermes backup`은 **자격증명을 포함해** Hermes home 전체를 담고 `hermes import`가 복원한다. `hermes profile export`는 의도적으로 자격증명을 제거하므로 전체 백업이 아니다.

**사실 — 절대 커밋하지 않는다:** `.env`, `auth.json`, `.env.EXAMPLE`, `state.db*`, `gateway.pid`, `gateway_state.json`, `active_profile`, `memories/`, `sessions/`, `logs/`, `plans/`, `workspace/`, `home/`, `cache/`, `checkpoints/`, `sandboxes/`, `backups/`, `errors.log`, `.hermes_history`, 중첩된 `profiles/`. Security 페이지는 `chmod 600 ~/.hermes/.env`도 명시한다.

**권고:** `config.yaml`은 모든 secret을 인라인 대신 `${env:NAME}`으로 참조한 뒤에야 커밋할 수 있다. 치환 문법이 존재하는 이유가 바로 이것이다.

## 문제 해결

| 증상 | 문서화된 원인 | 조치 |
| --- | --- | --- |
| 설정이 먹지 않는다 | 상위 우선순위 계층이 이기거나 managed scope가 해당 leaf를 pin했다 | `hermes config show`로 managed 헤더 확인 |
| `hermes config set`이 키를 거부한다 | Managed scope가 pin했다 | 명령이 managed 출처를 알려준다. 거기서 변경한다 |
| `${VAR}` 참조가 문자 그대로 보인다 | 변수가 정의되지 않았다 | 로그의 경고를 확인하고 `.env`나 secret source에 정의한다 |
| 새 `.env` 키가 실행 중 session에 안 보인다 | 프로세스가 `.env`를 다시 읽지 않았다 | `/reload` 실행 또는 프로세스 재시작 |
| API key가 무시되는 듯하다 | 저장된 model/provider 선택이 일반 환경 해석보다 우선한다 | `hermes config show` 확인 후 `hermes model` 재실행 |
| `config get`이 `sk-o...7890`을 보여 준다 | Session transcript가 남으므로 credential 형태 값은 가려진다 | `--raw`를 붙이거나 `security.redact_secrets: false`로 둔다 |
| Update 후 옵션이 사라졌다 | 새 schema 옵션이 아직 없다 | `hermes config check` 후 `hermes config migrate` |
| Managed 정책이 적용되지 않는다 | Managed 파일 형식 오류로 무시됐다 | 크게 로깅된다. `hermes doctor`로 확인 |

## 검증 체크리스트

- [ ] Secret은 `.env`, `auth.json`, secret source에 있고 `config.yaml`에는 없다.
- [ ] `~/.hermes/.env` 권한이 `600`이다.
- [ ] 모든 키 이름과 기본값을 이 문서만 보고 옮기지 않고 설치 버전의 공식 reference에서 확인했다.
- [ ] 가드 스택은 호스트에 닿는 백엔드에서만 동작하므로, 승인 정책을 terminal 백엔드와 함께 기술했다.
- [ ] Hermes home에서 무언가를 커밋하기 전에 위의 금지 목록을 적용했다.
