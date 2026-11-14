# 시안 브리프

최소 토큰을 정하거나 화면의 브리프를 쓸 때 이 참조를 읽습니다. 브리프는 한 테마의 화면 하나를 빠짐없이 서술한 글이고, 이미지 스킬이 레퍼런스를 보지 않고도 렌더링할 수 있게 씁니다.

## Contents

1. 브리프에 담는 것
2. 플랫폼별 캔버스
3. 브리프 뼈대
4. 최소 토큰 세트
5. 라이트와 다크
6. 수정 브리프

## 1. 브리프에 담는 것

| 담는 것 | 절대 담지 않는 것 |
|---|---|
| 화면의 목적 한 줄 | 제품, 브랜드, 디자이너 이름 |
| 플랫폼 프레임과 말로 쓴 캔버스 모양 | 레퍼런스 URL이나 레퍼런스 이미지 |
| 토큰 값: HEX 색, 글자 크기, 모서리, 간격 | 모델 이름이나 모델 옵션 |
| 위에서 아래로 본 영역과 그 컴포넌트 | 실제 개인 정보 |
| 렌더링할 정확한 문자열을 한 번씩, 역할과 자리와 함께 | 긴 본문 |
| 나오면 안 되는 것 | 한 이미지에 여러 화면을 넣으라는 요청 |

브리프 하나는 한 테마의 화면 하나이고 이미지 하나를 만듭니다.

## 2. 플랫폼별 캔버스

프레임은 시안이 나타내는 논리 화면입니다. 캔버스는 이미지 스킬에 요청하는 모양입니다. 브리프 안에는 모양을 말로 서술하고, 실제 비율이나 크기는 이미지 스킬의 구조화된 캔버스 값으로만 넘깁니다.

| 플랫폼 | 디자인 기준 논리 프레임 | 캔버스 모양 | 프레임 메모 |
|---|---|---|---|
| `mobile` | 390×844, 세로 | 긴 세로, 약 9:19.5 | 위에 상태 바, 아래에 홈 인디케이터, 하단 내비게이션은 안전 영역 안 |
| `tablet` | 세로 1024×1366 또는 가로 1366×1024 | 세로 약 3:4 또는 가로 약 4:3 | 방향을 밝힙니다. 가로 태블릿은 보통 사이드 레일이나 두 패널을 둡니다 |
| `web` | 1440×900 데스크톱 뷰포트 | 가로, 약 16:10 | 사용자가 요청하지 않으면 브라우저 틀 없이 뷰포트 안의 페이지만 그립니다 |

- 런타임이 모양을 몇 가지만 제공하면 같은 방향에서 가장 가까운 것을 고르고, 요청한 모양과 돌아온 모양을 메모에 적으며, 반환된 이미지를 자르거나 크기를 바꾸지 않습니다.
- 긴 페이지는 첫 뷰포트로 그립니다. 그 아래 섹션은 각각 뷰포트 하나 높이의 별도 브리프입니다.
- 화면을 평평하게 정면으로, 가장자리까지 그립니다. 기기 사진, 원근, 손, 책상, 화면 둘레 그림자는 레이아웃을 가리므로 넣지 않습니다.
- 좁은 웹 레이아웃은 웹 프레임 메모를 붙인 `mobile` 브리프입니다.

## 3. 브리프 뼈대

모든 줄을 채웁니다. invariant로 표시한 줄은 세트의 모든 브리프에 글자 그대로 반복합니다.

```text
Screen: <name> - <one-line purpose>
Platform and frame: <mobile | tablet portrait | tablet landscape | web desktop>, flat straight-on UI screen, edge to edge  [invariant]
Canvas shape: <words only, e.g. tall portrait>  [invariant]
Theme: <light | dark>

Tokens  [invariant per theme]
- Background <hex>, surface <hex>, border <hex>
- Text primary <hex>, text secondary <hex>
- Accent <hex>, text on accent <hex>, danger <hex>
- Typeface character: <e.g. a clean neutral sans-serif with Hangul support>
- Type sizes: title <n>, body <n>, caption <n>
- Corner radius: controls <n>, cards <n>
- Spacing unit <n>; screen side padding <n>; gap between groups <n>

Shared components  [invariant]
- Buttons: <shape, height, fill rule>
- Fields: <shape, label position>
- Icons: <one style, e.g. simple outlined line icons, one weight>
- System bars: <status bar and navigation treatment>

Regions, top to bottom
1. <region>: <components, alignment, relative size>
2. ...

Primary action: <one, with its place>

Text to render (exact, each once)
- "<string>" - <role>, <place by region or by top/middle/bottom and left/center/right>
- ...
Other text: short neutral bars in the text color, no readable sentences

Must not appear: brand logos or names, real app icons, watermarks, device frame, extra screens, invented statistics
```

