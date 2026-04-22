---
name: color-cli
description: '@kood/color-cli를 사용해 hex, rgb, oklch 사이에서 색상을 변환합니다. 사용자가 색상 변환, CSS 파일 색상 일괄 변환, 정확한 oklch 값 계산을 원할 때 사용합니다. 트리거 문구 예: "color convert", "hex to oklch", "oklch to hex", "rgb to oklch", "CSS 색상 변환", "색상 변환", "oklch 값 알려줘".'
compatibility: Bash 도구가 필요합니다. `@kood/color-cli`가 전역 설치되어 있어야 합니다 (`npm i -g @kood/color-cli`).
---

# Color CLI

> `@kood/color-cli`를 사용해 hex, rgb, oklch 색상을 정확하게 변환합니다.

AI 모델은 행렬 정밀도 오차, gamut mapping 누락, degree/radian 혼동 때문에 oklch 변환을 자주 틀립니다. 이 스킬은 `@kood/color-cli`(culori 기반)에 변환을 위임해 CSS Color Level 4에 맞는 결과를 얻습니다.

<request_routing>

## 긍정 트리거

- "#ff0000을 oklch로 변환해줘"
- "rgb(0, 128, 255)의 oklch 값 알려줘"
- "styles.css 색상 전부 oklch로 바꿔줘"
- "hex to rgb", "oklch to hex", "색상 변환해줘"
- "이 CSS 파일 색상을 hex로 통일해줘"

## 범위 밖

- 색상 팔레트 생성이나 디자인 제안 — 디자인 스킬을 사용한다.
- 색채 이론 설명 — 스킬 없이 직접 답한다.
- CSS를 새로 작성하는 작업 — 구현 스킬을 사용한다.

## 경계

- "oklch(0.7 0.25 140)는 무슨 색이야?" → 이 스킬로 hex/rgb 대응값을 구한다.
- "버튼에 어울리는 색 하나 골라줘" → 디자인 질문이므로 이 스킬을 쓰지 않는다.

</request_routing>

<prerequisites>

`@kood/color-cli`가 아직 없으면 먼저 전역 설치한다:

```bash
npm i -g @kood/color-cli
```

설치 확인:

```bash
color --help
```

`color` 명령을 찾을 수 없으면 설치를 끝낸 뒤 진행한다.

</prerequisites>

<workflow>

## 단일 색상 변환

사용자가 특정 색상 값을 변환해 달라고 하면:

```bash
color "<value>"
```

예시:

```bash
color "#ff0000"
color "oklch(0.7 0.25 140)"
color "rgb(255, 0, 0)"
color "hsl(0, 100%, 50%)"
```

프로그래밍용 JSON 출력이 필요하면:

```bash
color --json "#ff0000"
```

여러 색상을 한 번에 변환할 수도 있다:

```bash
color "#e63946" "oklch(0.7 0.25 140)" "rgb(0, 128, 255)"
```

## CSS 파일 색상 변환

사용자가 CSS 파일의 모든 색상을 특정 포맷으로 바꾸고 싶어 하면:

**먼저 미리보기(dry run):**

```bash
color css <file> --to <format> --dry-run
```

**적용(in-place):**

```bash
color css <file> --to <format>
```

지원 대상 포맷: `hex`, `rgb`, `oklch`.

예시:

```bash
# oklch 변환 미리보기
color css styles.css --to oklch --dry-run

# hex로 적용
color css src/global.css --to hex

# rgb로 변환
color css theme.css --to rgb
```

### CSS 변환 동작

- 파일 안의 hex, rgb, rgba, oklch 패턴을 자동 감지한다.
- 이미 목표 포맷인 색상은 건너뛴다.
- alpha 값을 보존한다. 예: `rgba(255,0,0,0.5)` → `oklch(0.628 0.258 29.23 / 0.5)`
- CSS 주석(`/* ... */`) 내부 색상은 무시한다.
- sRGB 밖의 oklch 값에는 CSS Color Level 4 gamut mapping을 적용한다.

</workflow>

<output_interpretation>

## 단일 색상 출력

```text
HEX:   #ff0000
RGB:   rgb(255, 0, 0)
OKLCH: oklch(0.6280 0.2577 29.23)
```

## Gamut mapping 경고

도구가 다음과 같은 경고를 출력할 수 있다:

```text
⚠ Color was outside sRGB gamut — CSS Color Level 4 chroma-reduction applied.
```

이는 원래 oklch 값이 sRGB gamut 밖이라, lightness와 hue를 유지한 채 chroma를 줄여 맞췄다는 뜻이다.

## CSS 변환 요약

```text
styles.css: 12 colors found, 8 converted, 4 skipped
```

- **converted**: 목표 포맷으로 실제 변경된 색상 수
- **skipped**: 이미 목표 포맷이라 바꾸지 않은 색상 수

</output_interpretation>

<guidelines>

- CSS 파일 변환은 항상 먼저 `--dry-run`으로 미리 보여 준 뒤, 사용자가 적용을 원할 때만 반영한다.
- 사용자가 oklch 값을 주면 수동 계산하지 말고 반드시 도구로 변환한다. AI 모델은 oklch ↔ hex 매핑을 자주 틀린다.
- 사용자에게는 hex, rgb, oklch 결과를 모두 보여 줘서 필요한 포맷을 고를 수 있게 한다.
- CSS 파일 작업에서는 converted/skipped 요약도 함께 알려 준다.

</guidelines>
