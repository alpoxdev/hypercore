# Code Style and Conventions

## File Naming
- **kebab-case** for all files: `user-service.ts`, `add-component.ts`
- Components: `user-profile.tsx`
- Tests: `*.test.ts` or `*.spec.ts`
- Types: `*-types.ts` or inline

## TypeScript Standards
- Use `const` over `function` declarations
- Explicit return types on all exported functions
- Use `interface` for object shapes, `type` for unions/intersections
- Strict mode enabled (`strict: true`)
- No `any` types - use `unknown` when truly unknown

## Import Order
1. External libraries (Node built-ins, packages)
2. Internal packages (`@claude-code/*`)
3. Relative imports (parent dirs first)
4. Type imports (using `type` keyword)

## Code Style (Prettier)
- No semicolons
- Single quotes
- 2-space indentation
- 100 character line width
- Trailing commas in ES5 style

## Module System
- ES Modules (`"type": "module"`)
- Use `.js` extension in imports for TypeScript files
- Example: `import { foo } from './bar.js'`

## Tool Pattern (MCP Server)
```typescript
const inputSchema = z.object({
  // Zod schema for validation
})

export const toolName: Tool = {
  name: 'tool_name',  // snake_case
  description: 'Description',
  inputSchema,
  handler: async (input) => {
    // Implementation
    return { success: true, result: {} }
  },
}
```

## Response Pattern
```typescript
interface ToolResponse<T> {
  success: boolean
  result?: T
  error?: string
}
```