호출 전에 브리프 옆에 적어 둘 점검은 다음과 같습니다.

- 영역이 밝힌 순서대로 있다
- 렌더링한 문자열이 한 번씩 나오고 한 글자씩 일치한다
- 주 동작이 하나이고 강조색이다
- 로고, 브랜드 이름, 기기 프레임이 없다
- 캔버스 방향이 일치한다

## 4. 최소 토큰 세트

프로젝트에 디자인 문서나 토큰이 없을 때만 씁니다. 여러 시안의 일관성을 지키는 가장 작은 세트이고 `provisional`로 기록합니다.

| 묶음 | 토큰 | 고르는 방법 |
|---|---|---|
| 색 | 배경, 표면, 테두리, 주 글자, 보조 글자, 강조, 강조 위 글자, 위험 | 강조색은 하나만 둡니다. 사용자가 밝힌 색이 있으면 그것을 강조색으로 쓰고, 없으면 하나를 고르고 골랐다고 밝힙니다. 나머지는 모두 무채색이 맡습니다. |
| 글꼴 | 서체 성격 하나, 제목·본문·캡션 크기, 굵기 둘 | 프로젝트가 이미 쓰는 글꼴이 없으면 라이선스가 걸린 글꼴 이름이 아니라 성격을 적습니다. 본문 크기는 논리 단위로 웹 16, 모바일 15보다 작지 않게 합니다. |
| 모서리 | 컨트롤용 값 하나, 카드용 값 하나 | 최대 두 값입니다. |
| 간격 | 기준 단위 하나와 좌우 여백·묶음 간격에 쓰는 배수 | 기준은 4나 8이고 배수로만 씁니다. |

규칙은 다음과 같습니다.

- 쓰기 전에 주 글자, 보조 글자, 강조 위 글자의 대비를 각 배경에 대해 계산하고, 각각 최소 기준을 통과할 때까지 토큰을 조정합니다.
- 브랜드 색처럼 사용자가 밝힌 요구사항은 받은 그대로 세트에 넣습니다. 글자색으로 대비를 통과하지 못하면 채움에만 쓰고 통과하는 글자색을 따로 고른 뒤 그렇게 했다고 밝힙니다.
- 최소 세트에 두 번째 강조색, 그라데이션, 장식 스타일을 더하지 않습니다. 그것은 시각 방향에 속하고 별도 산출물입니다.
- 임시 세트는 임시라고 밝혀 넘깁니다. 구현자는 사용자가 받아들이기 전까지 그것을 프로젝트의 디자인 시스템으로 취급하지 않습니다.

## 5. 라이트와 다크

- 테마마다 자체 토큰 열을 가진 별도 브리프와 이미지입니다.
- 다크 토큰은 반전하지 않고 고릅니다. 순수한 검정이 아닌 어두운 배경, 배경보다 한 단계 밝은 표면, 여전히 보이는 테두리, 위에 놓인 글자가 대비를 통과하도록 조정한 강조색입니다.
- 두 브리프 사이에는 Theme 줄과 Tokens 블록만 바뀝니다. 영역, 문자열, 컴포넌트는 같게 두어 두 이미지를 비교할 수 있게 합니다.
- `both`면 라이트 버전을 먼저 생성하고 검토합니다.

## 6. 수정 브리프

- 앞선 브리프를 통째로 복사합니다.
- 한 가지를 바꾸고 맨 위에 한 줄을 더합니다: `Revision <n>: <what changed and why>`.
- 실패가 렌더링된 글자였다면 다른 것을 바꾸기 전에 렌더링할 문자열 수를 줄입니다.
- 실패가 세트의 화면 사이 흔들림이었다면 다른 이미지를 묘사하지 않고 흔들린 불변 요소를 더 정확히 다시 적습니다.

## Sources

> Checked 2026-11-15.

| Claim | Source |
|---|---|
| 모바일·태블릿·웹 대상, 라이트·다크 테마, 프로젝트 토큰 먼저, 없으면 색·글꼴·모서리·간격의 최소 세트 | user instruction, 2026-11-15 (new skill request) |
| 모양은 말로 서술하고 실제 비율이나 크기는 구조화된 값으로, 역할과 자리가 붙은 정확한 인용 문자열, 브리프당 이미지 하나, 시리즈 전체에 반복하는 공통 불변 요소 | this package's image-generation skill contract, restated for screens |
| 토큰 세트에 적용하는 대비 최소 기준 | <https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html> |

### Evidence grade

`LOCAL`: 세 논리 프레임, 캔버스 모양, 뼈대, 최소 토큰 표, 본문 크기 하한은 이 패키지가 시안용으로 고른 기본값이고 플랫폼 요구사항이 아닙니다. 프로젝트 자체의 프레임 크기와 토큰이 있으면 그것으로 대체합니다.
