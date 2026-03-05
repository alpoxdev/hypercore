---
name: git-commit
description: 'Conventional Commits 규칙 기반으로 변경사항을 분석하고, 지능형 스테이징 및 커밋 메시지 생성을 수행합니다. 사용자가 커밋 요청, git commit 생성 요청, 또는 "/git-commit"을 언급할 때 사용합니다. 지원 기능: (1) 변경사항 기반 type/scope 자동 감지, (2) diff 기반 conventional commit 메시지 생성, (3) type/scope/description 선택적 오버라이드가 가능한 인터랙티브 커밋, (4) 논리적 그룹화를 위한 지능형 파일 스테이징'
license: MIT
allowed-tools: Bash
---

# Conventional Commit 기반 Git Commit

## 개요

Conventional Commits 명세를 사용해 표준화된 의미 있는 git 커밋을 생성합니다. 실제 diff를 분석해 적절한 type, scope, message를 결정합니다.

## Conventional Commit 형식

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit 타입

| Type       | 용도                           |
| ---------- | ------------------------------ |
| `feat`     | 신규 기능                       |
| `fix`      | 버그 수정                       |
| `docs`     | 문서 변경만                     |
| `style`    | 포맷/스타일 변경(로직 변경 없음) |
| `refactor` | 리팩터링(기능 추가/버그 수정 아님) |
| `perf`     | 성능 개선                        |
| `test`     | 테스트 추가/수정                |
| `build`    | 빌드 시스템/의존성 변경         |
| `ci`       | CI/설정 변경                    |
| `chore`    | 유지보수/기타 작업              |
| `revert`   | 커밋 되돌리기                   |

## Breaking Changes

```
# type/scope 뒤 느낌표 사용
feat!: remove deprecated endpoint

# BREAKING CHANGE footer 사용
feat: allow config to extend other configs

BREAKING CHANGE: `extends` key behavior changed
```

## 워크플로우

### 1. Diff 분석

```bash
# 스테이징된 파일이 있으면 staged diff 사용
git diff --staged

# 스테이징된 파일이 없으면 working tree diff 사용
git diff

# 상태도 함께 확인
git status --porcelain
```

### 2. 파일 스테이징(필요 시)

아무것도 스테이징되지 않았거나, 변경을 다른 논리 단위로 나누고 싶다면:

```bash
# 특정 파일 스테이징
git add path/to/file1 path/to/file2

# 패턴 기반 스테이징
git add *.test.*
git add src/components/*

# 인터랙티브 스테이징
git add -p
```

**비밀 정보는 절대 커밋하지 않습니다** (`.env`, `credentials.json`, private key 등).

### 3. 커밋 메시지 생성

diff를 분석해서 다음을 결정합니다.

- **Type**: 어떤 종류의 변경인가?
- **Scope**: 어떤 영역/모듈이 영향을 받는가?
- **Description**: 변경 요약 1줄(현재형, 명령형, 72자 이내)

### 4. 커밋 실행

```bash
# 한 줄 커밋
git commit -m "<type>[scope]: <description>"

# 본문/푸터 포함 멀티라인 커밋
git commit -m "$(cat <<'EOCOMMIT'
<type>[scope]: <description>

<optional body>

<optional footer>
EOCOMMIT
)"
```

## 베스트 프랙티스

- 하나의 논리적 변경만 한 커밋에 담기
- 현재형 사용: "added" 대신 "add"
- 명령형 사용: "fixes bug" 대신 "fix bug"
- 이슈 참조: `Closes #123`, `Refs #456`
- description은 72자 이내 유지

## Git 안전 수칙

- git config를 임의로 변경하지 않기
- 명시적 요청 없이는 파괴적 명령(`--force`, hard reset 등) 금지
- 사용자가 요청하지 않으면 hook 우회(`--no-verify`) 금지
- main/master 브랜치에 force push 금지
- `Co-authored-by:` 푸터나 작성자 이메일을 자동으로 추가하지 않기(사용자가 명시적으로 요청한 경우에만 추가)
- hook 실패 시 수정 후 새 커밋 생성(기존 커밋 amend 금지)
