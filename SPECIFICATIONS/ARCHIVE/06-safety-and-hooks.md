# Phase 6: Safety Harness & Hooks Migration

**Phase number:** 6
**Phase name:** Safety Harness & Hooks Migration
**Estimated timeframe:** 1 session
**Dependencies:** Phase 1 (Research and Foundation), Phase 2 (Documentation Migration), Phase 3 (Configuration System), Phase 4 (Agent & Subagent Migration), Phase 5 (Skills Migration) complete
**Status:** ✅ COMPLETED

---

## Phase overview

This phase completes the migration of **Claude's hook system** to Vibe's equivalent functionality. While Phase 3 handled the safety harness (PreToolUse hook) by converting it to Vibe's permission system, and Phase 5 handled the SessionStart hook (profile setup) by converting it to a skill, there are remaining hooks and safety-related files to migrate.

This phase focuses on:
1. Migrating the `approve-scratch-write.sh` hook (Write tool auto-approval)
2. Finalizing the safety harness documentation
3. Verifying all safety mechanisms work in Vibe
4. Cleaning up any remaining hook references

---

## Scope and deliverables

### In scope

- [ ] Migrate `approve-scratch-write.sh` hook functionality
- [ ] Update all hook-related documentation
- [ ] Create REFERENCE/vibe-safety.md (Vibe-specific safety documentation)
- [ ] Verify permission configuration covers all safety cases
- [ ] Archive original hooks in SPECIFICATIONS/ARCHIVE/
- [ ] Update REFERENCE/safety-harness.md for Vibe
- [ ] Test all safety mechanisms
- [ ] Document any gaps or limitations

### Out of scope

- Permission configuration (Phase 3)
- Profile setup skill (Phase 5)
- Agent/subagent migration (Phase 4)
- Full end-to-end testing (Phase 7)

### Acceptance criteria

- [x] All hooks migrated or replaced with Vibe equivalents (via permissions.json)
- [x] REFERENCE/vibe-safety.md created - Vibe-specific safety documentation
- [x] REFERENCE/safety-harness.md updated for Vibe compatibility
- [x] REFERENCE/scratch-write-hook.md updated for Vibe compatibility
- [x] All safety mechanisms documented in REFERENCE/vibe-safety.md
- [x] Original hooks archived in SPECIFICATIONS/ARCHIVE/claude-hooks/
- [x] All safety tests pass via permission configuration
- [x] Gaps and limitations documented (Catch-22 problem noted)

---

## Technical approach

### Claude Hooks System Overview

Claude Code has **three hooks registered** in `.claude/settings.json`:

| Hook | Matcher | Script | Purpose |
|------|---------|--------|---------|
| Safety Harness | `Bash` (with filter) | `safety-harness.sh` | Block/ask on dangerous commands |
| Approve SCRATCH Write | `Write` | `approve-scratch-write.sh` | Auto-approve writes to SCRATCH/ |
| Profile Setup | `SessionStart` | `check-profile-setup.sh` | Trigger profile setup flow |

**Migration status:**
- ✅ **Safety Harness** (PreToolUse) → Vibe permissions (Phase 3)
- ✅ **Profile Setup** (SessionStart) → `/check-profile-setup` skill (Phase 5)
- ⏳ **Approve SCRATCH Write** (PreToolUse) → This phase

### The Approve SCRATCH Write Hook

This hook (`approve-scratch-write.sh`) handles **auto-approval of Write tool calls to the SCRATCH/ directory**.

**What it does:**
1. Checks if the Write tool is being used
2. Checks if the target path is within `SCRATCH/`
3. If yes, auto-approves (exits 0 without prompting)
4. If no, falls through to normal permission handling

**Why it exists:**
- Vibe/Claude Code's allowlist has a quirk where `Write(SCRATCH/*)` patterns don't work as expected
- The hook provides a workaround by intercepting and auto-approving SCRATCH/ writes
- This enables the review workflows to write temp files without user prompts

**Script location:** `.claude/hooks/approve-scratch-write.sh`

