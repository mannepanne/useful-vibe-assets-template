# Vibe Learning Notes

> **Purpose**: Capture **actual learnings and practical findings** from migrating from Claude Code to Mistral Vibe. Focus on what we discovered through implementation, not theoretical descriptions.

---

## 🎯 Executive Summary

**Biggest Paradigm Shift**: Claude uses an **imperative hook system** (bash scripts that intercept and modify behavior) while Vibe uses a **declarative permission model** (JSON configuration that gates tools). This is not just a syntax change — it's a fundamental architectural difference.

**Bottom line**: We're trading flexibility (Claude's hooks can do anything) for simplicity and transparency (Vibe's permissions are visible JSON).

---

## 🔍 Conceptual Differences (Practical Impact)

### The Core Mental Model Shift

| What Changed | Claude | Vibe | What This Means |
|--------------|--------|------|-----------------|
| Agent spawning | `SpawnAgent("name")` in skill | `task(agent="name", task="...")` | Different syntax, same capability |
| Skills | Slash commands `/cmd` | `skill(name="cmd")` | Invocation syntax changed |
| Safety | Hooks (external scripts) | Permissions (internal config) | Trust model different |
| Configuration | Multiple files + hooks | Unified JSON config | Simpler to maintain |

---

## ⚠️ The Catch-22 Problem

**This is the most significant architectural challenge we've identified.**

### The Problem

In Claude, the `SessionStart` hook fires automatically when a user starts a session. This allows the template to:
1. Check if `prReviewMode` is set to `prompt-on-first-use`
2. Detect "review-adjacent moments" (user mentions PRs, finishing features, etc.)
3. Proactively prompt the user to set up the review system
4. Persist the answer to `project-config.json`

In Vibe:
1. No `SessionStart` hook exists
2. Skills only run when explicitly invoked
3. Users who don't know about review skills never invoke them
4. Users never get prompted, never discover the feature
5. **Catch-22: Users don't know → never invoke → never prompted → never know**

### Current Thinking on Solutions

#### Option A: Documentation-First (Simplest)
- Strong AGENTS.md instructions that Vibe surfaces
- Users read docs, learn about skills, invoke them
- **Pros**: Simple, no new infrastructure
- **Cons**: Relies on users reading docs (they won't)

#### Option B: First-Use Detection in Skills
- Review skills check for config on first invocation
- Prompt user, persist answer
- **Pros**: Works once user invokes skill
- **Cons**: Still requires user to know about and invoke skill at least once

#### Option C: MCP GitHub Integration
- MCP server monitors GitHub events
- Detects PR creation, proactively prompts
- **Pros**: True proactive behavior
- **Cons**: Heavy infrastructure, complex setup

#### Option D: Tool Permission Prompts
- Configure bash tool to require confirmation
- Include review system info in confirmation message
- **Pros**: Catches users when they do git operations
- **Cons**: Only works for git operations, not general "review moments"

**Current Recommendation**: Option B (First-Use Detection) + Option D (Tool Permission Prompts) as a pragmatic combination. Revisit for Option C when MCP servers are more mature.

---

## 🛠️ Practical Differences

### Spawning a Subagent

**Claude:**
```yaml
---
name: code-reviewer
role: Code Review Specialist
---

# Then in a skill:
SpawnAgent("code-reviewer", "Review this PR")
```

**Vibe:**
```
task(
  agent="explore",  // Built-in agent profile
  task="Review this PR"
)
```

**Key Differences:**
- Claude: Agents defined as markdown files with YAML frontmatter
- Vibe: Subagents invoked via `task` tool with profile names
- Claude: Can spawn arbitrary agents by filename
- Vibe: Uses predefined agent profiles (built-in: `explore`)

### Invoking a Skill

**Claude:**
```
/review-pr 123
```

**Vibe:**
```
skill(name="review-pr", args={"pr": "123"})
```

**Key Differences:**
- Claude: Slash command syntax, discovered via autocomplete
- Vibe: Function call syntax via `skill` tool
- Both: Can pass arguments, spawn subagents

### Configuration

**Claude:**
```
.claude/
├── settings.json          # Tool allowlist
├── project-config.json   # Project flags (prReviewMode)
└── project-config.local.json  # Local overrides (gitignored)
```

**Vibe:**
```
.vibe/config/
├── permissions.json      # Tool permissions (replaces settings.json + hooks)
└── project-config.json   # Project settings (includes reviewSystem.mode)
```

**Key Differences:**
- Claude: Separate allowlist and hook registration
- Vibe: Unified permission configuration
- Both: Support local overrides (gitignored)

---

## 🔐 Permission System: Trust Model (Key Learning)

**Question**: What stops Vibe from bypassing permissions?

**Answer**: Nothing technical — it's a **trust-based architecture**.

### How It Works

```
User Request → Vibe Checks permissions.json → [Allow/Deny/Confirm] → Execute
```

The permission check is **built into Vibe's tool invocation layer**. When I prepare to use a tool:
1. I look up the tool's permission mode
2. If `deny` → I refuse
3. If `confirm` → I prompt you
4. If `allow` → I execute

### vs Claude's Hooks

| Aspect | Claude | Vibe |
|--------|--------|------|
| **Mechanism** | External bash scripts | Internal JSON config |
| **Bypassability** | Cannot bypass (separate process) | Could bypass, but won't (trust model) |
| **Flexibility** | Arbitrary logic possible | Limited to declarative patterns |
| **Auditability** | Read hook scripts | Read permissions.json |

### Is It Deterministic?

**Yes** — the permission check always runs. Vibe is designed to follow its own rules consistently.

**But**: Unlike Claude's external hooks (which Vibe literally cannot bypass), Vibe's permission system relies on Vibe choosing to follow it. This is similar to:
- A user with sudo who doesn't `rm -rf /`
- A type system that you choose not to circumvent with `any`

**The safety comes from**:
1. Permissions are part of Vibe's core operational constraints
2. The config is transparent and auditable
3. Vibe is programmed to be a trustworthy assistant

**Bottom line**: It's a simpler, more transparent model. You can see exactly what I can and cannot do by reading `permissions.json`.

---

## 📚 Migration Patterns

### What Translates Directly

| Claude | Vibe | Notes |
|--------|------|-------|
| File structure | File structure | Keep SPECIFICATIONS/, REFERENCE/, SCRATCH/ |
| Documentation philosophy | Documentation philosophy | Lifecycle-based docs, token efficiency |
| Tests as guardrails | Tests as guardrails | Same principle |
| Phase-based development | Phase-based development | Same workflow |

### What Needs Adaptation

| Claude | Vibe | Adaptation |
|--------|------|------------|
| CLAUDE.md files | AGENTS.md files | Rename, update references |
| `.claude/` directory | `.vibe/` directory | Rename, restructure |
| Agent YAML frontmatter | Subagent profiles | Format conversion |
| Slash command skills | SKILL.md + `skill` tool | Syntax conversion |
| Hook scripts | permissions.json | Paradigm shift |

### What Needs Rethinking

| Claude Feature | Issue | Vibe Solution |
|----------------|-------|---------------|
| SessionStart hooks | No equivalent | First-use detection in skills |
| PreToolUse hooks | No equivalent | permissions.json patterns |
| Proactive prompting | Catch-22 problem | Documentation + first-use detection |

---

## 🎓 Lessons Learned So Far

### From Phase 1 Subagent Review

The subagent we spawned to review Phase 1 spec demonstrated:

1. **Subagents are powerful**: It performed a comprehensive review with structured output
2. **Context is shared**: It had access to the full conversation and file context
3. **Results are integrated**: The output came back as a complete, formatted response
4. **Limitation**: The built-in `explore` agent is read-only (no write capabilities)

### From Directory Structure Creation

Creating the `.vibe/` structure revealed:

1. **Vibe's permission system is flexible**: We can express complex rules in JSON
2. **The declarative model is simpler**: No need to maintain hook scripts
3. **Pattern matching works**: We can block dangerous commands with regex patterns

---

## 📝 Open Questions

Questions we haven't yet answered (from Phase 1 spec, lines 250-254):

1. **MCP Server Configurations**: Should we add MCP server configurations in the template?
   - *Current thinking*: Yes, but as optional examples users can enable
   
2. **Connector Definitions**: Should we define project-specific connectors?
   - *Current thinking*: Document the pattern, but don't include specific connectors in the template
   
3. **Profile Setup Flow**: How should we handle the profile setup flow in Vibe?
   - *Current thinking*: Embed in AGENTS.md as explicit setup instructions
   
4. **Dual Support**: Should we maintain dual Claude/Vibe support?
   - *Current thinking*: No — out of scope per project-outline.md

---

## 🔗 Related Documentation

- [REFERENCE/vibe-architecture-overview.md](./vibe-architecture-overview.md) - Vibe's architecture, mental model, MCP servers, connectors (see there for Vibe-unique features)
- [Phase 1: Research and Foundation](../SPECIFICATIONS/01-research-and-planning.md) - The spec that generated these notes
- [.vibe/AGENTS.md](../.vibe/AGENTS.md) - Vibe collaboration principles
- [.vibe/config/permissions.json](../.vibe/config/permissions.json) - Example permission configuration
- [.claude/hooks/safety-harness.sh](../.claude/hooks/safety-harness.sh) - Original safety harness (archive)
- [.claude/settings.json](../.claude/settings.json) - Original Claude settings (archive)

---

*Last updated: Phase 1 implementation*
