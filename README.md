# Hypercore Agent Skills

> Claude Code · Codex · Cursor · Antigravity에서 그대로 쓰는 한국어 우선 AI 에이전트 스킬 모음.

Hypercore는 코드베이스 분석부터 릴리스까지의 반복 작업을 한 번에 줄여주는 28개 스킬을 한 패키지로 제공합니다. 각 스킬은 트리거, 워크플로, 검증 게이트가 명시되어 있어 어떤 CLI에서 호출해도 같은 의도로 동작합니다.

- **드롭인 설치**: Claude Code 마켓플레이스에 한 줄, 다른 CLI에는 `npx skills add` 한 줄.
- **다중 CLI**: Claude Code, Codex, Cursor, Antigravity에서 동일하게 사용.
- **한국어 우선**: 모든 스킬에 한국어 사양이 정렬되어 있으며 영어 원본도 함께 유지.
- **검증 가능한 결과물**: 각 스킬은 evidence/validation/stop-condition 계약을 따라 결과를 남깁니다.

[Vercel Skills](https://github.com/vercel-labs/skills) 구조 위에 만들어졌습니다.

## 호환성

| 런타임 | 설치 경로 | 비고 |
|---|---|---|
| Claude Code | `/plugin marketplace add` + `/plugin install` | 1순위 호환 — 모든 스킬 사용 가능 |
| Codex CLI | `npx skills add ... -a codex` | `claude-code` 스킬을 제외한 모든 스킬 사용 가능 |
| Cursor | `npx skills add ... -a cursor` | 동일 |
| Antigravity 등 기타 | `npx skills add ...` (`-a` 생략 시 기본 대상에 포함) | `npx skills` 가 지원하는 에이전트 |

스킬별 호환은 아래 [스킬 카탈로그](#스킬-카탈로그) 표의 **호환** 컬럼 또는 각 `SKILL.md`의 `compatibility` 필드에서 확인합니다.

## 설치

### Claude Code 마켓플레이스 (권장)

Claude Code 안에서:

```bash
/plugin marketplace add https://github.com/alpoxdev/hypercore
/plugin install hypercore
```

설치가 끝나면 Claude Code가 28개 스킬과 메타데이터를 자동으로 인식합니다. 슬래시 명령으로 곧바로 호출할 수 있습니다 — 예: `/git-maker`, `/readme-maker`, `/research`.

### npx skills add (Codex / Cursor / Antigravity 등)

기본 대상(지원되는 모든 에이전트)에 한 번에 설치:

```bash
npx skills add alpoxdev/hypercore --skill '*' -g -y
```

특정 에이전트만 설치:

```bash
npx skills add alpoxdev/hypercore --skill '*' -a codex -g -y
npx skills add alpoxdev/hypercore --skill '*' -a cursor -g -y
```

특정 스킬만 골라서 설치:

```bash
npx skills add alpoxdev/hypercore --skill git-maker --skill readme-maker -g -y
```

옵션 요약:

- `--skill '*'` — 모든 스킬 설치. `--skill <이름>`을 반복하면 골라서 설치.
- `-g`, `--global` — 사용자 전역 위치에 설치. 생략하면 현재 프로젝트(`.claude/skills/` 등)에만 설치.
- `-a <agent>` — 특정 에이전트만 대상으로. 생략하면 기본 대상 모두.
- `-y` — 확인 프롬프트 건너뜀.

> `npx skills add`의 기본 설치 범위는 **프로젝트 로컬**입니다. 시스템 전역에 등록하려면 `-g`를 명시하세요.

### 소스에서 직접 사용

레포를 클론해 그대로 가져다 써도 됩니다 (CI나 CLI 빌드/실행에는 별도 의존성이 필요하지 않습니다 — 스킬은 모두 마크다운입니다):

```bash
git clone https://github.com/alpoxdev/hypercore.git
# 원하는 스킬 디렉터리를 자신의 프로젝트로 복사
cp -R hypercore/skills/git-maker your-project/.claude/skills/
```

## 빠른 사용 예시

설치 후 자연어로 호출하거나 슬래시 명령으로 시작합니다.

```text
/git-maker            # 변경 사항을 그룹별로 커밋하고 푸시까지 한 번에
/readme-maker         # 코드를 읽고 프로젝트의 실제 모양에 맞는 README 생성/리팩터
/research "<주제>"    # 출처가 있는 다중 소스 리서치 보고서
/prd-maker "<아이디어>"  # 다이어그램·플로우·와이어프레임을 포함한 기획 패키지
/pre-deploy           # 배포 전 lint/타입/빌드 게이트
```

자연어로도 트리거됩니다 — 예: "이 프로젝트 README 다시 써줘" → `readme-maker`, "방금 변경 사항 커밋하고 푸시" → `git-maker`.

## 스킬 카탈로그

용도별 분류입니다. 같은 스킬이 둘 이상의 그룹에 어울릴 수 있습니다.

### 스킬·문서 작성

| 스킬 | 설명 | 호환 |
|------|------|------|
| `skill-maker` | 유지보수하기 쉬운 Codex/AI 에이전트 스킬 생성 및 리팩터링 | All |
| `skill-tester` | 스킬 트리거/동작을 시나리오 기반으로 검증 | All |
| `autoresearch-skill` | 반복 실행과 이진 eval 기반으로 기존 스킬을 자동 최적화 | All |
| `readme-maker` | 코드베이스 분석 기반 README 생성 및 리팩터링 | All |
| `docs-maker` | AI가 읽기 좋은 구조화된 문서/룰 팩 생성 | All |
| `prd-maker` | 증거 기반 Living PRD + 다이어그램·플로우·와이어프레임 생성 | All |

### 아키텍처 가드

| 스킬 | 설명 | 호환 |
|------|------|------|
| `nextjs-architecture` | Next.js App Router 아키텍처 규칙 적용 | All |
| `hono-architecture` | Hono 아키텍처 규칙 적용 | All |
| `tanstack-start-architecture` | TanStack Start 아키텍처 규칙 적용 | All |
| `tanstack-start-security` | TanStack Start 인증/세션/보안 규칙 적용 | All |
| `vite-architecture` | Vite + TanStack Router 아키텍처 규칙 적용 | All |

### 빌드 · 배포 · 릴리스

| 스킬 | 설명 | 호환 |
|------|------|------|
| `pre-deploy` | 배포 전 lint/타입/빌드 검증 | All |
| `deploy-fix` | 빌드/CI/배포 장애 진단 및 수정 | All |
| `version-update` | 시맨틱 버전 업데이트 및 릴리스 | All |
| `autoresearch-code` | 반복 실험·이진 eval 기반 코드베이스 자동 최적화 | All |

### Git 워크플로

| 스킬 | 설명 | 호환 |
|------|------|------|
| `git-commit` | Conventional Commits 기반 커밋 생성 | All |
| `git-push` | 미푸시 커밋을 안전하게 리모트로 푸시 | All |
| `git-maker` | 커밋과 푸시를 한 번에 (worktree 인지) | All |
| `git-worktree` | Git worktree 생성/진입/정리, 병렬 에이전트 워크스페이스 관리 | All |

### 리서치 · 디버깅 · QA

| 스킬 | 설명 | 호환 |
|------|------|------|
| `research` | 다중 소스, 출처 추적 가능한 마크다운 리서치 보고서 | All |
| `qa` | 비개발자 이해관계자 요청 분석 및 기술 해석 후 구현 | All |
| `bug-fix` | 버그 분석 → 수리 옵션 제시 → 검증된 구현 | All |
| `crawler` | Playwright + CDP 기반 웹 크롤링 플로우 설계 및 코드 생성 | All |

### 콘텐츠 · SEO

| 스킬 | 설명 | 호환 |
|------|------|------|
| `seo-maker` | SEO / AEO / GEO 통합 분석 및 최적화 리포트 | All |

### 실행 보조

| 스킬 | 설명 | 호환 |
|------|------|------|
| `execute` | 난이도 적응형 사고 깊이로 즉시 작업 수행 | All |

### 외부 CLI 브리지

| 스킬 | 설명 | 호환 |
|------|------|------|
| `claude-code` | Anthropic Claude Code CLI 실행 및 세션 관리 | Claude |
| `gemini` | Google Gemini CLI 실행 및 세션 관리 | Gemini |

### 도메인 도구

| 스킬 | 설명 | 호환 |
|------|------|------|
| `color-cli` | `@kood/color-cli` 기반 hex / rgb / oklch 색상 변환 | All |

총 28개 스킬. 새 스킬은 `skills/<이름>/` 디렉터리를 추가하기만 하면 됩니다 — 자세한 형태는 [스킬 만들기](#스킬-만들기) 참고.

## 시나리오 예시

**1) 기존 프로젝트의 README가 오래됐을 때**

```text
이 저장소를 꼼꼼히 읽고 README를 다시 써줘
```

`readme-maker`가 매니페스트, 진입점, 스크립트, 라이선스, 기존 문서를 스캔해 프로젝트 형태(CLI/라이브러리/플러그인 등)에 맞는 섹션을 골라 작성합니다. 명령·API를 지어내지 않고, 모르는 부분은 `<!-- TODO -->`로 표시합니다.

**2) 모은 변경사항을 안전하게 출고**

```text
/git-maker ALL
```

변경을 논리 단위로 묶어 Conventional Commit으로 나눠 커밋하고, 모든 커밋이 성공한 뒤에만 자동으로 푸시합니다. `main`/`master`에 대한 force push는 차단됩니다.

**3) 배포 전 점검**

