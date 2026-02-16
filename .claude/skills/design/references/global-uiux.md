# 글로벌 UI/UX 디자인 패턴 레퍼런스

> 글로벌(미국/서양) UI/UX 디자인의 핵심 철학, 주요 디자인 시스템, 최신 트렌드

---

## 1. 글로벌 디자인 철학

### 1.1 미니멀리즘 (Minimalism)

**핵심 원칙 - "Less is More":**
- 깔끔한 레이아웃, 충분한 여백, 제한된 컬러 팔레트
- 명확한 타이포그래피와 직관적인 네비게이션
- **Progressive Disclosure**: 핵심 기능만 먼저 노출

**2025 트렌드 - Minimalism 3.0 (Emotional Minimalism):**
- 부드러운 색상 전환, 미세한 텍스처, 표현적 타이포그래피
- 미니멀하면서도 감성적인 인터페이스 추구

### 1.2 화이트스페이스 활용

- 시각적 휴식을 제공하여 가독성 개선
- 콘텐츠 간 명확한 구분 생성
- 고급스럽고 전문적인 인상 전달

### 1.3 타이포그래피 계층

- **Display → Headline → Title → Body → Label** 순의 명확한 체계
- 볼드 타이포그래피로 시각 요소 대체
- 폰트 웨이트 변화로 정보 계층 표현

### 1.4 서양 vs 아시아 디자인 비교

| 특성 | 서양 (미국/유럽) | 아시아 (한국/중국/일본) |
|------|-----------------|---------------------|
| **정보 밀도** | 낮음 - 여백 중시 | 높음 - 콘텐츠 밀집 |
| **앱 철학** | 단일 기능 특화 | 슈퍼앱 (다기능 통합) |
| **네비게이션** | 심플, 단계적 | 복합적, 탭 다수 |
| **색상** | 절제된 팔레트 | 다채로운 색상 활용 |
| **문화 반영** | 개인주의 | 집단주의 - 커뮤니티/공유 |

---

## 2. 주요 디자인 시스템

### 2.1 Google Material Design 3 (M3 Expressive)

**최신 버전:** Material 3 Expressive (2025년 5월)

#### Dynamic Color
- 단일 소스 컬러에서 전체 팔레트 알고리즘 생성
- Primary, Secondary, Tertiary + Error/Warning 상태 컬러

#### 타이포그래피
- **5단계**: Display, Headline, Title, Body, Label
- 각 단계별 Large/Medium/Small 사이즈
- Variable Fonts 지원

#### Shape 시스템
- 5단계 둥근 정도: Extra-Small → Extra-Large
- M3 Expressive에서 **35개 새 Shape** 추가
- Shape Morphing 애니메이션

#### Motion
- Physics System: 물리 기반 모션
- Fluid Motion: 유동적 애니메이션

### 2.2 Apple Human Interface Guidelines (Liquid Glass)

**최신:** Liquid Glass (2025년 6월 WWDC)

**4대 핵심 원칙:**
1. **Clarity** - 쉬운 이해
2. **Deference** - 콘텐츠에 초점
3. **Depth** - 시각적 레이어로 계층 전달
4. **Consistency** - 플랫폼 간 일관성

**Liquid Glass 특징:**
- 투명도와 깊이: 유리의 광학적 특성 시뮬레이션
- 3 레이어 구조: Foreground / Mid-ground / Background
- 콘텐츠 우선: UI가 우아하게 후퇴

### 2.3 Microsoft Fluent 2

**4대 디자인 원칙:**
1. **Natural on Every Platform** - 플랫폼에 맞는 자연스러운 경험
2. **Built for Focus** - 산만함 최소화, 생산적 몰입
3. **One for All, All for One** - 포용적 디자인
4. **Unmistakably Microsoft** - 브랜드 정체성

**기술:** WCAG 2.1 준수, Fluent UI React 컴포넌트

### 2.4 IBM Carbon Design System

**3대 원칙:**
1. **Consistency** - 예측 가능성 → 신뢰
2. **Human-Centered** - 인간으로서 먼저 이해
3. **Essential** - 모든 요소에 목적, 절제된 디자인

### 2.5 Salesforce Lightning (SLDS 2)

