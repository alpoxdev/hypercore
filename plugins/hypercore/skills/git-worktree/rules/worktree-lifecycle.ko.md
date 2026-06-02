# Worktree Lifecycle 규칙

`git-worktree` skill로 Git worktree를 operating할 때 이 규칙을 사용한다.

## 1. 저장소 discovery

대상 저장소의 어떤 descendant에서도 실행한다.

```bash
git rev-parse --show-toplevel
git rev-parse --git-common-dir
git worktree list --porcelain
```

Git repository 내부가 아니면 operation을 중단하고 repository path가 필요하다고 보고한다.

## 2. 작업 의도, naming, path

기본 root:

```text
<repo-root>/.hypercore/git-worktree/<folder_name>
```

Direct argument fast path:

- invocation이 `git-worktree <ARGUMENT>`이면 `<ARGUMENT>`를 create target으로 취급하고 어떤 worktree를 만들지 묻지 않는다.
- PR, issue, ref, explicit path를 명확히 나타내지 않는 한 argument를 branch/task label로 해석한다.
- Git operation에는 branch/ref text를 보존하고 `.hypercore/git-worktree/<folder_name>`의 folder label만 sanitize한다.
- unsafe, reserved, conflicting, unmappable argument에 대해서만 계속 질문한다.

Interaction language:

- Clarification question은 사용자 요청과 같은 언어로 묻는다.
- 한국어 사용자에게는 한국어로만 묻는다. English fallback text나 generic English operation menu를 보여주지 않는다.
- 묻기 전에 사용자 wording에서 operation을 추론한다. 추론이 실패하면 localized question 하나를 묻는다. 한국어 사용자에게는 생성, 목록, 열기/이동, 삭제, 정리, 복구, 잠금, 잠금 해제 중 어떤 worktree 작업을 원하는지 묻는다.
- 새 worktree의 work intent만 빠졌다면 operation이 아니라 work intent를 묻는다.

Worktree를 만들기 전에 거기서 무엇을 할지 확정한다.

- direct `git-worktree <ARGUMENT>` argument가 있으면 그것이 work intent다. work-intent question을 건너뛴다.
- 사용자가 이미 branch, PR, issue, task, concrete work item을 명명했다면 그 context를 사용한다.
- 사용자가 worktree 생성만 말했고 task가 불명확하면 생성 전에 정확히 하나의 concise localized question을 묻는다. 한국어 사용자에게는 이 worktree에서 어떤 작업을 할 예정인지 묻는다.
- 답변에서 `<folder_name>`을 도출한다. 사용자가 명시적으로 원하지 않는 한 random timestamp나 generic `worktree-1`을 사용하지 않는다.

Naming rules:

- 짧은 task label을 선호한다: `feature-auth`, `fix-login`, `review-pr-42`, `agent-docs-pass`.
- 실제 branch name은 folder name과 별도로 보존한다.
- explicit slug algorithm으로 folder name을 sanitize한다. task label을 lowercase로 만들고 `/`, whitespace, shell-sensitive character를 `-`로 바꾸며, 반복 separator를 collapse하고 leading/trailing separator를 trim한 뒤 `.`, `..`, `.git`, `main`, empty slug 같은 reserved label을 reject한다.
- sanitized slug가 너무 generic하면(`worktree`, `task`, `new-worktree`) folder 생성 전에 사용자 stated intent에서 concrete noun 하나를 추가한다.
- 너무 긴 label은 읽을 수 있는 길이로 제한하고 target path가 이미 있으면 numeric suffix를 추가한다.
- 사용자가 명시적으로 요청하지 않은 경우에만 repository 밖 path를 거부한다.
- 사용자가 명시적으로 요청하고 nesting risk를 이해하지 않는 한 existing linked worktree 안에 worktree를 만들지 않는다.

이 project의 요청 convention은 repository 아래에 worktree를 nest하므로 항상 root가 local에서 ignored되도록 보장한다.

