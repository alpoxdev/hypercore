#!/usr/bin/env bash
# Bash port of scripts/tests/skill-scripts.test.mjs.
#
# Exercises the immutable skill-script inventory, the behavior contracts, and the
# bundled bash scripts under skills/. Every case keeps the original bun test title.
# Requires bash 3.2+, POSIX tools, jq, and git. The inventory validator is the
# bash port scripts/check-skill-corpus.sh; set HYPERCORE_VALIDATE_SKILLS to run
# a different bash validator instead.
set -uo pipefail

# shellcheck source=/dev/null
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
SCRIPTS=${HYPERCORE_SCRIPTS_DIR:-$ROOT/scripts}
FIXTURES=$SCRIPTS/fixtures/skill-script-parity
MANIFEST=$FIXTURES/manifest.json
CONTRACTS=$FIXTURES/behavior/contracts.json
LEGACY_REF=990359457e2ccbf2bd4bb65065037d456c5940bc
MIGRATION_REF=d648cf6eeba28402f0b3c1265ca5d9f05995a131

DEPLOY_CHECK=$ROOT/skills/hyper-deploy/scripts/deploy-check.sh
HYPER_GIT_COMMIT=$ROOT/skills/hyper-git/scripts/git-commit.sh
REPO_DISCOVER=$ROOT/skills/hyper-git/scripts/repo-discover.sh
REPO_STATUS=$ROOT/skills/hyper-git/scripts/repo-status.sh
HYPER_GIT_FAST=$ROOT/skills/hyper-git/scripts/git-fast.sh

# Pre-migration preimages keyed by the renamed script's current path, exactly as
# the bun test pins them. Columns: current path, from path, sha256, mode, ref.
MIGRATION_PREIMAGES=$(
  cat <<'TSV'
skills/hyper-design/scripts/analyze-structure.sh	skills/ai-design-slop-remover/scripts/analyze-structure.cjs	9b379e486755ea09729d7b52097718868ef8817dbb4e9169e9bcab34152eb8d0	100644	migrationPreimageRef
skills/hyper-design/scripts/collect-rendered-evidence.sh	skills/ai-design-slop-remover/scripts/collect-rendered-evidence.cjs	562f561401694e9e8b0377a88e0a48884812929ca50c7c6e202896119ab1d7a3	100644	migrationPreimageRef
skills/hyper-design/scripts/detect-slop.sh	skills/ai-design-slop-remover/scripts/detect-slop.cjs	17e5c21a8eec75f0f4638196f67aca8de0bf5ff49b6bb6ff71c9d156e56e847a	100644	migrationPreimageRef
skills/hyper-design/scripts/engine-css.sh	skills/ai-design-slop-remover/scripts/engines/css.cjs	2cc502ed2086a4ff293a153e7981da7738dc019cbd3fd0d64ce1da1418d7a03c	100644	migrationPreimageRef
skills/hyper-design/scripts/engine-markup.sh	skills/ai-design-slop-remover/scripts/engines/markup.cjs	d283db47e8a7464a29a08ad2035e77e46a895a11693eb4b40842628caff06161	100644	migrationPreimageRef
skills/hyper-design/scripts/engine-text.sh	skills/ai-design-slop-remover/scripts/engines/text.cjs	d892fa19e78bc785631ec8ca0d472566a160898b035345a9c9136db49c91a7df	100644	migrationPreimageRef
skills/hyper-design/scripts/resolve-context.sh	skills/ai-design-slop-remover/scripts/resolve-context.cjs	4cd95ded813c423e0c3deba3e4af9240d38e4c88d5ca6e15e5be9fae5f8a27cc	100644	migrationPreimageRef
skills/hyper-design/scripts/rule-registry.sh	skills/ai-design-slop-remover/scripts/rules/registry.cjs	67492b55d8417e73ecdad9b32de902aca674cdd576f7cc9f920c595f8694db05	100644	migrationPreimageRef
skills/hyper-design/scripts/rule-shared.sh	skills/ai-design-slop-remover/scripts/rules/shared.cjs	0d4f0fec0192872ec25a459426ceae5707c45befa71a203de21a12f4088a40ce	100644	migrationPreimageRef
skills/hyper-design/scripts/run-contract-evals.sh	skills/ai-design-slop-remover/scripts/run-contract-evals.cjs	f9d5abe484d028aebcd7dad92e90dbc77ee6144f9ee96db98cb9393d5c7bca5b	100644	migrationPreimageRef
skills/hyper-design/scripts/run-detector-evals.sh	skills/ai-design-slop-remover/scripts/run-detector-evals.cjs	fddb35e5a47670733d2b85f657b88e6136d0bad7482d3e652bd3129466c4dbf4	100644	migrationPreimageRef
skills/hyper-design/scripts/validate-report.sh	skills/ai-design-slop-remover/scripts/validate-report.cjs	0876b9f0c9291cc590c406fb6552363de33303b9fdb244dfcd940d85798c7d1f	100644	migrationPreimageRef
skills/hyper-design/scripts/validate-waivers.sh	skills/ai-design-slop-remover/scripts/validate-waivers.cjs	f288eaeca8342136488d50ba456dfc00acc2fa78177ce356cb9256691075f1f7	100644	migrationPreimageRef
TSV
)

# The inventory validator is the bash port of the former validate-skills.mjs;
# HYPERCORE_VALIDATE_SKILLS can point the two validator cases at another bash port.
VALIDATOR_KIND=bash
VALIDATOR_SRC=$SCRIPTS/check-skill-corpus.sh
VALIDATOR_REL=scripts/check-skill-corpus.sh
if [ -n "${HYPERCORE_VALIDATE_SKILLS:-}" ]; then
  VALIDATOR_SRC=$HYPERCORE_VALIDATE_SKILLS
  VALIDATOR_REL=scripts/$(basename "$HYPERCORE_VALIDATE_SKILLS")
fi

# ---- generic helpers ------------------------------------------------------

# new_workdir with repeated slashes collapsed: TMPDIR often ends in a slash, and
# the scripts under test print the normalized form via pwd.
workdir() {
  new_workdir | sed 's#//*#/#g'
}

sha256_stream() { # stdin
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | cut -d' ' -f1
  else
    shasum -a 256 | cut -d' ' -f1
  fi
}

sha256_of() { # <file>
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

file_mode() { # <file>
  if [ "$(uname -s)" = Darwin ]; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

run_in() { # <cwd> <stdout> <stderr> <command...> — prints the exit code
  local cwd=$1 out=$2 err=$3
  shift 3
  local rc=0
  ( cd "$cwd" && "$@" ) >"$out" 2>"$err" || rc=$?
  printf '%s' "$rc"
}

# Mirrors normalizeOutput() from the bun suite.
normalize_output() { # <file> <cwd>
  local file=$1 cwd=$2
  sed -E \
    -e "s#$ROOT#<repo>#g" \
    -e "s#/private$cwd#<cwd>#g" \
    -e "s#$cwd#<cwd>#g" \
    -e "s#/(Users|home)/[^/]*(/[^:\"' )]*)*#<absolute-path>#g" \
    -e "s#Bun v[0-9.]+ \([^)]*\)#Bun v<version> (<os> <arch>)#g" \
    -e "s#:[0-9]+:[0-9]+#:<line>:<column>#g" \
    "$file"
}

# Mirrors observableFiles() file-content normalization.
normalize_observable_file() { # <file> <cwd>
  local file=$1 cwd=$2
  sed -E \
    -e "s#$cwd#<cwd>#g" \
    -e "s#[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z#<timestamp>#g" \
    "$file"
}

# snapshot_observables <cwd> <files.tsv> <modes.tsv> <scratch-dir>
# Writes "path<TAB>bytes<TAB>sha256" and "path<TAB>mode" for every regular file.
snapshot_observables() {
  local cwd=$1 files_out=$2 modes_out=$3 scratch=$4
  local rel norm bytes sha mode list
  : >"$files_out"
  : >"$modes_out"
  list=$scratch/file-list
  ( cd "$cwd" && find . -type f -print ) | sed 's#^\./##' | LC_ALL=C sort >"$list"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    norm=$scratch/norm.$$
    normalize_observable_file "$cwd/$rel" "$cwd" >"$norm"
    bytes=$(wc -c <"$norm" | tr -d ' ')
    sha=$(sha256_of "$norm")
    printf '%s\t%s\t%s\n' "$rel" "$bytes" "$sha" >>"$files_out"
    mode=$(file_mode "$cwd/$rel")
    printf '%s\t%s\n' "$rel" "$mode" >>"$modes_out"
    rm -f "$norm"
  done <"$list"
  LC_ALL=C sort -t "$(printf '\t')" -k1,1 "$modes_out" -o "$modes_out"
}

expected_files_tsv() { # <row-index> <kind>
  jq -r --argjson r "$1" --arg k "$2" \
    '.rows[$r].fixtures[$k].expected.files | sort_by(.path)[] | [.path, (.bytes|tostring), .sha256] | @tsv' \
    "$CONTRACTS"
}

expected_modes_tsv() { # <row-index> <kind>
  jq -r --argjson r "$1" --arg k "$2" \
    '.rows[$r].fixtures[$k].expected.modes | to_entries | sort_by(.key)[] | [.key, .value] | @tsv' \
    "$CONTRACTS"
}

materialize_fixture() { # <row-index> <kind> <cwd>
  local row=$1 kind=$2 cwd=$3
  local i=0 n p m
  n=$(jq --argjson r "$row" --arg k "$kind" '.rows[$r].fixtures[$k].input.files | length' "$CONTRACTS")
  while [ "$i" -lt "$n" ]; do
    p=$(jq -r --argjson r "$row" --arg k "$kind" --argjson i "$i" '.rows[$r].fixtures[$k].input.files[$i].path' "$CONTRACTS")
    mkdir -p "$(dirname "$cwd/$p")"
    jq -j --argjson r "$row" --arg k "$kind" --argjson i "$i" '.rows[$r].fixtures[$k].input.files[$i].text | @base64' "$CONTRACTS" \
      | openssl base64 -d -A >"$cwd/$p"
    m=$(jq -r --argjson r "$row" --arg k "$kind" --argjson i "$i" '.rows[$r].fixtures[$k].input.files[$i].mode // empty' "$CONTRACTS")
    if [ -n "$m" ]; then
      chmod "$m" "$cwd/$p"
    fi
    i=$((i + 1))
  done
}

# The legacy fake git the contracts use for scripts that shell out to git.
# shellcheck disable=SC2016
CONTRACT_FAKE_GIT='#!/bin/sh
case "$1" in rev-parse) pwd;; status) echo "## fixture";; diff) exit 0;; *) exit 0;; esac
'

