# Agent Security Reference

> 영어판: [`agent-security.md`](agent-security.md)

[`HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## Agentic Security Minimums` 뒤에 있는
위협 목록이다.

**출처 표기.** 아래 위험 10종은 **OWASP의 것**이다. *OWASP Top 10 for Agentic Applications for 2026*
으로 공개됐다. 판본명은 "Version 2026"이고 표지 날짜는 2025년 12월, 배포일은 2025-12-09다. 이 문서는
OWASP의 목록을 그대로 전하고, **하네스 통제** 열 하나를 덧붙인다. 그 열은 이 저장소의 대응이며 OWASP의
인용이 아니다. 2026-11-03 기준으로 리소스 페이지에는 판본이 하나뿐이고 개정판은 없다.

**인용 태도.** OWASP는 문서 앞머리의 서한에서 `Least-Agency`와 `strong observability` 두 가지 생각을
제시하지만, 그것을 "원칙(principle)"이라고 부르지 않는다. 문서 전체에 그 단어가 나오지 않는다. "두 가지
핵심 원칙"이라는 틀은 2차 해설에서 생겼다. **생각을 인용하고 틀은 인용하지 않는다.**

**"v2.01" 판본을 인용하지 않는다.** 2026년 블로그 여럿이 이 목록의 2026년 6월 개정판이 있다고 쓴다.
그 판번호는 다른 OWASP 문서인 *State of Agentic AI Security and Governance 2.01*의 것이다. 에이전트
Top 10 자체는 개정되지 않았다. 짝을 이루는 *Agentic AI Threats and Mitigations* 분류는 배포 시점에
1.1로 올라갔다.

## OWASP가 직접 쓴 문장

Agentic Top 10 Leaders 서한에서 인용한다. 서명자는 John Sotiropoulos(Agentic Top 10 의장),
Keren Katz, Ron F. Del Rosario다.

> "We expand on the concepts of Least-Privilege and Excessive Agency by citing Least-Agency. This
> captures our advice to organizations to avoid unnecessary autonomy; deploying agentic behavior
> where it is not needed expands the attack surface without adding value. Similarly, strong
> observability becomes non-negotiable: without clear visibility into what agents are doing, why
> they are doing it, and which tools they are invoking, unnecessary autonomy can quietly expand
> the attack surface and turn minor issues into system-wide failures."

두 생각이 함께여야 하는 이유는 어느 한쪽만으로는 성립하지 않기 때문이다.

- **관측성 없는 최소 자율**은 맹목적 위험 감소다. 자율성을 직감으로 줄이고, 그 축소가 도움이
  되었는지 아무도 보여 주지 못한다.
- **최소 자율 없는 관측성**은 무제약 에이전트에 대한 감시다. 기록은 완전하고 권한은 여전히 무한하다.

OWASP가 최소 자율을 적용한 예로 든 문장은 ASI02 완화 목록에 있다.

> "Least Agency and Least Privilege for Tools. Define per-tool least-privilege profiles (scopes,
> maximum rate, and egress allowlists)..."

## 위험 10종 (OWASP 공식 제목)

문서의 절 제목과 "Agentic Top 10 At A Glance" 페이지에서 그대로 옮겼다. 통제 열은 이 저장소가
`HE-S-*` 규칙과 그 규칙을 나르는 하네스 계층에 대응시킨 것이다.

| id | OWASP 제목 | 하네스 통제 | 규칙 |
|---|---|---|---|
| ASI01 | Agent Goal Hijack | 외부 입력은 데이터다. 계획을 허용 행동 목록으로 검증하고, 탈취된 목표가 프로덕션에 닿지 못하게 한다 | HE-S-2 |
| ASI02 | Tool Misuse and Exploitation | 도구별 범위·호출률·송신 제한, 인자 스키마 검증, 조합된 사슬까지 포함한 호출 단위 정책 | HE-S-1 |
| ASI03 | Identity and Privilege Abuse | 역할별로 구분된 에이전트 정체성, 기한 있는 범위, 에이전트·사용자·행동을 잇는 감사 기록 | HE-S-1, HE-T-2 |
| ASI04 | Agentic Supply Chain Vulnerabilities | 외부 에이전트·MCP 서버·플러그인·템플릿·도구 서술자의 버전 고정과 출처 인증 | HE-S-3 |
| ASI05 | Unexpected Code Execution (RCE) | 생성된 코드를 프로덕션 자격증명으로 실행하지 않는다. 샌드박스 런타임과 실행 전 허용 목록 | HE-S-1 |
| ASI06 | Memory & Context Poisoning | 저장 전 정제, 저장소 무결성 검사, 에이전트별 메모리 범위, 롤백 경로 | HE-S-2, HE-L-1 |
| ASI07 | Insecure Inter-Agent Communication | 모든 메시지 인증, 위임 사슬 인가, 에이전트 간 권한 상승 금지 | HE-S-1, HE-S-3 |
| ASI08 | Cascading Failures | 체인 깊이·런타임 상한, 계획과 실행 사이의 검증, 롤백 | HE-S-4 |
| ASI09 | Human-Agent Trust Exploitation | UI에서 에이전트 내용과 검증된 데이터를 구분하고, 고위험 행동에 사람 승인을 두며, 권고에 출처를 붙인다 | HE-S-4 |
| ASI10 | Rogue Agents | 검증된 정체성별 행동 기준선, 드리프트 감시, 킬 스위치, 세션 격리 | HE-S-4, HE-T-2 |

