# Community Tone Presets

샘플이 없을 때 쓰는, 잘 알려진 한국 커뮤니티 말투의 근사치 프리셋. 여기의 모든 프리셋은 `preset_approximation`이다 — 검증된 1차 샘플에서 추출한 것이 아니라 2차 리서치에서 요약한 스키마 형태의 근사치다.

## 목차

- 프리셋 사용법
- Preset: 디시인사이드 (DC Inside)
- Preset: 네이트판 (Nate Pan)
- Preset: 더쿠 · 인스티즈 (Theqoo / Instiz)
- Preset: 펨코 (Femco)
- Preset: 블라인드 (Blind)
- Preset: 맘카페 (Mom Cafe)
- Preset: 스레드 (Threads Korea)

## 프리셋 사용법

- 프리셋은 출발점이다. `sample_count: 0`은 1차 샘플이 전혀 뒷받침하지 않는다는 뜻이고, 라벨이 붙은 규칙을 제외한 모든 규칙을 PREFER급으로 다루며, author나 subcommunity fidelity를 절대 주장하지 않는다 — 커뮤니티 전반의 근사치까지만.
- 나중에 사용자가 샘플을 주면 샘플이 프리셋을 이긴다(`rules/sample-quality.md` preset → sample upgrade), mode는 `hybrid`가 된다.
- 은어는 빨리 낡는다. 각 프리셋의 `valid_at`이 관측 기반이고, 시의성이 중요한 것은 신선도를 확인하고, 확신 없는 항목은 미검증으로 표기한다.
- 비속어와 은어는 허용도 규칙(얼마나 자주, 어떤 감정에서)으로 나타내지, 필수 어휘 목록으로 만들지 않는다.

## Preset: 디시인사이드 (DC Inside)

- profile_mode: preset_approximation
- source_scope: DC Inside 갤러리 글과 답글, 일반 갤러리 문화 — 특정 갤러리의 전체 문화가 아님
- sample_count: 0
- observed_contexts: 갤러리 본문, 답글 스레드
- valid_at: 2026-09
- unsupported_contexts: 갤러리별 은어 사전, 타 플랫폼
- 근거: 리서치 claim C2, U1; 은어 목록 불완전(소스 차단) — 나열된 은어는 사전이 아니라 예시로만 취급

- MUST: 음슴체 종결 — 서술문은 ~임/~음, 의문문은 ~냐/~거든으로 끝낸다
- MUST: 짧은 문장, 생각 하나당 줄 하나(문장마다 개행)
- PREFER: 전체를 반말로; 직접적인 단정문을 먼저 놓고 반응을 뒤에 둔다
- PREFER: 드립이나 조롱 뒤 `ㅋㅋ` 연타(2~6회); 어색할 때 `;;`
- PREFER: 주제에 대한 비꼼·조롱 태도; "올바름"을 갤러리 공통 인식으로 프레임
- AVOID: 캐주얼 글에서 해요체·합니다체; 완충된 부드러운 지시
- 비속어: 가벼운 수준~강한 은어가 관용으로 자리 잡았다(격한 감정에서 PREFER), 인용된 욕설은 커뮤니티 고유 패턴을 따른다 — 고정 목록이 아님
- 미검증: 갤러리별 은어 목록(U1); 시대에 따른 은어 변이

## Preset: 네이트판 (Nate Pan)

- profile_mode: preset_approximation
- source_scope: 네이트판 게시판(사회·연예·이슈) 글, 일반 판 문화 — 특정 게시판 아님
- sample_count: 0
- observed_contexts: 사건글, 조언글, 핫이슈 반응
- valid_at: 2026-09
- unsupported_contexts: 게시판별 내부 드립, 타 플랫폼
- 근거: 리서치 claim C3

- MUST: 음슴체 + 호소체 혼용 — ~남/~임/~듯 서술과 감정 구간의 ~거든요/~네요 교차
- MUST: 잦은 개행, 정황 묘사를 곁들인 긴 감정 서사
- PREFER: 슬픔·답답함에 `ㅠㅠ`; 제목은 짧고 주목을 끌게
- PREFER: 공감 구하기 프레임; 독자를 같은 판 사용자로 호명
- PREFER: 서사 프레임에 썰 같은 은어 사용
- AVOID: 건조한 사실 보도체; 사건글에서 격식 존댓말 서술
- 비속어: 강한 구간에서 가벼운 표현, 서술에서는 아끼듯 절제

## Preset: 더쿠 · 인스티즈 (Theqoo / Instiz)

- profile_mode: preset_approximation
- source_scope: 더쿠·인스티즈 글+댓글 문화(여성 중심 커뮤니티) — 특정 게시판 아님
- sample_count: 0
- observed_contexts: 핫이슈 반응글, 댓글 스레드
- valid_at: 2026-09
- unsupported_contexts: 타 여초 게시판, 게시판별 은어
- 근거: 리서치 claim C4

- MUST: 친근한 반말, ~해/~임 혼용; 독자를 동료로 호명(언냐 register)
- MUST: `ㅋㅋ`/`ㅠㅠ`/`!!` 빈출; 주장에 스네크나 완충을 얹는 `(?)`
- PREFER: 공감 구하는 도입("나만 ~한 거 아니야?"식)
- PREFER: 비난 자제 규범 — 비판은 완충하고, 글의 대상에 대한 공격은 절제
- AVOID: 공격적 대립; 반응글에서의 격식 발화
- 비속어: 허용도 낮음; 강도는 문장부호와 과장으로 표현

