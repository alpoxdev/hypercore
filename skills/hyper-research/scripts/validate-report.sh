#!/usr/bin/env bash
# Validate a saved research report for citation and number lineage defects.
#
# Reads the report and its sources ledger and prints the defects it finds:
# unsourced_number, section_without_citation, unresolved_citation, and
# missing_required_section. Exit 0 means no defect, 1 means at least one
# defect, and 2 means a usage error.
set -euo pipefail

VD_USAGE='Usage: bash validate-report.sh --report <report.md> --ledger <ledger.md> [--json]
       bash validate-report.sh --self-test
       bash validate-report.sh --help'

VD_REQUIRED='Executive Summary
Key Findings
Source Ledger
Query Log
Validation Notes
References'

VD_DEFECT_CAP=50

vd_awk_prog() {
  cat <<'VD_AWK'
function trim(s) {
  sub(/^[ \t\r\n]+/, "", s)
  sub(/[ \t\r\n]+$/, "", s)
  return s
}
function strip_tabs(s) {
  gsub(/\t/, " ", s)
  return s
}
function emit(code, line, text) {
  if (nout >= cap) return
  text = strip_tabs(text)
  if (length(text) > 200) text = substr(text, 1, 197) "..."
  nout++
  out[nout] = sprintf("%d\t%s\t%s", line, code, text)
}
# prose_len counts characters other than whitespace in a line.
function prose_len(s) {
  s = strip_tabs(s)
  gsub(/[ \t]+/, "", s)
  return length(s)
}
function line_is_prose(s) {
  if (s ~ /^[ \t]*$/) return 0
  if (s ~ /^[ \t]*```/) return 0
  if (s ~ /^#+[ \t]/) return 0
  if (s ~ /^[ \t]*\|/) return 0
  # The template header is a blockquote of run metadata (counts, as-of date).
  if (s ~ /^[ \t]*>/) return 0
  if (s ~ /^[ \t]*<!--/) return 0
  return 1
}
# number_tokens appends each distinct unsourced number in s to the global list.
function number_tokens(s,   tok, seen, re, cnt) {
  gsub(/\[S[0-9]+\]/, " ", s)
  gsub(/`[^`]*`/, " ", s)
  gsub(/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/, " ", s)
  gsub(/[0-9][0-9]?:[0-9][0-9](:[0-9][0-9])?/, " ", s)
  gsub(/([Ff]igure|[Ff]ig\.|[Tt]able)[ \t]*[0-9]+/, " ", s)
  gsub(/[vV][0-9]+(\.[0-9]+)+/, " ", s)
  gsub(/[0-9]+(\.[0-9]+)+/, " ", s)
  split("", seen)
  cnt = 0
  re = "[0-9]+([.,][0-9]+)*"
  while (match(s, re) > 0) {
    tok = substr(s, RSTART, RLENGTH)
    s = substr(s, RSTART + RLENGTH)
    if (tok ~ /^(19|20)[0-9][0-9]$/) continue
    if (tok in seen) continue
    seen[tok] = 1
    cnt++
    found[cnt] = tok
  }
  return cnt
}
BEGIN {
  cap = ENVIRON["VD_CAP"] + 0
  if (cap <= 0) cap = 50
  nout = 0

  n = 0
  while ((getline line < ENVIRON["VD_REPORT"]) > 0) {
    n++
    L[n] = line
  }
  close(ENVIRON["VD_REPORT"])

  while ((getline line < ENVIRON["VD_LEDGER"]) > 0) {
    if (split(line, cells, "|") >= 2) {
      cell = trim(cells[2])
      sub(/^\[/, "", cell)
      sub(/\]$/, "", cell)
      if (cell ~ /^S[0-9]+$/) known[cell] = 1
    }
  }
  close(ENVIRON["VD_LEDGER"])

  # Required sections.
  nreq = split(ENVIRON["VD_REQUIRED"], req, "\n")
  for (i = 1; i <= nreq; i++) {
    if (req[i] == "") continue
    found_heading = 0
    for (j = 1; j <= n; j++) {
      h = trim(L[j])
      if (h == "## " req[i]) found_heading = 1
    }
    if (!found_heading) emit("missing_required_section", 0, "## " req[i])
  }

  # Section citation coverage.
  infence = 0
  for (j = 1; j <= n; j++) {
    if (L[j] ~ /^[ \t]*```/) { infence = !infence; continue }
    if (infence) continue
    if (L[j] !~ /^## /) continue
    heading = trim(L[j])
    chars = 0
    cited = 0
    for (k = j + 1; k <= n; k++) {
      if (L[k] ~ /^#{1,2}[ \t]/) break
      if (L[k] ~ /^[ \t]*$/) continue
      if (L[k] ~ /^[ \t]*\|/) continue
      if (L[k] ~ /^[ \t]*```/) continue
      chars += prose_len(L[k])
      if (L[k] ~ /\[S[0-9]+\]/) cited = 1
    }
    if (heading ~ /\[S[0-9]+\]/) cited = 1
    if (chars > 120 && !cited) emit("section_without_citation", j, heading)
  }

  # Paragraph number lineage.
  infence = 0
  j = 1
  while (j <= n) {
    if (L[j] ~ /^[ \t]*```/) {
      infence = !infence
      j++
      continue
    }
    if (infence || !line_is_prose(L[j])) {
      j++
      continue
    }
    start = j
    para = L[j]
    j++
    while (j <= n && line_is_prose(L[j])) {
      para = para " " trim(L[j])
      j++
    }
    if (para ~ /\[S[0-9]+\]/) continue
    if (para ~ /MEASURED|ASSUMED|DERIVED/) continue
    cnt = number_tokens(para)
    for (k = 1; k <= cnt; k++) emit("unsourced_number", start, para)
  }

  # Unresolved citations.
  infence = 0
  for (j = 1; j <= n; j++) {
    if (L[j] ~ /^[ \t]*```/) { infence = !infence; continue }
    if (infence) continue
    rest = L[j]
    while (match(rest, /\[S[0-9]+\]/) > 0) {
      marker = substr(rest, RSTART + 1, RLENGTH - 2)
      rest = substr(rest, RSTART + RLENGTH)
      if (marker in known) continue
      key = j SUBSEP marker
      if (key in reported) continue
      reported[key] = 1
      emit("unresolved_citation", j, marker)
    }
  }

  for (i = 1; i <= nout; i++) print out[i]
}
VD_AWK
}

