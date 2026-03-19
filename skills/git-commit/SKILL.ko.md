---
name: git-commit
description: '현재 저장소 상태를 기준으로 Conventional Commit 하나를 생성합니다. staged/unstaged 변경을 확인하고, 하나의 논리적 변경 집합을 선택한 뒤, 규격에 맞는 메시지를 만들고, 모호하거나 위험한 조건에서는 멈춥니다.'
license: MIT
allowed-tools: Bash
compatibility: `skills/git-commit/scripts` 아래 Bash 스크립트를 필요로 합니다.
---

# Git Commit 스킬

<scripts>

## 사용 가능한 스크립트

| Script | Purpose |
|------|------|
| `scripts/repo-discover.sh [start_dir]` | 현재 저장소인지, 하위 저장소들인지 구조를 판별 |
| `scripts/repo-status.sh [repo]` | 브랜치, 상태, staged 요약, unstaged 요약 출력 |
| `scripts/git-commit.sh [--repo path] "msg" [files...]` | 하나의 저장소에서 staged 또는 선택 파일 커밋 |
| `scripts/git-push.sh [--repo path] [--force]` | 하나의 저장소에서 현재 브랜치를 안전하게 push |

</scripts>

<objective>

- 현재 저장소 상태를 기준으로 Conventional Commit 1개를 생성한다.
- 모든 판단은 실제 git 상태와 diff 출력에 근거해 수행한다.
- 변경 집합이 모호하거나 섞여 있거나 위험하면 추측하지 말고 멈춘다.

</objective>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "commit these changes" | yes |
| "make a git commit" | yes |
| "/git-commit" | yes |
| push/rebase/reset만 요청하고 커밋 생성은 요청하지 않음 | no |

</trigger_conditions>

<argument_validation>

ARGUMENT가 없으면:

- 현재 세션에서 작업한 파일, 저장소, 논리적 변경 단위를 기본 후보로 잡는다.
- 스테이징이나 커밋 전에 그 후보를 실제 `git status` 와 `git diff` 출력으로 검증한다.
- 현재 세션 작업이 이미 모두 커밋되어 있으면, 아직 커밋되지 않은 나머지 변경을 다음 후보로 사용할 수 있다.
- 현재 세션 안에 관련 없는 변경 묶음이 여러 개면, 어떤 커밋을 만들지 명확하지 않을 때 멈춘다.

ARGUMENT가 있으면:

- ARGUMENT를 기본 커밋 대상 또는 필터로 취급한다.
- 저장소 탐색, 파일 선택, 스테이징, 커밋 메시지 생성을 모두 ARGUMENT 기준으로 좁힌다.
- ARGUMENT가 실제 저장소 상태와 맞지 않거나 여전히 관련 없는 여러 변경을 포함하면 멈춘다.

</argument_validation>

<scope_assumptions>

- 현재 작업 디렉터리에서 시작한다. 현재 위치가 git 저장소가 아니면, 진행 전에 하위 디렉터리들에 git 저장소가 있는지 먼저 확인한다.
- 커밋까지만 수행한다. 사용자가 명시적으로 요청하지 않으면 push, amend, rebase, history rewrite는 하지 않는다.
- 커밋이 성공하면 `git push` 할지 반드시 묻는다. Codex에서는 평문 질문으로 처리하고, OpenCode에서는 가능하면 런타임의 기본 승인 프롬프트를 우선 사용한다.
- Bash 명령만 사용한다.

</scope_assumptions>

<required>

