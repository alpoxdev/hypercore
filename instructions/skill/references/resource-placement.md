# Resource Placement

Resource placement는 skill 폴더의 각 파일이 정확한 책임을 갖도록 배치하는 규칙이다.

## 1. Placement matrix

| 리소스 | 둬야 할 곳 | 이유 |
|---|---|---|
| 언제 skill을 써야 하는지 | `description`, `routing_rule` | discovery/trigger 신호 |
| 고수준 실행 순서 | `SKILL.md` | activation 시 항상 필요 |
| 반복 검증 체크리스트 | `rules/` 또는 `SKILL.md` validation | 모든 run에서 재사용 |
| 공식 문서 요약 | `references/official/` | provider drift와 상세성 분리 |
| 긴 예시 | `references/examples.md` 또는 `assets/` | 필요 시만 로드 |
| 반복 loop 정책 | `rules/loop.md` | feedback, guard, stop condition 재사용 |
| prompt template | `assets/prompts/` 또는 `references/examples.md` | 복사/채움 대상이면 assets, 설명이면 references |
| eval fixture | `assets/evals/` | 입력/expected output을 실행 가능하게 보관 |
| source ledger | `references/sources.md` 또는 `references/official/` | 외부 claim 추적 |
| safety boundary | `rules/safety.md` 또는 `references/safety.md` | tool/network/credential/destructive gate |
| 출력 템플릿 | `assets/` | 복사/채움 대상 |
| 자동 검증 | `scripts/` | 결정성/반복성 보장 |
| UI/runtime metadata | `agents/` | 플랫폼별 표시/의존성 정보 |

## 2. Rules vs References

`rules/`는 판단 기준과 절차다.

예:

- “script를 언제 추가할지”
- “검증 실패 시 어떤 순서로 고칠지”
- “research source를 어떻게 등급화할지”
- “loop가 언제 계속되고 언제 멈춰야 하는지”
- “network/credential/destructive action을 언제 gate할지”

`references/`는 지식과 상세다.

예:

- OpenAI Codex skill docs 요약
- Anthropic Claude Code skill lifecycle
- API schema
- domain-specific edge cases
- source ledger와 vendor drift note
- 논문/benchmark 근거 요약

## 3. Scripts 추가 기준

스크립트는 다음 중 하나 이상을 만족할 때만 추가한다.

- 같은 로직을 여러 번 반복해야 한다.
- agent가 매번 명령을 틀릴 위험이 높다.
- output을 machine-readable하게 검증해야 한다.
- 실패 메시지가 self-correction에 중요하다.
- 기존 도구를 호출하더라도 version pinning과 parameter normalization이 필요하다.

스크립트 문서화 필수 항목:

```markdown
## Available scripts

- `scripts/validate-skill.mjs`
  - Purpose: validate frontmatter, local links, code fences, and support file references.
  - Usage: `node scripts/validate-skill.mjs skills/my-skill`
  - Requires: Node.js 20+
  - Output: JSON summary plus non-zero exit on failure.
```

## 4. Assets 추가 기준

Assets는 산출물에 실제로 쓰이는 파일만 둔다.

좋은 assets:

- report template
- CSV fixture
- JSON schema
- style sample
- image/reference mock
- prompt template with blanks
- eval input/expected output pair
- golden output snapshot

나쁜 assets:

- 읽기 전용 설명 문서
- 중복된 reference
- 언제 쓰는지 모르는 예시 파일

## 5. Official references 배치

공식 문서 근거는 core에 길게 넣지 않는다. 다음처럼 분리한다.

```text
references/
└── official/
    ├── openai.md
    ├── anthropic.md
    └── agent-skills-standard.md
```

각 파일은 다음을 포함한다.

- 확인일
- 출처 URL
- 해당 skill에 영향을 주는 claim
- drift caveat
- core rule로 옮긴 요약

## 6. Eval resources 배치

Eval 자료는 “읽는 설명”과 “실행/비교하는 fixture”를 나눈다.

```text
assets/
└── evals/
    ├── trigger-cases.jsonl
    ├── workflow-cases.jsonl
    └── safety-cases.jsonl

references/
└── eval-rubric.md
```

- `assets/evals/*.jsonl`은 parser나 runner가 읽을 수 있는 machine-readable case를 둔다.
- `references/eval-rubric.md`는 사람이 읽는 scoring 기준과 caveat를 둔다.
- deterministic runner가 있으면 `scripts/run-evals.*`에 두고, dependency와 expected output을 문서화한다.
- eval case가 외부 source를 요구하면 source URL, accessed date, freshness caveat를 case 안이나 source ledger에 연결한다.

## 7. 금지 패턴

- `SKILL.md`가 reference knowledge base가 되는 것
- `references/` 안에서 다시 여러 단계 reference를 요구하는 것
- scripts를 만들었지만 `SKILL.md`에 사용 조건이 없는 것
- assets가 실제 workflow에 연결되지 않는 것
- 공식 문서 원문을 길게 복사하는 것
- eval fixture를 prose checklist로만 남겨 재실행할 수 없게 하는 것
- safety boundary를 final answer tone 규칙처럼만 쓰고 tool gate에 연결하지 않는 것

## 8. 완료 기준

- [ ] 모든 support file은 위치 이유가 있다.
- [ ] 모든 support file은 `SKILL.md`에서 직접 또는 명확히 discoverable하다.
- [ ] scripts/assets는 usage와 validation이 있다.
- [ ] provider-sensitive content는 references에 격리되어 있다.
- [ ] prompt templates, eval fixtures, source ledgers, safety notes가 prose/reference/asset/script 중 올바른 위치에 있다.
