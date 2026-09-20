# Progressive Disclosure

> 영어판: [`progressive-disclosure.md`](progressive-disclosure.md)

Progressive disclosure는 skill의 핵심 설계 원리다. agent가 모든 skill의 모든 내용을 처음부터 읽는다고 가정하면 context가 낭비되고 지시 충돌이 늘어난다. 따라서 skill은 필요한 순간에 필요한 깊이만 읽도록 설계한다.

## 1. 세 단계 모델

| 단계 | 로드되는 내용 | 설계 목표 |
|---|---|---|
| Discovery | `name`, `description`, path | 정확한 skill 선택 |
| Activation | 전체 `SKILL.md` | 핵심 workflow와 계약 실행 |
| Execution | `references/`, `scripts/`, `assets/` | 필요할 때 세부 지식/도구 사용 |

## 2. `SKILL.md`에 남길 것

- trigger와 scope
- authority/evidence 기준
- workflow 큰 단계
- loop type, feedback source, stop condition의 요약
- 꼭 알아야 하는 gotcha
- support files를 언제 읽을지 알려주는 navigation
- validation과 stop condition

## 3. 내려보낼 것

| 내용 | 위치 |
|---|---|
| 긴 공식 문서 요약 | `references/official/*.md` |
| 반복 정책 | `rules/*.md` |
| prompt scaffold / reusable prompt template | `assets/prompts/` 또는 `references/examples.md` |
| loop 세부 규칙과 실패 복구 순서 | `rules/loop.md` |
| eval case / fixture / expected output | `assets/evals/` 또는 `references/eval-cases.md` |
| source ledger / vendor drift note | `references/official/` 또는 `references/sources.md` |
| prompt injection / side-effect safety note | `rules/safety.md` 또는 `references/safety.md` |
| schema/API/detail | `references/*.md` |
| deterministic 검증 | `scripts/*.py`, `scripts/*.sh`, `scripts/*.mjs` |
| 템플릿 | `assets/*` |
| 긴 예시 모음 | `references/examples.md` 또는 `assets/examples/*` |

## 4. Navigation 문장

단순히 “see references/”라고 쓰지 않는다. 언제 읽을지 적는다.

약한 예:

```markdown
For more information, see references/.
```

강한 예:

```markdown
Read `references/official/openai.md` only when provider-specific Codex skill behavior changes the core rule.
Read `references/prompt-loop-eval.md` before adding an iterative loop, prompt optimizer, or eval fixture.
Read `rules/safety.md` before enabling network, credential, destructive, or production side effects.
Run `scripts/validate-skill.mjs` when the skill includes scripts, generated assets, or eval fixtures.
```

## 5. Context 예산 규칙

- core `SKILL.md`는 500줄 이내로 유지한다 — 그 한계는 specification이 말한 것이지 이 저장소가 만든 것이 아니다. 이 저장소는 **추가로** 300줄 게이트를 강제한다(`scripts/check-sources.sh`, `MAX_LINES=300`). 300은 **이 저장소가 고른 기본값**이지 출처가 진술한 수치가 아니다. 둘은 다르다: 500은 출처가 말한 값이고, 300은 이 저장소가 검사하는 값이다.
- `references/` 파일은 하나의 주제에 집중한다.
- deep reference chain을 만들지 않는다.
- support file을 만들었으면 `SKILL.md`에서 직접 참조한다.
- support file을 만들지 않아도 되는 설명은 만들지 않는다.
- eval fixture와 prompt template은 prose reference가 아니라 실제 실행/복사 대상이면 `assets/`에 둔다.

## 6. Readback check

분리 후 다음 질문에 답한다.

- `SKILL.md`만 읽어도 무엇을 언제 해야 하는지 알 수 있는가?
- support file을 읽어야 하는 조건이 명확한가?
- 반복 정의가 core와 reference에 중복되어 있지 않은가?
- 모든 reference가 실제로 유용한가?
- scripts/assets가 reasoning 파일로 오용되지 않는가?

### 제거 판정

위 질문들은 내용이 *유용한지*를 묻는다. 아래는 그 내용이 *자리를 얻을 자격이 있는지*를 판정한다.

- SK-D-1: 각 지시에 **"이것이 없으면 에이전트가 틀리는가?"**를 묻는다. 답이 "아니오"면 지운다. 확신이 없으면 미심쩍다는 이유로 남기지 말고 시험한다.
- SK-D-2: skill 없이도 과제가 성공하면 그 skill은 가치를 더하지 않을 수 있다. 에이전트가 이미 안정적으로 하는 일을 다시 적는 skill은 이득 없이 비용만 늘린다.

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| 주장 | 출처 |
|---|---|
| 500줄·5,000토큰 점진공개 예산, 그리고 `SK-D-1`·`SK-D-2` 뒤의 제거 판정 | <https://agentskills.io/skill-creation/best-practices> |
| 3단계 모델(메타데이터 → 전체 지시 → 참조 파일) | <https://agentskills.io/specification> |

### 근거 등급

이 파일이 점진공개 예산의 **정본**이다. [`skill-anatomy.ko.md`](skill-anatomy.ko.md)는 예산을 다시 적지 않고 이쪽을 가리킨다. 500줄·5,000토큰은 `PRIMARY`다 — specification 사이트가 직접 진술한다. 300줄은 이 저장소의 게이트이고, 그렇게 표시했다.
