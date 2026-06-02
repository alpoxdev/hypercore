# Playwriter Commands

> Core command reference for crawling analysis.

Use this file after `pre-crawl-checklist.md` when the workflow already chose Playwriter-based discovery and you need concrete session, interaction, structure, or selector-validation commands. Use `cdp-capture.md` for lower-token network/auth evidence capture.

---

<session>

## Session

```bash
playwriter session new      # create session -> returns ID
playwriter session list     # list sessions
playwriter session reset 1  # reset session 1
```

</session>

---

<execution>

## Execute Code

```bash
playwriter -s 1 -e "<code>"
playwriter -s 1 --timeout 20000 -e "<code>"  # increase timeout
```

</execution>

---

<page>

## Page Control

```javascript
// create and navigate
state.page = await context.newPage();
await state.page.goto('https://example.com', { waitUntil: 'domcontentloaded' });

// find existing page by URL
state.page = context.pages().find((p) => p.url().includes('example.com'));
```

</page>

---

<structure>

## Structure Inspection

```javascript
// accessibility tree (recommended)
await accessibilitySnapshot({ page: state.page });
await accessibilitySnapshot({ page: state.page, search: /button|link/ });

// visual check with labels
await screenshotWithAccessibilityLabels({ page: state.page });

// clean HTML
await getCleanHTML({ locator: state.page.locator('body') });
```

</structure>

---

<interaction>

## Interaction

```javascript
// click
await page.locator('aria-ref=e14').click();
await page.getByRole('button', { name: 'Submit' }).click();

// input
await page.getByLabel('Email').fill('user@example.com');

// scroll
await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
```

</interaction>

---

<selector_extraction>

## Selector Extraction

```javascript
const selector = await getLocatorStringForElement(page.locator('aria-ref=e14'));
console.log(selector);
```

</selector_extraction>

---

<network_intercept>

## Network Interception Fallback

```javascript
state.responses = [];
state.page.on('response', async (res) => {
  if (!res.url().includes('/api/')) return;
  try {
    state.responses.push({
      url: res.url(),
      status: res.status(),
      body: await res.json(),
    });
  } catch {
    // ignore non-JSON responses
  }
});
```

Use this only when CDP is unavailable or when a quick browser-side fallback is enough.

</network_intercept>

---

<screenshot>

## Screenshot

```javascript
await state.page.screenshot({ path: 'page.png', fullPage: true });
await screenshotWithAccessibilityLabels({ page: state.page });
```

</screenshot>

---

<wait>

## Wait Patterns

```javascript
await page.waitForSelector('.item-card');
await page.waitForLoadState('networkidle');
await page.waitForTimeout(1000);
```

</wait>

---

<utilities>

## Utility Functions

| Function | Purpose |
|------|------|
| `accessibilitySnapshot({ page })` | Accessibility tree |
| `screenshotWithAccessibilityLabels({ page })` | Label screenshot |
| `getCleanHTML({ locator })` | Clean HTML output |
| `getLocatorStringForElement(locator)` | Convert to stable locator |
| `waitForPageLoad({ page })` | Page-load wait helper |

</utilities>
