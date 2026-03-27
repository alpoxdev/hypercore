# SEO Fundamentals Reference

**Purpose**: Core SEO knowledge for audit analysis. Load when evaluating findings against standards.

## E-E-A-T Framework

Google's quality evaluation framework:

| Pillar | Meaning | Signals |
|--------|---------|---------|
| **Experience** | First-hand knowledge of the topic | Personal anecdotes, original photos, case studies, "I tested this" language |
| **Expertise** | Credentials and deep knowledge | Author bio, credentials, detailed technical accuracy |
| **Authoritativeness** | Recognition from others | Quality backlinks, citations, mentions from authoritative sources |
| **Trustworthiness** | Reliability and transparency | HTTPS, clear contact info, privacy policy, accurate content, no deception |

Trustworthiness is the most important pillar. Without trust, E-E-A is meaningless.

## Core Web Vitals

| Metric | Full Name | Good | Needs Improvement | Poor |
|--------|-----------|------|-------------------|------|
| **LCP** | Largest Contentful Paint | < 2.5s | 2.5s – 4.0s | > 4.0s |
| **INP** | Interaction to Next Paint | < 200ms | 200ms – 500ms | > 500ms |
| **CLS** | Cumulative Layout Shift | < 0.1 | 0.1 – 0.25 | > 0.25 |

### LCP Optimization

- Optimize largest image/text block above the fold
- Use `next/image` or `<img loading="eager">` for hero images
- Preload critical resources (`<link rel="preload">`)
- Minimize server response time (TTFB)

### INP Optimization

- Break up long tasks (> 50ms)
- Use `requestIdleCallback` or `setTimeout` for non-critical work
- Minimize main thread blocking from JavaScript
- Optimize event handlers

### CLS Optimization

- Set explicit `width` and `height` on images and videos
- Reserve space for dynamic content (ads, embeds)
- Avoid inserting content above existing content
- Use CSS `contain` for layout-heavy components

## Ranking Factors (Priority Order)

1. **Quality content** — relevant, comprehensive, original, satisfies search intent
2. **Backlinks** — quality over quantity, relevant domains, natural link profile
3. **Page experience** — Core Web Vitals, mobile-friendly, HTTPS, no intrusive interstitials
4. **Search intent match** — content type matches what users expect (informational, transactional, navigational)
5. **Technical SEO** — crawlable, indexable, fast, structured data
6. **AI citability** — structured for AI extraction, statistics, clear definitions (GEO factor)
7. **Freshness** — updated content for time-sensitive queries; 3-month threshold for AI citation
8. **Entity authority** — topical clusters, consistent expertise across multiple content pieces (replacing domain authority)

## Schema Markup Types

Common JSON-LD schemas to recommend:

| Type | When to Use |
|------|-------------|
| `Article` | Blog posts, news articles |
| `Organization` | Company pages, about pages |
| `Person` | Author pages, team member profiles |
| `FAQPage` | FAQ sections, Q&A content |
| `Product` | E-commerce product pages |
| `Review` | Review content, testimonials |
| `BreadcrumbList` | Navigation breadcrumbs |
| `WebSite` | Site-level search box |
| `LocalBusiness` | Local business pages |
| `HowTo` | Tutorial, step-by-step content |

### JSON-LD Template

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title",
  "author": {
    "@type": "Person",
    "name": "Author Name"
  },
  "datePublished": "2026-01-15",
  "dateModified": "2026-03-20",
  "description": "Article description",
  "image": "https://example.com/image.jpg"
}
</script>
```

## Keyword Strategy Principles

- **Search intent first**: Match content type to intent (informational, navigational, transactional, commercial)
- **Long-tail keywords**: Lower competition, higher conversion, more specific intent
- **Keyword density**: 1–2% natural density — never stuff
- **Semantic variations**: Use related terms and synonyms naturally
- **Placement priority**: Title > H1 > first paragraph > headings > body > alt text

## AI Content Guidelines

- AI-generated content is allowed by Google, but must provide value
- Recommended approach: AI draft + human editing for accuracy and voice
- Avoid: raw AI output without review, keyword-stuffed AI content, mass-produced thin pages
- Add unique insights, personal experience, or original data to differentiate

## Entity SEO

AI 시대에 도메인 권위(Domain Authority)가 엔터티 권위(Entity Authority)로 전환되고 있다.

### 핵심 원칙
- AI 엔진은 키워드가 아닌 엔터티(사람, 조직, 제품, 개념)와 관계를 식별
- 개별 페이지 최적화 < 여러 콘텐츠에 걸친 지식 일관성
- 토픽 클러스터: pillar page + 관련 cluster 콘텐츠로 주제 완전 커버리지

### 스키마 마크업의 AI 시대 역할
- 2026년: SERP 표시 트리거 → **AI 신뢰 및 엔터티 검증 신호**로 진화
- 적절한 스키마 마크업 → AI 생성 답변 등장 확률 **2.5배** 증가
- FAQPage 스키마 → AI 인용률 평균 **30% 향상**
- JSON-LD `@graph` 배열로 관련 엔터티 연결

## Measurement Tools

| Tool | Purpose |
|------|---------|
| Google Search Console | Indexing, performance, coverage errors, AI Overviews data |
| Google Analytics (GA4) | Traffic, user behavior, conversions |
| PageSpeed Insights | Core Web Vitals, performance scoring |
| Lighthouse | Comprehensive page audit (performance, a11y, SEO) |
| Ahrefs / Semrush | Backlinks, keyword rankings, competitor analysis |
| Schema Markup Validator | Structured data validation |
| Profound / AIclicks | AI citation tracking, brand visibility in AI responses |
| Otterly.ai | ChatGPT, Perplexity, Google AIO monitoring |

See `references/aeo-geo-guide.md` for detailed AEO/GEO measurement KPIs and tools.