```bash
exclude_file="$(git rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$exclude_file")"
grep -qxF ".hypercore/git-worktree/" "$exclude_file" 2>/dev/null || printf '\n.hypercore/git-worktree/\n' >> "$exclude_file"
```

사용자가 convention을 commit하라고 요청하지 않는 한 `.gitignore` 편집보다 local exclude를 선호한다.

## 3. Worktree 생성

### 현재 `HEAD`에서 새 branch

```bash
git worktree add -b <branch> <path> HEAD
```

### base branch에서 새 branch

```bash
git fetch --all --prune
git worktree add -b <branch> <path> <base-ref>
```

### 기존 local branch

```bash
git worktree add <path> <branch>
```

Git이 branch가 이미 다른 곳에서 checked out되었다고 보고하면 duplicate checkout을 force하지 말고 기존 worktree를 list하고 open한다.

### 기존 remote branch

```bash
git fetch --all --prune
git switch --track -c <branch> origin/<branch>
# or, from the main worktree:
git worktree add -b <branch> <path> origin/<branch>
```

사용자의 current working tree를 방해하지 않는 command를 선호한다. `git switch`가 current worktree를 바꿀 수 있다면 대신 `git worktree add -b ... origin/...` form을 사용한다.

### Detached review

```bash
git worktree add --detach <path> <commit-or-tag>
```

Detached worktree는 read-only inspection, bisect-like diagnostics, 또는 explicit throwaway review에만 사용한다.

생성 후 worktree가 존재하는지 검증하고 follow-up work의 active context로 만든다. "enter", "open", "switch", "go into it" 또는 같은 의미의 한국어 표현이 있는 create request는 새 path에서 follow-up command가 실행될 때까지 완료되지 않는다.

```bash
git -C <path> status --short --branch
# In a normal interactive shell:
cd <path> && pwd

# In persistent agent shells/sessions, actually run cd <path> there.
# In tool-only environments, run the next command with workdir=<path>, or use git -C <path>.
```

Persistent shell, tmux pane, CLI session에서 "worktree로 이동"은 active session에서 실제로 `cd <path>`를 실행하고 `pwd`로 검증한다는 뜻이다. subprocess의 `cd`가 지속되지 않는 agent environment에서는 이 task의 다음 및 이후 tool call에 `workdir=<path>`를 설정하거나 equivalent tool working-directory field를 사용한다. `cd <path>`를 출력만 했다면 active context가 이동했다고 주장하지 않는다. 사용한 move mechanism을 보고한다: persistent-session `cd <path>` 또는 tool `workdir=<path>`.

## 4. 이동, 열기, handoff

생성 후 active agent context를 folder로 전환한 다음 사용 가능한 handoff command를 하나 이상 제공한다.

```bash
cd <path>
pwd
code <path>
cursor <path>
tmux new-session -A -s <folder_name> -c <path>
```

AI-agent workflow에서는 task와 boundary를 명시적으로 hand off한다.

- branch name
- worktree path
- target files 또는 ownership boundary
- verification command
- merge/cleanup expectation

사용자가 요청했거나 현재 skill invocation이 그 action을 명확히 포함하지 않는 한 external editor 또는 agent command를 시작하지 않는다. Active agent command context를 새 worktree로 이동하는 것은 creation의 일부이며 추가 confirmation이 필요 없다.

## 5. 목록과 상태 dashboard

Git registry와 per-worktree status를 모두 사용한다.

```bash
git worktree list --porcelain
git worktree list --verbose
for p in $(git worktree list --porcelain | awk '/^worktree / {print substr($0, 10)}'); do
  printf '\n== %s ==\n' "$p"
  git -C "$p" status --short --branch
 done
```

다음을 보고한다.

- path
- branch 또는 detached commit
- clean/dirty state
- locked/prunable annotation
- recommended next action

## 6. 안전한 removal

