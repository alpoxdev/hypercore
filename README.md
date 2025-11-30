# Claude Code Helper

> TanStack Start 프로젝트를 위한 Claude Code 지원 도구

---

## 🚀 Quick Reference

```typescript
// Server Function
export const getData = createServerFn({ method: 'GET' })
  .handler(async () => prisma.table.findMany())

// Zod v4
const schema = z.object({
  email: z.email(),  // v4 API!
  name: z.string().min(1).trim(),
})

// Route
export const Route = createFileRoute('/path')({
  component: Page,
  loader: async () => ({ data: await getData() }),
})
```

---

## 🛠 Tech Stack

| 분류 | 기술 | 버전 |
|------|------|------|
| Framework | TanStack Start | 1.x |
| Language | TypeScript | 5.x |
| Styling | Tailwind CSS | 4.x |
| Database | Prisma | 7.x |
| Validation | Zod | 4.x |
| Auth | Better Auth | 최신 |
| Data | TanStack Query | 5.x |

---

## 📁 Project Structure

```
claude-code/
├── README.md                 # 이 문서
├── CLAUDE.md                 # ⚠️ Claude Code 필수 규칙
├── package.json
├── tsconfig.json
├── packages/                 # MCP 서버 등
└── docs/
    ├── README.md             # 문서 가이드
    ├── guides/               # 개발 가이드
    ├── architecture/         # 시스템 아키텍처
    ├── design/               # UI/UX 디자인
    ├── library/              # 라이브러리 사용법
    ├── mcp/                  # MCP 도구 가이드
    ├── deployment/           # 배포 가이드
    └── git/                  # Git 컨벤션
```

---

## 📋 Documentation

| 문서 | 내용 | 필독 |
|------|------|------|
| [CLAUDE.md](./CLAUDE.md) | Claude Code 규칙 | 🔴 |
| [docs/README.md](./docs/README.md) | 문서 가이드 | 🔴 |
| [docs/git/](./docs/git/index.md) | Git 커밋 규칙 | 🔴 |
| [docs/mcp/](./docs/mcp/index.md) | MCP 도구 | 🔴 |
| [docs/library/prisma/](./docs/library/prisma/index.md) | Prisma v7 | 🟡 |
| [docs/library/zod/](./docs/library/zod/index.md) | Zod v4 | 🟡 |
| [docs/library/tanstack-start/](./docs/library/tanstack-start/index.md) | Server Functions | 🟡 |
| [docs/design/](./docs/design/index.md) | UI/UX 가이드 | 🟡 |

**필독**: 🔴 필수 / 🟡 해당 작업 시

---

## ⚡ Core Rules

### ⛔ NEVER
```
❌ Git 커밋에 AI 표시 금지 (Generated with Claude Code, 🤖, Co-Authored-By)
❌ Prisma 명령어 자동 실행 금지 (db push, migrate, generate)
❌ Zod v3 API 사용 금지 (z.string().email() → z.email())
```

### ✅ ALWAYS
```
✅ 작업 전 CLAUDE.md 읽기
✅ Git: 단일 라인, prefix 필수 (feat:, fix:, etc.)
✅ Prisma v7: provider="prisma-client", output 필수
✅ TypeScript: const 선언, 명시적 return type
✅ MCP: sgrep + Sequential Thinking + Context7 적극 활용
✅ 코드베이스 검색: sgrep 사용 (grep/rg 금지)
```

---

## 🚀 Getting Started

```bash
# Clone
git clone https://github.com/your-org/claude-code.git
cd claude-code

# Install
yarn install

# Development
yarn dev
```

### Prerequisites

- Node.js 18+
- Yarn
- Claude Code CLI

---

## License

MIT License
