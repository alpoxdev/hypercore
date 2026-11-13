# 렌더링과 검증

첫 렌더링 전과 전달 전에 이 규칙 파일을 사용합니다. 명령 셋, 보고 필드, 수정 반복, 마무리 보고를 담습니다.

## 1. 만들기

```bash
bash <skill-dir>/scripts/render-deck.sh --spec <out-dir>/<slug>.deck.json --out-dir <out-dir> \
  [--name <slug>] [--formats pptx,html,png[,pdf]] [--scale 1-3] [--browser <path>] [--budget-ms <ms>] [--no-check]
```

- 기본값은 `--formats pptx,html,png`, `--scale 1`이고 이름은 spec 파일 이름에서 가져옵니다. `--budget-ms`는 `30000`입니다.
- `--browser`나 `HYPER_PPTX_BROWSER`로 렌더러를 고르고, `--list-browsers`로 실제로 있는 후보를 봅니다.
- 종료 코드: `0`은 만들고 모든 검사 통과, `1`은 만들었지만 배치 검사 실패, `2`는 사용법 또는 spec 오류, `3`은 막힘(브라우저, zip, 런타임 결과 없음)입니다.

표준 출력은 JSON 객체 하나입니다.

| 필드 | 뜻 |
|---|---|
| `status` | `pass` 또는 `fail` |
| `slides` | 슬라이드 수 |
| `checks` | `{code, message}` 배열. `LAYOUT_OVERFLOW`는 글자가 상자보다 크다는 뜻이고 `OUTSIDE`는 도형이 슬라이드 경계를 넘는다는 뜻입니다 |
| `images` | 쓴 PNG의 `[{index, path}]` |
| `pptx`, `html` | 절대 경로, 요청하지 않았으면 `null` |

## 2. 읽기

```bash
bash <skill-dir>/scripts/inspect-deck.sh --file <deck.pptx> [--outline|--json] [--slide <n>] [--check]
```

`slideCount`, 크기, 글꼴과 슬라이드마다 `shapes`(이름, 종류, 좌표, 글자), `notes`, `table`(2차원 배열), `chart`(`{type, categories, series}`), 캔버스를 벗어난 도형을 보고합니다.

- 검사가 실패했을 때 자기 산출물에, 편집 전에 남의 덱에 실행합니다.
- `--check`는 캔버스를 벗어난 도형이 있으면 1로 끝납니다.

## 3. 기존 덱 편집

```bash
bash <skill-dir>/scripts/edit-deck.sh --file <in.pptx> --out <out.pptx> \
  [--replace "old=>new"]... [--set-font <name>] [--set-font-ea <name>] [--drop-slide <n>]... [--allow-miss]
```

- 텍스트 노드, 글꼴 속성, 이름 붙인 슬라이드 파트만 바뀝니다. 원본의 레이아웃, 마스터, 이미지, 사용자 XML은 남습니다.
- 아무것도 못 찾은 `--replace`는 `missed`에 적히고 종료 코드 1이 됩니다. 실행이 나뉜 문구는 안전하게 바꿀 수 없기 때문입니다. 찾는 문자열을 줄여 다시 실행하거나, spec으로 슬라이드를 다시 씁니다.
- `--drop-slide`는 슬라이드 파트, 그 관계, 노트, 차트, `sldId`, 관계 항목, 콘텐츠 타입 항목을 지우고 모든 XML 파트를 다시 검사합니다.

## 4. 수정 반복

피드백은 `checks`와 PNG에서 보이는 것입니다. 통과 기준은 `status: pass`와 모든 PNG를 읽는 것입니다. 상한은 첫 렌더링 뒤 세 번입니다.

| 검사 코드 | 흔한 원인 | spec에서 고칠 곳 |
|---|---|---|
| `LAYOUT_OVERFLOW` | 글자가 상자 높이를 넘음 | 단어를 줄이거나, 슬라이드를 나누거나, 하위 항목을 뺍니다 |
| `LAYOUT_OUTSIDE` | 도형이 슬라이드 경계를 넘음 | 행이나 열 수를 줄입니다 |
| `LAYOUT_OVERLAP` | 글자 블록 둘이 서로를 덮음 | 캡션이나 카드가 이미 있는 자리에 글자를 놓았습니다 |
| `LAYOUT_SPARSE` | 캔버스의 3분의 1도 쓰지 않음 | 짧은 한 줄뿐인 슬라이드입니다. 요소를 하나 더 두거나 합칩니다 |
| `IMAGE_NO_ALT` | 그림에 대체 텍스트가 없음 | `alt`를 씁니다. 없으면 그림은 보이지 않는 것과 같습니다 |
| `IMAGE_REMOTE` | 이미지 경로가 주소임 | 파일을 내려받아 로컬 경로를 넘깁니다 |
| `IMAGE_UNREADABLE` | 파일에서 픽셀 크기를 읽을 수 없음 | 파일을 바꾸거나 맞는 `aspect`를 적습니다 |
| `RELATIONSHIP_BROKEN` | 패키지 파트가 빠짐 | spec 문제가 아니라 스킬 버그입니다. 보고합니다 |
| `XML_INVALID` | 파트 형식이 깨짐 | 위와 같습니다 |

