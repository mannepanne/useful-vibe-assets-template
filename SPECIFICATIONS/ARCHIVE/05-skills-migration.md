# Phase 5: Skills Migration

**Phase number:** 5
**Phase name:** Skills Migration
**Estimated timeframe:** 2-3 sessions
**Dependencies:** Phase 1 (Research and Foundation), Phase 2 (Documentation Migration), Phase 3 (Configuration System), Phase 4 (Agent & Subagent Migration) complete
**Status:** ✅ COMPLETED

---

## Phase Overview

This phase successfully converted **Claude's slash-command skills** to **Vibe's skill system**. All skill files were migrated from `.claude/skills/` to `.vibe/skills/` and adapted to use Vibe's `task` tool for subagent delegation instead of Claude's `SpawnAgent`.

This phase **completed the functional migration** of the automated review system.

---

## Implementation Summary

### Completed Deliverables

✅ **All skill files migrated from `.claude/skills/` to `.vibe/skills/`:**
- `review-pr/SKILL.md` - PR review dispatcher
- `review-pr-team/SKILL.md` - Full multi-perspective team review
- `review-spec/SKILL.md` - Spec review workflow
- `review-gate.md` - Shared gate logic
- `post-review-follow-through.md` - Follow-through protocol

✅ **New skills created:**
- `check-profile-setup/SKILL.md` - Replaces SessionStart hook functionality
- `setup-profile/SKILL.md` - Guides user through profile setup

✅ **Frontmatter converted to Vibe format:**
- Removed `disable-model-invocation` field (not needed in Vibe)
- Changed `argument-hint` to `arguments` array with structured format
- Preserved `user-invocable: true` and `name` fields
- Added `pattern` validation for PR numbers

✅ **Agent spawning converted:**
- All `SpawnAgent` calls replaced with Vibe's `task` tool
- Syntax: `task: {"agent": "name", "task": "description"}`
- Maintained parallel execution where applicable

✅ **Gate logic adapted:**
- All skills reference `.vibe/skills/review-gate.md`
- Configuration paths updated from `.claude/` to `.vibe/`
- Persistence logic preserved (local config file support)

✅ **Skills library index updated:**
- `.vibe/skills/AGENTS.md` created with comprehensive documentation
- All skills indexed with status, purpose, and invocation info

✅ **Verification script created:**
- `SCRATCH/verify-skills.sh` with comprehensive checks
- All verification tests passing

---

## Key Migration Decisions

### Agent Teams Adaptation

**Challenge:** Claude Code had an experimental agent teams feature that allowed spawned agents to discuss with each other in real-time. Vibe does not have this feature.

**Solution:** Instead of real-time discussion, we:
1. Spawn multiple independent subagents via `task` tool in parallel
2. Collect all results
3. Explicitly synthesize findings in the parent skill

**Trade-offs:**
- **Lost:** Real-time debate and consensus-building between agents
- **Gained:** Parallel execution, explicit synthesis control, clearer result handling
- **Result:** Equivalent quality with different execution model

### prReviewMode Setup Challenge

**Challenge:** Unlike Claude's SessionStart hook that automatically prompted for setup, Vibe skills only run when explicitly invoked. This creates a catch-22 where users never discover the skills.

**Solution:** Implemented three approaches:
1. **First-use detection:** Each review skill checks the gate on first invocation
2. **Explicit setup skills:** `/check-profile-setup` and `/setup-profile` as user-invocable skills
3. **Documentation:** Strong references in AGENTS.md and other documentation

### Path References

All file path references were updated:
- `.claude/` → `.vibe/`
- `.claude/config/` → `.vibe/config/`
- `.claude/agents/` → `.vibe/agents/`
- `CLAUDE.md` → `AGENTS.md` (already done in Phase 2)

Some documentation references to the original `.claude/skills/` directory are preserved in the archive reference section for backward compatibility.

---

## Files Changed

