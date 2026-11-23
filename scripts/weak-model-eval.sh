#!/usr/bin/env bash
# weak-model-eval.sh — prepare and score weak-model workflow-compliance runs of the hyper skill.
#
# Usage:
#   bash scripts/weak-model-eval.sh list
#   bash scripts/weak-model-eval.sh prepare --scenario <id> --out <dir>
#   bash scripts/weak-model-eval.sh score --scenario <id> --workdir <dir> --transcript <file>
#
# Scenarios live in scripts/fixtures/weak-model-eval/<id>/ (scenario.json + repo/).
#
# prepare  Copies the scenario repo to <dir> (which must not exist), commits it
#          as a fresh git repository, copies this repository's skills/ to
#          <dir>/.agents/skills/, and writes the exact prompt to
#          <dir>/.eval/prompt.txt. Run the agent under test inside <dir> with
#          that prompt and save everything it printed as the transcript.
# score    Prints one JSON object counting step, state, and checklist
#          omissions plus the outcome (scenario tests pass, files changed
#          outside the allowed paths). The transcript may be plain text (the
#          agent's own replies) or an `omp --mode json` event log; from an
#          event log only assistant text and shell command output count, so a
#          banner template echoed by a file read never scores as printed.
#
# Exit codes: 0 done (a score with omissions is still exit 0), 1 runtime
# failure, 2 usage error. Requires bash 3.2+, git, jq, and node for scoring.
set -uo pipefail

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
SCENARIOS_DIR=${HYPERCORE_EVAL_SCENARIOS:-$SCRIPT_DIR/fixtures/weak-model-eval}
STATE_SCRIPT=$REPO_ROOT/skills/hyper/scripts/hyper-workflow-state.sh

usage_err() {
  printf 'weak-model-eval: %s\n' "$1" >&2
  printf 'usage: weak-model-eval.sh list | prepare --scenario <id> --out <dir> | score --scenario <id> --workdir <dir> --transcript <file>\n' >&2
  exit 2
}

die() {
  printf 'weak-model-eval: %s\n' "$1" >&2
  exit 1
}

scenario_file() { # <id>
  local file=$SCENARIOS_DIR/$1/scenario.json
  [ -f "$file" ] || usage_err "unknown scenario: $1"
  printf '%s\n' "$file"
}