## Preset: 펨코 (Femco)

- profile_mode: preset_approximation
- source_scope: 펨코 게시판 글과 댓글, 일반 문화 — 특정 게시판 아님
- sample_count: 0
- observed_contexts: 핫이슈 반응, 커뮤니티 메타 글
- valid_at: 2026-09
- unsupported_contexts: 게시판별 은어, 타 플랫폼
- 근거: 리서치 claim C5

- MUST: 짧고 단정적인 문장; ~임/~다 종결
- MUST: 초성체 약어(ㄱㄱ, ㅁㅁ, ㅇㅈ, ㄹㅇ)를 기본 register로
- PREFER: 드립 뒤 `ㅋㅋ`; 팩트 제시 뒤 한 마디
- PREFER: ~지않냐 같은 수사적 도발; 감정 서사보다 건조한 유머
- AVOID: 긴 감정 서사; 공감 구하기 프레임
- 비속어: 가벼운 은어의 관용적 사용이 보통(PREFER); 직접적 비하 표현은 커뮤니티 규범을 따름 — 여기에 나열하지 않음

## Preset: 블라인드 (Blind)

- profile_mode: preset_approximation
- source_scope: 블라인드 직장 글, 일반 직장 문화 register — 특정 회사 게시판 아님
- sample_count: 0
- observed_contexts: 커리어 조언, 연봉·이직 화제, 직장 하소연
- valid_at: 2026-09
- unsupported_contexts: 비직장 주제, 회사별 은어
- 근거: 리서치 claim C6

- MUST: 익명임에도 존댓말(~합니다/~요)
- MUST: 직장 register — 직장 명사와 호칭(부장님, 선배, 동료)이 자연스러운 어휘
- PREFER: 절제된 톤, 이모티콘 적음; 하소연보다 실용적 디테일
- PREFER: 연봉·이직·평가 화제를 담담하게 다룸
- AVOID: 커뮤니티식 밈 대화; 공격적 은어
- 비속어: 허용도 낮음; 불만은 완곡어법으로 표현

## Preset: 맘카페 (Mom Cafe)

- profile_mode: preset_approximation
- source_scope: 맘카페(줌마체) 글, 일반 카페 문화 — 특정 카페 아님
- sample_count: 0
- observed_contexts: 육아 질문, 일상 이야기, 제품 추천
- valid_at: 2026-09
- unsupported_contexts: 카페별 은어, 타 인구층
- 근거: 리서치 claim C7

- MUST: ~네요가 사실상 기본 종결; 따뜻한 톤과 관용적 어미 연장
- MUST: 시그니처 표기와 애칭(넘흐, 딸램, 잇님, 횐님), 인그룹 추임새(푸힛, 이궁)
- MUST: 문장부호 습관 — 여운의 `..`, 물결 `~`, 인사 뒤 `^^`
- PREFER: 거친 요청도 우회·길게 끄는 표현; 부드러운 마무리(총총)
- PREFER: 아이 의인화 프레임("그 아이"식 지칭)
- AVOID: 무디한 명령문; 건조한 격식 서술
- 비속어: 사실상 금지; 분노는 비속어가 아니라 단어 길이 끌기로 표현

## Preset: 스레드 (Threads Korea)

- profile_mode: preset_approximation
- source_scope: 한국 스레드 피드 문화 — 특정 서브커뮤니티 아님
- sample_count: 0
- observed_contexts: 단문 일상 글, 답글 스레드
- valid_at: 2026-09
- unsupported_contexts: 팬덤 서브커뮤니티 은어 전체, 타 플랫폼
- 근거: 리서치 claim C8; 은어 목록은 부분적이고 빠르게 변함

- MUST: 독자 나이와 무관하게 반말 고정; 대화체 짧은 문장
- MUST: `스-` 접두 조어(스팔, 스하리, 스린이, 스인물식)를 고유 은어 계열로 — 나열 예시 외에는 미검증
- PREFER: 강한 인그룹 결속 표시; 상대 register 미러링(존댓말에는 존댓말로 답)
- PREFER: 일상·자영업·정치가 흔한 주제
- AVOID: 격식 서술; 게시판식 형식(제목, 구조화된 섹션)
- 비속어: 가벼운 은어가 흔함(PREFER); 강도는 공격이 아니라 캐주얼함으로

## Sources

> 외부 출처를 사용하지 않았다. 내용 확인 2026-09-21.

모든 프리셋은 이 패키지 자체의 `preset_approximation` 요약이다. `근거:` 라벨(C2~C8, U1)이 가리키는 것은 이 프리셋을 만든 리서치 실행의 claim이며, 그 실행 기록은 이 패키지에 포함돼 있지 않다. 따라서 여기서 인용하거나 다시 확인한 외부 페이지나 출판물은 없다. 리서치가 확인하지 못한 항목은 출처 대신 미검증으로 적혀 있고, `valid_at`은 인용이 아니라 관측 기반이다.
