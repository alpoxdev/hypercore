# Artifact Spec

오토리서치 실행의 실험 워크스페이스를 만들거나 검토할 때 이 레퍼런스를 사용한다.

## 워크스페이스 형태

```text
.hypercore/autoresearch-code/[codebase-name]/
|-- dashboard.html
|-- results.json
|-- results.js        # file:// 브라우저 폴백용, 선택이지만 권장
|-- results.tsv
|-- changelog.md
`-- baseline.md
```

이 디렉터리는 스킬 폴더 안이 아니라 저장소 루트에 만든다.

정식 생성 자산:

- template: `skills/autoresearch-code/assets/dashboard-template.html`
- renderer: `skills/autoresearch-code/scripts/render-dashboard.sh`

## `baseline.md`

실험 `0` 전에 수정되지 않은 상태를 기록한다.

권장 섹션:

- 범위와 소유 패키지 또는 모듈
- 선택한 팩 이름, 팩 유형, 팩 버전
- 대상 범위
- 최적화 목표
- baseline 측정에 사용한 명령
- proof command hash 또는 정확한 명령 목록
- 측정 수치 또는 정성 관찰
- 환경 또는 runner 정보
- 회귀하면 안 되는 제약
- 롤백 조건
- 선택한 프롬프트 팩과 eval 세트

## `results.tsv`

다음 헤더를 가진 탭 구분 파일:

```text
experiment	score	max_score	pass_rate	status	description
```

예시:

```text
experiment	score	max_score	pass_rate	status	description
0	12	20	60.0%	baseline	원본 코드베이스 - 수정 없음
1	15	20	75.0%	keep	빌드 단계의 반복 파일 읽기를 배치 처리
2	15	20	75.0%	discard	측정 가능한 이득 없는 메모이제이션 추가
```

## `results.json`

권장 형태:

```json
{
  "codebase_name": "my-repo",
  "status": "running",
  "current_experiment": 3,
  "baseline_score": 60.0,
  "best_score": 85.0,
  "scope": {
    "kind": "package",
    "label": "apps/web"
  },
  "eval_pack": {
    "name": "web",
    "type": "trace-backed",
    "version": "2026-03-24"
  },
  "proof_commands": {
    "hash": "sha256:...",
    "commands": ["pnpm --filter web build", "pnpm --filter web test"]
  },
  "environment": {
    "os": "macos",
    "runtime": "node 22"
  },
  "experiments": [
    {
      "id": 0,
      "score": 12,
      "max_score": 20,
      "pass_rate": 60.0,
      "status": "baseline",
      "promotion_state": "hold",
      "description": "원본 코드베이스 - 수정 없음",
      "dimensions": {
        "quality": 3,
        "regression": 4,
        "resource": 2,
        "safety": 3
      }
    }
  ],
  "eval_breakdown": [
    {
      "name": "임계값 이하 빌드",
      "pass_count": 3,
      "total": 5
    }
  ]
}
```

상태 값:

- `running`
- `idle`
- `complete`

승격 상태 값:

- `hold`
- `promote`
- `rollback`

## `dashboard.html`

인라인 CSS와 JavaScript를 포함한 self-contained HTML 파일 하나를 생성한다.

매 실행마다 임의의 다른 대시보드를 손으로 만들지 않는다. 정식 템플릿에서 `dashboard.html`을 물질화하고, 레이아웃과 로딩 동작을 안정적으로 유지한다.

필수 동작:

- 10초마다 자동 새로고침
- `results.json` 읽기
- 점수 추이를 선형 차트로 렌더
- 실험별 컬러 바 렌더
- 범위, eval pack, 환경, 현재 promotion 상태 표시
- 실험 테이블 표시
- 있으면 실험별 dimension 점수 표시
- eval별 통과 수 표시
- 현재 실행 상태 표시
- `results.json`의 `running`, `idle`, `complete` 상태를 반영
- Chrome 등 브라우저에서 `file://`로 직접 열어도 정상 렌더

생명주기 규칙:

- `skills/autoresearch-code/assets/dashboard-template.html`에서 `dashboard.html`을 렌더한다
- 기본 렌더러는 `skills/autoresearch-code/scripts/render-dashboard.sh <artifact-dir>`를 사용한다
- `dashboard.html`을 만든 뒤, 런타임이 안전하면 즉시 연다
- 매 실험 뒤 `results.tsv`와 `results.json`을 업데이트한다
- `scope`, `eval_pack`, `proof_commands`, `environment`, 실험 `dimensions`를 현재 실행과 동기화한다
- 실험이 실행 중일 때는 `results.json.status`를 `running`으로 둔다
- 루프가 끝나면 `results.json.status`를 `complete`로 둔다
- 대시보드를 `file://`로 여는 경우 `fetch("./results.json")`만 믿지 않는다
- 같은 데이터를 브라우저 글로벌에 할당하는 `results.js` 같은 파일 기반 폴백을 제공한다
- 폴백 파일이 있으면 `results.js`는 항상 `results.json`과 동기화한다

## `changelog.md`

실험마다 항목 하나를 추가한다:

```markdown
## Experiment [N] - [keep/discard]

**Score:** [X]/[max] ([percent]%)
**Change:** [변이 한 줄 요약]
**Reasoning:** [왜 이 변경이 도움 될 것이라 봤는지]
**Result:** [어떤 eval이 개선, 유지, 악화되었는지]
**Failing outputs:** [남은 실패가 있으면 기록]
```

## Worked Example

빌드 속도 최적화 예시 요약:

- Baseline: `10/20 (50%)`
- Experiment 1 keep: 반복 파일 시스템 작업을 배치 처리해 빌드 임계값 통과율 개선
- Experiment 2 discard: 추가 캐시가 복잡성만 늘리고 측정 가능한 이득은 없음
- Experiment 3 keep: 죽은 플러그인 제거로 번들 크기 감소
- Experiment 4 keep: flaky test helper 단순화로 신뢰성 개선

후속 에이전트가 같은 막다른 길을 반복하지 않도록 reasoning은 changelog에 남긴다.
