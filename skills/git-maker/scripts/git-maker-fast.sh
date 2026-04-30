#!/usr/bin/env bash
# git-maker-fast.sh - fast inspect/push helper for git-maker
# Usage:
#   git-maker-fast.sh inspect [start_dir] [--jobs N]
#   git-maker-fast.sh push [--force] [repo...]
#
# Inspect gathers repository state with pruned discovery and parallel per-repo status.
# Push accepts explicit repo paths so git-maker can reuse inspect results instead of rediscovering.

set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  git-maker-fast.sh inspect [start_dir] [--jobs N]
  git-maker-fast.sh push [--force] [repo...]

Environment:
  GIT_MAKER_JOBS                 default parallel inspect jobs (default: 4)
  GIT_MAKER_PUSH_TIMEOUT_SECONDS accepted for compatibility; no portable timeout is enforced
USAGE
}

abs_path() {
  local path=$1
  (cd "$path" && pwd -P)
}

is_git_repo() {
  git -C "$1" rev-parse --git-dir >/dev/null 2>&1
}

discover_repos() {
  local start_dir=${1:-.}

  if [[ ! -d "$start_dir" ]]; then
    echo "Error: Directory not found: $start_dir" >&2
    return 1
  fi

  if root="$(git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null)"; then
    printf '%s\n' "$root"
    return 0
  fi

  # Prune heavy/generated directories before looking for descendant repositories.
  find "$start_dir" \
    \( -name .git -type d -prune -print \) -o \
    \( -type d \( \
      -name node_modules -o -name dist -o -name build -o -name .next -o \
      -name .turbo -o -name .cache -o -name coverage -o -name vendor \
    \) -prune \) -o \
    \( -name .git -type f -print \) 2>/dev/null |
    sort |
    while IFS= read -r git_path; do
      [[ -z "$git_path" ]] && continue
      abs_path "$(dirname "$git_path")"
    done
}

status_one_repo() {
  local repo=$1
  local root branch upstream ahead staged unstaged untracked

  if ! is_git_repo "$repo"; then
    printf 'repo|%s\nerror|not a git repository\n' "$repo"
    return 0
  fi

  root="$(git -C "$repo" rev-parse --show-toplevel)"
  branch="$(git -C "$repo" branch --show-current 2>/dev/null || true)"
  upstream="$(git -C "$repo" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
  ahead=0
  if [[ -n "$upstream" ]]; then
    ahead="$(git -C "$repo" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)"
  fi

  staged="$(git -C "$repo" diff --cached --name-only)"
  unstaged="$(git -C "$repo" diff --name-only)"
  untracked="$(git -C "$repo" ls-files --others --exclude-standard)"

  printf 'repo|%s\n' "$root"
  printf 'branch|%s\n' "${branch:-DETACHED}"
  printf 'upstream|%s\n' "${upstream:-none}"
  printf 'ahead|%s\n' "$ahead"
  printf 'status|begin\n'
  git -C "$repo" status --short --branch
  printf 'status|end\n'
  printf 'files|begin\n'
  if [[ -n "$staged" ]]; then
    while IFS= read -r file; do [[ -n "$file" ]] && printf 'staged|%s\n' "$file"; done <<< "$staged"
  fi
  if [[ -n "$unstaged" ]]; then
    while IFS= read -r file; do [[ -n "$file" ]] && printf 'unstaged|%s\n' "$file"; done <<< "$unstaged"
  fi
  if [[ -n "$untracked" ]]; then
    while IFS= read -r file; do [[ -n "$file" ]] && printf 'untracked|%s\n' "$file"; done <<< "$untracked"
  fi
  printf 'files|end\n'
}

