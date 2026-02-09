---
title: Cargo Release Profile Optimization
impact: HIGH
impactDescription: reduces binary size by 30-50%
tags: bundle, cargo, optimization, release, size
---

# Cargo Release 프로필 최적화

## 왜 중요한가

Tauri 앱의 최종 바이너리 크기는 사용자의 다운로드 시간, 설치 크기, 메모리 사용량에 직접 영향을 미칩니다. Cargo의 기본 release 설정은 빠른 컴파일을 위해 최적화되지만, 더 공격적인 최적화 옵션을 적용하면 바이너리 크기를 **30-50%까지 줄일 수 있습니다**.

## ❌ 잘못된 패턴

**기본 release 프로필 사용 (Cargo.toml):**

```toml
# 기본 설정 (최적화 안함)
[package]
name = "app"
version = "0.1.0"

# release 프로필 설정 없음
```

**결과:**
- 바이너리 크기: ~15MB (최적화 전)
- 컴파일 시간: 빠름
- 디버그 심볼 포함

## ✅ 올바른 패턴

**최적화된 release 프로필 (Cargo.toml):**

```toml
[package]
name = "app"
version = "0.1.0"

[profile.release]
# 코드 생성 유닛을 1개로 통합 (LLVM 최적화 극대화)
codegen-units = 1

# Link-Time Optimization 활성화 (전체 프로그램 최적화)
lto = true

# 크기 최적화 모드 ("s" = size, "z" = aggressive size)
opt-level = "s"

# panic을 abort로 변경 (unwinding 코드 제거)
panic = "abort"

# 디버그 심볼 제거
strip = true
```

**각 옵션 설명:**

| 옵션 | 설명 | 크기 영향 |
|------|------|-----------|
| `codegen-units = 1` | 병렬 컴파일 비활성화, LLVM 최적화 극대화 | ~10-15% 감소 |
| `lto = true` | 전체 프로그램 최적화 (Link-Time Optimization) | ~15-20% 감소 |
| `opt-level = "s"` | 속도 대신 크기 최적화 | ~10-15% 감소 |
| `panic = "abort"` | panic unwinding 코드 제거 | ~5-10% 감소 |
| `strip = true` | 디버그 심볼 제거 | ~10-20% 감소 |

**예상 결과:**
- 바이너리 크기: ~7-10MB (최적화 후)
- 컴파일 시간: 느림 (2-3배)
- 프로덕션 배포용

## 추가 컨텍스트

**컴파일 시간 vs 크기:**
- 개발 중에는 기본 설정 사용 (빠른 반복)
- CI/CD 프로덕션 빌드에서만 최적화 프로필 사용

**opt-level 옵션:**
- `"s"` (size): 크기 최적화, 합리적인 성능 유지
- `"z"` (aggressive size): 극단적 크기 최적화, 일부 성능 희생
- 대부분의 앱에서는 `"s"` 권장

**LTO 옵션:**
- `lto = true`: 전체 최적화 (가장 느림, 가장 작음)
- `lto = "thin"`: 부분 최적화 (빠름, 적당한 크기)
- 프로덕션에서는 `lto = true` 권장

**참고:**
- Tauri 공식 가이드: [App Size Optimization](https://tauri.app/v2/guides/building/app-size/)
- Rust Cargo Book: [Profiles](https://doc.rust-lang.org/cargo/reference/profiles.html)

**영향도:**
- 크기: HIGH (30-50% 감소)
- 컴파일 시간: HIGH (2-3배 증가)
- 런타임 성능: NEUTRAL (opt-level="s"일 때)
