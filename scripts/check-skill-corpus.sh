#!/usr/bin/env bash
# check-skill-corpus.sh — validate the approved bash skill-script inventory and safety boundaries.
#
# Port of scripts/validate-skills.mjs. Takes no arguments. Prints the same success
# line on success and exits 0; on the first failed check prints that check's message
# to stderr and exits 1.
set -o pipefail
export LC_ALL=C

root=$(cd "$(dirname "$0")/.." && pwd) || exit 1
manifest=$root/scripts/fixtures/skill-script-parity/manifest.json
contracts=$root/scripts/fixtures/skill-script-parity/behavior/contracts.json

tmp=$(mktemp -d "${TMPDIR:-/tmp}/check-skill-corpus.XXXXXX") || exit 1
trap 'rm -rf "$tmp"' EXIT

die() {
  printf '%s\n' "$1" >&2
  exit 1
}

file_mode_executable() {
  local mode
  if mode=$(stat -c %a "$1" 2>/dev/null); then
    :
  else
    mode=$(stat -f %Lp "$1" 2>/dev/null) || return 1
  fi
  [ "$((8#$mode & 8#111))" -ne 0 ]
}

same_list() {
  sort -u "$1" >"$tmp/same-a"
  sort -u "$2" >"$tmp/same-b"
  cmp -s "$tmp/same-a" "$tmp/same-b"
}

in_set() {
  grep -qxF -- "$1" <<<"$2"
}

# Full-line comments are prose, not policy: drop them the way codeLines() does.
code_lines_file() {
  awk '!/^[[:space:]]*#/' "$1" >"$2"
}

approved_sources() {
  case $1 in
    skills/hyper-design/scripts/analyze-structure.sh) printf '%s\n' 'rule-shared.sh' ;;
    skills/hyper-design/scripts/detect-slop.sh) printf '%s\n' 'engine-css.sh' 'engine-markup.sh' 'engine-text.sh' 'resolve-context.sh' 'rule-shared.sh' ;;
    skills/hyper-design/scripts/validate-waivers.sh) printf '%s\n' 'rule-registry.sh' ;;
    skills/hyper-design/scripts/engine-css.sh) printf '%s\n' 'engine-text.sh' ;;
    skills/hyper-design/scripts/engine-markup.sh) printf '%s\n' 'engine-text.sh' ;;
    skills/hyper-design/scripts/engine-text.sh) printf '%s\n' 'rule-shared.sh' ;;
    skills/hyper-design/scripts/resolve-context.sh) printf '%s\n' 'rule-shared.sh' ;;
    skills/hyper-design/scripts/rule-shared.sh) printf '%s\n' 'rule-registry.sh' ;;
    *) : ;;
  esac
}

approved_child_scripts() {
  case $1 in
    skills/hyper-design/scripts/run-contract-evals.sh) printf '%s\n' 'collect-rendered-evidence.sh' 'validate-report.sh' 'validate-waivers.sh' ;;
    skills/hyper-design/scripts/run-detector-evals.sh) printf '%s\n' 'detect-slop.sh' ;;
    skills/hyper-deploy/scripts/build-run.sh) printf '%s\n' 'pm-detect.sh' 'stack-detect.sh' ;;
    skills/hyper-deploy/scripts/deploy-check.sh) printf '%s\n' 'build-run.sh' 'lint-check.sh' 'stack-detect.sh' ;;
    skills/hyper-deploy/scripts/lint-check.sh) printf '%s\n' 'pm-detect.sh' 'stack-detect.sh' ;;
    *) : ;;
  esac
}

