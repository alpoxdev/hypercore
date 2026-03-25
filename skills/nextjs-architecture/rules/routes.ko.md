# 라우트와 파일 규칙

> 공식 App Router 구조, 특수 파일, 세그먼트 규칙.

---

## 기본 구조

```text
app/
├── layout.tsx
├── page.tsx
├── dashboard/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── loading.tsx
│   ├── error.tsx
│   ├── not-found.tsx
│   ├── _components/
│   └── _lib/
└── api/
    └── webhooks/
        └── route.ts
```

## 세그먼트 파일 의미

| 파일 | 목적 |
|------|------|
| `page.tsx` | 라우트 세그먼트의 UI 진입점 |
| `layout.tsx` | 세그먼트와 자식들의 공통 UI 셸 |
| `template.tsx` | navigation 때 다시 마운트되는 layout 유사 래퍼 |
| `loading.tsx` | 세그먼트 Suspense fallback |
| `error.tsx` | 세그먼트 에러 경계. Client Component여야 함 |
| `not-found.tsx` | 세그먼트 404 UI |
| `route.ts` | HTTP 전용 Route Handler |

## 라우트가 아닌 구조화 규칙

| 패턴 | 의미 |
|------|------|
| `(marketing)` | URL에 영향 없는 route group |
| `_components/` | route segment가 되지 않는 private folder |
| `_lib/` | 세그먼트 로컬 헬퍼용 private folder |

라우트가 되면 안 되는 구현 파일은 `_` private folder에 colocate 하세요.

## 강한 규칙

| 확인 항목 | 규칙 |
|-----------|------|
| 같은 세그먼트에 `route.ts`와 `page.tsx`가 공존 | 차단 |
| 이미 `app/`가 담당하는 기능을 `pages/` 아래로 추가 | 명시적 요청 없으면 차단 |
| route group을 URL 변경 수단처럼 사용 | 차단 |
| 사용자용 loading/error 상태가 필요한데 경계 파일이 전혀 없음 | 경고 |
| 내부 헬퍼를 private folder 대신 공개 세그먼트로 노출 | 차단 |

## 배치 가이드

- 페이지 UI는 `page.tsx`
- 세그먼트 공통 UI는 `layout.tsx`
- route 전용 헬퍼는 `_` private folder
- HTTP 응답이 필요한 경우에만 `route.ts`
- URL은 유지하고 구조만 나누려면 route group 사용

## 에러/로딩 경계

- `error.tsx`는 Client Component여야 합니다
- `loading.tsx`는 세그먼트 단위 스트리밍 fallback에 적합합니다
- 블로킹 작업이 트리 깊은 곳에 있으면, 세그먼트 루트 `loading.tsx`만 믿지 말고 더 가까운 `<Suspense>`를 두는 편이 낫습니다
- 리소스가 없을 때는 `notFound()`와 `not-found.tsx` 조합을 사용합니다

## Mixed Router 저장소

- untouched `pages/` 라우트에 App Router 파일 규칙을 억지로 적용하지 않습니다
- 레거시 호환성이 필요하지 않다면 새 `pages/api/*`보다 App Router `route.ts` 또는 Server Action이 자연스러운지 먼저 봅니다

## 리뷰 체크리스트

- 특수 파일이 올바른 세그먼트에 있음
- `route.ts` / `page.tsx` 충돌 없음
- route group과 private folder 사용 의도가 명확함
- 필요한 loading/error/not-found 경계가 존재함
