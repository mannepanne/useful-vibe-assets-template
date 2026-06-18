# AGENTS.md

Navigation index and quick reference for working with this project using **Mistral Vibe**.

> **🚧 Migration in Progress: Claude Code → Mistral Vibe CLI**
> 
> This is the Vibe version of CLAUDE.md. The template is being migrated from Claude Code to Mistral Vibe. See [SPECIFICATIONS/AGENTS.md](./SPECIFICATIONS/AGENTS.md) for implementation phases.

---

## Rules of engagement

Collaboration principles and ways of working: @.vibe/AGENTS.md

When asked to remember anything, add project memory in this AGENTS.md (project root), not @.vibe/AGENTS.md.

**Vibe-specific**: Vibe uses the `task` tool for subagent delegation instead of Claude's `SpawnAgent`. Use `task(agent="explore", task="...")` for complex investigations.

---

## Project overview

**useful-vibe-assets-template** - A Vibe-optimized fork of Magnus's battle-tested AI-assisted development template, enabling fair comparison between Claude Code and Mistral Vibe.

**Core workflow:**
1. Create feature branch for each change
2. Read relevant SPECIFICATIONS/ phase files
3. Implement against acceptance criteria
4. Review with Vibe-native workflows (in development)
5. Merge via PR

**Full specification:** [SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md](./SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md)

---

## Current Migration Status

**Current phase:** Phase 6 (Safety and Hooks) - Phase 5 ✅ Complete and archived in SPECIFICATIONS/ARCHIVE/05-skills-migration.md

**Phase 1 Completed:**
- ✅ `.vibe/` directory structure established
- ✅ `.vibe/AGENTS.md` - Vibe collaboration principles
- ✅ `.vibe/config/` - Permission system and project config
- ✅ `.vibe/agents/AGENTS.md` - Subagent library index
- ✅ `.vibe/skills/AGENTS.md` - Skills library index
- ✅ `.vibe/hooks/AGENTS.md` - Hooks/permissions documentation
- ✅ `AGENTS.md` (root) - Navigation index
- ✅ `REFERENCE/vibe-learning-notes.md` - Practical findings (created in Phase 1)
- ✅ `REFERENCE/vibe-architecture-overview.md` - Architecture reference (created in Phase 1)
- ✅ `SPECIFICATIONS/ARCHIVE/01-research-and-planning.md` - Completed spec archived

**Phase 2 Completed:**
- ✅ `.vibe/COLLABORATION/` directory created with adapted CLAUDE.md files
- ✅ All CLAUDE.md files renamed to AGENTS.md (root, REFERENCE/, REFERENCE/decisions/, REFERENCE/TEMPLATE-UPDATES/, SPECIFICATIONS/ARCHIVE/)
- ✅ All internal references updated from CLAUDE.md to AGENTS.md
- ✅ README.md and TEMPLATE-INSTRUCTIONS.md updated for Vibe
- ✅ .claude/ directory preserved for backward compatibility
- ✅ PR #2 merged successfully
- ✅ Spec archived in SPECIFICATIONS/ARCHIVE/02-documentation-migration.md

**Phase 3 Completed:**
- ✅ `.vibe/` directory structure populated with README.md
- ✅ `.vibe/config/` directory with permissions.json, project-config.json, and README.md
- ✅ Safety harness adapted from Claude hooks to Vibe's declarative permission model
- ✅ `REFERENCE/vibe-permissions.md` created with comprehensive permission documentation
- ✅ `.gitignore` updated with .vibe/ specific entries
- ✅ PR #3 merged successfully
- ✅ Spec archived in SPECIFICATIONS/ARCHIVE/03-configuration-system.md

