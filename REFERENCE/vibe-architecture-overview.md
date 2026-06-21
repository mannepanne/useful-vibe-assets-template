# Vibe Architecture Overview

> **Purpose**: Explain Mistral Vibe's architecture, mental model, and how it organizes conversation context, tools, permissions, subagents, and skills.

---

## 🏗️ Vibe's Mental Model

### Core Philosophy

Vibe organizes work around **conversations** with **tools**, **subagents**, and **skills**. Unlike Claude's agent-centric model, Vibe treats the assistant as a conversation participant with access to a rich tool ecosystem.

```
┌─────────────────────────────────────────────────────────────┐
│                      CONVERSATION                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                     VIBE (You)                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │ │
│  │  │  TOOLS      │  │  SKILLS     │  │  SUBAGENTS       │ │ │
│  │  │  (built-in) │  │  (loaded)    │  │  (delegated)     │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘ │ │
│  │       ▲                 ▲                ▲              │ │
│  │       │                 │                │              │ │
│  └───────┼─────────────────┼────────────────┼──────────────┘ │
│          │                 │                │                │
│          ▼                 ▼                ▼                │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   PERMISSION SYSTEM                        │ │
│  │              (declarative JSON config)                     │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                       ▲      ▲      ▲
                       │      │      │
                 ┌─────┴─────┴─────┴─────┐
                 │   EXTERNAL RESOURCES       │
                 │   - Filesystem             │
                 │   - Git repos              │
                 │   - MCP Servers            │
                 │   - Connectors             │
                 └───────────────────────────┘
```

---

## 🧩 Core Components

### 1. Tools

**What**: Built-in operations that Vibe can perform.

**Categories:**

| Category | Tools | Purpose |
|----------|-------|---------|
| File Ops | `read`, `write_file`, `edit` | File manipulation |
| Search | `grep` | Pattern searching |
| Shell | `bash` | Command execution |
| Git | (via bash) | Version control |
| HTTP | `web_search`, `web_fetch` | External data access |
| delegation | `task`, `skill` | Subagent and skill invocation |
| State | `todo` | Task management |
| User | `ask_user_question` | Clarification prompts |

**Permission Model**: Each tool has a permission mode:
- `allow` - Runs without prompt
- `confirm` - Prompts user before execution
- `deny` - Blocked entirely

Configuration: `.vibe/config/permissions.json`

### 2. Subagents

**What**: Specialized agents spawned via the `task` tool for delegated work.

**Characteristics:**
- Operate within the conversation context
- Have their own tool permissions (inherit or override)
- Return results to the parent conversation
- Can run in parallel

**Built-in Profiles:**
- `explore` - Read-only research and analysis

**Custom Profiles**: Defined in `.vibe/agents/` directory

**Invocation:**
```
task(
  agent="explore",
  task="Research Vibe's architecture"
)
```

### 3. Skills

**What**: Structured, reusable workflows defined in SKILL.md files.

**Characteristics:**
- Self-contained workflows
- Can use any available tools (subject to permissions)
- Can spawn subagents via `task`
- Can be invoked by name
- Can have parameters

**Structure:**
```
.vibe/skills/
├── skill-name/
│   └── SKILL.md    # Skill definition and logic
└── AGENTS.md        # Skills library index
```

**Invocation:**
```
skill(name="review-pr", args={"prNumber": "123"})
```

### 4. Permissions System

**What**: Declarative JSON configuration that gates tool access.

**Key Concepts:**
- **Tool-level permissions**: Each tool has a mode (allow/confirm/deny)
- **Pattern matching**: Tools like `bash` can have allow/deny patterns
- **Path-level permissions**: Control access to specific file paths
- **Default mode**: Applies to tools not explicitly configured

**Configuration File**: `.vibe/config/permissions.json`

**Example:**
```json
{
  "tools": {
    "bash": {
      "mode": "confirm",
      "deny_patterns": ["rm -rf /", "git push --force"]
    }
  },
  "paths": {
    "deny": [".env.*", "*.secret"]
  }
}
```

### 5. Configuration

**What**: Project and user-level settings.

**Files:**
- `.vibe/config/project-config.json` - Project-level configuration
- `.vibe/config/permissions.json` - Tool permissions

**Project Config Example:**
```json
{
  "reviewSystem": {
    "mode": "prompt-on-first-use"
  },
  "features": {
    "mcpServers": {"enabled": false},
    "connectors": {"enabled": false}
  }
}
```

---

## 🔄 Conversation Context Flow

### How Vibe Processes a Request

```
1. USER REQUEST
   └── "Review the Phase 1 specification"

2. CONTEXT LOADING
   ├── Load auto-loaded AGENTS.md files
   ├── Load relevant project documentation
   └── Build conversation context

3. INTENT DETECTION
   ├── Parse request
   ├── Identify required tools/skills
   └── Check permissions

4. PERMISSION CHECK
   ├── Tool: read → mode: allow ✓
   └── Tool: task → mode: allow ✓

5. EXECUTION OPTIONS
   Option A: Direct tool use
   └── read(SPECIFICATIONS/01-research-and-planning.md)
   
   Option B: Subagent delegation
   └── task(agent="explore", task="Review the spec")
   
   Option C: Skill invocation
   └── skill(name="review-spec", args={...})

6. RESULT RETURN
   └── Formatted response with findings

7. CONTEXT UPDATE
   └── Add interaction to conversation history
```

### Subagent Execution Flow

