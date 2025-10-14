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

## 🚧 Roadmap - Planned Improvements

### **Current Limitations**

The current implementation has several gaps that prevent full Claude Code integration:

❌ **Agents aren't auto-created** - Markdown files exist but aren't registered with Claude Code
❌ **Claude Code doesn't see agents** - The `--agents` flag requires JSON format, not markdown files
❌ **No validation system** - Can't verify if agents actually load correctly
❌ **No per-project support** - Agents not available in project-specific `.claude/` directories
❌ **Manual rebuild required** - Must run `sync-agents` after every edit

### **Phase 1: Agent Auto-Creation** (Critical)

**Goal**: Convert markdown agent definitions into executable Claude Code wrappers

**New Scripts**:
- `scripts/build-agents.sh` - Parse MD frontmatter and generate Claude Code wrapper scripts
- `scripts/validate-agents.sh` - Test that each agent loads and works correctly

**What This Enables**:
```bash
# After install, agents become directly invokable:
architectural-orchestrator "Review my code"
codebase-complexity-analyzer "Find over-engineering"

# Claude Code can use agents via:
claude --agents @~/.config/claude/agents.json
```

**Implementation Details**:
1. Parse agent markdown frontmatter (name, description, tools, model)
2. Generate executable wrapper script for each agent
3. Deploy to `~/.local/bin/agents/`
4. Register with Claude Code configuration
5. Validate each agent loads successfully

### **Phase 2: Claude Code Integration**

**Goal**: Make agents natively available to Claude Code system-wide

**New Components**:

1. **Global Agent Registry** (`~/.config/claude/agents.json`)
   - Central registry of all available agents
   - Maps agent names to executable wrappers
   - Tracks source locations and metadata

2. **Executable Agent Wrappers** (`~/.local/bin/agents/`)
   - Each agent gets standalone executable
   - Invokes Claude Code with proper configuration
   - Includes full agent prompt from markdown

3. **Per-Project Linking** (`.claude/agents/`)
   - Projects can opt-in to specific agents
   - Symlink agents needed for that project
   - Keeps project-specific agent configurations

**Enhanced Directory Structure**:
```
001-agents-manager/
├── agents/                          # Source markdown files
├── scripts/
│   ├── build-agents.sh             # NEW: Build Claude wrappers
│   ├── validate-agents.sh          # NEW: Validate registration
│   ├── link-agents.sh              # NEW: Per-project linking
│   ├── doctor.sh                   # NEW: Health diagnostics
│   └── uninstall.sh                # NEW: Clean removal
├── templates/
│   ├── agent-wrapper.sh.template   # NEW: Wrapper template
│   └── agent-config.json.template  # NEW: Config template
├── .agents-cache/                  # NEW: Build artifacts
└── tests/                          # NEW: Validation tests

System-wide deployment:
~/.local/bin/agents/                # NEW: Executable wrappers
~/.config/claude/agents.json        # NEW: Claude config
~/.claude/agents/                   # Existing: Reference symlinks
```

### **Phase 3: Sync & Validation Enhancements**

**Goal**: Ensure agents stay in sync and work correctly across all machines

**Improvements**:

1. **Incremental Builds**
   - Only rebuild changed agents (faster sync)
   - Detect new/modified/deleted agents
   - Track build state in `.agents-cache/`

2. **Validation System**
   - Test each agent loads successfully
   - Verify Claude Code can invoke them
   - Check agent prompts parse correctly
   - Report broken agents with actionable fixes

3. **Conflict Resolution**
   - Detect when multiple machines modify same agent
   - Show diff and allow choosing version
   - Prevent accidental overwrites

4. **Health Checks**
   - `agents-doctor` command for diagnostics
   - Verify all dependencies present
   - Check Claude Code version compatibility
   - Report system-wide agent health

### **Phase 4: Per-Project Agent Support**

**Goal**: Allow projects to use specific agents without global installation

**New Command**: `agents-link`

```bash
# In any project:
cd ~/my-project

# Link specific agents to this project
agents-link architectural-orchestrator codebase-complexity-analyzer

# Link all available agents
agents-link --all

# List linked agents
agents-link --list

# Unlink agents
agents-link --remove architectural-orchestrator
```

**What This Creates**:
```
my-project/
├── .claude/
│   └── agents/
│       ├── architectural-orchestrator -> ~/.local/bin/agents/architectural-orchestrator
│       └── codebase-complexity-analyzer -> ~/.local/bin/agents/codebase-complexity-analyzer
└── ...
```

### **Implementation Priority**

| Phase | Priority | Status | Target |
|-------|----------|--------|--------|
| Agent Auto-Creation | 🔴 Critical | Planned | v2.0 |
| Claude Code Integration | 🔴 Critical | Planned | v2.0 |
| Validation System | 🟡 High | Planned | v2.1 |
| Incremental Builds | 🟡 High | Planned | v2.1 |
| Per-Project Linking | 🟢 Medium | Planned | v2.2 |
| Health Diagnostics | 🟢 Medium | Planned | v2.2 |
| Conflict Resolution | 🟢 Low | Planned | v2.3 |

### **Expected Workflow After Improvements**

**Initial Install**:
```bash
cd ~/Apps
git clone https://github.com/kairin/001-agents-manager
cd 001-agents-manager
./scripts/install.sh

# Now automatically:
# ✅ Builds Claude Code wrapper scripts
# ✅ Registers agents with Claude Code
# ✅ Validates all agents load correctly
# ✅ Creates executable commands
# ✅ Sets up auto-sync
```

**Daily Usage**:
```bash
# Edit agent
vim ~/Apps/001-agents-manager/agents/5-meta-agents/my-agent.md

# Auto-rebuild happens via file watcher
# OR manually trigger:
sync-agents  # Now validates and reports what changed

# Use agent anywhere
architectural-orchestrator "Review this implementation"

# Or in Claude Code:
claude  # Agents automatically available
```

**Per-Project Usage**:
```bash
cd ~/my-project
agents-link architectural-orchestrator

# Agent now available for this project only
claude  # Can invoke agent in project context
```

### **Success Metrics**

After all improvements are implemented:

✅ **100% auto-creation** - All agents built on install, no manual steps
✅ **100% validation** - Every agent tested and confirmed working
✅ **Zero manual rebuilds** - File watcher auto-rebuilds on changes
✅ **Full Claude Code integration** - Agents natively available
✅ **Per-project flexibility** - Use agents globally or per-project
✅ **Cross-machine consistency** - Same agents everywhere, validated

---

## 🤝 Contributing

1. Edit agents in `~/Apps/001-agents-manager/agents/`
2. Test locally with `watch-agents`
3. Commit changes: `git commit -m "feat: description"`
4. Push: `git push`
5. Other machines will auto-sync within 6 hours
