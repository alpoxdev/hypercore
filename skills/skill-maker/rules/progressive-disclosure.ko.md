# 점진적 공개

**목적**: 스킬을 얇게 유지하면서도 깊은 상세 정보를 필요한 순간에 찾을 수 있게 합니다.

## 1. 3단계 로딩 모델

모든 스킬은 agent가 단계적으로 로드한다고 가정하고 설계합니다.

| 단계 | 로드되는 내용 | 설계 목표 |
|---|---|---|
| Discovery | `name`, `description`, path | 정확한 skill selection |
| Activation | 전체 `SKILL.md` | Core workflow와 execution contract |
| Execution | `rules/`, `references/`, `scripts/`, `assets/` | 필요할 때만 detail, deterministic helper, output resource 로드 |

아래 계층으로 갈수록 내용은 더 구체적이고 더 선택적이어야 합니다.

## 2. 코어는 얇게 유지

코어 스킬에는 다음을 둡니다.

- job, trigger, boundary
- authority, safety, output, verification, stop-condition 요약
- high-level workflow
- read condition이 있는 깊은 파일 pointer

다음은 밖으로 뺍니다.

- 긴 예시
- 공식 출처 요약
- schema와 provider-specific detail
- variant-specific workflow
- 결정적 command logic
- output template

## 3. Navigation Cue

`see references/` 같은 모호한 참조를 쓰지 않습니다.

약한 예:

```markdown
For more information, see references/.
```

더 나은 예:

```markdown
Read `references/official/openai.md` only when OpenAI-specific skill behavior changes the rule.
Read `rules/validation-and-iteration.md` before declaring the skill complete.
Run `scripts/validate-skill.mjs` when the target skill includes scripts or generated assets.
```

## 4. 한 단계 깊이

가능하면 `SKILL.md`에서 직접 연결된 support file을 사용합니다.
명시적 정당화 없이 rule이 다른 rule을 요구하고, 다시 reference를 요구하는 chain을 만들지 않습니다.

## 5. 필요에 따라 분리

다음 기준으로 내용을 나눕니다.

- 반복 정책은 `rules/`
- 상세 지식은 `references/`
- 결정적 실행은 `scripts/`
- 출력 자원은 `assets/`
- 소비되는 runtime/UI metadata는 `agents/`

## 6. Readback Check

분리 후 확인합니다.

- 코어만 읽어도 스킬이 이해되는가
- support file을 코어에서 찾을 수 있는가
- 핵심 지시가 여러 계층에 중복되지 않았는가
- 모든 support file의 존재 이유가 있는가