# usage and behavior for each concrete path, tab-separated.
metadata_for() {
  case $1 in
    skills/hyper-design/scripts/analyze-structure.sh) printf 'analyze-structure\tstructure-analysis\n' ;;
    skills/hyper-design/scripts/collect-rendered-evidence.sh) printf 'collect-rendered-evidence\trendered-evidence-collection\n' ;;
    skills/hyper-design/scripts/detect-slop.sh) printf 'detect-slop\tslop-detection\n' ;;
    skills/hyper-design/scripts/engine-css.sh) printf 'slop-engine-css\tslop-engine-css\n' ;;
    skills/hyper-design/scripts/engine-markup.sh) printf 'slop-engine-markup\tslop-engine-markup\n' ;;
    skills/hyper-design/scripts/engine-text.sh) printf 'slop-engine-text\tslop-engine-text\n' ;;
    skills/hyper-design/scripts/resolve-context.sh) printf 'resolve-context\tcontext-resolution\n' ;;
    skills/hyper-design/scripts/rule-registry.sh) printf 'slop-rule-registry\tslop-rule-registry\n' ;;
    skills/hyper-design/scripts/rule-shared.sh) printf 'slop-rule-shared\tslop-rule-shared\n' ;;
    skills/hyper-design/scripts/run-contract-evals.sh) printf 'run-contract-evals\tcontract-eval-run\n' ;;
    skills/hyper-design/scripts/run-detector-evals.sh) printf 'run-detector-evals\tdetector-eval-run\n' ;;
    skills/hyper-design/scripts/validate-report.sh) printf 'validate-report\treport-validation\n' ;;
    skills/hyper-design/scripts/validate-waivers.sh) printf 'validate-waivers\twaiver-validation\n' ;;
    skills/hyper-git/scripts/git-commit.sh) printf 'commit-files\tscoped-git-commit\n' ;;
    skills/hyper-git/scripts/git-fast.sh) printf 'commit-files\tfast-git-commit\n' ;;
    skills/hyper-git/scripts/git-push.sh) printf 'push-commit\tgit-push\n' ;;
    skills/hyper-git/scripts/repo-discover.sh) printf 'inspect-repository\trepository-discovery\n' ;;
    skills/hyper-git/scripts/repo-status.sh) printf 'inspect-repository\trepository-status\n' ;;
    skills/hyper-imagegen/scripts/validate-hyper-imagegen.sh) printf 'validate-skill\tskill-validation\n' ;;
    skills/hyper-architecture/scripts/validate-architecture.sh) printf 'validate-skill\tskill-validation\n' ;;
    skills/prd-maker/scripts/build-preview.sh) printf 'build-preview\tpreview-build\n' ;;
    skills/prd-maker/scripts/render-planning-map.sh) printf 'render-planning-map\tplanning-map-render\n' ;;
    skills/hyper-database/scripts/detect-engines.sh) printf 'detect-engines\tengine-detection\n' ;;
    skills/hyper-deploy/scripts/build-run.sh) printf 'run-build\tproject-build\n' ;;
    skills/hyper-deploy/scripts/deploy-check.sh) printf 'check-deployment\tdeployment-readiness-check\n' ;;
    skills/hyper-deploy/scripts/lint-check.sh) printf 'check-lint\tlint-readiness-check\n' ;;
    skills/hyper-deploy/scripts/pm-detect.sh) printf 'detect-package-manager\tpackage-manager-detection\n' ;;
    skills/hyper-deploy/scripts/stack-detect.sh) printf 'detect-stack\tstack-detection\n' ;;
    skills/hyper-google-tagmanager/scripts/gtm-container-audit.sh) printf 'audit-gtm-container\tgtm-container-audit\n' ;;
    skills/hyper-google-tagmanager/scripts/gtm-detect.sh) printf 'detect-gtm-install\tgtm-install-detection\n' ;;
    skills/hyper-google-tagmanager/scripts/gtm-site-check.sh) printf 'check-gtm-site\tgtm-site-check\n' ;;
    skills/hyper-seo/scripts/render-dashboard.sh) printf 'render-dashboard\trender-dashboard\n' ;;
    skills/hyper-skill/scripts/validate-hyper-skill.sh) printf 'validate-skill\tskill-validation\n' ;;
    skills/jev-maker/scripts/check-jev-request.sh) printf 'check-jev-request\tjev-request-validation\n' ;;
    *) : ;;
  esac
}

strip_edges() {
  local word=$1
  while [ -n "$word" ]; do
    case ${word:0:1} in
      '"' | "'" | '(') word=${word#?} ;;
      *) break ;;
    esac
  done
  while [ -n "$word" ]; do
    case ${word:${#word}-1:1} in
      '"' | "'" | ')') word=${word%?} ;;
      *) break ;;
    esac
  done
  STRIPPED=$word
}

