#!/usr/bin/env bun
// @ts-check

/**
 * Document-contract assertions for the seo-maker rule docs.
 *
 * The parser itself lives in `seo-maker-doc-contracts.mjs` so that later seo-maker
 * todos and plain scripts can import it; this file re-exports it and holds the
 * contract assertions. Every helper takes a repository root path and defaults to
 * this repository, so a negative control can point the parser at a `mkdtemp` copy
 * instead of mutating repository files.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { expect, test } from "bun:test";

export * from "./seo-maker-doc-contracts.mjs";

import {
  AEO_GEO_EN,
  AEO_GEO_KO,
  CHECKBOX,
  CHECKLIST_EN,
  CHECKLIST_KO,
  REPO_ROOT,
  REPORT_TEMPLATE_EN,
  REPORT_TEMPLATE_KO,
  TABLE_ROW,
  VALIDATION_EN,
  VALIDATION_KO,
  WORKFLOW_EN,
  WORKFLOW_KO,
  checklistIds,
  checklistSections,
  compareChecklistFiles,
  compareConditionalItems,
  compareHeadingStructure,
  compareHeuristicMarkers,
  compareReportTemplates,
  conditionalItems,
  conditionalItemsForTarget,
  headingPosition,
  heuristicItemIndices,
  itemId,
  lastVerified,
  parseDoc,
  rankingAlgorithmIds,
  readDoc,
  reportColumnConflicts,
  sourceLedger,
  tempCopy,
} from "./seo-maker-doc-contracts.mjs";

/** Section path suffix of the crawl/render/index interpretation boundaries. */
const BOUNDARY_SECTION_EN = "Crawl, Render & Index Interpretation Boundaries";
const BOUNDARY_SECTION_KO = "크롤·렌더·색인 해석 경계";

/**
 * The six interpretation boundaries carried over from the research report's
 * technical table, identified by their first backticked token.
 */
const BOUNDARY_IDS = ["source HTML", "robots.txt", "canonical", "internal links", "filtered URLs", "sitemap"];

/** @param {string} md @param {string} sectionTitle @returns {import("./seo-maker-doc-contracts.mjs").ChecklistItem[]} items of the matching section */
function itemsOfSection(md, sectionTitle) {
  const section = checklistSections(md).find((entry) => entry.section.endsWith(sectionTitle));
  if (!section) throw new Error(`checklist section not found: ${sectionTitle}`);
  return section.items;
}

test("validation checklists keep the same item structure in English and Korean", () => {
  const result = compareChecklistFiles(readDoc(VALIDATION_EN), readDoc(VALIDATION_KO));
  expect(result.mismatches).toEqual([]);
  expect(result.ok).toBe(true);
});

test("complex audit checklist covers the mode artifacts", () => {
  const ids = checklistIds(itemsOfSection(readDoc(VALIDATION_EN), "Complex audit"));
  for (const artifact of ["dashboard.html", "results.js", "flow.json"]) {
    expect(ids).toContain(artifact);
  }
});

test("simple audit checklist covers its minimum artifacts", () => {
  const ids = checklistIds(itemsOfSection(readDoc(VALIDATION_EN), "Simple audit"));
  expect(ids).toContain("sources.md");
});

test("workflow phases keep the same heading structure in English and Korean", () => {
  const en = parseDoc(readDoc(WORKFLOW_EN)).headings;
  const ko = parseDoc(readDoc(WORKFLOW_KO)).headings;
  expect(ko.map((heading) => heading.level)).toEqual(en.map((heading) => heading.level));
  expect(ko.length).toBe(en.length);
});

test("parser detects a checklist item dropped from one language variant", () => {
  const copy = tempCopy(VALIDATION_KO);
  try {
    const target = join(copy.root, VALIDATION_KO);
    const lines = readFileSync(target, "utf8").split("\n");
    const dropIndex = lines.findIndex((line) => CHECKBOX.test(line) && itemId(line) === "dashboard.html");
    expect(dropIndex).toBeGreaterThan(-1);
    lines.splice(dropIndex, 1);
    writeFileSync(target, lines.join("\n"));

    const result = compareChecklistFiles(readDoc(VALIDATION_EN), readDoc(VALIDATION_KO, copy.root));
    expect(result.ok).toBe(false);
    expect(result.mismatches.join("\n")).toContain("item count");
  } finally {
    copy.cleanup();
  }
});

test("seo checklist keeps the same checkbox structure in English and Korean", () => {
  const en = parseDoc(readDoc(CHECKLIST_EN)).items;
  const ko = parseDoc(readDoc(CHECKLIST_KO)).items;
  expect(ko.length).toBe(en.length);
  expect(compareChecklistFiles(readDoc(CHECKLIST_EN), readDoc(CHECKLIST_KO)).mismatches).toEqual([]);
});