run_contract_fixture() { # <row-index> <kind> <cwd> <stdout> <stderr> — prints exit code
  local row=$1 kind=$2 cwd=$3 out=$4 err=$5
  local script argv=() envargs=(NO_COLOR=1)
  local i=0 n fake
  script=$(jq -r --argjson r "$row" '.rows[$r].path' "$CONTRACTS")
  n=$(jq --argjson r "$row" --arg k "$kind" '.rows[$r].fixtures[$k].input.argv | length' "$CONTRACTS")
  while [ "$i" -lt "$n" ]; do
    argv+=("$(jq -r --argjson r "$row" --arg k "$kind" --argjson i "$i" '.rows[$r].fixtures[$k].input.argv[$i]' "$CONTRACTS")")
    i=$((i + 1))
  done
  fake=$(jq -r --argjson r "$row" --arg k "$kind" '.rows[$r].fixtures[$k].input.fakeGit // false' "$CONTRACTS")
  if [ "$fake" = true ]; then
    mkdir -p "$cwd/bin"
    printf '%s' "$CONTRACT_FAKE_GIT" >"$cwd/bin/git"
    chmod 755 "$cwd/bin/git"
    envargs+=("PATH=$cwd/bin:$PATH")
  fi
  run_in "$cwd" "$out" "$err" env "${envargs[@]}" bash "$ROOT/$script" ${argv[@]+"${argv[@]}"}
}

# expect_fixture_output <expected-json-object-file> <actual> <label>
expect_fixture_output() {
  local expected=$1 actual=$2 label=$3
  local equals_file
  equals_file=$(dirname "$actual")/expected-output
  if jq -e 'has("equals")' "$expected" >/dev/null 2>&1; then
    jq -j '.equals' "$expected" >"$equals_file"
    if ! cmp -s "$equals_file" "$actual"; then
      fail "$label: expected $(jq -c '.equals' "$expected"), got $(cat "$actual")"
      return 1
    fi
  else
    local needle
    while IFS= read -r needle; do
      assert_contains "$(cat "$actual")" "$needle" "$label"
    done < <(jq -r '.contains[]' "$expected")
  fi
}

# expect_migration_evidence <script path> <migration json>
expect_migration_evidence() {
  local path=$1 migration=$2 expected row
  expected=$(printf '%s\n' "$MIGRATION_PREIMAGES" | awk -F'\t' -v p="$path" '$1 == p { print; exit }')
  expected=$(printf '%s' "$expected" | sed "s/migrationPreimageRef/$MIGRATION_REF/")
  [ -n "$expected" ] || { fail "migration evidence missing from the pinned map: $path"; return 1; }
  row=$(printf '%s\t%s\t%s\t%s\t%s' \
    "$path" \
    "$(printf '%s' "$migration" | jq -r '.fromPath')" \
    "$(printf '%s' "$migration" | jq -r '.fromSha256')" \
    "$(printf '%s' "$migration" | jq -r '.fromMode')" \
    "$(printf '%s' "$migration" | jq -r '.fromRef')")
  assert_eq "$expected" "$row" "migration evidence for $path"

  local ref from blob out
  ref=$(printf '%s' "$migration" | jq -r '.fromRef')
  from=$(printf '%s' "$migration" | jq -r '.fromPath')
  out=$(workdir)
  blob=$out/blob
  git -C "$ROOT" show "$ref:$from" >"$blob" || { fail "git show $ref:$from failed"; return 1; }
  assert_eq "$(printf '%s' "$migration" | jq -r '.fromSha256')" "$(sha256_of "$blob")" "migrated blob sha for $path"

  git -C "$ROOT" ls-tree "$ref" -- "$from" >"$out/tree"
  local mode type tree_path
  mode=$(cut -d' ' -f1 <"$out/tree")
  type=$(cut -d' ' -f2 <"$out/tree")
  tree_path=$(cut -f2 <"$out/tree")
  assert_eq "$(printf '%s' "$migration" | jq -r '.fromMode')" "$mode" "migration tree mode for $path"
  assert_eq "blob" "$type" "migration tree type for $path"
  assert_eq "$from" "$tree_path" "migration tree path for $path"
}

# install_validator <fixture dir> — mirrors the bun fixture's scripts/ layout.
install_validator() {
  local fixture=$1
  mkdir -p "$fixture/scripts"
  cp "$VALIDATOR_SRC" "$fixture/$VALIDATOR_REL"
  cp -R "$SCRIPTS/fixtures" "$fixture/scripts/fixtures"
  if [ -d "$SCRIPTS/lib" ]; then
    cp -R "$SCRIPTS/lib" "$fixture/scripts/lib"
  fi
  chmod 755 "$fixture/$VALIDATOR_REL"
}

run_installed_validator() { # <fixture> <stdout> <stderr> — prints exit code
  if [ "$VALIDATOR_KIND" = bash ]; then
    run_in "$1" "$2" "$3" bash "$VALIDATOR_REL"
  else
    run_in "$1" "$2" "$3" node "$VALIDATOR_REL"
  fi
}

run_repo_validator() { # <stdout> <stderr> — prints exit code
  if [ "$VALIDATOR_KIND" = bash ]; then
    run_in "$ROOT" "$1" "$2" bash "$VALIDATOR_SRC"
  else
    run_in "$ROOT" "$1" "$2" node "$VALIDATOR_SRC"
  fi
}

# ---- cases ----------------------------------------------------------------

