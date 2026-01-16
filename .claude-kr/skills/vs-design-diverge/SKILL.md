---
name: vs-design-diverge
description: Verbalized Sampling (VS)으로 고엔트로피 프론트엔드 인터페이스 생성. Mode Collapse 방지, 독창적 디자인 구현.
---

<context>

**목적:** Mode Collapse (모드 붕괴) 방지, 고품질 프로덕션 프론트엔드 생성

**원리:** Verbalized Sampling (VS) - 전형적(P ≈ 0.95) 디자인을 피하고 Low-T (낮은 전형성) 방향 선택

</context>

---

<workflow>

## 작업 흐름

```
Phase 0: 컨텍스트 수집
  ↓ (AskUserQuestion으로 4개 차원 파악)
Phase 1: 전형적 디자인 언어화
  ↓ (P ≈ 0.95 기준선 명시, 선택 금지)
Phase 2: Long-Tail 샘플링
  ↓ (3개 방향 + T-Score 정당화)
Phase 3: Low-T 방향 선택
  ↓ (최저 T-Score + Guardrails 통과)
Phase 4: 구현
  ↓ (프로덕션급 코드)
Phase 5: Surprise 검증
  ↓ (AI 전형 디자인인가? → 리팩토링)
```

### Phase 0: 컨텍스트 수집

**AskUserQuestion 도구로 다음 차원 파악:**

| 차원 | 질문 예시 |
|------|-----------|
| **감정 톤** | "신뢰감", "날카로운", "유쾌한", "고급스러운" 중 어느 분위기? |
| **타겟 청중** | 누가 볼까? 기술 수준은? 기대치는? |
| **참고점 / 반참고점** | 벤치마킹 대상? 명시적으로 피할 스타일? |
| **비즈니스 맥락** | UI가 해결하는 문제? 사용 시나리오? |

**추가 신호:**
- 기존 코드: 스타일 패턴, 색상 체계, 컴포넌트 규칙 추출
- 프롬프트: landing page, dashboard, portfolio, SaaS 등 키워드 파싱
- 후속 질문: 단순 프롬프트도 깊이 탐색

충분한 컨텍스트 확보 후 Phase 1 진행.

### Phase 1: 전형적 디자인 언어화

**최고 확률(P ≈ 0.95) 디자인 명시:**

AI-slop 마커 예시:
- Inter/Roboto/System 폰트
- 둥근 파란/보라 버튼
- 표준 F-패턴 레이아웃
- 흰 배경 + 그라데이션 강조
- 일반적인 Hero 섹션 + 스톡 이미지

**이 기준선은 선택하지 않음.**

### Phase 2: Long-Tail 샘플링

**3개 방향 + T-Score (전형성 점수, 0~1.0) 부여:**

| 방향 | T-Score | 특징 |
|------|---------|------|
| **A** | ≈ 0.7 | 모던/깔끔, 안전함 |
| **B** | ≈ 0.4 | 독특함/개성 (특정 니치 스타일) |
| **C** | < 0.2 | 실험적/대담 (고엔트로피, 예상 외) |

**T-Score 정당화 필수:** 각 방향이 왜 그 점수인지, 구체적 디자인 선택 근거 명시.

### Phase 3: Low-T 방향 선택

**최저 T-Score 선택 (조건 만족 시):**
1. Phase 0의 기능 요구사항
2. Quality Guardrails 모두 통과

의도적이고 신중한 선택, 우연이 아님.

</workflow>

---

<guardrails>

## 품질 기준

실험적 디자인도 아래 원칙 만족 필수. 위반 시 T-Score 상향 조정.

| 원칙 | 설명 |
|------|------|
| **시각적 위계** | 명확한 우선순위 (1st → 2nd → 3rd) |
| **대비 & 가독성** | 배경 대비 텍스트 가독 (WCAG AA 최소) |
| **내적 일관성** | 디자인 자체 논리 따름 (무작위 ❌) |
| **기능적 명확성** | 상호작용 요소 인식 가능, affordance 명확 |

</guardrails>

---

<anti_patterns>

## 실패 패턴

| 패턴 | 증상 | 검증 |
|------|------|------|
| **우연한 디자인** | 의도 없는 차별화, 무작위성 | "왜 이 색상/폰트/레이아웃?" → 답변 가능해야 함 |
| **프랑켄슈타인 스타일** | 비호환 미학 혼합, 통일성 부재 | "이 디자인의 개성을 한 문장으로?" → 설명 가능해야 함 |

</anti_patterns>

---

<aesthetics>

## 프론트엔드 미학 가이드라인 (VS-Enhanced)

**역전 원칙:** "명백한" 선택은 확률 질량 과다 → 낮은 확률, 높은 임팩트 대안 고려 (맥락에 맞을 때).

### 타이포그래피

| 분류 | 내용 |
|------|------|
| ❌ **AI-slop** | Inter, Roboto, Arial, System fonts, Space Grotesk (기본 사용) |
| ✅ **Low-T** | 개성 강한 Display 폰트 + 세련된 예상 외 본문 폰트. Variable fonts, 특이한 굵기. |
| **맥락 의존** | Brutalist 포트폴리오 → 산업적 산세리프 / 럭셔리 브랜드 → 세련된 세리프 |

### 색상 & 테마

| 원칙 | 설명 |
|------|------|
| ✅ **불균등 분포** | 응집력 있지만 "부조화-yet-아름다운" 팔레트 |
| ✅ **CSS Variables** | 체계적 테마 관리 |
| ✅ **텍스처 우선** | 평면 색상보다 노이즈, 조명 효과 (맥락 적합 시) |

### 공간 구성