제거 전에:

```bash
git -C <path> status --short --branch
git -C <path> log --oneline --decorate -5
```

사용자가 이미 linked worktree 안에 있으면서 path 없이 worktree delete/remove를 요청하면 current linked worktree를 target으로 추론한다. 밖으로 이동하기 전에 target path를 저장하고, main worktree는 거부한 뒤, 다른 safe worktree에서 remove한다.

```bash
target_path="$(git rev-parse --show-toplevel)"
git_dir="$(git rev-parse --git-dir)"
common_dir="$(git rev-parse --git-common-dir)"
main_path="$(git worktree list --porcelain | awk 'NR==1 && /^worktree / {print substr($0, 10)}')"

# If git-dir and common-dir resolve to the same directory, this is the main worktree; do not remove it.
# Also stop when Git cannot provide a distinct safe worktree to run removal from.
if [ "$(cd "$git_dir" && pwd -P)" = "$(cd "$common_dir" && pwd -P)" ] || [ -z "$main_path" ] || [ "$main_path" = "$target_path" ]; then
  echo "Refusing to remove this path as a linked worktree: $target_path" >&2
  git worktree list --porcelain >&2
  exit 1
fi

git -C "$target_path" status --short --branch
git -C "$target_path" log --oneline --decorate -5
cd "$main_path"
git worktree remove "$target_path"
```

Target worktree 안에서 `git worktree remove .` 또는 `rm -rf .`를 실행하지 않는다. `main_path`를 resolve할 수 없으면 추측하지 말고 target path와 `git worktree list --porcelain` output을 보고한 뒤 중단한다.

Safe removal path:

```bash
git worktree remove <path>
```

사용자가 명시적으로 요청했거나 변경사항이 disposable임을 이미 확인했을 때만 force를 사용한다. Dirty current-worktree deletion도 `--force` 전에 같은 explicit force/discard intent가 필요하다.

```bash
git worktree remove --force <path>
```

Branch deletion은 별도이며 explicit해야 한다.

```bash
git branch -d <branch>
# use -D only when explicitly requested and disposable
```

Main worktree는 절대 삭제하지 않는다. Main worktree 안에서 path 없는 "워크트리 삭제" 같은 요청이 오면 repository root를 disposable로 취급하지 말고 linked worktree path/name을 물어본다.

## 7. Prune, lock, unlock, repair

Prune은 dry run 이후에만 한다.

```bash
git worktree prune --dry-run
git worktree prune
```

Long-lived 또는 externally stored worktree는 lock한다.

```bash
git worktree lock --reason "<reason>" <path>
git worktree unlock <path>
```

Path를 수동으로 옮겼다면 recreate하기 전에 repair한다.

```bash
git worktree repair <path>
```

## 8. Merge-back handoff

Worktree의 task가 완료되면:

1. status가 clean이거나 의도적으로 staged/committed인지 검증한다.
2. 그 worktree에서 project의 test/build를 실행한다.
3. project의 일반 Git workflow에 따라 merge, rebase, 또는 PR open을 수행한다.
4. work가 merged, pushed, 또는 intentionally abandoned된 뒤에만 worktree를 remove한다.
5. Stale metadata는 먼저 dry run으로 prune한다.

## 9. 일반적인 hazard

- `.hypercore/git-worktree/` 아래 nested worktree는 local에서 ignored되어야 한다. 그렇지 않으면 main worktree가 noisy해진다.
- 같은 branch는 보통 동시에 두 worktree에서 checked out될 수 없다.
- Linked worktree는 Git object storage와 config를 공유하지만 working file은 독립적이다.
- Per-worktree dependency folder, port, database, generated artifact는 여전히 충돌할 수 있다. 필요하면 별도 env file 또는 port를 사용한다.
- 한 Git executable이 만든 worktree를 다른 executable이 사용할 때 Windows/WSL path portability가 깨질 수 있다.
