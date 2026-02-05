---
description: 배포 전 typecheck/lint/build 검증 및 수정. ultrathink + sequential thinking 필수 사용.
allowed-tools: Bash(tsc:*, npx:*, yarn:*, npm:*, pnpm:*), Read, Edit, mcp__sequential-thinking__sequentialthinking
argument-hint: [파일/디렉토리 경로...]
---

@../instructions/multi-agent/coordination-guide.md
@../instructions/multi-agent/execution-patterns.md

# Pre-Deploy Command

> 배포 전 typecheck/lint/build를 Sequential Thinking으로 검증하고 수정

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **회피** | 오류 무시하고 배포, `any` 타입, `@ts-ignore`, `eslint-disable` 남발 |
| **전략** | 여러 오류 동시 수정, build 생략, 오류 메시지만 보고 급하게 수정 |
| **분석** | Sequential Thinking 없이 수정 |

</forbidden>

---

<agent_usage>

## @deployment-validator Agent 활용

**언제 사용:**
- PR 생성 전 전체 검증
- 배포 전 품질 보증
- CI/CD 전 로컬 검증

**호출 방법:**
```bash
@deployment-validator
# 또는 자연어
"배포 준비 완료 체크해줘"
"pre-deploy 검증해줘"
```

**장점:**
- typecheck + lint + build 전체 자동화
- Build 실패 시 Sequential Thinking으로 원인 자동 분석
- 배포 가능 여부 최종 판단
- 독립적 context에서 실행 (메인 작업 병렬 가능)

**직접 검증 vs Agent:**

| 상황 | 권장 방법 |
|------|----------|
| 빠른 개발 중 | 직접 검증 (command) |
| PR 생성 전 | @deployment-validator |
| 배포 전 최종 확인 | @deployment-validator |
| CI/CD 전 로컬 확인 | @deployment-validator |
| 자동화된 검증 | @deployment-validator |

---

## @security-reviewer Agent 활용

**언제 사용:**
- 배포 전 보안 취약점 검토
- 코드 변경 후 보안 검증
- 인증/권한/데이터 처리 로직 추가 시

**호출 방법:**
```bash
@security-reviewer
# 또는 자연어
"배포 전 보안 검토해줘"
"보안 취약점 체크해줘"
```

**장점:**
- OWASP Top 10 자동 검토
- 시크릿 노출 탐지 (API 키, 비밀번호 하드코딩)
- 입력 검증 체크 (SQL Injection, XSS, CSRF)
- 인증/권한 로직 검증
- 독립적 context에서 실행 (메인 작업 병렬 가능)

**검토 범위:**
- SQL Injection: Prisma raw query 사용 시
- XSS: HTML/dangerouslySetInnerHTML 사용 시
- CSRF: POST/PUT/DELETE 엔드포인트
- 인증: middleware 누락 여부
- 시크릿: .env 변수 하드코딩 여부
- 입력 검증: Zod validator 누락 여부

---

## @build-fixer Agent 활용

**언제 사용:**
- 빌드/타입 오류 다수 발생
- 빠른 자동 수정 필요
- 반복적인 타입 오류 일괄 수정

**호출 방법:**
```bash
@build-fixer
# 또는 자연어
"빌드 오류 수정해줘"
"타입 오류 자동 수정해줘"
```

**장점:**
- 최소 diff로 오류 수정
- 언어 자동 감지 (TypeScript, Python, Go 등)
- 여러 오류 효율적 처리
- Sequential Thinking 자동 적용
- 독립적 context에서 실행

**직접 수정 vs Agent:**

| 상황 | 권장 방법 |
|------|----------|
| 1-2개 단순 오류 | 직접 수정 (command) |
| 5개+ 반복적 오류 | @build-fixer |
| 리팩토링 후 다수 오류 | @build-fixer |
| 라이브러리 업그레이드 후 | @build-fixer |

</agent_usage>

---

<required>

| 분류 | 필수 |
|------|------|
| **Thinking** | Sequential Thinking 3-5단계 (각 오류마다) |
| **Tracking** | TodoWrite로 오류 목록 추적 |
| **Strategy** | typecheck + lint 병렬 실행 → 순차 수정 → build |
| **Validation** | 각 파일 수정 후 해당 파일 재검사 |
| **Build** | 모든 오류 해결 후 build 실행 및 성공 확인 |

</required>

---

<workflow>

1. **병렬 검사**
   ```bash
   npx tsc --noEmit
   npx eslint .
   ```

2. **TodoWrite 생성**
   - typecheck 오류 목록
   - lint 오류 목록
   - 우선순위: 타입 오류 → 린트 오류 → 린트 경고