```text
/pre-deploy
```

lint, typecheck, build, test 같은 프로젝트 게이트를 재현하고, 실패가 있으면 원인을 추적해서 고쳐 다시 검증합니다.

**4) 새 스킬 만들기**

```text
/skill-maker "내가 자주 쓰는 워크플로를 스킬로 만들어줘"
```

`skill-maker`가 트리거 디자인, 리소스 배치, 검증 체크리스트까지 갖춘 스킬 폴더를 만들어 냅니다. 이후 `autoresearch-skill`로 baseline-first 반복 최적화를 돌릴 수 있습니다.

## 프로젝트 구조

```text
hypercore/
├── .claude-plugin/        # Claude Code 마켓플레이스 매니페스트 (plugin.json, marketplace.json)
├── agents/                # 사용자 정의 에이전트 자리 (현재 비어 있음)
├── cli/                   # @kood/* 도구 모노레포 (pnpm workspace)
│   └── packages/
│       └── color/         # @kood/color-cli — color-cli 스킬이 호출
├── instructions/          # 프로젝트 LLM 작업 베이스 (context/harness/sourcing/validation)
├── scripts/               # 보조 스크립트
└── skills/                # 28개 스킬 (각 폴더에 SKILL.md / SKILL.ko.md)
```

스킬 한 개의 표준 구조:

