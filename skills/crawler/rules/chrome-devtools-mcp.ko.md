# chrome-devtools-mcp

> Playwriter 다음 단계로, Chrome DevTools 수준의 네트워크/콘솔/퍼포먼스/접근성/메모리 근거가 필요할 때 사용합니다.

---

<routing>

## Playwriter vs chrome-devtools-mcp

| 도구 | 강점 | 사용 시점 |
|------|------|------|
| `playwriter` (Playwright MCP) | 페이지 **조작(driving)** | 로그인, 클릭, 입력, 스크롤, lazy-load 트리거, selector 검증 |
| `chrome-devtools-mcp` | 페이지 **분석(debugging)** | 라이브 네트워크 캡처, 퍼포먼스 트레이스, 콘솔 오류, Lighthouse 감사, 메모리 스냅샷 |

두 도구는 중복이 아니라 **상호 보완**입니다. 사용자 플로우는 `playwriter`로 재현하고, 근거 수집은 `chrome-devtools-mcp`로 Chrome DevTools 수준의 충실도로 진행합니다. 한 쪽만 가능하면 `playwriter`로 조작, CDP fallback으로 근거를 모읍니다.

</routing>

---

<tool_surface>

## chrome-devtools-mcp 도구군

탐색 / 페이지 제어:
- `navigate_page`, `take_snapshot`, `take_screenshot`, `list_pages`, `select_page`, `new_page`, `close_page`

네트워크 근거 (Playwriter CDP를 대체하거나 보강):
- `list_network_requests`, `get_network_request` — 헤더/상태/mime/허용된 본문이 정규화된 형태로 제공

콘솔 근거:
- `list_console_messages`, `get_console_message` — 런타임 오류, 경고, deprecation 메시지

퍼포먼스와 감사:
- `performance_start_trace`, `performance_stop_trace`, `performance_analyze_insight`
- `lighthouse_audit` — 접근성, SEO, best-practices, 퍼포먼스
- `take_memory_snapshot`

페이지 상호작용 (Playwriter를 못 쓸 때):
- `click`, `fill`, `fill_form`, `hover`, `drag`, `press_key`, `wait_for`, `handle_dialog`, `type_text`, `upload_file`

스크립트 실행:
- `evaluate_script` — 페이지 컨텍스트 JS 실행

</tool_surface>

---

<workflow>

## 표준 discovery 흐름

```text
1. `playwriter`로 대상 플로우 재현 (로그인, 이동, lazy 스크롤)
2. 같은 세션 또는 같은 URL에 `chrome-devtools-mcp` 부착
3. `list_network_requests`로 요청 패밀리 목록화
4. 후보 엔드포인트만 `get_network_request`로 본문 샘플링
5. 퍼포먼스/탐지 신호가 중요하면 `performance_start_trace` → 플로우 트리거 → `performance_stop_trace` → `performance_analyze_insight`
6. 구조 파악은 전체 HTML 대신 `take_snapshot` (accessibility tree) 우선
```

</workflow>

---

<decision_notes>

## chrome-devtools-mcp을 Playwriter CDP보다 우선해야 할 때

- **네트워크 캡처**: `list_network_requests`가 정규화·중복 제거된 행을 돌려주므로, 직접 Playwriter CDP listener를 짜는 것보다 토큰이 적게 듭니다.
- **퍼포먼스 트레이스**: 네이티브 트레이스 + insight는 chrome-devtools-mcp만 제공.
- **Lighthouse 감사**: SEO/퍼포먼스/접근성 베이스라인은 chrome-devtools-mcp 전용.
- **콘솔 진단**: `list_console_messages`는 구조화·필터링 가능. Playwriter `page.on("console")`은 1회성에 적합하나 별도 버퍼링이 필요합니다.

페이지 조작과 selector 검증만 필요하면 Playwriter에 머무르고, 두 브라우저를 동시에 띄우지 않습니다.

</decision_notes>

---

<anti_detect_caveat>

## Anti-detect 상호작용

`chrome-devtools-mcp`은 CDP가 완전히 부착된 실제 Chrome을 띄웁니다. 그 결과:

- **`Runtime.Enable`이 켜져 있습니다** — Cloudflare와 DataDome가 이를 탐지합니다. 봇 탐지가 강한 대상은 chrome-devtools-mcp를 일회성/사전 로그인 페이지에서만 사용하고, 본 실행은 stealth 런너로 옮깁니다 ([anti-bot-checklist.md](anti-bot-checklist.md)).
- IP/지문/TLS 표면은 호스트 환경 그대로 노출됩니다. 확장 시에는 residential proxy + stealth 프로필을 함께 씁니다.
- chrome-devtools-mcp는 **대표 세션의 근거 수집** 용도이지, 보호된 대상에 장시간 도는 크롤러 런타임은 아닙니다.

</anti_detect_caveat>

---

<artifact_outputs>

## 근거 산출물 위치

- chrome-devtools-mcp 출력은 [cdp-capture.md](cdp-capture.md)에 정의된 `raw/network-summary.json`, `raw/auth-signals.json`, `raw/endpoint-candidates.json`으로 정규화합니다.
- 이 경로로 끝까지 갔다면 `ACTION.json`의 `capture_mode`를 `"chrome-devtools-mcp"`로 기록합니다.
- Lighthouse / 퍼포먼스 요약은 `ANALYSIS.md`에 한 줄로 적고 raw 아티팩트 링크를 답니다.

</artifact_outputs>
