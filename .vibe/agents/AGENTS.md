# Subagent Library Index

> **Purpose**: Library index for Vibe subagent definitions. Subagents are spawned via the `task` tool for specialized tasks.

---

## Available Subagent Profiles

Subagents are defined as profiles and invoked via the `task` tool. Each profile has specialized capabilities and permissions.

### Current Subagents

| Profile | Purpose | Trigger | Status |
|---------|---------|---------|--------|
| `explore` | Read-only exploration, research, analysis | Explicit `task` invocation | ✅ Built-in |
| `code-reviewer` | PR code review, quality checks | To be migrated from `.claude/agents/` | ⏳ Planned |
| `technical-writer` | Documentation generation and review | To be migrated from `.claude/agents/` | ⏳ Planned |
| `architect-reviewer` | Architecture decisions, high-level design | To be migrated from `.claude/agents/` | ⏳ Planned |
| `security-specialist` | Security audit, vulnerability scanning | To be migrated from `.claude/agents/` | ⏳ Planned |

### Subagent Definition Structure

Each subagent profile should include:
- **Role**: Primary responsibility
- **Capabilities**: Tools available to the subagent
- **Limitations**: Restrictions or boundaries
- **When to use**: Typical scenarios
- **Output format**: Expected deliverables

---

## Migration Status

This template currently uses the built-in `explore` subagent. The full suite of Claude agents will be migrated in **Phase 4: Agent & Subagent Migration**.

### Claude → Vibe Mapping

| Claude Agent (YAML frontmatter) | Vibe Subagent Profile | Migration Notes |
|---------------------------------|----------------------|-----------------|
| `.claude/agents/code-reviewer.md` | `code-reviewer` | Convert YAML to profile, adapt tool permissions |
| `.claude/agents/architect-reviewer.md` | `architect-reviewer` | Map specialized review criteria |
| `.claude/agents/security-specialist.md` | `security-specialist` | Adapt severity calibration for Vibe's threat model |
| `.claude/agents/technical-writer.md` | `technical-writer` | Documentation style preferences |
| `.claude/agents/product-reviewer.md` | `product-reviewer` | PM mode integration |

---

## Usage Patterns

### Spawning a Subagent

```
task(
  agent="explore",
  task="Review SPECIFICATIONS/01-research-and-planning.md against acceptance criteria"
)
```

### Parallel Subagents

Multiple subagents can be spawned for parallel investigation:

```
task(agent="explore", task="Research Vibe's permission system")
task(agent="explore", task="Document MCP server capabilities")
```

---

## Capability Matrix

| Subagent | Read | Write | Bash | Grep | Task | Skill | Web |
|----------|------|-------|------|------|------|-------|------|
| explore | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| code-reviewer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| security-specialist | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |

*Note: Actual permissions are configured in `.vibe/config/permissions.json`*

---

## Related Documentation

- [Root AGENTS.md](../AGENTS.md) - Collaboration principles
- [Phase 4: Agent & Subagent Migration](../../SPECIFICATIONS/04-agent-subagent-migration.md) - Migration plan
- [.claude/agents/CLAUDE.md](../../.claude/agents/CLAUDE.md) - Original Claude agent definitions (archive)
