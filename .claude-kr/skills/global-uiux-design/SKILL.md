# Global UI/UX Design

<context>

**Purpose:** Implement modern, accessible UI/UX design for global audiences. Apply industry-standard patterns from Material Design, Apple HIG, Fluent, and other leading design systems.

**Trigger:** Frontend UI/UX implementation, React/Vue component design, responsive web/app development, international product design

**Key Features:**
- WCAG 2.2 AA accessibility compliance
- Cross-platform consistency
- Mobile-first responsive design
- Industry-standard design patterns

</context>

---

<core_principles>

## Design Philosophy

| Principle | Application |
|-----------|-------------|
| **Clarity** | Interface should not compete with content. Use subtle hierarchy and whitespace. |
| **Consistency** | Follow platform conventions. iOS apps feel like iOS, web apps follow web standards. |
| **Accessibility** | Design for everyone. WCAG 2.2 AA minimum, aim for AAA where possible. |
| **Performance** | Fast, responsive interactions. 60fps animations, instant feedback. |

**Details:** [references/design-philosophy.md](references/design-philosophy.md)

</core_principles>

---

<layout_patterns>

## Layout

### Container Widths

```tsx
{/* Dashboard - 1280px */}
<div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">

{/* Content - 768px */}
<div className="max-w-3xl mx-auto px-4 sm:px-6">

{/* Forms - 560px */}
<div className="max-w-xl mx-auto px-4">
```

### Spacing Scale

```tsx
{/* 8px base grid */}
<div className="space-y-8">  {/* 32px */}
  <section className="space-y-4">  {/* 16px */}
    <div className="p-6">  {/* 24px */}
```

**Mobile tap targets:** Minimum 44x44px (iOS) or 48x48px (Material)

</layout_patterns>

---

<component_patterns>

## Components

### Buttons

```tsx
{/* Primary - Material 3 style */}
<button className="h-10 px-6 rounded-full bg-primary-600 hover:bg-primary-700 text-white font-medium shadow-sm transition-all">
  Save changes
</button>

{/* Secondary - iOS style */}
<button className="h-10 px-6 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-900 font-semibold transition-colors">
  Cancel
</button>

{/* Ghost */}
<button className="h-10 px-4 rounded-lg hover:bg-gray-100 font-medium transition-colors">
  Learn more
</button>
```

**Sizes:** Small h-8 px-3 | Medium h-10 px-6 | Large h-12 px-8

### Cards

```tsx
<div className="p-6 rounded-2xl border border-gray-200 bg-white shadow-sm hover:shadow-md transition-shadow">
  {/* Header */}
  <div className="flex items-center justify-between mb-4">
    <h3 className="text-lg font-semibold">Card Title</h3>
    <button className="p-2 rounded-lg hover:bg-gray-100">
      <svg className="w-5 h-5 text-gray-500" />
    </button>
  </div>

  {/* Body */}
  <div className="space-y-3">
    <p className="text-sm text-gray-600 leading-relaxed">Content goes here</p>
  </div>

  {/* Footer */}
  <div className="flex items-center justify-between mt-4 pt-4 border-t">
    <span className="text-sm text-gray-500">2 hours ago</span>
    <button className="text-sm text-primary-600 font-medium">Details</button>
  </div>
</div>
```

### List Items

```tsx
<div className="flex items-center gap-4 p-4 hover:bg-gray-50 rounded-lg transition-colors cursor-pointer">
  {/* Avatar/Icon */}
  <div className="w-12 h-12 rounded-full bg-primary-100 flex items-center justify-center flex-shrink-0">
    <svg className="w-6 h-6 text-primary-600" />
  </div>

  {/* Content */}
  <div className="flex-1 min-w-0">
    <div className="font-semibold text-sm truncate">Item Title</div>
    <div className="text-sm text-gray-600 truncate">Description text</div>
  </div>

  {/* Meta */}
  <div className="flex items-center gap-2 flex-shrink-0">
    <span className="text-sm font-medium text-gray-900">$99</span>
    <svg className="w-5 h-5 text-gray-400" />
  </div>
</div>
```

### Input Fields

