import type { ConvertResult } from './convert.js';
import type { CssConvertResult } from './css.js';

export function formatOutput(result: ConvertResult): string {
  const lines: string[] = [
    `HEX:   ${result.hex}`,
    `RGB:   ${result.rgb}`,
    `OKLCH: ${result.oklch}`,
  ];

  if (result.gamutMapped) {
    lines.push('');
    lines.push('⚠ Color was outside sRGB gamut — CSS Color Level 4 chroma-reduction applied.');
  }

  return lines.join('\n');
}

export function formatJson(result: ConvertResult): string {
  return JSON.stringify(result, null, 2);
}

export function formatCssResult(
  filename: string,
  summary: CssConvertResult,
  dryRun: boolean,
): string {
  const lines: string[] = [];
  lines.push(
    `${filename}: ${summary.total} colors found, ${summary.converted} converted, ${summary.skipped} skipped`,
  );

  if (summary.changes.length > 0) {
    lines.push('');
    for (const change of summary.changes) {
      lines.push(`  L${change.line}:  ${change.from} → ${change.to}`);
    }
    lines.push('');
  }

  lines.push(dryRun ? 'Dry run — no files modified.' : 'Done. File updated.');

  return lines.join('\n');
}
