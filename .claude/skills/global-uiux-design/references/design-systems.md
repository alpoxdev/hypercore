# Leading Design Systems - Comparison & Best Practices

## Overview

| System | Org | License | Best For |
|--------|-----|---------|----------|
| Material Design 3 | Google | Apache 2.0 | Android apps, cross-platform consistency |
| Apple HIG | Apple | Proprietary | iOS/macOS apps, premium feel |
| Fluent 2 | Microsoft | MIT | Windows apps, enterprise, Office integration |
| Carbon | IBM | Apache 2.0 | Enterprise B2B, data-heavy interfaces |
| Ant Design | Ant Group | MIT | Admin dashboards, internal tools |
| Polaris | Shopify | MIT | E-commerce, merchant tools |
| Lightning | Salesforce | Custom | CRM, business apps |
| Spectrum 2 | Adobe | Apache 2.0 | Creative tools, content-focused |
| Atlassian DS | Atlassian | Custom | Collaboration tools, project management |
| Chakra UI | Community | MIT | Accessible React apps, rapid prototyping |

---

## Material Design 3 (Google)

**URL:** https://m3.material.io/

### Key Features

- **Dynamic Color:** Generate entire palette from single source color
- **Material You:** Adapts to user's wallpaper (Android 12+)
- **Component States:** Clearly defined hover, focus, active, disabled
- **Elevation:** Uses shadow and tonal surfaces

### Philosophy

- **Expressive:** Bold, intentional, vibrant
- **Adaptable:** Scales across devices and contexts
- **Inclusive:** Accessibility built-in

### When to Use

✅ Android apps (native integration)
✅ Cross-platform apps (consistent Google ecosystem feel)
✅ Apps targeting international/diverse audiences

❌ iOS-first apps (users expect iOS patterns)
❌ High-end luxury brands (too "tech company")

### Code Example

```tsx
{/* Material 3 button */}
<button className="
  h-10 px-6
  rounded-full
  bg-primary-600 hover:bg-primary-700
  text-white font-medium
  shadow-sm hover:shadow-md
  transition-all duration-200
">
  Action
</button>
```

### Resources

- Design Kit: Figma Community (Material 3 Design Kit)
- Components: material-web (Web Components)
- Icons: Material Symbols (variable font)

---

## Apple Human Interface Guidelines

**URL:** https://developer.apple.com/design/human-interface-guidelines/

### Key Features (2026)

- **Liquid Glass:** Translucency, depth, fluid motion
- **SF Symbols:** 5000+ symbols, auto-weight matching
- **Dynamic Type:** User-controlled text sizing
- **Dark Mode:** System-wide, automatic switching

### Philosophy

- **Clarity:** Content is paramount
- **Deference:** UI doesn't compete with content
- **Depth:** Layers and motion provide hierarchy

### When to Use

✅ iOS/macOS apps (platform expectation)
✅ Premium consumer products
✅ Content-focused apps (reading, media)

