# 구조 뷰 스키마

**목적**: 구조 뷰의 입력·명령·오류 계약을 정확히 고정해 렌더러와 호출자가 추측하지 않게 한다.

이 문서는 `explanation.html`의 레퍼런스다. HTML 산출물을 만들 때 읽는다. 산출물을 *만들지*를 결정하는 규칙은 [`../rules/output-artifacts.md`](../rules/output-artifacts.md)에 있다.

## 1. 렌더러 명령

```bash
node skills/eli5/scripts/render-explanation.mjs <artifact-dir>
```

- 인자는 정확히 하나, 산출물 디렉터리다. 렌더러는 `<artifact-dir>/explanation.json`을 읽고 `<artifact-dir>/explanation.html`을 쓴다.
- 런타임은 `bun`도 된다. 스크립트는 Node 내장만 쓰고 로컬 모듈을 import하지 않는다.
- 성공하면 exit 0과 stdout 한 줄 JSON을 낸다. 출력 경로는 일부러 넣지 않아 디렉터리가 달라도 그 줄이 바이트 단위로 같다.

```json
{"status":"ok","layers":2,"steps":1,"terms":1,"cautions":1}
```

- 실패하면 exit 1과 stderr 한국어 메시지 한 줄을 낸다. stdout은 비어 있으므로 호출자가 실패를 성공으로 오인할 수 없다.
- 쓰기는 원자적이다. 임시 파일을 만든 뒤 rename한다. 실패하면 이전 `explanation.html`이 바이트 단위로 보존되고 권한도 유지되며 임시 파일이 남지 않는다.
- 출력은 결정론적이다. HTML에 생성 시각, 난수, 호스트명, 환경 변수, 절대경로가 들어가지 않는다. 같은 입력은 바이트 단위로 같은 출력을 낸다.

## 2. 입력 스키마

닫힌 스키마다. 모르는 최상위 키는 위반이다.

```json
{
  "title": "필수, 1..120자",
  "summary": "필수, 요지 한 줄",
  "language": "선택, 소문자 BCP-47 태그, 기본 ko",
  "audience": "선택, 대상 독자 메모",
  "layers": [{ "id": "gist|model|mechanism|why|boundary|check", "label": "필수", "body": "필수" }],
  "mechanism": [{ "actor": "필수", "action": "필수", "effect": "필수" }],
  "analogy": { "text": "analogy가 있으면 필수", "limit": "analogy가 있으면 필수" },
  "terms": [{ "term": "필수", "plain": "필수" }],
  "cautions": ["문자열"],
  "sources": ["문자열"]
}
```

| 필드 | 필수 | 규칙 |
|---|---|---|
| `title` | 예 | trim 후 비어 있지 않고 120자 이하 |
| `summary` | 예 | trim 후 비어 있지 않음 |
| `language` | 아니오 | `^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$`와 일치. 정규화하지 않음. 기본 `ko` |
| `audience` | 아니오 | 있을 때 trim 후 비어 있지 않음 |
| `layers` | 예 | 1개 이상 배열. `id`는 중복 없이 아래 여섯 값만 |
| `mechanism` | 아니오 | `actor`, `action`, `effect`를 가진 객체 배열 |
| `analogy` | 아니오 | 있을 때 `text`와 `limit` 둘 다 필수 |
| `terms` | 아니오 | `term`과 `plain`을 가진 객체 배열 |
| `cautions` | 아니오 | 비어 있지 않은 문자열 배열 |
| `sources` | 아니오 | 비어 있지 않은 문자열 배열 |

모든 문자열은 trim 후 비어 있으면 위반이다. 배열로 선언한 필드는 배열이어야 한다. 위반은 모아서 함께 보고한다.

여섯 계층 id는 [`../SKILL.md`](../SKILL.md)의 `<explanation_shape>`에서 온다. `gist`, `model`, `mechanism`, `why`, `boundary`, `check`이며 확장하지 않는다. 각 계층이 무엇을 *담아야 하는지*는 [`../rules/explanation-method.md`](../rules/explanation-method.md)의 causal spine에서 온다.

