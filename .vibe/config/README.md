# Vibe Configuration System

**Purpose:** Central configuration for Mistral Vibe when working in this repository. This directory contains all Vibe-specific configuration files that control tool permissions, project settings, and feature flags.

> **Note:** This replaces Claude Code's `.claude/` configuration system. Vibe uses a **declarative permission model** instead of hook-based configuration.

---

## Configuration Files

### [permissions.json](./permissions.json)
**Purpose:** Tool permission configuration - controls which tools Vibe can use and under what conditions.

**Key differences from Claude:**
- **Declarative** - Uses JSON configuration instead of imperative hook scripts
- **Integrated** - Permissions are built into Vibe's tool system, not a separate hook layer
- **Three modes:** `allow` (runs without prompt), `confirm` (prompts user), `deny` (blocked)

**Structure:**
```json
{
  "default": {"mode": "allow"},
  "tools": {
    "bash": {
      "mode": "confirm",
      "deny_patterns": ["rm -rf *", "git push --force"],
      "allow_patterns": ["git status", "ls"]
    }
  },
  "paths": {
    "allow": [".vibe/*", "SPECIFICATIONS/*"],
    "deny": [".git/*", ".env*"]
  }
}
```

**Migration note:** This adapts the safety patterns from Claude's `.claude/hooks/safety-harness.sh`. The `deny_patterns` in bash come directly from the original hook's test fixtures.

### [project-config.json](./project-config.json)
**Purpose:** Project-level settings that control Vibe's behavior in this repository.

**Current configuration:**
- **reviewSystem.mode:** `prompt-on-first-use` - Controls when automated PR review skills are invoked
- **permissions:** Points to permissions.json for tool-level permissions
- **features:** Vibe-unique features (MCP servers, connectors, local models) - currently disabled

**Key differences from Claude:**
- No SessionStart hook to auto-detect first use - users must invoke a review skill at least once
- No hooks system - relies on Vibe's built-in tool permission model
- Catch-22: Users won't be prompted about review system if they never invoke a review skill

---

## Vibe vs Claude: Configuration Comparison

### Claude Code Model
```
.claude/
├── settings.json          # Tool allowlist
├── CLAUDE.md             # Collaboration principles
├── hooks/                # Imperative hook scripts
│   ├── safety-harness.sh  # PreToolUse: block/ask logic
│   └── check-profile-setup.sh  # SessionStart: profile detection
└── project-config.json   # PR review mode flag
```

**How it worked:**
- Hooks ran as separate processes
- Could execute arbitrary logic (Bash, Python, etc.)
- Emitted JSON to communicate with Claude
- `settings.json` allowlist + hooks created a layered permission system

### Vibe Model
```
.vibe/
├── AGENTS.md             # Collaboration principles
├── config/
│   ├── permissions.json  # Declarative tool permissions (replaces hooks + settings.json)
│   └── project-config.json  # Project settings (replaces .claude/project-config.json)
├── agents/               # Subagent definitions
├── skills/               # Skill definitions
└── hooks/                # Documentation of Vibe's permission model
```

**How it works:**
- **Integrated permissions:** Built into Vibe's tool system
- **Declarative:** JSON configuration, not imperative scripts
- **Simpler:** No separate hook process, no JSON emission needed
- **Trade-off:** Less flexible (no arbitrary logic), but more maintainable

---

## Permission Model Deep Dive

### Three Permission Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| `allow` | Tool runs without user prompt | Safe operations (read, grep, edit) |
| `confirm` | Vibe pauses and asks user before running | Potentially destructive or costly operations |
| `deny` | Tool is blocked entirely | Always-dangerous patterns (rm -rf, drop database, etc.) |

### Pattern Matching

Vibe supports **glob-style patterns** for fine-grained control:

```json
{
  "bash": {
    "mode": "confirm",
    "allow_patterns": ["git status", "git log *", "ls -la"],
    "deny_patterns": ["rm -rf *", "git push --force"]
  }
}
```

**Evaluation order:**
1. Check if command matches any `deny_patterns` → **BLOCKED**
2. Check if command matches any `allow_patterns` → **ALLOWED** (no prompt)
3. Fall back to tool-level `mode` → **ALLOW/CONFIRM/DENY**

### Path-based Restrictions

You can also restrict tool access by file paths:

```json
{
  "paths": {
    "allow": [".vibe/*", "SPECIFICATIONS/*", "REFERENCE/*", "SCRATCH/*"],
    "deny": [".git/*", ".env*", "*.secret", "*.key"],
    "confirm": []
  }
}
```

This prevents Vibe from reading or writing to specific directories regardless of the tool.

---

## Safety Harness Migration

### What Was Migrated

