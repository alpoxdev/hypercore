# Ralph Document Templates

## TASKS.md

```markdown
# Tasks - [작업명]

생성: YYYY-MM-DD HH:MM
상태: Phase X/4

## 요구사항 체크리스트
- [ ] 요구사항 1: [설명]

## 완료 상태
- 완료: 0 / 총 X
- 진행률: 0%
```

## PROCESS.md

```markdown
# Process Log

## 현재 상태
- Phase: X (작업명)
- 진행 중: [현재 작업]
- 다음: [다음 작업]

## Phase 1: 작업 실행
**시작:** YYYY-MM-DD HH:MM

### 완료 항목
- 항목 1

### 진행 중
- 항목 2

### 의사결정
- 결정 1: [이유]
```

## VERIFICATION.md

```markdown
# Verification Results

## /pre-deploy 검증
**실행 시각:** 미실행
**결과:**
- Typecheck: 대기
- Lint: 대기
- Build: 대기

## TODO 확인
**실행 시각:** 미실행
**결과:** pending/in_progress = ?

## Planner 검증
**실행 시각:** 미실행
**응답:** 대기 중
```

## 업데이트 타이밍

| Phase | 문서 | 타이밍 |
|-------|------|--------|
| **1** | TASKS.md | 요구사항 완료 시 |
| **1** | PROCESS.md | Phase 전환 시 |
| **2** | VERIFICATION.md | /pre-deploy 후 |
| **3** | VERIFICATION.md | Planner 응답 후 |
| **4** | PROCESS.md | 완료 시각 기록 |