| Category | Rule |
|------|------|
| Inspect first | 스테이징이나 커밋 전에 반드시 `git status --short --branch`를 먼저 실행한다. |
| Argument mode | 저장소 탐색과 스테이징 전에 세션 기본 모드인지, 명시적 ARGUMENT 모드인지 먼저 결정한다. |
| Repository discovery | 현재 작업 디렉터리가 git 저장소인지 먼저 판별한다. 아니라면 `git add`나 `git commit` 전에 하위 디렉터리의 저장소 목록을 먼저 만든다. |
| Diff source | staged 변경이 있으면 staged 집합을 기본 커밋 후보로 보고 `git diff --staged`를 확인한다. staged 변경이 없으면 `git diff`를 확인한다. |
| Repository boundary | 현재 디렉터리 아래에 여러 git 저장소가 발견되면, 각 저장소 안에서 `git status`, `git add`, `git commit`을 각각 따로 실행한다. 여러 저장소를 하나의 커밋 단위로 다루지 않는다. |
| Logical scope | 하나의 논리적 변경만 커밋한다. 저장소 안에 관련 없는 변경이 섞여 있으면 분리하거나 멈춰서 확인한다. |
| Staging discipline | 선택한 논리적 변경에 필요한 파일만 스테이징한다. 기본값으로 전체 스테이징하지 않는다. |
| Type selection | Conventional Commit type은 실제 변경의 중심 성격으로 고른다. 파일명만 보고 결정하지 않는다. |
| Scope selection | 하나의 모듈, 패키지, 기능 영역, 서브시스템이 명확할 때만 scope를 붙인다. 여러 영역에 걸치거나 애매한 이름이면 scope를 생략한다. |
| Subject line | 명령형, 현재형을 사용하고, 콜론 뒤는 소문자로 시작하며, subject는 72자 이내로 유지한다. |
| Body/footer | subject만으로 중요한 맥락이 부족할 때만 body를 추가한다. footer는 검증된 이슈 참조, breaking change, 사용자가 명시적으로 요청한 메타데이터에만 사용한다. |
| Push confirmation | `git add` 와 `git commit` 이 성공하면 `git push` 를 실행할지 반드시 확인한다. Codex에서는 평문으로 묻고, OpenCode에서는 가능하면 ask 스타일의 기본 승인 프롬프트를 우선 사용한다. 해당 프롬프트를 쓸 수 없으면 평문으로 fallback 한다. |
| Safety | secret, credential, 관련 없는 사용자 변경은 절대 커밋하지 않는다. 사용자가 명시적으로 요청하지 않으면 `--no-verify`, force 계열 옵션, 파괴적 git 명령은 사용하지 않는다. |
| Failure handling | hook이 실패하면 에러를 확인한다. 현재 변경 집합이 직접 원인이고 안전하게 고칠 수 있을 때만 수정 후 재시도한다. 그 외에는 멈추고 blocker를 보고한다. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| Staging | 관련 없는 변경이 섞여 있는데 `git add .` 같은 전체 스테이징 사용 |
| Argument handling | 명시적 ARGUMENT를 무시하고 더 넓은 변경 집합을 커밋하는 것 |
| Repository boundary | 저장소가 아닌 루트에서 `git add`나 `git commit`을 실행하면서 하위 저장소까지 같이 처리된다고 가정하는 것 |
| Push | 명시적 확인 없이 커밋 직후 `git push` 를 자동 실행하는 것 |
| Hooks | 사용자가 명시적으로 요청하지 않았는데 `--no-verify` 사용 |
| History rewrite | 명시적 요청 없이 amend, rebase, reset, force push, 기타 이력 수정 명령 사용 |
| Secrets | `.env`, credential, private key, token 커밋 |
| Guessing | diff 근거 없이 scope, footer, 변경 묶음을 임의로 만드는 것 |

</forbidden>

<decision_tables>

## ARGUMENT 모드

