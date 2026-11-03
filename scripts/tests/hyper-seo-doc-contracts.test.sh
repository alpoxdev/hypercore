#!/usr/bin/env bash
# hyper-seo doc contracts — bash port of scripts/tests/hyper-seo-doc-contracts.test.mjs.
#
# Assertions about the structure of the hyper-seo rule documents: bilingual
# checklist items, headings, tables, heuristic markers, source ledgers and
# conditional target markers. Negative controls copy one file into a temp root,
# so no repository file is ever written to.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "$(dirname "$0")/lib/hyper-seo-doc-contracts.sh"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}

NO_DATE="—"
UNCONFIRMED="unconfirmed"
BOUNDARY_SECTION_EN="Crawl, Render & Index Interpretation Boundaries"
BOUNDARY_SECTION_KO="크롤·렌더·색인 해석 경계"
BOUNDARY_IDS="source HTML,robots.txt,canonical,internal links,filtered URLs,sitemap"
PIPELINE_STAGE_IDS="crawl,render,index,appearance"
SPAM_POLICY_IDS="scaled content abuse,expired domain abuse,site reputation policy,doorway abuse,thin affiliation,scraped content,generative AI use"
AI_CONTROLS_SECTION_EN="Search Console AI Inclusion Controls (\`official\`)"
AI_CONTROLS_SECTION_KO="Search Console 생성 AI 포함 제어(\`official\`)"
AI_REPORT_SECTION_EN="Generative AI Performance Report (\`official\`)"
AI_REPORT_SECTION_KO="생성 AI 성과 보고서(\`official\`)"
BOT_EVIDENCE_SECTION_EN="Bot Purpose vs Observed Access (\`official\` + \`field\`)"
BOT_EVIDENCE_SECTION_KO="봇 목적과 관측 접근의 구분(\`official\` + \`field\`)"
VERIFIED_ON_2026_09_21_1="https://support.google.com/webmasters/answer/16908024"
VERIFIED_ON_2026_09_21_2="https://support.google.com/webmasters/answer/16984139"
NAVER_SECTION_EN="Platform Policy Checklist > Naver (Search Advisor)"
NAVER_SECTION_KO="플랫폼 정책 체크리스트 > Naver(서치어드바이저)"
NAVER_CONDITIONAL_IDS="Yeti,robots.txt,RSS,og:image,nosourceinfo,soft 404,Google-only directives"
BING_SECTION_EN="Platform Policy Checklist > Bing (IndexNow & Webmaster Tools)"
BING_SECTION_KO="플랫폼 정책 체크리스트 > Bing(IndexNow·웹마스터 도구)"
BING_CONDITIONAL_IDS="IndexNow,key file,urlList,429,crawl quota,backfill submissions,changefreq,Bing Webmaster Tools"
FINDINGS_HEADER='| # | Finding | Location | Evidence Grade | Confidence | Method | Source Tier | Recommendation |'

DOC_DATE_RE='^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$'

# ---- helpers -------------------------------------------------------------

# doc <relative-path> [root] — absolute path inside the repository or a copy.
doc() {
  printf '%s/%s\n' "${2:-$ROOT}" "$1"
}

# join_commas — stdin lines joined by commas, without a trailing comma.
join_commas() {
  tr '\n' ',' | sed 's/,$//'
}

# section_items <file> <suffix> — items of the first section ending with suffix.
section_items() {
  hs_section_items "$1" "$2"
}

# section_ids <file> <suffix>
section_ids() {
  hs_section_ids "$1" "$2"
}

# copy_doc <workdir> <relative-path> — copy one file, print the new path.
copy_doc() {
  local dir=$1 rel=$2
  mkdir -p "$dir/$(dirname "$rel")"
  cp "$ROOT/$rel" "$dir/$rel"
  printf '%s/%s\n' "$dir" "$rel"
}

# replace_in_line <file> <line-number> <from> <to> — literal replacement.
replace_in_line() {
  local file=$1
  local go=$2
  local from=$3
  local to=$4
  local tmp="$file.replace.$$"
  awk -v n="$go" -v from="$from" -v to="$to" '
    NR == n {
      p = index($0, from)
      if (p > 0) $0 = substr($0, 1, p - 1) to substr($0, p + length(from))
    }
    { print }
  ' "$file" >"$tmp" && mv "$tmp" "$file"
}

# delete_line <file> <line-number>
delete_line() {
  local file=$1
  local go=$2
  local tmp="$file.delete.$$"
  awk -v n="$go" 'NR != n' "$file" >"$tmp" && mv "$tmp" "$file"
}

