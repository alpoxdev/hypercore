---
name: vs-design-diverge
description: Create high-entropy frontend interfaces using Verbalized Sampling (VS). Break mode collapse, avoid AI-slop aesthetics. Use for distinctive design work.
---

<context>

**Purpose:** Mitigate Mode Collapse (tendency to produce generic AI output) and create production-grade frontend interfaces

**Principle:** Verbalized Sampling (VS) - Verbalize typical design (P ≈ 0.95), then deliberately select Low-T (low typicality) alternatives

</context>

---

<workflow>

## Execution Flow

```
Phase 0: Context Discovery
  ↓ (AskUserQuestion - probe 4 dimensions)
Phase 1: Identify the Mode
  ↓ (verbalize P ≈ 0.95 baseline, avoid it)
Phase 2: Sample the Long-Tail
  ↓ (3 directions + T-Score justification)
Phase 3: Commit to Low-Typicality
  ↓ (lowest T-Score + pass Guardrails)
Phase 4: Implementation
  ↓ (production-grade code)
Phase 5: Surprise Validation
  ↓ (AI-typical? → refactor)
```

### Phase 0: Context Discovery

**Probe these dimensions using AskUserQuestion tool:**

| Dimension | Question Examples |
|-----------|-------------------|
| **Emotional Tone** | "Trustworthy", "edgy", "playful", "luxurious" - which atmosphere? |
| **Target Audience** | Who will see this? Technical sophistication? Expectations? |
| **Reference Points / Anti-References** | Benchmark examples? Styles to explicitly avoid? |
| **Business Context** | Problem this UI solves? Usage scenario? |

**Additional signals:**
- Existing code: Extract style patterns, color schemes, component conventions
- User prompt: Parse keywords (landing page, dashboard, portfolio, SaaS, etc.)
- Follow-up questions: Surface full vision even for simple prompts

Gather sufficient context before proceeding to Phase 1.

### Phase 1: Identify the Mode

**Verbalize the highest-probability (P ≈ 0.95) design:**

AI-slop markers:
- Inter/Roboto/System fonts
- Rounded blue/purple buttons
- Standard F-pattern layouts
- White backgrounds with gradient accents
- Generic hero sections with stock imagery

**Avoid this baseline.**

### Phase 2: Sample the Long-Tail

**Generate 3 directions with T-Score (Typicality Score, 0~1.0):**

| Direction | T-Score | Characteristics |
|-----------|---------|-----------------|
| **A** | ≈ 0.7 | Modern/Clean, safe |
| **B** | ≈ 0.4 | Distinctive/Characterful (specific niche style) |
| **C** | < 0.2 | Experimental/Bold (high-entropy, unexpected) |

**T-Score justification required:** Explain WHY each direction has that score. Reference specific design choices.

### Phase 3: Commit to Low-Typicality

**Select lowest T-Score that meets:**
1. Functional requirements from Phase 0
2. All Quality Guardrails

Deliberate and intentional choice, not accidental.

</workflow>

---

<guardrails>

## Quality Principles

Experimental designs must satisfy these principles. If violated, increase T-Score until compliance.

| Principle | Description |
|-----------|-------------|
| **Visual Hierarchy** | Clear priority ordering (1st → 2nd → 3rd) |
| **Contrast & Legibility** | Text readable against background (WCAG AA minimum) |
| **Internal Consistency** | Design follows its own logic (not random) |
| **Functional Clarity** | Interactive elements recognizable, affordances clear |

</guardrails>

---

<anti_patterns>

## Failure Patterns

| Pattern | Symptoms | Validation |
|---------|----------|------------|
| **Accidental Design** | Differentiation without intent, randomness | "Why this color/font/layout?" → must have coherent answer |
| **Frankenstein Style** | Incompatible aesthetics mixed, no unity | "Describe this design's personality in one sentence?" → must be possible |

</anti_patterns>

---

<aesthetics>

## Frontend Aesthetics Guidelines (VS-Enhanced)

**Inversion Principle:** If a choice feels "obvious," it has too much probability mass → consider lower-probability, higher-impact alternatives (when context-appropriate).

### Typography

| Category | Content |
|----------|---------|
| ❌ **AI-slop** | Inter, Roboto, Arial, System fonts, Space Grotesk (default usage) |
| ✅ **Low-T** | High-character display faces + refined, unexpected body typefaces. Variable fonts, unusual weights. |
| **Context-dependent** | Brutalist portfolio → industrial sans-serifs / Luxury brand → refined serifs |

### Color & Theme

| Principle | Description |
|-----------|-------------|
| ✅ **Uneven distribution** | Cohesive but "dissonant-yet-beautiful" palette |
| ✅ **CSS Variables** | Systematic theming |
| ✅ **Texture-first** | Sophisticated noise/lighting over flat fills (when context-appropriate) |

### Spatial Composition

