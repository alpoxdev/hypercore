# inblog 양식

> 영어 원본: [`inblog-format.md`](inblog-format.md)

판별된 플랫폼이 `inblog`일 때만 전달 전에 [`format-options.ko.md`](format-options.ko.md)에서 이어 읽습니다. 이 파일은 inblog의 배치, 메타데이터, 에디터 사실, 실측한 붙여넣기 결과를 담습니다. 네이버 동작은 다루지 않습니다. 네이버 에디터 관찰값은 [`format-options.ko.md`](format-options.ko.md) §2에 남고, 네이버 랭킹 참조는 inblog 글에서 읽지 않습니다.

## 목차

- 1. 전달
- 2. 본문 배치
- 3. 본문과 분리된 메타데이터
- 4. 네이티브 스키마
- 5. 붙여넣기 관찰값
- 6. 문서에 있는 에디터 블록과 이미지
- 7. Sources

## 1. 전달

- 기본은 본문 HTML이고 plain 텍스트는 명시적으로 요청할 때만 씁니다. 네이버와 같습니다([`format-options.ko.md`](format-options.ko.md) §1).
- **경로는 서식 붙여넣기입니다.** 출력 틀에서 `서식 콘텐츠 복사`를 누르면 렌더링된 본문이 `text/html`로 클립보드에 올라갑니다. 그다음 inblog의 **일반 편집 본문**에 `Ctrl+V` / `⌘V`로 붙여 넣습니다. 블록을 먼저 열지 않고 슬래시 메뉴도 쓰지 않습니다. 2026-11-03 실측에서 본문은 편집 가능한 inblog 블록으로 들어갔습니다. 링크, 굵게, 기울임, 밑줄, 취소선, 인라인 코드, 형광펜, 글자색, H2~H4, 중첩 목록, 인용, 구분선, 병합 셀이 있는 표, 언어가 잡힌 코드 블록, 작은 외부 이미지, 가운데 정렬이 모두 해당합니다(§5).
- 브라우저가 자동 복사를 막으면 출력 틀이 본문을 선택한 상태로 둡니다. 그때는 `Ctrl+C` / `⌘C`를 직접 누른 뒤 같은 본문을 붙여 넣습니다.
- **`HTML 소스 복사`는 본문 경로가 아닙니다.** 마크업을 plain 텍스트로 복사하므로 일반 편집 본문에는 서식 블록 대신 태그가 문자 그대로 보입니다.
- **HTML 임베드 블록은 외부 임베드 전용입니다**(지도, 영상, 위젯). 공식 문서에 따르면 이 블록에 넣은 내용은 HTML 블록 하나로 남고 일반 에디터 블록으로 변환되지 않으므로, 글 본문은 절대 이 블록에 넣지 않습니다.
- **Markdown은 경로가 아닙니다.** 공식 문서는 붙여 넣은 Markdown이 편집 가능한 inblog 블록이 된다고 적습니다. 그런데 2026-11-03 실측에서 이 에디터 빌드는 인라인 마크(굵게, 기울임, 취소선, 인라인 코드)만 해석했습니다. 소제목, 목록, 인용, 구분선, 표, 코드 펜스, Markdown 링크는 문자 그대로 남았습니다(§5 Markdown 열, 서식 16행 가운데 4행만 `native`이고 밑줄·형광펜·글자색은 소실). 그래서 이 패키지는 inblog 본문을 서식 붙여넣기로만 전달하고 Markdown 경로를 제공하지 않습니다.
- 붙여넣기로 생기지 않는 블록이 셋 있습니다. 콜아웃, 북마크, 링크 버튼이고, 글이 필요로 하면 에디터에서 `/` 명령으로 직접 삽입합니다(§5).

## 2. 본문 배치

inblog는 네이버가 아니며 네이버 리듬 계약이 적용되지 않습니다.

- 본문 문단은 **왼쪽 정렬 자연 문단**입니다. 12~25자 강제 줄바꿈을 넣지 않고 본문을 가운데 정렬하지 않습니다.
- 소제목은 `h2`~`h4`입니다(에디터의 제목 블록은 H2~H4를 다룹니다).
- `Title` 필드가 H1이므로 본문에는 **같은 H1을 중복하지 않습니다.** H2부터 시작하고 제목을 소제목으로 되풀이하지 않습니다.