test("seo checklist marks the nine fixed thresholds as heuristic in both languages", () => {
  const result = compareHeuristicMarkers(readDoc(CHECKLIST_EN), readDoc(CHECKLIST_KO));
  expect(result.mismatches).toEqual([]);
  expect(result.en).toEqual([59, 61, 64, 73, 78, 81, 83, 84, 94]);
  expect(result.ko).toEqual(result.en);

  const items = parseDoc(readDoc(CHECKLIST_EN)).items;
  const marked = items.filter((item) => item.text.includes("(heuristic)"));
  expect(marked.length).toBe(9);
  expect(checklistIds(marked)).toEqual([
    "<title>",
    `<meta name="description">`,
    "<h1>",
    "og:image",
    null,
    null,
    null,
    null,
    null,
  ]);
  expect(marked.every((item) => item.checked === false)).toBe(true);
});

test("seo checklist records the six crawl, render, and index interpretation boundaries", () => {
  const enIds = checklistIds(itemsOfSection(readDoc(CHECKLIST_EN), BOUNDARY_SECTION_EN));
  const koIds = checklistIds(itemsOfSection(readDoc(CHECKLIST_KO), BOUNDARY_SECTION_KO));
  expect(enIds).toEqual(BOUNDARY_IDS);
  expect(koIds).toEqual(BOUNDARY_IDS);
  expect(enIds.length).toBe(6);
});

test("parser detects a heuristic marker removed from one language variant", () => {
  const copy = tempCopy(CHECKLIST_KO);
  try {
    const target = join(copy.root, CHECKLIST_KO);
    const lines = readFileSync(target, "utf8").split("\n");
    const dropIndex = lines.findIndex((line) => CHECKBOX.test(line) && line.includes("(heuristic)"));
    expect(dropIndex).toBeGreaterThan(-1);
    lines[dropIndex] = lines[dropIndex].replace(" (heuristic)", "");
    writeFileSync(target, lines.join("\n"));

    const result = compareHeuristicMarkers(readDoc(CHECKLIST_EN), readDoc(CHECKLIST_KO, copy.root));
    expect(result.ok).toBe(false);
    expect(result.mismatches.join("\n")).toContain("heuristic count");
    expect(heuristicItemIndices(readDoc(CHECKLIST_KO, copy.root)).length).toBe(8);
  } finally {
    copy.cleanup();
  }
});

test("report templates keep the same table columns in English and Korean", () => {
  const result = compareReportTemplates(readDoc(REPORT_TEMPLATE_EN), readDoc(REPORT_TEMPLATE_KO));
  expect(result.mismatches).toEqual([]);
  expect(result.ok).toBe(true);
});

test("report templates spell each column one way", () => {
  expect(reportColumnConflicts(readDoc(REPORT_TEMPLATE_EN))).toEqual([]);
  expect(reportColumnConflicts(readDoc(REPORT_TEMPLATE_KO))).toEqual([]);
});

test("parser detects report template header drift in one language variant", () => {
  const copy = tempCopy(REPORT_TEMPLATE_EN);
  try {
    const target = join(copy.root, REPORT_TEMPLATE_EN);
    const original = readFileSync(target, "utf8");
    const findingsHeader = "| # | Finding | Location | Evidence Grade | Confidence | Method | Source Tier | Recommendation |";
    expect(original).toContain(findingsHeader);

    const unknownLabel = original.replace(findingsHeader, "| # | Finding | Location | Evidence | Confidence | Method | Source Tier | Recommendation |");
    writeFileSync(target, unknownLabel);
    const unknownResult = compareReportTemplates(readDoc(REPORT_TEMPLATE_EN, copy.root), readDoc(REPORT_TEMPLATE_KO));
    expect(unknownResult.ok).toBe(false);
    expect(unknownResult.mismatches.join("\n")).toContain("unknown en header cells");

    const otherColumn = original.replace(findingsHeader, "| # | Finding | Location | Evidence Grade | Confidence | Notes | Source Tier | Recommendation |");
    writeFileSync(target, otherColumn);
    const otherResult = compareReportTemplates(readDoc(REPORT_TEMPLATE_EN, copy.root), readDoc(REPORT_TEMPLATE_KO));
    expect(otherResult.ok).toBe(false);
    expect(otherResult.mismatches.join("\n")).toContain("columns en=");

    const snakeCase = original.replace(
      findingsHeader,
      "| # | Finding | Location | evidence_grade | Confidence | measurement_method | source_tier | Recommendation |",
    );
    writeFileSync(target, snakeCase);
    expect(reportColumnConflicts(readDoc(REPORT_TEMPLATE_EN, copy.root)).sort()).toEqual([
      "evidence_grade: Evidence Grade | evidence_grade",
      "measurement_method: Method | measurement_method",
      "source_tier: Source Tier | source_tier",
    ]);
  } finally {
    copy.cleanup();
  }
});

