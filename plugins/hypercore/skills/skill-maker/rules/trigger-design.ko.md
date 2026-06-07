# 트리거 설계

**목적**: 스킬이 맞는 요청에는 잘 걸리고, 틀린 요청에는 끼어들지 않게 만듭니다.

## 1. Description 규칙

`description`은 다음을 설명해야 합니다.

- 스킬이 하는 일
- 언제 써야 하는지
- 애매할 때 어떤 이웃 요청은 소유하지 않는지

약한 예:

```yaml
description: Helps with skills.
```

더 나은 예:

```yaml
description: Use this skill when the user asks to create or refactor a reusable Codex skill folder, including SKILL.md trigger wording, rules, references, scripts, assets, and validation checks. Do not use for generic documentation that is not a skill.
```

## 2. 작성 패턴

- runtime이 prose description을 받는다면 `Use this skill when...`으로 시작합니다.
- 내부 구현보다 user intent와 outcome을 앞세웁니다.
- 가장 중요한 trigger term을 앞부분에 둡니다.
- 가까운 이웃 skill이 있으면 짧은 negative boundary를 포함합니다.
- 모든 meta-skill과 겹칠 만큼 넓은 description은 피합니다.

## 3. Trigger Example Set

현실적인 사용자 발화를 포함합니다.

긍정 예시:

- "SQL migration 리뷰용 스킬 만들어줘."
- "이 스킬이 references를 제대로 읽도록 리팩토링해줘."
- "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘."

부정 예시:

- "이 런북을 더 명확하게 다시 써줘."
- "OpenAI 문서를 요약해줘."
- "스킬 폴더가 아니라 프롬프트만 만들어줘."

경계 예시:

- "스킬 작성 가이드를 만들어줘."
- "최신 skill 문서를 조사하고 이 스킬을 업데이트해줘."
- "이 스킬을 고치고 나서 커밋까지 해줘."

## 4. Trigger Smoke Test

새 skill 또는 실질 변경 skill에는 작은 smoke set을 둡니다.

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "should_trigger": true },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "should_trigger": true },
  { "id": "p3", "prompt": "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘", "should_trigger": true },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "should_trigger": false },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "should_trigger": false },
  { "id": "b1", "prompt": "Create a guide for writing skills", "should_trigger": "depends_on_output_shape" }
]
```

## 5. Scope Boundaries

이 스킬이 하지 않는 일도 적습니다.

예:

- 일반 문서 작업은 `docs-maker`
- 스킬 폴더 생성이나 스킬 리팩토링은 `skill-maker`
- 출처 기반 사실 조사가 핵심이면 `research`
- 구현 전 계획 수립이 핵심이면 `plan`
- 커밋 생성이 핵심이면 `git-commit`

## 6. Anti-Patterns

- 모호한 description
- 도구 목록만 있고 실제 일이 없는 description
- 하는 일은 있지만 언제 써야 하는지 없는 description
- should-not-trigger 예시가 없음
- 이웃 skill과 너무 넓게 겹치는 description
