import { describe, it, expect } from 'vitest';
import { convertColor } from './convert.js';

function hexToRgb(hex: string): { r: number; g: number; b: number } {
  const m = /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(hex);
  if (!m) throw new Error(`Bad hex: ${hex}`);
  return { r: parseInt(m[1], 16), g: parseInt(m[2], 16), b: parseInt(m[3], 16) };
}

function rgbClose(hex: string, expected: { r: number; g: number; b: number }, tol = 1) {
  const actual = hexToRgb(hex);
  expect(Math.abs(actual.r - expected.r)).toBeLessThanOrEqual(tol);
  expect(Math.abs(actual.g - expected.g)).toBeLessThanOrEqual(tol);
  expect(Math.abs(actual.b - expected.b)).toBeLessThanOrEqual(tol);
}

describe('convertColor', () => {
  it('black: oklch(0, 0, 0) → #000000', () => {
    const r = convertColor('oklch(0 0 0)');
    rgbClose(r.hex, { r: 0, g: 0, b: 0 });
  });

  it('white: oklch(1, 0, 0) → #ffffff', () => {
    const r = convertColor('oklch(1 0 0)');
    rgbClose(r.hex, { r: 255, g: 255, b: 255 });
  });

  it('red: oklch(0.6279 0.2576 29.23) → #ff0000', () => {
    const r = convertColor('oklch(0.6279 0.2576 29.23)');
    rgbClose(r.hex, { r: 255, g: 0, b: 0 });
  });

  it('green: oklch(0.8664 0.2948 142.5) → #00ff00', () => {
    const r = convertColor('oklch(0.8664 0.2948 142.5)');
    rgbClose(r.hex, { r: 0, g: 255, b: 0 });
  });

  it('blue: oklch(0.4520 0.3131 264.1) → #0000ff', () => {
    const r = convertColor('oklch(0.4520 0.3131 264.1)');
    rgbClose(r.hex, { r: 0, g: 0, b: 255 });
  });

  it('round-trip: hex → oklch → hex', () => {
    const first = convertColor('#e63946');
    const second = convertColor(first.oklch);
    const orig = hexToRgb('#e63946');
    rgbClose(second.hex, orig, 2);
  });

  it('gamut mapping: out-of-gamut oklch should set gamutMapped=true', () => {
    const r = convertColor('oklch(0.7 0.35 200)');
    expect(r.gamutMapped).toBe(true);
    // result should still produce a valid hex
    expect(r.hex).toMatch(/^#[0-9a-f]{6}$/i);
  });

  it('achromatic: oklch(0.5 0 0) → neutral gray (r ≈ g ≈ b)', () => {
    const r = convertColor('oklch(0.5 0 0)');
    const { r: rv, g, b } = hexToRgb(r.hex);
    expect(Math.abs(rv - g)).toBeLessThanOrEqual(2);
    expect(Math.abs(g - b)).toBeLessThanOrEqual(2);
  });

  it('auto-detect hex input: originalFormat indicates hex/rgb', () => {
    const r = convertColor('#e63946');
    expect(['rgb', 'hex']).toContain(r.originalFormat);
  });

  it('auto-detect rgb input: rgb(255, 0, 0) works', () => {
    const r = convertColor('rgb(255, 0, 0)');
    rgbClose(r.hex, { r: 255, g: 0, b: 0 });
  });

  it('error handling: invalid input throws', () => {
    expect(() => convertColor('not-a-color')).toThrow();
  });
});
