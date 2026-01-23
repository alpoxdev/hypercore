# Figma → Code (100% Pixel-Perfect)

<context>

**Purpose:** Figma 디자인을 100% 정확하게 코드로 변환. Figma MCP로 디자인 토큰/레이아웃/에셋을 추출하여 픽셀 단위 정확도 보장.

**Trigger:** Figma 디자인 구현, 디자인 시스템 코드 생성, UI 컴포넌트 개발

**Key Features:**
- 픽셀 단위 정확도 (근사치 금지)
- 디자인 토큰 자동 추출 (Variables, Styles)
- 실제 에셋 다운로드 (AI 생성 금지)
- Auto Layout → Flexbox/Grid 정확한 매핑
- 반응형 디자인 필수 구현
- 에셋 WebP 압축 및 구조화

**Critical Rules (무조건 준수):**
1. 디자인을 임의로 해석하거나 "비슷하게" 만들지 않음
2. 모든 수치는 Figma에서 추출한 정확한 값 사용
3. 반응형 브레이크포인트 필수 구현 (모바일/태블릿/데스크톱)
4. 이미지는 반드시 WebP 압축 후 적재적소 폴더링
5. Figma 에셋만 사용 (AI 생성 절대 금지)

</context>

---

<prerequisites>

## 사전 준비

### Figma MCP 연결 확인

```bash
# Desktop MCP (로컬, 선택 기반)
claude mcp add --transport http figma-desktop http://127.0.0.1:3845/mcp

# Remote MCP (클라우드)
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```

**Desktop MCP 활성화:**
1. Figma 데스크톱 앱 실행
2. 파일 열기 → Dev Mode 전환
3. Inspect 패널에서 "Enable desktop MCP server" 클릭

### Figma 파일 구조화 (디자이너 가이드)

| 항목 | 필수 사항 |
|------|----------|
| **Auto Layout** | 모든 Frame에 Auto Layout 적용 |
| **Variables** | 색상/간격/폰트 크기를 Variables로 정의 |
| **Components** | 재사용 요소는 Component로 분리 |
| **Naming** | 레이어명: PascalCase (Button, CardHeader) |
| **Annotations** | 호버/클릭 등 인터랙션 주석으로 설명 |

</prerequisites>

---

<workflow>

## 워크플로우 (5단계)

### Phase 0: 프로젝트 환경 파악

**목표:** Vite/Next.js 환경 감지 및 기존 토큰 확인

```
1. 프레임워크 감지
   - Vite: vite.config.js/ts 존재 여부 확인
   - Next.js: next.config.js/ts 존재 여부 확인

2. globals.css 위치 파악
   Vite:
   - src/index.css
   - src/main.css
   - src/app.css

   Next.js:
   - app/globals.css (App Router)
   - styles/globals.css (Pages Router)

3. 기존 @theme 블록 확인
   @import "tailwindcss";

   @theme {
     --color-primary: #xxx;
     --spacing-md: 16px;
     ...
   }

4. Tailwind CSS 버전 확인
   - v4 사용 확인 (package.json에서 tailwindcss: ^4.0.0)
   - v4 아닐 경우 업그레이드 권장
```

**Tailwind v4 특징:**
- **설정 파일 없음**: tailwind.config.js 제거 → CSS 파일에 @theme 직접 작성
- **자동 클래스 생성**: `@theme { --color-primary: #xxx; }` → `bg-primary` 자동
- **globals.css 통합**: 모든 토큰을 한 곳에서 관리

### Phase 1: 분석 (Extract)

**목표:** Figma에서 정확한 디자인 데이터 추출

