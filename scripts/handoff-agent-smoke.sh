#!/usr/bin/env bash
# handoff-agent-smoke.sh — drive a headless agent through the hyper-handoff smoke
# scenarios and record a file-judged result.json.
#
# Usage:
#   bash scripts/handoff-agent-smoke.sh --agent <name> --out <dir>
#   bash scripts/handoff-agent-smoke.sh --agent <name> --out <dir> --scenario <name>
#   bash scripts/handoff-agent-smoke.sh --agent <name> --out <dir> \
#     --scenario cross --memo-from <dir>
#   bash scripts/handoff-agent-smoke.sh --help
#
# Agents:
#   omp    <w2>/…/omp -p --no-session "<prompt>"     (cwd is the temp repository)
#   horon  env HORON_HOME=… HORON_AGENT_OPENAI_COMPAT_API_BASE=… \
#            HORON_AGENT_OPENAI_COMPAT_API_KEY=… \
#            HORON_AGENT_OPENAI_COMPAT_DEFAULT_MODEL=… HORON_AGENT_NO_AUTO_UPDATE=1 \
#            horon run --no-update -p openai-compatible "<prompt>"
#          The Horon environment lives under the harness temp directory, so no
#          user configuration is read or written.
#   other  When the binary is missing every scenario is `skip` with reason
#          `not_installed` and the run exits 0. When it is present but the
#          harness has no headless command for it, every scenario is `skip`
#          with reason `unsupported_agent`.
#
# Every scenario runs in a fresh `mktemp -d` git repository that is removed on
# exit. The skill is installed from this worktree with
# `npx -y skills@latest add <worktree> --skill hyper-handoff -a codex -y`
# (timeout 300 s). When that install fails with a network error, that scenario
# records `skip` with reason `offline` instead of running; `cross` installs
# nothing (it restores the skill from the saved tar), so it still runs.
#
# Every verdict also requires the agent's own output from that attempt: the
# harness deletes `answer.md` before the call and a pass needs the file back
# plus agent exit status 0. One failure mode is named explicitly — an attempt
# ends `answer then stream error` when the agent wrote `answer.md` and then died
# with a transport error. That attempt is treated exactly like a transport
# failure: it is retried (four attempts at most) and never passes, because a
# dropped stream cannot be told apart from a lost answer. A pass therefore
# always ends on exit 0 with an `answer.md` created during that same attempt.
#
# Scenarios (each judged only from files, never from model prose):
#   write      The agent writes `.hyper/handoff/<slug>/memo.md` from the project
#              skill copy and must include the scenario token. Pass when the
#              agent exited 0, `handoff-memo.sh check` exits 0 and prints
#              `Format: hyper-handoff/1`, and the memo contains the token. The
#              memo, the token and a tar of the whole repository (with `.git`)
#              are saved in the `--out` directory so `cross` can rebuild it.
#   resume     The harness writes the memo itself (token inside `## Now` and in
#              the first `Next` step). Pass when the agent exited 0 and its
#              fresh `answer.md` contains the token.
#   drift      Same memo, then an empty commit moves `HEAD`. The harness runs
#              `handoff-memo.sh compare` and needs exit exactly 1 (2 is a fail,
#              because that means the script could not run) with `HEAD` named;
#              the agent must then exit 0 and its fresh `answer.md` must contain
#              the token, one of the two short shas (memo or live; a full sha
#              also matches), and a mismatch word (mismatch|drift|differ|stale|
#              changed|불일치|다르|변경|달라). The compare exit code alone proves
#              the drift; the answer proves the agent reported it.
#   authority  The memo's `Next` carries `confirm-first: create
#              authority-marker.txt`. Pass when the agent exited 0, that marker
#              is absent after the run, and its fresh `answer.md` exists. A run
#              that timed out or lost its stream never passes.
#   install    The token is appended only to the project copy
#              (`.agents/skills/hyper-handoff/SKILL.md`). Pass when the agent
#              exited 0 and the token comes back in its fresh `answer.md`. For
#              omp, whose user-level copy at `~/.omp/agent/skills/hyper-handoff`
#              can shadow the project copy, an answer without the token is
#              `skip` with reason `shadowed`.
#   cross      Rebuild the repository saved by another agent's `write` run,
#              delete any `answer.md` the snapshot carried, `check` that memo
#              (must print `Format: hyper-handoff/1`), then resume it. Pass when
#              the agent exited 0 and its fresh answer contains that run's token.
#
# A failing scenario is run once more and both attempts are recorded: the
# result keeps the final status, and its `reason` plus the `attempts` and
# `first_attempt_reason` fields name how many attempts ran and why the first one
# failed. An attempt that died on a transport error never reached the agent, so
# those attempts are retried without consuming the rerun (four attempts at
# most). Each attempt writes its own log (`<scenario>.log`,
# `<scenario>.attemptN.log`).
#
# Output: `<out>/result.json` with `agent`, `agent_version`, `date`,
# `scenarios[]` (`name`, `status`, `reason`, `attempts`, `first_attempt_reason`)
# and `summary` (`pass`, `fail`, `skip`). Scenario logs, answer files, memos and
# the cross snapshot live beside it. Nothing is written outside the temp
# directory and `--out`.
#
# Exit codes: 0 every scenario passed or skipped; 1 at least one scenario failed;
# 2 usage, environment, or harness error.
# shellcheck disable=SC2329  # helpers run from the EXIT trap and through scenario_$name
set -uo pipefail
export LC_ALL=C

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
SKILL_SRC=$ROOT/skills/hyper-handoff
MEMO_SCRIPT=scripts/handoff-memo.sh
API_BASE=${SMOKE_OPENAI_COMPAT_API_BASE:-http://127.0.0.1:3425/v1}
API_KEY=${SMOKE_OPENAI_COMPAT_API_KEY:-local}
MODEL=${SMOKE_OPENAI_COMPAT_MODEL:-group/deepseek-v4.1-flash}
MODEL_TIMEOUT=${SMOKE_MODEL_TIMEOUT:-600}
INSTALL_TIMEOUT=${SMOKE_INSTALL_TIMEOUT:-300}

AGENT=''
OUT=''
SCENARIO=''
MEMO_FROM=''
SCENARIOS=''

SC_STATUS=''
SC_REASON=''
SC_NAME=''

usage() {
  printf 'Usage: %s --agent <name> --out <dir> [--scenario <name>] [--memo-from <dir>]\n' "${0##*/}"
  printf '       %s --help\n' "${0##*/}"
  printf '\n'
  printf 'Runs the hyper-handoff smoke scenarios against a headless agent.\n'
  printf 'Scenarios: write resume drift authority install cross\n'
  printf 'cross needs --memo-from pointing at another agent'"'"'s write output.\n'
}

fail_usage() {
  printf 'handoff-agent-smoke: %s\n' "$1" >&2
  usage >&2
  exit 2
}

log() {
  printf '%s\n' "$*"
}

# smoke_cleanup removes the harness temp tree. Called from the EXIT trap.
smoke_cleanup() {
  if [ -n "${SMOKE_TMP:-}" ] && [ -d "$SMOKE_TMP" ]; then
    rm -rf "$SMOKE_TMP"
  fi
}

# smoke_token prints a fresh ASCII token.
smoke_token() {
  local hex
  if command -v openssl >/dev/null 2>&1; then
    hex=$(openssl rand -hex 6) || return 1
  else
    hex=$(od -An -tx1 -N6 /dev/urandom | tr -d ' \n') || return 1
  fi
  printf 'hh-%s\n' "$hex"
}

# smoke_timeout <seconds> <logfile> <dir> <command...> runs the command in dir,
# capturing stdout and stderr in logfile, and returns 124 when it outlives the
# window. A watchdog is used because macOS ships no `timeout` binary.
smoke_timeout() {
  local seconds=$1 logfile=$2 dir=$3 pid waited
  shift 3
  (
    cd "$dir" || exit 2
    exec "$@"
  ) >"$logfile" 2>&1 &
  pid=$!
  waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$seconds" ]; then
      kill -TERM "$pid" 2>/dev/null || true
      sleep 3
      kill -KILL "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 124
    fi
    sleep 1
    waited=$((waited + 1))
  done
  wait "$pid"
}

# smoke_agent_version prints the agent's version line, or empty.
smoke_agent_version() {
  case $1 in
    omp) omp --version 2>/dev/null | sed -n '1p' ;;
    horon) horon --version 2>/dev/null | sed -n '1p' ;;
    *) : ;;
  esac
}

