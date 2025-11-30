# @kood/claude-code

> Claude Code 문서 설치 CLI

프로젝트에 Claude Code 문서 템플릿을 빠르게 설치하는 CLI 도구입니다.

---

## Quick Start

```bash
npx @kood/claude-code
```

---

## Features

- **다중 템플릿 지원**: Hono, TanStack Start 등 여러 프레임워크 템플릿 제공
- **단일/다중 선택**: 프로젝트 유형에 맞게 하나 또는 여러 템플릿 설치
- **Skills 설치**: Claude Code skills 자동 설치 옵션
- **Interactive UI**: 스페이스바로 선택, 엔터로 확정

---

## Installation

### npx (권장)
```bash
npx @kood/claude-code
```

### Global Install
```bash
npm install -g @kood/claude-code
claude-code
```

---

## Usage

### Interactive Mode
```bash
npx @kood/claude-code
```

프롬프트에서 템플릿 선택:
- **스페이스바**: 선택/해제
- **엔터**: 확정

### CLI Options

```bash
npx @kood/claude-code [options]
```

| 옵션 | 설명 | 예시 |
|------|------|------|
| `-t, --template <names>` | 템플릿 지정 (쉼표로 구분) | `-t hono` |
| `-f, --force` | 기존 파일 덮어쓰기 | `-f` |
| `-s, --skills` | Skills 설치 | `-s` |
| `--no-skills` | Skills 설치 건너뛰기 | `--no-skills` |
| `--cwd <path>` | 작업 디렉토리 지정 | `--cwd ./my-project` |

---

## Templates

### Available Templates

| 템플릿 | 설명 |
|--------|------|
| `hono` | Hono 서버 프레임워크 (Cloudflare Workers) |
| `tanstack-start` | TanStack Start 풀스택 프레임워크 |

### 단일 템플릿 선택

```bash
npx @kood/claude-code -t hono
```

**결과 구조**:
```
your-project/
├── CLAUDE.md           # 루트에 설치
└── docs/               # 문서 폴더
    ├── git/
    ├── library/
    ├── mcp/
    └── ...
```

### 다중 템플릿 선택 (모노레포)

```bash
npx @kood/claude-code -t hono,tanstack-start
```

**결과 구조**:
```
your-project/
└── docs/
    ├── hono/
    │   ├── CLAUDE.md
    │   └── docs/
    └── tanstack-start/
        ├── CLAUDE.md
        └── docs/
```

---

## Examples

### 기본 사용
```bash
# Interactive 모드
npx @kood/claude-code

# 특정 템플릿 지정
npx @kood/claude-code -t hono

# 모노레포 (여러 템플릿)
npx @kood/claude-code -t hono,tanstack-start
```

### Skills 포함 설치
```bash
# Skills 자동 설치
npx @kood/claude-code -t hono -s

# Skills 설치 건너뛰기
npx @kood/claude-code -t hono --no-skills
```

### 기존 파일 덮어쓰기
```bash
npx @kood/claude-code -t hono -f
```

### 다른 디렉토리에 설치
```bash
npx @kood/claude-code -t hono --cwd ./packages/api
```

---

## Installed Files

### CLAUDE.md
프로젝트 작업 지침 파일. 다음 내용 포함:
- 절대 금지 사항 (NEVER DO)
- 필수 실행 사항 (ALWAYS DO)
- Tech Stack 및 버전 정보
- 코드 컨벤션
- Quick Patterns (복사용 코드)

### docs/
상세 문서 폴더:
- `git/` - Git 커밋 규칙
- `library/` - 라이브러리별 가이드 (Hono, Prisma, Zod 등)
- `mcp/` - MCP 도구 사용 가이드
- `deployment/` - 배포 가이드
- `skills/` - Claude Code skills

---

## Requirements

- Node.js >= 18
- npm, yarn, or pnpm

---

## Links

- [GitHub Repository](https://github.com/alpoxdev/claude-code)
- [npm Package](https://www.npmjs.com/package/@kood/claude-code)
