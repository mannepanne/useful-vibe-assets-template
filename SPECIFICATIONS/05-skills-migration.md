# Phase 5: Skills Migration

**Phase number:** 5
**Phase name:** Skills Migration
**Estimated timeframe:** 2-3 sessions
**Dependencies:** Phase 1 (Research and Foundation), Phase 2 (Documentation Migration), Phase 3 (Configuration System), Phase 4 (Agent & Subagent Migration) complete
**Status:** Not started

---

## Phase overview

This phase converts **Claude's slash-command skills** (`/review-pr`, `/review-pr-team`, `/review-spec`) to **Vibe's skill system**. We'll migrate all skill files from `.claude/skills/` to `.vibe/skills/` and adapt them to use Vibe's `task` tool for subagent delegation.

This is where we **complete the functional migration** of the automated review system.

---

## Scope and deliverables

### In scope

- [ ] Migrate all skill files from `.claude/skills/` to `.vibe/skills/`
- [ ] Convert slash-command skills to Vibe skill format
- [ ] Create `.vibe/skills/AGENTS.md` (skills library index)
- [ ] Adapt agent spawning to use Vibe's `task` tool
- [ ] Update gate logic to work with Vibe's permission system
- [ ] Create `/check-profile-setup` skill (replaces SessionStart hook)
- [ ] Update all internal references
- [ ] Verify all skills work in the new structure

### Out of scope

- Hooks migration (Phase 6)
- Full end-to-end testing (Phase 7)
- Documentation finalization (Phase 7)

### Acceptance criteria

- [ ] All skill files migrated from `.claude/skills/` to `.vibe/skills/`
- [ ] All skills use Vibe skill format
- [ ] `.vibe/skills/AGENTS.md` exists and indexes all skills
- [ ] Agent spawning adapted to use `task` tool
- [ ] Gate logic adapted to Vibe's model
- [ ] `/check-profile-setup` skill created
- [ ] All internal references updated
- [ ] Skills can be invoked and work correctly

---

## Technical approach

### Claude vs Vibe: Skills Compared

#### Claude Code Skills

Claude's skills are **slash commands** defined as markdown files with YAML frontmatter:

```markdown
---
name: review-pr
description: Smart PR review dispatcher — triages the change for risk, then routes to a light, standard, or team review.
disable-model-invocation: false
user-invocable: true
argument-hint:
  - PR-number
---

# Smart PR Review (Dispatcher)

This skill reviews a PR at the right level of depth...
[Skill instructions]
```

**Key characteristics:**
- Invoked via slash command (`/review-pr 42`)
- Frontmatter defines metadata and invocation
- Can spawn agents via `SpawnAgent`
- Complex multi-step workflows
- Can call other skills

#### Mistral Vibe Skills

Vibe's skills are **loaded via the `skill` tool** and defined in SKILL.md files:

```markdown
---
name: review-pr
description: Smart PR review dispatcher
user-invocable: true
---

# Smart PR Review (Dispatcher)

This skill reviews a PR at the right level of depth...
[Skill instructions - adapted for Vibe]
```

**Key characteristics (based on Phase 1 research):**
- Invoked via `skill` tool: `skill: {"name": "review-pr", "args": "42"}`
- Or via chat: `/review-pr 42` (if Vibe supports slash commands)
- Can use `task` tool to spawn subagents
- Integrated with tool permissions
- Can call other skills

### Skill File Mapping

| Claude Path | Vibe Path | Action |
|-------------|-----------|--------|
| `.claude/skills/review-pr/SKILL.md` | `.vibe/skills/review-pr/SKILL.md` | Migrate skill |
| `.claude/skills/review-pr-team/SKILL.md` | `.vibe/skills/review-pr-team/SKILL.md` | Migrate skill |
| `.claude/skills/review-spec/SKILL.md` | `.vibe/skills/review-spec/SKILL.md` | Migrate skill |
| `.claude/skills/review-gate.md` | `.vibe/skills/review-gate.md` | Migrate gate logic |
| `.claude/skills/post-review-follow-through.md` | `.vibe/skills/post-review-follow-through.md` | Migrate follow-through |

### Frontmatter Conversion

**Claude format:**
```yaml
---
name: review-pr
description: Smart PR review dispatcher — triages the change for risk, then routes to a light, standard, or team review.
disable-model-invocation: false
user-invocable: true
argument-hint:
  - PR-number
---
```

