# 분석 결과 문서 템플릿

> `.hypercore/crawler/[사이트명]/` 폴더 구조

---

## 폴더 구조

```
.hypercore/crawler/example-com/
├── ANALYSIS.md      # 사이트 구조
├── SELECTORS.md     # DOM selector
├── API.md           # API endpoint
├── NETWORK.md       # 인증 정보
└── CRAWLER.ts       # 생성 코드
```

---

## ANALYSIS.md

```markdown
# [사이트명] 크롤링 분석

생성: {{TIMESTAMP}}
URL: {{BASE_URL}}

## 페이지 타입

| 타입 | URL | 비고 |
|------|-----|------|
| 목록 | /items | |
| 상세 | /items/[id] | |
| 검색 | /search?q= | |

## 데이터 로딩

- [ ] SSR
- [ ] CSR (API 기반)
- [ ] 무한 스크롤
- [ ] 페이지네이션

## 인증

- [ ] 공개
- [ ] 로그인 필요
- [ ] API 키

## 발견사항

[특이사항, 제약, 주의점]

실행이 차단되었으면 이 섹션에 중단 원인, 그 판단의 근거, 가장 안전한 다음 단계를 기록합니다.
```

---

## SELECTORS.md

```markdown
# [사이트명] Selector

## 목록 페이지

| 요소 | Selector | 비고 |
|------|----------|------|
| 컨테이너 | `.item-list` | |
| 카드 | `.item-card` | |
| 제목 | `.item-card h2` | |
| 링크 | `.item-card a` | |
| 다음 | `button[aria-label="Next"]` | |

## aria-ref 매핑

| ref | Selector | 설명 |
|-----|----------|------|
| e14 | `getByRole('button', { name: 'Load more' })` | 더보기 |
```

---

## API.md

```markdown
# [사이트명] API

## GET /api/items

**Parameters:**

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| page | number | 페이지 |
| limit | number | 개수 |

**Headers:**

```json
{ "Authorization": "Bearer ..." }
```

**Response:**

```typescript
interface Response {
  data: Item[];
  pagination: { page: number; total: number; hasNext: boolean };
}
```

## Rate Limiting

[제한사항]
```

---

## NETWORK.md

```markdown
# [사이트명] Network

## 인증 정보

| 항목 | 값 | 만료 |
|------|-----|------|
| Cookie | `session=...` | 24h |
| Token | `Bearer ...` | 1h |

## 필수 헤더

```json
{
  "Cookie": "...",
  "Authorization": "Bearer ...",
  "User-Agent": "Mozilla/5.0 ..."
}
```

## Rate Limit

- 제한: 60 req/min
- 딜레이: 1000ms

## 봇 탐지

- [ ] Cloudflare
- [ ] reCAPTCHA

실행이 차단되었거나 안전하지 않다면 `CRAWLER.ts`를 만들지 못하게 한 차단 신호나 인증 제약을 기록합니다.
```
