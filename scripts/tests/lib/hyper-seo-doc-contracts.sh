#!/usr/bin/env bash
# hyper-seo-doc-contracts.sh — bash port of scripts/tests/hyper-seo-doc-contracts.mjs.
#
# Shared document-contract parser for the hyper-seo rule docs. It reads
# structure, not prose: headings, checkbox items and table cells. Checklist
# items are matched across languages by position and by their first backticked
# identifier, never by sentence text.
#
# The parser is one awk pass per document. Records are emitted with the ASCII
# unit separator (0x1f) so empty fields survive `read`:
#
#   H <index> <level> <title> <path>
#   I <index> <checked 0|1> <id> <section> <text>
#   T <table> <row -1 = header> <section> <cell...>
#
# Every helper takes explicit file paths, so a negative control can point the
# parser at a temp copy instead of mutating repository files. Requires bash 3.2+
# and POSIX tools; no associative arrays, no mapfile.

# ---- paths ---------------------------------------------------------------
# Exported so the test files that source this library can use them directly.

export HS_VALIDATION_EN="skills/hyper-seo/rules/validation.md"
export HS_VALIDATION_KO="skills/hyper-seo/rules/validation.ko.md"
export HS_WORKFLOW_EN="skills/hyper-seo/rules/seo-workflow.md"
export HS_WORKFLOW_KO="skills/hyper-seo/rules/seo-workflow.ko.md"
export HS_REPORT_TEMPLATE_EN="skills/hyper-seo/assets/report.template.md"
export HS_REPORT_TEMPLATE_KO="skills/hyper-seo/assets/report.template.ko.md"
export HS_CHECKLIST_EN="skills/hyper-seo/references/seo-checklist.md"
export HS_CHECKLIST_KO="skills/hyper-seo/references/seo-checklist.ko.md"
export HS_AEO_GEO_EN="skills/hyper-seo/references/aeo-geo-guide.md"
export HS_AEO_GEO_KO="skills/hyper-seo/references/aeo-geo-guide.ko.md"
export HS_FUNDAMENTALS_EN="skills/hyper-seo/references/seo-fundamentals.md"
export HS_FUNDAMENTALS_KO="skills/hyper-seo/references/seo-fundamentals.ko.md"
export HS_ARTIFACT_SPEC_EN="skills/hyper-seo/references/artifact-spec.md"
export HS_ARTIFACT_SPEC_KO="skills/hyper-seo/references/artifact-spec.ko.md"
export HS_SKILL_EN="skills/hyper-seo/SKILL.md"

# Marker appended to checklist items whose fixed number is a heuristic.
HS_HEURISTIC_MARKER="(heuristic)"

HS_US=$(printf '\037')

# ---- parser --------------------------------------------------------------

# hs_records <file> — emit H/I/T records for one markdown document.
hs_records() {
  if [ "$#" -ne 1 ]; then
    printf 'hs_records: usage: hs_records <file>\n' >&2
    return 2
  fi
  awk -v us="$HS_US" '
    function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
    function section(   out, i, part) {
      out = ""
      for (i = 1; i <= level; i++) {
        part = s[i]
        if (part == "") continue
        out = (out == "") ? part : out " > " part
      }
      return out
    }
    function item_id(text,   a) {
      if (match(text, /`[^`]+`/)) {
        a = substr(text, RSTART + 1, RLENGTH - 2)
        return a
      }
      return ""
    }
    {
      line = $0
      sub(/\r$/, "", line)

      # heading: 1-6 hashes followed by whitespace
      if (line ~ /^#{1,6}[ \t]/) {
        h = line
        sub(/[^#].*$/, "", h)
        lvl = length(h)
        title = line
        sub(/^#+[ \t]+/, "", title)
        title = trim(title)
        table = 0
        for (i = lvl + 1; i <= maxlevel; i++) s[i] = ""
        s[lvl] = title
        level = lvl
        if (maxlevel < lvl) maxlevel = lvl
        printf "H%s%d%s%d%s%s%s%s\n", us, hidx, us, lvl, us, title, us, section()
        hidx++
        next
      }

      # table row
      if (line ~ /^[ \t]*\|.*\|[ \t]*$/) {
        if (line ~ /^[ \t]*\|[ \t:|+-]+\|[ \t]*$/) next
        content = line
        sub(/^[ \t]*\|/, "", content)
        sub(/\|[ \t]*$/, "", content)
        n = split(content, cells, "|")
        if (content == "") { n = 1; cells[1] = "" }
        rec = ""
        for (i = 1; i <= n; i++) rec = rec us trim(cells[i])
        if (table == 0) {
          tidx++
          tabsec = section()
          trow = 0
          table = 1
          printf "T%s%d%s-1%s%s%s\n", us, tidx, us, us, tabsec, rec
          next
        }
        printf "T%s%d%s%d%s%s%s\n", us, tidx, us, trow, us, tabsec, rec
        trow++
        next
      }

      # blank lines keep the current table open, exactly like parseDoc
      if (line ~ /^[ \t\r]*$/) next
      table = 0

      # checklist item
      if (line ~ /^[ \t]*[-*][ \t]*\[[ xX]\][ \t]+/) {
        c = line
        sub(/^[ \t]*[-*][ \t]*\[/, "", c)
        checked = (substr(c, 1, 1) == "x" || substr(c, 1, 1) == "X") ? 1 : 0
        c = substr(c, 2)
        sub(/^\][ \t]+/, "", c)
        text = trim(c)
        printf "I%s%d%s%d%s%s%s%s%s%s\n", us, itemidx, us, checked, us, item_id(text), us, section(), us, text
        itemidx++
      }
    }
    BEGIN { itemidx = 0; hidx = 0; tidx = -1; trow = 0; level = 0; maxlevel = 0; table = 0 }
  ' "$1"
}

# hs_items <file> — emit `index<US>checked<US>id<US>section<US>text`.
hs_items() {
  hs_records "$1" | awk -F "$HS_US" '$1 == "I" { print }'
}

# hs_headings <file> — emit `index<US>level<US>title<US>path`.
hs_headings() {
  hs_records "$1" | awk -F "$HS_US" '$1 == "H" { print }'
}

# hs_item_text <file> <index> — text of one checklist item.
hs_item_text() {
  hs_records "$1" | awk -F "$HS_US" -v want="$2" '$1 == "I" && $2 == want { print $6; exit }'
}

# hs_item_id <text> — first backticked token, or the empty string.
hs_item_id() {
  printf '%s' "$1" | awk '
    { if (match($0, /`[^`]+`/)) print substr($0, RSTART + 1, RLENGTH - 2) }
  '
}

