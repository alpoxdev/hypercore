# Anthropic 공식 참고 자료

## 갱신 정책
- last_verified_at: 2026-03-19
- refresh_when:
  - 스킬 작성 가이드가 실질적으로 바뀜
  - 스킬 설계에 영향을 주는 프롬프트 구조 가이드가 바뀜
  - 스킬 검증에 영향을 주는 평가 가이드가 바뀜
  - 코어 skill-maker 규칙이 Anthropic 동작을 더 직접적으로 인용하게 됨
- supports_rules:
  - `rules/trigger-design.ko.md`
  - `rules/progressive-disclosure.ko.md`
  - `rules/validation-and-iteration.ko.md`

## 스킬 작성 모범 사례
- source_url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- last_verified_at: 2026-03-19
- applies_to: 스킬 description, 점진적 공개, 검증, 안티패턴
- summary: 간결한 description, 적절한 자유도, 점진적 공개, 분명한 워크플로, 현실적 테스트, 시간 민감 정보 회피, 한 단계 깊이의 support file 구조를 강조합니다.
- implication_for_skill_maker: 트리거 문구, 자원 배치, 현실적 검증을 1급 관심사로 둡니다.

## 프롬프트 엔지니어링 개요
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- last_verified_at: 2026-03-19
- applies_to: 구조화된 지시와 예시
- summary: 명확한 지시, 예시, 구조화된 컨텍스트, 반복 개선이 프롬프트 품질을 높입니다.
- implication_for_skill_maker: 스킬 본문은 구조화하고 예시 중심으로 두되, 얇게 유지합니다.

## 긴 컨텍스트 팁
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips
- last_verified_at: 2026-03-19
- applies_to: 상세 references 배치
- summary: 긴 입력은 의도적인 순서와 구조가 필요합니다.
- implication_for_skill_maker: 큰 상세 내용은 references로 보내고, 배치도 의식적으로 설계합니다.

## 성공 기준 정의
- source_url: https://docs.anthropic.com/en/docs/test-and-evaluate/define-success
- last_verified_at: 2026-03-19
- applies_to: 평가와 반복
- summary: 반복 전에 성공 기준과 평가 세트를 먼저 정의해야 합니다.
- implication_for_skill_maker: prose review만이 아니라 트리거와 사용 검증을 요구합니다.
