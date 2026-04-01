# Reliable Search Guide

**목적**: 검색 결과의 최신성과 신뢰성 보장, 중복 검색 방지 및 효율적 검색 전략

**참조**: @../context-optimization/redundant-exploration-prevention.md

---

## 중복 검색 방지 (Duplicate Search Prevention)

**목적**: 동일 쿼리 반복 실행 방지, 컨텍스트 윈도우 절약, Rate Limiting 회피

### 핵심 규칙

| 규칙 | 실행 |
|------|------|
| **같은 쿼리 금지** | 동일 쿼리 반복 실행 금지 (WebSearch + SearXNG 같은 쿼리 금지) |
| **이전 결과 확인** | 검색 전 이전 검색 결과 확인 |
| **유사 쿼리 병합** | 유사한 쿼리는 한 번에 실행 |
| **검색 종료 조건** | 목표 정보 획득, 교차 검증 완료, 검색 깊이 도달 |

### 검색 전 체크리스트

```text
✓ 이 쿼리를 이미 실행했는가?
  → YES: 이전 결과 활용 (재검색 금지)
  → NO: 검색 실행

✓ 이전 결과로 충분한가?
  → YES: 검색 중단, 다음 단계 진행
  → NO: 다른 각도의 쿼리 생성

✓ 다른 각도의 쿼리가 필요한가?
  → YES: 새로운 관점 쿼리 생성
  → NO: 이전 결과 활용

✓ 같은 채널에 같은 쿼리를 보내는가?
  → YES: 금지 (WebSearch + SearXNG 같은 쿼리)
  → NO: 허용
```

### 허용/금지 패턴

```typescript
// ❌ 금지: 같은 쿼리 반복
WebSearch({ query: "React best practices 2026" })
// ... 작업 ...
WebSearch({ query: "React best practices 2026" })  // 중복!

// ❌ 금지: 다른 채널에 같은 쿼리
WebSearch({ query: "Next.js 15 features" })
SearXNG({ query: "Next.js 15 features" })  // 중복!

// ✅ 올바름: 다른 각도 쿼리
WebSearch({ query: "React best practices 2026" })
WebSearch({ query: "React performance optimization 2026" })  // 다른 각도

// ✅ 올바름: 채널별 특화 쿼리
WebSearch({ query: "Next.js 15 features overview" })  // 개요
SearXNG({ query: "Next.js 15 breaking changes" })     // 상세 변경사항
```

---

## 검색 결과 캐싱 전략 (Search Result Caching)

**목적**: 검색 결과 재사용, 동일 세션 내 재검색 방지, 컨텍스트 절약

### 캐싱 규칙

| 규칙 | 실행 |
|------|------|
| **파일로 저장** | 장기 세션 시 검색 결과를 파일로 저장 |
| **요약 형식** | 전문 저장 대신 요약 형식으로 컨텍스트 절약 |
| **캐시 활용** | 동일 세션 내 재검색 시 캐시 파일 확인 |
| **주제별 분류** | 주제별 디렉토리 구조로 관리 |

### 저장 위치 및 형식

```markdown
저장 위치: .claude/research/[topic]/

파일 구조:
- sources.md: URL + 발행일 + 요약
- findings.md: 핵심 발견사항
- queries.md: 실행한 쿼리 목록 (중복 방지)
```

### 캐시 파일 예시

```markdown
# .claude/research/react-2026/sources.md

## 검색 쿼리 기록
- "React best practices 2026" (WebSearch, 2026-02-06)
- "React performance optimization 2026" (SearXNG, 2026-02-06)

## 출처 목록

### S등급 (공식 문서)
- https://react.dev/blog/2026/01/react-19-release
  - 발행일: 2026-01-15
  - 요약: React 19 정식 릴리스, Server Components 안정화
  - 핵심: Actions, useOptimistic, use() hook

### A등급 (주요 기술 미디어)
- https://vercel.com/blog/react-19-adoption
  - 발행일: 2026-01-20
  - 요약: React 19 도입 가이드, 마이그레이션 전략
  - 핵심: 점진적 도입, 호환성 확인

---

# .claude/research/react-2026/findings.md

## 핵심 발견사항 (2026-02-06)

### React 19 주요 변경사항
1. Server Components 기본 지원
2. Actions API 안정화
3. useOptimistic hook 추가
4. use() hook으로 Promise/Context 처리

### 성능 최적화 패턴
1. React Compiler 사용 (자동 메모이제이션)
2. Suspense Boundary 전략적 배치
3. Streaming SSR 최적화

### 교차 검증 완료
- Server Components 안정화: 2개 소스 확인 (react.dev, vercel.com)
- React Compiler: 3개 소스 확인 (공식 문서, Meta blog, Vercel blog)
```

### 캐시 활용 흐름

