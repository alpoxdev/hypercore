# Resource Placement

> 영어판: [`resource-placement.md`](resource-placement.md)

Resource placement는 skill 폴더의 각 파일에 정확한 책임을 부여하는 규칙 집합입니다.

## 1. 배치 표

| 리소스 | 두는 곳 | 이유 |
|---|---|---|
| Skill을 언제 쓰는지 | `description`, `routing_rule` | Discovery와 트리거 신호 |
| 상위 수준 실행 순서 | `SKILL.md` | 활성화 시 항상 필요 |
| 반복되는 검증 checklist | `rules/` 또는 `SKILL.md` validation | 실행마다 재사용 |
| 공식 문서 요약 | `references/official/` | provider 변동과 상세를 분리 |
| 긴 예시 | `references/examples.md` 또는 `assets/` | 필요할 때만 로드 |
| 반복 loop 정책 | `rules/loop.md` | feedback, guard, stop condition을 재사용 |
| Prompt 템플릿 | `assets/prompts/` 또는 `references/examples.md` | 복사·채우면 asset, 설명이면 reference |
| Eval fixture | `assets/evals/` | 입력과 기대 출력을 실행 가능한 형태로 유지 |
| Source ledger | `references/sources.md` 또는 `references/official/` | 외부 주장을 추적 |
| 안전 경계 | `rules/safety.md` 또는 `references/safety.md` | 도구, network, credential, 파괴적 행동 gate |
| 출력 템플릿 | `assets/` | 복사하거나 채우는 대상 |
| 자동 검증 | `scripts/` | 결정성과 반복 가능성을 보장 |
| 런타임 metadata | `agents/` | 플랫폼별 표시, 호출 정책, 의존성 |

## 2. Rules와 references

`rules/`는 판단 기준과 절차를 담습니다.

예:

- "언제 스크립트를 추가하는가"
- "검증이 실패할 때 어떤 순서로 고치는가"
- "조사 출처를 어떻게 등급 매기는가"
- "Loop가 언제 계속되고 언제 멈추는가"
- "Network, credential, 파괴적 행동을 언제 gate하는가"

`references/`는 지식과 상세를 담습니다.

예:

- OpenAI Codex skill 문서 요약
- Anthropic Claude Code skill lifecycle
- API schema
- 도메인별 edge case
- Source ledger와 벤더 변동 기록
- 논문·벤치마크 근거 요약

## 3. Script 추가 기준

다음 중 하나 이상을 만족할 때만 스크립트를 추가합니다.

- 같은 로직을 여러 번 반복해야 합니다.
- Agent가 매번 명령을 틀릴 가능성이 큽니다.
- 출력을 기계가 읽을 수 있는 형태로 검증해야 합니다.
- 실패 메시지가 자기 수정에 중요합니다.
- 기존 도구를 호출하더라도 버전 고정과 인자 정규화가 필요합니다.

필수 스크립트 문서:

```markdown
## Available scripts

- `scripts/validate-skill.sh`
  - Purpose: validate frontmatter, local links, code fences, and support file references.
  - Usage: `bash scripts/validate-skill.sh skills/my-skill`
  - Requires: bash 3.2+ and jq
  - Output: JSON summary plus non-zero exit on failure.
```

## 4. Asset 추가 기준

산출물에 실제로 쓰이는 파일만 남깁니다.

좋은 asset:

- 보고서 템플릿
- CSV fixture
- JSON schema
- 스타일 샘플
- 이미지와 참조 mock
- 빈칸이 있는 prompt 템플릿
- Eval 입력과 기대 출력 쌍
- Golden output 스냅샷

나쁜 asset:

- 읽기만 하는 설명 문서
- 중복된 reference
- 쓰임이 확인되지 않는 예시 파일

## 5. 공식 참조 배치

긴 공식 문서 근거를 core에 넣지 않습니다. 다음처럼 분리합니다.

```text
references/
└── official/
    ├── openai.md
    ├── anthropic.md
    └── agent-skills-standard.md
```

각 파일에 담을 것:

- 확인 날짜
- 출처 URL
- 이 skill에 영향을 주는 주장
- 변동(Drift) caveat
- Core 규칙으로 승격된 요약

`references/official/`는 **권장** 배치이지 필수 경로가 아니며, 이 저장소에는 아직 이 폴더를 쓰는 skill이 없습니다. 규칙이 요구하는 것은 provider 상세를 core 밖으로 두는 일입니다. 이 저장소 안 문서의 고정 스냅샷이면 폴더 이름을 `references/local/`로 씁니다. `skills/skill-maker/references/local/`이 이미 그 예입니다.

## 6. Eval 리소스 배치

Eval 자료를 "읽는 설명"과 "실행하거나 비교하는 fixture"로 나눕니다.

```text
assets/
└── evals/
    ├── trigger-cases.jsonl
    ├── workflow-cases.jsonl
    └── safety-cases.jsonl

references/
└── eval-rubric.md
```