| Condition | Approach |
|-----------|----------|
| **Standard grid (P=0.9)** | Consider asymmetry, overlapping elements, diagonal flows, editorial whitespace (P=0.1) |
| **Data-heavy UIs** | Dashboards, tables → conventional grids may be needed (usability priority) |

### Motion

| Principle | Description |
|-----------|-------------|
| ✅ **Micro-delights** | Staggered reveals, scroll-bound transformations, custom easing |
| ❌ **Purposeless motion** | Every animation must have purpose |

</aesthetics>

---

<frameworks>

## AIDA Framework (Conditional)

**Apply only for persuasion/conversion goals (landing pages, marketing sites, product showcases):**

| Stage | Goal | Design Application |
|-------|------|-------------------|
| **A**ttention | Stop scroll, create immediate visual impact | Bold typography, unexpected imagery, striking color contrast |
| **I**nterest | Build curiosity, encourage exploration | Progressive information reveal, visual storytelling, highlight unique value |
| **D**esire | Create emotional connection, make them want it | Social proof, benefits visualization, aspirational imagery, micro-interactions |
| **A**ction | Drive conversion with clear next steps | High-contrast CTAs, reduced friction, urgency cues (when appropriate) |

### Application Conditions

| Apply ✅ | Don't Apply ❌ |
|---------|----------------|
| Landing/marketing pages | Dashboards, data-heavy UIs (usability priority) |
| Product launch pages | Documentation/content-focused sites (readability priority) |
| Client-attracting portfolios | Internal tools (efficiency priority) |

**VS + AIDA Integration:** Apply Low-T aesthetics to EACH AIDA stage. Generic hero → Attention failure / Predictable CTA → Action failure. AIDA = "what", VS = "how".

</frameworks>

---

<implementation>

## Implementation Standards

| Standard | Description |
|----------|-------------|
| **Production-Grade** | Functional, accessible (A11y), performant |
| **Complexity-Typicality Balance** | Low-T design → implementation complexity increases proportionally (maintain quality) |
| **No Complexity Refusal** | Pursue extraordinary work, don't simplify vision |

</implementation>

---

<validation>

## Final Validation

Pre-delivery checklist:

1. **Intentionality**: Can you justify every major design decision?
2. **Consistency**: Does the design follow its own internal logic?
3. **Guardrails**: Are hierarchy, legibility, consistency, and clarity preserved?
4. **Surprise**: Would this stand out in a lineup of AI-generated designs?

**Goal:** Maximize "Surprise Score" while maintaining "Production Quality." Deliberate disruption.

</validation>

---

<examples>

## Practical Examples

### Phase 2: T-Score Justification

```markdown
**Direction A (T ≈ 0.7): Modern Minimal**
- Inter font, white background, blue buttons
- High typicality: 2020s SaaS standard pattern

**Direction B (T ≈ 0.4): Brutalist Style**
- Space Mono font, grid background, angular black buttons
- Lower typicality: Specific niche, non-mainstream choice

**Direction C (T < 0.2): Neo-Baroque**
- Fraunces Display font, irregular layout, animated gradients
- Very low probability: Rarely seen on web
```

### Typography Code

```css
/* ❌ AI-slop */
font-family: 'Inter', system-ui, sans-serif;

/* ✅ Low-T (Brutalist portfolio) */
@import url('https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&display=swap');
font-family: 'Space Mono', monospace;
font-variation-settings: 'wght' 650;

/* ✅ Low-T (Luxury brand) */
@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@300;500&display=swap');
font-family: 'Cormorant Garamond', serif;
letter-spacing: 0.05em;
```

### Color System

```css
/* ❌ AI-slop (even distribution) */
:root {
  --primary: #3b82f6; /* blue */
  --secondary: #a855f7; /* purple */
  --accent: #10b981; /* green */
}

/* ✅ Low-T (uneven, cohesive) */
:root {
  --dominant: #0a0908; /* near-black (60%) */
  --support: #8d99ae; /* neutral blue (30%) */
  --punch: #ef233c; /* intense red (10%) */
  --texture: url('data:image/svg+xml,...'); /* noise overlay */
}
```

### AIDA + Low-T Integration

```tsx
// Hero Section (Attention stage + Low-T)
<section className="hero">
  <h1 style={{
    fontFamily: 'Fraunces',
    fontSize: 'clamp(3rem, 10vw, 8rem)',
    fontVariationSettings: '"SOFT" 100, "WONK" 1',
    background: 'linear-gradient(135deg, #0a0908, #ef233c)',
    backgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
  }}>
    Disruptive Product Name
  </h1>
  {/* Unexpected imagery treatment */}
</section>

// CTA (Action stage + Low-T)
<button style={{
  background: '#ef233c',
  color: '#0a0908',
  border: '2px solid #0a0908',
  padding: '1.5rem 3rem',
  fontSize: '1.25rem',
  fontWeight: 700,
  clipPath: 'polygon(5% 0, 100% 0, 95% 100%, 0 100%)', // asymmetric
  transition: 'clip-path 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
}}>
  Get Started →
</button>
```

</examples>