```typescript
// ✅ 올바른 흐름: 캐시 확인 → 검색
// 1. 캐시 확인
Read(".claude/research/react-2026/queries.md")
// → "React best practices 2026" 이미 검색함

// 2-1. 캐시 결과 활용
Read(".claude/research/react-2026/findings.md")
// → 핵심 발견사항 확인

// 2-2. 추가 정보 필요 시 다른 각도 쿼리
WebSearch({ query: "React security best practices 2026" })
// → 새로운 각도 (보안)
```

---

## 검색 범위 사전 결정 (Search Scope Pre-Planning)

**목적**: 검색 시작 전 범위와 깊이 결정, 무분별한 검색 방지

### 검색 계획 단계

| 단계 | 결정 사항 | 예시 |
|------|----------|------|
| **1. 정보 유형** | 공식 문서 vs 블로그 vs 벤치마크 | 공식 문서: Context7 (Claude Code) / WebFetch (Codex/기타), 벤치마크: WebSearch |
| **2. 검색 깊이** | Quick(3쿼리) / Medium(5쿼리) / Deep(10쿼리) | 개요: Quick, 완전 분석: Deep |
| **3. 우선순위 채널** | 환경별: Context7/WebFetch → GitHub → WebSearch | 라이브러리 문서 우선 |
| **4. 종료 조건** | 목표 달성 / 교차 검증 완료 / 깊이 도달 | 2+ 소스 교차 검증 완료 시 종료 |

### 검색 깊이 기준

| 깊이 | 쿼리 수 | 용도 | 예시 |
|------|---------|------|------|
| **Quick** | 1-3개 | 개요 파악, 빠른 확인 | "React 19란?", "주요 변경사항" |
| **Medium** | 4-6개 | 표준 조사, 비교 분석 | "React vs Vue 2026", "성능 비교" |
| **Deep** | 7-10개 | 완전 분석, 심층 연구 | "React 생태계 전체", "마이그레이션 전략" |

### 검색 시작 전 체크리스트

```text
✓ 필요한 정보 유형은?
  - 공식 문서: Context7 MCP (Claude Code) 또는 WebFetch (Codex/기타) → 라이브러리 문서 직접 조회
  - 코드 예시: GitHub MCP → 리포지토리/코드 검색
  - 최신 동향: WebSearch/SearXNG → 블로그/미디어
  - 벤치마크: WebSearch → 성능 비교 자료

✓ 검색 깊이는?
  - Quick: 개요만 필요
  - Medium: 비교 분석 필요
  - Deep: 완전한 이해 필요

✓ 우선순위 채널은? (환경에 따라 다름)
  Claude Code: Context7 → GitHub → WebSearch/SearXNG
  Codex/기타: WebSearch/WebFetch → GitHub → SearXNG

✓ 검색 종료 조건은?
  - 목표 정보 획득
  - 교차 검증 완료 (2+ 소스)
  - 검색 깊이 도달
```

### 채널별 우선순위 전략

```typescript
// ✅ 올바른 흐름: 우선순위대로 검색 (Claude Code 환경 예시)
// Codex/기타 환경에서는 Phase 1을 WebFetch로 대체

// Phase 1: Context7 (라이브러리 문서, Claude Code 전용)
Context7_resolve_library_id({ libraryName: "react" })
Context7_query_docs({
  libraryId: "react",
  query: "Server Components"
})
// → 공식 문서로 기본 정보 확보

// Phase 2: GitHub (코드 예시, 이슈)
GitHub_search_repositories({
  query: "react server components production",
  sort: "stars"
})
// → 실제 구현 사례 확인

// Phase 3: WebSearch (최신 동향, 블로그)
WebSearch({
  query: "React Server Components production experience 2026"
})
// → 실전 경험, 문제 해결 사례 확인

// 종료 조건 확인:
// ✓ 목표 정보 획득 (Server Components 개념, 구현, 경험)
// ✓ 교차 검증 완료 (공식 문서 + GitHub + 블로그)
// → 검색 종료
```

### 검색 종료 조건

| 조건 | 기준 | 처리 |
|------|------|------|
| **목표 정보 획득** | 필요한 정보 모두 확보 | 즉시 검색 종료 |
| **교차 검증 완료** | 핵심 주장 2+ 소스 확인 | 추가 검색 불필요 |
| **검색 깊이 도달** | Quick(3) / Medium(5) / Deep(10) | 종료 조건 재평가 |
| **중복 결과 반복** | 새로운 정보 없음 (3회 연속) | 검색 종료 |

---

## 날짜 인식 검색 (Date-Aware Search)

