# SEO Audit Checklist

**Purpose**: Actionable item-by-item checklist for scanning. Use during each audit phase.

## Measurement & Confidence Checklist

- [ ] Access level recorded: live URL, local files, Search Console, analytics, field Core Web Vitals, AI citation probe.
- [ ] Each evidence channel labeled as `official`, `field`, `tool`, `lab`, `synthetic`, or `heuristic`.
- [ ] Missing live/field/probe data lowers confidence instead of being hidden.
- [ ] Findings include `evidence_grade`, `confidence`, `measurement_method`, and `source_tier`.

## Technical SEO Checklist

### Crawling & Indexing

- [ ] `robots.txt` exists at root and doesn't block important pages
- [ ] `sitemap.xml` exists, is valid, and includes all indexable pages
- [ ] `sitemap.xml` is referenced in `robots.txt`
- [ ] No unintentional `noindex` directives on indexable pages
- [ ] Canonical tags present and pointing to correct URLs
- [ ] No orphan pages (pages not linked from anywhere)

### HTTPS & Security

- [ ] HTTPS enforced site-wide
- [ ] No mixed content (HTTP resources on HTTPS pages)
- [ ] Valid SSL certificate
- [ ] HTTP → HTTPS redirects in place (301)

### Performance & Core Web Vitals

- [ ] LCP target: ≤ 2.5s at p75 when field data is available — check hero image optimization, preloading
- [ ] INP target: ≤ 200ms at p75 when field data is available — check JavaScript execution, event handlers
- [ ] CLS target: ≤ 0.1 at p75 when field data is available — check image dimensions, dynamic content insertion
- [ ] Images optimized (WebP/AVIF, proper sizing, lazy loading for below-fold)
- [ ] Critical CSS inlined or preloaded
- [ ] JavaScript bundle size reasonable, code-split where possible

### Structured Data

- [ ] JSON-LD schema markup present on key pages
- [ ] Schema validates without errors (Schema Markup Validator)
- [ ] Appropriate schema types for visible content (Article, Product, FAQPage/QAPage where eligible, etc.)

### Mobile

- [ ] `<meta name="viewport" content="width=device-width, initial-scale=1">` present
- [ ] Responsive design — no horizontal scroll on mobile
- [ ] Touch targets ≥ 48px
- [ ] Font size ≥ 16px for body text

### URL Structure

- [ ] Clean, descriptive URLs (kebab-case, lowercase)
- [ ] No unnecessary query parameters in indexable URLs
- [ ] Proper 301 redirects for moved/renamed pages
- [ ] No redirect chains (A→B→C, should be A→C)

## Platform Policy Checklist

- [ ] Googlebot indexing/snippet access checked separately from AI training controls.
- [ ] Google-Extended policy checked only where relevant.
- [ ] OAI-SearchBot and GPTBot are evaluated separately for ChatGPT Search vs OpenAI training.
- [ ] `nosnippet`, `data-nosnippet`, `max-snippet`, `noindex`, canonical, and X-Robots-Tag effects checked.
- [ ] Recommendations cite official docs or observed files/headers when marked high confidence.

## On-Page SEO Checklist

### Title & Meta

- [ ] `<title>` unique per page, under 60 characters
- [ ] `<title>` includes primary keyword naturally
- [ ] `<meta name="description">` exists, 150–160 characters
- [ ] Meta description is compelling and includes a call to action or value proposition
- [ ] No duplicate titles or descriptions across pages

### Headings

- [ ] Single `<h1>` per page
- [ ] `<h1>` includes primary keyword
- [ ] Logical heading hierarchy: h1 → h2 → h3 (no skipped levels)
- [ ] Headings are descriptive, not generic ("Section 1")

### Images

- [ ] All `<img>` have descriptive `alt` attributes
- [ ] Alt text includes relevant keywords where natural
- [ ] Images have explicit `width` and `height` (CLS prevention)
- [ ] Decorative images use `alt=""`

### Social Meta Tags

