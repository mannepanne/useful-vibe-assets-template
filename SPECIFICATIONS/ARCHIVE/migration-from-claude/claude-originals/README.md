# Claude Originals Archive

> **Purpose:** Preserve original Claude CLAUDE.md files for backward compatibility and reference during the Vibe migration.

## Overview

This directory contains **original, unmodified** CLAUDE.md files from before the migration to Mistral Vibe. These files are preserved for:

1. **Backward compatibility** - Projects still using the Claude Code version can reference these
2. **Reference** - Compare original Claude implementation with Vibe equivalents
3. **Rollback capability** - If needed, these can be used to restore the original state
4. **Historical record** - Document the pre-migration state

## Archive Structure

```
SPECIFICATIONS/ARCHIVE/claude-originals/
├── README.md                          # This file
├── SPECIFICATIONS_CLAUDE.md          # Original SPECIFICATIONS/CLAUDE.md
├── .claude/
│   ├── CLAUDE.md                     # Original .claude/CLAUDE.md
│   ├── agents/
│   │   └── CLAUDE.md                 # Original .claude/agents/CLAUDE.md
│   └── COLLABORATION/
│       └── CLAUDE.md                 # Original .claude/COLLABORATION/CLAUDE.md
└── REFERENCE/
    ├── TEMPLATE-UPDATES/
    │   └── CLAUDE.md                 # Original REFERENCE/TEMPLATE-UPDATES/CLAUDE.md
    └── decisions/
        └── CLAUDE.md                 # Original REFERENCE/decisions/CLAUDE.md
```

## Migration Status

| Original File | Migration Status | Vibe Equivalent |
|---------------|------------------|----------------|
| `.claude/CLAUDE.md` | ✅ Archived | `.vibe/AGENTS.md` |
| `.claude/agents/CLAUDE.md` | ✅ Archived | `.vibe/agents/AGENTS.md` |
| `.claude/COLLABORATION/CLAUDE.md` | ✅ Archived | `.vibe/COLLABORATION/AGENTS.md` |
| `REFERENCE/decisions/CLAUDE.md` | ✅ Archived | `REFERENCE/decisions/AGENTS.md` |
| `REFERENCE/TEMPLATE-UPDATES/CLAUDE.md` | ✅ Archived | `REFERENCE/TEMPLATE-UPDATES/AGENTS.md` |
| `SPECIFICATIONS/CLAUDE.md` | ✅ Archived | `SPECIFICATIONS/AGENTS.md` |

## Notes

- These files are **read-only** and should not be modified
- All references to these files in the active codebase should use the AGENTS.md equivalents
- The .claude/ directory is preserved in the main codebase for backward compatibility
- For the current Vibe-optimized template, use the corresponding AGENTS.md files

## Usage

To reference the original Claude implementation for comparison:

```bash
# View original .claude/CLAUDE.md
cat SPECIFICATIONS/ARCHIVE/claude-originals/.claude/CLAUDE.md

# Compare with current Vibe version
diff SPECIFICATIONS/ARCHIVE/claude-originals/.claude/CLAUDE.md .vibe/AGENTS.md
```

## Archive Created

**Date:** 2026-06-20  
**Phase:** Phase 7 (Validation and Completion)  
**Purpose:** Complete migration validation and cleanup