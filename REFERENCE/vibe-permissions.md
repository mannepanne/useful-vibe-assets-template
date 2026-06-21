# Vibe Permissions Model

**When to read this:** Setting up Vibe, troubleshooting permission issues, or customizing the safety harness for your project.

**Related Documents:**
- [Vibe Configuration README](../.vibe/config/README.md) - Configuration overview
- [permissions.json](../.vibe/config/permissions.json) - Actual permission configuration
- [Configuration Migration Spec](../SPECIFICATIONS/ARCHIVE/migration-from-claude/03-configuration-system.md) - Historical migration details

---

## Overview

Mistral Vibe uses a **declarative permission system** to control which tools can be invoked and under what conditions. This replaces Claude Code's hook-based system (PreToolUse, SessionStart) with a simpler, more maintainable JSON configuration.

### Key Concept

**Instead of hooks that intercept and decide, Vibe has permissions that declare.**

This is a fundamental shift in the security model:
- **Claude:** "Before running tool X, execute this script to decide"
- **Vibe:** "Tool X has these permissions declared in JSON"

---

## Permission Modes

Every tool in Vibe has one of three permission modes:

### 1. Allow Mode

**Behavior:** Tool runs **without any user prompt**

**Use for:** Safe, read-only, or low-risk operations

**Examples:**
- `read` - Reading files
- `grep` - Searching files
- `edit` - Editing files (generally safe)
- `write_file` - Creating new files
- `task` - Spawning subagents
- `skill` - Loading skills
- `todo` - Task management

### 2. Confirm Mode

**Behavior:** Vibe **pauses and asks the user** before running the tool

**Use for:** Potentially destructive or costly operations

**Examples:**
- `bash` - Shell commands (by default)
- `web_search` - Internet searches (token cost)
- `web_fetch` - Web content fetching (token cost)

**User experience:**
```
Vibe: I'm about to run: git push origin main

Allow? (y/n):
```

### 3. Deny Mode

**Behavior:** Tool is **completely blocked** - Vibe will never run it

**Use for:** Always-dangerous operations

**Examples:**
- Commands matching dangerous patterns (rm -rf, drop database, etc.)

**Note:** Deny mode is rarely used at the tool level. More common is to use `deny_patterns` within a tool that's in confirm mode.

---

## Pattern Matching

Vibe supports **glob-style pattern matching** within tool configurations for fine-grained control.

### Pattern Types

| Pattern Type | Behavior | Example |
|-------------|----------|---------|
| `deny_patterns` | Commands matching these are **always blocked** | `["rm -rf *", "git push --force"]` |
| `allow_patterns` | Commands matching these **bypass confirm mode** | `["git status", "git log"]` |

### Evaluation Order

```
Command: git push --force

1. Check deny_patterns: ["rm -rf *", "git push --force"]
   ↳ MATCH FOUND → BLOCKED
   
Command: git push

1. Check deny_patterns: ["rm -rf *", "git push --force"]
   ↳ No match
2. Check allow_patterns: ["git status", "git log"]
   ↳ No match
3. Fall back to tool mode: "confirm"
   ↳ PROMPT USER
   
Command: git status

1. Check deny_patterns: ["rm -rf *", "git push --force"]
   ↳ No match
2. Check allow_patterns: ["git status", "git log"]
   ↳ MATCH FOUND → ALLOW (no prompt)
```

### Pattern Syntax

- `*` - Matches any characters
- `?` - Matches single character
- Literal strings match exactly

**Examples:**
- `git *` - Matches `git status`, `git log`, `git push`
- `rm -rf *` - Matches `rm -rf /`, `rm -rf .`, `rm -rf ~`
- `*.secret` - Matches any file ending in `.secret`

---

## Path-Based Restrictions

In addition to tool-level permissions, Vibe supports **path-based restrictions** that apply regardless of the tool being used.

### Configuration

```json
{
  "paths": {
    "allow": [
      ".vibe/*",
      "SPECIFICATIONS/*",
      "REFERENCE/*",
      "SCRATCH/*"
    ],
    "deny": [
      ".git/*",
      ".env*",
      "*.secret",
      "*.key"
    ],
    "confirm": []
  }
}
```

**Behavior:**
- **Allow paths:** Vibe can read/write files in these directories without restriction (subject to tool permissions)
- **Deny paths:** Vibe **cannot** read or write files in these directories, regardless of tool permissions
- **Confirm paths:** Vibe prompts before reading/writing files in these directories

### Common Path Patterns

| Path | Purpose | Mode |
|------|---------|------|
| `.vibe/*` | Vibe configuration | allow |
| `SPECIFICATIONS/*` | Active specifications | allow |
| `REFERENCE/*` | Documentation | allow |
| `SCRATCH/*` | Scratch work | allow |
| `.git/*` | Git internals | deny |
| `.env*`, `*.env` | Environment files | deny |
| `*.secret`, `*.key`, `*.pem` | Secret/key files | deny |
| `node_modules/`, `.venv/` | Dependencies | deny |

---

## Template Default Configuration

### Tool Defaults

