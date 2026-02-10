#!/bin/bash
# Agent Teams 사용 가능 여부 확인
# Usage: .claude/scripts/agent-teams/check-availability.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Agent Teams Availability Check ===${NC}"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

# 1. 환경변수 / settings.json 확인
echo -e "${BLUE}[1/5] Agent Teams 활성화 확인${NC}"

AGENT_TEAMS_ENABLED=false
ENABLED_SOURCE=""

# 환경변수 확인
if [[ "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" == "1" ]]; then
    AGENT_TEAMS_ENABLED=true
    ENABLED_SOURCE="환경변수"
fi

# 글로벌 settings.json 확인 (~/.claude/settings.json)
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$GLOBAL_SETTINGS" ]] && grep -q '"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS".*"1"' "$GLOBAL_SETTINGS" 2>/dev/null; then
    AGENT_TEAMS_ENABLED=true
    if [[ -n "$ENABLED_SOURCE" ]]; then
        ENABLED_SOURCE="$ENABLED_SOURCE + ~/.claude/settings.json"
    else
        ENABLED_SOURCE="~/.claude/settings.json"
    fi
fi

# 프로젝트 settings.json 확인 (.claude/settings.json)
PROJECT_SETTINGS=".claude/settings.json"
if [[ -f "$PROJECT_SETTINGS" ]] && grep -q '"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS".*"1"' "$PROJECT_SETTINGS" 2>/dev/null; then
    AGENT_TEAMS_ENABLED=true
    if [[ -n "$ENABLED_SOURCE" ]]; then
        ENABLED_SOURCE="$ENABLED_SOURCE + .claude/settings.json"
    else
        ENABLED_SOURCE=".claude/settings.json"
    fi
fi

if [[ "$AGENT_TEAMS_ENABLED" == "true" ]]; then
    echo -e "  ${GREEN}✓${NC} Agent Teams 활성화됨 ($ENABLED_SOURCE)"
    ((PASSED++))
else
    echo -e "  ${RED}✗${NC} Agent Teams 미활성화"
    echo -e "    설정 방법 (하나 선택):"
    echo -e "    1. 환경변수: export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
    echo -e "    2. ~/.claude/settings.json:"
    echo -e '       { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }'
    echo -e "    3. .claude/settings.json (프로젝트):"
    echo -e '       { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }'
    ((FAILED++))
fi

# 2. .claude/agents/ 디렉토리 확인
echo ""
echo -e "${BLUE}[2/5] 에이전트 디렉토리 확인${NC}"
AGENTS_DIR=".claude/agents"
if [[ -d "$AGENTS_DIR" ]]; then
    echo -e "  ${GREEN}✓${NC} $AGENTS_DIR 디렉토리 존재"
    ((PASSED++))
else
    echo -e "  ${RED}✗${NC} $AGENTS_DIR 디렉토리 없음"
    echo -e "    생성: mkdir -p $AGENTS_DIR"
    ((FAILED++))
fi