| Input state | Action |
|------|------|
| ARGUMENT 없음 | 현재 세션에서 수정한 파일과 저장소를 시작점으로 잡고, git 상태로 확인한 뒤 커밋 후보를 선택한다 |
| ARGUMENT 없음, 그리고 현재 세션 작업이 이미 커밋됨 | 아직 커밋되지 않은 변경이 남아 있으면, 그 나머지 변경을 다음 후보로 사용할 수 있다 |
| ARGUMENT 있음, 그리고 하나의 논리적 변경과 일치함 | ARGUMENT를 저장소 탐색, 스테이징, 메시지 생성의 기본 필터로 사용한다 |
| ARGUMENT가 있지만 git 상태와 충돌함 | 멈추고 불일치를 보고한다 |
| ARGUMENT가 있지만 관련 없는 여러 변경을 함께 가리킴 | 더 좁은 대상으로 다시 지정하도록 멈춘다 |

## 저장소 탐색

| Observed layout | Action |
|------|------|
| 현재 작업 디렉터리가 git 저장소임 | 현재 저장소에서 일반 커밋 워크플로우를 수행한다 |
| 현재 작업 디렉터리는 git 저장소가 아니지만, 하위 디렉터리에 하나 이상의 저장소가 있음 | 저장소 목록을 만들고, 변경이 있는 각 저장소 안에서 전체 커밋 워크플로우를 각각 수행한다 |
| 현재 작업 디렉터리도 git 저장소가 아니고, 하위 저장소도 없음 | git 저장소를 찾지 못했다고 보고하고 멈춘다 |

## 변경 집합 선택

| Repository state | Action |
|------|------|
| staged 변경만 있음 | staged 집합을 그대로 커밋한다. |
| staged + unstaged 변경이 있고, 같은 논리적 변경임 | 빠진 파일만 의도적으로 추가 스테이징한 뒤 전체 집합을 커밋한다. |
| staged + unstaged 변경이 있지만 관련 없는 변경이 섞여 있음 | 기본값은 staged 집합만 커밋한다. 의도한 커밋 대상을 판단할 수 없으면 멈춘다. |
| staged 변경 없음, 논리적 변경이 하나로 명확함 | 관련 파일만 스테이징한 뒤 커밋한다. |
| staged 변경 없음, 관련 없는 변경이 여러 개임 | 추측하지 않는다. 어떻게 나눌지 확인하거나 한 그룹만 명시적으로 스테이징한다. |
| 커밋할 diff 자체가 없음 | 멈추고 커밋할 내용이 없다고 보고한다. |

## 타입 선택

| Observed dominant change | Type |
|------|------|
| 사용자 기능 추가 | `feat` |
| 잘못된 동작 수정 | `fix` |
| 문서만 변경 | `docs` |
| 동작 변화 없는 포맷/스타일 수정 | `style` |
| 기능 추가나 버그 수정이 아닌 내부 구조 변경 | `refactor` |
| 성능 개선 | `perf` |
| 테스트 추가 또는 수정 | `test` |
| 빌드 도구나 의존성 관리 변경 | `build` |
| CI 워크플로우나 자동화 설정 변경 | `ci` |
| 저장소 유지보수, 잡무, 메타데이터 | `chore` |
| 이전 커밋 되돌리기 | `revert` |

## subject/body/footer 선택

| Condition | Output rule |
|------|------|
| 한 줄 subject만으로 변경이 충분히 설명됨 | subject만 사용 |
| 왜 바뀌었는지, 위험, 후속 맥락이 중요함 | 짧은 body 추가 |
| API, 스키마, 동작이 깨지는 변경 | `!` 와 `BREAKING CHANGE:` footer 사용 |
| 검증된 이슈/티켓 참조가 있음 | `Refs:` 또는 `Closes:` footer 추가 |
| 사용자가 co-author를 명시적으로 요청함 | 요청한 형식 그대로 `Co-authored-by:` footer 추가 |

</decision_tables>

<workflow>

## Phase 1. 저장소 상태 확인

먼저 ARGUMENT 모드를 결정한다.

