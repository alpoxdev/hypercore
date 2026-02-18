# @kood/claude-code

Claude Code 프로젝트에 표준화된 문서(CLAUDE.md), 에이전트, 스킬, 커맨드를 설치하는 NPX CLI 도구.

Claude Code는 `CLAUDE.md`와 `.claude/` 디렉토리에서 지침을 읽어 코딩 규칙을 따른다. 이 도구는 프레임워크별 지침과 AI 에이전트 구성을 한 번에 설치해준다.

## 빠른 시작

```bash
npx @kood/claude-code
```

대화형 프롬프트가 실행되어 템플릿과 옵션을 선택할 수 있다.

## 모노레포 구조

```
claude-code/
├── packages/
│   ├── claude-code/          # NPX CLI 도구 (핵심 패키지)
│   └── firecrawl-searxng/    # Firecrawl + SearXNG + Jina Reader 셀프호스팅
├── .claude/
│   ├── agents/               # 26개 전문 에이전트 정의
│   ├── skills/               # 28개 재사용 스킬
│   ├── commands/             # 6개 슬래시 커맨드
│   ├── instructions/         # 17개 공통 지침
│   └── scripts/              # git, deploy, lint 스크립트
└── package.json              # Yarn 4 Workspaces
```

## 기술 스택

| 분류 | 기술 |
|------|------|
| 언어 | TypeScript 5.x (strict) |
| 런타임 | Node.js >= 18 (ESM) |
| CLI | Commander.js |
| 빌드 | tsup |
| 패키지 매니저 | Yarn 4.12.0 (Berry) |
| Lint | ESLint 9.x + Prettier 3.x |
| Git Hook | Husky + lint-staged |

---

## packages/claude-code

### 설치 및 실행

```bash
# 대화형 모드
npx @kood/claude-code

# 특정 템플릿 설치
npx @kood/claude-code -t tanstack-start

# 다중 템플릿 설치
npx @kood/claude-code -t tanstack-start,hono

# 사용자 홈 디렉토리에 설치 (모든 프로젝트에서 공유)
npx @kood/claude-code --scope user --skills --commands --agents

# 사용 가능한 템플릿 목록 확인
npx @kood/claude-code --list
```

### CLI 옵션

| 옵션 | 단축 | 설명 |
|------|------|------|
| `--template <names>` | `-t` | 설치할 템플릿 (콤마 구분) |
| `--force` | `-f` | 기존 파일 덮어쓰기 |
| `--cwd <path>` | | 대상 디렉토리 (기본: 현재 디렉토리) |
| `--list` | | 사용 가능한 템플릿 목록 출력 |
| `--skills` | `-s` | `.claude/skills/` 에 스킬 설치 |
| `--commands` | `-c` | `.claude/commands/` 에 커맨드 설치 |
| `--agents` | `-a` | `.claude/agents/` 에 에이전트 설치 |
| `--sync-codex` | | Codex AI 설정 동기화 |
| `--scope <scope>` | | 설치 범위: `project` 또는 `user` |

### 프레임워크 템플릿

각 템플릿은 `CLAUDE.md`(지침) + `docs/`(상세 라이브러리 문서)로 구성된다.

| 템플릿 | 스택 |
|--------|------|
| `tanstack-start` | React, TanStack Router/Query, Prisma 7, Better Auth, Tailwind 4 |
| `hono` | Hono, Cloudflare Workers, Prisma 7, Zod 4 |
| `npx` | Node.js ESM, Commander.js, fs-extra, prompts |
| `tauri` | Tauri 2, Rust, React 19, Vite |

### 설치 흐름

```
1. 대상 디렉토리 검증
2. 설치 범위 선택 (project → CWD / user → ~/.claude/)
3. 템플릿 선택 (CLI 인자 또는 대화형 프롬프트)
4. 기존 파일 덮어쓰기 확인
5. 템플릿 파일 복사 (CLAUDE.md + docs/)
6. Extras 설치 (skills, commands, agents, instructions, scripts)
7. Codex 동기화 (선택)
8. .gitignore 자동 업데이트
```

### Codex 동기화

`--sync-codex` 사용 시 Claude Code 설정을 OpenAI Codex 포맷으로 변환한다:

- `.claude/skills/` → `.codex/skills/`
- `.claude/commands/` → `.codex/skills/claude-commands/` (SKILL.md 포맷)
- `.claude/instructions/` → `.codex/instructions/`
- MCP 서버 설정 → `.codex/config.toml` (TOML 포맷)

### 에이전트 (26개)

설치되는 전문 에이전트 예시:

| 에이전트 | 역할 |
|---------|------|
| `analyst` | 요구사항 분석 (READ-ONLY) |
| `architect` | 아키텍처 고문 (READ-ONLY) |
| `planner` | 구현 계획 수립 |
| `implementation-executor` | Sequential Thinking 기반 구현 |
| `code-reviewer` | 코드 리뷰 |
| `security-reviewer` | 보안 검토 |
| `designer` | UI/UX 디자인 |
| `build-fixer` | 빌드 에러 수정 |
| `lint-fixer` | Lint 에러 수정 |
| `pm` | 팀 오케스트레이션 |

### 커맨드 (6개)

| 커맨드 | 설명 |
|--------|------|
| `git-all` | 전체 변경사항 커밋 + 푸시 |
| `git-session` | 현재 세션 파일만 커밋 + 푸시 |
| `lint-fix` | tsc + eslint 검사 및 수정 |
| `lint-init` | ESLint flat config 초기화 |
| `pre-deploy` | 배포 전 typecheck/lint/build 검증 |
| `version-update` | 프로젝트 버전 업데이트 |

### 스킬 (28개)

**개발:** `bug-fix`, `refactor`, `execute`, `figma-to-code`, `codex`
**분석:** `brainstorm`, `plan`, `research`, `prd`, `feedback`
**프레임워크:** `tanstack-start-react-best-practices`, `nextjs-react-best-practices`, `tauri-react-best-practices`
**인프라:** `sql-optimizer`, `project-optimizer`, `design`, `teams`

---

## packages/firecrawl-searxng

Firecrawl + SearXNG + Jina Reader 셀프호스팅 Docker Compose 패키지. Claude Code MCP 서버와 연동하여 로컬 웹 검색/크롤링 인프라를 제공한다.

자세한 내용은 [packages/firecrawl-searxng/README.md](packages/firecrawl-searxng/README.md) 참조.

---

## 개발

```bash
# 의존성 설치
yarn install

# 전체 빌드
yarn build

# 개발 모드
yarn dev

# Lint
yarn lint

# 포맷
yarn format
```

## 라이선스

MIT
