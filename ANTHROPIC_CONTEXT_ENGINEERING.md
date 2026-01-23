# Context Engineering for Claude

> Anthropic 공식 가이드 기반 효과적인 Instructions 작성법

<context>

**Purpose:** Claude Code/Agents에 효과적인 Instructions 작성

**Sources:**
- [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude 4.x Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [XML Tags](https://console.anthropic.com/docs/en/build-with-claude/prompt-engineering/use-xml-tags)
- [Chain of Thought](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/chain-of-thought)
- [Extended Thinking](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/extended-thinking-tips)

</context>

---

<forbidden>

| 분류 | 금지 |
|------|------|
| **설명** | 장황한 설명, Claude가 아는 것 반복 |
| **구조** | 중복 정보, 모호한 지시사항 |
| **표현** | 부정형 ("Don't X"), 과도한 강조 (CRITICAL 남발) |
| **복잡도** | 복잡한 조건문, 모든 엣지 케이스 나열 |

</forbidden>

---

<required>

| 분류 | 필수 |
|------|------|
| **구조** | XML 태그 섹션 구분, 명확한 계층 |
| **표현** | 표 형식 압축, ✅/❌ 마커 |
| **예시** | 코드 중심, 복사 가능 패턴 |
| **로딩** | @imports로 just-in-time 로딩 |
| **지시** | 긍정형 명시적 지시 |

</required>

---

<core_principles>

## Core Principles

### 1. Find the Right Altitude

> "Specific enough to guide, flexible enough to adapt"

| ❌ Too Low | ✅ Right Altitude | ❌ Too High |
|-----------|------------------|-------------|
| 복잡한 조건문 | 명확한 원칙 + 예시 | 모호한 지시 |
| 모든 엣지 케이스 | 핵심 패턴 | 구체성 부족 |

### 2. Context as Finite Resource

| 전략 | 방법 |
|------|------|
| **Just-in-Time** | 필요 시점에만 정보 제공 |
| **Minimal Start** | 최소 프롬프트 → 실패 시 추가 |
| **Token Minimization** | 중복 제거, 압축 표현 |

### 3. Explicit > Implicit (Claude 4.x)

**Claude 4.x는 명시적 지시에 강하게 반응**

```text
❌ "Create dashboard"
✅ "Create dashboard. Include as many relevant features as possible.
   Go beyond basics to create fully-featured implementation."
```

**Details:** [references/core-principles.md](references/core-principles.md)

</core_principles>

---

<xml_tags>

## XML Tags

### Why XML?

**Claude는 XML로 학습됨** → 구조화된 입력을 더 잘 이해

| 장점 | 설명 |
|------|------|
| **Clarity** | 구성 요소 명확 구분 |
| **Accuracy** | 오해석 감소 |
| **Parseability** | 출력 구조 제어 |

### Common Patterns

```xml
<!-- Instructions Document -->
<instructions>
@path/to/guide.md
</instructions>

<!-- Role + Task -->
<role>Expert developer</role>
<task>Specific task</task>

<!-- Forbidden + Required -->
<forbidden>
절대 금지사항
</forbidden>

<required>
반드시 필수사항
</required>

<!-- Examples -->
<examples>
  <example>
    <input>Input</input>
    <output>Output</output>
  </example>
</examples>

<!-- Thinking -->
<thinking>추론 과정</thinking>
<answer>최종 답변</answer>

<!-- Behavior Control -->
<default_to_action>
Implement directly
</default_to_action>
```

**Details:** [references/xml-tags.md](references/xml-tags.md)

</xml_tags>

---

<techniques>

## Chain of Thought (CoT)

**단계별 사고 유도 → 정확성 향상**

### Three Levels

| Level | Method | When |
|-------|--------|------|
| **Basic** | "단계별로 생각하세요" | 간단한 작업 |
| **Guided** | 구체적 단계 제공 | 중간 복잡도 |
| **Structured** | `<thinking>` 태그 | 복잡한 작업 (권장) |

### Pattern

```xml
<thinking>
1. 문제 분석
2. 접근 방법
3. 단계별 추론
4. 검증
</thinking>

<answer>
최종 답변
</answer>
```

### When to Use

```text
✅ 복잡한 수학, 다단계 분석, 의사결정
❌ 단순 검색, 변환, 지연 시간 중요한 경우
```

---

## Extended Thinking

**긴 추론 시간으로 복잡한 문제 해결** (최소 1024 토큰)

### Best Practices

```text
❌ 단계별 지시 (1. 변수 식별 2. 방정식...)
✅ 일반적 지시 ("철저히 생각하세요. 여러 접근법 고려.")

⚠️ 최소 예산: 1024 토큰
⚠️ 32K+ 예산: Batch Processing 권장
```

### When to Use

| Use Case | Example |
|----------|---------|
| **복잡한 STEM** | 4D 시각화, 고급 물리 |
| **제약 최적화** | 다중 제약 여행 계획 |
| **사고 프레임워크** | Porter's 5 Forces + 시나리오 |

**Details:** [references/techniques.md](references/techniques.md)

</techniques>

---

<claude_4x>

## Claude 4.x Specifics

### 1. Precise Instruction Following

**문자 그대로 따름** → 더 명시적으로 작성

| Situation | Claude 3.x | Claude 4.x |
|-----------|-----------|-----------|
| "Create dashboard" | 추가 기능 자동 | 최소한만 |
| "Suggest changes" | 때때로 구현 | 제안만 |

### 2. Action Control

```xml
<!-- 적극적 행동 -->
<default_to_action>
Implement changes rather than suggesting.
</default_to_action>

<!-- 보수적 행동 -->
<do_not_act_before_instructions>
Wait for explicit instruction.
</do_not_act_before_instructions>
```

### 3. Parallel Tool Calling

```xml
<use_parallel_tool_calls>
Call independent tools in parallel for speed.
</use_parallel_tool_calls>
```

**Details:** [references/claude-4x.md](references/claude-4x.md)

</claude_4x>

---

<best_practices>

## Best Practices

### Do's

| 원칙 | 방법 |
|------|------|
| **명시적** | "Create X with Y and Z features" |
| **Context** | 왜 중요한지 설명 |
| **예시** | 원하는 패턴 보여주기 |
| **구조화** | XML/Markdown 섹션 구분 |
| **점진적** | 최소 → 실패 시 보강 |

### Don'ts

| 피할 것 | 이유 |
|---------|------|
| **복잡한 조건** | 취약, 유지보수 어려움 |
| **모든 엣지 케이스** | 토큰 낭비 |
| **모호함** | Claude가 추측 |
| **중복** | Context 낭비 |
| **부정형** | "Don't X" → "Do Y" |

### Anti-Patterns

```text
❌ "Never use markdown" (부정형)
✅ "Write in flowing prose" (긍정형)

❌ "If X then Y, unless Z..." (복잡 조건)
✅ "Follow this pattern: [예시]"

❌ CRITICAL: MUST use this! (과도한 강조)
✅ Use this when... (일반 지시)
```

</best_practices>

---

<document_organization>

## Document Organization

### High-Density Principles

```xml
<structure>

✅ 코드/예시 중심, 설명 최소화
✅ 표 형식 정보 압축
✅ ✅/❌ 마커 명확 구분
✅ @imports just-in-time 로딩
✅ 복사 가능 패턴

❌ 장황한 설명
❌ 중복 정보
❌ 모호한 지시

</structure>
```

### Template

```xml
# Title - Purpose

<instructions>
@path/to/guides.md
</instructions>

---

<forbidden>
[표 형식 금지사항]
</forbidden>

---

<required>
[표 형식 필수사항]
</required>

---

<patterns>
[복사 가능 코드]
</patterns>

---

<examples>
[실전 예시]
</examples>
```

### Progressive Disclosure

| 위치 | 내용 | 크기 |
|------|------|------|
| **메인 파일** | 핵심 원칙 + 요약 | 300줄 이하 |
| **references/** | 상세 가이드 | 무제한 |

</document_organization>

---

<examples>

## Quick Examples

### Agentic Coding

```xml
<coding_guidelines>

<investigation>
ALWAYS read files before proposing edits. Do not speculate.
</investigation>

<implementation>
Avoid over-engineering. Only make directly requested changes.
</implementation>

</coding_guidelines>
```

### Frontend Design

```xml
<frontend_aesthetics>

Avoid generic "AI slop" aesthetic. Make creative, distinctive frontends.

<focus>
- Typography: Unique fonts (avoid Inter, Roboto)
- Color: Cohesive theme with sharp accents
- Motion: High-impact animations
- Backgrounds: Depth and atmosphere
</focus>

</frontend_aesthetics>
```

**More:** [references/examples.md](references/examples.md)

</examples>

---

<sources>

## Sources

### English
- [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude 4.x Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Use XML Tags](https://console.anthropic.com/docs/en/build-with-claude/prompt-engineering/use-xml-tags)

### Korean
- [XML 태그 사용](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/use-xml-tags)
- [사고의 연쇄](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/chain-of-thought)
- [확장 사고](https://platform.claude.com/docs/ko/build-with-claude/prompt-engineering/extended-thinking-tips)

</sources>
