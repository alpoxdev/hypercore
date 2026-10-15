# inblog 양식

> 영어 원본: [`inblog-format.md`](inblog-format.md)

판별된 플랫폼이 `inblog`일 때만 전달 전에 [`format-options.ko.md`](format-options.ko.md)에서 이어 읽습니다. 이 파일은 inblog의 배치, 메타데이터, 에디터 사실을 담습니다. 네이버 동작은 다루지 않습니다. 네이버 에디터 관찰값은 [`format-options.ko.md`](format-options.ko.md) §2에 남고, 네이버 랭킹 참조는 inblog 글에서 읽지 않습니다.

## 1. 전달

- 기본은 본문 HTML이고 plain 텍스트는 명시적으로 요청할 때만 씁니다. 네이버와 같습니다([`format-options.ko.md`](format-options.ko.md) §1).
- 기본 HTML의 확인된 inblog 경로는 에디터의 **HTML 임베드 블록**입니다. 본문에서 `/`를 입력하고 HTML 임베드 블록을 고른 뒤 HTML을 붙여 넣습니다. 공식 문서에 따르면 이렇게 넣은 내용은 **HTML 블록으로 남고 inblog의 일반 에디터 블록(제목, 문단)으로 자동 변환되지 않으므로**, 그 상태로는 블록 단위로 편집할 수 없습니다.
- 같은 내용을 **일반 에디터 블록**으로 편집하는 것은 별도의 선택 경로입니다. 먼저 HTML을 Markdown으로 변환하고(온라인 HTML→Markdown 변환기를 쓸 수 있습니다) 그 결과를 붙여 넣으면, 붙여 넣은 Markdown이 소제목별·문단별로 편집 가능한 inblog 블록이 됩니다. 일반 블록을 원하는 사용자를 위한 보조 경로이며 기본이 아니고 서식 복사 경로도 아닙니다.
- 렌더링된 본문을 서식 있는 `text/html`로 복사해 inblog에 붙여 넣는 것은 이 패키지에서 **검증하지 않았습니다.** 그 붙여넣기에서 CSS, 표, 이미지가 살아남는다고 약속하지 않습니다. 확인된 경로는 문서에 명시된 HTML 임베드뿐입니다.

## 2. 본문 배치

inblog는 네이버가 아니며 네이버 리듬 계약이 적용되지 않습니다.

- 본문 문단은 **왼쪽 정렬 자연 문단**입니다. 12~25자 강제 줄바꿈을 넣지 않고 본문을 가운데 정렬하지 않습니다.
- 소제목은 `h2`와 `h3`입니다(에디터의 제목 블록은 H2~H4를 다룹니다).
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

바깥쪽 `Description` 상자는 자리표시자가 "Write meta description..."로 적혀 있어도 독자에게 보이는 설명입니다. 별도 meta description은 톱니를 눌러야 나타나는 안쪽 상자입니다. 지원되지 않는 메타데이터 필드를 본문에 넣지 않습니다.

inblog 글에는 **해시태그 요구도 에디터 주제 레인도 없습니다.** 네이버의 해시태그 규칙, 순위·알고리즘 참조, 데이터랩 수요 확인, 에디터 주제 선택을 inblog로 옮기지 않습니다. inblog 글의 주제 리서치는 공개 일반 리서치와 주제 자체의 1차 출처로 합니다.

## 4. 문서에 있는 에디터 블록 (클립보드 보장 아님)

공식 문서가 밝힌 에디터 블록은 제목(H2, H3, H4), 표, 목록, 인용, 코드 스니펫, 구분선, 콜아웃, 이모지, 북마크, 이미지(최대 10MB, JPG·PNG·GIF·WebP, **SVG 미지원**), HTML 임베드, 폼 임베드(HubSpot, Tally, Google Forms, Typeform)입니다. 슬래시 명령으로 블록을 넣고, 2026년 8월 업데이트로 슬래시 메뉴 키보드 이동, 인터페이스 언어별 명령 검색, 표 셀 간 `Tab` 이동, 선택한 여러 셀 한 번에 서식 지정이 추가됐습니다.

이것은 **문서에 적힌 에디터 기능이며 클립보드 붙여넣기 시험 결과가 아닙니다.** 지원되는 블록 종류가 있다고 해서 외부 HTML이 서식을 그대로 유지한 채 그 블록으로 들어간다는 뜻은 아닙니다. 이 목록은 에디터가 담을 수 있는 것이지 바깥에서 붙여 넣었을 때 살아남는 것이 아닙니다.

## 5. Sources

> 외부 출처. 확인 2026-10-15.

| 주장 | 출처 |
|---|---|
| §1 HTML 임베드는 HTML 블록으로 남고 자동 변환되지 않음. Markdown 붙여넣기는 편집 가능한 블록이 됨. 이미지 최대 10MB, SVG 미지원. 에디터 블록 목록. CTA 설정 | <https://inblog.ai/docs/write-contents/creating-content> (공식. 문서 갱신 2026-09-08) |
| §2 Title 필드가 H1 역할 | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (공식) |
| §3 별도 Description과 선택 Meta title / Meta description, slug, category | <https://inblog.ai/docs/write-contents/understanding-the-inblog-editor> (공식) |
| §4 표 셀 이동과 여러 셀 서식 지정, 슬래시 명령 키보드 이동 | <https://inblog.io/changelog/faster-tables-and-slash-commands> (공식. 2026-08-21) |

미검증. inblog에 로그인해 렌더링된 HTML을 붙여 넣는 것은 확인하지 않았습니다. 그 붙여넣기에서의 CSS, 병합 셀, 이미지, 특수 블록 보존은 주장하지 않습니다.
