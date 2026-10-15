# Workflow

> 영어 정본: [`workflow.md`](workflow.md)

실행 시작 전에 읽습니다. 이 파일은 시작 질문부터 전달까지의 전체 절차를 다룹니다.

## 1. 시작 질문과 리서치

브리프가 비워 둔 항목만 함께 묻습니다. 주제, 브랜드와 사용자와의 관계(자사 / 협찬 / 없음), 독자와 목표, 사진 출처(제공 / 생성 / 없음), 로고 제공 여부, 형식, 선택적 톤입니다. 답을 기다린 뒤 다시 묻지 않습니다.

사실 묶음을 요구하지 않고 주제에서 리서치합니다. 카드마다 독자의 질문과 출처 있는 답을 적습니다.

- 검색어 후보를 넓히고 카드 세트가 답할 하나를 고릅니다.
- 사실을 `URL | 접근 날짜`와 함께 모읍니다. 1차 출처와 2차 출처를 다르게 표시합니다.
- 직접 경험, 지불한 가격, 결과, 고객 수, 브랜드 문장은 사용자에게서만 옵니다. 없으면 슬롯으로 둡니다.
- 사진 슬롯을 기록합니다. 카드마다 필요한 사진, 존재 여부, 출처입니다.

## 2. 계획

- 카드 수를 정합니다. 앱 캐러셀이 최대 20개이므로 최소 2, 최대 20입니다. 내용이 필요한 만큼만 구성하고 그보다 늘리지 않습니다.
- [`../references/platform-specs.ko.md`](../references/platform-specs.ko.md)에서 형식을 고릅니다. 기본은 1080×1350(4:5)입니다.
- 문구를 훅 → 출처 있는 설명 → 필요한 주의점 → 다음 행동 순서로 구성합니다. 내용에 맞게 장수를 정하며 짧은 세트에서는 역할을 합칩니다. 정해진 장수를 채우려고 카드를 늘리거나 없는 단점을 만들지 않습니다.
- 이미지를 확보하기 전에 카드마다 `scene`, `visualType`, `layout`, `layoutReason`을 정합니다. 서사에 맞게 장면이나 이미지 종류를 바꿉니다. 같은 사진은 장면 연결이나 비교에 필요할 때만 `reuseReason`과 함께 재사용하며 여러 장씩 묶어 반복하는 방식을 기본값으로 삼지 않습니다.

## 3. 구성

- [`../references/output-contract.ko.md`](../references/output-contract.ko.md)대로 입력 문서를 만듭니다.
- 카드마다 [`../references/card-composition.ko.md`](../references/card-composition.ko.md)와 [`legibility-and-typography.ko.md`](legibility-and-typography.ko.md)대로 구성합니다.
- 사진과 글자를 분리한 레이어로 유지합니다. 커버만 `bottom-left`에 고정하고 본문은 이미지 속 대상을 피하도록 배치합니다. 같은 정보 유형의 배치는 유지할 수 있습니다.

## 4. 내보내기

- [`../assets/card-studio.html`](../assets/card-studio.html)을 열고 문서를 불러온 뒤 컴포저 검증을 돌립니다.
- `render` 거부는 `#status[data-error="true"]`를 설정하고 `exportCards`를 막습니다. 원인을 먼저 고칩니다.
- API로 내보내고 게시 순서대로 카드마다 PNG 한 장을 모읍니다.

## 5. 캡션과 대체 텍스트

[`../references/caption-and-alt.ko.md`](../references/caption-and-alt.ko.md)대로 한국어 캡션과 카드별 대체 텍스트를 씁니다. 수와 순서를 카드와 맞춥니다.

## 6. 점검과 전달

[`validation.ko.md`](validation.ko.md)와 컴포저 검증을 돌리고 강제 실패를 최대 두 번 고칩니다. `.hyper/instagram-card-maker/<slug>/`에 `index.html`, `cards/NN.png`, `caption.txt`, `alt-text.json`, `sources.md`, `manifest.json`을 전달합니다.

## Sources

> 외부 출처 없음. 내용 확인 2026-10-15.

이 파일은 이 패키지 자체의 절차를 적습니다. 그것이 가리키는 플랫폼 사실은 [`../references/platform-specs.ko.md`](../references/platform-specs.ko.md)에 있습니다.
