---
name: stitch:loop
description: 반복적 빌드 루프로 웹사이트 자율 구축
---

<purpose>
작업 바통 전달 방식으로 웹사이트를 점진적으로 구축하는 자율 루프 실행
</purpose>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| "빌드 루프 시작" | 즉시 실행 |
| "점진적 구축" | 즉시 실행 |
| "next-prompt 실행" | 즉시 실행 |

</trigger_conditions>

---

<workflow>

<step number="1">
<action>작업 읽기</action>
<tools>Read</tools>
<details>
`next-prompt.md`에서 다음 작업 추출:
```yaml
---
page: about
---
회사 소개 페이지 생성
- 팀 소개 섹션
- 연혁 타임라인
```
</details>
</step>

<step number="2">
<action>컨텍스트 참조</action>
<tools>Read</tools>
<details>
필수 문서:
- `SITE.md`: 비전, 사이트맵, 로드맵
- `DESIGN.md`: 디자인 시스템

완료된 페이지 확인 (중복 생성 방지)
</details>
</step>

<step number="3">
<action>페이지 생성</action>
<tools>Stitch MCP (또는 직접 구현)</tools>
<details>
프롬프트 구성:
1. `next-prompt.md` 내용
2. `DESIGN.md`의 디자인 시스템 블록
3. 페이지 요구사항

**중요:** YAML `page` 필드가 출력 파일명 결정
</details>
</step>

<step number="4">
<action>통합</action>
<tools>Write, Edit</tools>
<details>
- 생성된 HTML/CSS/JS를 프로덕션으로 이동
- 경로 수정 (`/assets/` → 실제 경로)
- 네비게이션 링크 업데이트
</details>
</step>

<step number="5">
<action>문서화</action>
<tools>Edit</tools>
<details>
`SITE.md` 업데이트:
- 사이트맵에 완료된 페이지 추가
- 로드맵에서 완료 항목 제거
</details>
</step>

<step number="6">
<action>바통 전달</action>
<tools>Write</tools>
<details>
`next-prompt.md` 작성:
```yaml
---
page: contact
---
문의 페이지 생성
- 문의 폼
- 지도 임베드
- 연락처 정보

[DESIGN.md의 디자인 시스템 블록 포함 필수]
```
</details>
</step>

</workflow>

---

<baton_system>

## 핵심 개념

**바통 파일 (`next-prompt.md`):**
- 에이전트 간 상태 전달 메커니즘
- 메모리 불필요 (파일이 상태)
- CI/CD 자동화 가능
- 사람 검토 가능

## 필수 규칙

| 규칙 | 이유 |
|------|------|
| YAML `page` 필드 필수 | 출력 파일명 결정 |
| DESIGN.md 블록 포함 | 스타일 일관성 |
| 완료 페이지 확인 | 중복 생성 방지 |
| 네비게이션 업데이트 | UX 연속성 |

## 바통 파일 구조

```yaml
---
page: [페이지명]
---
[작업 설명]

[요구사항]

---
Design System:
[DESIGN.md에서 복사]
---
```

</baton_system>

---

<examples>

## 초기 바통 파일

**next-prompt.md:**
```yaml
---
page: index
---
홈페이지 생성
- 히어로 섹션 (CTA 버튼)
- 주요 기능 3개 소개
- 푸터 (SNS 링크)

---
Design System:
## Colors
- Primary: #3B82F6 (파란색)
- Secondary: #64748B (회색)

## Typography
- Heading: Inter 32px Bold
- Body: Inter 16px Regular

## Spacing
- Section: 64px
- Element: 24px
---
```

---

## 루프 실행 후

**1. index.html 생성됨**

**2. SITE.md 업데이트:**
```markdown
## Sitemap
- [x] Home (`index.html`)
- [ ] About
- [ ] Contact
```

**3. 다음 바톤 (next-prompt.md):**
```yaml
---
page: about
---
회사 소개 페이지 생성
- 팀 소개 카드 (사진, 이름, 직책)
- 연혁 타임라인

---
Design System:
[동일한 디자인 시스템 블록]
---
```

</examples>

---

<site_md_structure>

```markdown
# Site Vision

[웹사이트의 목적과 목표]

## Sitemap

- [x] Home (`index.html`)
- [ ] About (`about.html`)
- [ ] Contact (`contact.html`)

## Roadmap

### Phase 1 (진행중)
- [x] 홈페이지
- [ ] 회사 소개
- [ ] 문의 페이지

### Phase 2
- [ ] 블로그
- [ ] 제품 페이지
```

</site_md_structure>

---

<integration_checklist>

**페이지 통합 시:**
- [ ] HTML/CSS/JS 파일 이동 완료
- [ ] 상대 경로 수정 (`/assets/` → `./assets/`)
- [ ] 네비게이션 링크 업데이트
- [ ] SITE.md 사이트맵 체크
- [ ] 플레이스홀더 제거 (Lorem ipsum 등)
- [ ] 접근성 검증 (ARIA, alt 텍스트)

</integration_checklist>

---

<failure_modes>

| 실패 패턴 | 해결 |
|----------|------|
| `next-prompt.md` 미작성 | 루프 중단 → 항상 작성 |
| 디자인 시스템 누락 | 스타일 불일치 → DESIGN.md 블록 포함 |
| 완료 페이지 재생성 | 리소스 낭비 → SITE.md 확인 |
| 네비게이션 미업데이트 | UX 단절 → 모든 링크 검증 |

</failure_modes>

---

<best_practices>

| 원칙 | 방법 |
|------|------|
| **상태 보존** | 바통 파일로 진행 상황 관리 |
| **일관성** | 항상 DESIGN.md 참조 |
| **검증** | 각 단계 후 SITE.md 업데이트 |
| **자동화** | CI/CD 파이프라인 통합 가능 |

## 자동화 예시

```yaml
# .github/workflows/build-loop.yml
name: Stitch Build Loop
on:
  push:
    paths:
      - 'next-prompt.md'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run stitch-loop skill
        run: claude skill stitch-loop
      - name: Commit changes
        run: |
          git add .
          git commit -m "chore: 빌드 루프 실행"
          git push
```

</best_practices>

---

<validation>

**체크리스트:**
- [ ] `next-prompt.md` YAML frontmatter 포함
- [ ] `page` 필드 명시
- [ ] DESIGN.md 블록 포함
- [ ] SITE.md 사이트맵 최신화
- [ ] 중복 페이지 생성 없음
- [ ] 네비게이션 링크 동작
- [ ] 플레이스홀더 제거

</validation>