3. **순차 수정** (각 오류마다)
   - Sequential Thinking 3-5단계
   - 수정 적용
   - 해당 파일 재검사
   - TodoWrite 업데이트 (completed)

4. **Build 실행**
   ```bash
   # package.json scripts 확인 후 실행
   npm run build  # or yarn build, pnpm build
   ```

5. **Build 성공 확인**
   - 오류 발생 시 Sequential Thinking으로 분석 및 수정
   - 성공 시 배포 준비 완료

</workflow>

---

<parallel_execution_critical>

## ⚠️ CRITICAL: 병렬 검사 필수

**typecheck와 lint는 반드시 단일 메시지에서 병렬로 실행해야 합니다.**

### 올바른 실행 방법

```typescript
// ✅ 단일 메시지에서 2개 Bash 동시 호출
Bash({ command: "npx tsc --noEmit", description: "TypeScript type check" })
Bash({ command: "npx eslint .", description: "ESLint check" })
```

**이렇게 하면:**
- typecheck와 lint가 동시에 실행됨
- 총 실행 시간 = max(typecheck 시간, lint 시간)
- 순차 실행 대비 약 50% 시간 단축

### 잘못된 실행 방법

```typescript
// ❌ 순차 실행 (느림)
Bash({ command: "npx tsc --noEmit", description: "..." })
// 대기...
Bash({ command: "npx eslint .", description: "..." })
```

**이렇게 하면:**
- typecheck 완료 후 lint 시작
- 총 실행 시간 = typecheck 시간 + lint 시간
- 불필요한 대기 시간 발생

### 병렬 검사 체크리스트

배포 전 확인:

- [ ] typecheck와 lint를 단일 메시지에서 호출하는가?
- [ ] 2개의 Bash 도구를 연속으로 작성했는가?
- [ ] 중간에 대기나 분석이 없는가?
- [ ] 오류 수정은 순차로 진행하는가?
- [ ] build는 오류 수정 완료 후 실행하는가?

**모든 항목이 체크되어야 올바른 배포 준비입니다.**

### 검증 + 문서화 병렬 패턴

**검증과 문서화는 독립적이므로 병렬 가능:**

```typescript
// ✅ 검증 + 보안 검토 병렬
Task({ subagent_type: 'deployment-validator', model: 'sonnet',
       prompt: 'typecheck + lint + build 전체 검증' })
Task({ subagent_type: 'security-reviewer', model: 'sonnet',
       prompt: '배포 전 보안 취약점 검토' })

// ✅ 검증 + 문서 업데이트 병렬
Task({ subagent_type: 'deployment-validator', model: 'sonnet',
       prompt: 'typecheck + lint + build 전체 검증' })
Task({ subagent_type: 'document-writer', model: 'haiku',
       prompt: 'CHANGELOG.md 업데이트' })

// ✅ 여러 관점의 코드 리뷰 병렬
Task({ subagent_type: 'code-reviewer', model: 'opus',
       prompt: '보안 검토 (SQL Injection, XSS, CSRF)' })
Task({ subagent_type: 'code-reviewer', model: 'opus',
       prompt: '성능 검토 (N+1 쿼리, 메모이제이션)' })
Task({ subagent_type: 'code-reviewer', model: 'opus',
       prompt: '접근성 검토 (ARIA, 키보드 네비게이션)' })
```

**규칙:**
- 검사 단계 → 병렬 실행
- 오류 수정 → 순차 실행 (파일 충돌 방지)
- 검증 + 문서화 → 병렬 가능
- build → 오류 수정 완료 후

### 실제 배포 준비 워크플로우

**Step 1: 병렬 검사 (필수)**

```typescript
// 배포 준비 시작 시 즉시 실행
Bash({
  command: "npx tsc --noEmit",
  description: "TypeScript type check"
})
Bash({
  command: "npx eslint .",
  description: "ESLint check"
})
```

**Step 2: 오류 수정 (순차)**

- 오류가 있으면 하나씩 수정
- 각 수정 후 해당 파일만 재검사

**Step 3: 전체 재검사**

```typescript
// 모든 수정 완료 후 전체 검사
Bash({
  command: "npx tsc --noEmit",
  description: "Final type check"
})
Bash({
  command: "npx eslint .",
  description: "Final lint check"
})
```

**Step 4: Build**

```bash
npm run build  # 또는 yarn build, pnpm build
```

**Step 5: 검증 + 보안 검토 + 문서화 (병렬)**

