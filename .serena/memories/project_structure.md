# Project Structure

```
claude-code/
├── README.md                     # Project overview
├── CLAUDE.md                     # Claude Code instructions
├── package.json                  # Root monorepo config
├── tsconfig.json                 # Root TypeScript config
├── .gitignore
├── .prettierrc                   # Prettier config
│
├── packages/
│   └── mcp-server/               # MCP Server Package
│       ├── package.json
│       ├── tsconfig.json
│       ├── README.md
│       └── src/
│           ├── index.ts          # Entry point (#!/usr/bin/env node)
│           ├── server.ts         # MCP server setup and handlers
│           ├── types.ts          # TypeScript interfaces
│           └── tools/
│               ├── index.ts      # Tool exports
│               ├── create-react-app.ts
│               ├── create-node-api.ts
│               ├── add-component.ts
│               └── generate-docs.ts
│
└── docs/
    ├── getting-started.md        # Quick start guide
    ├── mcp-server.md             # MCP server reference
    ├── project-templates.md      # Template documentation
    ├── best-practices.md         # Development guidelines
    └── architecture.md           # System architecture
```

## Key Files

### Root Level
- `package.json` - Yarn workspaces configuration
- `CLAUDE.md` - Instructions for Claude Code when working with this project

### MCP Server
- `src/index.ts` - Server entry, runs `runServer()`
- `src/server.ts` - Creates MCP server, registers tool handlers
- `src/types.ts` - Shared TypeScript types (Tool, ToolResponse, etc.)
- `src/tools/*.ts` - Individual tool implementations

## Adding New Tools
1. Create file in `packages/mcp-server/src/tools/`
2. Export from `tools/index.ts`
3. Tool auto-registers via server.ts
