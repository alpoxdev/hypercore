# Core Principles

> 영어판: [`core-principles.md`](core-principles.md)

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

Anthropic도 같은 지점을 “골디락스 구간”이라고 부른다. 한쪽 끝은 프롬프트에 복잡하고 잘 부서지는 로직을 박아 넣는 방식이고, 다른 쪽 끝은 공유된 맥락이 있다고 잘못 가정하는 모호한 지침이다. 함께 제시하는 분량 기준은 “기대하는 동작을 온전히 규정하는 최소한의 정보”이며, 여기에 “최소가 반드시 짧다는 뜻은 아니다”라는 단서를 붙인다(확인 2026-11-03). 최소란 모든 문장이 신호를 담는다는 뜻이고, 문서가 짧다는 뜻이 아니다.

## 2. Context Is A Budget

컨텍스트는 무제한 지식창고가 아니다. 읽히는 모든 문장은 다른 근거와 충돌하거나 중요한 정보를 밀어낼 수 있다.

| 전략 | 방법 |
|---|---|
| JIT loading | 루트에는 map만 두고 필요 시 reference 로딩 |
| Deduplication | 같은 규칙은 한 곳에만 둔다 |
| Compression | 표, checklist, examples로 압축 |
| Separation | project rule / runtime quirk / task prompt 분리 |
| Compaction safety | 긴 작업은 결정·검증·남은 일을 별도 파일에 기록 |

이것은 가정이 아니라 측정 결과다. Chroma는 네 계열 모델 18종을 시험해, 작업 난이도를 고정한 상태에서도 입력 길이가 늘면 성능이 떨어진다는 사실을 확인했다. 주제가 인접한 방해 문서가 하나만 붙어도 정확도가 떨어졌고 네 개를 붙이면 하락이 더 커졌다. 또 문장 순서를 섞은 문서에서 정연하게 구성된 문서보다 성능이 좋았다. 관련성과 배치만으로는 긴 프롬프트를 구제하지 못한다는 뜻이다(2025-07-14). 실무적으로 읽으면 이렇다. 창을 키우면 자리가 늘 뿐 정확도가 늘지 않고, 신호가 약한 토큰 하나하나가 핵심 규칙에 쓸 주의를 잡아먹는다.

이 예산을 실제로 쓰고 되찾는 수단은 write, select, compress, isolate 넷이며 [`context-management.ko.md`](context-management.ko.md)에 정리했다.

## 3. Explicit Contract

좋은 prompt는 요청이 아니라 계약이다. 역할 프롬프트도 ‘전문가처럼 행동하라’가 아니라 목표, 범위, 권한, 근거, 출력, 검증을 가진 작업 계약이어야 한다.

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

Instruction을 “더 좋아 보이게” 바꾸기 전에 현재 실패 사례를 수집한다. 공식 문서 기반 prompt optimizer나 meta-prompt를 쓰더라도 production 반영 전에는 같은 eval set으로 회귀를 확인한다.

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

## Sources

> 출처 확인 2026-11-03.

| 주장 | 출처 | 발행·갱신 |
|---|---|---|
| Right Altitude 정의, “최소가 반드시 짧다는 뜻은 아니다”, 압축과 노트 필기의 근거 | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2025-09-29 발행, 2026-10-18 갱신 |
| 난이도를 고정해도 입력 길이가 늘면 모델 18종의 성능이 떨어진다. 방해 문서는 하락을 키우고, 정연한 문서가 섞은 문서보다 나쁘다 | <https://www.trychroma.com/research/context-rot> | 2025-07-14 |
| 압축·비우기·격리 수단과 벤더별 파라미터 | [`context-management.ko.md`](context-management.ko.md) | 2026-11-03 확인 |

## Related

- [`prompt-authoring.ko.md`](prompt-authoring.ko.md): 역할 수행 프롬프트 작성 템플릿
- [`context-management.ko.md`](context-management.ko.md): 예산을 쓰고 되찾는 기제
- 공식 출처는 [`../CONTEXT_ENGINEERING.ko.md`](../CONTEXT_ENGINEERING.ko.md)의 Sources 표를 따른다(지시 표면은 2026-07-29 확인, 링크 사용 가능 여부는 2026-11-03 재확인).