## 3. 본문과 분리된 메타데이터

메타데이터 필드를 본문 HTML에 넣지 않습니다.

| 필드 | 위치 | 비고 |
|---|---|---|
| Title | `Title` 필드 | H1 역할. 화면에 보이는 제목 |
| Description | `Description` 필드 | 글의 제목 아래에 표시 |
| Meta title(선택) | 제목 필드 오른쪽의 톱니 버튼 | `<title>`을 설정. 비우면 글 제목을 씀 |
| Meta description(선택) | 설명 필드 오른쪽의 톱니 버튼 | 비우면 글 설명을 씀 |
| Slug | 에디터 상단 영역 | 사람이 읽는 URL 슬러그. 기본은 제목에서 생성되고 바꿀 수 있음 |
| Category | `+Categories` 버튼 | 글 분류 |
| CTA 버튼 | 본문 아래 `+ Add CTA button` | 버튼 문구(30자 이하 권장), 연결 URL, 버튼 색. 설정하지 않으면 표시되지 않음 |

바깥쪽 `Description` 상자는 자리표시자가 "Write meta description..."로 적혀 있어도 독자에게 보이는 설명입니다. 별도 meta description은 톱니를 눌러야 나타나는 안쪽 상자입니다. 지원되지 않는 메타데이터 필드를 본문에 넣지 않습니다.

전환형의 CTA 하나는 `+ Add CTA button`으로 한 번만 설정합니다. 본문 마무리 문장은 plain 텍스트로 두고 그 CTA를 본문 링크 버튼으로 만들지 않습니다.

inblog 글에는 **해시태그 요구도 에디터 주제 레인도 없습니다.** 네이버의 해시태그 규칙, 순위·알고리즘 참조, 데이터랩 수요 확인, 에디터 주제 선택을 inblog로 옮기지 않습니다. inblog 글의 주제 리서치는 공개 일반 리서치와 주제 자체의 1차 출처로 합니다.

## 4. 네이티브 스키마

API 스키마가 에디터가 저장하는 구조를 밝힙니다. <https://inblog.ai/openapi.json>의 `PostResource` 가운데 `content_html` 필드이고 2026-11-03에 확인했습니다. 에디터는 TipTap 기반이며 `editor.getHTML()`로 HTML을 만들므로, 아래 목록의 노드는 모두 편집 가능한 일반 블록입니다.

| 묶음 | 노드 |
|---|---|
| 기본 | `p`; `h2`, `h3`, `h4`(`h1`, `h5`, `h6` 블록 없음. 글의 H1은 Title 필드); 중첩을 지원하는 `ul`/`ol`/`li`; `strong`, `em`, `u`, `s`, `code`; `a`(`rel` 속성 없음, `nofollow` 제거); `blockquote`; `hr`; `br` |
| 고급 서식 | 여러 색을 쓰는 `mark`; `span style="color: #hex"`; `style="text-align: left\|center\|right"`; `pre > code.language-*` |
| 표 | `table`, `thead`, `tbody`, `tr`, `th`, `td`, 셀의 `colwidth`, 가로 스크롤용 래퍼 |
| 커스텀 블록(`data-type`) | `img data-type="imageBlock"`; `div data-type="imageGrid"`; `div data-type="imageCarousel"`; `div data-type="callOut"`; `div data-type="linkButton"`; `div data-type="bookmark"` |
| 임베드 | `data-youtube-video-id`가 붙은 `div data-type="youtube"`; `div data-type="googleForm"`, `"hubspot"`, `"tally"`, `"typeform"`; 원본 HTML은 안쪽 `div`를 둔 `section data-type="code-block"`을 씁니다(`div data-type="htmlCodeBlock"`은 스키마와 맞지 않음) |

