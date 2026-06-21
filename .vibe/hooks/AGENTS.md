# Hooks Library Index

> **Purpose**: Library index for Vibe hooks and permission configurations.

---

## Important: Vibe vs Claude Hooks

**Key difference**: Claude Code uses executable hook scripts (bash) that run at specific events. Vibe uses a **declarative permission system** with JSON configuration.

| Claude Hook | Vibe Equivalent | Notes |
|--------------|-----------------|-------|
| `PreToolUse` | permissions.json tool configuration | Declarative gating instead of imperative interception |
| `PostToolUse` | Tool result handling in skills | No direct equivalent; handle in skill logic |
| `SessionStart` | Startup skill or AGENTS.md auto-load | No direct equivalent; different paradigm |

---

## Permission Configuration

Vibe's safety and tool control is managed through `.vibe/config/permissions.json`.

### Permission Levels

| Mode | Behavior | Use Case |
|------|----------|----------|
| `allow` | Tool runs without confirmation | Safe, read-only operations |
| `confirm` | Prompt user before execution | Potentially destructive operations |
| `deny` | Tool blocked entirely | Never-permitted operations |

### Example Configuration

See `.vibe/config/permissions.json` for the actual configuration.

```json
{
  "read": {"mode": "allow"},
  "write_file": {"mode": "allow"},
  "edit": {"mode": "allow"},
  "grep": {"mode": "allow"},
  "bash": {
    "mode": "confirm",
    "deny_patterns": ["rm -rf", "git push --force", "chmod 777"]
  }
}
```

---

## Migration Strategy

Claude hooks have been adapted to Vibe's permission system (see [Phase 6 spec](../../SPECIFICATIONS/ARCHIVE/migration-from-claude/06-safety-and-hooks.md)).

### Current Claude Hooks

| Hook File | Purpose | Vibe Migration Plan |
|-----------|---------|---------------------|
| `approve-scratch-write.sh` | Approve writes to SCRATCH/ | Map to permission allow pattern |
| `check-profile-setup.sh` | Profile setup validation | Embed in AGENTS.md or startup skill |
| `safety-harness.sh` | Dangerous command blocking | Map to permissions.json deny_patterns |

### Safety Harness Patterns

The existing safety harness tests (in `.claude/hooks/tests/`) define patterns for:
- Allowing safe operations (`rm -rf build/`, `echo`, `ls`)
- Asking confirmation for potentially dangerous (`git push --force`)
- Blocking dangerous operations (`rm -rf /`, `drop database`)

These will be translated to Vibe's permission configuration.

---

## The Catch-22 Problem Revisited

Claude's `check-profile-setup.sh` hook fires at session start to ensure profile setup. In Vibe:

- No SessionStart hook exists
- Profile validation must be handled differently:
  1. **Startup skill**: User invokes `/setup` skill on first use
  2. **First tool use**: Embed check in commonly-used skills
  3. **AGENTS.md**: Explicit setup instructions that Vibe might surface

This architectural difference means we need to rethink proactive checks.

---

## Related Documentation

- [Root AGENTS.md](../AGENTS.md) - Collaboration principles
- [Phase 6 Spec](../../SPECIFICATIONS/ARCHIVE/migration-from-claude/06-safety-and-hooks.md) - Historical migration plan
- [.claude/hooks/](../.claude/hooks/) - Original Claude hooks (archive)
