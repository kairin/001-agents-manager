# 001 Agents Manager

Universal Claude Code agents management system with automatic synchronization across all your machines.

## 🎯 Purpose

This repository manages all Claude Code subagents system-wide, allowing you to:
- Edit agents in one central location (`~/Apps/001-agents-manager`)
- Automatically sync changes across all your machines
- Keep agents available system-wide for Claude Code (`~/.claude/agents`)
- Version control all agent definitions via Git

## 🏗️ Architecture

```
~/Apps/001-agents-manager/          ← Your Git repo (edit here)
├── agents/                         ← Agent definitions
│   ├── 1-product/
│   ├── 2-engineering/
│   ├── 3-operations/
│   ├── 4-thinktank/
│   ├── 5-meta-agents/
│   └── 6-specialized/
└── scripts/                        ← Management tools

~/.claude/agents/                   ← System-wide (symlinked)
├── 1-product -> ~/Apps/.../1-product
├── 2-engineering -> ~/Apps/.../2-engineering
└── ...

~/.config/mcp-manager/
└── claude-agents.json              ← Auto-generated registry
```

## 🚀 Quick Start

### Initial Setup (Any New Machine)

```bash
# 1. Clone this repo
cd ~/Apps
git clone https://github.com/kairin/001-agents-manager

# 2. Run installer
cd 001-agents-manager
./scripts/install.sh
```

That's it! Agents are now available system-wide.

## 📝 Daily Usage

### Edit Agents

```bash
# Edit any agent in ~/Apps/001-agents-manager/agents/
cd ~/Apps/001-agents-manager/agents
vim 4-thinktank/1-analytical/101-thinktank-first-principles-guardian.md

# Changes are immediately available via symlinks
# But rebuild registry for Claude Code to see updates:
sync-agents
```

### Live Development

```bash
# Auto-rebuild registry on file changes
watch-agents
```

### Check Status

```bash
# View installation status
agents-status
```

### Sync Across Machines

```bash
# Machine 1: Commit and push changes
cd ~/Apps/001-agents-manager
git add agents/
git commit -m "feat: updated first principles agent"
git push

# Machine 2: Syncs automatically every 6 hours
# Or manually:
sync-agents
```

## 🛠️ Available Commands

After installation, these commands are available globally:

- **`sync-agents`** - Pull latest changes and rebuild registry
- **`watch-agents`** - Watch for file changes and auto-rebuild
- **`agents-status`** - Show installation status and statistics

## 📊 Agent Categories

- **1-product/** - Product management and design agents
- **2-engineering/** - Software engineering and architecture agents
- **3-operations/** - Operations, security, and infrastructure agents
- **4-thinktank/** - Creative problem-solving and analytical agents
- **5-meta-agents/** - Orchestration and complexity management agents
- **6-specialized/** - Project-specific specialized agents

## 🔄 How It Works

1. **Source Location**: Agents live in `~/Apps/001-agents-manager/agents/`
2. **System Symlinks**: Symlinked to `~/.claude/agents/` for Claude Code
3. **Registry Build**: Scripts scan agents and build JSON registry
4. **Auto Sync**: Systemd timer or cron pulls changes every 6 hours
5. **Git Sync**: Changes committed here sync to all machines

## 📁 Directory Structure

```
001-agents-manager/
├── agents/                     # Agent definitions (EDIT HERE)
│   ├── 1-product/
│   ├── 2-engineering/
│   ├── 3-operations/
│   ├── 4-thinktank/
│   ├── 5-meta-agents/
│   └── 6-specialized/
├── scripts/                    # Management scripts
│   ├── install.sh             # Initial setup
│   ├── build-registry.sh      # Build JSON registry
│   ├── sync-agents.sh         # Git pull & rebuild
│   ├── setup-auto-sync.sh     # Configure auto-sync
│   ├── watch-agents.sh        # File watcher
│   └── status.sh              # Status checker
├── docs/                       # Documentation
└── README.md                   # This file
```

## 🔧 Troubleshooting

### Agents not showing in Claude Code
```bash
# Rebuild the registry
sync-agents
```

### Symlinks broken
```bash
# Reinstall
./scripts/install.sh
```

### Auto-sync not working
```bash
# Check status
systemctl --user status claude-agents-sync.timer
# Or for cron:
crontab -l | grep claude-agents
```

## 📄 License

MIT

## 🤝 Contributing

1. Edit agents in `~/Apps/001-agents-manager/agents/`
2. Test locally with `watch-agents`
3. Commit changes: `git commit -m "feat: description"`
4. Push: `git push`
5. Other machines will auto-sync within 6 hours
