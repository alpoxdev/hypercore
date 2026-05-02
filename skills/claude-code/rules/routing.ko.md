# 라우팅 규칙

사용자가 `claude` CLI 자체, 별도 Claude Code 세션, 비대화형(`-p`) 실행, `--bare` 호출, 또는 세션 재개 플로우 중 하나를 명시적으로 원할 때만 이 스킬을 사용한다.

요청이 실제로 `claude` CLI를 필요로 하지 않으면 다른 경로로 전환한다.

## 범위 안

- 분석·검토·계획·구조화 출력(`json`, `stream-json`, `--json-schema`) 등을 위해 `claude -p` 를 실행해야 할 때
- `--continue` (`-c`), `--resume` (`-r`) (ID 또는 표시 이름), `--from-pr`, `--session-id` (UUID), `--fork-session` 으로 Claude Code 세션을 이어가야 할 때
- 사용자가 `claude` CLI 를 워크플로 일부로 명시했고 Claude Code 에게 코드 점검·패치를 맡기려 할 때 (`--allowedTools` / `--disallowedTools` / `--tools` 로 사전 허용 도구 집합 지정 포함)
- 로컬 훅·플러그인·MCP·auto memory·CLAUDE.md 를 끌어오면 안 되는 CI / 스크립트 실행에 `--bare` 를 써야 할 때
- 추가 저장소 경로가 필요한 Claude Code 실행에 `--add-dir` 을 써야 할 때 (파일 접근만 부여하며, `.claude/skills/` 를 제외한 다른 `.claude/` 설정은 로드되지 않음)
- 권한 모드 선택: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`
- `claude auth login`, `claude auth status`, `claude auth logout`, `claude setup-token` (CI 용 장기 OAuth) 로 인증 또는 자격 증명 회전이 필요할 때

## 범위 밖

- `claude` CLI 없이도 가능한 스킬 생성 또는 스킬 리팩터링
- 일반 문서 작성, 문서 정리, 런북 수정
- 사용자가 Claude Code를 요청하지 않았고 직접 로컬 편집이 더 단순한 작업
- Claude Code 실행보다 Anthropic 제품 조사 자체가 주목적인 리서치 작업

요청이 실제로 `claude` CLI 를 필요로 하지 않으면 다른 스킬이나 직접 편집으로 넘긴다.

일반 글쓰기, 스킬 생성, 직접 하는 편이 더 쉬운 로컬 편집을 위해 Claude Code 명령을 만들지 않는다.
Claude Code 가 맡을 일이 아닌데 억지로 실행하려고 `--dangerously-skip-permissions` 또는 `--permission-mode bypassPermissions` 까지 올리지 않는다 — 두 옵션 모두 사용자의 명시적 승인과 컨테이너/VM 같은 격리된 환경이 필요하다.
Claude Code 가 맞지 않는 작업이면 깔끔하게 다른 경로로 전환한다.
