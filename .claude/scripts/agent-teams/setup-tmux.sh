#!/bin/bash
# Agent Teams용 tmux 환경 세팅
# Usage: ${CLAUDE_SCRIPTS_ROOT}/agent-teams/setup-tmux.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Agent Teams tmux 환경 세팅 ===${NC}"
echo ""

# tmux 설치 확인
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}✗ tmux가 설치되어 있지 않습니다.${NC}"
    echo ""
    echo "설치 방법:"
    echo "  macOS: brew install tmux"
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  Fedora: sudo dnf install tmux"
    exit 1
fi

TMUX_VERSION=$(tmux -V 2>/dev/null | head -1)
echo -e "${GREEN}✓${NC} tmux 설치 확인: $TMUX_VERSION"

# iTerm2 확인 및 it2 CLI 설치 안내
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    echo -e "${GREEN}✓${NC} iTerm2 감지됨"

    if ! command -v it2 &> /dev/null; then
        echo -e "${YELLOW}!${NC} it2 CLI 미설치 (split-pane 모드에 필요)"
        echo ""
        echo "설치하시겠습니까? (y/n)"
        read -r answer
        if [[ "$answer" == "y" ]]; then
            if command -v brew &> /dev/null; then
                brew install mkusaka/it2/it2
                echo -e "${GREEN}✓${NC} it2 CLI 설치 완료"
            else
                echo -e "${RED}✗${NC} Homebrew가 필요합니다."
                echo "  설치: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            fi
        fi
    else
        echo -e "${GREEN}✓${NC} it2 CLI 설치됨"
    fi

    echo ""
    echo -e "${BLUE}iTerm2 Python API 활성화 필요:${NC}"
    echo "  iTerm2 → Settings → General → Magic → Enable Python API"
fi

# settings.json에 teammateMode 설정
echo ""
echo -e "${BLUE}teammateMode 설정${NC}"
echo ""
echo "옵션:"
echo "  1. auto (기본값) - tmux 세션 내부면 split-pane, 아니면 in-process"
echo "  2. tmux - 항상 split-pane 모드 (tmux 또는 iTerm2 필요)"
echo "  3. in-process - 항상 in-process 모드"
echo ""
echo "선택 (1/2/3, Enter=auto):"
read -r mode_choice

case "$mode_choice" in
    2)
        TEAMMATE_MODE="tmux"
        ;;
    3)
        TEAMMATE_MODE="in-process"
        ;;
    *)
        TEAMMATE_MODE="auto"
        ;;
esac

# settings.json 업데이트
SETTINGS_FILE="$HOME/.claude/settings.json"

if [[ -f "$SETTINGS_FILE" ]]; then
    # 기존 파일이 있으면 teammateMode 추가/업데이트
    if grep -q '"teammateMode"' "$SETTINGS_FILE"; then
        # 이미 있으면 업데이트
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/\"teammateMode\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"teammateMode\": \"$TEAMMATE_MODE\"/" "$SETTINGS_FILE"
        else
            sed -i "s/\"teammateMode\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"teammateMode\": \"$TEAMMATE_MODE\"/" "$SETTINGS_FILE"
        fi
    else
        # 없으면 추가 (첫 번째 { 뒤에 추가)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/{/{\"teammateMode\": \"$TEAMMATE_MODE\",/" "$SETTINGS_FILE"
        else
            sed -i "s/{/{\"teammateMode\": \"$TEAMMATE_MODE\",/" "$SETTINGS_FILE"
        fi
    fi
    echo -e "${GREEN}✓${NC} ~/.claude/settings.json 업데이트: teammateMode = $TEAMMATE_MODE"
else
    # 파일이 없으면 생성
    mkdir -p "$HOME/.claude"
    echo "{\"teammateMode\": \"$TEAMMATE_MODE\"}" > "$SETTINGS_FILE"
    echo -e "${GREEN}✓${NC} ~/.claude/settings.json 생성: teammateMode = $TEAMMATE_MODE"
fi

# tmux 세션 시작 안내
echo ""
echo -e "${BLUE}=== 세팅 완료 ===${NC}"
echo ""
echo "Agent Teams split-pane 모드 사용법:"
echo ""
echo "  1. tmux 세션 시작:"
echo "     tmux new -s claude"
echo ""
echo "  2. Claude Code 실행:"
echo "     claude"
echo ""
echo "  3. 또는 iTerm2에서:"
echo "     tmux -CC"
echo ""
echo -e "${GREEN}✓ 세팅 완료${NC}"
