# Safe Area 디자인 가이드

> iOS, Android, Foldable 디바이스의 Safe Area 사양서

---

## 1. iOS Safe Area

### 기본 Insets

| 요소 | 사이즈 | 비고 |
|------|--------|------|
| **상단 (노치)** | 47-59pt | 기기별 상이 |
| **하단 (Home Indicator)** | 34pt | 홈 버튼 없는 기기 |
| **좌측 (가로)** | 44pt | 노치 회피 |
| **우측 (가로)** | 44pt | 노치 회피 |

### Dynamic Island

| 요소 | 사이즈 |
|------|--------|
| **높이** | 36px |
| **너비 (Compact)** | 126px |
| **너비 (Expanded)** | 최대 371px |
| **아이콘** | 24px |
| **텍스트** | 15pt, line-height 22pt |

**프레젠테이션 모드:**
- **Compact**: 기본 축소 (진행 중인 활동)
- **Minimal**: 최소화 (배경 활동)
- **Expanded**: 확장 (상세 정보)

### 디바이스별 Safe Area

| 디바이스 | 상단 | 하단 |
|---------|------|------|
| **iPhone 15 Pro** | 59pt | 34pt |
| **iPhone 15** | 59pt | 34pt |
| **iPhone SE** | 20pt | 0pt |
| **iPad Pro** | 24pt | 20pt |

---

## 2. Android Safe Area

### Display Cutout 유형

| 유형 | 설명 |
|------|------|
| **Notch** | 상단 중앙 노치 |
| **Punch-hole** | 카메라 구멍 (좌상단/중앙) |
| **Waterfall** | 양측면 곡면 |

### System Bars 높이

| 요소 | 사이즈 | 비고 |
|------|--------|------|
| **Status Bar** | 24-48dp | 기기별 상이 |
| **Navigation Bar** | 48dp | 3버튼 네비게이션 |
| **Gesture Bar** | 24dp | 제스처 네비게이션 |

### Edge-to-Edge (Android 15+)

| 항목 | 사양 |
|------|------|
| **기본 동작** | SDK 35+ 앱은 강제 Edge-to-Edge |
| **시스템 바** | 반투명, 콘텐츠 뒤로 렌더링 |
| **필수 처리** | WindowInsets로 패딩 적용 |

### 제스처 영역

| 영역 | 사이즈 | 용도 |
|------|--------|------|
| **좌측 엣지** | 20dp | 뒤로가기 제스처 |
| **우측 엣지** | 20dp | 뒤로가기 제스처 |
| **하단** | 24dp | 홈 제스처 |

---

## 3. Foldable 디바이스

### 힌지 영역

| 디바이스 | 힌지 너비 | 힌지 높이 |
|---------|----------|----------|
| **Galaxy Z Fold** | 0px (접힘) | 전체 높이 |
| **Pixel Fold** | 약 12dp | 전체 높이 |

### Flex Mode (반접힘)

| 영역 | 용도 |
|------|------|
| **상단 (경사)** | 비주얼 콘텐츠 (영상, 이미지) |
| **하단 (평면)** | 컨트롤 (버튼, 슬라이더) |
| **힌지 근처** | 인터랙티브 요소 배치 금지 |

### 화면 상태

| 상태 | 설명 |
|------|------|
| **FLAT** | 완전히 펼침 |
| **HALF_OPENED** | 반접힘 (Flex Mode) |
| **Tabletop** | 가로 반접힘 (힌지 가로) |
| **Book** | 세로 반접힘 (힌지 세로) |

### 앱 연속성 요구사항

| 항목 | 요구사항 |
|------|----------|
| **화면 전환** | 커버 ↔ 메인 중단 없이 |
| **스크롤 위치** | 전환 시 유지 |
| **키보드 상태** | 전환 시 유지 |
| **전체 화면** | 레터박스 금지 |

---

## 4. 크로스 플랫폼

### React Native

| 요소 | 사양 |
|------|------|
| **라이브러리** | react-native-safe-area-context |
| **Hook** | useSafeAreaInsets() |
| **컴포넌트** | SafeAreaView, SafeAreaProvider |

### Web/PWA

| CSS 변수 | 설명 |
|---------|------|
| **safe-area-inset-top** | 상단 안전 영역 |
| **safe-area-inset-right** | 우측 안전 영역 |
| **safe-area-inset-bottom** | 하단 안전 영역 |
| **safe-area-inset-left** | 좌측 안전 영역 |

**Viewport 설정:** `viewport-fit=cover` 필수

---

## 5. 디자인 가이드라인

### 콘텐츠 배치

| 영역 | 배치 가능 | 주의사항 |
|------|----------|---------|
| **Safe Area 내부** | 모든 인터랙티브 요소 | - |
| **Safe Area 외부** | 배경색, 장식 이미지 | 터치 불가 |
| **노치 영역** | 상태 바 정보만 | 커스텀 UI 금지 |
| **홈 인디케이터** | 비움 | 스와이프 영역 |

### 터치 타겟

| 항목 | 사양 |
|------|------|
| **Safe Area 내부** | 44x44pt (iOS), 48x48dp (Android) |
| **하단 CTA** | Home Indicator 위 최소 8pt 여유 |
| **노치 근처** | 터치 감도 낮음, 중요 버튼 배치 금지 |

### 가로 모드

| 항목 | 사양 |
|------|------|
| **좌우 Inset** | 44pt (노치 회피) |
| **컨텐츠 중앙** | 좌우 Safe Area 내 배치 |
| **풀스크린 미디어** | Safe Area 무시 가능 |

---

## 6. 플랫폼별 체크리스트

### iOS
- [ ] safeAreaInsets 또는 safeAreaLayoutGuide 사용
- [ ] Home Indicator 영역 (34pt) 고려
- [ ] Dynamic Island 지원 시 Live Activities 통합
- [ ] 가로 모드 좌우 44pt 인셋 확인

### Android
- [ ] WindowInsetsCompat 사용 (하드코딩 금지)
- [ ] Edge-to-Edge 강제 적용 대응 (SDK 35+)
- [ ] Display Cutout 모드 설정
- [ ] 제스처 네비게이션 영역 고려

### Foldable
- [ ] WindowLayoutInfo 구독
- [ ] FoldingFeature.isSeparating 체크
- [ ] Tabletop/Book 자세별 UI 최적화
- [ ] 힌지 근처 중요 콘텐츠 배치 금지

### Web/PWA
- [ ] viewport-fit=cover 추가
- [ ] env(safe-area-inset-*) 사용
- [ ] Fallback 값 제공

---

## 참고

- [Apple Developer: Safe Area](https://developer.apple.com/documentation/uikit/uiview/safeareainsets)
- [Android: Display Cutout](https://developer.android.com/develop/ui/views/layout/display-cutout)
- [Android: Edge-to-Edge](https://developer.android.com/develop/ui/views/layout/edge-to-edge)
- [Samsung: Foldable Design](https://developer.samsung.com/one-ui/largescreen-and-foldable/)
- [MDN: CSS env()](https://developer.mozilla.org/en-US/docs/Web/CSS/env)
