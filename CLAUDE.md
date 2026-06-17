# CLAUDE.md

Navigation index and quick reference for working with this project.

---

**⚠️ THIS IS A TEMPLATE** - Replace this entire file with your project-specific content when starting a new project. Use the sections below as a guide for what to include.

---

## Rules of engagement

Collaboration principles and ways of working: @.claude/CLAUDE.md
When asked to remember anything, add project memory in this CLAUDE.md (project root), not @.claude/CLAUDE.md.

## Project overview

**[PROJECT NAME]** - [One sentence description of what this project does]

**[Optional: Name inspiration or meaningful context about the project name]**

**Core workflow:**
1. [Key user action or process step 1]
2. [Key user action or process step 2]
3. [Key user action or process step 3]
4. [Key user action or process step 4]

**Full specification:** [Link to master spec in SPECIFICATIONS/ORIGINAL_IDEA/]

## Architecture overview

**Stack:**
- **Framework**: [e.g., Next.js 14+, Django, FastAPI, etc.]
- **Styling**: [e.g., Tailwind CSS, styled-components, etc.]
- **Database**: [e.g., Supabase, PostgreSQL, MongoDB, etc.]
- **Email**: [e.g., Resend, SendGrid, etc. - if applicable]
- **Deployment**: [e.g., Cloudflare Workers, Vercel, AWS, etc.]
- **Domain**: [e.g., example.com or "TBD"]

**Key Integrations:**
- [External API or service 1]
- [External API or service 2]
- [External API or service 3]

**Current Status:** [e.g., "Planning complete - ready to begin Phase 1", "In development - Phase 3", "Production ready"]

## Implementation phases

Development is organised into numbered phases with clear deliverables, testing requirements, and PR workflows.

1. [01-phase-name.md](./SPECIFICATIONS/01-phase-name.md) - [Brief description] ([Timeframe])
2. [02-phase-name.md](./SPECIFICATIONS/02-phase-name.md) - [Brief description] ([Timeframe])
3. [03-phase-name.md](./SPECIFICATIONS/03-phase-name.md) - [Brief description] ([Timeframe])
4. [etc...]

**Each phase includes:**
- Clear scope and acceptance criteria
- Testing strategy (target: 95%+ coverage)
- Pre-commit checklist (tests, type-checking, manual verification)
- PR workflow and review requirements
- Technical considerations and edge cases

**Current phase:** [Phase number and name]

### SPECIFICATIONS/
- **Implementation phases** (numbered files) - Active work-in-progress
- **ORIGINAL_IDEA/** - Master spec, product vision, naming inspiration
- **ARCHIVE/** - Completed specs (move here when phase complete)

### REFERENCE/
How-it-works documentation for implemented features:
- [testing-strategy.md](./REFERENCE/testing-strategy.md) - Testing philosophy and approach
- [environment-setup.md](./REFERENCE/environment-setup.md) - API keys and environment configuration
- [troubleshooting.md](./REFERENCE/troubleshooting.md) - Common issues and solutions
- [TEMPLATE-UPDATES/](./REFERENCE/TEMPLATE-UPDATES/) - Migration packets for rolling out template improvements to derivative projects
- [Add project-specific reference docs as they're created]

*Note: Keep CLAUDE.md files short (<300 lines). Break details into separate reference files with succinct summaries. CLAUDE.md files work as "library index" to find context when needed, minimising token usage.*

## Code conventions

### File headers
```typescript
// ABOUT: Brief description of file purpose
// ABOUT: Key functionality or responsibility
```

### Naming
- Descriptive names: [Provide project-specific examples]
- TypeScript conventions: camelCase (variables), PascalCase (types)
- Avoid temporal references: no "new", "improved", "old"

### Comments
- Evergreen (describe what code does, not recent changes)
- Minimal (code should be self-documenting)
- Explain complex logic and non-obvious decisions

## Development workflow

**⚠️ CRITICAL: ALL CODE CHANGES REQUIRE A FEATURE BRANCH + PR ⚠️**

**Step 0 (BEFORE making ANY changes):**
- [ ] On feature branch (not main)?
- [ ] If on main: create feature branch first

**CRITICAL: ALL changes require feature branch + PR. NEVER work on main. Zero exceptions.**

**Implementation steps:**
1. Create feature branch (feature/, fix/, refactor/)
2. Check SPECIFICATIONS/ for relevant specs
3. Review spec with **`/review-spec`** before starting non-trivial features
4. Implement with tests (run tests + type checking)
5. Create PR for review:
  - **`/review-pr`** - Smart dispatcher: triages the change and routes to light / standard / team (1–5 min end-to-end; longer when auto-escalated to team tier)
  - **`/review-pr-team`** - Force team review, skip triage (2–7 min)
  - **See:** [pr-review-workflow.md](./REFERENCE/pr-review-workflow.md)

## TypeScript configuration

[Customise based on your project]
- Target: [e.g., ESNext, ES2022, etc.]
- Strict mode: [enabled/disabled]
- Path alias: [e.g., `@/` maps to `./src/`]
- Special types: [e.g., React, Next.js, Node, etc.]

## Testing

Tests serve dual purpose:
1. **Validation** - Verify code works
2. **Directional Context** - Guide AI development

**Commands:**
```bash
npm test                  # Run all tests
npm run test:watch        # Watch mode
npm run test:coverage     # Coverage report
```

**Coverage target:** 100% (enforced minimums: 95% lines/functions/statements, 90% branches)

**See:** [testing-strategy.md](./REFERENCE/testing-strategy.md) for complete details

## Quick reference links

**Planning & Specs:**
- **Project outline** → [SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md](./SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md)
- **Implementation phases** → See section above or [SPECIFICATIONS/](./SPECIFICATIONS/)
- **Completed specs** → [ARCHIVE/](./SPECIFICATIONS/ARCHIVE/)
- **Other ORIGINAL_IDEA documents** (naming, brainstorms, research — if you've added any) → [SPECIFICATIONS/ORIGINAL_IDEA/](./SPECIFICATIONS/ORIGINAL_IDEA/)

**Reference Docs:**
- **Setting up environment?** → [environment-setup.md](./REFERENCE/environment-setup.md)
- **Testing strategy?** → [testing-strategy.md](./REFERENCE/testing-strategy.md)
- **Known issues / technical debt?** → GitHub Issues with `technical-debt` label
- **Getting unstuck?** → [troubleshooting.md](./REFERENCE/troubleshooting.md)
- **Architecture decisions?** → [decisions/](./REFERENCE/decisions/) - ADRs explaining why things are this way
- **Rolling out a template improvement?** → [TEMPLATE-UPDATES/](./REFERENCE/TEMPLATE-UPDATES/) - Migration packets for derivative projects

## Project-specific notes

[Add any project-specific context, quirks, or important information here]

**Example topics:**
- Special build considerations
- Deployment gotchas
- External service limitations
- Performance targets
- Security requirements
- Compliance considerations

---

**Remember:** This file is your navigation hub. Keep it current as the project evolves, but keep it concise. Details belong in subdirectory files.
