# Core Principles

## 1. Right Altitude

Instruction은 너무 낮으면 edge-case 덤프가 되고, 너무 높으면 실행 불가능하다.

| Too Low | Right Altitude | Too High |
|---|---|---|
| 모든 조건문 나열 | 원칙 + 대표 예시 + 검증 기준 | “알아서 잘” |
| 도구별 세부 명령 복붙 | capability와 fallback 지정 | 도구 언급 없음 |
| 특정 모델 버전 행동 가정 | 런타임 profile로 분리 | 모델 차이 무시 |

### Pattern

```markdown
## Rule
[원칙 한 문장]

## Apply When
[언제 적용하는지]

## Example
[좋은 예시 1-2개]

## Verify
[통과/실패 기준]
```

## 2. Context Is A Budget

컨텍스트는 무제한 지식창고가 아니다. 읽히는 모든 문장은 다른 근거와 충돌하거나 중요한 정보를 밀어낼 수 있다.

| 전략 | 방법 |
|---|---|
| JIT loading | 루트에는 map만 두고 필요 시 reference 로딩 |
| Deduplication | 같은 규칙은 한 곳에만 둔다 |
| Compression | 표, checklist, examples로 압축 |
| Separation | project rule / runtime quirk / task prompt 분리 |
| Compaction safety | 긴 작업은 결정·검증·남은 일을 별도 파일에 기록 |

## 3. Explicit Contract

좋은 prompt는 요청이 아니라 계약이다.

```xml
<contract>
  <goal>성공 상태</goal>
  <scope>대상/제외 대상</scope>
  <constraints>금지·권한·보안</constraints>
  <evidence>신뢰할 근거</evidence>
  <actions>허용된 도구/작업</actions>
  <verification>완료 증명</verification>
  <output>산출물 형식</output>
</contract>
```

## 4. Evidence Before Confidence

- 최신/변동 정보는 반드시 조회한다.
- 기술/API 동작은 공식 문서나 repo evidence를 우선한다.
- 리서치 결과는 source ledger와 claim-source matrix로 남긴다.
- 불확실성은 제거하지 말고 caveat로 기록한다.

## 5. Eval Before Optimization

Instruction을 “더 좋아 보이게” 바꾸기 전에 현재 실패 사례를 수집한다.

```text
Define → Test → Diagnose → Patch → Re-run → Document
```

## Summary

| 원칙 | 핵심 |
|---|---|
| Right Altitude | 원칙 + 대표 예시 + 검증 |
| Context Budget | 짧은 루트, 깊은 reference |
| Explicit Contract | 목표/범위/권한/검증 명시 |
| Evidence | 주장보다 근거 우선 |
| Eval Loop | 개선은 테스트로 증명 |
