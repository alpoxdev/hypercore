# Artifact Spec

오토리서치 실행의 실험 워크스페이스를 만들거나 검토할 때 이 레퍼런스를 사용한다.

## 워크스페이스 형태

```text
.hypercore/autoresearch-skill/[skill-name]/
|-- dashboard.html
|-- results.json
|-- results.js        # file:// 브라우저 폴백용, 선택이지만 권장
|-- results.tsv
|-- changelog.md
|-- run-contract.md      # 권장; source/tool/delegation이 있으면 필수
|-- source-ledger.md     # 외부/current claim을 썼으면 필수
|-- trace-summary.md     # 도구/delegation/병렬 평가가 있으면 필수
|-- details/             # 선택; 긴 분석, 프롬프트 팩, eval 결과 원문
`-- SKILL.md.baseline
```

이 디렉터리는 스킬 폴더 안이 아니라 저장소 루트에 만든다.

`$autoresearch` 실행에서는 이 `.hypercore` 디렉터리가 도메인별 결과 로그이고, 최종 완료 gate는 별도 `.omx/specs/autoresearch-[skill-name]/result.json` completion artifact가 담당한다. `completion_artifact_path`에는 이 `.omx/specs/.../result.json` 경로를 기록하고, `output_artifact_path`에는 이 파일의 `results.json`을 기록한다.

항상 필요한 기본 아티팩트는 `dashboard.html`, `results.json`, `results.tsv`, `changelog.md`, `SKILL.md.baseline`이다. `run-contract.md`, `source-ledger.md`, `trace-summary.md`는 실행 조건에 따라 필수화된다.

긴 내용은 `results.json`에 억지로 밀어 넣지 말고 `details/` 아래 Markdown/Text/JSON/TSV/Log 파일로 둔다. 렌더러는 `changelog.md`, `run-contract.md`, `source-ledger.md`, `trace-summary.md`, 그리고 `details/` 아래 지원 확장자 파일을 `results.js`에 안전하게 직렬화해 대시보드의 상세 로그 섹션에 표시한다.

정식 생성 자산:

- template: `skills/autoresearch-skill/assets/dashboard-template.html`
- renderer: `skills/autoresearch-skill/scripts/render-dashboard.sh`
- renderer runtime: `python3` 표준 JSON 라이브러리

## Baseline snapshot

대상 스킬의 `SKILL.md`만 수정할 때는 `SKILL.md.baseline`으로 충분하다. `rules/`, `references/`, `scripts/`, `assets/`까지 바꿀 수 있는 실행에서는 다음 중 하나를 추가한다:

- `baseline/` 디렉터리에 수정 대상 원본 파일 복사
- `baseline-files.json`에 파일별 path, sha256, size 기록

지원 파일을 바꾸면서 `SKILL.md.baseline`만 남기는 것은 불완전한 baseline으로 취급한다.

## `run-contract.md`

baseline 전 계약을 짧게 기록한다. 외부/current source, 도구, delegation을 쓰지 않는 단순 실행에서도 있으면 좋고, 해당 요소가 있으면 필수다.

```markdown
# Run Contract

- Intent: [이번 실행의 성공 결과]
- Scope: [수정 가능 파일 / 제외 파일]
- Authority: [사용자, 프로젝트, target skill, retrieved content 우선순위]
- Evidence: [로컬 파일, 공식 문서, source ledger]
- Tools: [사용 capability와 side-effect 제한]
- Output: [남길 아티팩트]
- Verification: [binary eval, trace assertion, artifact check]
- Stop condition: [예산, 안정 고득점, blocker, reset 조건]
```

## `source-ledger.md`

provider/runtime/current claim, 외부 문서, 보안/컴플라이언스 주장이 변이나 KEEP 결정에 영향을 주면 만든다.

```markdown
| # | Source | URL/path | Date/freshness | Grade | Claim supported | Used in experiment |
|---:|---|---|---|---|---|---|
```

## `trace-summary.md`

도구 사용, delegation, 병렬 평가가 correctness에 영향을 주면 만든다.

```markdown
| Assertion | Evidence | Pass? |
|---|---|---|
| read_before_mutation | [files read before edit] | yes/no |
| baseline_before_edit | [experiment 0 artifact] | yes/no |
| stable_eval_set | [prompt/eval hash or reset event] | yes/no |
| one_mutation | [changelog experiment entry] | yes/no |
| source_guard | [ledger / no external claims] | yes/no |
| parent_verifies | [final verification command/output] | yes/no |
```

## `results.tsv`

다음 헤더를 가진 탭 구분 파일:

```text
experiment	score	max_score	pass_rate	status	description
```

예시:

```text
experiment	score	max_score	pass_rate	status	description
0	14	20	70.0%	baseline	원본 스킬 - 수정 없음
1	16	20	80.0%	keep	번호 매기기 관련 anti-pattern 추가
2	16	20	80.0%	discard	레이아웃 지침을 앞으로 옮겼지만 측정 가능한 이득 없음
```

## `results.json`

권장 형태:

```json
{
  "skill_name": "diagram-generator",
  "status": "running",
  "current_experiment": 3,
  "baseline_score": 70.0,
  "best_score": 90.0,
  "experiments": [
    {
      "id": 0,
      "score": 14,
      "max_score": 20,
      "pass_rate": 70.0,
      "status": "baseline",
      "description": "원본 스킬 - 수정 없음"
    }
  ],
  "run_contract_path": "run-contract.md",
  "source_ledger_path": "source-ledger.md",
  "trace_summary_path": "trace-summary.md",
  "eval_breakdown": [
    {
      "name": "텍스트 가독성",
      "pass_count": 8,
      "total": 10
    }
  ]
}
```

상태 값:

- `running`
- `idle`
- `complete`

## `dashboard.html`

외부 CDN 없이 인라인 CSS와 JavaScript를 포함한 self-contained HTML 파일 하나를 생성한다.

매 실행마다 임의의 다른 대시보드를 손으로 만들지 않는다. 정식 템플릿에서 `dashboard.html`을 물질화하고, 레이아웃과 로딩 동작을 안정적으로 유지한다.

필수 동작:

- 10초마다 자동 새로고침
- `results.json` 읽기
- 내장 Canvas API로 점수 추이를 선형 차트로 렌더
- 실험별 컬러 바 렌더
- 실험 테이블 표시
- eval별 통과 수 표시
- 현재 실행 상태 표시
- `results.json`의 `running`, `idle`, `complete` 상태를 반영
- Chrome 등 브라우저에서 `file://`로 직접 열어도 정상 렌더