- **Design Tokens**: 재사용 가능한 디자인 변수
- **CSS Custom Properties**: 구조와 비주얼 분리
- **UX 패턴**: Welcome Mat, Setup Assistant, Empty States

### 2.6 Atlassian Design System

**핵심 가치:**
- **Foundational**: 공통 문제 먼저 해결
- **Harmonious**: 빌딩 블록이 함께 작동
- **Empowering**: 복잡한 경험 구성 가능

---

## 3. 플랫폼별 가이드라인

### 3.1 Mobile App

| 항목 | iOS (Apple HIG) | Android (Material 3) |
|------|-----------------|---------------------|
| **네비게이션** | Tab Bar (하단) | Navigation Rail/Bar |
| **제스처** | Edge Swipe Back | Predictive Back |
| **디자인 언어** | Liquid Glass | M3 Expressive |
| **타이포** | SF Pro | Roboto / Google Sans |
| **터치 타겟** | 최소 44x44pt | 최소 48x48dp |

### 3.2 Web / Desktop

- 반응형 레이아웃 (Mobile-First)
- 키보드 네비게이션 완벽 지원
- 마우스 호버 상태 디자인
- 최소 클릭 타겟 24x24px

**브레이크포인트:**
```
Mobile: 360-480px | Tablet: 768px | Desktop: 1024-1440px+
```

### 3.3 SaaS / Enterprise

- **Progressive Disclosure**: 핵심 도구 우선
- **Smart Defaults**: AI 기반 예측 레이아웃
- 대량 데이터 테이블/차트 처리
- 역할 기반 접근 제어 (RBAC) UI

---

## 4. 최신 트렌드 (2024-2026)

### 4.1 AI 통합 UI

- **AI 기반 개인화**: 클릭 패턴, 사용 이력 분석
- **Generative UI**: AI가 동적 인터페이스 생성
- **대화형 디자인**: 화면 + 음성 명령 동시 지원

### 4.2 다크 모드

- 순수 검정 대신 소프트 블랙 (#121212)
- 채도 높은 색상 주의 (진동 현상)
- 라이트/다크 독립 테스트 필수
- **WCAG**: 일반 4.5:1, 큰 텍스트 3:1

### 4.3 모션 & 마이크로인터랙션

**4요소:**
1. **Trigger**: 사용자/시스템 액션
2. **Rules**: 발생 동작
3. **Feedback**: 시각적/청각적 피드백
4. **Loops & Modes**: 반복과 모드 변환

### 4.4 접근성 우선 (WCAG 2.2)

| 기준 | 레벨 | 내용 |
|------|------|------|
| **텍스트 대비** | AA | 일반 4.5:1, 큰 텍스트 3:1 |
| **Focus Appearance** | AA | 최소 2px, 3:1 대비 |
| **Target Size** | AA | 최소 24x24 CSS px |

---

## 5. 디자인 토큰 공통 구조

```
tokens/
├── color/ (primary, secondary, surface, error)
├── typography/ (font-family, size, weight, line-height)
├── spacing/ (4px 단위: 4, 8, 12, 16, 24, 32, 48, 64)
├── shape/ (border-radius, elevation)
├── motion/ (duration, easing, physics)
└── breakpoint/ (compact, medium, expanded)
```

---

## 6. 디자인 시스템 선택 가이드

| 용도 | 추천 시스템 | 이유 |
|------|-----------|------|
| **Android 앱** | Material Design 3 | 네이티브 통합, Dynamic Color |
| **iOS 앱** | Apple HIG | 플랫폼 일관성 |
| **Microsoft 생태계** | Fluent 2 | Office/Azure 통합 |
| **Enterprise B2B** | Carbon / SLDS | 대규모 데이터 특화 |
| **협업 도구** | Atlassian DS | 팀 생산성 패턴 |
| **크로스 플랫폼 웹** | Material Design 3 | 가장 넓은 가이드라인 |

---

## 참고 자료

- [Material Design 3](https://m3.material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Microsoft Fluent 2](https://fluent2.microsoft.design/)
- [IBM Carbon](https://carbondesignsystem.com/)
- [Salesforce Lightning](https://www.lightningdesignsystem.com/)
- [Atlassian Design](https://atlassian.design/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
