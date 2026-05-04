---
name: deploy-fix
description: 저장소 전체 또는 특정 폴더의 빌드 실패, CI 파이프라인 오류, 배포 오류를 진단하고 수정하는 스킬. 간단한 빌드 장애는 바로 수정하고, 복잡한 다중 시스템 장애는 .hypercore/deploy-fix/ JSON 플로우로 진행 상황을 추적한다.
compatibility: 코드 탐색(Read/Grep/Glob), 수정(Edit), 셸 실행(Bash)이 가능한 환경에서 사용.
---

# Deploy Fix Skill

> 빌드, CI, 배포 장애를 진단하고, 가장 안전한 수정 경로를 고른 뒤 구현한다 — 복잡도를 먼저 판단하고, 간단하면 바로 수정하고 복잡하면 단계별로 추적하며 진행한다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<request_routing>

## Positive triggers

- `Module not found`, 타입 에러, 컴파일 실패 등 구체적인 에러로 빌드 명령이 실패
- CI 파이프라인의 특정 단계(lint, test, build, deploy)가 로그에 구체적인 에러를 남기며 실패
- 함수 타임아웃, 환경변수 누락, 플랫폼 빌드 에러 등 구체적인 에러로 배포 실패
- 모노레포 내 특정 폴더 또는 워크스페이스의 빌드 실패

## Out-of-scope

- 재현 경로가 있는 애플리케이션 런타임 버그. `bug-fix`로 라우팅
- 보안 감사, 익스플로잇 검토, 신뢰 경계 분석. `security-review`로 라우팅
- 구체적 장애와 무관한 신규 기능 개발, 리팩터링, 추측성 정리 작업
- 빌드/배포 실패가 아닌 일반적 성능 최적화

## Boundary cases

- 사용자가 원인 분석만 원하면 diagnosis 모드로 머물고 수정하지 않는다.
- CI 실패의 원인이 단일 런타임 버그(코드 결함으로 인한 테스트 실패 등)이면 CI 레벨 수정은 이 스킬이 담당하고, 근본적인 코드 버그는 `bug-fix`로 넘긴다.
- 장애가 빌드 + 배포 + 런타임에 걸쳐 있으면 빌드/배포 레이어를 담당하고 런타임은 `bug-fix`로 넘긴다.

</request_routing>

<argument_validation>

ARGUMENT가 없으면 즉시 질문:

```text
어떤 빌드/CI/배포 장애를 수정해야 하나요?
- 에러 메시지 또는 실패 로그 출력
- 실패하는 빌드 명령 또는 CI 단계
- 전체 저장소 빌드인지 특정 폴더/워크스페이스인지?
- CI 제공자 (GitHub Actions, Vercel 등) 해당 시
- 회귀인지 신규인지? (이전에 작동했는지? 언제부터 실패했는지?)
- 일관적인지 간헐적인지?
- 최근 변경, 의심 커밋, 또는 환경 정보
- 관련 설정 파일 (package.json, tsconfig, CI 설정, vercel.json 등)
```

</argument_validation>

<mandatory_reasoning>

## 필수 순차적 사고

수정 전에 반드시 `sequential-thinking`을 실행한다. 깊이는 복잡도에 비례:

- **간단 (3단계)**: 실패 지점 파악 -> 수정 결정 -> 검증 방법 확인
- **보통 (5단계)**: 분류 -> 로컬 재현 -> 가설 -> 옵션 비교 -> 추천
- **복잡 (7단계 이상)**: 분류 -> 재현 -> 의존성 체인 분석 -> CI 설정 확인 -> 다중 원인 가설 -> 옵션 비교 -> 교차 영향 평가 -> 추천

권장 흐름:

1. 복잡도 판단
2. 장애 재현 및 로그 분석
3. 원인 가설
4. 수정 옵션 비교
5. 추천안 도출

수정 전에 반드시 빌드 로그, CI 출력, 배포 로그에서 root-cause evidence를 확보하고, 실제로 검증 가능한 가장 좁은 failing boundary까지 문제를 줄인다.

</mandatory_reasoning>

<complexity_classification>

## 복잡도 분류

sequential-thinking 직후에 즉시 분류:

