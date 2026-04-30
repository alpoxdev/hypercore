# Docs Maker용 하네스 엔지니어링 가이드

**목적**: docs-maker가 프롬프트 자체만이 아니라, 프롬프트를 둘러싼 시스템 전체를 문서화하도록 정의합니다.

## 0. 계층 규칙

하네스 문서는 다음 3개 계층으로 나눕니다.

- 코어 규칙
- 공급자 참조
- 로컬 오버레이

문장이 vendor 동작에 의존한다면 공급자 참조 계층에 두거나 그 자리에서 직접 출처를 붙입니다.

## 1. 프롬프트 자산

- 프롬프트를 목적, 입력, 출력, 검증 기대치가 분명한 자산으로 문서화합니다.
- 고정 지시와 변수 입력, 실행 중 상태를 분리합니다.
- 거의 같은 프롬프트를 복제하기보다 템플릿과 변수를 선호합니다.
- provider 민감한 동작이 있으면 공식 출처와 검증 날짜를 붙입니다.

패턴:

```markdown
## 프롬프트 자산
- 목적:
- 고정 지시:
- 변수 입력:
- 출력 계약:
- 검증 방법:
```

## 2. 도구 계약

- 각 도구를 목적, 입력, 출력, 실패 모드, 승인 경계로 설명합니다.
- 일회성 프롬프트 문장보다 재사용 가능한 도구 계약을 선호합니다.
- 언제 도구를 쓰고, 언제 직접 처리하는 편이 나은지 적습니다.
- 민감한 도구라면 가드레일 또는 승인 단계를 명시합니다.

패턴:

```markdown
## 도구 계약: [도구 이름]
- 사용 시점:
- 사용하지 말아야 할 시점:
- 필요한 입력:
- 기대 출력:
- 승인 또는 가드레일:
- 실패 처리:
```

## 3. 평가 루프

- 프롬프트나 하네스 반복을 권하기 전에 성공 기준을 정의합니다.
- 평가 세트, 평가기, 수용 임계값, 실패 분류 경로를 적습니다.
- 실패 원인이 prompt인지, tool인지, state인지, policy인지 구분합니다.

패턴:

```markdown
## 평가 계획
- 성공 기준:
- 테스트 세트:
- 평가기:
- 수용 임계값:
- 평가가 실패했을 때 무엇을 바꿀지:
```

## 4. 안전과 승인 게이트

- 어떤 입력이 untrusted인지 적습니다.
- 어떤 행동에 승인, 확인, 사람 검토가 필요한지 적습니다.
- prompt injection과 data leakage를 어떻게 줄이는지 적습니다.
- MCP나 외부 도구가 있으면 기대되는 승인 자세를 적습니다.

## 5. 컨텍스트 배치와 캐싱

- 어떤 내용이 정적이고 어떤 내용이 변수인지 문서화합니다.
- 재사용되는 안정적 지시는 provider가 공유 접두부나 상단 컨텍스트에서 이점을 얻는 위치에 둡니다.
- 긴 문서, 예시, 사용자별 입력의 배치 순서를 적습니다.

패턴:

```markdown
## 컨텍스트 배치
1. 고정 지시
2. 재사용 가능한 참고 자료
3. 변수 사용자 입력
4. 현재 작업 또는 질의
```

## 6. 대화 상태와 압축

- turn 사이에 어떤 상태가 유지되는지 적습니다.
- compaction 후에도 남겨야 할 것과 요약 가능한 것을 구분합니다.
- 장기 실행 하네스는 active plan, 현재 제약, 미해결 리스크를 명시적으로 유지합니다.
- task state를 영구 policy처럼 다루지 않습니다.

패턴:

```markdown
## 상태 정책
- 유지할 것:
- 압축 가능한 것:
- 재구성 가능한 것:
- 압축 후에도 반드시 남겨야 할 것:
```

## 7. 모델 및 버전 프로필

- canonical 문서에서는 고정 모델명이 아니라 성능 프로필을 설명합니다.
- 배포에 정확한 모델 문자열이나 snapshot이 필요하면 공급자 참조 또는 배포 예시로 보냅니다.
- 언제 version pinning이 필요한지, 언제 provider-default 최신 모델로 충분한지 적습니다.

## 8. 작성 예시