# vd_validate <report> <ledger> prints TSV defects: line, code, text.
vd_validate() {
  local report=$1 ledger=$2
  VD_REPORT=$report VD_LEDGER=$ledger VD_REQUIRED=$VD_REQUIRED VD_CAP=$VD_DEFECT_CAP \
    LC_ALL=C awk "$(vd_awk_prog)"
}

vd_self_ledger() {
  cat <<'VD_LEDGER'
# Sources

| # | Source | URL/path | Publisher | Published/updated | Accessed | Version/freshness | Channel | Grade | Role | Relevant claim | Used? | Caveat |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S1 | Example report | https://example.com/report | Example | 2026-01-02 | 2026-11-09 | 1.0 | web | S | primary-evidence | C1 | yes | |
| S2 | Example registry | https://example.org/registry | Example | 2026-02-03 | 2026-11-09 | 2.1 | web | A | supporting | C1 | yes | |
VD_LEDGER
}

vd_self_report() {
  cat <<'VD_REPORT'
# Example Research Report

> As of: 2026-11-09 | Depth: default | Run state: converged
> Sources reviewed: 2 | Sources cited: 2 | Domains: 2

## Executive Summary

Adoption grew in the surveyed period [S1].

## Scope And Fidelity

- Core question: did adoption grow
- Axes: one

## Key Findings

### 1. Adoption

- Claim: adoption grew by 20 percent [S1]
- Numbers: 20 percent MEASURED [S1]

## Comparison

| Criteria | Option A | Option B | Sources |
|---|---|---|---|
| Price | 1,200 | 2,400 | [S2] |

## Source Ledger

| # | Source | URL/path |
|---|---|---|
| S1 | Example report | https://example.com/report |
| S2 | Example registry | https://example.org/registry |

## Query Log

- adoption query, web search, axis one

## Validation Notes

- Gates: structure, citation, lineage, recency, read-back pass

## References

- [S1] [Example report](https://example.com/report), accessed 2026-11-09
- [S2] [Example registry](https://example.org/registry), accessed 2026-11-09
VD_REPORT
}

# vd_codes <report> <ledger> prints the sorted defect codes.
vd_codes() {
  vd_validate "$1" "$2" | cut -f2 | LC_ALL=C sort
}

vd_self_test() {
  local work base defects codes ok=true cases='[]' one
  work=$(mktemp -d "${TMPDIR:-/tmp}/research-report.XXXXXX")
  vd_self_ledger >"$work/ledger.md"
  vd_self_report >"$work/base.md"
  base=$work/base.md

  defects=$(vd_validate "$base" "$work/ledger.md" | wc -l | tr -d ' ')
  cases=$(jq -cn --argjson c "$cases" --argjson a "$([ "$defects" -eq 0 ] && echo true || echo false)" \
    '$c + [{id: "valid-report-clean", expected: true, actual: $a}]')
  [ "$defects" -eq 0 ] || ok=false

  awk '/^## Executive Summary$/ { print; print ""; print "Adoption grew 37% in 2025."; next } { print }' \
    "$base" >"$work/unsourced.md"
  defects=$(vd_validate "$work/unsourced.md" "$work/ledger.md" | wc -l | tr -d ' ')
  codes=$(vd_codes "$work/unsourced.md" "$work/ledger.md" | tr '\n' ' ')
  cases=$(jq -cn --argjson c "$cases" --argjson a "$([ "$defects" -eq 1 ] && [ "$codes" = "unsourced_number " ] && echo true || echo false)" \
    '$c + [{id: "unsourced-number-detected", expected: true, actual: $a}]')
  [ "$defects" -eq 1 ] && [ "$codes" = "unsourced_number " ] || ok=false

  awk '/^## Executive Summary$/ { print; print ""; print "Released in 2025."; next } { print }' \
    "$base" >"$work/year-only.md"
  defects=$(vd_validate "$work/year-only.md" "$work/ledger.md" | wc -l | tr -d ' ')
  cases=$(jq -cn --argjson c "$cases" --argjson a "$([ "$defects" -eq 0 ] && echo true || echo false)" \
    '$c + [{id: "year-only-sentence-clean", expected: true, actual: $a}]')
  [ "$defects" -eq 0 ] || ok=false

  awk '{ print } /^\| Price \|/ { print "| Volume | 37 | 42 | [S2] |" }' \
    "$base" >"$work/table.md"
  defects=$(vd_validate "$work/table.md" "$work/ledger.md" | wc -l | tr -d ' ')
  cases=$(jq -cn --argjson c "$cases" --argjson a "$([ "$defects" -eq 0 ] && echo true || echo false)" \
    '$c + [{id: "table-row-numbers-ignored", expected: true, actual: $a}]')
  [ "$defects" -eq 0 ] || ok=false

  awk '/^## Executive Summary$/ { print; print ""; print "Market share is 12% [S9]."; next } { print }' \
    "$base" >"$work/unresolved.md"
  defects=$(vd_validate "$work/unresolved.md" "$work/ledger.md" | wc -l | tr -d ' ')
  codes=$(vd_codes "$work/unresolved.md" "$work/ledger.md" | tr '\n' ' ')
  cases=$(jq -cn --argjson c "$cases" --argjson a "$([ "$defects" -eq 1 ] && [ "$codes" = "unresolved_citation " ] && echo true || echo false)" \
    '$c + [{id: "unresolved-citation-detected", expected: true, actual: $a}]')
  [ "$defects" -eq 1 ] && [ "$codes" = "unresolved_citation " ] || ok=false

  awk '!/^## References$/ && !/^- \[S1\]/ && !/^- \[S2\]/' "$base" >"$work/missing.md"
  defects=$(vd_validate "$work/missing.md" "$work/ledger.md" | wc -l | tr -d ' ')
  codes=$(vd_codes "$work/missing.md" "$work/ledger.md" | tr '\n' ' ')
  cases=$(jq -cn --argjson c "$cases" --argjson a "$([ "$defects" -eq 1 ] && [ "$codes" = "missing_required_section " ] && echo true || echo false)" \
    '$c + [{id: "missing-required-section-detected", expected: true, actual: $a}]')
  [ "$defects" -eq 1 ] && [ "$codes" = "missing_required_section " ] || ok=false

  rm -rf "$work"
  jq -n --argjson ok "$([ "$ok" = true ] && echo true || echo false)" --argjson cases "$cases" \
    '{ok: $ok, cases: $cases}'
  [ "$ok" = true ]
}

vd_main() {
  local help=0 self_test=0 report='' ledger='' json=0 errs ok defects
  if [ $# -eq 0 ]; then
    printf '%s\n' "$VD_USAGE" >&2
    exit 2
  fi
  while [ $# -gt 0 ]; do
    case "$1" in
      --report)
        shift
        report=${1-}
        case "$report" in '' | --*) printf '%s\n' '{"ok":false,"error":"--report requires a path"}' >&2; exit 2 ;; esac
        if [ $# -gt 0 ]; then shift; fi
        ;;
      --ledger)
        shift
        ledger=${1-}
        case "$ledger" in '' | --*) printf '%s\n' '{"ok":false,"error":"--ledger requires a path"}' >&2; exit 2 ;; esac
        if [ $# -gt 0 ]; then shift; fi
        ;;
      --json) json=1; shift ;;
      --self-test) self_test=1; shift ;;
      --help | -h) help=1; shift; break ;;
      *) printf '%s\n' "$(jq -cn --arg error "Unknown argument: $1" '{ok: false, error: $error}')" >&2; exit 2 ;;
    esac
  done
  if [ "$help" = 1 ]; then
    printf '%s\n' "$VD_USAGE"
    return 0
  fi
  if [ "$self_test" = 1 ]; then
    vd_self_test
    return $?
  fi
  [ -n "$report" ] || { printf '%s\n' '{"ok":false,"error":"--report is required"}' >&2; exit 2; }
  [ -n "$ledger" ] || { printf '%s\n' '{"ok":false,"error":"--ledger is required"}' >&2; exit 2; }
  if [ ! -f "$report" ] || [ ! -r "$report" ]; then
    printf '%s\n' "$(jq -cn --arg error "ENOENT: no such file or directory, open '$report'" '{ok: false, error: $error}')" >&2
    exit 2
  fi
  if [ ! -f "$ledger" ] || [ ! -r "$ledger" ]; then
    printf '%s\n' "$(jq -cn --arg error "ENOENT: no such file or directory, open '$ledger'" '{ok: false, error: $error}')" >&2
    exit 2
  fi

  errs=$(vd_validate "$report" "$ledger")
  if [ -z "$errs" ]; then
    ok=true
    defects='[]'
  else
    ok=false
    defects=$(printf '%s\n' "$errs" | LC_ALL=C sort -t "$(printf '\t')" -k1,1n -k2,2 |
      jq -Rn '[inputs | split("\t") | {code: .[1], line: (.[0] | tonumber), text: .[2]}]')
  fi
  if [ "$json" = 1 ]; then
    jq -n --argjson ok "$ok" --argjson defects "$defects" '{ok: $ok, defects: $defects}'
  elif [ "$ok" = true ]; then
    printf 'Report is valid.\n'
  else
    printf '%s\n' "$defects" | jq -r '.[] | "\(.code) (line \(.line)): \(.text)"' >&2
  fi
  [ "$ok" = true ]
}

vd_main "$@"
