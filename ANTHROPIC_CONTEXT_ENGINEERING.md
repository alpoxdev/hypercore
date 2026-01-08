# INSTRUCTION.md - Effective Context Engineering for Claude

> Anthropic 공식 가이드 기반 Instructions 작성법

---

<context>

**Purpose:** Claude Code에 효과적인 Instructions 작성을 위한 종합 가이드

**Sources:**
- [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude 4.x Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Use XML tags](https://console.anthropic.com/docs/en/build-with-claude/prompt-engineering/use-xml-tags)
- [Chain of Thought](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/chain-of-thought)
- [Extended Thinking](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/extended-thinking-tips)

</context>

---

<forbidden>

**문서 작성 시 절대 금지:**

| 분류 | 금지 사항 |
|------|----------|
| **설명** | 장황한 설명, 불필요한 텍스트, 중복 정보 |
| **구조** | XML 태그 없이 복잡한 구조, 모호한 지시사항 |
| **표현** | 부정형 지시 ("Don't X" 대신 "Do Y" 사용) |
| **복잡도** | 복잡한 조건문 나열, 모든 엣지 케이스 포함 |
| **강조** | 과도한 강조 (CRITICAL, MUST 남발) |

</forbidden>

---

<required>

**문서 작성 시 필수:**

| 분류 | 필수 사항 |
|------|----------|
| **구조** | XML 태그로 섹션 구분, 명확한 계층 |
| **표현** | 표 형식 정보 압축, ✅/❌ 마커 사용 |
| **예시** | 코드/예시 중심, 복사 가능한 패턴 |
| **로딩** | @imports로 just-in-time 로딩 |
| **지시** | 명시적 지시사항, 긍정형 표현 |

</required>

---

<core_principles>

## Core Principles

### 1. Find the Right Altitude

> "Specific enough to guide behavior effectively, yet flexible enough to provide strong heuristics."

| ❌ Too Low (Brittle) | ✅ Right Altitude | ❌ Too High (Vague) |
|---------------------|------------------|-------------------|
| 복잡한 조건문 나열 | 명확한 원칙 + 예시 | 모호한 지시 |
| 모든 엣지 케이스 포함 | 핵심 패턴 설명 | 구체성 부족 |

### 2. Context as Finite Resource

| 전략 | 방법 |
|------|------|
| **Just-in-Time** | 필요한 시점에만 정보 제공 |
| **Minimal Start** | 최소 프롬프트 → 실패 시 추가 |
| **Curated Examples** | 다양하고 대표적인 예시만 |
| **Token Minimization** | 중복 제거, 압축된 표현 |

### 3. Explicit > Implicit (Claude 4.x)

**Claude 4.x는 명시적 지시사항에 강하게 반응**

```text
❌ "Create an analytics dashboard"
✅ "Create an analytics dashboard. Include as many relevant features and
   interactions as possible. Go beyond the basics to create a fully-featured
   implementation."
```

</core_principles>

---

<xml_tags>

## XML Tags: Structure & Optimization

### Why XML Tags?

**Claude는 XML 태그로 학습됨** → 구조화된 프롬프트를 더 잘 이해

| 장점 | 설명 |
|------|------|
| **Clarity** | 프롬프트 구성 요소 명확히 구분 |
| **Accuracy** | 오해석 감소 |
| **Parseability** | 출력 구조 제어 가능 |
| **Flexibility** | 수정 용이 |

### XML vs Markdown

```text
✅ 둘 다 사용 가능 (Claude 4.x는 형식에 덜 민감)
✅ XML: 복잡한 구조, 의미적 구분 필요 시
✅ Markdown: 간단한 섹션 구분
```

### Common XML Patterns

```xml
<!-- ===== 기본 구조 ===== -->
<instructions>
핵심 지시사항
</instructions>

<context>
배경 정보
</context>

<examples>
  <example>
    <input>입력</input>
    <output>출력</output>
  </example>
</examples>

<forbidden>
절대 하지 말아야 할 것
</forbidden>

<required>
반드시 해야 할 것
</required>

<!-- ===== 문서 구조 ===== -->
<documents>
  <document index="1">
    <source>filename.txt</source>
    <document_content>
      내용
    </document_content>
  </document>
</documents>

<!-- ===== 사고 과정 ===== -->
<thinking>
내부 추론 과정
</thinking>

<answer>
최종 답변
</answer>

<!-- ===== 출력 제어 ===== -->
<smoothly_flowing_prose_paragraphs>
마크다운 없이 자연스러운 문장으로 작성
</smoothly_flowing_prose_paragraphs>

<!-- ===== 행동 제어 ===== -->
<default_to_action>
제안보다 직접 구현 우선
</default_to_action>

<do_not_act_before_instructions>
명시적 요청 전까지 대기
</do_not_act_before_instructions>
```

### Best Practices for XML Tags

| 원칙 | 설명 |
|------|------|
| **Meaningful Names** | 내용과 일치하는 태그명 |
| **Consistency** | 프롬프트 전체에서 동일한 태그명 |
| **Proper Nesting** | 계층 구조 명확히 |
| **No Canonical Tags** | 정해진 표준 없음 (자유롭게 정의) |

### Structure Patterns

#### 1. Instructions Document

```xml
<instructions>
@path/to/specific-guide.md
@path/to/another-guide.md
</instructions>

<!-- @imports: Just-in-time loading, 중복 방지 -->
```

#### 2. Role + Task Structure

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

#### 3. Forbidden + Required Pattern

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

#### 4. Examples with Context

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

#### 5. Multi-Step Instructions

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

</xml_tags>

---

<techniques>

## Chain of Thought (CoT)

### Why Use CoT?

**Claude가 단계별로 생각하도록 유도 → 복잡한 작업의 정확성 향상**

| 장점 | 설명 |
|------|------|
| **Accuracy** | 수학, 논리, 분석 작업의 오류 감소 |
| **Consistency** | 구조화된 사고 → 응집력 있는 응답 |
| **Debugging** | 사고 과정 확인으로 프롬프트 개선 가능 |

| 단점 | 설명 |
|------|------|
| **Latency** | 출력 길이 증가 → 지연 시간 증가 |
| **Overkill** | 모든 작업이 깊이 있는 사고 필요한 것은 아님 |

**핵심:** 사고 과정을 출력하지 않으면 생각이 일어나지 않음!

### Three Levels of CoT

| 레벨 | 방법 | 강점 | 약점 |
|------|------|------|------|
| **Basic** | "단계별로 생각하세요" | 간단함 | 사고 방향 제어 부족 |
| **Guided** | 구체적 단계 제공 | 사고 방향 제어 | 구조 분리 부족 |
| **Structured** | XML 태그 사용 | 사고/답변 분리, 파싱 용이 | 약간의 복잡도 증가 |

### CoT Patterns

```xml
<!-- ===== Basic CoT ===== -->
이 문제를 단계별로 생각하세요.

<!-- ===== Guided CoT ===== -->
이메일을 작성하기 전에 생각하세요:
1. 기부자의 이력 분석
2. 어필할 수 있는 메시지 식별
3. 개인화된 이메일 작성

<!-- ===== Structured CoT (권장) ===== -->
<thinking>
1. 문제 분석
2. 접근 방법 고려
3. 단계별 추론
4. 검증
</thinking>

<answer>
최종 답변
</answer>

<!-- ===== CoT + Multishot ===== -->
<examples>
  <example>
    <problem>80의 15%는?</problem>
    <thinking>
    1. 15% = 0.15
    2. 0.15 × 80 = 12
    </thinking>
    <answer>12</answer>
  </example>
</examples>

이제 240의 35%를 구하세요.
```

### When to Use CoT

```text
✅ 복잡한 수학 계산
✅ 다단계 분석
✅ 복잡한 문서 작성
✅ 많은 요소가 있는 의사결정
✅ 인간이 생각해야 할 작업

❌ 단순한 정보 검색
❌ 간단한 변환 작업
❌ 지연 시간이 중요한 경우
```

---

## Extended Thinking

### What is Extended Thinking?

**Claude가 긴 시간 동안 깊이 사고할 수 있는 모드** (최소 1024 토큰 예산)

| 특징 | 설명 |
|------|------|
| **긴 추론 시간** | 복잡한 문제를 체계적으로 분해 |
| **자기 검증** | 사고 과정에서 오류 자체 수정 |
| **다중 접근법** | 여러 방법 시도 후 최선 선택 |
| **영어 최적화** | 영어에서 최고 성능 (출력은 모든 언어 가능) |

### Extended Thinking Best Practices

#### 1. 일반적 지시 > 단계별 지시

```text
❌ 이 수학 문제를 단계별로:
   1. 변수 식별
   2. 방정식 설정
   3. x 구하기
   ...

✅ 이 수학 문제에 대해 철저하고 매우 자세히 생각해보세요.
   여러 접근법을 고려하고 완전한 추론을 보여주세요.
   첫 번째 접근법이 작동하지 않으면 다른 방법을 시도해보세요.
```

**Why?** Claude의 창의성이 인간의 처방보다 나을 수 있음

#### 2. Multishot + Extended Thinking

```xml
<example>
<problem>테서랙트 안에서 튀는 노란 공 시뮬레이션</problem>
<thinking>
1. 4D 공간 표현 방법 고려
2. 충돌 감지 알고리즘 설계
3. 회전 변환 구현
...
</thinking>
</example>

이제 비슷한 복잡도의 문제를 해결하세요.
```

#### 3. 자기 검증 유도

```text
숫자의 팩토리얼을 계산하는 함수를 작성하세요.

완료하기 전에 다음 테스트 케이스로 검증하세요:
- n=0
- n=1
- n=5
- n=10

발견한 문제를 수정하세요.
```

### When Extended Thinking Excels

| 사용 사례 | 예시 |
|----------|------|
| **복잡한 STEM** | 4D 시각화, 고급 물리 시뮬레이션 |
| **제약 최적화** | 다중 제약 조건을 만족하는 여행 계획 |
| **사고 프레임워크** | Porter's 5 Forces + 시나리오 계획 + Ansoff Matrix |
| **긴 콘텐츠 생성** | 20,000+ 단어 상세 문서 |

### Technical Considerations

```text
⚠️ 최소 예산: 1024 토큰
⚠️ 32K+ 예산: Batch Processing 권장 (네트워크 타임아웃 방지)
⚠️ <1024 토큰 필요: Extended Thinking OFF + XML <thinking> 태그 사용
⚠️ 사고 블록 미리 채우기: 명시적으로 금지됨
⚠️ 사고를 user 텍스트로 재전달: 성능 저하 가능
```

### Extended Thinking Patterns

```xml
<!-- ===== 제약 최적화 ===== -->
다음 제약 조건으로 일본 7일 여행을 계획하세요:
- 예산 $2,500
- 도쿄와 교토 포함
- 채식주의 식단
- 문화 체험 선호
- 하루는 하이킹
- 하루 이동 시간 2시간 이내
- 매일 오후 자유 시간
- 인파 회피

<!-- ===== 사고 프레임워크 ===== -->
Microsoft의 개인 맞춤형 의학 시장 진입 전략 (2027):

1. 블루오션 전략 캔버스
2. Porter's 5 Forces 분석
3. 4가지 시나리오 계획 (규제/기술 변수)
   - 각 시나리오: Ansoff Matrix 적용
4. 3개 지평선 프레임워크
   - 전환 경로 매핑
   - 파괴적 혁신 식별

<!-- ===== 자기 검증 ===== -->
[작업 지시]

완료 전 검증:
1. 테스트 케이스 실행
2. 엣지 케이스 확인
3. 오류 수정
4. 최종 검증
```

</techniques>

---

<claude_4x>

## Claude 4.x Specifics

### Precise Instruction Following

**Claude 4.x는 지시사항을 문자 그대로 따름** → 더 명시적으로 작성

| 상황 | Claude 3.x | Claude 4.x |
|------|-----------|-----------|
| "Create dashboard" | 추가 기능 자동 포함 | 최소한만 구현 |
| "Suggest changes" | 때때로 직접 구현 | 제안만 제공 |
| "Fix this" | 주변 코드도 정리 | 요청한 것만 수정 |

### Action Control

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

### Verbosity Control

```xml
<!-- 요약 제공 요청 -->
<communication_style>
After completing a task that involves tool use, provide a quick summary of the
work you've done.
</communication_style>

<!-- 간결한 출력 유도 -->
<output_style>
Focus on essential information. Provide fact-based progress reports without
unnecessary elaboration.
</output_style>
```

### Parallel Tool Calling

```xml
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between the
tool calls, make all independent tool calls in parallel. Maximize use of
parallel tool calls where possible to increase speed and efficiency. However,
if some tool calls depend on previous calls, do NOT call these tools in parallel.
</use_parallel_tool_calls>
```

### Output Format Control

```xml
<!-- Method 1: Tell what to do (NOT what not to do) -->
Your response should be composed of smoothly flowing prose paragraphs.

<!-- Method 2: XML format indicators -->
Write the prose sections in <smoothly_flowing_prose_paragraphs> tags.

<!-- Method 3: Detailed formatting rules -->
<avoid_excessive_markdown_and_bullet_points>
When writing reports, use clear, flowing prose with complete paragraphs.
Reserve markdown for `inline code`, code blocks (```), and simple headings.
DO NOT use ordered lists (1. ...) or unordered lists (*) unless:
a) presenting truly discrete items where list format is best, or
b) user explicitly requests a list

