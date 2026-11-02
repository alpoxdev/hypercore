#!/usr/bin/env bash
# Render the autoresearch dashboard: copy the HTML template and embed results.json
# plus detail files into results.js. Rejects an invalid payload before writing.
set -euo pipefail

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

# Normalize a path the way Node's path.join does: collapse duplicate
# separators, drop "." segments, and fold ".." where possible.
normalize_path() {
  awk -v raw="$1" 'BEGIN {
    absolute = (substr(raw, 1, 1) == "/");
    total = split(raw, parts, "/");
    count = 0;
    for (i = 1; i <= total; i++) {
      segment = parts[i];
      if (segment == "" || segment == ".") continue;
      if (segment == "..") {
        if (count > 0 && stack[count] != "..") {
          delete stack[count];
          count--;
        } else if (!absolute) {
          count++;
          stack[count] = "..";
        }
        continue;
      }
      count++;
      stack[count] = segment;
    }
    joined = "";
    for (i = 1; i <= count; i++) {
      joined = joined (i > 1 ? "/" : "") stack[i];
    }
    if (absolute) joined = "/" joined;
    if (joined == "") joined = (absolute ? "/" : ".");
    printf "%s", joined;
  }'
}

join_path() {
  local base=$1 leaf=$2 joined
  if [ -z "$base" ]; then
    joined=$leaf
  elif [ "$base" = "/" ]; then
    joined="/$leaf"
  else
    joined="${base%/}/$leaf"
  fi
  normalize_path "$joined"
}

file_mode() {
  local mode
  if mode=$(stat -c '%a' "$1" 2>/dev/null); then
    printf '%s' "$mode"
  else
    stat -f '%Lp' "$1"
  fi
}

temporary_path() {
  printf '%s.%s.%s%s.tmp' "$1" "$$" "$RANDOM" "$RANDOM"
}


usage() {
  fail "사용법: bash scripts/render-dashboard.sh <artifact-dir>"
}

[ "$#" -eq 1 ] || usage

artifact_dir=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
skill_dir=$(dirname "$script_dir")
template_path="$skill_dir/assets/dashboard-template.html"
results_path=$(join_path "$artifact_dir" results.json)
dashboard_path=$(join_path "$artifact_dir" dashboard.html)
results_js_path=$(join_path "$artifact_dir" results.js)
explanation_path=$(join_path "$artifact_dir" score-explanation.md)

[ -f "$template_path" ] || fail "대시보드 템플릿이 없습니다: $template_path"
[ -f "$results_path" ] || fail "results.json이 없습니다: $results_path"

# JSON.parse rejects a byte order mark; jq would silently skip it.
bom_prefix=$(dd if="$results_path" bs=1 count=3 2>/dev/null | od -An -tx1 | tr -d ' \n' || true)
if [ "$bom_prefix" = "efbbbf" ]; then
  fail "results.json JSON 파싱에 실패했습니다: invalid JSON"
fi

explanation_file=0
if [ -f "$explanation_path" ]; then
  explanation_file=1
fi

# shellcheck disable=SC2016  # jq program text; $ names are jq variables.
JSON_JQ='
def hexchars: "0123456789abcdef";
def hex2: . as $n | hexchars[($n / 16 | floor):((($n / 16) | floor) + 1)] + hexchars[($n % 16):(($n % 16) + 1)];
def jstrraw:
  explode
  | map(
      if . == 34 then "\\\""
      elif . == 92 then "\\\\"
      elif . == 8 then "\\b"
      elif . == 12 then "\\f"
      elif . == 10 then "\\n"
      elif . == 13 then "\\r"
      elif . == 9 then "\\t"
      elif . < 32 then "\\u00" + (. | hex2)
      else [.] | implode
      end
    )
  | join("");
