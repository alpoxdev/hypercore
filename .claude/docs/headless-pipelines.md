# Headless Pipelines

Claude Code 비대화형(headless) 모드를 활용한 자동화 파이프라인 가이드

---

## 배경

**Usage Report 분석 기반 자동화 기회**:
- "With 1,411 commits and frequent /git-all and /pre-deploy runs, you could chain these into a single deployment script"
- "Also useful for your memory observer pattern - instead of running a separate interactive session, trigger it headlessly"

**핵심 가치**:
- 반복 작업 자동화 (배포, 검증, 분석)
- CI/CD 통합으로 품질 게이트 구축
- Memory Observer 패턴 자동 실행

---

## Headless Mode 개요

### 정의

비대화형(non-interactive) CLI 실행 모드로, 프롬프트를 인자로 전달하여 자동 실행.

### 기본 구문

```bash
claude -p "prompt" --allowedTools "Tool1,Tool2,..." --max-turns N
```

### 사용 시나리오

| 시나리오 | 설명 | 빈도 |
|---------|------|------|
| **배포 자동화** | typecheck → lint → build → commit → push | 매 배포 |
| **Memory Observation** | git diff 분석 → 구조화된 관찰 기록 | 일/주 단위 |
| **코드 품질 검사** | 검증 실패 시 자동 수정 | PR 생성 시 |
| **문서 동기화** | 코드 변경 시 문서 자동 업데이트 | commit 시 |
| **테스트 커버리지** | 테스트 누락 검사 및 생성 | PR 검증 |

---

## 배포 자동화 스크립트

### 기본 배포 파이프라인

```bash
#!/bin/bash
# deploy.sh

claude -p "Run typecheck, eslint, and production build. Fix any errors. Then commit all changes with Korean conventional commit messages and push to dev branch." \
  --allowedTools "Edit,Read,Bash,Write" \
  --max-turns 30
```

**실행**:
```bash
chmod +x deploy.sh
./deploy.sh
```

### 조건부 배포

```bash
#!/bin/bash
# conditional-deploy.sh

# Phase 1: 검증만 수행
claude -p "Run /pre-deploy. Report errors without fixing." \
  --allowedTools "Bash,Read" \
  --max-turns 5

# 검증 성공 시에만 배포
if [ $? -eq 0 ]; then
  echo "✅ Validation passed. Deploying..."

  claude -p "Commit all changes with Korean conventional commit messages and push to dev branch." \
    --allowedTools "Task,Bash" \
    --max-turns 10
else
  echo "❌ Validation failed. Fix errors manually."
  exit 1
fi
```

### 에러 자동 수정 배포

```bash
#!/bin/bash
# auto-fix-deploy.sh

# 최대 3회 재시도
MAX_RETRY=3
RETRY=0

while [ $RETRY -lt $MAX_RETRY ]; do
  claude -p "Run /pre-deploy. If errors found, fix them. Repeat until all checks pass." \
    --allowedTools "Edit,Read,Bash,Write" \
    --max-turns 20

  if [ $? -eq 0 ]; then
    echo "✅ All checks passed. Deploying..."

    claude -p "Commit all changes and push to dev branch." \
      --allowedTools "Task,Bash" \
      --max-turns 10

    exit 0
  fi

  RETRY=$((RETRY+1))
  echo "⚠️  Retry $RETRY/$MAX_RETRY..."
done

echo "❌ Failed after $MAX_RETRY retries."
exit 1
```

---

## Memory Observation 자동화

### 기본 관찰

```bash
#!/bin/bash
# observe.sh

claude -p "Analyze git diff HEAD~3..HEAD and record structured observations about what changed and why. Use Memory Observer pattern." \
  --allowedTools "Read,Bash,Write" \
  --max-turns 10
```

### 주기적 관찰 (Cron)

```bash
# crontab -e
# 매일 오후 6시 실행
0 18 * * * cd /path/to/project && ./observe.sh
```

### 커밋 기반 관찰

```bash
#!/bin/bash
# observe-commit.sh

# 특정 커밋 범위 분석
COMMIT_RANGE="${1:-HEAD~5..HEAD}"

claude -p "Analyze git diff $COMMIT_RANGE. Extract patterns, key decisions, and technical insights. Record in .claude/memory/observations.md" \
  --allowedTools "Read,Bash,Write,Edit" \
  --max-turns 15
```

**실행**:
```bash
./observe-commit.sh HEAD~10..HEAD
```

---

## CI/CD 통합 예시

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [dev]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install dependencies
        run: yarn install

      - name: Validate with Claude
        run: |
          claude -p "Run typecheck, eslint, and build. Report all errors." \
            --allowedTools "Bash,Read" \
            --max-turns 10

      - name: Auto-fix errors
        if: failure()
        run: |
          claude -p "Fix all typecheck and lint errors." \
            --allowedTools "Edit,Read,Bash,Write" \
            --max-turns 20

      - name: Deploy
        run: |
          claude -p "Deploy to production. Commit and push changes." \
            --allowedTools "Task,Bash" \
            --max-turns 10
