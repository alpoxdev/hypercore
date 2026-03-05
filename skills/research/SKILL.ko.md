---
name: research
description: 범용 자료조사 후 사람이 읽기 쉬운 구조화 리포트를 생성합니다. WebSearch/WebFetch/GitHub MCP/Firecrawl/SearXNG 등 가용 채널을 조합해 quick/standard/deep 깊이로 조사할 때 사용합니다.
compatibility: 외부 검색이 가능한 환경과 출처 확인 가능한 도구(WebSearch/WebFetch/MCP)가 필요합니다.
---

# Research Skill

> 범용 자료조사 -> 사람이 읽기 쉬운 구조화 리포트 생성.

<purpose>

입력: 주제(자연어) + 선택 깊이(`--quick`/기본/`--deep`)
출력: `.hypercore/research/[NN].주제_요약.md`

</purpose>

<trigger_conditions>

| 트리거 | 반응 |
|------|------|
| `/research AI 에이전트 프레임워크 비교` | 기술 비교 조사 |
| `/research --deep 한국 SaaS 시장 트렌드` | 심층 시장 조사 |
| `/research --quick WebSocket vs SSE` | 빠른 기술 비교 |
| "OO에 대해 자료조사" | 주제 확인 후 실행 |

ARGUMENT가 없으면 즉시 질문: "어떤 주제를 조사할까요?"

</trigger_conditions>

<depth_levels>

| 설정 | quick | standard(기본) | deep |
|------|------|------|------|
| 쿼리 수 | 3-5 | 5-10 | 10-15 |
| 에이전트 | researcher 2 + explore 0-1 | researcher 3-4 + explore 0-1 | researcher 4-5 + explore 1 + MCP |
| 2차 수집 | X | X | O |
| 최소 소스 | 5 | 10 | 20+ |
| 리포트 길이 | 500-1000자 | 1500-3000자 | 3000-6000자 |

</depth_levels>

<topic_classification>

| 유형 | 키워드 | 채널 |
|------|------|------|
| 기술 비교 | vs, 비교 | WebSearch + explore(gh) |
| 시장/트렌드 | 시장, 트렌드 | WebSearch + Firecrawl |
| 경쟁사 분석 | 경쟁사, 대안 | WebSearch + GitHub MCP |
| 학술/개념 | 원리, 논문 | WebSearch(arxiv) + WebFetch |
| 프로젝트 내부 | 우리 코드 | explore + Grep |
| 라이브러리 | 패키지@버전 | docs-fetch 위임 |

</topic_classification>

<mandatory_reasoning>

## Mandatory Sequential Thinking

- Phase 1(전략 수립)과 deep 모드의 Phase 3(갭 분석)에서는 `sequential-thinking`을 반드시 사용합니다.
- 검색 쿼리에는 현재 연도(2026)를 포함해 최신성 기준을 명시합니다.
- structured reasoning 없이 바로 결론을 작성하지 않습니다.

</mandatory_reasoning>

<parallel_agent_execution>

- 3개 이상 병렬 에이전트가 필요하면 Agent Teams를 우선 사용합니다.
- Agent Teams가 없으면 Task 병렬 호출로 폴백합니다.
- quick 모드(2개 이하)는 직접 병렬 호출 허용.

</parallel_agent_execution>

<workflow>

| Phase | 작업 | 도구 |
|------|------|------|
| 0 | 입력 파싱 + MCP 감지 + 주제 분류 | ToolSearch |
| 1 | 검색 전략 수립 | Sequential Thinking(2단계) |
| 2 | 병렬 수집 | researcher + explore + MCP |
| 3 | 갭 분석 + 2차 수집(deep만) | analyst -> researcher |
| 4 | 리포트 작성 | general-purpose |
| 5 | 저장 + 요약 출력 | Write |

### Phase 1 (필수)
- 핵심 질문 3-5개 정의
- 범위(시간/지역/언어) 정의
- 한/영 쿼리 세트 생성
- 채널/에이전트 역할 배분

### Phase 4 리포트 작성 원칙
- 결론 우선(Pyramid Principle)
- 핵심 주장마다 출처 URL 명시
- 요약 -> 상세 순서
- 표/비교 매트릭스 적극 사용

</workflow>

<report_template>

```markdown
# [주제] 조사 리포트

> 조사일: YYYY-MM-DD | 깊이: quick/standard/deep | 소스: N개 검토, M개 인용

## Executive Summary
[250-400자, 결론 우선]

## 1. 조사 개요
### 1.1 배경
### 1.2 범위
### 1.3 방법론

## 2. 핵심 발견사항
### 2.1 [발견 1]
핵심: [한 줄]
상세: ...
출처: [제목](URL)

## 3. 비교 분석 (필요 시)
| 기준 | A | B | C |
|------|---|---|---|

## 4. 트렌드 및 시사점

## 5. 결론 및 권장사항

## 참고자료
- [제목](URL)
```

</report_template>

<validation>

| 항목 | 필수 |
|------|------|
| ARGUMENT | 없으면 즉시 질문 |
| 전략 | Sequential Thinking으로 질문/쿼리 설계 |
| 소스 | quick 5+, standard 10+, deep 20+ |
| 최신성 | 연도/발행일 기준 명시 |
| 결과물 | Executive Summary + 출처 + 권장사항 |
| 저장 | `.hypercore/research/[NN].*.md` |

금지:
- 출처 없는 주장
- 비교 없는 비교 결론
- 저장 없이 종료

</validation>