case_manifest_inventory() {
  require_cmd jq
  require_cmd git
  assert_eq 35 "$(jq '.scripts | length' "$MANIFEST")" "script count"
  assert_eq 35 "$(jq '[.scripts[].path] | unique | length' "$MANIFEST")" "unique script paths"
  assert_eq 0 "$(jq '[.scripts[] | select((.path // "") == "" or (.family // "") == "" or (.legacyOrigin // "") == "" or (.usage // "") == "" or (.behavior // "") == "")] | length' "$MANIFEST")" "every row carries its required fields"
  assert_eq '{"authored-mjs":21,"authored-sh":1,"former-sh":11,"retained-mjs":2}' \
    "$(jq -S -c '[.scripts[].legacyOrigin] | group_by(.) | map({key: .[0], value: length}) | from_entries' "$MANIFEST")" \
    "legacy origin counts"

  local authored
  authored=$(cat <<'LIST'
skills/hyper-architecture/scripts/validate-architecture.sh
skills/hyper-database/scripts/detect-engines.sh
skills/hyper-google-tagmanager/scripts/gtm-container-audit.sh
skills/hyper-google-tagmanager/scripts/gtm-detect.sh
skills/hyper-google-tagmanager/scripts/gtm-site-check.sh
skills/hyper-design/scripts/analyze-structure.sh
skills/hyper-design/scripts/collect-rendered-evidence.sh
skills/hyper-design/scripts/detect-slop.sh
skills/hyper-design/scripts/engine-css.sh
skills/hyper-design/scripts/engine-markup.sh
skills/hyper-design/scripts/engine-text.sh
skills/hyper-design/scripts/resolve-context.sh
skills/hyper-design/scripts/rule-registry.sh
skills/hyper-design/scripts/rule-shared.sh
skills/hyper-design/scripts/run-contract-evals.sh
skills/hyper-design/scripts/run-detector-evals.sh
skills/hyper-design/scripts/validate-report.sh
skills/hyper-design/scripts/validate-waivers.sh
skills/hyper-google-analytics/scripts/ga-detect.sh
skills/hyper-decision/scripts/check-decision-request.sh
skills/hyper-diagram/scripts/render-diagram.sh
LIST
)
  local work expected_migration
  work=$(workdir)
  find "$ROOT/skills" -type f -name '*.sh' | sed "s#^$ROOT/##" | LC_ALL=C sort >"$work/disk-scripts"
  jq -r '.scripts[].path' "$MANIFEST" | LC_ALL=C sort >"$work/manifest-scripts"
  if ! diff -u "$work/disk-scripts" "$work/manifest-scripts" >"$work/scripts.diff"; then
    fail "manifest does not inventory the bundled scripts: $(cat "$work/scripts.diff")"
    return 1
  fi
  jq -r '.scripts[] | select(.legacyOrigin == "authored-mjs") | .path' "$MANIFEST" | LC_ALL=C sort >"$work/manifest-authored"
  printf '%s\n' "$authored" | LC_ALL=C sort >"$work/expected-authored"
  if ! diff -u "$work/expected-authored" "$work/manifest-authored" >"$work/authored.diff"; then
    fail "authored baseline-absent paths drifted: $(cat "$work/authored.diff")"
    return 1
  fi
  printf '%s\n' "$MIGRATION_PREIMAGES" | cut -f1 | LC_ALL=C sort >"$work/expected-migration"
  jq -r '.scripts[] | select(.sourcePreimage.migration) | .path' "$MANIFEST" | LC_ALL=C sort >"$work/manifest-migration"
  expected_migration=$(cat "$work/expected-migration")
  assert_eq "$expected_migration" "$(cat "$work/manifest-migration")" "renamed scripts pinned to the migration ref"

  local path row historical
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    historical=${path%.sh}.mjs
    row=$(jq -c --arg p "$path" '.scripts[] | select(.path == $p)' "$MANIFEST")
    assert_eq "$(jq -cn --arg base "$LEGACY_REF" --arg hist "$historical" '{baselineRef: $base, path: $hist, absent: true}')" \
      "$(printf '%s' "$row" | jq -c '.sourcePreimage.baselineAbsence')" \
      "baseline absence record for $path"
    if git -C "$ROOT" cat-file -e "$LEGACY_REF:$historical" 2>/dev/null; then
      fail "authored path already exists at the baseline ref: $historical"
      return 1
    fi
    if printf '%s' "$row" | jq -e '.sourcePreimage.migration' >/dev/null; then
      expect_migration_evidence "$path" "$(printf '%s' "$row" | jq -c '.sourcePreimage.migration')"
    fi
  done <<EOF
$(printf '%s\n' "$authored")
EOF

  assert_eq 6 "$(jq '.forbiddenDetectorReferences.records | length' "$MANIFEST")" "forbidden detector records"
  assert_eq 0 "$(jq '[.forbiddenDetectorReferences.records[] | select((.literal // "") == "" or (.allowedLocations | length) != 1)] | length' "$MANIFEST")" "every forbidden literal has exactly one allowed location"
}

case_behavior_contracts() {
  require_cmd jq
  require_cmd git
  require_cmd openssl
  assert_eq "$(cd "$ROOT" && echo "${MANIFEST#"$ROOT"/}")" "$(jq -r '.requiredBy' "$CONTRACTS")" "contracts point at the manifest"
  assert_eq "$LEGACY_REF" "$(jq -r '.legacyPreimageBase' "$MANIFEST")" "manifest legacy ref"
  assert_eq "$LEGACY_REF" "$(jq -r '.legacyPreimageBase' "$CONTRACTS")" "contracts legacy ref"
  assert_eq 35 "$(jq '.coverage.expectedRows' "$CONTRACTS")"
  assert_eq 105 "$(jq '.coverage.expectedFixtures' "$CONTRACTS")"
  assert_eq '{"authored-mjs":21,"authored-sh":1,"former-sh":11,"retained-mjs":2}' \
    "$(jq -S -c '.coverage.legacyOriginCounts' "$CONTRACTS")" "coverage origins"
  assert_eq 35 "$(jq '.rows | length' "$CONTRACTS")" "contract rows"
  assert_eq "$(printf '%s\n' "$MIGRATION_PREIMAGES" | cut -f1 | LC_ALL=C sort)" \
    "$(jq -r '.rows[] | select(.sourcePreimage.migration) | .path' "$CONTRACTS" | LC_ALL=C sort)" \
    "renamed rows pinned to the migration ref"

  local work rows i cases=0 kind
  work=$(workdir)
  rows=$(jq '.rows | length' "$CONTRACTS")
  i=0
  while [ "$i" -lt "$rows" ]; do
    local row_json path family legacy_origin contract_id manifest_row
    row_json=$(jq -c --argjson r "$i" '.rows[$r]' "$CONTRACTS")
    path=$(printf '%s' "$row_json" | jq -r '.path')
    family=$(printf '%s' "$row_json" | jq -r '.family')
    legacy_origin=$(printf '%s' "$row_json" | jq -r '.legacyOrigin')
    contract_id=$(printf '%s' "$row_json" | jq -r '.id')
    manifest_row=$(jq -c --arg p "$path" '.scripts[] | select(.path == $p)' "$MANIFEST")
    [ -n "$manifest_row" ] || { fail "contract row missing from the manifest: $path"; return 1; }
    assert_eq "$(printf '%s' "$manifest_row" | jq -r '.behaviorContractId')" "$contract_id" "behavior contract id for $path"
    assert_eq '["familyEdge","happy","malformed"]' \
      "$(printf '%s' "$row_json" | jq -c '.fixtures | keys | sort')" "fixture kinds for $path"
    assert_eq '["argv","cwd","env","exit","files","modes","stderr","stdout"]' \
      "$(printf '%s' "$row_json" | jq -c '.dimensions | keys | sort')" "dimension names for $path"

    local observables=$work/observables.$i
    : >"$observables"
    for kind in happy malformed familyEdge; do
      cases=$((cases + 1))
      local cwd scratch fixture_json
      cwd=$(workdir)
      scratch=$work/scratch.$i.$kind
      mkdir -p "$scratch"
      fixture_json=$scratch/fixture.json
      printf '%s' "$row_json" | jq -c --arg k "$kind" '.fixtures[$k]' >"$fixture_json"

      assert_eq "$kind" "$(jq -r '.scenario' "$fixture_json")" "scenario for $path/$kind"
      assert_eq '{"executable":"bash","arguments":["'"$path"'"]}' "$(jq -c '.command' "$fixture_json")" "command for $path/$kind"
      assert_eq "isolated-temp-tree" "$(jq -r '.input.cwd' "$fixture_json")" "input cwd for $path/$kind"
      assert_eq '{"NO_COLOR":"1"}' "$(jq -c '.input.env' "$fixture_json")" "input env for $path/$kind"
      assert_eq "true" "$(jq -r '.input.files | type == "array"' "$fixture_json")" "input files are an array for $path/$kind"

      materialize_fixture "$i" "$kind" "$cwd"
      local stdout=$scratch/stdout stderr=$scratch/stderr rc
      rc=$(run_contract_fixture "$i" "$kind" "$cwd" "$stdout" "$stderr")
      assert_eq "$(jq -r '.expected.exit' "$fixture_json")" "$rc" "exit code for $path/$kind"

      local normalized=$scratch/stdout.normalized
      normalize_output "$stdout" "$cwd" >"$normalized"
      jq '.expected.stdout' "$fixture_json" >"$scratch/expected-stdout.json"
      expect_fixture_output "$scratch/expected-stdout.json" "$normalized" "stdout for $path/$kind"
      normalize_output "$stderr" "$cwd" >"$scratch/stderr.normalized"
      jq '.expected.stderr' "$fixture_json" >"$scratch/expected-stderr.json"
      expect_fixture_output "$scratch/expected-stderr.json" "$scratch/stderr.normalized" "stderr for $path/$kind"

      snapshot_observables "$cwd" "$scratch/files.tsv" "$scratch/modes.tsv" "$scratch"
      expected_files_tsv "$i" "$kind" >"$scratch/expected-files.tsv"
      expected_modes_tsv "$i" "$kind" >"$scratch/expected-modes.tsv"
      if ! diff -u "$scratch/expected-files.tsv" "$scratch/files.tsv" >"$scratch/files.diff"; then
        fail "files for $path/$kind: $(cat "$scratch/files.diff")"
        return 1
      fi
      if ! diff -u "$scratch/expected-modes.tsv" "$scratch/modes.tsv" >"$scratch/modes.diff"; then
        fail "modes for $path/$kind: $(cat "$scratch/modes.diff")"
        return 1
      fi
      assert_eq "isolated-temp-tree" "$(jq -r '.expected.cwd' "$fixture_json")" "expected cwd for $path/$kind"
      assert_eq '{"NO_COLOR":"1"}' "$(jq -c '.expected.env' "$fixture_json")" "expected env for $path/$kind"
      assert_eq "$(jq -c '.input.argv' "$fixture_json")" "$(jq -c '.expected.argv' "$fixture_json")" "expected argv for $path/$kind"

      {
        printf 'exit=%s\n' "$rc"
        cat "$normalized"
        cat "$scratch/stderr.normalized"
        cat "$scratch/files.tsv"
      } | sha256_stream >>"$observables"

      rm -rf "$cwd"
    done

    case " $family " in
      " hyper-architecture "|" hyper-skill ")
        assert_eq 3 "$(LC_ALL=C sort -u "$observables" | wc -l | tr -d ' ')" "three distinct observables for $family"
        ;;
    esac

    if [ "$legacy_origin" = authored-mjs ]; then
      local historical
      historical=${path%.sh}.mjs
      assert_eq "$(jq -cn --arg base "$LEGACY_REF" --arg hist "$historical" '{baselineRef: $base, path: $hist, absent: true}')" \
        "$(printf '%s' "$row_json" | jq -c '.sourcePreimage.baselineAbsence')" \
        "baseline absence for $path"
      if git -C "$ROOT" cat-file -e "$LEGACY_REF:$historical" 2>/dev/null; then
        fail "authored path already exists at the baseline ref: $historical"
        return 1
      fi
      if printf '%s' "$row_json" | jq -e '.sourcePreimage.migration' >/dev/null; then
        expect_migration_evidence "$path" "$(printf '%s' "$row_json" | jq -c '.sourcePreimage.migration')"
      fi
    elif [ "$legacy_origin" = authored-sh ]; then
      assert_eq "$(jq -cn --arg base "$LEGACY_REF" --arg own "$path" '{baselineRef: $base, path: $own, absent: true}')" \
        "$(printf '%s' "$row_json" | jq -c '.sourcePreimage.baselineAbsence')" \
        "baseline absence for $path"
      assert_eq "null" "$(printf '%s' "$row_json" | jq -c '.sourcePreimage.migration // null')" \
        "authored bash row carries no migration record for $path"
      if git -C "$ROOT" cat-file -e "$LEGACY_REF:$path" 2>/dev/null; then
        fail "authored path already exists at the baseline ref: $path"
        return 1
      fi
    else
      local source=$work/source
      if ! git -C "$ROOT" show "$LEGACY_REF:$(printf '%s' "$row_json" | jq -r '.sourcePreimage.path')" >"$source"; then
        fail "git show failed for $path preimage"
        return 1
      fi
      assert_eq "$(printf '%s' "$row_json" | jq -r '.sourcePreimage.sha256')" "$(sha256_of "$source")" "preimage sha for $path"
    fi
    i=$((i + 1))
  done
  assert_eq 105 "$cases" "fixture executions"
}