생명주기 규칙:

- `skills/autoresearch-skill/assets/dashboard-template.html`에서 `dashboard.html`을 렌더한다
- 기본 렌더러는 `skills/autoresearch-skill/scripts/render-dashboard.sh <artifact-dir>`를 사용한다
- `dashboard.html`을 만든 뒤, 런타임이 안전하면 즉시 연다
- 매 실험 뒤 `results.tsv`와 `results.json`을 업데이트한다
- source/tool/delegation이 실행에 영향을 주면 `run-contract.md`, `source-ledger.md`, `trace-summary.md`도 최신 상태로 둔다
- 실험이 실행 중일 때는 `results.json.status`를 `running`으로 둔다
- 루프가 끝나면 `results.json.status`를 `complete`로 둔다
- 대시보드를 `file://`로 여는 경우 `fetch("./results.json")`만 믿지 않는다
- 같은 데이터를 브라우저 글로벌에 할당하는 `results.js` 같은 파일 기반 폴백을 제공한다
- 폴백 파일이 있으면 `results.js`는 항상 `results.json`과 동기화한다
- 긴 상세 내용은 HTML 템플릿을 직접 수정하지 말고 `details/*.md`, `details/*.txt`, `details/*.json`, `details/*.tsv`, `details/*.log` 또는 표준 로그 파일에 작성한 뒤 렌더러가 `results.js`로 싣게 한다
- 상세 로그는 HTML로 변환하지 않고 escaped preformatted text로 보여 주어, 실험 출력에 포함된 태그나 프롬프트가 대시보드 스크립트 권한을 얻지 못하게 한다

## Detailed content files

상세한 판단 근거, 프롬프트 팩, 원문 eval 결과, 실패 출력, 수동 리뷰는 아래처럼 분리한다.

```text
details/
|-- prompt-pack.md
|-- eval-results.tsv
|-- failure-excerpts.md
`-- architect-review.json
```

권장 원칙:

- 핵심 지표와 상태는 `results.json`에 둔다.
- 사람이 읽을 긴 설명은 `details/` 또는 표준 로그 파일에 둔다.
- `dashboard-template.html`은 presentation template으로만 유지하고 실행별 내용을 직접 하드코딩하지 않는다.
- `scripts/render-dashboard.sh <artifact-dir>`를 다시 실행해 `dashboard.html`과 `results.js`를 동기화한다.

권장 브라우저 안전 패턴:

- HTTP로 제공될 때는 `fetch("./results.json")`을 우선 사용
- 디스크에서 직접 열리면 `results.js`를 로드
- 두 경로는 별도 상태가 아니라 같은 결과 데이터를 보여 주는 뷰여야 한다

권장 렌더 순서:

```bash
skills/autoresearch-skill/scripts/render-dashboard.sh .hypercore/autoresearch-skill/my-skill
open .hypercore/autoresearch-skill/my-skill/dashboard.html
```

권장 스타일:

- 흰색 또는 거의 흰색 배경
- 부드러운 포인트 색
- 깔끔한 산세리프 타이포그래피
- baseline, keep, discard를 쉽게 구분하는 상태 색상

차트 가이드:

- 내장 Canvas API 사용
- X축: 실험 번호
- Y축: 통과율 %

## `changelog.md`

실험마다 항목 하나를 추가한다:

```markdown
## Experiment [N] - [keep/discard]

**Score:** [X]/[max] ([percent]%)
**Change:** [변이 한 줄 요약]
**Reasoning:** [왜 이 변경이 도움 될 것이라 봤는지]
**Result:** [어떤 eval이 개선, 유지, 악화되었는지]
**Failing outputs:** [남은 실패가 있으면 기록]
**Evidence/Trace:** [source ledger 또는 trace assertion 변화가 있으면 기록]
```

## Worked Example

다이어그램 스킬 예시 요약:

- Baseline: `32/40 (80%)`
- Experiment 1 keep: 번호 매기기 방지 규칙이 번호 실패를 개선
- Experiment 2 discard: 글자 크기 요구가 복잡성만 늘리고 이득은 약함
- Experiment 3 keep: 구체적 파스텔 팔레트 예시가 색상 준수를 개선
- Experiment 4 discard: 중복 anti-color 규칙은 효과 없음
- Experiment 5 keep: worked example이 일관성을 높여 `97.5%` 도달

후속 에이전트가 같은 막다른 길을 반복하지 않도록 reasoning은 changelog에 남긴다.