cmd_list() {
  local dir
  for dir in "$SCENARIOS_DIR"/*/; do
    [ -f "$dir/scenario.json" ] && basename "$dir"
  done
  return 0
}

cmd_prepare() {
  local id=$1 out=$2 meta
  meta=$(scenario_file "$id")
  [ ! -e "$out" ] || usage_err "output directory already exists: $out"
  mkdir -p "$out" || die "cannot create $out"
  cp -R "$SCENARIOS_DIR/$id/repo/." "$out/" || die "cannot copy scenario repo"
  printf '.agents/\n.eval/\n' >"$out/.gitignore"
  (
    cd "$out" &&
      git init -q &&
      git add -A &&
      git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "scenario $id"
  ) || die "cannot initialize the scenario git repository"
  mkdir -p "$out/.agents" "$out/.eval"
  cp -R "$REPO_ROOT/skills" "$out/.agents/skills" || die "cannot copy skills"
  {
    printf '먼저 .agents/skills/hyper/SKILL.md 를 읽고 그 지시를 끝까지 따르세요.\n\n'
    jq -r '.prompt' "$meta"
  } >"$out/.eval/prompt.txt"
  printf '%s\n' "$out/.eval/prompt.txt"
}

# The text the agent itself produced. From an omp JSON event log: assistant
# text plus shell output (the state helper prints the banners). Any other file
# is taken as plain text the agent printed.
normalize_transcript() { # <file>
  if jq -e 'select(.type == "message_end")' "$1" >/dev/null 2>&1; then
    jq -r 'select(.type == "message_end") | .message
      | if .role == "assistant" then (.content[]? | select(.type == "text") | .text)
        elif .role == "toolResult" and .toolName == "bash" then (.content[]? | select(.type == "text") | .text)
        else empty end' "$1"
  else
    cat "$1"
  fi
}

has_line() { # <regex> <file>
  grep -Eq -- "$1" "$2"
}

cmd_score() {
  local id=$1 work=$2 transcript=$3 meta tmp
  meta=$(scenario_file "$id")
  [ -d "$work" ] || usage_err "workdir not found: $work"
  [ -f "$transcript" ] || usage_err "transcript not found: $transcript"
  tmp=$(mktemp -d) || die "cannot create a temp dir"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" EXIT
  normalize_transcript "$transcript" >"$tmp/text"

  local steps_expected=0 state_expected=4 checklist_expected=6
  : >"$tmp/steps" ; : >"$tmp/state" ; : >"$tmp/checklist" ; : >"$tmp/no"

  # Steps: route banner, entry and exit banners per chain stage, debug step banners.
  steps_expected=$((steps_expected + 1))
  has_line '\[라우팅:' "$tmp/text" || printf 'route-banner\n' >>"$tmp/steps"
  local n k stage s debug_steps
  n=$(jq -r '.expected_chain | length' "$meta")
  k=0
  while [ "$k" -lt "$n" ]; do
    stage=$(jq -r ".expected_chain[$k]" "$meta")
    k=$((k + 1))
    steps_expected=$((steps_expected + 2))
    has_line "\\[현재 단계: $k/$n ${stage}[^]]*진행 중" "$tmp/text" || printf 'enter:%s\n' "$stage" >>"$tmp/steps"
    has_line "\\[현재 단계: $k/$n ${stage}[^]]*완료" "$tmp/text" || printf 'exit:%s\n' "$stage" >>"$tmp/steps"
  done
  debug_steps=$(jq -r '.debug_steps // 0' "$meta")
  s=1
  while [ "$s" -le "$debug_steps" ]; do
    steps_expected=$((steps_expected + 1))
    has_line "\\[현재 단계: $s/$debug_steps([^0-9]|$)" "$tmp/text" || printf 'debug-step:%s\n' "$s" >>"$tmp/steps"
    s=$((s + 1))
  done

  # State: workflow state file, its verify gate, the debug journal and its terminal.
  local states slug journal
  states=$(find "$work/.hyper/workflows" -mindepth 2 -maxdepth 2 -name state.json 2>/dev/null | LC_ALL=C sort)
  if [ -z "$states" ]; then
    printf 'workflow-state\nworkflow-verify\n' >>"$tmp/state"
  else
    slug=$(basename "$(dirname "$(printf '%s\n' "$states" | head -n 1)")")
    if ! bash "$STATE_SCRIPT" verify --root "$work" --slug "$slug" >/dev/null 2>&1; then
      printf 'workflow-verify\n' >>"$tmp/state"
    fi
  fi
  journal=$(find "$work/.hyper/debug" -maxdepth 1 -name '*.md' -size +0 2>/dev/null | LC_ALL=C sort | head -n 1)
  if [ -z "$journal" ]; then
    printf 'debug-journal\ndebug-result\n' >>"$tmp/state"
  elif ! awk 'NF { last = $0 } END { exit !(last ~ /^Result: (confirmed|fixed|handoff|unconfirmed|awaiting_input|blocked)[ \t]*$/) }' "$journal"; then
    printf 'debug-result\n' >>"$tmp/state"
  fi

  # Checklist: the closing line answers items 1..6.
  local line i
  line=$(grep -E '체크리스트:' "$tmp/text" | tail -n 1)
  i=1
  while [ "$i" -le "$checklist_expected" ]; do
    if printf '%s' "$line" | grep -Eq "(^|[^0-9])$i=예"; then
      :
    elif printf '%s' "$line" | grep -Eq "(^|[^0-9])$i=아니오"; then
      printf '%s\n' "$i" >>"$tmp/no"
    else
      printf '%s\n' "$i" >>"$tmp/checklist"
    fi
    i=$((i + 1))
  done

  # Outcome: the scenario's own tests and the files the run changed.
  local tests_pass=false
  if (cd "$work" && jq -r '.test_command[]' "$meta" | tr '\n' '\0' | xargs -0 env >/dev/null 2>&1); then
    tests_pass=true
  fi
  jq -r '.allowed_paths[]' "$meta" >"$tmp/allowed"
  : >"$tmp/scope"
  (cd "$work" && git status --porcelain --untracked-files=all) | cut -c4- | while IFS= read -r path; do
    local ok=0 prefix
    while IFS= read -r prefix; do
      case $path in "$prefix"*) ok=1 ;; esac
    done <"$tmp/allowed"
    [ "$ok" -eq 1 ] || printf '%s\n' "$path" >>"$tmp/scope"
  done

  jq -n \
    --arg scenario "$id" \
    --argjson steps_expected "$steps_expected" \
    --argjson state_expected "$state_expected" \
    --argjson checklist_expected "$checklist_expected" \
    --argjson tests_pass "$tests_pass" \
    --rawfile steps "$tmp/steps" \
    --rawfile state "$tmp/state" \
    --rawfile checklist "$tmp/checklist" \
    --rawfile no "$tmp/no" \
    --rawfile scope "$tmp/scope" '
    def lines: split("\n") | map(select(length > 0));
    {
      scenario: $scenario,
      steps: { expected: $steps_expected, missing: ($steps | lines) },
      state: { expected: $state_expected, missing: ($state | lines) },
      checklist: { expected: $checklist_expected, missing: ($checklist | lines), answered_no: ($no | lines) },
      outcome: { tests_pass: $tests_pass, out_of_scope: ($scope | lines) }
    }
    | .omissions = { steps: (.steps.missing | length), state: (.state.missing | length), checklist: (.checklist.missing | length) }
    | .omissions.total = (.omissions.steps + .omissions.state + .omissions.checklist)'
}

[ "$#" -ge 1 ] || usage_err "missing command"
command -v jq >/dev/null 2>&1 || die "jq is required"
CMD=$1
shift
SCENARIO="" OUT="" WORKDIR="" TRANSCRIPT=""
while [ "$#" -gt 0 ]; do
  case $1 in
    --scenario | --out | --workdir | --transcript)
      [ "$#" -ge 2 ] && [ -n "$2" ] || usage_err "$1 requires a value"
      case $1 in
        --scenario) SCENARIO=$2 ;;
        --out) OUT=$2 ;;
        --workdir) WORKDIR=$2 ;;
        --transcript) TRANSCRIPT=$2 ;;
      esac
      shift 2
      ;;
    -h | --help)
      sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) usage_err "unknown argument: $1" ;;
  esac
done

case $CMD in
  list) cmd_list ;;
  prepare)
    [ -n "$SCENARIO" ] && [ -n "$OUT" ] || usage_err "prepare needs --scenario and --out"
    cmd_prepare "$SCENARIO" "$OUT"
    ;;
  score)
    [ -n "$SCENARIO" ] && [ -n "$WORKDIR" ] && [ -n "$TRANSCRIPT" ] || usage_err "score needs --scenario, --workdir, and --transcript"
    cmd_score "$SCENARIO" "$WORKDIR" "$TRANSCRIPT"
    ;;
  -h | --help) sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) usage_err "unknown command: $CMD" ;;
esac