strip_quotes() {
  local word=$1
  case $word in
    \"* | \'*) word=${word#?} ;;
  esac
  case $word in
    *\" | *\') word=${word%?} ;;
  esac
  STRIPPED=$word
}

is_command_start() {
  case $1 in
    if | then | else | elif | do | while | until | '!' | '&&' | '||' | ';' | '{' | '(') return 0 ;;
  esac
  return 1
}

check_contract_fixture() {
  local idx=$1 kind=$2 ftype=$3 ctype=$4 exec_ok=$5 args_ok=$6
  if [ "$ftype" != "object" ] || [ "$ctype" != "object" ]; then
    die "behavior contracts.rows[$idx].$kind requires a command"
  fi
  if [ "$exec_ok" != "1" ] || [ "$args_ok" != "1" ]; then
    die "behavior contracts.rows[$idx].$kind must execute the bash script with bash"
  fi
}

# Collect sourced basenames and referenced .sh basenames, mirroring scriptEdges().
collect_edges() {
  local file=$1
  : >"$tmp/sourced-raw"
  : >"$tmp/referenced-raw"
  # Comment lines are prose. echo/printf/Usage lines are printed text, not edges.
  awk '{
    line = $0
    sub(/^[ \t]+/, "", line)
    if (line ~ /^(echo|printf)([^A-Za-z0-9_]|$)/) next
    if (index(line, "Usage:") > 0) next
    print
  }' <(awk '!/^[[:space:]]*#/' "$file") >"$tmp/refs-code"

  local line nextchar
  local -a words
  local i n word stripped target
  while IFS= read -r line || [ -n "$line" ]; do
    case $line in
      *source* | *.sh*) : ;;
      *) continue ;;
    esac
    words=()
    read -r -a words <<<"$line"
    n=${#words[@]}
    i=0
    while [ "$i" -lt "$n" ]; do
      word=${words[$i]}
      strip_edges "$word"
      stripped=$STRIPPED
      if [ "$i" -eq 0 ] || is_command_start "${words[$((i - 1))]}"; then
        if [ "$stripped" = "source" ] || [ "$stripped" = "." ]; then
          if [ "$((i + 1))" -lt "$n" ]; then
            strip_quotes "${words[$((i + 1))]}"
            target=$STRIPPED
            case $target in
              *.sh) printf '%s\n' "${target##*/}" >>"$tmp/sourced-raw" ;;
            esac
          fi
        fi
      fi
      i=$((i + 1))
    done
  done <"$tmp/refs-code"

  local hits hit off name prev trail refs_text
  hits=$(grep -boE '[A-Za-z0-9_.-]+\.sh' "$tmp/refs-code" || true)
  refs_text=$(cat "$tmp/refs-code")
  if [ -n "$hits" ]; then
    while IFS= read -r hit; do
      off=${hit%%:*}
      name=${hit#*:}
      [ -n "$name" ] || continue
      prev=
      if [ "$off" -gt 0 ]; then
        prev=${refs_text:$((off - 1)):1}
      fi
      trail=1
      nextchar=${refs_text:$((off + ${#name})):1}
      case $nextchar in
        [A-Za-z0-9_]) trail=0 ;;
      esac
      if [ "$trail" -eq 1 ]; then
        case $prev in
          '' | [[:space:]] | '"' | "'" | '`' | '(' | '=' | ':' | '/') printf '%s\n' "$name" >>"$tmp/referenced-raw" ;;
        esac
      fi
    done <<<"$hits"
  fi

  sort -u "$tmp/sourced-raw" >"$tmp/sourced"
  sort -u "$tmp/referenced-raw" >"$tmp/referenced"
}

validate_bash_policy() {
  local file=$1 abs=$2 code=$tmp/policy-code
  local first_line
  first_line=$(head -n 1 "$abs")
  first_line=${first_line%$'\r'}
  if [ "$first_line" != "#!/usr/bin/env bash" ] || [ "$(wc -l <"$abs")" -lt 1 ]; then
    die "$file must use the bash shebang"
  fi
  file_mode_executable "$abs" || die "$file must be executable"
  code_lines_file "$abs" "$code"

  local eval_re interp_re upper_re lower_re declare_a_re declare_n_re wait_n_re
  eval_re="(^|[;&|(\`]|\\\$\\()[[:space:]]*eval([[:space:]\"'\$])"
  interp_re="(^|[;&|(\`]|\\\$\\()[[:space:]]*(bun|node|nodejs|deno|python[0-9.]*|perl|ruby)[[:space:]]+([^;&|]*\.(mjs|cjs|js|mts|cts|ts|py|rb|pl)([^A-Za-z0-9_]|\$)|(-e|-c|--eval)([^A-Za-z0-9_]|\$))"
  upper_re="\\\$\\{[A-Za-z_][A-Za-z0-9_]*\\^\\^?[^}]*\\}"
  lower_re="\\\$\\{[A-Za-z_][A-Za-z0-9_]*,,?[^}]*\\}"
  declare_a_re="^[ \t]*declare[ \t]+-A([^A-Za-z0-9_]|\$)"
  declare_n_re="^[ \t]*declare[ \t]+-n([^A-Za-z0-9_]|\$)"
  wait_n_re="(^|[^A-Za-z0-9_])wait[ \t]+-n([^A-Za-z0-9_]|\$)"

  grep -Eq "$eval_re" "$code" && die "$file must not use eval"
  grep -Eq "$interp_re" "$code" && die "$file must not run JavaScript or Python interpreters on a script"
  grep -Eq "$declare_a_re" "$code" && die "$file must not use bash 4 associative arrays"
  grep -Eq '(^|[^A-Za-z0-9_])(mapfile|readarray)([^A-Za-z0-9_]|$)' "$code" && die "$file must not use bash 4 array readers"
  grep -Eq "$upper_re" "$code" && die "$file must not use bash 4 case conversion"
  grep -Eq "$lower_re" "$code" && die "$file must not use bash 4 case conversion"
  if grep -Eq "$declare_n_re" "$code" ||
    grep -Eq "$wait_n_re" "$code" ||
    grep -Eq '\|&' "$code" ||
    grep -Eq '&>>' "$code"; then
    die "$file must not use bash 4-only constructs"
  fi
}

validate_script_edges() {
  local file=$1 own=$2
  collect_edges "$root/$file"
  approved_sources "$file" | sort -u >"$tmp/approved-sources"
  if ! same_list "$tmp/sourced" "$tmp/approved-sources"; then
    die "$file must not source unapproved local scripts"
  fi
  approved_child_scripts "$file" | sort -u >"$tmp/approved-children"
  if [ -s "$tmp/sourced" ]; then
    grep -vxF -f "$tmp/sourced" "$tmp/referenced" >"$tmp/invoked-raw" || true
  else
    cp "$tmp/referenced" "$tmp/invoked-raw"
  fi
  grep -vxF -- "$own" "$tmp/invoked-raw" >"$tmp/invoked" || true
  if ! same_list "$tmp/invoked" "$tmp/approved-children"; then
    die "$file must not invoke unapproved sibling scripts"
  fi
}

# ---------------------------------------------------------------------------
# Manifest shape and rows
# ---------------------------------------------------------------------------

jq -e 'type == "object"' "$manifest" >/dev/null 2>&1 || die "manifest must be a JSON object"
jq -e '(.scripts | type) == "array"' "$manifest" >/dev/null 2>&1 || die "manifest scripts must be an array"
row_count=$(jq -r '.scripts | length' "$manifest")
[ "$row_count" -eq 34 ] || die "manifest must contain exactly 34 scripts"
jq -e 'all(.scripts[]; type == "object")' "$manifest" >/dev/null 2>&1 || die "manifest rows must be objects"

legacy_origins=$(printf '%s\n' former-sh former-py retained-mjs authored-mjs)
usage_enum=$(printf '%s\n' analyze-structure audit-gtm-container build-preview check-deployment check-gtm-site check-jev-request check-lint collect-rendered-evidence commit-files detect-engines detect-gtm-install detect-package-manager detect-slop detect-stack inspect-repository push-commit render-dashboard render-planning-map resolve-context run-build run-contract-evals run-detector-evals slop-engine-css slop-engine-markup slop-engine-text slop-rule-registry slop-rule-shared validate-report validate-skill validate-waivers)
behavior_enum=$(printf '%s\n' context-resolution contract-eval-run deployment-readiness-check detector-eval-run engine-detection fast-git-commit git-push gtm-container-audit gtm-install-detection gtm-site-check jev-request-validation lint-readiness-check package-manager-detection planning-map-render preview-build project-build render-dashboard rendered-evidence-collection report-validation repository-discovery repository-status scoped-git-commit skill-validation slop-detection slop-engine-css slop-engine-markup slop-engine-text slop-rule-registry slop-rule-shared stack-detection structure-analysis waiver-validation)

former_sh=0
former_py=0
retained_mjs=0
authored_mjs=0

legacy_base=$(jq -r '.legacyPreimageBase' "$manifest")
cat >"$tmp/manifest-rows.jq" <<'JQ'
.scripts | to_entries[] |
.key as $i | .value as $r |
($r | if type == "object" then . else {} end) as $o |
($o.sourcePreimage | if type == "object" then . else {} end) as $p |
[
  ($i | tostring),
  ($r | type),
  (["path", "family", "legacyOrigin", "usage", "behavior"] | map(if (($o[.] | type) == "string" and (($o[.] | test("^\\s*$")) | not)) then "1" else "0" end) | join("")),
  (if ($o.path | type) == "string" then $o.path else "" end),
  (if ($o.family | type) == "string" then $o.family else "" end),
  (if ($o.legacyOrigin | type) == "string" then $o.legacyOrigin else "" end),
  (if ($o.usage | type) == "string" then $o.usage else "" end),
  (if ($o.behavior | type) == "string" then $o.behavior else "" end),
  ($p | type),
  (if ($p.path | type) == "string" then $p.path else "" end),
  (if (($p.path | type) == "string") and ((($p.path | test("^\\s*$")) | not)) then "1" else "0" end),
  (if ($p.sha256 | type) == "string" then $p.sha256 else "" end),
  (if ($p.gitMode | type) == "string" then $p.gitMode else "" end),
  (if ($p.baselineAbsence | type) == "object" then "object" else ($p.baselineAbsence | type) end),
  (if ($p.baselineAbsence.baselineRef | type) == "string" then $p.baselineAbsence.baselineRef else "" end),
  (if ($p.baselineAbsence.path | type) == "string" then $p.baselineAbsence.path else "" end),
  (if ($p.baselineAbsence.absent == true) then "1" else "0" end),
  (if ($o.behaviorContractId | type) == "string" then $o.behaviorContractId else "" end),
  (if (($o.behaviorContractId | type) == "string") and ((($o.behaviorContractId | test("^\\s*$")) | not)) then "1" else "0" end)
] | join("\u001f")
JQ
jq -r -f "$tmp/manifest-rows.jq" "$manifest" >"$tmp/manifest-rows.tsv"

required_fields='path family legacyOrigin usage behavior'
i=0
while IFS=$'\x1f' read -r idx rtype field_ok path family legacy usage behavior sp_type _source_path source_path_ok source_sha source_mode abs_type abs_ref abs_path abs_absent _contract_id contract_id_ok; do
  j=0
  for field in $required_fields; do
    if [ "${field_ok:$j:1}" != "1" ]; then
      die "manifest scripts[$idx].$field must be a non-empty string"
    fi
    j=$((j + 1))
  done
  in_set "$legacy" "$legacy_origins" || die "manifest scripts[$idx].legacyOrigin must be an approved enum value"
  in_set "$usage" "$usage_enum" || die "manifest scripts[$idx].usage must be an approved enum value"
  in_set "$behavior" "$behavior_enum" || die "manifest scripts[$idx].behavior must be an approved enum value"
  base=${path##*/}
  [ "$path" = "skills/$family/scripts/$base" ] || die "manifest scripts[$idx] path/family must agree"
  case $path in
    *.sh) : ;;
    *) die "manifest scripts[$idx] path must be a bash script" ;;
  esac
  meta=$(metadata_for "$path")
  expected_usage=${meta%%$'\t'*}
  expected_behavior=${meta#*$'\t'}
  if [ -z "$meta" ] || [ "$usage" != "$expected_usage" ] || [ "$behavior" != "$expected_behavior" ]; then
    die "manifest scripts[$idx] metadata must match its concrete path mapping"
  fi
  case $legacy in
    former-sh) former_sh=$((former_sh + 1)) ;;
    former-py) former_py=$((former_py + 1)) ;;
    retained-mjs) retained_mjs=$((retained_mjs + 1)) ;;
    authored-mjs) authored_mjs=$((authored_mjs + 1)) ;;
  esac
  [ "$sp_type" = "object" ] || die "manifest scripts[$idx] requires source provenance evidence"
  if [ "$legacy" = "authored-mjs" ]; then
    mjs_path=${path%.sh}.mjs
    if [ "$abs_type" != "object" ] || [ "$abs_ref" != "$legacy_base" ] || [ "$abs_path" != "$mjs_path" ] || [ "$abs_absent" != "1" ]; then
      die "manifest scripts[$idx] requires baseline-absence proof for its historical MJS path"
    fi
  else
    if [ "$source_path_ok" != "1" ] ||
      ! grep -Eq '^[a-f0-9]{64}$' <<<"$source_sha" ||
      { [ "$source_mode" != "100755" ] && [ "$source_mode" != "100644" ]; }; then
      die "manifest scripts[$idx] requires concrete historical source preimage evidence"
    fi
  fi
  [ "$contract_id_ok" = "1" ] || die "manifest scripts[$idx] requires a behavior contract id"
  i=$((i + 1))