# ---- checklist sections --------------------------------------------------

# hs_section_items <file> <section-suffix> — items of the first section whose
# path ends with the suffix: `index<US>checked<US>id<US>section<US>text`.
hs_section_items() {
  hs_records "$1" | awk -F "$HS_US" -v want="$2" '
    $1 == "I" {
      n = length(want)
      matches = (n == 0 || substr($5, length($5) - n + 1) == want)
      if (!found) {
        if (!matches) next
        found = 1
        matched = $5
      }
      if ($5 == matched) print
    }
  '
}

# hs_section_ids <file> <section-suffix> — ids of that section, one per line.
hs_section_ids() {
  hs_section_items "$1" "$2" | awk -F "$HS_US" '{ print $4 }'
}

# ---- comparisons ---------------------------------------------------------

# hs_compare_checklist_files <en> <ko> — mismatch lines (empty when aligned).
hs_compare_checklist_files() {
  {
    hs_records "$1" | awk -F "$HS_US" -v OFS="$HS_US" '{ $1 = "E" $1; print }'
    hs_records "$2" | awk -F "$HS_US" -v OFS="$HS_US" '{ $1 = "K" $1; print }'
  } | awk -F "$HS_US" '
    BEGIN { nsec["E"] = 0; nsec["K"] = 0; gcount["E"] = 0; gcount["K"] = 0 }
    function close_group(stream) {
      sec[stream, nsec[stream]] = lastsec[stream]
      nids[stream, nsec[stream]] = gcount[stream]
      nsec[stream]++
    }
    substr($1, 2) == "I" {
      stream = substr($1, 1, 1)
      secname = $5
      if (gcount[stream] == 0 || secname != lastsec[stream]) {
        if (gcount[stream] > 0) close_group(stream)
        gcount[stream] = 0
        lastsec[stream] = secname
      }
      ids[stream, nsec[stream], gcount[stream]] = $4
      gcount[stream]++
    }
    END {
      for (s = 1; s <= 2; s++) {
        stream = (s == 1) ? "E" : "K"
        if (gcount[stream] > 0) close_group(stream)
      }
      if (nsec["E"] != nsec["K"]) printf "section count: en=%d ko=%d\n", nsec["E"], nsec["K"]
      width = (nsec["E"] > nsec["K"]) ? nsec["E"] : nsec["K"]
      for (i = 0; i < width; i++) {
        where = sprintf("section %d (%s): ", i, sec["E", i])
        if (i >= nsec["E"] || i >= nsec["K"]) {
          printf "%ssection %d present in en=%d ko=%d\n", where, i, (i < nsec["E"]), (i < nsec["K"])
          continue
        }
        if (nids["E", i] != nids["K", i]) {
          printf "%sitem count: en=%d ko=%d\n", where, nids["E", i], nids["K", i]
        }
        w = (nids["E", i] > nids["K", i]) ? nids["E", i] : nids["K", i]
        for (j = 0; j < w; j++) {
          a = (j < nids["E", i]) ? ids["E", i, j] : "<missing>"
          b = (j < nids["K", i]) ? ids["K", i, j] : "<missing>"
          if (a != b) printf "%sitem %d: id en=%s ko=%s\n", where, j, a, b
        }
      }
    }
  '
}

# hs_heuristic_indices <file> — document-order indices of marked items.
hs_heuristic_indices() {
  hs_records "$1" | awk -F "$HS_US" -v marker="$HS_HEURISTIC_MARKER" '
    $1 == "I" && index($6, marker) > 0 { print $2 }
  '
}

# hs_compare_heuristic <en> <ko> — mismatch lines for the heuristic markers.
hs_compare_heuristic() {
  {
    hs_heuristic_indices "$1" | awk '{ print "E " $0 }'
    hs_heuristic_indices "$2" | awk '{ print "K " $0 }'
  } | awk '
    BEGIN { nen = 0; nko = 0 }
    $1 == "E" { en[nen++] = $2 }
    $1 == "K" { ko[nko++] = $2 }
    END {
      if (nen != nko) printf "heuristic count: en=%d ko=%d\n", nen, nko
      width = (nen > nko) ? nen : nko
      for (i = 0; i < width; i++) {
        a = (i < nen) ? en[i] : "<missing>"
        b = (i < nko) ? ko[i] : "<missing>"
        if (a != b) printf "heuristic %d: index en=%s ko=%s\n", i, a, b
      }
    }
  '
}

