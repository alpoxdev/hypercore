---
title: Resolve Peer Dependency Conflicts
impact: LOW-MEDIUM
impactDescription: Eliminates runtime version conflicts
tags: deps, peer, conflict, resolution
languages: all
related: [deps-version-pin, deps-security-audit]
---

## Peer Dependency 버전 충돌 해결

peer dependency 경고/에러를 해결하여 런타임 버전 충돌을 방지합니다.

**감지:**

```bash
# npm
npm ls --all 2>&1 | grep "peer dep"
npm install  # 경고 메시지 확인

# yarn
yarn install  # 경고 확인

# pnpm
pnpm install  # strict peer deps 기본
```

**해결 전략:**

| 상황 | 해결 |
|------|------|
| 라이브러리 A가 react@18 요구, B가 react@19 요구 | A 업데이트 또는 overrides 사용 |
| 여러 버전의 같은 라이브러리 설치됨 | `npm ls [pkg]`로 확인, 상위 버전으로 통일 |
| 호환 불가 | `overrides` (npm) / `resolutions` (yarn) / `overrides` (pnpm) |

```json
// package.json - 강제 버전 통일
{
  "overrides": { "react": "^19.0.0" },
  "resolutions": { "react": "^19.0.0" }
}
```

**원칙:** overrides는 최후 수단. 먼저 라이브러리 업데이트 시도.
