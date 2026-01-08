---
description: 기존 Claude Code 문서 개선
allowed-tools: Read, Edit, Glob, Grep
argument-hint: <문서 경로>
---

# Docs Refactor Command

기존 CLAUDE.md, SKILL.md 문서를 Anthropic 가이드라인에 맞게 개선.

<checklist>

| 개선 항목 | 목표 |
|----------|------|
| **토큰 효율** | 불필요한 설명 제거 |
| **XML 태그** | 섹션 명확화 |
| **@imports** | 공통 규칙 분리 |
| **예시 중심** | 설명 → 코드 전환 |
| **중복 제거** | 반복 내용 통합 |

</checklist>

<workflow>

1. **문서 읽기 및 분석**

2. **개선 포인트 식별**
   - 장황한 설명
   - 중복 내용
   - XML 태그 미사용

3. **리팩토링 적용**

4. **토큰 수 비교** (50% 감소 목표)

</workflow>

<xml_tags>

**권장 태그:**
```markdown
<requirements>
<workflow>
<examples>
<principles>
<references>
```

</xml_tags>
