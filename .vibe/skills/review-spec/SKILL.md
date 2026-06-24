---
name: review-spec
description: Spec review using agent teams — requirements auditor, technical skeptic, and devil's advocate challenge a feature specification before implementation begins. Use this skill whenever a new feature spec or significant design decision needs review before writing code. Agents debate and challenge each other's findings to surface blind spots and gaps.
user-invocable: true
vibe-adaptation: Uses file-based agent spawning pattern (see agent-spawning.md). Arguments are extracted from user request rather than passed via skill tool.
---

**VIBE ADAPTATION NOTE:** This skill has been updated to work with Vibe's current tool model. Since Vibe's `skill` tool does not support argument passing and `task` tool does not auto-discover agents from .md files, this skill uses the pattern defined in [agent-spawning.md](agent-spawning.md). All custom agent spawns use `agent="explore"` with the agent's system prompt loaded from the definition file.

# Spec Review with Agent Teams

This skill reviews a feature specification before implementation begins, using three specialized reviewers who analyze the spec from different perspectives, then share and debate findings to reach a collaborative assessment.

## The Three Reviewers

- **Requirements Auditor** — completeness: edge cases, error states, undefined behaviour, missing flows
- **Technical Skeptic** — feasibility: DB implications, blast radius, hidden complexity, integration risks
- **Devil's Advocate** — strategy: is this the right solution? Simpler alternatives? Wrong assumptions?

## How This Works

**Phase 1: Independent Review** — all three reviewers analyze the spec simultaneously from their own perspective

**Phase 2: Findings Synthesis** — findings are collected, common themes identified, and a unified assessment produced

**Phase 3: Result Presentation** — comprehensive review with clear recommendations

---

## Instructions for Vibe

**When invoked** (e.g., user says "Run review-spec on SPECIFICATIONS/07-new-feature.md" or "review spec 07-new-feature"):

### Step 0: Extract Spec Path from User Request

**CRITICAL:** Extract the spec file path or name from the user's invocation message.

**Extraction rules:**
1. Look for patterns like: "SPECIFICATIONS/07-new-feature.md", "review-spec SPECIFICATIONS/07", "spec 07-new-feature", "review SPECIFICATIONS/07-new-feature.md"
2. The spec identifier is typically:
   - A full file path (e.g., "SPECIFICATIONS/07-new-feature.md")
   - A partial path (e.g., "SPECIFICATIONS/07")
   - A file name (e.g., "07-new-feature.md" or "07-new-feature")
3. If multiple potential specs appear, use the most specific one (full path > partial path > filename)
4. If no spec can be extracted, ask the user: "Which spec file should I review? Please provide a path or name."
5. Store the extracted value as `$SPEC_PATH` for use in all subsequent steps

**Default directory:** If the extracted spec doesn't start with a path, prepend `SPECIFICATIONS/` to it.

### Step 0b: Review-mode gate

Run the gate defined in [`.vibe/skills/review-gate.md`](../review-gate.md) → "Gate logic". When rendering the disabled message, substitute this skill's name: `review-spec`. If the gate tells you to stop, stop. If it tells you to proceed, continue to Step 1.

### Step 1: Locate the Spec

Resolve the spec file using `$SPEC_PATH`:
- If `$SPEC_PATH` is a full path (starts with `SPECIFICATIONS/` or `/`), use it directly
- If it's a partial name, search `SPECIFICATIONS/` for a matching file using the `glob` tool (or `grep` for filename matching)
- Filter out any path containing `/ARCHIVE/` from the results
- If ambiguous, ask the user to clarify

Confirm the spec file exists and read the first 50 lines with the `read` tool to understand its scope before proceeding.

---

### Step 2: Spawn Reviewer Team

**CRITICAL:** Spawn all three reviewers in parallel to ensure independent perspectives. Use the file-based pattern from [agent-spawning.md](agent-spawning.md).

**First, cache all system prompts** by reading the agent definition files once:

1. Read `.vibe/agents/requirements-auditor.md` and extract system prompt (after second `---`)
2. Read `.vibe/agents/technical-skeptic.md` and extract system prompt (after second `---`)
3. Read `.vibe/agents/devils-advocate.md` and extract system prompt (after second `---`)

**Then spawn all reviewers in parallel:**

1. **Requirements Auditor**:
   ```
   task: {
     "agent": "explore",
     "task": "<requirements-auditor system prompt>\n\nConduct a requirements-focused review of the spec at '$SPEC_PATH'. Follow your review checklist and output format. Focus on: completeness, edge cases, error states, undefined behavior, missing flows, user stories, acceptance criteria, and non-functional requirements. Return your findings in a structured format."
   }
   ```

2. **Technical Skeptic**:
   ```
   task: {
     "agent": "explore",
     "task": "<technical-skeptic system prompt>\n\nConduct a technical feasibility review of the spec at '$SPEC_PATH'. Follow your review checklist and output format. Focus on: technical feasibility, database implications, blast radius, hidden complexity, integration risks, performance considerations, scalability concerns, and implementation challenges. Return your findings with technical risk assessments."
   }
   ```

3. **Devil's Advocate**:
   ```
   task: {
     "agent": "explore",
     "task": "<devils-advocate system prompt>\n\nConduct a strategic challenge review of the spec at '$SPEC_PATH'. Follow your review checklist and output format. Focus on: strategic fit, whether this is the right solution, simpler alternatives, questionable assumptions, scope creep, opportunity cost, and alignment with business goals. Return your findings with strategic recommendations."
   }
   ```

