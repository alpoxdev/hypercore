# 디자인-코드 검증 가이드

Figma 디자인과 코드의 정확도를 검증하는 체크리스트.

---

## 검증 체크리스트

### 색상

| 확인 항목 | 방법 |
|----------|------|
| Figma 값 | Color Picker → #3182F6 |
| 브라우저 값 | DevTools → Computed → `background-color` |
| 일치 확인 | `getComputedStyle(el).backgroundColor` |

```
□ Primary/Secondary 색상
□ Semantic 색상 (success/error/warning)
□ 텍스트/배경/보더 색상
```

### 간격

| 확인 항목 | 방법 |
|----------|------|
| Figma 값 | Auto Layout → Gap 18px, Padding 24px |
| 브라우저 값 | DevTools → Layout → Box Model |
| 일치 확인 | `getComputedStyle(el).gap` |

```
□ gap 값
□ padding (top/right/bottom/left)
□ margin (있을 경우)
```

### 타이포그래피

| 확인 항목 | 방법 |
|----------|------|
| Figma 값 | Text Style → 28px/600/36px/-0.02em |
| 브라우저 값 | DevTools → Computed |
| 일치 확인 | `getComputedStyle(el).fontSize` |

```
□ font-family
□ font-size
□ font-weight
□ line-height
□ letter-spacing
```

### 레이아웃

| 확인 항목 | 방법 |
|----------|------|
| Figma 값 | Auto Layout → Horizontal/Center/Center |
| 브라우저 값 | DevTools → Layout → Flexbox |
| 일치 확인 | `getComputedStyle(el).display` |

```
□ display: flex
□ flex-direction
□ justify-content
□ align-items
□ gap
```

### 크기

| 확인 항목 | 방법 |
|----------|------|
| Figma 값 | Button → 120x44px |
| 브라우저 값 | DevTools → Layout → width/height |
| 일치 확인 | `el.getBoundingClientRect()` |

```
□ width
□ height
□ min-width/max-width
□ min-height/max-height
```

### 에셋 (필수)

```
□ Figma 다운로드 파일 사용 (AI 생성 X)
□ WebP 압축 완료
□ public/images/[category]/ 구조
□ 파일명 명확 (hero-banner.webp)
□ 적절한 압축 품질 (hero: 85-90, 일반: 75-85)
```

### 반응형 (필수)

```
□ Mobile (320-767px) 레이아웃 확인
  □ Grid → List 변환
  □ 폰트 크기 축소
  □ 간격 축소
  □ Hamburger 메뉴

□ Tablet (768-1023px) 레이아웃 확인
  □ 2단 그리드
  □ 중간 폰트 크기
  □ 중간 간격

□ Desktop (1024px+) 레이아웃 확인
  □ 4단 그리드
  □ 큰 폰트 크기
  □ 넓은 간격
  □ 전체 메뉴

□ 반응형 이미지 (<picture> 또는 srcSet)
□ 미디어 쿼리 정확한 브레이크포인트
```

---

## 검증 도구

### DevTools 단축키

| 기능 | 단축키 |
|------|--------|
| DevTools 열기 | F12 또는 Cmd+Opt+I |
| Device Toolbar | Cmd+Shift+M |
| Inspect Element | Cmd+Shift+C |

### Console 스니펫

```js
// 색상 확인
const el = document.querySelector('.button')
console.log(getComputedStyle(el).backgroundColor)

// 간격 확인
const padding = {
  top: getComputedStyle(el).paddingTop,
  right: getComputedStyle(el).paddingRight,
  bottom: getComputedStyle(el).paddingBottom,
  left: getComputedStyle(el).paddingLeft,
}
console.table(padding)

// 타이포그래피 확인
const typography = {
  fontFamily: getComputedStyle(el).fontFamily,
  fontSize: getComputedStyle(el).fontSize,
  fontWeight: getComputedStyle(el).fontWeight,
  lineHeight: getComputedStyle(el).lineHeight,
  letterSpacing: getComputedStyle(el).letterSpacing,
}
console.table(typography)

// 크기 확인
const rect = el.getBoundingClientRect()
console.log(`Width: ${rect.width}px, Height: ${rect.height}px`)
```

---

## 시각적 비교

### 오버레이 도구

| 도구 | 용도 |
|------|------|
| [PerfectPixel](https://chrome.google.com/webstore/detail/perfectpixel) | Chrome 확장 프로그램 |
| Figma Inspect | Figma Dev Mode → Compare to design |

### 사용 방법

```
1. Figma Export as PNG (2x)
2. 브라우저 스크린샷
3. 오버레이 도구로 비교
4. 차이점 수정
```

---

## 자동화

### Visual Regression Testing

```bash
# Percy 설치
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

## 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| 색상 불일치 | Variables 대신 하드코딩 | Variables 추출 |
| 간격 불일치 | Tailwind 기본값 (`gap-4`) | 정확한 값 (`gap-[18px]`) |
| 폰트 불일치 | letter-spacing 변환 오류 | PERCENT → em 변환 확인 |
| 레이아웃 깨짐 | Auto Layout 무시 | Frame 계층 그대로 변환 |

---

## 참조

- [Chrome DevTools](https://developer.chrome.com/docs/devtools/)
- [Percy Visual Testing](https://percy.io/)
- [Figma Dev Mode](https://help.figma.com/hc/en-us/articles/15023124644247)
