# 검증

> English version: [`validation.md`](validation.md)

전달 전과 이 패키지를 바꿀 때마다 읽습니다. 이 파일은 전달 전 체크리스트, 보고서 실패별 대응, 반복 한도, 패키지 변경이 통과해야 할 검사를 다룹니다.

## 1. 전달 전 체크리스트

- [ ] `.hyper/storyboard-maker/<slug>/` 폴더에 `index.html`, `storyboard.json`, `shot-list.md`, `manifest.json`이 있고, `index.html`은 스튜디오 사본이며 디스크에서 열립니다.
- [ ] 문서가 `<script type="application/json" id="storyboard-doc">` 안에 있고 그 안의 모든 `</`가 `<\/`로 이스케이프됐습니다. 코어 스크립트와 인쇄 규칙은 고치지 않았습니다.
- [ ] `storyboard.json`의 문서가 `index.html`에 내장한 문서와 같습니다. 모든 `shots[].image`와 그 프롬프트를 포함합니다.
- [ ] 실제 브라우저에서 `window.storyboardStudio.getReport()`를 읽었거나 출력 계약대로 `node`나 `bun`으로 코어를 실행했고, `errors`가 비어 있습니다.
- [ ] 선화가 썸네일 크기에서 읽힙니다. 실루엣 검사를 통과하고, 얼굴 중심선·눈점·코 쐐기·가슴선이 인물이 카메라를 향할 때만 나타나며, 머리카락 덩어리가 어느 각도에서나 뒤통수에 보여 앞과 뒤가 같게 읽히지 않습니다.
- [ ] 모든 패널의 카메라 줄이 정해진 순서로 숫자와 한국어 용어를 갖춥니다. 크기, 피치와 한국어 이름이 붙은 앵글 이름, 방위, 렌즈, 높이 이름이 붙은 카메라 높이, 그리고 롤이 0이 아닐 때만 붙는 `DUTCH`입니다.
- [ ] `STATIC`과 `HANDHELD`를 뺀 모든 무브가 피사체 바깥으로 나가는 화살표와 어휘에 있는 라벨을 갖습니다. `HANDHELD`는 라벨만 갖습니다. 패널마다 주동작은 최대 하나이고, 얼굴이나 손을 가로지르는 화살표가 없습니다.
- [ ] 연속성 경고를 해결했거나 기록했습니다. 설명 없는 `AXIS_CROSSED`, `EYELINE_MISMATCH`, `SCREEN_DIRECTION_FLIP`이 남아 있지 않고, `intentional[]` 항목마다 `method`, `intentional`, 비어 있지 않은 `reason`이 있습니다.
- [ ] 패널 메모가 씬·샷, 카메라 줄, 액션, 대사, 사운드, 길이, 전환 순서로 있고, 전환은 나가는 패널에 붙습니다.
- [ ] 샷 번호가 10 단위이고 인서트는 `15`나 `25`에 있습니다. 씬 번호는 대본을 따릅니다.
- [ ] 씬마다 패널과 맞는 평면도가 있습니다. 카메라가 선언한 축의 같은 쪽에 있고, 평면도의 방향선이 패널과 일치합니다.
- [ ] 인쇄 CSS가 그대로입니다. `@page { size: A4 landscape; margin: 12mm }`, 패널의 `break-inside: avoid`, `panelsPerPage` 반영입니다.
- [ ] `manifest.json`이 `getReport()` 객체 그대로이고, `panels`와 `scenes`가 화면에 보이는 수와 같습니다.
- [ ] 내장한 그림마다 `provenance`가 `generated` 또는 `supplied`로 정직하게 적혔고, 어떤 그림도 사진·영화 프레임·제작 스틸로 제시하지 않았습니다.
- [ ] 모든 그림이 내장 전에 검사 항목을 통과했습니다. 샷 크기, 앵글, 뷰, 향한 쪽, 글자·로고 없음, `characters[].look`과 앞서 승인한 패널에 맞는 외형입니다.
- [ ] 어느 패널도 세 번 이상 생성하지 않았고, 저장한 프롬프트는 컴파일된 문자열 그대로이며 시도 사이에 고치지 않았습니다.
- [ ] 대체한 패널은 모두 전달 메시지에 id로 밝혔고, 선화를 유지하며 `shot-list.md`에 `PROMPT SAVED` 메모와 `SH <id>` 블록을 남겼습니다.
- [ ] 생성 패널에 실존 인물·연예인·알아볼 수 있는 얼굴이 없고, 기존 영화의 프레임·포스터·스틸을 참고 이미지로 넣지 않았습니다.
- [ ] 네트워크가 없습니다. 원격 스크립트, 원격 `src`나 `href`, `fetch`, `XMLHttpRequest`, 웹 폰트 파일이 없고, 모든 `image.src`가 URL이나 파일 경로가 아닌 `data:image/...` URI입니다.
- [ ] 사용자가 읽는 문자열이 모두 한국어입니다. 표제, 액션 문장, 샷 리스트, `intent`가 여기에 해당합니다.
- [ ] 기존 영화의 프레임이나 콘티를 복제한 것이 없습니다. 연출, 자세, 카메라 값은 이 대본에서 나왔습니다.
- [ ] 모든 샷에 `intent`가 있고, 새 정보가 없는 샷이 없습니다.

