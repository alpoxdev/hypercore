# Claude Code Helper

TanStack Start 프로젝트를 위한 Claude Code 지원 도구. 문서화 및 MCP 서버를 통해 Claude Code의 개발 효율성을 높입니다.

## Overview

Claude Code Helper는 다음을 제공합니다:

- **프로젝트 문서화** - Claude Code가 프로젝트 컨벤션을 이해할 수 있는 문서
- **MCP 서버** - 프로젝트 스캐폴딩 및 코드 생성 도구
- **개발 가이드** - TanStack Start 기반 개발 모범 사례

## Tech Stack

- **Framework**: TanStack Start (React + Vinxi)
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS
- **State Management**: TanStack Query
- **Routing**: TanStack Router (file-based)
- **Database**: Prisma
- **Validation**: Zod
- **Testing**: Vitest

## Project Structure

```
claude-code/
├── README.md                 # 프로젝트 개요
├── CLAUDE.md                 # Claude Code 지침
├── package.json
├── tsconfig.json
├── packages/                 # 패키지 (MCP 서버 등)
└── docs/
    ├── architecture/         # 시스템 아키텍처
    ├── design/               # UI/UX 디자인 가이드
    ├── library/              # 라이브러리 사용법
    ├── guides/               # 개발 가이드
    └── api/                  # API 문서
```

## Installation

### Prerequisites

- Node.js 18+
- Yarn
- Claude Code CLI

### Setup

```bash
git clone https://github.com/your-org/claude-code.git
cd claude-code
yarn install
```

## Documentation

- [Getting Started](docs/guides/getting-started.md) - 시작 가이드
- [Best Practices](docs/guides/best-practices.md) - 개발 모범 사례
- [Architecture](docs/architecture/architecture.md) - 시스템 아키텍처

## License

MIT License
