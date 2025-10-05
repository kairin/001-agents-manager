#!/usr/bin/env bash
# Watch agent files and auto-rebuild registry on changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$APP_ROOT/agents"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}👁️  Watching agent files for changes...${NC}"
echo -e "${YELLOW}📂 Directory: $AGENTS_DIR${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Check if inotify-tools is available
if ! command -v inotifywait &> /dev/null; then
    echo -e "${YELLOW}⚠️  inotify-tools not found. Install with:${NC}"
    echo "   sudo apt install inotify-tools"
    echo ""
    echo "Falling back to polling mode (checks every 3 seconds)..."
    echo ""

    # Fallback: polling mode
    LAST_HASH=""
    while true; do
        CURRENT_HASH=$(find "$AGENTS_DIR" -name "*.md" -type f -exec md5sum {} \; | md5sum)
        if [ "$CURRENT_HASH" != "$LAST_HASH" ] && [ -n "$LAST_HASH" ]; then
            echo -e "${GREEN}🔄 Changes detected, rebuilding registry...${NC}"
            "$SCRIPT_DIR/build-registry.sh"
            echo ""
        fi
        LAST_HASH="$CURRENT_HASH"
        sleep 3
    done
else
    # Use inotifywait for real-time monitoring
    inotifywait -m -r -e modify,create,delete,move "$AGENTS_DIR" \
        --format '%w%f %e' \
        --exclude '\.git|\.swp|~$|\.tmp' |
    while read -r file event; do
        if [[ "$file" == *.md ]]; then
            echo -e "${GREEN}🔄 Change detected: $(basename $file) ($event)${NC}"
            "$SCRIPT_DIR/build-registry.sh"
            echo ""
        fi
    done
fi