## 2. 보고서 실패와 대응

화면 모양이 아니라 보고서 객체를 읽습니다. `#status[data-error="true"]`이고 패널이 하나도 없는데도 화면은 끝난 것처럼 보일 수 있습니다.

오류는 빌드를 멈추고 패널을 0개로 남깁니다. 오류마다 `path`가 있으니 그 경로를 고칩니다.

| 코드 | 대응 |
|---|---|
| `SCHEMA_REQUIRED` | 빠진 키를 넣거나, `OTS` 샷에 `camera.over`를 넣습니다. |
| `SCHEMA_TYPE` | 값의 타입을 고칩니다. `over`는 `OTS` 샷에만 붙습니다. |
| `SCHEMA_ENUM` | 값을 정해진 열거값 중 하나로 바꿉니다. |
| `SCHEMA_RANGE` | 숫자를 범위 안으로 넣습니다. 범위 밖 값은 보통 단위나 값 자체가 틀렸다는 뜻이므로 조용히 잘라 넣지 않습니다. |
| `SCHEMA_DUPLICATE` | 범위 안에서 겹친 id 하나를 바꿉니다. |
| `SCHEMA_REFERENCE` | 필드가 존재하는 인물이나 소품 id를 가리키게 합니다. |
| `SCHEMA_CONFLICT` | 겹쳐 정하는 입력 하나를 뺍니다. `pitchDeg`와 `heightM`이 함께 있거나, `pov`·`OTS` 샷에 고정 값이 붙은 경우입니다. |
| `CAMERA_GEOMETRY` | 카메라를 닿는 위치로 옮깁니다. 프레이밍 거리 안의 `heightM`을 고르거나, 유도 높이가 바닥 위에 남는 피치를 고릅니다. |

경고는 막지 않습니다. 선 관련 경고는 고치거나 `crossing`으로 기록하고, 나머지 세 가지는 고쳐서만 지웁니다.

| 코드 | 대응 |
|---|---|
| `AXIS_CROSSED` | `neutral`, `subject-move`, `camera-move`, `both`로 컷에 다리를 놓거나, `method: "none"`과 이유를 갖춘 `crossing`을 기록합니다. |
| `EYELINE_MISMATCH` | 다리 숏으로 카메라 하나를 반대쪽으로 옮기고 `layoutShot().facingScreen`을 다시 읽습니다. |
| `JUMP_CUT` | 각도를 30° 이상 바꾸거나, 크기 변화를 분명한 `axial` cut으로 만듭니다. |
| `SCREEN_DIRECTION_FLIP` | 이동 벡터를 유지하거나, 회전을 보여 주거나, `crossing`으로 반전을 기록합니다. |
| `PRIMARY_MOVE_OVERLOAD` | 무브 하나를 보조로 내리거나 샷을 나눕니다. |
| `WIDE_LENS_FACE` | 렌즈나 샷 크기를 바꿉니다. 가까운 얼굴에 넓은 렌즈를 남기지 않습니다. |

