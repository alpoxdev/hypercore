# PRD 안티패턴 & 평가 기준

> Scopilot AI, PM Prompt, Addy Osmani, Parallel HQ, Carnegie Mellon SEI

---

## 안티패턴

### 작성 단계

| # | 안티패턴 | 문제 | 해결 |
|---|----------|------|------|
| 1 | **모호한 요구사항** | "빠른 로딩", "좋은 UX" 측정 불가 | "3G에서 2초 내 로딩", "3클릭 이내 완료" |
| 2 | **기능 과적재** | 스코프 크리프, 지연, 비대한 제품 | MoSCoW/RICE 우선순위화, Appetite 설정 |
| 3 | **이해관계자 배제** | 나중에 비용 큰 분쟁 | 초기부터 다기능 팀 참여, Contributor Review |
| 4 | **솔루션 편향** | 문제 정의 전 솔루션 결정, 최적 솔루션 배제 | 문제 공간 먼저 정의, Opportunity Solution Tree |
| 5 | **엣지 케이스 무시** | 사용자 불만, 제품 갭 | Happy Path + Alternative Flow + Edge Case |
| 6 | **성공 지표 부재** | 성공 여부 판단 불가, Landing Review 불가 | 현재값 → 목표값 KPI + 측정 방법 |
| 7 | **정적 문서화** | 빠르게 구식화, 개발 현실과 괴리 | 정기 리뷰 + 변경 이력 + Living Document |
| 8 | **기술 요구사항 누락** | 개발자 혼란, 잘못된 구현 | API, 통합, 보안, 성능 요구사항 명시 |
| 9 | **부실한 User Stories** | 개발 중 오해, 범위 논쟁 | "As a [user], I want to [action] so that [benefit]" |
| 10 | **체크박스용 PRD** | 형식만 갖춘 비효과적 문서 | 결정 중심 문서, Discovery First |

### AI 시대 특유

| 안티패턴 | 설명 | 해결 |
|----------|------|------|
| **LLM으로 긴 PRD 생성** | 내용 없이 길기만 함, 가독성 급락 | 간결하고 결정 중심 작성, 인간 편집 필수 |
| **모호한 프롬프트** | "멋진 걸 만들어" -- 앵커링 포인트 없음 | 구체적 목표, AC, 제약조건 명시 |
| **계층 없는 장문 컨텍스트** | 50페이지 덤프 → 모델 이해 실패 | Phase 분해, 모듈형 구조 |
| **인간 리뷰 생략** | 테스트 통과 ≠ 올바른 코드 | 각 Phase 완료 후 인간 검토 |
| **Vibe Coding과 프로덕션 혼동** | 빠른 프로토타이핑 ≠ 엔지니어링 | 명세 기반 검증 프로세스 |
| **Non-Goals 누락** | AI가 범위 외 기능 임의 추가 | 하지 않을 것 명시적 기술 |
| **속도/품질 긴장 무시** | 생성 속도가 검증 능력 초과 | 단계별 체크포인트 |

---

## 품질 평가 기준

### 종합 평가 체크리스트

| 항목 | 기준 | 가중치 | 확인 방법 |
|------|------|--------|----------|
| **명확성** | 모호한 용어 없이 측정 가능 | 높음 | "빠른", "좋은" 등 형용사 검색 |
| **완전성** | 범위, 제약, AC, Non-Goals 포함 | 높음 | 섹션 체크리스트 대조 |
| **전략 정렬** | 비즈니스 목표/OKR과 직접 연결 | 높음 | "왜 지금?"에 답할 수 있는가 |
| **성공 메트릭** | 정량적 KPI + 현재값 → 목표값 | 높음 | 숫자 없는 목표 검색 |
| **사용자 중심** | 페르소나, JTBD, User Stories, AC | 중간 | 사용자 관점 서술 비율 |
| **우선순위** | MoSCoW/RICE 기반 명확한 순위 | 중간 | P0/P1 태그 존재 여부 |
| **가정 명시** | 검증되지 않은 가정 문서화 | 중간 | 가정 섹션 존재 여부 |
| **AI 실행 가능** | Phase 분해, Non-Goals, 체크포인트 | 중간 | Given-When-Then AC 비율 |
| **간결성** | 불필요한 내용 없이 결정 중심 | 낮음 | 전체 분량, 반복 내용 |
| **이해관계자 정렬** | 리뷰/사인오프 문서화 | 낮음 | Contributor Review 기록 |

### Carnegie Mellon SEI 연구 기반

- 소프트웨어 개발 비용의 **60-80%가 재작업**
- 효과적 요구사항 관리 시 **50-80% 결함 제거** 가능
- 요구사항 결함은 나중에 발견할수록 수정 비용 **기하급수적 증가**

### 좋은 PRD의 신호

| 신호 | 설명 |
|------|------|
| **읽힌다** | 팀원이 실제로 읽고 참조함 (Cagan: "거의 읽히지 않는" PRD는 실패) |
| **결정을 담는다** | "왜 A가 아닌 B를 선택했는가" 기록 (Linear: 거부된 대안 분석) |
| **변한다** | 개발 중 발견사항이 반영됨 (Living Document) |
| **짧다** | 필요한 것만 포함 (Lenny: 1-Pager로 시작) |
| **측정 가능하다** | 모든 목표에 숫자가 있음 (현재값 → 목표값) |
| **블로킹하지 않는다** | 팀이 PRD 없이도 병렬 진행 가능 (Doshi: "just enough") |

---

## 출처

- https://www.scopilot.ai/top-10-mistakes-to-avoid-when-writing-a-product-requirements-document/
- https://www.parallelhq.com/blog/how-to-write-product-requirements
- https://pmprompt.com/blog/prd-examples
- https://addyosmani.com/blog/good-spec/
- https://shreyasdoshi.com/good-product-managers-great-product-managers/
- https://www.svpg.com/revisiting-the-product-spec/
- https://www.lennysnewsletter.com/p/prds-1-pagers-examples
