import { describe, it, expect } from 'vitest';
import { findCssColors, replaceCssColors } from './css.js';

describe('findCssColors', () => {
  it('finds hex colors', () => {
    const matches = findCssColors('body { color: #ff0000; }');
    expect(matches).toHaveLength(1);
    expect(matches[0].original).toBe('#ff0000');
    expect(matches[0].format).toBe('hex');
  });

  it('finds rgb colors', () => {
    const matches = findCssColors('a { color: rgb(0, 128, 255); }');
    expect(matches).toHaveLength(1);
    expect(matches[0].original).toBe('rgb(0, 128, 255)');
    expect(matches[0].format).toBe('rgb');
  });

  it('finds rgba colors', () => {
    const matches = findCssColors('a { color: rgba(255, 0, 0, 0.5); }');
    expect(matches).toHaveLength(1);
    expect(matches[0].original).toBe('rgba(255, 0, 0, 0.5)');
    expect(matches[0].format).toBe('rgb');
  });

  it('finds oklch colors', () => {
    const matches = findCssColors('p { color: oklch(0.6280 0.2577 29.23); }');
    expect(matches).toHaveLength(1);
    expect(matches[0].original).toBe('oklch(0.6280 0.2577 29.23)');
    expect(matches[0].format).toBe('oklch');
  });

  it('ignores colors inside CSS comments', () => {
    const matches = findCssColors('/* color: #ff0000 */ body { color: #00ff00; }');
    expect(matches).toHaveLength(1);
    expect(matches[0].original).toBe('#00ff00');
  });

  it('finds multiple colors across lines', () => {
    const css = `body {
  color: #ff0000;
  background: rgb(0, 128, 255);
}`;
    const matches = findCssColors(css);
    expect(matches).toHaveLength(2);
  });
});

describe('replaceCssColors', () => {
  it('converts hex to oklch', () => {
    const css = 'body { color: #ff0000; }';
    const { result, summary } = replaceCssColors(css, 'oklch');
    expect(summary.converted).toBe(1);
    expect(summary.skipped).toBe(0);
    expect(summary.total).toBe(1);
    expect(result).toContain('oklch(');
    expect(result).not.toContain('#ff0000');
  });

  it('skips colors already in target format', () => {
    const css = 'body { color: oklch(0.6280 0.2577 29.23); }';
    const { result, summary } = replaceCssColors(css, 'oklch');
    expect(summary.skipped).toBe(1);
    expect(summary.converted).toBe(0);
    expect(result).toBe(css);
  });

  it('preserves alpha when converting rgba to oklch', () => {
    const css = 'body { color: rgba(255, 0, 0, 0.5); }';
    const { result, summary } = replaceCssColors(css, 'oklch');
    expect(summary.converted).toBe(1);
    expect(result).toContain('/ 0.5');
  });

  it('converts oklch to hex', () => {
    const css = 'body { color: oklch(0.6280 0.2577 29.23); }';
    const { result, summary } = replaceCssColors(css, 'hex');
    expect(summary.converted).toBe(1);
    expect(result).toMatch(/#[0-9a-fA-F]{6}/);
    expect(result).not.toContain('oklch(');
  });

  it('records line numbers in changes', () => {
    const css = `body {
  color: #ff0000;
}`;
    const { summary } = replaceCssColors(css, 'oklch');
    expect(summary.changes[0].line).toBe(2);
    expect(summary.changes[0].from).toBe('#ff0000');
  });
});

describe('replaceCssColors end-to-end', () => {
  it('converts a full CSS snippet', () => {
    const css = `
body {
  color: #ff0000;
  background: rgb(0, 128, 255);
  border-color: oklch(0.5 0.1 200);
}
`.trim();

    const { result, summary } = replaceCssColors(css, 'oklch');
    expect(summary.total).toBe(3);
    expect(summary.converted).toBe(2); // hex + rgb converted; oklch skipped
    expect(summary.skipped).toBe(1);
    expect(result).not.toContain('#ff0000');
    expect(result).not.toContain('rgb(0, 128, 255)');
    expect(result).toContain('oklch(0.5 0.1 200)'); // unchanged
  });
});
