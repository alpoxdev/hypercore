# SEO 기본 레퍼런스

**목적**: 감사 분석을 위한 핵심 SEO 지식. 발견사항을 기준과 비교해 평가할 때 로드한다.
**최종 확인**: 2026-04-29, Google Search Central 및 web.dev 가이드 기준.

## Search Essentials

다음을 가장 신뢰도 높은 기준선으로 사용한다:

1. 중요한 페이지가 크롤링, 렌더링, 색인되고 snippet과 함께 표시될 수 있도록 기술 요구사항을 충족한다.
2. 스팸 또는 기만적 전술을 피한다.
3. 유용하고 신뢰할 수 있으며 사람 중심의 콘텐츠를 만든다.
4. 사람들이 콘텐츠를 찾을 때 사용할 단어를 title, main heading, alt text, link text 같은 눈에 띄는 위치에 사용한다.
5. 링크를 crawlable하게 만들고 중요한 콘텐츠를 visible text로 제공한다.
6. 관련성이 있을 때 structured data, images, videos, JavaScript best practices를 사용한다.

## E-E-A-T 프레임워크

E-E-A-T는 단일 직접 ranking factor가 아니다. 특히 YMYL 주제에서 trust signals를 식별하는 데 도움이 되는 self-assessment 및 quality framework로 다룬다.

| 축 | 의미 | 신호 |
|----|------|------|
| **Experience** | 주제에 대한 직접 경험 | 원본 사진, 테스트된 예시, case studies, 실제 또는 제품 경험 |
| **Expertise** | 자격과 깊은 주제 지식 | Author bio, credentials, technical accuracy, expert review |
| **Authoritativeness** | 다른 이들의 인정 | Quality citations, reputable mentions, topic cluster consistency |
| **Trustworthiness** | 신뢰성과 투명성 | HTTPS, clear contact, privacy policy, accurate sourcing, no deception |

Trust는 가장 중요한 축이다. 콘텐츠가 모든 E-E-A-T 신호를 동일하게 가질 필요는 없지만 YMYL 주제에는 더 엄격한 증거와 전문성이 필요하다.

## Core Web Vitals

Field data가 있을 때 실제 사용자 전체의 75th percentile에서 Core Web Vitals를 평가한다. Lab tools는 디버깅에 유용하지만 field data보다 낮은 신뢰도로 라벨링해야 한다.

| Metric | Full Name | Good | Needs Improvement | Poor |
|--------|-----------|------|-------------------|------|
| **LCP** | Largest Contentful Paint | ≤ 2.5s | > 2.5s – 4.0s | > 4.0s |
| **INP** | Interaction to Next Paint | ≤ 200ms | > 200ms – 500ms | > 500ms |
| **CLS** | Cumulative Layout Shift | ≤ 0.1 | > 0.1 – 0.25 | > 0.25 |

### LCP 최적화

- Fold 위의 가장 큰 image/text block을 최적화한다.
- Hero assets에는 framework image components 또는 올바른 `<img>` loading priorities를 사용한다.
- 정말 critical한 리소스만 preload한다.
- Server response time(TTFB)과 render-blocking resources를 최소화한다.

### INP 최적화

- Long tasks(> 50ms)를 나눈다.
- Scheduling APIs 또는 framework-specific lazy loading으로 non-critical work를 지연한다.
- Main thread blocking JavaScript와 expensive event handlers를 최소화한다.
- Lighthouse 점수만 보지 말고 interaction-specific profiling을 선호한다.

### CLS 최적화

- Images/videos에 explicit `width`와 `height` 또는 aspect ratio를 설정한다.
- Ads, embeds, banners, dynamic content를 위한 공간을 예약한다.
- Load 후 기존 콘텐츠 위에 콘텐츠를 삽입하지 않는다.
- 적절한 경우 stable font loading과 layout containment를 사용한다.

## 우선순위 모델

이를 보편적인 ranking-factor 순서로 제시하지 않는다. 실무 감사 triage model로 사용한다:

1. **Eligibility** — crawlability, indexability, canonical correctness, snippet eligibility.
2. **People-first usefulness** — intent를 만족하는 original, complete, accurate content.
3. **Trust and safety** — transparent authorship/organization, sourcing, policies, no deceptive behavior.
4. **Search appearance** — titles, descriptions, structured data, images/video metadata.
5. **Page experience** — Core Web Vitals, mobile usability, HTTPS, intrusive interstitial avoidance.
6. **Authority and discovery** — internal links, external mentions/backlinks, relevant communities에서의 promotion.
7. **AEO/GEO readiness** — answer blocks, sourceable claims, entity clarity, AI crawler policy, citation probes.

