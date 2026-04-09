import { parse } from 'culori';
import { convertColor, formatAs } from './convert.js';

export interface CssColorMatch {
  original: string;
  start: number;
  end: number;
  format: string;
}

export interface CssConvertResult {
  converted: number;
  skipped: number;
  total: number;
  changes: Array<{ line: number; from: string; to: string }>;
}

function findCommentRanges(css: string): Array<{ start: number; end: number }> {
  const ranges: Array<{ start: number; end: number }> = [];
  const commentRe = /\/\*[\s\S]*?\*\//g;
  let m: RegExpExecArray | null;
  while ((m = commentRe.exec(css)) !== null) {
    ranges.push({ start: m.index, end: m.index + m[0].length });
  }
  return ranges;
}

function isInComment(index: number, ranges: Array<{ start: number; end: number }>): boolean {
  return ranges.some((r) => index >= r.start && index < r.end);
}

function detectFormat(color: string): 'hex' | 'rgb' | 'oklch' | null {
  if (/^#[0-9a-fA-F]{3,8}$/.test(color)) return 'hex';
  if (/^rgba?\s*\(/i.test(color)) return 'rgb';
  if (/^oklch\s*\(/i.test(color)) return 'oklch';
  return null;
}

export function findCssColors(css: string): CssColorMatch[] {
  const commentRanges = findCommentRanges(css);
  const matches: CssColorMatch[] = [];

  const patterns = [
    { re: /#[0-9a-fA-F]{3,8}\b/g, format: 'hex' },
    { re: /rgba?\([^)]+\)/g, format: 'rgb' },
    { re: /oklch\([^)]+\)/g, format: 'oklch' },
  ];

  for (const { re } of patterns) {
    let m: RegExpExecArray | null;
    re.lastIndex = 0;
    while ((m = re.exec(css)) !== null) {
      if (isInComment(m.index, commentRanges)) continue;
      const original = m[0];
      if (!parse(original)) continue;
      const fmt = detectFormat(original);
      if (!fmt) continue;
      matches.push({ original, start: m.index, end: m.index + original.length, format: fmt });
    }
  }

  // Sort by start position, deduplicate overlapping matches
  matches.sort((a, b) => a.start - b.start);
  const deduped: CssColorMatch[] = [];
  let lastEnd = -1;
  for (const match of matches) {
    if (match.start >= lastEnd) {
      deduped.push(match);
      lastEnd = match.end;
    }
  }

  return deduped;
}

function lineNumberAt(css: string, offset: number): number {
  let line = 1;
  for (let i = 0; i < offset && i < css.length; i++) {
    if (css[i] === '\n') line++;
  }
  return line;
}

export function replaceCssColors(
  css: string,
  targetFormat: 'hex' | 'rgb' | 'oklch',
): { result: string; summary: CssConvertResult } {
  const colorMatches = findCssColors(css);
  const summary: CssConvertResult = {
    converted: 0,
    skipped: 0,
    total: colorMatches.length,
    changes: [],
  };

  // Process in reverse order to preserve offsets
  const toReplace: Array<{ match: CssColorMatch; replacement: string }> = [];

  for (const match of colorMatches) {
    if (match.format === targetFormat) {
      summary.skipped++;
      continue;
    }
    try {
      const converted = convertColor(match.original);
      const replacement = formatAs(converted, targetFormat);
      toReplace.push({ match, replacement });
    } catch {
      summary.skipped++;
    }
  }

  // Calculate line numbers before replacing (offsets still valid)
  for (const { match, replacement } of toReplace) {
    summary.changes.push({
      line: lineNumberAt(css, match.start),
      from: match.original,
      to: replacement,
    });
    summary.converted++;
  }

  // Apply replacements from end to start
  let result = css;
  for (let i = toReplace.length - 1; i >= 0; i--) {
    const { match, replacement } = toReplace[i];
    result = result.slice(0, match.start) + replacement + result.slice(match.end);
  }

  return { result, summary };
}
