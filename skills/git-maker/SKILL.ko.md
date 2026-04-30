---
name: git-maker
description: '커밋과 푸시를 한 번에 실행합니다. 사용자가 커밋+푸시, 변경사항 저장 후 올리기, `/git-maker`를 요청할 때 사용하며, 안전한 커밋 그룹핑을 먼저 수행한 뒤 두 번째 확인 없이 자동으로 푸시합니다.'
license: MIT
allowed-tools: Bash
compatibility: Bash와 `skills/git-maker/scripts` 아래 스크립트를 필요로 합니다.
---

# Git Maker 스킬

> 빠르고 안전한 커밋+푸시 오케스트레이션.

<purpose>

- 현재 저장소 변경사항으로 하나 이상의 Conventional Commit을 만든다.
- 성공적으로 만든 커밋은 커밋과 푸시 사이 확인 없이 자동으로 푸시한다.
- 반복 저장소 탐색을 줄이고 read-only 점검을 병렬화하기 위해 fast helper를 먼저 사용한다.

</purpose>

<routing_rule>

사용자가 **커밋 + 푸시**를 한 번에 원할 때 `git-maker`를 사용한다.

다음 경우에는 이웃 스킬을 사용한다:

- 커밋만 요청 → `git-commit`
- 푸시/동기화만 요청 → `git-push`
- rebase/reset/amend/history rewrite 요청 → commit+push가 명시되고 이력 작업도 별도 승인된 경우가 아니면 이 스킬을 사용하지 않는다

</routing_rule>

<trigger_conditions>

Positive triggers:

- "commit and push"
- "commit and push these changes"
- "/git-maker"
- "make a commit and push it"
- "save and push my changes"
- "커밋하고 푸시해"
- "변경사항 저장하고 올려"

Negative triggers:

- "commit these changes" → `git-commit`
- "push my commits" → `git-push`
- "rebase this branch" → 이 스킬 아님

Boundary trigger:

- "commit this, then maybe push" → 푸시가 조건부이므로 `git-commit` 사용

</trigger_conditions>

<scripts>

| Script | Purpose |
|------|------|
| `scripts/git-maker-fast.sh inspect [start_dir] [--jobs N]` | 빠른 preflight: pruned repo discovery, parallel repo status, file inventory |
| `scripts/git-maker-fast.sh push [--force] [repo...]` | 재탐색 없이 명시 repo push; non-interactive; protected force-push guard |
| `scripts/git-commit.sh [--repo path] "msg" [files...]` | 한 저장소에서 staged 또는 선택 파일 커밋 |
| `scripts/git-push.sh [--force]` | legacy/discovered safe push fallback |
| `scripts/repo-discover.sh [start_dir]` | legacy repo discovery fallback |
| `scripts/repo-status.sh [repo]` | legacy status fallback |

</scripts>

<support_file_read_order>

필요한 파일만 읽는다:

1. 속도 개선 요청, 큰 repo set, multi-repo 가능성이 있으면 `rules/speed-and-automation.md`.
2. Claude Code/Codex subagent로 read-only grouping, message drafting, safety review를 나눌 수 있으면 `rules/agent-parallelism.md`.
3. staging/commit 전 또는 argument mode, grouping, safety, push behavior가 애매하면 `rules/commit-and-push-policy.md`.
4. 실행/리팩터 완료 보고 전 `rules/validation.md`.

</support_file_read_order>

<argument_validation>

인자는 `--force`를 제외하고 commit phase로 전달한다.

| Argument | Meaning |
|------|------|
| 없음 | 현재 세션 변경에서 시작하고 git state로 검증한 뒤 논리적으로 그룹핑 |
| `ALL` / `all` | 모든 미커밋 변경을 포함하고 논리적으로 그룹핑하며 파일을 남기지 않음 |
| `--force` | commit 인자에서 제거하고 push에만 전달 (`--force-with-lease`, `main`/`master` 차단) |
| 기타 텍스트 | repo discovery, file selection, staging, commit message generation 필터로 사용 |

명시 필터가 실제 git state와 맞지 않으면 멈춘다.

</argument_validation>

<workflow>

## Phase 1. Fast preflight

먼저 fast helper를 실행한다:

```bash
scripts/git-maker-fast.sh inspect . --jobs 4
```

출력된 repo list와 file inventory로 다음을 결정한다:

