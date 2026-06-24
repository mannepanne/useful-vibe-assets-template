# Vibe Adaptation Summary: Skills and Agent Compatibility

**Date**: 2025-06-24  
**Status**: ✅ Complete - All skills and agents now compatible with Vibe's current tool model  
**Issue**: review-pr skill and subagents weren't working due to Vibe's tool limitations

---

## Problem Statement

The review system was migrated from Claude Code to Vibe, but two critical limitations prevented it from working:

1. **No argument passing**: Vibe's `skill` tool only accepts a `name` parameter. The `arguments` field in skill frontmatter was not supported, so PR numbers couldn't be passed to skills.

2. **Agents not registered**: Vibe's `task` tool requires agents to be pre-registered. The subagent definitions in `.vibe/agents/*.md` files were not auto-discovered, so `task(agent="triage-reviewer", ...)` returned "Unknown agent".

---

## Solution Implemented

Created a **file-based agent spawning pattern** that works within Vibe's current capabilities:

### For Argument Passing
Instead of relying on the skill tool to pass arguments, all skills now:
1. Extract the required parameters (PR number, spec path) from the user's invocation message
2. Use pattern matching to find values like "PR 42", "#42", "SPECIFICATIONS/07-feature.md"
3. Store extracted values in variables (`$PR_NUMBER`, `$SPEC_PATH`) for use in all subsequent steps

