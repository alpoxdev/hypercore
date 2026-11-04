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

VERSION_CURRENT=$ROOT/skills/version-update/scripts/version-current.sh
VERSION_APPLY=$ROOT/skills/version-update/scripts/version-apply.sh
VERSION_GIT_COMMIT=$ROOT/skills/version-update/scripts/git-commit.sh
VERSION_GIT_PUSH=$ROOT/skills/version-update/scripts/git-push.sh
DEPLOY_CHECK=$ROOT/skills/pre-deploy/scripts/deploy-check.sh
GIT_MAKER_COMMIT=$ROOT/skills/git-maker/scripts/git-commit.sh
REPO_DISCOVER=$ROOT/skills/git-maker/scripts/repo-discover.sh
REPO_STATUS=$ROOT/skills/git-maker/scripts/repo-status.sh
GIT_MAKER_FAST=$ROOT/skills/git-maker/scripts/git-maker-fast.sh

# Pre-migration preimages keyed by the renamed script's current path, exactly as
# the bun test pins them. Columns: current path, from path, sha256, mode, ref.
MIGRATION_PREIMAGES=$(
  cat <<'TSV'
skills/ai-design-slop-remover/scripts/analyze-structure.sh	skills/ai-design-slop-remover/scripts/analyze-structure.cjs	9b379e486755ea09729d7b52097718868ef8817dbb4e9169e9bcab34152eb8d0	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/collect-rendered-evidence.sh	skills/ai-design-slop-remover/scripts/collect-rendered-evidence.cjs	562f561401694e9e8b0377a88e0a48884812929ca50c7c6e202896119ab1d7a3	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/detect-slop.sh	skills/ai-design-slop-remover/scripts/detect-slop.cjs	17e5c21a8eec75f0f4638196f67aca8de0bf5ff49b6bb6ff71c9d156e56e847a	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/engine-css.sh	skills/ai-design-slop-remover/scripts/engines/css.cjs	2cc502ed2086a4ff293a153e7981da7738dc019cbd3fd0d64ce1da1418d7a03c	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/engine-markup.sh	skills/ai-design-slop-remover/scripts/engines/markup.cjs	d283db47e8a7464a29a08ad2035e77e46a895a11693eb4b40842628caff06161	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/engine-text.sh	skills/ai-design-slop-remover/scripts/engines/text.cjs	d892fa19e78bc785631ec8ca0d472566a160898b035345a9c9136db49c91a7df	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/resolve-context.sh	skills/ai-design-slop-remover/scripts/resolve-context.cjs	4cd95ded813c423e0c3deba3e4af9240d38e4c88d5ca6e15e5be9fae5f8a27cc	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/rule-registry.sh	skills/ai-design-slop-remover/scripts/rules/registry.cjs	67492b55d8417e73ecdad9b32de902aca674cdd576f7cc9f920c595f8694db05	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/rule-shared.sh	skills/ai-design-slop-remover/scripts/rules/shared.cjs	0d4f0fec0192872ec25a459426ceae5707c45befa71a203de21a12f4088a40ce	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/run-contract-evals.sh	skills/ai-design-slop-remover/scripts/run-contract-evals.cjs	f9d5abe484d028aebcd7dad92e90dbc77ee6144f9ee96db98cb9393d5c7bca5b	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/run-detector-evals.sh	skills/ai-design-slop-remover/scripts/run-detector-evals.cjs	fddb35e5a47670733d2b85f657b88e6136d0bad7482d3e652bd3129466c4dbf4	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/validate-report.sh	skills/ai-design-slop-remover/scripts/validate-report.cjs	0876b9f0c9291cc590c406fb6552363de33303b9fdb244dfcd940d85798c7d1f	100644	migrationPreimageRef
skills/ai-design-slop-remover/scripts/validate-waivers.sh	skills/ai-design-slop-remover/scripts/validate-waivers.cjs	f288eaeca8342136488d50ba456dfc00acc2fa78177ce356cb9256691075f1f7	100644	migrationPreimageRef
skills/skill-tester/scripts/validate-skill-tester.sh	skills/skill-tester/scripts/validate-skill-tester.js	978399934eee9ee856d07ae6703c6181ab4ec2c25e19ab420107682b0bebee56	100644	migrationPreimageRef
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
  assert_eq 44 "$(jq '.scripts | length' "$MANIFEST")" "script count"
  assert_eq 44 "$(jq '[.scripts[].path] | unique | length' "$MANIFEST")" "unique script paths"
  assert_eq 0 "$(jq '[.scripts[] | select((.path // "") == "" or (.family // "") == "" or (.legacyOrigin // "") == "" or (.usage // "") == "" or (.behavior // "") == "")] | length' "$MANIFEST")" "every row carries its required fields"
  assert_eq '{"authored-mjs":15,"former-py":1,"former-sh":19,"retained-mjs":9}' \
    "$(jq -S -c '[.scripts[].legacyOrigin] | group_by(.) | map({key: .[0], value: length}) | from_entries' "$MANIFEST")" \
    "legacy origin counts"

  local authored
  authored=$(cat <<'LIST'
skills/ai-design-slop-remover/scripts/analyze-structure.sh
skills/ai-design-slop-remover/scripts/collect-rendered-evidence.sh
skills/ai-design-slop-remover/scripts/detect-slop.sh
skills/ai-design-slop-remover/scripts/engine-css.sh
skills/ai-design-slop-remover/scripts/engine-markup.sh
skills/ai-design-slop-remover/scripts/engine-text.sh
skills/ai-design-slop-remover/scripts/resolve-context.sh
skills/ai-design-slop-remover/scripts/rule-registry.sh
skills/ai-design-slop-remover/scripts/rule-shared.sh
skills/ai-design-slop-remover/scripts/run-contract-evals.sh
skills/ai-design-slop-remover/scripts/run-detector-evals.sh
skills/ai-design-slop-remover/scripts/validate-report.sh
skills/ai-design-slop-remover/scripts/validate-waivers.sh
skills/jev-maker/scripts/check-jev-request.sh
skills/skill-tester/scripts/validate-skill-tester.sh
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
  assert_eq "false" "$(jq '.versionUpdateDetectorAbsentCorrection.detectorRestored' "$MANIFEST")" "detector stays absent"
  assert_eq 7 "$(jq '.versionUpdateDetectorAbsentCorrection.legacyFiles | length' "$MANIFEST")" "legacy files"
  assert_eq 0 "$(jq '[.versionUpdateDetectorAbsentCorrection.legacyFiles[] | select((.sha256 | test("^[a-f0-9]{64}$") | not) or .gitMode != "100755")] | length' "$MANIFEST")" "legacy file hashes and modes"
  assert_jq "$MANIFEST" '.versionUpdateDetectorAbsentCorrection.restoreOrder | length >= 4' "restore order"
}

case_behavior_contracts() {
  require_cmd jq
  require_cmd git
  require_cmd openssl
  assert_eq "$(cd "$ROOT" && echo "${MANIFEST#"$ROOT"/}")" "$(jq -r '.requiredBy' "$CONTRACTS")" "contracts point at the manifest"
  assert_eq "$LEGACY_REF" "$(jq -r '.legacyPreimageBase' "$MANIFEST")" "manifest legacy ref"
  assert_eq "$LEGACY_REF" "$(jq -r '.legacyPreimageBase' "$CONTRACTS")" "contracts legacy ref"
  assert_eq 44 "$(jq '.coverage.expectedRows' "$CONTRACTS")"
  assert_eq 132 "$(jq '.coverage.expectedFixtures' "$CONTRACTS")"
  assert_eq '{"authored-mjs":15,"former-py":1,"former-sh":19,"retained-mjs":9}' \
    "$(jq -S -c '.coverage.legacyOriginCounts' "$CONTRACTS")" "coverage origins"
  assert_eq 44 "$(jq '.rows | length' "$CONTRACTS")" "contract rows"
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
      " nextjs-architecture "|" prompt-maker "|" skill-maker "|" vite-architecture ")
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
  assert_eq 132 "$cases" "fixture executions"
}

case_detector_absent_correction() {
  require_cmd jq
  require_cmd git
  local fixture correction manifest
  fixture=$(workdir)
  correction=$(jq -c '.detectorAbsentCorrection' "$CONTRACTS")
  manifest=$(jq -c '.versionUpdateDetectorAbsentCorrection' "$MANIFEST")
  assert_contains "$(printf '%s' "$correction" | jq -r '.absenceEvidence')" "exact 30-entrypoint inventory" "absence evidence"
  assert_eq "$(printf '%s' "$manifest" | jq -S -c '.legacyFiles')" \
    "$(printf '%s' "$correction" | jq -S -c '.legacyFiles')" "legacy file records match the manifest"

  local n i legacy_path final_path git_mode target
  n=$(printf '%s' "$correction" | jq '.legacyFiles | length')
  i=0
  while [ "$i" -lt "$n" ]; do
    legacy_path=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.legacyFiles[$i].legacyPath')
    git_mode=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.legacyFiles[$i].gitMode')
    target=$fixture/$legacy_path
    mkdir -p "$(dirname "$target")"
    git -C "$ROOT" show "$LEGACY_REF:$legacy_path" >"$target" || { fail "git show $LEGACY_REF:$legacy_path failed"; return 1; }
    chmod "${git_mode#100}" "$target"
    assert_eq "$(printf '%s' "$correction" | jq -r --argjson i "$i" '.legacyFiles[$i].sha256')" \
      "$(sha256_of "$target")" "restored legacy sha for $legacy_path"
    assert_eq 755 "$(file_mode "$target")" "restored legacy mode for $legacy_path"
    i=$((i + 1))
  done

  n=$(printf '%s' "$correction" | jq '.pairedDirectShDocuments | length')
  i=0
  while [ "$i" -lt "$n" ]; do
    legacy_path=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.pairedDirectShDocuments[$i].path')
    git_mode=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.pairedDirectShDocuments[$i].gitMode')
    target=$fixture/$legacy_path
    mkdir -p "$(dirname "$target")"
    git -C "$ROOT" show "$LEGACY_REF:$legacy_path" >"$target" || { fail "git show $LEGACY_REF:$legacy_path failed"; return 1; }
    chmod "${git_mode#100}" "$target"
    assert_eq "$(printf '%s' "$correction" | jq -r --argjson i "$i" '.pairedDirectShDocuments[$i].sha256')" \
      "$(sha256_of "$target")" "restored document sha for $legacy_path"
    assert_eq 644 "$(file_mode "$target")" "restored document mode for $legacy_path"
    local command
    while IFS= read -r command; do
      assert_file_contains "$target" "$command" "restored document command for $legacy_path"
    done < <(printf '%s' "$correction" | jq -r --argjson i "$i" '.pairedDirectShDocuments[$i].commands[]')
    i=$((i + 1))
  done

  local legacy_caller final_caller caller_file
  legacy_caller=$(printf '%s' "$correction" | jq -r '.callerRestoration.legacyCaller')
  final_caller=$(printf '%s' "$correction" | jq -r '.callerRestoration.finalCaller')
  caller_file=$fixture/$legacy_caller
  assert_eq "$(printf '%s' "$correction" | jq -r '.callerRestoration.legacyCallerSha256')" \
    "$(sha256_of "$caller_file")" "legacy caller sha"
  assert_file_contains "$caller_file" "version-find.sh" "legacy caller keeps its callee edge"

  # Apply the final state: every legacy file is replaced by the shipped file.
  n=$(printf '%s' "$correction" | jq '.legacyFiles | length')
  i=0
  while [ "$i" -lt "$n" ]; do
    legacy_path=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.legacyFiles[$i].legacyPath')
    final_path=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.legacyFiles[$i].finalPath')
    target=$fixture/$final_path
    mkdir -p "$(dirname "$target")"
    cp "$ROOT/$final_path" "$target"
    chmod "$(file_mode "$ROOT/$final_path")" "$target"
    assert_eq "$(sha256_of "$ROOT/$final_path")" "$(sha256_of "$target")" "final bytes for $final_path"
    assert_eq "$(file_mode "$ROOT/$final_path")" "$(file_mode "$target")" "final mode for $final_path"
    if [ "$legacy_path" != "$final_path" ]; then
      rm -f "$fixture/$legacy_path"
    fi
    i=$((i + 1))
  done

  n=$(printf '%s' "$correction" | jq '.pairedDirectShDocuments | length')
  i=0
  while [ "$i" -lt "$n" ]; do
    final_path=$(printf '%s' "$correction" | jq -r --argjson i "$i" '.pairedDirectShDocuments[$i].path')
    target=$fixture/$final_path
    cp "$ROOT/$final_path" "$target"
    chmod "$(file_mode "$ROOT/$final_path")" "$target"
    assert_eq "$(sha256_of "$ROOT/$final_path")" "$(sha256_of "$target")" "final document bytes for $final_path"
    local command
    while IFS= read -r command; do
      assert_file_contains "$target" "$command" "final document command for $final_path"
    done < <(printf '%s' "$manifest" | jq -r '.documents.finalCommands[]')
    i=$((i + 1))
  done

  if [ "$legacy_caller" != "$final_caller" ]; then
    assert_not_file "$fixture/$legacy_caller" "legacy caller removed"
  fi
  assert_file_contains "$fixture/$final_caller" "version-find.sh" "final caller keeps its callee edge"
  assert_eq "$(printf '%s' "$manifest" | jq -c '.restoreOrder')" \
    "$(printf '%s' "$correction" | jq -c '.restoreReapplyFixture.restoreOrder')" "restore order matches the manifest"
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
  assert_contains "$(cat "$out")" "Validated 44 bash skill scripts (19 former-sh, 1 former-py, 9 retained-mjs, 15 authored-mjs historical origins)." "validator summary"
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
  target=$fixture/skills/version-update/scripts/version-current.sh
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

trim() { # <file>
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$1"
}

case_version_current_isolated() {
  local fixture package source work out err rc
  work=$(workdir)
  fixture=$work/fixture
  mkdir -p "$fixture"
  package=$fixture/package.json
  source='{"name":"fixture","version":"1.2.3"}'
  printf '%s\n' "$source" >"$package"
  out=$work/stdout
  err=$work/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_CURRENT" "$package")
  assert_eq 0 "$rc" "version-current exit"
  assert_eq "$package|1.2.3" "$(trim "$out")" "version-current output"
  assert_eq "$source" "$(cat "$package")" "version-current leaves the package untouched"
}

case_version_rejects_leading_zero() {
  local fixture package work out err rc
  work=$(workdir)
  fixture="$work/hypercore version fixture"
  mkdir -p "$fixture"
  package=$fixture/package.json
  printf '%s\n' '{"name":"fixture","version":"1.2.3"}' >"$package"

  out=$work/stdout
  err=$work/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_APPLY" "01.2.3" "$package")
  assert_eq 1 "$rc" "leading-zero semver rejected"

  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_APPLY" "2.0.0" "$package")
  assert_eq 0 "$rc" "valid semver accepted"
  assert_file_contains "$package" '"version":"2.0.0"' "version rewritten in place"
}

case_version_apply_rollback() {
  local work fixture first_directory second_directory first second out err rc
  work=$(workdir)
  fixture=$work/fixture
  first_directory=$fixture/first
  second_directory=$fixture/second
  first=$first_directory/package.json
  second=$second_directory/package.json
  mkdir -p "$first_directory" "$second_directory"
  local padding first_source second_source
  padding=$(head -c 262144 /dev/zero | tr '\0' 'x')
  first_source=$(printf '{"name":"first","version":"1.2.3","padding":"%s"}' "$padding")
  second_source='{"name":"second","version":"1.2.3"}'
  printf '%s\n' "$first_source" >"$first"
  printf '%s\n' "$second_source" >"$second"
  chmod 640 "$first"
  chmod 600 "$second"
  cp "$first" "$work/first.original"
  cp "$second" "$work/second.original"
  chmod 500 "$second_directory"

  out=$work/stdout
  err=$work/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_APPLY" "2.0.0" "$first" "$second")
  chmod 755 "$second_directory"

  assert_eq 1 "$rc" "version-apply fails when the later write cannot proceed"
  assert_nonempty "$(trim "$err")" "rollback failure is reported"
  cmp -s "$work/first.original" "$first" || { fail "first package bytes changed"; return 1; }
  assert_eq 640 "$(file_mode "$first")" "first package keeps its mode"
  cmp -s "$work/second.original" "$second" || { fail "second package bytes changed"; return 1; }
  assert_eq 600 "$(file_mode "$second")" "second package keeps its mode"
  assert_eq "package.json" "$(ls -A "$first_directory")" "no temporary files beside the first package"
  assert_eq "package.json" "$(ls -A "$second_directory")" "no temporary files beside the second package"
  assert_eq "first second" "$(find "$fixture" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')" "fixture keeps only its inputs"
}

case_autoresearch_corpus() {
  require_cmd jq
  local eval_file work contract
  eval_file=$ROOT/skills/autoresearch-skill/assets/evals/autoresearch-skill-cases.jsonl
  work=$(workdir)
  jq -s -e '
    (map(has("id") and (.id | type == "string")) | all) and
    (([.[].id] | length) == ([.[].id] | unique | length)) and
    (map(.prompt | type == "string") | all) and
    (map(.context | type == "object") | all) and
    (map((.expected.must | length) > 0 and (.expected.mustNot | length) > 0) | all) and
    (map((.metrics | length) > 0) | all) and
    (map(.category as $c |
      if (["positive", "negative", "boundary", "coexistence"] | index($c)) != null
      then (.expect == "trigger" or .expect == "no_trigger")
      else true end) | all)
  ' "$eval_file" >/dev/null || { fail "autoresearch eval corpus has malformed rows"; return 1; }
  jq -s -e '([.[].category] | unique) as $c | (["positive","negative","boundary","adversarial","regression"] - $c | length) == 0' \
    "$eval_file" >/dev/null || { fail "autoresearch corpus misses a required category"; return 1; }
  jq -s -e 'any(.[]; .language == "ko" and .expect == "trigger")' "$eval_file" >/dev/null \
    || { fail "no Korean triggering case"; return 1; }
  jq -s -e 'any(.[]; .language == "ko" and .expect == "no_trigger")' "$eval_file" >/dev/null \
    || { fail "no Korean non-triggering case"; return 1; }

  contract=$work/contract.md
  cat \
    "$ROOT/skills/autoresearch-skill/SKILL.md" \
    "$ROOT/skills/autoresearch-skill/SKILL.ko.md" \
    "$ROOT/skills/autoresearch-skill/rules/experiment-loop.md" \
    "$ROOT/skills/autoresearch-skill/rules/experiment-loop.ko.md" \
    "$ROOT/skills/autoresearch-skill/rules/context-sourcing-and-trace.md" \
    "$ROOT/skills/autoresearch-skill/rules/context-sourcing-and-trace.ko.md" \
    "$ROOT/skills/autoresearch-skill/rules/validation-and-exit.md" \
    "$ROOT/skills/autoresearch-skill/rules/validation-and-exit.ko.md" \
    "$ROOT/skills/autoresearch-skill/references/artifact-spec.md" \
    "$ROOT/skills/autoresearch-skill/references/artifact-spec.ko.md" >"$contract"
  local pattern
  for pattern in \
    'compare-before-restore' \
    'guard-error' \
    'cleanup-error' \
    'rollback-error' \
    'manual_recovery' \
    'non_resumable' \
    'last finalized iteration|last_finalized_iteration' \
    'network destination/data|destination/data policy'; do
    if ! grep -Eq "$pattern" "$contract"; then
      fail "autoresearch contract misses /$pattern/"
      return 1
    fi
  done
}

case_deploy_fix_corpus() {
  require_cmd jq
  local eval_file work contract
  eval_file=$ROOT/skills/deploy-fix/assets/evals/deploy-fix-cases.jsonl
  work=$(workdir)
  jq -s -e '
    (map((.id | type == "string") and ((.id | length) > 0)) | all) and
    (([.[].id] | length) == ([.[].id] | unique | length)) and
    (map((.prompt | type == "string") and ((.prompt | length) > 0)) | all) and
    (map((.context.files | type == "array") and (.context.sources | type == "array")) | all) and
    (map((.expected.must | type == "array") and ((.expected.must | length) > 0) and (.expected.mustNot | type == "array") and ((.expected.mustNot | length) > 0)) | all) and
    (map((.metrics | type == "array") and ((.metrics | length) > 0)) | all)
  ' "$eval_file" >/dev/null || { fail "deploy-fix eval corpus has malformed rows"; return 1; }
  jq -s -e '([.[].category] | unique) as $c | (["positive","negative","boundary","workflow","source","safety","adversarial","regression"] - $c | length) == 0' \
    "$eval_file" >/dev/null || { fail "deploy-fix corpus misses a required category"; return 1; }
  jq -s -e '([.[].language] | unique) as $l | (["en","ko","mixed"] - $l | length) == 0' \
    "$eval_file" >/dev/null || { fail "deploy-fix corpus misses a language"; return 1; }
  jq -s -e '([.[].invocationMode] | unique) as $m | (["explicit","implicit","contextual","negative-control"] - $m | length) == 0' \
    "$eval_file" >/dev/null || { fail "deploy-fix corpus misses an invocation mode"; return 1; }
  assert_eq 3 "$(jq -s '[.[] | select(.category == "positive")] | length' "$eval_file")" "positive cases"
  assert_eq 2 "$(jq -s '[.[] | select(.category == "negative")] | length' "$eval_file")" "negative cases"
  jq -s -e 'any(.[]; .expect == "trigger")' "$eval_file" >/dev/null || { fail "no triggering case"; return 1; }
  jq -s -e 'any(.[]; .expect == "no_trigger")' "$eval_file" >/dev/null || { fail "no non-triggering case"; return 1; }

  contract=$work/contract.md
  cat \
    "$ROOT/skills/deploy-fix/SKILL.md" \
    "$ROOT/skills/deploy-fix/SKILL.ko.md" \
    "$ROOT/skills/deploy-fix/rules/diagnosis-resume-and-safety.md" \
    "$ROOT/skills/deploy-fix/rules/diagnosis-resume-and-safety.ko.md" \
    "$ROOT/skills/deploy-fix/references/flow-schema.md" \
    "$ROOT/skills/deploy-fix/references/flow-schema.ko.md" >"$contract"
  local pattern
  for pattern in \
    'evidence only|근거일 뿐' \
    'non-resumable' \
    'authorized_target' \
    'rollback_or_stop' \
    'one materially different approach|실질적으로 다른 접근'; do
    if ! grep -Eq "$pattern" "$contract"; then
      fail "deploy-fix contract misses /$pattern/"
      return 1
    fi
  done
}

case_autoresearch_dashboard_typed_statuses() {
  require_cmd jq
  local work fixture statuses
  work=$(workdir)
  fixture=$work/fixture
  mkdir -p "$fixture"
  statuses='["tie","inconclusive","candidate-crash","infra-flake","timeout","signaled","guard-failed","guard-error","cleanup-error","rollback-error"]'
  printf '%s' "$statuses" | jq '{
    skill_name: "fixture",
    status: "running",
    current_experiment: length,
    baseline_score: 1,
    best_score: 1,
    metric_direction: "higher_is_better",
    last_statuses: .,
    best_experiment: 0,
    experiments: [to_entries[] | {
      id: .key,
      commit: "-",
      score: 1,
      max_score: 1,
      metric: 1,
      delta: 0,
      pass_rate: 100,
      guard: (if .value == "guard-failed" then "fail" elif .value == "guard-error" then "error" else "pass" end),
      guard_metric: null,
      status: .value,
      description: .value
    }]
  }' >"$fixture/results.json"

  local out err rc
  out=$work/stdout
  err=$work/stderr
  rc=$(run_in "$fixture" "$out" "$err" bash "$ROOT/skills/autoresearch-skill/scripts/render-dashboard.sh" "$fixture")
  assert_eq 0 "$rc" "dashboard render exit"
  assert_eq "dashboard.html results.js results.json" \
    "$(find "$fixture" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')" "dashboard outputs"
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

case_version_git_helpers_reject_unrelated() {
  local fixture out err rc
  fixture=$(workdir)
  init_git "$fixture"
  printf 'initial\n' >"$fixture/a.txt"
  printf 'initial\n' >"$fixture/b.txt"
  git -C "$fixture" add a.txt b.txt
  git -C "$fixture" commit -qm initial
  printf 'changed\n' >"$fixture/a.txt"
  printf 'changed\n' >"$fixture/b.txt"
  git -C "$fixture" add b.txt

  out=$(mktemp "$fixture/stdout.XXXXXX")
  err=$(mktemp "$fixture/stderr.XXXXXX")
  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_GIT_COMMIT" "test: scoped" a.txt)
  assert_eq 1 "$rc" "scoped commit refuses unrelated staged files"
  assert_eq "b.txt" "$(git -C "$fixture" diff --cached --name-only | tr -d '\n')" "unrelated index entry preserved"
  assert_eq "initial" "$(git -C "$fixture" log -1 --format=%s)" "no commit was created"
}

case_version_git_commit_all_is_literal() {
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
  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_GIT_COMMIT" "test: injection" "--all")
  assert_eq 1 "$rc" "--all is treated as a literal path"
  assert_eq "" "$(git -C "$fixture" diff --cached --name-only | tr -d '\n')" "nothing staged"
  assert_eq "initial" "$(git -C "$fixture" log -1 --format=%s)" "no commit was created"
}

case_version_git_commit_boundaries() {
  local fixture marker out err rc path
  fixture=$(workdir)
  marker=$fixture/marker.txt
  printf 'unchanged\n' >"$marker"

  out=$(mktemp "$fixture/stdout.XXXXXX")
  err=$(mktemp "$fixture/stderr.XXXXXX")
  rc=$(run_in "$fixture" "$out" "$err" env LC_ALL=C LANG=C bash "$VERSION_GIT_COMMIT" "test: boundary" "$marker")
  assert_eq 1 "$rc" "non-repository boundary exit"
  assert_contains "$(cat "$err")" "Not a git repository" "non-repository message"
  assert_eq "unchanged" "$(tr -d '\n' <"$marker")" "marker untouched outside a repository"

  path=$(write_fake_git "$fixture" '#!/bin/sh
printf "%s\n" "$*" >> git-calls.log
printf "%s\n" "fake rev-parse failure" >&2
exit 97
')
  rm -f "$fixture/git-calls.log"
  out=$(mktemp "$fixture/stdout.XXXXXX")
  err=$(mktemp "$fixture/stderr.XXXXXX")
  rc=$(run_in "$fixture" "$out" "$err" env "PATH=$path" bash "$VERSION_GIT_COMMIT" "test: inspection" "$marker")
  assert_eq 97 "$rc" "Git inspection failure propagates"
  assert_contains "$(cat "$err")" "fake rev-parse failure" "inspection stderr"
  assert_eq "rev-parse --git-dir" "$(trim "$fixture/git-calls.log")" "only the first inspection ran"
  assert_eq "unchanged" "$(tr -d '\n' <"$marker")" "marker untouched after inspection failure"
}

case_version_current_forwards_signals() {
  local fixture current_fixture finder ready signal_file out err
  fixture=$(workdir)
  current_fixture=$fixture/version-current.sh
  cp "$VERSION_CURRENT" "$current_fixture"
  finder=$fixture/version-find.sh
  cat >"$finder" <<'FINDER'
#!/usr/bin/env bash
set -u
printf '%s' "$$" > "$READY_FILE"
trap 'printf %s SIGTERM > "$SIGNAL_FILE"; exit 143' TERM
trap 'printf %s SIGINT > "$SIGNAL_FILE"; exit 130' INT
deadline=$((SECONDS + 90))
while kill -0 "$PPID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do sleep 0.02; done
exit 99
FINDER
  chmod 755 "$finder"

  local name expected signal pid rc discovery_pid alive
  set -m
  for entry in "SIGTERM:143" "SIGINT:130"; do
    name=${entry%:*}
    expected=${entry#*:}
    ready=$fixture/ready-$name
    signal_file=$fixture/signal-$name
    out=$fixture/stdout-$name
    err=$fixture/stderr-$name
    (
      cd "$fixture" || exit 1
      exec env "READY_FILE=$ready" "SIGNAL_FILE=$signal_file" bash "$current_fixture"
    ) >"$out" 2>"$err" &
    pid=$!
    if ! wait_for_file "$ready" 200; then
      kill -KILL "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      fail "version-current discovery child never signalled ready ($name)"
      return 1
    fi
    discovery_pid=$(tr -d '[:space:]' <"$ready")
    kill -s "$name" "$pid" 2>/dev/null || true
    rc=0
    wait "$pid" 2>/dev/null || rc=$?
    assert_eq "$expected" "$rc" "version-current exit after $name"
    assert_eq "$name" "$(cat "$signal_file" 2>/dev/null)" "discovery child received $name"
    alive=1
    kill -0 "$discovery_pid" 2>/dev/null || alive=0
    assert_eq 0 "$alive" "discovery child reaped after $name"
  done
  set +m
}

case_version_git_push_unknown_arguments() {
  local fixture out err rc
  fixture=$(workdir)
  git -C "$fixture" init -q
  out=$(mktemp "$fixture/stdout.XXXXXX")
  err=$(mktemp "$fixture/stderr.XXXXXX")
  rc=$(run_in "$fixture" "$out" "$err" bash "$VERSION_GIT_PUSH" "--unknown")
  assert_eq 2 "$rc" "unknown argument exit"
  assert_contains "$(cat "$err")" "Usage:" "unknown argument usage"
}

case_version_git_push_upstream_failure() {
  local fixture out err rc path calls
  fixture=$(workdir)
  path=$(write_fake_git "$fixture" '#!/bin/sh
printf "%s\n" "$*" >> git-calls.log
case "$*" in
  "rev-parse --git-dir") printf "%s\n" .git ;;
  "branch --show-current") printf "%s\n" topic ;;
  "for-each-ref --format=%(upstream:short) refs/heads/topic") printf "%s\n" "fake upstream failure" >&2; exit 97 ;;
  *) printf "%s\n" "unexpected git invocation: $*" >&2; exit 98 ;;
esac
')
  out=$(mktemp "$fixture/stdout.XXXXXX")
  err=$(mktemp "$fixture/stderr.XXXXXX")
  rc=$(run_in "$fixture" "$out" "$err" env "PATH=$path" bash "$VERSION_GIT_PUSH")
  assert_eq 97 "$rc" "upstream inspection failure propagates"
  assert_contains "$(cat "$err")" "fake upstream failure" "upstream failure stderr"
  calls=$(cat "$fixture/git-calls.log")
  assert_eq "rev-parse --git-dir
branch --show-current
for-each-ref --format=%(upstream:short) refs/heads/topic" "$calls" "push stops before the network"
}

case_git_maker_commit_rejects_option_paths() {
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
  rc=$(run_in "$fixture" "$out" "$err" bash "$GIT_MAKER_COMMIT" "test: injection" "--all")
  assert_eq 1 "$rc" "option-like path rejected"
  assert_contains "$(cat "$err")" "Usage:" "option-like path usage"
  assert_eq "" "$(git -C "$fixture" diff --cached --name-only | tr -d '\n')" "nothing staged"
  assert_eq "initial" "$(git -C "$fixture" log -1 --format=%s)" "no commit was created"
}

case_git_maker_discover_status_reject_option_paths() {
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

pre_deploy_child_source() { # <role>
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

case_pre_deploy_forwards_termination() {
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
    pre_deploy_child_source lint >"$scripts/lint-check.sh"
    pre_deploy_child_source build >"$scripts/build-run.sh"
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

case_git_maker_fast_reaps_children() {
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
      exec env "PATH=$path" "PROBE_ROOT=$fixture" "MODE=$mode" bash "$GIT_MAKER_FAST" inspect "$fixture" --jobs 2
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
    assert_eq "$expected" "$rc" "git-maker-fast exit ($mode/$signal)"
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

case_git_maker_fast_paths_with_spaces() {
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
  rc=$(run_in "$fixture" "$out" "$err" bash "$GIT_MAKER_FAST" inspect "$repository" --jobs=1)
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

case_pre_deploy_rejects_malformed_metadata() {
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
  validator=$ROOT/skills/skill-maker/scripts/validate-skill-maker.sh
  evals=$ROOT/skills/skill-maker/assets/evals/skill-maker-cases.jsonl
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
  validator=$ROOT/skills/skill-maker/scripts/validate-skill-maker.sh
  evals=$ROOT/skills/skill-maker/assets/evals/skill-maker-cases.jsonl
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

# image-maker and git-worktree ship their own validators outside the standard gate,
# so the repository suite runs them here to catch drift in their fixtures and core.
case_image_maker_validator() {
  require_cmd jq
  local out err rc work
  work=$(workdir)
  out=$work/image-maker.json
  err=$work/image-maker.err
  rc=$(run_in "$ROOT" "$out" "$err" bash "$ROOT/skills/image-maker/scripts/validate-image-maker.sh" --root skills/image-maker --json)
  assert_eq 0 "$rc" "image-maker validator exit"
  assert_json_valid "$out" "image-maker validator output"
  assert_eq "true" "$(jq -r '.ok' "$out")" "image-maker validator ok"
  assert_eq 0 "$(jq -r '.counts.errors' "$out")" "image-maker case errors"
  assert_eq "$(jq -r '.counts.total' "$out")" \
    "$(jq -r '.counts.automatic + .counts.manual_required' "$out")" "image-maker case total"
  assert_eq "$(jq -r '.counts.manual_required' "$out")" \
    "$(jq -r '.manual_required | length' "$out")" "image-maker manual cases"
}

case_git_worktree_validator() {
  require_cmd jq
  local out err rc work
  work=$(workdir)
  out=$work/git-worktree.json
  err=$work/git-worktree.err
  rc=$(run_in "$ROOT" "$out" "$err" bash "$ROOT/skills/git-worktree/scripts/validate-git-worktree-skill.sh")
  assert_eq 0 "$rc" "git-worktree validator exit"
  assert_json_valid "$out" "git-worktree validator output"
  assert_eq "$(jq -r '.total' "$out")" "$(jq -r '.score' "$out")" "git-worktree validator score"
  assert_jq "$out" '.total > 0 and (.checks | length) > 0 and all(.checks[]; .pass)' "git-worktree validator checks"
}

STRUCTURE_GATE_MARKERS='필수 키가 없습니다
값이 유효하지 않습니다
배열이어야 합니다
객체여야 합니다
0..100 또는 null이어야 합니다
JSON 파싱에 실패했습니다'

renderer_results_json() { # <name>
  case $1 in
    autoresearch-skill)
      printf '%s' '{"skill_name":"fixture","status":"running","current_experiment":0,"baseline_score":1,"best_score":1,"metric_direction":"higher_is_better","last_statuses":[],"best_experiment":0,"experiments":[]}'
      ;;
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
    autoresearch-skill:second-write)
      printf '%s' "  if ! printf 'window.__AUTORESEARCH_RESULTS__ = %s;\\nwindow.__AUTORESEARCH_DETAILS__ = %s;\\n' \"\$results_json\" \"\$details_json\" | write_temp_stream \"\$RESULTS_JS_TEMP\" \"\$RESULTS_MODE\"; then"
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
    autoresearch-skill)
      template=$ROOT/skills/autoresearch-skill/assets/dashboard-template.html
      src_script=$ROOT/skills/autoresearch-skill/scripts/render-dashboard.sh
      ;;
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

case_autoresearch_renderer_second_write() { renderer_atomic_case autoresearch-skill second-write; }
case_autoresearch_renderer_second_rename() { renderer_atomic_case autoresearch-skill second-rename; }
case_hyper_seo_renderer_second_write() { renderer_atomic_case hyper-seo second-write; }
case_hyper_seo_renderer_second_rename() { renderer_atomic_case hyper-seo second-rename; }

run_case "manifest centrally inventories 44 scripts including fifteen authored baseline-absent MJS paths" case_manifest_inventory
run_case "behavior contracts execute all 132 isolated semantic fixtures with exact observables" case_behavior_contracts
run_case "detector-absent correction restores legacy bytes and reapplies the exact final filesystem state" case_detector_absent_correction
run_case "validator accepts the approved inventory" case_validator_accepts_inventory
run_case "validator rejects bash policy mutations a real regression would introduce" case_validator_rejects_mutations
run_case "version-current reads an isolated package fixture without changing it" case_version_current_isolated
run_case "version scripts reject leading-zero semver and preserve paths with spaces" case_version_rejects_leading_zero
run_case "version-apply leaves every input untouched when a later write cannot proceed" case_version_apply_rollback
run_case "autoresearch skill contract eval corpus is valid and covers fail-closed recovery" case_autoresearch_corpus
run_case "deploy-fix eval corpus covers trigger, trajectory, safety, and recovery regressions" case_deploy_fix_corpus
run_case "autoresearch dashboard accepts typed non-happy outcomes" case_autoresearch_dashboard_typed_statuses
run_case "version Git helpers reject unrelated staged files without staging requested files" case_version_git_helpers_reject_unrelated
run_case "version git-commit treats --all as a literal path and cannot stage unrelated files" case_version_git_commit_all_is_literal
run_case "version git-commit stops at Git inspection failures and non-repository boundaries" case_version_git_commit_boundaries
run_case "version-current forwards SIGTERM and SIGINT and reaps its ready discovery child" case_version_current_forwards_signals
run_case "version git-push rejects unknown arguments before touching a remote" case_version_git_push_unknown_arguments
run_case "version git-push stops before network push when upstream inspection fails" case_version_git_push_upstream_failure
run_case "git-maker commit rejects option-like paths without staging unrelated changes" case_git_maker_commit_rejects_option_paths
run_case "git-maker discover and status reject option-like paths before Git inspection" case_git_maker_discover_status_reject_option_paths
run_case "pre-deploy drains multi-MiB children and forwards termination without orphaning sequential or parallel work" case_pre_deploy_forwards_termination
run_case "git-maker-fast drains concurrent fake Git children, stops queued work, and reaps children on failures and signals" case_git_maker_fast_reaps_children
run_case "git-maker-fast inspects a repository whose path contains spaces without remote access" case_git_maker_fast_paths_with_spaces
run_case "pre-deploy rejects malformed package metadata" case_pre_deploy_rejects_malformed_metadata
run_case "self-containment check catches cross-skill references, including with no sibling present" case_self_containment_check
run_case "script-runtime check rejects non-bash bundled scripts and non-bash shebangs" case_script_runtime_check
run_case "the image-maker validator accepts its own skill folder and eval corpus" case_image_maker_validator
run_case "the git-worktree validator scores its own skill folder at full marks" case_git_worktree_validator
run_case "autoresearch-skill preserves both prior outputs when its second-write fails" case_autoresearch_renderer_second_write
run_case "autoresearch-skill preserves both prior outputs when its second-rename fails" case_autoresearch_renderer_second_rename
run_case "hyper-seo preserves both prior outputs when its second-write fails" case_hyper_seo_renderer_second_write
run_case "hyper-seo preserves both prior outputs when its second-rename fails" case_hyper_seo_renderer_second_rename

test_summary