**Phase 4 Completed:**
- ✅ All agent files migrated from `.claude/agents/` to `.vibe/agents/`
- ✅ Frontmatter converted to Vibe format (YAML array for tools, default model, no color)
- ✅ Tool grant asymmetry maintained (spec agents have web_search/web_fetch, PR agents don't)
- ✅ All internal references updated (CLAUDE.md → AGENTS.md, .claude/ → .vibe/)
- ✅ Titles updated from "Agent" to "Subagent"
- ✅ `.vibe/agents/AGENTS.md` created with comprehensive index
- ✅ `triage-scan-patterns.txt` copied
- ✅ Verification script created and passing
- ✅ PR #4 merged successfully
- ✅ Spec archived in SPECIFICATIONS/ARCHIVE/04-agent-subagent-migration.md

**Phase 5 Completed:**
- ✅ All skill files migrated from `.claude/skills/` to `.vibe/skills/`
- ✅ `review-pr/SKILL.md` - Smart PR review dispatcher
- ✅ `review-pr-team/SKILL.md` - Multi-perspective team review
- ✅ `review-spec/SKILL.md` - Spec review workflow
- ✅ `review-gate.md` - Shared gate logic for all review skills
- ✅ `post-review-follow-through.md` - Follow-through protocol
- ✅ `check-profile-setup/SKILL.md` - Profile setup check (new, replaces SessionStart hook)
- ✅ `setup-profile/SKILL.md` - Profile setup guide (new)
- ✅ Frontmatter converted to Vibe format (removed `disable-model-invocation`, updated `arguments`)
- ✅ Agent spawning converted from `SpawnAgent` to Vibe's `task` tool
- ✅ All `.claude/` references updated to `.vibe/` in skill files
- ✅ `.vibe/skills/AGENTS.md` updated with comprehensive skills index
- ✅ Verification script `SCRATCH/verify-skills.sh` created and passing
- ✅ Spec archived in SPECIFICATIONS/ARCHIVE/05-skills-migration.md with implementation notes

---

## Implementation phases

Development is organised into 7 sequential phases for the Vibe migration:

1. **[01-research-and-planning.md](./SPECIFICATIONS/ARCHIVE/01-research-and-planning.md)** - Research and Foundation (✅ COMPLETED)
   - Vibe architecture understanding
   - .vibe/ structure creation
   - Difference documentation

2. **[02-documentation-migration.md](./SPECIFICATIONS/ARCHIVE/02-documentation-migration.md)** - Documentation Migration (✅ COMPLETED in PR #2)
   - Converted CLAUDE.md → AGENTS.md files
   - Updated all references throughout the project
   - Created .vibe/COLLABORATION/ directory with adapted files

3. **[03-configuration-system.md](./SPECIFICATIONS/ARCHIVE/03-configuration-system.md)** - Configuration System (✅ COMPLETED in PR #3)
   - .vibe/config/ permissions
   - Project configuration

4. **[04-agent-subagent-migration.md](./SPECIFICATIONS/ARCHIVE/04-agent-subagent-migration.md)** - Agent & Subagent Migration (✅ COMPLETED in PR #4)
   - Convert agent definitions
   - Test subagent workflows

5. **[05-skills-migration.md](./SPECIFICATIONS/ARCHIVE/05-skills-migration.md)** - Skills Migration (✅ COMPLETED)
   - Convert slash commands to skills
   - Address the catch-22 problem
   - All review skills migrated and adapted for Vibe

6. **[06-safety-and-hooks.md](./SPECIFICATIONS/06-safety-and-hooks.md)** - Safety Harness & Hooks
   - Permission configuration
   - Safety patterns

7. **[07-validation-and-completion.md](./SPECIFICATIONS/07-validation-and-completion.md)** - Validation and Completion
   - End-to-end testing
   - Backward compatibility

**Each phase includes:**
- Clear scope and acceptance criteria
- Testing strategy (verification for research phases)
- Pre-commit checklist
- PR workflow and review requirements
- Technical considerations and edge cases

---

## Vibe Configuration Reference

### Directory Structure

```
.vibe/
├── AGENTS.md                    # Vibe collaboration principles (this replaces .claude/CLAUDE.md)
├── config/
│   ├── permissions.json         # Tool permission configuration (replaces .claude/settings.json + hooks)
│   └── project-config.json      # Project-level settings (replaces .claude/project-config.json)
├── agents/
│   └── AGENTS.md                # Subagent library index
├── skills/
│   └── AGENTS.md                # Skills library index
└── hooks/
    └── AGENTS.md                # Hooks/permissions documentation
```

### Key Files

- **[.vibe/AGENTS.md](.vibe/AGENTS.md)** - Core collaboration principles for Vibe
- **[.vibe/config/permissions.json](.vibe/config/permissions.json)** - Tool permission configuration
- **[.vibe/config/project-config.json](.vibe/config/project-config.json)** - Project settings (includes reviewSystem.mode)

---

## Documentation organisation pattern

**Vibe adaptation of the lifecycle-based documentation pattern:**

- **Root AGENTS.md** (this file) - Project navigation and status
- **.vibe/AGENTS.md** - Vibe-specific collaboration principles
- **SPECIFICATIONS/** - Active phase work
- **SPECIFICATIONS/ARCHIVE/** - Completed phases
- **REFERENCE/** - How-it-works documentation
- **.vibe/COLLABORATION/** - Behavioral guidance (to be created)

*Keep AGENTS.md files short (<300 lines). Break details into separate reference files.*

---

## Architecture overview (Vibe-specific)

**Vibe's tool model:**
- **Tools**: Built-in operations (read, write, grep, bash, etc.) with permission gating
- **Subagents**: Delegated tasks via `task` tool, operating within conversation context
- **Skills**: Structured workflows via `skill` tool, defined in SKILL.md files
- **MCP Servers**: Live external resource integration (Vibe-unique)
- **Connectors**: Custom tool integrations (Vibe-unique)

**Key differences from Claude:**
- No hooks → Declarative permissions
- No SpawnAgent → `task` tool with subagent profiles
- No slash commands → `skill` tool with SKILL.md files
- New capabilities: MCP servers, connectors, local models

---

## Code conventions

- **Branch naming**: `feature/`, `fix/`, `refactor/`, `docs/` prefixes
- **Commit messages**: Brief summary first line, context in body
- **Pull requests**: Always required, never push to main directly
- **Review requirements**: Tests pass, documentation current, code clean

---

## Technology defaults

**Vibe-specific stack:**
- **Primary**: Mistral Vibe CLI
- **Configuration**: JSON-based in `.vibe/config/`
- **Skills**: SKILL.md files
- **Subagents**: Profile-based via `task` tool
- **MCP Servers**: For GitHub, documentation, package registries (optional)

**Traditional stack** (unchanged from original template):
- TypeScript, Next.js, Cloudflare Workers, Supabase, Vitest

*See .vibe/COLLABORATION/technology-preferences.md for rationale (once migrated).*

---

## Credits & License

**Collaboration patterns** inspired by:
- @obra
- @harperreed
- OpenAI's Harness Engineering
- steipete/agent-rules

**Template**: MIT License - Use freely, adapt as needed, share improvements.

---

*Template guidance: Replace project-specific sections when using this template for a new project.*
