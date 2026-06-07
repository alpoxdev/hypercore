# 검증과 종료

**목적**: 코드 오토리서치 완료 주장을 희망이 아니라 증거 기반으로 만들고, 코드/점수 이동을 한국어 아티팩트에서 볼 수 있게 한다.

## 1. 트리거 가능성 검증

다음이 명확히 구분되는지 확인한다:

- autoresearch를 트리거해야 하는 요청
- autoresearch를 트리거하면 안 되는 요청
- 직접 수정만으로 충분한 경계 사례

최소 기준:

- 긍정 트리거 예시 3개 이상
- 부정 예시 2개 이상
- 경계 예시 1개 이상
- 한국어 긍정 예시 1개 이상

## 2. 스킬 구조 검증

다음을 확인한다:

- core `SKILL.md`만 읽어도 모든 지원 파일을 열지 않고 작업을 이해할 수 있다
- 실험 정책은 `rules/`에 있고 core 문서에 중복되지 않는다
- 상세 artifact 형식, 보고 템플릿, eval 설계, baseline guide는 `references/`에 있다
- core에서 지원 파일을 찾기 쉽다
- reference chain이 한 단계보다 깊지 않다

## 3. Eval 표면 검증

다음을 확인한다:

- 모든 eval은 이진 평가다
- eval끼리 과도하게 겹치지 않는다
- eval은 사용자가 실제로 신경 쓰는 것을 점검한다
- 최소 한 eval은 표면 formatting이 아니라 사용자의 실제 코드 병목을 점검한다
- 선택한 eval pack은 대상 도메인과 맞거나 generic fallback임을 명시한다
- guard 점검은 scoring eval과 분리되어 있고, 점수가 올랐다는 이유로 무시할 수 없다

## 4. 실행 아티팩트 검증

워크스페이스에 다음이 있는지 확인한다:

- `dashboard.html`
- `results.json`
- `results.js`
- `results.tsv`
- `changelog.md`
- `baseline.md`
- 완료 실행의 `code-explanation.md` 또는 `results.json.code_explanation`
- 완료 실행의 `final-report.md`
- 가정/기본값을 추론했다면 `run-contract.md`
- trace-backed eval 또는 런타임 trace를 사용했다면 `trace-summary.md`
- 외부/최신 claim이 코드 판단에 영향을 줬다면 `source-ledger.md`
- 긴 로그나 proof snippet이 상위 파일을 비대하게 만들면 `details/`

예상 위치:

- `.hypercore/autoresearch-code/[codebase-name]/`

또한 `results.json`과 `results.tsv`가 같은 점수, 통과율, keep/discard/reset 상태를 설명하는지 확인한다.
또한 대시보드가 임의로 손수 편집된 것이 아니라 정식 템플릿에서 렌더됐는지 확인한다.
또한 artifact가 `scope`, `eval_pack`, `proof_commands`, `environment`, 롤백 조건, 수정 파일, proof 결과, guard 결과를 재현 가능하게 기록하는지 확인한다.

워크플로가 `dashboard.html`을 로컬 브라우저에서 직접 여는 경우, `file://` 환경에서 빈 화면이 아니라 실제 데이터와 Markdown 상세 로그가 렌더되는지 확인한다.

## 5. `$autoresearch` 완료 아티팩트 검증

`$autoresearch` 기반 실행을 보고할 때는 다음을 확인한다:

- `.omx/state/.../autoresearch-state.json`에 `validation_mode: "mission-validator-script"`가 있다
- 같은 상태 파일에 `completion_artifact_path`와 `mission_validator_command`가 있다
- `completion_artifact_path`의 JSON이 존재하고 `passed: true` 또는 `status: "passed"`를 기록한다
- `output_artifact_path`가 `.hypercore/autoresearch-code/[codebase-name]/results.json`을 가리킨다

이 artifact가 없으면 점수가 올랐더라도 `$autoresearch` 완료를 주장하지 않는다.

## 6. 코드 개선 주장 검증

다음 중 하나가 참일 때만 성공을 주장한다:

- 최종 점수가 baseline보다 높고 모든 필수 guard가 통과했다
- 코드베이스가 회귀 없이 실질적으로 단순해졌고, 그 단순화가 proof-command 근거와 함께 명시됐다
- 현재 코드베이스가 이미 점수 천장에 가깝고 추가 변이가 정당하지 않음을 증명했다

긍정 주장은 최종 보고에 다음을 보여야 한다:

- 어떤 metric/eval/category에서 점수가 바뀌었는지
- 이전/이후 값 또는 pass count
- 수정 파일
- 각 유지 변경을 왜 남겼는지
- proof command와 guard 결과
- 롤백 또는 promotion 상태
- 남은 실패 또는 명시적 “없음”

## 7. Promotion 안정성 검증

승리 실험을 promotable이라고 부르기 전에 다음을 확인한다:

- 변동성이 큰 지표가 반복 측정에서도 통과한다
- 롤백 조건이 keep 실험 이전 또는 도중에 기록됐다
- 승리 변경 이후 모든 필수 guard가 통과했다
- 실험이 `hold`, `promote`, `rollback` 중 하나로 명시되어 있으며 암묵 상태가 아니다

점수는 올랐지만 guard가 실패한 변경은 promotable이 아니다. `discard`, `rollback`으로 표시하거나 guard 문제를 수정하고 재검증한 뒤에만 `keep-reworked`로 표시한다.

## 8. 최종 보고 체크리스트

최종 보고는 한국어로 다음을 포함해야 한다:

- baseline과 비교한 최종 점수
- 정확한 점수/통과율 변화량
- 전체 실험 수
- keep 비율
- 가장 효과가 컸던 변경
- 점수가 오른 metric/eval/category
- 수정 파일과 각 파일을 유지한 이유
- proof command 결과
- guard 결과
- promotion/rollback 상태
- 남은 실패 패턴
- 실험 artifact 경로
- dashboard 경로
- `$autoresearch`를 사용했다면 `.omx/specs/.../result.json` completion artifact 경로

## 9. 권장 점검 명령

```bash
find skills/autoresearch-code -maxdepth 3 -type f | sort
wc -l skills/autoresearch-code/SKILL.md
rg -n "results.tsv|results.json|results.js|dashboard.html|changelog.md|baseline.md|code-explanation.md|final-report.md|run-contract.md|trace-summary.md|source-ledger.md" skills/autoresearch-code/SKILL.md skills/autoresearch-code/references skills/autoresearch-code/rules
bash -n skills/autoresearch-code/scripts/render-dashboard.sh
find .hypercore -maxdepth 3 -type f | sort | rg "autoresearch-code"
```