# hs_target_condition <text> — normalized `(target: x)` value, or empty.
hs_target_condition() {
  printf '%s' "$1" | awk '
    {
      if (match($0, /\(target:[ \t]*[a-zA-Z0-9][a-zA-Z0-9 \/,_-]*\)/)) {
        value = substr($0, RSTART + 8, RLENGTH - 9)
        gsub(/^[ \t]+|[ \t]+$/, "", value)
        gsub(/  +/, " ", value)
        print tolower(value)
      }
    }
  '
}

# hs_conditional_items <file> — `C<US>index<US>id<US>target<US>section`, in order.
hs_conditional_items() {
  hs_records "$1" | awk -F "$HS_US" -v us="$HS_US" '
    $1 == "I" {
      if (match($6, /\(target:[ \t]*[a-zA-Z0-9][a-zA-Z0-9 \/,_-]*\)/)) {
        value = substr($6, RSTART + 8, RLENGTH - 9)
        gsub(/^[ \t]+|[ \t]+$/, "", value)
        gsub(/  +/, " ", value)
        printf "C%s%s%s%s%s%s%s%s\n", us, $2, us, $4, us, tolower(value), us, $5
      }
    }
  '
}

# hs_conditional_items_for_target <file> <target> — ids for one target.
hs_conditional_items_for_target() {
  hs_conditional_items "$1" | awk -F "$HS_US" -v want="$2" '
    BEGIN { wanted = tolower(want); gsub(/^[ \t]+|[ \t]+$/, "", wanted) }
    $4 == wanted { print $3 }
  '
}

# hs_compare_conditional <en> <ko> — mismatch lines for conditional items.
hs_compare_conditional() {
  {
    hs_conditional_items "$1" | awk -F "$HS_US" -v OFS="$HS_US" '{ $1 = "E" $1; print }'
    hs_conditional_items "$2" | awk -F "$HS_US" -v OFS="$HS_US" '{ $1 = "K" $1; print }'
  } | awk -F "$HS_US" '
    BEGIN { nen = 0; nko = 0 }
    substr($1, 2) == "C" {
      stream = substr($1, 1, 1)
      if (stream == "E") { eid[nen] = $3; etgt[nen] = $4; nen++ }
      else { kid[nko] = $3; ktgt[nko] = $4; nko++ }
    }
    END {
      if (nen != nko) printf "conditional item count: en=%d ko=%d\n", nen, nko
      width = (nen > nko) ? nen : nko
      for (i = 0; i < width; i++) {
        if (i >= nen || i >= nko) {
          a = (i < nen) ? eid[i] : "<missing>"
          b = (i < nko) ? kid[i] : "<missing>"
          printf "conditional item %d: en=%s ko=%s\n", i, a, b
          continue
        }
        if (eid[i] != kid[i]) printf "conditional item %d: id en=%s ko=%s\n", i, eid[i], kid[i]
        if (etgt[i] != ktgt[i]) printf "conditional item %d (%s): target en=%s ko=%s\n", i, eid[i], etgt[i], ktgt[i]
      }
    }
  '
}

# hs_ranking_ids <file> — item ids naming a third-party ranking-algorithm claim.
hs_ranking_ids() {
  hs_records "$1" | awk -F "$HS_US" '
    function rank_claim(id,   low) {
      low = tolower(id)
      if (low ~ /(^|[^a-z0-9_])c[- ]?rank([^a-z0-9_]|$)/) return 1
      if (low ~ /(^|[^a-z0-9_])d\.i\.a(\.|[^a-z0-9_]|$)/) return 1
      if (low ~ /(^|[^a-z0-9_])smart ?block([^a-z0-9_]|$)/) return 1
      if (id ~ /스마트[ \t]*블록/) return 1
      return 0
    }
    $1 == "I" && $4 != "" { if (rank_claim($4)) print $4 }
  '
}

# hs_heading_levels <file> — level per heading, space separated.
hs_heading_levels() {
  hs_headings "$1" | awk -F "$HS_US" '{ printf "%s%s", sep, $3; sep = " " }'
}

# hs_heading_titles <file> — title per heading, one per line.
hs_heading_titles() {
  hs_headings "$1" | awk -F "$HS_US" '{ print $4 }'
}

# hs_compare_headings <en> <ko> — heading count and level mismatch lines.
hs_compare_headings() {
  local en_count ko_count en_levels ko_levels
  en_count=$(hs_headings "$1" | wc -l | tr -d ' ')
  ko_count=$(hs_headings "$2" | wc -l | tr -d ' ')
  if [ "$en_count" -ne "$ko_count" ]; then
    printf 'heading count: en=%s ko=%s\n' "$en_count" "$ko_count"
  fi
  en_levels=$(hs_heading_levels "$1")
  ko_levels=$(hs_heading_levels "$2")
  if [ "$en_levels" != "$ko_levels" ]; then
    printf 'heading levels: en=[%s] ko=[%s]\n' "$(printf '%s' "$en_levels" | tr ' ' ',')" "$(printf '%s' "$ko_levels" | tr ' ' ',')"
  fi
}

