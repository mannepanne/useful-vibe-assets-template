# Phase 1: Research and Foundation

**Phase number:** 1
**Phase name:** Research and Foundation
**Estimated timeframe:** 1-2 sessions
**Dependencies:** None - starting phase
**Status:** Not started

---

## Phase overview

This foundational phase establishes our understanding of Mistral Vibe's architecture and how it differs from Claude Code. We'll document these differences, create the basic `.vibe/` directory structure, and prepare for the subsequent migration phases.

This phase is **primarily a learning and planning exercise** - we're not making significant changes to the template yet, just understanding what needs to change and documenting our findings.

---

## Scope and deliverables

### In scope

- [ ] Research Vibe's tool model (tools, permissions, subagents, skills, task delegation)
- [ ] Document key differences between Claude Code and Vibe
- [ ] Create `.vibe/` directory structure
- [ ] Create initial `.vibe/AGENTS.md` with collaboration principles
- [ ] Draft `REFERENCE/vibe-learning-notes.md` with findings
- [ ] Create `REFERENCE/vibe-architecture-overview.md` explaining Vibe's model
- [ ] Identify Vibe-unique features worth incorporating (MCP, connectors, local models)
- [ ] Update root `AGENTS.md` to reference new structure

### Out of scope

- Any actual file renames (CLAUDE.md → AGENTS.md) - this happens in Phase 2
- Any configuration migration - this happens in Phase 3
- Any agent/subagent conversion - this happens in Phase 4
- Any skills migration - this happens in Phase 5
- Any hooks migration - this happens in Phase 6

### Acceptance criteria

- [ ] `REFERENCE/vibe-learning-notes.md` exists and documents all major differences
- [ ] `REFERENCE/vibe-architecture-overview.md` exists with clear explanations
- [ ] `.vibe/` directory exists with basic structure
- [ ] `.vibe/AGENTS.md` exists with Vibe-appropriate collaboration principles
- [ ] Root `AGENTS.md` references the new `.vibe/` structure
- [ ] All documentation is clear enough for Magnus to understand Vibe's model

---

## Technical approach

### Vibe Architecture Research

We need to understand Vibe's core components:

