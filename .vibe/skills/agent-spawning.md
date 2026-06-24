# Agent Spawning Pattern for Vibe

**Purpose:** This file defines the pattern for spawning subagents in Vibe when agent auto-discovery from `.md` files is not available. All skills that spawn custom subagents should follow this pattern.

**Why this is needed:** Vibe's `task` tool does not automatically discover and register subagent definitions from `.vibe/agents/*.md` files. This pattern provides a workaround that works with Vibe's current capabilities.

---

## Pattern Overview

Instead of using `task(agent="custom-agent-name", task="...")`, which fails with "Unknown agent", use:

1. **Read** the agent definition file (e.g., `.vibe/agents/triage-reviewer.md`)
2. **Extract** the system prompt (content after the YAML frontmatter)
3. **Spawn** an `explore` subagent with the system prompt + task combined

---

## Step-by-Step Pattern

### Step 1: Load the Agent Definition

Use the `read` tool to read the agent definition file:

```
Read the file `.vibe/agents/<agent-name>.md`
```

### Step 2: Extract the System Prompt

The agent definition file has YAML frontmatter followed by the system prompt:

```markdown
---
name: triage-reviewer
description: Lightweight PR risk classifier
tools: [Bash, Read, Grep]
model: default
---

# Triage Reviewer Subagent

You are a triage reviewer...
```

**Extract everything AFTER the first `---` delimiter that ends the frontmatter.**

The pattern is:
1. Find the first occurrence of `---` (line 1)
2. Find the second occurrence of `---` (ends the frontmatter, typically around line 5-6)
3. The system prompt is everything from line AFTER the second `---` to the end of the file

### Step 3: Spawn with the explore Agent

Use the `task` tool with `agent="explore"` and include the system prompt as part of the task:

```
task: {
  "agent": "explore",
  "task": "[SYSTEM PROMPT FROM AGENT FILE]\n\n[YOUR ACTUAL TASK HERE]"
}
```

---

## Concrete Examples

### Example 1: Spawning triage-reviewer for PR #42

```
1. Read `.vibe/agents/triage-reviewer.md`
2. Extract the system prompt (after the second ---)
3. Spawn:
   task: {
     "agent": "explore",
     "task": "<extracted system prompt>\n\nClassify PR #42 for review tier. Follow your rubric and output format exactly. Return only the classification block."
   }
```

### Example 2: Spawning light-reviewer for PR #42

```
1. Read `.vibe/agents/light-reviewer.md`
2. Extract the system prompt (after the second ---)
3. Spawn:
   task: {
     "agent": "explore",
     "task": "<extracted system prompt>\n\nLight-tier review of PR #42. Follow your agent definition. Post nothing — return your findings."
   }
```

---

## Helper Function Concept

While Vibe doesn't support true functions, you can use this reusable pattern in your skill instructions:

```
To spawn agent '<agent-name>' with task '<user-task>':
1. Read the file at `.vibe/agents/<agent-name>.md`
2. Find the line number of the second occurrence of '---' (this marks the end of frontmatter)
3. Extract all content from the line AFTER that second '---' to the end
4. Combine: system_prompt + "\n\n" + user_task
5. Spawn: task(agent="explore", task=combined_text)
```

---

## Agent File Format

All agent files in `.vibe/agents/` follow this format:

```markdown
---
name: agent-name
description: What this agent does
tools: [Bash, Read, Grep, ...]
model: default
---

# Agent Title

## Role

You are a [role description]...

## Protocol

1. Step one...
2. Step two...
```

The **system prompt** is everything after the second `---` (including the `# Agent Title` line).

---

## Extracting the Frontmatter End

To programmatically find where the frontmatter ends:

1. Read the file with `read` tool
2. Find the first line that is exactly `---` (line 1)
3. Find the NEXT line that is exactly `---` (this ends the frontmatter)
4. The system prompt starts on the line immediately after this second `---`

**Example:** If the second `---` is on line 6, the system prompt starts on line 7.

---

## Important Notes

1. **Tool permissions**: The spawned `explore` agent will have its own tool permissions. The `tools:` array in the agent definition file is currently informational only (not enforced by Vibe).

2. **Agent identity**: Using `explore` as the agent name means logs won't show the custom agent name, but the functionality is preserved.

3. **Performance**: Reading the agent file for each spawn adds a small overhead, but ensures the latest agent definition is always used.

4. **Cache the extraction**: If spawning the same agent multiple times in one skill, read the file once, extract the prompt once, then reuse it for all spawns.

---

## Migration Note

This pattern is a workaround for Vibe's current limitations. When Vibe adds native support for:
- Custom agent registration from `.md` files
- Argument passing to skills

This pattern can be replaced with the direct approach:
```
task(agent="triage-reviewer", task="Classify PR #42...")
```

---

## See Also

- [.vibe/agents/AGENTS.md](../agents/AGENTS.md) - Subagent definitions
- [.vibe/skills/AGENTS.md](AGENTS.md) - Skills library index