case_validator_accepts_inventory() {
  require_cmd jq
  if [ "$VALIDATOR_KIND" = node ]; then require_cmd node; fi
  local work out err rc
  work=$(workdir)
  out=$work/stdout
  err=$work/stderr
  rc=$(run_repo_validator "$out" "$err")
  assert_empty "$(cat "$err")" "validator stderr"
  assert_eq 0 "$rc" "validator exit"
  assert_contains "$(cat "$out")" "Validated 35 bash skill scripts (11 former-sh, 0 former-py, 2 retained-mjs, 21 authored-mjs, 1 authored-sh historical origins)." "validator summary"
}

case_validator_rejects_mutations() {
  require_cmd jq
  require_cmd git
  if [ "$VALIDATOR_KIND" = node ]; then require_cmd node; fi
  local fixture work target original original_mode out err rc
  work=$(workdir)
  fixture=$work/fixture
  mkdir -p "$fixture"
  cp -R "$ROOT/skills" "$fixture/skills"
  install_validator "$fixture"
  target=$fixture/skills/hyper-deploy/scripts/stack-detect.sh
  original=$work/original.sh
  cp "$target" "$original"
  original_mode=$(file_mode "$target")

  local mutations
  mutations=$(cat <<'LIST'
eval	eval "printf ok >/dev/null"
node invocation	node -e 'true'
bun script invocation	bun ./helper.mjs
python invocation	python3 -c 'pass'
interpreter module run	node ./helper.mjs
unapproved source edge	. ./unapproved.sh
unapproved child script	bash ./unapproved.sh
associative array	declare -A table=()
mapfile	mapfile -t lines < /dev/null
case conversion	printf "%s" "${PATH,,}"
wait -n	wait -n
pipe stderr	true |& true
append redirect	true &>> /dev/null
LIST
)
  local name mutation
  while IFS="$(printf '\t')" read -r name mutation; do
    [ -n "$name" ] || continue
    { cat "$original"; printf '%s\n' "$mutation"; } >"$target"
    chmod "$original_mode" "$target"
    out=$work/stdout
    err=$work/stderr
    rc=$(run_installed_validator "$fixture" "$out" "$err")
    if [ "$rc" -eq 0 ]; then
      fail "validator accepted a bash policy mutation ($name)"
      return 1
    fi
  done <<EOF
$mutations
EOF

  local replacement
  for replacement in missing bun node; do
    case $replacement in
      missing) tail -n +2 "$original" >"$target" ;;
      bun) { printf '%s\n' '#!/usr/bin/env bun'; tail -n +2 "$original"; } >"$target" ;;
      node) { printf '%s\n' '#!/usr/bin/env node'; tail -n +2 "$original"; } >"$target" ;;
    esac
    chmod "$original_mode" "$target"
    out=$work/stdout
    err=$work/stderr
    rc=$(run_installed_validator "$fixture" "$out" "$err")
    if [ "$rc" -eq 0 ]; then
      fail "validator accepted a $replacement shebang"
      return 1
    fi
  done

  cp "$original" "$target"
  chmod 644 "$target"
  out=$work/stdout
  err=$work/stderr
  rc=$(run_installed_validator "$fixture" "$out" "$err")
  if [ "$rc" -eq 0 ]; then
    fail "validator accepted a non-executable bundled script"
    return 1
  fi
}

init_git() { # <fixture>
  git -C "$1" init -q
  git -C "$1" config user.name Test
  git -C "$1" config user.email test@example.com
}

# write_fake_git <fixture> <source> — writes bin/git and prints the PATH to use.
write_fake_git() {
  local fixture=$1 source=$2
  mkdir -p "$fixture/bin"
  printf '%s' "$source" >"$fixture/bin/git"
  chmod 755 "$fixture/bin/git"
  printf '%s' "$fixture/bin:$PATH"
}

kill_recorded_pid() { # <pid-file>
  local pid
  [ -f "$1" ] || return 0
  pid=$(tr -d '[:space:]' <"$1")
  case $pid in
    '' | *[!0-9]*) return 0 ;;
  esac
  if [ "$pid" -gt 1 ]; then
    kill -KILL "$pid" 2>/dev/null || true
  fi
}

wait_for_file() { # <path> <attempts>
  local i=0
  while [ "$i" -lt "$2" ] && [ ! -e "$1" ]; do
    sleep 0.01
    i=$((i + 1))
  done
  [ -e "$1" ]
}

