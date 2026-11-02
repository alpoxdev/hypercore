#!/usr/bin/env bash
# Applies a semantic version to explicitly supplied or discovered version files.
# Usage: version-apply.sh <new_version> [files...]

set -euo pipefail

work="$(mktemp -d "${TMPDIR:-/tmp}/version-apply.XXXXXX")"
child_pid=""
plan_files=()
plan_modes=()
plan_temps=()
plan_stages=()
plan_count=0
replaced_indices=()

cleanup() {
  local idx
  for ((idx = 0; idx < plan_count; idx++)); do
    rm -f "${plan_temps[$idx]}" 2>/dev/null || true
  done
  rm -rf "$work"
}

forward_signal() {
  local signal="$1"
  if [ -n "$child_pid" ]; then
    kill -s "$signal" "$child_pid" 2>/dev/null || true
    wait "$child_pid" 2>/dev/null || true
    child_pid=""
  fi
  case "$signal" in
    INT) exit 130 ;;
    TERM) exit 143 ;;
    *) exit 1 ;;
  esac
}

trap cleanup EXIT
trap 'forward_signal INT' INT
trap 'forward_signal TERM' TERM

discover() {
  local script_dir status=0
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  set -m
  bash "$script_dir/version-find.sh" --plain >"$work/find.stdout" 2>"$work/find.stderr" &
  child_pid=$!
  set +m
  wait "$child_pid" || status=$?
  child_pid=""
  if [ "$status" -ne 0 ]; then
    cat "$work/find.stderr" >&2
    echo "Error: Version discovery failed with exit code $status" >&2
    return 1
  fi
}

file_mode() {
  if [ "$platform" = "Darwin" ]; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

version_kind() {
  case "${1##*/}" in
    package.json) printf 'package' ;;
    Cargo.toml) printf 'cargo' ;;
    pyproject.toml) printf 'pyproject' ;;
    setup.py) printf 'setup' ;;
    *)
      case "$1" in
        *.py) printf 'py' ;;
        *) printf '' ;;
      esac
      ;;
  esac
}

ends_with_newline() {
  local last
  [ -s "$1" ] || return 1
  last="$(tail -c 1 "$1" | od -An -tx1 | tr -d ' \n')"
  [ "$last" = "0a" ]
}

# Every transform prints the full file to stdout, keeping the trailing-newline
# state of the source so the rewritten bytes match the original exactly.
update_package() {
  awk -v v="$2" -v nl="$3" '
    {
      line = $0
      if (!done && line ~ /"version"[[:blank:]]*:/) {
        gsub(/"[0-9]+\.[0-9]+\.[0-9]+"/, "\"" v "\"", line)
        done = 1
      }
      emit(line)
    }
    function emit(text) {
      if (started) printf "\n"
      printf "%s", text
      started = 1
    }
    END { if (started && nl + 0) printf "\n" }
  ' "$1"
}

update_cargo() {
  awk -v v="$2" -v nl="$3" '
    {
      line = $0
      bare = line
      sub(/\r$/, "", bare)
      if (bare ~ /^\[package\][[:blank:]]*$/) {
        in_package = 1
      } else if (bare ~ /^\[[^]]+\][[:blank:]]*$/) {
        in_package = 0
      } else if (in_package && bare ~ /^[[:blank:]]*version[[:blank:]]*=/) {
        sub(/"[0-9]+\.[0-9]+\.[0-9]+"/, "\"" v "\"", line)
      }
      if (started) printf "\n"
      printf "%s", line
      started = 1
    }
    END { if (started && nl + 0) printf "\n" }
  ' "$1"
}

update_pyproject() {
  awk -v v="$2" -v nl="$3" '
    {
      line = $0
      bare = line
      sub(/\r$/, "", bare)
      if (bare ~ /^\[[^]]+\][[:blank:]]*$/) {
        section = bare
      } else if ((section == "[project]" || section == "[tool.poetry]") && bare ~ /^[[:blank:]]*version[[:blank:]]*=/) {
        sub(/"[0-9]+\.[0-9]+\.[0-9]+"/, "\"" v "\"", line)
        sub(/\047[0-9]+\.[0-9]+\.[0-9]+\047/, "\047" v "\047", line)
      }
      if (started) printf "\n"
      printf "%s", line
      started = 1
    }
    END { if (started && nl + 0) printf "\n" }
  ' "$1"
}