```

### Pre-push Hook

```bash
#!/bin/bash
# .husky/pre-push

echo "🔍 Running pre-push validation..."

claude -p "Run /pre-deploy. If errors found, fix them and re-run until all checks pass." \
  --allowedTools "Edit,Read,Bash,Write" \
  --max-turns 20

if [ $? -eq 0 ]; then
  echo "✅ Pre-push validation passed."
  exit 0
else
  echo "❌ Pre-push validation failed."
  exit 1
fi
```

**설치**:
```bash
chmod +x .husky/pre-push
```

### Pre-commit Hook

```bash
#!/bin/bash
# .husky/pre-commit

echo "🔍 Linting staged files..."

claude -p "Run eslint on staged files. Fix all errors." \
  --allowedTools "Edit,Bash" \
  --max-turns 10
```

---

## 파이프라인 패턴

### 단일 작업 (Typecheck만)

```bash
claude -p "Run typecheck only. Report errors." \
  --allowedTools "Bash,Read" \
  --max-turns 5
```

### 체인 작업 (Lint → Fix → Commit)

```bash
claude -p "1. Run eslint. 2. Fix all errors. 3. Commit with Korean conventional commit message." \
  --allowedTools "Edit,Bash,Task" \
  --max-turns 20
```

### 조건부 실행 (테스트 실패 시만)

```bash
# 테스트 실행
yarn test

# 실패 시에만 수정
if [ $? -ne 0 ]; then
  claude -p "Fix failing tests." \
    --allowedTools "Edit,Read,Bash" \
    --max-turns 15
fi
```

### Fan-Out (병렬 검증)

```bash
# 병렬 실행
claude -p "Run typecheck." --allowedTools "Bash" --max-turns 5 &
PID1=$!

claude -p "Run eslint." --allowedTools "Bash" --max-turns 5 &
PID2=$!

claude -p "Run build." --allowedTools "Bash" --max-turns 5 &
PID3=$!

# 모두 완료 대기
wait $PID1 $PID2 $PID3

if [ $? -eq 0 ]; then
  echo "✅ All checks passed."
else
  echo "❌ Some checks failed."
  exit 1
fi
```

### Sequential Pipeline (순차 처리)

```bash
#!/bin/bash
# sequential-pipeline.sh

# Step 1: 분석
claude -p "Analyze codebase for potential issues." \
  --allowedTools "Read,Glob,Grep" \
  --max-turns 10

# Step 2: 수정
claude -p "Fix identified issues." \
  --allowedTools "Edit,Write" \
  --max-turns 20

# Step 3: 검증
claude -p "Run /pre-deploy to verify fixes." \
  --allowedTools "Bash" \
  --max-turns 5

# Step 4: 커밋
claude -p "Commit all changes with Korean conventional commit message." \
  --allowedTools "Task,Bash" \
  --max-turns 10
```

---

## 옵션 설명

### --allowedTools

**허용할 도구 목록 (콤마 구분)**

```bash
--allowedTools "Edit,Read,Bash,Write"
```

| 도구 | 설명 | 사용 예시 |
|-----|------|---------|
| **Edit** | 파일 수정 | 에러 수정, 리팩토링 |
| **Read** | 파일 읽기 | 분석, 탐색 |
| **Bash** | Shell 명령 | typecheck, lint, build |
| **Write** | 파일 생성 | 새 파일 생성 |
| **Glob** | 파일 검색 | 패턴 매칭 |
| **Grep** | 내용 검색 | 코드 검색 |
| **Task** | 에이전트 호출 | git-operator, planner |

**최소 권한 원칙**:
```bash
# ❌ 금지: 모든 도구 허용
--allowedTools "Edit,Read,Bash,Write,Glob,Grep,Task"

# ✅ 올바름: 필요한 도구만
--allowedTools "Bash,Read"  # 검증만
--allowedTools "Edit,Bash"  # 수정만
```

### --max-turns

**최대 턴 수 (기본값: 100)**

```bash
--max-turns 10  # 간단한 작업
--max-turns 30  # 복잡한 작업
--max-turns 50  # 매우 복잡한 작업
```

**권장값**:

| 작업 복잡도 | max-turns | 예시 |
|-----------|-----------|------|
| LOW | 5-10 | typecheck, lint (검증만) |
| MEDIUM | 10-20 | 에러 수정, 간단한 구현 |
| HIGH | 20-30 | 배포 파이프라인, 리팩토링 |
| VERY HIGH | 30-50 | 대규모 수정, 자동화 |

### -p (프롬프트)

**실행할 작업 설명**

```bash
# ✅ 올바름: 명확한 지시
-p "Run typecheck. If errors found, fix them and re-run until all checks pass."