- `assets/evals/*.jsonl`은 parser나 runner가 읽는 machine-readable case입니다.
- `references/eval-rubric.md`는 사람이 읽는 채점 기준과 caveat입니다.
- Deterministic runner가 있으면 `scripts/run-evals.*`에 두고 의존성과 기대 출력을 문서화합니다.
- Eval case에 외부 출처가 필요하면 그 case 안이나 source ledger에 출처 URL, 확인일, 최신성 caveat을 적습니다.

### 패키지 도구와의 호환

`assets/evals/`는 **이 저장소의** 관례이고, 기존 skill이 이미 그렇게 쓰고 있어서 골랐습니다. 이 경로를 읽는 패키지 도구는 없습니다. Anthropic `skill-creator`는 skill root의 `evals/evals.json`을 읽으며, 그 항목에는 프롬프트, 입력 파일, 기대 행동, assertion이 들어갑니다. Claude Code `claude plugin eval`은 자체 case 형식을 쓰고, 벤더 문서는 두 형식을 "서로 바꿔 쓸 수 없다"고 밝힙니다.

그래서 규칙은 이렇습니다. 사람이나 이 저장소의 runner가 읽는 자리는 `assets/evals/`로 두고, 같은 skill을 그 도구 중 하나로도 평가할 계획이면 그 도구의 case 파일을 추가하고 **`assets/evals/`와 동기화하거나**, `scripts/`에서 `assets/evals/`로부터 생성합니다. 절반만 옮긴 두 벌은 하나의 정본보다 나쁩니다.

### 실행 결과를 두는 곳

위 fixture는 입력입니다. 그것을 실행한 **결과**는 skill 폴더 밖에 둡니다. 배포되는 skill이 자기 실행 이력을 들고 다니면 안 되고, 이 저장소의 다른 실행도 이미 그 자리에 쓰기 때문입니다.

```text
.omo/evidence/<skill>/iteration-N/
├── grading.json          # 필수 — SK-E-2
├── timing.json           # 필수 — SK-E-2
├── feedback.json         # 사람 검토가 있으면 필수 — SK-E-5
├── run-notes.json        # 선택 — runner, 모델, 기준선 caveat
├── trajectory.md         # 선택 — 실행 readback 추적
├── benchmark.json        # 선택 — benchmark 주장이 있을 때만
└── eval-<case>/
    ├── with_skill/       # SK-V-1 쌍 — 기준선을 돌리면 필수
    │   ├── outputs/
    │   ├── timing.json
    │   └── grading.json
    └── without_skill/    # 기준선이 이전 버전이면 old_skill/
        ├── outputs/
        ├── timing.json
        └── grading.json
```

| 파일 또는 디렉터리 | 상태 | 근거 |
|---|---|---|
| `grading.json` | 모든 실행에 필수 | SK-E-2 — assertion별 통과/실패와 근거 문자열 |
| `timing.json` | 모든 실행에 필수 | SK-E-2 — 토큰과 wall time |
| `feedback.json` | 사람 검토가 있으면 필수 | SK-E-5 |
| `eval-<case>/with_skill/`과 `eval-<case>/without_skill/`(또는 `old_skill/`) | 기준선 쌍을 돌릴 때 필수이며, deterministic skill 예외는 그 사실을 기록합니다 | SK-V-1, SK-E-6 |
| `benchmark.json` | 선택 — benchmark나 leaderboard 주장이 있을 때만 | [`validation.ko.md`](validation.ko.md) §7 |
| `run-notes.json` | 선택 — iteration의 runner, 모델, 기준선 caveat | 이 저장소의 관행 |
| `trajectory.md` | 선택 — 실행이 읽고 한 일을 readback용으로 기록 | 이 저장소의 관행 |

선택 파일은 진단용입니다. `run-notes.json`이나 `trajectory.md`를 빼면 나중에 읽는 사람이 원할 맥락이 줄지만, `grading.json`과 `timing.json`, 기준선 쌍을 빼면 그 실행은 근거로 읽을 수 없습니다. 집계는 허용합니다. 하나의 점수 map을 내는 runner는 `.omo/evidence/hyper-mass/iteration-1/grading.json`처럼 eval id를 key로 `grading.json`을 iteration root에 둘 수 있습니다. Case별 assertion은 근거 문자열을 그대로 가져야 합니다.

기준선이 "skill 없음"이 아니라 이전 버전이면 `without_skill/` 대신 `old_skill/`을 두고, 실행이 가리킨 스냅샷을 유지합니다.

이 저장소에는 eval 자료를 두는 자리가 이미 두 가지로 갈려 있었고, 세 번째를 더하면 정답이 하나도 남지 않습니다. 위 배치는 skill 폴더 옆에 workspace를 두는 대안 대신 골랐습니다. 형제 workspace 형태는 이 저장소에 선례가 없고 evidence 디렉터리에는 선례가 있기 때문입니다. 대가는 실제입니다. 결과가 배포되는 skill을 따라가지 않으므로 이 저장소 밖의 독자는 결과를 볼 수 없습니다.