**Vibe format:**
```yaml
---
name: review-pr
description: Smart PR review dispatcher — triages the change for risk, then routes to a light, standard, or team review.
user-invocable: true
arguments:
  - name: pr-number
    description: The PR number to review
    required: true
---
```

**Key differences:**
- `disable-model-invocation` → Not needed in Vibe (different model)
- `argument-hint` → `arguments` array with more structure
- May have additional Vibe-specific fields

### Gate Logic Adaptation

Claude's `review-gate.md` is the **canonical gate logic** that all `/review-*` skills reference. It handles:
1. Reading `prReviewMode` from config
2. Handling `prompt-on-first-use` mode
3. Persisting user's choice

**Vibe adaptation:**

Since Vibe doesn't have hooks, we need to **integrate the gate logic into each skill** or create a **shared gate skill**.

**Option A: Inline in each skill**
- Each skill has its own Step 0 that runs the gate
- Duplicates logic but keeps skills self-contained

**Option B: Shared gate skill**
- Create a `/review-gate` skill that other skills call
- Single source of truth but adds dependency

**Recommendation:** **Option B** - Create a shared `/review-gate` skill that encapsulates the gate logic. This maintains the single source of truth principle from the original design.

However, since Vibe skills may not be able to call other skills directly, we might need to **inline the gate logic** in each review skill (Option A).

### Agent Spawning Conversion

**Claude pattern:**
```markdown
Spawn the **`triage-reviewer`** subagent with task: "Classify PR #$ARGUMENTS..."
Wait for the classification...
```

**Vibe pattern:**
```markdown
Use the task tool to spawn the triage-reviewer subagent:
task: {"agent": "triage-reviewer", "task": "Classify PR #$ARGUMENTS for review tier. Follow your rubric and output format exactly. Return only the classification block."}
Wait for the task to complete and return results...
```

**Key considerations:**
- Vibe's `task` tool returns results that can be processed
- We need to handle the results appropriately
- Error handling may be different

### Review Skills Structure

#### /review-pr (Dispatcher)

This is the **main entry point** for PR reviews. It:
1. Runs the gate (checks prReviewMode)
2. Validates input (PR number)
3. Spawns triage-reviewer to classify
4. Announces decision to user
5. Routes to appropriate tier (light/standard/team)
6. Posts results to PR
7. Runs follow-through protocol

**Vibe adaptation:**
- Gate logic inlined or shared
- Agent spawning via `task` tool
- Rest of workflow largely the same

#### /review-pr-team (Team Review)

This skill:
1. Runs the gate
2. Posts triage marker comment
3. Spawns team of subagents (security, product, architect, docs, code)
4. Orchestrates discussion between them
5. Combines findings
6. Posts results
7. Runs follow-through

**Vibe adaptation:**
- Use `task` to spawn multiple subagents in parallel
- Vibe may have better parallel execution than Claude
- Discussion orchestration largely the same

#### /review-spec (Spec Review)

This skill:
1. Runs the gate
2. Spawns spec review team (requirements-auditor, technical-skeptic, devils-advocate)
3. Orchestrates review
4. Combines findings
5. Returns results

**Vibe adaptation:**
- Use `task` to spawn spec review subagents
- Leverage web_search in spec agents (added in Phase 4)

### New Skill: /check-profile-setup

This skill **replaces the SessionStart hook** functionality:

```markdown
---
name: check-profile-setup
description: Check if personal profile setup is required and trigger setup flow if needed.
user-invocable: true
---

# Profile Setup Check

## Step 0: Check conditions

Read `.vibe/COLLABORATION/personal-profile.local.md`:
- If it exists: Setup is complete. Exit with confirmation.

Read `.vibe/COLLABORATION/personal-profile.md`:
- If it does NOT contain `<!-- profile_status: default -->`: Setup is complete. Exit with confirmation.

## Step 1: Trigger setup

If neither condition above is met, trigger the profile setup flow:

1. Inform the user: "Personal profile setup is required before we continue."
2. Guide them to run: `/setup-profile` (separate skill)
3. Or provide the setup instructions from `.vibe/COLLABORATION/profile-setup-flow.md`

## Step 2: Verify

After setup, re-check conditions to confirm completion.
```

