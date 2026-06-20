# Vibe Safety Model

> **Purpose:** Document how safety is handled in the Vibe version of the template.

---

## Overview

Mistral Vibe handles safety **differently from Claude Code**. Where Claude uses a separate hooks system with imperative scripts, Vibe integrates safety into its **declarative tool permission model**.

## Safety Mechanisms

### 1. Tool Permissions

Vibe's primary safety mechanism is **tool permissions** (configured in `.vibe/config/permissions.json`):

- **allow** - Commands run silently without user prompt
- **confirm** - Commands require user confirmation before executing
- **deny** - Commands are blocked entirely

This replaces Claude's PreToolUse hooks (safety-harness.sh).

#### Current Configuration

**Bash tool:**
- Mode: `confirm` (user must approve all bash commands)
- Deny patterns: Blocks catastrophic operations (rm -rf /, dd, mkfs, DROP DATABASE, etc.)
- Allow patterns: Allows safe operations (git status, git log, ls, etc.)

**Write tools (write_file, edit):**
- Mode: `allow` (runs without prompt)
- Path restrictions apply globally (see below)

**Other tools:**
- read, grep: `allow` (always safe)
- task, skill: `allow` (core Vibe capabilities)
- web_search, web_fetch: `confirm` (token cost requires user awareness)

### 2. SCRATCH/ Directory Auto-Approval

Writes to the `SCRATCH/` directory are **auto-approved** to enable workflows to create temporary files without prompts.

**Implementation:** Path-based permissions in `.vibe/config/permissions.json`

**Patterns:**
- `SCRATCH/*` - Files directly in SCRATCH/
- `SCRATCH/**` - Files in any subdirectory of SCRATCH/

**Rationale:** Review workflows need to write temp files (e.g., `SCRATCH/review-pr-42-light.md`) as part of their operation. Requiring user confirmation for each would defeat the purpose of automation.

**Note:** If Vibe has the same allowlist quirk as Claude Code for directory patterns, this may need to be adjusted. The current approach uses Vibe's native path-based permissions.

### 3. Profile Setup Check

The profile setup check (formerly a SessionStart hook in Claude) is now handled by the `/check-profile-setup` skill.

**Implementation:** User-invocable skill that checks profile conditions

**Rationale:** Vibe doesn't have SessionStart hooks, so we use a skill that can be invoked manually or as a first step in workflows.

**Usage:** Run `/check-profile-setup` at the start of a new project or session.

---

## Safety Coverage

| Risk | Claude Mechanism | Vibe Mechanism | Status |
|------|-----------------|----------------|--------|
| Dangerous Bash commands | PreToolUse hook (safety-harness.sh) | Tool permissions (deny_patterns + confirm mode) | ✅ Covered |
| SessionStart profile check | SessionStart hook (check-profile-setup.sh) | /check-profile-setup skill | ✅ Covered |
| SCRATCH/ write approval | PreToolUse hook (approve-scratch-write.sh) | Path-based permissions (paths.allow) | ✅ Covered |
| GitHub API access | Allowlist | Tool permissions (allow) | ✅ Covered |

---

## Known Limitations

### 1. Pattern-based only

Vibe's permission system is **pattern-based**, not logic-based. Complex conditions (like "check for sentinel in file") can't be expressed as permissions.

**Example:** Claude's safety-harness.sh could check the full command context and make complex decisions. Vibe's permissions can only match patterns against the command string.

### 2. No pre-execution hooks

Vibe doesn't have hooks that run **before tool execution** with access to full context. All safety must be configured via permissions or handled in skills.

**Implication:** Complex safety logic that requires full context (like checking file contents before allowing a write) cannot be implemented as a global permission and must be handled in individual skills.

### 3. User must invoke

Safety checks that were automatic in Claude (like profile setup on session start) must be **explicitly invoked** in Vibe.

**Mitigation:** Document these checks prominently in AGENTS.md and workflow documentation.

### 4. No escape hatch for SCRATCH/ writes

