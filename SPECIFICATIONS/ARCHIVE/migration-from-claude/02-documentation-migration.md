# Phase 2: Documentation Migration

**Phase number:** 2
**Phase name:** Documentation Migration
**Estimated timeframe:** 1 session
**Dependencies:** Phase 1 (Research and Foundation) complete
**Status:** ✅ COMPLETED - Merged in PR #2 on 2026-06-18

---

## Phase overview

This phase focuses on **renaming and updating all CLAUDE.md files to AGENTS.md** throughout the project. We'll also update all internal references to point to the new filenames and structure.

This is a **mechanical but important phase** - it establishes the new naming convention and ensures all cross-references are correct before we start migrating the actual functionality.

---

## Implementation Notes

**Completed on:** 2026-06-18
**PR:** #2 - Phase 2: Complete CLAUDE.md to AGENTS.md migration
**Files changed:** 17 files changed, 922 insertions(+), 381 deletions(-)

### What Was Actually Done

#### Files Created
- `.vibe/COLLABORATION/` directory with 7 files:
  - `AGENTS.md` - Collaboration reference library (adapted from .claude/COLLABORATION/CLAUDE.md)
  - `debugging-mindset.md` - Copied from .claude/COLLABORATION/
  - `documentation-standards.md` - Updated references to AGENTS.md
  - `personal-profile.md` - Updated "Claude" → "Vibe" references
  - `product-management-mode.md` - Updated all references
  - `profile-setup-flow.md` - Fully rewritten for Vibe (no SessionStart hook)
  - `technology-preferences.md` - Updated references to AGENTS.md
- `REFERENCE/AGENTS.md` - New reference library index (adapted from REFERENCE/CLAUDE.md)
- `REFERENCE/TEMPLATE-UPDATES/AGENTS.md` - New template updates index (adapted from REFERENCE/TEMPLATE-UPDATES/CLAUDE.md)
- `REFERENCE/decisions/AGENTS.md` - New ADR index (adapted from REFERENCE/decisions/CLAUDE.md)
- `SPECIFICATIONS/ARCHIVE/AGENTS.md` - New archived specs index (adapted from SPECIFICATIONS/ARCHIVE/CLAUDE.md)

#### Files Modified
- `README.md` - Updated migration status to Phase 2 completion
- `REFERENCE/troubleshooting.md` - CLAUDE.md → AGENTS.md reference
- `REFERENCE/pr-review-workflow.md` - CLAUDE.md → AGENTS.md reference
- `TEMPLATE-INSTRUCTIONS.md` - Comprehensive update of all Claude → Vibe references
- `.vibe/COLLABORATION/profile-setup-flow.md` - Rewritten for Vibe's tool model
- `.vibe/COLLABORATION/product-management-mode.md` - Updated references
- `.vibe/COLLABORATION/AGENTS.md` - Updated references

#### Files Deleted
- Root `CLAUDE.md`
- `REFERENCE/CLAUDE.md` (renamed to AGENTS.md)
- `SPECIFICATIONS/CLAUDE.md`

#### Files Preserved
- `.claude/` directory - Kept intact for backward compatibility
- `SPECIFICATIONS/ARCHIVE/CLAUDE.md` - Historical archive of original Claude spec

### Key Adaptations Made

1. **SessionStart Hook Removal**: All references to Claude's SessionStart hook were replaced with Vibe equivalents:
   - Manual invocation via skills
   - First-use detection in skills
   - Explicit instructions in AGENTS.md files

2. **Path Updates**: All `.claude/` references in active documentation updated to `.vibe/` (historical references in archive kept as-is)

3. **Tool Model Changes**: Documentation updated to reflect:
   - `SpawnAgent` → `task` tool with subagents
   - Slash commands → `skill` tool
   - Hooks → Declarative permissions

4. **Naming Updates**: "Claude" → "Vibe" in active documentation (historical context preserved in archives)

### Differences from Spec

