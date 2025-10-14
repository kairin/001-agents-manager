<!--
SYNC IMPACT REPORT
Version: 0.0.0 → 1.0.0
Modified Principles: Initial creation - all principles are new
Added Sections: All sections (initial constitution)
Removed Sections: None
Templates Status:
  ✅ plan-template.md - Constitution Check section aligns with principles
  ✅ spec-template.md - No constitution-specific constraints needed at spec phase
  ✅ tasks-template.md - Task categorization reflects automation and validation principles
  ✅ agent-file-template.md - Generic template, no agent-specific references
  ✅ Command files - Checked for agent-specific references (generic guidance preserved)
Follow-up TODOs: None - all placeholders filled
-->

# Agents Manager Constitution

## Core Principles

### I. Single Source of Truth
Agent definitions MUST reside exclusively in `~/Apps/001-agents-manager/agents/`. All system-wide
access occurs via symlinks to this canonical location. Direct editing of symlinked locations is
PROHIBITED to maintain version control integrity.

**Rationale**: Centralizing agent definitions ensures consistency, enables Git-based versioning,
and prevents synchronization conflicts across machines.

### II. Git-Driven Synchronization
All agent changes MUST be version-controlled via Git. Cross-machine synchronization MUST occur
through Git pull operations, never manual file copying. Local changes MUST be stashed before sync
to prevent data loss.

**Rationale**: Git provides auditable change history, conflict resolution, and reliable
distribution mechanism across development environments.

### III. Registry Validation
Every agent MUST have valid YAML frontmatter with a `name` field. The system MUST auto-generate
`~/.config/mcp-manager/claude-agents.json` from agent metadata. Agents without valid frontmatter
MUST be skipped with logged warnings.

**Rationale**: Registry validation ensures Claude Code can discover and invoke agents correctly,
preventing runtime failures from malformed definitions.

### IV. Automation-First
Manual intervention MUST be minimized through automated processes:
- File watchers MUST auto-rebuild registry on agent changes
- Systemd timers or cron MUST sync changes every 6 hours
- Installer MUST handle all setup (symlinks, registry, auto-sync) in one command

**Rationale**: Automation reduces human error, ensures consistency, and improves developer
experience by eliminating repetitive tasks.

### V. Hierarchical Organization
Agents MUST be organized in numbered department directories (1-product, 2-engineering,
3-operations, 4-thinktank, 5-meta-agents, 6-specialized). Numeric prefixes in agent names MUST
indicate hierarchy (e.g., 000-master-orchestrator, 001-development-orchestrator).

**Rationale**: Structured organization enables scalable agent management, clear responsibility
boundaries, and intuitive discovery as the agent library grows.

## Development Workflow

### Location Validation
The repository MUST reside in `~/Apps/` directory. Installer MUST validate location before
proceeding. Symlinks MUST target `~/.claude/agents/` for system-wide availability.

**Enforcement**: Installer checks repo path against `~/Apps/` prefix and exits with error if
validation fails.

### Change Propagation
Agent edits MUST trigger registry rebuild via `sync-agents` command or file watcher. Changes MUST
NOT require manual registry updates. The system MUST preserve manual additions between designated
markers in generated files.

**Enforcement**: `build-registry.sh` scans all `.md` files, extracts frontmatter, and regenerates
JSON registry atomically.

### Conflict Prevention
The installer MUST remove existing symlinks/directories in `~/.claude/agents/` before creating new
ones. Git sync MUST stash local changes before pull, then restore them after successful pull.

**Enforcement**: `install.sh` performs cleanup, `sync-agents.sh` implements stash/pull/pop workflow.

## Quality Standards

### Agent Definition Requirements
Every agent markdown file MUST contain:
- YAML frontmatter with `name`, `description`, `tools`, and `model` fields
- Clear description of when and how to use the agent
- Explicit tool list (e.g., `Glob, Grep, Read, Bash`)
- Model specification (`opus`, `sonnet`, or `haiku`)

**Validation**: `build-registry.sh` skips agents without `name` field and logs warnings.

### Script Reliability
Management scripts MUST be idempotent and handle errors gracefully:
- Check for required dependencies (`jq`, `git`, optional `inotify-tools`)
- Provide clear error messages with remediation steps
- Support both systemd and cron for auto-sync compatibility
- Fall back to polling if `inotify-tools` unavailable

**Enforcement**: Each script validates prerequisites and exits with actionable error messages.

### Registry Integrity
The registry JSON MUST contain complete metadata for agent discovery:
- Agent name and description
- Tool availability
- Model preferences
- Source file paths for debugging

**Enforcement**: `build-registry.sh` generates structured JSON with all required fields or fails
with parsing errors.

## Governance

### Amendment Process
Constitution changes MUST follow semantic versioning:
- MAJOR: Backward-incompatible governance changes (e.g., removing sync mechanism)
- MINOR: New principles or materially expanded guidance (e.g., adding security requirements)
- PATCH: Clarifications, typos, or non-semantic refinements

All amendments MUST update dependent templates (plan, spec, tasks) to maintain consistency.

### Compliance Verification
New features MUST include Constitution Check section in `plan.md`. Violations MUST be justified in
Complexity Tracking section or simplified to comply. Scripts MUST validate frontmatter structure
before registry generation.

### Template Synchronization
When constitution changes, these artifacts MUST be reviewed and updated if needed:
- `.specify/templates/plan-template.md` - Constitution Check gates
- `.specify/templates/spec-template.md` - Requirement constraints
- `.specify/templates/tasks-template.md` - Task categorization rules
- Agent-specific guidance files (`CLAUDE.md`, `GEMINI.md`, etc.) - Development guidelines

**Version**: 1.0.0 | **Ratified**: 2025-10-05 | **Last Amended**: 2025-10-05
