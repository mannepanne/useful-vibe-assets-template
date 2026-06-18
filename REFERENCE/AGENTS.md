# Reference Documentation Library

Auto-loaded when working with files in this directory. How-it-works documentation for implemented features with Mistral Vibe.

> **Note**: This file adapts the original `REFERENCE/CLAUDE.md` for Vibe's tool model.

---

## Files in this directory

### [testing-strategy.md](./testing-strategy.md)
**When to read:** Writing tests, setting up test coverage, or implementing TDD workflow.

Complete testing philosophy, framework setup (Vitest), test categories, coverage requirements, and CI/CD integration.

### [environment-setup.md](./environment-setup.md)
**When to read:** Setting up local development, configuring secrets, or deploying to production.

Environment variables, API key configuration, third-party service setup (Supabase, Readwise, Perplexity, Resend).

### [troubleshooting.md](./troubleshooting.md)
**When to read:** Debugging issues, fixing deployment problems, or resolving API integration errors.

Common issues and solutions for local development, deployment, and API integrations.

### [pr-review-workflow.md](./pr-review-workflow.md)
**When to read:** Starting a new feature, creating PRs, or running any kind of review.

How to use `/review-spec` (pre-implementation), `/review-pr`, and `/review-pr-team` skills.

### [safety-harness.md](./safety-harness.md)
**When to read:** A safety-harness block or ask dialog fired and you want to understand what's going on, you want to add a pattern, or you want to bypass the hook for a legitimate use.

What's caught at block / ask tier, what's deliberately not caught, how the inline `SAFETY_HARNESS_OFF=1` bypass works (and its limits), how the hook composes with the allowlist, how to extend patterns + tests.

**Vibe note**: Vibe uses declarative permissions in `.vibe/config/permissions.json` instead of hooks. The safety harness concept is implemented differently.

### [decisions/](./decisions/)
**When to read:** Making architectural decisions, choosing between alternatives, or looking up why something was built the way it was.

Architecture Decision Records (ADRs) — permanent log of significant technical choices, alternatives considered, and trade-offs accepted.

### [TEMPLATE-UPDATES/](./TEMPLATE-UPDATES/)
**When to read:** Rolling out a template improvement to a derivative project, or formalising a new improvement so future derivative projects can adopt it.

Migration packets that describe template changes in conceptual terms plus a file manifest, so a Vibe in another project can compare against local files and apply the improvement without clobbering customisations.