done <"$tmp/manifest-rows.tsv"

[ "$former_sh" -eq 11 ] && [ "$former_py" -eq 0 ] && [ "$retained_mjs" -eq 4 ] && [ "$authored_mjs" -eq 19 ] ||
  die "manifest historical origin counts must be exactly 11/0/4/19"

if ! jq -e '.portPreimage | (type == "object") and (.baselineRef | type == "string" and test("^[a-f0-9]{40}$")) and (.model | type == "string" and test("\\S")) and (.note | type == "string" and test("\\S")) and (.workingTreeEdited | type == "array" and length == 4)' "$manifest" >/dev/null 2>&1; then
  die "manifest portPreimage must record the port baseline and the uncommitted pre-port edits"
fi

jq -r '.scripts[].path' "$manifest" >"$tmp/approved"
sort "$tmp/approved" | uniq -d >"$tmp/approved-dupes"
[ ! -s "$tmp/approved-dupes" ] || die "manifest script paths must be unique"

# ---------------------------------------------------------------------------
# Behavior contracts
# ---------------------------------------------------------------------------

jq -e 'type == "object"' "$contracts" >/dev/null 2>&1 || die "behavior contracts must be a JSON object"
[ "$(jq -r '.requiredBy' "$contracts")" = "scripts/fixtures/skill-script-parity/manifest.json" ] ||
  die "behavior contracts must name the manifest as their central owner"
