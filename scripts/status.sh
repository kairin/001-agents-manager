#!/usr/bin/env bash
# Show status of Claude Code Agents installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$HOME/.claude/agents"
MCP_CONFIG="$HOME/.config/mcp-manager/claude-agents.json"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Agents Manager Status    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# App location
echo -e "${BLUE}📂 App Location:${NC}"
echo -e "   $APP_ROOT"
echo ""

# System location
echo -e "${BLUE}🔗 System Location:${NC}"
if [ -d "$CLAUDE_DIR" ]; then
    SYMLINK_COUNT=$(find "$CLAUDE_DIR" -maxdepth 1 -type l 2>/dev/null | wc -l)
    echo -e "   $CLAUDE_DIR ${GREEN}($SYMLINK_COUNT symlinks)${NC}"
else
    echo -e "   ${RED}❌ Not installed${NC}"
fi
echo ""

# Agent count
if [ -f "$MCP_CONFIG" ]; then
    AGENT_COUNT=$(jq '.agent_count // (.agents | length)' "$MCP_CONFIG" 2>/dev/null || echo "0")
    LAST_UPDATE=$(jq -r '.last_updated' "$MCP_CONFIG" 2>/dev/null || echo "Unknown")
    echo -e "${BLUE}📋 Registry:${NC}"
    echo -e "   Agents: ${GREEN}$AGENT_COUNT${NC}"
    echo -e "   Updated: ${YELLOW}$LAST_UPDATE${NC}"
    echo -e "   Location: $MCP_CONFIG"
else
    echo -e "${BLUE}📋 Registry:${NC} ${RED}❌ Not found${NC}"
fi
echo ""

# Git status
if [ -d "$APP_ROOT/.git" ]; then
    cd "$APP_ROOT"
    echo -e "${BLUE}🔀 Git Status:${NC}"
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    echo -e "   Branch: ${YELLOW}$BRANCH${NC}"
    echo -e "   Commit: ${YELLOW}$COMMIT${NC}"

    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "   Status: ${YELLOW}⚠️  Uncommitted changes${NC}"
    else
        echo -e "   Status: ${GREEN}✅ Clean${NC}"
    fi

    # Check for remote
    if git remote get-url origin &>/dev/null; then
        REMOTE=$(git remote get-url origin)
        echo -e "   Remote: ${BLUE}$REMOTE${NC}"
    else
        echo -e "   Remote: ${YELLOW}⚠️  No remote configured${NC}"
    fi
else
    echo -e "${BLUE}🔀 Git:${NC} ${YELLOW}Not a repository${NC}"
fi
echo ""

# Auto-sync status
echo -e "${BLUE}⚙️  Auto-sync:${NC}"
if systemctl --user is-active claude-agents-sync.timer &>/dev/null; then
    NEXT_RUN=$(systemctl --user show claude-agents-sync.timer --property=NextElapseUSecRealtime --value 2>/dev/null | cut -d' ' -f1-2)
    echo -e "   ${GREEN}✅ Enabled (systemd)${NC}"
    echo -e "   Next run: ${YELLOW}$NEXT_RUN${NC}"
elif crontab -l 2>/dev/null | grep -q "claude-agents-sync"; then
    echo -e "   ${GREEN}✅ Enabled (cron)${NC}"
else
    echo -e "   ${RED}❌ Not configured${NC}"
fi
echo ""

# Agent categories
echo -e "${BLUE}📊 Agent Categories:${NC}"
for category_dir in "$APP_ROOT/agents"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        count=$(find "$category_dir" -name "*.md" -type f 2>/dev/null | wc -l)
        echo -e "   ${YELLOW}$category${NC}: $count agents"
    fi
done
echo ""