case_hyper_git_commit_rejects_option_paths() {
  local fixture out err rc
  fixture=$(workdir)
  init_git "$fixture"
  printf 'initial\n' >"$fixture/requested.txt"
  printf 'initial\n' >"$fixture/unrelated.txt"
  git -C "$fixture" add .
  git -C "$fixture" commit -qm initial
  printf 'changed\n' >"$fixture/requested.txt"
  printf 'changed\n' >"$fixture/unrelated.txt"

  out=$(mktemp "$fixture/stdout.XXXXXX")
  err=$(mktemp "$fixture/stderr.XXXXXX")
  rc=$(run_in "$fixture" "$out" "$err" bash "$HYPER_GIT_COMMIT" "test: injection" "--all")
  assert_eq 1 "$rc" "option-like path rejected"
  assert_contains "$(cat "$err")" "Usage:" "option-like path usage"
  assert_eq "" "$(git -C "$fixture" diff --cached --name-only | tr -d '\n')" "nothing staged"
  assert_eq "initial" "$(git -C "$fixture" log -1 --format=%s)" "no commit was created"
}

case_hyper_git_discover_status_reject_option_paths() {
  local fixture path out err rc script
  fixture=$(workdir)
  path=$(write_fake_git "$fixture" '#!/bin/sh
printf "%s\n" "$*" >> git-calls.log
exit 99
')
  for script in "$REPO_DISCOVER" "$REPO_STATUS"; do
    out=$(mktemp "$fixture/stdout.XXXXXX")
    err=$(mktemp "$fixture/stderr.XXXXXX")
    rc=$(run_in "$fixture" "$out" "$err" env "PATH=$path" bash "$script" "--not-a-path")
    assert_eq 1 "$rc" "option-like path rejected by $(basename "$script")"
    assert_contains "$(cat "$err")" "Usage:" "usage for $(basename "$script")"
  done
  assert_not_file "$fixture/git-calls.log" "no Git inspection ran"
}

preflight_child_source() { # <role>
  cat <<CHILD
#!/usr/bin/env bash
set -u
root="\$PROBE_ROOT"
printf '%s' "\$\$" > "\$root/$1.ready"
trap 'printf %s SIGTERM > "\$root/$1.signal"; exit 143' TERM
head -c 2097152 /dev/zero | tr '\\000' 'o'
head -c 2097152 /dev/zero | tr '\\000' 'e' >&2
printf '%s' done > "\$root/$1.emitted"
deadline=\$((SECONDS + 90))
while kill -0 "\$PPID" 2>/dev/null && [ "\$SECONDS" -lt "\$deadline" ]; do /bin/sleep 0.02; done
exit 99
CHILD
}

case_preflight_forwards_termination() {
  local mode
  for mode in --sequential --parallel; do
    local fixture scripts out err pid rc combined
    fixture=$(workdir)
    scripts=$fixture/scripts
    mkdir -p "$scripts"
    cp "$DEPLOY_CHECK" "$scripts/deploy-check.sh"
    chmod 755 "$scripts/deploy-check.sh"
    printf '%s\n' '#!/usr/bin/env bash' 'exit 0' >"$scripts/stack-detect.sh"
    chmod 755 "$scripts/stack-detect.sh"
    preflight_child_source lint >"$scripts/lint-check.sh"
    preflight_child_source build >"$scripts/build-run.sh"
    chmod 755 "$scripts/lint-check.sh" "$scripts/build-run.sh"

    out=$fixture/stdout
    err=$fixture/stderr
    (
      cd "$fixture" || exit 1
      exec env "PROBE_ROOT=$fixture" bash "$scripts/deploy-check.sh" "$mode"
    ) >"$out" 2>"$err" &
    pid=$!

    if ! wait_for_file "$fixture/lint.ready" 1000; then
      kill -KILL "$pid" 2>/dev/null || true
      kill_recorded_pid "$fixture/lint.ready"
      kill_recorded_pid "$fixture/build.ready"
      wait "$pid" 2>/dev/null || true
      fail "lint child never started ($mode): $(cat "$out" "$err")"
      return 1
    fi
    wait_for_file "$fixture/lint.emitted" 1000 || { kill -KILL "$pid" 2>/dev/null || true; fail "lint child never drained $mode"; return 1; }
    assert_file "$fixture/lint.emitted" "lint child emitted its payload ($mode)"
    if [ "$mode" = --parallel ]; then
      wait_for_file "$fixture/build.emitted" 1000 || true
      assert_file "$fixture/build.emitted" "build child emitted its payload ($mode)"
      assert_file "$fixture/build.ready" "build child started in parallel ($mode)"
    else
      assert_not_file "$fixture/build.ready" "sequential mode did not start the build child ($mode)"
    fi

    kill -s TERM "$pid" 2>/dev/null || true
    rc=0
    wait "$pid" 2>/dev/null || rc=$?
    assert_eq 143 "$rc" "deploy-check exit after SIGTERM ($mode)"
    combined=$(( $(wc -c <"$out") + $(wc -c <"$err") ))
    if [ "$combined" -lt 524288 ]; then
      fail "drained output too small ($mode): $combined bytes"
      return 1
    fi
    assert_eq SIGTERM "$(cat "$fixture/lint.signal" 2>/dev/null)" "lint child received SIGTERM ($mode)"
    if [ "$mode" = --parallel ]; then
      assert_eq SIGTERM "$(cat "$fixture/build.signal" 2>/dev/null)" "build child received SIGTERM ($mode)"
    else
      assert_not_file "$fixture/build.signal" "build child never ran ($mode)"
    fi
    kill_recorded_pid "$fixture/lint.ready"
    kill_recorded_pid "$fixture/build.ready"
  done
}

write_git_maker_fast_fake_git() { # <fixture> — prints the PATH to use
  local fixture=$1
  mkdir -p "$fixture/bin"
  cat >"$fixture/bin/git" <<'GIT'
#!/usr/bin/env bash
set -u
root="$PROBE_ROOT"
repo="${PWD##*/}"
args="$*"
emit() {
  head -c 2097152 /dev/zero | tr '\000' 'x'
}
if [ "$args" = "rev-parse --show-toplevel" ]; then
  if [ -d "$PWD/.git" ]; then printf '%s\n' "$PWD"; else printf '%s\n' "not a git repository" >&2; exit 128; fi
elif [ "$args" = "rev-parse --is-inside-work-tree" ]; then
  printf '%s' "$$" > "$root/$repo.ready"
  trap 'printf %s SIGTERM > "$root/$repo.signal"; exit 143' TERM
  trap 'printf %s SIGINT > "$root/$repo.signal"; exit 130' INT
  emit
  emit >&2
  printf '%s' done > "$root/$repo.emitted"
  if [ "${MODE:-}" = "failure" ] && [ "$repo" = "repo-a" ]; then
    deadline=$((SECONDS + 10))
    while [ ! -e "$root/repo-b.ready" ] && [ "$SECONDS" -lt "$deadline" ]; do /bin/sleep 0.01; done
    printf '%s\n' "intentional worker failure" >&2
    exit 97
  fi
  deadline=$((SECONDS + 90))
  while kill -0 "$PPID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do /bin/sleep 0.02; done
  exit 99
else
  printf '%s\n' "unexpected git invocation: $args" >&2
  exit 98
fi
GIT
  chmod 755 "$fixture/bin/git"
  printf '%s' "$fixture/bin:$PATH"
}

case_hyper_git_fast_reaps_children() {
  local entry mode signal expected
  set -m
  for entry in "failure::1" "signal:SIGTERM:143" "signal:SIGINT:130"; do
    mode=${entry%%:*}
    signal=$(printf '%s' "${entry#*:}" | cut -d: -f1)
    expected=${entry##*:}
    local fixture repositories repository path out err pid rc
    fixture=$(workdir)
    repositories="repo-a repo-b repo-c"
    for repository in $repositories; do
      mkdir -p "$fixture/$repository/.git"
    done
    path=$(write_git_maker_fast_fake_git "$fixture")

    out=$fixture/stdout
    err=$fixture/stderr
    (
      cd "$fixture" || exit 1
      exec env "PATH=$path" "PROBE_ROOT=$fixture" "MODE=$mode" bash "$HYPER_GIT_FAST" inspect "$fixture" --jobs 2
    ) >"$out" 2>"$err" &
    pid=$!

    if ! wait_for_file "$fixture/repo-a.ready" 1000 || ! wait_for_file "$fixture/repo-b.ready" 1000; then
      kill -KILL "$pid" 2>/dev/null || true
      for repository in $repositories; do kill_recorded_pid "$fixture/$repository.ready"; done
      wait "$pid" 2>/dev/null || true
      fail "two workers did not start ($mode/$signal): $(cat "$err")"
      return 1
    fi
    assert_file "$fixture/repo-a.ready" "repo-a started"
    assert_file "$fixture/repo-b.ready" "repo-b started"
    assert_not_file "$fixture/repo-c.ready" "queued repo-c did not start"

    wait_for_file "$fixture/repo-a.emitted" 1000 || true
    assert_file "$fixture/repo-a.emitted" "repo-a emitted"
    if [ -n "$signal" ]; then
      wait_for_file "$fixture/repo-b.emitted" 1000 || true
      assert_file "$fixture/repo-b.emitted" "repo-b emitted"
    fi

    if [ -n "$signal" ]; then
      kill -s "$signal" "$pid" 2>/dev/null || true
    fi
    rc=0
    wait "$pid" 2>/dev/null || rc=$?
    assert_eq "$expected" "$rc" "git-fast exit ($mode/$signal)"
    if [ -z "$signal" ]; then
      if [ "$(wc -c <"$err")" -lt 2097152 ]; then
        fail "stderr was not drained in failure mode: $(wc -c <"$err") bytes"
        return 1
      fi
    fi
    assert_not_file "$fixture/repo-c.ready" "queued repo-c stayed unstarted ($mode/$signal)"

    if [ -n "$signal" ]; then
      for repository in repo-a repo-b; do
        assert_eq "$signal" "$(cat "$fixture/$repository.signal" 2>/dev/null)" "child $repository received $signal"
      done
    else
      assert_contains "$(cat "$err")" "intentional worker failure" "worker failure surfaced"
      assert_eq SIGTERM "$(cat "$fixture/repo-b.signal" 2>/dev/null)" "sibling cancelled with SIGTERM"
    fi
    for repository in repo-a repo-b; do
      local child_pid alive
      child_pid=$(tr -d '[:space:]' <"$fixture/$repository.ready")
      alive=1
      kill -0 "$child_pid" 2>/dev/null || alive=0
      assert_eq 0 "$alive" "child $repository reaped ($mode/$signal)"
      kill_recorded_pid "$fixture/$repository.ready"
    done
  done
  set +m
}

case_hyper_git_fast_paths_with_spaces() {
  local fixture repository out err rc stdout
  fixture=$(workdir)
  repository="$fixture/repository with spaces"
  mkdir -p "$repository"
  init_git "$repository"
  printf 'initial\n' >"$repository/tracked.txt"
  git -C "$repository" add tracked.txt
  git -C "$repository" commit -qm initial

  out=$fixture/stdout
  err=$fixture/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$HYPER_GIT_FAST" inspect "$repository" --jobs=1)
  assert_eq 0 "$rc" "inspect exit for a path with spaces"
  stdout=$(cat "$out")
  assert_contains "$stdout" "repos|begin" "repo stream opener"
  assert_contains "$stdout" "repository with spaces" "repository path in the stream"
  assert_contains "$stdout" "repo|" "repo record"
  case $stdout in
    *"status|begin
status|end"*) : ;;
    *) fail "status block did not close"; return 1 ;;
  esac
}

case_preflight_rejects_malformed_metadata() {
  local fixture out err rc combined
  fixture=$(workdir)
  printf '%s' '{broken' >"$fixture/package.json"
  out=$fixture/stdout
  err=$fixture/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$DEPLOY_CHECK" --sequential)
  assert_eq 1 "$rc" "malformed package metadata exit"
  combined=$(cat "$out" "$err")
  assert_contains "$combined" "package.json" "malformed metadata is reported"
  assert_not_contains "$(cat "$out")" "Ready to deploy" "no deploy-ready line"
}

case_self_containment_check() {
  require_cmd jq
  local fixture validator evals out err rc work
  fixture=$(workdir)
  work=$(workdir)
  validator=$ROOT/skills/hyper-skill/scripts/validate-hyper-skill.sh
  evals=$ROOT/skills/hyper-skill/assets/evals/hyper-skill-cases.jsonl
  mkdir -p "$fixture/skills/sibling-one" "$fixture/skills/sibling-two" "$fixture/skills/target-pkg"
  printf '%s\n' "---" "name: sibling-one" "description: fixture package" "---" >"$fixture/skills/sibling-one/SKILL.md"
  printf '%s\n' "---" "name: sibling-two" "description: fixture package" "---" >"$fixture/skills/sibling-two/SKILL.md"
  {
    printf '%s\n' "---" "name: target-pkg" "description: fixture package" "---"
    printf '%s\n' ""
    printf '%s\n' "See skills/sibling-one/ and \$sibling-two."
  } >"$fixture/skills/target-pkg/SKILL.md"

  # A package that does not adopt the contract reports the finding as a warning.
  out=$work/warned.out
  err=$work/warned.err
  rc=$(run_in "$fixture" "$out" "$err" bash "$validator" --root "$fixture/skills/target-pkg" --evals "$evals" --json)
  assert_eq "false" "$(jq -r '[.errors[].code] | index("CROSS_SKILL_REFERENCE") != null' "$out")" "warning mode keeps cross-skill references out of errors"
  assert_eq "true" "$(jq -r '[.warnings[].code] | index("CROSS_SKILL_REFERENCE") != null' "$out")" "warning mode reports the cross-skill reference"

  # Strict mode promotes it to an error.
  out=$work/strict.out
  err=$work/strict.err
  rc=$(run_in "$fixture" "$out" "$err" bash "$validator" --root "$fixture/skills/target-pkg" --evals "$evals" --require-self-containment --json)
  assert_ne 0 "$rc" "strict mode fails the package"
  assert_eq "true" "$(jq -r '[.errors[].code] | index("CROSS_SKILL_REFERENCE") != null' "$out")" "strict mode reports the cross-skill reference"

  # A user-directed waiver stays visible without failing the package.
  out=$work/waived.out
  err=$work/waived.err
  rc=$(run_in "$fixture" "$out" "$err" bash "$validator" --root "$fixture/skills/target-pkg" --evals "$evals" --require-self-containment --allow sibling-one --allow sibling-two --json)
  assert_eq "false" "$(jq -r '[.errors[].code] | index("CROSS_SKILL_REFERENCE") != null' "$out")" "waiver clears the error"
  assert_eq "true" "$(jq -r '[.warnings[].code] | index("SELF_CONTAINMENT_WAIVER") != null' "$out")" "waiver stays visible"

  # Standalone tree: the named sibling does not exist, and strict mode still catches the path.
  mkdir -p "$fixture/lonely/skills/lonely-pkg"
  {
    printf '%s\n' "---" "name: lonely-pkg" "description: fixture package" "---"
    printf '%s\n' ""
    printf '%s\n' "A stale pointer: skills/ghost-skill/ is not here."
  } >"$fixture/lonely/skills/lonely-pkg/SKILL.md"
  out=$work/lonely.out
  err=$work/lonely.err
  rc=$(run_in "$fixture" "$out" "$err" bash "$validator" --root "$fixture/lonely/skills/lonely-pkg" --evals "$evals" --require-self-containment --json)
  assert_ne 0 "$rc" "standalone strict mode fails"
  assert_eq "true" "$(jq -r '[.errors[].code] | index("CROSS_SKILL_REFERENCE") != null' "$out")" "standalone cross-skill error"
  assert_eq "[]" "$(jq -c '.selfContainment.siblings' "$out")" "no siblings detected"
}

script_runtime_package_body() { # <package-name> <tags>
  printf '%s\n' "---" "name: $1" "description: Use this skill when a fixture package is needed." "---" "$2"
}

script_runtime_korean_body() { # <package-name> <tags>
  printf '%s\n' "---" "name: $1" "description: 픽스처 패키지가 필요할 때 사용합니다." "---" "$2"
}

case_script_runtime_check() {
  require_cmd jq
  local parent validator evals pkg package_name tags work
  work=$(workdir)
  parent=$work/parent
  mkdir -p "$parent"
  validator=$ROOT/skills/hyper-skill/scripts/validate-hyper-skill.sh
  evals=$ROOT/skills/hyper-skill/assets/evals/hyper-skill-cases.jsonl
  package_name="fixture-pkg"
  pkg=$parent/$package_name
  tags='<output_language>
<purpose>
<routing_rule>
<instruction_contract>
<activation_examples>
<trigger_conditions>
<skill_architecture>
<loop_policy>
<language_and_translation_default>
<reference_routing>
<support_file_read_order>
<workflow>
<required>
<forbidden>
<validation>'

  local out err rc
  write_pkg() { # [violation-label]
    rm -rf "$pkg"
    mkdir -p "$pkg/scripts"
    script_runtime_package_body "$package_name" "$tags" >"$pkg/SKILL.md"
    script_runtime_korean_body "$package_name" "$tags" >"$pkg/SKILL.ko.md"
    case ${1:-} in
      "") ;;
      cjs) printf '%s\n' '#!/usr/bin/env bash' >"$pkg/scripts/probe.cjs" ;;
      mjs) printf '%s\n' '#!/usr/bin/env bash' >"$pkg/scripts/probe.mjs" ;;
      ts) printf '%s\n' '#!/usr/bin/env bash' >"$pkg/scripts/probe.ts" ;;
      extensionless) printf '%s\n' '#!/usr/bin/env bash' >"$pkg/scripts/probe" ;;
      uppercase) printf '%s\n' '#!/usr/bin/env bash' >"$pkg/scripts/probe.SH" ;;
      node-shebang) printf '%s\n' '#!/usr/bin/env node' >"$pkg/scripts/probe.sh" ;;
      linked-file-bad-shebang) ln -s "$parent/outside-node.sh" "$pkg/scripts/probe.sh" ;;
      linked-file-wrong-name) ln -s "$parent/outside-bash" "$pkg/scripts/linked" ;;
      linked-scripts-dir)
        mkdir -p "$pkg/real-scripts"
        printf '%s\n' '#!/usr/bin/env bash' >"$pkg/real-scripts/probe.cjs"
        rm -rf "$pkg/scripts"
        ln -s "$pkg/real-scripts" "$pkg/scripts"
        ;;
      fifo-entry)
        rm -rf "$pkg/scripts"
        mkdir -p "$pkg/scripts"
        mkfifo "$pkg/scripts/probe.sh"
        ;;
      case-variant-dir)
        mkdir -p "$pkg/Scripts"
        printf '%s\n' '#!/usr/bin/env bash' >"$pkg/Scripts/probe.cjs"
        ;;
    esac
  }
  run_validator_case() { # <label> — sets out/err and writes the exit code to <label>.rc
    out=$work/$1.out
    err=$work/$1.err
    run_in "$ROOT" "$out" "$err" bash "$validator" --root "$pkg" --evals "$evals" --json >"$work/$1.rc"
  }

  printf '%s\n' '#!/usr/bin/env node' >"$parent/outside-node.sh"
  printf '%s\n' '#!/usr/bin/env bash' >"$parent/outside-bash"

  # Control: a valid package with no scripts directory passes and inspects nothing.
  rm -rf "$pkg"
  mkdir -p "$pkg"
  script_runtime_package_body "$package_name" "$tags" >"$pkg/SKILL.md"
  script_runtime_korean_body "$package_name" "$tags" >"$pkg/SKILL.ko.md"
  run_validator_case control
  rc=$(cat "$work/control.rc")
  assert_eq "[]" "$(jq -c '[.errors[].code]' "$out")" "control package has no errors"
  assert_eq 0 "$rc" "control package exit"
  assert_eq '{"checked":0,"findings":[],"ok":true}' "$(jq -S -c '.scriptRuntime' "$out")" "control script runtime"

  local case_sensitive=0 permissions_enforced=0
  mkdir -p "$parent/CaseProbe"
  if [ ! -e "$parent/caseprobe" ]; then
    case_sensitive=1
  fi
  rm -rf "$parent/CaseProbe"
  mkdir -p "$parent/perm-probe"
  printf 'x' >"$parent/perm-probe/child"
  chmod 000 "$parent/perm-probe"
  if ! ls "$parent/perm-probe" >/dev/null 2>&1; then
    permissions_enforced=1
  fi
  chmod 755 "$parent/perm-probe"
  rm -rf "$parent/perm-probe"

  local violations
  violations="cjs:SCRIPT_RUNTIME_EXTENSION:scripts/probe.cjs
