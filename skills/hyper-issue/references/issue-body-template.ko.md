# Issue Body Template

본문을 쓸 때 이 참고 파일을 사용한다. 골격을 복사해 모든 자리표시자를 바꾼다. `##` 이름과 `hyper:` 키는 적힌 그대로 유지한다.

## Contents

- 골격
- 작성 예
- 규칙

## 골격

```markdown
## What

<한 단락. 무엇이 잘못됐는지 또는 무엇을 원하는지. 누가 영향을 받고 무엇이 달라지는지.>

## Evidence

- `<path>:<line>` - 이것이 보여 주는 것
- `<command>` -> 관측한 출력 중 중요한 줄만

<위 내용 중 추론한 것이 있으면 가정 줄:>
- 가정: <추론한 진술> - 확인 방법: <무엇이 확인해 주는지>

## Cause

<bug: 위 경로에 연결한 확인된 원인. 증상, 유발 조건, 원인을 구분해 적는다.>

## Intended behavior

<feature 또는 task: 결정된 동작. 오류 경로와 바뀌지 않는 동작 포함.>

## Scope

<변경 경계를 한두 문장으로. 무엇을 고치고, 더하고, 지우는지.>

```yaml
hyper:
  touches:
    - <경로 또는 글롭>
  depends_on: []
  conflicts_with: []
  lane_hint: <kebab-case>
  verify: "<그대로의 명령>"
  size: <s | m | l>
```

## Out of scope

- <독자가 포함됐다고 오해할 만한 것>

## Acceptance

- [ ] <명령과 기대 결과가 붙은 이분법 검사>
- [ ] <오류 경로 검사>

## Verify

```sh
<hyper.verify의 그대로의 명령>
```

Pass: <작업이 끝났을 때 출력이 어떤 모습인지>.
```

## 작성 예

```markdown
## What

`POST /api/orders`가 재시도 창 안에서 같은 멱등성 키를 다시 받으면 409 대신 500을 반환한다. 타임아웃 뒤 재시도하는 호출자가 중복 주문을 만든다.

## Evidence

- `src/api/orders.ts:88` - 멱등성 키를 인서트 시도 뒤에 읽는다
- `bun test src/api/orders.test.ts` -> `1 fail: replays a duplicate key`, `duplicate key value violates unique constraint`
- `docs/contracts/orders.md:14` - 재입력 시 409를 요구한다

## Cause

`src/api/orders.ts:88`에서 인서트가 키 조회보다 먼저 실행되어, 재입력이 데이터베이스 유니크 제약에 닿고 처리되지 않은 오류가 500이 된다. 계약 조회는 나중에 `:95`에 추가되었고 인서트 앞으로 옮겨지지 않았다.

## Scope

키 조회를 인서트 앞으로 옮기고, 재입력이면 저장된 주문 id와 함께 409를 반환한다. 새 주문의 인서트 경로와 응답 형태는 그대로 둔다.

```yaml
hyper:
  touches:
    - src/api/orders.ts
    - src/api/orders.test.ts
  depends_on: []
  conflicts_with: []
  lane_hint: orders-idempotency
  verify: "bun test src/api/orders.test.ts"
  size: s
```

## Out of scope

- 재시도 창 길이 변경
- 이미 만들어진 중복 주문 백필

## Acceptance

- [ ] `bun test src/api/orders.test.ts` 통과. 409와 원래 주문 id를 확인하는 재입력 케이스 포함
- [ ] 첫 요청은 새 주문 id와 함께 여전히 201을 반환

## Verify

```sh
bun test src/api/orders.test.ts
```

Pass: 모든 케이스 통과, 재입력 케이스가 500이 아니라 409를 기록.
```

## 규칙

- 본문은 홀로 선다. "앞서 논의한 대로"도, 이해에 필요한 링크도 없다.
- 인용은 짧게, 출처를 붙이고, 비밀은 가린다.
- 본문 하나에 `hyper:` 블록 하나이며 `## Scope`의 유일한 펜스 `yaml` 블록이다.
- `verify`는 이슈가 다르게 말하지 않는 한 브라우저, 자격증명, 네트워크 호출 없이 실행 가능해야 한다.

## Sources

> 확인 2026-11-07.

| Claim | Source |
|---|---|
| 본문 절, `hyper:` 키, 작성 예의 형태 | 이 패키지가 이슈 작성 선행 사례 위에 세운 설계, 2026-11-07 |
| 로그와 세션이 사라진 뒤에도 쓸 수 있는 본문 | [kdy1-scripts add-issue](https://github.com/kdy1/kdy1-scripts) |

### 근거 등급

`LOCAL` - 템플릿과 예시는 이 저장소의 이슈 흐름을 위해 이 패키지가 직접 작성한 것이다.