# replace_first_backtick <file> <line-number> <identifier> — replace the first ``token``.
replace_first_backtick() {
  local file=$1
  local go=$2
  local ident=$3
  local tmp="$file.backtick.$$"
  awk -v n="$go" -v ident="$ident" '
    NR == n && !done {
      if (match($0, /`[^`]+`/)) {
        $0 = substr($0, 1, RSTART - 1) "`" ident "`" substr($0, RSTART + RLENGTH)
        done = 1
      }
    }
    { print }
  ' "$file" >"$tmp" && mv "$tmp" "$file"
}

# line_of_checkbox_with_id <file> <id> — first checklist line whose id matches.
line_of_checkbox_with_id() {
  awk -v want="$2" '
    {
      line = $0
      if (line ~ /^[ \t]*[-*][ \t]*\[[ xX]\][ \t]+/) {
        if (match(line, /`[^`]+`/)) {
          if (substr(line, RSTART + 1, RLENGTH - 2) == want) { print NR; exit }
        }
      }
    }
  ' "$1"
}

# line_with <file> <literal> — first line containing the literal.
line_with() {
  awk -v want="$2" 'index($0, want) > 0 { print NR; exit }' "$1"
}

# replace_everywhere <file> <from> <to> — literal replacement on every line.
replace_everywhere() {
  local file=$1
  local from=$2
  local to=$3
  local tmp="$file.replaceall.$$"
  awk -v from="$from" -v to="$to" '
    {
      out = ""
      rest = $0
      while ((p = index(rest, from)) > 0) {
        out = out substr(rest, 1, p - 1) to
        rest = substr(rest, p + length(from))
      }
      print out rest
    }
  ' "$file" >"$tmp" && mv "$tmp" "$file"
}

# table_with_header_cell <file> <cell> — table text (header + rows).
table_with_header_cell() {
  hs_table "$1" "$2"
}

# cell_of <table> <row> <column> — one named cell of a row.
cell_of() {
  hs_table_cell "$2" "$1" "$3"
}

# row_with_id <table> <column> <id>
row_with_id() {
  hs_table_row "$1" "$2" "$3"
}

# first_column_ids <table>
first_column_ids() {
  hs_table_first_ids "$1"
}