# hs_heading_position <file> <title> — `index<US>level` of the first exact match.
hs_heading_position() {
  hs_headings "$1" | awk -F "$HS_US" -v want="$2" '
    $4 == want { printf "%s%s%s\n", $2, "\037", $3; exit }
  '
}

# ---- tables --------------------------------------------------------------

# hs_table <file> [header-cell] — TSV of the first table carrying the header
# cell (any table when the cell is omitted): header line, then rows.
hs_table() {
  hs_records "$1" | awk -F "$HS_US" -v want="${2:-}" '
    function join_cells(from, to,   s, i) {
      s = ""
      for (i = from; i <= to; i++) s = s (i > from ? "\t" : "") $i
      return s
    }
    $1 == "T" {
      t = $2
      if (!(t in seen)) { seen[t] = 1; order[++ntables] = t; nrows[t] = 0 }
      if ($3 == "-1") { hdr[t] = join_cells(5, NF) }
      else { rows[t, nrows[t]] = join_cells(5, NF); nrows[t]++ }
    }
    END {
      for (k = 1; k <= ntables; k++) {
        t = order[k]
        if (!(t in hdr)) continue
        n = split(hdr[t], cells, "\t")
        found = (want == "") ? 1 : 0
        for (i = 1; i <= n; i++) if (cells[i] == want) found = 1
        if (!found) continue
        print hdr[t]
        for (r = 0; r < nrows[t]; r++) print rows[t, r]
        exit 0
      }
    }
  '
}

# hs_table_header <table-text> — first line.
hs_table_header() {
  printf '%s\n' "$1" | awk 'NR == 1 { print; exit }'
}

# hs_table_rows <table-text> — every line after the header.
hs_table_rows() {
  printf '%s\n' "$1" | awk 'NR > 1 { print }'
}

# hs_table_is_aligned <table-text> <columns> — exit 0 when every row has N cells.
hs_table_is_aligned() {
  printf '%s\n' "$1" | awk -F '\t' -v want="$2" '{ if (NF != want) bad = 1 } END { exit bad ? 1 : 0 }'
}

# hs_column_index <header-line> <column> — 1-based index, or empty.
hs_column_index() {
  printf '%s\n' "$1" | awk -F '\t' -v want="$2" '
    { for (i = 1; i <= NF; i++) if ($i == want) { print i; exit } }
  '
}

# hs_cell <row-line> <1-based index> — one cell.
hs_cell() {
  printf '%s\n' "$1" | awk -F '\t' -v i="$2" '{ print $i }'
}

# hs_table_column <table-text> <column> — one cell per row, in row order.
hs_table_column() {
  local header idx
  header=$(hs_table_header "$1")
  idx=$(hs_column_index "$header" "$2")
  hs_table_rows "$1" | awk -F '\t' -v i="$idx" 'i > 0 { print $i }'
}

# hs_table_first_ids <table-text> — first-backtick id (or trimmed cell) per row.
hs_table_first_ids() {
  hs_table_rows "$1" | awk -F '\t' '
    {
      cell = $1
      if (match(cell, /`[^`]+`/)) print substr(cell, RSTART + 1, RLENGTH - 2)
      else print cell
    }
  '
}

# hs_table_row <table-text> <column> <id> — row whose named cell carries the id.
hs_table_row() {
  local header idx
  header=$(hs_table_header "$1")
  idx=$(hs_column_index "$header" "$2")
  hs_table_rows "$1" | awk -F '\t' -v i="$idx" -v want="$3" '
    i > 0 {
      cell = $i
      if (match(cell, /`[^`]+`/)) cell = substr(cell, RSTART + 1, RLENGTH - 2)
      if (cell == want) { print; exit }
    }
  '
}

# hs_table_cell <row-line> <table-text> <column> — one cell addressed by name.
hs_table_cell() {
  local header idx
  header=$(hs_table_header "$2")
  idx=$(hs_column_index "$header" "$3")
  printf '%s\n' "$1" | awk -F '\t' -v i="$idx" 'i > 0 { print $i }'
}

# ---- report template columns ---------------------------------------------

# Canonical column identity of a report-template header cell. The English and
# Korean display labels and the raw results.json field names all resolve to one
# identity, so a column survives translation while a second spelling stays
# visible. The awk block below is the only copy of that table.
# shellcheck disable=SC2016  # awk program text; $ names are awk fields, not shell variables.
HS_AWK_COLUMNS='
function field(cell) {
  if (cell == "#") return "#"
  if (cell == "Category" || cell == "카테고리") return "category"
  if (cell == "Score" || cell == "점수") return "score"
  if (cell == "Status" || cell == "상태") return "status"
  if (cell == "Method" || cell == "방법" || cell == "measurement_method") return "measurement_method"
  if (cell == "Evidence Grade" || cell == "증거 등급" || cell == "evidence_grade") return "evidence_grade"
  if (cell == "Confidence" || cell == "신뢰도" || cell == "confidence") return "confidence"
  if (cell == "Confidence Impact" || cell == "신뢰도 영향") return "confidence_impact"
  if (cell == "Notes" || cell == "메모") return "notes"
  if (cell == "Finding" || cell == "발견사항") return "finding"
  if (cell == "Location" || cell == "위치") return "location"
  if (cell == "Source Tier" || cell == "출처 계층" || cell == "source_tier") return "source_tier"
  if (cell == "Recommendation" || cell == "권장사항") return "recommendation"
  if (cell == "Dimension" || cell == "차원") return "dimension"
  if (cell == "Platform/Bot" || cell == "플랫폼/봇") return "platform"
  if (cell == "Purpose" || cell == "목적") return "purpose"
  if (cell == "Priority" || cell == "우선순위") return "priority"
  if (cell == "Action" || cell == "작업") return "action"
  if (cell == "Impact" || cell == "영향") return "impact"
  if (cell == "Effort" || cell == "노력") return "effort"
  if (cell == "Date" || cell == "날짜") return "date"
  if (cell == "Changes" || cell == "변경사항") return "changes"
  return ""
}
function quote(text,   out) {
  out = text
  gsub(/"/, "\\\"", out)
  return "\"" out "\""
}
function field_array(from, to,   out, i) {
  out = "["
  for (i = from; i <= to; i++) out = out (i > from ? "," : "") quote(field($i))
  return out "]"
}
function unknown_array(from, to,   out, i) {
  out = "["
  for (i = from; i <= to; i++) {
    if (field($i) != "") continue
    out = out (out == "[" ? "" : ",") quote($i)
  }
  return out "]"
}
'