## Schema Markup Types

고려할 수 있는 일반 JSON-LD schema. Structured data가 보이는 page content와 일치하고 가장 구체적인 applicable type을 사용하는지 항상 검증한다.

| Type | 사용할 때 | 주의사항 |
|------|-----------|----------|
| `Article` | Blog posts, news articles, guides | Visible하거나 적절한 author/date/image를 정확히 포함 |
| `Organization` | Company/about pages | name/logo/contact/social profiles를 일관되게 유지 |
| `Person` | Author/team profile pages | 실제 visible people/entities에만 사용 |
| `FAQPage` | 질문당 accepted answer가 하나인 FAQ content | Google FAQ rich results는 authoritative government/health sites로 제한됨 |
| `QAPage` | 하나의 질문에 user-submitted multiple answers가 있는 경우 | Forums 또는 multi-answer Q&A에 FAQPage를 사용하지 않음 |
| `Product` | Ecommerce product pages | Price/availability/reviews가 visible content와 일치해야 함 |
| `Review` | Review content/testimonials | Fake 또는 hidden reviews 금지 |
| `BreadcrumbList` | Navigation breadcrumbs | Visible 또는 logical site hierarchy와 일치 |
| `WebSite` | Site-level search box와 identity | 적절한 경우 Organization과 함께 사용 |
| `LocalBusiness` | Local business pages | Address/hours를 visible content 및 profiles와 일관되게 유지 |
| `HowTo` | Step-by-step content | Steps가 visible하고 실제 instruction일 때만 사용 |

## Keyword And Intent Strategy

- **Intent first**: Content format을 informational, commercial, transactional, navigational intent에 맞춘다.
- **Natural language**: 사용자가 실제로 검색할 terms를 titles, headings, first paragraphs, alt text, links에 사용한다.
- **No stuffing**: Scoring shortcut으로 fixed-density targets를 피한다. Readability와 intent fit이 더 중요하다.
- **Semantic coverage**: Related entities, comparisons, limitations, examples를 자연스럽게 포함한다.

## AI Content Guidelines

- AI-generated content도 helpful, accurate, reviewed, people-first라면 허용될 수 있다.
- AI-assisted drafts에 human review, fact checking, source verification, original examples를 더하는 방식을 선호한다.
- Mass-produced thin pages, unreviewed generated text, unsupported claims, search traffic capture만을 위한 콘텐츠를 피한다.

## Entity And Trust Signals

AI와 search systems는 명확한 entities에서 이점을 얻지만 schema만으로 deterministic AI citation gains가 생긴다고 주장하지 않는다.

### 점검

- Organization, product, author, topic names가 페이지 전반에서 일관적인지.
- Author/about/contact pages와 visible expertise signals가 있는지.
- Definitions, comparisons, implementation, risks, examples를 다루는 topic clusters가 있는지.
- JSON-LD `@id`/`@graph` links가 visible content를 정확히 반영하는지.

### 피할 것

- Schema가 AI citations 또는 rich results를 보장한다고 주장하기.
- Invisible, misleading, irrelevant content를 마크업하기.
- Domain authority, entity authority, freshness를 하나의 magic lever로 취급하기.

## 측정 도구

| Tool | 목적 | Evidence grade |
|------|------|----------------|
| Google Search Console | Indexing, performance, coverage, Search traffic | `field`/`official` |
| Google Analytics / server logs | Traffic, user behavior, conversions, AI referrers | `field` |
| PageSpeed Insights / CrUX | Core Web Vitals field and lab diagnostics | `field` + `lab` |
| Lighthouse | Performance/accessibility/SEO lab audit | `lab` |
| Rich Results Test / Schema validator | Structured data validation | `tool` |
| Local crawler/static scan | Links, metadata, robots, schema, headings | `lab` |
| AI citation prompt set | AI answers에서 citation/mention visibility | `synthetic` |
| Ahrefs/Semrush/etc. | Backlinks, keyword rankings, competitor research | `tool` |

AEO/GEO measurement KPIs, crawler policy, citation probe guidance는 `references/aeo-geo-guide.md`를 참고한다.