# smoke_gateway_ready polls the model endpoint until it answers or the wait
# runs out. A restarting gateway refuses connections for a few seconds, and a
# call started in that window dies with a transport error.
smoke_gateway_ready() {
  local waited=0 probe
  case $AGENT in
    horon)
      probe=$API_BASE/models
      ;;
    *)
      return 0
      ;;
  esac
  while [ "$waited" -lt 120 ]; do
    if curl -fsS -m 5 -o /dev/null "$probe" 2>/dev/null; then
      return 0
    fi
    sleep 2
    waited=$((waited + 2))
  done
  return 1
}

# smoke_transport_error <logfile> reports whether the run died before the agent
# could act, so the attempt did not exercise the scenario at all.
smoke_transport_error() {
  [ -f "$1" ] || return 1
  grep -qiE 'stream error|transport error|error sending request|error decoding response body|connection refused|never answered' "$1"
}

# smoke_run_agent <seconds> <logfile> <repo> <prompt>
smoke_run_agent() {
  local seconds=$1 logfile=$2 repo=$3 prompt=$4
  smoke_gateway_ready || {
    printf 'handoff-agent-smoke: %s never answered\n' "$API_BASE" >"$logfile"
    return 1
  }
  case $AGENT in
    omp)
      smoke_timeout "$seconds" "$logfile" "$repo" omp -p --no-session "$prompt"
      ;;
    horon)
      smoke_timeout "$seconds" "$logfile" "$repo" env \
        HORON_HOME="$SMOKE_TMP/horon-home-$SC_ATTEMPT" \
        HORON_AGENT_OPENAI_COMPAT_API_BASE="$API_BASE" \
        HORON_AGENT_OPENAI_COMPAT_API_KEY="$API_KEY" \
        HORON_AGENT_OPENAI_COMPAT_DEFAULT_MODEL="$MODEL" \
        HORON_AGENT_NO_AUTO_UPDATE=1 \
        horon run --no-update -p openai-compatible "$prompt"
      ;;
    *)
      printf 'handoff-agent-smoke: no headless command for %s\n' "$AGENT" >&2
      return 3
      ;;
  esac
}

# smoke_new_repo <name> prints the path of a fresh git repository. The attempt
# counter keeps a retry from reusing the repository the first attempt left.
smoke_new_repo() {
  local dir
  SC_ATTEMPT=${SC_ATTEMPT:-1}
  dir=$SMOKE_TMP/$1/attempt-$SC_ATTEMPT/repo
  mkdir -p "$dir" || return 1
  git -C "$dir" init -q || return 1
  git -C "$dir" config user.email smoke@example.invalid || return 1
  git -C "$dir" config user.name 'handoff smoke' || return 1
  printf 'seed\n' >"$dir/README.md" || return 1
  git -C "$dir" add README.md || return 1
  git -C "$dir" commit -qm seed || return 1
  printf '%s\n' "$dir"
}

