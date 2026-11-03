# 워크플로

> English version: [`workflow.md`](workflow.md)

실행 전에 읽습니다. 이 파일은 시작 질문부터 전달까지의 전체 절차를 다룹니다. 번호가 붙은 열한 단계는 이 순서대로 진행하며, 앞 단계가 정해지지 않은 채 뒤 단계를 열지 않습니다.

## 독창성과 언어

아래 두 규칙은 모든 단계에 적용합니다.

- 이 대본의 공간에서 보드를 만듭니다. 기존 영화의 프레임, 콘티, 샷 단위 구성을 복제하지 않고 공개된 스토리보드를 베끼지 않습니다. 카메라 값, 블로킹, 자세는 이 이야기와 이 인물에서 나옵니다. 참고 자료는 표기를 가르칠 수는 있어도 연출을 대신하지는 못합니다.
- 보드에 보이는 것과 사용자가 읽는 것은 모두 한국어로 씁니다. 씬 표제, 액션 문장, `intent`, 샷 리스트, 전달 메모가 여기에 해당합니다. 대사는 사용자가 번역을 요청하지 않으면 원천이 준 언어를 유지합니다.

## 1. 시작 질문

브리프가 비워 둔 항목만 한 메시지로 한 번에 묻습니다.

- 원천: 대본인지 줄거리인지, 대본이라면 최종본인지 초고인지
- 화면비: 기본은 `16:9`
- 범위: 대본 전체인지, 한 씬인지, 고른 시퀀스인지, 패널 수를 어느 정도로 보는지
- 등장 인물: 이름과 대략의 키
- 톤: 원천이 정하지 않았을 때

답이 없을 때 쓸 기본값을 함께 밝힙니다. `16:9`, 35mm 센서, A4 가로 한 장에 세 패널입니다. 답을 기다린 뒤 다시 묻지 않습니다. 이 스킬에는 대본 파서가 없으므로 대본은 직접 읽고 비트를 2단계로 넘깁니다.

## 2. 비트 분해

카메라를 생각하기 전에 원천을 비트로 나눕니다. 비트는 정보가 한 번 바뀌는 단위입니다. 결정, 폭로, 반전, 거절이 여기에 해당합니다.

- 비트마다 한 줄로 적습니다. 관객이 무엇을 알아내는지, 누가 무엇을 원하는지, 어디서 일어나는지입니다.
- 비트를 씬으로 묶고 씬마다 대본의 표제(`INT.` / `EXT.`, 장소, 시간)와 씬 번호를 붙입니다.
- 각 씬을 뒤집는 비트를 표시합니다. 보통 그 비트가 가장 가까운 샷을 얻습니다.
- 아무것도 바꾸지 않는 비트는 뺍니다. 보드는 대본의 모든 대사를 옮기는 물건이 아니라 이야기를 나르는 물건입니다.

보드의 씬 수는 샷 리스트가 아니라 비트 시트가 정합니다.

## 3. 샷 리스트

비트마다 샷 하나 이상을 만들고 번호를 붙입니다.

- 샷 번호는 10 단위로 붙입니다. `10`, `20`, `30`입니다. 사이를 비워 두는 이유는 나중에 인서트를 씬 번호를 다시 매기지 않고 `15`로 끼워 넣기 위해서입니다. 원천이 다른 번호를 쓰지 않으면 이야기 순서대로 씬을 넘어 10 단위를 이어 갑니다.
- 한 패널은 한 동작을 담습니다. 한 대사에 자세가 둘 필요하면 샷도 둘입니다.
- 샷마다 크기, 초점, 존재 이유를 적습니다. 새 정보가 없는 샷은 뺍니다.
- 씬은 쓸모 있는 가장 넓은 앵글에서 안쪽으로 커버합니다. 먼저 공간을 세우는 샷, 그다음 교환에 필요한 커버리지입니다.
- 넓은 샷으로 보여 줄 수 없는 인서트(손, 화면, 물건)는 빈 번호를 받습니다. `10`과 `20` 사이면 `15`, `20`과 `30` 사이면 `25`입니다.

## 4. 씬 블로킹과 축

카메라를 고르기 전에 인물과 소품을 평면도에 놓습니다.