mjs:SCRIPT_RUNTIME_EXTENSION:scripts/probe.mjs
ts:SCRIPT_RUNTIME_EXTENSION:scripts/probe.ts
extensionless:SCRIPT_RUNTIME_EXTENSION:scripts/probe
uppercase:SCRIPT_RUNTIME_EXTENSION:scripts/probe.SH
node-shebang:SCRIPT_RUNTIME_SHEBANG:scripts/probe.sh
linked-file-bad-shebang:SCRIPT_RUNTIME_SHEBANG:scripts/probe.sh
linked-file-wrong-name:SCRIPT_RUNTIME_EXTENSION:scripts/linked
linked-scripts-dir:SCRIPT_RUNTIME_EXTENSION:scripts/probe.cjs"
  if mkfifo "$parent/fifo-probe" 2>/dev/null; then
    rm -f "$parent/fifo-probe"
    violations="$violations
fifo-entry:SCRIPT_RUNTIME_SHEBANG:scripts/probe.sh"
  fi
  if [ "$case_sensitive" -eq 1 ]; then
    violations="$violations
case-variant-dir:SCRIPT_RUNTIME_EXTENSION:Scripts/probe.cjs"
  fi

  local label code expected_path
  while IFS=: read -r label code expected_path; do
    [ -n "$label" ] || continue
    write_pkg "$label"
    run_validator_case "$label"
    rc=$(cat "$work/$label.rc")
    assert_eq "true" "$(jq -r --arg c "$code" '[.errors[].code] | index($c) != null' "$out")" "error code $code for $label"
    assert_ne 0 "$rc" "exit for $label"
    assert_eq "false" "$(jq -r '.scriptRuntime.ok' "$out")" "runtime ok false for $label"
    assert_eq 1 "$(jq -r '.scriptRuntime.checked' "$out")" "checked count for $label"
    assert_eq 1 "$(jq -r '.scriptRuntime.findings | length' "$out")" "single finding for $label"
    assert_eq "$expected_path" "$(jq -r '.scriptRuntime.findings[0].path' "$out")" "finding path for $label"
  done <<EOF
