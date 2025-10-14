# Changelog

All notable changes to the 001 Agents Manager project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2025-10-05

### Added

**Initial Release** - Universal Claude Code agents management system

- ✅ Consolidated 104 agent files from 3 source repositories into unified structure
- ✅ Created dual-location architecture (source in `~/Apps`, system-wide in `~/.claude/agents/`)
- ✅ Implemented directory-level symlinks for immediate file availability
- ✅ Built automatic JSON registry generation from markdown frontmatter
- ✅ Created 6 management scripts for installation, sync, watch, and status
- ✅ Set up Git-based version control with remote repository
- ✅ Configured automatic synchronization via systemd timer (every 6 hours)
- ✅ Deployed global commands: `sync-agents`, `watch-agents`, `agents-status`
- ✅ Created comprehensive documentation (README, SETUP-COMPLETE)

**Agent Categories**:
- 1-product: 11 agents
- 2-engineering: 21 agents
- 3-operations: 15 agents
- 4-thinktank: 9 agents
- 5-meta-agents: 3 agents
- 6-specialized: 45 agents

**Scripts Included**:
- `install.sh` - One-time system-wide installation
- `build-registry.sh` - Build JSON registry from agent markdown files
- `sync-agents.sh` - Git pull and rebuild registry
- `setup-auto-sync.sh` - Configure automatic synchronization
- `watch-agents.sh` - Live file watcher for development
- `status.sh` - Display comprehensive installation status

### Fixed

- Fixed `xargs` quote handling in `build-registry.sh` by replacing with `sed`
- Ensured proper whitespace trimming in agent metadata extraction

### Known Limitations

- Agents are markdown files, not registered with Claude Code executable format
- Claude Code `--agents` flag requires JSON format, current implementation doesn't support this
- No validation system to verify agents load correctly
- No per-project agent support
- Manual rebuild required after editing agents (unless using watch mode)

---

## [2.0.0] - Planned (Phase 1 & 2)

### Planned - Agent Auto-Creation & Claude Code Integration 🔴 **Critical Priority**

**Phase 1: Agent Auto-Creation**

- [ ] Create `scripts/build-agents.sh` - Parse markdown frontmatter and generate Claude Code wrapper scripts
- [ ] Create `scripts/validate-agents.sh` - Test that each agent loads and works correctly
- [ ] Deploy executable wrappers to `~/.local/bin/agents/`
- [ ] Enable direct agent invocation: `architectural-orchestrator "Review my code"`

**Phase 2: Claude Code Integration**

- [ ] Build global agent registry (`~/.config/claude/agents.json`)
- [ ] Create executable agent wrappers for each agent
- [ ] Register agents with Claude Code configuration
- [ ] Validate all agents load successfully during install
- [ ] Make agents natively available to Claude Code via `--agents` flag

**What This Enables**:
- ✅ 100% auto-creation - All agents built on install, no manual steps
- ✅ Direct invocation - Use agents as standalone commands
- ✅ Claude Code native support - Agents available via `claude` command
- ✅ Validation on install - Confirm all agents work before deployment

**New Files**:
- `scripts/build-agents.sh` - Agent wrapper generator
- `scripts/validate-agents.sh` - Agent validation system
- `templates/agent-wrapper.sh.template` - Wrapper script template
- `templates/agent-config.json.template` - Agent config template
- `.agents-cache/` - Build artifacts and state tracking

---

## [2.1.0] - Planned (Phase 3)

### Planned - Sync & Validation Enhancements 🟡 **High Priority**

**Incremental Builds**

- [ ] Only rebuild changed agents (faster sync)
- [ ] Detect new/modified/deleted agents
- [ ] Track build state in `.agents-cache/`
- [ ] Skip unchanged agents during rebuild

**Validation System**

- [ ] Test each agent loads successfully
- [ ] Verify Claude Code can invoke agents
- [ ] Check agent prompts parse correctly
- [ ] Report broken agents with actionable fixes