Incorporate information naturally into sentences instead of bullet points.
</avoid_excessive_markdown_and_bullet_points>
```

</claude_4x>

---

<best_practices>

## Best Practices

### Do's

| 원칙 | 방법 |
|------|------|
| **명시적 지시** | "Create X with Y and Z features" |
| **Context 제공** | 왜 중요한지 설명 |
| **예시 활용** | 원하는 패턴 보여주기 |
| **도구 명시** | "Use Read tool to check..." |
| **구조화** | XML/Markdown으로 섹션 구분 |
| **점진적 추가** | 최소 → 실패 시 보강 |

### Don'ts

| 피해야 할 것 | 이유 |
|------------|------|
| **복잡한 조건문** | 취약하고 유지보수 어려움 |
| **모든 엣지 케이스** | 토큰 낭비, diminishing returns |
| **모호한 지시** | Claude가 추측해야 함 |
| **중복 정보** | Context 낭비 |
| **부정형 지시** | "Don't X" → "Do Y" 형태로 |

### Common Anti-Patterns

```text
❌ "Never use markdown" (부정형)
✅ "Write in flowing prose paragraphs" (긍정형)

❌ "If X then Y, unless Z, but if W..." (복잡한 조건)
✅ "Follow this pattern: [예시]" (패턴 제시)