# hs_compare_report_templates <en> <ko> — mismatch lines.
hs_compare_report_templates() {
  {
    hs_records "$1" | awk -F "$HS_US" -v OFS="$HS_US" '{ $1 = "E" $1; print }'
    hs_records "$2" | awk -F "$HS_US" -v OFS="$HS_US" '{ $1 = "K" $1; print }'
  } | awk -F "$HS_US" "$HS_AWK_COLUMNS"'
    substr($1, 2) == "T" && $3 == "-1" {
      stream = substr($1, 1, 1)
      t = $2
      ncols[stream, t] = NF - 4
      section[stream, t] = $4
      unknown[stream, t] = unknown_array(5, NF)
      fields[stream, t] = field_array(5, NF)
      ntables[stream]++
    }
    END {
      if (ntables["E"] != ntables["K"]) printf "table count: en=%d ko=%d\n", ntables["E"], ntables["K"]
      width = (ntables["E"] < ntables["K"]) ? ntables["E"] : ntables["K"]
      for (i = 0; i < width; i++) {
        where = sprintf("table %d (%s)", i, section["E", i])
        if (ncols["E", i] != ncols["K", i]) {
          printf "%s: column count en=%d ko=%d\n", where, ncols["E", i], ncols["K", i]
          continue
        }
        if (unknown["E", i] != "[]") printf "%s: unknown en header cells %s\n", where, unknown["E", i]
        if (unknown["K", i] != "[]") printf "%s: unknown ko header cells %s\n", where, unknown["K", i]
        if (fields["E", i] != fields["K", i]) printf "%s: columns en=%s ko=%s\n", where, fields["E", i], fields["K", i]
      }
    }
  '
}

# hs_report_conflicts <file> — one line per field spelled more than one way.
hs_report_conflicts() {
  hs_records "$1" | awk -F "$HS_US" "$HS_AWK_COLUMNS"'
    $1 == "T" && $3 == "-1" {
      for (i = 5; i <= NF; i++) {
        f = field($i)
        if (f == "") continue
        key = f SUBSEP $i
        if (key in seen) continue
        seen[key] = 1
        print f "\t" $i
      }
    }
  ' | LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2 | awk -F '\t' '
    {
      if ($1 != last) {
        if (last != "" && count > 1) printf "%s: %s\n", last, labels
        last = $1
        labels = $2
        count = 1
      } else {
        labels = labels " | " $2
        count++
      }
    }
    END { if (last != "" && count > 1) printf "%s: %s\n", last, labels }
  '
}

# ---- document structure --------------------------------------------------

# hs_compare_doc_structure <en> <ko> — heading, title and table structure.
hs_compare_doc_structure() {
  hs_compare_headings "$1" "$2"
  local en_titles ko_titles i width en_title ko_title
  en_titles=$(hs_heading_titles "$1")
  ko_titles=$(hs_heading_titles "$2")
  width=$(printf '%s\n' "$en_titles" | wc -l | tr -d ' ')
  i=1
  while [ "$i" -le "$width" ]; do
    en_title=$(printf '%s\n' "$en_titles" | awk -v n="$i" 'NR == n { print }')
    ko_title=$(printf '%s\n' "$ko_titles" | awk -v n="$i" 'NR == n { print; found = 1 } END { if (!found) print "<missing>" }')
    case $en_title in
      *[!\ -~]*) : ;;
      *)
        case $ko_title in
          *[!\ -~]*) : ;;
          *)
            if [ "$en_title" != "$ko_title" ]; then
              printf 'heading %s: en=%s ko=%s\n' "$((i - 1))" "$en_title" "$ko_title"
            fi
            ;;
        esac
        ;;
    esac
    i=$((i + 1))
  done

  local en_tables ko_tables count t
  en_tables=$(hs_records "$1" | awk -F "$HS_US" '$1 == "T" && $3 == "-1" { print $2 }' | wc -l | tr -d ' ')
  ko_tables=$(hs_records "$2" | awk -F "$HS_US" '$1 == "T" && $3 == "-1" { print $2 }' | wc -l | tr -d ' ')
  if [ "$en_tables" -ne "$ko_tables" ]; then
    printf 'table count: en=%s ko=%s\n' "$en_tables" "$ko_tables"
  fi
  count=$en_tables
  [ "$ko_tables" -lt "$count" ] && count=$ko_tables
  t=0
  while [ "$t" -lt "$count" ]; do
    local en_header ko_header en_cols ko_cols en_rows ko_rows
    en_header=$(hs_table_by_index "$1" "$t" header)
    ko_header=$(hs_table_by_index "$2" "$t" header)
    en_cols=$(printf '%s\n' "$en_header" | awk -F '\t' '{ print NF }')
    ko_cols=$(printf '%s\n' "$ko_header" | awk -F '\t' '{ print NF }')
    en_rows=$(hs_table_by_index "$1" "$t" rows | wc -l | tr -d ' ')
    ko_rows=$(hs_table_by_index "$2" "$t" rows | wc -l | tr -d ' ')
    if [ "$en_cols" -ne "$ko_cols" ]; then
      printf 'table %s: columns en=%s ko=%s\n' "$t" "$en_cols" "$ko_cols"
    fi
    if [ "$en_rows" -ne "$ko_rows" ]; then
      printf 'table %s: rows en=%s ko=%s\n' "$t" "$en_rows" "$ko_rows"
    fi
    t=$((t + 1))
  done
}