**Conflict Resolution**

- [ ] Detect when multiple machines modify same agent
- [ ] Show diff and allow choosing version
- [ ] Prevent accidental overwrites
- [ ] Provide merge assistance for concurrent edits

**Health Checks**

- [ ] Create `scripts/doctor.sh` for diagnostics
- [ ] Verify all dependencies present
- [ ] Check Claude Code version compatibility
- [ ] Report system-wide agent health
- [ ] Add `agents-doctor` global command

**What This Enables**:
- ✅ Faster synchronization - Only rebuild what changed
- ✅ 100% validation - Every agent tested and confirmed working
- ✅ Safe multi-machine workflow - Conflict detection and resolution
- ✅ Self-diagnostics - Health checks before deployment

**New Files**:
- `scripts/doctor.sh` - System diagnostics
- `tests/` - Validation test suite
- `.agents-cache/build-state.json` - Incremental build tracking

---

## [2.2.0] - Planned (Phase 4)

### Planned - Per-Project Agent Support 🟢 **Medium Priority**

**Per-Project Linking**

- [ ] Create `scripts/link-agents.sh` - Link agents to specific projects
- [ ] Support selective agent deployment per project
- [ ] Enable project-specific agent configurations
- [ ] Add `agents-link` global command

**New Command: `agents-link`**

```bash
# Link specific agents to current project
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

**What This Enables**:
- ✅ Per-project flexibility - Use agents globally or per-project
- ✅ Selective deployment - Only include needed agents
- ✅ Project-specific configs - Customize agents per project
- ✅ Clean separation - Global vs. project-specific agents

**New Files**:
- `scripts/link-agents.sh` - Per-project linking utility

---

## [2.3.0] - Planned (Additional Enhancements)

### Planned - Quality of Life Improvements 🟢 **Low Priority**

**Enhanced Tooling**

- [ ] Create `scripts/uninstall.sh` - Clean removal of all components
- [ ] Improve error messages with actionable suggestions
- [ ] Add progress indicators for long operations
- [ ] Support custom agent categories

**Developer Experience**

- [ ] Auto-detection of Claude Code installation
- [ ] Interactive mode for `agents-link` (select from menu)
- [ ] Colorized output for better readability
- [ ] Detailed logging with debug mode

**Documentation**

- [ ] Add troubleshooting guide with common issues
- [ ] Create agent development guide
- [ ] Document best practices for multi-machine workflows
- [ ] Add examples for custom agent creation

**New Files**:
- `scripts/uninstall.sh` - Clean uninstaller
- `docs/troubleshooting.md` - Common issues and solutions
- `docs/development.md` - Agent development guide
- `docs/examples/` - Example agents and workflows

---

## Success Metrics (Post-Improvements)

After all planned improvements are implemented:

- ✅ **100% auto-creation** - All agents built on install, no manual steps
- ✅ **100% validation** - Every agent tested and confirmed working
- ✅ **Zero manual rebuilds** - File watcher auto-rebuilds on changes
- ✅ **Full Claude Code integration** - Agents natively available
- ✅ **Per-project flexibility** - Use agents globally or per-project
- ✅ **Cross-machine consistency** - Same agents everywhere, validated

---

## Implementation Timeline

| Version | Status | Target | Priority |
|---------|--------|--------|----------|
| 1.0.0 | ✅ Released | 2025-10-05 | - |
| 2.0.0 | 📋 Planned | TBD | 🔴 Critical |
| 2.1.0 | 📋 Planned | TBD | 🟡 High |
| 2.2.0 | 📋 Planned | TBD | 🟢 Medium |
| 2.3.0 | 📋 Planned | TBD | 🟢 Low |

---

## Repository

- **GitHub**: https://github.com/kairin/001-agents-manager
- **Documentation**: See README.md for complete usage guide
- **Issues**: Report bugs and feature requests on GitHub

---

[1.0.0]: https://github.com/kairin/001-agents-manager/releases/tag/v1.0.0
