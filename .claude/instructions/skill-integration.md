# Skill Integration Map

스킬 간 연결 및 전환 규칙 정의

---

<skill_chaining>

## 아이디어 → 구현 파이프라인

```
brainstorm → research → prd → plan → execute → ralph(검증)
```

## 전환 규칙

| From | To | 트리거 조건 | 전달 데이터 |
|------|-----|-------------|------------|
| brainstorm | research | 아이디어 확정 후 팩트 검증 필요 | .claude/brainstorms/NN.*/SUMMARY.md |
| research | prd | 기술 조사 완료, 요구사항 정리 필요 | .claude/research/NN.*/REPORT.md |
| prd | plan | PRD 확정, 구현 방법 결정 필요 | PRD.md |
| plan | execute | 옵션 선택 완료, 즉시 구현 | .claude/plans/NN.*/IMPLEMENTATION.md |
| execute | ralph | 구현 중 검증 반복 필요 시 | 현재 작업 상태 |

## 단축 경로

| 상황 | 경로 |
|------|------|
| 간단한 버그 | bug-fix (단독) |
| 명확한 요구사항 | plan → execute |
| 반복 수정 | ralph (단독) |
| 복잡한 리팩토링 | refactor → plan → execute |
| 기존 코드 개선 | refactor (단독) |

</skill_chaining>

---

<session_continuity>

## Partially Achieved 방지

| 원칙 | 구현 |
|------|------|
| **문서 경로 명시** | 다음 스킬로 전환 시 생성된 문서 경로 명확히 전달 |
| **체크포인트 기록** | 각 스킬 완료 시 .claude/[스킬명]/NN.*/SUMMARY.md 생성 |
| **중단 시 복구** | 세션 재개 시 마지막 생성된 문서 읽고 이어서 진행 |

## 파이프라인 연결 예시

```bash
1. /brainstorm "사용자 인증 개선"
   → .claude/brainstorms/00.사용자_인증/SUMMARY.md

2. /research @.claude/brainstorms/00.사용자_인증/SUMMARY.md
   → .claude/research/00.OAuth_vs_JWT/REPORT.md

3. /prd @.claude/research/00.OAuth_vs_JWT/REPORT.md
   → PRD.md

4. /plan @PRD.md
   → .claude/plans/00.인증_개선/IMPLEMENTATION.md

5. /execute @.claude/plans/00.인증_개선/IMPLEMENTATION.md
   → 구현 완료

6. /ralph (필요 시)
   → 검증 루프
```

</session_continuity>

---

<output_matrix>

## 스킬별 출력 문서

| 스킬 | 출력 문서 | 다음 스킬 입력 |
|------|----------|--------------|
| brainstorm | .claude/brainstorms/NN.*/SUMMARY.md | research |
| research | .claude/research/NN.*/REPORT.md | prd |
| prd | PRD.md | plan |
| plan | .claude/plans/NN.*/IMPLEMENTATION.md | execute |
| execute | 구현 완료 | ralph (필요 시) |
| ralph | 검증 완료 | - |
| bug-fix | 수정 완료 | - |
| refactor | 리팩토링 완료 | plan (필요 시) |

</output_matrix>
