# PM 리더 PRD 인사이트

> Marty Cagan, Shreyas Doshi, Lenny Rachitsky, Kevin Yien

---

## Marty Cagan / SVPG

### Discovery vs Documentation
- PRD 자체는 문제가 아님 -- Discovery 이후 커뮤니케이션 도구로서는 유용
- **PRD가 Discovery를 대체하면 문제**: "검증되지 않은 가정의 문서화"에 불과
- 원격 근무 확산으로 팀들이 진정한 Product Discovery 대신 PRD에 과도하게 의존
- Discovery 없는 PRD는 엔지니어의 혁신 잠재력을 "거세(neuter)"하는 결과

### Revisiting the Product Spec
전통적 PRD의 문제: "작성에 너무 오래 걸리고, 거의 읽히지 않으며, 필요한 세부사항을 제공하지 못함"

**대안:** 고충실도 프로토타입(High-Fidelity Prototype)이 진정한 제품 명세
- 사용자 경험 전체 표현
- 소프트웨어 동작의 정확한 표현
- 다중 이해관계자 대응
- 단일 마스터 표현

### PRD 4대 핵심 섹션
1. **Purpose (목적)**: 왜 이것을 만드는가
2. **Features (기능)**: 무엇을 만드는가 ("What", not "How")
3. **Release Criteria (출시 기준)**: 언제 출시할 수 있는가
4. **Rough Timing (대략적 일정)**: 스케치 수준의 타임라인

### Opportunity Assessment
90%의 경우 무거운 PRD 대신 **기회 평가(Opportunity Assessment)**로 충분:
1. 이것이 어떤 비즈니스 목표를 지원하는가?
2. 문제를 가지고 있는 고객이 누구인가?
3. 성공을 어떻게 알 수 있는가?
4. 가장 큰 리스크는 무엇인가?

---

## Shreyas Doshi (Stripe, Twitter, Google)

### Good PM vs Great PM의 PRD 차이

| Good PM | Great PM |
|---------|----------|
| 상세하고 명쾌한 PRD 작성 | **반복적으로(iteratively)** PRD 작성 |
| 팀이 PRD에 크게 의존 | 엔지니어링/디자인이 PRD에 블로킹되지 않음 |
| 2개월간 "완벽한 스펙" 후 전달 | "충분한(just enough)" 요구사항으로 병렬 진행 |

**핵심 인사이트:**
- "비범한 제품에서는 모든 요구사항을 사전에 필요한 수준의 세부사항으로 표현하는 것이 불가능하다"
- PM-Design-Engineering 간 협업적 발견 프로세스를 만들어야 함
- 디자인이 탐색을 시작하고 엔지니어링이 아키텍처를 구상할 수 있는 "just enough" 요구사항 제공

### PRD에 반드시 포함할 것
- **사용 지표 추적 방법**: "이 기능이 어떻게 사용되는지 이해하기 위한 메트릭"
- PRD는 항상 엔지니어링이 구축 중인 내용을 반영해야 함
- PRD 변경은 불가피하며, 이를 관리하는 프로세스가 중요

---

## Lenny Rachitsky

### PRD 작성 핵심
- **짧고 간결한 형식** 강조
- **솔루션보다 문제 정의에 우선순위**
- 실제 작성된 PRD와 1-Pager 예시 공개
- Confluence에서 공식 템플릿으로 채택됨

### Lenny의 1-Pager 구조
전체 PRD 대신 1-페이지 요약으로 시작하는 접근법 권장. 필요시 확장.

---

## Kevin Yien (Stripe, Square, Mutiny)

### 5단계 PRD 프로세스
1. **초안** → 2. **문제 검토** → 3. **솔루션 검토** → 4. **출시 검토** → 5. **출시**

### 핵심 특징

**Non-Goals 섹션:**
범위 제한을 명확히 -- 무엇을 만들지 않을지 정의. AI 에이전트 시대에 특히 중요.

**"둘레 그리기(Perimeter Drawing)":**
Shape Up과 유사하게 솔루션을 적절한 추상화 수준에서 유지. 엔지니어링/디자인 판단 여지 보존. 과도한 상세는 오히려 혁신을 저해.

**Contributor Review 섹션:**
"아무도 동의하지 않은 것을 만드는" 실패 방지. 이해관계자 정렬 문서화.

**"쓰기(writing)는 대규모 명확성(clarity at scale)"** -- PM의 핵심 역량

---

## 출처

- https://www.svpg.com/discovery-vs-documentation/
- https://www.svpg.com/revisiting-the-product-spec/
- https://www.svpg.com/assessing-product-opportunities/
- https://www.cimit.org/documents/20151/228904/How%20To%20Write%20a%20Good%20PRD.pdf
- https://shreyasdoshi.com/good-product-managers-great-product-managers/
- https://shreyasdoshi.typepad.com/main/2008/01/how-to-deal-wit.html
- https://www.lennysnewsletter.com/p/prds-1-pagers-examples
- https://www.lennysnewsletter.com/p/my-favorite-templates-issue-37
- https://www.atlassian.com/software/confluence/templates/lennys-product-requirements
- https://almanac.io/docs/template-product-requirements-documentby-kevinyien-14ca95049c0a56c42842e34153d6ea72
- https://www.lennysnewsletter.com/p/unorthodox-pm-wisdom-kevin-yien
