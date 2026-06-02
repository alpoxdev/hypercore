# OpenAI 공식 참고 자료

## 갱신 정책
- last_verified_at: 2026-03-19
- refresh_when:
  - skills 가이드가 실질적으로 바뀜
  - 평가 또는 상태 가이드가 스킬 검증에 영향을 줄 만큼 바뀜
  - 프롬프트 엔지니어링 가이드가 트리거 문구에 영향을 줄 만큼 바뀜
  - 코어 skill-maker 규칙이 OpenAI 동작을 더 직접적으로 인용하게 됨
- supports_rules:
  - `rules/trigger-design.ko.md`
  - `rules/validation-and-iteration.ko.md`
  - `rules/progressive-disclosure.ko.md`

## Skills 가이드
- source_url: https://developers.openai.com/api/docs/guides/tools-skills
- last_verified_at: 2026-03-19
- applies_to: 에이전트 행동 자산으로서의 스킬
- summary: 스킬은 에이전트 행동을 가이드하며, 로컬 셸에서는 올바른 스킬 파일 처리 방식이 중요합니다.
- implication_for_skill_maker: 스킬은 단순 텍스트 파일이 아니라 잘 트리거되는 자산으로 설계해야 합니다.

## 프롬프트 엔지니어링
- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-03-19
- applies_to: 지시 명확성 및 예시
- summary: 명확한 지시, 예시, 명시적 형식 지정이 따라가기 쉬운 출력을 만듭니다.
- implication_for_skill_maker: 코어 스킬 지시는 명시적이고 예시 근거가 있어야 합니다.

## Agent Builder
- source_url: https://developers.openai.com/api/docs/guides/agent-builder
- last_verified_at: 2026-03-19
- applies_to: 도구와 가드레일을 가진 시스템 설계
- summary: 에이전트는 지시, 도구, 가드레일, handoff가 결합된 시스템입니다.
- implication_for_skill_maker: 필요할 때 스킬은 단순 문장보다 전체 운영 표면을 문서화해야 합니다.

## 평가 작업
- source_url: https://developers.openai.com/api/docs/guides/evals
- last_verified_at: 2026-03-19
- applies_to: 평가 기준
- summary: 평가는 데이터 소스와 testing criteria 또는 grader를 필요로 합니다.
- implication_for_skill_maker: 스킬 검증은 관측 가능한 트리거 및 사용 체크를 정의해야 합니다.

## 대화 상태와 압축
- source_url: https://developers.openai.com/api/docs/guides/conversation-state
- last_verified_at: 2026-03-19
- applies_to: 장기 실행 스킬 기반 워크플로
- summary: 상태와 압축은 명시적 시스템 설계 선택입니다.
- implication_for_skill_maker: 길거나 계층화된 스킬은 상태와 support file 배치가 읽기 쉬워야 합니다.
