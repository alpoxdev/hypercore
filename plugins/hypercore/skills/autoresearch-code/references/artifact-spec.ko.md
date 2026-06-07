# Artifact Spec

`autoresearch-code` 실행의 실험 워크스페이스를 만들거나 검토할 때 이 레퍼런스를 사용한다.

## 워크스페이스 형태

```text
.hypercore/autoresearch-code/[codebase-name]/
|-- dashboard.html
|-- results.json
|-- results.js        # 렌더 후 file:// 브라우저 폴백으로 필수
|-- results.tsv
|-- changelog.md
|-- baseline.md
|-- code-explanation.md   # 완료 실행에서 results.json.code_explanation이 없으면 필수
|-- final-report.md       # 완료 실행에서 필수
|-- run-contract.md       # 가정/기본값을 추론했으면 필수
|-- trace-summary.md      # trace-backed eval 또는 런타임 trace를 썼으면 필수
|-- source-ledger.md      # 외부/최신 claim이 코드 판단에 영향을 줬으면 필수
`-- details/             # 긴 로그, proof snippet, JSON/TSV/log diagnostics
```

이 디렉터리는 스킬 폴더 안이 아니라 저장소 루트에 만든다.

`$autoresearch` 실행에서는 이 `.hypercore` 디렉터리가 도메인별 결과 로그이고, 최종 완료 gate는 별도 `.omx/specs/autoresearch-[codebase-name]/result.json` completion artifact가 담당한다. `completion_artifact_path`에는 이 `.omx/specs/.../result.json` 경로를 기록하고, `output_artifact_path`에는 이 파일의 `results.json`을 기록한다.

정식 생성 자산:

- template: `skills/autoresearch-code/assets/dashboard-template.html`
- renderer: `skills/autoresearch-code/scripts/render-dashboard.sh`
- renderer runtime: `python3` 표준 JSON 라이브러리

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
experiment\tscore\tmax_score\tpass_rate\tstatus\tdescription
```

예시:

```text
experiment\tscore\tmax_score\tpass_rate\tstatus\tdescription
0\t12\t20\t60.0%\tbaseline\t원본 코드베이스 - 수정 없음
1\t15\t20\t75.0%\tkeep\t빌드 단계의 반복 파일 읽기를 배치 처리
2\t15\t20\t75.0%\tdiscard\t측정 가능한 이득 없는 메모이제이션 추가
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
      "delta": 0,
      "guard": "not-run",
      "guard_metric": "baseline",
      "changed_files": [],
      "proof_command": "pnpm --filter web build",
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
  ],
  "code_explanation": {
    "summary_ko": "기준 60.0%에서 최고 85.0%로 +25.0%p 상승했습니다.",
    "baseline_score": 60.0,
    "final_score": 85.0,
    "delta": 25.0,
    "best_experiment": 3,
    "most_effective_change_ko": "반복 파일 읽기를 배치 처리했습니다.",
    "changed_files": ["src/build/collect-files.ts"],
    "metric_movements": [
      {
        "metric_ko": "빌드 시간",
        "direction": "lower_is_better",
        "before": "42.0s",
        "after": "31.5s",
        "delta_ko": "-10.5s",
        "evidence_ko": "`pnpm build` 5회 평균"
      }
    ],
    "code_changes": [
      {
        "file": "src/build/collect-files.ts",
        "change_ko": "동기 파일 읽기를 배치 처리로 바꿨습니다.",
        "why_kept_ko": "빌드 임계값 eval과 guard가 모두 통과했습니다.",
        "guard_ko": "`pnpm test` 통과"
      }
    ],
    "proof_commands_ko": ["`pnpm build` 통과"],
    "guard_results_ko": ["`pnpm test` 통과"],
    "remaining_failures_ko": ["없음"]
  }
}
```

상위 상태 값:

- `running`
- `idle`
- `complete`

실험 상태 값:

