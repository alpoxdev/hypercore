# CLAUDE.md - Claude Code Documentation Installer

> @kood/claude-code - 프로젝트에 Claude Code 문서를 설치하는 CLI 도구

<instructions>
@.claude/instructions/git-rules.md
@.claude/instructions/sequential-thinking-guide.md
@.claude/instructions/common-patterns.md
</instructions>

---

<required_tools>

| 도구 | 용도 |
|------|------|
| **Memento MCP** | 세션 시작 시 `read_graph` 필수 |
| **Gemini Review** | 구현 계획/코드 리뷰 (3+ 파일) |
| **ast-grep** | 코드 구조 검색 (rg/grep 대신) |

</required_tools>

---

<project_structure>

```
사용법: npx @kood/claude-code [옵션]
템플릿: tanstack-start | hono | npx
```

```
claude-code/
├── CLAUDE.md
├── packages/claude-code/        # CLI 패키지
│   ├── src/index.ts             # CLI 진입점
│   ├── src/commands/init.ts     # 설치 로직
│   └── templates/               # 빌드 시 docs/ → templates/
└── docs/[템플릿명]/             # 템플릿 소스
    ├── CLAUDE.md
    └── docs/
```

</project_structure>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **Git 커밋** | "Generated with Claude Code", 🤖, "Co-Authored-By:", 여러 줄 |
| **문서 작성** | 장황한 설명, XML 태그 미사용, @imports 없이 중복 |

</forbidden>

---

<required>

**문서 작성 원칙:**
1. 코드 예시 중심, 설명 최소화
2. 복사 가능한 패턴
3. ✅/❌ 마커로 구분
4. 버전 명시 (Zod v4, Prisma v7)
5. @imports로 just-in-time 로딩

**코드 컨벤션:**
```typescript
// ✅ const 함수, 명시적 타입, 절대 경로
const fn = (param: string): ReturnType => { ... }
interface User { ... }  // 객체
type Status = 'a' | 'b' // 유니온
import { ... } from '@/...'

// ❌ any 금지 → unknown
```

</required>

---

<document_structure>

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

</document_structure>

---

<quick_commands>

```bash
npx @kood/claude-code --list              # 템플릿 목록
npx @kood/claude-code                     # 설치 (대화형)
npx @kood/claude-code -t tanstack-start   # 특정 템플릿
npx @kood/claude-code -t tanstack-start,hono  # 다중 템플릿
npx @kood/claude-code -t hono -f          # 강제 덮어쓰기
npx @kood/claude-code -t hono -s          # Skills 포함
npx @kood/claude-code -t hono -c          # Commands 포함
```

</quick_commands>

---

<development>

```bash
# 개발
yarn install && yarn build
cd packages/claude-code && yarn dev

# 배포
cd packages/claude-code && npm publish
```

**빌드:** `tsup (src/ → dist/)` → `copy-templates (docs/ → templates/)`

**버전 업데이트:**
1. `package.json` version 수정
2. `src/index.ts` version 동기화
3. 커밋: `chore: 버전 X.X.X로 업데이트`

</development>