| Tool | Mode | Rationale |
|------|------|-----------|
| `read` | allow | Reading files is safe |
| `write_file` | allow | Creating files is generally safe |
| `edit` | allow | Editing files is generally safe |
| `grep` | allow | Searching is read-only |
| `bash` | confirm | Shell commands can be destructive |
| `web_search` | confirm | Token cost, external access |
| `web_fetch` | confirm | Token cost, external access |
| `task` | allow | Core Vibe capability |
| `skill` | allow | Core Vibe capability |
| `ask_user_question` | allow | Always safe |
| `todo` | allow | Always safe |

### Safety Patterns

The bash tool has **deny_patterns** and **allow_patterns** adapted from the original Claude safety harness (78 test fixtures):

**Dangerous Patterns (BLOCKED):**
- `rm -rf /`, `rm -rf \$`, `rm -rf ~` - Recursive deletion of critical paths
- `rm -rf /home`, `rm -rf /Users` - User directory deletion
- `chmod -R 777`, `chmod -R a\+w` - World-writable permissions
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

## Customization Guide

### Per-Developer Customization

Create a **gitignored** `.vibe/config/project-config.local.json` to override settings:

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

## Migration from Claude

### Conceptual Mapping

| Claude Component | Vibe Equivalent | Migration Complexity |
|-----------------|-----------------|---------------------|
| `settings.json` allowlist | `permissions.json` allow_patterns | Low - direct mapping |
| PreToolUse hook (safety-harness.sh) | `deny_patterns` + `allow_patterns` | Medium - pattern translation |
| SessionStart hook | No direct equivalent | High - requires skill-based approach |
| Hook JSON emission | Not needed | N/A - declarative model |

### PreToolUse Hook Migration

Claude's PreToolUse hook intercepted ALL Bash tool calls and:
1. Matched against block patterns → BLOCK
2. Matched against ask patterns → ASK
3. Otherwise → ALLOW

Vibe's equivalent:
```json
{
  "bash": {
    "mode": "confirm",
    "deny_patterns": [...],  // Block patterns
    "allow_patterns": [...]  // Allow patterns (skip confirm)
  }
}
```

**Note:** The `mode: "confirm"` at tool level handles the "ask" case. Commands matching `allow_patterns` skip the confirm. Commands matching `deny_patterns` are blocked.

### SessionStart Hook Migration

Claude's SessionStart hook ran on session start and:
- Detected if profile wasn't set up
- Emit a signal to trigger profile setup flow

**Vibe equivalent:** There is no SessionStart hook. Options:
1. **Manual invocation** - User explicitly runs a setup skill
2. **First-use detection** - Skills check for profile existence before proceeding
3. **AGENTS.md instructions** - Strong instructions in auto-loaded files

This is the **catch-22 problem** identified in Phase 1: users need to invoke a skill to be prompted about setup, but they won't know to do that unless they're prompted.

**Current approach:** Profile setup is initiated by explicit instructions in AGENTS.md files.

---

## Best Practices

### 1. Start Restrictive, Loosen as Needed

Begin with strict permissions and add allow_patterns as you encounter safe commands.

### 2. Use Path Restrictions for Sensitive Files

Always deny access to:
- `.git/` - Git internals
- `.env*`, `*.env` - Environment files
- `*.secret`, `*.key`, `*.pem` - Secret/key files
- `node_modules/`, `.venv/` - Dependencies

### 3. Test Your Patterns

Verify your patterns work as expected:
```bash
# Should be blocked
rm -rf /

# Should prompt
git push

# Should run without prompt
git status
rm -rf ./build
```

### 4. Document Your Customizations

If you customize permissions for your project, document:
- Why specific patterns are allowed/blocked
- What the default mode is
- How to test the configuration

---

## Troubleshooting

### "My tool is blocked but shouldn't be"

**Diagnosis:**
1. Check if the command matches any `deny_patterns`
2. Check if the path matches any `paths.deny`
3. Check the tool's `mode`

**Solution:**
- Add the command to `allow_patterns`
- Remove from `deny_patterns` if too broad
- Add path to `paths.allow`

### "My tool prompts too often"

**Diagnosis:**
1. Check if there's a matching `allow_patterns` entry
2. Check the tool's `mode`

**Solution:**
- Add the command to `allow_patterns`
- Change tool `mode` to `allow` (use cautiously)

### "I need to run a blocked command for testing"

**Solution:** Run it manually outside of Vibe, or:
1. Temporarily modify permissions.json
2. Run the command
3. Restore permissions.json
4. Commit the original

**Note:** There is no bypass flag like Claude's `SAFETY_HARNESS_OFF=1`. This is intentional - the permission system is the safety net.

### "Patterns aren't matching as expected"

**Diagnosis:**
- Pattern syntax may differ from what you expect
- Glob patterns are simple, not regex

**Solution:**
- Test patterns with simple commands first
- Use `*` for any characters, `?` for single character
- Check for special characters that need escaping

---

## References

- [permissions.json](../.vibe/config/permissions.json) - Template's actual configuration
- [.vibe/config/README.md](../.vibe/config/README.md) - Configuration system overview
- [Configuration Migration Spec](../SPECIFICATIONS/ARCHIVE/migration-from-claude/03-configuration-system.md) - Historical Phase 3 specification
- [REFERENCE/safety-harness.md](./safety-harness.md) - Original Claude safety harness (historical)