if ! jq -e '(.coverage | type == "object") and .coverage.expectedRows == 34 and .coverage.expectedFixtures == 102' "$contracts" >/dev/null 2>&1; then
  die "behavior contract coverage must be exactly 34 rows and 102 fixtures"
fi
contract_rows=$(jq -r '.rows | length' "$contracts")
[ "$contract_rows" -eq 34 ] || die "behavior contracts must contain exactly 34 rows"

jq -r '.scripts[] | [(.path // ""), (.behaviorContractId // "")] | join("\u001f")' "$manifest" >"$tmp/script-contract-ids"
cat >"$tmp/contract-rows.jq" <<'JQ'
.rows | to_entries[] |
.key as $i | .value as $r |
($r | if type == "object" then . else {} end) as $o |
($o.fixtures | if type == "object" then . else {} end) as $f |
($f.happy | if type == "object" then (.command | if type == "object" then . else {} end) else {} end) as $hc |
($f.malformed | if type == "object" then (.command | if type == "object" then . else {} end) else {} end) as $mc |
($f.familyEdge | if type == "object" then (.command | if type == "object" then . else {} end) else {} end) as $ec |
[
  ($i | tostring),
  ($r | type),
  (if (($o.path | type) == "string") and ((($o.path | test("^\\s*$")) | not)) then "1" else "0" end),
  (if ($o.path | type) == "string" then $o.path else "" end),
  (if (($o.id | type) == "string") and ((($o.id | test("^\\s*$")) | not)) then "1" else "0" end),
  (if ($o.id | type) == "string" then $o.id else "" end),
  ($o.fixtures | type),
  (if ($o.fixtures | type) == "object" then ($o.fixtures | keys | join(",")) else "" end),
  ($f.happy | type),
  (if ($f.happy | type) == "object" then ($f.happy.command | type) else "" end),
  (if $hc.executable == "bash" then "1" else "0" end),
  (if ($hc.arguments | type) == "array" then (if (($hc.arguments | length) == 1) and ($hc.arguments[0] == $o.path) then "1" else "0" end) else "0" end),
  ($f.malformed | type),
  (if ($f.malformed | type) == "object" then ($f.malformed.command | type) else "" end),
  (if $mc.executable == "bash" then "1" else "0" end),
  (if ($mc.arguments | type) == "array" then (if (($mc.arguments | length) == 1) and ($mc.arguments[0] == $o.path) then "1" else "0" end) else "0" end),
  ($f.familyEdge | type),
  (if ($f.familyEdge | type) == "object" then ($f.familyEdge.command | type) else "" end),
  (if $ec.executable == "bash" then "1" else "0" end),
  (if ($ec.arguments | type) == "array" then (if (($ec.arguments | length) == 1) and ($ec.arguments[0] == $o.path) then "1" else "0" end) else "0" end)
] | join("\u001f")
JQ
jq -r -f "$tmp/contract-rows.jq" "$contracts" >"$tmp/contract-rows.tsv"