모든 수정에 두 규칙이 붙습니다.

- 렌더링 뒤에 문서를 고치면 화면에는 이전 보드가 남습니다. 다시 렌더링하고 보고서를 다시 읽은 뒤에 체크리스트를 믿습니다.
- 선 관련 경고는 기하를 고치거나 `crossing` 이유를 기록해서 지웁니다. `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, `WIDE_LENS_FACE`는 고쳐서만 지웁니다. 코드를 없애려고 샷을 지우는 것은 수정이 아닙니다.

## 3. 반복과 정지

체크리스트와 보고서를 함께 돌리고 실패한 항목을 고친 뒤 다시 읽습니다.

- 한 회차는 수정 한 번, 재렌더링 한 번, 보고서 다시 읽기 한 번입니다. 최대 두 회차입니다.
- 두 회차 뒤에는 남은 경고 코드를 전달 메시지에 적고 전달합니다. 보드가 좋아 보일 때까지 편집을 이어 가지 않습니다. 그 반복에는 끝이 없고 실제 결정을 가립니다.
- 보드에 필요한 사실(인물 키, 씬 순서, 화면비)을 원천이나 사용자 답에서 근거 있게 정할 수 없으면 멈추고 빠진 입력을 밝힙니다.
- 오류가 남아 있으면 전달 전에 멈춥니다. 오류는 메모를 붙여 전달하지 않습니다.
- 브라우저를 쓸 수 있을 때는 렌더링을 보지 않은 패널을 전달하지 않습니다. 문서에 적힌 브라우저 없는 대체 절차를 쓸 때는 시각 확인을 수집하지 못했다고 밝힙니다.

## 4. 패키지 변경 체크리스트

이 패키지를 바꿀 때만 해당합니다.

- [ ] 모든 Markdown 쌍에서 한영 대응이 맞습니다. 같은 `##` 섹션이 같은 순서로 있고 목록 항목과 표 행도 같습니다.
- [ ] 이 패키지의 코퍼스 검증기가 `--only storyboard-maker --json`으로 통과하고 `ok: true`를 보고합니다.
- [ ] 저작 검증기가 `--require-self-containment`와 이 패키지의 eval 파일을 `--evals`로 받아 오류 없이 통과합니다.
- [ ] `bun run --cwd scripts verify`가 종료 코드 0으로 끝납니다.
- [ ] 이 패키지를 추가하거나 이름을 바꿨으면 `README.md`의 스킬 개수와 카탈로그 행을 고칩니다.

## Sources

> 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| 이 패키지의 렌더러 오류·경고 코드, 원인, 억제 규칙 | [`../references/output-contract.ko.md`](../references/output-contract.ko.md) §5 |
| 인형을 읽히게 만드는 앞뒤 표식과 은선 제거 규칙 | [`../references/notation-and-drawing.ko.md`](../references/notation-and-drawing.ko.md) §9 |
| 보고서가 기준이며 오류 상태의 페이지는 패널을 렌더링하지 않는다 | [`../references/output-contract.ko.md`](../references/output-contract.ko.md) §4 |
| 이 패키지의 그림 검사 항목, 두 번 시도 한도, 정직한 출처 표시, 대체 기록 | [`../references/panel-art.ko.md`](../references/panel-art.ko.md) |
| A4 가로 인쇄와 쪽 나눔 회피는 `@page`와 `break-inside`를 쓴다 | <https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page> |
