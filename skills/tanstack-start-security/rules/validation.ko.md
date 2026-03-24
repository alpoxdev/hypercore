# 검증

> TanStack Start 보안 작업용 리뷰/검증 게이트

## 보안 리뷰 순서

1. 프로젝트가 실제로 TanStack Start인지 확인
2. auth / session 표면 점검
3. secret / env / runtime boundary 표면 점검
4. server route / header / webhook 표면 점검
5. 앱 검증 명령 실행

## 반드시 통과해야 할 질문

- secret 또는 privileged helper가 client-reachable code에서 import 가능한가?
- 보호된 mutation을 위조된 client identity로 실행할 수 있는가?
- 브라우저 요청이 auth/origin/CSRF 보호 없이 state를 바꿀 수 있는가?
- webhook 또는 external callback이 signature 검증 전에 악용될 수 있는가?
- 하드닝 변경이 정상 앱 동작을 깨뜨리지는 않았는가?

하나라도 불확실하면 계속 검증합니다.

## 추천 명령

가장 작은 명령 집합으로 주장에 필요한 증거를 확보합니다.

```bash
rg -n "process\\.env|import\\.meta\\.env|createServerFn|createServerOnlyFn|createClientOnlyFn" src app
rg -n "beforeLoad|validateSearch|params\\.parse|getSession|ensureSession|trustedOrigins|tanstackStartCookies|disableCSRFCheck|Set-Cookie" src app
rg -n "createServerRoute|webhook|signature|Cache-Control|Content-Security-Policy|Access-Control-Allow|rateLimit|rate-limit" src app
test -f src/start.ts && sed -n '1,220p' src/start.ts
```

그 다음 저장소에 존재하는 검증 명령을 실행합니다.

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

저장소에 실제로 있는 명령만 실행하되, 가능한 검증을 작은 변경이라는 이유로 건너뛰지 않습니다.

## Readback 체크

- core `SKILL.md`만 읽어도 스킬의 역할이 이해됨
- 규칙 파일이 core에서 바로 발견 가능함
- 규칙과 참조 파일이 서로를 그대로 복제하지 않음
- 트리거 예시가 generic security review와 겹치지 않을 정도로 구체적임
- 전역 request middleware 또는 header가 관련되면 `src/start.ts`가 검토됨

## 종료 기준

- 최소 1개 이상의 명시적 보안 표면이 식별되고 강화됨
- 바뀐 동작이 저장소 검증 증거로 뒷받침됨
- 남은 리스크가 generic한 공포 표현이 아니라 stack-specific하게 정리됨
- SSR이 있다면 민감한 loader/context 데이터가 hydration 출력으로 직렬화되지 않음
