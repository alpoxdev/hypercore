---
name: claude-code
description: >-
  사용자가 Anthropic Claude Code CLI(`claude`) 자체를 명시적으로 원할 때 사용.
  격리된 세션 실행, 비대화형(`-p`) 실행, ID 또는 이름 기반 세션 재개,
  CI 친화적인 `--bare` 호출이 대상이다. 트리거 문구 예시:
  "claude code 써줘", "claude한테 물어봐", "claude 실행해",
  "지난 claude 세션 이어줘", "auth-refactor claude 세션 재개해",
  "Anthropic CLI로 이 저장소를 점검하거나 수정해줘".
---

@rules/routing.ko.md

# Claude Code 스킬

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

진실 공급원: <https://code.claude.com/docs/en/cli-reference>

## 기본값

| 항목 | 기본값 |
|------|--------|
| 모델 선택 | 사용자가 `--model` 을 명시적으로 요구하지 않으면 Claude Code CLI 기본 모델 사용 |
| 추론 강도 | 사용자가 `--effort` 를 명시적으로 요구하지 않으면 CLI 기본값 사용 |
| 권한 모드 | `--permission-mode default` |
| 헤드리스 모드 | `-p` / `--print` |
| CI / 스크립트 실행 | `--bare` 를 추가해 로컬 훅·플러그인·MCP·CLAUDE.md 자동 발견을 끈다 |
| 재개 대상 | 현재 디렉터리 최근 세션은 `claude --continue` (`-c`), 특정 세션은 ID 또는 표시 이름으로 `claude --resume` (`-r`) |

사용자가 명시적으로 요청하지 않는 한 모델이나 `--effort` 를 묻지 않는다.

## 라우팅

이 스킬은 실제로 `claude` CLI 또는 별도 Claude Code 세션이 필요한 요청에만 사용한다.

- 요청이 범위를 벗어날 수 있으면 먼저 [rules/routing.ko.md](rules/routing.ko.md)를 읽고 커맨드를 만들지 말지 결정한다.
- `claude` CLI 자체가 필요 없는 일반 문서 작성, 문서 정리, 직접 로컬 편집은 다른 스킬이나 직접 작업으로 전환한다.

## 예시

긍정 트리거:

- "Claude Code로 이 저장소를 리뷰하고 위험 요소를 요약해줘."
- "`claude` print 모드로 실행해서 이 아키텍처를 분석해줘."
- "지난 Claude Code 세션 이어서 패치를 마무리하게 해줘."
- "`auth-refactor` 라는 이름의 claude 세션을 재개해서 다음 수정을 적용해줘."
- "이 CI 단계가 로컬 훅을 끌어오지 않게 `claude --bare -p` 로 돌려줘."

부정 트리거:

- "이 런북을 읽기 쉽게 다시 써줘."
- "우리 저장소용 새 스킬을 만들어줘."

경계 사례:

- "Claude Code 권한 모드를 조사해서 설명해줘."
  사용자가 `claude` CLI 실행까지 원할 때만 이 스킬을 쓰고, 그렇지 않으면 리서치나 직접 문서 작업으로 전환한다.

## 핵심: 비대화형 실행은 `-p`

비대화형 Claude Code 실행에는 항상 `-p` / `--print` 를 사용한다. `-p` 없이 위치 인수 프롬프트만 주면 대화형 REPL이 시작되어 스크립트가 TTY 를 기다리며 멈춘다.

```bash
# 비대화형 (헤드리스 / SDK)
claude --permission-mode default -p "프롬프트"

# 대화형 REPL (초기 프롬프트만 - 종료되지 않음)
claude "프롬프트"
```

`-p` 가 SDK/CI 의 표준 진입점이다. 이전에 "headless mode" 라고 부르던 것이 이 플래그이며, 동작은 동일하다.

## CI / 스크립트용 Bare 모드