```tsx
<div className="space-y-2">
  <label className="block text-sm font-medium text-gray-900">
    Email address <span className="text-red-500">*</span>
  </label>
  <input
    type="email"
    className="w-full h-11 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-shadow"
    placeholder="name@example.com"
  />
  <p className="text-sm text-gray-500">We'll never share your email.</p>
</div>
```

### Modals

```tsx
<div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 backdrop-blur-sm">
  <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-auto shadow-xl">
    <div className="flex items-center justify-between p-6 border-b">
      <h2 className="text-xl font-semibold">Modal Title</h2>
      <button className="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-gray-100 transition-colors">
        <svg className="w-5 h-5" />
      </button>
    </div>
    <div className="p-6">
      <p className="text-sm text-gray-700 leading-relaxed">Modal content</p>
    </div>
    <div className="flex gap-3 justify-end p-6 border-t">
      <button className="h-10 px-6 rounded-lg border border-gray-300 hover:bg-gray-50">
        Cancel
      </button>
      <button className="h-10 px-6 rounded-lg bg-primary-600 text-white hover:bg-primary-700">
        Confirm
      </button>
    </div>
  </div>
</div>
```

### Tabs

```tsx
{/* Underline style - iOS/Material */}
<div className="border-b border-gray-200">
  <div className="flex gap-8">
    <button className="py-3 text-sm font-medium text-primary-600 border-b-2 border-primary-600">
      All
    </button>
    <button className="py-3 text-sm font-medium text-gray-600 hover:text-gray-900">
      Active
    </button>
  </div>
</div>

{/* Segment control - iOS style */}
<div className="inline-flex p-1 bg-gray-100 rounded-lg gap-1">
  <button className="px-4 py-2 rounded-md bg-white shadow-sm text-sm font-medium">
    All
  </button>
  <button className="px-4 py-2 rounded-md text-sm font-medium text-gray-600">
    Active
  </button>
</div>
```

</component_patterns>

---

<color_system>

## Color System

| Color | Usage | Ratio |
|-------|-------|-------|
| **Primary** | CTA buttons, links, active states | 10% |
| **Neutral** | Text, borders, backgrounds | 60% |
| **Secondary** | Filters, chips, supporting actions | 30% |
| **Semantic** | Success/Error/Warning/Info | As needed |

```tsx
{/* 60-30-10 rule */}
<button className="bg-primary-600 hover:bg-primary-700 text-white">Primary action</button>
<button className="bg-secondary-100 text-secondary-900 hover:bg-secondary-200">Secondary</button>
```

**WCAG 2.2 AA:** Normal text 4.5:1 | Large text 3:1 | Interactive controls 3:1

**Details:** [references/color-system.md](references/color-system.md)

</color_system>

---

<icon_system>

## Icons

| Size | Usage | Touch Target |
|------|-------|--------------|
| 16px, 20px | Inline with text | - |
| 24px | Standard system icons | 44-48px |
| 32-48px | Feature icons | Use as-is |

```tsx
{/* Sufficient touch target */}
<button className="w-12 h-12 flex items-center justify-center rounded-lg hover:bg-gray-100">
  <svg className="w-6 h-6" />
</button>

{/* States: Outline (inactive) | Filled (active) */}
<svg className="w-6 h-6 stroke-current text-gray-600" fill="none" strokeWidth={2} />
<svg className="w-6 h-6 fill-current text-primary-600" />
```

**Icon libraries:** Heroicons, Lucide, Material Symbols, SF Symbols

**Details:** [references/icon-guide.md](references/icon-guide.md)

</icon_system>

---

<typography>

## Typography

```tsx
{/* Display - Landing pages */}
<h1 className="text-5xl sm:text-6xl font-bold tracking-tight leading-tight">
  Welcome to our platform
</h1>

{/* Page title */}
<h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>

{/* Section title */}
<h2 className="text-xl font-semibold tracking-tight">Recent Activity</h2>

{/* Body text */}
<p className="text-base leading-relaxed text-gray-700">
  Body content with comfortable reading line-height
</p>

{/* Caption */}
<span className="text-sm text-gray-500">2 hours ago</span>
```

**Font stack:**
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
```

**Details:** [references/typography.md](references/typography.md)

</typography>

---

<responsive_patterns>

## Responsive Design

### Grid Layouts

```tsx
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### Navigation