```typescript
// build 성공 후 병렬 작업
Task({
  subagent_type: 'security-reviewer',
  model: 'sonnet',
  description: '배포 전 보안 검토',
  prompt: 'OWASP Top 10, 시크릿 노출, 입력 검증 체크'
})
Task({
  subagent_type: 'code-reviewer',
  model: 'opus',
  description: '배포 전 최종 코드 리뷰',
  prompt: '성능, 접근성 종합 검토'
})
Task({
  subagent_type: 'document-writer',
  model: 'haiku',
  description: 'CHANGELOG 업데이트',
  prompt: '배포 버전 변경사항 문서화'
})
```

**전체 실행 시간:**
- 순차: 검사1(3초) + 검사2(2초) + 수정(5초) + 재검사1(3초) + 재검사2(2초) + build(10초) = 25초
- 병렬: 검사(3초) + 수정(5초) + 재검사(3초) + build(10초) = 21초
- **개선: 16% 시간 단축** (검사 단계만 병렬화 시)
- 검증+문서화까지 병렬화 시 추가 30% 단축 가능

</parallel_execution_critical>

---

<sequential_thinking>

**각 오류마다 필수:**

| 단계 | 내용 |
|------|------|
| 1 | 오류 메시지 분석 및 이해 |
| 2 | 관련 코드 컨텍스트 파악 |
| 3 | 근본 원인 식별 |
| 4 | 수정 방안 검토 (여러 옵션 고려) |
| 5 | 최적 수정 방안 선택 및 적용 |

**파라미터:**

```typescript
{
  thought: "현재 사고 내용",
  nextThoughtNeeded: true | false,
  thoughtNumber: 1, // 현재 단계
  totalThoughts: 5  // 예상 총 단계 (동적 조정 가능)
}
```

</sequential_thinking>

---

<commands>

**검사:**

```bash
# TypeScript (전체)
npx tsc --noEmit

# TypeScript (특정 파일)
npx tsc --noEmit $ARGUMENTS

# ESLint (전체)
npx eslint .

# ESLint (특정 파일/디렉토리)
npx eslint $ARGUMENTS

# Build (package.json 확인 필요)
npm run build
yarn build
pnpm build
```

**인수 처리:**

| 인수 | 동작 |
|------|------|
| 없음 | 전체 프로젝트 검사 + build |
| 파일 경로 | 해당 파일만 검사 (build 생략) |
| 디렉토리 | 해당 디렉토리만 검사 (build 생략) |

</commands>

---

<examples>

**Example 1: 전체 워크플로우**

```
1. 병렬 검사 실행
   npx tsc --noEmit
   → TS2322: Type 'string' is not assignable to type 'number'

   npx eslint .
   → error: 'user' is assigned a value but never used (no-unused-vars)

2. TodoWrite 생성
   - TS2322 오류 수정 (src/utils/calc.ts:15)
   - no-unused-vars 수정 (src/components/Form.tsx:8)

3. Sequential Thinking (TS2322)
   thought 1: "TS2322 오류. string을 number에 할당 시도"
   thought 2: "calc.ts:15의 반환값 타입과 실제 반환값 확인"
   thought 3: "함수가 parseInt 결과를 반환해야 하는데 toString() 호출 중"
   thought 4: "수정 옵션: 1) toString() 제거 2) 반환 타입 변경"
   thought 5: "parseInt는 number를 반환하므로 toString() 제거가 적절"

4. Edit으로 수정 → npx tsc --noEmit src/utils/calc.ts 재검사 → 해결

5. TodoWrite 업데이트 (completed) → 다음 오류

6. 모든 오류 해결 후 build 실행
   npm run build → ✅ Build successful

7. 배포 준비 완료
```

**Example 2: 우선순위**

| 우선순위 | 유형 | 예시 |
|----------|------|------|
| 1 | 타입 오류 (컴파일 차단) | TS2322, TS2345, TS2339 |
| 2 | 린트 오류 (error 레벨) | no-unused-vars, no-undef |
| 3 | 린트 경고 (warning 레벨) | prefer-const, no-console |

**Example 3: Build 실패 시나리오**

```
1. typecheck + lint 통과

2. npm run build 실행
   → Error: Cannot find module '@/utils/helper'

3. Sequential Thinking
   thought 1: "Build 시 import 오류 발생"
   thought 2: "helper 모듈이 존재하지 않거나 경로 오류"
   thought 3: "Read로 파일 확인 필요"
   thought 4: "helper.ts가 아닌 helpers.ts로 존재"
   thought 5: "import 경로를 '@/utils/helpers'로 수정"

4. Edit으로 수정 → npm run build 재실행 → ✅ 성공
```

**Example 4: 부분 검사 (인수 제공)**

```bash
# 특정 파일만 검사 (build 생략)
/pre-deploy src/utils/calc.ts

→ npx tsc --noEmit src/utils/calc.ts
→ npx eslint src/utils/calc.ts
→ 오류 수정
→ build는 실행하지 않음
```

</examples>