# hs_table_by_index <file> <index> header|rows — one table part addressed by index.
hs_table_by_index() {
  hs_records "$1" | awk -F "$HS_US" -v t="$2" -v part="$3" '
    function join_cells(from, to,   s, i) {
      s = ""
      for (i = from; i <= to; i++) s = s (i > from ? "\t" : "") $i
      return s
    }
    $1 == "T" && $2 == t {
      if ($3 == "-1") { if (part == "header") print join_cells(5, NF) }
      else if (part == "rows") print join_cells(5, NF)
    }
  '
}

# ---- source ledger -------------------------------------------------------

# hs_source_ledger <file> — TSV with Source/Accessed/Supports/Caveat.
# Header line first; empty when the document carries no ledger table.
hs_source_ledger() {
  local table header idx_source idx_accessed idx_supports idx_caveat
  table=$(hs_table "$1" "Source")
  [ -n "$table" ] || return 0
  header=$(hs_table_header "$table")
  idx_accessed=$(hs_column_index "$header" "Accessed")
  idx_supports=$(hs_column_index "$header" "Supports")
  idx_caveat=$(hs_column_index "$header" "Caveat")
  if [ -z "$idx_accessed" ] || [ -z "$idx_supports" ] || [ -z "$idx_caveat" ]; then
    return 0
  fi
  idx_source=$(hs_column_index "$header" "Source")
  printf 'Source\tAccessed\tSupports\tCaveat\n'
  hs_table_rows "$table" | awk -F '\t' -v s="$idx_source" -v a="$idx_accessed" -v p="$idx_supports" -v c="$idx_caveat" '
    { printf "%s\t%s\t%s\t%s\n", $s, $a, $p, $c }
  '
}

# hs_ledger_rows <file> — ledger rows without the header.
hs_ledger_rows() {
  hs_source_ledger "$1" | awk 'NR > 1'
}

# hs_ledger_column <file> <column> — one cell per ledger row.
hs_ledger_column() {
  hs_source_ledger "$1" | awk -F '\t' -v want="$2" '
    NR == 1 { for (i = 1; i <= NF; i++) if ($i == want) idx = i; next }
    idx > 0 { print $idx }
  '
}

# hs_last_verified <file> — declared verification date, or empty.
hs_last_verified() {
  grep -oE '\*\*(Last verified|최종 확인)\*\*:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$1" 2>/dev/null |
    awk 'NR == 1' |
    sed -E 's/.*:?[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2})$/\1/'
}

# ---- dashboard template -----------------------------------------------
#
# The dashboard template runs in a browser. Two node programs below execute the
# shipped asset itself instead of reimplementing it: the source gate scans its
# inline script for unescaped sinks, and the observation harness evaluates the
# template's own render functions against a minimal element stub. The stub is
# not a layout engine: it models innerHTML, textContent, className and hidden,
# which is exactly the surface the escaping, counter and panel checks read. Checks
# that need real layout or file:// script loading stay skipped, with the reason
# printed by the caller.