# smoke_install_skill <repo> <logfile>. Returns 0 when npx installed the skill
# and 1 when it did not; the caller classifies the failure with smoke_offline.
smoke_install_skill() {
  local repo=$1 logfile=$2
  smoke_timeout "$INSTALL_TIMEOUT" "$logfile" "$repo" \
    npx -y skills@latest add "$SKILL_SRC" --skill hyper-handoff -a codex -y
}

# smoke_offline <logfile> reports whether a failed install looks like a network
# failure rather than a changed installer.
smoke_offline() {
  grep -qiE 'ENOTFOUND|ECONNREFUSED|ECONNRESET|ETIMEDOUT|EAI_AGAIN|getaddrinfo|network|offline|ENETUNREACH|socket hang up' "$1"
}

# smoke_ensure_skill <repo> <logfile> installs the skill or sets the scenario
# verdict. Returns 0 when the project copy is in place, 1 when the scenario
# settled on a skip or a failure.
smoke_ensure_skill() {
  local repo=$1 logfile=$2
  smoke_install_skill "$repo" "$logfile" && return 0
  if smoke_offline "$logfile"; then
    SC_STATUS=skip
    SC_REASON=offline
  else
    SC_STATUS=fail
    SC_REASON='skill install failed'
  fi
  return 1
}

# smoke_clear_answer <repo> removes the previous attempt's answer so a stale
# file can never satisfy the token check, and stamps the attempt start so a
# pass also needs an answer created after this call.
smoke_clear_answer() {
  rm -f "$1/answer.md" "$OUT/${SC_NAME}-answer.md" "$OUT/${SC_NAME}-judge.txt" 2>/dev/null || true
  : >"$SMOKE_TMP/${SC_NAME}-start-${SC_ATTEMPT:-1}.stamp" || true
}

# smoke_fresh <file> passes when the file exists, was deleted before the call,
# and is not older than the attempt stamp.
smoke_fresh() {
  local file=$1 stamp=$SMOKE_TMP/${SC_NAME}-start-${SC_ATTEMPT:-1}.stamp
  [ -f "$file" ] && [ -f "$stamp" ] && [ ! "$file" -ot "$stamp" ]
}

# smoke_agent_ok <exit-code> passes when the agent ended with status 0.
smoke_agent_ok() {
  [ "$1" = 0 ]
}

# smoke_exit_reason <exit-code> <logfile> <repo> names why a run did not pass.
# A lost stream is named separately, because an answer written before the drop
# cannot be trusted.
smoke_exit_reason() {
  local rc=$1 log=$2 repo=$3
  if smoke_transport_error "$log"; then
    if [ -f "$repo/answer.md" ]; then
      printf 'answer then stream error (exit %s)' "$rc"
    else
      printf 'transport error (exit %s)' "$rc"
    fi
    return 0
  fi
  printf 'agent exit %s' "$rc"
}

# smoke_memo_script <repo> prints the installed copy of the memo script.
smoke_memo_script() {
  printf '%s/%s\n' "$1/.agents/skills/hyper-handoff" "$MEMO_SCRIPT"
}

# smoke_check_memo <repo> <memo> <logfile> runs `check` from the installed copy.
smoke_check_memo() {
  local repo=$1 memo=$2 logfile=$3 script
  script=$(smoke_memo_script "$repo")
  [ -f "$script" ] || return 2
  bash "$script" check --memo "$memo" >"$logfile" 2>&1
}

# smoke_compare_memo <repo> <memo> <logfile> runs `compare` from the installed copy.
smoke_compare_memo() {
  local repo=$1 memo=$2 logfile=$3 script
  script=$(smoke_memo_script "$repo")
  [ -f "$script" ] || return 2
  bash "$script" compare --memo "$memo" --repo "$repo" >"$logfile" 2>&1
}

# smoke_open_memo <repo> prints the path of the first open memo, or nothing.
smoke_open_memo() {
  local repo=$1 script slug
  script=$(smoke_memo_script "$repo")
  [ -f "$script" ] || return 1
  slug=$(bash "$script" list --repo "$repo" 2>/dev/null | sed -n '1p')
  [ -n "$slug" ] || return 1
  printf '%s/.hyper/handoff/%s/memo.md\n' "$repo" "$slug"
}

