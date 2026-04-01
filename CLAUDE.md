# CLAUDE.md

이 파일은 Claude Code 전용 프로젝트 지시사항입니다.
범용 규칙은 `AGENTS.md`를 참조하세요.

## 공통 규칙

AGENTS.md에 정의된 작업 범위, `npx skills add` 규칙, 우선순위, 변경 원칙을 따른다.

## Claude Code 전용 설정

- Context7 MCP가 설치되어 있으면 라이브러리 공식 문서 조회 시 1순위로 사용한다.
- `.claude-plugin/` 디렉터리에 Claude Code 플러그인 마켓플레이스 설정이 정의되어 있다.
- Claude Code 환경에서는 `~/.claude/` 전역 설정을 참조하지 않는다 — 프로젝트 로컬 설정만 사용한다.