## 이름과 인용 주의

문서 자체가 일관되지 않으므로, 틀려 보이는 인용도 원문대로일 수 있다.

| 관찰 | 내용 |
|---|---|
| `&`와 `and` | "At A Glance" 격자는 `ASI02: Tool Misuse & Exploitation`, `ASI03: Identity & Privilege Abuse`로 적고, 그 두 항목의 본문 제목과 목차는 `and`를 쓴다. ASI06 같은 다른 제목은 `&`를 그대로 쓴다 |
| ASI05 괄호 | 제목과 격자 모두 `Unexpected Code Execution (RCE)`를 붙인다 |
| ASI10 오타 | ASI10 본문은 다른 항목을 `AS01`, `AS04`로 적는다 |
| 제목 대소문자 | 제목은 title case다. 소문자로 "정규화"한 목록을 정본처럼 쓰지 않는다 |

## 위험들이 공통으로 갖는 것

ASI01~ASI10을 가로질러 한 가지 패턴이 반복된다. 많은 실패가 **정체성과 인가 문제로 위장**해 있다.
목표 탈취는 에이전트가 신뢰된 오케스트레이션과 신뢰할 수 없는 데이터를 구분하지 못할 때 성공한다.
도구 오용은 인가를 도구가 아니라 에이전트에서 검사할 때 성공한다. 통제 이탈 에이전트는 검증된
정체성에 묶인 행동 기준선이 없을 때 성공한다.

모든 신뢰 경계에서 물을 세 가지:

1. **누가 행동하는가?** 빌려온 사람 세션이 아니라 구분된 에이전트 정체성.
2. **무엇이 허가되어 있는가?** 범위가 있고 기한이 있으며 취소 가능한 권한.
3. **나중에 증명할 수 있는가?** 정체성·정책 결정·결과를 잇는 감사 기록.

하네스 규칙이 직접 규정하는 지점은 **조합**이다. 개별 도구는 허용되어도 그 사슬은 허용되지 않을 수
있다.

## 2026년 하네스 문헌이 보태는 것

OWASP는 위험을 열거한다. 2026년 벤더 하네스 문헌은 그 목록이 비스듬히만 가리키는 통제 두 가지를
제시한다.

- **하네스와 연산을 분리한다** (ASI01, ASI05). OpenAI의 Agents SDK 발표에서 인용한다.

  > "Agent systems should be designed assuming prompt-injection and exfiltration attempts.
  > Separating harness and compute helps keep credentials out of environments where model-generated
  > code executes."

  이것은 HE-S-1의 구조적 판본이다. 자격증명을 쥔 프로세스와 모델이 쓴 코드를 실행하는 프로세스가
  다르므로, 탈취된 목표는 닿지 못하는 것을 쓰지 못한다.

- **상태를 바깥에 두어 샌드박스 손실이 실행 손실이 되지 않게 한다** (ASI08, ASI10).

  > "It also enables durable execution. When the agent's state is externalized, losing a sandbox
  > container does not mean losing the run."

  발동할 때 작업을 파괴하는 격리 통제는 결국 필요로 하는 사람이 꺼 버린다. 그래서 내구성은 별도
  관심사가 아니라 보안 논증의 일부다.

## Sources

> 확인 2026-11-03.

**등급 어휘.** 이 디렉터리의 모든 출처 표가 쓰는 하나의 닫힌 집합이다. [`../HARNESS_ENGINEERING.ko.md`](../HARNESS_ENGINEERING.ko.md)의 `## Sources`를 본다.

| 주장 | 출처 | Grade |
|---|---|---|
| 위험 10종의 제목, 위에 인용한 두 생각, `Least Agency and Least Privilege for Tools` 완화 항목, 그리고 요약 격자가 ASI02·ASI03에 `&`를 쓴다는 점 | <https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/> (문서 PDF는 이 페이지에서 연결되며, 페이지와 PDF 모두 로그인 없이 응답한다) | PRIMARY |
| 판본명 "Version 2026", 표지 날짜 2025년 12월, 배포일 2025-12-09, 개정판 부재 | <https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/> | PRIMARY |
| 짝을 이루는 *Agentic AI Threats and Mitigations* 분류와 그 별도 버전 관리 | <https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/> | PRIMARY |
| 하네스/연산 분리, 자격증명 격리, 상태 외부화를 통한 내구성 | <https://openai.com/index/the-next-evolution-of-the-agents-sdk> | VENDOR |

이 파일의 이전 판은 OWASP 페이지가 초록만 반환한다고 보고 원칙 진술과 위험 목록을 3자 요약 하나에
의존했다. 문서는 로그인 없이 받을 수 있으므로, 제목과 인용문에 그 요약이 더는 필요하지 않다.
