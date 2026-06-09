# Import Protection

> Start의 기본 client/server import boundary를 인정하면서 hypercore safety deny rules를 적용합니다.

## Rule Classifications

| Rule | Classification | Enforcement |
|---|---|---|
| Start import protection은 기본 enabled | Official | custom config 전 behavior 확인 |
| `.server.*`는 client에서, `.client.*`는 server에서 deny | Official | leak 차단 |
| marker import는 module을 한 environment로 제한 | Official | suffix가 부족할 때 사용 |
| `database/`, `server/`, ORM package custom deny rules | Safety policy | 프로젝트에 필요하면 추가/확장 |
| import protection 비활성화 금지 | Safety policy | 명시 요청 없으면 차단 |

## Official Defaults

TanStack Start import protection은 기본 enabled입니다. explicit `importProtection` object가 항상 필요하다고 말하지 않습니다.

기본 deny pattern:

- Client environment: `**/*.server.*`, Start server specifiers.
- Server environment: `**/*.client.*`.

Type-only imports and re-exports are ignored because runtime bundle에서 제거됩니다. Runtime value를 포함하는 mixed imports는 여전히 검사 대상입니다.

## Marker Imports

```typescript
import '@tanstack/react-start/server-only'
import '@tanstack/react-start/client-only'
```

- 한 파일에는 marker 하나만 사용합니다.
- 파일명만으로 boundary가 명확하지 않을 때 사용합니다.

## Custom Deny Rules

프로젝트가 directory/package 추가 차단을 필요로 할 때 explicit `tanstackStart({ importProtection })` config를 추가합니다:

```typescript
import { tanstackStart } from '@tanstack/react-start/plugin/vite'

tanstackStart({
  importProtection: {
    behavior: { dev: 'mock', build: 'error' },
    client: {
      files: ['**/*.server.*', '**/server/**', '**/database/**', '**/db/**'],
      specifiers: ['@prisma/client', 'bcrypt'],
    },
    server: {
      files: ['**/*.client.*', '**/client/**'],
      specifiers: ['localforage'],
    },
  },
})
```

기존 `tanstackStart()`가 있으면 관련 nested option만 확장합니다. plugin을 중복 추가하거나 unrelated option을 덮어쓰지 않습니다.

Project가 development에서도 violation을 실패시키길 원하면 `behavior: 'error'`를 사용합니다. Current options에는 scoped enforcement와 diagnostics를 위한 `log`, `include`, `exclude`, `ignoreImporters`, `maxTraceDepth`, `onViolation`도 포함됩니다.

`client`와 `server` rules는 `files`, `specifiers`, `excludeFiles`를 지원합니다. Default는 `node_modules` 아래 resolved files를 제외합니다. `excludeFiles: []`는 선택한 environment에서 이 검사를 다시 켜므로, third-party package false positive 가능성을 고려해 의도적으로만 사용합니다.

## Compiler Boundary Leak Rule

`createServerFn` handler 내부 server-only import는 client build에서 제거될 수 있습니다. 같은 import가 client compilation 후 살아남는 코드에서 참조되면 import protection violation입니다.

수정 방법:

- surviving helper를 `*.server.*`로 분리.
- helper를 `createServerOnlyFn`으로 감싸기.
- browser-only code는 `*.client.*` 또는 `createClientOnlyFn` 뒤로 이동.

## Validation Checklist

- [ ] import protection이 disabled가 아님.
- [ ] project directory/package에 필요하면 custom deny rules가 있음.
- [ ] Type-only imports를 runtime boundary leak로 잘못 보고하지 않음.
- [ ] 기존 `tanstackStart()` option을 덮어쓰지 않고 확장함.
- [ ] `behavior: 'error'`와 `{ dev, build }` behavior를 의도적으로 선택함.
- [ ] Third-party resolved-file checks가 의도적으로 필요할 때만 `excludeFiles: []`를 사용함.
- [ ] `.server.*`, `.client.*`, marker import가 일관됨.
- [ ] server-only import가 recognized boundary 밖에 살아남지 않음.
- [ ] tree-shaking false positive 가능성이 있으면 production build로 확인함.
