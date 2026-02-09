# 반복 조회용 Map 빌드

## 왜 중요한가

동일한 키로 배열을 여러 번 `.find()` 조회하면 O(n) 복잡도가 반복됩니다. Map을 사용하면 O(1) 조회로 성능을 크게 개선할 수 있습니다. Tauri 앱에서는 파일 목록, 사용자 목록, 설정 데이터 등을 처리할 때 특히 유용합니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState } from 'react'

type Order = { id: string; userId: string; total: number }
type User = { id: string; name: string; email: string }

function OrderList() {
  const [orders, setOrders] = useState<Order[]>([])
  const [users, setUsers] = useState<User[]>([])

  useEffect(() => {
    Promise.all([
      invoke<Order[]>('get_orders'),
      invoke<User[]>('get_users')
    ]).then(([ordersData, usersData]) => {
      setOrders(ordersData)
      setUsers(usersData)
    })
  }, [])

  return (
    <div>
      {orders.map(order => {
        // ❌ 매 order마다 O(n) 조회
        const user = users.find(u => u.id === order.userId)
        return (
          <div key={order.id}>
            Order #{order.id} - {user?.name} - ${order.total}
          </div>
        )
      })}
    </div>
  )
}

// 1000개 주문 × 1000명 사용자 = 1,000,000 연산
```

**문제점:**
- 매 렌더링마다 O(n) 조회 반복
- 큰 데이터셋에서 성능 저하
- 1000 orders × 1000 users = 1M 연산

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState, useMemo } from 'react'

type Order = { id: string; userId: string; total: number }
type User = { id: string; name: string; email: string }

function OrderList() {
  const [orders, setOrders] = useState<Order[]>([])
  const [users, setUsers] = useState<User[]>([])

  useEffect(() => {
    Promise.all([
      invoke<Order[]>('get_orders'),
      invoke<User[]>('get_users')
    ]).then(([ordersData, usersData]) => {
      setOrders(ordersData)
      setUsers(usersData)
    })
  }, [])

  // ✅ Map을 한 번만 생성 (O(n))
  const userById = useMemo(
    () => new Map(users.map(u => [u.id, u])),
    [users]
  )

  return (
    <div>
      {orders.map(order => {
        // ✅ O(1) 조회
        const user = userById.get(order.userId)
        return (
          <div key={order.id}>
            Order #{order.id} - {user?.name} - ${order.total}
          </div>
        )
      })}
    </div>
  )
}

// 1000개 주문 + 1000명 사용자 = 2,000 연산
```

**파일 경로 인덱싱:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState, useMemo } from 'react'

type FileMetadata = {
  path: string
  size: number
  modified: string
}

function FileExplorer() {
  const [files, setFiles] = useState<FileMetadata[]>([])
  const [selectedPaths, setSelectedPaths] = useState<string[]>([])

  useEffect(() => {
    invoke<FileMetadata[]>('list_files').then(setFiles)
  }, [])

  // ✅ 파일 경로로 Map 생성
  const fileByPath = useMemo(
    () => new Map(files.map(f => [f.path, f])),
    [files]
  )

  return (
    <div>
      <h2>Selected Files</h2>
      {selectedPaths.map(path => {
        // ✅ O(1) 조회
        const file = fileByPath.get(path)
        return file ? (
          <div key={path}>
            {path} - {file.size} bytes
          </div>
        ) : null
      })}
    </div>
  )
}
```

**다중 키 인덱싱:**

```tsx
import { useMemo } from 'react'

type Product = {
  id: string
  sku: string
  name: string
  price: number
}

function ProductCatalog({ products }: { products: Product[] }) {
  // ✅ ID로 인덱싱
  const productById = useMemo(
    () => new Map(products.map(p => [p.id, p])),
    [products]
  )

  // ✅ SKU로 인덱싱
  const productBySku = useMemo(
    () => new Map(products.map(p => [p.sku, p])),
    [products]
  )

  const getProductById = (id: string) => productById.get(id)
  const getProductBySku = (sku: string) => productBySku.get(sku)

  return <div>...</div>
}
```

**그룹화 Map:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useEffect, useState, useMemo } from 'react'

type File = {
  path: string
  extension: string
  size: number
}

function FilesByExtension() {
  const [files, setFiles] = useState<File[]>([])

  useEffect(() => {
    invoke<File[]>('list_files').then(setFiles)
  }, [])

  // ✅ 확장자별로 그룹화
  const filesByExt = useMemo(() => {
    const map = new Map<string, File[]>()
    files.forEach(file => {
      const existing = map.get(file.extension) || []
      map.set(file.extension, [...existing, file])
    })
    return map
  }, [files])

  return (
    <div>
      {Array.from(filesByExt.entries()).map(([ext, files]) => (
        <div key={ext}>
          <h3>{ext} ({files.length} files)</h3>
          {files.map(file => (
            <div key={file.path}>{file.path}</div>
          ))}
        </div>
      ))}
    </div>
  )
}
```

**Set으로 존재 여부 체크:**

```tsx
import { useMemo } from 'react'

type FileItem = { path: string; selected: boolean }

function FileList({ files }: { files: FileItem[] }) {
  // ✅ Set으로 O(1) 체크
  const selectedPaths = useMemo(
    () => new Set(files.filter(f => f.selected).map(f => f.path)),
    [files]
  )

  const isSelected = (path: string) => selectedPaths.has(path)  // O(1)

  return (
    <div>
      {files.map(file => (
        <div key={file.path} className={isSelected(file.path) ? 'selected' : ''}>
          {file.path}
        </div>
      ))}
    </div>
  )
}
```

## 추가 컨텍스트

**성능 비교:**

| 데이터 크기 | Array.find() | Map.get() | 개선율 |
|-------------|--------------|-----------|--------|
| 100 items | 5,000 ops | 100 ops | 50x |
| 1,000 items | 500,000 ops | 1,000 ops | 500x |
| 10,000 items | 50,000,000 ops | 10,000 ops | 5000x |

**Map vs Object:**
- Map은 키로 객체 사용 가능
- Map은 순서 보장 (insertion order)
- Map은 size 프로퍼티 제공
- Map은 iterate 최적화

**언제 사용:**
- 반복 조회가 필요한 경우
- 배열 크기가 큰 경우 (100개 이상)
- 조회 빈도가 높은 경우
- 성능이 중요한 렌더링 로직

**언제 불필요:**
- 1회성 조회
- 작은 배열 (10개 이하)
- Map 생성 비용이 조회 비용보다 큰 경우

**참고:** [MDN Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)

영향도: LOW-MEDIUM - 대규모 데이터 처리 성능 개선
