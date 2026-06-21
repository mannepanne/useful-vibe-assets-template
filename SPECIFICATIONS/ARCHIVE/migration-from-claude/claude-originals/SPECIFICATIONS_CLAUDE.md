# Archived Specifications

Auto-loaded when working with files in this directory. Completed implementation phases moved here for reference.

## Completed phases

- [pretooluse-safety-harness.md](./pretooluse-safety-harness.md) — PreToolUse safety-harness hook (block/ask tiers, calibrated for the less-experienced-user sub-case). How-it-works at [`REFERENCE/safety-harness.md`](../../REFERENCE/safety-harness.md).
- [INVESTIGATION-claude-code-write-path-normalisation.md](./INVESTIGATION-claude-code-write-path-normalisation.md) — Five-sighting diagnosis of why `Write(/SCRATCH/*)` allow-list entries do not silence the `Write` prompt in fresh Claude Code sessions. Closed 2026-04-26 with a `PreToolUse` hook fallback after hypothesis #3 (Write tool gates beyond the allow-list matcher) was confirmed. Decision rationale at [`REFERENCE/decisions/2026-04-26-scratch-write-pretooluse-hook.md`](../../REFERENCE/decisions/2026-04-26-scratch-write-pretooluse-hook.md); operations at [`REFERENCE/scratch-write-hook.md`](../../REFERENCE/scratch-write-hook.md).

## Link convention for archived specs

Archived specs sit one directory deeper than their original `SPECIFICATIONS/` location. Outbound relative links must use `../../` (not `../`) to reach project-root-relative paths like `REFERENCE/`, `CLAUDE.md`, etc. When moving a spec into this directory, walk every `](../...)` link and add one extra `../` segment. A markdown link checker can catch missed updates.

---

**Note:** Archived specs are historical record. For current implementation details, see `REFERENCE/` documentation.
