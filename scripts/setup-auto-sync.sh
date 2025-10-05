#!/usr/bin/env bash
# Setup automatic agent synchronization

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"
SYNC_SCRIPT="$SCRIPT_DIR/sync-agents.sh"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}⚙️  Setting up auto-sync...${NC}"

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Create systemd user service (Linux)
if command -v systemctl &> /dev/null; then
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"

    # Service file
    cat > "$SYSTEMD_DIR/claude-agents-sync.service" <<EOF
[Unit]
Description=Sync Claude Code Agents
After=network.target

[Service]
Type=oneshot
ExecStart=$SYNC_SCRIPT
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

    # Timer file (every 6 hours)
    cat > "$SYSTEMD_DIR/claude-agents-sync.timer" <<EOF
[Unit]
Description=Sync Claude Code Agents every 6 hours

[Timer]
OnBootSec=5min
OnUnitActiveSec=6h
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable and start
    systemctl --user daemon-reload
    systemctl --user enable claude-agents-sync.timer 2>/dev/null || true
    systemctl --user start claude-agents-sync.timer 2>/dev/null || true

    echo -e "${GREEN}✅ Systemd timer installed (syncs every 6 hours)${NC}"
    echo -e "${YELLOW}   Status: systemctl --user status claude-agents-sync.timer${NC}"

else
    # Fallback to cron
    CRON_LINE="0 */6 * * * $SYNC_SCRIPT >> /tmp/claude-agents-sync.log 2>&1"

    if crontab -l 2>/dev/null | grep -q "claude-agents-sync"; then
        echo -e "${GREEN}✅ Cron job already exists${NC}"
    else
        (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
        echo -e "${GREEN}✅ Cron job installed (syncs every 6 hours)${NC}"
    fi
fi

# Create manual sync command
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/sync-agents" <<EOF
#!/bin/bash
$SYNC_SCRIPT
EOF
chmod +x "$BIN_DIR/sync-agents"

# Create watch command
cat > "$BIN_DIR/watch-agents" <<EOF
#!/bin/bash
$SCRIPT_DIR/watch-agents.sh
EOF
chmod +x "$BIN_DIR/watch-agents"

# Create status command
cat > "$BIN_DIR/agents-status" <<EOF
#!/bin/bash
$SCRIPT_DIR/status.sh
EOF
chmod +x "$BIN_DIR/agents-status"

echo -e "${GREEN}✅ Global commands installed:${NC}"
echo -e "   ${YELLOW}sync-agents${NC}    - Manual sync"
echo -e "   ${YELLOW}watch-agents${NC}   - Live file watcher"
echo -e "   ${YELLOW}agents-status${NC}  - Show installation status"
