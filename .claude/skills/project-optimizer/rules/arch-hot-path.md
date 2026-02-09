---
title: Identify and Optimize Hot Paths
impact: LOW-MEDIUM
impactDescription: Targeted optimization on code that matters most
tags: arch, hot-path, profiling, optimization, bottleneck
languages: all
related: [concurrency-parallel, io-batch-queries, memory-pool-reuse]
---

## 핫 패스 식별 및 집중 최적화

전체 코드의 80%는 최적화 불필요. 실행 빈도가 높은 20% (핫 패스)를 프로파일링으로 식별하고 집중 최적화합니다.

**프로파일링 도구:**

| 언어 | 도구 | 명령어 |
|------|------|--------|
| **JS/TS** | Node.js `--prof` | `node --prof app.js` + `node --prof-process` |
| **JS/TS** | Chrome DevTools | Performance 탭 |
| **Python** | cProfile / py-spy | `python -m cProfile -s cumtime app.py` |
| **Go** | pprof (내장) | `go tool pprof http://localhost:6060/debug/pprof/profile` |
| **Rust** | flamegraph | `cargo flamegraph` |
| **Java** | async-profiler | `-agentpath:libasyncProfiler.so` |

**최적화 순서:**

```
1. 측정 (프로파일링) → 핫 패스 식별
2. 알고리즘 개선 (O(n²) → O(n log n))
3. I/O 최적화 (이 스킬의 io-* 규칙 적용)
4. 메모리 최적화 (이 스킬의 memory-* 규칙 적용)
5. 마이크로 최적화 (마지막 수단)
```

**원칙:** "추측하지 말고, 측정하라." 프로파일링 없는 최적화는 시간 낭비. 핫 패스가 아닌 코드의 최적화는 ROI가 낮음.
