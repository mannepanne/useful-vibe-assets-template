# Phase 3: Configuration System

**Phase number:** 3
**Phase name:** Configuration System
**Estimated timeframe:** 1-2 sessions
**Dependencies:** Phase 1 (Research and Foundation), Phase 2 (Documentation Migration) complete
**Status:** Not started

---

## Phase overview

This phase establishes the **Vibe-specific configuration system** for the template. We'll create the `.vibe/` directory structure, adapt the safety harness from Claude's hook-based system to Vibe's built-in permission model, and set up project-level configuration.

This is where we **start making functional changes** to how the template works, moving beyond just renaming files.

---

## Scope and deliverables

### In scope

- [ ] Create and populate `.vibe/` directory structure
- [ ] Create `.vibe/AGENTS.md` with Vibe-appropriate collaboration principles
- [ ] Create `.vibe/config/` directory with configuration files
- [ ] Adapt safety harness from hooks to Vibe's permission system
- [ ] Create `.vibe/config/project-config.json` (Vibe equivalent)
- [ ] Create `.vibe/config/README.md` explaining configuration
- [ ] Update `.gitignore` with `.vibe/` specific entries
- [ ] Document Vibe's permission model in REFERENCE/
- [ ] Create verification that configuration works

### Out of scope

- Agent/subagent definition migration (Phase 4)
- Skills migration (Phase 5)
- Hooks to skills conversion (Phase 6)
- Profile setup system migration (handled separately)

### Acceptance criteria

- [ ] `.vibe/` directory exists with proper structure
- [ ] `.vibe/AGENTS.md` exists with Vibe collaboration principles
- [ ] `.vibe/config/project-config.json` exists with appropriate schema
- [ ] Safety harness adapted to Vibe's permission model
- [ ] `.gitignore` updated with `.vibe/` entries
- [ ] Configuration is documented and verified to work
- [ ] `REFERENCE/vibe-permissions.md` explains Vibe's model

---

## Technical approach

### Vibe Configuration Architecture

Based on Phase 1 research, Vibe's configuration is **different from Claude's**:

**Claude Code Configuration:**
```
.claude/
├── settings.json          # Tool allowlist + hook registration
└── project-config.json    # Project-level flags (prReviewMode, etc.)
```

**Mistral Vibe Configuration:**
```
.vibe/
├── config/
│   ├── permissions.json    # Tool permission configuration
│   └── project-config.json # Project-level settings
├── AGENTS.md              # Collaboration principles
└── ...
```

### Directory Structure to Create

```
.vibe/
├── AGENTS.md                    # Vibe collaboration principles
├── config/
│   ├── permissions.json         # Tool permission configuration (replaces .claude/settings.json hooks)
│   ├── project-config.json      # Project-level flags (replaces .claude/project-config.json)
│   └── README.md                # Configuration documentation
├── COLLABORATION/
│   ├── personal-profile.md       # Default profile (from .claude/COLLABORATION/)
│   └── README.md                # Collaboration docs
└── README.md                    # .vibe/ directory documentation
```

### Configuration File Mapping

| Claude File | Vibe Equivalent | Purpose | Migration Notes |
|-------------|-----------------|---------|-----------------|
| `.claude/settings.json` | `.vibe/config/permissions.json` | Tool permissions + hook registration | Hooks → permission rules |
| `.claude/project-config.json` | `.vibe/config/project-config.json` | Project flags (prReviewMode) | Similar structure, different location |
| `.claude/project-config.local.json` | `.vibe/config/project-config.local.json` | Local overrides | Same gitignore pattern |

### Safety Harness: Claude vs Vibe

This is the **most significant difference** we need to adapt.

#### Claude's Approach (Hooks-based)

```
PreToolUse Hook (safety-harness.sh):
├── Intercepts ALL Bash tool calls
├── Pattern matching on command string
├── Emits JSON to block/ask/allow
└── Registered in .claude/settings.json

SessionStart Hook (check-profile-setup.sh):
├── Runs on session start
├── Checks for profile setup
└── Emits JSON signal
```