### Vibe Equivalent for Approve SCRATCH Write

Vibe's permission system may handle this differently. We have **several options**:

#### Option A: Permission Configuration
If Vibe's Write tool permissions support directory patterns:
```json
{
  "Write": {
    "allow": ["SCRATCH/*", "SCRATCH/**"]
  }
}
```

**Pros:**
- Native to Vibe
- Simple configuration
- No custom code

**Cons:**
- May not work if Vibe has the same allowlist quirk as Claude

#### Option B: Custom Permission Logic
If Vibe supports custom permission logic (unlikely based on Phase 1 research):
```json
{
  "Write": {
    "allow": ["*"],
    "auto_approve": ["SCRATCH/*"]
  }
}
```

#### Option C: Skill-Level Handling
Handle SCRATCH/ writes within each skill by:
1. Checking if the write is to SCRATCH/
2. Using a different approach if it is

**Pros:**
- Works regardless of permission system
- Skill has full control

**Cons:**
- Duplicates logic across skills
- Less transparent

#### Option D: Accept Vibe's Default
If Vibe's Write tool works correctly with `SCRATCH/*` patterns in allowlist:
```json
{
  "Write": {
    "allow": ["SCRATCH/*", "SCRATCH/**"]
  }
}
```

**Recommendation:** Start with **Option D** (permission configuration). If testing reveals that Vibe has the same allowlist quirk as Claude, fall back to **Option C** (skill-level handling) or **Option A** (if we can verify it works).

### Hook Files to Archive

These files should be **archived** (not deleted) to maintain backward compatibility reference:

```
.claude/hooks/
├── approve-scratch-write.sh      → Archive
├── check-profile-setup.sh       → Already handled (SessionStart → skill)
├── safety-harness.sh            → Already handled (PreToolUse → permissions)
├── lib/
│   └── parse-tool-input.sh      → Archive (used by hooks)
└── tests/
    ├── approve-scratch-write/
    │   └── ...                  → Archive
    ├── check-profile-setup/
    │   └── ...                  → Archive
    └── safety-harness/
        └── ...                  → Archive
```

**Archive location:** `SPECIFICATIONS/ARCHIVE/claude-hooks/`

### Safety Documentation Updates

We need to **update or create** several documentation files:

#### 1. REFERENCE/vibe-safety.md (New)

This document explains **Vibe's safety model** and how it compares to Claude's:

```markdown
# Vibe Safety Model

> **Purpose:** Document how safety is handled in the Vibe version of the template.

---

## Overview

Mistral Vibe handles safety **differently from Claude Code**. Where Claude uses a separate hooks system, Vibe integrates safety into its tool permission model.

## Safety Mechanisms

### 1. Tool Permissions

Vibe's primary safety mechanism is **tool permissions** (configured in `.vibe/config/permissions.json`):

- **deny** - Commands are blocked entirely
- **confirm** - Commands require user confirmation
- **allow** - Commands run silently

This replaces Claude's PreToolUse hooks (safety-harness.sh).

### 2. SCRATCH/ Directory Auto-Approval

Writes to the `SCRATCH/` directory are **auto-approved** to enable workflows to create temporary files without prompts.

**Implementation:** Permission configuration in permissions.json

**Rationale:** Review workflows need to write temp files (e.g., SCRATCH/review-pr-42-light.md) as part of their operation. Requiring user confirmation for each would defeat the purpose of automation.

### 3. Profile Setup Check

The profile setup check (formerly a SessionStart hook) is now handled by the `/check-profile-setup` skill.

**Implementation:** User-invocable skill that checks profile conditions

**Rationale:** Vibe doesn't have SessionStart hooks, so we use a skill that can be invoked manually or as a first step in workflows.

## Safety Coverage

| Risk | Claude Mechanism | Vibe Mechanism | Status |
|------|-----------------|----------------|--------|
| Dangerous Bash commands | PreToolUse hook (safety-harness.sh) | Tool permissions (deny/confirm) | ✅ Covered |
| SessionStart profile check | SessionStart hook | /check-profile-setup skill | ✅ Covered |
| SCRATCH/ write approval | PreToolUse hook (approve-scratch-write.sh) | Tool permissions (allow) | ✅ Covered |
| GitHub API access | Allowlist | Tool permissions (allow) | ✅ Covered |

## Known Limitations

1. **Pattern-based only** - Vibe's permission system is pattern-based, not logic-based. Complex conditions (like "check for sentinel in file") can't be expressed as permissions.

2. **No pre-execution hooks** - Vibe doesn't have hooks that run before tool execution with access to full context. All safety must be configured via permissions or handled in skills.

3. **User must invoke** - Safety checks that were automatic in Claude (like profile setup on session start) must be explicitly invoked in Vibe.

## Migration Notes

For users migrating from the Claude version:

1. **Safety harness patterns** are now in `.vibe/config/permissions.json`
2. **Profile setup** must be manually checked with `/check-profile-setup`
3. **SCRATCH/ writes** are handled via permissions, not a separate hook
4. **Hook tests** have been adapted to permission tests

## Testing Safety

To verify safety mechanisms:

```bash
# This should be blocked
rm -rf /

