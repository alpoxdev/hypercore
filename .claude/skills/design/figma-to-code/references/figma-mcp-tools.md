# Figma MCP 도구 사용법

Figma MCP가 제공하는 도구와 API 엔드포인트 상세 가이드.

---

## MCP 연결 타입

### Desktop MCP (로컬)

**장점:**
- 선택 기반 (Selection-based): 현재 선택한 레이어만 처리
- 빠른 응답 속도
- 인터넷 연결 불필요

**설정:**

```bash
# 추가
claude mcp add --transport http figma-desktop http://127.0.0.1:3845/mcp

# 확인
claude mcp list

# 재시작
claude mcp restart figma-desktop
```

**활성화:** Figma Desktop → Dev Mode (Shift+D) → Inspect → "Enable desktop MCP server" → 확인: `http://127.0.0.1:3845/health`

### Remote MCP (클라우드)

**장점:**
- 파일 URL로 접근 가능
- 데스크톱 앱 불필요
- 팀 협업에 유리

**설정:**

```bash
# 추가
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp

# 인증
claude mcp login figma-remote-mcp
```

**사용:**
```
파일 URL 제공:
https://www.figma.com/file/ABC123/ProjectName
```

---

## 주요 MCP 도구

### 1. get_file_info

파일 메타데이터 및 구조 조회 (작업 시작 전 필수).

**응답:**
```json
{
  "name": "Design System",
  "version": "1.2.3",
  "lastModified": "2026-01-20T10:30:00Z",
  "document": {
    "children": [
      { "type": "CANVAS", "name": "Components" },
      { "type": "CANVAS", "name": "Tokens" }
    ]
  }
}
```

### 2. get_variables

Variables (Color, Number, String, Boolean) 추출.

**응답:**
```json
{
  "variables": [
    {
      "id": "VariableID:123",
      "name": "color/primary/500",
      "resolvedType": "COLOR",
      "valuesByMode": {
        "modeId": { "r": 0.192, "g": 0.51, "b": 0.965, "a": 1 }
      },
      "codeSyntax": {
        "WEB": "--color-primary-500",
        "ANDROID": "colorPrimary500",
        "iOS": "colorPrimary500"
      }
    },
    {
      "id": "VariableID:456",
      "name": "spacing/md",
      "resolvedType": "FLOAT",
      "valuesByMode": { "modeId": 16 },
      "codeSyntax": { "WEB": "--spacing-md" }
    }
  ]
}
```

**→ CSS:**
```css
:root {
  --color-primary-500: #3182F6;
  --spacing-md: 16px;
}
```

### 3. get_styles

Text Styles, Color Styles, Effect Styles 추출.

**Text Styles:**
```json
{
  "id": "S:123",
  "name": "Heading/H1",
  "type": "TEXT",
  "fontSize": 28,
  "fontFamily": "Pretendard",
  "fontWeight": 600,
  "lineHeight": { "unit": "PIXELS", "value": 36 },
  "letterSpacing": { "unit": "PERCENT", "value": -2 }
}
```

**→ CSS:**
```css
.heading-h1 {
  font-family: 'Pretendard', sans-serif;
  font-size: 28px;
  font-weight: 600;
  line-height: 36px;
  letter-spacing: -0.02em;
}
```

**Color Styles:**
```json
{
  "id": "S:456",
  "name": "Semantic/Success",
  "type": "FILL",
  "color": { "r": 0.133, "g": 0.725, "b": 0.478, "a": 1 }
}
```

### 4. get_node_properties

선택된 레이어의 레이아웃/Auto Layout/스타일/텍스트/이미지 속성 (Desktop MCP: 레이어 선택 필수).

**응답:**
```json
{
  "id": "123:456",
  "name": "Button/Primary",
  "type": "FRAME",
  "absoluteBoundingBox": { "x": 100, "y": 200, "width": 120, "height": 44 },
  "layoutMode": "HORIZONTAL",
  "primaryAxisAlignItems": "CENTER",
  "counterAxisAlignItems": "CENTER",
  "itemSpacing": 8,
  "paddingLeft": 16,
  "paddingRight": 16,
  "paddingTop": 12,
  "paddingBottom": 12,
  "fills": [
    { "type": "SOLID", "color": { "r": 0.192, "g": 0.51, "b": 0.965, "a": 1 } }
  ],
  "cornerRadius": 8,
  "children": [
    {
      "type": "TEXT",
      "characters": "버튼 텍스트",
      "style": { "fontSize": 14, "fontWeight": 600 }
    }
  ]
}
```

**→ TSX:**
```tsx
<button className="flex items-center justify-center gap-[8px] px-[16px] py-[12px] bg-[#3182F6] rounded-[8px] w-[120px] h-[44px]">
  <span className="text-[14px] font-semibold text-white">버튼 텍스트</span>
</button>
```

### 5. get_images

이미지 에셋 다운로드 링크 생성.

**사용:**
```json
// Input: image_refs: ["123:456"]
// Output: { "123:456": "https://s3-alpha.figma.com/..." }
```

**워크플로우:**
```bash
# PNG/JPG → WebP (SVG 파일은 변환하지 않음)
curl -o hero.png "https://..." && cwebp hero.png -q 80 -o hero.webp && mv hero.webp public/images/
curl -o banner.jpg "https://..." && cwebp banner.jpg -q 80 -o banner.webp && mv banner.webp public/images/
```

### 6. export_node

레이어를 SVG/PNG/JPG로 export.

**설정:**
```json
{ "node_id": "123:456", "format": "SVG", "scale": 2 }
```

**케이스:** 아이콘(SVG), 일러스트(PNG/WebP 2x), 로고(SVG)

---

## 워크플로우

| 단계 | 도구 | 출력 |
|------|------|------|
| 1. 파일 구조 | get_file_info | Canvas/Frame 구조 |
| 2. 토큰 추출 | get_variables | CSS Variables |
| 3. 스타일 추출 | get_styles | Text/Color Styles |
| 4. 레이어 속성 | get_node_properties | Layout/Auto Layout |
| 5. 이미지 수집 | get_images | 다운로드 URL |
| 6. 코드 구현 | - | Flexbox/Grid + 정확한 수치 |
| 7. 검증 | DevTools | 수치 비교 |

---

## 주의 사항

### Desktop MCP

| 제약 | 해결 |
|------|------|
| 레이어 선택 필수 | 구현 전 대상 레이어 선택 |
| 동시 실행 제한 | 한 번에 하나의 파일만 |
| 로컬 네트워크 필요 | 방화벽 확인 (포트 3845) |

### Remote MCP

| 제약 | 해결 |
|------|------|
| 인증 필요 | `claude mcp login` 실행 |
| Rate Limit | 429 에러 시 대기 |
| 파일 권한 | View 권한 이상 필요 |

---

## 디버깅

### MCP 연결 확인

```bash
# Desktop MCP 상태
curl http://127.0.0.1:3845/health

# Remote MCP 로그인 상태
claude mcp status figma-remote-mcp
```

### 오류 해결

| 오류 | 원인 | 해결 |
|------|------|------|
| `Connection refused` | Desktop MCP 미활성화 | Figma Dev Mode에서 Enable |
| `401 Unauthorized` | Remote MCP 인증 만료 | `claude mcp login` 재실행 |
| `404 Not Found` | 잘못된 node_id | Figma에서 ID 재확인 |
| `429 Too Many Requests` | Rate Limit 초과 | 1분 대기 후 재시도 |

---

## 참조

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Figma REST API Reference](https://www.figma.com/developers/api)
- [Claude MCP Integration](https://www.builder.io/blog/figma-mcp-server)
