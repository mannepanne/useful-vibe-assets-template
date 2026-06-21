# Implementation specifications library

> **⚠️ TEMPLATE GUIDANCE** - This file has been adapted from SPECIFICATIONS/CLAUDE.md for the Vibe migration project. It serves as the library index for implementation phases.

Auto-loaded when working with files in this directory. Forward-looking plans for the Vibe migration.

---

## Purpose of this folder

The SPECIFICATIONS folder contains **forward-looking plans** for migrating this template from Claude Code to Mistral Vibe. These are living documents that guide the migration and evolve as we learn more about Vibe's capabilities.

### Key principles

1. **Minimal changes only** - Preserve everything that isn't Claude-specific
2. **Leverage Vibe's strengths** - Incorporate MCP servers, connectors, and other Vibe-unique features where beneficial
3. **Small, focused phases** - Each phase delivers something complete and testable
4. **Document differences** - This is a learning exercise; explain Claude vs Vibe differences
5. **Maintain backward compatibility** - Keep original files in archive during migration

## Active implementation phases

Development is organised into **7 sequential phases**. Each phase focuses on a specific aspect of the migration, with clear deliverables and acceptance criteria.

**Current phase:** All phases completed - Migration ready for production use

### Phase files (work through in order)

1. **[01-research-and-planning.md](./ARCHIVE/01-research-and-planning.md)** - Phase 1: Research and Foundation (✅ COMPLETED - archived in PR #1)
   Foundational research, Vibe architecture understanding, difference documentation, .vibe/ structure creation

2. **[02-documentation-migration.md](./ARCHIVE/02-documentation-migration.md)** - Phase 2: Documentation Migration (✅ COMPLETED - archived in PR #2)
   Converted all CLAUDE.md files to AGENTS.md, updated all references throughout. Created .vibe/COLLABORATION/ directory with adapted files. Preserved .claude/ for backward compatibility.

3. **[03-configuration-system.md](./ARCHIVE/03-configuration-system.md)** - Phase 3: Configuration System (✅ COMPLETED - archived in PR #3)
   Created .vibe/ directory structure, project config, permission system adaptation. Established Vibe's declarative permission model replacing Claude's hooks.

4. **[04-agent-subagent-migration.md](./ARCHIVE/04-agent-subagent-migration.md)** - Phase 4: Agent & Subagent Migration (✅ COMPLETED - archived in PR #4)
   Migrated all Claude agent definitions to Vibe subagent profiles with proper frontmatter, tool grant asymmetry, and Vibe-specific enhancements.

5. **[05-skills-migration.md](./ARCHIVE/05-skills-migration.md)** - Phase 5: Skills Migration (✅ COMPLETED - archived in PR #5)
   Converted all slash-command skills to Vibe skill format, adapted agent spawning to use task tool, created new skills for profile setup.

6. **[06-safety-and-hooks.md](./ARCHIVE/06-safety-and-hooks.md)** - Phase 6: Safety Harness & Hooks (✅ COMPLETED - archived in PR #6)
   Migrated all hooks to Vibe's permission system, created comprehensive safety documentation, archived all original hooks.

7. **[07-validation-and-completion.md](./ARCHIVE/07-validation-and-completion.md)** - Phase 7: Validation and Completion (✅ COMPLETED - archived in PR #7)
   Created comprehensive test suites, completed migration validation, updated all documentation, archived all original files.

### Supporting folders

### ORIGINAL_IDEA/
Store project vision and concept documents:
- `project-outline.md` - Master specification and product vision (already filled in)

### ARCHIVE/
Completed specifications will be moved here after each phase is verified and merged.

### REFERENCE/decisions/
Architecture Decision Records for migration-specific decisions:
- Search here BEFORE making architectural decisions
- Follow existing ADRs unless new information invalidates reasoning
- Document new architectural decisions here

---

## Migration approach overview

### What changes

| Claude Component | Vibe Equivalent | Migration Complexity |
|-----------------|-----------------|---------------------|
| `.claude/` directory | `.vibe/` directory | Medium - structure is different |
| `CLAUDE.md` files | `AGENTS.md` files | Low - rename and minor content updates |
| Hooks (PreToolUse, SessionStart) | Built-in tool permissions | High - different paradigm |
| Slash-command skills | `skill` tool | Medium - similar concept, different implementation |
| Agent definitions (YAML frontmatter) | Subagent definitions | Medium - different format and capabilities |
| `project-config.json` | Vibe config files | Medium - different schema |

### What stays the same

- Core documentation structure (SPECIFICATIONS/, REFERENCE/, SCRATCH/)
- Lifecycle-based documentation philosophy
- Token efficiency principles
- Tests as guardrails approach
- Collaboration framework and principles
- Phase-based development workflow

### Vibe-specific enhancements to consider

| Vibe Feature | Potential Use in Template | Benefit |
|--------------|---------------------------|---------|
| MCP servers | Integration with external tools/docs | Live documentation, API access |
| Connectors | Project-specific connectors | Custom tool integration |
| Local model support | Offline/private model options | Privacy, cost reduction |
| `task` tool | Delegate complex tasks to subagents | Better parallelization |
| `skill` tool | Structured, reusable workflows | Consistency, maintainability |
| Built-in permissions | Fine-grained tool control | Security, safety |

---

## When specs move to archive

After completing a phase and merging the PR:
1. Move the phase file to `ARCHIVE/`
2. Update implementation docs in `REFERENCE/` if needed
3. Update this index to reflect current phase

---

## Learning objectives

This migration serves as a learning exercise. Key questions to answer:

1. **How does Vibe's permission system differ from Claude's hooks?**
2. **What are Vibe's subagent capabilities vs Claude's agents?**
3. **How do Vibe skills compare to Claude's slash-command skills?**
4. **What Vibe-unique features should we incorporate?**
5. **What patterns from the Claude template don't translate well to Vibe?**

Document answers to these in `REFERENCE/vibe-learning-notes.md` as we progress through phases.