- 좌표는 씬 바닥의 미터 단위입니다. `x`는 씬의 오른쪽, `z`는 관객에서 멀어지는 쪽이며 바닥은 `y = 0`입니다.
- 인물마다 `x`, `z`, `facingDeg`(`0`은 `+z`를 봄, 양수는 `+x`로 돎), 그리고 `stand`, `walk`, `sit`, `reach`, `crouch` 중 하나의 `pose`를 줍니다.
- 소품마다 `x`, `z`, `w`, `d`, `h`를 주고, 바닥에 놓이지 않으면 `y`도 줍니다. `y`는 바닥에서 잰 받침 높이(미터)라서 `h: 0.75`인 식탁 위에 놓인 찻잔은 `y: 0.75`입니다. 빼면 소품이 바닥(`0`)에 놓입니다. 소품 초점 샷은 `y`부터 `y + h`까지의 상자를 프레이밍하므로, 이 높이가 인서트에 물건이 보일지 그 아래 탁자 상판만 보일지를 정합니다.
- 교환을 나르는 두 인물 id로 `scene.axis`를 선언합니다. 씬에 선이 없으면 `null`입니다.
- 패널보다 평면도를 먼저 확인합니다. 축에 대한 카메라 쪽, 카메라와 각 피사체의 거리, 각 인물이 보는 방향입니다. `index.html`에서 씬마다 그려지는 평면도가 이 확인입니다.

180도 규칙, 네 가지 다리 방법, 시선 일치, 30도 규칙은 [`continuity.ko.md`](continuity.ko.md)에 있습니다. 렌더링 뒤가 아니라 블로킹할 때 읽습니다.

## 5. 카메라 값과 의도

샷마다 형용사가 아니라 숫자를 적습니다.

- 열거값에서 고른 `size`, 인물 또는 소품 id 하나인 `focus`, 초점과 함께 프레이밍할 인물의 `subjects`입니다.
- 모든 샷에 `yawDeg`, `rollDeg`, `focalMm`을 적습니다.
- `pitchDeg` 또는 `heightM` 중 하나만 적습니다. 카메라에 물리적 위치가 있을 때(식탁 가장자리, 바닥)는 `heightM`, 각도 자체가 지시일 때는 `pitchDeg`를 씁니다.
- 계산된 프레이밍 거리가 공간에 맞지 않을 때만 `distanceM`을 쓰고, `pov`와 `over`는 [`../references/output-contract.ko.md`](../references/output-contract.ko.md) §1.4의 규칙 안에서만 씁니다.
- in·out 계열에는 `endSize`를 붙인 `move`를, 샷 안에서 위치를 바꾸는 인물에는 `subjectMoves`를 씁니다.
- `durationSec`과 `transition`을 적습니다.
- `intent`에는 이 비트에 이 앵글이 왜 맞는지 한 문장으로 적습니다. 패널에는 인쇄되지 않고 검토자가 읽습니다.

앵글 경계, 지평선 규칙, 한국어 용어, 초점거리 표는 [`../references/camera-and-framing.ko.md`](../references/camera-and-framing.ko.md)에 있습니다.

## 6. JSON 작성

[`../references/output-contract.ko.md`](../references/output-contract.ko.md) §1대로 문서 하나를 만듭니다. `version: 1`, `title`, 선택 항목인 `aspect`, `sensorLongMm`, `panelsPerPage`, 그다음 `characters`와 `scenes`입니다.

- 모든 id가 해석됩니다. `focus`, `subjects`, `blocking.character`, `axis`, `subjectMoves.character`, `pov`, `over`가 존재하는 대상을 가리킵니다.
- id는 범위 안에서 겹치지 않고, 모든 열거값은 정해진 목록에서 나옵니다.
- 이 문서를 먼저 `storyboard.json`으로 씁니다. 다음 단계가 같은 바이트를 넣기 때문입니다.

## 7. 스튜디오 사본에 주입

[`../assets/storyboard-studio.html`](../assets/storyboard-studio.html)을 전달 폴더의 `index.html`로 복사하고, 문서를 문서 요소 안에 넣습니다.

```html
<script type="application/json" id="storyboard-doc">{ ...문서... }</script>
```

JSON 텍스트의 모든 `</`를 `<\/`로 이스케이프해 넣은 객체가 자기 스크립트 요소를 닫지 못하게 합니다. 다른 이스케이프는 필요하지 않습니다. 코어 스크립트, 스타일, 인쇄 규칙은 고치지 않습니다. 사본과 asset의 차이는 그 요소 하나뿐입니다.

