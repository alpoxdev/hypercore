# Explanation View Schema

**Purpose**: Define the exact input, command, and error contract of the structure view so the renderer and its caller never have to guess.

This is the reference for `explanation.html`. Read it when producing an HTML artifact; the rules that decide *whether* to produce one live in [`../rules/output-artifacts.md`](../rules/output-artifacts.md).

## Contents

- 1. Renderer command
- 2. Input schema
- 3. Template tokens
- 4. Escaping and injection safety
- 5. Error contract
- 6. Worked example
- Sources

## 1. Renderer command

```bash
node skills/eli5/scripts/render-explanation.mjs <artifact-dir>
```

- Exactly one argument: the artifact directory. The renderer reads `<artifact-dir>/explanation.json` and writes `<artifact-dir>/explanation.html`.
- `bun` works as the runtime as well. The script uses only Node built-ins and imports no local module.
- On success: exit 0 and exactly one line of JSON on stdout. The output path is deliberately absent, so the line stays byte-identical across directories:

```json
{"status":"ok","layers":2,"steps":1,"terms":1,"cautions":1}
```

- On failure: exit 1 and one Korean message on stderr. stdout stays empty, so a caller can never mistake a failure for success.
- Writes are atomic: a temporary file is created and renamed into place. A failure preserves the previous `explanation.html` byte for byte, keeps its mode, and leaves no temporary file.
- Output is deterministic. The HTML contains no generation time, random value, hostname, environment variable, or absolute path. The same input produces byte-identical output.

## 2. Input schema

A closed schema: an unknown top-level key is a violation.

```json
{
  "title": "required, 1..120 characters",
  "summary": "required, one-line gist",
  "language": "optional, lowercase BCP-47 tag, default ko",
  "audience": "optional, note about the target reader",
  "layers": [{ "id": "gist|model|mechanism|why|boundary|check", "label": "required", "body": "required" }],
  "mechanism": [{ "actor": "required", "action": "required", "effect": "required" }],
  "analogy": { "text": "required when analogy is present", "limit": "required when analogy is present" },
  "terms": [{ "term": "required", "plain": "required" }],
  "cautions": ["string"],
  "sources": ["string"]
}
```

| Field | Required | Rule |
|---|---|---|
| `title` | yes | non-empty after trim, at most 120 characters |
| `summary` | yes | non-empty after trim |
| `language` | no | matches `^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$`; never normalized; defaults to `ko` |
| `audience` | no | non-empty after trim when present |
| `layers` | yes | array with at least one entry; `id` values are unique and drawn from the six ids below |
| `mechanism` | no | array of objects with `actor`, `action`, `effect` |
| `analogy` | no | when present, both `text` and `limit` are required |
| `terms` | no | array of objects with `term` and `plain` |
| `cautions` | no | array of non-empty strings |
| `sources` | no | array of non-empty strings |

Every string is non-empty after trim. A field declared as an array must be an array. Violations are collected and reported together.

The six layer ids come from `<explanation_shape>` in [`../SKILL.md`](../SKILL.md): `gist`, `model`, `mechanism`, `why`, `boundary`, `check`. They are never extended. What each layer must *contain* comes from the causal spine in [`../rules/explanation-method.md`](../rules/explanation-method.md).

## 3. Template tokens

The renderer substitutes nine tokens, each exactly once. A token that is missing or repeated stops the run.

| Token | Position | Content |
|---|---|---|
| `<!--{{LANG}}-->` | inside `<html lang="...">` | the `language` value |
| `<!--{{TITLE}}-->` | inside `<title>` | the document title, HTML-escaped |
| `<!--{{SUMMARY}}-->` | top of the body | the one-line gist |
| `<!--{{LAYERS}}-->` | body | layer rail markup |
| `<!--{{MECHANISM}}-->` | body | mechanism step flow markup |
| `<!--{{ANALOGY}}-->` | body | analogy and its limit block |
| `<!--{{TERMS}}-->` | body | term list markup |
| `<!--{{CAUTIONS}}-->` | body | caution list markup |
| `/*{{DATA}}*/` | inside `<script type="application/json" id="eli5-data">` | JSON payload for the interaction layer |

The template holds exactly two `<script>` elements: that data block and one inline script for the interactions. Content is rendered into real markup, so the page is complete without JavaScript and the print stylesheet never depends on script state.

## 4. Escaping and injection safety

- Every inserted string is HTML-escaped for `&`, `<`, `>`, and `"`.
- The JSON payload serializes `<` as `\u003c`, so a `</script>` inside the data cannot close the data block.
- A title containing `<b>`, `&`, `"`, and `</script>` must still produce a page whose data block parses and whose visible text shows those characters literally.

## 5. Error contract

| Condition | Exit | stderr contains |
|---|---|---|
| argument count is not 1 | 1 | `사용법: scripts/render-explanation.mjs <artifact-dir>` |
| template missing | 1 | `뷰 템플릿이 없습니다: <path>` |
| input missing | 1 | `explanation.json이 없습니다: <path>` |
| JSON parse failure | 1 | `explanation.json JSON 파싱에 실패했습니다: <detail>` |
| schema violation | 1 | `explanation.json 스키마 위반: <field>` (multiple fields joined with `,`) |
| template token missing or repeated | 1 | `뷰 템플릿 토큰이 없습니다: <token>` |
| write failure | 1 | `뷰 출력을 쓰지 못했습니다: <path>` |

## 6. Worked example

A cache explanation, complete and valid:

```json
{"title":"캐시","summary":"자주 쓰는 값을 가까이에 두고 다시 계산하지 않는 것","language":"ko","layers":[{"id":"gist","label":"한 줄 정의","body":"캐시는 자주 쓰는 값을 빠르게 꺼낼 수 있는 곳에 잠시 두는 장치다."},{"id":"boundary","label":"한계","body":"원본이 바뀌면 오래된 값을 돌려줄 수 있다."}],"mechanism":[{"actor":"클라이언트","action":"값을 요청한다","effect":"캐시가 먼저 응답한다"}],"analogy":{"text":"책상 위에 두는 메모","limit":"메모는 저절로 갱신되지 않는다"},"terms":[{"term":"캐시","plain":"빠른 임시 저장소"}],"cautions":["캐시된 값이 최신이 아닐 수 있다"],"sources":[]}
```

Run the renderer against it and it exits 0 with the JSON line shown in section 1.

## Sources

> No external sources were used. Content checked 2026-09-22.

The renderer command, the input schema, the template tokens, the escaping rules, and the error contract describe this package's own renderer script and template. No external claim is made, so no external source is cited.