```markdown
# 리서치 하네스

## 프롬프트 자산
- 목적: vendor SDK 문서 품질 비교
- 고정 지시: 공식 출처를 먼저 수집하고, 차이를 요약하고, 각 핵심 주장에 출처를 붙인다
- 변수 입력: 대상 vendor, 제품 영역, 출력 형식
- 출력 계약: 실행 요약, 발견 사항, 인용, 권고
- 검증 방법: 출처 수 기준 + 리뷰어 재독

## 도구 계약: 웹 검색
- 사용 시점: 최신성이나 출처 명시가 중요한 질문일 때
- 사용하지 말아야 할 시점: 사용자가 브라우징을 금지했고 로컬 정보만으로 해결 가능한 경우
- 필요한 입력: query, domain filter, 필요 시 recency
- 기대 출력: 공식 URL과 뒷받침 구절
- 승인 또는 가드레일: 규범적 vendor guidance는 공식 문서만 인용
- 실패 처리: query를 더 좁히거나 더 직접적인 출처로 전환

## 평가 계획
- 성공 기준: 모든 핵심 주장에 공식 출처가 있고, canonical rule 파일에 오래된 모델명이 없다
- 테스트 세트: 대표 harness-doc 섹션 5개
- 평가기: 출처 근거성, 명확성, 유지보수성, 규칙 경계 위생
- 수용 임계값: 반드시 통과해야 하는 항목 전부 true
- 평가가 실패했을 때 무엇을 바꿀지: 먼저 reference를 업데이트하고, 그 다음 그 규칙을 다시 쓴다

## 컨텍스트 배치
1. 고정 지시
2. 재사용 가능한 공식 참고 자료
3. 변수 작업 입력
4. 활성 질의

## 상태 정책
- 유지할 것: 승인된 규칙, 출처 참조, 활성 제약
- 압축 가능한 것: 완료된 하위 분석
- 재구성 가능한 것: 중간 드래프트 메모
- 압축 후에도 반드시 남겨야 할 것: 현재 계획, 미해결 리스크, 검증 상태
```

## 9. 출처 메타데이터

provider 민감한 가이드는 다음 필드를 가진 참조 항목으로 유지합니다.

- `source_url`
- `last_verified_at`
- `applies_to`
- `summary`
- `implication_for_docs_maker`

## 10. 참조 갱신 워크플로우

- 다음 조건이면 공급자 참조를 갱신합니다.
  - canonical 규칙이 문서화되지 않은 vendor 동작에 기대기 시작함
  - migration guide가 바뀜
  - model, tool, context 기능이 실질적으로 바뀜
  - reviewer가 provider 민감 주장의 공식 근거를 추적하지 못함
- 갱신 순서:
  - 먼저 참조 항목 업데이트
  - 그 다음 의존하는 canonical 또는 adapter 규칙 업데이트
  - 마지막으로 새 출처가 무효화한 stale phrasing을 grep이나 readback으로 정리

## 11. 드리프트 신호

다음은 드리프트 신호입니다.

- canonical 문서가 날짜 없는 vendor 동작을 언급함
- 공급자 참조는 있는데 canonical 규칙에서 아무도 그것을 사용하지 않음
- 예시가 규칙보다 더 구체적임
- 같은 capability에 대해 references끼리 서로 다른 설명을 함

## 12. 검증 체크리스트

- [ ] 프롬프트 자산 계약 문서화
- [ ] tools가 범위에 있으면 도구 계약 문서화
- [ ] optimization이 범위에 있으면 평가 계획 문서화
- [ ] 시스템이나 데이터에 영향을 주는 행동이면 안전과 승인 게이트 명시
- [ ] long 또는 cache-sensitive prompt면 컨텍스트 배치 문서화
- [ ] 장기 실행 워크플로우면 state와 compaction 정책 문서화
- [ ] 공급자 참조에 갱신 준비 메타데이터 포함
- [ ] canonical 문서에 고정 모델명이 없음

## 13. 실패 분류

하네스 문서가 여전히 약하게 느껴지면 다음 순서로 봅니다.

1. 코어와 참조 경계가 없는가
2. 성공 기준이나 평가 계획이 빠졌는가
3. 도구 승인이나 안전 규칙이 빠졌는가
4. state 또는 compaction policy가 빠졌는가
5. 예시가 상위 규칙보다 더 구체적인가
## 14. 최소 Eval Case 형식

Prompt/instruction regression case에는 아래 형태를 사용합니다.

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

## 15. Parallel / Subagent Trace 규칙

문서가 parallel agents를 다루면 final output뿐 아니라 trajectory도 검증합니다.

| Assertion | Pass condition |
|---|---|
| bounded_spawn | objective, scope, output, stop condition이 있음 |
| independent_or_sequenced | 병렬 작업에 숨은 의존성이 없거나 명시적으로 순차화됨 |
| ownership_declared | edit 가능 작업에 write set이 선언됨 |
| least_privilege_tools | read-only 작업에 write/side-effect tool이 필요하지 않음 |
| child_reports_evidence | child output에 files, links, test output, changed paths가 있음 |
| parent_integrates | parent가 충돌, 중복, 누락을 합성함 |
| parent_verifies | parent가 완료 전 최종 tests/evals/source checks를 읽음 |

## 16. Instruction Change Loop

```text
Define success → collect baseline cases → run current doc → diagnose failures → patch smallest surface → re-run → document risk
```