- [ ] `og:title`, `og:description`, `og:image`, `og:url` present
- [ ] `og:image` is at least 1200×630px
- [ ] `twitter:card` set to `summary_large_image` or `summary`
- [ ] `twitter:title`, `twitter:description` present

### Internal Links

- [ ] Important pages are linked from navigation or content
- [ ] Anchor text is descriptive (not "click here")
- [ ] 3–5 internal links per 1,000 words of content
- [ ] No broken internal links (404s)

## Content SEO Checklist

### Quality & Relevance

- [ ] Content matches search intent for target keyword
- [ ] Sufficient depth — minimum 300 words for indexable pages
- [ ] Original content — no duplicate from other pages or sites
- [ ] Updated within last 12 months for time-sensitive topics

### Keyword Usage

- [ ] Primary keyword in title, H1, first 100 words
- [ ] Keywords and related entities appear naturally; no fixed-density target or stuffing
- [ ] Semantic variations and related terms used throughout
- [ ] No keyword cannibalization (multiple pages targeting same keyword)

### E-E-A-T Signals

- [ ] Author information visible (bio, credentials)
- [ ] Sources cited for factual claims
- [ ] Contact information accessible
- [ ] Privacy policy and terms of service present
- [ ] Clear disclosure for sponsored/affiliate content

### Readability

- [ ] Short paragraphs (2–4 sentences)
- [ ] Subheadings every 200–300 words
- [ ] Bullet points and lists for scannable content
- [ ] Clear, jargon-free language (unless technical audience)

## AEO (Answer Engine Optimization) Checklist

### Direct Answer Structure

- [ ] Concise visible answer blocks appear near the top of sections for key questions (length rules are heuristic)
- [ ] Question-style H2/H3 headings are used, for example "## What is X?"
- [ ] Definition-style sentences follow the pattern "[Term] is [definition]"
- [ ] List or table content supports Featured Snippet extraction

### FAQ & Schema

- [ ] FAQPage and QAPage use cases are distinguished, and Google rich result eligibility is not overstated
- [ ] FAQ/Q&A answers match visible content and structured data
- [ ] HowTo schema is applied to HowTo content

### Voice Search

- [ ] Natural-language question-style subheadings are used (Who, What, Where, When, Why, How)
- [ ] Conversational answer structure is present
- [ ] Answers are concise and direct enough for voice assistants to read

## GEO (Generative Engine Optimization) Checklist

### GEO CORE — Context

- [ ] Sufficient context and background are provided for the topic
- [ ] Related concepts and definitions are included
- [ ] The topic scope is clearly defined

### GEO CORE — Organization

- [ ] Clear H2/H3 hierarchy is present
- [ ] Each section starts with a 2-3 sentence key summary
- [ ] Short paragraphs (2-3 sentences), bullets, and tables are used
- [ ] Paragraphs can be extracted independently by AI systems

### GEO CORE — Reliability

- [ ] Verifiable statistics and numeric data are included
- [ ] Explicit source citations are included (author name, organization, date)
- [ ] Expert opinions or case studies are included
- [ ] E-E-A-T signals are strengthened (author information, credentials, contact details)

### GEO CORE — Exclusivity

- [ ] Proprietary data, original research, or benchmarks are included
- [ ] A unique perspective or framework is provided
- [ ] Insights exist that cannot be found elsewhere

### Entity Authority

- [ ] Topic clusters are organized (pillar + cluster)
- [ ] Internal links connect related content
- [ ] Organization/Person schema identifies entities
- [ ] Consistent expertise is expressed across multiple content pieces

### Content Freshness

- [ ] Content freshness matches the topic's time sensitivity, and `dateModified`/source dates are accurate
- [ ] `dateModified` schema markup is included
- [ ] Time-sensitive data includes exact dates

### AI Crawler Access

- [ ] `llms.txt` is checked as an optional content map, and a missing file is not treated as critical by default
- [ ] `robots.txt` is checked for purpose-specific blocks for OAI-SearchBot (search), GPTBot (training), ChatGPT-User (user fetch), ClaudeBot/PerplexityBot, and similar crawlers
- [ ] Important content is accessible without JavaScript rendering
