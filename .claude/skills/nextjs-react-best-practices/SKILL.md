---
name: nextjs-react-best-practices
description: Vercel Engineering의 React와 Next.js 성능 최적화 가이드. React 컴포넌트, Next.js 페이지 작성/리뷰/리팩토링 시 최적 성능 패턴 보장. React 컴포넌트, Next.js 페이지, 데이터 페칭, 번들 최적화, 성능 개선 작업에 트리거.
license: MIT
metadata:
  author: vercel
  version: "1.0.0"
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md
@../../instructions/multi-agent/coordination-guide.md
@../../instructions/multi-agent/execution-patterns.md

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

<parallel_agent_execution>

## 병렬 에이전트 실행 (ULTRAWORK MODE)

### 기본 원칙

| 원칙 | 실행 방법 | 기대 효과 |
|------|----------|----------|
| **PARALLEL** | 단일 메시지에서 여러 Tool 동시 호출 | 5-15배 속도 향상 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | 컨텍스트 격리, 품질 향상 |
| **SMART MODEL** | 복잡도에 따라 haiku/sonnet/opus 선택 | 비용 최적화 |

**핵심 룰:**
```typescript
// ❌ 순차 실행 (느림)
Task(...) // 60초 대기
Task(...) // 60초 대기
// 총 120초

// ✅ 병렬 실행 (빠름)
Task(...) // 단일 메시지에서
Task(...) // 동시 호출
// 총 60초 (가장 긴 작업 기준)
```

### Phase별 에이전트 활용

| Phase | 작업 | 에이전트 | 모델 | 병렬 실행 |
|-------|------|---------|------|----------|
| **1. 코드베이스 분석** | 기존 패턴 탐색 | explore | haiku | ✅ (여러 영역) |
| **1. 코드베이스 분석** | 성능 이슈 식별 | explore | haiku | ✅ (규칙별) |
| **2. 규칙 적용** | Waterfall 제거 | implementation-executor | sonnet | ✅ (독립 파일) |
| **2. 규칙 적용** | 번들 최적화 | implementation-executor | sonnet | ✅ (독립 파일) |
| **2. 규칙 적용** | Re-render 최적화 | implementation-executor | sonnet | ✅ (독립 파일) |
| **3. 검증** | 보안 검토 | code-reviewer | opus | ✅ (다중 관점) |
| **3. 검증** | 성능 검토 | code-reviewer | opus | ✅ (다중 관점) |
| **4. 수정** | 린트/타입 오류 | lint-fixer | sonnet | ❌ (순차) |

### 에이전트별 역할

| 에이전트 | 모델 | 용도 | 병렬 가능 |
|---------|------|------|----------|
| **explore** | haiku | 규칙 위반 코드 탐색, 패턴 분석 | ✅ |
| **implementation-executor** | sonnet | 규칙 적용, 리팩토링 실행 | ✅ |
| **code-reviewer** | opus | 성능/보안/접근성 검토 | ✅ |
| **lint-fixer** | sonnet | 적용 후 오류 수정 | ❌ |

### 실전 패턴

**패턴 1: 독립 파일 병렬 최적화**

```typescript
// 목표: 여러 컴포넌트에 re-render 최적화 규칙 적용

// ❌ 순차 실행 (느림)
Edit("ComponentA.tsx", ...) // 대기...
Edit("ComponentB.tsx", ...) // 대기...
Edit("ComponentC.tsx", ...) // 대기...

// ✅ 병렬 실행 (빠름)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`ComponentA.tsx에 다음 규칙 적용:
     - rerender-functional-setstate
     - rerender-memo
     - rerender-defer-reads`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`ComponentB.tsx에 다음 규칙 적용:
     - rerender-functional-setstate
     - rerender-memo
     - rerender-defer-reads`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`ComponentC.tsx에 다음 규칙 적용:
     - rerender-functional-setstate
     - rerender-memo
     - rerender-defer-reads`)
```

**패턴 2: Waterfall 제거 + 번들 최적화 동시**

```typescript
// 독립적인 카테고리 병렬 처리
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`src/routes/users/ 전체에 Waterfall 제거:
     - async-parallel: 독립 fetch는 Promise.all()
     - async-defer-await: await를 실제 사용 지점으로`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`src/components/ 전체에 번들 최적화:
     - bundle-barrel-imports: lucide-react 직접 import
     - bundle-dynamic-imports: Chart 컴포넌트 next/dynamic`)

Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`src/lib/ 전체에 서버 성능:
     - server-cache-react: React.cache()로 중복 제거
     - server-serialization: 클라이언트 데이터 최소화`)
```

**패턴 3: 다중 관점 검증**

```typescript
// 코드 수정 완료 후 병렬 검토
Task(subagent_type="code-reviewer", model="opus",
     prompt=`성능 검토:
     - Waterfall 제거 확인
     - 불필요한 re-render
     - N+1 쿼리`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`번들 크기 검토:
     - barrel import 사용 여부
     - 무거운 라이브러리 dynamic import
     - tree-shaking 가능 여부`)

Task(subagent_type="code-reviewer", model="opus",
     prompt=`타입 안정성 검토:
     - any 사용 금지
     - 명시적 return type
     - 타입 가드 적절성`)
```

**패턴 4: 코드베이스 탐색 병렬**

```typescript
// 프로젝트 초기 분석 시 여러 영역 동시 탐색
Task(subagent_type="explore", model="haiku",
     prompt="Waterfall 패턴 탐색: 순차 await, Promise.all() 누락")

Task(subagent_type="explore", model="haiku",
     prompt="barrel import 탐색: lucide-react, @radix-ui 등")

Task(subagent_type="explore", model="haiku",
     prompt="re-render 이슈 탐색: useCallback 의존성, useMemo 누락")

Task(subagent_type="explore", model="haiku",
     prompt="서버 캐싱 누락: React.cache() 미사용 중복 호출")
```

### Model Routing

| 복잡도 | 모델 | 작업 예시 | 비용 | 속도 |
|--------|------|----------|------|------|
| **LOW** | haiku | 패턴 탐색, 규칙 위반 검색 | 💰 | ⚡⚡⚡ |
| **MEDIUM** | sonnet | 규칙 적용, 리팩토링 실행 | 💰💰 | ⚡⚡ |
| **HIGH** | opus | 복잡한 성능 분석, 아키텍처 검토 | 💰💰💰 | ⚡ |

**모델 명시 예시:**
```typescript
Task(subagent_type="explore", model="haiku", ...)           // 빠르고 저렴
Task(subagent_type="implementation-executor", model="sonnet", ...)
Task(subagent_type="code-reviewer", model="opus", ...)      // 고품질 검토
```

### 체크리스트

작업 시작 전 확인:

- [ ] 독립적인 파일/컴포넌트 → 병렬 executor 실행
- [ ] 여러 카테고리 규칙 적용 → 카테고리별 병렬
- [ ] 코드베이스 탐색 필요 → 영역별 explore 병렬
- [ ] 다중 관점 검증 필요 → code-reviewer 병렬
- [ ] 복잡도별 모델 선택 (haiku/sonnet/opus)
- [ ] 10개 이상 파일 → 배치 처리 고려

**적극적으로 에이전트 활용. 혼자 하지 말 것.**

</parallel_agent_execution>

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

**전체 컴파일 문서:** `PARALLEL_AGENTS.md`

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
