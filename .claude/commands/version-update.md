---
description: 프로젝트 버전 업데이트 및 커밋
allowed-tools: Bash, Read, Edit
argument-hint: <new-version | +1 | +minor | +major>
---

<critical_instruction>

**CRITICAL: 사용자와의 모든 커뮤니케이션은 반드시 한국어로 작성하세요.**

- 내부 사고와 분석은 영어로 해도 됨
- 설명, 요약, 보고서, 피드백 등 사용자에게 전달하는 모든 내용은 반드시 한국어
- 사용자가 영어로 말하더라도 답변은 한국어로
- 진행 상황 업데이트와 상태 보고는 반드시 한국어

이 규칙은 절대적이며 예외가 없습니다.

</critical_instruction>

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
