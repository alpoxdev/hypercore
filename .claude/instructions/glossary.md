# Glossary - 용어 통일 규칙

Claude Code 템플릿에서 사용하는 공식 용어 정의

---

## 용어 통일 규칙

| 공식 용어 | 의미 | 금지 대체어 | 예시 |
|-----------|------|------------|------|
| **Task 에이전트** | Task 도구로 실행하는 서브 에이전트 | subagent, 서브태스크, delegation | `Task(subagent_type="planner", ...)` |
| **TaskCreate** | 작업 목록 생성 도구 (현재 API) | TodoWrite (레거시) | `TaskCreate(subject="...", description="...")` |
| **TaskUpdate** | 작업 상태 업데이트 도구 (현재 API) | TodoUpdate (레거시) | `TaskUpdate(taskId="1", status="completed")` |
| **Phase** | 워크플로우의 대단계 (Phase 1-4) | Stage | ralph: Phase 1 (작업 실행) |
| **Step** | Phase 내 세부 단계 | - | Phase 1, Step 3: 파일 읽기 |

---

## 레거시 용어

| 레거시 용어 | 현재 API | 마이그레이션 일자 |
|------------|---------|-----------------|
| TodoWrite | TaskCreate | 2026-01 |
| TodoUpdate | TaskUpdate | 2026-01 |
| subagent | Task 에이전트 | - |

**참고:** 기존 문서에서 TodoWrite/TodoUpdate를 발견하면 TaskCreate/TaskUpdate로 교체

---

## 스킬 용어

| 용어 | 의미 |
|------|------|
| **user-invocable skill** | 사용자가 직접 호출 가능한 스킬 (예: /plan, /ralph) |
| **스킬 체이닝** | 스킬 간 연결 (brainstorm → research → prd → plan → execute) |
| **고유 패턴** | 각 스킬만의 특화된 실행 패턴 (예: ralph의 무한 루프) |

---

## 에이전트 관련 용어

| 용어 | 의미 |
|------|------|
| **병렬 실행** | 여러 Task 에이전트를 동시에 실행 (독립적인 작업) |
| **순차 실행** | Task 에이전트를 하나씩 실행 (의존성 있는 작업) |
| **모델 라우팅** | 작업 복잡도에 따라 haiku/sonnet/opus 선택 |
| **에이전트 위임** | 작업을 Task 에이전트에게 맡김 |