/** The fundamentals reference pair, which carries the pipeline, policy, status and ledger tables. */
const FUNDAMENTALS_EN = "skills/seo-maker/references/seo-fundamentals.md";
const FUNDAMENTALS_KO = "skills/seo-maker/references/seo-fundamentals.ko.md";

/** Stage identifiers of the crawl -> render -> index -> appearance pipeline table. */
const PIPELINE_STAGE_IDS = ["crawl", "render", "index", "appearance"];

/**
 * Policy identifiers of the spam and abuse table. The last row records that generative AI use
 * alone is not a violation, so that rule is carried as parsed structure instead of as prose.
 */
const SPAM_POLICY_IDS = [
  "scaled content abuse",
  "expired domain abuse",
  "site reputation policy",
  "doorway abuse",
  "thin affiliation",
  "scraped content",
  "generative AI use",
];

/** Support states allowed in the structured-data status table. */
const SUPPORT_STATUSES = ["supported", "retired", "unverified"];

const DATE_CELL = /^\d{4}-\d{2}-\d{2}$/;
/** Cell text for a date the source does not document. */
const NO_DATE = "\u2014";
/** Cell text for a date that exists but was not verified against a primary source. */
const UNCONFIRMED = "unconfirmed";

/**
 * The first table carrying a given header cell.
 *
 * @param {string} markdown document text
 * @param {string} cell header cell text
 * @returns {import("./seo-maker-doc-contracts.mjs").Table} table
 * @throws {Error} when no table carries the cell
 */
function tableWithHeaderCell(markdown, cell) {
  const table = parseDoc(markdown).tables.find((entry) => entry.header.includes(cell));
  if (!table) throw new Error(`no table with header cell: ${cell}`);
  return table;
}

/**
 * @param {import("./seo-maker-doc-contracts.mjs").Table} table table
 * @param {string[]} row row cells
 * @param {string} column header cell naming the column
 * @returns {string} cell text
 * @throws {Error} when the header names no such column
 */
function cellOf(table, row, column) {
  const index = table.header.indexOf(column);
  if (index < 0) throw new Error(`no column ${column} in ${JSON.stringify(table.header)}`);
  return row[index] ?? "";
}

/**
 * Row whose first backticked token in one column equals the identifier.
 *
 * @param {import("./seo-maker-doc-contracts.mjs").Table} table table
 * @param {string} column header cell naming the column
 * @param {string} id backticked identifier
 * @returns {string[] | null} matching row
 */
function rowWithId(table, column, id) {
  return table.rows.find((row) => itemId(cellOf(table, row, column)) === id) ?? null;
}

/**
 * First backticked token of every row in the first column, falling back to the raw cell.
 *
 * @param {import("./seo-maker-doc-contracts.mjs").Table} table table
 * @returns {string[]} row identifiers
 */
function firstColumnIds(table) {
  return table.rows.map((row) => itemId(row[0] ?? "") ?? (row[0] ?? "").trim());
}

/**
 * Structural parity of two language variants: heading count, levels and untranslated headings via
 * the shared heading comparison, plus table count, column count and row count. Translated headings
 * are compared by position only, so a dropped, added or renamed section still fails.
 *
 * @param {string} enMarkdown English document
 * @param {string} koMarkdown Korean document
 * @returns {{ ok: boolean, mismatches: string[] }} comparison result
 */
function compareDocStructure(enMarkdown, koMarkdown) {
  const en = parseDoc(enMarkdown);
  const ko = parseDoc(koMarkdown);
  const headings = compareHeadingStructure(enMarkdown, koMarkdown);
  /** @type {string[]} */
  const mismatches = [...headings.mismatches];

  en.headings.forEach((heading, index) => {
    if (!/^[\x20-\x7E]+$/.test(heading.title)) return;
    const koTitle = ko.headings[index]?.title ?? "<missing>";
    if (!/^[\x20-\x7E]+$/.test(koTitle)) return;
    if (koTitle !== heading.title) mismatches.push(`heading ${index}: en=${heading.title} ko=${koTitle}`);
  });

  if (en.tables.length !== ko.tables.length) {
    mismatches.push(`table count: en=${en.tables.length} ko=${ko.tables.length}`);
  }
  for (let i = 0; i < Math.min(en.tables.length, ko.tables.length); i += 1) {
    const enTable = en.tables[i];
    const koTable = ko.tables[i];
    const where = `table ${i} (${enTable.section})`;
    if (enTable.header.length !== koTable.header.length) {
      mismatches.push(`${where}: columns en=${enTable.header.length} ko=${koTable.header.length}`);
    }
    if (enTable.rows.length !== koTable.rows.length) {
      mismatches.push(`${where}: rows en=${enTable.rows.length} ko=${koTable.rows.length}`);
    }
  }

  return { ok: mismatches.length === 0, mismatches };
}