검사를 늘린 수정은 되돌립니다. 세 번을 다 쓰면 전달하지 않고 남은 결함을 보고합니다.

## 5. PNG가 증명하는 것

PNG는 `.pptx`를 만든 것과 같은 해석 JSON으로 이 패키지의 뷰어가 1/9525 축척으로 그립니다. 기하와 글자가 들어가는지를 증명합니다. 읽는 사람의 파워포인트가 같은 글꼴을 보여 준다는 것과, 차트 축이 파워포인트 렌더러와 같다는 것은 증명하지 않습니다. 중요한 덱이면 이 한계를 함께 적습니다.

차트와 그림에서 이 차이가 가장 큽니다. 혼합 차트의 보조 축, 산점도의 x 배치, `srcRect` 크롭은 패키지와 미리보기가 각각 한 번씩 그립니다. 둘이 어긋나면 읽는 사람이 여는 것은 패키지이고 작성자가 승인한 것은 미리보기입니다. 차트나 그림이 주장을 지는 슬라이드에서는 둘을 맞춰 봅니다.

PNG를 모두 보는 것은 형식이 아닙니다. 이 패키지를 만들며 고친 결함 셋은 자동 검사를 모두 통과했고 이미지에서만 보였습니다. 막대를 그리지 않은 혼합 차트, 대각선으로 그려진 산점도, 눈금선을 가린 불투명 면으로 채워진 영역 차트입니다.

## 5-1. 결정성

한 spec을 두 번 렌더링하면 바이트 단위로 같은 `.pptx`가 나와야 합니다. 모든 파트의 시간을 `1980-01-01 00:00`으로 고정하고, 구성원 목록을 정렬하며, `zip -X`로 부가 속성을 지웁니다. 확인하려면 다른 디렉터리에 두 번 렌더링하고 `shasum -a 256`을 비교합니다. 해시가 같아야 합니다. 다르면 무언가 시계나 파일 시스템 순서를 읽고 있다는 뜻이고, 두 덱의 차이가 변경이 아닌 변경으로 보이게 됩니다.

## 6. 전달 전에

- `status: pass`이고 슬라이드마다 PNG를 열어 읽었는지.
- 전달할 파일에 `inspect-deck.sh --check`를 돌려 0으로 끝났는지.
- 모든 슬라이드와 차트 파트를 ECMA-376 스키마로 검증했는지. 관문은 `xmllint --schema`이고 "파워포인트가 열었다"가 아닙니다. 결과를 읽기 전에 출력의 `failed to load` 가져오기 경고를 걸러 냅니다.
- 같은 spec을 두 번 렌더링한 해시가 같은지.
- spec의 `slides` 수와 요청이 맞는지. 슬라이드 수, 주장, 없는 내용을 만들지 않았는지.
- `.pptx`(그리고 쓴 경우 HTML, PNG)의 절대 경로, 슬라이드 수, 팔레트와 글꼴, 실행한 검사, 해당되는 한계를 보고합니다.

## Sources

> 확인 2026-11-13.

| Claim | Source |
|---|---|
| 프레젠테이션 파트 구조와 슬라이드 순서 | <https://learn.microsoft.com/en-us/office/open-xml/presentation/structure-of-a-presentationml-document> |
| 노트와 관계 파트 | <https://learn.microsoft.com/en-us/office/open-xml/presentation/working-with-notes-slides> |
| 차트 값 캐시 | <https://learn.microsoft.com/en-us/office/open-xml/presentation/working-with-charts> |
| 결정적 zip 출력(고정 시각, `-X`) | <https://linux.die.net/man/1/zip> |

### 근거 등급

`LOCAL` - 종료 코드, 보고 필드, 검사 코드는 이 패키지의 스크립트 셋에서 읽었고 2026-11-13에 일부러 넘침을 만들고 고쳐 다시 렌더링하는 과정까지 확인했습니다.