**Pros:**
- Very flexible (can run arbitrary logic)
- Can access full command context
- Can emit rich JSON responses

**Cons:**
- Separate system from permissions
- Hook scripts can be complex
- Each hook is a separate process

#### Vibe's Approach (Built-in Permissions)

Vibe has **integrated tool permissions** that can:
- Block tools entirely
- Require confirmation for specific patterns
- Allow tools silently

**How it works:**
```json
{
  "permissions": {
    "Bash": {
      "allow": ["git *", "ls *"],
      "deny": ["rm -rf *"],
      "confirm": ["git push --force"]
    }
  }
}
```

**Pros:**
- Integrated with tool system
- Simpler configuration
- Native to Vibe

**Cons:**
- Less flexible than hooks (no arbitrary logic)
- Pattern matching may be more limited

#### Migration Strategy for Safety Harness

We have **three options** for adapting the safety harness:

**Option A: Pure Permission Configuration (Recommended)**
- Map all hook patterns to Vibe's permission system
- Convert block tier → deny
- Convert ask tier → confirm
- Lose some flexibility but gain simplicity

**Option B: Hybrid Approach**
- Use permissions for simple patterns
- Create a Vibe skill for complex logic (profile setup, etc.)
- More complex but more faithful to original

**Option C: Custom Script with task tool**
- Create a subagent that handles safety checks
- Invoke it before sensitive operations
- Most flexible but most complex

**Recommendation:** Start with **Option A** (pure permissions) for the safety harness patterns. For the profile setup (SessionStart hook), use **Option B** (a skill that runs on first use).

### Permission Pattern Mapping

From Claude's `safety-harness.sh` to Vibe's permissions:

| Hook Pattern | Type | Vibe Permission | Pattern |
|--------------|------|-----------------|---------|
| `rm -rf /` | Block | deny | `"rm -rf /"` |
| `rm -rf ~` | Block | deny | `"rm -rf ~"` |
| `rm -rf $HOME` | Block | deny | `"rm -rf $HOME"` |
| `rm -rf /Users` | Block | deny | `"rm -rf /Users*"` |
| `dd of=/dev/disk` | Block | deny | `"dd * of=/dev/(disk\|sd\|nvme\|rdisk)*"` |
| `mkfs /dev/disk` | Block | deny | `"mkfs* /dev/(disk\|sd\|nvme\|rdisk)*"` |
| `diskutil eraseDisk` | Block | deny | `"diskutil eraseDisk"` |
| `DROP TABLE` | Block | deny | `"*DROP (TABLE\|DATABASE\|SCHEMA)*"` (case-insensitive) |
| `gh repo delete` | Block | deny | `"gh repo delete"` |
| `git reset --hard` | Ask | confirm | `"git reset --hard"` |
| `git push --force` | Ask | confirm | `"git push * --force"` |
| `chmod 777` | Ask | confirm | `"chmod * 777"` |

### Profile Setup Migration

Claude's profile setup uses a **SessionStart hook** that:
1. Checks for `personal-profile.local.md` existence
2. Checks for sentinel in `personal-profile.md`
3. Emits signal that triggers setup flow

**Vibe Equivalent:**

Since Vibe doesn't have SessionStart hooks, we have **two options**:

**Option 1: Initial Check Skill**
- Create a `/check-profile-setup` skill
- User invokes it manually or we document it as first step
- Checks same conditions, triggers setup flow

**Option 2: AGENTS.md Auto-check**
- Document in `.vibe/AGENTS.md` that users should check profile setup
- Provide a simple command to run
- Less automated but simpler

**Option 3: Project Setup Guide**
- Document profile setup in TEMPLATE-INSTRUCTIONS.md
- User follows steps manually
- Most transparent but least automated

**Recommendation:** **Option 1** - Create a `/check-profile-setup` skill that mimics the hook behavior. This maintains the automation while using Vibe's native skill system.

---

## Configuration Files

### .vibe/config/permissions.json

