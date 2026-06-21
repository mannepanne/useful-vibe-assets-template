# .vibe/ Directory

Vibe-specific configuration and collaboration files for this project.

## Purpose

This directory contains everything Vibe needs to work effectively with this project:
- Collaboration principles and profile
- Tool permissions
- Subagent definitions
- Skill definitions
- Hooks/permissions documentation

## Structure

```
.vibe/
├── AGENTS.md              # Collaboration principles (auto-loaded)
├── config/
│   ├── permissions.json   # Tool permissions
│   ├── project-config.json # Project settings
│   └── README.md          # Configuration docs
├── COLLABORATION/
│   ├── personal-profile.md       # Default profile
│   ├── personal-profile.local.md # Local profile (gitignored)
│   ├── debugging-mindset.md
│   ├── documentation-standards.md
│   ├── product-management-mode.md
│   ├── profile-setup-flow.md
│   └── technology-preferences.md
├── agents/                # Subagent definitions
│   └── AGENTS.md
├── skills/                 # Skill definitions
│   └── AGENTS.md
├── hooks/                 # Hooks/permissions documentation
│   └── AGENTS.md
└── README.md              # This file
```

## Auto-loading

Vibe automatically loads:
- `.vibe/AGENTS.md` - When working in project root
- Subdirectory `AGENTS.md` files - When working in that directory

## Git ignore

The following files in `.vibe/` are gitignored:
- `.vibe/COLLABORATION/personal-profile.local.md`
- `.vibe/config/project-config.local.json`
- `.vibe/session-state/` (if used)

## Migration from .claude/

This directory replaces `.claude/` from the Claude Code version of the template. The migration preserves all functionality while adapting to Vibe's architecture.

See [REFERENCE/vibe-permissions.md](../REFERENCE/vibe-permissions.md) for details on how the permission model differs from Claude's hooks.

## Vibe-Specific Features

### Tools
Vibe provides these core tools (subject to permissions):
- `read`, `write_file`, `edit` - File operations
- `grep` - Pattern searching
- `bash` - Shell command execution
- `task` - Delegate work to subagents
- `skill` - Load and execute structured skills
- `web_search`, `web_fetch` - External information access
- `ask_user_question` - User interaction
- `todo` - Task management

### Subagents
Use the `task` tool to delegate complex or parallelizable work:
```
task(agent="explore", task="Review this specification document")
```

### Skills
Skills are structured workflows defined in SKILL.md files:
```
skill(name="review-pr")
```

## Configuration

The configuration system is documented in `.vibe/config/README.md`. Key files:
- `permissions.json` - Tool permission configuration (replaces Claude's hooks)
- `project-config.json` - Project-level settings (replaces `.claude/project-config.json`)

## Collaboration

The collaboration principles are defined in `.vibe/AGENTS.md`. Profile files in `.vibe/COLLABORATION/` provide behavioral guidance.
