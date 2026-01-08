---
description: 프로젝트 버전 업데이트 및 커밋
allowed-tools: Bash, Read, Edit
argument-hint: <new-version | +1 | +minor | +major>
---

@../instructions/git-rules.md

# Version Update Command

프로젝트 전체 버전을 업데이트하고 커밋.

**인수**: $ARGUMENTS

<version_rules>

| 인수 | 동작 | 예시 |
|------|------|------|
| `+1` | patch +1 | 0.1.13 → 0.1.14 |
| `+minor` | minor +1 | 0.1.13 → 0.2.0 |
| `+major` | major +1 | 0.1.13 → 1.0.0 |
| `x.x.x` | 직접 지정 | 0.1.13 → 2.0.0 |

</version_rules>

<workflow>

1. **현재 버전 확인** (병렬 읽기)
   - packages/claude-code/package.json
   - packages/claude-code/src/index.ts

2. **새 버전 계산**

3. **모든 파일 Edit로 업데이트**

4. **스테이징**
   ```bash
   git add packages/claude-code/package.json packages/claude-code/src/index.ts
   ```

5. **커밋**
   ```bash
   git commit -m "chore: 버전 X.X.X로 업데이트"
   ```

6. **완료 확인**
   ```bash
   git status
   ```

</workflow>

<update_targets>

| 파일 | 수정 위치 |
|------|----------|
| `package.json` | `"version": "x.x.x"` |
| `src/index.ts` | `.version('x.x.x')` |

</update_targets>

<examples>

```bash
/version-update +1
→ 0.1.13 → 0.1.14
→ chore: 버전 0.1.14로 업데이트

/version-update +minor
→ 0.1.13 → 0.2.0

/version-update 2.0.0
→ 직접 지정
```

</examples>
