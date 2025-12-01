# CLAUDE.md - Claude Code Instructions

> NPX CLI 도구 프로젝트 작업 지침

---

## 🚨 STOP - 작업 전 필수 확인

```
┌─────────────────────────────────────────────────────────────┐
│  이 프로젝트에서 작업하기 전에 이 문서를 끝까지 읽으세요.  │
│  특히 ⛔ NEVER DO 섹션의 규칙은 절대 위반하지 마세요.      │
│                                                             │
│  📖 작업 유형별 상세 문서: docs/ 폴더 참조                  │
└─────────────────────────────────────────────────────────────┘
```

---

## ⛔ NEVER DO (절대 금지 - 예외 없음)

### Git 커밋 금지 사항
```
❌ "Generated with Claude Code" 포함 금지
❌ "🤖" 또는 AI 관련 이모지 포함 금지
❌ "Co-Authored-By:" 헤더 포함 금지
❌ AI/봇이 작성했다는 어떤 표시도 금지
❌ 커밋 메시지 여러 줄 작성 금지
❌ 커밋 메시지에 이모지 사용 금지
```

### CLI 구현 금지 사항
```
❌ process.exit() 없이 에러 상황 종료 금지
❌ console.log 직접 사용 금지 (logger 사용)
❌ 동기 파일 작업 (fs.readFileSync 등) 금지
❌ hardcoded 경로 사용 금지 (path.join 사용)
❌ 사용자 입력 검증 없이 처리 금지
```

### 코드 검색 금지 사항
```
❌ grep, rg 등 기본 검색 도구 사용 금지
❌ find 명령어로 코드 검색 금지
✅ 코드베이스 검색 시 sgrep 사용 필수
```

---

## ✅ ALWAYS DO (필수 실행)

### 1. 작업 전: 관련 문서 읽기
```
CLI 작업      → docs/library/commander/ 읽기
파일 작업     → docs/library/fs-extra/ 읽기
사용자 입력   → docs/library/prompts/ 읽기
```

### 2. MCP 도구 적극 활용
```
코드베이스 검색     → sgrep 사용 (grep/rg 금지)
복잡한 분석/디버깅  → Sequential Thinking 사용
라이브러리 문서     → Context7 사용
```
**상세**: `docs/mcp/` 참고

### 3. 작업 완료 후: Git 커밋
```bash
git add .
git commit -m "<prefix>: <설명>"
```

**커밋 형식**: `<prefix>: <설명>` (한 줄, 본문 없음)

**Prefix**: `feat` | `fix` | `refactor` | `style` | `docs` | `test` | `chore` | `perf` | `ci`

**예시**:
```bash
feat: 템플릿 복사 기능 추가
fix: 경로 처리 오류 수정
docs: README 업데이트
```

---

## 📚 문서 참조 테이블

| 작업 | 문서 경로 | 필독 여부 |
|------|----------|----------|
| **Git 규칙** | `docs/git/git.md` | 🔴 필수 |
| **MCP 도구** | `docs/mcp/` | 🔴 필수 |
| **Commander** | `docs/library/commander/` | 🔴 필수 |
| **fs-extra** | `docs/library/fs-extra/` | 🔴 필수 |
| **prompts** | `docs/library/prompts/` | 🔴 필수 |

---

## 🛠 Tech Stack (버전 주의)

| 기술 | 버전 | 주의사항 |
|------|------|----------|
| Node.js | >= 18 | ESM 모듈 사용 |
| TypeScript | 5.x | strict mode |
| Commander | 12.x | CLI 프레임워크 |
| fs-extra | 11.x | 파일 시스템 유틸리티 |
| prompts | 2.x | Interactive CLI prompts |
| picocolors | 1.x | 터미널 색상 출력 |
| tsup | 8.x | TypeScript 번들러 |

---

## 📁 Directory Structure

