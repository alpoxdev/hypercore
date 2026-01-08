---
description: Claude Code 문서 작성 가이드
allowed-tools: Read, Write, Glob, Grep
argument-hint: <문서 유형: CLAUDE.md | SKILL.md | 기타>
---

# Docs Creator Command

Claude Code 문서 (CLAUDE.md, SKILL.md 등)를 효과적으로 작성.

<principles>

| 원칙 | 설명 |
|------|------|
| **코드 중심** | 예시 > 설명 |
| **복사 가능** | 바로 사용 가능한 패턴 |
| **구분 명확** | ✅/❌ 마커 사용 |
| **버전 명시** | Zod v4, Prisma v7 등 |
| **Just-in-Time** | @imports 로딩 |

</principles>

<structure>

**CLAUDE.md:**
```markdown
@instructions/...
@docs/library/...

## ⛔ NEVER DO
금지 사항

## ✅ ALWAYS DO
필수 사항

## Quick Patterns
```코드 예시```
```

**SKILL.md:**
```markdown
---
name: skill-name
description: ...
---

<trigger_conditions>
언제 사용하는가
</trigger_conditions>

<workflow>
실행 단계
</workflow>

<examples>
```코드 예시```
</examples>
```

</structure>

<guidelines>

| 항목 | 기준 |
|------|------|
| **토큰 효율** | 파일당 500줄 이하 |
| **구조화** | XML 태그 섹션 구분 |
| **중복 제거** | @imports 활용 |
| **예시 우선** | Few-shot > 규칙 나열 |

</guidelines>