같은 스키마에 따르면 `script` 태그는 제거되고, 이미지는 inblog CDN(`source.inblog.dev`)을 쓰는 것이 권장되며, 외부 스타일시트 링크는 제한되고, iframe은 허용된 임베드 서비스에만 쓸 수 있습니다. 이 목록은 에디터가 담을 수 있는 것이고, 이 패키지의 붙여넣기가 실제로 만드는 것은 §5에 적습니다.

## 5. 붙여넣기 관찰값

2026-11-03(KST)에 대시보드 블로그 `alpox`의 inblog 에디터에서 실제 클립보드 복사와 `Ctrl+V`로 측정하고, 뒤이어 `.ProseMirror`를 읽었습니다. `native`는 같은 의미의 편집 가능한 inblog 블록이나 마크가 남은 경우이고, `flattened`는 텍스트만 남은 경우입니다. Markdown 열은 같은 출력 틀에서 Markdown을 붙여 넣은 결과이며, 한계를 밝히려고 기록한 것이지 전달 경로가 아닙니다.

| 행 | 항목 | 서식 붙여넣기 | Markdown 붙여넣기 |
|---|---|---|---|
| P1 | 문단 속 링크 `https://www.naver.com` | native(`a[href]`. inblog는 `https://www.naver.com/`로 저장) | flattened(링크 문법이 문자로 남고 주소만 자동 링크가 됨) |
| P2a | strong | native | native |
| P2b | em | native | native |
| P2c | u | native | flattened(Markdown에 밑줄 문법 없음) |
| P2d | s | native | native |
| P2e | 인라인 코드 | native | native |
| P3 | mark | native | flattened |
| P4 | `span` 글자색 | native(`color: rgb(23, 63, 138)`이 붙은 `span`) | flattened(색 소실) |
| P5a | h2 | native | flattened(`## `가 문자로 남음) |
| P5b | h3 | native | flattened(`### `가 문자로 남음) |
| P5c | h4 | native | flattened(`#### `가 문자로 남음) |
| P6 | 중첩 `ul`·`ol` | native(중첩 유지) | flattened(줄마다 별도 문단) |
| P7 | blockquote | native | flattened(`> `가 문자로 남음) |
| P8 | hr | native(`hr`) | flattened(`---`가 문자로 남음) |
| P9 | `thead`가 있는 표 | native(`th` 셀이 `tbody`에 들어가고 `tableWrapper`가 붙음) | flattened(파이프 표가 텍스트로 남음) |
| P10 | `colspan`·`rowspan` 표 | native(병합 유지) | flattened(파이프 표가 텍스트로 남음) |
| P11 | `pre > code.language-javascript` | native(코드 블록, 언어가 `Javascript`로 잡힘) | flattened(펜스가 텍스트로 남음) |
| P12 | callOut | flattened(`/` 명령으로 직접 삽입) | flattened(`/` 명령으로 직접 삽입) |
| P13 | bookmark | flattened(`/` 명령으로 직접 삽입) | flattened(`/` 명령으로 직접 삽입) |
| P14 | linkButton | flattened(`/` 명령으로 직접 삽입) | flattened(`/` 명령으로 직접 삽입) |
| P15 | 외부 이미지(작은 PNG 한 건) | native(이미지 블록) | flattened(이미지 문법이 텍스트로 남음) |
| P16 | 가운데 정렬 문단 | native(`text-align: center`) | flattened(`text-align: left`) |

서식 붙여넣기는 서식 16행(P2a~P2e, P3, P4, P5a~P5c, P6~P11)이 모두 `native`이고 P1 링크도 `native`입니다. Markdown 붙여넣기는 서식 16행 가운데 4행(P2a, P2b, P2d, P2e)만 `native`입니다.

- inblog는 링크 주소를 정규화해 `https://www.naver.com`을 `https://www.naver.com/`로 저장합니다. 링크는 살아 있고 호스트와 경로도 같으므로, 원래 주소를 끝 슬래시 없이 그대로 비교하는 문자열 검사는 걸리지 않습니다.
- 코드 블록은 `class="language-javascript"`에서 언어를 읽은 에디터의 코드 블록 노드로 들어갑니다.
- P15 이미지는 작은 외부 PNG 한 건입니다. 큰 파일과 외부 주소로 바로 걸어 둔 이미지는 이 측정 범위 밖이므로, 이미지는 Image 블록으로 업로드합니다(§6).

