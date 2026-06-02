# Selector 전략

> Playwright Selector 우선순위 및 패턴

---

<priority>

## 우선순위

| 순위 | 유형 | 예시 | 안정성 |
|------|------|------|--------|
| 1 | aria-ref | `aria-ref=e14` | 세션 한정 |
| 2 | data-testid | `[data-testid="submit"]` | 매우 높음 |
| 3 | Role + Name | `getByRole('button', { name: 'Save' })` | 높음 |
| 4 | Text/Label | `getByText('Sign in')` | 중간 |
| 5 | Semantic | `button[type="submit"]` | 중간 |
| 6 | Class/ID | `.btn-primary` | 낮음 |

</priority>

---

<extraction>

## Selector 추출

```javascript
// aria-ref → Playwright selector
const snapshot = await accessibilitySnapshot({ page });
// => button "Save" [ref=e14]

const selector = await getLocatorStringForElement(page.locator('aria-ref=e14'));
// => "getByRole('button', { name: 'Save' })"
```

</extraction>

---

<patterns>

## Locator 패턴

### Role 기반 (권장)

```javascript
page.getByRole('button', { name: 'Submit' })
page.getByRole('link', { name: 'Home' })
page.getByRole('textbox', { name: 'Email' })
page.getByRole('checkbox', { name: 'Remember' })
```

### 텍스트 기반

```javascript
page.getByText('Sign in')
page.getByText(/sign in/i)  // 정규식
page.getByLabel('Email')
page.getByPlaceholder('Enter email')
```

### CSS Selector

```javascript
page.locator('[data-testid="submit"]')
page.locator('input[name="email"]')
page.locator('button:has-text("Save")')
page.locator('li:nth-child(2)')
```

### 체이닝/필터

```javascript
page.locator('.card').locator('.price')
page.locator('tr').filter({ hasText: 'John' }).locator('button')
page.locator('.item').first()
page.locator('.item').nth(2)
```

</patterns>

---

<crawling>

## 크롤링용 패턴

```javascript
// 목록 추출
const texts = await page.locator('.item').allTextContents();

// 구조화 데이터
const items = await page.$$eval('.card', cards =>
  cards.map(c => ({
    title: c.querySelector('h2')?.textContent?.trim(),
    url: c.querySelector('a')?.href,
  }))
);

// 속성 추출
const links = await page.$$eval('a', els => els.map(el => el.href));
```

</crawling>

---

<wait>

## 대기

```javascript
await page.waitForSelector('.loaded');
await page.waitForSelector('.loading', { state: 'hidden' });
await page.waitForLoadState('networkidle');
```

</wait>

---

<troubleshooting>

## 문제 해결

| 문제 | 해결 |
|------|------|
| 여러 요소 매칭 | `.first()`, `.nth(n)`, 더 구체적 selector |
| 요소 없음 | `waitForSelector`, iframe/Shadow DOM 확인 |
| 동적 클래스 | Role/Text 기반, data-testid 사용 |

```javascript
// 동적 클래스 해결
// ❌ page.locator('.Button_a1b2c3')
// ✅ page.getByRole('button', { name: 'Submit' })
// ✅ page.locator('[data-testid="submit"]')
```

</troubleshooting>
