# Task Completion Checklist

When completing a task in this project, follow these steps:

## Before Committing

### 1. Build Check
```bash
yarn build
```
Ensure TypeScript compilation passes without errors.

### 2. Lint Check
```bash
yarn lint
```
Fix any linting issues:
```bash
yarn lint:fix
```

### 3. Run Tests
```bash
yarn test
```
Ensure all tests pass.

### 4. Format Code
Prettier is configured. Most IDEs will format on save.
Verify formatting is correct.

## Code Review Checklist

- [ ] All exported functions have explicit return types
- [ ] No `any` types used
- [ ] Zod schemas validate all external inputs
- [ ] Error handling is appropriate
- [ ] File naming follows kebab-case convention
- [ ] Imports are properly ordered
- [ ] No unused imports or variables
- [ ] Tests cover new functionality

## After Task Completion

1. Update documentation if API changed
2. Update CLAUDE.md if conventions changed
3. Update relevant docs/ files if needed
4. Commit with descriptive message
