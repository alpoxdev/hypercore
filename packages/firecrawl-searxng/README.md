# Firecrawl + SearXNG Self-Hosted

Firecrawl (웹 스크래핑/크롤링) + SearXNG (메타검색 엔진) 셀프호스팅 Docker Compose 패키지.
Claude Code MCP 서버와 연동하여 로컬에서 웹 검색 + 크롤링 인프라를 제공합니다.

## 전제 조건

| 항목 | 요구사항 |
|------|----------|
| Docker Desktop | 설치 완료 |
| RAM | 12GB+ 할당 권장 |
| CPU | 6코어+ 할당 권장 |
| pipx | SearXNG MCP 실행용 |

## 서비스 구성

| 서비스 | 이미지 | 포트 | 설명 |
|--------|--------|------|------|
| api | ghcr.io/firecrawl/firecrawl | 40999 | Firecrawl API 서버 |
| playwright-service | ghcr.io/firecrawl/playwright-service | 내부 3000 | 브라우저 렌더링 |
| redis | redis:alpine | 내부 6379 | 캐시/큐 |
| rabbitmq | rabbitmq:3-management | 내부 5672 | 메시지 큐 |
| postgres | postgres:16-alpine | 내부 5432 | 내부 DB |
| searxng | searxng/searxng | 40998 | 메타검색 엔진 |

## 빠른 시작

```bash
# 1. 이 디렉토리로 이동
cd packages/firecrawl-searxng

# 2. 이미지 다운로드 + 서비스 시작
docker compose pull && docker compose up -d

# 3. 상태 확인
docker compose ps
```

## 서비스 검증

```bash
# SearXNG JSON API 테스트
curl "http://localhost:40998/search?q=test&format=json" | head -200

# Firecrawl 스크래핑 테스트
curl -X POST http://localhost:40999/v1/scrape \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'

# Firecrawl 검색 테스트 (SearXNG 경유)
curl -X POST http://localhost:40999/v1/search \
  -H "Content-Type: application/json" \
  -d '{"query": "firecrawl documentation"}'
```

## Claude Code MCP 등록

MCP 서버는 이미 등록되어 있습니다. 수동으로 등록하려면:

```bash
# Firecrawl MCP
claude mcp add firecrawl \
  -e FIRECRAWL_API_URL=http://localhost:40999 \
  -- npx -y firecrawl-mcp

# SearXNG MCP
claude mcp add searxng \
  -e SEARXNG_MCP_SEARXNG_URL=http://localhost:40998 \
  -- pipx run searxng-simple-mcp@latest

# 등록 확인
claude mcp list
```

## 일상 사용

```bash
# 서비스 시작
cd packages/firecrawl-searxng && docker compose up -d

# 서비스 중지
cd packages/firecrawl-searxng && docker compose down

# 로그 확인
docker compose logs -f api
docker compose logs -f searxng

# 이미지 업데이트
docker compose pull && docker compose up -d
```

## 환경 변수

`.env` 파일에서 설정 가능한 주요 변수:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `PORT` | 40999 | Firecrawl API 외부 포트 |
| `NUM_WORKERS_PER_QUEUE` | 8 | 큐당 워커 수 |
| `SEARXNG_ENDPOINT` | http://searxng:8080 | SearXNG 내부 엔드포인트 |
| `SEARXNG_ENGINES` | ["google","bing","duckduckgo"] | 검색 엔진 목록 |
| `SEARXNG_CATEGORIES` | ["general"] | 검색 카테고리 |
| `USE_DB_AUTHENTICATION` | false | API 인증 비활성화 (로컬용) |
| `BULL_AUTH_KEY` | localdev | 큐 관리자 키 |

## SearXNG 설정

`searxng/settings.yml`에서 검색 엔진 설정 가능:

- `json` 포맷이 활성화되어 있어야 API 사용 가능
- `brave`, `qwant` 엔진은 CAPTCHA 문제로 비활성화됨
- 추가 엔진 활성화/비활성화는 [SearXNG 문서](https://docs.searxng.org/admin/engines/) 참고

## 트러블슈팅

### SearXNG MCP 연결 실패
Docker 서비스가 실행 중인지 확인:
```bash
docker compose ps
curl http://localhost:40998/search?q=test&format=json
```

### Firecrawl API 응답 없음
API 서비스 로그 확인:
```bash
docker compose logs api
```

### 메모리 부족
Docker Desktop에서 RAM 할당 증가 (Settings > Resources > Memory)

## 참고 자료

- [Firecrawl 공식 문서](https://docs.firecrawl.dev/)
- [Firecrawl Self-Hosting 가이드](https://docs.firecrawl.dev/self-hosting)
- [SearXNG 공식 문서](https://docs.searxng.org/)
- [SearXNG 연동 PR #1193](https://github.com/mendableai/firecrawl/pull/1193)