This skill can be:
- Invoked manually by users
- Called by other skills as a prerequisite
- Documented as the first step in TEMPLATE-INSTRUCTIONS.md

### Follow-Through Protocol Adaptation

Claude's `post-review-follow-through.md` handles:
- Re-bucketing findings by action tier
- Surfacing decisions
- Creating GitHub issues for out-of-scope items

**Vibe adaptation:**
- This protocol is **largely the same** - it's about processing review results
- May need to adapt for Vibe's result handling from `task` tool
- Should preserve the same logic and outcomes

---

## Skill File Structure

### .vibe/skills/AGENTS.md

This is the **skills library index**, replacing the skills section in `.claude/CLAUDE.md`:

```markdown
# Skills Definitions

This directory contains Vibe skills for automated workflows.

## Purpose

Skills define structured, reusable workflows that can be invoked by users. They orchestrate complex tasks by:
- Gathering context
- Spawning subagents via `task` tool
- Processing results
- Taking actions (posting comments, creating files, etc.)

## Available Skills

### PR Review Skills

- **[review-pr/](./review-pr/SKILL.md)** - Smart dispatcher: triages PR for risk, then routes to light/standard/team review
- **[review-pr-team/](./review-pr-team/SKILL.md)** - Full team review: security, product, architect, docs perspectives
- **[review-gate](./review-gate.md)** - Shared gate logic for all review skills

### Spec Review Skills

- **[review-spec/](./review-spec/SKILL.md)** - Spec review: completeness, feasibility, strategy analysis

### Setup Skills

- **[check-profile-setup](./check-profile-setup/SKILL.md)** - Verify profile setup (replaces SessionStart hook)
- **[setup-profile](./setup-profile/SKILL.md)** - Guide user through profile setup (to be created)

### Supporting Skills

- **[post-review-follow-through](./post-review-follow-through.md)** - Re-bucket findings, surface decisions, create issues

## Usage Pattern

### Invoking Skills

Users can invoke skills in several ways:

1. **Slash command**: `/review-pr 42` (if Vibe supports this)
2. **Skill tool**: `skill: {"name": "review-pr", "args": "42"}`
3. **Chat**: "Run the review-pr skill on PR 42"

### Skill Structure

Each skill has:
- YAML frontmatter with metadata
- Clear step-by-step instructions
- Error handling
- Result processing

### Spawning Subagents

Use the `task` tool to spawn subagents:

```markdown
task: {
  "agent": "agent-name",
  "task": "What the agent should do",
  "context": {"optional": "context"}
}
```

The skill receives results and can process them.

## Skill-to-Agent Mapping

| Skill | Primary Agents Used |
|-------|---------------------|
| `review-pr` | triage-reviewer, light-reviewer or code-reviewer, technical-writer |
| `review-pr-team` | triage-reviewer, code-reviewer, technical-writer, security-specialist, product-reviewer, architect-reviewer |
| `review-spec` | requirements-auditor, technical-skeptic, devils-advocate |
| `check-profile-setup` | None (direct file checks) |

## Shared Patterns

All review skills share:

1. **Gate check** - Verify prReviewMode allows execution
2. **Input validation** - Validate arguments before processing
3. **Context gathering** - Fetch PR/spec details, read AGENTS.md
4. **Subagent orchestration** - Spawn and coordinate subagents
5. **Result processing** - Combine findings, format output
6. **Action execution** - Post comments, create files, etc.
7. **Follow-through** - Re-bucket findings, create issues

## Vibe-Specific Enhancements

### Parallel Execution

Vibe's `task` tool may support better parallel execution than Claude's SpawnAgent. We should:
- Spawn triage and other independent tasks in parallel where possible
- Document parallel execution patterns
- Handle results appropriately

### Result Handling

Vibe returns results from `task` calls that can be:
- Processed programmatically
- Displayed to user
- Used in subsequent steps

We should leverage this for better error handling and result processing.

### MCP Integration

When MCP servers are enabled, skills can:
- Access live documentation
- Check package versions
- Verify API contracts
- Fetch external resources

This enhances spec review and code review capabilities.
```

### Example Skill: review-pr/SKILL.md

