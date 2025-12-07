# 타이포그래피

## 기본 원칙
- 폰트 2-3개만 (제목용, 본문용, 코드용)
- 크기로 계층 표현
- 일관된 스타일

## 폰트 선택

| 폰트 | 용도 |
|------|------|
| Pretendard | 한글 프로젝트 (권장) |
| Inter | 영문, 웹 전반 |
| Noto Sans KR | 다국어 프로젝트 |
| JetBrains Mono | 코드 |

## 크기 시스템

```css
text-xs     12px   작은 레이블
text-sm     14px   보조 텍스트
text-base   16px   본문 (기본)
text-lg     18px   강조 본문
text-xl     20px   소제목 (h4)
text-2xl    24px   섹션 제목 (h3)
text-3xl    30px   부제목 (h2)
text-4xl    36px   페이지 제목 (h1)
text-5xl    48px   히어로
```

```tsx
<h1 className="text-4xl font-bold">제목</h1>
<h2 className="text-2xl font-semibold">섹션</h2>
<p className="text-base">본문</p>
<span className="text-sm text-gray-500">보조</span>
```

## 줄 간격 (Line Height)

```css
leading-tight     1.25   제목
leading-normal    1.5    본문 (권장)
leading-relaxed   1.625  긴 글
```

## 굵기 (Font Weight)

```css
font-normal    400   본문
font-medium    500   약간 강조
font-semibold  600   부제목, 버튼
font-bold      700   제목
```

## 가독성 최적화

```tsx
// 줄 길이 제한 (45-75자)
<article className="max-w-prose mx-auto">

// 글자 간격
<h1 className="text-5xl tracking-tight">히어로</h1>
<span className="text-xs tracking-wide uppercase">LABEL</span>
```

## Tailwind 폰트 설정

```css
@theme {
  --font-sans: "Pretendard", "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", monospace;
}
```

## 체크리스트

- [ ] 폰트 2-3개 이하
- [ ] 본문 16px 이상
- [ ] 줄 간격 1.5 이상
- [ ] 제목/본문 명확한 크기 차이