The original spec planned to:
- Create `SPECIFICATIONS/ARCHIVE/claude-originals/` directory with all original CLAUDE.md files

What we actually did:
- Kept `.claude/` directory intact for backward compatibility
- Kept `SPECIFICATIONS/ARCHIVE/CLAUDE.md` as historical reference
- Did NOT create a separate claude-originals/ subdirectory

Rationale: The `.claude/` directory serves as the archive for the original Claude files, and SPECIFICATIONS/ARCHIVE/CLAUDE.md is a historical artifact that documents the original structure. This provides backward compatibility while still achieving the migration goal.

### Verification

- ✅ No remaining CLAUDE.md references in working files (excluding .claude/ and SPECIFICATIONS/ARCHIVE/)
- ✅ All internal links verified and working
- ✅ Documentation reads naturally with new names
- ✅ PR reviewed and merged successfully

### Open Items (Deferred to Later Phases)

- **`.gitignore` updates**: The .gitignore file still contains only `.claude/` entries. `.vibe/` entries need to be added:
  ```
  .vibe/session-state/
  .vibe/project-config.local.json
  .vibe/COLLABORATION/personal-profile.local.md
  ```
  **Note**: This was identified in the original spec but not implemented in Phase 2. To be addressed in Phase 3 (Configuration System).

---

## Scope and deliverables

### In scope

- [x] Rename root `CLAUDE.md` → `AGENTS.md`
- [x] Rename `.claude/CLAUDE.md` → `.vibe/AGENTS.md` (Note: .vibe/AGENTS.md already existed from Phase 1, but .claude/CLAUDE.md was deleted)
- [x] Rename `SPECIFICATIONS/CLAUDE.md` → `SPECIFICATIONS/AGENTS.md` (Already existed from Phase 1, SPECIFICATIONS/CLAUDE.md deleted)
- [x] Update all internal references from CLAUDE.md to AGENTS.md
- [x] Update all documentation to reference `.vibe/` instead of `.claude/`
- [x] Update README.md to reference new structure
- [x] Update TEMPLATE-INSTRUCTIONS.md to reference new structure
- [x] Verify all links work in the new structure
- [x] Archive original CLAUDE.md files in `SPECIFICATIONS/ARCHIVE/` for reference (Note: Kept SPECIFICATIONS/ARCHIVE/CLAUDE.md as historical, did not create claude-originals/ subdirectory)

### Out of scope

- Actual content changes to the CLAUDE.md files (happens in later phases)
- Migration of hooks, skills, or agents (happens in Phases 3-6)
- Configuration migration (happens in Phase 3)
- Any functional changes beyond renaming

### Acceptance criteria

- [x] All CLAUDE.md files renamed to AGENTS.md
- [x] All internal references updated (grep confirms no remaining CLAUDE.md references except in archive)
- [x] Root AGENTS.md exists and is properly structured
- [x] .vibe/AGENTS.md exists with migrated content
- [x] SPECIFICATIONS/AGENTS.md exists with migrated content
- [x] README.md updated to reference AGENTS.md files
- [x] TEMPLATE-INSTRUCTIONS.md updated to reference AGENTS.md files
- [x] All links between documentation files work
- [x] Original files archived in SPECIFICATIONS/ARCHIVE/

---

## Technical approach

### File Mapping

This phase implements a **direct mapping** from Claude's naming convention to Vibe's convention:

| Old Path | New Path | Action |
|----------|----------|--------|
| `CLAUDE.md` | `AGENTS.md` | Rename |
| `.claude/CLAUDE.md` | `.vibe/AGENTS.md` | Rename (directory created in Phase 1) |
| `SPECIFICATIONS/CLAUDE.md` | `SPECIFICATIONS/AGENTS.md` | Rename (already done in Phase 1) |

### Reference Updates

We need to update references in these key files:

1. **README.md**
   - References to `.claude/` → `.vibe/`
   - References to `CLAUDE.md` → `AGENTS.md`
   - Update the directory structure diagram

