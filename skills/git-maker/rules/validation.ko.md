# 검증

`git-maker` 변경 완료를 선언하거나 fast-path run을 성공으로 보고하기 전에 이 check를 실행한다.

## 스킬 품질 체크

- Description은 이 skill이 commit과 push를 함께 수행한다고 말하며, 모든 경계(commit-only, push-only, 이력 재작성, pull request)를 다른 skill 이름이 아니라 요청한 결과로 표현한다.
- `assets/evals/git-maker-cases.jsonl`은 should-trigger, should-not-trigger, boundary, near-miss, safety, adversarial, regression case로 구성되고, 모든 case가 자기 `intent`, `runs`, `threshold`, `metrics`를 명시한다. 기존 case가 다루지 않는 지점을 검사할 때만 case를 추가한다.
- Core `SKILL.md`는 lean하게 유지되고 rules/scripts를 직접 가리키며 중복하지 않는다. subagent lane rule은 `rules/agent-parallelism.md`에만 둔다.
- Script addition은 deterministic speed 또는 safety improvement로 정당화된다.
- Worktree guidance가 명확하다. linked worktree는 valid context이고 checkout root는 별도로 유지되며 `.git`이 directory라고 가정하지 않는다.
- 인자 없음과 `current`/`CURRENT`는 현재 세션 변경을, `all`/`ALL`은 모든 uncommitted 변경을 선택한다.
- 모든 scope mode에서 `&&` propagation syntax가 정의되고 mutation 전에 모든 target을 validate한다.
- Conflict handling은 intent-preserving 자율 해결이 기본이며 중요한 결정 경계에서만 escalation한다.

## 런타임 체크

- Skill root에서는 `bash -n scripts/git-maker-fast.sh`, repository root에서는 `bash -n skills/git-maker/scripts/git-maker-fast.sh`가 통과한다.
- `scripts/git-maker-fast.sh inspect . --jobs 2`가 `repos|begin`, `repo-status|begin`, file inventory block을 출력한다.
- 가능하면 local linked-worktree fixture가 `worktree|linked`와 linked checkout root의 `repo|...` path를 보여준다.
- 사용자가 push를 요청하지 않는 한 push helper는 실제 remote에 대해 테스트하지 않는다. behavior validation에는 local fixture를 사용한다.
- Commit phase는 여전히 targeted staging과 commit당 하나의 logical change를 사용한다.
- 커밋 메시지는 영어 Conventional Commit이다. 명령형 subject, colon 뒤 소문자, 끝 마침표 없음, 72자 이하, body 앞 빈 줄을 지키고, 사용자나 저장소가 요청하지 않은 sign-off·attribution trailer가 없다.
- Push phase는 모든 commit group이 성공한 뒤에만 automatic이다.
- Force push는 `main`과 `master`에서 계속 차단된다.
- Subagent를 사용했다면 그 작업은 read-only였고, 두 에이전트가 같은 Git index mutation을 소유하지 않았으며, 최종 staged 파일이 main integrator가 선택한 그룹과 일치하고, 건너뛴/실패한 push target을 모두 보고했다.
- Local multi-branch fixture로 이번 run에서 만든 commit만 각 target에 왼쪽부터 도달하는지 검증한다.
- Local conflict fixture로 mechanical conflict 하나는 질문 없이 해결·검증하고, 의도적으로 ambiguous한 behavior conflict는 이후 target 전에 한 가지 집중된 질문을 유발하는지 검증한다.

## Readback 체크

다음 관점으로 읽는다.

1. trigger model: 이 skill은 commit+push에서 활성화되고 commit-only 또는 push-only에서는 활성화되지 않는다.
2. rushed operator: 가장 빠르고 안전한 명령이 명확하다.
3. commit reviewer: 생성된 subject가 과거형 보고나 모호한 요약이 아니라 영어 명령형 변경("add", "fix")으로 읽힌다.
4. maintainer: future speed rules는 `rules/speed-and-automation.md`에, durable commit policy는 `rules/commit-and-push-policy.md`에, subagent lane rules는 `rules/agent-parallelism.md`에 속한다.
5. branch operator: `/git-maker && dev`, `/git-maker CURRENT && dev && deploy/staging`, `/git-maker all && dev`의 scope와 propagation behavior가 모호하지 않다.

## Sources

> 외부 출처 없음. 내용 확인 2026-09-22.

이 규칙은 이 패키지의 저장소 작업 경험에서 작성했다. 외부 주장이 없으므로 외부 출처를 인용하지 않는다.
