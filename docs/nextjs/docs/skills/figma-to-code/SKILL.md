# Figma → Code (100% Pixel-Perfect)

<context>

**Purpose:** Convert Figma designs to 100% accurate code. Extract design tokens/layouts/assets via Figma MCP to ensure pixel-perfect accuracy.

**Trigger:** Implementing Figma designs, generating design system code, developing UI components

**Key Features:**
- Pixel-perfect accuracy (no approximations)
- Automatic design token extraction (Variables, Styles)
- Real asset downloads (no AI-generated assets)
- Accurate Auto Layout → Flexbox/Grid mapping
- Responsive design implementation required
- Asset WebP compression and structured organization

**Critical Rules (must be followed):**
1. Do not arbitrarily interpret designs or create "similar-looking" versions
2. Use only precise values extracted from Figma for all measurements
3. Implement responsive breakpoints for all devices (mobile/tablet/desktop)
4. Always compress images to WebP and organize in appropriate folders
5. Use only Figma assets (AI-generated assets absolutely forbidden)

</context>

---

<prerequisites>

## Pre-requisites

### Verify Figma MCP Connection

```bash
# Desktop MCP (local, selection-based)
claude mcp add --transport http figma-desktop http://127.0.0.1:3845/mcp

# Remote MCP (cloud)
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```

**Enable Desktop MCP:**
1. Launch Figma Desktop app
2. Open file → Switch to Dev Mode
3. In Inspect panel, click "Enable desktop MCP server"

### Organize Figma File Structure (Designer Guide)

| Item | Requirement |
|------|-------------|
| **Auto Layout** | Apply Auto Layout to all Frames |
| **Variables** | Define colors/spacing/font sizes as Variables |
| **Components** | Separate reusable elements as Components |
| **Naming** | Layer names in PascalCase (Button, CardHeader) |
| **Annotations** | Document interactions (hover, click) in comments |

</prerequisites>

---

<workflow>

## Workflow (5 Phases)

### Phase 0: Understand Project Environment

**Goal:** Detect Vite/Next.js environment and verify existing tokens

```
1. Detect framework
   - Vite: Check for vite.config.js/ts existence
   - Next.js: Check for next.config.js/ts existence

2. Locate globals.css
   Vite:
   - src/index.css
   - src/main.css
   - src/app.css

   Next.js:
   - app/globals.css (App Router)
   - styles/globals.css (Pages Router)

3. Verify existing @theme block
   @import "tailwindcss";

   @theme {
     --color-primary: #xxx;
     --spacing-md: 16px;
     ...
   }

4. Verify Tailwind CSS version
   - Confirm v4 usage (tailwindcss: ^4.0.0 in package.json)
   - Recommend upgrade if not v4
```

**Tailwind v4 Characteristics:**
- **No Config File**: Remove tailwind.config.js → Write @theme directly in CSS
- **Auto Class Generation**: `@theme { --color-primary: #xxx; }` → `bg-primary` generated automatically
- **Integrated globals.css**: Manage all tokens in one place

### Phase 1: Extract

**Goal:** Extract precise design data from Figma

```
1. Verify Figma file/component selection
   - Desktop MCP: Select target layers before work
   - Remote MCP: Provide file URL

2. Extract Variables & Styles
   - Colors: Color Variables → CSS Variables / Tailwind config
   - Typography: Text Styles → font-size, line-height, weight
   - Spacing: Spacing Variables → margin, padding, gap

3. Analyze Auto Layout structure
   - Direction: Horizontal → flex-row, Vertical → flex-col
   - Alignment: align-items, justify-content
   - Spacing: gap value

4. Create asset list
   - Images: Extract download links
   - Icons: SVG export
   - Logos/Illustrations: PNG/WebP
   - Categorize by type (hero/icons/logos/illustrations)

5. Verify responsive breakpoints (required)
   Analyze Figma Constraints:
   - Mobile: 320px ~ 767px
   - Tablet: 768px ~ 1023px
   - Desktop: 1024px+

   Check each breakpoint:
   - Layout changes (Grid → List, Horizontal → Vertical)
   - Font size changes
   - Spacing adjustments
   - Hidden/visible elements
```

**Details:** [references/figma-mcp-tools.md](references/figma-mcp-tools.md)

### Phase 2: Structure

**Goal:** Convert Figma Frame hierarchy → React component structure + Tailwind v4 tokens