```
1. Figma 파일/컴포넌트 선택 확인
   - Desktop MCP: 레이어 선택 후 작업
   - Remote MCP: 파일 URL 제공

2. Variables & Styles 추출
   - 색상: Color Variables → CSS Variables / Tailwind config
   - 타이포그래피: Text Styles → font-size, line-height, weight
   - 간격: Spacing Variables → margin, padding, gap

3. Auto Layout 구조 파악
   - Direction: Horizontal → flex-row, Vertical → flex-col
   - Alignment: align-items, justify-content
   - Spacing: gap 값

4. 에셋 목록 생성
   - 이미지: 다운로드 링크 추출
   - 아이콘: SVG export
   - 로고/일러스트: PNG/WebP
   - 에셋 타입별 분류 (hero/icons/logos/illustrations)

5. 반응형 브레이크포인트 확인 (필수)
   Figma Constraints 분석:
   - Mobile: 320px ~ 767px
   - Tablet: 768px ~ 1023px
   - Desktop: 1024px+

   각 브레이크포인트별 확인:
   - 레이아웃 변화 (Grid → List, Horizontal → Vertical)
   - 폰트 크기 변화
   - 간격 조정
   - 숨김/표시 요소
```

**상세:** [references/figma-mcp-tools.md](references/figma-mcp-tools.md)

### Phase 2: 구조화 (Structure)

**목표:** Figma Frame 계층 → React 컴포넌트 구조 + Tailwind v4 토큰 생성

