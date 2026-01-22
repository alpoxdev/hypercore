# Figma MCP Tools Usage

Detailed guide to tools and API endpoints provided by Figma MCP.

---

## MCP Connection Types

### Desktop MCP (Local)

**Advantages:**
- Selection-based: Process only selected layers
- Fast response
- No internet connection required

**Setup:**

```bash
# Add
claude mcp add --transport http figma-desktop http://127.0.0.1:3845/mcp

# Verify
claude mcp list

# Restart
claude mcp restart figma-desktop
```

**Enable:** Figma Desktop → Dev Mode (Shift+D) → Inspect → "Enable desktop MCP server" → Verify: `http://127.0.0.1:3845/health`

### Remote MCP (Cloud)

**Advantages:**
- Access via file URL
- No desktop app required
- Better for team collaboration

**Setup:**

```bash
# Add
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp

# Authenticate
claude mcp login figma-remote-mcp
```

**Usage:**
```
Provide file URL:
https://www.figma.com/file/ABC123/ProjectName
```

---

## Key MCP Tools

### 1. get_file_info

Retrieve file metadata and structure (required before starting work).

**Response:**
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

Extract Variables (Color, Number, String, Boolean).

**Response:**
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

Extract Text Styles, Color Styles, Effect Styles.

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

Retrieve layer properties including layout/Auto Layout/styles/text/images (Desktop MCP: requires layer selection).

**Response:**
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
      "characters": "Button text",
      "style": { "fontSize": 14, "fontWeight": 600 }
    }
  ]
}
```

**→ TSX:**
```tsx
<button className="flex items-center justify-center gap-[8px] px-[16px] py-[12px] bg-[#3182F6] rounded-[8px] w-[120px] h-[44px]">
  <span className="text-[14px] font-semibold text-white">Button text</span>
</button>
```

### 5. get_images

Generate download links for image assets.

**Usage:**
```json
// Input: image_refs: ["123:456"]
// Output: { "123:456": "https://s3-alpha.figma.com/..." }
```

**Workflow:**
```bash
curl -o hero.png "https://..." && cwebp hero.png -q 80 -o hero.webp && mv hero.webp public/images/
```

### 6. export_node

Export layer as SVG/PNG/JPG.

**Settings:**
```json
{ "node_id": "123:456", "format": "SVG", "scale": 2 }
```

**Use Cases:** Icons (SVG), Illustrations (PNG/WebP 2x), Logos (SVG)

---

## Workflow

| Step | Tool | Output |
|------|------|--------|
| 1. File structure | get_file_info | Canvas/Frame structure |
| 2. Extract tokens | get_variables | CSS Variables |
| 3. Extract styles | get_styles | Text/Color Styles |
| 4. Layer properties | get_node_properties | Layout/Auto Layout |
| 5. Collect images | get_images | Download URLs |
| 6. Implement code | - | Flexbox/Grid + exact measurements |
| 7. Validate | DevTools | Measurement comparison |

---

## Important Notes

### Desktop MCP

| Limitation | Solution |
|-----------|----------|
| Layer selection required | Select target layer before work |
| Limited concurrent execution | One file at a time |
| Requires local network | Verify firewall (port 3845) |

### Remote MCP

| Limitation | Solution |
|-----------|----------|
| Authentication required | Run `claude mcp login` |
| Rate limit | Wait if 429 error occurs |
| File permissions | Requires View access or higher |

---

## Debugging

### Verify MCP Connection

```bash
# Desktop MCP status
curl http://127.0.0.1:3845/health

# Remote MCP login status
claude mcp status figma-remote-mcp
```

### Error Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | Desktop MCP not enabled | Enable in Figma Dev Mode |
| `401 Unauthorized` | Remote MCP auth expired | Rerun `claude mcp login` |
| `404 Not Found` | Invalid node_id | Verify ID in Figma |
| `429 Too Many Requests` | Rate limit exceeded | Wait 1 minute and retry |

---

## References

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Figma REST API Reference](https://www.figma.com/developers/api)
- [Claude MCP Integration](https://www.builder.io/blog/figma-mcp-server)
