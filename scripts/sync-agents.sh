#!/usr/bin/env bash
# Sync agents with Git repository and rebuild registry

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔄 Syncing Claude Code Agents...${NC}"

# Check if git repo
if [ ! -d "$APP_ROOT/.git" ]; then
    echo -e "${YELLOW}⚠️  Not a git repository, skipping pull${NC}"
else
    cd "$APP_ROOT"

    # Store local changes
    STASHED=false
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${YELLOW}📝 Stashing local changes...${NC}"
        git stash
        STASHED=true
    fi

    # Pull latest
    echo "⬇️  Pulling latest changes..."
    BEFORE=$(git rev-parse HEAD 2>/dev/null || echo "none")
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || echo "Pull failed or no remote"
    AFTER=$(git rev-parse HEAD 2>/dev/null || echo "none")

    # Restore local changes
    if [ "$STASHED" = true ]; then
        echo -e "${YELLOW}📝 Restoring local changes...${NC}"
        git stash pop
    fi

    if [ "$BEFORE" != "$AFTER" ]; then
        echo -e "${GREEN}✅ Updated to latest version${NC}"
    else
        echo -e "${GREEN}✅ Already up to date${NC}"
    fi
fi

# Rebuild registry
echo "📋 Rebuilding registry..."
"$SCRIPT_DIR/build-registry.sh"

echo -e "${GREEN}✅ Sync complete!${NC}"