2. **TEMPLATE-INSTRUCTIONS.md**
   - References to `CLAUDE.md` → `AGENTS.md`
   - References to `.claude/` → `.vibe/`
   - Update example prompts

3. **All .md files in REFERENCE/**
   - Update any references to CLAUDE.md files
   - Update any references to .claude/ directory

4. **All .md files in SPECIFICATIONS/**
   - Update references (though SPECIFICATIONS/AGENTS.md is already updated)

5. **All .md files in .claude/** (to be migrated to .vibe/)
   - Update internal references within these files

### Content Preservation Strategy

**Principle:** We're doing a rename, not a rewrite. The content of CLAUDE.md files should remain **largely unchanged** during this phase. We're just:
1. Renaming the files
2. Updating internal references to the new names
3. Updating directory paths from `.claude/` to `.vibe/`

**What stays the same:**
- Collaboration principles
- Rules of engagement
- Project-specific content (once de-templatified)
- Documentation organization patterns
- Lifecycle-based documentation philosophy

**What changes:**
- File names (CLAUDE.md → AGENTS.md)
- Directory references (.claude/ → .vibe/)
- Tool-specific references (Claude → Vibe)

### Archive Strategy

To maintain backward compatibility and allow rollback if needed:

1. Before renaming, copy all CLAUDE.md files to `SPECIFICATIONS/ARCHIVE/claude-originals/`
2. Create a `SPECIFICATIONS/ARCHIVE/claude-originals/CLAUDE.md` with the original root file
3. Create `SPECIFICATIONS/ARCHIVE/claude-originals/.claude/CLAUDE.md` with the original
4. Add a README in that directory explaining these are originals for reference

This way, the original files are preserved but clearly marked as historical.

---

## Vibe vs Claude: Documentation Philosophy

### What's Different

| Aspect | Claude Code | Mistral Vibe | Migration Note |
|--------|-------------|--------------|----------------|
| Primary nav file | `CLAUDE.md` | `AGENTS.md` | Simple rename |
| Auto-load pattern | Same | Same | No change needed |
| File purpose | "Library index" | "Library index" | Same concept |
| Content guidelines | <300 lines, lazy-load details | Same | No change needed |

### What's the Same

- The **lifecycle-based documentation** pattern works identically
- The **lazy-loading** approach (keep CLAUDE.md/AGENTS.md lean) works the same
- The **two-level structure** (root + .vibe/) is analogous
- The **documentation organization** (SPECIFICATIONS/, REFERENCE/, SCRATCH/) is unchanged

### Vibe-Specific Documentation to Add

While we're updating references, we should **add Vibe-specific sections** to the migrated AGENTS.md files:

1. **Vibe-specific tools section** - Document Vibe's `skill`, `task`, `web_search`, etc.
2. **Subagent usage** - How to use Vibe's subagent system
3. **MCP server integration** - If we incorporate MCP (decision from Phase 1)
4. **Connector usage** - If we use connectors (decision from Phase 1)

However, these content additions are **out of scope for Phase 2** - we'll add them in their respective phases (Phase 4 for subagents, Phase 5 for skills).

---

## Migration Steps

### Step 1: Create Archive
```bash
mkdir -p SPECIFICATIONS/ARCHIVE/claude-originals/.claude/
cp CLAUDE.md SPECIFICATIONS/ARCHIVE/claude-originals/CLAUDE.md
cp .claude/CLAUDE.md SPECIFICATIONS/ARCHIVE/claude-originals/.claude/CLAUDE.md
cp SPECIFICATIONS/CLAUDE.md SPECIFICATIONS/ARCHIVE/claude-originals/SPECIFICATIONS_CLAUDE.md
```

### Step 2: Create Archive README
Create `SPECIFICATIONS/ARCHIVE/claude-originals/README.md` explaining these are originals for backward compatibility reference.

### Step 3: Rename Files
```bash
# Root level
git mv CLAUDE.md AGENTS.md

# .vibe/ level (assuming Phase 1 created .vibe/)
git mv .claude/CLAUDE.md .vibe/AGENTS.md

# SPECIFICATIONS/ level (already done in Phase 1, but verify)
# SPECIFICATIONS/CLAUDE.md should already be SPECIFICATIONS/AGENTS.md
```

### Step 4: Update References
Use grep to find all CLAUDE.md references:
```bash
grep -r "CLAUDE\.md" --include="*.md" . | grep -v "ARCHIVE/claude-originals/" | grep -v ".git/"
```

Update each file to change:
- `CLAUDE.md` → `AGENTS.md`
- `.claude/` → `.vibe/`
- Any other Claude-specific references

### Step 5: Update README.md
Update the directory structure diagram and all references:
- Old: `.claude/` → New: `.vibe/`
- Old: `CLAUDE.md` → New: `AGENTS.md`
- Old: "Claude reads" → New: "Vibe reads" (or keep generic)

### Step 6: Update TEMPLATE-INSTRUCTIONS.md
Update all references to CLAUDE.md and .claude/:
- Example prompts that reference CLAUDE.md
- Directory structure mentions
- Any Claude-specific instructions

### Step 7: Verify All Links
```bash
# Find all markdown links
grep -r "\[.*\](.*\.md)" --include="*.md" . | grep -v ".git/"

# Manually verify each link works
```

---

## Testing strategy

### Automated verification

Create a simple verification script (SCRATCH/verify-links.sh):
```bash
#!/bin/bash
# Check for remaining CLAUDE.md references (excluding archive)
if grep -r "CLAUDE\.md" --include="*.md" . | grep -v "ARCHIVE/claude-originals/" | grep -v ".git/"; then
    echo "ERROR: Found CLAUDE.md references outside archive"
    exit 1
fi

# Check for remaining .claude/ references (excluding archive)
if grep -r "\.claude/" --include="*.md" . | grep -v "ARCHIVE/claude-originals/" | grep -v ".git/"; then
    echo "ERROR: Found .claude/ references outside archive"
    exit 1
fi

echo "All references updated successfully"
```

### Manual verification

1. **Link testing**: Open each markdown file and click/test each link
2. **Documentation flow**: Verify the documentation narrative makes sense with new names
3. **Consistency check**: Ensure all files use the same naming convention

### Acceptance review

Use manual review (since /review-spec may not be available yet) to verify:
1. All CLAUDE.md files renamed to AGENTS.md
2. All references updated
3. Archive contains originals
4. All links work
5. Documentation reads naturally with new names

---

## Pre-commit checklist

Before creating PR for Phase 2:

- [x] All CLAUDE.md files renamed to AGENTS.md
- [x] Archive preserved (kept .claude/ directory and SPECIFICATIONS/ARCHIVE/CLAUDE.md)
- [x] All CLAUDE.md references updated (grep confirms)
- [x] All .claude/ references updated to .vibe/ in active files
- [x] README.md updated
- [x] TEMPLATE-INSTRUCTIONS.md updated
- [x] All internal links verified
- [x] Root AGENTS.md exists and loads correctly
- [x] .vibe/AGENTS.md exists (from Phase 1)
- [x] SPECIFICATIONS/AGENTS.md exists (from Phase 1)
- [x] No broken links
- [x] No secrets in new files

---

## PR workflow

### Branch naming
```
feature/phase-2-documentation-migration
```

### PR title
```
Phase 2: Documentation Migration - CLAUDE.md to AGENTS.md rename
```

### PR description template
```markdown
## Summary
Renames all CLAUDE.md files to AGENTS.md throughout the project to align with Vibe's naming conventions. Updates all internal references and preserves originals in archive.

## Changes
- Renamed `CLAUDE.md` → `AGENTS.md` (root)
- Renamed `.claude/CLAUDE.md` → `.vibe/AGENTS.md`
- Renamed `SPECIFICATIONS/CLAUDE.md` → `SPECIFICATIONS/AGENTS.md` (already done in Phase 1)
- Updated all internal references from CLAUDE.md to AGENTS.md
- Updated all directory references from .claude/ to .vibe/
- Updated README.md with new structure
- Updated TEMPLATE-INSTRUCTIONS.md with new references
- Created SPECIFICATIONS/ARCHIVE/claude-originals/ with original files

## Testing
- Ran grep to verify no remaining CLAUDE.md references (except archive)
- Manually verified all links work
- Confirmed documentation reads naturally with new names

## Files Changed
[List all changed files]

## Backward Compatibility
Original CLAUDE.md files preserved in SPECIFICATIONS/ARCHIVE/claude-originals/ for reference.
```

### Review requirements
- Manual review focusing on:
  - Completeness of reference updates
  - Link integrity
  - Documentation clarity with new names

---

## Edge cases and considerations

### Known risks
- **Broken links in existing documentation**: Some files might reference CLAUDE.md in ways we don't catch with simple grep. Mitigation: Manual verification of all .md files.
- **Case sensitivity**: Some files might use different case (Claude.md, claude.md). Mitigation: Use case-insensitive grep.
- **Archive contamination**: Accidentally updating references in archived files. Mitigation: Exclude ARCHIVE/ from all search-replace operations.

### Special cases to handle
1. **Files in .gitignore**: The .gitignore file has entries for .claude/ files. These need to be duplicated for .vibe/:
   ```
   # Add alongside existing .claude/ entries
   .vibe/session-state/
   .vibe/project-config.local.json
   .vibe/COLLABORATION/personal-profile.local.md
   ```

2. **JSON configuration files**: Any JSON files in .claude/ that reference paths may need updating.

3. **Shell scripts**: The hooks in .claude/hooks/ reference .claude/ paths. These will be migrated in Phase 6, but we should note them.

4. **Markdown code blocks**: Some documentation might show example .claude/ paths in code blocks. These should be updated to .vibe/.

### Files that need special attention
- `.gitignore` - needs .vibe/ entries
- Any JSON config files
- Shell scripts with hardcoded paths
- Markdown files with code examples

---

## Vibe-Specific Content Updates (Future Phases)

While Phase 2 focuses only on renaming, we should **flag content that needs Vibe-specific updates in later phases**:

### For Phase 3 (Configuration)
- Update permission model documentation in AGENTS.md files
- Add Vibe configuration examples

### For Phase 4 (Subagents)
- Update agent spawning documentation
- Add Vibe subagent usage patterns

### For Phase 5 (Skills)
- Update slash command references to Vibe skill invocation
- Add Vibe skill usage examples

### For Phase 6 (Safety)
- Update hooks documentation to Vibe's permission model

---

## Related documentation

- [Phase 1: Research and Foundation](./01-research-and-planning.md) - Prerequisite (✅ COMPLETED)
- [Root AGENTS.md](../AGENTS.md) - Implementation library (✅ COMPLETED in Phase 1)
- [ORIGINAL_IDEA/project-outline.md](../ORIGINAL_IDEA/project-outline.md) - Master specification
- [.vibe/AGENTS.md](../.vibe/AGENTS.md) - Vibe-specific collaboration principles (✅ COMPLETED in Phase 1)
- [SPECIFICATIONS/AGENTS.md](../AGENTS.md) - Migration implementation library (✅ COMPLETED in Phase 1, updated in Phase 2)

---

## Notes

This phase is **primarily mechanical** - we're doing a systematic rename and reference update. The key to success is:

1. **Be systematic** - Use grep to find all references
2. **Be careful** - Don't update files in the archive
3. **Verify thoroughly** - Test all links after changes
4. **Preserve history** - Keep originals in archive

**Important:** This phase does NOT change the functionality or content of the documentation - it only changes the names and references. All the collaboration principles, rules, and patterns remain the same; they're just in files with different names.

This makes the migration **reversible** - if we need to go back to Claude, we can simply restore from the archive.
