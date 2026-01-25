# Design Philosophy

## Core Principles

### 1. Clarity Over Complexity

**Good:**
- White space guides attention
- One primary action per screen
- Visual hierarchy through size and weight

**Bad:**
- Cluttered interfaces with competing elements
- Multiple CTAs at same prominence
- Equal visual weight for all elements

### 2. Consistency Builds Trust

**Platform Consistency:**
- iOS apps use iOS patterns (bottom sheets, swipe gestures)
- Web apps use web patterns (hover states, URL navigation)
- Don't force mobile patterns onto desktop or vice versa

**Internal Consistency:**
- Same action = same location (e.g., save always top-right)
- Same component = same behavior across app
- Design tokens ensure visual consistency

### 3. Performance is UX

**Perceived Performance:**
- Optimistic UI updates (update immediately, sync in background)
- Skeleton screens instead of spinners
- Instant feedback on interactions (<100ms)

**Actual Performance:**
- 60fps animations
- Core Web Vitals: LCP <2.5s, FID <100ms, CLS <0.1
- Lazy load below-the-fold content

### 4. Accessibility is Not Optional

**Universal Design:**
- High contrast benefits everyone in bright sunlight
- Keyboard navigation helps power users
- Clear labels help non-native speakers

**Legal Requirements:**
- WCAG 2.2 AA is minimum (soon legally required in EU, US)
- Accessibility lawsuits are increasing
- Design accessible from the start (retrofitting is expensive)

## Anti-Patterns

### Don't Do

❌ **Rely on color alone**
```tsx
{/* Bad: Only color differentiates */}
<span className="text-red-500">Error</span>
<span className="text-green-500">Success</span>
```

✅ **Use icons + color**
```tsx
{/* Good: Icon + color + text */}
<div className="flex items-center gap-2 text-red-600">
  <svg className="w-5 h-5" />
  <span>Error: Invalid input</span>
</div>
```

❌ **Tiny touch targets**
```tsx
{/* Bad: 24px icon without padding */}
<button><svg className="w-6 h-6" /></button>
```

✅ **44px minimum**
```tsx
{/* Good: Icon centered in 44px button */}
<button className="w-11 h-11 flex items-center justify-center">
  <svg className="w-6 h-6" />
</button>
```

❌ **Generic error messages**
```
Error: Something went wrong
```

✅ **Actionable feedback**
```
Email address is invalid. Please use format: name@example.com
```

❌ **Disable buttons without explanation**
```tsx
<button disabled>Submit</button>
```

✅ **Show why it's disabled**
```tsx
<button disabled className="opacity-50 cursor-not-allowed">
  Submit
</button>
<p className="text-sm text-gray-500 mt-2">
  Complete all required fields to submit
</p>
```

## Design System Selection

**Choose based on:**

| Type | Recommended System |
|------|-------------------|
| B2B SaaS | Carbon, Ant Design, Lightning |
| Consumer apps | Material 3, Apple HIG |
| E-commerce | Polaris, custom with strong brand |
| Internal tools | Ant Design, Atlassian |
| Creative tools | Spectrum 2, custom |

**Don't:**
- Mix design systems (pick one as foundation)
- Copy competitors exactly (users expect some consistency)
- Ignore platform conventions (iOS users expect iOS patterns)

## Mobile-First Mindset

**Start mobile:**
1. Forces prioritization (limited space)
2. Ensures touch targets are adequate
3. Progressive enhancement to desktop

**Desktop-first problems:**
- Hover states don't translate to mobile
- Dense layouts become unusable
- Assumptions about mouse precision

## Progressive Disclosure

**Show essential, hide advanced:**
```tsx
{/* Good: Advanced options collapsed */}
<form>
  <input type="email" required />
  <input type="password" required />
  <button type="submit">Sign in</button>

  <details className="mt-4">
    <summary className="text-sm text-gray-600 cursor-pointer">
      Advanced options
    </summary>
    <div className="mt-2 space-y-2">
      {/* Advanced fields */}
    </div>
  </details>
</form>
```

**Benefits:**
- Reduces cognitive load
- Faster for common cases
- Power users can still access everything

## Feedback Loops

**Immediate → Ongoing → Completion**

1. **Immediate:** Button press animation (<100ms)
2. **Ongoing:** Progress indicator for long operations
3. **Completion:** Success/error state with clear next action

```tsx
{/* Example: File upload */}
<button onClick={upload} className="relative">
  {uploading && <Spinner className="absolute inset-0" />}
  Upload
</button>

{progress > 0 && (
  <div className="w-full bg-gray-200 rounded-full h-2">
    <div className="bg-blue-600 h-2 rounded-full" style={{width: `${progress}%`}} />
  </div>
)}

{complete && (
  <div className="text-green-600">
    ✓ Upload complete. <a href="/files">View files</a>
  </div>
)}
```

## Context Matters

**Different contexts = different patterns:**

| Context | Pattern |
|---------|---------|
| High-stakes (banking) | Confirmation dialogs, clear labels, conservative design |
| Creative work | Expansive canvas, minimal chrome, keyboard shortcuts |
| Data entry | Keyboard-first, tab order, inline validation |
| Consumption (news) | Comfortable reading, minimal distractions |

Don't use the same design for all contexts.