| 규칙 | 실행 |
|------|------|
| **연도 포함** | 모든 검색 쿼리에 현재 연도 포함 (예: "React best practices 2026") |
| **기간 필터** | SearXNG: `time_range=year`, WebSearch: 쿼리에 연도 추가 |
| **한국어 쿼리** | "2026년 기준", "최신" 키워드 포함 |
| **영어 쿼리** | "2025-2026", "latest", "current" 키워드 포함 |

```typescript
// ✅ 올바른 검색 쿼리
WebSearch({ query: "AI agent frameworks comparison 2026" })
WebSearch({ query: "SaaS 시장 트렌드 2026년" })

// ❌ 연도 없는 검색 (오래된 결과 반환 위험)
WebSearch({ query: "AI agent frameworks comparison" })
```

---

## 출처 신뢰도 등급

| 등급 | 소스 유형 | 예시 |
|------|----------|------|
| **S (최고)** | 공식 문서, 논문, 1차 데이터 | docs.prisma.io, arxiv.org, 정부 통계 |
| **A (높음)** | 공식 블로그, 주요 기술 미디어, 검증된 벤치마크 | engineering.fb.com, infoq.com, GitHub Releases |
| **B (보통)** | 개인 기술 블로그, 커뮤니티, Stack Overflow | dev.to, medium.com, reddit.com |
| **C (낮음)** | AI 생성 의심 콘텐츠, 오래된 문서, 미검증 주장 | 날짜 없는 블로그, SEO 스팸 |

### 신뢰도 검증 규칙

| 체크 | 기준 | 처리 |
|------|------|------|
| **날짜 확인** | 발행일 12개월 이내 | 초과 시 "⚠ 오래된 자료" 표기 |
| **저자 확인** | 실명/소속 확인 가능 | 익명 → 등급 1단계 하향 |
| **교차 검증** | 핵심 주장은 2개+ 소스 확인 | 단일 소스 주장 → "미검증" 표기 |
| **이해충돌** | 벤더 자사 제품 주장 | "벤더 출처" 명시, 독립 소스 교차 확인 |

---

## 검색 쿼리 패턴

### 다각도 쿼리 생성

```
기본: "[주제] [연도]"
심층: "[주제] benchmark performance [연도]"
비교: "[주제A] vs [주제B] comparison [연도]"
한국어: "[주제] 최신 동향 [연도]년"
실패 사례: "[주제] pitfalls mistakes lessons learned"
```

### 채널별 최적 쿼리

| 채널 | 쿼리 전략 |
|------|----------|
| **WebSearch** | 연도 포함, 영어+한국어 병렬 |
| **SearXNG** | `time_range=year` + 연도 키워드 |
| **Firecrawl** | 공식 문서 URL 직접 지정 |
| **Jina Reader** | `WebFetch('https://r.jina.ai/{URL}')` — JS 렌더링 클린 MD 변환 |
| **GitHub** | `created:>YYYY-01-01` 필터, stars 정렬 |

---

## Smart Tier Fallback

환경에 따라 사용 가능한 도구가 다릅니다:

```
Claude Code 환경:
  Tier 1 (MCP, ToolSearch로 감지):
    SearXNG MCP  → 메타검색 (246+ 엔진, 시간 필터 지원)
    Firecrawl MCP → 페이지→MD 변환, 사이트 구조 파악
    GitHub MCP   → 코드/리포/이슈/릴리스 검색
    Context7 MCP → 라이브러리 문서 즉시 조회

Codex / Cursor / 기타 환경:
  Tier 1 (내장, 항상 가용):
    WebSearch → 웹 검색 (연도 키워드 필수)
    WebFetch  → 페이지 직접 읽기 + 공식 문서 조회
    gh CLI    → GitHub API (Bash via explore)

공통:
  Tier 2 (내장, 항상 가용):
    WebSearch → 웹 검색 (연도 키워드 필수)
    WebFetch  → 페이지 직접 읽기
    Jina Reader → WebFetch('https://r.jina.ai/{URL}') 클린 마크다운 변환
    gh CLI    → GitHub API (Bash via explore)

  Tier 3: Playwright → SPA/JS 렌더링 필요 시 (crawler skill)
```

**MCP는 main agent가 직접 실행** (subagent는 MCP 도구 사용 불가)

| MCP 도구 | 용도 | 미설치 시 폴백 |
|----------|------|--------------|
| `firecrawl_map/scrape/crawl` | 사이트 구조/페이지 수집 | Jina Reader → WebFetch (페이지별) |
| SearXNG `web_search` | 246+ 엔진 메타검색 | WebSearch (내장) |
| `search_repositories/code/issues` | GitHub 리포/코드/이슈 | `gh search` (Bash) |
| `resolve-library-id` + `query-docs` | 라이브러리 문서 조회 | Jina Reader → WebFetch (직접) |

### MCP 감지 (Phase 0 공통)