# ledger_problems <file> — date-contract problems in the source ledger.
ledger_problems() {
  local table header
  table=$(hs_table "$1" "Accessed")
  if [ -z "$table" ]; then
    printf 'ledger table not found\n'
    return 0
  fi
  header=$(hs_table_header "$table")
  hs_table_rows "$table" | awk -F '\t' -v hdr="$header" -v nodate="$NO_DATE" '
    function is_date(s) { return s ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ }
    BEGIN { n = split(hdr, h, "\t"); for (i = 1; i <= n; i++) col[h[i]] = i }
    {
      source = $(col["Source"]); accessed = $(col["Accessed"]); observed = $(col["Observed"])
      notice = $(col["Notice"]); effective = $(col["Effective"]); confirmed = $(col["Confirmed at"])
      if (!is_date(accessed)) printf "%s: accessed=%s\n", source, (accessed == "" ? "<empty>" : accessed)
      if (!is_date(observed)) printf "%s: observed=%s\n", source, (observed == "" ? "<empty>" : observed)
      if (confirmed != nodate && confirmed !~ /^https:\/\//) printf "%s: confirmed at=%s\n", source, (confirmed == "" ? "<empty>" : confirmed)
      notice_dated = is_date(notice)
      effective_dated = is_date(effective)
      if (notice_dated != effective_dated) printf "%s: notice=%s effective=%s\n", source, notice, effective
      if (notice_dated && notice == effective) printf "%s: notice equals effective (%s)\n", source, notice
      if (notice_dated && confirmed == nodate) printf "%s: dated policy row without a confirmation URL\n", source
    }
  '
}

# status_table_problems <file> — contract problems in the structured-data table.
status_table_problems() {
  local table header
  table=$(hs_table "$1" "Status")
  if [ -z "$table" ]; then
    printf 'status table not found\n'
    return 0
  fi
  header=$(hs_table_header "$table")
  hs_table_rows "$table" | awk -F '\t' -v hdr="$header" -v nodate="$NO_DATE" -v unconfirmed="$UNCONFIRMED" '
    function is_date(s) { return s ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ }
    function item_id(s,   t) {
      if (match(s, /`[^`]+`/)) return substr(s, RSTART + 1, RLENGTH - 2)
      return s
    }
    BEGIN { n = split(hdr, h, "\t"); for (i = 1; i <= n; i++) col[h[i]] = i }
    {
      type = item_id($(col["Type"])); status = $(col["Status"])
      notice = $(col["Notice"]); effective = $(col["Effective"])
      if (status != "supported" && status != "retired" && status != "unverified") printf "%s: status=%s\n", type, status
      notice_dated = is_date(notice)
      effective_dated = is_date(effective)
      if (notice_dated != effective_dated) printf "%s: notice=%s effective=%s\n", type, notice, effective
      if (notice_dated && notice == effective) printf "%s: notice equals effective (%s)\n", type, notice
      if (status == "retired" && !notice_dated && !(notice == unconfirmed && effective == unconfirmed)) {
        printf "%s: retired without dates or an unconfirmed marker\n", type
      }
      if (status == "unverified" && (notice != nodate || effective != nodate)) {
        printf "%s: unverified with dates notice=%s effective=%s\n", type, notice, effective
      }
    }
  '
}

# accessed_dates <file> — ledger access dates in row order.
accessed_dates() {
  hs_ledger_column "$1" "Accessed"
}

# ---- validation.md -------------------------------------------------------

case_validation_checklist_parity() {
  local mismatches
  mismatches=$(hs_compare_checklist_files "$(doc "$HS_VALIDATION_EN")" "$(doc "$HS_VALIDATION_KO")")
  assert_empty "$mismatches" "validation checklists"
}

case_complex_audit_artifacts() {
  local ids
  ids=$(section_ids "$(doc "$HS_VALIDATION_EN")" "Complex audit" | join_commas)
  assert_contains "$ids" "dashboard.html" "complex audit"
  assert_contains "$ids" "results.js" "complex audit"
  assert_contains "$ids" "flow.json" "complex audit"
}

case_simple_audit_artifacts() {
  local ids
  ids=$(section_ids "$(doc "$HS_VALIDATION_EN")" "Simple audit" | join_commas)
  assert_contains "$ids" "sources.md" "simple audit"
}

case_workflow_heading_parity() {
  local en_count ko_count
  en_count=$(hs_headings "$(doc "$HS_WORKFLOW_EN")" | wc -l | tr -d ' ')
  ko_count=$(hs_headings "$(doc "$HS_WORKFLOW_KO")" | wc -l | tr -d ' ')
  assert_eq "$en_count" "$ko_count" "workflow heading count"
  assert_empty "$(hs_compare_headings "$(doc "$HS_WORKFLOW_EN")" "$(doc "$HS_WORKFLOW_KO")")" "workflow headings"
}

case_dropped_checklist_item_detected() {
  local work target goal mismatches
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_VALIDATION_KO")
  goal=$(line_of_checkbox_with_id "$target" "dashboard.html")
  assert_nonempty "$goal" "dashboard.html item present"
  delete_line "$target" "$goal"
  mismatches=$(hs_compare_checklist_files "$(doc "$HS_VALIDATION_EN")" "$target")
  assert_contains "$mismatches" "item count" "dropped item detected"
}

# ---- seo-checklist.md ----------------------------------------------------

case_checklist_checkbox_parity() {
  local en_count ko_count
  en_count=$(hs_items "$(doc "$HS_CHECKLIST_EN")" | wc -l | tr -d ' ')
  ko_count=$(hs_items "$(doc "$HS_CHECKLIST_KO")" | wc -l | tr -d ' ')
  assert_eq "$en_count" "$ko_count" "checklist item count"
  assert_empty "$(hs_compare_checklist_files "$(doc "$HS_CHECKLIST_EN")" "$(doc "$HS_CHECKLIST_KO")")" "checklist items"
}

case_heuristic_thresholds() {
  local en_indices ko_indices marked ids checked
  en_indices=$(hs_heuristic_indices "$(doc "$HS_CHECKLIST_EN")" | join_commas)
  ko_indices=$(hs_heuristic_indices "$(doc "$HS_CHECKLIST_KO")" | join_commas)
  assert_empty "$(hs_compare_heuristic "$(doc "$HS_CHECKLIST_EN")" "$(doc "$HS_CHECKLIST_KO")")" "heuristic markers"
  assert_eq "59,61,64,73,78,81,83,84,94" "$en_indices" "en heuristic indices"
  assert_eq "$en_indices" "$ko_indices" "ko heuristic indices"

  marked=$(hs_items "$(doc "$HS_CHECKLIST_EN")" | awk -F "$HS_US" -v marker="$HS_HEURISTIC_MARKER" 'index($6, marker) > 0')
  assert_eq "9" "$(printf '%s\n' "$marked" | wc -l | tr -d ' ')" "marked item count"
  ids=$(printf '%s\n' "$marked" | awk -F "$HS_US" '{ print $4 }' | join_commas)
  assert_eq '<title>,<meta name="description">,<h1>,og:image,,,,,' "$ids" "marked item ids"
  checked=$(printf '%s\n' "$marked" | awk -F "$HS_US" '{ print $3 }' | sort -u | tr -d '\n')
  assert_eq "0" "$checked" "marked items stay unchecked"
}

case_boundary_section() {
  local en_ids ko_ids
  en_ids=$(section_ids "$(doc "$HS_CHECKLIST_EN")" "$BOUNDARY_SECTION_EN" | join_commas)
  ko_ids=$(section_ids "$(doc "$HS_CHECKLIST_KO")" "$BOUNDARY_SECTION_KO" | join_commas)
  assert_eq "$BOUNDARY_IDS" "$en_ids" "en boundary ids"
  assert_eq "$BOUNDARY_IDS" "$ko_ids" "ko boundary ids"
  assert_eq "6" "$(printf '%s\n' "$en_ids" | tr ',' '\n' | wc -l | tr -d ' ')" "boundary id count"
}

case_heuristic_marker_removed_detected() {
  local work target goal mismatches count
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_CHECKLIST_KO")
  goal=$(awk '
    /^[ \t]*[-*][ \t]*\[[ xX]\][ \t]+/ && index($0, "(heuristic)") > 0 { print NR; exit }
  ' "$target")
  assert_nonempty "$goal" "heuristic marker line present"
  replace_in_line "$target" "$goal" " (heuristic)" ""
  mismatches=$(hs_compare_heuristic "$(doc "$HS_CHECKLIST_EN")" "$target")
  assert_contains "$mismatches" "heuristic count" "removed marker detected"
  count=$(hs_heuristic_indices "$target" | wc -l | tr -d ' ')
  assert_eq "8" "$count" "remaining heuristic markers"
}

# ---- report templates ----------------------------------------------------

case_report_template_columns() {
  local mismatches
  mismatches=$(hs_compare_report_templates "$(doc "$HS_REPORT_TEMPLATE_EN")" "$(doc "$HS_REPORT_TEMPLATE_KO")")
  assert_empty "$mismatches" "report templates"
}

case_report_template_single_spelling() {
  assert_empty "$(hs_report_conflicts "$(doc "$HS_REPORT_TEMPLATE_EN")")" "en template conflicts"
  assert_empty "$(hs_report_conflicts "$(doc "$HS_REPORT_TEMPLATE_KO")")" "ko template conflicts"
}

case_report_template_header_drift_detected() {
  local work target original unknown_label other_column snake_case
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_REPORT_TEMPLATE_EN")
  original=$(cat "$target")
  assert_contains "$original" "$FINDINGS_HEADER" "findings header present"

  unknown_label=${original/$FINDINGS_HEADER/'| # | Finding | Location | Evidence | Confidence | Method | Source Tier | Recommendation |'}
  printf '%s\n' "$unknown_label" >"$target"
  assert_contains "$(hs_compare_report_templates "$target" "$(doc "$HS_REPORT_TEMPLATE_KO")")" \
    "unknown en header cells" "unknown header cell detected"

  other_column=${original/$FINDINGS_HEADER/'| # | Finding | Location | Evidence Grade | Confidence | Notes | Source Tier | Recommendation |'}
  printf '%s\n' "$other_column" >"$target"
  assert_contains "$(hs_compare_report_templates "$target" "$(doc "$HS_REPORT_TEMPLATE_KO")")" \
    "columns en=" "shifted column detected"

  snake_case=${original/$FINDINGS_HEADER/'| # | Finding | Location | evidence_grade | Confidence | measurement_method | source_tier | Recommendation |'}
  printf '%s\n' "$snake_case" >"$target"
  assert_eq 'evidence_grade: Evidence Grade | evidence_grade
measurement_method: Method | measurement_method
source_tier: Source Tier | source_tier' \
    "$(hs_report_conflicts "$target" | sort)" "conflicting spellings"
}

# ---- seo-fundamentals.md -------------------------------------------------

case_fundamentals_structure() {
  assert_empty "$(hs_compare_doc_structure "$(doc "$HS_FUNDAMENTALS_EN")" "$(doc "$HS_FUNDAMENTALS_KO")")" "fundamentals structure"
}

case_pipeline_stages() {
  local path table
  for path in "$HS_FUNDAMENTALS_EN" "$HS_FUNDAMENTALS_KO"; do
    table=$(table_with_header_cell "$(doc "$path")" "Stage")
    assert_nonempty "$table" "$path: stage table"
    assert_eq "$PIPELINE_STAGE_IDS" "$(first_column_ids "$table" | join_commas)" "$path: stage ids"
    assert_success hs_table_is_aligned "$table" "$(hs_table_header "$table" | awk -F '\t' '{ print NF }')"
  done
}

case_spam_policies() {
  local path table
  for path in "$HS_FUNDAMENTALS_EN" "$HS_FUNDAMENTALS_KO"; do
    table=$(table_with_header_cell "$(doc "$path")" "Policy")
    assert_nonempty "$table" "$path: policy table"
    assert_eq "$SPAM_POLICY_IDS" "$(first_column_ids "$table" | join_commas)" "$path: policy ids"
  done
}

case_structured_data_status() {
  local path table row
  for path in "$HS_FUNDAMENTALS_EN" "$HS_FUNDAMENTALS_KO"; do
    assert_empty "$(status_table_problems "$(doc "$path")")" "$path: status contract"
    table=$(table_with_header_cell "$(doc "$path")" "Status")
    assert_nonempty "$table" "$path: status table"

    row=$(row_with_id "$table" "Type" "FAQPage")
    assert_nonempty "$row" "$path: FAQPage row"
    assert_eq "retired" "$(cell_of "$table" "$row" "Status")" "$path: FAQPage status"
    assert_match "$DOC_DATE_RE" "$(cell_of "$table" "$row" "Notice")" "$path: FAQPage notice"
    assert_match "$DOC_DATE_RE" "$(cell_of "$table" "$row" "Effective")" "$path: FAQPage effective"
    assert_ne "$(cell_of "$table" "$row" "Notice")" "$(cell_of "$table" "$row" "Effective")" "$path: FAQPage dates differ"

    row=$(row_with_id "$table" "Type" "HowTo")
    assert_nonempty "$row" "$path: HowTo row"
    assert_eq "retired" "$(cell_of "$table" "$row" "Status")" "$path: HowTo status"
    assert_eq "$UNCONFIRMED" "$(cell_of "$table" "$row" "Notice")" "$path: HowTo notice"

    local type
    for type in Product "merchant listing" ProductGroup; do
      row=$(row_with_id "$table" "Type" "$type")
      assert_nonempty "$row" "$path: $type row"
      assert_eq "supported" "$(cell_of "$table" "$row" "Status")" "$path: $type status"
    done

    row=$(row_with_id "$table" "Type" "ClaimReview")
    assert_nonempty "$row" "$path: ClaimReview row"
    assert_eq "unverified" "$(cell_of "$table" "$row" "Status")" "$path: ClaimReview status"
  done
}

case_ledger_dates() {
  local path markdown table dated total
  for path in "$HS_FUNDAMENTALS_EN" "$HS_FUNDAMENTALS_KO"; do
    markdown=$(doc "$path")
    assert_empty "$(ledger_problems "$markdown")" "$path: ledger contract"
    table=$(table_with_header_cell "$markdown" "Accessed")
    total=$(hs_table_rows "$table" | wc -l | tr -d ' ')
    assert_nonempty "$total" "$path: ledger rows"
    [ "$total" -gt 0 ] || fail "$path: ledger has no rows"
    dated=$(hs_table_column "$table" "Notice" | grep -cE "$DOC_DATE_RE" || true)
    [ "$dated" -gt 0 ] || fail "$path: no dated policy row"
    assert_eq "$dated" "$(hs_table_rows "$table" | awk -F '\t' -v hdr="$(hs_table_header "$table")" -v re="$DOC_DATE_RE" '
      BEGIN { n = split(hdr, h, "\t"); for (i = 1; i <= n; i++) if (h[i] == "Notice") c = i; else if (h[i] == "Effective") e = i }
      $c ~ re { total++; if ($c != $e) differ++ } END { print total }')" "$path: dated rows differ"
  done
}

case_ledger_missing_accessed_detected() {
  local work target goal problems
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_FUNDAMENTALS_EN")
  goal=$(awk '/\| 2026-09-21 \| 2026-09-21 \|/ { print NR; exit }' "$target")
  assert_nonempty "$goal" "dated ledger row present"
  replace_in_line "$target" "$goal" "| 2026-09-21 |" "|  |"
  problems=$(ledger_problems "$target")
  assert_nonempty "$problems" "ledger problem reported"
  assert_contains "$problems" "accessed=<empty>" "access date dropped"
}

# ---- aeo-geo-guide.md ----------------------------------------------------

case_aeo_heading_parity() {
  assert_empty "$(hs_compare_headings "$(doc "$HS_AEO_GEO_EN")" "$(doc "$HS_AEO_GEO_KO")")" "aeo/geo headings"
}

case_aeo_ai_sections() {
  local en ko pair en_title ko_title en_pos ko_pos
  en=$(doc "$HS_AEO_GEO_EN")
  ko=$(doc "$HS_AEO_GEO_KO")
  for pair in "$AI_CONTROLS_SECTION_EN|$AI_CONTROLS_SECTION_KO" \
    "$AI_REPORT_SECTION_EN|$AI_REPORT_SECTION_KO" \
    "$BOT_EVIDENCE_SECTION_EN|$BOT_EVIDENCE_SECTION_KO"; do
    en_title=${pair%%|*}
    ko_title=${pair#*|}
    en_pos=$(hs_heading_position "$en" "$en_title")
    ko_pos=$(hs_heading_position "$ko" "$ko_title")
    assert_nonempty "$en_pos" "en section: $en_title"
    assert_eq "$en_pos" "$ko_pos" "section position: $en_title"
  done
}

case_aeo_ledger_alignment() {
  local en ko en_header ko_header
  en=$(doc "$HS_AEO_GEO_EN")
  ko=$(doc "$HS_AEO_GEO_KO")
  en_header=$(hs_source_ledger "$en" | awk 'NR == 1')
  ko_header=$(hs_source_ledger "$ko" | awk 'NR == 1')
  assert_nonempty "$en_header" "en ledger"
  assert_nonempty "$ko_header" "ko ledger"
  assert_eq "$en_header" "$ko_header" "ledger header"
  assert_eq "$(hs_ledger_column "$en" "Source")" "$(hs_ledger_column "$ko" "Source")" "ledger sources"
  assert_eq "$(hs_ledger_column "$en" "Accessed")" "$(hs_ledger_column "$ko" "Accessed")" "ledger access dates"
}

case_aeo_verification_rows() {
  local en dates access sources
  en=$(doc "$HS_AEO_GEO_EN")
  dates=$(accessed_dates "$en")
  assert_contains "$dates" "2026-09-21" "verification access date"
  assert_empty "$(printf '%s\n' "$dates" | grep -vE "$DOC_DATE_RE" || true)" "access dates stay ISO"

  access=$(hs_ledger_column "$en" "Accessed")
  sources=$(hs_source_ledger "$en" | awk -F '\t' 'NR > 1 && $2 == "2026-09-21" { print $1 }')
  assert_contains "$sources" "$VERIFIED_ON_2026_09_21_1" "first verified source"
  assert_contains "$sources" "$VERIFIED_ON_2026_09_21_2" "second verified source"
  assert_nonempty "$access" "ledger access column"
}

case_aeo_last_verified() {
  local en ko newest
  en=$(doc "$HS_AEO_GEO_EN")
  ko=$(doc "$HS_AEO_GEO_KO")
  newest=$(accessed_dates "$en" | LC_ALL=C sort | tail -n 1)
  assert_eq "$newest" "$(hs_last_verified "$en")" "en last verified"
  assert_eq "$newest" "$(hs_last_verified "$ko")" "ko last verified"
}

case_aeo_ledger_date_dropped_detected() {
  local work target goal en_ko_dates total iso
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_AEO_GEO_KO")
  goal=$(line_with "$target" "$VERIFIED_ON_2026_09_21_2")
  assert_nonempty "$goal" "verification row present"
  replace_in_line "$target" "$goal" "| 2026-09-21 |" "| |"
  en_ko_dates=$(accessed_dates "$target")
  assert_ne "$(accessed_dates "$(doc "$HS_AEO_GEO_EN")")" "$en_ko_dates" "ledger dates diverge"
  total=$(printf '%s\n' "$en_ko_dates" | wc -l | tr -d ' ')
  iso=$(printf '%s\n' "$en_ko_dates" | grep -cE "$DOC_DATE_RE" || true)
  [ "$iso" -lt "$total" ] || fail "every access date still parses as ISO"
}

case_aeo_section_dropped_detected() {
  local work target goal mismatches
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_AEO_GEO_KO")
  goal=$(awk -v title="## $AI_REPORT_SECTION_KO" '$0 == title { print NR; exit }' "$target")
  assert_nonempty "$goal" "report section present"
  delete_line "$target" "$goal"
  mismatches=$(hs_compare_headings "$(doc "$HS_AEO_GEO_EN")" "$target")
  assert_contains "$mismatches" "heading count" "dropped section detected"
  assert_empty "$(hs_heading_position "$target" "$AI_REPORT_SECTION_KO")" "section no longer found"
}

# ---- conditional platform items -----------------------------------------

case_naver_conditional_items() {
  local en ko naver_en naver_ko
  en=$(doc "$HS_CHECKLIST_EN")
  ko=$(doc "$HS_CHECKLIST_KO")
  assert_empty "$(hs_compare_conditional "$en" "$ko")" "conditional items"
  naver_en=$(hs_conditional_items_for_target "$en" "naver" | join_commas)
  naver_ko=$(hs_conditional_items_for_target "$ko" "naver" | join_commas)
  assert_eq "$NAVER_CONDITIONAL_IDS" "$naver_en" "en naver ids"
  assert_eq "$NAVER_CONDITIONAL_IDS" "$naver_ko" "ko naver ids"
  assert_eq "$NAVER_CONDITIONAL_IDS" "$(section_ids "$en" "$NAVER_SECTION_EN" | join_commas)" "en naver section ids"
  assert_eq "$NAVER_CONDITIONAL_IDS" "$(section_ids "$ko" "$NAVER_SECTION_KO" | join_commas)" "ko naver section ids"

  local offending
  offending=$(hs_conditional_items "$en" | awk -F "$HS_US" -v want="$NAVER_SECTION_EN" '
    $4 == "naver" {
      n = length(want)
      if (substr($5, length($5) - n + 1) != want) print "outside:" $3
    }
  ')
  assert_empty "$offending" "naver items live in the Naver block"
  offending=$(hs_conditional_items "$ko" | awk -F "$HS_US" -v want="$NAVER_SECTION_KO" '
    $4 == "naver" {
      n = length(want)
      if (substr($5, length($5) - n + 1) != want) print "outside:" $3
    }
  ')
  assert_empty "$offending" "ko naver items live in the Naver block"
}

case_ranking_claim_absent() {
  local en ko work target goal
  en=$(doc "$HS_CHECKLIST_EN")
  ko=$(doc "$HS_CHECKLIST_KO")
  assert_empty "$(hs_ranking_ids "$en")" "en ranking claims"
  assert_empty "$(hs_ranking_ids "$ko")" "ko ranking claims"

  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_CHECKLIST_EN")
  goal=$(line_with "$target" "(target: naver)")
  assert_nonempty "$goal" "naver item line present"
  replace_first_backtick "$target" "$goal" "C-Rank score"
  assert_eq "C-Rank score" "$(hs_ranking_ids "$target" | join_commas)" "injected claim detected"
}

case_target_marker_change_detected() {
  local en ko work target goal retargeted dropped total
  en=$(doc "$HS_CHECKLIST_EN")
  ko=$(doc "$HS_CHECKLIST_KO")
  assert_empty "$(hs_compare_conditional "$en" "$ko")" "repository pair"

  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_CHECKLIST_KO")
  goal=$(line_with "$target" "(target: naver)")
  assert_nonempty "$goal" "naver marker present"

  replace_in_line "$target" "$goal" "(target: naver)" "(target: bing)"
  retargeted=$(hs_compare_conditional "$en" "$target")
  assert_nonempty "$retargeted" "retargeted marker detected"
  assert_eq "naver" "$(hs_conditional_items "$en" | awk -F "$HS_US" 'NR == 1 { print $4 }')" "en first target"
  assert_eq "bing" "$(hs_conditional_items "$target" | awk -F "$HS_US" 'NR == 1 { print $4 }')" "ko first target"
  assert_contains "$retargeted" "conditional item 0 (Yeti): target en=naver ko=bing" "target mismatch line"

  replace_in_line "$target" "$goal" " (target: bing)" ""
  dropped=$(hs_compare_conditional "$en" "$target")
  total=$(hs_conditional_items "$en" | wc -l | tr -d ' ')
  assert_nonempty "$dropped" "removed marker detected"
  assert_eq "Yeti" "$(hs_conditional_items "$en" | awk -F "$HS_US" 'NR == 1 { print $3 }')" "en first id"
  assert_eq "robots.txt" "$(hs_conditional_items "$target" | awk -F "$HS_US" 'NR == 1 { print $3 }')" "ko first id"
  assert_contains "$dropped" "conditional item count: en=$total ko=$((total - 1))" "conditional count line"
  assert_eq "$total" "$(($(hs_conditional_items "$target" | wc -l | tr -d ' ') + 1))" "one conditional item dropped"
  assert_contains "$dropped" "conditional item 0: id en=Yeti ko=robots.txt" "id mismatch line"

  assert_empty "$(hs_compare_conditional "$en" "$ko")" "repository pair unchanged"
}

case_bing_conditional_items() {
  local en ko bing_en bing_ko
  en=$(doc "$HS_CHECKLIST_EN")
  ko=$(doc "$HS_CHECKLIST_KO")
  assert_empty "$(hs_compare_conditional "$en" "$ko")" "conditional items"
  bing_en=$(hs_conditional_items_for_target "$en" "bing" | join_commas)
  bing_ko=$(hs_conditional_items_for_target "$ko" "bing" | join_commas)
  assert_eq "$BING_CONDITIONAL_IDS" "$bing_en" "en bing ids"
  assert_eq "$BING_CONDITIONAL_IDS" "$bing_ko" "ko bing ids"
  assert_eq "$BING_CONDITIONAL_IDS" "$(section_ids "$en" "$BING_SECTION_EN" | join_commas)" "en bing section ids"
  assert_eq "$BING_CONDITIONAL_IDS" "$(section_ids "$ko" "$BING_SECTION_KO" | join_commas)" "ko bing section ids"
  assert_empty "$(hs_ranking_ids "$en")" "en ranking claims"
  assert_empty "$(hs_ranking_ids "$ko")" "ko ranking claims"
}

case_bing_target_marker_removed_detected() {
  local en ko work target goal total bing_start dropped
  en=$(doc "$HS_CHECKLIST_EN")
  ko=$(doc "$HS_CHECKLIST_KO")
  assert_empty "$(hs_compare_conditional "$en" "$ko")" "repository pair"
  total=$(hs_conditional_items "$en" | wc -l | tr -d ' ')
  bing_start=$((total - 8))

  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_CHECKLIST_KO")
  goal=$(line_with "$target" "(target: bing)")
  assert_nonempty "$goal" "bing marker present"
  replace_in_line "$target" "$goal" " (target: bing)" ""

  dropped=$(hs_compare_conditional "$en" "$target")
  assert_nonempty "$dropped" "removed bing marker detected"
  assert_contains "$dropped" "conditional item count: en=$total ko=$((total - 1))" "conditional count line"
  assert_contains "$dropped" "conditional item $bing_start: id en=IndexNow ko=key file" "bing id shift line"
  assert_eq "7" "$(hs_conditional_items_for_target "$target" "bing" | wc -l | tr -d ' ')" "remaining bing items"
  assert_empty "$(hs_compare_conditional "$en" "$ko")" "repository pair unchanged"
}

run_case "validation checklists keep the same item structure in English and Korean" case_validation_checklist_parity
run_case "complex audit checklist covers the mode artifacts" case_complex_audit_artifacts
run_case "simple audit checklist covers its minimum artifacts" case_simple_audit_artifacts
run_case "workflow phases keep the same heading structure in English and Korean" case_workflow_heading_parity
run_case "parser detects a checklist item dropped from one language variant" case_dropped_checklist_item_detected
run_case "seo checklist keeps the same checkbox structure in English and Korean" case_checklist_checkbox_parity
run_case "seo checklist marks the nine fixed thresholds as heuristic in both languages" case_heuristic_thresholds
run_case "seo checklist records the six crawl, render, and index interpretation boundaries" case_boundary_section
run_case "parser detects a heuristic marker removed from one language variant" case_heuristic_marker_removed_detected
run_case "report templates keep the same table columns in English and Korean" case_report_template_columns
run_case "report templates spell each column one way" case_report_template_single_spelling
run_case "parser detects report template header drift in one language variant" case_report_template_header_drift_detected
run_case "seo fundamentals keeps the same section and table structure in English and Korean" case_fundamentals_structure
run_case "seo fundamentals names the four pipeline stages in both languages" case_pipeline_stages
run_case "seo fundamentals names the spam and abuse policies in both languages" case_spam_policies
run_case "seo fundamentals records structured-data support status and leaves ClaimReview unverified" case_structured_data_status
run_case "seo fundamentals dates every source row and separates policy notice from effective dates" case_ledger_dates
run_case "parser detects a source ledger row that lost its accessed date" case_ledger_missing_accessed_detected
run_case "aeo/geo guide keeps the same heading structure in English and Korean" case_aeo_heading_parity
run_case "aeo/geo guide carries the AI inclusion, reporting, and bot-evidence sections in both languages" case_aeo_ai_sections
run_case "aeo/geo guide source ledger stays aligned in English and Korean" case_aeo_ledger_alignment
run_case "aeo/geo guide source ledger records the 2026-09-21 verification rows" case_aeo_verification_rows
run_case "aeo/geo guide last-verified date matches its newest ledger access date" case_aeo_last_verified
run_case "parser detects an aeo/geo source ledger row that lost its access date" case_aeo_ledger_date_dropped_detected
run_case "parser detects an aeo/geo section missing from one language variant" case_aeo_section_dropped_detected
run_case "seo checklist declares the same conditional Naver items in English and Korean" case_naver_conditional_items
run_case "seo checklist conditional ids carry no third-party ranking-algorithm claim" case_ranking_claim_absent
run_case "parser detects a conditional target marker changed or removed in one language variant" case_target_marker_change_detected
run_case "seo checklist declares the same conditional Bing and IndexNow items in English and Korean" case_bing_conditional_items
run_case "parser detects a Bing target marker removed from one language variant" case_bing_target_marker_removed_detected
test_summary
