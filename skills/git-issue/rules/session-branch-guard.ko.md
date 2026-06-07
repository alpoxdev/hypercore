# Session Branch Guard

`git-issue`가 issue branch를 checkout하거나 생성한 뒤 이 rule을 사용합니다.

## Guard Definition

issue branch guard는 current-AI-session 제약입니다.

- issue branch checkout이 검증된 뒤 시작됩니다.
- active AI session이 수행하는 이후 command와 edit에 적용됩니다.
- agent가 제어할 수 있는 execution surface 밖의 사용자 parent shell을 변경했다고 주장하지 않습니다.
- 사용자가 명시적으로 issue branch를 벗어나라고 하거나, `git-issue`로 다른 issue를 target하거나, branch 변경이 필수인 Git workflow를 요청할 때만 끝납니다.

## Required State

편집 전에 working context에 다음 값을 기록합니다.

- issue number
- issue URL
- branch name
- repository root
- checkout verification command와 result

## Enforcement

- 같은 task의 이후 file edit 또는 Git operation 전에 `git branch --show-current`를 확인합니다.
- current branch가 guarded branch가 아니면 계속하기 전에 guarded branch로 다시 전환합니다.
- 사용자가 명시적으로 guard를 종료하거나 retarget하지 않았는데 관련 없는 branch에 대해 `git switch`, `git checkout`, `git worktree add`, rebase, reset, branch delete를 실행하지 않습니다.
- 다른 branch를 임시로 확인해야 하면 checkout을 바꾸지 않는 `git show`, `git diff`, `gh` query 같은 read-only command를 우선합니다.

## Reporting

final 또는 handoff message에서 다음을 말합니다.

- 어떤 issue branch가 active인지
- guard가 현재 AI 세션 scope라는 점
- checkout을 `git status --short --branch`로 검증했는지

## Blockers

다음 경우 멈추고 blocker를 보고합니다.

- checkout이 local changes를 덮어쓸 수 있음
- guarded branch가 외부에서 삭제되거나 renamed됨
- `gh`가 issue를 더 이상 resolve할 수 없음
- 사용자가 guard를 명시적으로 retarget/exit하지 않고 conflicting branch operation을 요청함
