---
description: 배포 전 typecheck/lint/build 검증 및 수정. ultrathink + sequential thinking 필수 사용.
allowed-tools: Bash(tsc:*, npx:*, yarn:*, npm:*, pnpm:*), Read, Edit, mcp__sequential-thinking__sequentialthinking
argument-hint: [파일/디렉토리 경로...]
---

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