/**
 * Date-contract problems in the source ledger. Every row carries an accessed and an observed date
 * and a confirmation URL, and notice and effective dates appear together and differ, so a policy
 * announcement is never read as the date the policy took effect.
 *
 * @param {string} markdown document text
 * @returns {string[]} one line per problem
 */
function ledgerProblems(markdown) {
  const table = tableWithHeaderCell(markdown, "Accessed");
  /** @type {string[]} */
  const problems = [];
  for (const row of table.rows) {
    const source = cellOf(table, row, "Source");
    const accessed = cellOf(table, row, "Accessed");
    const observed = cellOf(table, row, "Observed");
    const notice = cellOf(table, row, "Notice");
    const effective = cellOf(table, row, "Effective");
    const confirmedAt = cellOf(table, row, "Confirmed at");
    if (!DATE_CELL.test(accessed)) problems.push(`${source}: accessed=${accessed || "<empty>"}`);
    if (!DATE_CELL.test(observed)) problems.push(`${source}: observed=${observed || "<empty>"}`);
    if (confirmedAt !== NO_DATE && !/^https:\/\//.test(confirmedAt)) {
      problems.push(`${source}: confirmed at=${confirmedAt || "<empty>"}`);
    }
    const noticeDated = DATE_CELL.test(notice);
    const effectiveDated = DATE_CELL.test(effective);
    if (noticeDated !== effectiveDated) {
      problems.push(`${source}: notice=${notice} effective=${effective}`);
    }
    if (noticeDated && notice === effective) {
      problems.push(`${source}: notice equals effective (${notice})`);
    }
    if (noticeDated && confirmedAt === NO_DATE) {
      problems.push(`${source}: dated policy row without a confirmation URL`);
    }
  }
  return problems;
}

/**
 * Contract problems in the structured-data status table: statuses stay inside the enum, notice and
 * effective dates appear together and differ, a retired feature carries either both dates or an
 * unconfirmed marker, and an unverified feature carries no dates at all.
 *
 * @param {string} markdown document text
 * @returns {string[]} one line per problem
 */
function statusTableProblems(markdown) {
  const table = tableWithHeaderCell(markdown, "Status");
  /** @type {string[]} */
  const problems = [];
  for (const row of table.rows) {
    const type = itemId(cellOf(table, row, "Type")) ?? cellOf(table, row, "Type");
    const status = cellOf(table, row, "Status");
    const notice = cellOf(table, row, "Notice");
    const effective = cellOf(table, row, "Effective");
    if (!SUPPORT_STATUSES.includes(status)) problems.push(`${type}: status=${status}`);
    const noticeDated = DATE_CELL.test(notice);
    const effectiveDated = DATE_CELL.test(effective);
    if (noticeDated !== effectiveDated) problems.push(`${type}: notice=${notice} effective=${effective}`);
    if (noticeDated && notice === effective) problems.push(`${type}: notice equals effective (${notice})`);
    if (status === "retired" && !noticeDated && !(notice === UNCONFIRMED && effective === UNCONFIRMED)) {
      problems.push(`${type}: retired without dates or an unconfirmed marker`);
    }
    if (status === "unverified" && (notice !== NO_DATE || effective !== NO_DATE)) {
      problems.push(`${type}: unverified with dates notice=${notice} effective=${effective}`);
    }
  }
  return problems;
}

test("seo fundamentals keeps the same section and table structure in English and Korean", () => {
  const result = compareDocStructure(readDoc(FUNDAMENTALS_EN), readDoc(FUNDAMENTALS_KO));
  expect(result.mismatches).toEqual([]);
  expect(result.ok).toBe(true);
});

test("seo fundamentals names the four pipeline stages in both languages", () => {
  for (const path of [FUNDAMENTALS_EN, FUNDAMENTALS_KO]) {
    const table = tableWithHeaderCell(readDoc(path), "Stage");
    expect(firstColumnIds(table)).toEqual(PIPELINE_STAGE_IDS);
    expect(table.rows.every((row) => row.length === table.header.length)).toBe(true);
  }
});

test("seo fundamentals names the spam and abuse policies in both languages", () => {
  for (const path of [FUNDAMENTALS_EN, FUNDAMENTALS_KO]) {
    const table = tableWithHeaderCell(readDoc(path), "Policy");
    expect(firstColumnIds(table)).toEqual(SPAM_POLICY_IDS);
  }
});