```markdown
---
name: review-pr
description: Smart PR review dispatcher — triages the change for risk, then routes to a light, standard, or team review. Explains every decision in plain language so you can override if it got it wrong.
user-invocable: true
arguments:
  - name: pr-number
    description: The PR number to review
    required: true
    pattern: "^[0-9]+$"
---

# Smart PR Review (Dispatcher)

This skill reviews a PR at the right level of depth — not too shallow, not token-wasteful. It first runs a cheap triage pass, announces what it decided and why, then hands off to one of three review tiers.

## The three tiers

| Tier | What runs | Good for | Approx. time |
|---|---|---|---|
| **light** | `light-reviewer` + `technical-writer` (light mode) | Docs, tests, styling, comment-only | ~1-2 min |
| **standard** | `code-reviewer` + `technical-writer` | Typical feature work, core logic | ~2-4 min |
| **team** | Multi-perspective team (security, product, architect, docs) | Data layer, auth, CI, dependencies, secrets | ~2-7 min |

---

## Instructions for Vibe

When invoked with a PR number (e.g., `/review-pr 42`):

### Step 0: Gate check

Run the gate logic from [`.vibe/skills/review-gate.md`](../review-gate.md):

1. Read `.vibe/config/project-config.json` (committed) and `.vibe/config/project-config.local.json` (if exists)
2. Merge local on top of committed (local wins)
3. Check `prReviewMode`:
   - `"enabled"` → proceed to Step 1
   - `"disabled"` → reply: "The review system is disabled. Not running /review-pr. To enable, set prReviewMode to 'enabled' in .vibe/config/project-config.json." Stop.
   - `"prompt-on-first-use"` or missing → render the pitch (see review-gate.md), persist answer, then proceed or stop

### Step 1: Input validation

`$ARGUMENTS` MUST match `^[0-9]+$` (positive integer) before any tool call.
If not, refuse with: "/review-pr expects a single positive integer (PR number). Got: '<value>'. Aborting."

### Step 2: Triage

Use task to spawn the **`triage-reviewer`** subagent:

task: {
  "agent": "triage-reviewer",
  "task": "Classify PR #$ARGUMENTS for review tier. Follow your rubric and output format exactly. Return only the classification block."
}

Wait for results. Parse the classification block (4 lines: TIER:, RATIONALE:, FLAGGED_PATHS:, SIZE:).

**Parsing fallback:** If response doesn't parse or TIER is missing/invalid, default to `team`.

### Step 3: Announce the decision

Tell the user the decision in plain language BEFORE spawning any reviewer:

```
🎯 Triage: <tier>
   <rationale>
   <size>

Running <tier> review now. If this looks wrong, stop me and run
/review-pr-team $ARGUMENTS directly to force the deepest tier.
```

### Step 4: Route to the right reviewer

**If TIER: light:**

Spawn in parallel:
1. task: {"agent": "light-reviewer", "task": "Light-tier review of PR #$ARGUMENTS. Follow your agent definition. Post nothing — return your findings."}
2. task: {"agent": "technical-writer", "task": "Light-mode documentation pass for PR #$ARGUMENTS. Operate in light-mode. Post nothing — return your findings."}

Combine findings and post via gh pr comment.

**If TIER: standard:**

Spawn:
1. task: {"agent": "code-reviewer", "task": "Conduct a comprehensive code review of PR #$ARGUMENTS. Follow your review checklist and output format. Post nothing — return your findings."}
2. task: {"agent": "technical-writer", "task": "Conduct a documentation review of PR #$ARGUMENTS. Follow your review checklist and output format. Post nothing — return your findings."}

Combine findings and post.

**If TIER: team:**

1. Post triage marker comment via gh pr comment
2. Spawn team via: task: {"agent": "review-pr-team", "task": "Conduct team review of PR #$ARGUMENTS.", "args": "$ARGUMENTS"}
   (The team skill handles its own orchestration)

### Step 5: User summary and follow-through

After posting, give one-line status. Then run follow-through protocol from [post-review-follow-through.md](../post-review-follow-through.md).

---

## Override & escape hatches

| Situation | What to do |
|---|---|
| Want to skip triage | Run `/review-pr-team N` directly |
| Triage chose wrong tier | Press ESC or run `/review-pr-team N` |
| Want deeper look after light/standard | Run `/review-pr-team N` |

---

## Vibe-Specific Notes

This skill has been adapted from Claude Code's version:
- Agent spawning uses Vibe's `task` tool instead of SpawnAgent
- Gate logic adapted for Vibe's configuration system
- Result handling adapted for Vibe's task return format

The core workflow and triage logic remain the same.
```

