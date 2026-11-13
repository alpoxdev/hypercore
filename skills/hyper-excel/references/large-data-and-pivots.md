# Large Data and Pivots

> Row limits, measured throughput, and what "make a pivot" actually produces here.

## Hard limits

| Limit | Value | Consequence |
|---|---|---|
| Rows per sheet | 1,048,576 | a 1.2M-row CSV needs two sheets or a real database |
| Columns per sheet | 16,384 | stops at `XFD` |
| Cell text length | 32,767 characters | longer is truncated silently by some writers |
| Distinct cell formats per workbook | 65,490 | a per-row style breaks the file |
| Sheet name | 31 characters | longer is rejected |
| Cell reference in a formula | 8,192 characters | long array formulas hit this |

The row limit is the one that bites. A conversion that silently drops rows past 1,048,576 is worse than a failure, so `build_workbook.py` refuses rather than truncating, and `profile` reports the row count before you convert.

## Measured throughput

Conditions: this machine (Apple silicon), 2026-11-13, `inspect` over a 120,000-row × 6-column CSV converted to `.xlsx`.

| Stage | Result |
|---|---|
| CSV → `.xlsx` (`build --csv`) | completed |
| `inspect` of the result (≈720,000 cells) | ≈6 s |
| peak behaviour | streaming read; the package is opened part by part, not held as an object graph |

So roughly 8 µs per cell for a full structural inspection. Budget a minute for a million cells and plan the read window accordingly: `inspect --rows N` limits the per-sheet sample without limiting the scan.

## Streaming rules

- Read one sheet part at a time; never build a workbook-wide cell dict for a large file.
- Convert with the CSV path, not by loading the sheet and re-writing it: the CSV path streams rows into the sheet XML.
- Avoid writing a per-row style. Use a handful of range formats.
- For analysis over more than a few hundred thousand rows, a spreadsheet is the wrong tool. Say so and compute in a script, then write only the summary to the workbook.

## Pivots

**A native pivot table is not produced by this skill.** A pivot is a `pivotTableDefinition` plus a `pivotCacheDefinition` whose cache holds a copy of the source rows; authoring one correctly requires the cache field index mapping, the shared-item tables, and the row/column field axes. Writing it by hand is possible but fragile, and a malformed cache makes Excel repair the file.

What to do instead, and say so plainly:

1. Compute the aggregation and write it as ordinary rows with a header, a total row, and a number format.
2. If the user needs to re-pivot interactively, deliver the source as an Excel **table** (`Table` with a name and style). Excel's "Insert → PivotTable" then works on it in one click, and the table survives a `patch`.
3. If the user explicitly needs a native pivot and the machine has Excel, say the pivot must be created in Excel; do not fabricate one.

The report line is: `피벗은 계산된 일반 행으로 만들었습니다. 원본은 표(Table)로 넣었으니 엑셀에서 피벗을 바로 만들 수 있습니다.`

## Aggregation contract

When computing a pivot-like summary:

- State the group-by keys, the aggregation function, and the filter.
- Report the input row count and the number of groups.
- Sort deterministically (by key, or by value descending with a tie-break on key) so the output is reproducible.
- Put a total row at the bottom, and make it a formula (`=SUM(...)`) rather than a constant so it survives edits.
- Keep numbers numeric. A group label that looks like a number (`2026`) is text in the key column.

## Wide tables

A table with 300 columns is legal and unusable. Before building one, report the column count and propose transposing or splitting. A `.xlsx` with 300 columns will also make the recipient scroll sideways forever; that is a delivery problem, not a format problem, but say it once.

## Memory

The Python scripts hold one part in memory at a time plus the parsed cell list for the sheet being inspected. A 120,000-row sheet is comfortable. Past roughly 500,000 rows in one sheet, expect several hundred MB and prefer `--rows` plus targeted reads. If a job needs more, it is a data-processing job, not a workbook job.

## Sources

> Checked 2026-11-13.

| Claim | Source |
|---|---|
| Worksheet limits: 1,048,576 rows, 16,384 columns, 32,767 characters per cell | <https://support.microsoft.com/en-us/office/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3> |
| Distinct cell formats per workbook: 65,490 | <https://support.microsoft.com/en-us/office/excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3> |
| The 120,000-row conversion and ≈6 s inspection | `build_workbook.py` and `inspect_workbook.py` run on this machine 2026-11-13 |
| A row or column overflow is refused rather than truncated | `build_workbook.py` `MAX_ROWS`/`MAX_COLS` guard, exercised by its self-test on 2026-11-13 |
| A pivot table needs a `pivotTableDefinition` plus a `pivotCacheDefinition` holding the source copy | <https://learn.microsoft.com/en-us/office/open-xml/spreadsheet/working-with-pivot-tables> |

### Evidence grade

`LOCAL` for the measured throughput and the refusal behavior; the limits and pivot-structure rows are Microsoft's documentation.