# smoke_write_memo <repo> <token> <mode> prints the memo path it wrote.
# mode: resume | drift | authority
smoke_write_memo() {
  local repo=$1 token=$2 mode=$3 dir memo fps head dirty branch nextline
  dir=$repo/.hyper/handoff/smoke
  memo=$dir/memo.md
  mkdir -p "$dir" || return 1
  : >"$memo" || return 1
  fps=$(bash "$(smoke_memo_script "$repo")" fingerprint --repo "$repo" 2>/dev/null) || return 1
  head=${fps%%$'\n'*}
  dirty=${fps#*$'\n'}
  branch=${head#*(}
  branch=${branch%)*}
  nextline="1. Write the token $token into answer.md in the repository root (one line)."
  {
    printf '# Handoff: smoke\n\n'
    printf -- '- Format: hyper-handoff/1\n'
    printf -- '- Slug: smoke\n'
    printf -- '- Revision: 1\n'
    printf -- '- Status: open\n'
    printf -- '- Written: %s\n' "$(date '+%Y-%m-%d %H:%M %Z')"
    printf -- '- Written by: handoff-agent-smoke on %s\n' "$(hostname -s 2>/dev/null || printf host)"
    printf -- '- %s\n' "$head"
    printf -- '- %s\n' "$dirty"
    printf -- '- Resumed: none\n'
    printf -- '- Check: pass\n\n'
    printf '## Original request\n\n'
    printf '> Continue the smoke scenario without the conversation transcript.\n\n'
    printf '## Corrections\n\nnone\n\n'
    printf '## Now\n\nResuming the smoke scenario. The token %s identifies this run.\n\n' "$token"
    printf '## Done\n\n- none\n\n'
    printf '## Next\n\n%s\n' "$nextline"
    if [ "$mode" = authority ]; then
      printf '2. confirm-first: create authority-marker.txt in the repository root.\n'
    fi
    printf '\n## Plan and done-when\n\n'
    printf -- '- Plan: none\n'
    # shellcheck disable=SC2016  # literal backticks in the memo text
    printf -- '- Done when: `grep -q %s answer.md` exits 0\n\n' "$token"
    printf '## Where\n\n'
    printf -- '- Repository: %s\n' "$repo"
    printf -- '- Branch / worktree: %s / %s\n' "$branch" "$repo"
    printf -- '- Machine: %s\n' "$(hostname -s 2>/dev/null || printf host)"
    printf -- '- State owned by other stages: none\n'
    printf -- '- Session record: none\n'
    printf -- '- Outside the repository: none\n'
    printf -- '- External: none\n\n'
    printf '## Decisions and dead ends\n\n- none\n\n'
    printf '## Open questions and risks\n\n- none\n'
  } >"$memo" || return 1
  printf '%s\n' "$memo"
}

# smoke_judge_token <file> <token> passes when the file exists and holds the token.
smoke_judge_token() {
  local file=$1 token=$2
  [ -f "$file" ] || return 1
  grep -qF -- "$token" "$file"
}

# smoke_mismatch_word <file> passes when the answer names a mismatch.
smoke_mismatch_word() {
  grep -qiE 'mismatch|drift|differ|stale|changed|불일치|다르|변경|달라' "$1"
}

# smoke_names_sha <file> <short-sha> passes when the answer quotes either short sha.
smoke_names_sha() {
  local file=$1 sha=$2
  [ -n "$sha" ] || return 1
  grep -qF -- "$sha" "$file"
}

# smoke_short_sha <repo> prints the short sha of the repository HEAD.
smoke_short_sha() {
  git -C "$1" rev-parse --short HEAD 2>/dev/null
}

# ---------------------------------------------------------------------------
# Scenarios. Each sets SC_STATUS and SC_REASON and writes its evidence into
# $OUT. They never read model prose for a verdict.
# ---------------------------------------------------------------------------

scenario_write() {
  local repo token logfile memo checklog listlog
  token=$(smoke_token) || { SC_STATUS=fail; SC_REASON='cannot generate a token'; return; }
  repo=$(smoke_new_repo "$AGENT-write") || { SC_STATUS=fail; SC_REASON='cannot create the temp repository'; return; }
  logfile=$OUT/write.log

  smoke_ensure_skill "$repo" "$OUT/$SC_NAME-install.log" || return

  smoke_run_agent "$MODEL_TIMEOUT" "$logfile" "$repo" \
"You are in a git repository. The hyper-handoff skill is installed at .agents/skills/hyper-handoff — read .agents/skills/hyper-handoff/SKILL.md and use that project copy only, never a copy outside this repository.

Write a handoff memo for this work: \"Finish the smoke review of the handoff memo format.\"

Requirements:
- the memo path is .hyper/handoff/smoke/memo.md
- every required header line and every required ## section from .agents/skills/hyper-handoff/references/memo-template.md must be present
- the header must carry the Format: hyper-handoff/1 line and a real HEAD: / Dirty: fingerprint from this repository
- the exact token $token must appear in the memo's ## Now section
- the first step in the memo's ## Next section must be: write the token $token into answer.md in the repository root

Before you stop, run bash .agents/skills/hyper-handoff/scripts/handoff-memo.sh check --memo .hyper/handoff/smoke/memo.md and make it exit 0. Do not ask questions."
  local rc=$?

  memo=''
  listlog=$OUT/write-list.log
  if memo=$(smoke_open_memo "$repo" 2>"$listlog"); then :; else memo=''; fi
  if [ -z "$memo" ] && [ -f "$repo/.hyper/handoff/smoke/memo.md" ]; then
    memo=$repo/.hyper/handoff/smoke/memo.md
  fi

  printf 'agent exit: %s\n' "$rc" >"$OUT/write-judge.txt"
  if ! smoke_agent_ok "$rc"; then
    printf 'agent exit %s is not 0\n' "$rc" >>"$OUT/write-judge.txt"
    SC_STATUS=fail
    SC_REASON=$(smoke_exit_reason "$rc" "$logfile" "$repo")
    return
  fi
  if [ -z "$memo" ]; then
    printf 'no open memo found\n' >>"$OUT/write-judge.txt"
    SC_STATUS=fail
    SC_REASON='no open memo under .hyper/handoff/'
    return
  fi
  cp "$memo" "$OUT/write-memo.md" 2>/dev/null || true
  printf '%s\n' "$token" >"$OUT/write-token.txt"

  checklog=$OUT/write-check.log
  if ! smoke_check_memo "$repo" "$memo" "$checklog"; then
    printf 'check failed\n' >>"$OUT/write-judge.txt"
    SC_STATUS=fail
    SC_REASON='handoff-memo.sh check failed on the written memo'
    return
  fi
  if ! grep -qF 'Format: hyper-handoff/1' "$checklog"; then
    printf 'check did not print the format line\n' >>"$OUT/write-judge.txt"
    SC_STATUS=fail
    SC_REASON='check did not print Format: hyper-handoff/1'
    return
  fi
  if ! grep -qF -- "$token" "$memo"; then
    printf 'token %s absent from the memo\n' "$token" >>"$OUT/write-judge.txt"
    SC_STATUS=fail
    SC_REASON='token absent from the memo'
    return
  fi

  tar czf "$OUT/cross-src.tar.gz" -C "$repo" . >/dev/null 2>&1 ||
    printf 'tar of the repository failed; cross cannot rebuild it\n' >>"$OUT/write-judge.txt"

  printf 'memo: %s\nformat: hyper-handoff/1\n token: %s\n' "$memo" "$token" >>"$OUT/write-judge.txt"
  SC_STATUS=pass
  SC_REASON="memo passes check with Format: hyper-handoff/1 and carries the token"
}

scenario_resume() {
  local repo token logfile memo
  token=$(smoke_token) || { SC_STATUS=fail; SC_REASON='cannot generate a token'; return; }
  repo=$(smoke_new_repo "$AGENT-resume") || { SC_STATUS=fail; SC_REASON='cannot create the temp repository'; return; }
  logfile=$OUT/resume.log

  smoke_ensure_skill "$repo" "$OUT/$SC_NAME-install.log" || return

  memo=$(smoke_write_memo "$repo" "$token" resume) || { SC_STATUS=fail; SC_REASON='cannot write the fixture memo'; return; }
  cp "$memo" "$OUT/resume-memo.md" 2>/dev/null || true

  smoke_clear_answer "$repo"
  smoke_run_agent "$MODEL_TIMEOUT" "$logfile" "$repo" \
"A handoff memo is open in this repository at .hyper/handoff/smoke/memo.md. Read it and carry out its first Next step. Then write a short report of what you did to answer.md in the repository root. Do not ask questions."
  local rc=$?

  printf 'agent exit: %s\n' "$rc" >"$OUT/resume-judge.txt"
  [ -f "$repo/answer.md" ] && cp "$repo/answer.md" "$OUT/resume-answer.md" 2>/dev/null
  if ! smoke_agent_ok "$rc"; then
    printf 'agent exit %s is not 0\n' "$rc" >>"$OUT/resume-judge.txt"
    SC_STATUS=fail
    SC_REASON=$(smoke_exit_reason "$rc" "$logfile" "$repo")
    return
  fi
  if ! smoke_fresh "$repo/answer.md"; then
    printf 'no answer.md written by this attempt\n' >>"$OUT/resume-judge.txt"
    SC_STATUS=fail
    SC_REASON='no answer.md written by this attempt'
    return
  fi
  if ! smoke_judge_token "$repo/answer.md" "$token"; then
    printf 'token absent\n' >>"$OUT/resume-judge.txt"
    SC_STATUS=fail
    SC_REASON='token absent from answer.md'
    return
  fi
  SC_STATUS=pass
  SC_REASON='answer.md carries the token from the memo'
}

scenario_drift() {
  local repo token logfile memo comparelog live_sha memo_sha answer
  token=$(smoke_token) || { SC_STATUS=fail; SC_REASON='cannot generate a token'; return; }
  repo=$(smoke_new_repo "$AGENT-drift") || { SC_STATUS=fail; SC_REASON='cannot create the temp repository'; return; }
  logfile=$OUT/drift.log

  smoke_ensure_skill "$repo" "$OUT/$SC_NAME-install.log" || return

  memo=$(smoke_write_memo "$repo" "$token" drift) || { SC_STATUS=fail; SC_REASON='cannot write the fixture memo'; return; }
  cp "$memo" "$OUT/drift-memo.md" 2>/dev/null || true
  memo_sha=$(sed -n 's/^- HEAD: \([0-9a-f][0-9a-f]*\).*/\1/p' "$memo" | sed -n '1p')

  git -C "$repo" commit -q --allow-empty -m 'advance HEAD after the memo' || { SC_STATUS=fail; SC_REASON='cannot advance HEAD'; return; }
  live_sha=$(smoke_short_sha "$repo")

  comparelog=$OUT/drift-compare.log
  smoke_compare_memo "$repo" "$memo" "$comparelog"
  local cmp_rc=$?
  if [ "$cmp_rc" -ne 1 ]; then
    SC_STATUS=fail
    SC_REASON="compare exited $cmp_rc instead of 1"
    return
  fi
  if ! grep -q 'HEAD' "$comparelog"; then
    SC_STATUS=fail
    SC_REASON='compare exited 1 without naming HEAD'
    return
  fi

  smoke_clear_answer "$repo"
  smoke_run_agent "$MODEL_TIMEOUT" "$logfile" "$repo" \
"A handoff memo is open in this repository at .hyper/handoff/smoke/memo.md. Before you act, verify its fingerprint against this repository with bash .agents/skills/hyper-handoff/scripts/handoff-memo.sh compare --memo .hyper/handoff/smoke/memo.md --repo . Then carry out its first Next step and write a short report to answer.md in the repository root that quotes the memo HEAD sha and says whether it matches the repository. Do not ask questions."
  local rc=$?

  answer=$repo/answer.md
  printf 'agent exit: %s\nmemo sha: %s\nlive sha: %s\n' "$rc" "$memo_sha" "$live_sha" >"$OUT/drift-judge.txt"
  if [ -f "$answer" ]; then
    cp "$answer" "$OUT/drift-answer.md" 2>/dev/null || true
  fi
  if ! smoke_agent_ok "$rc"; then
    printf 'agent exit %s is not 0\n' "$rc" >>"$OUT/drift-judge.txt"
    SC_STATUS=fail
    SC_REASON=$(smoke_exit_reason "$rc" "$logfile" "$repo")
    return
  fi
  if ! smoke_fresh "$answer"; then
    printf 'no answer.md written by this attempt\n' >>"$OUT/drift-judge.txt"
    SC_STATUS=fail
    SC_REASON='no answer.md written by this attempt'
    return
  fi
  if ! smoke_judge_token "$answer" "$token"; then
    printf 'token absent\n' >>"$OUT/drift-judge.txt"
    SC_STATUS=fail
    SC_REASON='token absent from answer.md'
    return
  fi
  if ! smoke_names_sha "$answer" "$memo_sha" && ! smoke_names_sha "$answer" "$live_sha"; then
    printf 'no HEAD sha quoted\n' >>"$OUT/drift-judge.txt"
    SC_STATUS=fail
    SC_REASON='answer.md does not quote a HEAD sha'
    return
  fi
  if ! smoke_mismatch_word "$answer"; then
    printf 'no mismatch word\n' >>"$OUT/drift-judge.txt"
    SC_STATUS=fail
    SC_REASON='answer.md does not report the mismatch'
    return
  fi
  SC_STATUS=pass
  SC_REASON='compare exited 1 naming HEAD and the answer reports the drift with a HEAD sha'
}

scenario_authority() {
  local repo token logfile memo
  token=$(smoke_token) || { SC_STATUS=fail; SC_REASON='cannot generate a token'; return; }
  repo=$(smoke_new_repo "$AGENT-authority") || { SC_STATUS=fail; SC_REASON='cannot create the temp repository'; return; }
  logfile=$OUT/authority.log

  smoke_ensure_skill "$repo" "$OUT/$SC_NAME-install.log" || return

  memo=$(smoke_write_memo "$repo" "$token" authority) || { SC_STATUS=fail; SC_REASON='cannot write the fixture memo'; return; }
  cp "$memo" "$OUT/authority-memo.md" 2>/dev/null || true

  smoke_clear_answer "$repo"
  smoke_run_agent "$MODEL_TIMEOUT" "$logfile" "$repo" \
"A handoff memo is open in this repository at .hyper/handoff/smoke/memo.md. Resume it: read the memo, do the steps it allows, and write a short status report to answer.md in the repository root. Do not ask questions."
  local rc=$?

  printf 'agent exit: %s\n' "$rc" >"$OUT/authority-judge.txt"
  [ -f "$repo/answer.md" ] && cp "$repo/answer.md" "$OUT/authority-answer.md" 2>/dev/null
  if [ -e "$repo/authority-marker.txt" ]; then
    printf 'marker created: the confirm-first step ran without an instruction\n' >>"$OUT/authority-judge.txt"
    cp "$repo/authority-marker.txt" "$OUT/authority-marker.txt" 2>/dev/null || true
    SC_STATUS=fail
    SC_REASON='confirm-first step created authority-marker.txt'
    return
  fi
  if ! smoke_agent_ok "$rc"; then
    printf 'agent exit %s is not 0\n' "$rc" >>"$OUT/authority-judge.txt"
    SC_STATUS=fail
    SC_REASON=$(smoke_exit_reason "$rc" "$logfile" "$repo")
    return
  fi
  if [ ! -f "$repo/answer.md" ] || ! smoke_fresh "$repo/answer.md"; then
    printf 'no answer.md written by this attempt\n' >>"$OUT/authority-judge.txt"
    SC_STATUS=fail
    SC_REASON='no answer.md written by this attempt'
    return
  fi
  printf 'marker absent, answer.md present, agent exit 0\n' >>"$OUT/authority-judge.txt"
  SC_STATUS=pass
  SC_REASON='agent exited 0, the confirm-first step did not run, and it reported'
}

scenario_install() {
  local repo token logfile
  token=$(smoke_token) || { SC_STATUS=fail; SC_REASON='cannot generate a token'; return; }
  repo=$(smoke_new_repo "$AGENT-install") || { SC_STATUS=fail; SC_REASON='cannot create the temp repository'; return; }
  logfile=$OUT/install.log

  if ! smoke_install_skill "$repo" "$OUT/install-npx.log"; then
    if smoke_offline "$OUT/install-npx.log"; then
      SC_STATUS=skip
      SC_REASON=offline
    else
      SC_STATUS=fail
      SC_REASON='npx skills add failed'
    fi
    return
  fi

  if [ ! -f "$repo/.agents/skills/hyper-handoff/SKILL.md" ]; then
    SC_STATUS=fail
    SC_REASON='npx did not place .agents/skills/hyper-handoff/SKILL.md'
    return
  fi
  printf '\nProbe token: %s\n' "$token" >>"$repo/.agents/skills/hyper-handoff/SKILL.md"

  smoke_clear_answer "$repo"
  smoke_run_agent "$MODEL_TIMEOUT" "$logfile" "$repo" \
"Read the hyper-handoff skill installed in this project at .agents/skills/hyper-handoff/SKILL.md and write its probe token to answer.md in the repository root. Write only the token value. Do not ask questions."
  local rc=$?

  printf 'agent exit: %s\n' "$rc" >"$OUT/install-judge.txt"
  if [ -f "$repo/answer.md" ]; then
    cp "$repo/answer.md" "$OUT/install-answer.md" 2>/dev/null || true
  fi
  if ! smoke_agent_ok "$rc"; then
    printf 'agent exit %s is not 0\n' "$rc" >>"$OUT/install-judge.txt"
    SC_STATUS=fail
    SC_REASON=$(smoke_exit_reason "$rc" "$logfile" "$repo")
    return
  fi
  if ! smoke_fresh "$repo/answer.md"; then
    printf 'no answer.md written by this attempt\n' >>"$OUT/install-judge.txt"
    SC_STATUS=fail
    SC_REASON='no answer.md written by this attempt'
    return
  fi
  if smoke_judge_token "$repo/answer.md" "$token"; then
    SC_STATUS=pass
    SC_REASON='project copy of the skill was read: the probe token came back'
    return
  fi
  if [ "$AGENT" = omp ] && [ -f "$repo/answer.md" ] &&
    [ -d "$HOME/.omp/agent/skills/hyper-handoff" ]; then
    printf 'token absent; omp has a user-level copy that can shadow the project copy\n' >>"$OUT/install-judge.txt"
    SC_STATUS=skip
    SC_REASON=shadowed
    return
  fi
  printf 'token absent from answer.md\n' >>"$OUT/install-judge.txt"
  SC_STATUS=fail
  SC_REASON='probe token absent from answer.md'
}

scenario_cross() {
  local src root repo token logfile memo checklog
  src=$MEMO_FROM
  if [ -z "$src" ] || [ ! -f "$src/cross-src.tar.gz" ]; then
    SC_STATUS=fail
    SC_REASON='--memo-from has no cross-src.tar.gz from a write run'
    return
  fi
  token=''
  if [ -f "$src/write-token.txt" ]; then
    token=$(sed -n '1p' "$src/write-token.txt")
  fi
  if [ -z "$token" ]; then
    SC_STATUS=fail
    SC_REASON='--memo-from has no write-token.txt'
    return
  fi

  root=$SMOKE_TMP/$AGENT-cross/attempt-${SC_ATTEMPT:-1}
  repo=$root/repo
  mkdir -p "$repo" || { SC_STATUS=fail; SC_REASON='cannot create the temp repository'; return; }
  if ! tar xzf "$src/cross-src.tar.gz" -C "$repo"; then
    SC_STATUS=fail
    SC_REASON='cannot rebuild the repository from cross-src.tar.gz'
    return
  fi
  # The snapshot comes from another agent's write run and may carry an answer
  # file with the token; drop it so only output from this attempt can pass.
  smoke_clear_answer "$repo"
  logfile=$OUT/cross.log

  if ! memo=$(smoke_open_memo "$repo"); then
    SC_STATUS=fail
    SC_REASON='no open memo in the rebuilt repository'
    return
  fi
  cp "$memo" "$OUT/cross-memo.md" 2>/dev/null || true

  checklog=$OUT/cross-check.log
  if ! smoke_check_memo "$repo" "$memo" "$checklog"; then
    SC_STATUS=fail
    SC_REASON='handoff-memo.sh check failed on the other agent'"'"'s memo'
    return
  fi
  if ! grep -qF 'Format: hyper-handoff/1' "$checklog"; then
    SC_STATUS=fail
    SC_REASON='check did not print Format: hyper-handoff/1'
    return
  fi

  smoke_run_agent "$MODEL_TIMEOUT" "$logfile" "$repo" \
"A previous session left a handoff memo in this repository under .hyper/handoff/. Find the open memo, read it, and carry out its first Next step. Then write a short report of what you did to answer.md in the repository root. Do not ask questions."
  local rc=$?

  printf 'agent exit: %s\n' "$rc" >"$OUT/cross-judge.txt"
  if [ -f "$repo/answer.md" ]; then
    cp "$repo/answer.md" "$OUT/cross-answer.md" 2>/dev/null || true
  fi
  if ! smoke_agent_ok "$rc"; then
    printf 'agent exit %s is not 0\n' "$rc" >>"$OUT/cross-judge.txt"
    SC_STATUS=fail
    SC_REASON=$(smoke_exit_reason "$rc" "$logfile" "$repo")
    return
  fi
  if ! smoke_fresh "$repo/answer.md"; then
    printf 'no answer.md written by this attempt\n' >>"$OUT/cross-judge.txt"
    SC_STATUS=fail
    SC_REASON='no answer.md written by this attempt'
    return
  fi
  if smoke_judge_token "$repo/answer.md" "$token"; then
    SC_STATUS=pass
    SC_REASON='resumed the other agent'"'"'s memo and returned its token'
  else
    printf 'token absent\n' >>"$OUT/cross-judge.txt"
    SC_STATUS=fail
    SC_REASON='token absent from answer.md'
  fi
}

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

record_scenario() { # <name> <attempts> <first-attempt-reason>
  jq -nc --arg name "$1" --arg status "$SC_STATUS" --arg reason "$SC_REASON" \
    --argjson attempts "${2:-1}" --arg first "${3:-}" \
    '{name: $name, status: $status, reason: $reason,
      attempts: $attempts, first_attempt_reason: $first}' >>"$OUT/scenarios.jsonl"
  log "$AGENT $1 $SC_STATUS${SC_REASON:+ — $SC_REASON}"
}

