# Accessibility (WCAG 2.2 AA)

## Core Requirements

### 1. Perceivable

**Information must be presentable to users in ways they can perceive.**

#### Text Alternatives (1.1)

```tsx
{/* Images */}
<img src="chart.png" alt="Sales increased 25% in Q4" />

{/* Decorative images */}
<img src="decoration.png" alt="" role="presentation" />

{/* Icon buttons */}
<button aria-label="Close dialog">
  <svg className="w-5 h-5" aria-hidden="true" />
</button>
```

#### Color Contrast (1.4.3)

- **Normal text:** 4.5:1 minimum
- **Large text (18pt+):** 3:1 minimum
- **UI components:** 3:1 minimum (borders, form controls)

#### Resize Text (1.4.4)

```tsx
{/* Support up to 200% zoom */}
<p className="text-base leading-relaxed">
  Use relative units (rem, em) not px
</p>
```

### 2. Operable

**UI components must be operable.**

#### Keyboard Accessible (2.1)

```tsx
{/* All interactive elements keyboard accessible */}
<button onClick={handleClick}>Submit</button>  {/* ✓ */}
<div onClick={handleClick}>Submit</div>  {/* ✗ Not keyboard accessible */}

{/* Custom interactive elements need tabIndex and keyboard handlers */}
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Custom button
</div>
```

#### Focus Visible (2.4.7)

```tsx
{/* Ensure visible focus indicator */}
<button className="
  focus:outline-none
  focus:ring-2
  focus:ring-primary-500
  focus:ring-offset-2
">
  Save
</button>
```

#### Skip Links (2.4.1)

```tsx
{/* Allow keyboard users to skip navigation */}
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4"
>
  Skip to main content
</a>

<main id="main-content">
  {/* Page content */}
</main>
```

### 3. Understandable

**Information and operation must be understandable.**

#### Language (3.1.1)

```html
<html lang="en">
  <body>
    <p>This is English text.</p>
    <p lang="es">Este es texto en español.</p>
  </body>
</html>
```

#### Error Identification (3.3.1)

```tsx
{/* Clear error messages */}
<div>
  <label htmlFor="email">Email</label>
  <input
    id="email"
    type="email"
    aria-invalid={hasError}
    aria-describedby={hasError ? "email-error" : undefined}
  />
  {hasError && (
    <p id="email-error" className="text-red-600 text-sm mt-1">
      Please enter a valid email address (e.g., name@example.com)
    </p>
  )}
</div>
```

#### Labels (3.3.2)

```tsx
{/* Every form input needs a label */}
<label htmlFor="username" className="block text-sm font-medium">
  Username
</label>
<input id="username" type="text" />

{/* Or use aria-label */}
<input type="search" aria-label="Search products" />
```

### 4. Robust

**Content must be robust enough for assistive technologies.**

#### Valid HTML (4.1.1)

- Proper nesting (no `<div>` inside `<p>`)
- Unique IDs
- Closing tags
- Valid ARIA attributes

#### Name, Role, Value (4.1.2)

```tsx
{/* Use semantic HTML when possible */}
<button>Click me</button>  {/* ✓ Role implicit */}

{/* Custom components need explicit roles */}
<div role="button" aria-pressed={isPressed}>
  Toggle
</div>
```

## ARIA (Accessible Rich Internet Applications)

### ARIA Roles

```tsx
{/* Landmark roles */}
<header role="banner">
<nav role="navigation">
<main role="main">
<aside role="complementary">
<footer role="contentinfo">

{/* Widget roles */}
<div role="dialog" aria-modal="true">
<div role="alertdialog">
<div role="tooltip">
<div role="tablist">
  <button role="tab" aria-selected={true}>Tab 1</button>
</div>
```

### ARIA States & Properties

```tsx
{/* aria-expanded (dropdowns, accordions) */}
<button aria-expanded={isOpen} onClick={toggle}>
  Menu
</button>

{/* aria-hidden (decorative elements) */}
<svg aria-hidden="true" />

{/* aria-live (dynamic content) */}
<div role="status" aria-live="polite">
  {notification}
</div>

{/* aria-describedby (additional descriptions) */}
<input
  type="password"
  aria-describedby="password-requirements"
/>
<p id="password-requirements">
  Must be at least 8 characters
</p>
```

### ARIA Best Practices

**First Rule of ARIA:**
> If you can use native HTML, do it.

❌ **Bad:**
```tsx
<div role="button" tabIndex={0} onClick={click}>Submit</div>
```

✅ **Good:**
```tsx
<button onClick={click}>Submit</button>
```

## Common Patterns