- scope에 포함되는 저장소
- staged / unstaged / untracked 파일
- 논리적 변경 그룹
- 느린 fallback 필요 여부

helper가 실패하거나 정보가 부족하면 다음으로 fallback한다:

```bash
scripts/repo-discover.sh
scripts/repo-status.sh
scripts/repo-status.sh path/to/repo
```

## Phase 2. Group and commit

변경사항을 논리 그룹으로 나눈다. 각 그룹은 저장소별로 순차 커밋한다:

```bash
scripts/git-commit.sh "<type>[scope]: <한국어 subject>" path/to/file1 path/to/file2
scripts/git-commit.sh --repo path/to/repo "<type>[scope]: <한국어 subject>" path/to/file1
```

규칙:

- 커밋 하나는 논리 변경 하나만 포함
- 필요한 파일만 targeted staging
- Conventional Commit type/scope 뒤 subject/body는 한국어
- subject는 `~하라`, `~해라`, `~라` 같은 명령형 어미가 아니라 커밋 요약에 맞는 중립적 변경/결과 표현
- secret, 무관한 사용자 변경, destructive git operation, `--no-verify` 금지
- 커밋 하나라도 실패하면 멈추고 push하지 않음

자세한 정책은 `rules/commit-and-push-policy.md`를 읽는다.

## Phase 3. Push automatically

모든 commit group이 성공하면 확인을 묻지 않고 push한다.

preflight repo list 재사용을 우선한다:

```bash
scripts/git-maker-fast.sh push /absolute/repo/path
scripts/git-maker-fast.sh push --force /absolute/repo/path
```

Fallback:

```bash
scripts/git-push.sh
scripts/git-push.sh --force
```

## Phase 4. Report

다음을 보고한다:

- 생성한 commit과 메시지
- push된 저장소
- skipped 또는 failed push target
- 남은 local changes 또는 blocker

</workflow>

<parallelization>

- `scripts/git-maker-fast.sh inspect --jobs N`으로 read-only repo inspection을 병렬화한다.
- 복잡한 dirty tree에서 Claude Code/Codex subagent를 쓰기 전에는 `rules/agent-parallelism.md`를 읽는다; subagent는 검토와 제안만 수행한다.
- 같은 저장소 안의 commit은 git index를 공유하므로 병렬화하지 않는다.
- multi-repo commit은 repo boundary와 file group이 명확할 때만 독립적으로 진행할 수 있다.
- 모든 intended commit이 성공한 뒤에만 push한다.

</parallelization>

<required>

| Category | Rule |
|------|------|
| Commit first | 모든 commit group이 성공해야 push한다. |
| Automatic push | 성공한 commit 뒤 push 여부를 묻지 않는다. |
| Safety | `main`/`master` force push 금지; detached HEAD push 금지. |
| Upstream | upstream이 없으면 `-u origin <branch>`로 push한다. |
| Reuse preflight | 중복 discovery를 피하기 위해 `git-maker-fast.sh push [repo...]`를 우선한다. |
| Agent boundaries | subagent는 검토와 제안만 수행하고, main integrator가 staging, commit, push를 소유한다. |
| Validation | 최종 보고 전 `rules/validation.md` checks를 실행한다. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Push confirmation | commit 성공 후 "push할까요?" 묻기 |
| Partial push | intended commit group이 끝나기 전 push |
| Blanket staging | `ALL` mode가 아니면 `git add .` 금지 |
| Unsafe history | 명시 요청 없는 amend, rebase, reset, raw `--force`, `--no-verify` |
| Secrets | credentials, tokens, private keys, 무관한 사용자 변경 커밋 |

</forbidden>

<examples>

## Simple fast commit and push

```text
/git-maker
```

Result: fast inspect → session changes grouping → 각 그룹 commit → inspected repo auto-push.

## Commit all and push

```text
/git-maker ALL
```

Result: 모든 미커밋 파일을 그룹핑, 커밋, 푸시한다. 파일을 건너뛰지 않는다.

## Commit and force push a feature branch

```text
/git-maker --force
```

Result: 정상 commit 후 `--force-with-lease` push; `main`/`master`에서는 차단.

## Commit-only request

```text
commit these changes
```

Result: 이 스킬을 사용하지 않고 `git-commit`으로 라우팅한다.

</examples>
