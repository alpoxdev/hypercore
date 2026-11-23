# 약한 모델 워크플로 평가

> 영어판: [`weak-model-eval.md`](weak-model-eval.md)

`hyper` 스킬의 워크플로 장치(라우팅 줄, 단계 선언, 디스크 상태, 마무리 체크리스트)가 성능이 낮은 모델에서도 지켜지는지 반복해서 확인하는 절차입니다. 모델이 얼마나 잘 추론했는지가 아니라 무엇을 빠뜨렸는지를 셉니다. 스크립트는 `scripts/weak-model-eval.sh`, 시나리오는 `scripts/fixtures/weak-model-eval/`에 있습니다.

## What it measures

| 개수 | 검사 | 세는 이유 |
|---|---|---|
| 단계 누락 | `[라우팅: ...]` 줄, 기대 단계마다 `[현재 단계: k/N <stage> ... 진행 중]`과 `... 완료`, 디버그 9단계마다 `[현재 단계: s/9` | 단계 선언이 빠지는 것이 모델이 체인 안의 위치를 놓쳤다는 첫 신호입니다 |
| 상태 누락 | `.hyper/workflows/<slug>/state.json` 존재, 그 파일로 `hyper-workflow-state.sh verify` 통과, `.hyper/debug/<slug>.md` 존재, 그 마지막 줄이 `Result: <terminal>` | 재개되거나 압축된 세션이 이어 가려면 디스크 상태가 있어야 합니다. 선언 줄은 일을 하지 않고도 찍을 수 있습니다 |
| 체크리스트 누락 | 마무리 체크리스트 줄(`[체크리스트: 1=예 ... 6=예]`, 괄호 유무 무관)이 1번부터 6번까지 답함 | 체크리스트는 완료 선언 전 마지막 관문입니다. 답하지 않은 항목은 관문을 건너뛴 것입니다. 괄호는 서식일 뿐이라 괄호가 없다는 이유만으로 누락으로 세지 않습니다 |
| 결과 | 시나리오 자체 테스트 통과, `src/`, `test/`, `.hyper/`, `.gitignore` 밖의 파일 변경 없음 | "워크플로는 지켰지만 작업을 망침"과 "워크플로를 건너뜀"을 구분합니다 |

`answered_no`에는 `아니오`로 답한 항목이 들어갑니다. 정직한 보고이므로 누락으로 세지 않고 따로 둡니다.

## Scenarios

세 시나리오 모두 파일 하나에 있는 런타임 버그이고 `node --test test/`가 실패합니다. 프롬프트에 단계 스킬 이름이 없으므로 모델이 스스로 `hyper`에서 `hyper-debug`로 경로를 정해야 합니다.

| 시나리오 | 버그 | 기대 체인 |
|---|---|---|
| `paginate-off-by-one` | 페이지 자르기가 한 항목 일찍 끝남 | `hyper-debug` |
| `timeout-zero-default` | `timeoutMs: 0`이 `||` 때문에 30000으로 바뀜 | `hyper-debug` |
| `slugify-spaces` | 앞뒤 공백과 연속 공백이 하이픈으로 남음 | `hyper-debug` |

## Run procedure

1. 실행마다 새 작업 폴더를 만듭니다. `bash scripts/weak-model-eval.sh prepare --scenario <id> --out <dir>`는 시나리오 저장소를 복사해 커밋하고, 이 저장소의 `skills/`를 `<dir>/.agents/skills/`로 복사하고, `<dir>/.eval/prompt.txt`를 씁니다. 프롬프트가 먼저 `.agents/skills/hyper/SKILL.md`를 읽으라고 지시하므로 런타임마다 스킬 로더가 달라도 모두 같은 스킬 본문을 봅니다.
2. 평가할 에이전트를 `<dir>` 안에서 그 프롬프트로 실행하고, 출력 전체를 `<dir>/.eval/transcript.*`에 저장합니다. 런타임별 명령은 아래 표를 따릅니다.
3. 채점합니다. `bash scripts/weak-model-eval.sh score --scenario <id> --workdir <dir> --transcript <file>`은 JSON 하나를 출력하고, 대표 수치는 `omissions.total`입니다.
4. 모델마다 시나리오를 세 번씩 돌리고 모든 실행을 기록합니다. 한 번 돌린 결과는 결과로 치지 않습니다([`measurement.ko.md`](measurement.ko.md) 참고).

