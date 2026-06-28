# PRD 섹션 레퍼런스

`prd.md`를 작성하거나 갱신할 때 이 reference를 사용합니다.

근거 기반: 아래 섹션 집합은 PRD 출처 12개를 검토하고 기능명세서, 유저플로우, 와이어프레임 출처와 비교한 로컬 조사 보고서 [`../../../.hypercore/research/002-prd-package-layered-artifacts.md`](../../../.hypercore/research/002-prd-package-layered-artifacts.md)에 기반합니다.

## 안정적인 기본 섹션 집합

조사한 여러 PRD 가이드에서 공통으로 수렴한 최소 섹션은 다음과 같습니다.

- 개요와 상태
- 문제와 목표
- 사용자와 유스케이스
- 범위와 비목표
- 안정적인 ID가 있는 요구사항
- 메트릭과 성공 기준
- 가정, 제약, 리스크, 의존성
- 오픈 질문
- 관련 후속 산출물: `feature-spec.md`, `user-flow.md`, `wireframe.md`, `diagram.md`, `sources.md`
- 변경 이력

정당한 경우에만 추가할 선택 섹션:

- 검토한 대안 또는 옵션
- 출시 기준
- 리뷰/미팅 목표
- 출시/readiness 계획

근거:

- Atlassian은 상위 맥락, 가정, 사용자 스토리, 질문, 명시적 비범위를 강조합니다. 출처: [Atlassian PRD guide](https://www.atlassian.com/agile/requirements)
- Atlassian의 product requirements template은 objective, success metrics, assumptions, user stories, open questions를 추적합니다. 출처: [Atlassian product requirements template](https://www.atlassian.com/software/confluence/templates/product-requirements)
- ProductPlan은 release-complete capability, use case, constraints, dependencies를 중심으로 PRD를 설명합니다. 출처: [ProductPlan PRD glossary](https://www.productplan.com/glossary/product-requirements-document)
- Aha!는 구현을 과도하게 지시하지 않으면서 좋은 해법을 유도할 만큼의 맥락을 강조합니다. 출처: [Aha! PRD template guide](https://www.aha.io/roadmapping/guide/templates/create/prd)
- Productboard와 Miro는 outcome, success measure, out-of-scope 결정, constraints, dependencies, risks, stakeholders를 강조합니다. 출처: [Productboard PRD glossary](https://www.productboard.com/glossary/product-requirements-document/), [Miro PRD template](https://miro.com/templates/prd/)
- Pendo는 goals, success metrics, out-of-scope items, open questions, product usage measurement를 추가합니다. 출처: [Pendo PRD template](https://www.pendo.io/de-de/product-led/artifacts/product-requirements-document-prd-template/)

## 섹션별 질문

### 개요와 상태

- 이 이니셔티브 이름은 무엇인가?
- 누가 책임지는가?
- 현재 상태는 무엇인가?
- 목표 마일스톤이나 출시 시점은 언제인가?

### 문제와 목표

- 지금 어떤 사용자/비즈니스 문제가 있는가?
- 왜 지금 해야 하는가?
- 성공하면 어떤 결과가 달라져야 하는가?

### 사용자와 유스케이스

- 누가 영향을 받는가?
- 어떤 핵심 작업/시나리오가 중요한가?
- 이 유스케이스를 뒷받침하는 근거는 무엇인가?

### 범위와 비목표

- 이번 작업에 포함되는 것은 무엇인가?
- 의도적으로 포함하지 않는 것은 무엇인가?
- 후속 작업으로 미루는 것은 무엇인가?

### 요구사항

- 어떤 제품 동작이 반드시 있어야 하는가?
- 후속 산출물이 사용할 요구사항 ID는 무엇인가?
- 제품 레벨에서 완료를 정의하는 수락 기준은 무엇인가?
- 어떤 디자인, 사용자 스토리, 티켓이 이 요구사항을 더 명확하게 하는가?

### 메트릭과 성공 기준

- 성공을 어떻게 측정할 것인가?
- 어떤 선행 지표와 결과 지표가 중요한가?
- 메인 지표가 좋아져도 악화되면 안 되는 guardrail metric이 있는가?

### 가정, 제약, 리스크, 의존성

- 이 계획이 성립하려면 무엇이 참이어야 하는가?
- 전달을 막거나 효과를 낮출 수 있는 것은 무엇인가?
- 어떤 팀, 시스템, 결정에 의존하는가?

### 오픈 질문

- 아직 해결되지 않은 것은 무엇인가?
- 어떤 질문이 기능명세서, 유저플로우, 와이어프레임 세부화를 막는가?
- 어떤 조사, 결정, 검증이 추가로 필요한가?

### 관련 후속 산출물

- `feature-spec.md`가 모든 must-have PRD 요구사항을 다루는가?
- `user-flow.md`가 모든 사용자-facing 기능 동작을 다루는가?
- `wireframe.md`가 모든 사용자-facing 플로우 화면/상태를 다루는가?
- `diagram.md`, `diagram.svg`, `preview.html`이 최신인가?

### 선택: 검토한 대안 또는 옵션

- 의미 있는 대안은 무엇이었는가?
- 왜 현재 방향을 선택했는가?

### 선택: 출시 기준

- 출시 전에 반드시 충족되어야 하는 조건은 무엇인가?
- 어떤 readiness, reliability, rollout gate가 남아 있는가?

### 변경 이력

- 무엇이 바뀌었는가?
- 언제 바뀌었는가?
- 왜 바뀌었는가?