## 8. 패널 그림

패널 그림은 `image-maker` 스킬에 위임해 만듭니다. 먼저 [`../references/panel-art.ko.md`](../references/panel-art.ko.md)를 읽습니다. 그림체, 브리프, 검사 항목, 대체 규칙은 그 파일이 다룹니다. 능력 관찰, 패널별 호출 두 번 한도, 거절 처리, `.hyper/image-maker/<topic>/` 저장은 image-maker가 맡습니다.

- `compilePanelPrompt(doc, sceneId, shotId)`를 호출해 문자열을 그대로 보관합니다. 사실 오류가 있는지 한 번 읽고 나면 고치지 않습니다.
- `renderGuideSvg(doc, sceneId, shotId)`를 호출해 가이드를 보관하되, 스토리보드 쪽 용도로만 씁니다. 돌아온 그림을 검사할 때 구도 참고로 나란히 보고, 래스터화하거나 이미지 동작에 넘기지 않습니다.
- 컴파일한 프롬프트만 브리프로 `image-maker`를 호출합니다. 참고 이미지는 어떤 것도 붙이지 않습니다. 가이드, 앞 패널, 캐릭터 시트, 그림체 이미지, 외부 이미지가 모두 해당합니다. 인물 일관성은 컴파일된 프롬프트 안의 고치지 않은 `characters[].look` 문구만으로 전달합니다.
- 돌아온 그림마다 검사 표의 모든 항목을 봅니다. 샷 크기, 앵글, 뷰, 더치 기울기, 향한 쪽, 피사체 수, 글자, 외형, 구도, 프레임 장식입니다. 한 항목이라도 실패한 그림은 내장하지 않습니다.
- 통과한 그림을 샷의 `shots[].image`에 넣습니다. `src`는 `data:image/png`, `data:image/jpeg`, `data:image/webp` URI이고, `provenance`는 `"generated"`, `prompt`는 컴파일한 문자열 그대로입니다. URL, 파일 경로, blob은 쓰지 않습니다.
- `image-maker`가 설치되어 있지 않거나 `prompt_saved`나 `blocked`로 끝나면 선화를 두고 `image`를 비워 둡니다. 컴파일한 프롬프트를 `shot-list.md`에 `PROMPT SAVED` 메모와 표 뒤의 `SH <id>` 블록으로 쓰고, 대체한 패널을 전달 메시지에 id로 밝힙니다.

패널은 샷 순서로 처리하고 다음 패널을 시작하기 전에 검사합니다. 그래야 설계가 어긋난 것이 시퀀스 전체로 번지지 않습니다. 패널 단계가 끝나면 통과한 그림을 담은 문서를 `storyboard.json`에 다시 쓰고, 같은 `<\/` 이스케이프로 `index.html`에 다시 주입해 9~11단계가 같은 바이트를 읽고 전달하게 합니다.

씬마다 위에서 내려다본 평면도 그림을 하나 둘 수 있습니다. `compileFloorPlanPrompt(doc, sceneId)`로 브리프를 만들어 같은 규칙으로 `image-maker`에 넘깁니다. 모든 소품과 인물이 기술 평면도와 같은 자리에 있는지, 글자가 없는지 확인한 뒤 `scenes[].planImage`에 저장합니다. 기술 평면도는 계속 그려지고 기준으로 남습니다.

## 9. 브라우저에서 열고 보고서 읽기

`index.html`을 브라우저에서 열고 콘솔이나 사용 중인 브라우저 자동화로 `window.storyboardStudio.getReport()`를 호출합니다. 화면 모양이 아니라 돌려받은 객체를 읽습니다.

- `errors`는 빌드를 멈추고 패널을 0개로 남깁니다.
- `warnings`는 패널 배지와 요약으로 표시되지만 막지 않습니다.
- `info`는 `HORIZON_OFFFRAME`처럼 예상된 상태를 기록합니다.
- `intentional`은 `crossing`을 단 샷을 모두 나열합니다.
- `panels`와 `scenes`는 실제로 렌더링된 수입니다.

