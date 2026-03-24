# 라우팅 규칙

사용자가 `claude` CLI 자체, 별도 Claude Code 세션, 또는 Claude Code의 비대화형/재개 플로우를 명시적으로 원할 때만 이 스킬을 사용한다.

요청이 실제로 Claude Code CLI를 필요로 하지 않으면 다른 경로로 전환한다.

## 범위 안

- 분석, 검토, 계획, 구조화 출력 등을 위해 `claude -p` 를 실행해야 할 때
- `--continue` 또는 `--resume` 으로 Claude Code 세션을 이어가야 할 때
- 사용자가 `claude` CLI를 워크플로 일부로 명시했고, Claude Code에게 코드 점검이나 패치를 맡기려 할 때
- 추가 저장소 경로가 필요한 Claude Code 실행에서 `--add-dir` 이 필요할 때

## 범위 밖

- `claude` CLI 없이도 가능한 스킬 생성 또는 스킬 리팩터링
- 일반 문서 작성, 문서 정리, 런북 수정
- 사용자가 Claude Code를 요청하지 않았고 직접 로컬 편집이 더 단순한 작업
- Claude Code 실행보다 Anthropic 제품 조사 자체가 주목적인 리서치 작업

요청이 실제로 Claude Code CLI를 필요로 하지 않으면 다른 스킬이나 직접 편집으로 넘긴다.

일반 글쓰기, 스킬 생성, 직접 하는 편이 더 쉬운 로컬 편집을 위해 Claude Code 명령을 만들지 않는다.
Claude Code가 맡을 일이 아닌데 억지로 실행하려고 `--dangerously-skip-permissions` 까지 올리지 않는다.
Claude Code가 맞지 않는 작업이면 깔끔하게 다른 경로로 전환한다.