```
1. Analyze Frame Hierarchy
   Frame "Header"
   ├─ Frame "Logo" → <div className="logo">
   ├─ Frame "Navigation" → <nav>
   └─ Frame "Actions" → <div className="actions">

2. Design Tokens → @theme block (Tailwind v4)

   A. Verify globals.css
      - If existing @theme block exists, merge with it
      - Otherwise, create new one

   B. Map Figma Variables → @theme

   Vite (src/index.css or src/main.css):
   ```css
   @import "tailwindcss";

   @theme {
     /* Figma Color Variables */
     --color-primary: #3182F6;
     --color-secondary: #64748B;
     --color-success: #22C55E;

     /* Figma Spacing Variables */
     --spacing-xs: 4px;
     --spacing-sm: 8px;
     --spacing-md: 16px;
     --spacing-lg: 24px;

     /* Figma Typography Variables */
     --font-size-body: 14px;
     --font-size-heading: 28px;
     --font-weight-regular: 400;
     --font-weight-semibold: 600;

     /* Prevent conflicts with existing tokens */
     /* --color-brand: #xxx; (existing) */
   }
   ```

   Next.js (app/globals.css):
   ```css
   @import "tailwindcss";

   @theme {
     /* Same structure */
   }
   ```

   C. Verify auto class generation
      @theme { --color-primary: #3182F6; }
      → bg-primary, text-primary, border-primary generated automatically

   D. Merge existing globals.css tokens
      ```css
      @theme {
        /* Existing tokens (maintain) */
        --color-brand: #FF5733;

        /* Tokens extracted from Figma (add) */
        --color-primary: #3182F6;
        --spacing-md: 16px;
      }
      ```

3. Component separation criteria
   - Reusable → Separate component
   - Used once → Inline
```

**Details:**
- [references/design-tokens.md](references/design-tokens.md)
- [references/layout-mapping.md](references/layout-mapping.md)

### Phase 3: Implement

**Goal:** Write code with exact measurements

#### Layout Implementation

```tsx
// ❌ Arbitrary values
<div className="flex gap-4 p-6">

// ✅ Precise Figma values
<div className="flex gap-[18px] p-[24px]">
</div>
```

#### Color Implementation

```tsx
// ❌ Similar color
<button className="bg-blue-500">

// ✅ @theme token (Tailwind v4)
<button className="bg-primary">

// ✅ Or precise HEX
<button className="bg-[#3182F6]">
```

#### Typography Implementation

```tsx
// ❌ Approximation
<h1 className="text-2xl font-bold">

// ✅ Exact values
<h1 className="text-[28px] leading-[36px] font-semibold tracking-[-0.02em]">
```

#### Asset Handling (Required)

**1. Download Assets from Figma**
```bash
# Generate download link via Figma MCP
get_images → Obtain download URL
```

**2. WebP Compression (Required)**
```bash
# Using cwebp (Google WebP)
cwebp -q 80 input.png -o output.webp

# Or ImageMagick
convert input.png -quality 80 output.webp

# Batch conversion
for file in *.png; do cwebp -q 80 "$file" -o "${file%.png}.webp"; done
```

**Compression Quality Guide:**
| Use Case | Quality | Size |
|----------|---------|------|
| Hero images | 85-90 | High quality |
| General images | 75-85 | Balanced |
| Thumbnails | 60-75 | Optimized |

**3. Organize public Folder (Required)**
```
public/
├── images/
│   ├── hero/           # Hero section images
│   │   ├── banner.webp
│   │   └── background.webp
│   ├── products/       # Product images
│   │   ├── product-1.webp
│   │   └── product-2.webp
│   ├── team/           # Team photos
│   │   └── member-1.webp
│   └── thumbnails/     # Thumbnails
│       └── thumb-1.webp
├── icons/              # Icons (SVG)
│   ├── social/
│   │   ├── facebook.svg
│   │   └── twitter.svg
│   └── ui/
│       ├── arrow.svg
│       └── close.svg
└── logos/              # Logos
    ├── logo.svg
    └── logo-white.svg
```

**4. Use in Code**
```tsx
// ❌ AI-generated/arbitrary images
<img src="/placeholder.jpg" alt="Hero" />

// ✅ Real Figma assets + WebP + organized path
<img
  src="/images/hero/banner.webp"
  alt="Hero Banner"
  width={1200}
  height={600}
  loading="lazy"
/>

// Icons
<img src="/icons/ui/arrow.svg" alt="" width={24} height={24} />

// Logo
<img src="/logos/logo.svg" alt="Company Logo" width={120} height={40} />
```

**5. Responsive Images**
```tsx
<picture>
  <source media="(min-width: 1024px)" srcSet="/images/hero/banner-desktop.webp" />
  <source media="(min-width: 768px)" srcSet="/images/hero/banner-tablet.webp" />
  <img src="/images/hero/banner-mobile.webp" alt="Hero" />
</picture>
```

### Phase 4: Verify

**Goal:** Validate design and code accuracy