| 복잡도 | 신호 | 예시 | 경로 |
|--------|------|------|------|
| **간단** | 단일 파일/설정, 명확한 에러 메시지, 원인 자명, 수정 경로 1개, 리스크 낮음 | 환경변수 누락, 설정 파일 오타, 단일 의존성 버전 문제, 단일 파일 타입 에러 | **Fix-now** — 플로우 추적 없이 바로 수정 |
| **복잡** | 다중 패키지/설정 관여, 의존성 체인 문제, CI 환경 불일치, 워크스페이스 간 사이드 이펙트, 유효한 수정 전략 다수 | 워크스페이스 간 타입 에러 체인, 로컬 재현 불가 CI 전용 실패, 다중 패키지 lockfile 충돌, 빌드 성공 후 배포 실패 | **추적 모드** — `.hypercore/deploy-fix/flow.json` 생성 |

분류 결과 발표:

```
복잡도: [간단/복잡] — [한 줄 근거]
```

판단이 애매하면 복잡으로 분류한다. 추적하는 비용이 조사 진행 상황을 잃는 비용보다 낮다.

</complexity_classification>

<flow_tracking>

## 플로우 추적 (복잡 경로만)

복잡으로 분류되면 플로우를 초기화:

```bash
mkdir -p .hypercore/deploy-fix
```

`.hypercore/deploy-fix/flow.json`을 작성하고 각 단계 완료 시 업데이트한다. 전체 스키마는 `references/flow-schema.md` 참조.

### 단계 진행

| 단계 | 설명 | 다음 |
|------|------|------|
| `investigate` | 장애 재현, 로그 분석, 원인 분석, 근거 수집 | `options` |
| `options` | 수정 옵션 2-3개 제시 | `confirm` |
| `confirm` | 사용자 선택 대기 및 기록 | `fix` |
| `fix` | 선택된 옵션 구현 | `verify` |
| `verify` | 빌드/CI/배포 검증 실행, 결과 보고 | 완료 |

### 재개 지원

`.hypercore/deploy-fix/flow.json`이 이미 존재하면 먼저 읽고 마지막 미완료 단계(`in_progress` 또는 `pending`)부터 이어간다. 완료된 단계를 재시작하지 않는다.

</flow_tracking>

<execution_modes>

아래 분기 중 하나를 명시적으로 선택:

- **Diagnose-only**: 장애 재현, 실패 지점 격리, 근거 요약까지만 하고 코드 수정 전에 멈춘다.
- **Fix-now** (간단 경로): 사용자가 직접 수정을 명시적으로 요청했고 가장 안전한 경로가 분명하면, 어떤 경로로 진행하는지 먼저 밝히고 추가 확인 없이 구현한다. 플로우 추적 없음.
- **Option-first** (복잡 경로): 플로우 추적과 함께 옵션 2-3개를 제시하고 사용자 선택을 기다린다.
- **Handoff**: 애플리케이션 런타임 버그는 `bug-fix`, 보안 검토 요청은 `security-review`로 넘긴다.

</execution_modes>

<investigation_strategy>

## 조사 전략

가능성 높은 순서대로 점검:

1. **빌드 로그**: 정확한 에러 출력 읽기, 첫 번째 실패 지점 파악
2. **의존성 문제**: lockfile 충돌(`package-lock.json`/`pnpm-lock.yaml` 무결성), 누락 패키지, 버전 불일치, peer dependency 경고, hoisting 문제
3. **설정 파일**: `tsconfig.json`, `package.json`, `next.config.*`, `vercel.json`/`vercel.ts`, CI 워크플로우 파일, 번들러 설정
4. **환경**: Node.js 버전, 환경변수, 플랫폼별 차이 (로컬 vs CI vs 배포 타겟), 메모리 제한 (빌드 중 OOM)
5. **빌드 캐시**: 오래되거나 오염된 빌드 캐시 (`.next/`, `.turbo/`, `node_modules/.cache/`), `--force` 리빌드로 격리
6. **워크스페이스 간**: 모노레포 의존성 그래프, 빌드 순서, 공유 패키지 버전 드리프트
7. **최근 변경**: `git log`와 `git diff`로 장애를 유발했을 수 있는 의심 커밋 확인

</investigation_strategy>

<workflow>

## 간단 경로 (Fix-now)

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 입력 확인, sequential-thinking (3단계) | sequential-thinking |
| 2 | 간단으로 분류 | - |
| 3 | 로컬에서 장애 재현, 에러 출력 읽기 | Bash + Read |
| 4 | 로그/설정에서 원인 파악 | Read/Grep/Glob |
| 5 | 수정 경로 발표 후 구현 | Edit |
| 6 | 검증 (빌드/린트/타입체크/배포) | Bash |
| 7 | 결과 보고 | - |

