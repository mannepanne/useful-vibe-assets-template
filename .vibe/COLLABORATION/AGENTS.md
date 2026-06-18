# Collaboration Reference Library

Auto-loaded when working with files in this directory. Navigation index for collaboration guidance with Mistral Vibe.

> **Note**: This file adapts the original `.claude/COLLABORATION/CLAUDE.md` for Vibe's tool model.

---

## Files in this directory

### [personal-profile.md](./personal-profile.md) / [personal-profile.local.md](./personal-profile.local.md)
**When to read:** Every session — tells you who you're working with, how they like to be addressed, their background, communication preferences, and PM style.

Read `personal-profile.local.md` if it exists (gitignored, operator's personalised copy); otherwise fall back to `personal-profile.md` (the committed template default). 

**Vibe note**: Unlike Claude's SessionStart hook that automatically detected `PERSONAL_PROFILE_SETUP_REQUIRED`, Vibe does not have this hook. Profile setup should be handled via explicit instructions in AGENTS.md files or first-use detection in skills.

### [profile-setup-flow.md](./profile-setup-flow.md)
**When to read:** When you first start using this template with Vibe.

Step-by-step instructions for personalising the profile, handling the "keep as-is" case, making the file private, and guiding the operator to the project-outline conversation.

**Vibe note**: The original Claude version relied on a SessionStart hook firing. In Vibe, you should run this flow manually on first use or when prompted by a skill.

### [documentation-standards.md](./documentation-standards.md)
**When to read:** Creating or updating project documentation, README files, or reference guides.

Templates and standards for writing clear, complete technical documentation.

### [product-management-mode.md](./product-management-mode.md)
**When to read:** Product discovery, strategy, requirements definition, or business decisions.

**Trigger phrases:** "Let's think about this as PMs", "I need product thinking on this", "Help me with discovery/strategy"

Product Operating Model, four big risks framework, PM mental models, and archetypes for product thinking.

### [technology-preferences.md](./technology-preferences.md)
**When to read:** Selecting frameworks, libraries, services, or making technology stack decisions.

Platform-specific technology preferences and selection criteria across the stack.

**Vibe note**: This template is now optimized for Mistral Vibe CLI. See `.vibe/AGENTS.md` for Vibe-specific preferences.

### [debugging-mindset.md](./debugging-mindset.md)
**When to read:** Working on a tricky bug, considering a workaround vs root-cause fix, or deciding when to ask for help.

Scientific debugging principles, what to do when stuck, and the practical reality check on shortcuts vs proper fixes.

---

## Vibe-Specific Notes

### Tool Model Changes

- **Claude**: Used `SpawnAgent` to spawn sub-agents, hooks for session management
- **Vibe**: Uses `task` tool to delegate to subagents, no SessionStart hook equivalent

### Profile Setup

The original Claude template relied on:
1. SessionStart hook detecting `PERSONAL_PROFILE_SETUP_REQUIRED`
2. Automatic prompt to run profile-setup-flow.md

In Vibe:
1. No automatic detection
2. Profile setup must be initiated manually or via skill first-use detection
3. Consider adding a startup skill that users invoke on first project use

### References Updated

All references to `.claude/COLLABORATION/` have been updated to `.vibe/COLLABORATION/` in this directory's files.
