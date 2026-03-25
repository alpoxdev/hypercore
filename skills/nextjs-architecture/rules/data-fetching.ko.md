# 데이터 페칭과 캐싱

> 서버 우선 읽기, 스트리밍, 캐시 의도, freshness 규칙.

---

## 권장 읽기 경로

- 가능하면 초기 페이지 데이터는 Server Component에서 가져옵니다
- 데이터를 쓰는 컴포넌트 가까이에서 읽습니다
- 서로 독립적인 읽기는 병렬화합니다
- 전체 라우트를 불필요하게 막지 말고 `loading.tsx` 또는 `<Suspense>`로 스트리밍합니다

## 중요한 런타임 사실

- 동일한 `fetch` 요청은 요청 트리 안에서 Next.js가 memoization 할 수 있습니다
- `cookies()`, `headers()`, request-time API, 명시적 uncached 데이터는 라우트를 dynamic 쪽으로 밀 수 있습니다
- layout이 uncached runtime data를 읽으면 같은 세그먼트 `loading.tsx`가 가려질 수 있으므로, 더 아래로 내리거나 더 가까운 `<Suspense>`로 감싸야 합니다

## 캐시 규칙

| 확인 항목 | 규칙 |
|-----------|------|
| 캐시 동작을 이해하지 못했거나 변경에 설명이 없음 | 차단 |
| request-time API 때문에 dynamic rendering이 우발적으로 발생함 | 차단 |
| uncached/request-time 데이터를 트리 상단에서 경계 없이 읽음 | 차단 |
| 반복되는 privileged read를 page 코드에 직접 둠 | 경고. DAL 또는 server-only helper 권장 |

## mutation 이후 freshness

mutation 뒤에는 UI가 어떻게 새 데이터를 보게 되는지 명시해야 합니다:

- `revalidatePath`
- `revalidateTag`
- fresh data를 다시 그리게 되는 redirect
- 또는 명확히 설명된 다른 전략

## 스트리밍 가이드

사용 기준:

- 세그먼트 단위 로딩은 `loading.tsx`
- 느리거나 dynamic한 하위 트리는 `<Suspense>`
- promise 전달 + React `use()`는 구조가 더 명확해질 때만 사용

## official-first 판단 순서

권장 우선순위:

1. 초기 데이터는 Server Component에서 읽기
2. privileged read는 server-only helper 또는 DAL
3. client-side fetching은 client-driven refresh, polling, browser-only state일 때만

## 리뷰 체크리스트

- 초기 읽기가 진짜 client-only 이유 없이 클라이언트로 내려가지 않았는지
- dynamic rendering 트리거가 의도적인지
- Suspense 또는 `loading.tsx`가 실제 블로킹 작업 가까이에 있는지
- mutation 뒤 freshness 경로가 명시적인지
