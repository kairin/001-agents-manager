#!/usr/bin/env bash
# Claude Code Agents Manager - System-Wide Installer
# This script installs agents system-wide while keeping source in ~/Apps

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Detect script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"
APP_NAME="$(basename "$APP_ROOT")"

# System-wide locations
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
MCP_CONFIG_DIR="$HOME/.config/mcp-manager"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/claude-agents.json"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Agents Manager Installer ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📂 App Location: $APP_ROOT${NC}"
echo -e "${YELLOW}🔗 Install Target: $CLAUDE_AGENTS_DIR${NC}"
echo ""

# Validate we're in ~/Apps
if [[ ! "$APP_ROOT" =~ ^$HOME/Apps/ ]]; then
    echo -e "${RED}❌ Error: This app must reside in ~/Apps/${NC}"
    echo -e "Current location: $APP_ROOT"
    exit 1
fi

# Check if agents directory exists
if [ ! -d "$APP_ROOT/agents" ]; then
    echo -e "${RED}❌ Error: agents/ directory not found in $APP_ROOT${NC}"
    exit 1
fi

# Create system-wide directories
echo -e "${GREEN}📁 Creating system-wide directories...${NC}"
mkdir -p "$CLAUDE_AGENTS_DIR"
mkdir -p "$MCP_CONFIG_DIR"

# Remove old symlinks/directories
echo -e "${GREEN}🧹 Cleaning old installations...${NC}"
if [ -d "$CLAUDE_AGENTS_DIR" ]; then
    find "$CLAUDE_AGENTS_DIR" -maxdepth 1 -type l -delete 2>/dev/null || true
    find "$CLAUDE_AGENTS_DIR" -maxdepth 1 -type d ! -path "$CLAUDE_AGENTS_DIR" -exec rm -rf {} + 2>/dev/null || true
fi

# Create symlinks from ~/.claude/agents/ to ~/Apps/001-agents-manager/agents/
echo -e "${GREEN}🔗 Creating symlinks to system-wide location...${NC}"
for agent_dir in "$APP_ROOT/agents"/*; do
    if [ -d "$agent_dir" ]; then
        dir_name="$(basename "$agent_dir")"
        ln -sf "$agent_dir" "$CLAUDE_AGENTS_DIR/$dir_name"
        echo -e "  ${GREEN}✓${NC} Linked: $dir_name"
    fi
done

# Build agent registry
echo -e "${GREEN}📋 Building agent registry...${NC}"
"$SCRIPT_DIR/build-registry.sh"

# Install sync mechanism
echo -e "${GREEN}⚙️  Installing auto-sync...${NC}"
"$SCRIPT_DIR/setup-auto-sync.sh"

# Summary
AGENT_COUNT=$(find "$APP_ROOT/agents" -name "*.md" -type f | wc -l)
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ Installation Complete!         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Statistics:${NC}"
echo -e "   Agents installed: ${GREEN}$AGENT_COUNT${NC}"
echo ""
echo -e "${BLUE}📂 Locations:${NC}"
echo -e "   Source: ${YELLOW}$APP_ROOT/agents/${NC}"
echo -e "   System: ${YELLOW}$CLAUDE_AGENTS_DIR/${NC}"
echo -e "   Config: ${YELLOW}$MCP_CONFIG_FILE${NC}"
echo ""
echo -e "${BLUE}📝 Next steps:${NC}"
echo -e "   1. Edit agents in: ${YELLOW}$APP_ROOT/agents/${NC}"
echo -e "   2. Changes sync automatically via symlinks"
echo -e "   3. Run ${GREEN}sync-agents${NC} to rebuild registry"
echo -e "   4. Run ${GREEN}watch-agents${NC} for live development"
echo ""