```json
{
  "_meta": {
    "description": "Tool permission configuration for Mistral Vibe. Replaces Claude Code's .claude/settings.json hooks.",
    "version": "1.0",
    "migrated_from": "Claude Code safety-harness.sh and check-profile-setup.sh"
  },
  
  "permissions": {
    "Bash": {
      "allow": [
        "git *",
        "gh *",
        "npm *",
        "yarn *",
        "pnpm *",
        "ls *",
        "cd *",
        "cat *",
        "echo *",
        "mkdir *",
        "rm *",
        "mv *",
        "cp *",
        "find *",
        "grep *",
        "sed *",
        "awk *",
        "python3 *",
        "node *",
        "npx *"
      ],
      
      "deny": [
        "rm -rf /",
        "rm -rf ~/",
        "rm -rf $HOME",
        "rm -rf /Users*",
        "dd * of=/dev/(disk|sd|nvme|rdisk)*",
        "mkfs* /dev/(disk|sd|nvme|rdisk)*",
        "diskutil eraseDisk",
        "*DROP TABLE*",
        "*DROP DATABASE*",
        "*DROP SCHEMA*",
        "gh repo delete"
      ],
      
      "confirm": [
        "git reset --hard",
        "git push * --force",
        "git push * -f",
        "chmod * 777",
        "chmod * -R 777"
      ]
    },
    
    "Write": {
      "allow": [
        "*",
        "!*.env",
        "!.env.*",
        "!.dev.vars"
      ],
      "confirm": [
        "*.env",
        ".env.*"
      ]
    },
    
    "Edit": {
      "allow": ["*"],
      "confirm": []
    },
    
    "Read": {
      "allow": ["*"],
      "confirm": []
    }
  }
}
```

### .vibe/config/project-config.json

```json
{
  "_meta": {
    "description": "Project-level configuration for Vibe template features. Checked in to git so team members share the same settings.",
    "migrated_from": ".claude/project-config.json"
  },
  
  "prReviewMode": "prompt-on-first-use",
  
  "mcpServers": {
    "enabled": false,
    "configs": {}
  },
  
  "connectors": {
    "enabled": false,
    "definitions": {}
  },
  
  "features": {
    "autoProfileCheck": true,
    "safetyHarness": true,
    "skillDiscovery": true
  }
}
```

Note: This is a **strawman proposal** - we'll refine the schema based on Phase 1 research into Vibe's actual configuration capabilities.

### .vibe/AGENTS.md

This is the **Vibe equivalent** of `.claude/CLAUDE.md`. It should contain:

```markdown
# Vibe Collaboration Principles

> **Context for Mistral Vibe**
> This file provides collaboration principles and ways of working guidance to Mistral Vibe when working in this repository.

---

## Introduction

You are Mistral Vibe, a CLI coding agent. Read `.vibe/COLLABORATION/personal-profile.local.md` if it exists, otherwise `.vibe/COLLABORATION/personal-profile.md` — tells you who you're working with and how they like to collaborate.

## Core principles

[Migrate principles from .claude/CLAUDE.md, adapting for Vibe]

## Vibe-specific capabilities

### Tools available
- `skill` - Load specialized skills
- `task` - Delegate to subagents
- `web_search` - Search the web
- `web_fetch` - Fetch web content
- Standard tools: Bash, Read, Glob, Grep, Edit, Write, etc.

### Subagents
You can spawn subagents using the `task` tool. Subagents run independently and can access tools based on their configuration.

### Skills
Skills are structured workflows loaded via the `skill` tool. They can orchestrate complex tasks and use subagents.

## Automated review system

[Adapted from .claude/CLAUDE.md - reference new Vibe-based system]

## Migration notes

This file was migrated from `.claude/CLAUDE.md` as part of the Vibe adaptation. The core principles remain the same, but some implementation details have been adapted for Vibe's architecture.
```

---

## .vibe/config/README.md

