# Skills Library Index

> **Purpose**: Library index for Vibe skills. Skills are structured workflows invoked via the `skill` tool.

---

## Available Skills

Skills are defined in SKILL.md files within subdirectories. Each skill is a self-contained, reusable workflow.

### PR Review Skills

| Skill | Purpose | Invocation | Status |
|-------|---------|------------|--------|
| [`review-pr/`](./review-pr/SKILL.md) | Smart dispatcher: triages PR for risk, then routes to light/standard/team review | `skill(name="review-pr", args="42")` or `/review-pr 42` | ✅ Migrated |
| [`review-pr-team/`](./review-pr-team/SKILL.md) | Full multi-perspective team review: security, product, architect, docs perspectives | `skill(name="review-pr-team", args="42")` or `/review-pr-team 42` | ✅ Migrated |
| [`review-gate.md`](./review-gate.md) | Shared gate logic for all review skills (checks prReviewMode) | Internal (referenced by other skills) | ✅ Migrated |

### Spec Review Skills

| Skill | Purpose | Invocation | Status |
|-------|---------|------------|--------|
| [`review-spec/`](./review-spec/SKILL.md) | Spec review: completeness, feasibility, strategy analysis with 3 specialized reviewers | `skill(name="review-spec", args="SPECIFICATIONS/07-feature.md")` or `/review-spec SPECIFICATIONS/07-feature.md` | ✅ Migrated |

### Setup Skills

| Skill | Purpose | Invocation | Status |
|-------|---------|------------|--------|
| [`check-profile-setup/`](./check-profile-setup/SKILL.md) | Verify profile setup (replaces SessionStart hook) | `skill(name="check-profile-setup")` or `/check-profile-setup` | ✅ Created |
| [`setup-profile/`](./setup-profile/SKILL.md) | Guide user through profile setup | `skill(name="setup-profile")` or `/setup-profile` | ✅ Created |

### Supporting Skills

| Skill | Purpose | Invocation | Status |
|-------|---------|------------|--------|
| [`post-review-follow-through.md`](./post-review-follow-through.md) | Re-bucket findings, surface decisions, create GitHub issues | Internal (referenced by review skills) | ✅ Migrated |

---

## Usage Pattern

### Invoking Skills

Users can invoke skills in several ways (depending on Vibe's current capabilities):

1. **Slash command**: `/review-pr 42` (if Vibe supports slash commands)
2. **Skill tool**: `skill: {"name": "review-pr", "args": "42"}`
3. **Chat**: "Run the review-pr skill on PR 42"

### Skill Structure

Each skill has:
- YAML frontmatter with metadata (name, description, arguments, user-invocable)
- Clear step-by-step instructions
- Error handling guidelines
- Result processing instructions
- Vibe-specific adaptation notes

### Spawning Subagents

Vibe uses the `task` tool to spawn subagents (replacing Claude's `SpawnAgent`):

```
task: {
  "agent": "agent-name",
  "task": "What the agent should do",
  "context": {"optional": "context"}
}
```

The skill receives results from the task and can process them programmatically.

### Skill-to-Agent Mapping

| Skill | Primary Agents Used |
|-------|---------------------|
| `review-pr` | triage-reviewer, light-reviewer, code-reviewer, technical-writer |
| `review-pr-team` | security-specialist, product-reviewer, architect-reviewer, technical-writer |
| `review-spec` | requirements-auditor, technical-skeptic, devils-advocate |
| `check-profile-setup` | None (direct file checks) |
| `setup-profile` | None (interactive setup) |

---

## Shared Patterns

All review skills share these common patterns:

1. **Gate check** - Verify `prReviewMode` allows execution via [`review-gate.md`](./review-gate.md)
2. **Input validation** - Validate arguments before processing (especially PR numbers)
3. **Context gathering** - Fetch PR/spec details, read AGENTS.md
4. **Subagent orchestration** - Spawn and coordinate subagents via `task` tool
5. **Result processing** - Combine findings, format output
6. **Action execution** - Post comments, create files, etc.
7. **Follow-through** - Run [`post-review-follow-through.md`](./post-review-follow-through.md) protocol

---

## Vibe-Specific Enhancements

### Parallel Execution

Vibe's `task` tool supports parallel execution. Review skills should:
- Spawn independent tasks (like triage, light-reviewer, technical-writer) in parallel
- Wait for all results before proceeding
- Handle results appropriately

### Result Handling

Vibe returns results from `task` calls that can be:
- Processed programmatically in subsequent steps
- Displayed to user
- Used for conditional logic

### MCP Integration

When MCP servers are enabled, skills can:
- Access live documentation via MCP servers
- Check package versions and dependencies
- Verify API contracts
- Fetch external resources

This enhances spec review and code review capabilities.

---

## The prReviewMode Setup Challenge

**Important Architecture Note**: 

Unlike Claude's hook-based approach (SessionStart hook), Vibe skills only execute when explicitly invoked. This creates a catch-22:

1. User doesn't know about review skills
2. Never invokes them
3. Never gets prompted to set up prReviewMode
4. Never discovers the skills

### Solutions Implemented

1. **First-use detection**: Each review skill checks the gate on first invocation, which prompts for prReviewMode setup
2. **Explicit setup skills**: `/check-profile-setup` and `/setup-profile` provide the hook-like functionality as user-invocable skills
3. **Documentation**: Strong AGENTS.md instructions and README references

### Recommended Usage

- Run `/check-profile-setup` at the start of each new project
- Run it periodically to verify configuration
- Document it in TEMPLATE-INSTRUCTIONS.md as the first step

---

## Migration Notes

### Claude → Vibe Conversion Summary

| Aspect | Claude Code | Mistral Vibe | Migration Note |
|--------|-------------|--------------|----------------|
| Invocation | Slash command `/name` | `skill` tool or `/name` | May support both |
| Definition | Markdown + YAML frontmatter | SKILL.md file | Structure preserved |
| Arguments | `argument-hint` array | `arguments` array | Format updated |
| Agent spawning | SpawnAgent action | `task` tool | Updated all skills |
| Model invocation | `disable-model-invocation` | Not needed | Removed from frontmatter |
| User invocable | `user-invocable: true` | Same | Preserved |
| File paths | `.claude/` directory | `.vibe/` directory | All updated |

### Agent Teams Adaptation

Claude Code had an **experimental agent teams feature** that allowed spawned agents to discuss with each other. Vibe does not have this feature.

**Adaptation approach:**
- Spawn multiple independent subagents via `task` tool
- Collect all results
- Explicitly synthesize findings (replicating the discussion benefit)
- Document the trade-off in each affected skill

This approach provides equivalent quality with different execution model.

---

## Related Documentation

- [Root AGENTS.md](../AGENTS.md) - Collaboration principles and project navigation
- [.vibe/agents/AGENTS.md](../agents/AGENTS.md) - Subagent library index
- [.vibe/config/README.md](../config/README.md) - Configuration documentation
- [Skills Migration Spec](../../SPECIFICATIONS/ARCHIVE/migration-from-claude/05-skills-migration.md) - Historical Phase 5 specification
- [ORIGINAL_IDEA/project-outline.md](../../ORIGINAL_IDEA/project-outline.md) - Master specification

---

## Archive Reference

Original Claude skills are preserved in the `.claude/skills/` directory:
- `review-pr/SKILL.md`
- `review-pr-team/SKILL.md`
- `review-spec/SKILL.md`
- `review-gate.md`
- `post-review-follow-through.md`

These are kept for backward compatibility and reference. All new Vibe skills use `.vibe/skills/` paths.