그럴듯해 보이는 화면도 오류 상태일 수 있습니다. 그때는 `#status[data-error="true"]`이고 패널이 하나도 없습니다. 객체와 상태 속성을 확인합니다.

브라우저가 없으면 [`../references/output-contract.ko.md`](../references/output-contract.ko.md) §6대로 `node`나 `bun`으로 코어를 실행하고 출력에서 `validate`와 `lint`를 읽습니다. 주입한 사본에는 `<\/` 이스케이프가 있으므로 이 실행은 `storyboard.json`을 가리킵니다. 브라우저도 자바스크립트 런타임도 없으면 그 사실을 밝히고 보고서를 수집하지 못한 상태로 전달합니다.

## 10. 오류 수정과 경고 검토

오류는 변명하지 않고 고칩니다.

- 문서를 고치고 다시 렌더링한 뒤 보고서를 다시 읽습니다. 스키마 오류는 보통 경로 하나에 있고 수정 한 번으로 사라집니다.
- 모든 경고를 검토합니다. 기하를 고칩니다. `AXIS_CROSSED`, `EYELINE_MISMATCH`, `SCREEN_DIRECTION_FLIP`은 대신 `method`, `intentional: true`, 효과를 밝히는 `reason`을 갖춘 `crossing`으로 기록해도 됩니다. `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, `WIDE_LENS_FACE`는 기록할 수 없으므로 반드시 고칩니다.
- `HORIZON_OFFFRAME`은 앵글이 의도한 것이면 그대로 둡니다. 그 정보 항목이 기록입니다.
- 한 회차는 수정 한 번, 재렌더링 한 번, 보고서 다시 읽기 한 번입니다. 최대 두 회차입니다. 두 회차 뒤에는 남은 경고 코드를 전달 메시지에 적고 전달합니다. 해결되지 않은 오류가 있으면 전달하지 않습니다. 보드가 좋아 보일 때까지 계속 고치지 않습니다.
- 그림이 있는 샷의 `size`, 카메라 값, `move`, `subjects`를 바꾸는 수정을 한 뒤에는 그 샷에 대해 새로 컴파일한 프롬프트로 8단계를 다시 실행하되 image-maker의 호출 두 번 한도 안에서 하거나, `image`를 빼고 프롬프트를 대체 패널로 저장합니다. 그다음 문서를 다시 주입한 뒤 보고서를 다시 읽습니다.

## 11. 전달

`.hyper/storyboard-maker/<slug>/` 폴더를 씁니다. `<slug>`는 영화를 가리키는 짧은 케밥 표기 이름입니다.

| 파일 | 내용 |
|---|---|
| `index.html` | 문서를 넣은 스튜디오 사본 |
| `storyboard.json` | 렌더링한 그대로의 문서 |
| `shot-list.md` | [`../references/output-contract.ko.md`](../references/output-contract.ko.md) §3의 한국어 샷 표, 선화로 대체한 패널마다의 `SH <id>` 프롬프트 블록 |
| `manifest.json` | `getReport()` 객체 그대로 |

폴더를 끝났다고 하기 전에 [`validation.ko.md`](validation.ko.md)를 실행합니다. 전달 메시지에는 폴더, 보고서 수치, 남은 경고나 의도적 위반을 적습니다.

## Sources

> 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| 샷 번호를 10 단위로 붙이면 인서트를 나중에 15로 끼워 넣고 번호를 다시 매기지 않아도 된다 | <https://storyboardart.org/storyboard-tutorials/storyboard-format-for-film/> |
| 패널은 씬, 샷 크기, 카메라 노트, 액션, 선택적 대사, 전환으로 구성한다 | <https://storyboardart.org/storyboard-tutorials/storyboard-format-for-film/> |
| A4 가로 인쇄는 `@page { size: A4 landscape; margin: … }`로 선언하고 패널은 쪽 나눔을 피한다 | <https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page> |
| 이 패키지의 입력 문서, 보고서 필드, 브라우저 없는 코어 실행 | [`../references/output-contract.ko.md`](../references/output-contract.ko.md) |
| 이 패키지의 패널 이미지 가이드, 프롬프트, 생성 한도, 검사, 대체 | [`../references/panel-art.ko.md`](../references/panel-art.ko.md) |
| 이 패키지의 네 가지 선 넘기 방법과 기록된 위반 | [`continuity.ko.md`](continuity.ko.md) |
