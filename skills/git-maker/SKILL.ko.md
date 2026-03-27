---
name: git-maker
description: '커밋과 푸시를 한 번에 실행합니다. git-commit 워크플로우(확인, 그룹핑, 스테이징, 커밋)를 완료한 뒤 자동으로 원격에 푸시합니다. 커밋과 푸시 사이에 확인 단계가 없습니다. 커밋과 푸시를 함께 하고 싶을 때 사용합니다.'
license: MIT
allowed-tools: Bash
compatibility: '`skills/git-maker/scripts` 아래 Bash 스크립트(git-commit, git-push 스킬의 심링크)를 필요로 합니다.'
---

# Git Maker 스킬

<scripts>

## 사용 가능한 스크립트

| Script | Purpose |
|------|------|
| `scripts/repo-discover.sh [start_dir]` | 현재 저장소인지, 하위 저장소들인지 구조를 판별 |
| `scripts/repo-status.sh [repo]` | 브랜치, 상태, staged 요약, unstaged 요약 출력 |
| `scripts/git-commit.sh [--repo path] "msg" [files...]` | 하나의 저장소에서 staged 또는 선택 파일 커밋 |
| `scripts/git-push.sh [--force]` | 저장소를 탐색하고, 미푸시 커밋을 확인하고, 안전하게 push |

</scripts>

<objective>

- 현재 저장소 상태를 기준으로 하나 이상의 Conventional Commit을 생성한 뒤, 자동으로 원격에 푸시한다.
- **git-commit 워크플로우를 먼저 실행하고, git-push 워크플로우를 이어서 실행**하는 순차 조합이다.
- 커밋과 푸시 사이에 확인 단계가 없다. 모든 커밋이 성공하면 자동으로 푸시한다.

</objective>

<trigger_conditions>

| User intent | Activate |
|------|------|
| "commit and push" | yes |
| "커밋하고 푸시해" | yes |
| "/git-maker" | yes |
| "커밋하고 올려줘" | yes |
| "커밋 푸시" | yes |
| "변경사항 저장하고 올려" | yes |
| 커밋만 요청하고 푸시는 요청하지 않음 | no — git-commit 사용 |
| 푸시만 요청하고 커밋은 요청하지 않음 | no — git-push 사용 |
| rebase, reset, 기타 이력 조작 요청 | no |

</trigger_conditions>

<argument_validation>

인자는 커밋 단계로 전달된다. 푸시 단계에는 `--force` 지정 시에만 인자가 전달된다.

ARGUMENT가 없으면:

- 현재 세션에서 작업한 파일, 저장소, 논리적 변경 단위를 기본 후보로 잡는다.
- 스테이징이나 커밋 전에 그 후보를 실제 `git status`와 `git diff` 출력으로 검증한다.
- 후보 집합에 논리적 변경 그룹이 여러 개 있으면, 각 그룹을 식별하고 순서대로 따로 커밋한다. 멈추거나 확인을 요청하지 않는다 — 모든 그룹을 순회한다.
- 현재 세션 작업이 이미 모두 커밋되어 있으면, 아직 커밋되지 않은 나머지 변경을 다음 후보로 사용하고 동일한 그룹핑 로직을 적용한다.

ARGUMENT가 "ALL" 또는 "all"이면:

- 현재 세션에서 작업했는지 여부와 관계없이, 저장소의 모든 미커밋 변경을 대상으로 잡는다.
- 관련 기능, 기능 영역, 목적을 기준으로 모든 변경을 논리적 변경 집합으로 분류한다.
- 각 그룹을 순서대로 따로 커밋한다. 멈추지 않고, 확인을 요청하지 않고, 어떤 파일도 건너뛰지 않는다.
- 모든 미커밋 파일이 정확히 하나의 커밋 그룹에 포함되어야 한다. 어떤 파일도 남겨두지 않는다.

ARGUMENT에 `--force`가 포함되면:

- `--force`를 분리하여 푸시 단계에 전달한다 (`--force-with-lease` 사용).
- 나머지 인자(있을 경우)는 커밋 단계에 전달한다.

