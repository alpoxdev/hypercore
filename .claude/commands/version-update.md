---
description: 프로젝트 버전 업데이트 및 커밋
allowed-tools: Bash(git:*), Read, Edit
argument-hint: <new-version | +1>
---

프로젝트 전체 버전을 업데이트하고 커밋.

**인수**: `$ARGUMENTS`

## 인수 처리

| 인수 | 동작 | 예시 |
|------|------|------|
| `+1` | patch 버전 +1 | 0.1.13 → 0.1.14 |
| `+minor` | minor 버전 +1 | 0.1.13 → 0.2.0 |
| `+major` | major 버전 +1 | 0.1.13 → 1.0.0 |
| `x.x.x` | 해당 버전으로 설정 | 0.1.13 → 2.0.0 |

## 실행 흐름

```
1. 현재 버전 확인 (병렬로 버전 파일들 읽기)
2. 인수에 따라 새 버전 계산
3. 모든 버전 파일 업데이트
4. git add + git commit
```

## 버전 파일 목록

| 파일 | 필드 |
|------|------|
| `packages/claude-code/package.json` | `"version": "x.x.x"` |
| `packages/claude-code/src/index.ts` | `.version('x.x.x')` |

## 병렬 실행

**초기 확인 단계에서 병렬 실행 필수:**

```
Read: packages/claude-code/package.json
Read: packages/claude-code/src/index.ts
```

## 업데이트 절차

1. **버전 검증**: semver 형식 확인 (예: 0.1.14, 1.0.0)
2. **Edit 도구로 각 파일 수정**:
   - `package.json`: `"version": "이전버전"` → `"version": "새버전"`
   - `index.ts`: `.version('이전버전')` → `.version('새버전')`
3. **git add + git commit**

## 커밋 규칙

**형식**: `chore: 버전 X.X.X로 업데이트`

## CRITICAL: 절대 금지

| 금지 항목 |
|----------|
| "Generated with Claude Code" 포함 |
| "🤖" 또는 AI 관련 이모지 |
| "Co-Authored-By:" 헤더 |
| AI/봇 작성 표시 일체 |
| 여러 줄 커밋 메시지 |
| 커밋 메시지에 마침표(.) |

## 예시

```bash
# patch 버전 증가 (가장 일반적)
/version-update +1
# 0.1.13 → 0.1.14

# minor 버전 증가
/version-update +minor
# 0.1.13 → 0.2.0

# major 버전 증가
/version-update +major
# 0.1.13 → 1.0.0

# 직접 버전 지정
/version-update 2.0.0

# 커밋 결과
chore: 버전 0.1.14로 업데이트
```
