# Failure Modes

> Each of these produces a spreadsheet that looks finished and is wrong. Every one has a detection the tool reports.

## 1. Numbers stored as text

Symptom: `SUM` over a column returns 0 or skips rows; the cell shows a small green triangle in Excel.

Why: CSV import, copy-paste from a web page, or a leading apostrophe leaves the value as a string.

Detection: `profile` reports `MIXED_TYPES` for a column that is mostly text with numbers mixed in, and `LEADING_ZERO` for values whose leading zero would vanish; `verify_formulas` flags `TEXT_NUMBER` when arithmetic touches a text cell.

Fix: convert with `--set-value` after confirming the intended type, or fix at build time by emitting numbers. Never "fix" by wrapping the formula in `VALUE()` — the underlying data stays wrong.

## 2. Short sum range

Symptom: totals are slightly low; every row is included in the table.

Why: a formula was written before the last rows were appended, or a filter hid rows and someone applied a subtotal to the visible part only.

Detection: `verify_formulas` reports `RANGE_GAP` when a sum range ends before the contiguous data ends, when a range stops at a blank row inside the block, or when a total sits inside the range it sums.

Fix: extend the range or reference a table column. Confirm the new total against an independent computation.

## 3. Stale cache

Symptom: another program (pandas, a script with `data_only=True`) shows an old number or blank; Excel shows the correct one.

Why: the file was written by a tool that stored the formula without a `<v>`, or the cache was computed before the data changed.

Detection: `inspect` raises `W_FORMULA_NO_CACHE` and reports `formulaWithoutCache` per sheet; `verify` keeps `totals.uncached` separate from `mismatches`.

Fix: `recalc` to store values, or leave the cache alone and tell the user which reader will see blanks. Cached and computed counts are reported separately — never merge them into one "mismatch" number.

## 4. Percent off by 100

Symptom: a growth rate shows 1,500% instead of 15%.

Why: the value was stored as `15` with a percent format, or as `0.15` with a general format. Only `0.15` plus `0.0%` is right.

Detection: `verify_formulas` reports `PERCENT_AS_WHOLE` when a percent-formatted cell holds a value above 1, and `profile` reports `PERCENT_AS_TEXT` for a `%` suffix inside imported text.

Fix: divide by 100 and apply the percent format; keep the numeric value fractional.

## 5. Date locale inversion

Symptom: `03/04/2026` became March 4 in one tool and April 3 in another.

Why: a date typed or parsed under a day-first locale, stored as a string, or converted with an ambiguous format.

Detection: `profile` reports `AMBIGUOUS_DATE` when a column mixes date patterns or holds ISO dates alongside locale dates, and `LOCALE_DATE_TEXT` when every value uses one non-ISO pattern.

Fix: store dates as serial numbers with an explicit `yyyy-mm-dd` format. Never store a date as text and never guess between day-first and month-first: report the ambiguity.

## 6. Lost leading zeros

Symptom: a postal code or product ID `00123` became `123`.

Why: the column was typed as a number during import or conversion.

Detection: `profile` reports `LEADING_ZERO` with the count and the column, and the column record carries a `leadingZeros` count.

Fix: store as text with an explicit text number format (`@`), and mark the column as text in the build spec.

## 7. Self-reference and cycles

Symptom: Excel shows a circular reference warning; the value is 0 or the last typed value.

Why: a total was placed inside its own range, or a formula chain loops.

Detection: `verify_formulas` reports `SELF_REFERENCE` for a direct hit and a cycle for a longer loop, naming every cell in the loop.

Fix: move the total out of the range or break the loop. Never paper over it by turning on iterative calculation.

## 8. Formula injection from imported text

Symptom: none until someone opens the file — a value starting with `=`, `+`, `-`, or `@` is executed as a formula or a DDE call.

Why: imported CSV text was written as a formula because the writer did not escape a leading `=`.

Detection: the builder escapes a leading `=`, `+`, `-`, `@` into a text cell and reports the count; review that report.

Fix: store as text (string type), and report which column and how many values were neutralized. Never silently delete the value — the user may need to see it.

## 9. No cached value for a formula-heavy file

Symptom: recipients on a non-calculating reader see an empty report.

Why: formulas were written without a cache and never recalculated.

Detection: `inspect` raises `W_FORMULA_NO_CACHE` with a per-sheet `formulaWithoutCache` count; `verify` reports `cache_complete` as `partial` while any formula lacks a value.

Fix: `recalc`. It writes values and sets `fullCalcOnLoad`, so Excel still recomputes from source on open.

## 10. Newer function unsupported by the target Excel

Symptom: `#NAME?` on an older Excel; the file was written with `XLOOKUP`, `LET`, `FILTER`, or `TEXTJOIN`.

Detection: `verify_formulas` reports `NEWER_FUNCTION` with the function and the cell.

Fix: replace with an equivalent, or state the minimum Excel version the file requires.

## 11. Volatile formulas in a large sheet

Symptom: the file is slow to open and every keystroke recalculates everything.

Detection: `verify_formulas` reports `VOLATILE_FUNCTION` with a cell count per function.

Fix: replace `OFFSET`/`INDIRECT`/`TODAY`/`NOW`/`RAND` with a static reference or a helper column, or state why it is needed.

## 12. Ragged rows and mixed types in one column

Symptom: totals work, but filtering or a pivot drops rows silently.

Why: a column holds numbers and text, or blank rows sit inside the data block.

Detection: `profile` reports per-column `kind`, `MIXED_TYPES` for a mixed column, and the column record counts blanks.

Fix: normalize before building; report rows that were dropped or coerced.

## Sources

> Checked 2026-11-13.

| Claim | Source |
|---|---|
| A percent cell must hold a fraction; storing 15 shows 1,500% | <https://support.microsoft.com/en-us/office/format-numbers-as-percentages-9b46a1f1-1c2b-40a8-9a9f-d9d9e1b0e8a1> |
| A formula cell's `<v>` cache is what non-calculating readers show | <https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.cellvalue> |
| Leading `=`, `+`, `-`, `@` in imported text is a formula-injection vector | <https://owasp.org/www-community/attacks/CSV_Injection> |
| `XLOOKUP`, `LET`, `FILTER`, `TEXTJOIN` are unavailable in older Excel builds | <https://support.microsoft.com/en-us/office/xlookup-function-b7fd680e-6d10-43e6-84f9-88eae8bf5929> |
| Circular references break calculation rather than resolving silently | <https://support.microsoft.com/en-us/office/remove-or-allow-a-circular-reference-in-excel-8540bd0f-6e97-4483-bcf7-1b49cd50d123> |
| The finding codes and their thresholds are this skill's | `verify_formulas.py` `static_findings`, read on 2026-11-13 |

### Evidence grade

`LOCAL` for the detection codes and severities; the Excel and OWASP rows are vendor and standards documentation for the underlying behavior.
