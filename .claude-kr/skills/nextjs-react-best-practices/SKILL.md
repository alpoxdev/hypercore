---
name: nextjs-react-best-practices
description: Vercel Engineering의 React와 Next.js 성능 최적화 가이드. React 컴포넌트, Next.js 페이지 작성/리뷰/리팩토링 시 최적 성능 패턴 보장. React 컴포넌트, Next.js 페이지, 데이터 페칭, 번들 최적화, 성능 개선 작업에 트리거.
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
---

# Next.js React 베스트 프랙티스

Vercel에서 관리하는 React와 Next.js 애플리케이션 종합 성능 최적화 가이드. 8개 카테고리, 45개 규칙 포함. 영향도별 우선순위로 자동 리팩토링과 코드 생성 가이드 제공.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| **컴포넌트 작성** | React 컴포넌트, Next.js 페이지 신규 작성 |
| **데이터 페칭** | 클라이언트/서버 사이드 데이터 페칭 구현 |
| **코드 리뷰** | 성능 이슈 검토 |
| **리팩토링** | 기존 React/Next.js 코드 개선 |
| **최적화** | 번들 크기, 로딩 시간 최적화 |

</when_to_use>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 접두사 |
|---------|---------|--------|--------|
| 1 | Waterfall 제거 | **CRITICAL** | `async-` |
| 2 | 번들 크기 최적화 | **CRITICAL** | `bundle-` |
| 3 | 서버 사이드 성능 | HIGH | `server-` |
| 4 | 클라이언트 데이터 페칭 | MEDIUM-HIGH | `client-` |
| 5 | Re-render 최적화 | MEDIUM | `rerender-` |
| 6 | 렌더링 성능 | MEDIUM | `rendering-` |
| 7 | JavaScript 성능 | LOW-MEDIUM | `js-` |
| 8 | 고급 패턴 | LOW | `advanced-` |

</categories>

---

<rules>

## 빠른 참조

### 1. Waterfall 제거 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `async-defer-await` | await를 실제 사용 지점으로 이동 |
| `async-parallel` | 독립 작업은 Promise.all() 사용 |
| `async-dependencies` | 부분 의존성은 better-all 사용 |
| `async-api-routes` | Promise 일찍 시작, 늦게 await |
| `async-suspense-boundaries` | Suspense로 콘텐츠 스트리밍 |

### 2. 번들 크기 최적화 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `bundle-barrel-imports` | 직접 import, barrel 파일 회피 |
| `bundle-dynamic-imports` | 무거운 컴포넌트는 next/dynamic 사용 |
| `bundle-defer-third-party` | 분석/로깅은 hydration 후 로드 |
| `bundle-conditional` | 기능 활성화 시에만 모듈 로드 |
| `bundle-preload` | hover/focus 시 preload로 체감 속도 향상 |

### 3. 서버 사이드 성능 (HIGH)

| 규칙 | 설명 |
|------|------|
| `server-cache-react` | React.cache()로 요청별 중복 제거 |
| `server-cache-lru` | LRU 캐시로 요청 간 캐싱 |
| `server-serialization` | 클라이언트로 전달 데이터 최소화 |
| `server-parallel-fetching` | 컴포넌트 재구성으로 병렬 페칭 |
| `server-after-nonblocking` | after()로 비차단 작업 실행 |

### 4. 클라이언트 데이터 페칭 (MEDIUM-HIGH)

| 규칙 | 설명 |
|------|------|
| `client-swr-dedup` | SWR로 자동 요청 중복 제거 |
| `client-event-listeners` | 전역 이벤트 리스너 중복 제거 |

### 5. Re-render 최적화 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `rerender-defer-reads` | 콜백 전용 상태는 구독 안 함 |
| `rerender-memo` | 비싼 작업은 memoized 컴포넌트로 추출 |
| `rerender-dependencies` | effect에 원시값 의존성 사용 |
| `rerender-derived-state` | 파생 boolean 구독, raw 값 구독 회피 |
| `rerender-functional-setstate` | 안정적 콜백용 함수형 setState |
| `rerender-lazy-state-init` | 비싼 초기값은 함수로 useState에 전달 |
| `rerender-transitions` | 비긴급 업데이트는 startTransition |