```
1. PARENT AGENT
   └── task(agent="explore", task="Review spec")

2. SUBAGENT SPAWN
   ├── Load agent profile: explore
   ├── Inherit conversation context
   └── Apply tool permissions

3. SUBAGENT EXECUTION
   ├── Read spec document
   ├── Analyze against criteria
   └── Generate findings

4. RESULT RETURN
   └── Findings returned to parent agent

5. PARENT CONTINUES
   └── Integrate findings into response
```

---

## 🔗 Component Relationships

### Subagents and Skills

```
SKILLS can use SUBAGENTS
  └── skill(review-pr) → task(agent="code-reviewer")

SUBAGENTS can use SKILLS
  └── task(agent="explore") → skill(name="gather-info")

SKILLS can use TOOLS
  └── skill(review-pr) → read(), grep(), bash()

SUBAGENTS can use TOOLS
  └── task(agent="explore") → read(), grep()
```

**Key Insight**: Skills and subagents are **orthogonal** - they serve different purposes:
- **Skills**: Reusable workflows, invoked explicitly
- **Subagents**: Delegated tasks, can be spawned by skills or directly

### Permissions Hierarchy

```
CONVERSATION
└── PERMISSIONS
    ├── Global (permissions.json)
    │   ├── Tool defaults
    │   ├── Path rules
    │   └── Pattern matching
    └── Local overrides (gitignored)
```

Permissions are **not** per-subagent in the current model. Subagents inherit the parent conversation's permissions.

---

## 💡 Vibe vs Claude: Architectural Comparison

### Control Flow

```
CLAUDE CODE:
User Request → Hook (PreToolUse) → [Intercept/Modify/Block] → Tool Execution → Hook (PostToolUse) → Response
                                        ↑
                                  (bash script)

MISTRAL VIBE:
User Request → Permission Check → [Allow/Deny/Confirm] → Tool Execution → Response
                      ↑
                (JSON config)
```

### Agent Model

```
CLAUDE CODE:
┌─────────────────────────────────────────────────────┐
│                    CLAUDE AGENT                          │
│  ┌─────────────────────────────────────────────────┐ │
│  │  YAML Frontmatter: name, role, tools, model        │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Markdown: instructions, context, personality      │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
           ▲
           │ SpawnAgent()
           ▼
┌─────────────────────────────────────────────────────┐
│                   SUB-AGENT                            │
│  (separate conversation, can spawn more agents)        │
└─────────────────────────────────────────────────────┘

MISTRAL VIBE:
┌─────────────────────────────────────────────────────┐
│                 CONVERSATION + VIBE                     │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Tools: read, write, grep, bash, task, skill     │ │
│  │  Context: conversation history, loaded files      │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
           ▲
           │ task()
           ▼
┌─────────────────────────────────────────────────────┐
│                   SUBAGENT                              │
│  (shared conversation context, inherited tools)        │
└─────────────────────────────────────────────────────┘
```

### Key Architectural Differences

| Aspect | Claude Code | Mistral Vibe |
|--------|-------------|--------------|
| **Primary abstraction** | Agent (with state) | Conversation (with tools) |
| **Concurrency model** | Parallel agent conversations | Subagents in shared context |
| **Extension model** | Hooks (imperative code) | Permissions (declarative config) + Skills (structured workflows) |
| **Discovery** | Slash commands + auto-loaded files | `skill` tool discovery + auto-loaded AGENTS.md |
| **Safety** | Hooks intercept and modify | Permissions gate access |

---

## 🚀 Vibe-Unique Capabilities

### 1. MCP Servers

**Architecture:**
```
VIBE
└── MCP Client
    └── MCP Server (External)
        ├── GitHub Server → Live repo access
        ├── Documentation Server → Live docs
        └── Custom Server → Your resources
```

**Benefits:**
- Real-time external data
- No manual fetching needed
- Standardized protocol

### 2. Connectors

**Architecture:**
```
VIBE
└── Connector System
    └── Custom Connector
        └── Your external tool/API
```

**Benefits:**
- Extend tool ecosystem
- Project-specific integrations
- Reusable across projects

### 3. Local Models

**Architecture:**
```
VIBE
├── Cloud Model (default)
└── Local Model (optional)
    └── Your machine
```

**Benefits:**
- Privacy
- Offline capability
- Cost reduction

---

## 🎯 Best Practices for Vibe Development

### When to Use Each Component

| Use Case | Recommended Approach |
|----------|---------------------|
| Simple file operation | Direct tool use (`read`, `edit`) |
| Complex analysis | Subagent via `task` tool |
| Reusable workflow | Skill via `skill` tool |
| External data access | MCP server (if available) |
| Project-specific tool | Connector |
| Safety-critical operation | Confirm mode in permissions |
| Parallel investigation | Multiple `task` calls |

### Organizing Skills

```
.vibe/skills/
├── review-pr/
│   ├── SKILL.md          # Main skill logic
│   └── subskills/        # Helper skills (optional)
│       └── analyze-code/
│           └── SKILL.md
├── review-spec/
│   └── SKILL.md
└── AGENTS.md            # Library index
```

### Organizing Subagents

```
.vibe/agents/
├── code-reviewer.md     # Subagent profile
├── security-specialist.md
├── technical-writer.md
└── AGENTS.md            # Library index
```

---

## 🔗 Related Documentation

- [.vibe/AGENTS.md](../.vibe/AGENTS.md) - Collaboration principles
- [.vibe/config/permissions.json](../.vibe/config/permissions.json) - Permission configuration
- [REFERENCE/vibe-learning-notes.md](./vibe-learning-notes.md) - Practical differences and migration patterns
- [Research and Planning Spec](../SPECIFICATIONS/ARCHIVE/migration-from-claude/01-research-and-planning.md) - Historical Phase 1 specification

---

*Last updated: Phase 1 implementation*