ARGUMENT가 있으면 (ALL, --force 이외):

- ARGUMENT를 기본 커밋 대상 또는 필터로 취급한다.
- 저장소 탐색, 파일 선택, 스테이징, 커밋 메시지 생성을 모두 ARGUMENT 기준으로 좁힌다.
- 필터링된 집합에 논리적 그룹이 여러 개 있으면 각 그룹을 따로 커밋한다.
- ARGUMENT가 실제 저장소 상태와 맞지 않으면 멈춘다.

</argument_validation>

<scope_assumptions>

- 현재 작업 디렉터리에서 시작한다. 현재 위치가 git 저장소가 아니면, 진행 전에 하위 디렉터리들에 git 저장소가 있는지 먼저 확인한다.
- 커밋 AND 푸시. 두 단계 사이에 확인 단계가 없다.
- Bash 명령만 사용한다.

</scope_assumptions>

<workflow>

## Phase 1. 커밋 — git-commit 워크플로우 실행

**git-commit 워크플로우 전체**를 다음 순서로 실행한다:

### 1a. 저장소 상태 확인

ARGUMENT 모드를 결정한 뒤 저장소를 탐색한다.

```bash
scripts/repo-discover.sh
```

각 발견된 저장소에 대해:

```bash
scripts/repo-status.sh
scripts/repo-status.sh path/to/repo
```

### 1b. 논리적 변경 그룹 식별

전체 후보 집합을 분석하고 논리적 변경 그룹으로 분류한다.

그룹핑 휴리스틱 (순서대로 적용):
1. 같은 기능이나 수정을 구현하는 파일은 함께 묶는다.
2. 테스트 파일은 해당 구현 파일과 함께 묶는다.
3. 같은 기능에 관련된 설정/빌드 변경은 그 기능과 함께 묶는다.
4. 관련 없는 독립 변경은 각각 별도 그룹으로 만든다.

ALL 모드에서: 모든 미커밋 파일이 정확히 하나의 그룹에 포함되어야 한다. 어떤 파일도 남겨두지 않는다.

### 1c. 각 그룹을 스테이징하고 커밋 (반복)

각 논리적 그룹에 대해 반복한다:

**스테이징** — 현재 그룹의 파일만:

```bash
git add path/to/file1 path/to/file2
```

**커밋 메시지 생성** — Conventional Commits 형식:

```text
<type>[optional scope]: <subject>

[optional body]

[optional footer]
```

