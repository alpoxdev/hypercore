# Action Manifest

> `.hypercore/crawler/<ACTION>.json`을 재개 가능한 크롤링 작업의 durable context 파일로 사용합니다.

---

<purpose>

- 실행 의도, 현재 상태, 근거 포인터, blocker, 다음 단계를 기계가 읽기 쉬운 파일 하나로 보존합니다.
- `ACTION.json`은 compact하고 orchestration 중심으로 유지합니다.
- 자세한 근거와 생성 결과물은 `.hypercore/crawler/[site]/`에 둡니다.

</purpose>

---

<lifecycle>

## 상태값

- `planned`: action은 만들어졌지만 discovery는 시작하지 않음
- `running`: discovery 또는 문서화가 진행 중
- `blocked`: 근거나 환경이 부족해 안전하게 계속할 수 없음
- `complete`: 필요한 산출물이 기록됐고 다음 단계가 비어 있거나 종료 상태임

</lifecycle>

---

<required_fields>

## 필수 필드

- `action`
- `site_name`
- `base_url`
- `site_dir`
- `status`
- `capture_mode`
- `evidence`
- `outputs`
- `blockers`
- `next_step`

</required_fields>

---

<capture_mode>

## Capture Mode 값

- `cdp`
- `fallback`
- `dom`

CDP 연결이 실패했지만 브라우저 네트워크 근거가 충분하면 `fallback`을 사용합니다.

</capture_mode>

---

<update_rules>

## 갱신 규칙

- 장시간 또는 재개 가능한 discovery를 시작하기 전에 `ACTION.json`을 만듭니다.
- 각 주요 단계 뒤에 `status`, `capture_mode`, `next_step`을 갱신합니다.
- 차단되면 blocker와 사용 가능한 output pointer를 먼저 기록하고 멈춥니다.
- 완료되면 `outputs`가 `.hypercore/crawler/[site]/` 아래 최종 파일을 가리키게 합니다.

</update_rules>

---

<validation_notes>

## 검증 메모

- `site_dir`는 `status`가 `running`, `blocked`, `complete`가 될 때 실제 사이트 아티팩트 디렉터리를 가리켜야 합니다.
- `status: "blocked"`이면 blocker 항목이나 명시적 제한 메모가 최소 하나 있어야 합니다.
- `status: "complete"`이면 `next_step`이 비어 있거나 종료 상태여야 하고, 최종 output pointer가 채워져 있어야 합니다.

</validation_notes>

---

<example>

## 예시

```json
{
  "action": "extract-products",
  "site_name": "shop-example-com",
  "base_url": "https://shop.example.com/products",
  "site_dir": ".hypercore/crawler/shop-example-com",
  "status": "running",
  "capture_mode": "cdp",
  "evidence": {
    "cdp_attached": true,
    "raw_files": [
      "raw/network-summary.json",
      "raw/auth-signals.json",
      "raw/endpoint-candidates.json"
    ]
  },
  "outputs": {
    "analysis": "ANALYSIS.md",
    "api": null,
    "network": null,
    "crawler": null
  },
  "blockers": [],
  "next_step": "summarize endpoint families into API.md"
}
```

</example>
