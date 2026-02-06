# Claude Code Hooks 설정 가이드

<overview>

Hooks는 도구 호출 전후에 자동으로 실행되는 명령어입니다.

**주요 사용 사례**:
- Edit/Write 후 자동 타입 체크로 버그 조기 발견
- Git 작업 전 자동 lint/test 실행
- 빌드 검증 자동화

**지원 이벤트**:
- `preToolUse`: 도구 실행 전
- `postToolUse`: 도구 실행 후

**설정 위치**: `.claude/settings.json`

</overview>

---

<quick_setup>

## TypeCheck 자동화 (가장 유용)

`.claude/settings.json`에 추가:

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx tsc --noEmit --pretty 2>&1 | head -20"
      }
    ]
  }
}
```

**효과**: Edit/Write 후 자동으로 TypeScript 타입 에러 감지

</quick_setup>

---

<use_cases>

## 유용한 Hook 패턴

### 1. TypeScript 타입 체크

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx tsc --noEmit --pretty 2>&1 | head -20"
      }
    ]
  }
}
```

**장점**: 타입 에러를 즉시 발견

---

### 2. ESLint 검사

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx eslint --max-warnings 0 --format compact 2>&1 | head -15 || true"
      }
    ]
  }
}
```

**장점**: 코드 스타일 문제 조기 발견

---

### 3. Git Commit 전 검증

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Bash.*git commit",
        "command": "npm run lint && npm run typecheck"
      }
    ]
  }
}
```

**장점**: 잘못된 커밋 방지

---

### 4. 빌드 검증

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit.*vite.config",
        "command": "npm run build -- --mode production 2>&1 | tail -10 || true"
      }
    ]
  }
}
```

**장점**: 설정 변경 시 빌드 가능 여부 확인

---

### 5. 테스트 실행 (선택적)

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit.*\\.test\\.ts",
        "command": "npm test -- --run --reporter=verbose 2>&1 | tail -20 || true"
      }
    ]
  }
}
```

**장점**: 테스트 파일 수정 시 자동 검증

</use_cases>

---

<hook_writing_tips>

## Hook 작성 팁

| 원칙 | 설명 | 예시 |
|------|------|------|
| **출력 제한** | Claude 응답 길이 방지 | `\| head -20` |
| **에러 핸들링** | Hook 실패해도 작업 계속 | `\|\| true` |
| **성능 고려** | 빠른 명령어만 사용 | `--noEmit` (compile X) |
| **정확한 Matcher** | 필요한 도구에만 실행 | `Edit\|Write` (특정 도구) |
| **stderr 포함** | 에러 메시지도 캡처 | `2>&1` |

### 권장 패턴

```bash
# ✅ 빠르고 안전
npx tsc --noEmit 2>&1 | head -20 || true

# ❌ 느리고 위험
npm run build  # 전체 빌드는 너무 느림
npx tsc        # 실패 시 Hook 중단
```

</hook_writing_tips>

---

<configuration_examples>

## 실전 설정 예시

### 최소 설정 (TypeCheck만)

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx tsc --noEmit --pretty 2>&1 | head -20 || true"
      }
    ]
  }
}
```

---

### 표준 설정 (TypeCheck + Lint)

```json
{
  "hooks": {
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx tsc --noEmit --pretty 2>&1 | head -20 || true"
      },
      {
        "matcher": "Edit|Write",
        "command": "npx eslint --max-warnings 0 --format compact 2>&1 | head -15 || true"
      }
    ]
  }
}
```

---

### 고급 설정 (Pre + Post)

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Bash.*git commit",
        "command": "npm run lint && npm run typecheck"
      }
    ],
    "postToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npx tsc --noEmit --pretty 2>&1 | head -20 || true"
      },
      {
        "matcher": "Edit.*package\\.json",
        "command": "npm install --dry-run 2>&1 | tail -10 || true"
      }
    ]
  }
}
```

</configuration_examples>

---

<troubleshooting>

## 주의사항 및 디버깅

### Hook이 너무 느린 경우

| 증상 | 원인 | 해결 |
|------|------|------|
| Edit 후 대기 시간 길어짐 | 무거운 명령어 | `--noEmit`, `--fast` 옵션 사용 |
| 전체 빌드 실행 | build 명령어 사용 | typecheck으로 변경 |

```json
// ❌ 느림
"command": "npm run build"

// ✅ 빠름
"command": "npx tsc --noEmit 2>&1 | head -20 || true"
```

---

### Hook 실패 시

| 증상 | 원인 | 해결 |
|------|------|------|
| Hook 에러로 작업 중단 | `|| true` 누락 | 모든 Hook에 추가 |
| npx 명령어 실패 | 패키지 미설치 | `npm install` 확인 |

```bash
# ✅ 실패해도 계속
command || true

# ❌ 실패 시 중단
command
```

---

### Hook 출력 확인

```bash
# Hook이 실행되는지 확인
echo "Hook executed" > /tmp/hook.log

# 설정 검증
cat .claude/settings.json | jq '.hooks'
```

---

### Hook 비활성화

임시로 비활성화하려면:

```json
{
  "hooks": {
    "postToolUse": []
  }
}
```

또는 `.claude/settings.json`에서 `hooks` 섹션 제거

</troubleshooting>

---

<best_practices>

## 권장 사항

| 원칙 | 설명 |
|------|------|
| **점진적 추가** | TypeCheck부터 시작 → 필요시 Lint 추가 |
| **빠른 피드백** | 3초 이내 명령어만 사용 |
| **실패 허용** | `\|\| true`로 Hook 실패해도 작업 계속 |
| **출력 제한** | `head -20`으로 과도한 로그 방지 |
| **명확한 Matcher** | 정규식으로 정확한 도구 타겟팅 |

### 우선순위

1. **필수**: TypeScript 타입 체크 (Edit/Write 후)
2. **권장**: ESLint 검사 (Edit/Write 후)
3. **선택**: Git commit 전 검증
4. **고급**: 빌드/테스트 자동화

</best_practices>

---

<real_world_impact>

## 실제 효과 (Usage Report 분석 기반)

| Before | After |
|--------|-------|
| 수동 typecheck 실행 | Edit 후 자동 타입 에러 감지 |
| 버그 발견까지 5-10분 | 즉시 피드백 (3초 이내) |
| 커밋 후 CI 실패 | 커밋 전 자동 검증 |

**5 sessions showing buggy code friction** → Hooks로 조기 발견 가능

</real_world_impact>
