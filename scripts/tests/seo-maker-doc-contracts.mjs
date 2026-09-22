// @ts-check

/**
 * Shared document-contract parser for the seo-maker rule docs.
 *
 * Importable from tests and plain scripts alike; it never registers a test.
 * Every helper takes a repository root path and defaults to this repository, so a
 * negative control can point the same parser at a `mkdtemp` copy instead of
 * mutating repository files.
 *
 * The parser reads structure, not prose: checkbox items, headings, and table cells.
 * Checklist items are matched across languages by position and by their first
 * backticked identifier, never by sentence text.
 */
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

export const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../..");

export const VALIDATION_EN = "skills/seo-maker/rules/validation.md";
export const VALIDATION_KO = "skills/seo-maker/rules/validation.ko.md";
export const WORKFLOW_EN = "skills/seo-maker/rules/seo-workflow.md";
export const WORKFLOW_KO = "skills/seo-maker/rules/seo-workflow.ko.md";
export const REPORT_TEMPLATE_EN = "skills/seo-maker/assets/report.template.md";
export const REPORT_TEMPLATE_KO = "skills/seo-maker/assets/report.template.ko.md";
export const CHECKLIST_EN = "skills/seo-maker/references/seo-checklist.md";
export const CHECKLIST_KO = "skills/seo-maker/references/seo-checklist.ko.md";
export const AEO_GEO_EN = "skills/seo-maker/references/aeo-geo-guide.md";
export const AEO_GEO_KO = "skills/seo-maker/references/aeo-geo-guide.ko.md";

/**
 * Marker appended to checklist items whose fixed number is a heuristic, not an
 * official requirement. The literal is language-independent on purpose: it is the
 * only cross-language handle for "this threshold is not a pass/fail rule".
 */
export const HEURISTIC_MARKER = "(heuristic)";