❌ Web apps (iOS patterns don't translate well)
❌ Android-first apps (use Material instead)

### Code Example

```tsx
{/* iOS-style button */}
<button className="
  h-11 px-6
  rounded-lg
  bg-blue-500 hover:bg-blue-600
  text-white font-semibold
  active:scale-95
  transition-all
">
  Continue
</button>

{/* iOS segment control */}
<div className="inline-flex p-1 bg-gray-100 rounded-lg">
  <button className="px-4 py-2 rounded-md bg-white shadow-sm">All</button>
  <button className="px-4 py-2 rounded-md text-gray-600">Active</button>
</div>
```

### Resources

- SF Symbols app (macOS)
- Design resources: developer.apple.com/design/resources
- SF Pro font family (system font)

---

## Fluent 2 (Microsoft)

**URL:** https://fluent2.microsoft.design/

### Key Features

- **Design Tokens:** Platform-agnostic styling
- **Figma-Native:** Built in Figma from ground up
- **Cross-Platform:** Web, iOS, Windows, Android
- **Fluent 2 Web Components:** Framework-agnostic

### Philosophy

- **Effortless:** Natural, intuitive interactions
- **Warm:** Friendly, approachable
- **Inclusive:** Accessible to all

### When to Use

✅ Windows apps (native feel)
✅ Office integrations
✅ Enterprise B2B (professional, familiar)

❌ Consumer mobile apps (better options exist)
❌ Branding-heavy products (Fluent is very "Microsoft")

### Code Example

```tsx
{/* Fluent button */}
<button className="
  h-8 px-3
  rounded
  bg-blue-500 hover:bg-blue-600
  text-white text-sm font-medium
  transition-colors
">
  Submit
</button>
```

### Resources

- UI Kit: Fluent 2 (Figma)
- Components: @fluentui/react-components
- Icons: @fluentui/react-icons

---

## Carbon Design System (IBM)

**URL:** https://carbondesignsystem.com/

### Key Features

- **Token-Based:** Semantic naming (ui-01, text-01)
- **Accessibility-First:** WCAG AA minimum, AAA where possible
- **Data Visualization:** Comprehensive charting guidelines
- **Grid System:** 16-column grid, 16px base unit

### Philosophy

- **Clarity:** Purpose-driven design
- **Efficiency:** Reduce cognitive load
- **Inclusivity:** Design for everyone

### When to Use

✅ Enterprise B2B SaaS
✅ Data-heavy dashboards
✅ Internal tools requiring consistency

❌ Consumer apps (too corporate)
❌ Marketing sites (not expressive enough)

### Code Example

```tsx
{/* Carbon button */}
<button className="
  h-12 px-4
  bg-blue-600 hover:bg-blue-700
  text-white text-sm
  border-none
  transition-colors
">
  Primary button
</button>
```

### Resources

- Design Kit: Carbon Design Kit (Sketch, Figma)
- Components: @carbon/react
- Icons: @carbon/icons-react

---

## Ant Design (Ant Group)

**URL:** https://ant.design/

### Key Features

- **Enterprise-Grade:** 60+ components
- **Internationalization:** Built-in i18n support
- **TypeScript:** First-class TypeScript support
- **Customizable:** Design token system

### Philosophy

- **Natural:** Inspired by nature
- **Certain:** Reliable, predictable
- **Meaningful:** Every element has purpose

### When to Use

✅ Admin dashboards
✅ Internal enterprise tools
✅ B2B SaaS platforms
✅ Data-heavy applications

❌ Consumer-facing apps (too "admin panel")
❌ Marketing sites (not expressive)

### Code Example

```tsx
import { Button, Table, Form } from 'antd';

{/* Ant Design usage */}
<Button type="primary" size="large">
  Submit
</Button>

<Table
  dataSource={data}
  columns={columns}
  pagination={{ pageSize: 10 }}
/>
```

### Resources

- Design Kit: Ant Design (Figma, Sketch)
- Components: antd (React)
- Icons: @ant-design/icons

---

## Shopify Polaris (2026)

**URL:** https://polaris.shopify.com/

### Key Features

- **Web Components:** Framework-agnostic (2026 update)
- **E-commerce Optimized:** Patterns for merchants
- **Auto-Updates:** CDN-delivered, always current
- **Accessibility:** WCAG 2.2 AA compliant

### Philosophy

- **Merchant-First:** Design for business owners
- **Efficient:** Reduce time to completion
- **Trustworthy:** Clear, predictable

### When to Use

✅ E-commerce apps (Shopify ecosystem)
✅ Merchant-facing tools
✅ Sales/inventory management

❌ General consumer apps
❌ Non-commerce products

### Code Example

```html
<!-- Polaris Web Components (2026) -->
<polaris-button variant="primary" size="large">
  Create product
</polaris-button>

<polaris-card>
  <polaris-card-section>
    Content
  </polaris-card-section>
</polaris-card>
```

### Resources

- Design Kit: Polaris for Figma
- Components: @shopify/polaris (Web Components)

---

## Salesforce Lightning Design System 2

**URL:** https://www.lightningdesignsystem.com/

### Key Features (2026)

- **SLDS 2:** Agentic design patterns
- **Styling Hooks:** Flexible customization
- **Cosmos Theme:** Modern, updated aesthetic
- **Backward Compatible:** Works with SLDS 1

### When to Use

✅ Salesforce integrations
✅ CRM applications
✅ Business/sales tools

❌ Consumer apps
❌ Non-CRM products

---

## Adobe Spectrum 2

**URL:** https://spectrum.adobe.com/

### Key Features

- **Cross-App:** Consistent across 100+ Adobe apps
- **Scale System:** Adaptive sizing for different contexts
- **Creative-First:** Optimized for creative workflows

### When to Use

✅ Creative tools (design, video, photo)
✅ Content management
✅ Apps requiring Adobe integration

❌ Business apps
❌ E-commerce

---

## Atlassian Design System

**URL:** https://atlassian.design/

### Key Features

- **4px Grid:** Strict spacing system
- **Collaboration-Optimized:** Team workflows
- **Design Tokens:** Theme-agnostic

### When to Use

✅ Project management tools
✅ Collaboration platforms
✅ Documentation sites

---

## Chakra UI

**URL:** https://chakra-ui.com/

### Key Features

- **Accessible:** WAI-ARIA compliant
- **Composable:** Build with primitives
- **Style Props:** Inline utility props
- **Dark Mode:** Built-in support

### When to Use

✅ Rapid prototyping
✅ Accessible React apps
✅ Startups (fast development)

### Code Example

```tsx
import { Button, Box, Stack } from '@chakra-ui/react';

<Stack spacing={4}>
  <Button colorScheme="blue" size="lg">
    Primary
  </Button>
  <Box bg="gray.100" p={4} rounded="lg">
    Content
  </Box>
</Stack>
```

---

## Decision Matrix

| Need | Recommended System |
|------|-------------------|
| Android app | Material Design 3 |
| iOS app | Apple HIG |
| Windows app | Fluent 2 |
| Admin dashboard | Ant Design, Carbon |
| E-commerce | Polaris |
| CRM/Sales | Lightning DS |
| Creative tool | Spectrum 2 |
| Collaboration | Atlassian DS |
| Rapid prototype | Chakra UI |
| Accessible web app | Chakra UI, Carbon |

## Hybrid Approach

**Foundation:** Choose one system as base
**Customization:** Adapt colors, typography to brand
**Components:** Cherry-pick from others when needed

**Example:**
- Base: Material Design 3
- Brand colors: Custom palette
- Data tables: Borrow from Ant Design
- Form validation: Carbon patterns

**Warning:** Don't mix design languages randomly. Users get confused.
