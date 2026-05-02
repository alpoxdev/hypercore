# Hypercore Agent Skills

Claude Code, Codex, Cursor에서 사용할 수 있는 AI 에이전트 스킬 모음입니다.

[Vercel Skills](https://github.com/vercel-labs/skills) 기반으로 제작되었습니다.

## 설치

### Claude Code Marketplace

```bash
/plugin marketplace add https://github.com/alpoxdev/hypercore
/plugin install hypercore
```

### npx skills add

기본 설치 대상(Codex, Cursor, Antigravity 등 지원되는 기본 에이전트)을 함께 설치하려면 `-a` 옵션을 생략합니다.

```bash
npx skills add alpoxdev/hypercore --skill '*' -g -y
```

특정 에이전트만 대상으로 설치해야 할 때만 `-a <agent>`를 추가합니다.

## 스킬 목록

| 스킬 | 설명 | 호환 |
|------|------|------|
| `autoresearch-code` | 반복 실험과 이진 eval 기반으로 코드베이스 자동 최적화 | All |
| `autoresearch-skill` | 반복 실행과 이진 eval 기반으로 기존 스킬을 자동 최적화 | All |
| `bug-fix` | 버그 분석 및 수정 | All |
| `claude-code` | Anthropic Claude Code CLI 실행 및 세션 관리 | Claude |
| `color-cli` | `@kood/color-cli` 기반 hex/rgb/oklch 색상 변환 | All |
| `crawler` | 웹 크롤링 플로우 설계 및 코드 생성 | All |
| `deploy-fix` | 빌드/CI/배포 장애 진단 및 수정 | All |
| `docs-maker` | AI가 읽기 좋은 구조화된 문서 생성 | All |
| `execute` | 난이도 적응형 사고 깊이로 즉시 작업 수행 | All |
| `gemini` | Google Gemini CLI 실행 및 세션 관리 | Gemini |
| `git-commit` | Conventional Commits 기반 커밋 생성 | All |
| `git-maker` | 커밋과 푸시를 한 번에 수행 | All |
| `git-push` | 미푸시 커밋을 리모트에 푸시 | All |
| `git-worktree` | Git worktree 생성/진입/정리 및 병렬 에이전트 워크스페이스 관리 | All |
| `hono-architecture` | Hono 아키텍처 규칙 적용 | All |
| `nextjs-architecture` | Next.js App Router 아키텍처 규칙 적용 | All |
| `prd-maker` | 증거 기반 Living PRD 작성 및 관리 | All |
| `pre-deploy` | 배포 전 품질/빌드 검증 | All |
| `qa` | 비개발자 이해관계자 요청 분석 및 기술 해석 후 구현 | All |
| `readme-maker` | 코드베이스 분석 기반 README 생성 및 리팩터링 | All |
| `research` | 구조화된 리서치 및 보고서 생성 | All |
| `seo-maker` | SEO/AEO/GEO 통합 분석 및 최적화 리포트 생성 | All |
| `skill-maker` | 유지보수하기 쉬운 Codex 스킬 생성 및 리팩터링 | All |
| `skill-tester` | 스킬 트리거/동작을 시나리오 기반으로 검증 | All |
| `tanstack-start-architecture` | TanStack Start 아키텍처 규칙 적용 | All |
| `tanstack-start-security` | TanStack Start 보안 규칙 적용 | All |
| `version-update` | 시맨틱 버전 업데이트 및 릴리스 | All |
| `vite-architecture` | Vite + TanStack Router 아키텍처 규칙 적용 | All |
