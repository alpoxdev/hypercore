# CLAUDE.md - Claude Code Documentation Installer

> @kood/claude-code - 프로젝트에 Claude Code 문서를 설치하는 CLI 도구

## 필수 도구

### Memento MCP
**세션 시작 시 `read_graph` 필수 실행**

| Tool | 용도 |
|------|------|
| `read_graph` | 전체 그래프 조회 (세션 시작) |
| `create_entities` | 새 엔티티 생성 |
| `add_observations` | 기존 엔티티에 관찰 추가 |
| `create_relations` | 엔티티 간 관계 생성 |
| `search_nodes` | 텍스트 검색 |

### Gemini Review
`gemini-review` 스킬 사용 시점:
- 구현 계획 수립 후
- 복잡한 코드 변경 완료 후
- 아키텍처 결정 시
- 버그 수정/리팩토링 후

### ast-grep
**코드 검색 시 `rg`/`grep` 대신 필수 사용**

```bash
ast-grep --lang <언어> -p '<패턴>'

# 예시
ast-grep --lang typescript -p 'function $NAME($_) { $$$ }'
ast-grep --lang typescript -p 'const $NAME = ($$$) => { $$$ }'
ast-grep --lang typescript -p 'class $NAME { $$$ }'
```

## 프로젝트

```
사용법: npx @kood/claude-code [옵션]
템플릿: tanstack-start | hono | npx
```

```
claude-code/
├── CLAUDE.md
├── package.json                 # 루트 워크스페이스
├── packages/claude-code/        # CLI 패키지
│   ├── src/
│   │   ├── index.ts             # CLI 진입점
│   │   ├── commands/init.ts     # 설치 로직
│   │   └── utils/               # copy.ts, logger.ts
│   └── templates/               # 빌드 시 docs/ → templates/
└── docs/                        # 템플릿 소스
    └── [템플릿명]/
        ├── CLAUDE.md
        └── docs/
```

### 설치 방식
| 선택 | 결과 |
|------|------|
| 단일 템플릿 | `CLAUDE.md` + `docs/` → 루트 |
| 다중 템플릿 | 각 템플릿 → `docs/템플릿명/` |

## 규칙

### 기능 추가
| 대상 | 작업 |
|------|------|
| CLI 기능 | `packages/claude-code/src/` 수정 → `index.ts`에 Commander 옵션 추가 |
| 새 템플릿 | `docs/[템플릿명]/` 생성 (`CLAUDE.md` + `docs/`) → `init.ts` TEMPLATE_DESCRIPTIONS 추가 |

### 문서 작성
```
docs/[템플릿명]/
├── CLAUDE.md                  # 필수 규칙 + 빠른 참조
└── docs/
    ├── library/[라이브러리]/   # 라이브러리별 사용법
    ├── mcp/                   # MCP 도구 가이드
    ├── skills/                # Claude Code Skills
    ├── commands/              # Claude Code Commands
    ├── deployment/            # 배포 가이드
    └── design/                # UI/UX 가이드
```

원칙:
- 코드 예시 중심, 설명 최소화
- 복사해서 바로 쓸 수 있는 패턴
- ✅/❌ 마커로 올바른/잘못된 예시 구분
- 버전 명시 (Zod v4, Prisma v7 등)

### 코드 컨벤션
```typescript
// ✅ const 함수 선언
const myFunction = (param: string): ReturnType => { ... }

// ✅ 명시적 타입
interface User { ... }  // 객체
type Status = 'a' | 'b' // 유니온

// ✅ 절대 경로 import
import { ... } from '@/utils/...'

// ❌ any 금지 → unknown
```

파일명: `kebab-case.ts` | `[name].service.ts` | `[name].test.ts`

### Git
커밋: `<prefix>: <한글 설명>`

| Prefix | 용도 |
|--------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| docs | 문서 수정 |
| refactor | 리팩토링 |
| chore | 빌드/설정 |

금지: `Generated with Claude Code` | `🤖` | `Co-Authored-By:` | 여러 줄 메시지

## 빌드/배포

```bash
# 개발
yarn install && yarn build
cd packages/claude-code && yarn dev

# 배포
cd packages/claude-code && npm publish
```

빌드: `tsup (src/ → dist/)` → `copy-templates (docs/ → templates/)`

### 버전 업데이트
1. `packages/claude-code/package.json` version 수정
2. `packages/claude-code/src/index.ts` version 동기화
3. 커밋: `chore: 버전 X.X.X로 업데이트`

## Quick Commands

```bash
npx @kood/claude-code --list              # 템플릿 목록
npx @kood/claude-code                     # 설치 (대화형)
npx @kood/claude-code -t tanstack-start   # 특정 템플릿
npx @kood/claude-code -t tanstack-start,hono  # 다중 템플릿
npx @kood/claude-code -t hono -f          # 강제 덮어쓰기
npx @kood/claude-code -t hono -s          # Skills 포함
npx @kood/claude-code -t hono -c          # Commands 포함
```
