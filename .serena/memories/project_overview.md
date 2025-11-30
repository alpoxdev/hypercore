# Claude Code Helper - Project Overview

## Purpose
A toolkit for building React + Node.js projects with Claude Code assistance. Provides:
- Documentation storage for Claude Code project understanding
- MCP (Model Context Protocol) server with development tools
- Project templates for React and Node.js applications
- Best practices and conventions guidance

## Tech Stack
- **Language**: TypeScript (strict mode)
- **Runtime**: Node.js 18+
- **Package Manager**: Yarn 4 with workspaces
- **Build Tool**: TypeScript compiler (tsc)
- **Testing**: Vitest
- **Linting**: ESLint
- **Formatting**: Prettier
- **MCP SDK**: @modelcontextprotocol/sdk
- **Validation**: Zod

## Project Type
Monorepo using Yarn workspaces

## Packages
- `packages/mcp-server` - MCP server providing development tools

## MCP Server Tools
- `create_react_app` - Generate React + Vite + TypeScript projects
- `create_node_api` - Generate Node.js API (Express/Fastify) projects
- `add_component` - Add React components with tests/styles
- `generate_docs` - Generate documentation