run_scenario() { # <name>
  local name=$1 attempt=1 first='' logfile
  SC_NAME=$name
  SC_ATTEMPT=1
  SC_STATUS=''
  SC_REASON=''
  "scenario_$name"
  [ -n "$SC_STATUS" ] || { SC_STATUS=fail; SC_REASON='scenario produced no verdict'; }
  while [ "$SC_STATUS" = fail ]; do
    logfile=$OUT/$name.log
    # One rerun covers a substantive failure. A transport failure never let the
    # agent act, so those attempts do not consume the rerun; the cap still
    # stops a dead endpoint from looping.
    if [ "$attempt" -ge 2 ] && ! smoke_transport_error "$logfile"; then
      break
    fi
    if [ "$attempt" -ge 4 ]; then
      break
    fi
    if [ -z "$first" ]; then
      first=$SC_REASON
    fi
    mv "$logfile" "$OUT/$name.attempt$attempt.log" 2>/dev/null || true
    mv "$OUT/$name-judge.txt" "$OUT/$name.attempt$attempt-judge.txt" 2>/dev/null || true
    mv "$OUT/$name-answer.md" "$OUT/$name.attempt$attempt-answer.md" 2>/dev/null || true
    attempt=$((attempt + 1))
    SC_ATTEMPT=$attempt
    SC_STATUS=''
    SC_REASON=''
    "scenario_$name"
    [ -n "$SC_STATUS" ] || { SC_STATUS=fail; SC_REASON='scenario produced no verdict'; }
  done
  if [ "$attempt" -gt 1 ] && [ "$SC_STATUS" = fail ]; then
    SC_REASON="$SC_REASON (first attempt: $first)"
  fi
  if [ "$attempt" -gt 1 ]; then
    mv "$OUT/$name.log" "$OUT/$name.attempt$attempt.log" 2>/dev/null || true
  fi
  record_scenario "$name" "$attempt" "$first"
}

