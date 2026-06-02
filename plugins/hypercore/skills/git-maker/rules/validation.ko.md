# 검증

`git-maker` 변경 완료를 선언하거나 fast-path run을 성공으로 보고하기 전에 이 check를 실행한다.

## 스킬 품질 체크

- Description은 이 skill이 commit과 push를 함께 수행한다고 말하며 `git-commit` 및 `git-push`와 구분한다.
- Positive trigger example이 최소 3개 있다.
- Negative trigger example이 최소 2개 있다.
- Boundary example이 최소 1개 있다.
- Core `SKILL.md`는 lean하게 유지되고 rules/scripts를 직접 가리키며 중복하지 않는다.
- Script addition은 deterministic speed 또는 safety improvement로 정당화된다.
- Agent parallelism guidance는 `rules/agent-parallelism.md`에 격리되어 있고 core에 중복되지 않는다.
- Worktree guidance가 명확하다. linked worktree는 valid context이고 checkout root는 별도로 유지되며 `.git`이 directory라고 가정하지 않는다.

## 런타임 체크

- `bash -n scripts/git-maker-fast.sh`가 통과한다.
- `scripts/git-maker-fast.sh inspect . --jobs 2`가 `repos|begin`, `repo-status|begin`, file inventory block을 출력한다.
- 가능하면 local linked-worktree fixture가 `worktree|linked`와 linked checkout root의 `repo|...` path를 보여준다.
- 사용자가 push를 요청하지 않는 한 push helper는 실제 remote에 대해 테스트하지 않는다. behavior validation에는 local fixture를 사용한다.
- Commit phase는 여전히 targeted staging과 commit당 하나의 logical change를 사용한다.
- Commit subject는 `~하라`, `~해라`, `~라`로 끝나는 한국어 command가 아니라 neutral Conventional Commit summary처럼 읽힌다.
- Push phase는 모든 commit group이 성공한 뒤에만 automatic이다.
- Force push는 `main`과 `master`에서 계속 차단된다.
- Subagent를 사용했다면 그 작업은 read-only였고 최종 Git mutation은 main integrator에 남아 있었다.

## Readback 체크

다음 관점으로 읽는다.

1. trigger model: 이 skill은 commit+push에서 활성화되고 commit-only 또는 push-only에서는 활성화되지 않는다.
2. rushed operator: 가장 빠르고 안전한 명령이 명확하다.
3. commit reviewer: 생성된 한국어 subject가 instruction이 아니라 간결한 change/result summary처럼 보인다.
4. maintainer: future speed rules는 `rules/speed-and-automation.md`에, durable commit policy는 `rules/commit-and-push-policy.md`에, subagent lane rules는 `rules/agent-parallelism.md`에 속한다.
