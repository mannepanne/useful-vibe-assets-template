# Migration Test Cases

> **Purpose:** Document manual test cases for verifying the Vibe migration.

---

## Test Suite Overview

These test cases verify that the migration from Claude Code to Mistral Vibe is complete and functional.

### Prerequisites
- Vibe installed and configured
- GitHub CLI (`gh`) installed and authenticated
- Project cloned locally
- Test repository available for PR testing

---

## Test Cases

### TC-1: Basic Vibe Functionality
**Description:** Verify Vibe can start and load the project.

**Steps:**
1. Navigate to project directory
2. Start Vibe
3. Verify Vibe loads without errors

**Expected Result:**
- Vibe starts successfully
- No errors about missing files or configuration

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-2: Configuration Loading
**Description:** Verify Vibe loads the .vibe/ configuration.

**Steps:**
1. Start Vibe in project
2. Check that Vibe recognizes the configuration

**Expected Result:**
- .vibe/config/permissions.json is loaded
- .vibe/config/project-config.json is loaded
- No configuration errors

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-3: Tool Permissions
**Description:** Verify permission system works correctly.

**Steps:**
1. Test blocked commands (should be blocked):
   ```bash
   rm -rf /
   ```
2. Test confirmation-required commands (should ask for confirmation):
   ```bash
   git reset --hard
   ```
3. Test allowed commands (should run silently):
   ```bash
   git status
   ```

**Expected Result:**
- Dangerous commands are blocked
- Sensitive commands require confirmation
- Safe commands run without interruption

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-4: SCRATCH/ Directory Writes
**Description:** Verify SCRATCH/ directory writes work without prompts.

**Steps:**
1. From within a Vibe session, attempt to write to SCRATCH/:
   ```
   Write to SCRATCH/test-file.md
   ```

**Expected Result:**
- Write succeeds without permission prompt
- File is created in SCRATCH/ directory

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-5: Profile Setup Check
**Description:** Verify the profile setup check works.

**Steps:**
1. Start Vibe in project
2. Check if profile setup is triggered

**Expected Result:**
- Profile setup check runs if .vibe/COLLABORATION/personal-profile.local.md doesn't exist
- No setup prompt if profile is already configured

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-6: Agent Spawning
**Description:** Verify subagent spawning works with task tool.

**Steps:**
1. From within a Vibe session, spawn a subagent:
   ```
   task(agent="code-reviewer", task="Introduce yourself")
   ```

**Expected Result:**
- Subagent is spawned successfully
- Returns expected response
- No errors

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-7: Review PR Skill
**Description:** Verify /review-pr skill works end-to-end.

**Steps:**
1. Create a test PR in the repository
2. Run: `/review-pr <PR_NUMBER>`

**Expected Result:**
- Gate logic checks configuration
- Triage runs successfully
- Appropriate review tier is executed
- Comment is posted to PR (if configured)

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-8: Review PR Team Skill
**Description:** Verify /review-pr-team skill works end-to-end.

**Steps:**
1. Create a test PR in the repository
2. Run: `/review-pr-team <PR_NUMBER>`

**Expected Result:**
- Gate logic checks configuration
- Team of agents is spawned
- Discussion is orchestrated
- Comprehensive comment is posted

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-9: Review Spec Skill
**Description:** Verify /review-spec skill works.

**Steps:**
1. Run: `/review-spec SPECIFICATIONS/01-research-and-planning.md`

**Expected Result:**
- Gate logic checks configuration
- Spec review agents are spawned
- Spec is reviewed thoroughly
- Findings are returned

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

### TC-10: Documentation Completeness
**Description:** Verify all documentation has been properly migrated.

**Steps:**
1. Check that all .vibe/ files exist and are properly structured
2. Check that AGENTS.md files exist in all required locations
3. Check that no CLAUDE.md references exist in Vibe-specific files
4. Check that archive contains all original files

**Expected Result:**
- All required files are present
- Documentation structure is consistent
- Archive is complete

**Status:** [ ] Not tested / [ ] Pass / [ ] Fail

---

## Automated Test Suite

For automated testing, run:

```bash
# Full migration test
./SCRATCH/test-full-migration.sh

# Review workflow tests
./SCRATCH/test-review-workflows.sh
```

---

## Rollback Procedure

In case migration issues are discovered:

1. **Minor issues:** Fix forward and continue testing
2. **Major issues:** Restore from archive:
   ```bash
   # Restore original files from archive
   cp -r SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-originals/.claude/* .claude/
   cp SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-originals/SPECIFICATIONS_CLAUDE.md SPECIFICATIONS/CLAUDE.md
   ```
3. **Critical issues:** Revert to pre-migration commit

---

## Test Execution Notes

- **Manual tests** (TC-1 through TC-9) require Vibe session
- **Automated tests** can be run from command line
- **End-to-end testing** requires GitHub repository access
- **Performance testing** is out of scope for this migration

## Last Updated

**Date:** 2026-06-20  
**Phase:** Phase 7 (Validation and Completion)