### Example Skill: review-gate.md

```markdown
# Review system gate logic

> **Canonical gate logic** for all `/review-*` skills. This file is the single source of truth.

---

## Gate logic

Every `/review-*` skill must run this gate as its very first action before doing any other work.

### Step 1: Read configuration

1. Read `.vibe/config/project-config.json` (the committed file)
2. If `.vibe/config/project-config.local.json` exists, read it too and merge its top-level keys on top of the committed file's values (local wins)

### Step 2: Branch on prReviewMode

- **Both files missing, OR `prReviewMode` key missing from both** → treat as `"prompt-on-first-use"`
- **JSON unparseable in either file** → treat as `"prompt-on-first-use"`, warn which file needs fixing
- **`"enabled"`** → proceed with skill's normal behaviour
- **`"disabled"`** → reply with disabled message, stop
- **`"prompt-on-first-use"`** → render the pitch, wait for answer

### Step 3: Persist answer (for prompt-on-first-use)

- `yes` / affirmative → persist `"enabled"` to local file (or committed file if no local exists)
- `no` / negative → persist `"disabled"`, emit disabled message, stop
- `later` → do NOT modify any config file, proceed with this invocation only

### Write contract

When persisting:
- If `.vibe/config/project-config.local.json` exists, write to it
- Otherwise write to `.vibe/config/project-config.json`
- Read full JSON, replace only `prReviewMode`, write back
- Preserve all other keys byte-for-byte

---

## The pitch

Use this text verbatim when prompting the user:

> The project's `prReviewMode` is set to `"prompt-on-first-use"`, so before I review this PR, I need to ask:
>
> This template ships with an automated PR review system:
> - `/review-pr` triages each PR (~30s) then runs a light/standard/team review (1-5 min)
> - `/review-pr-team` forces a full multi-perspective team review (2-7 min)
> - `/review-spec` reviews a feature spec before you write code (2-7 min)
>
> These cost tokens. For throwaway experiments they're overkill; for meaningful projects they pay back the first time they catch a real issue.
>
> Enable for this project?
> - **yes** → I'll persist `"enabled"` and run this review now
> - **no** → I'll persist `"disabled"` — all `/review-*` skills will become no-ops
> - **later** → I'll run this one now and ask again next time
>
> Which would you like — yes / no / later?

---

## Vibe Adaptation Notes

This gate logic has been adapted from Claude's version:
- File paths changed from `.claude/` to `.vibe/`
- Configuration format adapted for Vibe
- Persistence logic preserved

The core state machine and contract remain the same.
```

---

## Migration Steps

### Step 1: Create .vibe/skills/ Directory
```bash
mkdir -p .vibe/skills/review-pr
mkdir -p .vibe/skills/review-pr-team
mkdir -p .vibe/skills/review-spec
```

### Step 2: Migrate Skill Files

For each skill in `.claude/skills/`:

