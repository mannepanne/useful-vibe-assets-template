---
name: review-spec
description: Spec review using agent teams — requirements auditor, technical skeptic, and devil's advocate challenge a feature specification before implementation begins. Use this skill whenever a new feature spec or significant design decision needs review before writing code. Agents debate and challenge each other's findings to surface blind spots and gaps.
user-invocable: true
arguments:
  - name: spec-file-path-or-name
    description: The spec file path or name to review
    required: true
---

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

When this skill is invoked with a spec file path or name (e.g., `/review-spec SPECIFICATIONS/07-new-feature.md`):

### Step 0: Review-mode gate

Run the gate defined in [`.vibe/skills/review-gate.md`](../review-gate.md) → "Gate logic". When rendering the disabled message, substitute this skill's name: `review-spec`. If the gate tells you to stop, stop. If it tells you to proceed, continue to Step 1.

### Step 1: Locate the Spec

Resolve the spec file:
- If `$ARGUMENTS` is a full path, use it directly
- If it's a partial name, search `SPECIFICATIONS/` for a matching file using the `glob` tool (or `grep` for filename matching)
- Filter out any path containing `/ARCHIVE/` from the results
- If ambiguous, ask the user to clarify

Confirm the spec file exists and read the first 50 lines with the `read` tool to understand its scope before proceeding.

---

### Step 2: Spawn Reviewer Team

**CRITICAL:** Spawn all three reviewers in parallel to ensure independent perspectives.

1. **Requirements Auditor**:
   ```
   task: {
     "agent": "requirements-auditor",
     "task": "Conduct a requirements-focused review of the spec at '$ARGUMENTS'. Follow your review checklist and output format. Focus on: completeness, edge cases, error states, undefined behavior, missing flows, user stories, acceptance criteria, and non-functional requirements. Return your findings in a structured format."
   }
   ```

2. **Technical Skeptic**:
   ```
   task: {
     "agent": "technical-skeptic",
     "task": "Conduct a technical feasibility review of the spec at '$ARGUMENTS'. Follow your review checklist and output format. Focus on: technical feasibility, database implications, blast radius, hidden complexity, integration risks, performance considerations, scalability concerns, and implementation challenges. Return your findings with technical risk assessments."
   }
   ```

3. **Devil's Advocate**:
   ```
   task: {
     "agent": "devils-advocate",
     "task": "Conduct a strategic challenge review of the spec at '$ARGUMENTS'. Follow your review checklist and output format. Focus on: strategic fit, whether this is the right solution, simpler alternatives, questionable assumptions, scope creep, opportunity cost, and alignment with business goals. Return your findings with strategic recommendations."
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
/review-spec SPECIFICATIONS/08-bulk-archive.md
/review-spec 08-bulk-archive
/review-spec interest-signals
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

This skill has been **adapted** from Claude Code's version:

### Key Differences:
1. **No Agent Teams**: Vibe does not support Claude's experimental agent teams feature with real-time discussion. Instead, we spawn independent subagents via the `task` tool and synthesize their findings.
2. **Explicit Synthesis**: Unlike Claude's agent teams that debate in real-time, Vibe's approach collects all findings and explicitly synthesizes them. This provides more control over the final output.
3. **Parallel Execution**: All reviewers are spawned in parallel, which may be faster than Claude's approach.

### Preserved Functionality:
- Same three reviewer roles with identical focus areas
- Same review checklists and output expectations
- Same recommendation taxonomy (APPROVED / APPROVED WITH CONDITIONS / NEEDS REVISION)
- Same comprehensive output format
- Same quality standards

### Trade-offs:
- **Lost**: Real-time debate between reviewers
- **Gained**: Explicit control over synthesis, parallel execution, clearer result handling
- **Different**: The "discussion" happens in the synthesis step rather than between agents

The overall thoroughness should be equivalent, with findings from all three perspectives being properly considered and documented.