# ❌ 금지: 모호한 지시
-p "Check the code."
```

**Best Practices**:
1. 구체적 작업 명시
2. 조건부 로직 포함 (if-then)
3. 종료 조건 명시 (until)
4. 에러 처리 방법 지시

---

## 주의사항

### 자동화 시 안전 고려

| 위험 | 대응책 |
|-----|--------|
| **잘못된 수정** | --max-turns 제한, 검증 단계 분리 |
| **무한 루프** | --max-turns 제한, 타임아웃 설정 |
| **권한 남용** | --allowedTools 최소화 |
| **민감 정보 노출** | .env 파일 제외, --allowedTools 제한 |
| **원격 브랜치 오염** | dev 브랜치만 자동 푸시, main 수동 |

### 에러 핸들링

```bash
#!/bin/bash
# error-handling.sh

set -e  # 에러 발생 시 즉시 종료

# 로그 파일 설정
LOG_FILE="/tmp/claude-headless-$(date +%s).log"

# 에러 트랩
trap 'echo "❌ Error occurred. Check $LOG_FILE for details." >&2' ERR

# 실행
claude -p "Run /pre-deploy." \
  --allowedTools "Bash,Read" \
  --max-turns 10 \
  > "$LOG_FILE" 2>&1

echo "✅ Success. Log: $LOG_FILE"
```

### 로그 저장

```bash
#!/bin/bash
# with-logging.sh

# 타임스탬프 로그
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR=".claude/logs"
LOG_FILE="$LOG_DIR/deploy-$TIMESTAMP.log"

mkdir -p "$LOG_DIR"

# 실행 및 로그 저장
claude -p "Run /pre-deploy and fix all errors." \
  --allowedTools "Edit,Read,Bash,Write" \
  --max-turns 30 \
  | tee "$LOG_FILE"

echo "📄 Log saved: $LOG_FILE"
```

---

## 실전 시나리오

### Scenario 1: 완전 자동 배포

```bash
#!/bin/bash
# full-auto-deploy.sh

echo "🚀 Starting automated deployment..."

# Step 1: 검증 및 수정
claude -p "Run /pre-deploy. Fix all errors until all checks pass." \
  --allowedTools "Edit,Read,Bash,Write" \
  --max-turns 30

# Step 2: 커밋 및 푸시
claude -p "Commit all changes with Korean conventional commit messages and push to dev branch." \
  --allowedTools "Task,Bash" \
  --max-turns 10

# Step 3: Memory Observation
claude -p "Analyze recent changes and record observations." \
  --allowedTools "Read,Bash,Write" \
  --max-turns 10

echo "✅ Deployment complete."
```

### Scenario 2: PR 검증 봇

```yaml
# .github/workflows/pr-validation.yml
name: PR Validation

on:
  pull_request:
    branches: [main, dev]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install
        run: yarn install

      - name: Validate
        run: |
          claude -p "Run /pre-deploy. Report all errors in GitHub Actions format." \
            --allowedTools "Bash,Read" \
            --max-turns 10
```

### Scenario 3: 야간 코드 품질 점검

```bash
#!/bin/bash
# nightly-quality-check.sh

# crontab -e
# 0 2 * * * cd /project && ./nightly-quality-check.sh

claude -p "Analyze entire codebase for code smells, security issues, and performance problems. Generate report in .claude/reports/quality-$(date +%Y%m%d).md" \
  --allowedTools "Read,Glob,Grep,Write" \
  --max-turns 50
```

---

## Best Practices

| 원칙 | 적용 |
|------|------|
| **최소 권한** | --allowedTools 필요한 것만 |
| **명확한 프롬프트** | 구체적 작업 + 종료 조건 |
| **에러 핸들링** | set -e, trap ERR |
| **로그 저장** | tee 또는 리다이렉션 |
| **턴 수 제한** | 작업 복잡도에 맞게 |
| **안전 브랜치** | dev만 자동, main 수동 |
| **검증 분리** | 검증 → 수정 → 재검증 |
| **재시도 로직** | MAX_RETRY 설정 |

---

## 참고 자료

- [Claude Code CLI 문서](https://github.com/anthropics/claude-code)
- [GitHub Actions 통합](https://docs.github.com/en/actions)
- [Husky Git Hooks](https://typicode.github.io/husky/)
- [@.claude/instructions/workflow-patterns/phase-based-workflow.md](./../instructions/workflow-patterns/phase-based-workflow.md)
- [@.claude/skills/ralph/SKILL.md](./../skills/ralph/SKILL.md)

---

**작성일**: 2026-02-06
**버전**: 1.0.0
**관련 스킬**: ralph, pre-deploy, git-operator