- SK-E-1: 실행 결과는 skill 폴더 **밖**, 위에 적은 evidence 경로에 둡니다. 배포되는 skill은 자기 실행 이력을 갖지 않습니다.
- SK-E-2: 모든 실행은 `timing.json`(토큰과 wall time)과 `grading.json`(assertion별 통과/실패 **및 근거 문자열**)을 남깁니다. 근거 문자열이 없는 `passed: true`는 근거가 아닙니다.
- SK-E-3: 각 실행은 **독립 세션**에서 돌립니다. 한 세션을 재사용하면 앞선 실행의 컨텍스트가 다음 실행을 오염시킵니다.
- SK-E-4: 기계적 assertion(유효한 JSON, 행 수, 파일 존재)은 LLM judge가 아니라 **스크립트**로 확인합니다. Judge는 스크립트가 판정할 수 없는 것에 남깁니다.
- SK-E-5: 사람 검토는 eval 디렉터리 옆 `feedback.json`에 eval id 기준으로 남깁니다. Case마다 구체적 지적 문자열을 쓰고, 검토를 통과한 case는 빈 문자열로 둡니다. 이 파일은 검토자가 쓰고, 점수에서 생성하지 않습니다.
- SK-E-6: 버전을 비교할 때는 이전 버전을 iteration 디렉터리 안 `old_skill/`으로 두고, 어느 스냅샷 commit 또는 복사본인지 기록해 비교를 다시 돌릴 수 있게 합니다.

## 7. 금지 패턴

- `SKILL.md`가 참조 지식 저장소가 되는 것
- `references/` 파일이 여러 단계의 참조를 다시 요구하는 것
- `SKILL.md`에 사용 조건을 적지 않고 스크립트를 만드는 것
- 실제 workflow와 연결되지 않은 asset
- 긴 공식 문서를 그대로 복사하는 것
- Eval fixture를 산문 checklist로 남겨 다시 실행할 수 없게 하는 것
- 안전 경계를 도구 gate와 연결하지 않고 최종 답변의 어조 규칙으로만 쓰는 것
- 서로 어긋난 eval 세트 두 벌을 유지하는 것

## 8. 완료 기준

- [ ] 모든 지원 파일이 그 위치에 있는 이유가 있습니다.
- [ ] 모든 지원 파일을 `SKILL.md`에서 직접 또는 분명히 찾을 수 있습니다.
- [ ] 스크립트와 asset에 사용법과 검증이 있습니다.
- [ ] Provider 민감 내용이 references에 격리됐습니다.
- [ ] Prompt 템플릿, eval fixture, source ledger, 안전 노트가 산문·reference·asset·script 중 올바른 자리에 있습니다.
- [ ] `skill-creator`나 `claude plugin eval`로 평가할 skill이면 그 도구의 case 파일이 있고 runner가 읽는 fixture와 일치합니다.
- [ ] 매 세션 로드되는 내용의 머리에 변동 값(날짜, 버전, 개수, 머신 경로)이 없습니다. [`../../cache/CACHE.md`](../../cache/CACHE.md)를 참고합니다.
- [ ] Eval 실행 결과를 skill 폴더 밖에 두고, 실행별 timing·grading·사람 feedback 기록을 남겼습니다.

## Sources

> 링크는 다시 읽고 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| 실행 결과를 skill 디렉터리 밖에 두는 것, 실행별 `timing.json`·`grading.json`과 근거, 실행마다 독립 세션, 기계적 assertion을 스크립트로 확인하는 것, `with_skill`/`without_skill`/`old_skill` 명명, `feedback.json` — `SK-E-1`~`SK-E-6`의 근거 | <https://agentskills.io/skill-creation/evaluating-skills> |
| `skill-creator`가 읽는 손수 작성 입력 `evals/evals.json`, 그리고 서로 바꿔 쓸 수 없는 별도 형식을 쓰는 `claude plugin eval` | <https://code.claude.com/docs/en/skills> |
| 스크립트는 자립적이거나 의존성을 문서화하고, 도움이 되는 오류를 포함하며, edge case를 처리해야 함 | <https://agentskills.io/specification> |

### 근거 등급

배치와 비용 기록 규칙은 specification 사이트가 밝히므로 `PRIMARY`입니다. 구체적 디렉터리 배치(`.omo/evidence/...`)는 출처가 아니라 **저장소 결정**입니다. 출처는 skill 폴더 옆 `<name>-workspace/iteration-N/`를 씁니다. 이 파일은 그 선택과 대가를 함께 적었습니다. `SK-E-5`와 `SK-E-6`은 출처의 `feedback.json`·`old_skill/` 관례를 배치 규칙으로 확장한 것입니다. 파일 이름은 출처에서, 위치는 이 저장소에서 왔습니다.
