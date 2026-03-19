# Anthropic 공식 참고 자료

## 갱신 정책
- last_verified_at: 2026-03-19
- refresh_when:
  - migration guidance가 바뀜
  - prompt/tool/context 동작 가이드가 실질적으로 바뀜
  - canonical docs-maker 규칙에 새 Anthropic 전용 예외가 필요함
  - 구체적인 모델 문자열이나 capability note가 오래됨
  - architect 또는 reviewer가 provider 민감 주장을 아래 출처에 연결하지 못함
- maintenance_note: 구체적인 모델 문자열과 migration 예시는 canonical core 규칙이 아니라 이 파일에 둡니다.

## 프롬프팅 모범 사례
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags
- last_verified_at: 2026-03-19
- applies_to: Anthropic prompt engineering, tool use, long-context prompting, adaptive thinking behavior
- refresh_when: prompt/tool 동작 가이드가 실질적으로 바뀜
- summary: 명확하고 직접적인 지시, 예시, XML 태그, 명시적 도구 가이드, 병렬 도구 호출, 과도한 도구 트리거 방지 조정을 권장합니다.
- implication_for_docs_maker: canonical 규칙은 명시적이고 구조화하되, 모델별 steering은 코어에 하드코딩하지 않습니다.

## 프롬프트 엔지니어링 개요
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- last_verified_at: 2026-03-19
- applies_to: 일반적인 prompt engineering 워크플로우
- refresh_when: prompt workflow 가이드가 실질적으로 바뀜
- summary: 예시, system prompt, XML 태그, 평가를 동반한 반복 작업으로 prompt engineering을 설명합니다.
- implication_for_docs_maker: 구조, 예시, 검증을 스킬의 핵심 요소로 유지합니다.

## 프롬프트 템플릿과 변수
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/prompt-templates-and-variables
- last_verified_at: 2026-03-19
- applies_to: 프롬프트 자산 템플릿화
- refresh_when: template 또는 variable 지원이 바뀜
- summary: 테스트와 유지보수를 위해 재사용 가능한 프롬프트 템플릿과 매개변수화된 변수를 권장합니다.
- implication_for_docs_maker: 프롬프트를 일회성 문장이 아니라 재사용 가능한 자산으로 다룹니다.

## 긴 컨텍스트 팁
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips
- last_verified_at: 2026-03-19
- applies_to: 긴 문서 프롬프트
- refresh_when: long-context 배치 가이드가 바뀜
- summary: 긴 입력은 위에, 질의는 아래에 두고, 여러 문서는 XML 태그와 인용 기반 grounding으로 구조화하라고 권장합니다.
- implication_for_docs_maker: 긴 컨텍스트 하네스를 문서화할 때 명시적 배치 규칙을 추가합니다.

## 성공 기준 정의
- source_url: https://docs.anthropic.com/en/docs/test-and-evaluate/define-success
- last_verified_at: 2026-03-19
- applies_to: 평가 계획
- refresh_when: eval setup이나 success-criteria 가이드가 바뀜
- summary: 반복 전에 success criteria와 minimum viable evaluation set을 먼저 정의하라고 권장합니다.
- implication_for_docs_maker: eval 기준과 테스트 세트 없이 prompt iteration을 문서화하지 않습니다.

## 컨텍스트 윈도우
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/context-windows
- last_verified_at: 2026-03-19
- applies_to: 컨텍스트 크기와 한도
- refresh_when: context-window 또는 sizing 가이드가 바뀜
- summary: 컨텍스트 크기를 무제한 버퍼가 아니라 관리 대상 자원으로 다룹니다.
- implication_for_docs_maker: 장기 실행 하네스 문서에는 compaction과 state retention 정책을 명시합니다.

## 압축
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/compaction
- last_verified_at: 2026-03-19
- applies_to: 장기 실행 대화와 에이전트
- refresh_when: compaction 전략 또는 agent-state 가이드가 바뀜
- summary: compaction을 1급 컨텍스트 관리 문제로 다룹니다.
- implication_for_docs_maker: canonical 규칙과 compactable task state를 분리하고, 무엇이 남아야 하는지 적습니다.

## 프롬프트 캐싱
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
- last_verified_at: 2026-03-19
- applies_to: 재사용 가능한 프롬프트 접두부
- refresh_when: prompt caching 메커니즘이나 전략이 바뀜
- summary: 안정적인 접두부와 cache breakpoint가 효율성과 재현성에 중요합니다.
- implication_for_docs_maker: 공유 컨텍스트를 반복 재사용하는 하네스에는 cache-aware prompt layout을 포함합니다.

## 에이전트 스킬 모범 사례
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/agent-skills/best-practices
- last_verified_at: 2026-03-19
- applies_to: skill과 agent guidance 설계
- refresh_when: agent-skill 포장 방식이나 계약 가이드가 바뀜
- summary: 스킬은 명확한 범위, 분명한 계약, 압축된 재사용 가이드가 있을 때 더 잘 작동합니다.
- implication_for_docs_maker: skill 본문은 압축하고, 전문 내용은 rules와 references로 보냅니다.

## 마이그레이션 가이드
- source_url: https://docs.anthropic.com/en/docs/about-claude/models/migration-guide
- last_verified_at: 2026-03-19
- applies_to: 모델 변경과 호환성 드리프트
- refresh_when: 새 모델 계열 출시나 migration 공지가 나옴
- summary: 모델 이름과 모델 동작은 시간이 지나며 바뀌므로 migration-aware 업데이트가 필요합니다.
- implication_for_docs_maker: canonical core 가이드에서는 고정 모델명을 금지하고, 구체적 모델 문자열은 날짜가 붙은 provider reference에만 둡니다.
