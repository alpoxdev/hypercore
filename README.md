# Hypercore Agent Skills

이 저장소는 다음 형식과 호환되도록 구성되어 있습니다.
- [`vercel-labs/agent-skills`](https://github.com/vercel-labs/agent-skills) 스타일 스킬 패키지
- [`agentskills.io`](https://agentskills.io/skill-creation/using-scripts)의 Agent Skills 포맷 및 스크립트 작성 가이드

## 저장소 구조

```text
skills/
  <skill-name>/
    SKILL.md
    scripts/      # 선택
    references/   # 선택
    assets/       # 선택
scripts/
  new-skill.sh
  validate-skills.sh
```

## 빠른 시작

1. 새 로컬 스킬 기본 구조 생성:

```bash
./scripts/new-skill.sh my-skill
```

2. 전체 스킬 검증:

```bash
./scripts/validate-skills.sh
```

## `vercel-labs/agent-skills`에서 스킬 가져오기

Vercel 공개 스킬 저장소를 기준 소스로 사용해 필요한 스킬을 이 레포에 가져옵니다.

1. 로컬 에이전트 환경에 Vercel 스킬 설치:

```bash
npx skills add vercel-labs/agent-skills
```

2. 특정 스킬을 이 저장소(`skills/<skill-name>`)로 가져오기:

```bash
TMP_DIR="$(mktemp -d)"
git clone --depth 1 --filter=blob:none --sparse https://github.com/vercel-labs/agent-skills "$TMP_DIR/agent-skills"
cd "$TMP_DIR/agent-skills"
git sparse-checkout set react-best-practices
cp -R react-best-practices /Users/alpox/Desktop/dev/kood/hypercore/skills/react-best-practices
```

3. 가져온 뒤 검증:

```bash
cd /Users/alpox/Desktop/dev/kood/hypercore
./scripts/validate-skills.sh
```

4. (선택) 이 저장소의 한/영 파일 규칙 유지:
- 원문이 한국어면 `SKILL.ko.md` 유지
- 영어 번역본은 `SKILL.md`로 추가

## 참고

- 스크립트는 `skills/<name>/scripts` 아래에 두고, 가능하면 평탄한 `.sh` 구조를 유지합니다.
- 검증기 호환성을 위해 `user-invocable` frontmatter는 필요 시 제거합니다.