**커밋 실행:**

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
```

모든 그룹이 커밋될 때까지 계속한다.

### 커밋 규칙 (git-commit 스킬과 동일)

| Category | Rule |
|------|------|
| Inspect first | 스테이징이나 커밋 전에 반드시 `git status --short --branch`를 먼저 실행한다. |
| Diff source | staged 변경이 있으면 staged 집합을 기본 커밋 후보로 보고 `git diff --staged`를 확인한다. staged 변경이 없으면 `git diff`를 확인한다. |
| Repository boundary | 여러 git 저장소가 발견되면 각 저장소 안에서 `git status`, `git add`, `git commit`을 각각 따로 실행한다. |
| Logical scope | 각 커밋은 정확히 하나의 논리적 변경만 포함한다. |
| Staging discipline | 선택한 논리적 변경에 필요한 파일만 스테이징한다. |
| Type selection | Conventional Commit type은 실제 변경의 중심 성격으로 고른다. 파일명만 보고 결정하지 않는다. |
| Scope selection | 하나의 모듈, 패키지, 기능 영역, 서브시스템이 명확할 때만 scope를 붙인다. 여러 영역에 걸치거나 애매한 이름이면 scope를 생략한다. |
| Language | 커밋 subject와 body를 한국어로 작성한다. Conventional Commit의 `type`과 `scope`는 영어로 유지하되 (예: `feat(auth):`), 콜론 뒤 설명과 body 본문은 반드시 한국어로 쓴다. |
| Subject line | 명령형, 현재형을 사용하고, 콜론 뒤는 소문자로 시작하며, subject는 72자 이내로 유지한다. |
| Body/footer | subject만으로 중요한 맥락이 부족할 때만 body를 추가한다. footer는 검증된 이슈 참조, breaking change, 사용자가 명시적으로 요청한 메타데이터에만 사용한다. |
| Safety | secret, credential, 관련 없는 사용자 변경은 절대 커밋하지 않는다. 사용자가 명시적으로 요청하지 않으면 `--no-verify`, force 계열 옵션, 파괴적 git 명령은 사용하지 않는다. |
| Failure handling | hook이 실패하면 에러를 확인한다. 현재 변경 집합이 직접 원인이고 안전하게 고칠 수 있을 때만 수정 후 재시도한다. 그 외에는 멈추고 blocker를 보고한다. |

## Phase 2. 푸시 — 커밋 성공 후 자동 실행

**푸시 확인을 절대 묻지 않는다.** 모든 커밋이 성공하면 자동으로 푸시한다.

어떤 커밋이라도 실패하면, 멈추고 실패를 보고한다. 푸시하지 않는다.

```bash
scripts/git-push.sh
```

또는 force 옵션이 있으면:

```bash
scripts/git-push.sh --force
```

푸시 스크립트가 처리하는 것:
1. 저장소를 탐색한다 (현재 디렉터리 또는 하위).
2. 각 저장소에서 브랜치와 upstream 상태를 확인한다.
3. 미푸시 커밋이 없거나, detached HEAD이거나, 보호 브랜치 충돌이면 건너뛴다.
4. upstream 대비 앞선 커밋이 있는 저장소를 푸시한다.
5. 푸시된/건너뛴/실패한 저장소 요약을 보고한다.

### 푸시 실패 처리

| Failure case | Response |
|------|------|
| 모든 저장소에서 푸시 성공 | 성공을 보고하고 Phase 3으로 진행한다 |
| 하나 이상의 저장소에서 푸시 실패 | 실패한 저장소를 보고한다. 커밋은 유실되지 않는다 — 로컬 저장소에 그대로 남아 있다. 사용자에게 수동 `git push` 재시도 또는 원격 조사를 제안한다. |
| upstream이 없고 `-u origin <branch>`도 실패 | 실패를 보고한다. 커밋은 로컬에 남는다. |
| 푸시 중 네트워크 오류 | 오류를 보고한다. 커밋은 로컬에 남는다. 자동 재시도하지 않는다. |

## Phase 3. 결과 보고

통합 요약을 보고한다:
- 생성된 커밋 수와 각 메시지
- 푸시된 저장소 수
- 건너뛴 또는 실패한 푸시 대상

</workflow>

<required>

| Category | Rule |
|------|------|
| 커밋 우선 | 모든 커밋이 성공한 후에만 푸시를 시도한다. |
| 확인 없음 | 푸시 여부를 절대 묻지 않는다. 푸시는 자동이다. |
| Safety | main이나 master에 force push 하지 않는다. detached HEAD에서 push 하지 않는다. |
| Upstream | upstream이 설정되어 있지 않으면 `-u origin <branch>`로 트래킹을 설정한다. |
| git-commit 규칙 전체 | 커밋 단계에는 git-commit의 모든 required 규칙이 적용된다. |

</required>

<forbidden>

| Category | Avoid |
|------|------|
| 푸시 확인 | "push 할까요?" 같은 질문이나 푸시 승인 대기 |
| 부분 푸시 | 모든 커밋 그룹이 완료되기 전에 푸시 |
| git-commit 금지 항목 전체 | 커밋 단계에는 git-commit의 모든 forbidden 규칙이 적용된다 |
| 보호 브랜치 force push | main이나 master에 `--force` |
| History rewrite | 명시적 요청 없이 amend, rebase, reset, force push, 기타 이력 수정 명령 사용 |

</forbidden>

<decision_tables>

## 저장소 탐색

| Observed layout | Action |
|------|------|
| 현재 작업 디렉터리가 git 저장소임 | 현재 저장소에서 커밋-푸시 워크플로우를 수행한다 |
| 현재 작업 디렉터리는 git 저장소가 아니지만, 하위 디렉터리에 하나 이상의 저장소가 있음 | 저장소 목록을 만들고, 변경이 있는 각 저장소 안에서 전체 커밋 워크플로우를 각각 수행한 뒤, 각각 푸시한다 |
| 현재 작업 디렉터리도 git 저장소가 아니고, 하위 저장소도 없음 | git 저장소를 찾지 못했다고 보고하고 멈춘다 |

## ARGUMENT 모드

| Input state | Action |
|------|------|
| ARGUMENT 없음 | 세션 변경을 커밋(그룹별)하고 자동 푸시 |
| ARGUMENT가 "ALL" 또는 "all" | 모든 미커밋 변경을 커밋(그룹별)하고 자동 푸시 |
| ARGUMENT에 `--force` 포함 | --force를 분리하여 푸시 단계에 전달, 커밋은 정상 처리, --force-with-lease로 푸시 |
| ARGUMENT 있음 (기타) | 필터링된 변경을 커밋(그룹별)하고 자동 푸시 |
| ARGUMENT가 git 상태와 충돌 | 멈추고 불일치 보고 — 푸시하지 않음 |

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

</decision_tables>

<examples>

## 단순 커밋 후 푸시

```text
/git-maker
```

결과:
- 현재 세션 변경을 확인한다
- 그룹핑, 스테이징, 각 논리적 그룹별 커밋
- 자동으로 푸시한다 — 확인을 묻지 않음

## 전체 커밋 후 푸시

```text
/git-maker ALL
```

결과:
- 모든 미커밋 변경을 대상으로 잡는다
- 논리적 변경 집합으로 분류한다
- 각 그룹을 따로 커밋한다
- 자동으로 전부 푸시한다

## 커밋 후 force 푸시

```text
/git-maker --force
```

결과:
- 세션 변경을 정상 커밋한다
- `--force-with-lease`로 푸시한다 (main/master에서는 차단)

## 특정 대상 커밋 후 푸시

```text
/git-maker packages/api session validation fix
```

결과:
- ARGUMENT에 맞는 커밋 후보로 필터링한다
- 일치하는 변경을 커밋한다
- 자동으로 푸시한다

## 여러 논리적 그룹

```text
/git-maker
```

결과:
- 세션에서 auth 모듈 + 관련 없는 docs를 수정함
- 그룹 1: `feat(auth): passkey 로그인 플로우 추가` → 커밋
- 그룹 2: `docs(cli): 릴리스 사전 조건 문서화` → 커밋
- 두 커밋을 자동 푸시

## 다중 저장소 커밋 후 푸시

```text
/git-maker
```

결과 (현재 디렉터리는 저장소가 아니지만, 하위 저장소가 있음):
- `packages/web`과 `packages/api`를 별도 저장소로 탐색한다
- 각 저장소에서 독립적으로 커밋한다:
  ```bash
  scripts/git-commit.sh --repo packages/web "fix(web): 빈 세션 처리" src/auth.ts
  scripts/git-commit.sh --repo packages/api "fix(api): 세션 페이로드 검증" src/routes/session.ts
  ```
- 각 저장소를 푸시한다:
  ```bash
  scripts/git-push.sh
  ```
- 보고: 2개 커밋 생성, 2개 저장소 푸시됨

## 커밋 실패 — 푸시 안 함

결과:
- 커밋 중 hook 실패
- blocker를 보고한다
- 푸시를 시도하지 않는다

</examples>

<validation>

- 커밋 단계에서 git-commit의 모든 검증 항목을 통과했는지 확인한다.
- 푸시 전에 확인 프롬프트가 없었는지 확인한다.
- 커밋이 하나라도 실패했을 때 푸시를 시도하지 않았는지 확인한다.
- main/master에 force push를 사용하지 않았는지 확인한다.
- 통합 요약(커밋 + 푸시)이 보고되었는지 확인한다.

</validation>