```markdown
# Vibe Configuration

This directory contains configuration files for the Vibe template.

## Files

### permissions.json
Tool permission configuration. Defines which tools are allowed, denied, or require confirmation.

**Migrated from:** `.claude/settings.json` (hooks) + `.claude/hooks/safety-harness.sh`

### project-config.json
Project-level configuration flags.

**Migrated from:** `.claude/project-config.json`

### project-config.local.json (gitignored)
Local overrides for project-config.json. Not checked in.

## Permission model

Vibe's permission system is **integrated** - unlike Claude's separate hooks system.

### Permission levels

1. **deny** - Tool call is blocked entirely
2. **confirm** - Tool call requires user confirmation
3. **allow** - Tool call runs silently

### Pattern syntax

- `*` - wildcard (matches anything)
- `git *` - matches any git command
- `rm -rf *` - matches rm -rf with anything
- Case-sensitive by default

### Local overrides

Create `project-config.local.json` to override committed settings without affecting other team members.

## Migration from Claude

| Claude Concept | Vibe Equivalent |
|---------------|-----------------|
| Hooks (PreToolUse) | Permissions (deny/confirm) |
| Hooks (SessionStart) | Skills or manual check |
| .claude/settings.json | .vibe/config/permissions.json |
| .claude/project-config.json | .vibe/config/project-config.json |
```

---

## .vibe/README.md

```markdown
# .vibe/ Directory

Vibe-specific configuration and collaboration files for this project.

## Purpose

This directory contains everything Vibe needs to work effectively with this project:
- Collaboration principles and profile
- Tool permissions
- Subagent definitions (Phase 4)
- Skill definitions (Phase 5)

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
│   └── README.md          # Profile setup docs
├── agents/                # Subagent definitions (Phase 4)
│   └── ...
├── skills/                 # Skill definitions (Phase 5)
│   └── ...
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
```

---

## Documentation to Create

### REFERENCE/vibe-permissions.md

```markdown
# Vibe Tool Permissions

> **Purpose:** Document Vibe's built-in tool permission system and how it replaces Claude Code's hooks.

---

## Overview

Mistral Vibe has an **integrated tool permission system** that replaces Claude Code's separate hooks system (PreToolUse, SessionStart, etc.).

### Key difference

| Aspect | Claude Code | Mistral Vibe |
|--------|-------------|--------------|
| Permission control | Allowlist in settings.json | Integrated permissions in config |
| Interception | Hook scripts (bash) | Permission rules (JSON) |
| Flexibility | High (arbitrary logic) | Medium (pattern-based) |
| Complexity | Complex (separate system) | Simple (integrated) |

## Permission Levels

### deny
Tool calls matching these patterns are **blocked entirely**.

```json
"deny": ["rm -rf /", "gh repo delete"]
```

### confirm
Tool calls matching these patterns **require user confirmation** before executing.

```json
"confirm": ["git reset --hard", "git push --force"]
```

### allow
Tool calls matching these patterns **run silently** without confirmation.

```json
"allow": ["git status", "ls -la"]
```

## Pattern Syntax

- `*` - Matches any characters
- `git *` - Matches any git command
- `rm -rf *` - Matches rm -rf with any arguments
- Patterns are case-sensitive by default

## Migration from Claude Hooks

### PreToolUse Hook → Permissions

Claude's `safety-harness.sh` (PreToolUse hook):
- **Block tier** → Vibe `deny`
- **Ask tier** → Vibe `confirm`
- **Allow** → Vibe `allow`

Example mapping:

| safety-harness.sh Pattern | Vibe Permission |
|-------------------------|-----------------|
| `rm -rf /` | `{"deny": ["rm -rf /"]}` |
| `git reset --hard` | `{"confirm": ["git reset --hard"]}` |
| `chmod 777` | `{"confirm": ["chmod * 777"]}` |

### SessionStart Hook → Skills

Claude's `check-profile-setup.sh` (SessionStart hook) doesn't have a direct equivalent in Vibe.

**Replacement options:**
1. **Initial check skill** - Create `/check-profile-setup` skill that users run
2. **Documentation** - Document as first step in TEMPLATE-INSTRUCTIONS.md
3. **AGENTS.md reminder** - Add note in `.vibe/AGENTS.md`

We use **Option 1** - a skill that can be invoked to check and trigger profile setup.

## Configuration Location

Vibe configuration lives in `.vibe/config/`:
- `permissions.json` - Tool permissions
- `project-config.json` - Project-level settings

## Local Overrides

Create `.vibe/config/project-config.local.json` (gitignored) to override committed settings:

```json
{
  "prReviewMode": "enabled"
}
```

This file merges with `project-config.json`, with local values taking precedence.

## Testing Permissions

To verify your permission configuration:

```bash
# This should be denied
rm -rf /

