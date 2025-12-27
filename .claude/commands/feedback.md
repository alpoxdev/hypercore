---
description: 피드백 기반 코드 위치 탐색 및 수정. ultrathink + sequential thinking 10+ + subagent 필수.
allowed-tools: Read, Edit, Glob, Grep, Bash(git:*, ast-grep:*), Task, mcp__sequential-thinking__sequentialthinking
argument-hint: <피드백 내용>
---

# Feedback Command

피드백을 분석하여 관련 코드를 찾고 수정하는 커맨드.

## CRITICAL: 필수 요구사항

| 요구사항 | 설명 |
|----------|------|
| **ARGUMENT 필수** | 피드백 내용 없이 실행 시 되물음 |
| **Ultrathink** | 깊은 사고로 피드백 분석 |
| **Sequential Thinking 10+** | 최소 10단계 사고 과정 필수 |
| **Subagent (Task)** | 코드 탐색에 Task 도구 활용 |

## ARGUMENT 확인

```
$ARGUMENTS 없음 → 즉시 질문:
"어떤 피드백을 수정해야 하나요? 구체적으로 알려주세요."

$ARGUMENTS 있음 → 다음 단계 진행
```

**피드백 내용**: $ARGUMENTS

## 실행 흐름

```
1. ARGUMENT 확인 (없으면 되물음)
2. Sequential Thinking 10+로 피드백 분석
   - 피드백 의도 파악
   - 키워드 추출
   - 수정 대상 추론
3. Task subagent로 코드 위치 탐색
4. 후보 위치 정리
   - 확실 → 수정 계획 제시
   - 불확실 → 2~3개 후보 제시 → 컨펌 요청
5. 사용자 컨펌
   - Y → 수정 진행
   - N → 더 찾기 반복
6. 수정 완료 → git add <파일> && git commit
```

## Sequential Thinking 가이드

**피드백 분석 시 최소 10단계:**

```
thought 1: 피드백 원문 분석 - 무엇을 수정하라는 것인가?
thought 2: 핵심 키워드 추출 (기능명, 변수명, 컴포넌트명 등)
thought 3: 피드백 유형 분류 (버그, UI, 로직, 성능 등)
thought 4: 예상 파일 위치 추론 (디렉토리, 파일 패턴)
thought 5: 검색 전략 수립 (ast-grep vs grep vs glob)
thought 6: 첫 번째 탐색 결과 분석
thought 7: 추가 탐색 필요 여부 판단
thought 8: 후보 위치 정리 및 우선순위
thought 9: 수정 방안 초안 작성
thought 10: 수정 영향 범위 분석
thought 11+: 필요시 추가 분석
```

## Task Subagent 활용

**코드 탐색 시 Task 도구 사용:**

| subagent_type | 용도 |
|---------------|------|
| `Explore` | 코드베이스 전반 탐색, 파일 구조 파악 |
| `general-purpose` | 복잡한 로직 분석, 다중 파일 연관 관계 파악 |

**Task 호출 예시:**

```
Task: "피드백 '[버튼 클릭 시 에러 발생]' 관련 코드 위치 탐색"
subagent_type: Explore
prompt: "버튼 클릭 핸들러, onClick 이벤트, 관련 컴포넌트 탐색.
        에러 발생 가능 위치와 수정 대상 파일 목록 제시."
```

**병렬 탐색:**

```
여러 가능성 있을 때:
Task 1: "컴포넌트 레벨 탐색" (Explore)
Task 2: "API 호출 레벨 탐색" (Explore)
Task 3: "상태 관리 레벨 탐색" (Explore)

→ 단일 메시지에 다중 Task 호출
→ 결과 취합 후 후보 정리
```

## 후보 제시 및 컨펌

**확실한 경우 (1개):**

```
수정 대상: src/components/Button.tsx:42

수정 계획:
- onClick 핸들러에서 null 체크 추가
- 에러 바운더리 적용

이대로 수정할까요? (Y/N)
```

**불확실한 경우 (2~3개):**

```
후보 위치를 찾았습니다:

1. src/components/Button.tsx:42
   - onClick 핸들러 내 API 호출 부분

2. src/hooks/useSubmit.ts:28
   - submit 함수의 에러 처리 부분

3. src/api/client.ts:15
   - API 클라이언트 에러 핸들링

어느 위치를 수정할까요? (1/2/3/N)
- 숫자: 해당 위치 수정
- N: 다른 위치 더 탐색
```

**N 선택 시:**

```
→ 추가 탐색 시작
→ 다른 키워드/패턴으로 재검색
→ 새로운 후보 제시
→ 반복
```

## Git 커밋 규칙

**수정 완료 후 커밋:**

```bash
# 수정한 파일만 add
git add <수정된 파일>

# 커밋 (한 줄, prefix 필수, 마침표 없음)
git commit -m "fix: <피드백 요약>"
```

**커밋 메시지 예시:**

```bash
# ✅ 올바른
git add src/components/Button.tsx
git commit -m "fix: 버튼 클릭 시 null 체크 추가"

git add src/hooks/useSubmit.ts
git commit -m "fix: submit 에러 핸들링 개선"

# ❌ 잘못된
git commit -m "fix: 버튼 수정."           # 마침표
git commit -m "피드백 반영"                # prefix 없음
git commit -m "fix: 여러 파일 수정"       # 구체적이지 않음
```

**prefix 선택 기준:**

| 피드백 유형 | prefix |
|-------------|--------|
| 버그 수정 | fix |
| 기능 개선 | feat |
| UI 수정 | style |
| 성능 개선 | perf |
| 코드 정리 | refactor |

## CRITICAL: 절대 금지

| 금지 항목 |
|----------|
| ARGUMENT 없이 수정 시작 |
| Sequential Thinking 10단계 미만 |
| 코드 탐색 없이 추측으로 수정 |
| 사용자 컨펌 없이 수정 |
| "Generated with Claude Code" 포함 |
| "🤖" 또는 AI 관련 이모지 |
| "Co-Authored-By:" 헤더 |
| 여러 줄 커밋 메시지 |
| 커밋 메시지에 마침표(.) |