## 3. 템플릿 토큰

렌더러는 토큰 아홉 개를 각각 정확히 한 번 치환한다. 토큰이 없거나 두 번 이상이면 실행을 멈춘다.

| 토큰 | 위치 | 내용 |
|---|---|---|
| `<!--{{LANG}}-->` | `<html lang="...">` 안 | `language` 값 |
| `<!--{{TITLE}}-->` | `<title>` 안 | 문서 제목, HTML 이스케이프 |
| `<!--{{SUMMARY}}-->` | 본문 상단 | 요지 한 줄 |
| `<!--{{LAYERS}}-->` | 본문 | 계층 레일 마크업 |
| `<!--{{MECHANISM}}-->` | 본문 | 메커니즘 단계 흐름 마크업 |
| `<!--{{ANALOGY}}-->` | 본문 | 비유와 그 한계 블록 |
| `<!--{{TERMS}}-->` | 본문 | 용어 목록 마크업 |
| `<!--{{CAUTIONS}}-->` | 본문 | 주의점 목록 마크업 |
| `/*{{DATA}}*/` | `<script type="application/json" id="eli5-data">` 안 | 인터랙션용 JSON 페이로드 |

템플릿의 `<script>` 요소는 정확히 두 개다. 그 데이터 블록과 인터랙션용 인라인 스크립트 하나다. 내용은 실제 마크업으로 렌더되므로 자바스크립트 없이도 페이지가 온전하고, 인쇄 스타일시트가 스크립트 상태에 의존하지 않는다.

## 4. 이스케이프와 주입 안전성

- 삽입되는 모든 문자열은 `&`, `<`, `>`, `"`를 HTML 이스케이프한다.
- JSON 페이로드는 `<`를 `\u003c`로 직렬화한다. 그래야 데이터 안의 `</script>`가 데이터 블록을 닫지 못한다.
- `<b>`, `&`, `"`, `</script>`가 들어간 제목도 데이터 블록이 파싱되고 화면 텍스트에 그 문자가 그대로 보이는 페이지를 만들어야 한다.

## 5. 오류 계약

| 조건 | exit | stderr 포함 문자열 |
|---|---|---|
| 인자 개수가 1이 아님 | 1 | `사용법: scripts/render-explanation.mjs <artifact-dir>` |
| 템플릿 없음 | 1 | `뷰 템플릿이 없습니다: <path>` |
| 입력 없음 | 1 | `explanation.json이 없습니다: <path>` |
| JSON 파싱 실패 | 1 | `explanation.json JSON 파싱에 실패했습니다: <detail>` |
| 스키마 위반 | 1 | `explanation.json 스키마 위반: <field>` (여러 개면 `,`로 연결) |
| 템플릿 토큰 누락 또는 중복 | 1 | `뷰 템플릿 토큰이 없습니다: <token>` |
| 쓰기 실패 | 1 | `뷰 출력을 쓰지 못했습니다: <path>` |

## 6. 예제

캐시 설명의 완전하고 유효한 입력이다.

```json
{"title":"캐시","summary":"자주 쓰는 값을 가까이에 두고 다시 계산하지 않는 것","language":"ko","layers":[{"id":"gist","label":"한 줄 정의","body":"캐시는 자주 쓰는 값을 빠르게 꺼낼 수 있는 곳에 잠시 두는 장치다."},{"id":"boundary","label":"한계","body":"원본이 바뀌면 오래된 값을 돌려줄 수 있다."}],"mechanism":[{"actor":"클라이언트","action":"값을 요청한다","effect":"캐시가 먼저 응답한다"}],"analogy":{"text":"책상 위에 두는 메모","limit":"메모는 저절로 갱신되지 않는다"},"terms":[{"term":"캐시","plain":"빠른 임시 저장소"}],"cautions":["캐시된 값이 최신이 아닐 수 있다"],"sources":[]}
```

이 입력으로 렌더러를 돌리면 1절의 JSON 줄을 내며 exit 0으로 끝난다.