```
Checklist:
□ Colors: Compare Figma Color Picker with DevTools
□ Spacing: All margin/padding/gap values match exactly
□ Typography: size, weight, line-height match precisely
□ Layout: Auto Layout structure reflected in code

□ Assets (Required):
  □ Use actual files downloaded from Figma
  □ WebP compression completed (PNG/JPG → WebP)
  □ public/ folder organized (images/icons/logos)
  □ Clear filenames (hero-banner.webp, product-1.webp)
  □ Appropriate compression quality (hero: 85-90, general: 75-85)

□ Responsive (Required):
  □ Mobile (320-767px) layout verified
  □ Tablet (768-1023px) layout verified
  □ Desktop (1024px+) layout verified
  □ Media query breakpoints exact
  □ Responsive images (<picture> or srcSet)
  □ All devices match Figma design
```

**Details:** [references/verification.md](references/verification.md)

</workflow>

---

<best_practices>

## Best Practices

### DO

| Principle | Description |
|-----------|-------------|
| **Exact Values** | Use `px-[18px]` instead of `px-4` (exact value) |
| **@theme First** | Figma Variables → @theme block (Tailwind v4) |
| **Merge Existing Tokens** | Maintain existing globals.css tokens + merge new ones |
| **Extract Before Implement** | Complete all token/asset extraction before coding |
| **WebP Only** | Compress all images to WebP (PNG/JPG forbidden) |
| **Structured Assets** | Organize with public/images/[category]/ folder structure |
| **Responsive Required** | Implement all three breakpoints (Mobile/Tablet/Desktop) |
| **Cross-Validate** | Figma Dev Mode + MCP + manual verification |
| **Document Mapping** | Annotate with Figma properties in comments |

### DON'T

| Forbidden | Reason |
|-----------|--------|
| **Use Approximations** | "Similar values" cause design mismatches |
| **AI-Generated Assets** | Use only real assets created by designers |
| **PNG/JPG Files** | Must compress to WebP before use |
| **Images in public/ Root** | Folder structure required (images/icons/logos) |
| **Skip Responsive** | All three breakpoints are mandatory |
| **Arbitrary Interpretation** | Ignore Auto Layout and use manual layout |
| **Tailwind Defaults** | Use exact `gap-[18px]` not `gap-4` |
| **Use tailwind.config.js** | Tailwind v4 uses @theme block |
| **Overwrite Existing Tokens** | Maintain existing globals.css tokens |

### Prompt Example

```
Convert this Figma component to code.

Environment:
- Vite/Next.js (verify project structure)
- Tailwind CSS v4 in use
- Maintain existing globals.css tokens

Critical Rules (must follow):
1. Phase 0: Understand project environment (Vite/Next.js, globals.css location)
2. Phase 1: Extract Variables, Text Styles, Auto Layout, breakpoints via Figma MCP
3. Phase 2: Add tokens to @theme block (merge with existing tokens)
4. Phase 3: All measurements match exactly (no approximations)

Asset Handling (Required):
- Download from Figma (absolutely no AI-generated assets)
- Compress PNG/JPG → WebP (quality 75-90)
- Organize in public/images/[category]/
- Clear filenames (hero-banner.webp, product-1.webp)

Responsive (Required):
- Mobile (320-767px): Verify layout changes
- Tablet (768-1023px): Verify layout changes
- Desktop (1024px+): Verify layout changes
- Responsive images (<picture> or srcSet)

Validation:
- Colors/spacing/typography: 100% match with Figma
- Assets: WebP compression and folder structure confirmed
- Responsive: All devices match Figma design
- @theme tokens auto-generate classes
```

</best_practices>

---

<troubleshooting>

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| MCP not connecting | Desktop MCP not enabled | Enable in Figma Dev Mode |
| Color mismatch | Using direct colors instead of Variables | Extract Variables first |
| Spacing error | Using Tailwind defaults | Override with exact px values |
| Layout broken | Ignoring Auto Layout structure | Convert Frame hierarchy directly |
| Missing assets | Export settings not verified | Verify Export Settings before download |

</troubleshooting>

---

<references>

## Detailed Documentation

| Document | Content |
|----------|---------|
| [figma-mcp-tools.md](references/figma-mcp-tools.md) | Figma MCP tools usage, API endpoints |
| [design-tokens.md](references/design-tokens.md) | Variables/Styles extraction and Tailwind v4 mapping |
| [layout-mapping.md](references/layout-mapping.md) | Auto Layout → Flexbox/Grid conversion rules |
| [responsive-design.md](references/responsive-design.md) | Responsive implementation guide (breakpoints, images) |
| [verification.md](references/verification.md) | Design-code accuracy verification checklist |

## External References

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Design Tokens with Figma](https://blog.prototypr.io/design-tokens-with-figma-aef25c42430f)
- [Pixel-Perfect Code Generation Guide](https://medium.com/@reuvenaor85/the-way-to-figma-mcp-pixel-perfect-code-generation-for-react-tailwind-1623fd5383b8)

</references>