1. **Tool System** - How tools are defined and invoked
2. **Permission Model** - How tool permissions work (built-in vs Claude's hooks)
3. **Subagents** - How subagents are defined and spawned (vs Claude's agents)
4. **Skills** - How skills are structured and loaded (vs Claude's slash commands)
5. **Task Delegation** - How the `task` tool works for delegating to subagents
6. **MCP Servers** - Vibe's unique MCP server integration
7. **Connectors** - Vibe's connector system for external tools

### Key Differences to Document

| Aspect | Claude Code | Mistral Vibe | Migration Impact |
|--------|-------------|--------------|-----------------|
| Agent configuration | `.claude/` directory | `.vibe/` directory | Directory rename, structure changes |
| Auto-loaded files | `CLAUDE.md` (root and `.claude/`) | `AGENTS.md` (root and `.vibe/`) | File rename |
| Sub-agents | YAML frontmatter in .md files | Subagent profiles | Format conversion |
| Skills/Commands | Slash commands (`/review-pr`) | `skill` tool with SKILL.md files | Conversion needed |
| Hooks | PreToolUse, SessionStart scripts | Built-in tool permissions | Paradigm shift |
| Tool invocation | Bash, Read, Glob, Grep, etc. | Same tools, different permission model | Permission config needed |
| External integrations | Custom hooks | MCP servers, connectors | New capabilities |

### Directory Structure to Create

```
.vibe/
├── AGENTS.md                    # Vibe collaboration principles (replaces .claude/CLAUDE.md)
├── config/                      # Configuration files
│   └── project-config.json      # Project-level configuration
├── agents/                      # Subagent definitions (replaces .claude/agents/)
│   ├── code-reviewer.md         # Example subagent
│   ├── technical-writer.md       # Example subagent
│   └── AGENTS.md                # Agent library index
├── skills/                      # Vibe skills (replaces .claude/skills/)
│   ├── review-pr/
│   │   └── SKILL.md
│   ├── review-pr-team/
│   │   └── SKILL.md
│   ├── review-spec/
│   │   └── SKILL.md
│   └── AGENTS.md                # Skills library index
└── hooks/                       # (Optional) If we need any custom logic
    └── AGENTS.md
```

### Vibe-Unique Features to Evaluate

1. **MCP Servers** - Should we add MCP server configurations for common dev tools?
   - Potential: GitHub, documentation servers, package registries
   - Benefit: Live access to external resources

2. **Connectors** - Should we define project-specific connectors?
   - Potential: Custom tool integrations
   - Benefit: Extensibility

3. **Local Model Support** - Should we document local model usage?
   - Benefit: Privacy, offline capability, cost reduction

4. **Task Delegation** - How can we leverage the `task` tool?
   - Benefit: Better parallelization of review workflows

---

## Learning Documentation

### REFERENCE/vibe-learning-notes.md

This document should capture:

1. **Conceptual Differences**
   - How Vibe thinks about "agents" vs Claude's approach
   - The relationship between skills, subagents, and tools
   - Permission model philosophy

2. **Practical Differences**
   - How to spawn a subagent in Vibe vs Claude
   - How skills are invoked and what they can do
   - Tool permission configuration

3. **Migration Patterns**
   - What translates directly
   - What needs adaptation
   - What needs complete rethinking

4. **Vibe Strengths**
   - Features that don't exist in Claude
   - How to leverage them in the template

### REFERENCE/vibe-architecture-overview.md

This document should explain:

1. **Vibe's Mental Model**
   - How Vibe organizes conversation context
   - How tools are made available
   - How permissions flow works

2. **Subagent Architecture**
   - How subagents are defined
   - What capabilities they have
   - How they differ from Claude's agents

3. **Skill System**
   - How skills are structured
   - How they relate to subagents
   - How they're invoked

4. **Task Delegation**
   - When to use `task` vs direct tool calls
   - Subagent capabilities and limitations
   - Result handling

---

## Testing strategy

This phase is primarily documentation and research, so testing is qualitative:

### Verification checklist
- [ ] Magnus can read `REFERENCE/vibe-learning-notes.md` and understand Vibe's model
- [ ] Magnus can read `REFERENCE/vibe-architecture-overview.md` and explain it back
- [ ] The `.vibe/` structure makes sense and is properly documented
- [ ] All major differences between Claude and Vibe are clearly documented
- [ ] We have a clear plan for how each subsequent phase will work

### Acceptance review
Use `/review-spec` (once available) or manual review against these criteria:
1. Documentation is comprehensive and accurate
2. Directory structure is logical and well-documented
3. All open questions from project-outline.md are addressed or acknowledged
4. Subsequent phases have clear prerequisites

---

## Pre-commit checklist

Before creating PR for Phase 1:

- [ ] `REFERENCE/vibe-learning-notes.md` created and reviewed
- [ ] `REFERENCE/vibe-architecture-overview.md` created and reviewed
- [ ] `.vibe/` directory created with basic structure
- [ ] `.vibe/AGENTS.md` created with collaboration principles
- [ ] Root `AGENTS.md` updated to reference new structure
- [ ] All links between documents work
- [ ] No secrets or sensitive data in new files
- [ ] Documentation is clear and well-structured

---

## PR workflow

### Branch naming
```
feature/phase-1-research-and-foundation
```

### PR title
```
Phase 1: Research and Foundation - Vibe migration groundwork
```

### PR description template
```markdown
## Summary
Establishes foundational understanding of Mistral Vibe's architecture and creates the basic `.vibe/` directory structure for the template migration.

## Changes
- Added `REFERENCE/vibe-learning-notes.md` - Key differences between Claude and Vibe
- Added `REFERENCE/vibe-architecture-overview.md` - Vibe's architecture explained
- Added `.vibe/` directory with basic structure
- Added `.vibe/AGENTS.md` - Vibe collaboration principles
- Updated root `AGENTS.md` to reference new structure

## Testing
- Documentation reviewed for clarity and accuracy
- Directory structure validated
- All internal links verified

## Learning Outcomes
[List key insights about Vibe that will inform subsequent phases]
```

### Review requirements
- Use `/review-pr` (once available) or manual review
- Focus on documentation clarity and accuracy
- Verify that the learning objectives are met

---

## Edge cases and considerations

### Known risks
- **Incomplete understanding**: We may discover Vibe features during later phases that require revisiting Phase 1 documentation. Mitigation: Treat Phase 1 docs as living documents; update as we learn more.
- **Vibe evolution**: Vibe may change during our migration. Mitigation: Document Vibe version used; note any version-specific behaviors.

### Open questions to resolve
1. Should we incorporate MCP server configurations in the template?
2. Should we add connector definitions for common tools?
3. How should we handle the profile setup flow in Vibe?
4. Should we maintain dual Claude/Vibe support during migration? (Out of scope per project-outline.md, but worth confirming)

### Vibe-specific opportunities
- **MCP Documentation Server**: Could we use an MCP server to provide live access to template documentation?
- **Skill discovery**: How can we make Vibe skills as discoverable as Claude's slash commands?
- **Subagent specialization**: Can we create more specialized subagents that leverage Vibe's capabilities?

---

## Vibe vs Claude: Deep Dive Comparisons

This section captures detailed technical comparisons to inform our migration approach.

### 1. Tool Permission Model

**Claude Code:**
- Uses an allowlist in `.claude/settings.json`
- Hooks (PreToolUse, PostToolUse) can intercept and modify tool calls
- Hooks are bash scripts that emit JSON
- Allowlist controls whether a prompt is shown, not whether the tool runs

**Mistral Vibe:**
- Built-in tool permission system
- Each tool has configurable permissions
- More fine-grained control per tool
- No separate hook system - permissions are integrated

**Migration approach:**
- Safety harness patterns need to be implemented as permission restrictions
- PreToolUse logic becomes tool permission configuration
- SessionStart logic may need different handling (possibly a skill or initial check)

### 2. Agent/Subagent Model

**Claude Code:**
- Agents defined as markdown files with YAML frontmatter
- Frontmatter specifies: name, description, tools, model, color
- Spawned via `SpawnAgent` or by reference in skills
- Run in parallel or sequentially

**Mistral Vibe:**
- Subagents are a core concept
- Defined via the `task` tool with agent profiles
- Can have specialized capabilities
- Integrated with the conversation context

**Migration approach:**
- Convert YAML frontmatter to Vibe subagent profiles
- Map agent tools to Vibe tool permissions
- Consider leveraging Vibe's task delegation for complex workflows

### 3. Skills System

**Claude Code:**
- Skills are slash commands (`/review-pr`)
- Defined as markdown files with YAML frontmatter
- Frontmatter: name, description, disable-model-invocation, user-invocable, argument-hint
- Can spawn sub-agents
- Complex multi-step workflows

**Mistral Vibe:**
- Skills are loaded via the `skill` tool
- SKILL.md files define the skill
- Can use subagents via `task` tool
- Integrated with tool permissions

**Migration approach:**
- Convert slash command skills to Vibe skills
- Map argument patterns to Vibe's skill invocation
- Adapt agent spawning to use `task` tool

### 4. Configuration

**Claude Code:**
- `.claude/settings.json` - Tool allowlist and hook registration
- `.claude/project-config.json` - Project-level flags
- `.claude/project-config.local.json` - Local overrides (gitignored)

**Mistral Vibe:**
- Configuration is per-project and per-user
- Tool permissions configured differently
- May have project-level config files

**Migration approach:**
- Map `.claude/settings.json` to Vibe's permission configuration
- Map `.claude/project-config.json` to appropriate Vibe config
- Maintain local override pattern with gitignored files

---

## Related documentation

- [Root AGENTS.md](../AGENTS.md) - Implementation library index
- [ORIGINAL_IDEA/project-outline.md](../ORIGINAL_IDEA/project-outline.md) - Master specification
- [REFERENCE/vibe-learning-notes.md](../REFERENCE/vibe-learning-notes.md) - (To be created)
- [REFERENCE/vibe-architecture-overview.md](../REFERENCE/vibe-architecture-overview.md) - (To be created)

---

## Notes

This phase is intentionally **research-heavy**. The quality of our entire migration depends on how well we understand Vibe's architecture in this phase. Take time to experiment, ask questions, and document findings thoroughly.

The documentation created in this phase will serve as reference for:
- Magnus learning Vibe
- Future maintainers of the Vibe template
- Anyone comparing Claude Code and Vibe approaches

**Key principle:** When in doubt, document it. If we're unsure about something, we document the uncertainty and flag it for resolution in later phases.