## 복잡 경로 (Option-first)

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 입력 확인, sequential-thinking (7단계 이상) | sequential-thinking |
| 2 | 복잡으로 분류, `.hypercore/deploy-fix/flow.json` 생성 | Write |
| 3 | 심층 조사: 재현, 로그 분석, 의존성 체인 추적 -> 플로우 `investigate: completed` 업데이트 | Bash + Read/Grep/Glob + Edit |
| 4 | 수정 옵션 2-3개 제시 -> 플로우 `options: completed` 업데이트 | Edit |
| 5 | 사용자 선택 대기 -> 플로우 `confirm: completed` 업데이트 | Edit |
| 6 | 선택된 옵션 구현 -> 플로우 `fix: completed` 업데이트 | Edit/Write |
| 7 | 검증 실행 -> 플로우 `verify: completed` 업데이트 | Bash + Edit |
| 8 | 결과 보고, 플로우 status를 `completed`로 설정 | Edit |

</workflow>

<option_presentation>

옵션은 아래 형식으로 제시 (복잡 경로):

```markdown
## 배포 장애 분석 결과

**원인**: ...
**장애 범위**: [전체 저장소 / 워크스페이스 / CI 단계 / 배포 타겟]
**복잡도**: 복잡

### 옵션 1: ... (추천)
- **장점**:
- **단점**:
- **리스크**:
- **수정 파일**:

### 옵션 2: ...
- **장점**:
- **단점**:
- **리스크**:
- **수정 파일**:

### 옵션 3: ... (임시 대응)
- **장점**:
- **단점**:
- **리스크**:
- **수정 파일**:

추천: 옵션 N (근거 ...)
어떤 옵션으로 진행할까요? (1/2/3)
```

</option_presentation>

<implementation_rules>

- 명시적인 Fix-now 분기가 아닌 한 사용자 선택 전에는 코드 수정을 시작하지 않는다.
- 추측성 수정 대신 빌드/CI/배포 로그 근거 기반으로 수정한다.
- 수정 범위는 실패하는 빌드/CI/배포 경로와 그 직접 의존성으로 제한한다.
- 변경 경로에 맞는 targeted validation을 실행한다: 실패했던 빌드 타겟 재빌드, 실패했던 CI 단계 재실행, 또는 실패했던 배포 재시도.
- 최종 보고에는 실행한 명령, 핵심 결과, 수정된 파일을 함께 적는다.
- 로컬에서 검증을 실행할 수 없으면(CI 전용 환경 등) 이유와 남아 있는 미검증 범위를 명시한다.

## 보고

실행 후 보고:

```markdown
## 완료

**장애**: [원본 에러 / 실패 단계]
**원인**: [무엇이 잘못되었는지]
**적용한 수정**: [어떤 옵션/접근법]
**변경사항**: [변경된 파일 목록]
**검증**: [검증한 내용과 결과]
```

복잡 경로: `.hypercore/deploy-fix/flow.json`의 status도 `completed`로 업데이트한다.

</implementation_rules>

<validation>

실행 체크리스트:

- [ ] ARGUMENT 확인 완료
- [ ] sequential-thinking 실행 완료 (복잡도에 비례한 깊이)
- [ ] 복잡도 분류 완료 (간단/복잡)
- [ ] 플로우 JSON 생성 및 유지 (복잡 경로만)
- [ ] 빌드/CI/배포 로그에서 원인 분석 근거 확보
- [ ] 옵션 2-3개 제시 (복잡 경로) 또는 수정 경로 발표 (간단 경로)
- [ ] 사용자 선택 확인 (복잡 경로)
- [ ] 실패했던 빌드/CI/배포 명령 재실행으로 검증
- [ ] 결과 및 수정 파일 보고
- [ ] 플로우 JSON `completed` 상태로 마무리 (복잡 경로만)

금지:

- [ ] 빌드/CI/배포 로그 근거 없는 추측 수정
- [ ] 옵션 제시 없이 바로 수정 (복잡 경로)
- [ ] 선택 확인 없이 구현 (복잡 경로)
- [ ] 실패했던 빌드/CI/배포 명령 재실행 없이 완료 선언
- [ ] 복잡 경로에서 플로우 JSON 업데이트 누락

</validation>