# hs_source_gate <template> — JSON {literals, sinks, checked, violations}.
hs_source_gate() {
  node - "$1" <<'JS'
const fs = require("fs");
const html = fs.readFileSync(process.argv[2], "utf8");

const SANITIZERS = ["escapeHtml", "sevClass", "statusClass", "gradeClass"];
const FRAGMENT_LOCALS = ["rows", "best"];
const SAFE_IDENTIFIERS = new Set([
  ...SANITIZERS, ...FRAGMENT_LOCALS,
  "i", "Number", "String", "Object", "Array", "Date", "Math", "JSON",
]);

function skipString(body, i) {
  const quote = body[i];
  i += 1;
  while (i < body.length) {
    if (body[i] === "\\") { i += 2; continue; }
    if (body[i] === quote) return i + 1;
    i += 1;
  }
  throw new Error("unterminated string literal in the inline script");
}

function matchBrace(body, i, found) {
  let depth = 0;
  while (i < body.length) {
    const ch = body[i];
    if (ch === '"' || ch === "'") { i = skipString(body, i); continue; }
    if (ch === "`") { i = readTemplate(body, i, found); continue; }
    if (ch === "{") depth += 1;
    else if (ch === "}") { depth -= 1; if (depth === 0) return i + 1; }
    i += 1;
  }
  throw new Error("unbalanced ${...} in the inline script");
}

function readTemplate(body, i, found) {
  const start = i;
  i += 1;
  let text = "";
  const expressions = [];
  while (i < body.length) {
    const ch = body[i];
    if (ch === "\\") { text += body.slice(i, i + 2); i += 2; continue; }
    if (ch === "`") { found.push({ start, text, expressions }); return i + 1; }
    if (ch === "$" && body[i + 1] === "{") {
      const close = matchBrace(body, i + 1, found);
      expressions.push(body.slice(i + 2, close - 1));
      i = close;
      continue;
    }
    text += ch;
    i += 1;
  }
  throw new Error("unterminated template literal in the inline script");
}

function collectTemplates(body) {
  const found = [];
  let i = 0;
  while (i < body.length) {
    const ch = body[i];
    if (ch === '"' || ch === "'") { i = skipString(body, i); continue; }
    if (ch === "`") { i = readTemplate(body, i, found); continue; }
    if (ch === "/" && body[i + 1] === "/") {
      const newline = body.indexOf("\n", i);
      i = newline < 0 ? body.length : newline + 1;
      continue;
    }
    if (ch === "/" && body[i + 1] === "*") {
      const close = body.indexOf("*/", i);
      i = close < 0 ? body.length : close + 2;
      continue;
    }
    i += 1;
  }
  return found;
}

function inlineScript(source) {
  const matches = [...source.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g)];
  if (matches.length !== 1) {
    throw new Error("expected exactly one inline <script>, found " + matches.length);
  }
  return matches[0][1];
}

function isSink(body, literal) {
  if (literal.text.includes("<")) return true;
  return /\.className\s*=\s*$/.test(body.slice(Math.max(0, literal.start - 40), literal.start));
}

function statementText(body, i) {
  const start = i;
  let depth = 0;
  while (i < body.length) {
    const ch = body[i];
    if (ch === '"' || ch === "'") { i = skipString(body, i); continue; }
    if (ch === "`") { i = readTemplate(body, i, []); continue; }
    if (ch === "(" || ch === "[" || ch === "{") depth += 1;
    else if (ch === ")" || ch === "]" || ch === "}") {
      if (depth === 0) return body.slice(start, i);
      depth -= 1;
    } else if (ch === ";" && depth === 0) return body.slice(start, i);
    i += 1;
  }
  return body.slice(start);
}

function verifiedFragments(body) {
  const verified = new Set();
  for (const name of FRAGMENT_LOCALS) {
    const declarations = [...body.matchAll(new RegExp("(?:const|let|var)\\s+" + name + "\\s*=\\s*", "g"))];
    if (!declarations.length) continue;
    const allSafe = declarations.every((match) => {
      const text = statementText(body, (match.index ?? 0) + match[0].length).trim();
      return text.includes("`") || /\.join\(""\)$/.test(text);
    });
    if (allSafe) verified.add(name);
  }
  return verified;
}

function innerHtmlViolations(body, fragments) {
  const violations = [];
  const record = (rule, expression) => violations.push({
    rule,
    sink: "innerHTML",
    expression: expression.trim().replace(/\s+/g, " ").slice(0, 80),
  });
  for (const match of body.matchAll(/\.innerHTML\s*(\+=|=)\s*/g)) {
    const start = (match.index ?? 0) + match[0].length;
    const ch = body[start];
    if (ch === "`" || ch === '"' || ch === "'") {
      const end = ch === "`" ? readTemplate(body, start, []) : skipString(body, start);
      const next = (body.slice(end).match(/^\s*(.)/) ?? [])[1];
      if (next !== ";") record("innerHTML-concatenation", body.slice(start, Math.min(end + 60, body.length)));
      continue;
    }
    const statement = statementText(body, start).trim();
    if (fragments.has(statement)) continue;
    record("innerHTML-unverified", statement);
  }
  return violations;
}

function sinkViolations(body) {
  const fragments = verifiedFragments(body);
  const violations = [];
  for (const literal of collectTemplates(body)) {
    if (!isSink(body, literal)) continue;
    for (const expression of literal.expressions) {
      const code = expression.replace(/"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'/g, '""').trim();
      if (SANITIZERS.some((name) => code.startsWith(name + "("))) continue;
      const unknown = [...code.matchAll(/(?<![.\w$])([A-Za-z_$][\w$]*)/g)]
        .map((match) => match[1])
        .filter((name) => !SAFE_IDENTIFIERS.has(name))
        .filter((name) => !(FRAGMENT_LOCALS.includes(name) && fragments.has(name)));
      if (unknown.length) {
        violations.push({
          rule: "unescaped-interpolation",
          sink: literal.text.trim().replace(/\s+/g, " ").slice(0, 60),
          expression: expression.trim().replace(/\s+/g, " ").slice(0, 70) + " [unknown: " + [...new Set(unknown)].join(", ") + "]",
        });
      }
    }
  }
  return [...violations, ...innerHtmlViolations(body, fragments)];
}

const body = inlineScript(html);
const literals = collectTemplates(body);
const sinks = literals.filter((literal) => isSink(body, literal));
const checked = sinks.flatMap((literal) => literal.expressions);
console.log(JSON.stringify({
  literals: literals.length,
  sinks: sinks.length,
  checked: checked.length,
  violations: sinkViolations(body),
}));
JS
}

