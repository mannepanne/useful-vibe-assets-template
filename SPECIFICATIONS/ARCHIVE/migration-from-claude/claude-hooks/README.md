# Claude Code Hooks Archive

This directory contains the **original Claude Code hooks** and related files for reference.

## Purpose

These files are preserved to:
1. **Maintain backward compatibility** - Users can see the original implementation
2. **Enable rollback** - If needed, the Claude version can be restored
3. **Documentation** - Serve as reference for how things worked in Claude

## What's Here

### .claude/hooks/
- `approve-scratch-write.sh` - Auto-approves Write tool calls to SCRATCH/
- `check-profile-setup.sh` - Checks for profile setup on session start
- `safety-harness.sh` - Blocks/asks for dangerous Bash commands
- `lib/parse-tool-input.sh` - Shared parsing logic for hooks

### .claude/settings.json
Original hook registration and configuration.

### tests/
Test suites for each hook:
- `approve-scratch-write/` - Tests SCRATCH/ write auto-approval
- `check-profile-setup/` - Tests profile setup detection
- `safety-harness/` - Tests safety harness patterns

## Migration Status

| Hook | Vibe Equivalent | Status |
|------|-----------------|--------|
| safety-harness.sh | permissions.json | ✅ Migrated (Phase 3) |
| check-profile-setup.sh | /check-profile-setup skill | ✅ Migrated (Phase 5) |
| approve-scratch-write.sh | permissions.json | ✅ Migrated (Phase 6) |

## Current Vibe Implementation

The Vibe version of the template uses:
- **`.vibe/config/permissions.json`** - Tool permissions (replaces PreToolUse hooks)
- **`/check-profile-setup` skill** - Profile setup check (replaces SessionStart hook)
- **`.vibe/config/permissions.json`** - SCRATCH/ write approval (replaces Write hook)

See `.vibe/` directory for the current implementation.

## Using This Archive

If you need to:
- **See the original implementation** - Browse these files
- **Restore Claude version** - Copy files back to `.claude/` and remove `.vibe/`
- **Understand the migration** - Compare with `.vibe/` files

## Do Not Use

These files are **archived** and may not work with current Vibe. Do not use them directly. Use the `.vibe/` versions instead.

---

## Original Hook Overview

### Safety Harness Hook (`safety-harness.sh`)

**Type:** PreToolUse hook for Bash tool

**Purpose:** Intercepts dangerous Bash commands before execution and either blocks them or prompts for confirmation.

**Blocking patterns:** `rm -rf` against root directories, disk operations (`dd`, `mkfs`), database destruction (`DROP TABLE/DATABASE/SCHEMA`), GitHub repo deletion.

**Confirmation patterns:** `git reset --hard`, `git push --force`, `chmod 777`.

**Vibe equivalent:** Deny and confirm patterns in `.vibe/config/permissions.json` Bash tool configuration.

---

### Profile Setup Hook (`check-profile-setup.sh`)

**Type:** SessionStart hook

**Purpose:** Automatically checks if user profile setup is required when a session starts.

**Vibe equivalent:** `/check-profile-setup` skill that users can invoke manually or as part of workflows.

---

### SCRATCH Write Hook (`approve-scratch-write.sh`)

**Type:** PreToolUse hook for Write tool

**Purpose:** Auto-approves Write tool calls to the SCRATCH/ directory to enable automated workflows.

**Why it exists:** Claude Code's allowlist matcher has a quirk where `Write(/SCRATCH/*)` patterns don't silence the permission prompt.

**Vibe equivalent:** SCRATCH/ directory patterns in Write tool permissions in `.vibe/config/permissions.json`.

**Note:** If Vibe has the same allowlist quirk, we may need to use skill-level handling instead.
