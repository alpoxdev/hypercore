# 명령 예시

이 예시들은 라우팅 판단이 끝난 뒤에만 사용한다. 모든 플래그는 공식 CLI 레퍼런스(<https://code.claude.com/docs/en/cli-reference>) 기준이다.

## 기본 비대화형 분석

`-p` / `--print` 는 SDK 루프를 한 번 돌고 종료한다.

```bash
claude --permission-mode default \
  -p "이 저장소의 최신 diff를 검토하고 주요 위험을 요약해줘."
```

## CI / 스크립트용 Bare 모드

`--bare` 는 훅·스킬·플러그인·MCP·auto memory·CLAUDE.md 자동 발견을 모두 끈다. 어느 머신에서도 같은 결과를 보장한다. OAuth 키체인도 건너뛰므로 `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, 혹은 `--settings` 의 `apiKeyHelper` 가 필요하다.

```bash
ANTHROPIC_API_KEY=$KEY claude --bare -p "이 파일 요약해줘" \
  --allowedTools "Read"
```

Bare 모드 없이 CI 용 장기 토큰을 쓰려면:

```bash
# 한 번만: claude setup-token   (출력된 토큰을 시크릿 저장소로 옮긴다)
export CLAUDE_CODE_OAUTH_TOKEN=...
claude -p "diff 요약해줘" --output-format json
```

## 명시적 파일 수정

사용자가 Claude Code 가 파일을 수정하길 명시적으로 요청했을 때만 사용한다. `acceptEdits` 는 `mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed` 같은 일반 파일 시스템 명령도 자동 승인한다.

```bash
claude --permission-mode acceptEdits \
  -p "src/app.ts 를 패치해서 failing build를 고치고 변경 이유를 설명해줘."
```

## 읽기 전용 계획

파일 변경이나 셸 실행 없이 분석/계획만 원할 때 사용한다.

```bash
claude --permission-mode plan \
  -p "이 아키텍처를 분석하고 주요 위험을 정리해줘."
```

## `dontAsk` 로 잠긴 CI

`dontAsk` 는 프롬프트가 뜰 만한 모든 호출을 자동 거부한다. 필요한 도구만 사전 허용한다.

```bash
claude --permission-mode dontAsk \
  --allowedTools "Read" "Bash(git diff *)" "Bash(git log *)" \
  -p "스테이징된 변경만 요약해줘."
```

## 장시간 작업용 Auto 모드

Auto 모드는 액션마다 묻지 않고 진행하며, 서버측 분류기가 위험 행위를 차단한다. v2.1.83+ 와 지원 모델, 관리자 활성화된 플랜이 필요하다.

```bash
claude --permission-mode auto \
  -p "MIGRATION.md 의 마이그레이션 계획을 실행하되 절대 main 에 push 하지 마."
```

분류기는 프롬프트 안의 경계 선언("절대 main 에 push 하지 마") 도 차단 신호로 읽는다.

## 최근 세션 계속하기

현재 디렉터리의 가장 최근 대화에 이어서 붙는다. `-c` 는 단축형이다.

```bash
claude --continue \
  -p "이전 작업을 계속하고 다음 의사결정을 요약해줘."
```

## 이름 또는 ID 로 특정 세션 재개

`--resume` 은 표시 이름(`--name` / `-n`, 또는 `/rename` 으로 지정) 또는 세션 ID 를 받는다.

```bash
claude --resume "auth-refactor" \
  -p "이 세션에서 이어서 후속 요청을 처리해줘."

claude --resume <session-id> \
  -p "이 세션에서 이어서 후속 요청을 처리해줘."
```

## 재현 스크립트용 UUID 고정

`--session-id` 는 유효한 UUID 만 받는다. 같은 UUID 로 다시 실행하면 같은 대화에 이어붙는다.

```bash
claude --session-id 550e8400-e29b-41d4-a716-446655440000 \
  -p "이 턴을 안정된 대화에 추가해줘."
```

## PR 에 연결된 세션 재개

```bash
claude --from-pr 123 \
  -p "최근 리뷰 코멘트 반영해줘."
```

## 기존 세션에서 분기

원래 세션을 재사용하지 않고 갈라서 시도하고 싶을 때 사용한다.

```bash
claude --resume <session-id> \
  --fork-session \
  -p "이 시점부터 이어가되, 다른 수정 방안을 탐색해줘."
```

## 추가 디렉터리 포함

`--add-dir` 은 파일 접근 권한만 부여한다. `.claude/skills/` 외의 다른 `.claude/` 설정은 추가 디렉터리에서 로드되지 않는다.

```bash
claude --add-dir ../shared \
  --permission-mode default \
  -p "이 저장소와 shared 디렉터리를 함께 보고 통합 지점을 요약해줘."
```

## 구조화된 JSON 출력

```bash
claude --permission-mode default \
  --output-format json \
  -p "이 diff를 기준으로 summary, risks, next_steps 키를 가진 JSON 객체를 반환해줘."
```

스키마 검증된 출력이 필요하면 `--output-format json` 과 `--json-schema` 를 함께 쓴다. 검증된 결과는 JSON envelope 의 `structured_output` 필드에 들어온다.

```bash
claude -p "auth.py 의 함수 이름을 추출해줘" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

## 실시간 스트리밍

`stream-json` 은 줄 단위 JSON 이벤트를 내보낸다. 토큰 델타를 보려면 `--verbose` 와 `--include-partial-messages` 를 함께 쓴다.

```bash
claude -p "재귀를 설명해줘" \
  --output-format stream-json --verbose --include-partial-messages
```

## 한정된 자율 실행

턴 수와 달러 한도를 정해 자율 실행이 무한 반복되지 않게 한다. 폴백 모델을 추가하면 한 번의 과부하로 작업이 죽지 않는다.

```bash
claude -p "오픈 이슈를 분류하고 답변 초안을 작성해줘." \
  --max-turns 8 \
  --max-budget-usd 5.00 \
  --fallback-model sonnet
```

## 도구 제한 또는 추가

```bash
# 빌트인만 사용, Bash 금지
claude -p "이 모듈 리팩터링 해줘." --tools "Read,Edit"

# 필요한 것만 사전 허용
claude -p "스테이징하고 커밋해줘." \
  --allowedTools "Bash(git add *)" "Bash(git commit *)" "Bash(git status *)"

# 특정 도구만 차단
claude -p "이 모듈 리팩터링 해줘." --disallowedTools "Bash"
```

## 시스템 프롬프트 조정

기본값을 유지하려면 append 계열을 우선한다.

```bash
claude -p "이 PR 리뷰해줘." \
  --append-system-prompt "너는 보안 엔지니어다. 인젝션과 인가 결함을 먼저 표시해."

claude -p "이 PR 리뷰해줘." \
  --append-system-prompt-file ./prompts/security-reviewer.txt
```

전체 교체가 필요할 때만 replacement 계열을 쓴다.

```bash
claude -p "..." --system-prompt "너는 Python 전문가다."
claude -p "..." --system-prompt-file ./prompts/full-prompt.md
```

## MCP 서버 로드

```bash
claude --mcp-config ./mcp.json \
  -p "데이터베이스 MCP 서버로 스키마 요약해줘."

# 재현성을 위해 다른 MCP 소스를 모두 무시
claude --strict-mcp-config --mcp-config ./mcp.json -p "..."
```

## 위험한 권한 우회는 명시적 승인 후에만

`--dangerously-skip-permissions` 는 `--permission-mode bypassPermissions` 와 같다. 사용자의 명시적 승인 후, 그리고 네트워크가 차단된 컨테이너/VM 처럼 격리된 환경에서만 사용한다. prompt injection 보호가 없으므로 "프롬프트가 적었으면" 이라는 목적이라면 `auto` 모드를 우선 검토한다.

```bash
claude --dangerously-skip-permissions \
  -p "요청된 패치를 적용하고 필요한 검증을 실행해줘."
```
