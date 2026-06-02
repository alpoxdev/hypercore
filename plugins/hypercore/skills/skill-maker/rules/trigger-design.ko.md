# 트리거 설계

**목적**: 스킬이 맞는 요청에는 잘 걸리고, 틀린 요청에는 끼어들지 않게 만듭니다.

## 1. 설명 문구 규칙

`description`은 다음을 설명해야 합니다.

- 스킬이 하는 일
- 언제 써야 하는지
- 어떤 사용자 요청이 이 스킬을 발동시켜야 하는지

약한 예:

```yaml
description: Helps with skills
```

더 나은 예:

```yaml
description: Create and refactor Codex skills, including SKILL.md, rules, references, scripts, assets, and trigger/validation guidance.
```

## 2. 트리거 예시

본문이나 예시 섹션에 현실적인 사용자 발화 예시를 넣습니다.

- "SQL migration 리뷰용 스킬 만들어줘"
- "이 스킬이 references를 제대로 읽도록 리팩토링해줘"
- "브라우저 기반 QA용 새 Codex 스킬을 만들어줘"

부정 예시:

- "이 런북을 더 명확하게 다시 써줘"
- "OpenAI 문서를 요약해줘"

경계 예시:

- "스킬 작성 가이드를 만들어줘"
- "이 스킬을 고치고 나서 커밋까지 해줘"

## 3. 범위 경계

이 스킬이 하지 않는 일도 적습니다.

예:

- 일반 문서 작업은 `docs-maker`
- 스킬 폴더 생성이나 스킬 리팩토링은 `skill-maker`
- 사실 조사 중심이면 `research`
- 구현 전 계획 수립이 핵심이면 `plan`
- 커밋 생성이 핵심이면 `git-commit`

## 4. 트리거 검증

설명 문구가 다음을 만족하는지 확인합니다.

- 목표 요청에는 잘 걸리는가
- 무관한 요청은 피하는가
- 스킬 본문 전체를 읽지 않아도 이해되는가

## 5. 안티패턴

- 모호한 설명 문구
- 도구 목록만 있고 실제 일이 없는 설명 문구
- 하는 일은 있지만 언제 써야 하는지 없는 설명 문구
- 너무 넓어서 모든 메타 스킬과 겹치는 description