❌ "You might want to consider..." (모호함)
✅ "Read the file before making changes" (명시적)

❌ CRITICAL: You MUST use this tool! (과도한 강조, Opus 4.5 overtrigger)
✅ Use this tool when... (일반적 지시)
```

</best_practices>

---

<examples>

## Real-World Examples

### Example 1: Agentic Coding

```xml
<coding_guidelines>

<investigation>
ALWAYS read and understand relevant files before proposing code edits. Do not
speculate about code you have not inspected. If the user references a specific
file/path, you MUST open and inspect it before explaining or proposing fixes.
</investigation>

<implementation>
Avoid over-engineering. Only make changes that are directly requested or clearly
necessary. Keep solutions simple and focused.

Don't add features, refactor code, or make "improvements" beyond what was asked.
A bug fix doesn't need surrounding code cleaned up. A simple feature doesn't
need extra configurability.

Don't create helpers, utilities, or abstractions for one-time operations. The
right amount of complexity is the minimum needed for the current task.
</implementation>

<testing>
Write a high-quality, general-purpose solution. Do not hard-code values or create
solutions that only work for specific test inputs. Implement the actual logic
that solves the problem generally.
</testing>

</coding_guidelines>
```

### Example 2: Research Task

```xml
<research_guidelines>

<approach>
Search for information in a structured way. As you gather data, develop several
competing hypotheses. Track confidence levels in your progress notes. Regularly
self-critique your approach and plan.
</approach>