test("seo fundamentals records structured-data support status and leaves ClaimReview unverified", () => {
  for (const path of [FUNDAMENTALS_EN, FUNDAMENTALS_KO]) {
    expect(statusTableProblems(readDoc(path))).toEqual([]);
    const table = tableWithHeaderCell(readDoc(path), "Status");

    const faq = rowWithId(table, "Type", "FAQPage");
    if (!faq) throw new Error(`${path}: no FAQPage row`);
    expect(cellOf(table, faq, "Status")).toBe("retired");
    expect(DATE_CELL.test(cellOf(table, faq, "Notice"))).toBe(true);
    expect(DATE_CELL.test(cellOf(table, faq, "Effective"))).toBe(true);
    expect(cellOf(table, faq, "Notice")).not.toBe(cellOf(table, faq, "Effective"));

    const howTo = rowWithId(table, "Type", "HowTo");
    if (!howTo) throw new Error(`${path}: no HowTo row`);
    expect(cellOf(table, howTo, "Status")).toBe("retired");
    expect(cellOf(table, howTo, "Notice")).toBe(UNCONFIRMED);

    for (const type of ["Product", "merchant listing", "ProductGroup"]) {
      const row = rowWithId(table, "Type", type);
      if (!row) throw new Error(`${path}: no ${type} row`);
      expect(cellOf(table, row, "Status")).toBe("supported");
    }

    const claimReview = rowWithId(table, "Type", "ClaimReview");
    if (!claimReview) throw new Error(`${path}: no ClaimReview row`);
    expect(cellOf(table, claimReview, "Status")).toBe("unverified");
  }
});

test("seo fundamentals dates every source row and separates policy notice from effective dates", () => {
  for (const path of [FUNDAMENTALS_EN, FUNDAMENTALS_KO]) {
    const markdown = readDoc(path);
    expect(ledgerProblems(markdown)).toEqual([]);
    const table = tableWithHeaderCell(markdown, "Accessed");
    expect(table.rows.length).toBeGreaterThan(0);
    const dated = table.rows.filter((row) => DATE_CELL.test(cellOf(table, row, "Notice")));
    expect(dated.length).toBeGreaterThan(0);
    expect(dated.every((row) => cellOf(table, row, "Notice") !== cellOf(table, row, "Effective"))).toBe(true);
  }
});

test("parser detects a source ledger row that lost its accessed date", () => {
  const copy = tempCopy(FUNDAMENTALS_EN);
  try {
    const target = join(copy.root, FUNDAMENTALS_EN);
    const original = readFileSync(target, "utf8");
    const datedRow = /^.*\| 2026-09-21 \| 2026-09-21 \|.*$/m.exec(original);
    expect(datedRow).not.toBeNull();
    const stripped = /** @type {RegExpExecArray} */ (datedRow)[0].replace("| 2026-09-21 |", "|  |");
    writeFileSync(target, original.replace(/** @type {RegExpExecArray} */ (datedRow)[0], stripped));

    const problems = ledgerProblems(readDoc(FUNDAMENTALS_EN, copy.root));
    expect(problems.length).toBeGreaterThan(0);
    expect(problems.join("\n")).toContain("accessed=<empty>");
  } finally {
    copy.cleanup();
  }
});

/** Section identity of the Search Console generative AI inclusion controls. */
const AI_CONTROLS_SECTION_EN = "Search Console AI Inclusion Controls (`official`)";
const AI_CONTROLS_SECTION_KO = "Search Console 생성 AI 포함 제어(`official`)";

/** Section identity of the Generative AI performance report. */
const AI_REPORT_SECTION_EN = "Generative AI Performance Report (`official`)";
const AI_REPORT_SECTION_KO = "생성 AI 성과 보고서(`official`)";

/** Section identity of the bot purpose versus observed access separation. */
const BOT_EVIDENCE_SECTION_EN = "Bot Purpose vs Observed Access (`official` + `field`)";
const BOT_EVIDENCE_SECTION_KO = "봇 목적과 관측 접근의 구분(`official` + `field`)";

/** Sources the 2026-09-21 verification pass added to the guide's source ledger. */
const VERIFIED_ON_2026_09_21 = [
  "https://support.google.com/webmasters/answer/16908024",
  "https://support.google.com/webmasters/answer/16984139",
];

const ISO_DATE = /^\d{4}-\d{2}-\d{2}$/;

/** @param {string} md @returns {string[]} access dates in ledger order */
function accessedDates(md) {
  const ledger = sourceLedger(md);
  if (!ledger) throw new Error("source ledger not found");
  return ledger.rows.map((row) => row.accessed);
}