| 런타임 | 명령 | 상태 |
|---|---|---|
| omp | `omp -p --mode json --no-rules --no-context-files --no-skills --model <model> --cwd <dir> "$(cat <dir>/.eval/prompt.txt)" > <dir>/.eval/transcript.jsonl` | `omp --help`(v19.1.1)로 플래그를 확인했습니다. `--no-rules`와 `--no-context-files`는 운영자 개인 규칙이 측정에 섞이지 않게 하고, `--no-skills`는 설치된 스킬 사본이 평가 대상 사본을 가리지 않게 합니다 |
| Codex | `codex exec --json -C <dir> -m <model> "$(cat <dir>/.eval/prompt.txt)" > <dir>/.eval/transcript.jsonl` | `codex exec --help`로 `--json`, `-C`, `-m`을 확인했습니다. 샌드박스·승인 플래그는 확인하지 않았습니다 |
| Claude Code | `<dir>`에서 `claude -p --output-format stream-json --verbose --model <model> "$(cat <dir>/.eval/prompt.txt)" > <dir>/.eval/transcript.jsonl` | CLI 문서를 보고 추정한 명령입니다. 이 기기에서는 확인하지 않았습니다 |
| Antigravity | 소유자가 `<dir>`에서 새 대화형 세션을 열고 `prompt.txt`를 붙여 넣은 뒤 세션 화면을 transcript로 저장합니다 | 계정 보호 규칙이 헤드리스 출력 모드를 금지하므로 이 행은 사람이 직접 돌립니다 |

오래 걸리는 에이전트 명령은 운영자 셸이 아니라 백그라운드 작업으로 돌리고, 실행마다 작업 폴더를 따로 씁니다.

## Recording results

실행마다 한 행을 기록합니다. 날짜, 런타임, 모델, 시나리오, 회차, `omissions.steps`, `omissions.state`, `omissions.checklist`, `outcome.tests_pass`, `outcome.out_of_scope`를 적습니다. 세 번 모두 `omissions.total == 0`, `tests_pass == true`, 빈 `out_of_scope`이면 그 모델은 그 시나리오를 통과합니다. 합계만 적지 말고 실패한 검사 id를 적습니다. id마다 지켜지지 않은 스킬 문장을 가리키기 때문입니다.

## Limits

- 선언 줄 검사는 transcript 글자를 맞춰 봅니다. 모델은 단계를 하지 않고 선언만 찍을 수 있습니다. 상태 검사가 이를 견제하지만 일을 했다는 증명은 아닙니다.
- 한 언어의 버그 세 개는 체인 하나(`hyper` -> `hyper-debug`)만 시험합니다. 체인 간 라우팅 정확도는 측정하지 않으며, 그것은 각 스킬의 `assets/evals/` 트리거 평가가 맡습니다.
- 칸마다 세 번 실행하면 큰 실패는 잡지만 작은 비율 차이는 잡지 못합니다.

## Sources

> Checked 2026-11-23.

| Claim | Source | Grade |
|---|---|---|
| 채점기가 확인하는 선언 줄, 상태 파일, 마무리 체크리스트 계약 | 이 저장소의 `skills/hyper/SKILL.md`, `skills/hyper-debug/SKILL.md`, `skills/hyper-debug/rules/working-loop.md` | `REPO` |
| 사례마다 반복 실행하고 행동 검사와 종단 결과를 분리함 | [`measurement.ko.md`](measurement.ko.md), [`../HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md) | `REPO` |
| omp와 Codex 플래그 | 2026-11-23에 실행한 `omp --help`(omp v19.1.1)와 `codex exec --help` | `REPO` |