$violations
EOF

  # A `scripts` entry that does not resolve must be reported, not silently dropped.
  rm -rf "$pkg"
  mkdir -p "$pkg"
  script_runtime_package_body "$package_name" "$tags" >"$pkg/SKILL.md"
  script_runtime_korean_body "$package_name" "$tags" >"$pkg/SKILL.ko.md"
  ln -s "$parent/missing-target" "$pkg/scripts"
  run_validator_case broken-link
  rc=$(cat "$work/broken-link.rc")
  assert_eq "true" "$(jq -r '[.errors[].code] | index("SCRIPT_RUNTIME_EXTENSION") != null' "$out")" "broken scripts link is reported"
  assert_eq 0 "$(jq -r '.scriptRuntime.checked' "$out")" "broken scripts link inspects nothing"

  if [ "$permissions_enforced" -eq 1 ]; then
    write_pkg locked-dir
    rm -rf "$pkg/scripts"
    mkdir -p "$pkg/scripts/locked"
    printf '%s\n' '#!/usr/bin/env bash' >"$pkg/scripts/locked/probe.cjs"
    chmod 000 "$pkg/scripts/locked"
    run_validator_case locked-dir
    rc=$(cat "$work/locked-dir.rc")
    chmod 755 "$pkg/scripts/locked"
    assert_eq "true" "$(jq -r '[.errors[].code] | index("SCRIPT_RUNTIME_UNREADABLE") != null' "$out")" "unreadable directory is reported"
    assert_eq "false" "$(jq -r '.scriptRuntime.ok' "$out")" "unreadable directory fails closed"

    local real_scripts=$parent/real-scripts-locked
    rm -rf "$pkg"
    mkdir -p "$pkg"
    script_runtime_package_body "$package_name" "$tags" >"$pkg/SKILL.md"
    script_runtime_korean_body "$package_name" "$tags" >"$pkg/SKILL.ko.md"
    mkdir -p "$real_scripts/locked"
    printf '%s\n' '#!/usr/bin/env bash' >"$real_scripts/locked/probe.cjs"
    chmod 000 "$real_scripts/locked"
    ln -s "$real_scripts" "$pkg/scripts"
    run_validator_case linked-locked-dir
    rc=$(cat "$work/linked-locked-dir.rc")
    chmod 755 "$real_scripts/locked"
    assert_eq "true" "$(jq -r '[.errors[].code] | index("SCRIPT_RUNTIME_UNREADABLE") != null' "$out")" "unreadable linked directory is reported"
    assert_eq "false" "$(jq -r '.scriptRuntime.ok' "$out")" "unreadable linked directory fails closed"
  fi

  # A bash shebang passes, and CRLF line endings must not be mistaken for a bad shebang.
  local body
  for body in bash crlf; do
    write_pkg shebang-$body
    if [ "$body" = crlf ]; then
      printf '#!/usr/bin/env bash\r\n' >"$pkg/scripts/probe.sh"
    else
      printf '#!/usr/bin/env bash\n' >"$pkg/scripts/probe.sh"
    fi
    run_validator_case "shebang-$body"
    rc=$(cat "$work/shebang-$body.rc")
    assert_eq "false" "$(jq -r '[.errors[].code] | index("SCRIPT_RUNTIME_EXTENSION") != null' "$out")" "no extension error for $body"
    assert_eq "false" "$(jq -r '[.errors[].code] | index("SCRIPT_RUNTIME_SHEBANG") != null' "$out")" "no shebang error for $body"
    assert_eq 0 "$rc" "exit for $body"
    assert_eq "true" "$(jq -r '.scriptRuntime.ok' "$out")" "runtime ok for $body"
    assert_eq 1 "$(jq -r '.scriptRuntime.checked' "$out")" "checked count for $body"
    assert_eq "[]" "$(jq -c '.scriptRuntime.findings' "$out")" "no findings for $body"
  done
}

