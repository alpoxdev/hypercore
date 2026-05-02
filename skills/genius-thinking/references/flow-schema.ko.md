# Genius Thinking Flow Schema

> `.hypercore/genius-thinking/[topic-slug]/flow.json`용 JSON 스키마.

## Schema

```json
{
  "id": "gt-{topic-slug}-{YYYYMMDD-HHmmss}",
  "skill": "genius-thinking",
  "status": "in_progress | completed",
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "topic": "topic-slug",
  "request": {
    "challenge": "문제 또는 기회 진술",
    "target": "대상 사용자 또는 시장",
    "constraints": "예산, 팀, 일정, 규제"
  },
  "current_phase": "select | analyze | ideate | prioritize",
  "phases": {
    "select": {
      "status": "pending | in_progress | completed",
      "output_file": "frameworks.md",
      "selected_formulas": []
    },
    "analyze": {
      "status": "pending | in_progress | completed",
      "output_file": "analysis.md"
    },
    "ideate": {
      "status": "pending | in_progress | completed",
      "output_file": "ideas.md",
      "ideas_count": 0
    },
    "prioritize": {
      "status": "pending | in_progress | completed",
      "output_file": "priorities.md"
    }
  }
}
```

## Phase outputs

| Phase | File | Content |
|-------|------|---------|
| `select` | `frameworks.md` | 선택한 공식 + 근거 + HMW 재정의 |
| `analyze` | `analysis.md` | 깊이 있는 프레임워크 적용(SCAMPER, TRIZ, JTBD), 1500자 이상 |
| `ideate` | `ideas.md` | 10개 이상 아이디어: 제목, 설명, 혁신 지점, JTBD, 점수 |
| `prioritize` | `priorities.md` | ERRC 검증, 순위가 매겨진 후보 목록, quick wins vs big bets, 다음 단계 |

## Example: initial state

```json
{
  "id": "gt-ai-education-20260327-100000",
  "skill": "genius-thinking",
  "status": "in_progress",
  "created_at": "2026-03-27T10:00:00Z",
  "updated_at": "2026-03-27T10:00:00Z",
  "topic": "ai-education",
  "request": {
    "challenge": "AI 기반 교육 서비스 아이디어",
    "target": "직장인",
    "constraints": "소규모 팀, 6개월 내 MVP"
  },
  "current_phase": "select",
  "phases": {
    "select": { "status": "in_progress", "output_file": "frameworks.md" },
    "analyze": { "status": "pending", "output_file": "analysis.md" },
    "ideate": { "status": "pending", "output_file": "ideas.md" },
    "prioritize": { "status": "pending", "output_file": "priorities.md" }
  }
}
```
