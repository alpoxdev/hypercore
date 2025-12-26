---
description: tsc 타입 오류 검사 및 하나씩 꼼꼼히 수정. ultrathink + sequential thinking 필수 사용.
allowed-tools: Bash(tsc:*, npx:*, yarn:*, npm:*, pnpm:*), Read, Edit, mcp__sequential-thinking__sequentialthinking
argument-hint: [파일/디렉토리 경로...]
---

# TypeScript Fix Command

tsc 타입 오류만 검사하고 하나씩 꼼꼼히 수정하는 커맨드.

## CRITICAL: 필수 요구사항

| 요구사항 | 설명 |
|----------|------|
| **Ultrathink** | 깊은 사고로 오류 분석. 급하게 수정하지 않음 |
| **Sequential Thinking** | `mcp__sequential-thinking__sequentialthinking` 도구 필수 사용 |
| **하나씩 수정** | 한 번에 하나의 오류만 집중. 여러 오류 동시 수정 금지 |

## 실행 흐름

```
1. tsc --noEmit 실행 → 타입 오류 수집
2. 오류 목록 정리 → TodoWrite로 추적
3. 각 오류마다:
   a. Sequential Thinking으로 원인 분석 (최소 3단계)
   b. 오류의 근본 원인 파악
   c. 안전한 수정 방안 도출
   d. 수정 적용
   e. 수정 후 해당 파일 재검사
4. 모든 오류 수정 완료 후 전체 재검사
```

## Sequential Thinking 사용법

**각 오류마다 반드시 Sequential Thinking 실행:**

```
오류 분석 시:
- thoughtNumber: 1 → 오류 메시지 분석 및 이해
- thoughtNumber: 2 → 관련 코드 컨텍스트 파악
- thoughtNumber: 3 → 근본 원인 식별
- thoughtNumber: 4 → 수정 방안 검토 (여러 옵션 고려)
- thoughtNumber: 5 → 최적 수정 방안 선택 및 적용
```

**Sequential Thinking 파라미터:**

| 파라미터 | 설명 |
|----------|------|
| `thought` | 현재 사고 내용 |
| `nextThoughtNeeded` | 추가 분석 필요 여부 |
| `thoughtNumber` | 현재 단계 번호 |
| `totalThoughts` | 예상 총 단계 (동적 조정 가능) |

## 오류 검사 명령어

```bash
# npm/yarn/pnpm 프로젝트
npx tsc --noEmit

# 특정 파일만
npx tsc --noEmit $ARGUMENTS
```

## 수정 원칙

### DO

- 오류 메시지를 정확히 이해
- 관련 코드 전체를 파악
- 타입 정의, 인터페이스 확인
- 제네릭 타입 파라미터 추적
- import된 타입 출처 확인
- 수정 전후 비교 분석
- 수정이 다른 곳에 영향 주는지 확인

### DON'T

- 오류 메시지만 보고 급하게 수정
- `any` 타입으로 회피
- `// @ts-ignore` 추가
- `// @ts-expect-error` 남용
- `as unknown as T` 강제 캐스팅
- 여러 오류 한 번에 수정

## 주요 타입 오류 유형

| 코드 | 설명 | 일반적 원인 |
|------|------|-------------|
| TS2322 | 할당 불가 | 타입 불일치 |
| TS2345 | 인수 타입 오류 | 함수 호출 시 타입 불일치 |
| TS2339 | 속성 없음 | 객체에 해당 속성 미존재 |
| TS2304 | 이름 찾을 수 없음 | import 누락 또는 오타 |
| TS2769 | 오버로드 매칭 실패 | 함수 시그니처 불일치 |
| TS2741 | 필수 속성 누락 | 객체 리터럴에 속성 누락 |
| TS2532 | undefined 가능성 | null/undefined 체크 필요 |

## 예시 워크플로우

```
1. "npx tsc --noEmit" 실행
   → TS2322: Type 'string' is not assignable to type 'number'

2. Sequential Thinking 시작:
   thought 1: "TS2322 오류. string을 number에 할당 시도"
   thought 2: "해당 파일의 변수 타입과 값 확인 필요"
   thought 3: "함수 반환 타입이 number인데 string 반환 중"
   thought 4: "수정 옵션: 1) 반환값 수정 2) 타입 수정"
   thought 5: "반환값을 올바른 number로 수정하는 것이 적절"

3. Edit으로 수정 적용

4. 해당 파일 재검사
   → 오류 해결 확인

5. 다음 오류로 이동
```

## 인수 처리

| 인수 | 동작 |
|------|------|
| 없음 | 전체 프로젝트 검사 |
| 파일 경로 | 해당 파일만 검사 |
| 디렉토리 | 해당 디렉토리만 검사 |

**인수**: $ARGUMENTS