test("aeo/geo guide keeps the same heading structure in English and Korean", () => {
  const result = compareHeadingStructure(readDoc(AEO_GEO_EN), readDoc(AEO_GEO_KO));
  expect(result.mismatches).toEqual([]);
  expect(result.ok).toBe(true);
});

test("aeo/geo guide carries the AI inclusion, reporting, and bot-evidence sections in both languages", () => {
  const en = readDoc(AEO_GEO_EN);
  const ko = readDoc(AEO_GEO_KO);
  for (const [enTitle, koTitle] of [
    [AI_CONTROLS_SECTION_EN, AI_CONTROLS_SECTION_KO],
    [AI_REPORT_SECTION_EN, AI_REPORT_SECTION_KO],
    [BOT_EVIDENCE_SECTION_EN, BOT_EVIDENCE_SECTION_KO],
  ]) {
    const enPosition = headingPosition(en, enTitle);
    expect(enPosition).not.toBeNull();
    expect(headingPosition(ko, koTitle)).toEqual(enPosition);
  }
});

test("aeo/geo guide source ledger stays aligned in English and Korean", () => {
  const en = sourceLedger(readDoc(AEO_GEO_EN));
  const ko = sourceLedger(readDoc(AEO_GEO_KO));
  expect(en).not.toBeNull();
  expect(ko).not.toBeNull();
  expect(ko?.header).toEqual(en?.header);
  expect(ko?.rows.length).toBe(en?.rows.length);
  expect(ko?.rows.map((row) => row.source)).toEqual(en?.rows.map((row) => row.source));
  expect(ko?.rows.map((row) => row.accessed)).toEqual(en?.rows.map((row) => row.accessed));
});

test("aeo/geo guide source ledger records the 2026-09-21 verification rows", () => {
  const accessed = accessedDates(readDoc(AEO_GEO_EN));
  expect(accessed).toContain("2026-09-21");
  expect(accessed.every((cell) => ISO_DATE.test(cell))).toBe(true);

  const ledger = sourceLedger(readDoc(AEO_GEO_EN));
  const verified = ledger?.rows.filter((row) => row.accessed === "2026-09-21").map((row) => row.source) ?? [];
  for (const source of VERIFIED_ON_2026_09_21) expect(verified).toContain(source);
});

test("aeo/geo guide last-verified date matches its newest ledger access date", () => {
  const accessed = accessedDates(readDoc(AEO_GEO_EN)).sort();
  const newest = accessed[accessed.length - 1];
  expect(newest).toBe("2026-09-21");
  expect(lastVerified(readDoc(AEO_GEO_EN))).toBe(newest);
  expect(lastVerified(readDoc(AEO_GEO_KO))).toBe(newest);
});

test("parser detects an aeo/geo source ledger row that lost its access date", () => {
  const copy = tempCopy(AEO_GEO_KO);
  try {
    const target = join(copy.root, AEO_GEO_KO);
    const lines = readFileSync(target, "utf8").split("\n");
    const rowIndex = lines.findIndex((line) => TABLE_ROW.test(line) && line.includes(VERIFIED_ON_2026_09_21[1]));
    expect(rowIndex).toBeGreaterThan(-1);
    lines[rowIndex] = lines[rowIndex].replace("| 2026-09-21 |", "| |");
    writeFileSync(target, lines.join("\n"));

    const koAccessed = accessedDates(readDoc(AEO_GEO_KO, copy.root));
    expect(koAccessed).not.toEqual(accessedDates(readDoc(AEO_GEO_EN)));
    expect(koAccessed.some((cell) => !ISO_DATE.test(cell))).toBe(true);
  } finally {
    copy.cleanup();
  }
});

test("parser detects an aeo/geo section missing from one language variant", () => {
  const copy = tempCopy(AEO_GEO_KO);
  try {
    const target = join(copy.root, AEO_GEO_KO);
    const lines = readFileSync(target, "utf8").split("\n");
    const dropIndex = lines.findIndex((line) => line.trim() === `## ${AI_REPORT_SECTION_KO}`);
    expect(dropIndex).toBeGreaterThan(-1);
    lines.splice(dropIndex, 1);
    writeFileSync(target, lines.join("\n"));

    const result = compareHeadingStructure(readDoc(AEO_GEO_EN), readDoc(AEO_GEO_KO, copy.root));
    expect(result.ok).toBe(false);
    expect(result.mismatches.join("\n")).toContain("heading count");
    expect(headingPosition(readDoc(AEO_GEO_KO, copy.root), AI_REPORT_SECTION_KO)).toBeNull();
  } finally {
    copy.cleanup();
  }
});