- ARGUMENT 없음: 현재 세션의 작업 내역에서 초기 후보를 만들고, 이후 git 상태로 검증한다.
- ARGUMENT 없음 fallback: 그 세션 후보가 이미 모두 커밋되어 있으면, 아직 커밋되지 않은 나머지 변경을 다시 확인해서 다음 후보로 사용할 수 있다.
- ARGUMENT 있음: ARGUMENT에서 초기 후보를 만들고, 이후 git 상태로 검증한다.

```bash
scripts/repo-discover.sh
```

그 다음 저장소 구조에 따라 분기한다.

1. `git rev-parse --show-toplevel` 이 성공하면 현재 저장소를 확인한다.

```bash
scripts/repo-status.sh
```

2. 현재 디렉터리가 저장소가 아니지만 하위 저장소가 있으면, 각 저장소를 독립적으로 확인한다.

```bash
scripts/repo-status.sh path/to/repo
```

저장소가 아닌 루트에서 한 번의 `git add`나 `git commit`으로 여러 하위 저장소를 같이 처리하지 않는다.

## Phase 2. 하나의 논리적 변경 선택 및 준비

필요할 때만 타겟팅된 스테이징 명령을 사용한다. ARGUMENT가 없으면 현재 세션과 일치해야 하고, ARGUMENT가 있으면 그 인자와 일치해야 한다.

```bash
git add path/to/file1 path/to/file2
git add -p
git restore --staged path/to/file
```

다음 경우에는 멈춘다.
- 커밋 후보에 secret 또는 credential 파일이 포함됨
- 관련 없는 변경을 자신 있게 분리할 수 없음
- 사용자의 의도와 현재 staged 상태가 충돌함
- ARGUMENT가 실제 수정 파일 또는 저장소와 충돌함
- 여러 하위 저장소에 변경이 있는데 커밋 분리 기준이 명확하지 않음

## Phase 3. 커밋 메시지 생성

다음 순서로 구성한다.
1. `type`
2. optional `scope`
3. subject
4. optional body
5. optional footer

메시지 형식:

```text
<type>[optional scope]: <subject>

[optional body]

[optional footer]
```

## Phase 4. 커밋 실행

subject만 있는 경우:

```bash
scripts/git-commit.sh "<type>[scope]: <subject>"
scripts/git-commit.sh --repo path/to/repo "<type>[scope]: <subject>"
```

body 또는 footer가 있으면:

```bash
scripts/git-commit.sh "$(cat <<'EOF'
<type>[scope]: <subject>

<optional body>

<optional footer>
EOF
)"
scripts/git-commit.sh --repo path/to/repo "$(cat <<'EOF'
<type>[scope]: <subject>

<optional body>

<optional footer>
EOF
)"
```

여러 하위 저장소가 범위에 들어가면, Phase 2부터 Phase 4까지를 각 저장소 안에서 각각 반복한다.

## Phase 5. push 여부 확인

커밋이 성공하면 `git push` 실행 여부를 명시적으로 확인한다.

- Codex: `Commit created. Run git push?` 같은 평문 질문으로 확인한다
- OpenCode: 일반적인 Y/N를 가정하지 말고, 가능하면 런타임의 기본 승인 프롬프트를 사용한다
- 다른 상호작용형 런타임: 기본 확인 UI가 있으면 그걸 써도 되지만, push 전 명시적 확인은 여전히 필요하다

## Phase 6. 커밋 실패 또는 push 후속 처리

| Failure case | Response |
|------|------|
| 현재 변경으로 인해 hook 또는 lint가 실패함 | 문제를 고치고, 영향받은 파일을 다시 스테이징한 뒤 새 커밋 시도를 한다 |
| 현재 변경과 무관한 hook 실패 | 멈추고 blocker를 보고한다 |
| 스테이징 정리 후 빈 커밋이 됨 | 멈추고 남은 커밋 대상이 없다고 보고한다 |
| merge conflict 또는 index lock 상태 | 멈추고 저장소 상태를 보고한다 |
| 사용자가 push를 거절함 | 성공한 커밋만 보고하고 종료한다 |
| 사용자가 push를 승인함 | 해당 저장소에서 `scripts/git-push.sh` 를 실행하고 결과를 보고한다 |

