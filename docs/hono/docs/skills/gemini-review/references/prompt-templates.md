# Prompt Templates for Gemini Review

## Command Patterns

All commands use the fixed model `gemini-3-pro-preview` with JSON output for parsing.

### Basic Pattern
```bash
gemini -m gemini-3-pro-preview -p "{prompt}" --output-format json
```

### File Piping Pattern
```bash
cat {file_path} | gemini -m gemini-3-pro-preview -p "{instructions}" --output-format json
```

### Multi-line Heredoc Pattern
```bash
gemini -m gemini-3-pro-preview --output-format json -p "$(cat << 'EOF'
{multi_line_prompt}
EOF
)"
```

### Response Parsing
```bash
result=$(gemini -m gemini-3-pro-preview -p "..." --output-format json)
review_content=$(echo "$result" | jq -r '.response')
echo "$review_content"
```

---

## Plan Review Template

```bash
gemini -m gemini-3-pro-preview --output-format json -p "$(cat << 'EOF'
[PLAN REVIEW REQUEST]

## Context
Project: {project_name}
Tech Stack: {tech_stack}
Current State: {current_state_description}

## Implementation Plan
{plan_content}

## Review Checklist
{checklist_items}

## Review Instructions
Analyze this implementation plan and provide feedback on:

1. **Completeness**
   - Are all requirements addressed?
   - Any missing steps or considerations?

2. **Logic & Feasibility**
   - Will this approach work as intended?
   - Any logical flaws or contradictions?

3. **Edge Cases**
   - What edge cases might be missed?
   - How should they be handled?

4. **Risks & Issues**
   - Potential problems during implementation?
   - Dependencies or blockers?

5. **Alternatives**
   - Better approaches available?
   - Trade-offs to consider?

Respond with:
- ✅ Strengths of the plan
- ⚠️ Concerns or issues found
- 💡 Suggestions for improvement
- 🔄 Alternative approaches (if any)
EOF
)"
```

---

## Code Review Template

### Option A: Inline Code
```bash
gemini -m gemini-3-pro-preview --output-format json -p "$(cat << 'EOF'
[CODE REVIEW REQUEST]

## Context
File: {file_path}
Language: {language}
Tech Stack: {tech_stack}
Purpose: {purpose_description}

## Code to Review
```{language}
{code_content}
```

## Review Checklist
{checklist_items}

## Review Instructions
Perform a thorough code review focusing on:

1. **Bugs & Logic Errors**
   - Incorrect logic or algorithms
   - Off-by-one errors
   - Null/undefined handling
   - Type mismatches

2. **Security Vulnerabilities**
   - Injection risks (SQL, XSS, etc.)
   - Authentication/authorization gaps
   - Data exposure risks
   - Input validation issues

3. **Performance Issues**
   - Inefficient algorithms (specify Big-O if problematic)
   - N+1 queries
   - Memory leaks
   - Unnecessary operations

4. **Best Practices**
   - Code organization
   - Naming conventions
   - Error handling patterns
   - Testing considerations

5. **Maintainability**
   - Code clarity
   - Documentation needs
   - Coupling and cohesion
   - Future extensibility

For each issue found, provide:
- 🔴 CRITICAL / 🟡 IMPORTANT / 🟢 MINOR
- Location (line number or function name)
- Description of the issue
- Suggested fix with code example
EOF
)"
```

### Option B: Piping File Content
```bash
cat {file_path} | gemini -m gemini-3-pro-preview --output-format json -p "Review this {language} code ({tech_stack} project) for:
1. Bugs and logic errors
2. Security vulnerabilities
3. Performance issues
4. Best practices violations
5. Maintainability concerns

For each issue: specify severity (🔴 CRITICAL/🟡 IMPORTANT/🟢 MINOR), location, description, and suggested fix with code."
```

---

## Architecture Review Template

```bash
gemini -m gemini-3-pro-preview --output-format json -p "$(cat << 'EOF'
[ARCHITECTURE REVIEW REQUEST]

## System Overview
Name: {system_name}
Purpose: {system_purpose}
Tech Stack: {tech_stack}
Scale: {expected_scale}

## Current/Proposed Architecture
{architecture_description}

## Components
{components_list}

## Data Flow
{data_flow_description}

## Specific Questions
{specific_questions}

## Review Instructions
Evaluate this architecture considering:

1. **Scalability**
   - Can it handle expected load?
   - Horizontal vs vertical scaling options?
   - Bottlenecks identified?

2. **Reliability**
   - Single points of failure?
   - Fault tolerance mechanisms?
   - Recovery strategies?

3. **Maintainability**
   - Component coupling?
   - Deployment complexity?
   - Operational overhead?

4. **Security**
   - Attack surface?
   - Data protection?
   - Access control boundaries?

5. **Cost Efficiency**
   - Resource utilization?
   - Scaling costs?
   - Operational costs?

6. **Trade-offs**
   - What are we sacrificing?
   - Alternative architectures?
   - Migration path considerations?

Respond with:
- 📊 Overall assessment
- ✅ Architectural strengths
- ⚠️ Concerns and risks
- 💡 Recommendations
- 🔄 Alternative approaches worth considering
EOF
)"
```

---

## Hono-Specific Additions

When tech_stack is `hono`, append to the relevant template:

```
## Hono-Specific Review Points
- Middleware chain correctness and order
- zValidator usage and Zod schema design
- HTTPException usage for error handling
- Context (c) usage patterns
- Type-safe bindings and variables
- RPC client type exports
- Built-in middleware configuration
```

---

## Cloudflare Workers-Specific Additions

When tech_stack is `cloudflare`, append to the relevant template:

```
## Cloudflare Workers-Specific Review Points
- Edge runtime compatibility (no Node.js APIs)
- KV, D1, R2 binding usage
- wrangler.toml configuration
- Environment variable handling via c.env
- Request/response size limits
- CPU and memory constraints
- Subrequest limits (<50)
- Durable Objects if applicable
```

---

## Quick Review Templates

### Security Quick Check
```bash
cat {file_path} | gemini -m gemini-3-pro-preview -p "Security audit this Hono code. Find: injection vulnerabilities, auth issues, data exposure risks, input validation gaps. List each with severity and fix." --output-format json
```

### Performance Quick Check
```bash
cat {file_path} | gemini -m gemini-3-pro-preview -p "Performance review this Hono code. Find: inefficient algorithms (note Big-O), N+1 queries, memory issues, unnecessary operations. Suggest optimizations." --output-format json
```

### Bug Hunt
```bash
cat {file_path} | gemini -m gemini-3-pro-preview -p "Find bugs in this code: logic errors, edge cases, null handling, race conditions, type issues. For each bug, show the fix." --output-format json
```

### Middleware Review
```bash
cat {file_path} | gemini -m gemini-3-pro-preview -p "Review this Hono middleware for: proper next() handling, error propagation, type safety, reusability, and side effects. Suggest improvements." --output-format json
```

### Validation Review
```bash
cat {file_path} | gemini -m gemini-3-pro-preview -p "Review Zod schemas and zValidator usage: schema completeness, error messages, type inference, reusability. Use Zod v4 syntax." --output-format json
```

---

## Template Usage Instructions

1. Select the appropriate base template (plan/code/architecture)
2. Fill in all `{placeholder}` fields with actual content
3. Load the relevant checklist from `checklists.md` based on tech stack
4. Append tech-stack-specific additions if applicable
5. Execute via Gemini CLI
6. Parse JSON response to extract `.response` field
7. Present both raw Gemini response and Claude's analysis