/** Section path of the conditional Naver platform-policy block, one per language variant. */
const NAVER_SECTION_EN = "Platform Policy Checklist > Naver (Search Advisor)";
const NAVER_SECTION_KO = "플랫폼 정책 체크리스트 > Naver(서치어드바이저)";

/**
 * The Naver-only audit items, identified by their first backticked token. Each carries the
 * language-independent `(target: naver)` marker, so both language variants must declare the same
 * identifiers under the same target condition in the same order.
 */
const NAVER_CONDITIONAL_IDS = [
  "Yeti",
  "robots.txt",
  "RSS",
  "og:image",
  "nosourceinfo",
  "soft 404",
  "Google-only directives",
];

test("seo checklist declares the same conditional Naver items in English and Korean", () => {
  const en = readDoc(CHECKLIST_EN);
  const ko = readDoc(CHECKLIST_KO);

  const result = compareConditionalItems(en, ko);
  expect(result.mismatches).toEqual([]);
  expect(result.ok).toBe(true);

  // A later platform module adds its own target marker, so this case reads the Naver items out of
  // the shared set; the identifier list, its order and its length are unchanged.
  const naverEn = conditionalItemsForTarget(en, "naver");
  const naverKo = conditionalItemsForTarget(ko, "naver");
  expect(naverEn.map((item) => item.id)).toEqual(NAVER_CONDITIONAL_IDS);
  expect(naverKo.map((item) => item.id)).toEqual(NAVER_CONDITIONAL_IDS);
  expect(naverEn.map((item) => item.target)).toEqual(NAVER_CONDITIONAL_IDS.map(() => "naver"));
  expect(naverKo.map((item) => item.target)).toEqual(NAVER_CONDITIONAL_IDS.map(() => "naver"));

  // Every Naver item lives in the platform-policy Naver block, not scattered elsewhere.
  expect(naverEn.every((item) => item.section.endsWith(NAVER_SECTION_EN))).toBe(true);
  expect(naverKo.every((item) => item.section.endsWith(NAVER_SECTION_KO))).toBe(true);
  expect(checklistIds(itemsOfSection(en, NAVER_SECTION_EN))).toEqual(NAVER_CONDITIONAL_IDS);
  expect(checklistIds(itemsOfSection(ko, NAVER_SECTION_KO))).toEqual(NAVER_CONDITIONAL_IDS);
});