</workflow>

<examples>

## 좋은 subject 예시

- `feat(auth): add passkey login flow`
- `fix(cache): avoid stale project reads`
- `docs(cli): document release prerequisites`
- `refactor(worker): split mailbox parsing logic`

## 나쁜 subject 예시

- `updated stuff`
- `Fix bug in the API module`
- `feat: Added New Feature`
- `chore(repo): miscellaneous changes`

## 좋은 멀티라인 커밋 예시

```bash
git commit -m "$(cat <<'EOF'
feat(api): add team membership filter

Limit list responses to memberships visible to the active user.

Refs: #482
EOF
)"
```

## 좋은 무인자 처리 예시

```text
/git-commit
```

결과:
- 현재 세션에서 작업한 내용을 먼저 확인한다
- git 상태로 일치하는 저장소와 파일을 검증한다
- 그 세션의 논리적 변경 하나만 커밋한다

## 좋은 무인자 fallback 처리 예시

```text
/git-commit
```

결과:
- 현재 세션 작업이 이미 커밋되었는지 확인한다
- 아직 커밋되지 않은 나머지 변경을 다시 확인한다
- 그 나머지 중 논리적 변경 하나를 다음 커밋 후보로 사용할 수 있다

## 좋은 명시적 ARGUMENT 처리 예시

```text
/git-commit packages/api session validation fix
```

결과:
- `packages/api session validation fix` 를 기본 대상으로 사용한다
- 일치하는 저장소와 파일로 저장소 탐색과 스테이징 범위를 좁힌다
- 그 대상 기준으로 커밋 메시지를 만든다

## 좋은 커밋 후 push 확인 예시

```text
Commit created. Run git push?
```

## 좋은 OpenCode push 확인 예시

- 가능하면 OpenCode의 기본 ask 승인 프롬프트를 사용한다
- 현재 연동에서 그 프롬프트를 쓸 수 없으면 push 전에 평문으로 다시 묻는다

## 좋은 다중 저장소 처리 예시

```bash
scripts/git-commit.sh --repo packages/web "fix(web): handle empty session" src/auth.ts
scripts/git-commit.sh --repo packages/api "fix(api): validate session payload" src/routes/session.ts
```

## 나쁜 다중 저장소 처리 예시

```bash
git add packages/web/src/auth.ts packages/api/src/routes/session.ts
git commit -m "fix: update web and api"
```

</examples>

<validation>

- 스테이징이나 커밋 전에 저장소 구조를 먼저 확인했는지 점검한다.
- 저장소 탐색 전에 ARGUMENT 모드를 먼저 결정했는지 점검한다.
- 하위 저장소가 있으면 저장소별로 각각 처리했는지 점검한다.
- ARGUMENT가 없을 때는 현재 세션과, ARGUMENT가 있을 때는 그 ARGUMENT와 최종 후보가 일치하는지 점검한다.
- ARGUMENT가 없을 때 현재 세션 작업이 이미 커밋되었다면, 남은 미커밋 변경으로 fallback 했는지 점검한다.
- 하위 저장소마다 독립된 `git add` 와 `git commit` 순서를 사용했는지 점검한다.
- 명시적 확인 전에는 `git push` 를 실행하지 않았는지 점검한다.
- 커밋된 파일이 하나의 논리적 변경인지 확인한다.
- 최종 메시지가 Conventional Commits 형식을 따르는지 확인한다.
- subject가 명령형/현재형이며 72자 이내인지 확인한다.
- secret 또는 credential 파일이 포함되지 않았는지 확인한다.
- 금지된 옵션이나 history rewrite 명령을 사용하지 않았는지 확인한다.
- hook 실패를 우회하지 않고 명시적으로 처리했는지 확인한다.

</validation>
