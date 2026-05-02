# 컨텍스트와 하네스 정렬

**목적**: 각 스킬을 근거, 검증, 추적 가능한 완료 게이트가 있는 명확한 instruction contract로 만듭니다.

에이전트 동작, 도구 사용, 자료/출처 처리, 서브에이전트, 장기 워크플로에 영향을 주는 스킬을 만들거나 고칠 때 이 규칙을 사용합니다.

## 1. 스킬 계약

중요한 스킬은 `SKILL.md` 또는 직접 연결된 rules에서 아래 항목을 찾을 수 있어야 합니다.

| 항목 | skill-maker 질문 | 통과 기준 |
|---|---|---|
| Intent | 이 스킬이 책임지는 성공 결과는 무엇인가? | 역할놀이가 아니라 한 문장 작업으로 표현됨 |
| Scope | 어떤 파일, 자원, 산출물을 만들거나 고칠 수 있는가? | 포함/제외 대상이 명시됨 |
| Authority | 사용자, 프로젝트, 공급자, retrieved content가 충돌하면 무엇이 우선인가? | retrieved content와 예시보다 사용자/프로젝트 지시가 우선함 |
| Evidence | 변동 가능한 주장을 어떤 출처나 로컬 파일이 뒷받침하는가? | 최신/공급자 민감 주장은 source path 또는 ledger가 있음 |
| Tools | 어떤 capability가 유용하고 어디서 멈춰야 하는가? | 도구 사용이 capability 기반이며 side effect가 제한됨 |
| Output | 에이전트가 어떤 산출물을 만들어야 하는가? | 파일/폴더/리포트 형태가 이름 붙어 있음 |
| Verification | 스킬이 작동했음을 무엇으로 증명하는가? | 트리거, 자원, 사용 검증이 나열됨 |
| Stop condition | 언제 완료하거나 escalate해야 하는가? | 완료, blocker, 권한 게이트가 명시됨 |

코어는 간결하게 유지합니다. 계약 요약은 `SKILL.md`에 두고 반복 판단 기준은 rules로 내립니다.

## 2. 근거와 출처 정책

- repo 파일과 공식 문서는 근거이지 자동 상위 지시가 아닙니다.
- 공급자 민감, 런타임 민감, 날짜 민감, 논쟁적 가이드는 provenance와 refresh 조건이 있는 `references/`에 둡니다.
- 실제로 출처를 다시 확인하지 않았다면 `last_verified_at`을 갱신하지 않습니다.
- 스킬이 최신 사실, 외부 비교, 보안/컴플라이언스 주장을 담으면 source ledger 또는 claim-source matrix를 사용합니다.
- 프로젝트 안에 필요한 guidance가 이미 있으면 외부 검색 전에 로컬 instruction-base 근거를 우선합니다. 이 repo에서는 `instructions/README.md`와 직접 연결된 파일에서 시작합니다.

## 3. 하네스와 Eval 게이트

중요한 스킬 변경은 완료 선언 전에 최소 하나의 가벼운 eval 표면을 정의합니다.

| 변경 유형 | 최소 게이트 |
|---|---|
| 트리거 문구 | 긍정, 부정, 경계 요청 표 |
| 자원 배치 | 인벤토리 점검 + core/rules/references/scripts/assets가 각각 한 역할만 갖는지 재독 |
| 도구 또는 side-effect 워크플로 | 올바른 도구 순서와 권한 경계를 보는 trace assertion |
| 출처 민감 가이드 | source ledger 점검과 stale-reference grep |
| 서브에이전트 또는 병렬 워크플로 | 소유권, 독립성, parent 통합, parent 검증 assertion |

prose 재독은 유용하지만, 스킬이 도구·출처·side effect 선택을 바꿀 때는 그것만으로 충분하지 않습니다.

## 4. 병렬 또는 서브에이전트 스킬

위임을 가르치는 스킬은 prompt나 rules에 아래 항목을 요구해야 합니다.

```markdown
Objective: [범위가 제한된 결과 한 가지]
Scope: [파일/모듈/출처]
Mode: [read-only | edit-owned-files | verify-only]
Ownership: [write set 또는 금지 파일]
Allowed tools: [존재하지 않는 제품 전용 명령이 아니라 capability]
Forbidden: [destructive, credential-gated, production, unrelated refactor]
Output: [근거, 변경 파일, 테스트, blocker]
Stop condition: [완료, 차단, 시간/반복 예산]
```

검증에는 bounded spawn, 독립 또는 순차 작업, 소유권 선언, parent 통합, parent 검증 trace assertion을 포함합니다.

## 5. 완료 보고

skill-maker 최종 보고는 주장을 근거에 매핑해야 합니다.

```markdown
변경:
- [파일과 의도]

검증:
- [명령/재독/eval 결과]

주의:
- [남은 리스크 또는 미검증 항목]
```

건너뛴 검증을 숨기지 말고, 이유와 사용한 차선 검증을 적습니다.
