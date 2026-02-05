# AI 에이전트용 PRD 작성법

> Addy Osmani (Google), David Haberlah, GitHub Spec Kit, ChatPRD, Thoughtworks 기반

---

## Spec-Driven Development (GitHub, 2025.09~)

명세가 진실의 원천(source of truth)이 되어 AI 에이전트가 직접 실행하는 패러다임.

**GitHub Spec Kit 4단계:**

| 단계 | 설명 | 초점 |
|------|------|------|
| **Specify** | 무엇을 왜 만드는지 기술 | 사용자 경험, 성공 지표 |
| **Plan** | 스택, 아키텍처, 제약조건 | 기술 계획 |
| **Tasks** | 작고 테스트 가능한 청크로 분해 | 검증 가능한 단위 |
| **Implement** | 순차 구현, 단계별 검증 | 코드 생성 |

---

## Addy Osmani의 5대 원칙

### 1. 고수준 비전으로 시작
AI에게 상세 명세 생성을 맡기고 협업으로 정제. 간단한 목표 설명 → AI가 세부사항 작성.

### 2. 전문 PRD처럼 구조화
6개 핵심 영역 필수 포함 (GitHub 2,500+ 리포지토리 분석):

| 영역 | 내용 | 예시 |
|------|------|------|
| **Commands** | 실행 가능한 명령어 + 플래그 | `npm test`, `pytest -v` |
| **Testing** | 프레임워크, 파일 위치, 커버리지 | Jest, 80% coverage |
| **Project Structure** | 소스, 테스트, 문서 경로 | `src/`, `tests/`, `docs/` |
| **Code Style** | 선호 패턴을 코드 스니펫으로 | ESLint 규칙, 네이밍 컨벤션 |
| **Git Workflow** | 브랜치 네이밍, 커밋 형식, PR | `feat/`, conventional commits |
| **Boundaries** | 에이전트가 절대 하지 말아야 할 것 | "Never edit node_modules/" |

### 3. 모듈형 프롬프트로 분해
"지시의 저주" -- 동시 지시가 많으면 성능 저하. Frontier LLM은 약 150-200개 instruction까지 합리적 일관성 유지, 이후 급락.

**해결:** 300개 요구사항의 단일 문서 대신 5-6개 Phase x 30-50개 요구사항으로 분해.

### 4. 자체 검증과 제약 내장
3단계 경계 시스템:

```
ALWAYS DO:  "항상 커밋 전 테스트 실행", "네이밍 규칙 준수"
ASK FIRST:  DB 스키마 변경, 의존성 추가, CI/CD 수정
NEVER DO:   "비밀키 커밋 금지", "node_modules 수정 금지"
```

### 5. 테스트, 반복, 진화
마일스톤마다 테스트, 발견 시 명세 업데이트. 초기 명세서는 시작점.

---

## David Haberlah의 AI PRD 핵심 규칙 (2026)

| 규칙 | 설명 |
|------|------|
| **Non-Goals 필수** | AI는 "생략에서 추론" 불가 → "X를 구현하지 말 것" 명시 안 하면 임의 추가 |
| **원자적 User Stories** | 1 스토리 = 1 요구사항, 복합 스토리 금지 |
| **Given-When-Then AC** | 체크 가능한 Acceptance Criteria |
| **의존성 순서 Phase** | 기초 → 핵심 → 고급, 각 Phase에 테스트 체크포인트 |
| **기존 기능 보호** | "기존 X 기능에 영향 주지 말 것" 명시 |
| **코드 스니펫 패턴** | 텍스트 설명보다 코드 예시가 AI에게 효과적 |

---

## ChatPRD: Claude Code를 위한 PRD

**역할 분리:**
- PRD = "무엇을(What)" + "왜(Why)"
- CLAUDE.md = "어떻게(How)"

**필수 섹션:** Introduction, Problem Statement, Solution Overview, User Stories, Technical Requirements, Acceptance Criteria, Constraints

**Claude Code 4가지 기법:**
1. `@-mention`으로 회사 전략/사용자 연구/템플릿 등 전체 맥락 제공
2. 소크라테스식 질문 (문제 명확화, 솔루션 검증, 성공 지표, 제약 조건)
3. 다중 전략 병렬 생성 ("채팅 우선", "목록 우선", "균형형")
4. Sub-agent 다각 피드백 (엔지니어/임원/사용자 연구자 관점)

---

## Thoughtworks: 명세(Specification) vs PRD

| 문서 | 초점 | 대상 |
|------|------|------|
| **PRD** | 제품 요구사항 (사용자/비즈니스 관점) | 인간 정렬 |
| **Specification** | 외부 동작 명시적 정의 (input/output, 사전/사후 조건, 불변량) | AI 에이전트 실행 |

명세가 포함해야 할 것:
- Input/Output 매핑
- 사전/사후 조건
- 불변량, 제약조건
- 인터페이스 타입
- 통합 계약
- 순차 로직/상태 머신
- Given/When/Then 시나리오

**반구조화된 입력이 추론 성능을 크게 향상시키고 환각을 줄임.**

---

## 출처

- https://addyosmani.com/blog/good-spec/
- https://medium.com/@haberlah/how-to-write-prds-for-ai-coding-agents-d60d72efb797
- https://www.chatprd.ai/resources/PRD-for-Claude-Code
- https://ccforpms.com/advanced/write-prd
- https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- https://github.com/github/spec-kit
- https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices
- https://tessl.io/blog/from-code-centric-to-spec-centric