```
1. Frame Hierarchy 분석
   Frame "Header"
   ├─ Frame "Logo" → <div className="logo">
   ├─ Frame "Navigation" → <nav>
   └─ Frame "Actions" → <div className="actions">

2. Design Tokens → @theme 블록 (Tailwind v4)

   A. globals.css 확인
      - 기존 @theme 블록이 있으면 병합
      - 없으면 새로 생성

   B. Figma Variables → @theme 매핑

   Vite (src/index.css 또는 src/main.css):
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

     /* 기존 토큰이 있다면 충돌 방지 */
     /* --color-brand: #xxx; (기존) */
   }
   ```

   Next.js (app/globals.css):
   ```css
   @import "tailwindcss";

   @theme {
     /* 동일한 구조 */
   }
   ```

   C. 자동 클래스 생성 확인
      @theme { --color-primary: #3182F6; }
      → bg-primary, text-primary, border-primary 자동 생성

   D. 기존 globals.css 토큰 병합
      ```css
      @theme {
        /* 기존 토큰 (유지) */
        --color-brand: #FF5733;

        /* Figma에서 추출한 토큰 (추가) */
        --color-primary: #3182F6;
        --spacing-md: 16px;
      }
      ```

3. Component 분리 기준
   - 재사용 가능 → 별도 컴포넌트
   - 한 번만 사용 → inline
```

**상세:**
- [references/design-tokens.md](references/design-tokens.md)
- [references/layout-mapping.md](references/layout-mapping.md)

### Phase 3: 구현 (Implement)

**목표:** 정확한 수치로 코드 작성

#### 레이아웃 구현

```tsx
// ❌ 임의의 값
<div className="flex gap-4 p-6">

// ✅ Figma 정확한 값
<div className="flex gap-[18px] p-[24px]">
</div>
```

#### 색상 구현

```tsx
// ❌ 비슷한 색상
<button className="bg-blue-500">

// ✅ @theme 토큰 (Tailwind v4)
<button className="bg-primary">

// ✅ 또는 정확한 HEX
<button className="bg-[#3182F6]">
```

#### 타이포그래피 구현

```tsx
// ❌ 근사치
<h1 className="text-2xl font-bold">

// ✅ 정확한 값
<h1 className="text-[28px] leading-[36px] font-semibold tracking-[-0.02em]">
```

#### 에셋 처리 (필수)

**1. Figma에서 에셋 다운로드**
```bash
# Figma MCP로 이미지 다운로드 링크 생성
get_images → 다운로드 URL 획득
```

**2. WebP 압축 (필수)**

**주의:** PNG/JPG/JPEG 파일만 WebP로 압축합니다. SVG 파일은 변환하지 않고 그대로 사용합니다.

```bash
# cwebp 사용 (Google WebP)
cwebp -q 80 input.png -o output.webp
cwebp -q 80 input.jpg -o output.webp

# 또는 ImageMagick
convert input.png -quality 80 output.webp
convert input.jpg -quality 80 output.webp

# 일괄 변환 (PNG/JPG/JPEG만, SVG 제외)
for file in *.{png,jpg,jpeg}; do
  [ -f "$file" ] || continue
  cwebp -q 80 "$file" -o "${file%.*}.webp"
done
```

**압축 품질 가이드:**
| 용도 | 품질 | 용량 |
|------|------|------|
| Hero 이미지 | 85-90 | 고화질 |
| 일반 이미지 | 75-85 | 균형 |
| 썸네일 | 60-75 | 최적화 |

**3. public 폴더 구조화 (필수)**
```
public/
├── images/
│   ├── hero/           # Hero 섹션 이미지
│   │   ├── banner.webp
│   │   └── background.webp
│   ├── products/       # 제품 이미지
│   │   ├── product-1.webp
│   │   └── product-2.webp
│   ├── team/           # 팀 사진
│   │   └── member-1.webp
│   └── thumbnails/     # 썸네일
│       └── thumb-1.webp
├── icons/              # 아이콘 (SVG)
│   ├── social/
│   │   ├── facebook.svg
│   │   └── twitter.svg
│   └── ui/
│       ├── arrow.svg
│       └── close.svg
└── logos/              # 로고
    ├── logo.svg
    └── logo-white.svg
```

**4. 코드에서 사용**
```tsx
// ❌ AI 생성/임의 이미지
<img src="/placeholder.jpg" alt="Hero" />

// ✅ Figma 실제 에셋 + WebP + 구조화된 경로
<img
  src="/images/hero/banner.webp"
  alt="Hero Banner"
  width={1200}
  height={600}
  loading="lazy"
/>

// 아이콘
<img src="/icons/ui/arrow.svg" alt="" width={24} height={24} />

// 로고
<img src="/logos/logo.svg" alt="Company Logo" width={120} height={40} />
```

**5. 반응형 이미지**
```tsx
<picture>
  <source media="(min-width: 1024px)" srcSet="/images/hero/banner-desktop.webp" />
  <source media="(min-width: 768px)" srcSet="/images/hero/banner-tablet.webp" />
  <img src="/images/hero/banner-mobile.webp" alt="Hero" />
</picture>
```

### Phase 4: 검증 (Verify)

**목표:** 디자인과 코드의 정확도 검증

```
체크리스트:
□ 색상: Figma Color Picker와 Dev Tools 비교
□ 간격: 모든 margin/padding/gap 값 일치
□ 폰트: size, weight, line-height 정확히 일치
□ 레이아웃: Auto Layout 구조 그대로 반영

□ 에셋 (필수):
  □ Figma에서 다운로드한 실제 파일 사용
  □ WebP 압축 완료 (PNG/JPG → WebP)
  □ public/ 폴더 구조화 (images/icons/logos)
  □ 파일명 명확 (hero-banner.webp, product-1.webp)
  □ 적절한 압축 품질 (hero: 85-90, 일반: 75-85)

□ 반응형 (필수):
  □ Mobile (320-767px) 레이아웃 확인
  □ Tablet (768-1023px) 레이아웃 확인
  □ Desktop (1024px+) 레이아웃 확인
  □ 미디어 쿼리 정확한 브레이크포인트
  □ 반응형 이미지 (<picture> 또는 srcSet)
  □ 모든 디바이스에서 Figma 디자인 일치
```

**상세:** [references/verification.md](references/verification.md)

</workflow>

---

<best_practices>

## 베스트 프랙티스

### DO

| 원칙 | 설명 |
|------|------|
| **Exact Values** | `px-4` 대신 `px-[18px]` (정확한 값) |
| **@theme First** | Figma Variables → @theme 블록 (Tailwind v4) |
| **Merge Existing Tokens** | globals.css 기존 토큰 유지 + 새 토큰 병합 |
| **Extract Before Implement** | 구현 전 모든 토큰/에셋 추출 완료 |
| **WebP Only** | 모든 이미지 WebP 압축 (PNG/JPG 금지) |
| **Structured Assets** | public/images/[category]/ 폴더 구조 |
| **Responsive Required** | Mobile/Tablet/Desktop 모두 구현 |
| **Cross-Validate** | Figma Dev Mode + MCP + 수동 확인 |
| **Document Mapping** | 주석으로 Figma 속성 명시 |

### DON'T

| 금지 사항 | 이유 |
|----------|------|
| **근사치 사용** | "비슷한 값"은 디자인 불일치 유발 |
| **AI 생성 에셋** | 디자이너가 제작한 실제 에셋만 사용 |
| **PNG/JPG 사용** | 반드시 WebP 압축 후 사용 |
| **public/ 루트에 이미지** | 폴더 구조화 필수 (images/icons/logos) |
| **반응형 생략** | Mobile/Tablet/Desktop 모두 필수 |
| **임의 해석** | Auto Layout 무시하고 수동 레이아웃 |
| **Tailwind 기본값** | `gap-4` 대신 정확한 `gap-[18px]` |
| **tailwind.config.js 사용** | Tailwind v4는 @theme 블록 사용 |
| **기존 토큰 덮어쓰기** | globals.css 기존 토큰 유지 필수 |

### 프롬프트 예시

```
이 Figma 컴포넌트를 코드로 만들어줘.

환경:
- Vite/Next.js (프로젝트 구조 확인)
- Tailwind CSS v4 사용
- globals.css 기존 토큰 유지

Critical Rules (무조건 준수):
1. Phase 0: 프로젝트 환경 파악 (Vite/Next.js, globals.css 위치)
2. Phase 1: Figma MCP로 Variables, Text Styles, Auto Layout, 브레이크포인트 추출
3. Phase 2: @theme 블록에 토큰 추가 (기존 토큰 병합)
4. Phase 3: 모든 수치는 정확히 일치 (근사치 금지)

에셋 처리 (필수):
- Figma에서 다운로드 (AI 생성 절대 금지)
- PNG/JPG → WebP 압축 (품질 75-90)
- public/images/[category]/ 구조화
- 파일명 명확 (hero-banner.webp, product-1.webp)

반응형 (필수):
- Mobile (320-767px): 레이아웃 변화 확인
- Tablet (768-1023px): 레이아웃 변화 확인
- Desktop (1024px+): 레이아웃 변화 확인
- 반응형 이미지 (<picture> 또는 srcSet)

검증:
- 색상/간격/폰트: Figma와 100% 일치
- 에셋: WebP 압축 및 폴더 구조 확인
- 반응형: 모든 디바이스에서 Figma 디자인 일치
- @theme 토큰 자동 클래스 생성 확인
```

</best_practices>

---

<troubleshooting>

## 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| MCP 연결 안 됨 | Desktop MCP 미활성화 | Figma Dev Mode에서 Enable |
| 색상 불일치 | Variables 대신 직접 색상 사용 | Variables 먼저 추출 |
| 간격 오차 | Tailwind 기본값 사용 | 정확한 px 값으로 override |
| 레이아웃 깨짐 | Auto Layout 구조 무시 | Frame 계층 그대로 변환 |
| 에셋 누락 | export 설정 미확인 | Export Settings 확인 후 다운로드 |

</troubleshooting>

---

<references>

## 상세 문서

| 문서 | 내용 |
|------|------|
| [figma-mcp-tools.md](references/figma-mcp-tools.md) | Figma MCP 도구 사용법, API 엔드포인트 |
| [design-tokens.md](references/design-tokens.md) | Variables/Styles 추출 및 Tailwind v4 매핑 |
| [layout-mapping.md](references/layout-mapping.md) | Auto Layout → Flexbox/Grid 변환 규칙 |
| [responsive-design.md](references/responsive-design.md) | 반응형 구현 가이드 (브레이크포인트, 이미지) |
| [verification.md](references/verification.md) | 디자인-코드 정확도 검증 체크리스트 |

## 외부 참조

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Design Tokens with Figma](https://blog.prototypr.io/design-tokens-with-figma-aef25c42430f)
- [Pixel-Perfect Code Generation Guide](https://medium.com/@reuvenaor85/the-way-to-figma-mcp-pixel-perfect-code-generation-for-react-tailwind-1623fd5383b8)

</references>