update_setup() {
  awk -v v="$2" -v nl="$3" '
    {
      line = $0
      result = ""
      rest = line
      while (match(rest, /version[[:blank:]]*=[[:blank:]]*[\047"][0-9]+\.[0-9]+\.[0-9]+[\047"]/)) {
        matched = substr(rest, RSTART, RLENGTH)
        sub(/[0-9]+\.[0-9]+\.[0-9]+/, v, matched)
        result = result substr(rest, 1, RSTART - 1) matched
        rest = substr(rest, RSTART + RLENGTH)
      }
      line = result rest
      if (started) printf "\n"
      printf "%s", line
      started = 1
    }
    END { if (started && nl + 0) printf "\n" }
  ' "$1"
}

update_py() {
  awk -v v="$2" -v nl="$3" '
    {
      line = $0
      if (!done) {
        bare = line
        sub(/\r$/, "", bare)
        if (match(bare, /^[[:blank:]]*__version__[[:blank:]]*=[[:blank:]]*[\047"][0-9]+\.[0-9]+\.[0-9]+[\047"]/)) {
          sub(/[0-9]+\.[0-9]+\.[0-9]+/, v, line)
          done = 1
        }
      }
      result = ""
      rest = line
      while (match(rest, /\.version\([\047"][0-9]+\.[0-9]+\.[0-9]+[\047"]\)/)) {
        matched = substr(rest, RSTART, RLENGTH)
        sub(/[0-9]+\.[0-9]+\.[0-9]+/, v, matched)
        result = result substr(rest, 1, RSTART - 1) matched
        rest = substr(rest, RSTART + RLENGTH)
      }
      line = result rest
      if (started) printf "\n"
      printf "%s", line
      started = 1
    }
    END { if (started && nl + 0) printf "\n" }
  ' "$1"
}

has_requested_version() {
  local kind="$1" target="$2" version="$3"
  case "$kind" in
    package)
      awk -v ver="$version" '
        function esc(s, o, i, c) {
          o = ""
          for (i = 1; i <= length(s); i++) {
            c = substr(s, i, 1)
            if (c == ".") c = "\\."
            o = o c
          }
          return o
        }
        BEGIN { re = "\"version\"[[:blank:]]*:[[:blank:]]*\"" esc(ver) "\"" }
        $0 ~ re { found = 1 }
        END { exit(found ? 0 : 1) }
      ' "$target"
      ;;
    cargo)
      awk -v ver="$version" '
        function esc(s, o, i, c) {
          o = ""
          for (i = 1; i <= length(s); i++) {
            c = substr(s, i, 1)
            if (c == ".") c = "\\."
            o = o c
          }
          return o
        }
        BEGIN { re = "^[[:blank:]]*version[[:blank:]]*=[[:blank:]]*\"" esc(ver) "\"" }
        {
          line = $0
          sub(/\r$/, "", line)
          if (line ~ /^\[[^]]+\][[:blank:]]*$/) section = line
          if (section == "[package]" && line ~ re) found = 1
        }
        END { exit(found ? 0 : 1) }
      ' "$target"
      ;;
    pyproject)
      awk -v ver="$version" '
        function esc(s, o, i, c) {
          o = ""
          for (i = 1; i <= length(s); i++) {
            c = substr(s, i, 1)
            if (c == ".") c = "\\."
            o = o c
          }
          return o
        }
        BEGIN { re = "^[[:blank:]]*version[[:blank:]]*=[[:blank:]]*[\047\"]" esc(ver) "[\047\"]" }
        {
          line = $0
          sub(/\r$/, "", line)
          if (line ~ /^\[[^]]+\][[:blank:]]*$/) section = line
          if ((section == "[project]" || section == "[tool.poetry]") && line ~ re) found = 1
        }
        END { exit(found ? 0 : 1) }
      ' "$target"
      ;;
    setup)
      awk -v ver="$version" '
        function esc(s, o, i, c) {
          o = ""
          for (i = 1; i <= length(s); i++) {
            c = substr(s, i, 1)
            if (c == ".") c = "\\."
            o = o c
          }
          return o
        }
        BEGIN { re = "version[[:blank:]]*=[[:blank:]]*[\047\"]" esc(ver) "[\047\"]" }
        $0 ~ re { found = 1 }
        END { exit(found ? 0 : 1) }
      ' "$target"
      ;;
    *)
      awk -v ver="$version" '
        function esc(s, o, i, c) {
          o = ""
          for (i = 1; i <= length(s); i++) {
            c = substr(s, i, 1)
            if (c == ".") c = "\\."
            o = o c
          }
          return o
        }
        BEGIN { re = "(__version__[[:blank:]]*=[[:blank:]]*[\047\"]" esc(ver) "[\047\"]|\\.version\\([\047\"]" esc(ver) "[\047\"]\\))" }
        $0 ~ re { found = 1 }
        END { exit(found ? 0 : 1) }
      ' "$target"
      ;;
  esac
}