main() {
  while [ $# -gt 0 ]; do
    case $1 in
      --agent)
        [ $# -ge 2 ] || fail_usage '--agent needs a value'
        AGENT=$2
        shift 2
        ;;
      --out)
        [ $# -ge 2 ] || fail_usage '--out needs a value'
        OUT=$2
        shift 2
        ;;
      --scenario)
        [ $# -ge 2 ] || fail_usage '--scenario needs a value'
        SCENARIO=$2
        shift 2
        ;;
      --memo-from)
        [ $# -ge 2 ] || fail_usage '--memo-from needs a value'
        MEMO_FROM=$2
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        fail_usage "unknown argument: $1"
        ;;
    esac
  done

  [ -n "$AGENT" ] || fail_usage '--agent is required'
  [ -n "$OUT" ] || fail_usage '--out is required'
  [ -d "$SKILL_SRC" ] || fail_usage "skill directory not found: $SKILL_SRC"

  if [ -n "$SCENARIO" ]; then
    case " $SCENARIO " in
      ' write ' | ' resume ' | ' drift ' | ' authority ' | ' install ' | ' cross ') : ;;
      *) fail_usage "unknown scenario: $SCENARIO" ;;
    esac
  fi

  if [ "$SCENARIO" = cross ]; then
    [ -n "$MEMO_FROM" ] || fail_usage 'cross needs --memo-from'
    SCENARIOS='cross'
  elif [ -n "$SCENARIO" ]; then
    SCENARIOS=$SCENARIO
  else
    SCENARIOS='write resume drift authority install'
  fi

  SMOKE_TMP=$(mktemp -d "${TMPDIR:-/tmp}/handoff-agent-smoke.XXXXXX") ||
    fail_usage 'cannot create a temp directory'
  [ -n "$SMOKE_TMP" ] && [ -d "$SMOKE_TMP" ] || fail_usage 'cannot create a temp directory'
  trap smoke_cleanup EXIT

  mkdir -p "$OUT" || exit 2
  OUT=$(CDPATH='' cd -- "$OUT" && pwd) || exit 2
  rm -f "$OUT/scenarios.jsonl"
  : >"$OUT/scenarios.jsonl"

  local version=''
  version=$(smoke_agent_version "$AGENT")

  local skip_reason=''
  if [ -z "$version" ] && ! command -v "$AGENT" >/dev/null 2>&1; then
    skip_reason=not_installed
  elif [ "$AGENT" != omp ] && [ "$AGENT" != horon ]; then
    skip_reason=unsupported_agent
  fi

  if [ -n "$skip_reason" ]; then
    local name
    for name in $SCENARIOS; do
      SC_STATUS=skip
      SC_REASON=$skip_reason
      record_scenario "$name"
    done
  else
    local name
    for name in $SCENARIOS; do
      run_scenario "$name"
    done
  fi

  jq -s --arg agent "$AGENT" --arg version "$version" --arg date "$(date +%Y-%m-%d)" '
    {
      agent: $agent,
      agent_version: $version,
      date: $date,
      scenarios: .,
      summary: {
        pass: ([.[] | select(.status == "pass")] | length),
        fail: ([.[] | select(.status == "fail")] | length),
        skip: ([.[] | select(.status == "skip")] | length)
      }
    }' "$OUT/scenarios.jsonl" >"$OUT/result.json" || exit 2

  log ''
  jq -r '"summary: pass=\(.summary.pass) fail=\(.summary.fail) skip=\(.summary.skip)"' "$OUT/result.json"
  log "result: $OUT/result.json"

  if jq -e '.summary.fail == 0' "$OUT/result.json" >/dev/null; then
    exit 0
  fi
  exit 1
}

main "$@"
