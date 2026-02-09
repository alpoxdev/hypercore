---
title: Enforce Clear Module Boundaries
impact: LOW-MEDIUM
impactDescription: Prevents spaghetti dependencies, enables parallel work
tags: arch, module, boundary, circular, dependency
languages: all
related: [arch-interface-segregation, code-complexity]
---

## 모듈 경계 명확화

모듈 간 순환 의존을 제거하고 명확한 의존 방향을 유지합니다.

**순환 의존 감지:**

| 언어 | 도구 |
|------|------|
| **JS/TS** | `madge --circular src/` |
| **Python** | `pydeps --no-show` |
| **Go** | 컴파일러 (순환 import = 컴파일 에러) |
| **Rust** | 컴파일러 (순환 crate = 컴파일 에러) |
| **Java** | ArchUnit, JDepend |

**해결 패턴:**

```
❌ 순환: A → B → C → A

✅ 의존성 역전:
A → Interface ← B → C
(A는 인터페이스에 의존, B가 구현)

✅ 이벤트/메시지:
A → EventBus ← B
(A가 이벤트 발행, B가 구독)

✅ 추출:
A → D ← B → C
(공통 부분을 D로 추출)
```

**원칙:** 의존 방향은 상위(추상) → 하위(구체). 도메인 모듈이 인프라에 의존하지 않음.
