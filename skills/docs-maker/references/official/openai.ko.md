# OpenAI 공식 참고 자료

## 갱신 정책
- last_verified_at: 2026-03-19
- refresh_when:
  - model snapshot 또는 versioning 가이드가 바뀜
  - agent, eval, context, tool 가이드가 실질적으로 바뀜
  - canonical docs-maker 규칙에 새 OpenAI 전용 예외가 필요함
  - 구체적인 모델 문자열이나 capability note가 오래됨
  - reviewer가 provider 민감 주장을 아래 출처에 연결하지 못함
- maintenance_note: 구체적인 모델 문자열과 snapshot 예시는 canonical core 규칙이 아니라 이 파일에 둡니다.

## 프롬프트 엔지니어링
- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-03-19
- applies_to: 프롬프트 구조, developer message, 예시, Markdown/XML 경계
- summary: 명확한 지시, 예시, 구조화된 메시지 경계, 명시적 형식 가이드를 권장합니다.
- implication_for_docs_maker: 섹션 구조와 명시적 규칙 문구를 스킬의 중심에 둡니다.

## Agent Builder
- source_url: https://developers.openai.com/api/docs/guides/agent-builder
- last_verified_at: 2026-03-19
- applies_to: 에이전트 아키텍처와 도구 기반 시스템
- summary: 에이전트를 지시, 도구, handoff, guardrail이 결합된 시스템으로 다룹니다.
- implication_for_docs_maker: prompt-only 가이드에서 전체 하네스 문서로 범위를 확장합니다.

## 에이전트 구축 시 안전
- source_url: https://developers.openai.com/api/docs/guides/agent-builder-safety
- last_verified_at: 2026-03-19
- applies_to: prompt injection, MCP tool safety, approvals, guardrails, evals
- summary: 민감한 MCP 작업에는 human approval, 입력 guardrail, trace grader 또는 eval을 권장합니다.
- implication_for_docs_maker: 도구 문서는 capability만이 아니라 승인과 안전 경계를 함께 다뤄야 합니다.

## 평가 작업
- source_url: https://developers.openai.com/api/docs/guides/evals
- last_verified_at: 2026-03-19
- applies_to: 평가 설정과 grading
- summary: eval은 data source configuration과 testing criteria 또는 grader를 요구합니다.
- implication_for_docs_maker: eval 가이드는 데이터셋, 평가기, 수용 임계값을 명시해야 합니다.

## Agent Evals
- source_url: https://developers.openai.com/api/docs/guides/agent-evals
- last_verified_at: 2026-03-19
- applies_to: agent trajectory, tool use, goal completion 평가
- summary: 에이전트 워크플로우는 최종 텍스트만이 아니라 trajectory, tool behavior, goal completion까지 평가해야 합니다.
- implication_for_docs_maker: 하네스 문서는 단계별 행동도 평가해야 합니다.

## 프롬프트 캐싱
- source_url: https://developers.openai.com/api/docs/guides/prompt-caching
- last_verified_at: 2026-03-19
- applies_to: 공유 프롬프트 접두부와 캐시 효율
- summary: 반복 사용하는 안정적 내용은 앞쪽에 둬서 캐싱 효과를 극대화해야 합니다.
- implication_for_docs_maker: 컨텍스트 배치 규칙은 정적 공유 접두부와 변수 입력을 분리해야 합니다.

## 대화 상태
- source_url: https://developers.openai.com/api/docs/guides/conversation-state
- last_verified_at: 2026-03-19
- applies_to: 다중 턴 애플리케이션과 agent state 관리
- summary: 대화 상태는 메시지, tool call, tool output을 포함하는 설계 대상입니다.
- implication_for_docs_maker: 하네스 문서는 turn 사이에 무엇이 유지되고 무엇이 일시 상태인지 적어야 합니다.

## 압축
- source_url: https://developers.openai.com/api/docs/guides/compaction
- last_verified_at: 2026-03-19
- applies_to: 장기 실행 컨텍스트 관리
- summary: compaction은 완료된 작업을 요약하되 active plan과 핵심 제약은 유지해야 합니다.
- implication_for_docs_maker: 장기 실행 하네스 문서에는 state-retention 정책을 명시합니다.

## 프롬프트 최적화기
- source_url: https://developers.openai.com/api/docs/guides/prompt-optimizer
- last_verified_at: 2026-03-19
- applies_to: 프롬프트 반복 워크플로우
- summary: 프롬프트는 임의 수정이 아니라 체계적인 반복으로 개선할 수 있습니다.
- implication_for_docs_maker: prompt asset, 버전형 반복, validation loop를 장려합니다.

## GPT-5 모델 문서
- source_url: https://developers.openai.com/api/docs/models/gpt-5
- last_verified_at: 2026-03-19
- applies_to: 모델 동작, tools 지원, snapshots
- summary: snapshot으로 특정 모델 버전을 고정해 동작 일관성을 유지할 수 있습니다.
- implication_for_docs_maker: canonical 문서는 capability profile을 설명하고, 버전 고정 전략만 언급하며 고정 모델명을 core 규칙에 박지 않습니다.