<verification>
Verify information across multiple sources. Define clear success criteria for
what constitutes a successful answer.
</verification>

<state_tracking>
Update a hypothesis tree or research notes file to persist information and
provide transparency.
</state_tracking>

</research_guidelines>
```

### Example 3: Frontend Design

```xml
<frontend_aesthetics>

You tend to converge toward generic, "on distribution" outputs. In frontend
design, this creates what users call the "AI slop" aesthetic. Avoid this: make
creative, distinctive frontends that surprise and delight.

<focus_areas>
- **Typography**: Choose fonts that are beautiful, unique, and interesting.
  Avoid generic fonts like Arial and Inter; opt for distinctive choices.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables.
  Dominant colors with sharp accents outperform evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Focus on
  high-impact moments: one well-orchestrated page load with staggered reveals.
- **Backgrounds**: Create atmosphere and depth rather than solid colors.
  Layer CSS gradients, use geometric patterns, add contextual effects.
</focus_areas>

<avoid>
- Overused font families (Inter, Roboto, Arial, system fonts)
- Clichéd color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character
</avoid>

Interpret creatively and make unexpected choices that feel genuinely designed
for the context. Vary between light and dark themes, different fonts, different
aesthetics. It is critical that you think outside the box!

</frontend_aesthetics>
```

### Example 4: Multi-Context Workflow

```xml
<long_horizon_task>