# This should require confirmation
git reset --hard

# This should run silently
git status
```

## Limitations

Vibe's permission system is **pattern-based**, which means:
- ✅ Simple command blocking/confirmation works well
- ⚠️ Complex logic (like checking for sentinel in a file) doesn't fit
- ⚠️ Conditional logic (based on file existence, time, etc.) isn't supported

For complex cases, use **skills** or **subagents** instead.

## Best Practices

1. **Start restrictive** - Deny by default, allow specific patterns
2. **Use confirm for destructive operations** - Give users a chance to cancel
3. **Document your patterns** - Add comments explaining why each pattern is there
4. **Test thoroughly** - Verify permissions work as expected before relying on them
5. **Provide escape hatches** - Document how to bypass for legitimate needs
```

---

## Testing strategy

### Verification checklist

- [ ] `.vibe/` directory exists with proper structure
- [ ] `.vibe/config/permissions.json` exists and is valid JSON
- [ ] `.vibe/config/project-config.json` exists and is valid JSON
- [ ] `.vibe/AGENTS.md` exists with Vibe-appropriate content
- [ ] `.gitignore` updated with `.vibe/` entries
- [ ] `REFERENCE/vibe-permissions.md` created and comprehensive
- [ ] All configuration files are properly documented

### Automated tests

Create `SCRATCH/test-permissions.sh`:
```bash
#!/bin/bash
set -e

echo "Testing Vibe configuration..."

# Test JSON validity
for file in .vibe/config/*.json; do
  if [ -f "$file" ]; then
    echo "Checking $file..."
    python3 -m json.tool "$file" > /dev/null || { echo "ERROR: Invalid JSON in $file"; exit 1; }
  fi
done

# Test .vibe/ structure
echo "Checking .vibe/ structure..."
for dir in .vibe/config .vibe/COLLABORATION; do
  [ -d "$dir" ] || { echo "ERROR: Missing directory $dir"; exit 1; }
done

for file in .vibe/AGENTS.md .vibe/README.md .vibe/config/README.md; do
  [ -f "$file" ] || { echo "ERROR: Missing file $file"; exit 1; }
done

echo "All configuration tests passed!"
```

### Manual verification

1. **Permission testing**: Try running commands that should be blocked/confirmed
2. **Configuration loading**: Verify Vibe loads the configuration correctly
3. **Documentation review**: Read through all new documentation
4. **Link checking**: Verify all cross-references work

---

## Pre-commit checklist

Before creating PR for Phase 3:

- [ ] `.vibe/` directory structure created
- [ ] `.vibe/AGENTS.md` created with Vibe principles
- [ ] `.vibe/config/permissions.json` created
- [ ] `.vibe/config/project-config.json` created
- [ ] `.vibe/config/README.md` created
- [ ] `.vibe/README.md` created
- [ ] `.vibe/COLLABORATION/` structure created
- [ ] `.gitignore` updated with `.vibe/` entries
- [ ] `REFERENCE/vibe-permissions.md` created
- [ ] All JSON files are valid
- [ ] All documentation is clear and accurate
- [ ] No secrets in configuration files

---

## PR workflow

### Branch naming
```
feature/phase-3-configuration-system
```

### PR title
```
Phase 3: Configuration System - Vibe .vibe/ structure and permissions
```

