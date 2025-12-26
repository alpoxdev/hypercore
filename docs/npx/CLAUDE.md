# CLAUDE.md - NPX CLI 프로젝트

> Node.js CLI 도구 개발 지침

## Instructions

@docs/library/commander/index.md
@docs/library/fs-extra/index.md
@docs/library/prompts/index.md

---

## 금지 사항

### Git 커밋
- `Generated with Claude Code` 포함 금지
- AI 관련 이모지/표시 금지
- `Co-Authored-By:` 헤더 금지
- 여러 줄 커밋 메시지 금지

### CLI 구현
- `process.exit()` 없이 에러 종료 금지
- `console.log` 직접 사용 금지 (logger 사용)
- 동기 파일 작업 (`fs.readFileSync` 등) 금지
- hardcoded 경로 금지 (`path.join` 사용)
- 사용자 입력 미검증 처리 금지

### 코드 검색
- `grep`, `rg` 사용 금지 → `ast-grep` 필수

---

## 필수 사항

### 작업 전
| 작업 | 참조 문서 |
|------|----------|
| CLI 작업 | `docs/library/commander/` |
| 파일 작업 | `docs/library/fs-extra/` |
| 사용자 입력 | `docs/library/prompts/` |

### 커밋 형식
```
<prefix>: <설명>
```

| Prefix | 용도 |
|--------|------|
| feat | 새 기능 |
| fix | 버그 수정 |
| refactor | 리팩토링 |
| docs | 문서 수정 |
| chore | 빌드/설정 |

---

## Tech Stack

| 기술 | 버전 | 비고 |
|------|------|------|
| Node.js | >= 18 | ESM 모듈 |
| TypeScript | 5.x | strict mode |
| Commander | 12.x | CLI 프레임워크 |
| fs-extra | 11.x | 파일 시스템 |
| prompts | 2.x | Interactive prompts |
| picocolors | 1.x | 터미널 색상 |
| tsup | 8.x | 번들러 |

---

## Directory Structure

```
src/
├── index.ts          # CLI 진입점
├── commands/         # 명령어 모듈
│   └── init.ts
├── utils/            # 유틸리티
│   ├── copy.ts
│   └── logger.ts
└── types/            # 타입 정의

templates/            # 템플릿 (빌드 시 복사)
scripts/              # 빌드 스크립트
dist/                 # 빌드 결과물
```

---

## 참조

| 문서 | 경로 |
|------|------|
| Commander 가이드 | [docs/library/commander/](docs/library/commander/index.md) |
| fs-extra 가이드 | [docs/library/fs-extra/](docs/library/fs-extra/index.md) |
| prompts 가이드 | [docs/library/prompts/](docs/library/prompts/index.md) |
| 코드 패턴 | [docs/references/patterns.md](docs/references/patterns.md) |