def jstr: "\"" + jstrraw + "\"";
def jsnum:
  (. + 0) as $v
  | if $v == 0 then "0"
    else
      ($v | tostring) as $s
      | (if ($s | startswith("-")) then "-" else "" end) as $sign
      | (if ($s | startswith("-")) then $s[1:] else $s end) as $body
      | (($body | index("e")) // ($body | index("E"))) as $eix
      | (if $eix == null then $body else $body[0:$eix] end) as $mant
      | (if $eix == null then 0 else ($body[($eix + 1):] | ltrimstr("+") | tonumber) end) as $exp
      | ($mant | index(".")) as $dix
      | (if $dix == null then $mant else $mant[0:$dix] end) as $ip
      | (if $dix == null then "" else $mant[($dix + 1):] end) as $fp
      | (($ip + $fp) | sub("^0+"; "")) as $lead
      | if $lead == "" then "0"
        else
          ($lead | length) as $k
          | ($lead | sub("0+$"; "")) as $digits
          | ($digits | length) as $kd
          | ($k - ($fp | length) + $exp) as $n
          | if $n >= $kd and $n <= 21 then $sign + $digits + ("0" * ($n - $kd))
            elif $n > 0 and $n < $kd and $n <= 21 then $sign + $digits[0:$n] + "." + $digits[$n:]
            elif $n <= 0 and $n > -6 then $sign + "0." + ("0" * (0 - $n)) + $digits
            else $sign + $digits[0:1] + (if $kd > 1 then "." + $digits[1:] else "" end) + "e" + (if $n - 1 >= 0 then "+" else "-" end) + (((($n - 1) | fabs)) | tostring)
            end
        end
    end;
def is_index_key: . as $k | ($k | test("^(0|[1-9][0-9]*)$")) and (($k | tonumber) <= 4294967294);
def jser:
  if type == "object" then
    ( [to_entries[] | select(.key | is_index_key)] | sort_by(.key | tonumber) ) as $idx
    | [to_entries[] | select((.key | is_index_key) | not)] as $rest
    | "{" + ([ ($idx[], $rest[]) | (.key | jstr) + ":" + (.value | jser) ] | join(",")) + "}"
  elif type == "array" then "[" + ([.[] | jser] | join(",")) + "]"
  elif type == "string" then jstr
  elif type == "number" then jsnum
  elif type == "boolean" then tostring
  else "null" end;
def isobj: type == "object";
def field($k): if (type == "object") and has($k) then {present: true, value: .[$k]} else {present: false, value: null} end;
def shown($f): if $f.present then ($f.value | jser) else "undefined" end;
def enum_ok($f; $allowed): ($f.present and (($f.value | type) == "string") and (($allowed | index($f.value)) != null));
def enum_msg($path; $f; $allowed): "results.json \($path) 값이 유효하지 않습니다: \(shown($f)) (허용: \($allowed | join(", ")))";
def nonempty_string($f): ($f.present and (($f.value | type) == "string") and (($f.value | gsub("^\\s+|\\s+$"; "")) != ""));

'

# shellcheck disable=SC2016  # jq program text; $ names are jq variables.
VALIDATION_MAIN='
def RAWSTATUSES: ["baseline", "keep", "keep-reworked", "discard", "tie", "inconclusive", "candidate-crash", "infra-flake", "timeout", "signaled", "no-op", "hook-blocked", "metric-error", "guard-failed", "guard-error", "cleanup-error", "rollback-error", "reset"];
def falsy($v): ($v == null) or ($v == false) or ($v == 0) or ($v == "");
def valstr($f): if ($f.present | not) then "undefined" elif (($f.value | type) == "string") then $f.value else ($f.value | tostring) end;
def ar_experiments_error($list):
  [ range(0; $list | length) as $i
    | $list[$i] as $e
    | (if ($e | isobj) then [ ["id", "commit", "score", "max_score", "metric", "delta", "pass_rate", "guard", "guard_metric", "status", "description"][] as $k | select(($e | has($k)) | not) | $k ] else null end) as $missing
    | if ($e | isobj | not) then "experiments[\($i)]는 객체여야 합니다"
      elif (($missing | length) > 0) then "experiments[\($i)] 필수 키가 없습니다: \($missing | sort | join(", "))"
      else ($e | field("status")) as $st
      | if (($st.present | not) or ((RAWSTATUSES | index($st.value)) == null)) then "experiments[\($i)].status 값이 유효하지 않습니다: \(valstr($st))"
        else null end
      end
  ] | map(select(. != null)) | .[0];
. as $docs
| if ($docs | length) != 1 then "E\tresults.json JSON 파싱에 실패했습니다: invalid JSON"
  else ($docs[0]) as $r
  | if ($r | isobj | not) then "E\tresults.json은 객체여야 합니다"
    else (["skill_name", "status", "current_experiment", "baseline_score", "best_score", "metric_direction", "last_statuses", "best_experiment", "experiments"]) as $req
    | ([ $req[] | . as $k | select(($r | has($k)) | not) ]) as $missing
    | if (($missing | length) > 0) then "E\tresults.json 필수 키가 없습니다: " + ($missing | sort | join(", "))
      else ($r | field("score_explanation")) as $se
      | if (($r.status == "complete") and (falsy($se.value)) and ($explanation_file == 0)) then "E\t완료 상태에는 results.json.score_explanation 또는 score-explanation.md가 필요합니다"
        elif (($r.experiments | type) != "array") then "E\tresults.json experiments는 배열이어야 합니다"
        else (ar_experiments_error($r.experiments)) as $err
        | if $err != null then "E\t" + $err else "O\t" + ($r | jser) end
        end
      end
    end
  end
'

VALIDATION_JQ="$JSON_JQ$VALIDATION_MAIN"

validation=$(jq -s -r --argjson explanation_file "$explanation_file" "$VALIDATION_JQ" "$results_path" 2>/dev/null) \
  || fail "results.json JSON 파싱에 실패했습니다: invalid JSON"

case $validation in
  O$'\t'*) results_json=${validation#O$'\t'} ;;
  E$'\t'*) fail "${validation#E$'\t'}" ;;
  *) fail "results.json JSON 파싱에 실패했습니다: invalid JSON" ;;
