# 출력 계약

> English version: [`output-contract.md`](output-contract.md)

문서를 만들거나 렌더러를 고치기 전에 이 파일을 읽습니다. 이 파일이 입력 스키마, 입력에서 계산되는 카메라 기하, 출력 폴더, `StoryboardCore`와 `window.storyboardStudio` API, 검사기가 낼 수 있는 모든 코드를 소유합니다.

## 목차

- [1. 입력 문서](#1-입력-문서)
- [2. 카메라 값과 계산 기하](#2-카메라-값과-계산-기하)
- [3. 출력 레이아웃](#3-출력-레이아웃)
- [4. 렌더러 API](#4-렌더러-api)
- [5. 코드와 억제](#5-코드와-억제)
- [6. 브라우저 없이 코어 실행](#6-브라우저-없이-코어-실행)

## 1. 입력 문서

`version: 1`인 JSON 객체 하나입니다. 아래 표의 키는 선택이라고 적힌 경우를 빼고 모두 필수입니다. 모르는 키는 거부하지 않고 무시합니다.

### 1.1 최상위

| 키 | 타입 | 필수 | 기본값 | 규칙 |
|---|---|---|---|---|
| `version` | number | 예 | — | `1`이어야 합니다. |
| `title` | string | 예 | — | 비어 있지 않은 문자열입니다. 페이지 머리말과 보고서에 인쇄됩니다. |
| `aspect` | string | 아니오 | `16:9` | `16:9`, `2.39:1`, `1.85:1`, `4:3`, `9:16` 중 하나입니다. |
| `sensorLongMm` | number | 아니오 | `35` | 센서 긴 축의 밀리미터 값입니다. 세로 화각에만 쓰입니다. |
| `panelsPerPage` | integer | 아니오 | `3` | `1`~`4`입니다. 인쇄한 A4 가로 한 쪽에 들어가는 패널 수입니다. |
| `style` | string | 아니오 | `grayscale manga storyboard line art, clean ink lines, 2-3 flat gray tones, no text, no speech bubbles` | 비어 있지 않은 문자열입니다. 모든 패널 프롬프트에 실리는 그림체(1.7절)입니다. 그려지는 선화는 바꾸지 않습니다. |
| `characters` | object[] | 예 | — | 하나 이상입니다. |
| `scenes` | object[] | 예 | — | 하나 이상이며 이야기 순서입니다. |

`characters[]`의 각 항목:

| 키 | 타입 | 필수 | 기본값 | 규칙 |
|---|---|---|---|---|
| `id` | string | 예 | — | 문서 안에서 고유합니다. `focus`, `subjects`, `blocking`, `subjectMoves`, `pov`, `over`, `axis`가 참조합니다. |
| `name` | string | 예 | — | 비어 있지 않은 문자열입니다. 패널과 평면도에 인쇄됩니다. |
| `heightM` | number | 아니오 | `1.70` | 미터 단위입니다. 프레이밍과 카메라 높이 계산을 정합니다. |
| `look` | string | 아니오 | 없음 | 비어 있지 않은 문자열입니다. 체형·머리·옷처럼 외형을 한 줄로 적은 창작 설명이며, 패널 프롬프트가 써서 같은 인물이 모든 생성 패널에서 같은 모습으로 읽히게 합니다. 실존 배우나 생존 인물의 이름은 쓰지 않습니다. |

### 1.2 씬

| 키 | 타입 | 필수 | 기본값 | 규칙 |
|---|---|---|---|---|
| `id` | string | 예 | — | 문서 안에서 고유합니다. |
| `number` | number | 예 | — | `SC <number>`로 표시합니다. |
| `heading` | string | 예 | — | 씬의 모든 패널에 인쇄되는 씬 표제입니다. |
| `props` | object[] | 예 | — | 비어 있어도 됩니다. |
| `blocking` | object[] | 예 | — | 이 씬에서 인물의 처음 위치입니다. |
| `axis` | `[string, string]` 또는 `null` | 예 | — | 180도 선을 정하는 인물 id 두 개이거나, 선이 없는 씬이면 `null`입니다. |
| `shots` | object[] | 예 | — | 하나 이상이며 컷 순서입니다. |

`props[]`의 각 항목:

| 키 | 타입 | 필수 | 기본값 | 규칙 |
|---|---|---|---|---|
| `id` | string | 예 | — | 씬 안에서 고유합니다. `focus`가 참조합니다. |
| `label` | string | 예 | — | 비어 있지 않은 문자열입니다. 평면도에 인쇄합니다. |
| `x` | number | 예 | — | 미터. 씬의 오른쪽으로 뻗습니다. |
| `z` | number | 예 | — | 미터. 관객 반대쪽으로 뻗습니다. |
| `w` | number | 예 | — | 미터. `x` 축 너비입니다. |
| `d` | number | 예 | — | 미터. `z` 축 깊이입니다. |
| `h` | number | 예 | — | 미터. 받침면 위 높이입니다. |
| `y` | number | 아니오 | `0` | 미터. 바닥 위 소품 받침 높이(`props[].y`)입니다. `h: 0.75`인 식탁 위 찻잔은 `y: 0.75`를 씁니다. `0` 이상이어야 하며, 음수는 `SCHEMA_RANGE`, 숫자가 아니면 `SCHEMA_TYPE`입니다. 그려지는 상자는 `y`에서 `y + h`까지이고, 평면도는 평면 투영이므로 `y`를 쓰지 않습니다. |

`y`가 없는 소품의 그려지는 상자는 바뀌지 않습니다. 소품 초점 샷은 `y + h / 2`를 중심으로 잡으므로, 소품 초점 샷이 있는 기존 문서는 카메라 높이가 달라집니다.

`blocking[]`의 항목은 `character`(인물 id, 인물마다 한 항목), `x`, `z`(미터), `facingDeg`(도, `0`이면 `+z`를 봄, 양수면 `+x` 쪽으로 돎), `pose`(`stand`, `walk`, `sit`, `reach`, `crouch` 중 하나)입니다.

### 1.3 샷

| 키 | 타입 | 필수 | 기본값 | 규칙 |
|---|---|---|---|---|
| `id` | string | 예 | — | 씬 안에서 고유합니다. 스케치 지터의 seed라서 id가 바뀌면 그림도 바뀝니다. |
| `size` | string | 예 | — | `ECU`, `CU`, `MCU`, `MS`, `COWBOY`, `MWS`, `FS`, `WS`, `ELS`, `OTS` 중 하나입니다. |
| `focus` | string | 예 | — | 인물 id 또는 소품 id입니다. 프레이밍 박스와 궤도 중심을 정합니다. |
| `subjects` | string[] | 아니오 | `focus`가 인물이면 `[focus]`, 소품이면 `[]` | 초점과 함께 프레임에 넣을 인물 id입니다. 프레이밍 박스는 초점 박스와 모든 인물 박스의 합집합이 됩니다. |
| `camera` | object | 예 | — | 1.4절을 봅니다. |
| `move` | object 또는 `null` | 예 | — | 1.5절을 봅니다. `null`이면 카메라 이동이 없습니다. |
| `subjectMoves` | object[] | 예 | — | 비어 있어도 됩니다. 1.5절을 봅니다. |
| `blockingOverride` | object[] | 아니오 | 없음 | `blocking[]`과 같은 형태의 항목이며, 그 인물의 블로킹을 이 샷에서만 바꿉니다. |
| `action` | string | 예 | — | 현재형 동작 설명입니다. |
| `dialogue` | object[] | 아니오 | 없음 | `{ "speaker": string, "line": string }`입니다. `speaker`는 콜론 앞에 그대로 인쇄되므로 인물 이름을 씁니다. |
| `sound` | string | 아니오 | 없음 | 패널에 인쇄되는 사운드 메모입니다. |
| `image` | object 또는 `null` | 아니오 | 없음 | 이 패널에 넣을 완성 그림입니다. 1.7절을 봅니다. 있으면 선화 대신 그림을 그리고, 메모와 이동 표기는 그대로 남깁니다. |
| `durationSec` | number | 예 | — | `0.2`~`600`입니다. |
| `transition` | string | 예 | — | `CUT`, `DISSOLVE`, `FADE IN`, `FADE OUT`, `WIPE`, `SMASH CUT`, `MATCH CUT` 중 하나입니다. 다음 패널로 넘어가는 전환으로 인쇄됩니다. |
| `crossing` | object 또는 `null` | 예 | — | 1.6절을 봅니다. |
| `intent` | string | 예 | — | 이 샷이 있는 이유입니다. 패널에는 인쇄하지 않고 검토용으로 문서에 남깁니다. |

### 1.4 카메라

| 키 | 타입 | 필수 | 기본값 | 범위·규칙 |
|---|---|---|---|---|
| `pitchDeg` | number | 아니오 | `0` | `-90`~`90`입니다. 양수면 내려다봅니다. `heightM`과 함께 쓸 수 없습니다. |
| `heightM` | number | 아니오 | — | `0.05`~`50`입니다. `pitchDeg`와 함께 쓸 수 없습니다. |
| `yawDeg` | number | 예 | — | `-180`~`180`입니다. 초점의 보는 방향을 기준으로 잰 카메라의 궤도 방위입니다(초점이 소품이면 `+z` 기준). `0`이면 카메라가 인물 정면에 있고, 양수면 인물의 코가 화면 왼쪽을 향하며, `±180`이면 인물 뒤입니다. |
| `rollDeg` | number | 예 | — | `-45`~`45`입니다. 시선 축을 도는 더치 앵글입니다. |
| `focalMm` | number | 예 | — | `10`~`300`입니다. |
| `distanceM` | number | 아니오 | — | 미터 단위입니다. 계산한 프레이밍 거리를 대신합니다. `pov`와 `OTS` 샷에서는 쓸 수 없습니다. |
| `pov` | string | 아니오 | — | 인물 id입니다. 카메라가 그 인물의 눈 위치에서 초점을 봅니다. `pitchDeg`, `heightM`, `distanceM`과 함께 쓸 수 없고, `size: "OTS"`와도 함께 쓸 수 없습니다. |
| `over` | string | 아니오 | — | 인물 id입니다. `size`가 `OTS`일 때 필수이고 다른 size에서는 거부합니다. |

`pitchDeg`와 `heightM`이 모두 없으면 피치는 `0`입니다. 둘 다 있으면 `SCHEMA_CONFLICT`로 문서를 거부합니다.

### 1.5 이동

`move` 객체는 `type`(`STATIC`, `PAN L`, `PAN R`, `TILT UP`, `TILT DOWN`, `PUSH IN`, `PULL OUT`, `ZOOM IN`, `ZOOM OUT`, `DOLLY IN`, `DOLLY OUT`, `TRUCK L`, `TRUCK R`, `PED UP`, `PED DOWN`, `CRANE UP`, `CRANE DOWN`, `ROLL L`, `ROLL R`, `HANDHELD` 중 하나), `endSize`(size 열거값, `PUSH IN`, `ZOOM IN`, `DOLLY IN`, `PULL OUT`, `ZOOM OUT`, `DOLLY OUT`일 때 필수), `primary`(boolean)로 이루어집니다.

`subjectMoves[]`의 항목은 `character`(인물 id), `to`(`{ "x": number, "z": number }`, 미터), `label`(string), `primary`(boolean)입니다.

`primary`가 `true`인 이동이 `PRIMARY_MOVE_OVERLOAD`에 셉니다. 카메라 `move`는 주동작을 많아야 하나 더하고, 주동작인 `subjectMove`는 각각 하나씩 더합니다.

### 1.6 선 넘기

`crossing`은 `null`이거나 `method`(`neutral`, `subject-move`, `camera-move`, `both`, `none` 중 하나), `intentional`(boolean), `reason`(비어 있지 않은 문자열)을 가진 객체입니다. `none`은 다리 없이 선을 넘는다는 뜻입니다. `crossing`을 선언한 샷은 그 샷으로 들어오는 컷에서 선 관련 경고 세 개를 억제하고, `intentional` 값과 상관없이 `intentional[]`에 기록됩니다.

### 1.7 그림·그림체·외형

패널은 보통 카메라 값으로 그린 선화를 담습니다. `shots[].image`는 한 패널에 완성 그림을 넣고, `doc.style`과 `characters[].look`은 이미지 생성기가 그려야 할 그림을 설명합니다.

`image`는 `null`이거나 다음 객체입니다.

| 키 | 타입 | 필수 | 규칙 |
|---|---|---|---|
| `src` | string | 예 | 데이터 URI만 씁니다. `data:image/png;base64,`, `data:image/jpeg;base64,`, `data:image/webp;base64,` 뒤에 base64 문자가 이어집니다. `http:`, `https:`, `file:`, blob URL은 `SCHEMA_TYPE`입니다. 보드는 어떤 것도 내려받지 않습니다. |
| `provenance` | string | 예 | 이미지 생성기가 만든 그림이면 `generated`, 사람이 준 그림이면 `supplied`입니다. 다른 값은 `SCHEMA_ENUM`입니다. |
| `prompt` | string | 아니오 | 그 그림을 만든 프롬프트입니다. 검토용으로 남기며 보드에는 인쇄하지 않습니다. |

`image`가 있는 샷은 그림을 프레임에 잘라 `data-part="panel-image"`로 그리고 `preserveAspectRatio="xMidYMid slice"`를 써서 늘리지 않고 프레임을 채웁니다. 그 패널에서는 인형과 선화를 건너뛰지만 이동 화살표, 끝 프레임, 인물 이동 화살표는 남아 그림 위에 인쇄됩니다. 패널 메모(카메라 줄, 액션, 대사, 사운드, 길이, 전환)는 그대로입니다. `image`가 없는 샷은 선화를 그립니다.

`style`은 문서 전체에 하나인 짧은 그림체 문구이며 `compilePanelPrompt()`(4절)에만 실리고 SVG는 바꾸지 않습니다. 모든 프롬프트 끝의 글자 금지 문구와 어긋나는 지시는 넣지 않습니다.

### 1.8 최소 문서

이 블록은 완전하고 유효한 문서입니다. 여기서는 `aspect`, `sensorLongMm`, `panelsPerPage`, `style`, `look`, `image`, `subjects`, `blockingOverride`, `sound`를 빼서 기본값을 보여 주고, 스키마가 요구하는 나머지 키는 모두 넣었습니다.

```json
{
  "version": 1,
  "title": "부엌의 아침",
  "characters": [
    { "id": "minsu", "name": "민수", "heightM": 1.72 }
  ],
  "scenes": [
    {
      "id": "s1",
      "number": 1,
      "heading": "INT. 부엌 - 아침",
      "props": [
        { "id": "table", "label": "식탁", "x": 0, "z": 1.2, "w": 1.4, "d": 0.8, "h": 0.74 }
      ],
      "blocking": [
        { "character": "minsu", "x": 0, "z": 0, "facingDeg": 0, "pose": "stand" }
      ],
      "axis": null,
      "shots": [
        {
          "id": "10",
          "size": "MS",
          "focus": "minsu",
          "camera": { "yawDeg": 0, "rollDeg": 0, "focalMm": 35 },
          "move": null,
          "subjectMoves": [],
          "action": "민수가 식탁 너머 창밖을 본다.",
          "dialogue": [
            { "speaker": "민수", "line": "오늘은 일찍 나가야 해." }
          ],
          "durationSec": 4,
          "transition": "CUT",
          "crossing": null,
          "intent": "인물과 공간을 한 번에 소개한다."
        }
      ]
    }
  ]
}
```

## 2. 카메라 값과 계산 기하

여기 있는 값은 모두 `layoutShot()`이 계산하며 문서에 넣으면 안 됩니다.

### 2.1 센서 축과 세로 화각

`aspect`를 비율로 바꾼 뒤(`16:9` → `1.7778`, `9:16` → `0.5625`) 다음 식을 씁니다.

```text
sensorAxisMm = ratio >= 1 ? sensorLongMm / ratio : sensorLongMm
vfovDeg      = 2 * atan(sensorAxisMm / (2 * focalMm)) * 180 / PI
```

세로 화면비에서는 센서 긴 축이 세로 축이므로 긴 축 값을 그대로 씁니다. 기본 35mm 센서 기준 기대값은 다음과 같습니다.

| `focalMm` | `aspect` | `vfovDeg` |
|---|---|---|
| 50 | `16:9` | 22.28 |
| 24 | `16:9` | 44.60 |
| 50 | `9:16` | 38.58 |
| 50 | `2.39:1` | 16.66 |

### 2.2 프레이밍 박스

프레이밍은 초점 인물의 키 `H`에 대한 세로 범위로 정합니다. 프레이밍 높이는 그 범위의 길이이고, 프레이밍 중심은 바닥에서 그 범위의 중간 높이입니다.

| `size` | 세로 범위 | 프레이밍 높이 |
|---|---|---|
| `ECU` | `0.90`~`0.98` × `H` | `0.08H` |
| `CU` | `0.80`~`1.02` × `H` | `0.22H` |
| `MCU` | `0.70`~`1.02` × `H` | `0.32H` |
| `MS` | `0.52`~`1.03` × `H` | `0.51H` |
| `COWBOY` | `0.40`~`1.04` × `H` | `0.64H` |
| `MWS` | `0.28`~`1.05` × `H` | `0.77H` |
| `FS` | `-0.03`~`1.06` × `H` | `1.09H` |
| `WS` | 인물이 프레임 높이의 절반 | `2H`, 중심 `0.5H` |
| `ELS` | 인물이 프레임 높이의 4분의 1 | `4H`, 중심 `0.5H` |
| `OTS` | 초점을 `MCU`로 프레이밍 | `0.32H` |

초점이 소품이면 소품 높이 `h`의 `1.6`배를 쓰고 중심은 `y + h / 2`입니다(`y`는 `props[].y` 받침 높이, 기본 `0`). `subjects`가 있으면 박스는 초점 박스와 모든 인물 박스의 합집합이 되고, 합집합의 중간 높이가 궤도 중심 높이가 됩니다.

### 2.3 거리와 궤도

```text
d      = distanceM ?? framingHeight / (2 * tan(vfovDeg / 2))
target = (focus x, 프레이밍 중심 높이, focus z)
camera = target + d * (sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
```

`rollDeg`는 시선 축을 돌릴 뿐 위치를 바꾸지 않습니다. `distanceM`을 주면 `d`를 그대로 대신하며, 그래서 피사체가 의도한 크기를 채우지 못해도 경고를 내지 않습니다.

### 2.4 피치와 높이

`pitchDeg`와 `heightM`은 같은 세로 오프셋을 두 방식으로 적은 것이라 많아야 하나만 받습니다.

- `heightM`이 있으면 `pitch = asin((heightM - 프레이밍 중심) / d)`입니다. 프레이밍 중심과의 차가 `d`보다 크면 카메라가 그 높이에 닿을 수 없으므로 `CAMERA_GEOMETRY`로 실패합니다.
- `pitchDeg`가 있으면 `height = 프레이밍 중심 + d * sin(pitch)`입니다. 높이가 `0.05`m보다 낮으면 `CAMERA_GEOMETRY`로 실패합니다. 카메라는 바닥 아래로 갈 수 없습니다.
- 둘 다 없으면 `pitch = 0`이고 높이는 프레이밍 거리에서 따라옵니다.

### 2.5 POV와 OTS

- `pov`: 카메라가 그 인물의 눈 위치(`0.94 × heightM`)에 서서 초점 프레이밍 중심을 봅니다. `pitchDeg`, `heightM`, `distanceM`은 쓸 수 없고 계산값으로만 돌려줍니다.
- `OTS`: 카메라가 `over` 인물의 어깨 뒤로 `0.35`m 서고, `size`와 상관없이 초점을 `MCU`로 프레이밍합니다. 옆 오프셋은 어깨가 프레임에 남도록 줄이며, `lateral = min(0.35, 0.115 * over.heightM + 0.80 * 0.35 * tanH)`이고 `tanH = tan(vfovDeg / 2) * aspect`입니다. 옆으로 `0.35`m를 고정하면 가까운 쪽 어깨가 프레임 밖으로 잘려 OTS의 어깨 단서가 사라집니다. 여기서도 `pitchDeg`, `heightM`, `distanceM`을 쓸 수 없습니다.
- `pov`와 `size: "OTS"`를 함께 쓰면 `SCHEMA_CONFLICT`입니다.
- 계산된 몸 위치는 쓸 수 있어야 합니다. `pov`·`OTS` 카메라가 `0.05`m 아래로 계산되거나 초점 대상에 `0.2`m보다 가깝게 계산되면 `CAMERA_GEOMETRY`로 실패합니다.

### 2.6 지평선과 바닥 가시성

- `|pitchDeg| < vfovDeg / 2`이면 `horizonVisible`이 참입니다. 아니면 지평선이 프레임 밖이고 패널이 `HORIZON_OFFFRAME` 정보 항목을 냅니다.
- 초점 중심의 6m × 6m 바닥 격자(0.5m 간격) 가운데 한 줄이라도 프레임으로 잘린 뒤 안에 투영되면 `groundVisible`이 참입니다. 거짓이면 패널이 `data-part="ground"` 요소를 만들지 않고 머리 구성선 곡률과 카메라 줄 라벨에 의존합니다.

### 2.7 이름

이름은 표시용 라벨이고 숫자가 정본입니다.

| `pitchDeg`·높이 | `angleName` | 한국어 |
|---|---|---|
| `-5`~`5` | `EYE LEVEL` | 아이레벨 |
| `5` 초과 `75` 미만 | `HIGH` | 부감 |
| `-75` 초과 `-5` 미만 | `LOW` | 앙각 |
| `75` 이상 | `OVERHEAD` | 오버헤드 |
| `-75` 이하 또는 `heightM` `0.3` 이하 | `WORM'S EYE` | 웜즈아이 |

높이 조건이 맞으면 `WORM'S EYE`가 `LOW`를 덮습니다.

| `yawDeg` 절댓값 | `yawName` | 한국어 |
|---|---|---|
| `0`~`15` | `FRONT` | 정면 |
| `15`~`60` | `3/4` | 3/4 |
| `60`~`120` | `PROFILE` | 측면 |
| `120`~`165` | `3/4 BACK` | 3/4 뒷모습 |
| `165`~`180` | `BACK` | 뒷모습 |

범위는 위쪽 경계를 포함합니다. yaw가 0이 아니면 부호에 따라 ` L`이나 ` R`을 붙입니다. 양수 yaw는 인물이 화면 왼쪽을 보는 값이라 `3/4 L`로 읽힙니다.

| `heightM` | `heightName` |
|---|---|
| `0.3` 미만 | `GROUND` |
| `0.7` 미만 | `KNEE` |
| `1.1` 미만 | `HIP` |
| `1.45` 미만 | `SHOULDER` |
| `1.75` 미만 | `EYE` |
| `1.75` 이상 | `ABOVE` |

## 3. 출력 레이아웃

`.hyper/storyboard-maker/<slug>/` 아래에 전달합니다. `<slug>`는 작품을 가리키는 짧은 케밥 케이스 이름입니다.

```text
index.html        # 이 문서를 넣은 스튜디오 자산
storyboard.json   # 렌더한 문서 그대로
shot-list.md      # 보드 전체의 한국어 샷 표
manifest.json     # 이 빌드의 getReport()
```

`index.html`은 `assets/storyboard-studio.html`의 사본이며, `<script type="application/json" id="storyboard-doc">` 요소가 문서를 담습니다. JSON 텍스트의 모든 `</`를 `<\/`로 이스케이프해 넣은 객체가 자기 script 요소를 닫지 못하게 하고, 다른 이스케이프는 필요하지 않습니다. 이 파일은 네트워크 없이 열리고 렌더되어야 합니다.

`storyboard.json`은 렌더한 그대로 기록해서 나중에 같은 보드를 다시 만들 수 있게 합니다.

`shot-list.md`는 문서 언어와 상관없이 한국어이며, 문서 순서대로 샷마다 한 행을 둡니다.

| 씬 | 샷 | 크기 | 앵글 | 방위 | 렌즈 | 카메라 높이 | 무브 | 액션 | 대사 | 길이 | 전환 | 비고 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 10 | MS | 아이레벨 0° | 정면 | 35mm | 1.33m (숄더) | STATIC | 민수가 창밖을 본다 | 민수: 오늘은 일찍 나가야 해 | 4s | CUT | — |

`앵글`에는 `angleName`과 피치 각도를, `방위`에는 `yawName`을, `카메라 높이`에는 계산한 높이와 `heightName`을 적습니다. `무브`에는 `move.type`과 `endSize`(있을 때)를, `대사`에는 대사 줄을 ` / `로 이어 붙입니다. `비고`에는 그 샷의 경고 코드와 `crossing`의 방법·이유를 적습니다. 표 아래에는 `intentional[]` 항목을 `SH <id> · <method> · <intentional> · <reason>` 형식으로 모두 나열합니다.

`manifest.json`은 `getReport()` 객체를 그대로 담습니다.

```json
{
  "errors": [],
  "warnings": [],
  "info": [],
  "intentional": [],
  "panels": 6,
  "scenes": 2
}
```

`panels`는 렌더한 패널 수이고 `scenes`는 렌더한 평면도 수입니다. 오류가 하나라도 남아 있으면 둘 다 `0`이고 `index.html`은 패널 대신 오류 상태를 보여 줍니다.

모든 패널 `<svg>`는 무엇을 그렸는지 표시하므로, 산문을 읽지 않고도 그림을 검사할 수 있습니다.

| `data-part` | 그리는 때 | 뜻 |
|---|---|---|
| `frame` | 항상 | 잉크 테두리를 두른 흰 프레임입니다. |
| `panel-image` | 샷에 `image`가 있을 때 | 프레임에 잘라 넣고 채우도록 늘린 그림입니다. 그 패널에서는 인형·소품·바닥·지평선을 그리지 않습니다. |
| `ground` | 그림이 없고 격자가 프레임 안에 투영될 때 | 6m 바닥 격자입니다. |
| `horizon` | 그림이 없고 지평선이 프레임 안에 있을 때 | 지평선입니다. |
| `head`, `hair`, `face`, `chest` | 그림이 없을 때 | 인형 표식입니다. `hair`는 뒤에서 볼 때만, `chest`는 몸통 앞면이 카메라를 향할 때만 나옵니다. |
| `foreground` | 그림이 없고 `OTS` 샷일 때 | 프레임에 잘린 어깨 너머 인물입니다. |
| `end-frame`, `end-frame-group` | `PUSH IN`, `ZOOM IN`, `DOLLY IN`, `PULL OUT`, `ZOOM OUT`, `DOLLY OUT` 이동일 때 | 점선 끝 프레임과 네 모서리 화살표입니다. 그림 위에도 인쇄됩니다. |
| `subject-move` | `subjectMoves` 항목이 있을 때 | 인물 이동의 바닥 화살표와 라벨입니다. 그림 위에도 인쇄됩니다. |
| `guide-frame` | `renderGuideSvg()`만 | 구도 가이드의 바깥 테두리입니다. |

## 4. 렌더러 API

`StoryboardCore`는 `<script id="storyboard-core">` 안에 있고 DOM 없이 동작합니다. 모든 함수는 순수합니다. 같은 문서는 같은 문자열을 돌려주며, 어떤 함수도 시계나 네트워크, 전역 상태를 읽지 않습니다.

| 함수 | 시그니처 | 반환 |
|---|---|---|
| `validate` | `validate(doc)` | `{ errors: Issue[], info: Issue[] }` |
| `lint` | `lint(doc)` | `{ warnings: Issue[], info: Issue[], intentional: IntentionalEntry[] }` |
| `layoutShot` | `layoutShot(doc, sceneId, shotId)` | 아래 레이아웃 객체, id를 찾지 못하면 `null` |
| `renderPanelSvg` | `renderPanelSvg(doc, sceneId, shotId)` | `<svg>` 문자열 하나, id를 찾지 못하면 `""` |
| `compilePanelPrompt` | `compilePanelPrompt(doc, sceneId, shotId)` | 영어 프롬프트 문자열 하나, id를 찾지 못하면 `""` |
| `renderGuideSvg` | `renderGuideSvg(doc, sceneId, shotId)` | 회색 구도 가이드 `<svg>` 문자열 하나, id를 찾지 못하면 `""` |
| `renderFloorPlanSvg` | `renderFloorPlanSvg(doc, sceneId)` | `<svg>` 문자열 하나, 씬을 찾지 못하면 `""` |
| `render` | `render(doc)` | 보드 마크업을 HTML 문자열 하나로(씬 섹션·페이지·패널·평면도, `<html>` 래퍼 없음) 돌려주고, `validate()`가 오류를 하나라도 돌려주면 `""`입니다. 보고서는 돌려주지 않으므로 `errors`는 `validate()`에서, `warnings`·`info`·`intentional`은 `lint()`에서 읽습니다. |
| `vfovDeg` | `vfovDeg(focalMm, aspect, sensorLongMm)` | 세로 화각(도) |

`Issue`는 `{ "code": string, "message": string, "path": string }`이고, `path`는 `scenes[0].shots[2].camera.focalMm` 같은 점·색인 위치입니다. `IntentionalEntry`는 `{ "shot": string, "method": string, "intentional": boolean, "reason": string }`입니다.

`layoutShot()`의 반환:

| 필드 | 타입 | 의미 |
|---|---|---|
| `cameraPos` | `{ x, y, z }` | 씬 미터 좌표의 카메라 위치입니다. |
| `target` | `{ x, y, z }` | 씬 미터 좌표의 궤도 중심입니다. |
| `pitchDeg` | number | 유효 피치입니다. `heightM`이나 `pov`·`OTS`에서 유도한 값도 포함합니다. |
| `heightM` | number | 유효 카메라 높이입니다. |
| `distanceM` | number | `target`에서 잰 유효 거리입니다. |
| `vfovDeg` | number | 그 샷 렌즈의 세로 화각입니다. |
| `horizonVisible` | boolean | 지평선이 프레임 안에 드는지 여부입니다. |
| `groundVisible` | boolean | 6m 격자가 프레임 안에 투영되는지 여부입니다. |
| `facingScreen` | `"left"`, `"right"`, `"center"` | 초점의 코가 화면에서 향하는 쪽입니다. `yawDeg`의 부호를 따르고, 코가 카메라 쪽이나 반대쪽을 거의 정면으로 향하면(즉 `sin(yawDeg)`의 절댓값이 `0.1` 미만) 또는 초점이 소품이면 `center`입니다. |
| `angleName` | string | 2.7절의 앵글 라벨입니다. |
| `yawName` | string | 2.7절의 방위 라벨입니다. |
| `heightName` | string | 2.7절의 높이 라벨입니다. |

입력값과 계산값은 분리되어 있습니다.

| 필드 | 입력으로 허용 | `layoutShot()` 반환 |
|---|---|---|
| `pitchDeg` | `heightM`·`pov`·`OTS`가 적용되지 않을 때 허용 | 항상 |
| `heightM` | `pitchDeg`·`pov`·`OTS`가 적용되지 않을 때 허용 | 항상 |
| `distanceM` | `pov`·`OTS`가 적용되지 않을 때 허용 | 항상 |
| `cameraPos`, `target`, `vfovDeg` | 절대 불가 | 항상 |
| `horizonVisible`, `groundVisible`, `facingScreen` | 절대 불가 | 항상 |
| `angleName`, `yawName`, `heightName` | 절대 불가 | 항상 |

`compilePanelPrompt()`는 패널을 그리는 것과 같은 투영을 읽으므로 프롬프트와 패널이 어긋나지 않습니다. 문자열에는 차례로 샷 크기의 영어 이름, 초점이 인물일 때 yaw 시점(`front view, subject faces the camera`, `three-quarter view`, `profile view (side view)`, `three-quarter back view, face mostly hidden`, `back view, subject's face not visible` 중 하나이며 3/4과 프로필에는 `, subject facing screen-left` 또는 `, subject facing screen-right`가 붙습니다), 앵글 이름과 피치 절댓값(예: `low angle 12°`), 렌즈 밀리미터, 카메라 높이 이름과 미터, `rollDeg`가 0이 아니면 `dutch angle, horizon tilted 8° to the right`(또는 `to the left`, 양수 롤은 그려지는 지평선을 오른쪽으로 기울입니다), 인물이 둘 이상 프레임에 들면 각 인물의 `look`과 함께 `N characters in frame`(한 명이면 `Characters:`), 적힌 그대로의 액션, 중심이 프레임 안에 투영되는 소품, 마지막으로 `doc.style`이 들어갑니다. 소품 초점에는 시점·방향 문구가 없습니다. 대사는 절대 옮기지 않고, 글자는 보드에서 붙이므로 그림 안에 글자·숫자·캡션·말풍선을 그리지 말라는 문구로 끝납니다. 같은 문서는 같은 문자열을 냅니다.

`renderGuideSvg()`는 이미지 생성기에 주는 회색조 구도 참고 그림을 돌려줍니다. 같은 카메라 투영에 인형, 바닥 격자, 지평선만 있고 화살표·라벨·소품·메모는 없습니다. `viewBox`는 기본 `16:9`에서 `0 0 1600 900`이고 그 밖의 화면비에서는 문서의 화면비를 따릅니다. 생성기가 참고 이미지를 받으면 프롬프트와 함께 넣습니다.

`image`, `image.src`, `image.provenance`, `image.prompt`, `style`, `characters[].look`은 입력 전용이며 어떤 함수도 계산하지 않습니다. `compilePanelPrompt()`와 `renderGuideSvg()`의 출력은 파생값이며 문서에 다시 쓰지 않습니다.

`window.storyboardStudio`는 DOM을 다루는 껍데기이며, QA 단계에서 브라우저로 호출하는 대상입니다.

| 호출 | 반환 | 동작 |
|---|---|---|
| `load(doc)` | 보고서 객체 | 검사하고 렌더해 현재 보드를 바꿉니다. |
| `getReport()` | `{ errors, warnings, info, intentional, panels, scenes }` | 다시 렌더하지 않고 현재 상태를 읽습니다. |
| `render()` | 보고서 객체 | 현재 문서를 다시 렌더합니다. 편집기 버튼이 씁니다. |

`window.storyboardStudio.render()`는 코어 `render(doc)`가 아니라 페이지 껍데기입니다. 마크업은 페이지에 들어가고 호출은 보고서 객체를 돌려줍니다.

로드할 때 `storyboard-doc` 요소가 비어 있지 않으면 바로 렌더합니다. 비어 있으면 JSON 붙여넣기 편집기와 렌더 버튼으로 바뀝니다. 오류가 있으면 패널은 0개, `#status[data-error="true"]` 상태, 오류 목록이 됩니다. 경고는 렌더를 막지 않고 패널 배지와 보드 위 요약으로 표시됩니다.

## 5. 코드와 억제

오류는 빌드를 멈춥니다. 오류가 남아 있는 동안 패널을 렌더하지 않습니다.

| 코드 | 발생 조건 |
|---|---|
| `SCHEMA_REQUIRED` | 필수 키가 빠졌거나, 스키마가 null 허용으로 선언하지 않은 키가 `null`이거나, `size`가 `OTS`인데 `camera.over`가 없습니다. |
| `SCHEMA_TYPE` | 값의 JSON 타입이 틀렸습니다. 또는 `camera.over`가 `OTS`가 아닌 size와 함께 있습니다. `image.src`가 base64 `data:image/png`, `data:image/jpeg`, `data:image/webp` URI가 아니어도 이 코드입니다. |
| `SCHEMA_ENUM` | `size`, `pose`, `move.type`, `transition`, `crossing.method`, `image.provenance`가 열거값 밖입니다. |
| `SCHEMA_RANGE` | 수가 허용 범위를 벗어납니다. `pitchDeg`, `heightM`, `yawDeg`, `rollDeg`, `focalMm`, `durationSec`, `panelsPerPage`. |
| `SCHEMA_DUPLICATE` | 인물 id, 씬 id, 소품 id, 샷 id가 자기 범위 안에서 겹칩니다. |
| `SCHEMA_REFERENCE` | `focus`, `subjects` 항목, `blocking.character`, `axis`, `subjectMoves.character`, `pov`, `over`가 없는 id를 가리킵니다. |
| `SCHEMA_CONFLICT` | `pitchDeg`와 `heightM`을 함께 씁니다. `pov`와 `pitchDeg`·`heightM`·`distanceM`을 함께 씁니다. `OTS`와 그 세 값을 함께 씁니다. `pov`와 `size: "OTS"`를 함께 씁니다. |
| `CAMERA_GEOMETRY` | `heightM`이 프레이밍 중심에서 `d`보다 멉니다. 또는 `pitchDeg`에서 유도한 높이가 `0.05`m 아래입니다. 또는 `pov`·`OTS` 카메라의 계산된 높이가 `0.05`m 아래입니다. 또는 `pov`·`OTS` 카메라가 초점 대상에 `0.2`m보다 가깝습니다. |

경고는 렌더를 막지 않고 해당 패널의 배지로 인쇄됩니다.

| 코드 | 발생 조건 | 억제 조건 |
|---|---|---|
| `AXIS_CROSSED` | 같은 씬의 연속한 두 샷이 `axis`를 기준으로 반대쪽에 섭니다. | 뒤 샷의 `crossing`. |
| `EYELINE_MISMATCH` | 연속한 단독 샷 두 개가 `axis`의 두 인물을 각각 잡고, 둘의 `facingScreen`이 같습니다. | 뒤 샷의 `crossing`. |
| `JUMP_CUT` | 연속한 두 샷의 `focus`와 `size`가 같고 초점 둘레 방위 차가 30° 미만입니다. | 없음. 각도나 크기를 바꿉니다. |
| `SCREEN_DIRECTION_FLIP` | 같은 인물의 `subjectMoves` 화면 x 방향이 연속한 컷 사이에서 뒤집힙니다. | 뒤 샷의 `crossing`. |
| `PRIMARY_MOVE_OVERLOAD` | 한 샷에 주동작이 둘 이상입니다. `primary`가 참인 카메라 이동과 주동작인 `subjectMove`를 각각 셉니다. | 없음. 이동을 나누거나 주동작을 내립니다. |
| `WIDE_LENS_FACE` | `focalMm`가 `18` 이하이면서 `size`가 `ECU`나 `CU`입니다. | 없음. 렌즈나 크기를 바꿉니다. |

| 코드 | 종류 | 발생 조건 |
|---|---|---|
| `HORIZON_OFFFRAME` | info | 피치 절댓값이 `vfovDeg / 2` 이상이라 지평선을 그리지 않습니다. |

억제는 컷 단위이며 선 관련 경고 세 개에만 적용됩니다. `crossing`은 `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, `WIDE_LENS_FACE`, 그리고 어떤 오류도 막지 않습니다. `crossing`이 있는 샷은 의도적 위반이 아닌 다리 샷까지 포함해 `{ shot, method, intentional, reason }`으로 `intentional[]`에 한 번씩 기록되므로, 둘을 구분할 때는 `intentional` 값을 읽습니다.

## 6. 브라우저 없이 코어 실행

코어 스크립트를 꺼내 Node와 호환되는 자바스크립트 런타임으로 호출하면 브라우저가 필요 없습니다. 두 명령 모두 설치된 스킬 디렉터리, 곧 `SKILL.md`가 있는 폴더에서 렌더러를 찾으므로 저장소 체크아웃이 필요 없습니다. `SKILL_DIR`을 그 폴더로 지정하고 `.hyper/storyboard-maker/<slug>/`에 문서를 전달한 프로젝트 폴더에서 명령을 실행합니다. `SKILL_DIR`을 빼면 자산을 현재 디렉터리에서 대신 읽습니다.

```bash
SKILL_DIR=/path/to/installed/storyboard-maker node -e '
const fs = require("fs"), path = require("path"), vm = require("vm");
const dir = process.env.SKILL_DIR || ".";
const html = fs.readFileSync(path.join(dir, "assets/storyboard-studio.html"), "utf8");
const m = html.match(/<script[^>]*id="storyboard-core"[^>]*>([\s\S]*?)<\/script>/);
if (!m) throw new Error("storyboard-core script not found");
const ctx = vm.createContext({});
vm.runInContext(m[1] + "\n;globalThis.StoryboardCore = StoryboardCore;", ctx);
const doc = JSON.parse(fs.readFileSync(".hyper/storyboard-maker/my-film/storyboard.json", "utf8"));
const core = ctx.StoryboardCore;
console.log(JSON.stringify({ validate: core.validate(doc), lint: core.lint(doc) }, null, 2));
console.log("svg elements:", (core.render(doc).match(/<svg/g) || []).length);
'
```

`bun -e`는 `vm` 없이 같은 일을 합니다.

```bash
SKILL_DIR=/path/to/installed/storyboard-maker bun -e '
const path = require("path");
const dir = process.env.SKILL_DIR || ".";
const html = await Bun.file(path.join(dir, "assets/storyboard-studio.html")).text();
const src = html.match(/<script[^>]*id="storyboard-core"[^>]*>([\s\S]*?)<\/script>/)[1];
const core = new Function(src + "\nreturn StoryboardCore;")();
const doc = JSON.parse(await Bun.file(".hyper/storyboard-maker/my-film/storyboard.json").text());
console.log(JSON.stringify({ errors: core.validate(doc).errors, warnings: core.lint(doc).warnings }, null, 2));
'
```

두 명령 모두 보고서를 JSON으로 인쇄하고, 예외가 던져질 때만 0이 아닌 코드로 끝납니다. 오류가 있는 문서도 예외가 아니므로 출력의 `errors`와 `warnings`를 읽습니다. `render()`는 오류가 남아 있는 동안 빈 마크업을 돌려주므로, SVG 개수가 0이면 렌더러가 없는 것이 아니라 문서에 오류가 있는 것입니다. 읽는 대상은 전달한 `storyboard.json`이지 `index.html`이 아닙니다. 주입한 사본에는 `<\/` 이스케이프가 들어 있기 때문입니다.

## Sources

> 확인 2026-11-03.

| Claim | Source |
|---|---|
| 세로 화각은 `2·atan(H / 2f)`이고 초점거리가 짧을수록 넓어집니다 | [Understanding Focal Length and Field of View, Edmund Optics](https://www.edmundoptics.com/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/) |
| 카메라 `fov`는 세로 화각이고 필름 게이지는 긴 축 기준입니다 | [PerspectiveCamera, three.js](https://threejs.org/docs/pages/PerspectiveCamera.html) |
| 180도 선을 넘으면 인물의 위치가 뒤바뀐 인상을 줍니다 | [180-Degree Rule, Columbia Film Language Glossary](https://filmglossary.ccnmtl.columbia.edu/term/180-degree-rule/) |
| 같은 피사체의 연속 샷은 30° 이상 각도가 달라야 하고, 아니면 점프컷으로 읽힙니다 | [30-degree rule, Wikipedia](https://en.wikipedia.org/wiki/30-degree_rule) |
| `PAN L`, `PUSH IN` 같은 화살표식 이동 라벨이 관례적 어휘입니다 | [Storyboard Arrows, StoryboardArt](https://storyboardart.org/storyboard-tutorials/storyboard-arrows/) |
| A4 가로 인쇄는 `@page { size: …; margin: … }`로 지정합니다 | [@page, MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page) |

이 파일은 이 패키지 자체의 렌더러 자산을 문서화합니다.