# This should require confirmation
git reset --hard

# This should run silently (SCRATCH/ write)
echo "test" > SCRATCH/test.md
```
```

#### 2. REFERENCE/safety-harness.md (Update)

Update the existing safety-harness.md to:
- Explain that it now applies to the **Claude version** only
- Reference the new `vibe-safety.md` for Vibe-specific information
- Document the migration from hooks to permissions

#### 3. REFERENCE/scratch-write-hook.md (New or Update)

Create or update documentation about SCRATCH/ write handling:

```markdown
# SCRATCH/ Write Handling

> **Purpose:** Document how writes to the SCRATCH/ directory are handled for temporary file creation.

---

## Overview

Both Claude Code and Mistral Vibe need to **auto-approve writes to SCRATCH/** to enable automated workflows (like review skills) to create temporary files without user prompts.

## Claude Code Implementation

**Mechanism:** PreToolUse hook (`approve-scratch-write.sh`)

**How it works:**
1. Hook registered for `Write` tool in `.claude/settings.json`
2. When Write is called, hook script runs
3. Script checks if path starts with `SCRATCH/`
4. If yes, emits JSON to auto-approve
5. If no, falls through to normal handling

**Files:**
- Hook: `.claude/hooks/approve-scratch-write.sh`
- Tests: `.claude/hooks/tests/approve-scratch-write/`

## Vibe Implementation

**Mechanism:** Tool permissions (configured in `.vibe/config/permissions.json`)

**How it works:**
1. Write tool permissions include `SCRATCH/*` and `SCRATCH/**` in allow list
2. Vibe's permission system auto-approves matching patterns
3. No custom hook needed

**Files:**
- Configuration: `.vibe/config/permissions.json`

## Migration Notes

The Vibe implementation is **simpler** - it uses native permission patterns instead of a custom hook. However, if Vibe has the same allowlist quirk as Claude Code for directory patterns, we may need to use a different approach.

## Testing

Both implementations should pass these tests:

1. Write to `SCRATCH/test.md` → succeeds without prompt
2. Write to `SCRATCH/subdir/test.md` → succeeds without prompt
3. Write to `src/test.md` → normal permission handling (may prompt)

## Troubleshooting

If SCRATCH/ writes are prompting:
1. Check permissions.json for SCRATCH/ patterns
2. Verify pattern syntax is correct
3. Test with explicit path: `SCRATCH/*` and `SCRATCH/**`
4. If still prompting, check Vibe's allowlist quirks
```

### Hook Archive Structure

Create `SPECIFICATIONS/ARCHIVE/claude-hooks/` with:

```
SPECIFICATIONS/ARCHIVE/claude-hooks/
├── README.md                          # Explanation of archive
├── .claude/
│   ├── hooks/
│   │   ├── approve-scratch-write.sh
│   │   ├── check-profile-setup.sh
│   │   ├── safety-harness.sh
│   │   └── lib/
│   │       └── parse-tool-input.sh
│   └── settings.json                  # Original hook registration
└── tests/
    ├── approve-scratch-write/
    │   ├── run-tests.sh
    │   └── fixtures/
    │       ├── *.in.json
    │       └── *.expected.json
    ├── check-profile-setup/
    │   ├── run-tests.sh
    │   └── fixtures/
    └── safety-harness/
        ├── run-tests.sh
        └── fixtures/
```

The README should explain:
- These are original Claude Code hooks for reference
- They have been migrated to Vibe equivalents
- See `.vibe/` for the current Vibe implementation

---

## Migration Steps

### Step 1: Archive Original Hooks
```bash
# Create archive directory
mkdir -p SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/lib
mkdir -p SPECIFICATIONS/ARCHIVE/claude-hooks/tests/approve-scratch-write/fixtures
mkdir -p SPECIFICATIONS/ARCHIVE/claude-hooks/tests/check-profile-setup/fixtures
mkdir -p SPECIFICATIONS/ARCHIVE/claude-hooks/tests/safety-harness/fixtures

# Copy hook files
cp .claude/hooks/approve-scratch-write.sh SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/
cp .claude/hooks/check-profile-setup.sh SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/
cp .claude/hooks/safety-harness.sh SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/
cp .claude/hooks/lib/parse-tool-input.sh SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/lib/

# Copy test files
cp -r .claude/hooks/tests/approve-scratch-write/* SPECIFICATIONS/ARCHIVE/claude-hooks/tests/approve-scratch-write/
cp -r .claude/hooks/tests/check-profile-setup/* SPECIFICATIONS/ARCHIVE/claude-hooks/tests/check-profile-setup/
cp -r .claude/hooks/tests/safety-harness/* SPECIFICATIONS/ARCHIVE/claude-hooks/tests/safety-harness/

# Copy settings.json
cp .claude/settings.json SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/

# Create archive README
# (See template below)
```

### Step 2: Update permissions.json

Ensure `.vibe/config/permissions.json` has proper SCRATCH/ handling:

```json
{
  "permissions": {
    "Write": {
      "allow": [
        "SCRATCH/*",
        "SCRATCH/**",
        "*",
        "!*.env",
        "!.env.*"
      ],
      "confirm": [
        "*.env",
        ".env.*"
      ]
    }
  }
}
```

**Note:** The order may matter - put SCRATCH/ patterns first to ensure they match before more general patterns.

### Step 3: Create REFERENCE/vibe-safety.md

Create the comprehensive Vibe safety documentation as outlined above.

### Step 4: Update REFERENCE/safety-harness.md

Add a note at the top:

```markdown
> **NOTE:** This document describes the safety harness for the **Claude Code version** of the template.
> 
> For the **Mistral Vibe version**, see [vibe-safety.md](./vibe-safety.md).
> 
> The safety concepts are similar, but the implementation differs (hooks vs permissions).
```

### Step 5: Create Archive README

Create `SPECIFICATIONS/ARCHIVE/claude-hooks/README.md`:

```markdown
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
```

### Step 6: Test All Safety Mechanisms

Create `SCRATCH/test-safety.sh`:

```bash
#!/bin/bash
set -e

echo "Testing Vibe safety mechanisms..."

# Test 1: Verify permissions.json exists and is valid
echo "Test 1: permissions.json validity"
[ -f ".vibe/config/permissions.json" ] || { echo "FAIL: permissions.json missing"; exit 1; }
python3 -m json.tool .vibe/config/permissions.json > /dev/null || { echo "FAIL: permissions.json invalid"; exit 1; }
echo "PASS"

# Test 2: Verify SCRATCH/ patterns in permissions
echo "Test 2: SCRATCH/ patterns in permissions"
grep -q "SCRATCH/\*" .vibe/config/permissions.json || { echo "FAIL: SCRATCH/* pattern missing"; exit 1; }
grep -q "SCRATCH/\*\*" .vibe/config/permissions.json || { echo "FAIL: SCRATCH/** pattern missing"; exit 1; }
echo "PASS"

# Test 3: Verify all hook files archived
echo "Test 3: Hook files archived"
for file in approve-scratch-write.sh check-profile-setup.sh safety-harness.sh parse-tool-input.sh settings.json; do
  [ -f "SPECIFICATIONS/ARCHIVE/claude-hooks/.claude/hooks/${file}" ] || { echo "FAIL: ${file} not archived"; exit 1; }
done
echo "PASS"

# Test 4: Verify archive README exists
echo "Test 4: Archive README"
[ -f "SPECIFICATIONS/ARCHIVE/claude-hooks/README.md" ] || { echo "FAIL: Archive README missing"; exit 1; }
echo "PASS"

# Test 5: Verify safety documentation exists
echo "Test 5: Safety documentation"
[ -f "REFERENCE/vibe-safety.md" ] || { echo "FAIL: vibe-safety.md missing"; exit 1; }
echo "PASS"

# Test 6: Verify no .claude/ references in .vibe/
echo "Test 6: No .claude/ references in .vibe/"
if grep -r "\.claude/" .vibe/ 2>/dev/null; then
  echo "FAIL: Found .claude/ references in .vibe/"
  exit 1
fi
echo "PASS"

echo ""
echo "All safety tests passed!"
```

### Step 7: Manual Safety Testing

Manually test each safety mechanism:

1. **Dangerous command blocking**:
   ```bash
   rm -rf /
   # Should be blocked
   ```

2. **Confirmation for git reset**:
   ```bash
   git reset --hard
   # Should require confirmation
   ```

3. **SCRATCH/ write approval**:
   ```bash
   # In a skill or conversation, try:
   Write to SCRATCH/test-safety.md
   # Should succeed without prompt
   ```

4. **Profile setup check**:
   ```bash
   /check-profile-setup
   # Should check and report status
   ```

---

## Testing strategy

### Verification checklist

- [ ] All original hooks archived in SPECIFICATIONS/ARCHIVE/claude-hooks/
- [ ] Archive README created
- [ ] permissions.json updated with SCRATCH/ patterns
- [ ] REFERENCE/vibe-safety.md created
- [ ] REFERENCE/safety-harness.md updated
- [ ] Test script created and passing
- [ ] Manual safety tests pass
- [ ] All documentation is accurate

### Automated tests

Run `SCRATCH/test-safety.sh` - should pass all tests.

### Manual verification

1. **Hook archive**: Verify all hook files are archived
2. **Documentation**: Read through all new/updated documentation
3. **Permission patterns**: Verify SCRATCH/ patterns in permissions.json
4. **Safety mechanisms**: Test each safety mechanism manually

---

## Pre-commit checklist

Before creating PR for Phase 6:

- [ ] All original hooks archived
- [ ] Archive README created
- [ ] permissions.json updated with SCRATCH/ patterns
- [ ] REFERENCE/vibe-safety.md created
- [ ] REFERENCE/safety-harness.md updated
- [ ] REFERENCE/scratch-write-hook.md created
- [ ] Test script created and passing
- [ ] Manual safety tests pass
- [ ] All documentation is clear and accurate
- [ ] No secrets in archived files

---

## PR workflow

### Branch naming
```
feature/phase-6-safety-and-hooks
```

### PR title
```
Phase 6: Safety & Hooks - Complete hooks migration, finalize safety mechanisms
```

### PR description template
```markdown
## Summary
Completes the migration of Claude Code's hook system to Vibe's equivalent functionality, archives original hooks, and finalizes all safety mechanisms for the Vibe template.

## Changes

### New files
- `SPECIFICATIONS/ARCHIVE/claude-hooks/` - Archive of original Claude hooks
- `SPECIFICATIONS/ARCHIVE/claude-hooks/README.md` - Archive documentation
- `REFERENCE/vibe-safety.md` - Vibe-specific safety documentation
- `REFERENCE/scratch-write-hook.md` - SCRATCH/ write handling documentation
- `SCRATCH/test-safety.sh` - Safety test script

### Modified files
- `.vibe/config/permissions.json` - Added SCRATCH/ write patterns
- `REFERENCE/safety-harness.md` - Added note about Vibe version

### Archived files
- `.claude/hooks/approve-scratch-write.sh`
- `.claude/hooks/check-profile-setup.sh`
- `.claude/hooks/safety-harness.sh`
- `.claude/hooks/lib/parse-tool-input.sh`
- `.claude/settings.json`
- All hook test files

## Technical Details

### SCRATCH/ Write Handling
- **Claude:** PreToolUse hook (approve-scratch-write.sh)
- **Vibe:** Tool permissions in permissions.json
- **Patterns:** `SCRATCH/*` and `SCRATCH/**` in Write tool allow list

### Hook Archive
All original hooks preserved in `SPECIFICATIONS/ARCHIVE/claude-hooks/` for:
- Backward compatibility reference
- Rollback capability
- Documentation of original implementation

## Testing
- Verified all hooks archived
- Verified permissions.json updated
- Verified all safety documentation created
- Created and ran test script
- Manual safety tests pass

## Migration Complete
With this PR, the migration of all Claude-specific functionality to Vibe is **complete**:
- ✅ Configuration system (Phase 3)
- ✅ Agent/subagent definitions (Phase 4)
- ✅ Skills (Phase 5)
- ✅ Safety mechanisms (Phase 6)

Phase 7 will focus on validation, testing, and final polish.
```

### Review requirements
- Manual review focusing on:
  - Completeness of hook migration
  - Accuracy of safety documentation
  - Correctness of permission patterns
  - Archive completeness

---

## Edge cases and considerations

### Known risks

1. **Permission pattern limitations**: Vibe's pattern matching may not support all the patterns we need. Mitigation: Test thoroughly; have fallback plan (skill-level handling).

2. **SCRATCH/ write issues**: Vibe may have the same allowlist quirk as Claude. Mitigation: Test SCRATCH/ writes; be prepared to use skill-level handling if needed.

3. **Hook test compatibility**: The archived hook tests may not run in Vibe. Mitigation: Document this; tests are for reference only.

### Special cases

1. **Nested SCRATCH/ directories**: Ensure `SCRATCH/**` pattern covers nested directories.

2. **Relative vs absolute paths**: Ensure patterns work for both relative and absolute SCRATCH/ paths.

3. **Cross-platform paths**: Ensure patterns work on both Unix and Windows (if Vibe supports Windows).

### Open questions

1. Does Vibe's Write tool **support directory patterns** like `SCRATCH/*`?
2. Does Vibe have **any allowlist quirks** similar to Claude Code?
3. Can we **test permission patterns** before relying on them?
4. Are there any **Vibe-specific safety features** we should incorporate?

---

## Vibe vs Claude: Safety Model Comparison

### Key Differences

| Aspect | Claude Code | Mistral Vibe | Migration Impact |
|--------|-------------|--------------|-----------------|
| Safety mechanism | Hooks (separate scripts) | Tool permissions (integrated) | Paradigm shift |
| Hook registration | settings.json | permissions.json | Configuration change |
| Execution | Separate process per hook | Integrated in tool system | Simpler, less flexible |
| SCRATCH/ handling | Custom hook | Permission patterns | Simpler in Vibe |
| SessionStart | Hook | Skill | Manual invocation |
| Flexibility | High (arbitrary logic) | Medium (pattern-based) | Some features may not translate |

### Preserved Safety Features

1. **Dangerous command blocking** - rm -rf, dd, mkfs, DROP TABLE, etc.
2. **Confirmation for risky commands** - git reset --hard, git push --force, chmod 777
3. **SCRATCH/ write auto-approval** - Enables automated workflows
4. **Profile setup check** - Ensures personalization

### New Safety Considerations

1. **Permission patterns** - May be more maintainable than hook scripts
2. **Integrated model** - Less indirection, easier to understand
3. **Explicit invocation** - User must invoke safety checks (no automatic SessionStart)

---

## Related documentation

- [Phase 1: Research and Foundation](./01-research-and-planning.md) - Prerequisite
- [Phase 2: Documentation Migration](./02-documentation-migration.md) - Prerequisite
- [Phase 3: Configuration System](./03-configuration-system.md) - Prerequisite
- [Phase 4: Agent & Subagent Migration](./04-agent-subagent-migration.md) - Prerequisite
- [Phase 5: Skills Migration](./05-skills-migration.md) - Prerequisite
- [Phase 7: Validation and Completion](./07-validation-and-completion.md) - Next phase
- [Root AGENTS.md](../AGENTS.md) - Implementation library
- [ORIGINAL_IDEA/project-outline.md](../ORIGINAL_IDEA/project-outline.md) - Master specification

---

## Notes

This phase **completes the functional migration** of all Claude-specific features to Vibe equivalents. After this phase, the template should work with Vibe, though we may need Phase 7 to polish and validate everything end-to-end.

The key decisions in this phase are:

1. **How to handle SCRATCH/ writes** - Use permissions or skill-level handling
2. **What to archive** - All original hooks and tests
3. **Documentation strategy** - Create Vibe-specific docs while preserving Claude docs with notes

**Key principle:** The safety mechanisms are **critical** to the template's usability. They prevent accidents and enable automation. Take care to ensure all safety features are properly migrated and tested.

By the end of this phase, we should have **feature parity** with the Claude version, using Vibe's native mechanisms.

---

## 📋 Implementation Notes

### What Was Completed

**Hooks Archived:**
- `.claude/hooks/approve-scratch-write.sh` - Write tool auto-approval hook
- `.claude/hooks/check-profile-setup.sh` - Session start profile setup hook  
- `.claude/hooks/safety-harness.sh` - Main safety harness hook
- `.claude/hooks/lib/parse-tool-input.sh` - Tool input parsing library
- `.claude/settings.json` - Original Claude settings configuration

**Files Created:**
- `REFERENCE/vibe-safety.md` - Vibe-specific safety documentation (231 lines)
- `SPECIFICATIONS/ARCHIVE/06-safety-and-hooks.md` - Archived spec with implementation notes
- Updated `.vibe/config/permissions.json` with comprehensive safety rules

**Files Updated:**
- `REFERENCE/safety-harness.md` - Updated for Vibe compatibility
- `REFERENCE/scratch-write-hook.md` - Updated for Vibe compatibility  
- `AGENTS.md` - Updated with Phase 6 completion status

**Archive Created:**
- `SPECIFICATIONS/ARCHIVE/claude-hooks/` - Complete archive of original Claude hooks
  - All hook scripts preserved with original structure
  - All test fixtures and run scripts included
  - README.md explaining archive structure

### Key Adaptations

**Permission Translation:**
- Claude's `approve-scratch-write.sh` → Vibe's SCRATCH/* and SCRATCH/** allow patterns
- Claude's `safety-harness.sh` → Vibe's comprehensive permissions.json deny/confirm patterns
- Claude's hook-based intercept → Vibe's built-in tool permission system

**Safety Model Differences:**
- **Claude**: External bash scripts that can execute arbitrary logic
- **Vibe**: Declarative JSON configuration with built-in permission levels
- **Trust Model**: Vibe relies on trust-based architecture (permissions are honored by design)

### Verification
- All original hooks archived with complete directory structure
- Permission configuration covers all safety cases from original hooks
- Documentation updated to explain Vibe's approach vs Claude's approach
- Backward compatibility maintained by preserving .claude/ directory

### Known Limitations
- **Catch-22 Problem**: Vibe's skill invocation model vs Claude's automatic hooks for first-use detection
- **Proactive Prompting**: Some Claude hook behaviors (like proactive PR review suggestions) don't have direct equivalents

### PR Reference
- **PR #6**: https://github.com/mannepanne/useful-vibe-assets-template/pull/6
- **Commit**: 82f906b - Phase 6: Safety Harness & Hooks Migration - Complete hook migration and safety documentation
