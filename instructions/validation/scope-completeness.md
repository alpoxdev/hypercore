# Scope Completeness (범위 완전성)

**목적**: 벌크 변경 작업 시 scope 누락 방지, 보수적 스코핑 금지

## 문제 분석

**Usage Report 반복 패턴:**
- "Incomplete Scope on First Pass" (다수 발생)
- "Claude initially only changed the layout-level background and scoped changes conservatively"
- "PRD and other skills were missed in the initial refactoring pass"
- "Requests sometimes leave scope implicit, leading to conservative first passes"

**핵심 원인**: 보수적 스코핑 → 레이아웃만 수정 → 컴포넌트/스킬 누락 → 재작업

## 1. Comprehensive Scan 원칙

### 금지: 보수적 스코핑

```typescript
// ❌ 금지: 레이아웃만 변경
Edit({ file_path: "app/routes/__root.tsx", ... })  // 레이아웃만
// → 컴포넌트, 페이지, 모달 누락!

// ❌ 금지: 일부 스킬만 수정
Edit({ file_path: ".claude/skills/plan/SKILL.md", ... })
Edit({ file_path: ".claude/skills/ralph/SKILL.md", ... })
// → 나머지 15개 스킬 누락!
```

### 필수: 전체 범위 탐색

```typescript
// ✅ 필수: 전체 관련 파일 스캔
Glob({ pattern: "**/*.tsx" })  // 레이아웃 + 페이지 + 컴포넌트
Glob({ pattern: "**/SKILL.md" })  // 모든 스킬
Glob({ pattern: "**/*.css" })  // 스타일 파일

// ✅ 필수: 중첩 파일 포함
Glob({ pattern: "app/components/**/*.tsx" })  // 중첩 컴포넌트
Glob({ pattern: "app/routes/**/*.tsx" })  // 중첩 라우트
```

## 2. 타겟 디렉토리 명시적 확인

### 작업 전 영향 범위 확인

**"모든 X 변경" 요청 시 반드시 목록 작성 후 사용자 확인**

```markdown
✅ 올바른 흐름:

1. Glob/Grep으로 전체 대상 확인
   → 결과: 레이아웃 1개, 페이지 5개, 컴포넌트 12개, 모달 3개

2. 사용자에게 범위 확인 요청:
   "다음 파일들을 수정합니다:
   - app/routes/__root.tsx (레이아웃)
   - app/routes/*.tsx (5개 페이지)
   - app/components/*.tsx (12개 컴포넌트)
   - app/components/modals/*.tsx (3개 모달)
   진행할까요?"

3. 승인 후 전체 작업 진행

❌ 금지:
1. Glob 없이 추측으로 범위 결정
2. 레이아웃만 수정하고 "완료" 선언
3. 암묵적 범위 가정 ("이 정도면 충분할 것")
```

### 추가 디렉토리 발견 시 즉시 포함

```typescript
// ✅ 필수: 예상 외 파일 발견 시 즉시 추가
Glob({ pattern: "**/*.tsx" })
// → 예상: 10개, 실제: 15개 (모달 5개 추가 발견)
// → 즉시 15개 모두 작업 범위에 포함

// ❌ 금지: 예상 범위만 처리하고 추가 파일 무시
```

## 3. 벌크 변경 체크리스트

작업 시작 전:

- [ ] 모든 관련 디렉토리 Glob/Grep 확인?
- [ ] 레이아웃 파일뿐 아니라 페이지 파일도 포함?
- [ ] 컴포넌트 파일도 포함?
- [ ] 중첩된 하위 컴포넌트 확인?
- [ ] 공유 컴포넌트/유틸리티 확인?
- [ ] 스타일 관련 변경 시 테마/변수 파일도 확인?
- [ ] 전체 대상 목록 사용자에게 확인?

작업 중:

- [ ] 발견된 모든 파일 TaskCreate 등록?
- [ ] 각 파일 수정 후 TaskUpdate 체크?
- [ ] 새 파일 발견 시 즉시 범위 추가?

작업 후:

- [ ] 재스캔으로 누락 항목 0개 확인?
- [ ] Grep으로 이전 패턴 잔존 여부 확인?