rollback_and_fail() {
  local detail="$1" idx position errors=""
  for ((position = ${#replaced_indices[@]} - 1; position >= 0; position--)); do
    idx="${replaced_indices[$position]}"
    if [ -e "${plan_temps[$idx]}" ]; then
      rm -f "${plan_temps[$idx]}" 2>/dev/null || true
    fi
    if (set -o noclobber; : >"${plan_temps[$idx]}") 2>/dev/null &&
      cat "$work/backup.$idx" >"${plan_temps[$idx]}" 2>/dev/null &&
      chmod "${plan_modes[$idx]}" "${plan_temps[$idx]}" 2>/dev/null &&
      mv -f "${plan_temps[$idx]}" "${plan_files[$idx]}" 2>/dev/null; then
      :
    else
      errors="$errors ${plan_files[$idx]}: rollback failed;"
    fi
  done
  for ((idx = 0; idx < plan_count; idx++)); do
    rm -f "${plan_temps[$idx]}" 2>/dev/null || true
  done
  echo "Error: Version update failed; restored replaced files. ${detail}${errors:+ Rollback errors:${errors}}" >&2
  exit 1
}

if [ "$#" -lt 1 ] || [ -z "${1-}" ]; then
  echo "Usage: $0 <new_version> [files...]" >&2
  exit 1
fi

new_version="$1"
shift
if ! [[ "$new_version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  echo "Error: Invalid version format: $new_version (expected x.y.z)" >&2
  exit 1
fi

files=("$@")
if [ "${#files[@]}" -eq 0 ]; then
  discover
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [ -n "$line" ] || continue
    files+=("$line")
  done <"$work/find.stdout"
fi
if [ "${#files[@]}" -eq 0 ]; then
  echo "Error: No version files found" >&2
  exit 1
fi

platform="$(uname -s)"
index=0
for file in ${files[@]+"${files[@]}"}; do
  if [ ! -e "$file" ]; then
    echo "Error: Version file not found: $file" >&2
    exit 1
  fi
  kind="$(version_kind "$file")"
  if [ -z "$kind" ]; then
    echo "Error: Unsupported version file: $file" >&2
    exit 1
  fi
  if [ ! -f "$file" ]; then
    echo "Error: Version target is not a file: $file" >&2
    exit 1
  fi

  mode="$(file_mode "$file")"
  if ends_with_newline "$file"; then
    nl=1
  else
    nl=0
  fi
  stage="$work/stage.$index"
  case "$kind" in
    package) update_package "$file" "$new_version" "$nl" >"$stage" ;;
    cargo) update_cargo "$file" "$new_version" "$nl" >"$stage" ;;
    pyproject) update_pyproject "$file" "$new_version" "$nl" >"$stage" ;;
    setup) update_setup "$file" "$new_version" "$nl" >"$stage" ;;
    *) update_py "$file" "$new_version" "$nl" >"$stage" ;;
  esac
  if cmp -s "$file" "$stage"; then
    echo "Error: No version update applied to $file" >&2
    exit 1
  fi
  if ! has_requested_version "$kind" "$stage" "$new_version"; then
    echo "Error: Version postcondition failed for $file" >&2
    exit 1
  fi

  plan_files[index]="$file"
  plan_modes[index]="$mode"
  plan_temps[index]="${file}.version-apply-$$-$index.tmp"
  plan_stages[index]="$stage"
  index=$((index + 1))
done
plan_count=$index

for ((index = 0; index < plan_count; index++)); do
  file="${plan_files[$index]}"
  tmp="${plan_temps[$index]}"
  detail=""
  if [ -e "$tmp" ]; then
    detail="EEXIST: file already exists, open '$tmp'"
  elif ! (set -o noclobber; : >"$tmp") 2>/dev/null; then
    detail="failed to create temporary file: $tmp"
  elif ! cat "${plan_stages[$index]}" >"$tmp" 2>/dev/null; then
    detail="failed to write temporary file: $tmp"
  elif ! chmod "${plan_modes[$index]}" "$tmp" 2>/dev/null; then
    detail="failed to set mode on temporary file: $tmp"
  elif ! cp -p "$file" "$work/backup.$index" 2>/dev/null; then
    detail="failed to back up $file"
  elif ! mv -f "$tmp" "$file" 2>/dev/null; then
    detail="failed to replace $file"
  fi
  if [ -n "$detail" ]; then
    rollback_and_fail "$detail"
  fi
  replaced_indices+=("$index")
done

for ((index = 0; index < plan_count; index++)); do
  echo "[updated] ${plan_files[$index]}"
done
echo "Applied version $new_version to $plan_count file(s)."
