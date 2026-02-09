---
title: Maximize Type System Usage
impact: MEDIUM
impactDescription: Catches bugs at compile time, better IDE support
tags: dx, type, safety, strict, generics
languages: [ts, go, rust, java, csharp]
related: [code-error-handling, code-naming]
---

## 타입 시스템 최대 활용

언어의 타입 시스템을 최대한 활용하여 런타임 에러를 컴파일 타임에 잡습니다.

**언어별 strict 설정:**

```json
// TypeScript - tsconfig.json
{ "compilerOptions": { "strict": true, "noUncheckedIndexedAccess": true } }
```

```toml
# Rust - Clippy strict
[lints.clippy]
pedantic = "warn"
```

```python
# Python - mypy strict
[tool.mypy]
strict = true
disallow_any_generics = true
```

```go
// Go - go vet + staticcheck
// go vet ./...
// staticcheck ./...
```

**패턴:**

| 패턴 | 효과 | 언어 |
|------|------|------|
| **Discriminated union** | 상태별 안전한 분기 | TS, Rust (enum), Python (Literal) |
| **Branded type** | 같은 원시형 혼동 방지 | TS (`type UserId = string & { __brand: 'UserId' }`) |
| **Exhaustive check** | switch에서 누락 분기 감지 | TS (`never`), Rust (match), Go (exhaustive) |
| **Generic constraint** | 타입 파라미터 제한 | 모든 정적 타입 언어 |

**원칙:** `any`/`object`/`interface{}` 사용 최소화. 가능한 가장 구체적인 타입 사용.