### PR description template
```markdown
## Summary
Creates the Vibe-specific configuration system, adapting Claude's hooks-based safety harness to Vibe's integrated permission model.

## Changes

### New files
- `.vibe/AGENTS.md` - Vibe collaboration principles
- `.vibe/config/permissions.json` - Tool permission configuration
- `.vibe/config/project-config.json` - Project settings
- `.vibe/config/README.md` - Configuration documentation
- `.vibe/README.md` - .vibe/ directory overview
- `.vibe/COLLABORATION/personal-profile.md` - Default profile
- `REFERENCE/vibe-permissions.md` - Permission system documentation

### Modified files
- `.gitignore` - Added .vibe/ specific entries

## Technical Details

### Safety Harness Migration
Converted Claude's hook-based safety harness to Vibe's permission system:
- Block tier patterns → `deny` in permissions.json
- Ask tier patterns → `confirm` in permissions.json
- Allow patterns → `allow` in permissions.json

### Profile Setup
SessionStart hook replaced with skill-based approach. Users can invoke `/check-profile-setup` to verify profile configuration.

## Testing
- Verified all JSON configuration is valid
- Verified .vibe/ directory structure
- Documented permission patterns
- Created test script in SCRATCH/

## Migration Notes
This phase establishes the foundation for Vibe's configuration. Subsequent phases will:
- Phase 4: Add subagent definitions
- Phase 5: Add skill definitions
- Phase 6: Complete hooks migration
```

### Review requirements
- Manual review focusing on:
  - Configuration structure and clarity
  - Permission patterns coverage
  - Documentation completeness
  - Security of permission settings

---

## Edge cases and considerations

### Known risks

1. **Permission pattern gaps**: Vibe's pattern matching may not cover all Claude hook patterns. Mitigation: Document limitations in REFERENCE/vibe-permissions.md; provide escape hatch instructions.

2. **SessionStart hook replacement**: No perfect equivalent in Vibe. Mitigation: Use skill-based approach; document as first step in instructions.

3. **Configuration schema**: Vibe may have specific schema requirements we're not aware of. Mitigation: Test configuration loading thoroughly; be prepared to adjust.

### Open questions

1. Does Vibe support **regular expressions** in permission patterns, or just glob patterns?
2. Does Vibe have a **native configuration file format**, or can we use our own JSON?
3. How does Vibe handle **local overrides** (per-user vs per-project)?
4. Can we **extend permissions with custom logic** (like checking file existence)?

### Vibe-specific opportunities

1. **Simpler configuration**: Vibe's integrated permissions may be simpler to maintain than Claude's hooks + settings.json separation.

2. **Better discoverability**: With configuration in a standard location, it may be easier for users to find and understand.

3. **Future extensibility**: Vibe's architecture may make it easier to add new features like MCP servers.

---

## Related documentation

- [Phase 1: Research and Foundation](./01-research-and-planning.md) - Prerequisite
- [Phase 2: Documentation Migration](./02-documentation-migration.md) - Prerequisite
- [Root AGENTS.md](../AGENTS.md) - Implementation library
- [ORIGINAL_IDEA/project-outline.md](../ORIGINAL_IDEA/project-outline.md) - Master specification
- [REFERENCE/vibe-permissions.md](../REFERENCE/vibe-permissions.md) - (To be created)

---

## Notes

This phase is **critical** because it establishes the configuration foundation that all subsequent phases build on. The key decisions are:

1. **Permission model**: How to map Claude's hooks to Vibe's permissions
2. **Configuration structure**: Where to put which configuration files
3. **Profile setup**: How to handle the SessionStart hook functionality

**Key principle:** Favor **simplicity and maintainability** over perfect feature parity. It's okay if some Claude features don't have direct equivalents in Vibe, as long as the core functionality (safety, configuration, collaboration) is preserved.

The documentation created in this phase (especially REFERENCE/vibe-permissions.md) will be **essential reference** for anyone using or maintaining the Vibe template.
