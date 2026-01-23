# Claude 4.x Specifics

> Claude 4 (Sonnet/Opus)는 3.x와 다른 특성을 가짐

## Precise Instruction Following

**Claude 4.x는 지시사항을 문자 그대로 따름** → 더 명시적으로 작성

| 상황 | Claude 3.x | Claude 4.x |
|------|-----------|-----------|
| "Create dashboard" | 추가 기능 자동 포함 | 최소한만 구현 |
| "Suggest changes" | 때때로 직접 구현 | 제안만 제공 |
| "Fix this" | 주변 코드도 정리 | 요청한 것만 수정 |

### Implications

**Before (Claude 3.x):**
```text
User: "Create a dashboard"
Claude: [Creates dashboard with charts, filters, real-time updates, export...]
```

**After (Claude 4.x):**
```text
User: "Create a dashboard"
Claude: [Creates minimal dashboard with basic layout]
```

### Solution

```text
❌ "Create a dashboard"
✅ "Create a dashboard. Include as many relevant features and interactions as
   possible. Go beyond the basics to create a fully-featured implementation."
```

## Action Control

### Default to Action

```xml
<default_to_action>
By default, implement changes rather than only suggesting them. If the user's
intent is unclear, infer the most useful likely action and proceed, using tools
to discover any missing details instead of guessing.
</default_to_action>
```

**Use when:**
- Agentic coding tasks
- User expects implementation
- Fast iteration needed

### Do Not Act Before Instructions

```xml
<do_not_act_before_instructions>
Do not jump into implementation or change files unless clearly instructed. When
the user's intent is ambiguous, default to providing information and
recommendations rather than taking action.
</do_not_act_before_instructions>
```

**Use when:**
- Exploratory tasks
- User wants to review first
- High-risk operations

## Verbosity Control

### Communication Style

```xml
<communication_style>
After completing a task that involves tool use, provide a quick summary of the
work you've done.
</communication_style>
```

### Output Style

```xml
<output_style>
Focus on essential information. Provide fact-based progress reports without
unnecessary elaboration.
</output_style>
```

### Avoid Excessive Markdown

```xml
<avoid_excessive_markdown_and_bullet_points>
When writing reports, use clear, flowing prose with complete paragraphs.
Reserve markdown for `inline code`, code blocks (```), and simple headings.
DO NOT use ordered lists (1. ...) or unordered lists (*) unless:
a) presenting truly discrete items where list format is best, or
b) user explicitly requests a list

Incorporate information naturally into sentences instead of bullet points.
</avoid_excessive_markdown_and_bullet_points>
```

## Parallel Tool Calling

**Claude 4.x는 병렬 도구 호출을 더 효과적으로 처리**

```xml
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between the
tool calls, make all independent tool calls in parallel. Maximize use of
parallel tool calls where possible to increase speed and efficiency. However,
if some tool calls depend on previous calls, do NOT call these tools in parallel.
</use_parallel_tool_calls>
```

### Examples

**Good (Parallel):**
```text
Reading 3 independent files → 3 Read calls in parallel
Git status + git diff → 2 Bash calls in parallel
```

**Bad (Sequential when should be parallel):**
```text
Read file A
[wait]
Read file B
[wait]
Read file C
```

**Good (Sequential when dependencies exist):**
```text
Write file
[wait]
Git add + commit (depends on file existing)
```

## Output Format Control

### Method 1: Tell What to Do (NOT What Not to Do)

```text
Your response should be composed of smoothly flowing prose paragraphs.
```

### Method 2: XML Format Indicators

```xml
Write the prose sections in <smoothly_flowing_prose_paragraphs> tags.
```

### Method 3: Detailed Formatting Rules

```xml
<avoid_excessive_markdown_and_bullet_points>
When writing reports, use clear, flowing prose with complete paragraphs.
Reserve markdown for `inline code`, code blocks (```), and simple headings.
DO NOT use ordered lists (1. ...) or unordered lists (*) unless:
a) presenting truly discrete items where list format is best, or
b) user explicitly requests a list

Incorporate information naturally into sentences instead of bullet points.
</avoid_excessive_markdown_and_bullet_points>
```

## Overtrigger Prevention (Opus 4.5)

**Opus 4.5는 과도한 강조에 과민 반응할 수 있음**

```text
❌ CRITICAL: You MUST use this tool! (Opus 4.5 overtrigger)
✅ Use this tool when... (일반적 지시)

❌ NEVER do X, ALWAYS do Y! (과도한 강조)
✅ Do Y for better results (긍정형)
```

## Claude 4.x Prompt Pattern

```xml
<role>
You are an expert [domain] developer.
</role>

<task>
[Specific task with all details]
Include as many relevant features as possible.
Go beyond basics to create fully-featured implementation.
</task>

<default_to_action>
Implement changes directly rather than suggesting.
</default_to_action>

<use_parallel_tool_calls>
Call independent tools in parallel for speed.
</use_parallel_tool_calls>

<output_style>
Focus on essential information.
</output_style>

<forbidden>
- Over-engineering
- Speculating about code not read
</forbidden>

<required>
- Read files before editing
- Test after implementation
</required>
```

## Migration Guide: 3.x → 4.x

| Claude 3.x Pattern | Claude 4.x Pattern |
|-------------------|-------------------|
| Implicit expectations | Explicit instructions |
| "Create X" | "Create X with Y and Z features" |
| Minimal guidance | Detailed success criteria |
| Rely on inference | State exact requirements |
| Brief prompts | Comprehensive prompts |

### Example Migration

**Before (3.x):**
```text
Create a login form.
```

**After (4.x):**
```text
Create a login form with the following features:
- Email and password fields
- "Remember me" checkbox
- "Forgot password" link
- Client-side validation
- Loading state during submission
- Error handling with clear messages
- Accessibility (WCAG 2.2 AA)
- Responsive design (mobile + desktop)

Make it fully functional and production-ready.
```

## Best Practices Summary

| Principle | Practice |
|-----------|----------|
| **Explicit** | State all requirements clearly |
| **Complete** | "Fully-featured", "production-ready" |
| **Action-oriented** | Use `<default_to_action>` |
| **Parallel** | Enable parallel tool calls |
| **Concise output** | Control verbosity |
| **No overtrigger** | Avoid excessive emphasis |