# hs_render_observe <template> <payload-json> — JSON observation of one render.
#
# The template's inline script is loaded with its trailing refresh() bootstrap
# removed, and its own applyData() is called with the payload. Observations are
# read back from the markup the template produced.
hs_render_observe() {
  node - "$1" "$2" <<'JS'
const fs = require("fs");
const templatePath = process.argv[2];
const payloadPath = process.argv[3];
const html = fs.readFileSync(templatePath, "utf8");
const payload = JSON.parse(fs.readFileSync(payloadPath, "utf8"));

function inlineScript(source) {
  const matches = [...source.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g)];
  if (matches.length !== 1) {
    throw new Error("expected exactly one inline <script>, found " + matches.length);
  }
  return matches[0][1];
}

function textOf(markup) {
  return String(markup)
    .replace(/<[^>]*>/g, "")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, "&");
}

const elements = new Map();
function makeElement(id) {
  const el = { id, className: "", hidden: false, style: {}, _html: "", _text: null };
  Object.defineProperty(el, "innerHTML", {
    get() { return el._html; },
    set(value) { el._html = String(value); el._text = null; },
  });
  Object.defineProperty(el, "textContent", {
    get() { return el._text === null ? textOf(el._html) : el._text; },
    set(value) { el._text = String(value); el._html = ""; },
  });
  return el;
}
for (const match of html.matchAll(/\sid="([^"]+)"/g)) elements.set(match[1], makeElement(match[1]));

const documentStub = {
  getElementById: (id) => elements.get(id) ?? null,
  querySelectorAll: () => [],
  createElement: () => makeElement(""),
  head: { appendChild() {} },
  body: { textContent: "" },
};

let body = inlineScript(html);
const bootstrap = body.search(/\n\s*refresh\(\)\.catch/);
if (bootstrap < 0) throw new Error("template bootstrap not found: cannot cut refresh() safely");
body = body.slice(0, bootstrap);
if (body.includes("setInterval(")) throw new Error("template bootstrap removal left setInterval behind");
const factory = new Function("document", "window", "Chart", body + "\n;return { applyData: applyData };");
const api = factory(documentStub, { location: { protocol: "http:" } }, undefined);
api.applyData(payload);

const PANELS = [
  "findings-wrap", "category-grid", "measurement-wrap", "platform-wrap",
  "ai-experiments-wrap", "history-wrap", "quickwins-wrap", "actions-wrap",
];
const panelText = {};
const panelMarkup = [];
for (const id of PANELS) {
  const el = elements.get(id);
  panelText[id] = el ? el.textContent : "";
  panelMarkup.push(el ? el.innerHTML : "");
}
const allMarkup = panelMarkup.join("\n");

const read = (id) => (elements.get(id) ? elements.get(id).textContent : "");
const payloadText = payload && payload.findings && payload.findings[0] ? String(payload.findings[0].finding ?? "") : "";
const tags = [...allMarkup.matchAll(/<[^>]+>/g)].map((match) => match[0]);
const attributeLeaks = tags.filter((tag) => /\son[a-z]+\s*=/.test(tag) || tag.includes("proof-marker")).length;

const observation = {
  markerElement: /<[a-z][^>]*\bid=["']?proof-marker/i.test(allMarkup),
  visibleText: payloadText !== "" && textOf(elements.get("findings-wrap").innerHTML).includes(payloadText),
  attributeLeaks,
  chartGlobal: typeof Chart,
  findings: panelText["findings-wrap"].includes("panel-marker") ? "visible" : "missing",
  measurement: panelText["measurement-wrap"].includes("panel-marker") ? "visible" : "missing",
  platform: panelText["platform-wrap"].includes("panel-marker") ? "visible" : "missing",
  category: panelText["category-grid"].includes("panel-marker") ? "visible" : "missing",
  total: read("cnt-total"),
  critical: read("cnt-critical"),
  warning: read("cnt-warning"),
  info: read("cnt-info"),
  other: read("cnt-other"),
  otherHidden: elements.get("cnt-other-wrap") ? elements.get("cnt-other-wrap").hidden : null,
  pillClassName: elements.get("status-pill") ? elements.get("status-pill").className : "",
  gradeClassName: elements.get("overall-grade") ? elements.get("overall-grade").className : "",
  sevClassNames: [...allMarkup.matchAll(/class="sev ([^"]*)"/g)].map((match) => "sev " + match[1]),
  panelText,
  actionsTextLength: panelText["actions-wrap"].length,
  subtitle: read("subtitle"),
};
console.log(JSON.stringify(observation));
JS
}

# hs_render_page_verdict <template> <payload-json> <observe> — the corpus verdict
# shape for a render-page probe: a compact JSON value the corpus compares with
# `jq -S -c`.
hs_render_page_verdict() {
  local observe=$3 observation
  observation=$(hs_render_observe "$1" "$2")
  case $observe in
    escaping)
      printf '%s' "$observation" | jq -S -c '{markerElement, visibleText, attributeLeaks}'
      ;;
    chart-absent)
      printf '%s' "$observation" | jq -S -c '{chartGlobal, findings, measurement, platform, category}'
      ;;
    *)
      printf 'unknown observe mode: %s\n' "$observe" >&2
      return 2
      ;;
  esac
}
