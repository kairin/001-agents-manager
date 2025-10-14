# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

This repository, "001-agents-manager," is a universal agent management system that maintains agent definitions in `~/Apps/001-agents-manager` and synchronizes them system-wide to `~/.claude/agents/` via symlinks. Changes are version-controlled via Git and auto-sync across machines.

The core of the project is a directory of Markdown files, where each file represents a specific AI agent. These files define the agent's name, description, tools, and personality. A set of shell scripts is used to manage these agents, including installing them system-wide, building a registry of available agents, and keeping them synchronized.

### Directory Structure

```
~/Apps/001-agents-manager/          ← Source (edit here)
├── agents/                         ← Agent markdown definitions
│   ├── 1-product/                 ← Product management & design
│   ├── 2-engineering/             ← Engineering (CTO, dev, QA, DevOps)
│   ├── 3-operations/              ← Security, data, IT, compliance
│   ├── 4-thinktank/               ← Problem-solving agents
│   ├── 5-meta-agents/             ← Orchestration & analysis
│   └── 6-specialized/             ← Project-specific agents
└── scripts/                        ← Management tools

~/.claude/agents/                   ← System-wide (symlinked)
~/.config/mcp-manager/
└── claude-agents.json              ← Auto-generated registry
```

## Build and Test Commands

### Build & Sync
```bash
# Rebuild agent registry from markdown files
./scripts/build-registry.sh

# Pull latest changes and rebuild registry
./scripts/sync-agents.sh
# Or use global command after install:
sync-agents

# Watch for changes and auto-rebuild
./scripts/watch-agents.sh
# Or:
watch-agents
```

### Installation & Status
```bash
# Install agents system-wide (creates symlinks, registry, auto-sync)
./scripts/install.sh

# Check installation status, agent counts, git status
./scripts/status.sh
# Or:
agents-status
```

## Code Style and Conventions

### Agent Definition Format

Agent markdown files use YAML frontmatter:
```yaml
---
name: agent-name
description: When and how to use this agent
tools: Glob, Grep, Read, Bash
model: opus|sonnet|haiku
---
```

### Key Architectural Patterns

**Symlink-Based Distribution**: Source agents live in `~/Apps/001-agents-manager/agents/`, symlinked to `~/.claude/agents/` for system-wide access. Edits in source are immediately visible via symlinks.

**Registry Generation**: `build-registry.sh` scans all `.md` files in `agents/`, extracts frontmatter, and generates `~/.config/mcp-manager/claude-agents.json` with metadata for each agent.

**Auto-Sync System**: `setup-auto-sync.sh` creates systemd timer (or cron job) that runs `sync-agents.sh` every 6 hours to pull Git changes and rebuild registry.

**Hierarchical Organization**: Agents organized by department (1-6) and specialization subdirectories. Numbering indicates hierarchy (e.g., 000-master-orchestrator, 001-development-orchestrator).

## Development Workflow

### Adding/Editing Agents
1. Edit files in `~/Apps/001-agents-manager/agents/`
2. Changes are immediately visible via symlinks
3. Rebuild registry: `sync-agents` or `watch-agents` (auto-rebuild)
4. Commit and push to sync across machines

### Git Workflow
```bash
# After editing agents
cd ~/Apps/001-agents-manager
git add agents/
git commit -m "feat: updated agent descriptions"
git push

# Other machines auto-sync every 6 hours
# Or manually: sync-agents
```

## Agent Categories

- **1-product**: Product leadership, strategy, ownership, UX research, UI design
- **2-engineering**: CTO office, architecture, backend/frontend/mobile dev, QA, DevOps
- **3-operations**: COO office, security ops, data ops, IT ops, compliance
- **4-thinktank**: Analytical, creative, human-centered, unconventional problem-solving
- **5-meta-agents**: `architectural-orchestrator`, `codebase-complexity-analyzer`, `minimal-todo-fixer`
- **6-specialized**: Project-specific agents (e.g., kyocera-project with 4-layer hierarchy)

## Important Constraints

**Location Validation**: Installer validates repo is in `~/Apps/` directory before proceeding.

**Frontmatter Required**: Agents without `name:` field are skipped during registry build.

**Git Stashing**: `sync-agents.sh` stashes local changes before pull, then restores them to prevent data loss.

**Symlink Management**: Installer removes old symlinks/directories in `~/.claude/agents/` before creating new ones to prevent conflicts.

## Script Dependencies

- `jq` - JSON processing for registry generation
- `inotify-tools` (optional) - File watching for `watch-agents.sh` (falls back to polling)
- `systemd` or `cron` - Auto-sync scheduling
- `git` - Version control and cross-machine sync