while IFS=$'\x1f' read -r cidx rtype path_ok cpath id_ok cid ftype keys hft hct hexec hargs mft mct mexec margs eft ect eexec eargs; do
  if [ "$rtype" != "object" ] || [ "$path_ok" != "1" ] || [ "$id_ok" != "1" ] || [ "$ftype" != "object" ]; then
    die "behavior contracts.rows[$cidx] must be a complete row"
  fi
  contract_row_id=$(awk -F '\037' -v p="$cpath" '$1 == p { print $2; exit }' "$tmp/script-contract-ids")
  if [ -z "$contract_row_id" ] || [ "$cid" != "$contract_row_id" ]; then
    die "behavior contracts.rows[$cidx] must match its manifest row"
  fi
  if [ "$keys" != "familyEdge,happy,malformed" ]; then
    die "behavior contracts.rows[$cidx] must contain exactly three fixture kinds"
  fi
  check_contract_fixture "$cidx" happy "$hft" "$hct" "$hexec" "$hargs"
  check_contract_fixture "$cidx" malformed "$mft" "$mct" "$mexec" "$margs"
  check_contract_fixture "$cidx" familyEdge "$eft" "$ect" "$eexec" "$eargs"
done <"$tmp/contract-rows.tsv"

# ---------------------------------------------------------------------------
# Forbidden detector references
# ---------------------------------------------------------------------------

