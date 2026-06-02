# Progressive Disclosure

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
- 꼭 알아야 하는 gotcha
- support files를 언제 읽을지 알려주는 navigation
- validation과 stop condition

## 3. 내려보낼 것

| 내용 | 위치 |
|---|---|
| 긴 공식 문서 요약 | `references/official/*.md` |
| 반복 정책 | `rules/*.md` |
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
Read `references/openai.md` only when provider-specific Codex skill behavior changes the core rule.
Read `rules/validation.md` before declaring a skill complete.
Run `scripts/validate-skill.mjs` when the skill includes scripts or generated assets.
```

## 5. Context 예산 규칙

- core `SKILL.md`는 가능하면 300줄 안팎, 특별한 이유가 있어도 500줄을 넘기지 않는다.
- `references/` 파일은 하나의 주제에 집중한다.
- deep reference chain을 만들지 않는다.
- support file을 만들었으면 `SKILL.md`에서 직접 참조한다.
- support file을 만들지 않아도 되는 설명은 만들지 않는다.

## 6. Readback check

분리 후 다음 질문에 답한다.

- `SKILL.md`만 읽어도 무엇을 언제 해야 하는지 알 수 있는가?
- support file을 읽어야 하는 조건이 명확한가?
- 반복 정의가 core와 reference에 중복되어 있지 않은가?
- 모든 reference가 실제로 유용한가?
- scripts/assets가 reasoning 파일로 오용되지 않는가?