```
ToolSearch("firecrawl") → Firecrawl 활성화
ToolSearch("searxng")   → SearXNG 활성화
ToolSearch("github")    → GitHub MCP 활성화
ToolSearch("context7")  → Context7 활성화
```

---

## Jina Reader (`r.jina.ai`)

**용도:** URL → 클린 마크다운 변환 (JS 렌더링 지원, 광고/네비 제거)

| 특성 | 설명 |
|------|------|
| **엔드포인트** | `https://r.jina.ai/{URL}` |
| **호출 방법** | `WebFetch('https://r.jina.ai/{URL}', '{프롬프트}')` |
| **장점** | JS 렌더링, 클린 MD, 광고/네비 자동 제거, 무료 |
| **한계** | 검색 기능 없음 (URL 필수), 대량 크롤링 비적합 |

### 활용 시나리오

| 시나리오 | 사용 |
|----------|------|
| **WebFetch 실패** | JS 렌더링 필요 페이지 → Jina Reader 폴백 |
| **Firecrawl 미설치** | 개별 페이지 클린 MD 변환 |
| **공식 문서 읽기** | SPA 기반 문서 사이트 (React, Vue 등) |
| **블로그/미디어** | 광고 제거된 본문만 추출 |

### 사용 패턴

```typescript
// ✅ 기본: URL을 클린 마크다운으로 변환
WebFetch('https://r.jina.ai/https://react.dev/reference/react/use', '핵심 API 사용법 추출')

// ✅ WebFetch 실패 시 Jina 폴백
WebFetch('https://docs.example.com/guide')  // → 빈 결과 (JS 렌더링 필요)
WebFetch('https://r.jina.ai/https://docs.example.com/guide', '가이드 내용 추출')  // → 클린 MD

// ✅ Firecrawl 미설치 시 개별 페이지 대안
WebFetch('https://r.jina.ai/https://prisma.io/docs/orm/prisma-schema', 'Prisma 스키마 문법 추출')

// ❌ 검색 용도로 사용 (검색은 WebSearch/SearXNG 사용)
WebFetch('https://r.jina.ai/react hooks tutorial')  // 잘못된 사용
```

### 폴백 체인 (페이지 읽기)

```
Firecrawl scrape → Jina Reader → WebFetch (직접) → Playwright (최후 수단)
```

---

## 수집 후 검증

| 단계 | 검증 |
|------|------|
| **날짜 체크** | 핵심 소스 발행일 확인, 12개월 초과 시 표기 |
| **등급 분류** | 각 소스에 S/A/B/C 등급 부여 |
| **교차 검증** | 핵심 주장 2개+ 소스 확인 |
| **편향 체크** | 벤더/광고 소스 식별, 독립 소스 보완 |

### researcher 에이전트 프롬프트 필수 포함

```
"검색 시 현재 연도(YYYY) 포함, 12개월 이내 자료 우선.
 각 출처: URL + 발행일 + 소스 유형(공식/블로그/커뮤니티).
 핵심 주장은 2개+ 소스로 교차 검증.
 중복 검색 방지: 이전 쿼리 확인, 같은 쿼리 재실행 금지."
```

---

## 검색 효율성 모니터링

### 검색 통계 추적

**세션 내 검색 패턴 모니터링**

```markdown
# 검색 통계 (세션 내)

## 검색 쿼리 기록
- "React best practices 2026" (WebSearch, 2026-02-06 10:30)
- "React performance optimization 2026" (SearXNG, 2026-02-06 10:35)
- "Next.js 15 features" (Context7, 2026-02-06 10:40)

## 검색 효율성 지표
| 지표 | 목표 | 현재 | 상태 |
|------|------|------|------|
| **중복 검색률** | < 5% | 0% | ✅ 우수 |
| **검색 깊이** | Quick(3) | 3회 | ✅ 정상 |
| **교차 검증** | 2+ 소스 | 3개 | ✅ 완료 |
| **캐시 활용률** | > 30% | 0% | ⚠️ 신규 주제 |

## 경고
✅ 중복 검색 없음
✅ 검색 깊이 적절
```

### 검색 품질 체크리스트

```text
✓ 중복 검색 방지
  - [ ] 이전 쿼리 확인
  - [ ] 같은 쿼리 재실행 금지
  - [ ] 유사 쿼리 병합

✓ 검색 범위 계획
  - [ ] 정보 유형 결정
  - [ ] 검색 깊이 설정
  - [ ] 우선순위 채널 선택

✓ 결과 검증
  - [ ] 날짜 확인 (12개월 이내)
  - [ ] 등급 분류 (S/A/B/C)
  - [ ] 교차 검증 (2+ 소스)

✓ 캐싱 전략
  - [ ] 검색 결과 저장
  - [ ] 요약 형식 작성
  - [ ] 캐시 활용 확인
```