if ! jq -e '(.forbiddenDetectorReferences | type == "object") and (.forbiddenDetectorReferences.records | type == "array")' "$manifest" >/dev/null 2>&1; then
  die "manifest forbiddenDetectorReferences.records must be an array"
fi
record_count=$(jq -r '.forbiddenDetectorReferences.records | length' "$manifest")
if [ "$record_count" -ne 6 ] || ! jq -e 'all(.forbiddenDetectorReferences.records[]; type == "object")' "$manifest" >/dev/null 2>&1; then
  die "forbidden detector records must contain the exact six policy literals"
fi
jq -r '.forbiddenDetectorReferences.records[].literal' "$manifest" >"$tmp/forbidden"
if grep -q '^$' "$tmp/forbidden"; then
  die "every forbidden detector record requires a literal"
fi
sort "$tmp/forbidden" | uniq -d >"$tmp/forbidden-dupes"
[ ! -s "$tmp/forbidden-dupes" ] || die "forbidden detector literals must be unique"
printf '%s\n' git-commit-detect .agents/skills/git-commit .claude/skills/git-commit .codex/skills/git-commit 'installed|' 'missing|' | sort -u >"$tmp/forbidden-expected"
same_list "$tmp/forbidden" "$tmp/forbidden-expected" || die "forbidden detector literal set must match the validator-owned contract"
jq -r '.forbiddenDetectorReferences.scanTargets[]' "$manifest" | sort -u >"$tmp/scan-targets"
printf '%s\n' scripts/fixtures/skill-script-parity/behavior | sort -u >"$tmp/scan-targets-expected"
same_list "$tmp/scan-targets" "$tmp/scan-targets-expected" || die "forbidden detector scan targets must be exact"
jq -r '.forbiddenDetectorReferences.enforcementFiles[]' "$manifest" | sort -u >"$tmp/enforcement"
printf '%s\n' scripts/fixtures/skill-script-parity/manifest.json scripts/validate-skills.mjs scripts/tests/skill-scripts.test.mjs | sort -u >"$tmp/enforcement-expected"
same_list "$tmp/enforcement" "$tmp/enforcement-expected" || die "forbidden detector enforcement files must be exact"