## 4. 금지 패턴

### 금지 1: 추측 기반 범위 결정

```markdown
❌ "이 정도면 충분할 것"
❌ "레이아웃만 수정하면 되겠지"
❌ "나머지는 영향 없을 것 같아"

✅ Glob/Grep으로 전체 목록 확인 후 결정
```

### 금지 2: 레이아웃만 변경

```typescript
// ❌ 금지: 레이아웃만 수정
Edit({ file_path: "app/routes/__root.tsx", ... })
<promise>DONE</promise>

// ✅ 올바름: 레이아웃 + 페이지 + 컴포넌트
Glob({ pattern: "app/**/*.tsx" })
// → 20개 파일 발견
TaskCreate({ subject: "파일 1/20 수정", ... })
TaskCreate({ subject: "파일 2/20 수정", ... })
// ... 20개 모두 작업
```

### 금지 3: 일부 스킬만 수정

```typescript
// ❌ 금지: 일부 스킬만
Edit({ file_path: ".claude/skills/plan/SKILL.md", ... })
Edit({ file_path: ".claude/skills/ralph/SKILL.md", ... })
// → 나머지 스킬 누락!

// ✅ 올바름: 모든 스킬
Glob({ pattern: "**/*SKILL.md" })
// → 19개 파일 발견
TaskCreate({ subject: "19개 SKILL.md 수정", ... })
// → 19개 모두 처리
Grep({ pattern: "이전패턴", glob: "**/SKILL.md" })  // 재스캔 확인
```

### 금지 4: 요청보다 좁은 범위 적용

```markdown
사용자: "모든 배경을 dark로 변경"

❌ 금지:
- 레이아웃만 변경
- 페이지 일부만 변경
- 컴포넌트 무시

✅ 올바름:
1. Glob: 레이아웃 + 페이지 + 컴포넌트 + 모달
2. 사용자 확인: "25개 파일 수정 예정"
3. 전체 작업
4. 재스캔: 누락 0개 확인
```

## 5. 권장 패턴

### 패턴 1: Glob 먼저 실행

```typescript
// ✅ 필수: 작업 전 전체 목록 확인
Glob({ pattern: "**/*.tsx" })
Glob({ pattern: "**/*.css" })
Glob({ pattern: "**/theme*.ts" })

// → 전체 범위 파악 후 작업 시작
```

### 패턴 2: 범위 목록 작성 후 사용자 확인

```markdown
✅ 올바른 흐름:

1. Glob 실행
   → 레이아웃: 1개
   → 페이지: 7개
   → 컴포넌트: 15개
   → 모달: 4개

2. 사용자 확인:
   "총 27개 파일을 수정합니다. 진행할까요?"

3. 승인 후 작업

❌ 금지:
- Glob 없이 즉시 작업 시작
- 범위 확인 없이 일부만 수정
```

### 패턴 3: "포함하지 않을 이유가 있나요?" 자문

```markdown
발견된 파일: app/components/dropdown.tsx

자문: "이 파일을 포함하지 않을 이유가 있나요?"

✅ 이유 없음 → 포함
❌ "아마 영향 없을 것" → 추측 금지, 포함
```

### 패턴 4: Over-include > Under-include

```markdown
원칙: 의심되면 포함

✅ 관련 가능성 50% → 포함
✅ 영향 불확실 → 포함 후 사용자 확인
❌ "아마 괜찮을 것" → 제외 금지
```

## 6. 스킬/문서 작업 시 추가 규칙

### 규칙 1: 유사 스킬 모두 확인

```typescript
// 사용자: "plan 스킬에서 TodoWrite를 TaskCreate로 변경"

// ❌ 금지: plan만 수정
Edit({ file_path: ".claude/skills/plan/SKILL.md", ... })

// ✅ 올바름: 모든 스킬 확인
Grep({ pattern: "TodoWrite", glob: "**/SKILL.md" })
// → 19개 파일에서 발견
TaskCreate({ subject: "19개 파일 수정", ... })
```

### 규칙 2: 공통 규칙 참조하는 모든 파일 확인

