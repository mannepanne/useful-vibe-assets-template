# Skills Library Index

> **Purpose**: Library index for Vibe skills. Skills are structured workflows invoked via the `skill` tool.

---

## Available Skills

Skills are defined in SKILL.md files within subdirectories. Each skill is a self-contained, reusable workflow.

### Current Skills

| Skill | Purpose | Invocation | Status |
|-------|---------|------------|--------|
| `review-pr` | Triage and review pull requests | `skill(name="review-pr")` | ⏳ Planned (Phase 5) |
| `review-pr-team` | Full multi-perspective team review | `skill(name="review-pr-team")` | ⏳ Planned (Phase 5) |
| `review-spec` | Review feature specifications | `skill(name="review-spec")` | ⏳ Planned (Phase 5) |

### Skill Structure

Each skill is defined in a SKILL.md file with this structure:

```
## Skill Definition
- name: review-pr
- description: Triage and review pull requests
- user-invocable: true

## Steps
1. [Step 1 description]
2. [Step 2 description]
...
```

---

## Migration Status

Claude slash-command skills will be migrated to Vibe skills in **Phase 5: Skills Migration**.

### Claude → Vibe Mapping

| Claude Slash Command | Vibe Skill | Migration Notes |
|-----------------------|-------------|-----------------|
| `/review-pr` | `review-pr` | Convert to SKILL.md, use `task` for subagents |
| `/review-pr-team` | `review-pr-team` | Full team review workflow |
| `/review-spec` | `review-spec` | Spec review workflow |
| `/review-gate` | `review-gate` | Gate logic, may be embedded in other skills |

### Key Differences

| Aspect | Claude | Vibe |
|--------|--------|------|
| Invocation | `/command` | `skill(name="command")` |
| Definition | Markdown + YAML frontmatter | SKILL.md file |
| Agent spawning | `SpawnAgent` in skill | `task` tool in skill |
| Discovery | Slash command list | `skill` tool discovery |

---

## Skill Development Guidelines

### When to Create a Skill

Create a skill when:
- The workflow is reused across projects
- The workflow involves multiple steps
- The workflow benefits from subagent delegation
- The workflow needs consistent execution

### Skill Best Practices

1. **Single responsibility**: Each skill should do one thing well
2. **Idempotent**: Safe to run multiple times
3. **Clear inputs**: Document required parameters
4. **Structured outputs**: Return consistent, parseable results
5. **Error handling**: Graceful degradation on failures

### Skill Location

Skills are organized in subdirectories under `.vibe/skills/`:

```
.vibe/skills/
├── review-pr/
│   └── SKILL.md
├── review-pr-team/
│   └── SKILL.md
├── review-spec/
│   └── SKILL.md
└── AGENTS.md (this file)
```

---

## The prReviewMode Setup Challenge

**Important**: Unlike Claude's hook-based approach, Vibe skills only prompt when explicitly invoked. This creates a catch-22:

1. User doesn't know about review skills
2. Never invokes them
3. Never gets prompted to set up prReviewMode
4. Never discovers the skills

### Potential Solutions (to be addressed in Phase 5)

1. **Documentation-first**: Strong AGENTS.md instructions that Vibe surfaces
2. **First-use detection**: Skills check for config on first invocation
3. **MCP GitHub integration**: Detect PR events and proactively prompt
4. **Tool permission prompts**: Use bash tool confirmation messages to mention review system

See Phase 1 spec for detailed discussion of this architectural challenge.

---

## Related Documentation

- [Root AGENTS.md](../AGENTS.md) - Collaboration principles
- [Phase 5: Skills Migration](../../SPECIFICATIONS/05-skills-migration.md) - Migration plan
- [.claude/skills/CLAUDE.md](../../.claude/skills/CLAUDE.md) - Original Claude skills (archive)