| 조건 | 접근 |
|------|------|
| **표준 그리드 (P=0.9)** | 비대칭, 겹침, 대각선 흐름, 편집 스타일 여백 (P=0.1) 고려 |
| **단, 데이터 중심 UI** | 대시보드, 테이블 → 기존 그리드 필요 (유용성 우선) |

### 모션

| 원칙 | 설명 |
|------|------|
| ✅ **Micro-delights** | 순차적 나타남, 스크롤 바인딩 변환, 커스텀 easing |
| ❌ **무목적 모션** | 모든 애니메이션은 목적 필수 |

</aesthetics>

---

<frameworks>

## AIDA 프레임워크 (조건부 적용)

**설득/전환 목표 UI (랜딩 페이지, 마케팅 사이트, 제품 쇼케이스)에만 적용:**

| 단계 | 목표 | 디자인 적용 |
|------|------|------------|
| **A**ttention (주목) | 스크롤 멈춤, 즉각 시각 임팩트 | 대담한 타이포, 예상 외 이미지, 강렬한 색상 대비 |
| **I**nterest (관심) | 호기심 유발, 탐색 유도 | 점진적 정보 공개, 시각 스토리텔링, 고유 가치 강조 |
| **D**esire (욕구) | 감정 연결, 원하게 만들기 | 사회적 증거, 혜택 시각화, 열망 이미지, 마이크로 인터랙션 |
| **A**ction (행동) | 전환 유도, 명확한 다음 단계 | 고대비 CTA, 마찰 감소, 긴급성 단서 (적절 시) |

### 적용 조건

| 적용 ✅ | 미적용 ❌ |
|---------|----------|
| 랜딩/마케팅 페이지 | 대시보드, 데이터 중심 UI (유용성 우선) |
| 제품 런칭 페이지 | 문서/콘텐츠 중심 사이트 (가독성 우선) |
| 클라이언트 유치용 포트폴리오 | 내부 도구 (효율성 우선) |

**VS + AIDA 통합:** AIDA 각 단계에 Low-T 미학 적용. 전형적 Hero → Attention 실패 / 예측 가능한 CTA → Action 실패. AIDA = "무엇", VS = "어떻게".

</frameworks>

---

<implementation>

## 구현 기준

| 기준 | 설명 |
|------|------|
| **프로덕션급** | 기능적, 접근성(A11y), 성능 보장 |
| **복잡도-전형성 균형** | Low-T 디자인 → 구현 복잡도 비례 증가 (품질 유지) |
| **복잡성 거부 불가** | 비전 단순화 금지, 뛰어난 창작물 추구 |

</implementation>

---

<validation>

## 최종 검증

배포 전 체크리스트:

1. **의도성**: 모든 주요 디자인 결정 정당화 가능?
2. **일관성**: 디자인이 자체 내적 논리 따름?
3. **Guardrails**: 위계, 가독성, 일관성, 명확성 유지?
4. **Surprise**: AI 생성 디자인 중 눈에 띄는가?

**목표:** "Surprise Score" 최대화 + "Production Quality" 유지. 의도적 파격.

</validation>

---

<examples>

## 실전 예시

### Phase 2: T-Score 정당화

```markdown
**Direction A (T ≈ 0.7): 모던 미니멀**
- Inter 폰트, 흰 배경, 파란 버튼
- 전형적 이유: 2020년대 SaaS 표준 패턴, 높은 확률

**Direction B (T ≈ 0.4): Brutalist 스타일**
- Space Mono 폰트, 격자 배경, 각진 블랙 버튼
- 전형성 낮음: 특정 니치, 비주류 선택

**Direction C (T < 0.2): 네오-바로크**
- Fraunces Display 폰트, 불규칙 레이아웃, 애니메이션 그라디언트
- 극도로 낮은 확률: 웹에서 거의 보지 못한 스타일
```

### 타이포그래피 코드

```css
/* ❌ AI-slop */
font-family: 'Inter', system-ui, sans-serif;

/* ✅ Low-T (Brutalist 포트폴리오) */
@import url('https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&display=swap');
font-family: 'Space Mono', monospace;
font-variation-settings: 'wght' 650;

/* ✅ Low-T (럭셔리 브랜드) */
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@300;500&display=swap');
font-family: 'Cormorant Garamond', serif;
letter-spacing: 0.05em;
```

### 색상 시스템

```css
/* ❌ AI-slop (균등 분포) */
:root {
  --primary: #3b82f6; /* 파란색 */
  --secondary: #a855f7; /* 보라색 */
  --accent: #10b981; /* 초록색 */
}

/* ✅ Low-T (불균등, 응집력) */
:root {
  --dominant: #0a0908; /* 거의 검정 (60%) */
  --support: #8d99ae; /* 무채색 블루 (30%) */
  --punch: #ef233c; /* 강렬한 빨강 (10%) */
  --texture: url('data:image/svg+xml,...'); /* 노이즈 오버레이 */
}
```

### AIDA + Low-T 통합

```tsx
// Hero Section (Attention 단계 + Low-T)
<section className="hero">
  <h1 style={{
    fontFamily: 'Fraunces',
    fontSize: 'clamp(3rem, 10vw, 8rem)',
    fontVariationSettings: '"SOFT" 100, "WONK" 1',
    background: 'linear-gradient(135deg, #0a0908, #ef233c)',
    backgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
  }}>
    파격적 제품명
  </h1>
  {/* 예상 외 이미지 처리 */}
</section>

// CTA (Action 단계 + Low-T)
<button style={{
  background: '#ef233c',
  color: '#0a0908',
  border: '2px solid #0a0908',
  padding: '1.5rem 3rem',
  fontSize: '1.25rem',
  fontWeight: 700,
  clipPath: 'polygon(5% 0, 100% 0, 95% 100%, 0 100%)', // 비대칭
  transition: 'clip-path 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
}}>
  시작하기 →
</button>
```

</examples>
