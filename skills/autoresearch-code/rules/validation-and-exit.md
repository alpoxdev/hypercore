# Validation and Exit

**목적**: 코드 오토리서치 완료 판단을 희망사항이 아니라 증거 기반으로 만든다.

## 1. 트리거 가능성 검증

다음이 명확히 구분되는지 확인한다:

- 오토리서치를 트리거해야 하는 요청
- 트리거하면 안 되는 요청
- 직접 수정이면 충분한 경계 사례

최소 기준:

- 긍정 트리거 예시 최소 3개
- 부정 예시 최소 2개
- 경계 예시 최소 1개
- 한국어 긍정 예시 최소 1개

## 2. 스킬 구조 검증

다음을 확인한다:

- 핵심 `SKILL.md`만 읽어도 모든 지원 파일을 열지 않고 맡은 일이 이해된다
- 실험 정책은 `rules/`에 있고 핵심 문서에 중복되지 않는다
- 상세 아티팩트 형식과 baseline 가이드는 `references/`에 있다
- core에서 support file을 쉽게 찾을 수 있다
- reference 체인은 한 단계 깊이를 넘지 않는다

## 3. Eval 표면 검증

다음을 확인한다:

- eval이 모두 이진이다
- eval끼리 과하게 겹치지 않는다
- eval이 사용자가 실제로 신경 쓰는 것을 검사한다
- 최소 하나는 피상적 포맷이 아니라 사용자의 실제 코드 병목을 검사한다
- 선택한 eval pack이 대상 도메인에 맞거나 generic fallback임이 명시되어 있다

## 4. 실행 아티팩트 검증

워크스페이스에 다음이 있는지 확인한다:

- `dashboard.html`
- `results.json`
- `results.tsv`
- `changelog.md`
- `baseline.md`

예상 위치:

- `.hypercore/autoresearch-code/[codebase-name]/`

또한 `results.json`과 `results.tsv`가 점수, 통과율, keep/discard 상태를 동일하게 설명하는지 확인한다.
또한 대시보드가 임의 편집본이 아니라 정식 템플릿에서 렌더되었는지 확인한다.
또한 아티팩트가 `scope`, `eval_pack`, `proof_commands`, `environment`, 롤백 조건을 재현 가능하게 기록하는지 확인한다.

워크플로가 `dashboard.html`을 로컬 브라우저에서 직접 연다면, `file://` 환경에서도 빈 화면이 아니라 실제 데이터를 렌더하는지 확인한다.

## 5. 최종 주장 검증

다음 중 하나가 참이 아니면 성공을 주장하지 않는다:

- 최종 점수가 baseline보다 높다
- 무회귀 상태에서 코드베이스가 실질적으로 단순해졌고 그 단순화가 명시되어 있다
- 현재 코드베이스가 이미 점수 상한에 가깝고 추가 변이가 정당하지 않다는 점을 이번 실행으로 입증했다

## 6. 승격 안정성 검증

우승 실험을 promote 가능하다고 부르기 전에 다음을 확인한다:

- 변동성이 있는 지표도 반복 측정에서 여전히 통과한다
- 롤백 조건이 keep 실험 전이나 중에 기록되었다
- 실험이 암묵적으로가 아니라 `hold`, `promote`, `rollback` 중 하나로 명시되어 있다

## 7. 최종 보고 체크리스트

최종 보고에는 반드시 다음이 포함되어야 한다:

- baseline 대비 최종 점수
- 총 실험 수
- keep 비율
- 가장 효과가 컸던 변경
- 남은 실패 패턴
- 실험 아티팩트 경로

## 8. 권장 점검 명령

```bash
find skills/autoresearch-code -maxdepth 3 -type f | sort
wc -l skills/autoresearch-code/SKILL.md
rg -n "results.tsv|results.json|dashboard.html|changelog.md|baseline.md" skills/autoresearch-code/SKILL.md skills/autoresearch-code/references skills/autoresearch-code/rules
find .hypercore -maxdepth 2 -type f | sort | rg "autoresearch-code"
```