esac

# shellcheck disable=SC2016  # jq program text; $ names are jq variables.

SERIALIZE_JQ="$JSON_JQ"'
jser'

detail_title() {
  case $1 in
    changelog.md) printf '변경 로그' ;;
    score-explanation.md) printf '점수 상승 설명' ;;
    final-report.md) printf '최종 보고' ;;
    run-contract.md) printf '실행 계약' ;;
    source-ledger.md) printf '출처 기록' ;;
    trace-summary.md) printf '추적 검증 요약' ;;
    *) printf '%s' "$1" | tr '_-' '  ' ;;
  esac
}

file_extension() {
  local base=$1 rest
  case $base in
    . | ..) printf '' ;;
    .*)
      rest=${base#?}
      case $rest in
        *.*) printf '.%s' "${rest##*.}" ;;
        *) printf '' ;;
      esac
      ;;
    *.*) printf '.%s' "${base##*.}" ;;
    *) printf '' ;;
  esac
}

collect_files() {
  local directory=$1 entry
  while IFS= read -r entry; do
    if [ -L "$entry" ]; then
      if [ -f "$entry" ]; then
        printf '%s\n' "$entry"
      fi
    elif [ -d "$entry" ]; then
      collect_files "$entry"
    elif [ -f "$entry" ]; then
      printf '%s\n' "$entry"
    fi
  done < <(find "$directory" -mindepth 1 -maxdepth 1 -print)
}

DETAILS_ENTRIES=""

append_detail() {
  local relative=$1 absolute=$2 title=$3 entry
  entry=$(jq -n -c --arg path "$relative" --arg title "$title" --rawfile content "$absolute" '{path: $path, title: $title, content: $content}')
  if [ -z "$DETAILS_ENTRIES" ]; then
    DETAILS_ENTRIES=$entry
  else
    DETAILS_ENTRIES="$DETAILS_ENTRIES
$entry"
  fi
}

for known in changelog.md score-explanation.md final-report.md run-contract.md source-ledger.md trace-summary.md; do
  known_path=$(join_path "$artifact_dir" "$known")
  if [ -f "$known_path" ]; then
    append_detail "$known" "$known_path" "$(detail_title "$known")"
  fi
done