<context_management>
Your context window will be automatically compacted as it approaches its limit,
allowing you to continue working indefinitely. Do not stop tasks early due to
token budget concerns. Save your current progress and state to memory before
the context window refreshes. Always be as persistent and autonomous as possible.
</context_management>

<first_context_window>
Use the first context window to set up a framework:
- Write tests in structured format (tests.json)
- Create setup scripts (init.sh)
- Establish quality of life tools
</first_context_window>

<subsequent_windows>
When starting with fresh context:
1. Call pwd
2. Review progress.txt, tests.json, and git logs
3. Manually run through fundamental integration test
4. Continue systematic work on todo list
</subsequent_windows>

<state_tracking>
- **Structured data**: Use JSON for test results, task status
- **Progress notes**: Use freeform text for general progress
- **Git**: Use git log to track what's been done
- **Incremental focus**: Keep track of progress, focus on incremental work
</state_tracking>

</long_horizon_task>
```

### Example 5: Tool Usage Optimization

```xml
<tool_guidance>

<file_operations>
- Search files: Use Glob (NOT find/ls)
- Content search: Use Grep (NOT grep/rg command)
- Read files: Use Read (NOT cat/head/tail)
- Edit files: Use Edit (NOT sed/awk)
- Write files: Use Write (NOT echo/cat heredoc)
</file_operations>

<exploration>
For open-ended codebase exploration, use Task tool with subagent_type=Explore
instead of running Glob/Grep directly. This prevents multiple rounds of
exploration and is more efficient.
</exploration>

<parallel_execution>
When multiple independent operations are needed, run tool calls in parallel:
- Reading 3 files → 3 Read calls in parallel
- Multiple searches → parallel Grep calls
- Git status + git diff → parallel Bash calls
</parallel_execution>

</tool_guidance>
```

</examples>

---

<advanced_techniques>

## Advanced Techniques

### 1. Thinking & Reflection

```xml
<thinking_guidance>
After receiving tool results, carefully reflect on their quality and determine
optimal next steps before proceeding. Use your thinking to plan and iterate
based on new information, then take the best next action.
</thinking_guidance>
```

### 2. Subagent Orchestration

```xml
<subagent_usage>
Only delegate to subagents when the task clearly benefits from a separate agent
with a new context window. Claude will delegate appropriately without explicit
instruction if subagent tools are well-defined.
</subagent_usage>
```

### 3. Vision + Crop Tool

```xml
<vision_optimization>
For improved image processing, provide a crop tool or skill. Claude performs
better when able to "zoom" in on relevant regions of an image.
</vision_optimization>
```

</advanced_techniques>

---

<document_organization>

## Document Organization Tips

### High-Density Principles

```xml
<document_structure>

✅ 코드/예시 중심, 설명 최소화
✅ 표 형식으로 정보 압축
✅ ✅/❌ 마커로 명확히 구분
✅ @imports로 just-in-time 로딩
✅ 복사 가능한 패턴 제공

❌ 장황한 설명
❌ 중복된 정보
❌ 모호한 지시사항
❌ 불필요한 텍스트

</document_structure>
```

### Template Structure

```xml
<claude_document_template>

# Title - Purpose

> Brief description

<instructions>
@path/to/guides.md
</instructions>

---

<forbidden>
[표 형식으로 금지사항]
</forbidden>

---

<required>
[표 형식으로 필수사항]
</required>

---

<patterns>
[복사 가능한 코드 패턴]
</patterns>

---

<examples>
[실전 예시]
</examples>

</claude_document_template>
```

</document_organization>

---

<sources>

## Sources

### English Documentation
- [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude 4.x Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Use XML tags to structure your prompts](https://console.anthropic.com/docs/en/build-with-claude/prompt-engineering/use-xml-tags)
- [Prompt Engineering Techniques - AWS Blog](https://aws.amazon.com/blogs/machine-learning/prompt-engineering-techniques-and-best-practices-learn-by-doing-with-anthropics-claude-3-on-amazon-bedrock/)

### Korean Documentation (한국어)
- [XML 태그를 사용하여 프롬프트 구조화하기](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/use-xml-tags)
- [사고의 연쇄 프롬프팅](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/chain-of-thought)
- [확장 사고 팁](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/extended-thinking-tips)

</sources>