- `baseline`
- `keep`
- `keep-reworked`
- `discard`
- `crash`
- `no-op`
- `hook-blocked`
- `metric-error`
- `reset`

승격 상태 값:

- `hold`
- `promote`
- `rollback`

완료된 실행에는 대시보드가 점수 이동을 설명할 수 있도록 `results.json.code_explanation` 또는 `code-explanation.md`가 필요하다.

## 상세 파일과 `results.js`

렌더러는 `results.js`에 두 브라우저 글로벌을 쓴다:

- `window.__AUTORESEARCH_CODE_RESULTS__`: 직렬화된 `results.json`
- `window.__AUTORESEARCH_CODE_DETAILS__`: 직렬화된 상세 파일

렌더러는 있으면 다음 알려진 상세 파일을 포함해야 한다:

- `changelog.md`
- `code-explanation.md`
- `final-report.md`
- `baseline.md`
- `run-contract.md`
- `source-ledger.md`
- `trace-summary.md`

또한 `details/` 아래 `.md`, `.txt`, `.json`, `.tsv`, `.log` 파일도 포함한다.

## `dashboard.html`

외부 CDN 없이 인라인 CSS와 JavaScript를 포함한 self-contained HTML 파일 하나를 생성한다.

매 실행마다 임의의 다른 대시보드를 손으로 만들지 않는다. 정식 템플릿에서 `dashboard.html`을 물질화하고, 레이아웃과 로딩 동작을 안정적으로 유지한다.

필수 동작:

- 10초마다 자동 새로고침
- HTTP로 서빙될 때는 `results.json`을 읽고, `file://`에서는 `results.js`를 사용
- 내장 Canvas API로 점수 추이를 선형 차트로 렌더
- 기준 점수, 최신 통과율, 최고 점수, 현재 실험 표시
- 점수 변화량, 최고 실험, 지표 이동, 수정 파일, proof command, guard 결과, 남은 실패, promotion 상태 표시
- 범위, eval pack, 환경, 현재 promotion 상태 표시
- 동적 값을 escape한 실험 테이블 표시
- 있으면 실험별 dimension 점수 표시
- eval별 통과 수 표시
- 현재 실행 상태 표시
- `results.json`의 `running`, `idle`, `complete` 상태 반영
- 원시 HTML을 먼저 escape한 뒤 안전한 Markdown 부분집합으로 상세 로그 렌더
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
- `results.js`는 `results.json`과 상세 파일에 동기화한다

## `changelog.md`

실험마다 한국어 항목 하나를 추가한다:

```markdown
## Experiment [N] - [keep/discard/reset]

**점수:** [X]/[max] ([percent]%)  
**변화량:** [+/-delta]  
**수정:** [변이 한 줄 요약]  
**어디서 올랐나:** [metric/eval before -> after]  
**왜 유지/폐기했나:** [score, complexity, guard evidence]  
**수정 파일:** `[path]`, `[path]`  
**Proof command:** `[command]` -> [result]  
**Guard:** [result]  
**롤백 조건:** [condition]  
**남은 실패:** [record remaining failures if any]
```

## `code-explanation.md`와 `final-report.md`

템플릿은 [reporting-and-code-improvement.ko.md](reporting-and-code-improvement.ko.md)를 사용한다. 사용자가 명시적으로 다른 언어를 요청하지 않았다면 두 파일은 한국어로 작성한다.

## Worked Example

빌드 속도 최적화 예시 요약:

- Baseline: `10/20 (50%)`
- Experiment 1 keep: 반복 파일 시스템 작업을 배치 처리해 빌드 임계값 통과율 개선
- Experiment 2 discard: 추가 캐시가 복잡성만 늘리고 측정 가능한 이득은 없음
- Experiment 3 keep: 죽은 플러그인 제거로 번들 크기 감소
- Experiment 4 keep: flaky test helper 단순화로 신뢰성 개선

후속 에이전트가 같은 막다른 길을 반복하지 않도록 reasoning은 changelog에 남긴다.
