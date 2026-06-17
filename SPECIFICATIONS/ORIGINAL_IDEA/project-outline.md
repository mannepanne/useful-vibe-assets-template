# Project outline

> **How to use this file:** This is a stub for Claude to fill in during the orientation conversation. You don't need to write this yourself — talk through the project with Claude and ask it to populate the sections below. Once filled in, this becomes your project's "source of truth" for original intent, referenced throughout development. When you finish populating it, replace `[date when filled in]` at the bottom with today's date.

---

## What this is

A **Vibe-only, Vibe-optimized** fork of Magnus's battle-tested AI-assisted development template. It preserves all the workflow patterns, documentation structure, and collaboration principles from the Claude Code version, but replaces the Claude-specific configuration, hooks, and agent systems with Mistral Vibe equivalents.

---

## Why this exists

To enable a **fair, apples-to-apples comparison** between Claude Code and Mistral Vibe. Magnus has delivered many projects using this template with Claude; by adapting it for Vibe, he can evaluate Vibe's effectiveness using the exact same methodology, workflows, and quality standards he's already validated.

---

## Who it's for

- **Primary**: Magnus Hultberg, for his own project work and evaluation
- **Secondary**: Other developers who want a Vibe-optimized version of this template
- **Tertiary**: The broader community, if published as a standalone template

---

## Core features (in scope)

*The things this project must do to be considered worth shipping. Keep this list small — the smaller the better.*

- Preserve the entire folder structure (`SPECIFICATIONS/`, `REFERENCE/`, `SCRATCH/`)
- Replace `.claude/` with `.vibe/` configuration
- Convert all `CLAUDE.md` files to `AGENTS.md` (Vibe's standard)
- Adapt the safety harness to Vibe's built-in tool permission system
- Convert agent profiles to Vibe subagent definitions
- Adapt review workflows to Vibe's `skill` and `task` tools
- Update all documentation references from Claude to Vibe
- Maintain backward compatibility where possible (keep original files in archive during migration)

---

## Explicitly out of scope

*Things you've considered and consciously decided NOT to build. Just as important as what's in scope. Helps prevent scope creep later.*

- Building an actual product with this template (that's the *next* project)
- Supporting dual Claude/Vibe usage in a single template
- Adding new features beyond what the original template offers
- Rewriting the core methodology — only the tool-specific implementation

---

## What "good" looks like

*Success criteria. How will you know this project is working? Could be qualitative ("I use it every day") or quantitative ("100 active users"). Doesn't need to be measurable, but it does need to be honest.*

- Magnus can open Vibe in a project using this template and it *just works* with the same flow he uses with Claude
- The adapted template produces comparable results (code quality, documentation, review thoroughness)
- The migration is minimal and focused — only changes what's necessary for Vibe compatibility
- Someone familiar with the Claude version can switch to the Vibe version with minimal friction

---

## Constraints and assumptions

*Things that shape the project from the outside: budget, time, hosting limits, regulatory requirements, dependencies on other systems, personal capacity, etc. Also assumptions you're making that could turn out to be wrong.*

- Must maintain the **core philosophy**: token efficiency, lifecycle-based docs, tests as guardrails
- Should be **minimal changes only** — preserve everything that isn't Claude-specific
- **Time box**: This is setup work, not a multi-phase project
- **Assumption**: Vibe's tool model (subagents, skills, permissions) can cover the same use cases as Claude's hooks and slash commands
- **Assumption**: The template will be used for real projects immediately after adaptation

---

## Open questions

*Things you don't yet know the answer to. Worth listing so they don't get forgotten — Claude can help work through these as the project progresses.*

- Are there **Vibe-specific features** we should incorporate that don't exist in the Claude version (e.g., MCP servers, connectors, local model support)?

---

## Naming and inspiration

*Optional. If the project name has a story or there are specific reference points (other products, aesthetic influences, philosophical inspirations), capture them here. Useful when making trade-off decisions later — you can ask "does this still feel like the project we set out to build?"*

Working name: **useful-vibe-assets-template** (matching the original "useful-assets-template"). Inspired by the original template's philosophy. The goal is functional equivalence with the Claude version, not reinvention.

---

*Last updated: 2026-06-17*