The original Claude template had a sophisticated safety harness in `.claude/hooks/safety-harness.sh` that:
- Intercepted ALL Bash tool calls
- Pattern matched on command strings
- Emitted JSON to block/ask/allow each command
- Had extensive test fixtures (39 fixtures)

### Vibe Adaptation

This functionality is now implemented in `permissions.json`:

- **Block tier** → `deny_patterns` (commands that are always dangerous)
- **Ask tier** → `confirm` mode with no allow_patterns match (prompts user)
- **Allow tier** → `allow_patterns` (safe commands that run without prompt)

### Pattern Coverage

The `deny_patterns` and `allow_patterns` in permissions.json come directly from the original safety-harness.sh test fixtures (78 fixtures). Patterns were refined to match the original hook's intent:

**Dangerous Patterns (BLOCKED):**
- `rm -rf /`, `rm -rf $`, `rm -rf ~` - Recursive deletion of critical paths
- `rm -rf /home`, `rm -rf /Users` - User directory deletion
- `chmod -R 777`, `chmod -R a+w` - World-writable permissions
- `dd if=/dev/` - Disk overwrite (blocks dd if=/dev/sda, etc.)
- `mkfs` - Filesystem creation
- `drop database`, `drop schema`, `drop table` - Database destruction
- `git push --force` - Force push (general)
- `git reset --hard` - Local changes loss
- `git clean -fd` - Untracked file deletion
- `:(){ :|:& };:` - Fork bomb

**Safe Patterns (ALLOWED without prompt):**
- `git status`, `git log`, `git diff`, `git branch`, `git checkout` - Git inspection
- `git push --force origin main`, `git push --force origin master` - Force push to main/master
- `rm -rf ./build`, `rm -rf build/` - Remove build directory
- `rm -rf ./dist`, `rm -rf dist/` - Remove dist directory
- `rm -rf ./node_modules`, `rm -rf node_modules/` - Remove node_modules
- `chmod 755`, `chmod +x` - Safe chmod operations
- `dd if=/dev/null`, `dd if=/dev/zero` - Safe dd operations
- `ls`, `pwd`, `echo` - Safe shell commands
- `cat`, `head`, `tail`, `wc` - File viewing
- `find . -name`, `grep` - File searching

---

## Practical Usage

### For Template Maintainers

1. **To add a new safe command:** Add to `allow_patterns` in the relevant tool
2. **To block a dangerous pattern:** Add to `deny_patterns`
3. **To require confirmation:** Set tool `mode` to `confirm`

### For Template Consumers

1. **Review `permissions.json`** before starting a project
2. **Customize for your needs** - different projects have different safety requirements
3. **Test the configuration** - try running blocked commands to verify they're caught

### Testing Your Configuration

```bash
# These should be blocked:
rm -rf /
git push --force

# These should prompt for confirmation:
git push

# These should run without prompt:
git status
rm -rf ./build
```

---

## Common Customizations

### Stricter Bash Controls
```json
{
  "bash": {
    "mode": "confirm",
    "deny_patterns": [
      "rm -rf *",
      "git push --force",
      ":()",
      ">",
      ">>"
    ],
    "allow_patterns": [
      "git *",
      "ls *",
      "cd *",
      "pwd",
      "echo *"
    ]
  }
}
```

### Allow All in Specific Directory
```json
{
  "paths": {
    "allow": ["SCRATCH/*"],
    "deny": []
  }
}
```

### Different Modes for Different Environments

Create a `.vibe/config/project-config.local.json` (gitignored) to override settings per developer:

```json
{
  "reviewSystem": {
    "mode": "enabled"
  }
}
```

Or a `.vibe/config/permissions.local.json`:

```json
{
  "tools": {
    "bash": {
      "mode": "confirm",
      "allow_patterns": ["my-custom-command *"]
    }
  }
}
```

**Important:** Local config files are **merged with** (not replacements for) the committed config. This allows team-wide defaults with individual customizations.

---

## Troubleshooting

### "Tool X is blocked but shouldn't be"
- Check `deny_patterns` in permissions.json
- Check `paths.deny` for path restrictions
- Add an `allow_patterns` entry for the command

### "Tool X prompts too often"
- Check if there's a matching `allow_patterns` entry
- Add the command to `allow_patterns`
- Or change tool `mode` to `allow` (use cautiously)

---

## See Also

- [permissions.json](./permissions.json) - The actual permission configuration
- [project-config.json](./project-config.json) - Project settings
- [Vibe Permissions Documentation](../../REFERENCE/vibe-permissions.md) - Detailed permission model explanation
- [Phase 3 Specification](../../SPECIFICATIONS/03-configuration-system.md) - Migration details
