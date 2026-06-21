# AGENTS.md

Navigation index and quick reference for working with this project using **Mistral Vibe**.

> **🚀 First time with this template?**
> Run `skill(name="setup-profile")` to configure your personal profile and review system settings.

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
4. Review with Vibe-native workflows
5. Merge via PR

**Full specification:** [SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md](./SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md)

---

## Vibe Configuration Reference

### Directory Structure

```
.vibe/
├── AGENTS.md                    # Vibe collaboration principles
├── COLLABORATION/             # Behavioral guidance, PM mode, tech preferences
├── config/
│   ├── permissions.json         # Tool permission configuration
│   └── project-config.json      # Per-project feature flags
├── agents/                # Subagent definitions
├── skills/                # Automated workflows and review systems
└── hooks/                 # Hooks/permissions documentation
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
- **SPECIFICATIONS/ARCHIVE/** - Completed phases and historical migration documents
- **REFERENCE/** - How-it-works documentation
- **.vibe/COLLABORATION/** - Behavioral guidance

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

*See .vibe/COLLABORATION/technology-preferences.md for rationale.*

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
