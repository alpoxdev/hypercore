# @kood/color-cli

CSS 색상 변환 CLI. hex, rgb, oklch 간 정확한 변환을 제공합니다.

AI가 oklch 변환을 정확하게 하지 못하는 문제를 해결하기 위해, [culori](https://culorijs.org/) 라이브러리(CSS Color Level 4 준수, Tailwind CSS v4 사용)를 핵심 엔진으로 사용합니다.

## 설치

```bash
cd cli && pnpm install && pnpm build
```

글로벌 링크 (선택):

```bash
cd cli/packages/color && pnpm link --global
```

## 사용법

### 단일 색상 변환

색상값을 인자로 전달하면 형식을 자동 감지하여 hex, rgb, oklch 모두 출력합니다.

```bash
color "#ff0000"
color "oklch(0.7 0.25 140)"
color "rgb(255, 0, 0)"
```

출력 예시:

```
HEX:   #ff0000
RGB:   rgb(255, 0, 0)
OKLCH: oklch(0.6280 0.2577 29.23)
```

### 여러 색상 동시 변환

```bash
color "#e63946" "oklch(0.7 0.25 140)" "rgb(0, 128, 255)"
```

### JSON 출력

```bash
color --json "#ff0000"
```

```json
{
  "hex": "#ff0000",
  "rgb": "rgb(255, 0, 0)",
  "oklch": "oklch(0.6280 0.2577 29.23)",
  "originalFormat": "rgb",
  "gamutMapped": false
}
```

### CSS 파일 색상 변환

CSS 파일 내 모든 색상을 지정한 형식으로 일괄 변환합니다.

```bash
# 모든 색상을 oklch로 변환
color css styles.css --to oklch

# hex로 변환
color css styles.css --to hex

# rgb로 변환
color css styles.css --to rgb

# 미리보기만 (파일 수정 안 함)
color css styles.css --to oklch --dry-run
```

출력 예시:

```
styles.css: 12 colors found, 8 converted, 4 skipped

  L3:  #ff0000 → oklch(0.6280 0.2577 29.23)
  L7:  rgb(0, 128, 255) → oklch(0.6171 0.1884 254.42)

Done. File updated.
```

## 지원 형식

| 형식     | 입력 예시                                          |
| -------- | -------------------------------------------------- |
| hex      | `#rgb`, `#rrggbb`, `#rrggbbaa`                     |
| rgb/rgba | `rgb(255, 0, 0)`, `rgba(255, 0, 0, 0.5)`           |
| oklch    | `oklch(0.7 0.25 140)`, `oklch(0.7 0.25 140 / 0.5)` |
| hsl      | `hsl(0, 100%, 50%)`                                |

culori가 지원하는 모든 CSS 색상 문법을 인식합니다.

## Gamut Mapping

oklch는 sRGB보다 넓은 색공간입니다. sRGB 범위 밖의 oklch 값은 CSS Color Level 4 표준의 chroma-reduction gamut mapping을 적용하여 변환합니다.

- naive clipping (단순 클램핑) 대신 binary-search chroma-reduction 사용
- 밝기(L)와 색상(H)을 보존하고 채도(C)만 줄임

범위 밖 색상이 감지되면 경고를 표시합니다:

```
⚠ Color was outside sRGB gamut — CSS Color Level 4 chroma-reduction applied.
```

## 개발

```bash
# 테스트
cd cli && pnpm test

# 빌드
cd cli && pnpm build

# 로컬 실행
node cli/packages/color/dist/index.js "#ff0000"
```

## 기술 스택

- [culori](https://culorijs.org/) — 색상 변환 엔진 (CSS Color Level 4 준수)
- [tsup](https://tsup.egoist.dev/) — ESM 번들링
- [vitest](https://vitest.dev/) — 테스트
- TypeScript, ESM
