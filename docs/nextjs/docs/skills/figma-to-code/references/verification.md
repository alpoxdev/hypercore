# Design-Code Verification Guide

Checklist for verifying accuracy between Figma design and code.

---

## Verification Checklist

### Colors

| Check Item | Method |
|----------|--------|
| Figma value | Color Picker → #3182F6 |
| Browser value | DevTools → Computed → `background-color` |
| Match verification | `getComputedStyle(el).backgroundColor` |

```
□ Primary/Secondary colors
□ Semantic colors (success/error/warning)
□ Text/background/border colors
```

### Spacing

| Check Item | Method |
|----------|--------|
| Figma value | Auto Layout → Gap 18px, Padding 24px |
| Browser value | DevTools → Layout → Box Model |
| Match verification | `getComputedStyle(el).gap` |

```
□ gap value
□ padding (top/right/bottom/left)
□ margin (if applicable)
```

### Typography

| Check Item | Method |
|----------|--------|
| Figma value | Text Style → 28px/600/36px/-0.02em |
| Browser value | DevTools → Computed |
| Match verification | `getComputedStyle(el).fontSize` |

```
□ font-family
□ font-size
□ font-weight
□ line-height
□ letter-spacing
```

### Layout

| Check Item | Method |
|----------|--------|
| Figma value | Auto Layout → Horizontal/Center/Center |
| Browser value | DevTools → Layout → Flexbox |
| Match verification | `getComputedStyle(el).display` |

```
□ display: flex
□ flex-direction
□ justify-content
□ align-items
□ gap
```

### Dimensions

| Check Item | Method |
|----------|--------|
| Figma value | Button → 120x44px |
| Browser value | DevTools → Layout → width/height |
| Match verification | `el.getBoundingClientRect()` |

```
□ width
□ height
□ min-width/max-width
□ min-height/max-height
```

### Assets (Required)

```
□ Use files downloaded from Figma (no AI-generated)
□ WebP compression completed
□ public/images/[category]/ structure
□ Clear filenames (hero-banner.webp)
□ Appropriate compression quality (hero: 85-90, general: 75-85)
```

### Responsive (Required)

```
□ Mobile (320-767px) layout verified
  □ Grid → List conversion
  □ Font size reduction
  □ Spacing reduction
  □ Hamburger menu

□ Tablet (768-1023px) layout verified
  □ 2-column grid
  □ Medium font size
  □ Medium spacing

□ Desktop (1024px+) layout verified
  □ 4-column grid
  □ Large font size
  □ Wide spacing
  □ Full menu

□ Responsive images (<picture> or srcSet)
□ Media query breakpoints exact
```

---

## Verification Tools

### DevTools Shortcuts

| Function | Shortcut |
|----------|----------|
| Open DevTools | F12 or Cmd+Opt+I |
| Device Toolbar | Cmd+Shift+M |
| Inspect Element | Cmd+Shift+C |

### Console Snippets

```js
// Verify color
const el = document.querySelector('.button')
console.log(getComputedStyle(el).backgroundColor)

// Verify spacing
const padding = {
  top: getComputedStyle(el).paddingTop,
  right: getComputedStyle(el).paddingRight,
  bottom: getComputedStyle(el).paddingBottom,
  left: getComputedStyle(el).paddingLeft,
}
console.table(padding)

// Verify typography
const typography = {
  fontFamily: getComputedStyle(el).fontFamily,
  fontSize: getComputedStyle(el).fontSize,
  fontWeight: getComputedStyle(el).fontWeight,
  lineHeight: getComputedStyle(el).lineHeight,
  letterSpacing: getComputedStyle(el).letterSpacing,
}
console.table(typography)

// Verify dimensions
const rect = el.getBoundingClientRect()
console.log(`Width: ${rect.width}px, Height: ${rect.height}px`)
```

---

## Visual Comparison

### Overlay Tools

| Tool | Purpose |
|------|---------|
| [PerfectPixel](https://chrome.google.com/webstore/detail/perfectpixel) | Chrome extension |
| Figma Inspect | Figma Dev Mode → Compare to design |

### Usage

```
1. Export Figma as PNG (2x)
2. Take browser screenshot
3. Use overlay tool to compare
4. Fix discrepancies
```

---

## Automation

### Visual Regression Testing

```bash
# Install Percy
npm install --save-dev @percy/cli @percy/playwright
```

```js
// playwright.config.js
import { percySnapshot } from '@percy/playwright'

test('Button matches Figma', async ({ page }) => {
  await page.goto('/components/button')
  await percySnapshot(page, 'Button Component')
})
```

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Color mismatch | Variables hardcoded instead | Extract Variables |
| Spacing mismatch | Using Tailwind defaults (`gap-4`) | Use exact value (`gap-[18px]`) |
| Font mismatch | Letter-spacing conversion error | Verify PERCENT → em conversion |
| Layout broken | Ignoring Auto Layout | Convert Frame hierarchy directly |

---

## References

- [Chrome DevTools](https://developer.chrome.com/docs/devtools/)
- [Percy Visual Testing](https://percy.io/)
- [Figma Dev Mode](https://help.figma.com/hc/en-us/articles/15023124644247)
