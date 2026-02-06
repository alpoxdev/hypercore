# Reliable Search Guide

**목적**: 검색 결과의 최신성과 신뢰성 보장

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
| **GitHub** | `created:>YYYY-01-01` 필터, stars 정렬 |

---

## Smart Tier Fallback

```
Tier 1 (MCP, ToolSearch로 감지):
  SearXNG MCP  → 메타검색 (246+ 엔진, 시간 필터 지원)
  Firecrawl MCP → 페이지→MD 변환, 사이트 구조 파악
  GitHub MCP   → 코드/리포/이슈/릴리스 검색
  Context7 MCP → 라이브러리 문서 즉시 조회

Tier 2 (내장, 항상 가용):
  WebSearch → 웹 검색 (연도 키워드 필수)
  WebFetch  → 페이지 직접 읽기
  gh CLI    → GitHub API (Bash via explore)

Tier 3: Playwright → SPA/JS 렌더링 필요 시 (crawler skill)
```

**MCP는 main agent가 직접 실행** (subagent는 MCP 도구 사용 불가)

| MCP 도구 | 용도 | 미설치 시 폴백 |
|----------|------|--------------|
| `firecrawl_map/scrape/crawl` | 사이트 구조/페이지 수집 | WebFetch (페이지별) |
| SearXNG `web_search` | 246+ 엔진 메타검색 | WebSearch (내장) |
| `search_repositories/code/issues` | GitHub 리포/코드/이슈 | `gh search` (Bash) |
| `resolve-library-id` + `query-docs` | 라이브러리 문서 조회 | WebFetch (직접) |

### MCP 감지 (Phase 0 공통)

```
ToolSearch("firecrawl") → Firecrawl 활성화
ToolSearch("searxng")   → SearXNG 활성화
ToolSearch("github")    → GitHub MCP 활성화
ToolSearch("context7")  → Context7 활성화
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
 핵심 주장은 2개+ 소스로 교차 검증."
```