스크립트나 CI 호출에는 `--bare` 를 같이 쓴다. 훅, 스킬, 플러그인, MCP 서버, auto memory, CLAUDE.md 자동 발견을 모두 건너뛰어 어느 머신에서도 같은 결과를 보장한다. Bare 모드는 OAuth 키체인도 건너뛰므로 `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, 혹은 `--settings` 에 들어 있는 `apiKeyHelper` 가 필요하다.

```bash
ANTHROPIC_API_KEY=$KEY claude --bare -p "diff 요약해줘" --allowedTools "Read"
```

장기 OAuth 토큰이 필요한 파이프라인에서는 `claude setup-token` 으로 발급한 뒤 `CLAUDE_CODE_OAUTH_TOKEN` 으로 export 한다. 단, `--bare` 는 `CLAUDE_CODE_OAUTH_TOKEN` 을 읽지 않으므로 `--bare` 와 함께 쓸 때는 `ANTHROPIC_API_KEY` 또는 `apiKeyHelper` 를 사용한다.

## 작업 실행

권한 모드를 바꾸거나, 세션을 재개하거나, 도구를 제한하거나, 추가 디렉터리를 넣기 전에는 [references/recipes.ko.md](references/recipes.ko.md)를 먼저 읽는다.

### 권한 모드 선택

지원되는 모드는 6 종이다. 작업이 안전하게 허용하는 가장 느슨한 모드를 선택한다.

| 플래그 | 사용 시점 |
|--------|-----------|
| `--permission-mode default` | 일반적인 Claude Code 사용, 기본 승인 프롬프트 유지 |
| `--permission-mode plan` | 파일 변경이나 셸 실행 없는 읽기 전용 분석/계획 |
| `--permission-mode acceptEdits` | 사용자가 Claude Code 가 파일을 수정하길 명시적으로 원할 때 (`mkdir`, `mv`, `cp` 같은 일반 파일 시스템 명령도 자동 승인) |
| `--permission-mode auto` | 프롬프트 피로가 큰 장시간 자율 작업; 서버측 분류기가 위험 행위를 차단하지만 검토를 대체하지는 않는다 |
| `--permission-mode dontAsk` | 잠긴 CI: `permissions.allow` 규칙과 읽기 전용 명령만 허용, 그 외는 자동 거부 |
| `--permission-mode bypassPermissions` | 컨테이너/VM 전용. `--dangerously-skip-permissions` 와 같은 효과이며, 사용자의 명시적 승인이 필요하고 prompt injection 보호가 없다 |

Auto 모드는 Claude Code v2.1.83+ 가 필요하며 플랜·관리자 정책·모델·공급자 조합으로 게이팅된다. CLI 가 사용 불가라고 보고하면 일시적 장애가 아니므로 재시도하지 않는다.

### 명령 작성 규칙

- 시작점은 `claude --permission-mode default -p "프롬프트"` 다.
- 사용자가 명시적으로 원할 때만 `--model <model>` 또는 `--effort <level>` 을 추가한다.
- `--output-format` 은 사용자가 `text` 외 형식을 원할 때만 쓴다. 지원 값: `text`(기본), `json`, `stream-json`.
- 스키마 검증된 구조화 출력이 필요하면 `--output-format json` 과 `--json-schema '<JSON Schema>'` 를 함께 쓴다.
- 무한 루프를 피해야 하는 자율 print 모드 실행에는 `--max-turns <N>` 또는 `--max-budget-usd <달러>` 를 추가한다.
- 과부하 시 즉시 실패 대신 우아한 폴백이 낫다면 print 모드에서 `--fallback-model <name>` 을 사용한다.
- 시작 디렉터리 밖의 파일이 필요할 때만 `--add-dir <path>` 를 추가한다. (`--add-dir` 은 파일 접근 권한만 부여하며, `.claude/skills/` 를 제외한 다른 `.claude/` 설정은 자동 로드되지 않는다.)
- 도구는 `--allowedTools`, `--disallowedTools`, `--tools` 로 제한한다 (`--tools ""` 는 모든 빌트인 비활성, `--tools "default"` 는 전체, `"Bash,Edit,Read"` 같은 콤마 목록도 가능).
- 시스템 프롬프트는 `--append-system-prompt`, `--append-system-prompt-file`, `--system-prompt`, `--system-prompt-file` 로 추가하거나 교체한다.
- MCP 서버는 `--mcp-config <file-or-json>` 으로 로드하고, 다른 MCP 소스를 무시하려면 `--strict-mcp-config` 를 추가한다.
- `--dangerously-skip-permissions` 는 반드시 명시적 승인 후에만 쓰고, 일반 파일 수정은 `--permission-mode acceptEdits` 를 우선한다.

### 세션 재개

```bash
# 현재 디렉터리의 최근 세션
claude --continue -p "이전 작업 계속해줘"   # 단축: claude -c -p "..."

# ID 또는 표시 이름으로 특정 세션 재개
claude --resume "auth-refactor" -p "이 후속 요청으로 이어가줘"   # 단축: -r
claude --resume <session-id> -p "이 후속 요청으로 이어가줘"