1. **Create directory** (if it's a multi-file skill like review-pr/)
2. **Copy SKILL.md**: `cp .claude/skills/{name}/SKILL.md .vibe/skills/{name}/SKILL.md`
3. **Update frontmatter**: Convert to Vibe format
4. **Update content**:
   - Change all `.claude/` references to `.vibe/`
   - Change all `CLAUDE.md` references to `AGENTS.md`
   - Change agent spawning from `SpawnAgent` to `task` tool
   - Update gate logic references
   - Preserve all workflow logic
5. **Update references**: Change any other Claude-specific references

### Step 3: Create New Skills

Create the new skills that don't exist in Claude:
- `/check-profile-setup` (replaces SessionStart hook)
- `/setup-profile` (guides user through profile setup)

### Step 4: Create .vibe/skills/AGENTS.md

Create the skills library index as documented above.

### Step 5: Update Cross-References

Ensure all skills reference:
- Correct agent paths (`.vibe/agents/`)
- Correct config paths (`.vibe/config/`)
- Correct documentation paths

---

## Testing strategy

### Verification checklist

- [ ] All skill files migrated from `.claude/skills/` to `.vibe/skills/`
- [ ] `.vibe/skills/AGENTS.md` exists and indexes all skills
- [ ] All frontmatter converted to Vibe format
- [ ] All agent spawning converted to `task` tool
- [ ] Gate logic adapted and shared
- [ ] New skills created (check-profile-setup)
- [ ] All internal references updated
- [ ] All skills have proper error handling
- [ ] All skills preserve original logic

### Automated verification

Create `SCRATCH/verify-skills.sh`:
```bash
#!/bin/bash
set -e

echo "Verifying skills migration..."

# Check all skill files exist
for skill in review-pr/SKILL.md review-pr-team/SKILL.md review-spec/SKILL.md \
            review-gate.md post-review-follow-through.md; do
  [ -f ".vibe/skills/${skill}" ] || { echo "ERROR: Missing ${skill}"; exit 1; }
done

# Check new skills exist
for skill in check-profile-setup/SKILL.md setup-profile/SKILL.md; do
  [ -f ".vibe/skills/${skill}" ] || { echo "ERROR: Missing new skill ${skill}"; exit 1; }
done

# Check AGENTS.md exists
[ -f ".vibe/skills/AGENTS.md" ] || { echo "ERROR: Missing AGENTS.md"; exit 1; }

# Check for remaining .claude/ references in .vibe/
if grep -r "\.claude/" .vibe/; then
  echo "ERROR: Found .claude/ references in .vibe/"
  exit 1
fi

# Check for remaining CLAUDE.md references in .vibe/
if grep -r "CLAUDE\.md" .vibe/; then
  echo "ERROR: Found CLAUDE.md references in .vibe/"
  exit 1
fi

echo "Skills migration verification passed!"
```

### Manual verification

1. **Skill content review**: Read through each migrated skill
2. **Frontmatter validation**: Verify each skill has correct frontmatter
3. **Workflow validation**: Verify each skill's workflow is complete
4. **Agent reference check**: Verify all agent references are correct
5. **Gate logic check**: Verify gate logic is correctly implemented
6. **Error handling**: Verify error cases are handled

---

## Pre-commit checklist

Before creating PR for Phase 5:

- [ ] `.vibe/skills/` directory structure created
- [ ] All skill files migrated from `.claude/skills/` to `.vibe/skills/`
- [ ] `.vibe/skills/AGENTS.md` created and accurate
- [ ] All frontmatter converted to Vibe format
- [ ] All agent spawning converted to `task` tool
- [ ] Gate logic adapted and shared
- [ ] New skills created (check-profile-setup, setup-profile)
- [ ] All internal references updated
- [ ] All skills have proper error handling
- [ ] Verification script passes
- [ ] All skill files are valid and complete

---

## PR workflow

### Branch naming
```
feature/phase-5-skills-migration
```

### PR title
```
Phase 5: Skills Migration - Convert Claude skills to Vibe skills
```

### PR description template
```markdown
## Summary
Migrates all Claude slash-command skills to Vibe's skill system, adapting them to use Vibe's `task` tool for subagent delegation and Vibe's configuration model.

## Changes

### New files
- `.vibe/skills/AGENTS.md` - Skills library index
- `.vibe/skills/review-pr/SKILL.md` - PR review dispatcher
- `.vibe/skills/review-pr-team/SKILL.md` - Team PR review
- `.vibe/skills/review-spec/SKILL.md` - Spec review
- `.vibe/skills/review-gate.md` - Shared gate logic
- `.vibe/skills/post-review-follow-through.md` - Follow-through protocol
- `.vibe/skills/check-profile-setup/SKILL.md` - Profile setup check (new)
- `.vibe/skills/setup-profile/SKILL.md` - Profile setup guide (new)

### Modified files
- None (all new files, .claude/skills/ preserved until migration complete)

## Technical Details

### Agent Spawning
Converted from Claude's `SpawnAgent` to Vibe's `task` tool:
```
# Claude
Spawn the **`triage-reviewer`** subagent with task: "..."

# Vibe
task: {"agent": "triage-reviewer", "task": "..."}
```

### Gate Logic
Adapted gate logic from `.claude/skills/review-gate.md` to `.vibe/skills/review-gate.md`:
- Configuration paths updated
- Persistence logic preserved
- Pitch text preserved

### New Skills
- `/check-profile-setup` - Replaces SessionStart hook functionality
- `/setup-profile` - Guides user through profile setup

## Testing
- Verified all skill files exist and are properly formatted
- Verified frontmatter conversion
- Verified agent spawning conversion
- Verified gate logic adaptation
- Created verification script

## Migration Notes
This phase completes the migration of the automated review system's functional components. Phase 6 will handle any remaining hooks, and Phase 7 will test everything end-to-end.
```

### Review requirements
- Manual review focusing on:
  - Skill content accuracy
  - Frontmatter correctness
  - Agent spawning correctness
  - Gate logic correctness
  - New skill functionality

---

## Edge cases and considerations

### Known risks

1. **Task tool limitations**: Vibe's `task` tool may have limitations we're not aware of. Mitigation: Test each task call; document any issues.

2. **Result handling**: Vibe's result handling from `task` may differ from Claude's. Mitigation: Verify result formats; adapt processing as needed.

3. **Parallel execution**: Vibe's parallel execution may work differently. Mitigation: Test parallel task spawning; verify results.

4. **Skill invocation**: Vibe may invoke skills differently than Claude. Mitigation: Test each invocation method; document supported methods.

### Special cases

1. **review-pr-team skill**: This skill spawns multiple agents and orchestrates discussion. We need to ensure:
   - All agents can be spawned in parallel
   - Discussion can be orchestrated
   - Results can be combined

2. **review-gate skill**: This skill is called by all other review skills. We need to ensure:
   - It can be called from other skills
   - Results are properly returned
   - Configuration is correctly read

3. **post-review-follow-through**: This protocol processes review results. We need to ensure:
   - It can access the review results
   - It can create GitHub issues
   - It can surface decisions

### Open questions

1. Can Vibe skills **call other skills** directly? This affects the gate logic sharing.

2. How does Vibe handle **skill arguments**? Are they passed as environment variables, function parameters, or something else?

3. Can skills **access conversation history**? This affects context gathering.

4. How does Vibe handle **parallel task execution**? Can we spawn multiple tasks at once?

---

## Vibe vs Claude: Skills Deep Dive

### Key Differences

| Aspect | Claude Code | Mistral Vibe | Migration Impact |
|--------|-------------|--------------|-----------------|
| Invocation | Slash command `/name` | `skill` tool or `/name` | May support both |
| Definition | Markdown + YAML frontmatter | Markdown + frontmatter | Frontmatter conversion |
| Arguments | `argument-hint` array | `arguments` array | Format update |
| Agent spawning | `SpawnAgent` action | `task` tool | Update all spawning |
| Model invocation | `disable-model-invocation` | Not needed | Remove from frontmatter |
| User invocable | `user-invocable: true` | Same | Preserve |

### Preserved Concepts

1. **Skill structure** - Step-by-step workflows
2. **Agent orchestration** - Spawning and coordinating agents
3. **Gate logic** - Configuration-based enabling/disabling
4. **Result processing** - Combining and formatting results
5. **Follow-through** - Post-review actions

### New Capabilities

1. **Task delegation** - Richer delegation with `task` tool
2. **Result handling** - Better result processing from tasks
3. **Parallel execution** - Potentially better parallel task execution
4. **MCP integration** - Access to MCP servers during skills

---

## Related documentation

- [Phase 1: Research and Foundation](./01-research-and-planning.md) - Prerequisite
- [Phase 2: Documentation Migration](./02-documentation-migration.md) - Prerequisite
- [Phase 3: Configuration System](./03-configuration-system.md) - Prerequisite
- [Phase 4: Agent & Subagent Migration](./04-agent-subagent-migration.md) - Prerequisite
- [Phase 6: Safety and Hooks](./06-safety-and-hooks.md) - Next phase
- [Root AGENTS.md](../AGENTS.md) - Implementation library
- [ORIGINAL_IDEA/project-outline.md](../ORIGINAL_IDEA/project-outline.md) - Master specification

---

## Notes

This phase is **the core of the functional migration** - we're converting the automated review system from Claude's architecture to Vibe's. The key is to:

1. **Preserve the workflow logic** - The review process should work the same way
2. **Adapt the implementation** - Use Vibe's `task` tool and configuration
3. **Maintain the contracts** - All the interfaces between components should work the same
4. **Leverage Vibe's strengths** - Use parallel execution, better result handling, etc.

**Key principle:** The automated review system is the **killer feature** of this template. Its quality and reliability are critical to the template's value. Take extreme care to preserve all the careful design that went into the original.

The migration should be **transparent to users** - they should be able to use `/review-pr 42` and have it work exactly as before (or better), without knowing or caring that the implementation is different.