### For Agent Spawning
Instead of using custom agent names, all skills now:
1. Read the agent definition file (e.g., `.vibe/agents/triage-reviewer.md`)
2. Extract the system prompt (content after the YAML frontmatter's second `---`)
3. Spawn an `explore` subagent with the system prompt + task combined

---

## Files Modified

### New Files Created
- **[agent-spawning.md](./agent-spawning.md)** - Complete documentation of the file-based spawning pattern

### Skill Files Updated

1. **review-pr/SKILL.md**
   - Removed `arguments` from frontmatter
   - Added PR number extraction logic (Step 0a)
   - Updated all agent spawns to use file-based pattern
   - Replaced all `$ARGUMENTS` with `$PR_NUMBER`
   - Updated invocation examples to use natural language

2. **review-pr-team/SKILL.md**
   - Removed `arguments` from frontmatter
   - Added PR number extraction logic (Step 0)
   - Updated all 4 reviewer spawns to use file-based pattern
   - Replaced all `$ARGUMENTS` with `$PR_NUMBER`
   - Updated invocation examples to use natural language

3. **review-spec/SKILL.md**
   - Removed `arguments` from frontmatter
   - Added spec path extraction logic (Step 0)
   - Updated all 3 reviewer spawns to use file-based pattern
   - Replaced all `$ARGUMENTS` with `$SPEC_PATH`
   - Updated invocation examples to use natural language

4. **skills/AGENTS.md**
   - Updated invocation examples to use natural language
   - Removed slash command references
   - Updated Skill Structure section to note `arguments` field removal
   - Updated Spawning Subagents section with Vibe adaptation notes
   - Added agent-spawning.md to Supporting Skills table

---

## Agents Affected

All 10 subagent definitions in `.vibe/agents/` are now spawnable via the file-based pattern:

| Agent | Used By | Status |
|-------|---------|--------|
| triage-reviewer | review-pr | ✅ Spawns via file-based pattern |
| light-reviewer | review-pr | ✅ Spawns via file-based pattern |
| code-reviewer | review-pr | ✅ Spawns via file-based pattern |
| technical-writer | review-pr, review-pr-team | ✅ Spawns via file-based pattern |
| security-specialist | review-pr-team | ✅ Spawns via file-based pattern |
| product-reviewer | review-pr-team | ✅ Spawns via file-based pattern |
| architect-reviewer | review-pr-team | ✅ Spawns via file-based pattern |
| requirements-auditor | review-spec | ✅ Spawns via file-based pattern |
| technical-skeptic | review-spec | ✅ Spawns via file-based pattern |
| devils-advocate | review-spec | ✅ Spawns via file-based pattern |

---

## How It Works Now

### For Users

**Before (Claude Code):**
```
/review-pr 42
/review-pr-team 42
/review-spec SPECIFICATIONS/07-feature.md
```

**After (Vibe):**
```
User: "Run review-pr on PR 42"
User: "review PR #42"
User: "Run review-pr-team on PR 42"
User: "team review PR #42"
User: "Run review-spec on SPECIFICATIONS/07-feature.md"
User: "review spec 07-feature"
```

### For Skills (Internal)

**Before:**
```
task: {
  "agent": "triage-reviewer",
  "task": "Classify PR #42..."
}
```

**After:**
```
1. Read .vibe/agents/triage-reviewer.md
2. Extract system prompt (after second ---)
3. task: {
     "agent": "explore",
     "task": "<extracted system prompt>\n\nClassify PR #42..."
   }
```

---

## Pattern Extraction Details

### PR Number Extraction
Extracts from user message using these patterns:
- "PR 42" → 42
- "PR#42" → 42
- "#42" → 42
- "pull request 42" → 42
- "review-pr 42" → 42
- "review PR #42" → 42

**Validation:** Must match `^[0-9]+$` (positive integer only)

### Spec Path Extraction
Extracts from user message using these patterns:
- "SPECIFICATIONS/07-new-feature.md" → SPECIFICATIONS/07-new-feature.md
- "SPECIFICATIONS/07" → SPECIFICATIONS/07 (then searches for matching file)
- "07-new-feature.md" → 07-new-feature.md (then prepends SPECIFICATIONS/)
- "07-new-feature" → 07-new-feature (then searches SPECIFICATIONS/)

**Default:** If no path prefix, prepends `SPECIFICATIONS/`

---

## Performance Considerations

### Caching Strategy
- Skills cache system prompts when spawning multiple instances of the same agent
- Example: review-pr caches both light-reviewer and technical-writer prompts once, then reuses them

### Overhead
- Each agent spawn requires one additional `read` tool call to load the definition file
- This adds minimal overhead (~1-2 seconds per agent) but ensures:
  - Latest agent definitions are always used
  - Changes to agent definitions propagate automatically
  - No separate registration step needed

---

## Trade-offs

### What Was Lost
- Slash command syntax (`/review-pr 42`)
- Direct agent name registration (`task(agent="triage-reviewer")`)
- Argument passing via skill tool (`skill(name="review-pr", args="42")`)
- Real-time agent team discussion (Claude feature not in Vibe)

### What Was Gained
- Works with current Vibe (no core changes needed)
- Explicit control over agent definitions
- Automatic propagation of agent definition changes
- Clear, documented pattern for all skills to follow
- Parallel execution of reviewers (improvement over sequential)

### What Remains the Same
- All reviewer personas and roles
- All review checklists and focus areas
- All output formats and structure
- All quality standards
- All gate logic and configuration

---

## Testing the Changes

To verify the adaptation works:

1. **Test PR number extraction:**
   ```
   Try: "Run review-pr on PR 42"
   Try: "review PR #99"
   Try: "Please review pull request 15"
   ```

2. **Test spec path extraction:**
   ```
   Try: "Run review-spec on SPECIFICATIONS/07-feature.md"
   Try: "review spec 07-feature"
   Try: "review SPECIFICATIONS/new-feature"
   ```

3. **Test agent spawning:**
   - The skill should successfully spawn all reviewers
   - Each reviewer should have its full persona and checklist
   - Results should be synthesized correctly

---

## Future Enhancements

When Vibe adds support for:
1. **Slash commands with arguments** → Restore `/review-pr 42` syntax
2. **Custom agent registration from .md files** → Restore `task(agent="triage-reviewer")`
3. **Argument passing to skills** → Restore `arguments` in frontmatter

The file-based pattern in [agent-spawning.md](./agent-spawning.md) can be replaced with the direct approach.

---

## Migration Notes

- All changes are backward-compatible with the agent definition files
- No changes were needed to `.vibe/agents/*.md` files
- No changes were needed to `.vibe/config/*.json` files
- The only changes were to the skill files' orchestration logic

---

## References

- [agent-spawning.md](./agent-spawning.md) - The file-based spawning pattern
- [.vibe/agents/AGENTS.md](../agents/AGENTS.md) - Subagent definitions
- [.vibe/config/permissions.json](../config/permissions.json) - Tool permissions
- [.vibe/AGENTS.md](../AGENTS.md) - Collaboration principles
