---
name: research
description: 라이브 웹, 공식 문서, GitHub, 로컬 저장소 근거를 조합해 사실 조사, 비교, 시장·트렌드 분석, 근거 기반 권고안을 마크다운 리포트로 남길 때 사용하는 조사 스킬입니다.
compatibility: 라이브 검색 또는 페이지 열람 도구, 가능하면 Context7 같은 공식 문서 접근 수단, GitHub 또는 저장소 검색, 로컬 파일 검색이 있을 때 가장 잘 동작합니다.
---

@rules/research-workflow.ko.md
@rules/validation.ko.md

# Research Skill

> 주제를 조사하고, 근거를 검증하고, 재사용 가능한 리포트로 저장합니다.

<purpose>

- 조사 질문을 `.hypercore/research/` 아래의 저장된 마크다운 브리프로 바꿉니다.
- 자유로운 글쓰기보다 근거 수집과 종합을 우선합니다.
- 코어 스킬은 얇게 유지하고, 검색 방식이나 보고 형식이 바뀔 때만 지원 파일을 읽습니다.

</purpose>

<routing_rule>

주된 일이 사실 조사, 비교, 트렌드 분석, 근거 기반 권고안 작성이면 `research`를 사용합니다.

다음 경우에는 `research`를 쓰지 않습니다.

- 새로운 근거 수집 없이 글쓰기, 리라이팅, 발표용 표현 다듬기만 필요한 경우
- 종합 없이 좁은 라이브러리/API 답 하나만 필요할 때. 이 경우에는 공식 문서 직접 조회를 우선합니다.
- 주된 일이 코드 수정, 디버깅, 구현 자체인 경우

</routing_rule>

<activation_examples>

Positive requests:

- "AI 에이전트 프레임워크 트레이드오프를 조사해줘."
- "실시간 알림용으로 WebSocket과 SSE를 비교해줘."
- "한국 SaaS 시장 최신 트렌드를 찾아서 정리해줘."

Negative requests:

- "이 보고서를 더 임원 친화적으로 다시 써줘."
- "문서 읽었으니 이제 마이그레이션을 구현해줘."

Boundary requests:

- "`/research react useEffectEvent`"
  여러 출처를 종합해야 할 때만 `research`를 쓰고, 아니면 공식 문서 직접 조회로 해결합니다.
- "`/research`"
  조사 주제가 없으므로 먼저 주제를 물어봅니다.

</activation_examples>

<depth_modes>

| 모드 | 검색 예산 | 최소 소스 | 2차 수집 | 결과물 형태 |
|------|------|------|------|------|
| `--quick` | 서로 다른 검색 1-3개 | 3개+ 검토, 2개+ 인용 | 없음 | 짧은 답변 또는 브리프 |
| 기본 | 서로 다른 검색 4-6개 | 6개+ 검토, 4개+ 인용 | 갭이 남을 때만 | 표준 리포트 |
| `--deep` | 서로 다른 검색 7-10개 | 10개+ 검토, 6개+ 인용 | 예 | 의사결정 메모 + 한계 |

</depth_modes>

<support_file_read_order>

다음 순서로 읽습니다.

1. 이 코어 `SKILL.ko.md`에서 조사 작업인지와 깊이를 먼저 확정합니다.
2. [instructions/sourcing/reliable-search.md](/Users/alpox/Desktop/dev/kood/hypercore/instructions/sourcing/reliable-search.md)를 읽어 중복 검색, 최신성 처리, 종료 조건을 고정합니다.
3. [references/channel-selection.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/research/references/channel-selection.ko.md)에서 로컬 검색, 공식 문서, GitHub 근거, 라이브 웹 소스 중 무엇을 먼저 쓸지 고릅니다.
4. [references/report-template.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/research/references/report-template.ko.md)에서 리포트 작성 및 저장 형식을 맞춥니다.
5. 완료 선언 전에는 [rules/validation.ko.md](/Users/alpox/Desktop/dev/kood/hypercore/skills/research/rules/validation.ko.md)를 확인합니다.

</support_file_read_order>

<workflow>

| Phase | 작업 | 산출물 |
|------|------|------|
| 0 | 주제, 깊이, 범위, 최신성 민감 여부 확정 | 조사 계획 |
| 1 | 채널과 검색 질문 선택 | 쿼리 계획 |
| 2 | 우선순위에 따라 근거 수집 | 소스 세트 |
| 3 | 결론 우선 리포트와 출처 정리 | 초안 |
| 4 | `.hypercore/research/`에 저장하고 검증 | 최종 리포트 + 짧은 사용자 요약 |

### Phase 규칙

- 주제가 없으면 검색 전에 먼저 질문합니다.
- 요청이 넓거나 고위험이거나 `--deep`이면, 검색 전에 sequential thinking으로 핵심 질문 3-5개, 범위, 날짜 제약, 종료 조건을 정의합니다.
- 요청이 좁고 저위험이면 장황한 계획 대신 짧은 계획만 적고 바로 수집합니다.
- 내부 프로젝트 질문은 로컬 저장소 검색을, 패키지/API 질문은 공식 문서를, 릴리스/구현 이력 질문은 GitHub 근거를, 시장/뉴스/트렌드는 라이브 웹 소스를 우선합니다.
- 사용자가 "latest", "current", "today", "최신" 같은 표현을 쓰면 라이브 소스로 검증하고, 상대 날짜 대신 절대 날짜를 리포트에 적습니다.
- 저장 없이 끝내지 않습니다. 이 스킬이 호출되었으면 채팅 답변만 하고 종료하지 않습니다.

</workflow>

<required>

- 검색 쿼리는 서로 다른 각도로 유지하고, 근거가 충분해지면 멈춥니다. 같은 쿼리를 채널만 바꿔 반복하지 않습니다.
- 기술 및 제품 관련 주장은 1차/공식 출처를 우선합니다.
- 최종 리포트의 비자명한 주장에는 모두 링크를 붙입니다.
- 대안을 평가할 때는 비교 표를 사용합니다.
- 충돌하는 주장이나 부족한 근거는 숨기지 말고 명시합니다.

</required>

<forbidden>

- 고정된 연도를 영구 규칙처럼 박아두는 것
- 출처 없는 주장
- 근거 표 없이 비교 결론만 내리는 것
- 로컬 런타임에 더 명확한 직접 경로가 있는데도 추상적인 도구/역할 이름만 쓰는 것

</forbidden>