ri=0
while [ "$ri" -lt "$record_count" ]; do
  literal=$(jq -r ".forbiddenDetectorReferences.records[$ri].literal" "$manifest")
  if ! jq -e ".forbiddenDetectorReferences.records[$ri].allowedLocations | (type == \"array\") and (length == 1)" "$manifest" >/dev/null 2>&1; then
    die "forbidden literal $literal requires one enforcement location"
  fi
  if ! jq -e ".forbiddenDetectorReferences.records[$ri].allowedLocations[0] | (type == \"object\") and (.file == \"scripts/fixtures/skill-script-parity/manifest.json\") and (.jsonPath == \"\$.forbiddenDetectorReferences.records[*].literal\")" "$manifest" >/dev/null 2>&1; then
    die "forbidden literal $literal enforcement location must be exact"
  fi
  occurrences=$(grep -oF -- "$literal" "$manifest" | wc -l)
  [ "$occurrences" -eq 1 ] || die "forbidden literal $literal must occur only in its declared manifest data location"
  ri=$((ri + 1))
done

# ---------------------------------------------------------------------------
# Inventory: only bash scripts, exactly the manifest paths
# ---------------------------------------------------------------------------

(cd "$root" && find skills -type f) | sort >"$tmp/all-skill-files"
grep -E '\.sh$' "$tmp/all-skill-files" >"$tmp/sh-files" || true
grep -E '/scripts/.*\.(mjs|cjs|js|py|rb)$' "$tmp/all-skill-files" >"$tmp/retired-files" || true
if [ -s "$tmp/retired-files" ]; then
  retired_list=$(awk 'BEGIN { first = 1 } { if (!first) printf ", "; printf "%s", $0; first = 0 }' "$tmp/retired-files")
  die "skill script directories must contain only bash scripts: $retired_list"
fi
same_list "$tmp/sh-files" "$tmp/approved" || die "bash inventory must exactly match the manifest"

# ---------------------------------------------------------------------------
# Forbidden-reference scan and per-script policy
# ---------------------------------------------------------------------------

while IFS= read -r target; do
  [ -e "$root/$target" ] || die "required forbidden-reference scan target is missing: $target"
  find "$root/$target" -type f >"$tmp/audit-files"
  while IFS= read -r audit; do
    [ -f "$audit" ] || continue
    rel=${audit#"$root"/}
    while IFS= read -r literal; do
      grep -Fq -- "$literal" "$audit" && die "forbidden detector reference outside enforcement data: $rel: $literal"
    done <"$tmp/forbidden"
  done <"$tmp/audit-files"
done <"$tmp/scan-targets"

while IFS= read -r file; do
  abs=$root/$file
  [ -f "$abs" ] || die "$file is missing"
  validate_bash_policy "$file" "$abs"
  own=${file##*/}
  validate_script_edges "$file" "$own"
  legacy=$(jq -r ".scripts[] | select(.path == \"$file\") | .legacyOrigin" "$manifest")
  if [ "$legacy" = "authored-mjs" ]; then
    baseline_path=${file%.sh}.mjs
    if git -C "$root" cat-file -e "990359457e2ccbf2bd4bb65065037d456c5940bc:$baseline_path" >/dev/null 2>&1; then
      die "$file historical MJS path must be absent from immutable baseline"
    fi
  fi
done <"$tmp/approved"

printf 'Validated %s bash skill scripts (11 former-sh, 0 former-py, 4 retained-mjs, 19 authored-mjs historical origins).\n' "$(wc -l <"$tmp/approved" | tr -d ' ')"
