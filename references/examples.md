# Real-World Examples

> 실전에서 사용할 수 있는 프롬프트 패턴

## Agentic Coding

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

---

## Research Task

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

---

## Frontend Design

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

---

## Multi-Context Workflow

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

---

## Tool Usage Optimization

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

---

## Data Analysis

```xml
<data_analysis_guidelines>

<exploration>
1. Load and inspect data structure
2. Check for missing values, outliers, data types
3. Generate summary statistics
4. Visualize distributions
</exploration>

<analysis>
1. State clear hypothesis
2. Choose appropriate statistical methods
3. Validate assumptions
4. Interpret results with confidence intervals
</analysis>

<visualization>
- Use appropriate chart types for data
- Clear labels and titles
- Accessible color schemes
- Include sample size and confidence levels
</visualization>

<reporting>
Structure findings:
1. Executive summary
2. Methodology
3. Results with visualizations
4. Conclusions and recommendations
5. Limitations and future work
</reporting>

</data_analysis_guidelines>
```

---

## API Design

```xml
<api_design_guidelines>

<principles>
- **RESTful**: Use standard HTTP methods correctly
- **Consistent**: Same patterns across all endpoints
- **Versioned**: Include version in URL (e.g., /api/v1/)
- **Documented**: OpenAPI/Swagger specs
</principles>

<patterns>
GET    /api/v1/users          # List users
GET    /api/v1/users/:id      # Get user
POST   /api/v1/users          # Create user
PUT    /api/v1/users/:id      # Update user
PATCH  /api/v1/users/:id      # Partial update
DELETE /api/v1/users/:id      # Delete user
</patterns>

<response_format>
{
  "data": {...},           // Actual data
  "meta": {...},           // Pagination, etc.
  "errors": [...]          // Error details if any
}
</response_format>

<error_handling>
- 400: Bad Request (validation errors)
- 401: Unauthorized (not authenticated)
- 403: Forbidden (not authorized)
- 404: Not Found
- 500: Internal Server Error
</error_handling>

</api_design_guidelines>
```

---

## Documentation Writing

```xml
<documentation_guidelines>

<structure>
1. **Overview**: What is this? Why does it exist?
2. **Quick Start**: Get running in <5 minutes
3. **Core Concepts**: Key ideas to understand
4. **API Reference**: Detailed technical docs
5. **Examples**: Real-world usage
6. **Troubleshooting**: Common issues
</structure>

<style>
- Active voice ("Use X to do Y" not "X can be used to do Y")
- Present tense ("Returns" not "Will return")
- Second person ("You can..." not "The user can...")
- Code examples for every feature
- Keep paragraphs short (2-3 sentences)
</style>

<code_examples>
- Show both input and output
- Include error cases
- Real-world scenarios, not toy examples
- Copy-paste ready
</code_examples>

</documentation_guidelines>
```

---

## Testing Strategy

```xml
<testing_guidelines>

<unit_tests>
- Test one thing per test
- Clear test names describe behavior
- Arrange-Act-Assert pattern
- Mock external dependencies
- Fast execution (<1s per test)
</unit_tests>

<integration_tests>
- Test actual integrations
- Use test database/APIs
- Realistic data
- Can be slower
</integration_tests>

<e2e_tests>
- Critical user flows only
- Happy path + key error cases
- Run in CI before deploy
- Keep minimal (slow and brittle)
</e2e_tests>

<coverage>
- Aim for 80%+ line coverage
- 100% coverage on business logic
- Don't test framework code
- Focus on high-value tests
</coverage>

</testing_guidelines>
```

---

## Database Schema Design

```xml
<database_guidelines>

<naming>
- Tables: plural, lowercase (users, posts)
- Columns: snake_case (created_at, user_id)
- Primary keys: id (integer, auto-increment)
- Foreign keys: singular_table_id (user_id)
</naming>

<types>
- IDs: BIGINT or UUID
- Timestamps: TIMESTAMP WITH TIME ZONE
- Money: DECIMAL(19,4) or integer (cents)
- Text: TEXT (not VARCHAR with arbitrary limit)
</types>

<indexes>
- Primary key (id)
- Foreign keys
- Frequently queried columns
- Unique constraints where needed
</indexes>

<migrations>
- Never edit existing migrations
- Always reversible (up + down)
- Test on production-like data
- Deploy during low traffic
</migrations>

</database_guidelines>
```

---

## Security Review

```xml
<security_guidelines>

<authentication>
- Hash passwords (bcrypt, scrypt)
- Use secure session tokens
- Implement rate limiting
- HTTPS only in production
</authentication>

<authorization>
- Principle of least privilege
- Check permissions on every request
- Don't trust client-side checks
- Use role-based access control (RBAC)
</authorization>

<input_validation>
- Validate all user input
- Sanitize for XSS
- Parameterized queries (prevent SQL injection)
- File upload restrictions (type, size)
</input_validation>

<data_protection>
- Encrypt sensitive data at rest
- Use HTTPS for data in transit
- Secure environment variables
- Regular security audits
</data_protection>

</security_guidelines>
```