### New Files Created

```
.vibe/skills/
├── AGENTS.md (updated)
├── review-pr/
│   └── SKILL.md
├── review-pr-team/
│   └── SKILL.md
├── review-spec/
│   └── SKILL.md
├── review-gate.md
├── post-review-follow-through.md
├── check-profile-setup/
│   └── SKILL.md
└── setup-profile/
    └── SKILL.md

SCRATCH/
└── verify-skills.sh
```

### Files Modified

- `.vibe/skills/AGENTS.md` - Updated from placeholder to comprehensive index with all migrated skills

### Files Preserved (Backward Compatibility)

- `.claude/skills/review-pr/SKILL.md` (original)
- `.claude/skills/review-pr-team/SKILL.md` (original)
- `.claude/skills/review-spec/SKILL.md` (original)
- `.claude/skills/review-gate.md` (original)
- `.claude/skills/post-review-follow-through.md` (original)

---

## Vibe vs Claude: Key Differences


| Aspect | Claude Code | Mistral Vibe | Migration Impact |
|--------|-------------|--------------|-----------------|
| Invocation | Slash command `/name` | `skill` tool: `skill(name="name")` | Users can use either syntax if Vibe supports slash commands |
| Definition | Markdown + YAML frontmatter | SKILL.md file with frontmatter | Structure preserved, minor format updates |
| Arguments | `argument-hint` array | `arguments` array with name, description, pattern | More structured argument definition |
| Agent spawning | `SpawnAgent` action | `task` tool with JSON | Updated all spawning syntax |
| Model invocation | `disable-model-invocation` flag | Not needed | Removed from all frontmatter |
| Agent teams | Experimental feature with discussion | Not available | Adapted to parallel independent agents with explicit synthesis |
| Hooks | SessionStart, PreInvoke, etc. | Not available | Replaced with explicit skills (`check-profile-setup`) |

---

## Verification

All acceptance criteria met:

✅ All skill files migrated from `.claude/skills/` to `.vibe/skills/`
✅ All skills use Vibe skill format with proper frontmatter
✅ `.vibe/skills/AGENTS.md` exists and indexes all skills
✅ Agent spawning converted to use `task` tool
✅ Gate logic adapted and shared across all review skills
✅ New skills created (check-profile-setup, setup-profile)
✅ All internal references updated from `.claude/` to `.vibe/`
✅ All skills have proper error handling and validation
✅ Verification script created and passing

---

## Lessons Learned

### Vibe's Strengths

1. **Explicit Control:** The `task` tool provides explicit, programmatic control over subagent delegation
2. **Parallel Execution:** Native support for parallel task execution
3. **Result Handling:** Results from `task` calls can be processed programmatically
4. **Cleaner Separation:** Skills are more explicitly separated from the main conversation

### Challenges

1. **No Agent Teams:** Vibe doesn't have Claude's experimental agent teams feature. The adaptation using parallel tasks and explicit synthesis works well.
2. **No Hooks:** The lack of hook system means some automatic behaviors (like SessionStart) need to be replaced with explicit skills.
3. **Documentation References:** Need to be careful about updating all internal references when migrating.

### Recommendations for Future Migrations

1. **Use the task tool liberally:** It's Vibe's primary mechanism for subagent delegation
2. **Explicit synthesis is good:** Even without real-time discussion, explicit synthesis of parallel results provides excellent quality
3. **Document the differences:** Each skill should have a Vibe-Specific Notes section explaining adaptations
4. **Maintain backward compatibility:** Keep original files for reference where possible

---

## Next Steps

Phase 6 (Safety and Hooks) will handle:
- Migration of any remaining hooks (if applicable)
- Safety harness configuration
- Permission system finalization

Phase 7 (Validation and Completion) will handle:
- End-to-end testing
- Final verification
- Documentation finalization
- Backward compatibility check

---

*Implementation completed on: 2026-06-18*