# 스크립트가 항상 같은 세션을 쓰도록 UUID 고정
claude --session-id 550e8400-e29b-41d4-a716-446655440000 -p "..."   # 반드시 유효한 UUID

# PR 에 연결된 세션 재개
claude --from-pr 123 -p "리뷰 코멘트 반영해줘"
```

현재 디렉터리의 최근 대화는 `--continue` 를 사용한다.
특정 세션은 **ID 또는 표시 이름**(`--name` / `-n` 으로 지정하거나 세션 도중 `/rename` 으로 변경) 으로 `--resume` 한다.
`--session-id` 는 실제 UUID 만 받는다 — 다른 문자열은 거절된다.
재개할 때는 기존 세션 동작을 유지하고, 사용자가 모델, `--effort`, 권한 모드 변경을 명시적으로 요청할 때만 그 설정을 바꾼다.
기존 세션을 덮지 않고 갈라서 이어가고 싶을 때만 `--fork-session` 을 추가한다.

### 완료 후

- 결과와 함께 경고나 부분 출력이 있으면 같이 요약한다.
- 사용자가 `claude --continue` (`-c`), `claude --resume <id-or-name>` (`-r`), `claude --from-pr <pr>` 로 이어갈 수 있다고 알려준다.
- 계속할지, 프롬프트를 조정할지, 직접 작업으로 돌아갈지 묻는다.

## 비판적으로 사용하기

Claude Code를 권위자가 아니라 동료로 다룬다.

- 근거가 분명하면 자신의 판단을 유지한다.
- 이견이 생기면 최신 문서나 1차 자료로 검증한다.
- 별도 Claude Code 세션도 틀리거나 오래된 판단을 할 수 있음을 기억한다.
- 실제로 애매할 때만 사용자에게 결정을 맡긴다.

## 인증

CLI 는 다음 우선순위로 자격 증명을 읽는다: 클라우드 공급자 환경 변수(`CLAUDE_CODE_USE_BEDROCK` / `_VERTEX` / `_FOUNDRY`) → `ANTHROPIC_AUTH_TOKEN` → `ANTHROPIC_API_KEY` → `apiKeyHelper` → `CLAUDE_CODE_OAUTH_TOKEN` → `/login` 의 구독 OAuth.

- 브라우저 로그인: `claude` 를 한 번 실행해 안내를 따르거나 `claude auth login` (Console 과금은 `--console`, SSO 강제는 `--sso`) 을 쓴다.
- 상태 확인 / 로그아웃: `claude auth status` 또는 세션 안의 `/status`; `claude auth logout` 또는 `/logout` 으로 자격 증명을 지운다.
- CI 용 장기 OAuth: `claude setup-token` 이 토큰을 출력하며, 이를 `CLAUDE_CODE_OAUTH_TOKEN` 으로 export 한다 (`--bare` 는 이 변수를 읽지 않음).
- 직접 API: `ANTHROPIC_API_KEY` 는 `X-Api-Key` 헤더, `ANTHROPIC_AUTH_TOKEN` 은 게이트웨이용 `Authorization: Bearer`.

## 오류 처리

- `command not found: claude`: Claude Code CLI 설치가 필요하다고 안내한다. 설치 후 `claude install stable` 로 재설치할 수 있다.
- 인증 오류: 위 우선순위를 확인하고 (구독이 활성인데도 막히면 `unset ANTHROPIC_API_KEY` 가 필요할 수 있음), `claude auth login` 또는 `claude auth status` 로 다시 점검한다.
- 권한 차단: 작업 성격에 맞는 `--permission-mode` (`plan` 은 읽기 전용, `acceptEdits` 는 파일 수정) 로 재시도하거나 `--allowedTools` / `--disallowedTools` 를 조정한다. 사용자의 명시적 승인 없이 `--dangerously-skip-permissions` 로 올리지 않는다.
- 세션을 찾지 못함: 인수 없이 `claude --resume` 으로 목록에서 선택하거나 현재 디렉터리 최근 세션이면 `claude --continue` 로 전환한다. `--session-id` 는 UUID 만 허용한다.
- Auto 모드 사용 불가: 플랜·관리자 정책·모델·공급자 조합으로 게이팅된 것이며 일시적 장애가 아니다. `default` 나 `acceptEdits` 로 폴백한다.
- 잘못된 플래그나 모델 오류: `claude --help` 로 옵션을 확인 후 재시도한다. `--help` 가 모든 플래그를 보여주지는 않으므로 전체 목록은 CLI 레퍼런스를 참고한다.
