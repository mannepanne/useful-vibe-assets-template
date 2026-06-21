# Migration from Claude Code - Historical Archive

> **📚 Historical Context Only**
>
> The files in this directory document the migration process from Claude Code to Mistral Vibe CLI. They are preserved for historical reference and learning purposes only.
>
> **These files are NOT part of the active template** - they describe how the template was adapted, not how to use it.

---

## What this archive contains

This directory contains all specifications, documentation, and original files from the migration project that adapted Magnus's battle-tested Claude Code template for use with Mistral Vibe CLI.

### Phase Specifications
- **01-research-and-planning.md** - Initial research and foundation planning
- **02-documentation-migration.md** - Documentation rename from CLAUDE.md to AGENTS.md
- **03-configuration-system.md** - Vibe configuration system setup
- **04-agent-subagent-migration.md** - Agent and subagent migration
- **05-skills-migration.md** - Skills migration from slash commands
- **06-safety-and-hooks.md** - Safety harness and hooks adaptation
- **07-validation-and-completion.md** - Final validation and completion

### Original Files
- **claude-originals/** - All original CLAUDE.md files preserved for backward compatibility
- **claude-hooks/** - All original Claude hooks archived with documentation

### Investigation Documents
- **INVESTIGATION-claude-code-write-path-normalisation.md** - Diagnosis of write path issues
- **pretooluse-safety-harness.md** - PreToolUse safety harness implementation
- **CLAUDE.md** - Original archive specifications file

---

## How to use this archive

These files are **read-only reference material**. They exist to:

1. **Document the migration journey** - Understanding what changed and why
2. **Preserve institutional knowledge** - Lessons learned during adaptation
3. **Enable rollback** - If needed, original files are preserved

**For actual template usage**, refer to:
- Root [AGENTS.md](../../../AGENTS.md) - Project navigation and collaboration principles
- [README.md](../../../README.md) - Template overview and usage instructions
- [TEMPLATE-INSTRUCTIONS.md](../../../TEMPLATE-INSTRUCTIONS.md) - How to use this template
- [REFERENCE/](../../../REFERENCE/) - How implemented features work

---

## Key Migration Decisions

The migration preserved the core philosophy and structure while adapting tool-specific implementations:

| Claude Code | Mistral Vibe | Migration Approach |
|-------------|--------------|-------------------|
| `CLAUDE.md` | `AGENTS.md` | Simple rename |
| `.claude/` | `.vibe/` | Directory rename, content adaptation |
| Hooks | Permissions JSON | Declarative permission model |
| Slash commands | Skills | SKILL.md files with `skill` tool |
| `SpawnAgent` | `task` tool | Subagent delegation |

---

**Note:** All files in this directory are frozen as of the completion of Phase 7. They will not be updated as the template evolves.
