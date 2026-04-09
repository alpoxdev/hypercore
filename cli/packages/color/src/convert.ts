import { parse, formatHex, formatHex8, formatRgb, toGamut, inGamut, converter } from 'culori';

export interface ConvertResult {
  hex: string;
  rgb: string;
  oklch: string;
  originalFormat: string;
  gamutMapped: boolean;
  alpha?: number;
}

const toOklch = converter('oklch');

function formatOklch(color: ReturnType<typeof toOklch>, alpha?: number): string {
  if (!color) return '';
  const l = (color.l ?? 0).toFixed(4);
  const c = (color.c ?? 0).toFixed(4);
  const h = (color.h ?? 0).toFixed(2);
  if (alpha !== undefined && alpha < 1) {
    return `oklch(${l} ${c} ${h} / ${alpha})`;
  }
  return `oklch(${l} ${c} ${h})`;
}

function formatRgbIntegers(color: object, alpha?: number): string {
  const raw = formatRgb(color as Parameters<typeof formatRgb>[0]);
  // formatRgb returns e.g. "rgb(255, 128, 0)" — already integers for in-gamut colors
  // but for mapped colors we may get decimals; round them
  const rounded = raw.replace(/(\d+\.\d+)/g, (m) => String(Math.round(Number(m))));
  if (alpha !== undefined && alpha < 1) {
    // Convert "rgb(r, g, b)" to "rgba(r, g, b, alpha)"
    return rounded.replace(/^rgb\((.+)\)$/, `rgba($1, ${alpha})`);
  }
  return rounded;
}

export function convertColor(input: string): ConvertResult {
  const parsed = parse(input);
  if (!parsed) {
    throw new Error(`Unable to parse color: "${input}"`);
  }

  const originalFormat = parsed.mode;
  let gamutMapped = false;
  let working = parsed;

  const alpha = parsed.alpha !== undefined && parsed.alpha < 1 ? parsed.alpha : undefined;

  if (!inGamut('rgb')(parsed)) {
    working = toGamut('rgb', 'oklch')(parsed) as typeof parsed;
    gamutMapped = true;
  }

  const hex = alpha !== undefined ? (formatHex8(working) ?? '') : (formatHex(working) ?? '');
  const rgb = formatRgbIntegers(working, alpha);
  const oklchColor = toOklch(working);
  const oklch = formatOklch(oklchColor, alpha);

  return {
    hex,
    rgb,
    oklch,
    originalFormat,
    gamutMapped,
    ...(alpha !== undefined ? { alpha } : {}),
  };
}

export function formatAs(result: ConvertResult, format: 'hex' | 'rgb' | 'oklch'): string {
  switch (format) {
    case 'hex':
      return result.hex;
    case 'rgb':
      return result.rgb;
    case 'oklch':
      return result.oklch;
  }
}
