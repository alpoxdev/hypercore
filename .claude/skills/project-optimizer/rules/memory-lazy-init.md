---
title: Lazy Initialize Expensive Resources
impact: MEDIUM
impactDescription: Faster startup, lower baseline memory
tags: memory, lazy, initialization, startup
languages: all
related: [concurrency-defer-await, build-code-split]
---

## 비싼 초기화 지연 실행

애플리케이션 시작 시 모든 리소스를 초기화하지 않고, 실제 사용 시점에 지연 초기화합니다.

**❌ 잘못된 예시 (즉시 초기화):**

```python
# 모듈 import 시 즉시 무거운 ML 모델 로드
import tensorflow as tf
model = tf.keras.models.load_model("huge_model.h5")  # 5초, 2GB RAM
```

```typescript
// 모듈 로드 시 즉시 초기화
const heavyConfig = JSON.parse(fs.readFileSync('config.json', 'utf8'))
const searchIndex = buildSearchIndex(allDocuments)  // 3초
```

**✅ 올바른 예시 (지연 초기화):**

```python
# Python - 필요 시점에 로드
_model = None
def get_model():
    global _model
    if _model is None:
        import tensorflow as tf
        _model = tf.keras.models.load_model("huge_model.h5")
    return _model

# Python 3.8+ functools.cached_property
class Service:
    @cached_property
    def model(self):
        return load_heavy_model()
```

```typescript
// JS/TS - getter 또는 lazy 패턴
let _searchIndex: SearchIndex | null = null
function getSearchIndex(): SearchIndex {
  if (!_searchIndex) {
    _searchIndex = buildSearchIndex(allDocuments)
  }
  return _searchIndex
}
```

```rust
// Rust - LazyLock (std) 또는 once_cell
use std::sync::LazyLock;
static CONFIG: LazyLock<Config> = LazyLock::new(|| {
    load_config().expect("config load failed")
});
```

```go
// Go - sync.Once
var (
    instance *Service
    once     sync.Once
)
func GetService() *Service {
    once.Do(func() { instance = newService() })
    return instance
}
```

**적용 대상:** ML 모델, 검색 인덱스, 대용량 설정, 외부 서비스 커넥션.