Wait for all tasks to complete and collect all results.

### Step 3: Synthesize Findings

After all reviewers complete their analysis, gather their final findings and produce a unified review:

```markdown
## Spec Review: [Spec Title]

> Reviewed by: Requirements Auditor, Technical Skeptic, Devil's Advocate
> Three independent reviewers analyzed the spec, then their findings were synthesized to provide a collaborative assessment.

---

### 📋 Overall Recommendation

**[APPROVED / APPROVED WITH CONDITIONS / NEEDS REVISION]**

[2-3 sentence summary of the team's overall assessment]

---

### 🔴 Blocking Issues — Must Resolve Before Implementation

[Issues serious enough that starting implementation would likely cause significant rework or build the wrong thing]

**Format per issue:**
**Issue:** [Description]
- **Raised by:** [which reviewer(s)]
- **Why blocking:** [specific impact if ignored]
- **Resolution needed:** [what the spec needs to say to unblock this]

---

### ⚠️ Conditions — Address Before or During Implementation

[Real concerns that need mitigation but don't require spec rewrite]

**Format per condition:**
**Condition:** [Description]
- **Raised by:** [which reviewer(s)]
- **Risk if ignored:** [specific consequence]
- **Suggested approach:** [how to address it]

---

### ✅ Well-Specified Areas

[Parts of the spec the reviewers found clear, complete, and well-reasoned]

---

### 💡 Suggestions and Alternatives

[Improvements, scoping changes, or alternative approaches worth considering]

---

### 🤝 Synthesis Highlights

[Key insights from combining reviewer perspectives]
- Where reviewers had different assessments and how they were resolved
- Tradeoffs identified across perspectives
- Points where one reviewer's insight informed another's assessment

---

### 📊 Review Summary

**Requirements Auditor:** [X blocking gaps, Y incomplete areas, Z assumptions to validate]
**Technical Skeptic:** [X blocking risks, Y technical concerns, Z hidden complexity items]
**Devil's Advocate:** [X fundamental challenges, Y questionable assumptions, Z alternatives proposed]

**Consensus Status:**
- Issues with unanimous agreement: X
- Issues with 2/3 agreement: Y
- Issues with split opinions: Z

**Recommendation:** [APPROVED / APPROVED WITH CONDITIONS / NEEDS REVISION]
```

Present this synthesis directly in the conversation — do **not** post to a PR or write to a file unless the user asks.

### Step 4: Clean Up

After presenting the review, confirm with the user that they've seen the results. No cleanup is needed for subagents as they complete automatically.

---

## Example Usage

```
User: "Run review-spec on SPECIFICATIONS/08-bulk-archive.md"
User: "review spec SPECIFICATIONS/08-bulk-archive"
User: "review the interest-signals specification"
```

Expected time: 2-7 minutes depending on spec size and complexity.

---

## Recommendation Guide

**APPROVED** — Spec is complete, feasible, and solving the right problem. Proceed with implementation.

**APPROVED WITH CONDITIONS** — Spec is substantially good but has specific gaps or risks that need addressing. Implementation can begin once conditions are met (or with awareness of the risks noted).

**NEEDS REVISION** — Spec has blocking issues: incomplete requirements that would cause rework, a technical approach that won't work as described, or a strategic direction that needs reconsideration. Revise before starting implementation.

---

## Tips

- **Run before starting any non-trivial feature** — the earlier issues are caught, the cheaper they are to fix
- **APPROVED WITH CONDITIONS is the most common outcome** — specs almost always have something worth clarifying
- **Use findings to improve the spec** — after review, update the spec to address the issues before archiving it
- **Document disagreements** - Split opinions between reviewers are valuable information for the spec author

---

## Vibe-Specific Notes

**VIBE ADAPTATION:** This skill has been significantly updated to work with Vibe's current tool model:

### Key Differences from Claude Code:
1. **No Agent Teams**: Vibe does not support Claude's experimental agent teams feature with real-time discussion. Instead, we spawn independent subagents via the `task` tool using the file-based pattern and synthesize their findings.
2. **Explicit Synthesis**: Unlike Claude's agent teams that debate in real-time, Vibe's approach collects all findings and explicitly synthesizes them. This provides more control over the final output.
3. **Parallel Execution**: All reviewers are spawned in parallel, which may be faster than Claude's approach.
4. **File-based agent spawning**: Uses the pattern from [agent-spawning.md](agent-spawning.md) to load agent definitions from files.

### Preserved Functionality:
- Same three reviewer roles with identical focus areas
- Same review checklists and output expectations
- Same recommendation taxonomy (APPROVED / APPROVED WITH CONDITIONS / NEEDS REVISION)
- Same comprehensive output format
- Same quality standards

### Trade-offs:
- **Lost**: Real-time debate between reviewers, argument passing to skills
- **Gained**: Explicit control over synthesis, parallel execution, clearer result handling, works with current Vibe
- **Different**: The "discussion" happens in the synthesis step rather than between agents; spec path extracted from user request

The overall thoroughness should be equivalent, with findings from all three perspectives being properly considered and documented.

**See also:** [agent-spawning.md](agent-spawning.md) for the spawning pattern used throughout this skill.
