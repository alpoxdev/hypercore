# SSR And Hydration

> 라우트 SSR 모드와 hydration 안전성 규칙

---

## 핵심 규칙

서버 HTML과 클라이언트 첫 렌더가 달라질 수 있으면, 단순 경고가 아니라 설계 문제로 취급해야 합니다.

---

## 비타협 규칙

| 확인 항목 | 규칙 |
|------|------|
| 첫 렌더에서 `Date.now()`, random ID, locale 의존 텍스트, viewport 분기 같은 불안정 값을 직접 렌더함? | 안정화되지 않았다면 차단 |
| 브라우저 전용 위젯을 `ClientOnly`나 SSR 제한 없이 SSR에 렌더함? | 차단 |
| `ssr: false` 또는 `ssr: 'data-only'`를 fallback 전략 없이 사용함? | 차단 |
| 루트에서 SSR을 끄면서 `shellComponent` 동작을 이해하지 못함? | 차단 |

---

## 선호하는 해결 순서

1. 서버와 클라이언트 출력이 결정적으로 같게 만든다
2. 서버에서 한 번 계산해서 loader data로 hydration한다
3. 진짜 브라우저 전용 UI만 `ClientOnly`로 감싼다
4. 꼭 필요할 때만 route `ssr: 'data-only'` 또는 `ssr: false`를 쓴다

---

## 허용 패턴

- locale/timezone 민감 UI는 cookie 기반의 결정적 서버 값을 사용합니다
- hydration 후 클라이언트 환경을 cookie로 저장해 이후 SSR 요청에 활용할 수 있습니다
- 불안정한 위젯은 `ClientOnly`로 감쌀 수 있습니다
- SSR 모드가 렌더링 동작을 바꾸는 라우트에는 `pendingComponent`를 둡니다
- 루트 라우트에서 SSR을 줄여도 `shellComponent`는 HTML shell을 렌더한다는 점을 이해해야 합니다

---

## 리뷰 체크리스트

- hydration에 unsafe한 첫 렌더 출력이 없음
- `ClientOnly`가 무분별한 탈출구가 아니라 의도적으로 쓰였음
- 불안정 라우트의 `ssr` 모드가 명시적임
- SSR 축소 라우트의 fallback/shell 동작을 이해하고 있음