export const HEADING = /^(#{1,6})\s+(.*)$/;
export const CHECKBOX = /^\s*[-*]\s*\[([ xX])\]\s+(.*)$/;
export const TABLE_ROW = /^\s*\|(.*)\|\s*$/;
export const TABLE_DIVIDER = /^\s*\|[\s:|-]+\|\s*$/;

/**
 * @param {string} [root] repository root; defaults to this repository
 * @returns {string} absolute root path
 */
export function resolveRoot(root) {
  return resolve(root ?? REPO_ROOT);
}

/**
 * @param {string} relPath path relative to the root
 * @param {string} [root] repository root; defaults to this repository
 * @returns {string} file contents
 */
export function readDoc(relPath, root) {
  return readFileSync(join(resolveRoot(root), relPath), "utf8");
}

/**
 * First backticked token of a checklist item, or `null` when the item has none.
 * This is the cross-language item identifier.
 *
 * @param {string} text checklist item text
 * @returns {string | null} identifier
 */
export function itemId(text) {
  const match = /`([^`]+)`/.exec(text);
  return match ? match[1] : null;
}

/**
 * @typedef {{ level: number, title: string, path: string }} Heading
 * @typedef {{ checked: boolean, text: string, id: string | null, section: string }} ChecklistItem
 * @typedef {{ section: string, header: string[], rows: string[][] }} Table
 * @typedef {{ headings: Heading[], items: ChecklistItem[], tables: Table[] }} ParsedDoc
 */

/**
 * Parse checkbox items, headings, and tables out of one markdown document.
 *
 * @param {string} markdown document text
 * @returns {ParsedDoc} parsed structure
 */
export function parseDoc(markdown) {
  /** @type {Heading[]} */
  const headings = [];
  /** @type {ChecklistItem[]} */
  const items = [];
  /** @type {Table[]} */
  const tables = [];
  /** @type {string[]} */
  const stack = [];
  /** @type {Table | null} */
  let table = null;

  const sectionOf = () => stack.filter(Boolean).join(" > ");

  for (const line of markdown.split(/\r?\n/)) {
    const heading = HEADING.exec(line);
    if (heading) {
      table = null;
      const level = heading[1].length;
      const title = heading[2].trim();
      stack.length = level - 1;
      stack[level - 1] = title;
      headings.push({ level, title, path: sectionOf() });
      continue;
    }

    if (TABLE_ROW.test(line)) {
      if (TABLE_DIVIDER.test(line)) continue;
      const cells = /** @type {RegExpExecArray} */ (TABLE_ROW.exec(line))[1].split("|").map((cell) => cell.trim());
      if (table) table.rows.push(cells);
      else {
        table = { section: sectionOf(), header: cells, rows: [] };
        tables.push(table);
      }
      continue;
    }

    if (line.trim() === "") continue;
    table = null;

    const item = CHECKBOX.exec(line);
    if (item) {
      items.push({
        checked: item[1].toLowerCase() === "x",
        text: item[2].trim(),
        id: itemId(item[2]),
        section: sectionOf(),
      });
    }
  }

  return { headings, items, tables };
}

/**
 * @typedef {{ index: number, section: string, items: ChecklistItem[] }} ChecklistSection
 */

/**
 * Checklist sections in document order. Section titles are translated, so callers
 * compare two language files positionally rather than by title.
 *
 * @param {string} markdown document text
 * @returns {ChecklistSection[]} checklist sections
 */
export function checklistSections(markdown) {
  /** @type {ChecklistSection[]} */
  const sections = [];
  for (const item of parseDoc(markdown).items) {
    const last = sections[sections.length - 1];
    if (last && last.section === item.section) last.items.push(item);
    else sections.push({ index: sections.length, section: item.section, items: [item] });
  }
  return sections;
}

/**
 * @param {ChecklistItem[]} items checklist items
 * @returns {(string | null)[]} identifiers in item order
 */
export function checklistIds(items) {
  return items.map((item) => item.id);
}

/**
 * Document-order indices of the checklist items carrying the heuristic marker.
 *
 * @param {string} markdown document text
 * @returns {number[]} item indices
 */
export function heuristicItemIndices(markdown) {
  return parseDoc(markdown)
    .items.map((item, index) => (item.text.includes(HEURISTIC_MARKER) ? index : -1))
    .filter((index) => index >= 0);
}

/**
 * Compare the heuristic markers of two language variants of one checklist.
 * The marker set must match in count and in item position.
 *
 * @param {string} enMarkdown English document
 * @param {string} koMarkdown Korean document
 * @returns {{ ok: boolean, mismatches: string[], en: number[], ko: number[] }} comparison result
 */
export function compareHeuristicMarkers(enMarkdown, koMarkdown) {
  const en = heuristicItemIndices(enMarkdown);
  const ko = heuristicItemIndices(koMarkdown);
  /** @type {string[]} */
  const mismatches = [];
  if (en.length !== ko.length) mismatches.push(`heuristic count: en=${en.length} ko=${ko.length}`);
  const width = Math.max(en.length, ko.length);
  for (let i = 0; i < width; i += 1) {
    if (en[i] !== ko[i]) mismatches.push(`heuristic ${i}: index en=${en[i] ?? "<missing>"} ko=${ko[i] ?? "<missing>"}`);
  }
  return { ok: mismatches.length === 0, mismatches, en, ko };
}

/**
 * Compare two language variants of one checklist section.
 *
 * @param {ChecklistItem[]} enItems English items
 * @param {ChecklistItem[]} koItems Korean items
 * @returns {{ ok: boolean, mismatches: string[] }} comparison result
 */
export function compareChecklists(enItems, koItems) {
  /** @type {string[]} */
  const mismatches = [];
  if (enItems.length !== koItems.length) {
    mismatches.push(`item count: en=${enItems.length} ko=${koItems.length}`);
  }
  const enIds = checklistIds(enItems);
  const koIds = checklistIds(koItems);
  const width = Math.max(enIds.length, koIds.length);
  for (let i = 0; i < width; i += 1) {
    const en = enIds[i] ?? "<missing>";
    const ko = koIds[i] ?? "<missing>";
    if (en !== ko) mismatches.push(`item ${i}: id en=${en} ko=${ko}`);
  }
  return { ok: mismatches.length === 0, mismatches };
}

/**
 * Positional comparison of every checklist section in two language files.
 *
 * @param {string} enMarkdown English document
 * @param {string} koMarkdown Korean document
 * @returns {{ ok: boolean, mismatches: string[] }} comparison result
 */
export function compareChecklistFiles(enMarkdown, koMarkdown) {
  const en = checklistSections(enMarkdown);
  const ko = checklistSections(koMarkdown);
  /** @type {string[]} */
  const mismatches = [];
  if (en.length !== ko.length) mismatches.push(`section count: en=${en.length} ko=${ko.length}`);
  for (let i = 0; i < Math.min(en.length, ko.length); i += 1) {
    const result = compareChecklists(en[i].items, ko[i].items);
    mismatches.push(...result.mismatches.map((line) => `section ${i} (${en[i].section}): ${line}`));
  }
  return { ok: mismatches.length === 0, mismatches };
}

/**
 * Copy one repository file into a fresh temp root, for negative controls that must
 * not mutate the repository.
 *
 * @param {string} relPath path relative to the root
 * @returns {{ root: string, cleanup: () => void }} temp root holding the copied file
 */
export function tempCopy(relPath) {
  const root = mkdtempSync(join(tmpdir(), "seo-maker-doc-contracts-"));
  const target = join(root, relPath);
  mkdirSync(dirname(target), { recursive: true });
  cpSync(join(REPO_ROOT, relPath), target);
  return { root, cleanup: () => rmSync(root, { recursive: true, force: true }) };
}

/**
 * Column identity of the report template tables, keyed by header cell. The English and Korean
 * display labels and the raw `results.json` field tokens all resolve to one identity, so a
 * column survives translation while a second spelling of the same field stays visible.
 *
 * The null prototype keeps a cell named after an `Object.prototype` member from resolving.
 *
 * @type {Record<string, string>}
 */
export const REPORT_COLUMN_FIELDS = Object.assign(Object.create(null), {
  "#": "#",
  Category: "category",
  "카테고리": "category",
  Score: "score",
  "점수": "score",
  Status: "status",
  "상태": "status",
  Method: "measurement_method",
  "방법": "measurement_method",
  measurement_method: "measurement_method",
  "Evidence Grade": "evidence_grade",
  "증거 등급": "evidence_grade",
  evidence_grade: "evidence_grade",
  Confidence: "confidence",
  "신뢰도": "confidence",
  confidence: "confidence",
  "Confidence Impact": "confidence_impact",
  "신뢰도 영향": "confidence_impact",
  Notes: "notes",
  "메모": "notes",
  Finding: "finding",
  "발견사항": "finding",
  Location: "location",
  "위치": "location",
  "Source Tier": "source_tier",
  "출처 계층": "source_tier",
  source_tier: "source_tier",
  Recommendation: "recommendation",
  "권장사항": "recommendation",
  Dimension: "dimension",
  "차원": "dimension",
  "Platform/Bot": "platform",
  "플랫폼/봇": "platform",
  Purpose: "purpose",
  "목적": "purpose",
  Priority: "priority",
  "우선순위": "priority",
  Action: "action",
  "작업": "action",
  Impact: "impact",
  "영향": "impact",
  Effort: "effort",
  "노력": "effort",
  Date: "date",
  "날짜": "date",
  Changes: "changes",
  "변경사항": "changes",
});

/**
 * @param {string} cell header cell text
 * @returns {string | null} field id, or `null` when the cell names no known column
 */
export function columnField(cell) {
  return cell in REPORT_COLUMN_FIELDS ? REPORT_COLUMN_FIELDS[cell] : null;
}

/**
 * @param {string[]} header header cells
 * @returns {(string | null)[]} field id per cell
 */
export function reportColumns(header) {
  return header.map(columnField);
}

/**
 * @param {string[]} header header cells
 * @returns {string[]} cells naming no known column
 */
export function unknownReportColumns(header) {
  return header.filter((cell) => columnField(cell) === null);
}

/**
 * Fields that one template spells more than one way across its tables. Two header labels for
 * one field is the mismatch this parser exists to catch.
 *
 * @param {string} markdown document text
 * @returns {string[]} one line per field with conflicting labels
 */
export function reportColumnConflicts(markdown) {
  /** @type {Map<string, Set<string>>} */
  const labels = new Map();
  for (const table of parseDoc(markdown).tables) {
    for (const cell of table.header) {
      const field = columnField(cell);
      if (field === null) continue;
      const seen = labels.get(field) ?? new Set();
      seen.add(cell);
      labels.set(field, seen);
    }
  }
  /** @type {string[]} */
  const conflicts = [];
  for (const [field, seen] of labels) {
    if (seen.size > 1) conflicts.push(`${field}: ${[...seen].sort().join(" | ")}`);
  }
  return conflicts;
}

/**
 * Compare the table structure of two language variants of one report template.
/**
 * Heading structure of two language variants of one reference document. Titles are translated,
 * so the comparison is positional: the same heading count in the same level order. A section
 * added to one language only shifts the sequence and is reported as a mismatch.
 *
 * @param {string} enMarkdown English document
 * @param {string} koMarkdown Korean document
 * @returns {{ ok: boolean, mismatches: string[], en: Heading[], ko: Heading[] }} comparison result
 */
export function compareHeadingStructure(enMarkdown, koMarkdown) {
  const en = parseDoc(enMarkdown).headings;
  const ko = parseDoc(koMarkdown).headings;
  /** @type {string[]} */
  const mismatches = [];
  if (en.length !== ko.length) mismatches.push(`heading count: en=${en.length} ko=${ko.length}`);
  const enLevels = en.map((heading) => heading.level);
  const koLevels = ko.map((heading) => heading.level);
  if (JSON.stringify(enLevels) !== JSON.stringify(koLevels)) {
    mismatches.push(`heading levels: en=${JSON.stringify(enLevels)} ko=${JSON.stringify(koLevels)}`);
  }
  return { ok: mismatches.length === 0, mismatches, en, ko };
}

/**
 * Document-order position of the first heading with an exact title, or `null` when the
 * document has no such heading. Callers use it to require one section at the same position
 * in both language variants.
 *
 * @param {string} markdown document text
 * @param {string} title exact heading title
 * @returns {{ index: number, level: number } | null} position, or `null`
 */
export function headingPosition(markdown, title) {
  const headings = parseDoc(markdown).headings;
  const index = headings.findIndex((heading) => heading.title === title);
  return index < 0 ? null : { index, level: headings[index].level };
}

/**
 * Column headers of a reference-document source ledger. Both language variants of a guide use
 * these labels, and the Source and Accessed cells hold language-independent values (a URL and an
 * ISO date), which is what makes two translated ledgers comparable cell by cell.
 */
export const LEDGER_HEADER = ["Source", "Accessed", "Supports", "Caveat"];

/**
 * @typedef {{ source: string, accessed: string, supports: string, caveat: string }} LedgerRow
 * @typedef {{ header: string[], rows: LedgerRow[] }} SourceLedger
 */

/**
 * The source ledger of a reference document: the first table carrying every ledger column.
 *
 * @param {string} markdown document text
 * @returns {SourceLedger | null} ledger, or `null` when the document has no ledger table
 */
export function sourceLedger(markdown) {
  const table = parseDoc(markdown).tables.find((entry) => LEDGER_HEADER.every((cell) => entry.header.includes(cell)));
  if (!table) return null;
  /** @type {(cell: string) => number} */
  const column = (cell) => table.header.indexOf(cell);
  const cellOf = (/** @type {string[]} */ row, /** @type {string} */ cell) => row[column(cell)] ?? "";
  return {
    header: table.header,
    rows: table.rows.map((row) => ({
      source: cellOf(row, "Source"),
      accessed: cellOf(row, "Accessed"),
      supports: cellOf(row, "Supports"),
      caveat: cellOf(row, "Caveat"),
    })),
  };
}

/** Bold metadata labels that carry a document's verification date, one per language variant. */
export const LAST_VERIFIED_LABEL = "(?:Last verified|최종 확인)";

/**
 * The verification date a reference document declares in its header metadata, or `null`.
 *
 * @param {string} markdown document text
 * @returns {string | null} ISO date, or `null`
 */
export function lastVerified(markdown) {
  const match = new RegExp(`\\*\\*${LAST_VERIFIED_LABEL}\\*\\*:\\s*(\\d{4}-\\d{2}-\\d{2})`).exec(markdown);
  return match ? match[1] : null;
}

/**
 * Compare the table structure of two language variants of one report template.
 *
 * @param {string} enMarkdown English template
 * @param {string} koMarkdown Korean template
 * @returns {{ ok: boolean, mismatches: string[] }} comparison result
 */
export function compareReportTemplates(enMarkdown, koMarkdown) {
  const en = parseDoc(enMarkdown).tables;
  const ko = parseDoc(koMarkdown).tables;
  /** @type {string[]} */
  const mismatches = [];
  if (en.length !== ko.length) mismatches.push(`table count: en=${en.length} ko=${ko.length}`);
  for (let i = 0; i < Math.min(en.length, ko.length); i += 1) {
    const where = `table ${i} (${en[i].section})`;
    if (en[i].header.length !== ko[i].header.length) {
      mismatches.push(`${where}: column count en=${en[i].header.length} ko=${ko[i].header.length}`);
      continue;
    }
    const enUnknown = unknownReportColumns(en[i].header);
    if (enUnknown.length) mismatches.push(`${where}: unknown en header cells ${JSON.stringify(enUnknown)}`);
    const koUnknown = unknownReportColumns(ko[i].header);
    if (koUnknown.length) mismatches.push(`${where}: unknown ko header cells ${JSON.stringify(koUnknown)}`);
    const enFields = reportColumns(en[i].header);
    const koFields = reportColumns(ko[i].header);
    if (JSON.stringify(enFields) !== JSON.stringify(koFields)) {
      mismatches.push(`${where}: columns en=${JSON.stringify(enFields)} ko=${JSON.stringify(koFields)}`);
    }
  }
  return { ok: mismatches.length === 0, mismatches };
}

/**
 * Marker carrying the target condition of a conditional checklist item: the platform or surface
 * the item applies to. The literal is language-independent on purpose — it is the only
 * cross-language handle for "this item applies only when the audited target set includes this
 * platform" — and it is never backticked, so `itemId` keeps resolving the item's own identifier.
 * An item without the marker is unconditional.
 */
export const TARGET_MARKER = /\(target:\s*([a-z0-9][a-z0-9 /,_-]*)\)/i;

/**
 * Target condition declared by a checklist item, or `null` when the item is unconditional.
 *
 * @param {string} text checklist item text
 * @returns {string | null} normalized target condition, or `null`
 */
export function targetCondition(text) {
  const match = TARGET_MARKER.exec(text);
  return match ? match[1].trim().toLowerCase().replace(/\s+/g, " ") : null;
}

/**
 * @typedef {{ index: number, section: string, id: string | null, target: string }} ConditionalItem
 */

/**
 * Conditional checklist items in document order: the items declaring a target condition.
 *
 * @param {string} markdown document text
 * @returns {ConditionalItem[]} conditional items
 */
export function conditionalItems(markdown) {
  /** @type {ConditionalItem[]} */
  const items = [];
  parseDoc(markdown).items.forEach((item, index) => {
    const target = targetCondition(item.text);
    if (target !== null) items.push({ index, section: item.section, id: item.id, target });
  });
  return items;
}

/**
 * Compare the conditional items of two language variants of one checklist. Item order, the
 * cross-language item identifier, and the target condition must all match positionally, so a
 * target marker dropped from one language — or an item that applies to a different platform in
 * one language — is reported instead of silently passing.
 *
 * @param {string} enMarkdown English document
 * @param {string} koMarkdown Korean document
 * @returns {{ ok: boolean, mismatches: string[], en: ConditionalItem[], ko: ConditionalItem[] }} comparison result
 */
export function compareConditionalItems(enMarkdown, koMarkdown) {
  const en = conditionalItems(enMarkdown);
  const ko = conditionalItems(koMarkdown);
  /** @type {string[]} */
  const mismatches = [];
  if (en.length !== ko.length) mismatches.push(`conditional item count: en=${en.length} ko=${ko.length}`);
  const width = Math.max(en.length, ko.length);
  for (let i = 0; i < width; i += 1) {
    const a = en[i];
    const b = ko[i];
    if (!a || !b) {
      mismatches.push(`conditional item ${i}: en=${a ? a.id : "<missing>"} ko=${b ? b.id : "<missing>"}`);
      continue;
    }
    if (a.id !== b.id) mismatches.push(`conditional item ${i}: id en=${a.id} ko=${b.id}`);
    if (a.target !== b.target) mismatches.push(`conditional item ${i} (${a.id}): target en=${a.target} ko=${b.target}`);
  }
  return { ok: mismatches.length === 0, mismatches, en, ko };
}

/**
 * Conditional checklist items declaring one target condition, in document order.
 *
 * @param {string} markdown document text
 * @param {string} target target condition, matched case-insensitively
 * @returns {ConditionalItem[]} matching conditional items
 */
export function conditionalItemsForTarget(markdown, target) {
  const wanted = target.trim().toLowerCase();
  return conditionalItems(markdown).filter((item) => item.target === wanted);
}

/**
 * Third-party ranking-algorithm commentary that no official source documents, so it can never
 * become an audit item identifier: C-Rank, D.I.A., and smart block are blog-level claims, not
 * platform requirements.
 */
export const RANKING_ALGORITHM_PATTERNS = [
  /\bc[-\s]?rank\b/i,
  /\bd\.i\.a\.?\b/i,
  /\bsmart\s?block\b/i,
  /스마트\s?블록/,
];

/**
 * Item identifiers that name a third-party ranking-algorithm claim.
 *
 * @param {string} markdown document text
 * @returns {string[]} offending identifiers, in item order
 */
export function rankingAlgorithmIds(markdown) {
  /** @type {string[]} */
  const ids = [];
  for (const item of parseDoc(markdown).items) {
    const id = item.id;
    if (id === null) continue;
    if (RANKING_ALGORITHM_PATTERNS.some((pattern) => pattern.test(id))) ids.push(id);
  }
  return ids;
}
