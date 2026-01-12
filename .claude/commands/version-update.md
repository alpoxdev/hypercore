---
description: 프로젝트 버전 업데이트 및 커밋
allowed-tools: Bash, Read, Edit
argument-hint: <new-version | +1 | +minor | +major>
---

@../instructions/git-rules.md

# Version Update Command

Update and commit entire project version.

**Argument**: $ARGUMENTS

<version_rules>

| Argument | Action | Example |
|----------|--------|---------|
| `+1` | patch +1 | 0.1.13 → 0.1.14 |
| `+minor` | minor +1 | 0.1.13 → 0.2.0 |
| `+major` | major +1 | 0.1.13 → 1.0.0 |
| `x.x.x` | Set directly | 0.1.13 → 2.0.0 |

</version_rules>

<workflow>

1. **Check current version** (parallel read)
   - packages/claude-code/package.json
   - packages/claude-code/src/index.ts

2. **Calculate new version**

3. **Update all files with Edit**

4. **Stage files**
   ```bash
   git add packages/claude-code/package.json packages/claude-code/src/index.ts
   ```

5. **Commit**
   ```bash
   git commit -m "chore: Update version to X.X.X"
   ```

6. **Verify completion**
   ```bash
   git status
   ```

</workflow>

<update_targets>

| File | Modification location |
|------|----------------------|
| `package.json` | `"version": "x.x.x"` |
| `src/index.ts` | `.version('x.x.x')` |

</update_targets>

<examples>

```bash
/version-update +1
→ 0.1.13 → 0.1.14
→ chore: Update version to 0.1.14

/version-update +minor
→ 0.1.13 → 0.2.0

/version-update 2.0.0
→ Set directly
```

</examples>