Unlike Claude's hook which had explicit logic to check paths, Vibe's path-based permissions are absolute. There's no way to conditionally approve or deny based on additional context.

**Current approach:** SCRATCH/ is globally allowed. This is acceptable given the threat model (single trusted contributor or small team).

---

## Migration Notes

### For users migrating from the Claude version:

1. **Safety harness patterns** are now in `.vibe/config/permissions.json`
2. **Profile setup** must be manually checked with `/check-profile-setup`
3. **SCRATCH/ writes** are handled via path-based permissions, not a separate hook
4. **Hook tests** have been adapted to permission tests

### Key differences:

| Aspect | Claude Code | Mistral Vibe |
|--------|-------------|--------------|
| Safety mechanism | Hooks (separate scripts) | Tool permissions (integrated) |
| Hook registration | settings.json | permissions.json |
| Execution | Separate process per hook | Integrated in tool system |
| SCRATCH/ handling | Custom hook | Path-based permissions |
| SessionStart | Hook | Skill (manual invocation) |
| Flexibility | High (arbitrary logic) | Medium (pattern-based) |
| Maintainability | Lower (script complexity) | Higher (declarative config) |

---

## Testing Safety

To verify safety mechanisms are working correctly:

### Automated Tests

Run the safety verification script:
```bash
bash SCRATCH/test-safety.sh
```

This script verifies:
- permissions.json exists and is valid JSON
- SCRATCH/ patterns are present in permissions
- All hook files are archived
- Archive README exists
- Safety documentation exists
- No .claude/ references in .vibe/

### Manual Tests

#### 1. Dangerous command blocking
```bash
rm -rf /
```
**Expected:** Command is blocked (deny pattern matches)

#### 2. Confirmation for risky commands
```bash
git reset --hard
```
**Expected:** User is prompted for confirmation

#### 3. SCRATCH/ write approval
```
# In a skill or conversation, try writing to SCRATCH/
# This should succeed without prompt
```
**Expected:** Write succeeds silently

#### 4. Profile setup check
```
/check-profile-setup
```
**Expected:** Skill checks and reports profile setup status

---

## Troubleshooting

### SCRATCH/ writes are prompting for confirmation

If writes to SCRATCH/ are still prompting:

1. **Check permissions.json** for SCRATCH/ patterns:
   - `SCRATCH/*` should be in paths.allow
   - `SCRATCH/**` should be in paths.allow

2. **Verify write_file mode** is set to "allow" or "confirm" as appropriate

3. **Test with explicit path:**
   ```bash
   Write to SCRATCH/test.md
   ```

4. **Check for Vibe allowlist quirks:** If Vibe has the same quirk as Claude Code where directory patterns don't work for Write tool, we may need to use skill-level handling instead.

### Dangerous commands are not being blocked

1. **Check bash deny_patterns** in permissions.json
2. **Verify pattern syntax** is correct
3. **Test specific pattern:**
   ```bash
   rm -rf /
   ```

### Git commands are prompting unnecessarily

1. **Check bash allow_patterns** for git commands
2. **Add missing patterns** for frequently used git commands
3. **Test pattern matching:**
   ```bash
   git status  # Should run without prompt
   git log     # Should run without prompt
   ```

---

## Related Documentation

- [.vibe/config/README.md](../.vibe/config/README.md) - Configuration system documentation
- [.vibe/config/permissions.json](../.vibe/config/permissions.json) - Current permission configuration
- [REFERENCE/safety-harness.md](./safety-harness.md) - Original Claude safety harness (for reference)
- [REFERENCE/scratch-write-hook.md](./scratch-write-hook.md) - Original SCRATCH/ write hook documentation
- [SPECIFICATIONS/ARCHIVE/claude-hooks/README.md](../SPECIFICATIONS/ARCHIVE/claude-hooks/README.md) - Hook archive documentation

---

## Archive Reference

Original Claude hooks are preserved in:
- `SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/`
- `SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/settings.json`

These are kept for backward compatibility and reference. All current safety mechanisms use Vibe's native permission system.