```
src/
├── index.ts              # Entry point (CLI 정의)
├── commands/             # 명령어 모듈
│   └── init.ts           # init 명령어
├── utils/                # 유틸리티
│   ├── copy.ts           # 파일 복사 유틸
│   └── logger.ts         # 로깅 유틸
└── types/                # 타입 정의
    └── index.ts          # 공통 타입

templates/                # 템플릿 파일 (빌드 시 복사)
scripts/                  # 빌드 스크립트
dist/                     # 빌드 결과물
```

---

## 🔧 Code Conventions

### File Naming
- **kebab-case**: `copy-template.ts`, `file-utils.ts`
- **index.ts**: 모듈 진입점

### TypeScript
- `const` 선언 사용 (function 대신)
- 명시적 return type
- `interface` (객체) / `type` (유니온)
- `any` 금지 → `unknown` 사용

### ESM Module
```typescript
// ✅ ESM import
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

// __dirname 대체
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
```

---

## 📝 Quick Patterns (복사용)

### CLI Entry Point
```typescript
#!/usr/bin/env node
import { Command } from 'commander';

const program = new Command();

program
  .name('my-cli')
  .description('CLI description')
  .version('1.0.0');

program
  .option('-t, --template <name>', 'template name')
  .option('-f, --force', 'overwrite existing files')
  .action(async (options) => {
    // 명령어 실행
  });

program.parse();
```

### Logger 유틸
```typescript
import pc from 'picocolors';

export const logger = {
  info: (msg: string) => console.log(pc.blue('ℹ'), msg),
  success: (msg: string) => console.log(pc.green('✔'), msg),
  warn: (msg: string) => console.log(pc.yellow('⚠'), msg),
  error: (msg: string) => console.log(pc.red('✖'), msg),
  step: (msg: string) => console.log(pc.gray('  →'), msg),
  blank: () => console.log(),
};
```

### Interactive Prompts
```typescript
import prompts from 'prompts';

// Select (단일 선택)
const { template } = await prompts({
  type: 'select',
  name: 'template',
  message: 'Select a template:',
  choices: [
    { title: 'Template A', value: 'a' },
    { title: 'Template B', value: 'b' },
  ],
});

// Multiselect (다중 선택)
const { templates } = await prompts({
  type: 'multiselect',
  name: 'templates',
  message: 'Select templates:',
  choices: [
    { title: 'Template A', value: 'a' },
    { title: 'Template B', value: 'b' },
  ],
  min: 1,
  hint: '- Space to select. Return to submit',
});

// Confirm
const { confirmed } = await prompts({
  type: 'confirm',
  name: 'confirmed',
  message: 'Overwrite existing files?',
  initial: false,
});
```

### File Copy 유틸
```typescript
import fs from 'fs-extra';
import path from 'path';

export const copyRecursive = async (
  src: string,
  dest: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };

  const copy = async (s: string, d: string): Promise<void> => {
    const stat = await fs.stat(s);

    if (stat.isDirectory()) {
      await fs.ensureDir(d);
      counter.directories++;

      const items = await fs.readdir(s);
      for (const item of items) {
        await copy(path.join(s, item), path.join(d, item));
      }
    } else {
      await fs.copy(s, d);
      counter.files++;
    }
  };

  await copy(src, dest);
  return counter;
};
```

### Package.json 설정
```json
{
  "name": "@scope/my-cli",
  "version": "1.0.0",
  "type": "module",
  "bin": "./dist/index.js",
  "files": ["dist", "templates"],
  "scripts": {
    "build": "tsup",
    "dev": "tsup --watch",
    "prepublishOnly": "npm run build"
  },
  "engines": {
    "node": ">=18"
  }
}
```

### tsup.config.ts
```typescript
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm'],
  target: 'node18',
  clean: true,
  dts: true,
  banner: {
    js: '#!/usr/bin/env node',
  },
});
```

---

## 🔗 Quick Links

- [Commander 가이드](./docs/library/commander/index.md)
- [fs-extra 가이드](./docs/library/fs-extra/index.md)
- [prompts 가이드](./docs/library/prompts/index.md)
- [Git 규칙](./docs/git/git.md)
- [MCP 가이드](./docs/mcp/index.md)