# hyper-imagegen ships its own validator outside the standard gate,
# so the repository suite runs it here to catch drift in their fixtures and core.
case_hyper_imagegen_validator() {
  require_cmd jq
  local out err rc work
  work=$(workdir)
  out=$work/hyper-imagegen.json
  err=$work/hyper-imagegen.err
  rc=$(run_in "$ROOT" "$out" "$err" bash "$ROOT/skills/hyper-imagegen/scripts/validate-hyper-imagegen.sh" --root skills/hyper-imagegen --json)
  assert_eq 0 "$rc" "hyper-imagegen validator exit"
  assert_json_valid "$out" "hyper-imagegen validator output"
  assert_eq "true" "$(jq -r '.ok' "$out")" "hyper-imagegen validator ok"
  assert_eq 0 "$(jq -r '.counts.errors' "$out")" "hyper-imagegen case errors"
  assert_eq "$(jq -r '.counts.total' "$out")" \
    "$(jq -r '.counts.automatic + .counts.manual_required' "$out")" "hyper-imagegen case total"
  assert_eq "$(jq -r '.counts.manual_required' "$out")" \
    "$(jq -r '.manual_required | length' "$out")" "hyper-imagegen manual cases"
}

STRUCTURE_GATE_MARKERS='필수 키가 없습니다
값이 유효하지 않습니다
배열이어야 합니다
객체여야 합니다
0..100 또는 null이어야 합니다
JSON 파싱에 실패했습니다'

renderer_results_json() { # <name>
  case $1 in
    hyper-seo)
      printf '%s' '{"project_name":"fixture","status":"running","categories":[{"name":"Technical SEO","status":"unknown","score":null}],"findings":[{"id":"T1","severity":"info","finding":"fixture finding","evidence_grade":"heuristic","source_tier":"research-backed-heuristic"}]}'
      ;;
  esac
}

renderer_seam_source() { # <name> <failure>
  case $1:$2 in
    hyper-seo:second-write)
      printf '%s' "  if ! printf 'window.__SEO_RESULTS__ = %s;\\n' \"\$results_json\" | write_temp_stream \"\$RESULTS_JS_TEMP\" \"\$RESULTS_MODE\"; then"
      ;;
    *:second-rename)
      # shellcheck disable=SC2016
      printf '%s' '  if ! mv -f -- "$RESULTS_JS_TEMP" "$results_js_path"; then'
      ;;
  esac
}

renderer_seam_replacement() { # <failure>
  case $1 in
    second-write) printf '%s' "  if ! (printf 'forced second write\\n' >&2; false); then" ;;
    second-rename) printf '%s' "  if ! (printf 'forced second rename\\n' >&2; false); then" ;;
  esac
}

renderer_atomic_case() { # <renderer> <failure>
  require_cmd node
  local name=$1 failure=$2
  local fixture script assets template source replacement
  fixture=$(workdir)
  script=$fixture/scripts/render-dashboard.sh
  assets=$fixture/assets
  mkdir -p "$fixture/scripts" "$assets"
  case $name in
    hyper-seo)
      template=$ROOT/skills/hyper-seo/assets/dashboard-template.html
      src_script=$ROOT/skills/hyper-seo/scripts/render-dashboard.sh
      ;;
  esac
  cp "$src_script" "$script"
  chmod 755 "$script"
  cp "$template" "$assets/dashboard-template.html"

  source=$(renderer_seam_source "$name" "$failure")
  replacement=$(renderer_seam_replacement "$failure")
  node - "$script" "$source" "$replacement" <<'NODE' || { fail "failed to inject the $failure seam into $name"; return 1; }
const fs = require("fs");
const [file, needle, replacement] = process.argv.slice(2);
const text = fs.readFileSync(file, "utf8");
if (!text.includes(needle)) {
  console.error("seam not found");
  process.exit(3);
}
fs.writeFileSync(file, text.replace(needle, replacement));
NODE
  assert_file_contains "$script" "$replacement" "injected $failure seam"

  renderer_results_json "$name" >"$fixture/results.json"
  printf 'prior dashboard\n' >"$fixture/dashboard.html"
  printf 'prior results\n' >"$fixture/results.js"
  chmod 640 "$fixture/dashboard.html"
  chmod 600 "$fixture/results.js"

  local out err rc marker
  out=$fixture/stdout
  err=$fixture/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$script" "$fixture")
  assert_eq 1 "$rc" "renderer exit after $failure"
  assert_contains "$(cat "$err")" "forced ${failure//-/ }" "forced failure is reported"

  while IFS= read -r marker; do
    [ -n "$marker" ] || continue
    assert_not_contains "$(cat "$err")" "$marker" "structure gate did not fire for $failure"
  done <<EOF
$STRUCTURE_GATE_MARKERS
EOF

  assert_eq "prior dashboard" "$(tr -d '\n' <"$fixture/dashboard.html")" "prior dashboard preserved"
  assert_eq "prior results" "$(tr -d '\n' <"$fixture/results.js")" "prior results preserved"
  assert_eq 640 "$(file_mode "$fixture/dashboard.html")" "prior dashboard mode preserved"
  assert_eq 600 "$(file_mode "$fixture/results.js")" "prior results mode preserved"
  local leftovers
  leftovers=$(find "$fixture" -maxdepth 1 -name '*.tmp' -print)
  assert_empty "$leftovers" "no temp files left behind"
}

case_hyper_seo_renderer_second_write() { renderer_atomic_case hyper-seo second-write; }
case_hyper_seo_renderer_second_rename() { renderer_atomic_case hyper-seo second-rename; }

run_case "manifest centrally inventories 35 scripts including twenty-one authored baseline-absent MJS paths and one authored bash script" case_manifest_inventory
run_case "behavior contracts execute all 105 isolated semantic fixtures with exact observables" case_behavior_contracts
run_case "validator accepts the approved inventory" case_validator_accepts_inventory
run_case "validator rejects bash policy mutations a real regression would introduce" case_validator_rejects_mutations
run_case "hyper-git commit rejects option-like paths without staging unrelated changes" case_hyper_git_commit_rejects_option_paths
run_case "hyper-git discover and status reject option-like paths before Git inspection" case_hyper_git_discover_status_reject_option_paths
run_case "hyper-deploy preflight drains multi-MiB children and forwards termination without orphaning sequential or parallel work" case_preflight_forwards_termination
run_case "hyper-git git-fast drains concurrent fake Git children, stops queued work, and reaps children on failures and signals" case_hyper_git_fast_reaps_children
run_case "hyper-git git-fast inspects a repository whose path contains spaces without remote access" case_hyper_git_fast_paths_with_spaces
run_case "hyper-deploy preflight rejects malformed package metadata" case_preflight_rejects_malformed_metadata
run_case "self-containment check catches cross-skill references, including with no sibling present" case_self_containment_check
run_case "script-runtime check rejects non-bash bundled scripts and non-bash shebangs" case_script_runtime_check
run_case "the hyper-imagegen validator accepts its own skill folder and eval corpus" case_hyper_imagegen_validator
run_case "hyper-seo preserves both prior outputs when its second-write fails" case_hyper_seo_renderer_second_write
run_case "hyper-seo preserves both prior outputs when its second-rename fails" case_hyper_seo_renderer_second_rename

test_summary