# 3. 에이전트 파일 확인
echo ""
echo -e "${BLUE}[3/5] 에이전트 파일 확인${NC}"
if [[ -d "$AGENTS_DIR" ]]; then
    AGENT_COUNT=$(find "$AGENTS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [[ $AGENT_COUNT -gt 0 ]]; then
        echo -e "  ${GREEN}✓${NC} $AGENT_COUNT개 에이전트 발견"

        # 주요 에이전트 확인
        CORE_AGENTS=("explore" "planner" "implementation-executor" "code-reviewer" "pm")
        MISSING_CORE=()
        for agent in "${CORE_AGENTS[@]}"; do
            if [[ -f "$AGENTS_DIR/$agent.md" ]]; then
                echo -e "    ${GREEN}✓${NC} $agent"
            else
                MISSING_CORE+=("$agent")
            fi
        done

        if [[ ${#MISSING_CORE[@]} -gt 0 ]]; then
            echo -e "    ${YELLOW}!${NC} 권장 에이전트 누락: ${MISSING_CORE[*]}"
            ((WARNINGS++))
        fi
        ((PASSED++))
    else
        echo -e "  ${YELLOW}!${NC} 에이전트 파일 없음"
        echo -e "    /agent-teams-setup 스킬로 기본 에이전트 생성 권장"
        ((WARNINGS++))
    fi
else
    echo -e "  ${YELLOW}!${NC} 디렉토리 없어 확인 불가"
    ((WARNINGS++))
fi

# 4. Frontmatter 형식 검증
echo ""
echo -e "${BLUE}[4/5] Frontmatter 형식 검증${NC}"
if [[ -d "$AGENTS_DIR" ]]; then
    INVALID_FILES=()

    for file in "$AGENTS_DIR"/*.md; do
        [[ -f "$file" ]] || continue

        # name 필드 확인
        if ! grep -q "^name:" "$file" 2>/dev/null; then
            INVALID_FILES+=("$(basename "$file"): name 필드 없음")
            continue
        fi

        # description 필드 확인
        if ! grep -q "^description:" "$file" 2>/dev/null; then
            INVALID_FILES+=("$(basename "$file"): description 필드 없음")
            continue
        fi

        # model 별칭 확인 (opus, sonnet, haiku만 허용)
        if grep -q "^model:" "$file" 2>/dev/null; then
            MODEL=$(grep "^model:" "$file" | head -1 | sed 's/model:[[:space:]]*//' | tr -d ' ')
            if [[ ! "$MODEL" =~ ^(opus|sonnet|haiku|inherit)$ ]]; then
                INVALID_FILES+=("$(basename "$file"): 잘못된 model ($MODEL)")
            fi
        fi
    done

    if [[ ${#INVALID_FILES[@]} -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} 모든 에이전트 frontmatter 유효"
        ((PASSED++))
    else
        echo -e "  ${YELLOW}!${NC} 일부 에이전트 frontmatter 문제:"
        for issue in "${INVALID_FILES[@]}"; do
            echo -e "    - $issue"
        done
        ((WARNINGS++))
    fi
else
    echo -e "  ${YELLOW}!${NC} 디렉토리 없어 검증 불가"
    ((WARNINGS++))
fi

# 5. tmux 환경 확인 및 teammateMode 추천
echo ""
echo -e "${BLUE}[5/5] tmux 환경 확인${NC}"

TMUX_AVAILABLE=false
ITERM2_AVAILABLE=false
RECOMMENDED_MODE="in-process"

# tmux 설치 확인
if command -v tmux &> /dev/null; then
    TMUX_AVAILABLE=true
    TMUX_VERSION=$(tmux -V 2>/dev/null | head -1)
    echo -e "  ${GREEN}✓${NC} tmux 설치됨 ($TMUX_VERSION)"
else
    echo -e "  ${YELLOW}!${NC} tmux 미설치"
    echo -e "    설치: brew install tmux (macOS) / apt install tmux (Linux)"
fi

# 현재 tmux 세션 내부인지 확인
if [[ -n "$TMUX" ]]; then
    echo -e "  ${GREEN}✓${NC} 현재 tmux 세션 내부"
    RECOMMENDED_MODE="tmux"
fi

# iTerm2 확인 (macOS)
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    ITERM2_AVAILABLE=true
    echo -e "  ${GREEN}✓${NC} iTerm2 감지됨"

    # it2 CLI 확인
    if command -v it2 &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} it2 CLI 설치됨"
        RECOMMENDED_MODE="tmux"
    else
        echo -e "  ${YELLOW}!${NC} it2 CLI 미설치"
        echo -e "    설치: brew install mkusaka/it2/it2"
    fi
fi

# teammateMode 설정 확인
echo ""
echo -e "  ${BLUE}권장 teammateMode:${NC} $RECOMMENDED_MODE"

# settings.json에서 현재 teammateMode 확인
CURRENT_MODE=""
if [[ -f "$GLOBAL_SETTINGS" ]]; then
    CURRENT_MODE=$(grep -o '"teammateMode"[[:space:]]*:[[:space:]]*"[^"]*"' "$GLOBAL_SETTINGS" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
fi

if [[ -n "$CURRENT_MODE" ]]; then
    echo -e "  ${BLUE}현재 설정:${NC} $CURRENT_MODE"
    if [[ "$CURRENT_MODE" == "$RECOMMENDED_MODE" ]] || [[ "$CURRENT_MODE" == "auto" ]]; then
        echo -e "  ${GREEN}✓${NC} 적절한 설정"
    else
        echo -e "  ${YELLOW}!${NC} 권장 설정과 다름"
    fi
else
    echo -e "  ${BLUE}현재 설정:${NC} auto (기본값)"
fi

((PASSED++))

# 결과 요약
echo ""
echo -e "${BLUE}=== 결과 요약 ===${NC}"
echo -e "  ${GREEN}통과:${NC} $PASSED"
echo -e "  ${RED}실패:${NC} $FAILED"
echo -e "  ${YELLOW}경고:${NC} $WARNINGS"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ Agent Teams 사용 가능${NC}"
    exit 0
else
    echo -e "${RED}✗ Agent Teams 사용 불가${NC}"
    echo -e "  위의 실패 항목을 해결해주세요."
    exit 1
fi
