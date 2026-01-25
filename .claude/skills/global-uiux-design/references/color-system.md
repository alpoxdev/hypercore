# Color System

## Palette Structure

### Base Palette (9-shade scale)

```tsx
// Example: Primary color
const primary = {
  50:  '#EFF6FF',  // Lightest background
  100: '#DBEAFE',
  200: '#BFDBFE',
  300: '#93C5FD',
  400: '#60A5FA',
  500: '#3B82F6',  // Base
  600: '#2563EB',  // Default button
  700: '#1D4ED8',  // Hover state
  800: '#1E40AF',
  900: '#1E3A8A',  // Darkest text
}
```

### Semantic Colors

| Color | Usage | Example |
|-------|-------|---------|
| **Success** | Completed actions, positive feedback | green-600 |
| **Error** | Failed actions, validation errors | red-600 |
| **Warning** | Caution, reversible actions | amber-600 |
| **Info** | Neutral information, tips | blue-600 |

```tsx
{/* Semantic usage */}
<div className="text-green-600">Payment successful</div>
<div className="text-red-600">Invalid email address</div>
<div className="text-amber-600">Unsaved changes</div>
<div className="text-blue-600">Tip: Press Cmd+K to search</div>
```

## Contrast Requirements (WCAG 2.2 AA)

### Text Contrast

| Type | Minimum | Recommended |
|------|---------|-------------|
| Normal text (<18pt) | 4.5:1 | 7:1 (AAA) |
| Large text (≥18pt) | 3:1 | 4.5:1 (AAA) |
| UI components | 3:1 | 4.5:1 |

### Testing Tools

- Chrome DevTools (Lighthouse)
- WebAIM Contrast Checker
- Stark (Figma plugin)
- Contrast Ratio (leaverou.github.io/contrast-ratio)

### Common Mistakes

❌ **Gray text on white**
```tsx
{/* Bad: Only 2.5:1 contrast */}
<p className="text-gray-400">Secondary text</p>
```

✅ **Darker gray**
```tsx
{/* Good: 7:1 contrast */}
<p className="text-gray-600">Secondary text</p>
```

## Dark Mode

### Approach

**System preference:**
```tsx
// Tailwind config
module.exports = {
  darkMode: 'media', // or 'class' for manual toggle
}
```

**Usage:**
```tsx
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">
  Content
</div>
```

### Dark Mode Palette Adjustments

**Don't just invert:**
- Pure black (#000) is too harsh → Use gray-900 (#111827)
- Pure white (#FFF) is too bright → Use gray-100 (#F3F4F6)
- Reduce saturation of colors in dark mode
- Increase contrast slightly (dark mode often viewed in dim lighting)

**Example:**
```tsx
const primary = {
  // Light mode: vibrant
  light: '#2563EB', // blue-600

  // Dark mode: slightly desaturated
  dark: '#60A5FA',  // blue-400 (lighter shade, less saturated)
}
```

### Elevation in Dark Mode

**Light mode:** Use shadows
**Dark mode:** Use lighter backgrounds

```tsx
<div className="
  bg-white shadow-lg
  dark:bg-gray-800 dark:shadow-none dark:ring-1 dark:ring-gray-700
">
  Card content
</div>
```

## Color Harmony

### 60-30-10 Rule

- **60%** Dominant (background, neutral)
- **30%** Secondary (supporting elements)
- **10%** Accent (CTA, highlights)

```tsx
{/* Example: Dashboard */}
<div className="bg-gray-50">  {/* 60% - neutral background */}
  <aside className="bg-white">  {/* 30% - secondary surface */}
    <button className="bg-blue-600">  {/* 10% - accent CTA */}
      Create
    </button>
  </aside>
</div>
```

### Analogous Colors

Use adjacent colors on color wheel for harmony:
- Blue (600) + Cyan (600) + Teal (600)

### Complementary Colors

Use opposite colors for high contrast:
- Blue (600) + Orange (600)
- Use sparingly for important CTAs

## Brand Color Integration

### Extract brand color palette

```tsx
// Brand primary: #FF6B35 (custom orange)

// Generate shades using tools:
// - uicolors.app
// - tailwindshades.com
// - palettte.app

const brand = {
  50:  '#FFF4F0',
  100: '#FFE8DF',
  200: '#FFCFBF',
  300: '#FFB49F',
  400: '#FF9A7F',
  500: '#FF6B35',  // Brand color
  600: '#E64D1A',
  700: '#B33A13',
  800: '#80290D',
  900: '#4D1808',
}
```

### Usage in Components

```tsx
// Replace default blue with brand color
<button className="bg-brand-500 hover:bg-brand-600 text-white">
  Brand CTA
</button>

// Keep semantic colors standard
<div className="text-green-600">Success message</div>
<div className="text-red-600">Error message</div>
```

## Design System Color Approaches

### Material Design 3 - Dynamic Color

- Generate palette from single source color
- Adapts to user's wallpaper (Android 12+)
- Tools: Material Theme Builder

### Apple HIG - System Colors

- Semantic colors (systemBlue, systemRed)
- Automatically adapt to light/dark mode
- Respect accessibility settings (increase contrast)

### IBM Carbon - Color Tokens

- Descriptive tokens (interactive-01, ui-background)
- Theme-agnostic (same token works across themes)
- Design → Dev handoff uses token names

## Color Blindness Considerations

### Types

- **Deuteranopia** (most common, 5% of males): Red-green
- **Protanopia**: Red-green
- **Tritanopia** (rare): Blue-yellow

### Design Strategies

✅ **Use patterns + color**
```tsx
{/* Good: Icon + color differentiates */}
<div className="text-green-600">✓ Success</div>
<div className="text-red-600">✗ Error</div>
```

✅ **Use high contrast**
- Avoid red-green combinations
- Use blue-orange instead

✅ **Test with simulators**
- Figma: Color Blind plugin
- Chrome: DevTools → Rendering → Emulate vision deficiencies

## Performance Considerations

### CSS Custom Properties

```css
:root {
  --color-primary: #3B82F6;
  --color-primary-hover: #2563EB;
}

.dark {
  --color-primary: #60A5FA;
  --color-primary-hover: #3B82F6;
}
```

**Benefits:**
- Runtime theme switching
- No CSS recompilation
- Smaller bundle (one color token, multiple values)

### Avoid Inline Styles

❌ **Bad:** (each instance is unique CSS)
```tsx
<div style={{color: '#3B82F6'}}>Text</div>
```

✅ **Good:** (reusable class)
```tsx
<div className="text-primary-500">Text</div>
```

## Accessibility Tools

- **WebAIM Contrast Checker**: webaim.org/resources/contrastchecker
- **Colorable**: colorable.jxnblk.com
- **Who Can Use**: whocanuse.com
- **Contrast Triangle**: contrast-triangle.com
