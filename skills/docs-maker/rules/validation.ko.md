# Docs Maker용 Validation 규칙

**목적**: 완료 주장이 취향이 아니라 evidence로 뒷받침되게 합니다.

## 1. Completion Contract

모든 docs-maker 완료는 아래에 답할 수 있어야 합니다.

```text
Claim → Evidence → Verification → Caveat
```

최종 보고는 무엇을 바꿨는지, 무엇이 그것을 증명하는지, 무엇이 남은 risk 또는 미검증 항목인지 말해야 합니다.

## 2. Scope Completeness

벌크 변경이나 "모든 X" 문서 요청은 다음을 따릅니다.

1. search 또는 glob으로 전체 후보를 만듭니다.
2. 포함/제외 기준을 기록합니다.
3. 새 후보를 발견하면 추가하거나 제외 사유를 남깁니다.
4. 완료 전 재스캔합니다.
5. 의도적으로 제외한 항목을 보고합니다.

## 3. Verification Menu

| 주장 | 적합한 검증 |
|---|---|
| Markdown 구조 변경 | heading/readback check, fence balance, link/path grep |
| 링크 또는 reference 변경 | link existence, target path check, stale-ref grep |
| 출처 기반 주장 변경 | source ledger, claim-source matrix, official/current source check |
| prompt/instruction 변경 | smoke eval case, known failure readback, trace assertion |
| harness workflow 변경 | eval plan, tool contract, safety boundary, context/state policy |
| parallel/subagent workflow 변경 | bounded objective/scope/output/stop condition, ownership, parent integration/verification |

## 4. Agent 문서용 Trace Assertions

agent, subagent, background workflow를 문서화할 때 필요하면 trajectory check를 포함합니다.

- bounded spawn 또는 handoff prompt
- 독립 작업 또는 명시적 sequencing
- edit 가능 작업의 write ownership
- least-privilege tool access
- child evidence reporting
- parent synthesis와 final verification
- shared file/resource에 대한 conflicting edit 없음

## 5. Smoke Eval Shape

Instruction 변경에는 작은 eval case를 사용합니다.

```yaml
id: unique-case-id
intent: user goal
context:
  files: []
  sources: []
input: |
  user request
expected:
  must:
    - required behavior
  must_not:
    - forbidden behavior
metrics:
  - instruction_following
  - factuality
  - tool_use
  - safety
  - completion
```

## 6. Readback Pass

완료 전에 갱신된 문서를 다음 관점에서 읽습니다.

- 다음 rule을 배치해야 하는 새 maintainer
- context pressure 아래 workflow를 실행하는 agent
- stale, unsupported, mixed-concern claim을 찾는 reviewer

validation path를 찾기 위해 무관한 파일을 검색해야 한다면 실패로 봅니다.

## 7. Final Report Shape

```markdown
완료:
- [변경 파일과 결과]

검증:
- [실행한 점검과 증거]

남은 리스크:
- [없음 또는 명시적 caveat]
```

건너뛴 검증은 숨기지 말고 이유를 적습니다.

## 8. Reviewer Quick Gate

다음 중 하나라도 참이면 문서를 실패로 봅니다.

- canonical docs에 고정 모델명 또는 universal rule처럼 취급한 runtime-only syntax가 있음
- provider-sensitive 또는 current claim에 적절한 출처 근거가 없음
- retrieved content 또는 tool output을 instruction authority처럼 취급함
- 일반 docs-maker 표면에 무관한 implementation-stack mandate가 있음
- harness 문서가 범위상 필요한 eval, tool, safety, context, validation 경계를 빠뜨림
- 영어/한국어 mirror가 다른 phase 순서 또는 호환되지 않는 readback path를 드러냄