```tsx
{/* Desktop: Sidebar */}
<aside className="hidden lg:block w-64 border-r" />

{/* Mobile: Bottom tab bar */}
<nav className="lg:hidden fixed bottom-0 inset-x-0 h-16 border-t bg-white safe-area-inset-bottom" />
```

### Breakpoints (Tailwind defaults)

| Breakpoint | Width |
|------------|-------|
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |
| 2xl | 1536px |

**Details:** [references/responsive-patterns.md](references/responsive-patterns.md)

</responsive_patterns>

---

<design_systems>

## Leading Design Systems

| System | Organization | Characteristics |
|--------|--------------|-----------------|
| **[Material Design 3](https://m3.material.io/)** | Google | Dynamic color, expressive motion, adaptive components |
| **[Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)** | Apple | Clarity, deference, depth. Liquid Glass aesthetic (2026) |
| **[Fluent 2](https://fluent2.microsoft.design/)** | Microsoft | Token-based, cross-platform, Figma-native |
| **[Carbon](https://carbondesignsystem.com/)** | IBM | Enterprise-grade, accessibility-first, open source |
| **[Ant Design](https://ant.design/)** | Ant Group | Enterprise UI, comprehensive components, i18n |
| **[Polaris](https://polaris.shopify.com/)** | Shopify | E-commerce optimized, web components (2026) |
| **[Lightning](https://www.lightningdesignsystem.com/)** | Salesforce | SLDS 2 with agentic design patterns |
| **[Spectrum 2](https://spectrum.adobe.com/)** | Adobe | Creative tools focus, cross-app consistency |
| **[Atlassian DS](https://atlassian.design/)** | Atlassian | Collaboration tools, strict 4px grid |
| **[Chakra UI](https://chakra-ui.com/)** | Community | Accessible, modular, style props |

**When to reference:**
- B2B/Enterprise → Carbon, Ant Design, Lightning
- Consumer apps → Material 3, Apple HIG
- Creative tools → Spectrum 2
- E-commerce → Polaris
- Developer tools → Atlassian

**Details:** [references/design-systems.md](references/design-systems.md)

</design_systems>

---

<accessibility_and_states>

## Accessibility & States

### WCAG 2.2 AA Requirements

- **Contrast:** 4.5:1 normal text, 3:1 large text (18pt+)
- **Keyboard:** All interactive elements accessible via keyboard
- **Screen readers:** Semantic HTML, ARIA labels where needed
- **Focus visible:** Clear focus indicators (2px outline minimum)
- **No color alone:** Never convey information with color only

### State Patterns

```tsx
{/* Loading skeleton */}
<div className="animate-pulse space-y-3">
  <div className="h-4 bg-gray-200 rounded w-3/4" />
  <div className="h-4 bg-gray-200 rounded w-1/2" />
</div>

{/* Error state */}
<div className="flex items-center gap-2 text-red-600 text-sm">
  <svg className="w-5 h-5" />
  <span>An error occurred. Please try again.</span>
</div>

{/* Empty state */}
<div className="py-16 text-center">
  <div className="w-20 h-20 mx-auto mb-4 rounded-full bg-gray-100 flex items-center justify-center">
    <svg className="w-10 h-10 text-gray-400" />
  </div>
  <h3 className="text-lg font-semibold mb-2">No items yet</h3>
  <p className="text-sm text-gray-600 mb-4">Get started by creating your first item</p>
  <button className="h-10 px-6 rounded-lg bg-primary-600 text-white">
    Create item
  </button>
</div>

{/* Success toast */}
<div className="flex items-center gap-3 px-4 py-3 rounded-lg bg-green-50 border border-green-200">
  <svg className="w-5 h-5 text-green-600" />
  <span className="text-sm font-medium text-green-900">Changes saved successfully</span>
</div>
```

**Details:**
- [references/accessibility.md](references/accessibility.md)
- [references/micro-interactions.md](references/micro-interactions.md)
- [references/state-patterns.md](references/state-patterns.md)

</accessibility_and_states>

---

<references>

## Detailed Documentation

| Document | Content |
|----------|---------|
| [design-philosophy.md](references/design-philosophy.md) | Core principles, anti-patterns |
| [color-system.md](references/color-system.md) | Palette generation, semantic colors, dark mode |
| [icon-guide.md](references/icon-guide.md) | Icon libraries, sizing, accessibility |
| [typography.md](references/typography.md) | Scale, font stacks, i18n considerations |
| [design-systems.md](references/design-systems.md) | Deep dive into Material, HIG, Fluent, etc. |
| [responsive-patterns.md](references/responsive-patterns.md) | Breakpoints, layouts, mobile-first |
| [accessibility.md](references/accessibility.md) | WCAG 2.2, ARIA, testing tools |
| [micro-interactions.md](references/micro-interactions.md) | Hover, focus, transitions, animations |
| [state-patterns.md](references/state-patterns.md) | Loading, error, empty, success states |
| [checklist.md](references/checklist.md) | Pre-deployment UI/UX audit |

### External Resources

| Resource | URL | Focus |
|----------|-----|-------|
| Material Design 3 | https://m3.material.io/ | Google's design system |
| Apple HIG | https://developer.apple.com/design/human-interface-guidelines/ | iOS/macOS guidelines |
| Fluent 2 | https://fluent2.microsoft.design/ | Microsoft design system |
| IBM Carbon | https://carbondesignsystem.com/ | Enterprise design system |
| Nielsen Norman Group | https://www.nngroup.com/ | UX research & guidelines |
| WCAG 2.2 | https://www.w3.org/WAI/standards-guidelines/wcag/ | Accessibility standard |
| Laws of UX | https://lawsofux.com/ | Psychology-based design principles |
| Ant Design | https://ant.design/ | Enterprise component library |
| Atlassian DS | https://atlassian.design/ | Collaboration tool patterns |
| Shopify Polaris | https://polaris.shopify.com/ | E-commerce design system |
| Salesforce Lightning | https://www.lightningdesignsystem.com/ | SLDS 2 (agentic design) |
| Adobe Spectrum | https://spectrum.adobe.com/ | Creative tool design |
| Chakra UI | https://chakra-ui.com/ | Accessible component library |
| Smashing Magazine | https://www.smashingmagazine.com/ | UX best practices |

</references>

---

<prompt_examples>

## Prompt Examples

### Dashboard

```
Create a dashboard page.

Layout:
- Desktop: Left sidebar (256px) + main content (max-w-7xl)
- Mobile: Bottom tab bar
- Responsive padding (px-4 sm:px-6 lg:px-8)

Components:
- Header with greeting + date
- 4 stat cards (grid-cols-1 sm:grid-cols-2 lg:grid-cols-4)
- Recent activity list
- Quick action buttons

Style:
- Material Design 3 aesthetic
- Cards: rounded-2xl, subtle shadow
- Primary color: blue-600
- Numbers: font-bold text-3xl
```

### Settings Screen

```
Create a settings page.

Layout:
- max-w-2xl mx-auto
- Sections with space-y-8

Components:
- Profile: Avatar + name + email
- Notifications: Toggle switches (h-11 touch target)
- Account: Password change, sign out
- Danger zone: Delete account (red)

Style:
- Each row: flex justify-between items-center
- Label: text-sm font-medium
- Section headers: text-xs text-gray-500 uppercase tracking-wide
```

### Data Table

```
Create a users table.

Layout:
- Desktop: Traditional table
- Mobile: Card list

Components:
- Header: Search bar + filters + add button
- Columns: Avatar, name, email, joined date, status
- Pagination

Style:
- Table header: bg-gray-50
- Row hover: hover:bg-gray-50
- No vertical borders
- Actions: Three-dot menu
- Sticky header on scroll
```

### Form

```
Create a multi-step form.

Layout:
- max-w-xl mx-auto
- Progress indicator at top
- Step transitions with slide animation

Components:
- Step 1: Personal info (name, email, phone)
- Step 2: Address
- Step 3: Review + submit

Style:
- Labels: text-sm font-medium mb-2
- Inputs: h-11 rounded-lg border focus:ring-2
- Validation: Inline errors below fields
- Buttons: Back (secondary) + Continue (primary)
```

</prompt_examples>