```typescript
// 사용자: "forbidden-patterns.md에서 규칙 수정"

// ✅ 필수: 참조하는 파일 모두 확인
Grep({ pattern: "@.*forbidden-patterns.md", output_mode: "files_with_matches" })
// → SKILL.md, CLAUDE.md 등 발견
// → 영향 받는 파일 모두 검토
```

### 규칙 3: 한 스킬 수정 시 관련 스킬 영향도 검토

```markdown
수정 대상: ralph/SKILL.md

관련 스킬:
- plan/SKILL.md (작업 계획)
- execute/SKILL.md (작업 실행)
- bug-fix/SKILL.md (버그 수정)

✅ 모두 검토 후 일관성 확인
```

## 7. 색상/스타일 변경 시 특별 규칙

### 탐색 계층

```markdown
레벨 1: 레이아웃
- app/routes/__root.tsx

레벨 2: 페이지
- app/routes/index.tsx
- app/routes/about.tsx
- ...

레벨 3: 컴포넌트
- app/components/header.tsx
- app/components/footer.tsx
- ...

레벨 4: 모달
- app/components/modals/*.tsx

레벨 5: 드롭다운/팝업
- app/components/dropdown.tsx
- app/components/popup.tsx

레벨 6: 공유 컴포넌트
- shared/components/*.tsx

레벨 7: 스타일 시스템
- theme.ts
- tailwind.config.ts
- globals.css
```

### 필수 확인 항목

```typescript
// ✅ 필수: 모든 레벨 확인
Glob({ pattern: "app/routes/__root.tsx" })      // 레벨 1
Glob({ pattern: "app/routes/*.tsx" })            // 레벨 2
Glob({ pattern: "app/components/*.tsx" })        // 레벨 3
Glob({ pattern: "app/components/modals/*.tsx" }) // 레벨 4
Glob({ pattern: "app/components/dropdown.tsx" }) // 레벨 5
Glob({ pattern: "shared/components/*.tsx" })     // 레벨 6
Glob({ pattern: "**/theme.ts" })                 // 레벨 7
Glob({ pattern: "**/tailwind.config.*" })        // 레벨 7
Glob({ pattern: "**/*.css" })                    // 레벨 7
```

### 스타일 변경 체크리스트

- [ ] 레이아웃 파일?
- [ ] 페이지 파일?
- [ ] 컴포넌트 파일?
- [ ] 모달 파일?
- [ ] 드롭다운/팝업 파일?
- [ ] 공유 컴포넌트?
- [ ] 테마 파일?
- [ ] Tailwind config?
- [ ] CSS 변수 파일?
- [ ] globals.css?

## 8. 범위 완전성 검증

### 작업 완료 후 필수 검증

```typescript
// ✅ 필수: 재스캔으로 누락 확인
// 1. 전체 파일 재스캔
Glob({ pattern: "**/*.tsx" })
// → 초기: 27개, 현재: 27개 (일치 확인)

// 2. 이전 패턴 잔존 확인
Grep({ pattern: "이전패턴", output_mode: "count" })
// → 결과: 0개 (완전 제거 확인)

// 3. 새 패턴 적용 확인
Grep({ pattern: "새패턴", output_mode: "count" })
// → 결과: 27개 (모두 적용 확인)
```

### 검증 실패 시 처리

```markdown
재스캔 결과: 누락 3개 발견

✅ 올바른 처리:
1. 누락 파일 즉시 목록화
2. TaskCreate로 등록
3. 수정 완료 후 재검증
4. 누락 0개 확인 후 완료

❌ 금지:
- "대부분 완료" 선언
- "나머지는 중요하지 않음" 추측
```

## 종합 원칙

| 원칙 | 적용 |
|------|------|
| **Comprehensive Scan** | 레이아웃 + 페이지 + 컴포넌트 + 모달 모두 |
| **Explicit Confirmation** | 범위 목록 작성 후 사용자 확인 |
| **Over-include** | 의심되면 포함 (Under-include 금지) |
| **No Guessing** | 추측 기반 범위 결정 금지 |
| **Full Verification** | 재스캔으로 누락 0개 확인 |

**보수적 스코핑 금지 → 완전한 범위 적용 → 재작업 제거**
