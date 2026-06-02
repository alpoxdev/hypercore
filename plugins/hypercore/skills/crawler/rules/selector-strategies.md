# Selector Strategies

> Playwright selector priority and stable locator patterns.

---

<priority>

## Priority

| Priority | Type | Example | Stability |
|------|------|------|------|
| 1 | aria-ref | `aria-ref=e14` | Session-scoped |
| 2 | data-testid | `[data-testid="submit"]` | Very high |
| 3 | Role + Name | `getByRole('button', { name: 'Save' })` | High |
| 4 | Text/Label | `getByText('Sign in')` | Medium |
| 5 | Semantic | `button[type="submit"]` | Medium |
| 6 | Class/ID | `.btn-primary` | Low |

</priority>

---

<extraction>

## Selector Extraction

```javascript
const snapshot = await accessibilitySnapshot({ page });
// => button "Save" [ref=e14]

const selector = await getLocatorStringForElement(page.locator('aria-ref=e14'));
// => "getByRole('button', { name: 'Save' })"
```

</extraction>

---

<patterns>

## Locator Patterns

### Role-based (recommended)

```javascript
page.getByRole('button', { name: 'Submit' });
page.getByRole('link', { name: 'Home' });
page.getByRole('textbox', { name: 'Email' });
page.getByRole('checkbox', { name: 'Remember' });
```

### Text-based

```javascript
page.getByText('Sign in');
page.getByText(/sign in/i); // regex
page.getByLabel('Email');
page.getByPlaceholder('Enter email');
```

### CSS selector

```javascript
page.locator('[data-testid="submit"]');
page.locator('input[name="email"]');
page.locator('button:has-text("Save")');
page.locator('li:nth-child(2)');
```

### Chaining / filtering

```javascript
page.locator('.card').locator('.price');
page.locator('tr').filter({ hasText: 'John' }).locator('button');
page.locator('.item').first();
page.locator('.item').nth(2);
```

</patterns>

---

<crawling_patterns>

## Crawling-oriented Patterns

```javascript
// list extraction
const links = await page.locator('.item-card a').evaluateAll((nodes) =>
  nodes.map((n) => (n as HTMLAnchorElement).href)
);

// structured data extraction
const rows = await page.locator('.item-card').evaluateAll((nodes) =>
  nodes.map((node) => ({
    id: (node as HTMLElement).dataset.id,
    title: node.querySelector('h2')?.textContent?.trim(),
  }))
);

// attribute extraction
const nextHref = await page.locator('a[rel="next"]').getAttribute('href');
```

</crawling_patterns>

---

<wait>

## Waiting Strategy

```javascript
await page.waitForSelector('.item-card');
await page.waitForLoadState('networkidle');
await page.locator('.item-card').first().waitFor({ state: 'visible' });
```

</wait>

---

<troubleshooting>

## Troubleshooting

| Problem | Fix |
|------|------|
| Too many matching elements | Use `.first()`, `.nth(n)`, or tighter selectors |
| Element not found | Add `waitForSelector`, inspect iframe/shadow DOM |
| Dynamic class names | Prefer role/text/data-testid selectors |

```javascript
// dynamic class workaround
const saveBtn = page.getByRole('button', { name: /save/i });
await saveBtn.click();
```

</troubleshooting>
