# XML Tags - Complete Guide

> Claude는 XML로 학습되어 구조화된 입력을 더 효과적으로 처리

## Why XML Tags?

| 장점 | 설명 |
|------|------|
| **Clarity** | 프롬프트 구성 요소를 명확히 구분 |
| **Accuracy** | 오해석 감소 |
| **Parseability** | 출력 구조 제어 가능 |
| **Flexibility** | 수정 용이 |

## XML vs Markdown

```text
✅ 둘 다 사용 가능 (Claude 4.x는 형식에 덜 민감)
✅ XML: 복잡한 구조, 의미적 구분 필요 시
✅ Markdown: 간단한 섹션 구분
```

## Common XML Patterns

### 1. Instructions Document

```xml
<instructions>
@path/to/specific-guide.md
@path/to/another-guide.md
</instructions>

<!-- @imports: Just-in-time loading, 중복 방지 -->
```

### 2. Role + Task Structure

```xml
<role>
You are an expert [domain] developer specializing in [technology].
</role>

<task>
[구체적 작업 설명]
</task>

<constraints>
- 제약사항 1
- 제약사항 2
</constraints>

<success_criteria>
- 성공 기준 1
- 성공 기준 2
</success_criteria>
```

### 3. Forbidden + Required Pattern

```xml
<forbidden>

| 분류 | 금지 |
|------|------|
| **Git** | AI 표시, 이모지, 여러 줄 커밋 |
| **코드** | any 타입, 불필요한 추상화 |

</forbidden>

<required>

| 분류 | 필수 |
|------|------|
| **타입** | 명시적 return type |
| **구조** | const 함수, 절대 경로 |

</required>
```

### 4. Examples with Context

```xml
<examples>

<example type="effective">
<description>명시적 도구 사용</description>
<input>Change this function to improve performance.</input>
<output>[파일 수정 도구 사용]</output>
</example>

<example type="ineffective">
<description>모호한 제안</description>
<input>Can you suggest some changes?</input>
<output>[제안만 제공, 실행 안 함]</output>
</example>

</examples>
```

### 5. Multi-Step Instructions

```xml
<workflow>

<step number="1">
<action>프로젝트 구조 분석</action>
<tools>Glob, Grep, Read</tools>
</step>

<step number="2">
<action>구현 계획 수립</action>
<deliverable>plan.md</deliverable>
</step>

<step number="3">
<action>코드 작성</action>
<validation>테스트 실행</validation>
</step>

</workflow>
```

## Document Structure Patterns

### Basic Document Tags

```xml
<context>
배경 정보, 왜 이 작업이 필요한지
</context>

<instructions>
핵심 지시사항
</instructions>

<documents>
  <document index="1">
    <source>filename.txt</source>
    <document_content>
      내용
    </document_content>
  </document>
</documents>
```

### Thinking Process Tags

```xml
<thinking>
내부 추론 과정
1. 문제 분석
2. 접근 방법
3. 단계별 추론
</thinking>

<answer>
최종 답변
</answer>
```

### Output Control Tags

```xml
<!-- 자연스러운 산문체 요청 -->
<smoothly_flowing_prose_paragraphs>
마크다운 없이 자연스러운 문장으로 작성
</smoothly_flowing_prose_paragraphs>

<!-- 상세 포맷 규칙 -->
<avoid_excessive_markdown_and_bullet_points>
When writing reports, use clear, flowing prose with complete paragraphs.
Reserve markdown for `inline code`, code blocks (```), and simple headings.
DO NOT use ordered lists (1. ...) or unordered lists (*) unless:
a) presenting truly discrete items where list format is best, or
b) user explicitly requests a list

Incorporate information naturally into sentences instead of bullet points.
</avoid_excessive_markdown_and_bullet_points>
```

### Behavior Control Tags

```xml
<!-- 적극적 행동 유도 -->
<default_to_action>
By default, implement changes rather than only suggesting them. If the user's
intent is unclear, infer the most useful likely action and proceed, using tools
to discover any missing details instead of guessing.
</default_to_action>

<!-- 보수적 행동 유도 -->
<do_not_act_before_instructions>
Do not jump into implementation or change files unless clearly instructed. When
the user's intent is ambiguous, default to providing information and
recommendations rather than taking action.
</do_not_act_before_instructions>
```

## Best Practices for XML Tags

| 원칙 | 설명 |
|------|------|
| **Meaningful Names** | 내용과 일치하는 태그명 사용 |
| **Consistency** | 프롬프트 전체에서 동일한 태그명 유지 |
| **Proper Nesting** | 계층 구조 명확히 |
| **No Canonical Tags** | 정해진 표준 없음 (자유롭게 정의) |

## Complete Example

```xml
<role>
You are an expert frontend developer specializing in React and TypeScript.
</role>

<task>
Implement a reusable data table component with sorting, filtering, and pagination.
</task>

<forbidden>

| Category | Don't |
|----------|-------|
| **Performance** | Inline functions in render |
| **State** | Prop drilling beyond 2 levels |
| **Types** | `any` type |

</forbidden>

<required>

| Category | Must |
|----------|------|
| **Accessibility** | WCAG 2.2 AA compliance |
| **Testing** | Unit tests for all logic |
| **Types** | Full TypeScript coverage |

</required>

<workflow>

<step number="1">
<action>Create component structure</action>
<deliverable>DataTable.tsx skeleton</deliverable>
</step>

<step number="2">
<action>Implement sorting logic</action>
<validation>Sort ascending/descending works</validation>
</step>

<step number="3">
<action>Add filtering</action>
<validation>Filter by column works</validation>
</step>

<step number="4">
<action>Implement pagination</action>
<validation>Navigate pages correctly</validation>
</step>

<step number="5">
<action>Add tests</action>
<validation>All tests pass</validation>
</step>

</workflow>

<examples>

<example>
<description>Effective table implementation</description>
<code>
```tsx
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  onSort?: (key: keyof T, order: 'asc' | 'desc') => void;
}

export function DataTable<T>({ data, columns, onSort }: DataTableProps<T>) {
  // Implementation
}
```
</code>
</example>

</examples>
</task>
```