### 6. 렌더링 성능 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `rendering-animate-svg-wrapper` | SVG 대신 wrapper div 애니메이션 |
| `rendering-content-visibility` | 긴 리스트는 content-visibility 사용 |
| `rendering-hoist-jsx` | 정적 JSX 컴포넌트 외부로 추출 |
| `rendering-svg-precision` | SVG 좌표 정밀도 감소 |
| `rendering-hydration-no-flicker` | 인라인 스크립트로 클라이언트 전용 데이터 처리 |
| `rendering-activity` | show/hide는 Activity 컴포넌트 사용 |
| `rendering-conditional-render` | 조건부 렌더링은 &&가 아닌 삼항 연산자 |

### 7. JavaScript 성능 (LOW-MEDIUM)

| 규칙 | 설명 |
|------|------|
| `js-batch-dom-css` | CSS 변경은 클래스나 cssText로 그룹화 |
| `js-index-maps` | 반복 조회용 Map 빌드 |
| `js-cache-property-access` | 루프에서 객체 속성 캐싱 |
| `js-cache-function-results` | 함수 결과를 모듈 레벨 Map에 캐싱 |
| `js-cache-storage` | localStorage/sessionStorage 읽기 캐싱 |
| `js-combine-iterations` | 여러 filter/map을 하나의 루프로 결합 |
| `js-length-check-first` | 비싼 비교 전 배열 길이 먼저 체크 |
| `js-early-exit` | 함수에서 조기 반환 |
| `js-hoist-regexp` | RegExp 생성을 루프 밖으로 |
| `js-min-max-loop` | sort 대신 루프로 min/max |
| `js-set-map-lookups` | O(1) 조회용 Set/Map 사용 |
| `js-tosorted-immutable` | 불변성용 toSorted() 사용 |

### 8. 고급 패턴 (LOW)

| 규칙 | 설명 |
|------|------|
| `advanced-event-handler-refs` | ref에 이벤트 핸들러 저장 |
| `advanced-use-latest` | 안정적 콜백 ref용 useLatest |

</rules>

---

<patterns>

## 핵심 패턴

### ✅ Waterfall 제거

```typescript
// ❌ 순차 실행, 3번 왕복
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()

// ✅ 병렬 실행, 1번 왕복
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

### ✅ 번들 최적화

```tsx
// ❌ 전체 라이브러리 import (1583개 모듈, ~2.8초)
import { Check, X, Menu } from 'lucide-react'

// ✅ 직접 import (3개 모듈만)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'

// ✅ Next.js 13.5+ 자동 최적화
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react']
  }
}
```

### ✅ 서버 캐싱

```typescript
import { cache } from 'react'

// 요청별 중복 제거
export const getCurrentUser = cache(async () => {
  const session = await auth()
  if (!session?.user?.id) return null
  return await db.user.findUnique({ where: { id: session.user.id } })
})
```

### ✅ Re-render 최적화

```tsx
// ❌ items가 의존성, 매번 재생성
const addItems = useCallback((newItems: Item[]) => {
  setItems([...items, ...newItems])
}, [items])

// ✅ 안정적 콜백, 재생성 없음
const addItems = useCallback((newItems: Item[]) => {
  setItems(curr => [...curr, ...newItems])
}, [])
```

</patterns>

---

<usage>

## 사용법

**상세 규칙 및 예시:**

```
rules/async-parallel.md
rules/bundle-barrel-imports.md
rules/_sections.md
```

각 규칙 파일 포함 내용:
- 중요한 이유 설명
- ❌ 잘못된 코드 예시 + 설명
- ✅ 올바른 코드 예시 + 설명
- 추가 컨텍스트 및 참조

**전체 컴파일 문서:** `AGENTS.md`

</usage>

---

<references>

## 참고 자료

1. [React 공식 문서](https://react.dev)
2. [Next.js 공식 문서](https://nextjs.org)
3. [SWR](https://swr.vercel.app)
4. [better-all](https://github.com/shuding/better-all)
5. [node-lru-cache](https://github.com/isaacs/node-lru-cache)
6. [Next.js Package Import 최적화](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
7. [Vercel Dashboard 2배 빠르게 만들기](https://vercel.com/blog/how-we-made-the-vercel-dashboard-twice-as-fast)

</references>
