# Claude 4.x Specifics

Claude 4.x 모델의 특징과 효과적 사용법.

## 핵심 차이점

### Precise Instruction Following

Claude 4.x는 **문자 그대로** 지시를 따름.

| 상황 | Claude 3.x | Claude 4.x |
|------|-----------|-----------|
| "Create dashboard" | 추가 기능 자동 포함 | 최소한만 구현 |
| "Suggest changes" | 때때로 바로 구현 | 제안만 |
| "Fix bug" | 주변 코드도 개선 | 버그만 수정 |
| "Add feature X" | X + 관련 기능들 | X만 |

**결론:** 더 명시적으로 작성 필요.

---

## Action Control

### 적극적 행동 유도

```xml
<default_to_action>
Implement changes directly rather than suggesting.
When you identify an issue, fix it immediately.
Go beyond the minimum to create comprehensive solutions.
</default_to_action>
```

**사용 시점:**
- 빠른 프로토타이핑
- 완전한 구현 원할 때
- 제안보다 실행 선호

### 보수적 행동 유도

```xml
<do_not_act_before_instructions>
Wait for explicit user instruction before taking action.
Only suggest changes, never implement without confirmation.
Ask for permission before modifying files.
</do_not_act_before_instructions>
```

**사용 시점:**
- 민감한 코드베이스
- 검토 필요한 변경
- 탐색적 작업

---

## Parallel Tool Calling

독립적 도구 호출을 병렬로 실행.

```xml
<use_parallel_tool_calls>
Call independent tools in parallel for maximum speed.
If operations don't depend on each other, run them simultaneously.
</use_parallel_tool_calls>
```

### 예시

```text
❌ 순차 실행 (느림)
1. Read file1.ts
2. Read file2.ts
3. Read file3.ts

✅ 병렬 실행 (빠름)
Read [file1.ts, file2.ts, file3.ts] 동시에
```

---

## Explicit Instruction Patterns

### 기능 구현

```text
❌ "Create user profile page"
✅ "Create comprehensive user profile page:
   - Avatar upload with preview
   - Editable fields (name, email, bio)
   - Password change form
   - Activity history
   - Settings panel
   Include all standard profile features."
```

### 최적화

```text
❌ "Optimize this component"
✅ "Optimize this component. Apply:
   - useMemo for expensive calculations
   - useCallback for event handlers
   - React.memo for child components
   - Code splitting if bundle > 100kb
   - Lazy loading for images
   Maximize performance improvements."
```

### 리팩토링

```text
❌ "Refactor this code"
✅ "Refactor this code to improve:
   - Extract reusable logic into hooks
   - Separate concerns into modules
   - Add TypeScript types
   - Improve naming clarity
   - Remove code duplication
   Follow modern React patterns."
```

---

## Completeness Control

### 최소 구현 방지

```xml
<avoid_minimal_implementation>
Don't create placeholder or minimal implementations.
Build complete, production-ready solutions.
Include error handling, loading states, and edge cases.
</avoid_minimal_implementation>
```

### 예시

```text
❌ Minimal (Claude 4.x 기본)
const Profile = () => {
  return <div>Profile</div>
}

✅ Complete (명시 후)
const Profile = () => {
  const { data, isLoading, error } = useQuery(...)

  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage error={error} />

  return (
    <div>
      <Avatar src={data.avatar} />
      <UserInfo user={data} />
      <ActivityFeed activities={data.activities} />
    </div>
  )
}
```

---

## Testing & Validation

### 자동 테스트 생성

```text
❌ "Add tests"
✅ "Add comprehensive tests:
   - Unit tests for all functions
   - Integration tests for API calls
   - Component tests for UI
   - Edge cases and error scenarios
   - Mock external dependencies
   Aim for 80%+ code coverage."
```

### 검증 단계 추가

```xml
<verify_implementation>
After implementing, verify:
- All requirements met
- Edge cases handled
- Tests passing
- No TypeScript errors
- Performance acceptable
</verify_implementation>
```

---

## Anti-Patterns

```text
❌ "Make it better" → 아무것도 안 함 (모호함)
✅ "Improve by adding X, Y, Z features"

❌ "Fix issues" → 최소한만
✅ "Fix all issues. Address root causes. Add safeguards."

❌ "Update design" → 최소 변경
✅ "Update design completely. Modern UI. Smooth animations."
```

---

## 요약

| 규칙 | 방법 |
|------|------|
| **명시성** | "Create X with Y and Z" |
| **행동 제어** | `<default_to_action>` or `<do_not_act>` |
| **병렬화** | `<use_parallel_tool_calls>` |
| **완전성** | "Include all features. Go beyond basics." |