```text
skills/<name>/
├── SKILL.md               # 영어 정본 — 트리거, 워크플로, 검증
├── SKILL.ko.md            # 한국어 번역
├── rules/                 # 재사용 가능한 정책/체크리스트 (옵션)
├── references/            # 외부 도큐먼트, 스키마, 깊은 디테일 (옵션)
├── scripts/               # 결정적 실행 헬퍼 (옵션)
└── assets/                # 출력 템플릿/리소스 (옵션)
```

## 스킬 만들기

직접 스킬을 만들고 싶다면:

1. `/skill-maker "<설명>"` — 빈 폴더부터 lean한 `SKILL.md`까지 한 번에.
2. `/autoresearch-skill <skill-path>` — 만들어진 스킬을 반복 실험으로 점수가 올라가지 않을 때까지 자동 최적화.
3. 영어 정본(`SKILL.md`) 옆에 한국어 번역(`SKILL.ko.md`)을 함께 유지하세요.
4. PR로 올리면 자동으로 마켓플레이스 카탈로그에 합류합니다.

세부 설계 가이드는 [`skills/skill-maker/SKILL.md`](skills/skill-maker/SKILL.md)와 [`instructions/`](instructions/)를 참고하세요.

## 인스트럭션 베이스

`instructions/` 폴더에는 모든 스킬이 따르는 공통 작업 원칙이 정리되어 있습니다.

| 영역 | 위치 | 목적 |
|---|---|---|
| Context Engineering | [`instructions/context-engineering/`](instructions/context-engineering/) | 프롬프트·컨텍스트·도구 지시를 런타임 중립으로 설계 |
| Harness Engineering | [`instructions/harness-engineering/`](instructions/harness-engineering/) | 프롬프트·에이전트·도구 사용을 테스트 가능한 하네스로 관리 |
| Sourcing | [`instructions/sourcing/`](instructions/sourcing/) | 자료 조사·검색·출처 검증 기준 |
| Validation | [`instructions/validation/`](instructions/validation/) | 작업 완료 전 검증 기준 |

자세한 적용 순서는 [`instructions/README.md`](instructions/README.md).

## 개발

CLI 패키지(`cli/`)만 빌드/테스트가 필요합니다. 스킬은 모두 마크다운이므로 빌드 단계가 없습니다.

```bash
pnpm install            # cli/ 워크스페이스 의존성 설치
pnpm -C cli build       # 모든 cli 패키지 빌드 (현재: @kood/color-cli)
pnpm -C cli test        # 모든 cli 패키지 테스트
pnpm -C cli lint        # ESLint 9
pnpm -C cli format      # Prettier
```

새 스킬을 추가했을 때:

1. 마켓플레이스 카탈로그에 영향이 있다면 [README의 스킬 표](#스킬-카탈로그)와 매니페스트 키워드를 갱신.
2. `skill-tester`로 트리거/동작을 검증.
3. `autoresearch-skill`로 점수 plateau까지 다듬는 것을 권장.

## 기여

PR 환영합니다. 작업 흐름:

1. 이슈를 열거나 기존 이슈에 의도를 적습니다 (한국어/영어 모두 환영).
2. 새 브랜치에서 변경 후 `git-maker` 또는 `git-commit`으로 Conventional Commits를 생성합니다.
3. 스킬 변경은 `SKILL.md`(영어 정본)와 `SKILL.ko.md`(한국어 번역)을 함께 갱신합니다.
4. 가능하면 `skill-tester`나 `autoresearch-skill`의 검증 결과를 PR 본문에 첨부해 주세요.
5. 큰 구조 변경은 [AGENTS.md](AGENTS.md)의 작업 원칙(작은 변경, 되돌리기 쉬움, 전역 환경 비의존)을 따릅니다.

## 라이선스

[MIT](LICENSE) © alpoxdev. `.claude-plugin/plugin.json`에도 선언되어 있습니다.

## 감사

- [Vercel Skills](https://github.com/vercel-labs/skills) — 패키지 구조와 `npx skills add` 워크플로의 기반.
- Claude Code · Codex · Cursor · Antigravity 팀의 스킬/플러그인 표면.
- 모든 컨트리뷰터 — 자세한 목록은 [GitHub Contributors](https://github.com/alpoxdev/hypercore/graphs/contributors).
