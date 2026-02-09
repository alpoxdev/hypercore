# 비싼 초기값은 함수로 전달

## 왜 중요한가

`useState`에 비용이 큰 초기 값을 직접 전달하면 매 렌더링마다 실행됩니다. 초기화 후에는 사용되지 않지만 계산 비용이 낭비됩니다. Tauri 앱에서는 IPC 호출, 파일 읽기, 데이터 구조 변환 등이 이에 해당합니다.

## ❌ 잘못된 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { readTextFile } from '@tauri-apps/plugin-fs'
import { useState, useEffect } from 'react'

function ConfigEditor() {
  // ❌ JSON.parse가 매 렌더링마다 실행됨
  const [config, setConfig] = useState(
    JSON.parse(localStorage.getItem('config') || '{}')
  )

  return <div>{JSON.stringify(config)}</div>
}

function FileSearch({ files }: { files: string[] }) {
  // ❌ buildSearchIndex()가 매 렌더링마다 실행됨
  const [searchIndex, setSearchIndex] = useState(
    buildSearchIndex(files)
  )

  return <SearchBar index={searchIndex} />
}

function buildSearchIndex(files: string[]) {
  console.log('Building index...')  // 매 렌더링마다 출력
  return files.reduce((acc, file) => {
    acc[file.toLowerCase()] = file
    return acc
  }, {} as Record<string, string>)
}
```

**문제점:**
- 초기화 후에도 매 렌더링마다 불필요한 계산 실행
- 성능 낭비 (특히 대규모 데이터 처리 시)
- 콘솔 로그가 반복 출력

## ✅ 올바른 패턴

```tsx
import { invoke } from '@tauri-apps/api/core'
import { readTextFile } from '@tauri-apps/plugin-fs'
import { useState, useEffect } from 'react'

function ConfigEditor() {
  // ✅ JSON.parse가 초기 렌더링 시에만 실행됨
  const [config, setConfig] = useState(() => {
    const stored = localStorage.getItem('config')
    return stored ? JSON.parse(stored) : {}
  })

  return <div>{JSON.stringify(config)}</div>
}

function FileSearch({ files }: { files: string[] }) {
  // ✅ buildSearchIndex()가 초기 렌더링 시에만 실행됨
  const [searchIndex, setSearchIndex] = useState(() =>
    buildSearchIndex(files)
  )

  return <SearchBar index={searchIndex} />
}

function buildSearchIndex(files: string[]) {
  console.log('Building index...')  // 초기 렌더링 시에만 출력
  return files.reduce((acc, file) => {
    acc[file.toLowerCase()] = file
    return acc
  }, {} as Record<string, string>)
}
```

**Tauri 파일 시스템 읽기:**

```tsx
import { readTextFile } from '@tauri-apps/plugin-fs'
import { appDataDir, join } from '@tauri-apps/api/path'
import { useState, useEffect } from 'react'

function UserSettings() {
  const [settings, setSettings] = useState<Settings | null>(null)

  useEffect(() => {
    // ✅ 비동기 초기화는 useEffect에서
    (async () => {
      const dataDir = await appDataDir()
      const configPath = await join(dataDir, 'settings.json')
      const content = await readTextFile(configPath)
      setSettings(JSON.parse(content))
    })()
  }, [])

  if (!settings) return <div>Loading...</div>
  return <div>{JSON.stringify(settings)}</div>
}
```

**Tauri invoke 결과 캐싱:**

```tsx
import { invoke } from '@tauri-apps/api/core'
import { useState, useEffect } from 'react'

function FileTree() {
  // ✅ 비동기 데이터는 null로 초기화 후 useEffect에서 로드
  const [tree, setTree] = useState<FileNode | null>(null)

  useEffect(() => {
    invoke<FileNode>('get_file_tree').then(setTree)
  }, [])

  if (!tree) return <div>Loading...</div>

  // ✅ 계산 비용이 큰 변환은 지연 초기화
  const [flatList, setFlatList] = useState(() =>
    flattenTree(tree)  // 초기 렌더링 시에만 실행
  )

  return <TreeView tree={tree} />
}

function flattenTree(node: FileNode): string[] {
  console.log('Flattening tree...')
  const result: string[] = []
  const stack = [node]
  while (stack.length > 0) {
    const current = stack.pop()!
    result.push(current.path)
    if (current.children) stack.push(...current.children)
  }
  return result
}
```

**Map/Set 초기화:**

```tsx
import { useState } from 'react'

type Item = { id: string; name: string }

function ItemList({ items }: { items: Item[] }) {
  // ✅ Map 생성이 초기 렌더링 시에만 실행됨
  const [itemMap, setItemMap] = useState(() =>
    new Map(items.map(item => [item.id, item]))
  )

  // ✅ Set 생성이 초기 렌더링 시에만 실행됨
  const [selectedIds, setSelectedIds] = useState(() =>
    new Set<string>()
  )

  return <div>{items.length} items</div>
}
```

## 추가 컨텍스트

**지연 초기화를 사용해야 하는 경우:**
- localStorage/sessionStorage에서 데이터 읽기 + JSON 파싱
- 데이터 구조 구축 (Map, Set, 인덱스)
- DOM에서 값 읽기
- 무거운 계산/변환 (정렬, 필터, reduce)
- 정규식 생성

**지연 초기화가 불필요한 경우:**
- 원시 값: `useState(0)`, `useState('')`
- 직접 참조: `useState(props.value)`
- 저렴한 리터럴: `useState({})`, `useState([])`

**비동기 초기화:**
- `useState`는 비동기 함수를 지원하지 않음
- 비동기 데이터는 null로 초기화 후 useEffect에서 로드
- 또는 TanStack Query의 `useQuery` 사용

**성능 측정:**
```tsx
const [data, setData] = useState(() => {
  const start = performance.now()
  const result = expensiveComputation()
  console.log(`Init took ${performance.now() - start}ms`)
  return result
})
```

**참고:** [React useState Lazy Initialization](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)

영향도: MEDIUM - 초기화 성능, 렌더링 성능