details_dir=$(join_path "$artifact_dir" details)
if [ -d "$details_dir" ]; then
  while IFS= read -r found; do
    base=${found##*/}
    extension=$(file_extension "$base" | tr '[:upper:]' '[:lower:]')
    case $extension in
      .md | .txt | .json | .tsv | .log) ;;
      *) continue ;;
    esac
    if [ "$artifact_dir" = "." ]; then
      relative=$found
    else
      relative=${found#"$artifact_dir"/}
    fi
    append_detail "$relative" "$found" "$(detail_title "$relative")"
  done < <(collect_files "$details_dir" | LC_ALL=C sort)
fi

details_json=$(printf '%s' "$DETAILS_ENTRIES" | jq -s -r "$SERIALIZE_JQ")
snapshot_output() {
  SNAPSHOT_EXISTS=0
  SNAPSHOT_MODE=""
  SNAPSHOT_COPY=""
  if [ ! -e "$1" ]; then
    return 0
  fi
  if [ ! -f "$1" ]; then
    printf '출력 경로가 일반 파일이 아닙니다: %s\n' "$1" >&2
    exit 1
  fi
  SNAPSHOT_EXISTS=1
  SNAPSHOT_MODE=$(file_mode "$1")
  SNAPSHOT_COPY=$(temporary_path "$1")
  if ! cp -p -- "$1" "$SNAPSHOT_COPY"; then
    printf '출력 경로를 백업하지 못했습니다: %s\n' "$1" >&2
    exit 1
  fi
}

write_temp_stream() {
  local path=$1 mode=$2
  if ! ( set -o noclobber; printf '' > "$path" ) 2>/dev/null; then
    printf '임시 파일을 만들지 못했습니다: %s\n' "$path" >&2
    return 1
  fi
  if [ -n "$mode" ] && ! chmod "$mode" "$path" 2>/dev/null; then
    rm -f -- "$path"
    return 1
  fi
  if ! dd of="$path" conv=fsync 2>/dev/null; then
    rm -f -- "$path"
    return 1
  fi
  return 0
}

restore_output() {
  if [ "$2" -eq 0 ]; then
    rm -f -- "$1"
    return 0
  fi
  mv -f -- "$3" "$1"
}

write_output_pair() {
  local dashboard_file=$1 dashboard_exists

  snapshot_output "$dashboard_path"
  dashboard_exists=$SNAPSHOT_EXISTS
  DASHBOARD_MODE=$SNAPSHOT_MODE
  DASHBOARD_SNAPSHOT=$SNAPSHOT_COPY

  snapshot_output "$results_js_path"
  RESULTS_MODE=$SNAPSHOT_MODE
  RESULTS_SNAPSHOT=$SNAPSHOT_COPY

  DASHBOARD_TEMP=$(temporary_path "$dashboard_path")
  RESULTS_JS_TEMP=$(temporary_path "$results_js_path")

  if ! cat -- "$dashboard_file" | write_temp_stream "$DASHBOARD_TEMP" "$DASHBOARD_MODE"; then
    fail "dashboard.html을 쓰지 못했습니다: $dashboard_path"
  fi
  if ! printf 'window.__AUTORESEARCH_RESULTS__ = %s;\nwindow.__AUTORESEARCH_DETAILS__ = %s;\n' "$results_json" "$details_json" | write_temp_stream "$RESULTS_JS_TEMP" "$RESULTS_MODE"; then
    fail "results.js를 쓰지 못했습니다: $results_js_path"
  fi

  if ! mv -f -- "$DASHBOARD_TEMP" "$dashboard_path"; then
    fail "dashboard.html을 교체하지 못했습니다: $dashboard_path"
  fi
  DASHBOARD_TEMP=""

  if ! mv -f -- "$RESULTS_JS_TEMP" "$results_js_path"; then
    if ! restore_output "$dashboard_path" "$dashboard_exists" "$DASHBOARD_SNAPSHOT"; then
      fail "results.js 커밋 실패 후 dashboard.html 복원에 실패했습니다"
    fi
    DASHBOARD_SNAPSHOT=""
    fail "results.js를 교체하지 못했습니다: $results_js_path"
  fi
  RESULTS_JS_TEMP=""

  rm -f -- "$DASHBOARD_SNAPSHOT" "$RESULTS_SNAPSHOT"
  DASHBOARD_SNAPSHOT=""
  RESULTS_SNAPSHOT=""
}

cleanup_temps() {
  local leftover
  for leftover in "${DASHBOARD_TEMP-}" "${RESULTS_JS_TEMP-}" "${DASHBOARD_SNAPSHOT-}" "${RESULTS_SNAPSHOT-}"; do
    if [ -n "$leftover" ]; then
      rm -f -- "$leftover"
    fi
  done
  return 0
}

DASHBOARD_TEMP=""
RESULTS_JS_TEMP=""
DASHBOARD_SNAPSHOT=""
RESULTS_SNAPSHOT=""
DASHBOARD_MODE=""
RESULTS_MODE=""

trap cleanup_temps EXIT

mkdir -p -- "$artifact_dir"
write_output_pair "$template_path"

printf '렌더 완료: %s\n' "$dashboard_path"
printf '렌더 완료: %s\n' "$results_js_path"