inspect_cmd() {
  local start_dir=. jobs=${GIT_MAKER_JOBS:-4}

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --jobs)
        jobs=${2:-}
        [[ -n "$jobs" ]] || { echo "Error: --jobs requires a value" >&2; return 1; }
        shift 2
        ;;
      --jobs=*)
        jobs=${1#--jobs=}
        shift
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        start_dir=$1
        shift
        ;;
    esac
  done

  [[ "$jobs" =~ ^[0-9]+$ ]] && [[ "$jobs" -gt 0 ]] || jobs=4

  repos=()
  while IFS= read -r repo; do
    [[ -n "$repo" ]] && repos+=("$repo")
  done < <(discover_repos "$start_dir")
  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "Error: No git repository found from $start_dir" >&2
    return 1
  fi

  printf 'repos|begin\n'
  printf '%s\n' "${repos[@]}"
  printf 'repos|end\n'

  if [[ ${#repos[@]} -eq 1 ]]; then
    printf 'repo-status|begin\n'
    status_one_repo "${repos[0]}"
    printf 'repo-status|end\n'
    return 0
  fi

  printf '%s\0' "${repos[@]}" |
    xargs -0 -n 1 -P "$jobs" bash -c '
      script=$1
      repo=$2
      printf "repo-status|begin\n"
      "$script" _status_one "$repo"
      printf "repo-status|end\n"
    ' bash "$0"
}

push_one_repo() {
  local repo=$1 force=$2 label branch upstream ahead
  label="$(abs_path "$repo")"

  branch="$(git -C "$repo" branch --show-current 2>/dev/null || true)"
  if [[ -z "$branch" ]]; then
    echo "[$label] Skipped: detached HEAD" >&2
    return 2
  fi

  if [[ "$force" == true ]] && { [[ "$branch" == main ]] || [[ "$branch" == master ]]; }; then
    echo "[$label] Skipped: cannot force push to protected branch $branch" >&2
    return 2
  fi

  upstream="$(git -C "$repo" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
  if [[ -n "$upstream" ]]; then
    ahead="$(git -C "$repo" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)"
    if [[ "$ahead" -eq 0 ]]; then
      echo "[$label] Already up to date on $branch"
      return 2
    fi
    echo "[$label] Pushing $ahead commit(s) on $branch..."
    if [[ "$force" == true ]]; then
      GIT_TERMINAL_PROMPT=0 git -C "$repo" push --force-with-lease
    else
      GIT_TERMINAL_PROMPT=0 git -C "$repo" push
    fi
  else
    echo "[$label] No upstream. Pushing $branch to origin..."
    if [[ "$force" == true ]]; then
      GIT_TERMINAL_PROMPT=0 git -C "$repo" push -u origin "$branch" --force-with-lease
    else
      GIT_TERMINAL_PROMPT=0 git -C "$repo" push -u origin "$branch"
    fi
  fi
}

push_cmd() {
  local force=false pushed=0 skipped=0 errors=0 rc repo
  local -a repos=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        force=true
        shift
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        repos+=("$1")
        shift
        ;;
    esac
  done

  if [[ ${#repos[@]} -eq 0 ]]; then
    repos=()
    while IFS= read -r repo; do
      [[ -n "$repo" ]] && repos+=("$repo")
    done < <(discover_repos .)
  fi

  if [[ ${#repos[@]} -eq 0 ]]; then
    echo "Error: No git repository found" >&2
    return 1
  fi

  for repo in "${repos[@]}"; do
    if ! is_git_repo "$repo"; then
      echo "[$repo] Failed: not a git repository" >&2
      errors=$((errors + 1))
      continue
    fi
    set +e
    push_one_repo "$repo" "$force"
    rc=$?
    set -e
    case "$rc" in
      0) pushed=$((pushed + 1)) ;;
      2) skipped=$((skipped + 1)) ;;
      *) errors=$((errors + 1)) ;;
    esac
  done

  echo ""
  echo "Done: $pushed pushed, $skipped skipped, $errors failed"
  [[ "$errors" -eq 0 ]]
}

cmd=${1:-}
case "$cmd" in
  inspect)
    shift
    inspect_cmd "$@"
    ;;
  push)
    shift
    push_cmd "$@"
    ;;
  _status_one)
    shift
    status_one_repo "$1"
    ;;
  -h|--help|"")
    usage
    [[ -n "$cmd" ]]
    ;;
  *)
    echo "Error: unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
