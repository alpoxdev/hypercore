# 산출물

**목적**: 완성된 설명이 독자가 열고 인쇄하고 공유할 수 있는 파일로도 존재하게 한다. 설명 자체는 바뀌지 않는다.

이 문서는 설명이 확정된 뒤에 읽는다. 산출물은 [`validation.md`](validation.md)의 다섯 문항 게이트를 이미 통과한 설명을 옮겨 담은 것이며, 설명을 새로 만들거나 늘리는 자리가 아니다.

## 1. 형식 선택

사용자는 한 가지 형식이나 조합을 고른다. 자연어가 기본 창구이고, 결정론이 필요한 호출자를 위해 정확한 토큰을 함께 문서화한다.

| 형식 | 정확한 토큰 | 생성 파일 | 만드는 주체 |
|---|---|---|---|
| 마크다운 | `md` | `explanation.md` | 직접 쓴다. 렌더러는 관여하지 않는다. |
| HTML | `html` | `explanation.json`, `explanation.html` | JSON은 직접 쓰고, HTML은 `scripts/render-explanation.mjs`가 만든다. |
| PDF | `pdf` | `html`의 파일 전부 + `explanation.pdf` | 브라우저로 HTML을 인쇄한다. |
| 조합 | `md,html,pdf` | 위 행들의 합집합 | 위와 같다. |
| 미지정 | — | 파일 없음 | 대화 응답만 낸다. |

- `pdf`는 `html`을 함의한다. PDF는 HTML의 인쇄물이므로 HTML을 먼저 만든다.
- `explanation.md`는 대화 응답과 같은 내용을 담는다. 응답을 파일로 복사하는 것은 두 번째 설명이 아니다.
- 형식을 요청받았는데 브라우저가 없으면 `explanation.pdf`만 생략하고 나머지는 그대로 만든 뒤 한계를 밝힌다.

## 2. 산출물을 만드는 시점

요청이 산출물을 요구할 때만 파일을 만든다.

- 명시적 산출물 요청(형식 이름, "저장해줘", "파일로 줘", "인쇄할 수 있게")이 있어야 한다.
- 구조적으로 큰 설명은 산출물을 *제안*할 수 있지만, 요청 없이 쓰지 않는다.
- 짧은 답에는 파일도 제안도 붙이지 않는다.
- 설명을 명확히 하거나 질문에 답하거나 결정을 돕는 경우는 대화에 남긴다.

## 3. 산출물 위치

작업 중인 프로젝트의 `.hyper/eli5/<slug>/` 아래에 쓴다.

`<slug>`는 요청받은 주제에서 유도한다.

1. ASCII 영문과 숫자만 남기고 소문자로 바꾼다. 그 외 문자(한글 포함)의 연속은 `-` 하나로 줄인다.
2. 앞뒤 `-`를 제거한다.
3. 결과가 빈 문자열이면 `explanation`을 쓴다.
4. 디렉터리가 이미 있으면 `-2`, `-3` 순으로 빈 이름을 찾는다. 기존 디렉터리의 파일을 덮어쓰지 않는다.

예: `Database index`는 `database-index`, `캐시가 뭐야`는 `explanation`, 두 번째 한국어 주제는 `explanation-2`.

## 4. 구조 뷰

`explanation.html`은 자체 완결 페이지다. 파일 하나, 네트워크 없음, 외부 폰트 없음, 빌드 단계 없음. 설명의 기존 계층, 메커니즘 단계, 비유와 그 한계, 용어, 주의점을 그린다.

JSON 스키마, 렌더러 명령, 오류 계약은 [`../references/explanation-view-schema.md`](../references/explanation-view-schema.md)에 있다.

인터랙션은 다섯 가지로 한정한다. 테마 전환, 계층별 접기, 모두 펼치기/접기, 메커니즘 단계 하이라이트, 용어 위치 이동. 검색·경로 추적·프레젠테이션 모드·내보내기 메뉴 같은 더 큰 기능은 다이어그램 도구의 몫이지 설명의 몫이 아니다.

## 5. PDF 경로

탐지는 렌더러가 아니라 담당자(에이전트)의 일이다. 렌더러는 프로세스를 띄울 수 없다.

```bash
CANDIDATES=(
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  "/Applications/Chromium.app/Contents/MacOS/Chromium"
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
)
BROWSER=""
for candidate in "${CANDIDATES[@]}"; do [ -x "$candidate" ] && BROWSER="$candidate" && break; done
if [ -z "$BROWSER" ]; then for name in google-chrome chromium chromium-browser microsoft-edge; do p="$(command -v "$name" 2>/dev/null)" && [ -n "$p" ] && BROWSER="$p" && break; done; fi
```

Windows 후보는 `%ProgramFiles%\Google\Chrome\Application\chrome.exe`와 `%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe`다.

그다음 인쇄한다.

```bash
"$BROWSER" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="<artifact-dir>/explanation.pdf" \
  "<artifact-dir>/explanation.html"
```

- 브라우저를 찾지 못하면 PDF 단계만 건너뛰고 정확히 이 문구를 보고한다.
  `Chromium 계열 브라우저를 찾지 못해 PDF를 만들지 않았습니다. <artifact-dir>/explanation.html을 브라우저로 열어 인쇄하면 PDF를 얻을 수 있습니다.`
- 브라우저를 설치하거나 내려받지 않고, 네트워크로 무엇도 가져오지 않는다.
- `explanation.html`은 모든 경우에 남긴다. 실패 경로에서도 그렇다.

## 6. 충실성 가드

뷰는 설명이 이미 말한 것 외에는 아무것도 더하지 않는다.

- 계층, 메커니즘 단계, 용어, 주의점, 비유의 한계는 확정된 설명에서 추출만 하고 페이지를 위해 지어내지 않는다.
- 페이지에만 있는 새 수치, 출처, 날짜, 주장은 넣지 않는다.
- 비유의 한계는 비유와 함께 간다. 한계 없이 은유만 보여주는 뷰는 충실성 실패다.
- 설명이 미지 또는 불확실로 표시한 것은 뷰에서도 그 표시를 유지한다.

## 7. 실패 처리

- 렌더러가 실패하면 대화 응답을 유지하고 실패를 보고한다. 부분적이거나 오래된 뷰를 결과로 제시하지 않는다.
- 렌더러는 원자적으로 쓴다. 실패하면 이전 `explanation.html`이 바이트 단위로 보존되고 임시 파일이 남지 않는다.
- 실제로 존재하는 산출물 경로만 보고한다. 건너뛴 PDF를 만들었다고 하지 않는다.