test("seo checklist conditional ids carry no third-party ranking-algorithm claim", () => {
  expect(rankingAlgorithmIds(readDoc(CHECKLIST_EN))).toEqual([]);
  expect(rankingAlgorithmIds(readDoc(CHECKLIST_KO))).toEqual([]);

  // The detector is not vacuous: an injected C-Rank identifier is reported.
  const copy = tempCopy(CHECKLIST_EN);
  try {
    const target = join(copy.root, CHECKLIST_EN);
    const lines = readFileSync(target, "utf8").split("\n");
    const index = lines.findIndex((line) => line.includes("(target: naver)"));
    expect(index).toBeGreaterThan(-1);
    lines[index] = lines[index].replace(/`[^`]+`/, "`C-Rank score`");
    writeFileSync(target, lines.join("\n"));

    expect(rankingAlgorithmIds(readDoc(CHECKLIST_EN, copy.root))).toEqual(["C-Rank score"]);
  } finally {
    copy.cleanup();
  }
});

test("parser detects a conditional target marker changed or removed in one language variant", () => {
  const en = readDoc(CHECKLIST_EN);
  const ko = readDoc(CHECKLIST_KO);
  expect(compareConditionalItems(en, ko).ok).toBe(true);

  const copy = tempCopy(CHECKLIST_KO);
  try {
    const target = join(copy.root, CHECKLIST_KO);
    const lines = readFileSync(target, "utf8").split("\n");
    const index = lines.findIndex((line) => line.includes("(target: naver)"));
    expect(index).toBeGreaterThan(-1);

    // A marker value changed in one language is a target mismatch, not a silent pass.
    lines[index] = lines[index].replace("(target: naver)", "(target: bing)");
    writeFileSync(target, lines.join("\n"));
    const retargeted = compareConditionalItems(en, readDoc(CHECKLIST_KO, copy.root));
    expect(retargeted.ok).toBe(false);
    expect(retargeted.en[0].target).toBe("naver");
    expect(retargeted.ko[0].target).toBe("bing");
    expect(retargeted.mismatches).toContain("conditional item 0 (Yeti): target en=naver ko=bing");

    // A marker removed entirely drops the item from the conditional set in that language only.
    lines[index] = lines[index].replace(" (target: bing)", "");
    writeFileSync(target, lines.join("\n"));
    const dropped = compareConditionalItems(en, readDoc(CHECKLIST_KO, copy.root));
    expect(dropped.ok).toBe(false);
    expect(dropped.en.map((item) => item.id)[0]).toBe("Yeti");
    expect(dropped.ko.map((item) => item.id)[0]).toBe("robots.txt");
    // The expected pair is read from the parsed document, so adding another platform module does
    // not invalidate this case while the reported counts stay pinned to the real ones.
    expect(dropped.mismatches).toContain(`conditional item count: en=${dropped.en.length} ko=${dropped.ko.length}`);
    expect(dropped.en.length - dropped.ko.length).toBe(1);
    expect(dropped.mismatches).toContain("conditional item 0: id en=Yeti ko=robots.txt");

    // The repository copy was never mutated.
    expect(compareConditionalItems(en, ko).ok).toBe(true);
  } finally {
    copy.cleanup();
  }
});

/** Section path of the conditional Bing/IndexNow platform-policy block, one per language variant. */
const BING_SECTION_EN = "Platform Policy Checklist > Bing (IndexNow & Webmaster Tools)";
const BING_SECTION_KO = "플랫폼 정책 체크리스트 > Bing(IndexNow·웹마스터 도구)";

/**
 * The Bing/IndexNow-only audit items, identified by their first backticked token. Each carries the
 * language-independent `(target: bing)` marker, so both language variants must declare the same
 * identifiers under the same target condition in the same order.
 */
const BING_CONDITIONAL_IDS = [
  "IndexNow",
  "key file",
  "urlList",
  "429",
  "crawl quota",
  "backfill submissions",
  "changefreq",
  "Bing Webmaster Tools",
];

test("seo checklist declares the same conditional Bing and IndexNow items in English and Korean", () => {
  const en = readDoc(CHECKLIST_EN);
  const ko = readDoc(CHECKLIST_KO);

  const result = compareConditionalItems(en, ko);
  expect(result.mismatches).toEqual([]);
  expect(result.ok).toBe(true);

  const bingEn = conditionalItemsForTarget(en, "bing");
  const bingKo = conditionalItemsForTarget(ko, "bing");
  expect(bingEn.map((item) => item.id)).toEqual(BING_CONDITIONAL_IDS);
  expect(bingKo.map((item) => item.id)).toEqual(BING_CONDITIONAL_IDS);
  expect(bingEn.map((item) => item.target)).toEqual(BING_CONDITIONAL_IDS.map(() => "bing"));
  expect(bingKo.map((item) => item.target)).toEqual(BING_CONDITIONAL_IDS.map(() => "bing"));

  // Every Bing item lives in the platform-policy Bing block, not scattered elsewhere.
  expect(bingEn.every((item) => item.section.endsWith(BING_SECTION_EN))).toBe(true);
  expect(bingKo.every((item) => item.section.endsWith(BING_SECTION_KO))).toBe(true);
  expect(checklistIds(itemsOfSection(en, BING_SECTION_EN))).toEqual(BING_CONDITIONAL_IDS);
  expect(checklistIds(itemsOfSection(ko, BING_SECTION_KO))).toEqual(BING_CONDITIONAL_IDS);

  // No third-party ranking-algorithm claim leaks in with the platform module.
  expect(rankingAlgorithmIds(en)).toEqual([]);
  expect(rankingAlgorithmIds(ko)).toEqual([]);
});

test("parser detects a Bing target marker removed from one language variant", () => {
  const en = readDoc(CHECKLIST_EN);
  const ko = readDoc(CHECKLIST_KO);
  expect(compareConditionalItems(en, ko).ok).toBe(true);
  const total = conditionalItems(en).length;
  const bingStart = total - BING_CONDITIONAL_IDS.length;

  const copy = tempCopy(CHECKLIST_KO);
  try {
    const target = join(copy.root, CHECKLIST_KO);
    const lines = readFileSync(target, "utf8").split("\n");
    const index = lines.findIndex((line) => line.includes("(target: bing)"));
    expect(index).toBeGreaterThan(-1);
    lines[index] = lines[index].replace(" (target: bing)", "");
    writeFileSync(target, lines.join("\n"));

    const dropped = compareConditionalItems(en, readDoc(CHECKLIST_KO, copy.root));
    expect(dropped.ok).toBe(false);
    expect(dropped.mismatches).toContain(`conditional item count: en=${total} ko=${total - 1}`);
    expect(dropped.mismatches).toContain(`conditional item ${bingStart}: id en=IndexNow ko=key file`);
    expect(conditionalItemsForTarget(readDoc(CHECKLIST_KO, copy.root), "bing").length).toBe(BING_CONDITIONAL_IDS.length - 1);

    // The repository copy was never mutated.
    expect(compareConditionalItems(en, ko).ok).toBe(true);
  } finally {
    copy.cleanup();
  }
});