### Modal Dialog

```tsx
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-description"
>
  <h2 id="dialog-title">Confirm deletion</h2>
  <p id="dialog-description">
    Are you sure you want to delete this item? This action cannot be undone.
  </p>
  <button onClick={confirm}>Delete</button>
  <button onClick={cancel}>Cancel</button>
</div>
```

**Requirements:**
- Focus trap (Tab cycles within dialog)
- Close on Escape key
- Return focus to trigger element on close
- Prevent body scroll

### Accordion

```tsx
<div>
  <button
    aria-expanded={isOpen}
    aria-controls="panel-1"
    onClick={toggle}
  >
    Section 1
  </button>
  <div id="panel-1" hidden={!isOpen}>
    Panel content
  </div>
</div>
```

### Tabs

```tsx
<div role="tablist" aria-label="Settings">
  <button
    role="tab"
    aria-selected={activeTab === 'general'}
    aria-controls="panel-general"
  >
    General
  </button>
  <button
    role="tab"
    aria-selected={activeTab === 'privacy'}
    aria-controls="panel-privacy"
  >
    Privacy
  </button>
</div>

<div role="tabpanel" id="panel-general" hidden={activeTab !== 'general'}>
  General settings
</div>
```

**Keyboard:**
- Arrow keys navigate between tabs
- Tab key moves to panel content
- Home/End jump to first/last tab

### Toast Notifications

```tsx
{/* Non-interruptive notifications */}
<div
  role="status"
  aria-live="polite"
  className="fixed bottom-4 right-4"
>
  <div className="bg-green-50 border border-green-200 p-4 rounded-lg">
    <p>Changes saved successfully</p>
  </div>
</div>

{/* Urgent alerts */}
<div
  role="alert"
  aria-live="assertive"
>
  <p>Error: Payment failed</p>
</div>
```

## Screen Reader Testing

### macOS VoiceOver

1. Enable: System Settings → Accessibility → VoiceOver
2. Toggle: Cmd + F5
3. Navigate: VO + Arrow keys (VO = Ctrl + Option)
4. Interact: VO + Shift + Down
5. Rotor: VO + U (lists headings, links, form controls)

### Windows NVDA (Free)

1. Download: nvaccess.org
2. Toggle: Ctrl + Alt + N
3. Navigate: Arrow keys
4. Elements list: Insert + F7

### Mobile

- **iOS VoiceOver:** Settings → Accessibility → VoiceOver
- **Android TalkBack:** Settings → Accessibility → TalkBack

## Testing Tools

### Automated

- **axe DevTools** (Chrome/Firefox extension)
- **Lighthouse** (Chrome DevTools → Lighthouse)
- **WAVE** (wave.webaim.org)
- **Pa11y** (CLI tool)

### Manual

- **Keyboard only:** Unplug mouse, navigate entire app
- **Screen reader:** VoiceOver (Mac), NVDA (Windows), TalkBack (Android)
- **Zoom:** Test at 200% browser zoom
- **Color blind:** Chrome DevTools → Rendering → Emulate vision deficiencies

## Legal Requirements

### Regions with Accessibility Laws

- **US:** ADA, Section 508 (government sites)
- **EU:** European Accessibility Act (June 2025)
- **UK:** Equality Act 2010
- **Canada:** AODA (Ontario)
- **Australia:** Disability Discrimination Act

### Compliance Level

- **A:** Minimum (many gaps)
- **AA:** Target for most (legal requirement in many regions)
- **AAA:** Gold standard (difficult to achieve fully)

**Recommendation:** WCAG 2.2 AA minimum for all public-facing sites.

## Quick Accessibility Checklist

- [ ] All images have alt text (or alt="" if decorative)
- [ ] Color contrast meets 4.5:1 (normal text) or 3:1 (large text, UI)
- [ ] All interactive elements keyboard accessible
- [ ] Focus indicators visible (not outline: none without replacement)
- [ ] Form inputs have labels
- [ ] Headings in logical order (h1 → h2 → h3, no skipping)
- [ ] Link text descriptive (not "click here")
- [ ] Videos have captions
- [ ] Page has valid lang attribute
- [ ] Zoom to 200% doesn't break layout
- [ ] Screen reader announces page changes
- [ ] Error messages clear and actionable

## Resources

- **WCAG 2.2:** w3.org/WAI/WCAG22/quickref
- **WAI-ARIA Authoring Practices:** w3.org/WAI/ARIA/apg
- **WebAIM:** webaim.org (articles, checklists)
- **A11y Project:** a11yproject.com (beginner-friendly)
- **Inclusive Components:** inclusive-components.design