## 6. 문서에 있는 에디터 블록과 이미지

공식 문서가 밝힌 에디터 블록은 제목(H2, H3, H4), 표, 목록, 인용, 코드 스니펫, 구분선, 콜아웃, 이모지, 북마크, 이미지(최대 10MB, JPG·PNG·GIF·WebP, **SVG 미지원**), HTML 임베드, 폼 임베드(HubSpot, Tally, Google Forms, Typeform)입니다. 슬래시 명령으로 블록을 넣고, 2026년 8월 업데이트로 슬래시 메뉴 키보드 이동, 인터페이스 언어별 명령 검색, 표 셀 간 `Tab` 이동, 선택한 여러 셀 한 번에 서식 지정이 추가됐습니다.

이 목록은 에디터가 담을 수 있는 것입니다. 이 패키지의 붙여넣기가 실제로 만드는 결과는 §5에 있으며, 목록에 있는 블록이라도 붙여넣기로 그 블록이 된다는 보장은 아닙니다.

### 이미지

- 이미지 마커(`[이미지: 대상 | 캡션]`, `[이미지 생성: 대상 | 캡션 | 프롬프트 #n]`)는 작성 보조 표시이고 본문 내용이 아닙니다. 에디터에서 마커를 지우고 파일은 Image 블록으로 업로드합니다.
- Image 블록은 10MB 이하 JPG, PNG, GIF, WebP 파일을 받고 SVG는 지원하지 않습니다. 스키마가 요구하는 inblog CDN(`source.inblog.dev`) 주소도 이 블록이 만듭니다.
- 작은 외부 https PNG 한 건이 실측 붙여넣기에서 이미지 블록으로 살아남았습니다. 그 한 행을 큰 파일이나 외부 주소 이미지에 일반화하지 않습니다.

## 7. Sources

> 외부 출처 확인 2026-11-03. 붙여넣기 세션은 이 패키지 자체의 실측입니다.

| 주장 | 출처 |
|---|---|
| §1 HTML 임베드는 HTML 블록 하나로 남고 일반 블록으로 변환되지 않음. 문서의 Markdown 주장. CTA 버튼 문구·URL·색. 이미지 최대 10MB와 SVG 미지원. 에디터 블록 목록 | <https://inblog.ai/docs/write-contents/creating-content> (공식. 문서 갱신 2026-09-08) |
| §4 저장되는 HTML 스키마. TipTap `getHTML()`, 태그 목록, `data-type` 블록, `code-block` section 래퍼, script 제거, CDN, iframe 제한 | <https://inblog.ai/openapi.json>의 `components.schemas.PostResource.properties.attributes.properties.content_html` (공식. 2026-11-03 확인) |
| §2 Title 필드가 H1 역할 | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (공식) |
| §3 별도 Description과 선택 Meta title / Meta description, slug, category | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (공식) |
| §6 표 셀 이동과 여러 셀 서식 지정, 슬래시 명령 키보드 이동 | <https://inblog.io/changelog/faster-tables-and-slash-commands> (공식. 2026-08-21) |
| §1, §5의 붙여넣기 결과, 경로, Markdown 한계 | 이 패키지 자체의 inblog 에디터 붙여넣기 세션, 대시보드 블로그 `alpox`, 2026-11-03(측정 22행, 실제 클립보드와 `Ctrl+V`) |

공식 문서의 Markdown 문장과 2026-11-03 실측은 서로 다릅니다. 문서는 붙여 넣은 Markdown이 블록별로 편집 가능한 내용이 된다고 적고, 실측은 인라인 마크만 해석됐습니다. 이 파일은 두 사실을 함께 적고 전달 계약은 실측을 따릅니다.

측정하지 않은 항목은 임베드(YouTube, 폼), 이미지 그리드와 캐러셀, 여러 색 형광펜, 큰 이미지와 CDN 업로드, HTML 임베드 블록 자체입니다. 출처가 밝힌 범위 밖으로 이 항목을 주장하지 않습니다.
