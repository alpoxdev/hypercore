---
name: command-creator
description: 슬래시 커맨드 생성 가이드. 새 커맨드를 만들거나 기존 커맨드를 수정할 때 사용. (project)
license: Complete terms in LICENSE.txt
---

# Command Creator

Claude Code 확장을 위한 슬래시 커맨드 생성 가이드.

## 커맨드 개요

커맨드는 재사용 가능한 프롬프트 단축키. `/command-name`으로 호출.

### 커맨드 제공 요소

| 요소 | 설명 |
|------|------|
| 재사용 프롬프트 | 슬래시 커맨드로 트리거 |
| 도구 권한 | 워크플로우별 사전 설정 |
| 인수 지원 | 호출 시 동적 값 전달 |
| 컨텍스트 주입 | 파일 또는 셸 출력 자동 포함 |

### 커맨드 vs 스킬

| 특성 | 커맨드 | 스킬 |
|------|--------|------|
| 구조 | 단일 `.md` 파일 | `SKILL.md` + 번들 리소스 |
| 복잡도 | 간단한 프롬프트 | 다단계 워크플로우 |
| 리소스 | 없음 | scripts, references, assets |
| 용도 | 빠른 단축키 | 도메인 전문성 |

### 커맨드 구조

```
command-name.md
├── YAML frontmatter (선택)
│   ├── description: (권장)
│   ├── allowed-tools: (선택)
│   ├── argument-hint: (선택)
│   ├── model: (선택)
│   └── disable-model-invocation: (선택)
└── Markdown 지침 (필수)
```

### 파일 위치

| 위치 | 경로 | 범위 |
|------|------|------|
| 프로젝트 | `.claude/commands/` | git으로 팀 공유 |
| 개인 | `~/.claude/commands/` | 개인 전용 |

이름 충돌 시 프로젝트 커맨드 우선.

### Frontmatter 필드

| 필드 | 목적 | 기본값 |
|------|------|--------|
| `description` | 설명 (/help에 표시) | 첫 줄 |
| `allowed-tools` | 허용 도구 | 대화 상속 |
| `argument-hint` | 인수 힌트 (자동완성) | 없음 |
| `model` | 사용 모델 | 대화 상속 |
| `disable-model-invocation` | SlashCommand 도구 사용 방지 | false |

### 명명 규칙

- 파일명 = 커맨드명: `security-check.md` → `/security-check`
- hyphen-case (소문자, 숫자, 하이픈만)
- 최대 40자 권장

## 생성 프로세스

### 1단계: 목적 파악

질문:
- "어떤 작업을 자동화하나?"
- "어떤 인수가 필요하나?"
- "어떤 도구를 허용해야 하나?"
- "프로젝트용인가 개인용인가?"

**좋은 예시**: `/review-security`, `/commit-fix`, `/add-tests`, `/explain-error`

### 2단계: 구조 계획

| 요소 | 설명 |
|------|------|
| 인수 | `$ARGUMENTS` (전체), `$1`, `$2` (위치별) |
| 도구 | `Bash(git:*)`, `Read`, `Write`, `Edit` 등 |
| 컨텍스트 | `@filepath` (파일), `` `command` `` (셸 출력) |

### 3단계: 초기화

```bash
scripts/init_command.py <command-name> --path <output-directory>
```

옵션: `--project` (기본), `--personal`

### 4단계: 편집

**작성 스타일**: 명령형 사용 ("코드 검토" ← "코드를 검토해 주세요" ❌)

**예시 패턴**:

인수 사용:
```markdown
---
description: 커밋 생성
argument-hint: <type> <message>
allowed-tools: Bash(git add:*), Bash(git commit:*)
---

타입 "$1", 메시지 "$2"로 커밋 생성.
형식: <type>: <message>
```

파일 컨텍스트:
```markdown
---
description: 보안 검토
allowed-tools: Read
---

보안 취약점 검토:
@$ARGUMENTS

체크: SQL 인젝션, XSS, 민감 데이터 노출
```

셸 출력:
```markdown
---
description: git 상태 설명
allowed-tools: Bash(git:*)
---

현재 상태:
!`git status`

최근 커밋:
!`git log --oneline -5`

저장소 상태 설명.
```

### 5단계: 패키징

```bash
scripts/package_command.py <path/to/commands-folder> [output-directory]
```

### 6단계: 반복

사용 → 문제 발견 → 수정 → 재테스트

## Subagent 활용

커맨드 생성 시 subagent를 활용하여 메인 컨텍스트 보호.

### 활용 시점

```
1. Explore agent → 기존 커맨드 패턴 분석
2. Explore agent → 관련 워크플로우 파악
3. Plan agent → 커맨드 구조 설계
4. 메인 에이전트 → 설계 기반 작성
```

### 프롬프트 예시

```
Explore agent에게:
"프로젝트의 기존 커맨드들을 분석하고 보고해줘:
- 커맨드 목록 및 용도
- 공통 패턴 (인수, 도구 권한)
- 네임스페이스 구조"
```

```
Plan agent에게:
"새 커맨드 구조 설계:
- 목적 및 사용 시나리오
- 필요 인수
- 허용 도구
- 컨텍스트 주입 방식"
```

## 빠른 참조

### 인수 문법

| 문법 | 설명 | 예시 |
|------|------|------|
| `$ARGUMENTS` | 전체 인수 | `/cmd foo bar` → `foo bar` |
| `$1`, `$2` | 위치 인수 | `/cmd foo bar` → `$1=foo`, `$2=bar` |

### 컨텍스트 주입

| 문법 | 설명 |
|------|------|
| `@filepath` | 파일 내용 포함 |
| `` `command` `` | 셸 출력 포함 |

### 도구 패턴

| 패턴 | 설명 |
|------|------|
| `Bash(git:*)` | 모든 git 명령 |
| `Bash(npm:*)` | 모든 npm 명령 |
| `Read`, `Write`, `Edit` | 파일 작업 |
| `WebFetch` | 웹 콘텐츠 가져오기 |

### 네임스페이싱

하위 디렉토리로 구성:
- `.claude/commands/frontend/component.md` → `/component` (project:frontend)
- `.claude/commands/backend/test.md` → `/test` (project:backend)

## 체크리스트

### 계획 단계

- [ ] 목적 명확히 정의
- [ ] 필요 인수 파악
- [ ] 허용 도구 결정
- [ ] 프로젝트/개인 범위 결정

### 작성 단계

- [ ] 명령형 작성
- [ ] description 추가
- [ ] 인수 힌트 설정 (필요 시)
- [ ] 도구 권한 최소화
- [ ] 컨텍스트 주입 설정

### 검증 단계

- [ ] 다양한 인수로 테스트
- [ ] 권한 오류 확인
- [ ] 팀 공유 시 git 커밋

## 참조

- [Claude Code Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
