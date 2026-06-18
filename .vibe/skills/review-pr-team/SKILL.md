---
name: review-pr-team
description: Comprehensive PR review using agent teams - security, product, and architecture specialists who debate and challenge each other's findings. Use for critical changes requiring thorough multi-perspective analysis.
user-invocable: true
arguments:
  - name: pr-number
    description: The PR number to review
    required: true
    pattern: "^[0-9]+$"
---

# Multi-Perspective PR Review with Agent Teams

This skill provides comprehensive pull request review using **agent teams** - multiple specialized reviewers who analyze the PR from their unique perspectives, then share and debate findings.

**Note on Vibe Adaptation:** Unlike Claude Code's experimental agent teams feature, Vibe uses the `task` tool to spawn independent subagents. While these agents cannot directly discuss with each other in real-time, the orchestration below ensures they share findings through structured coordination.

## How This Works

**Phase 1: Independent Review**
- Security Specialist, Product Manager, and Senior Architect each review the PR from their unique perspective
- Each has fresh context (no bias from the main session)

**Phase 2: Findings Synthesis**
- Results from all reviewers are collected and analyzed
- Common themes and unique perspectives are identified
- A unified review is synthesized

**Phase 3: Result Presentation**
- Combined findings are posted to the PR
- All perspectives are represented with clear attribution

---

## Instructions for Vibe

When this skill is invoked with a PR number (e.g., `/review-pr-team 1`):

### Step 0: Review-mode gate

Run the gate defined in [`.vibe/skills/review-gate.md`](../review-gate.md) → "Gate logic". When rendering the disabled message, substitute this skill's name: `review-pr-team`. If the gate tells you to stop, stop. If it tells you to proceed, continue to Step 1.

*(If you were invoked by `/review-pr` auto-escalating to team tier, the dispatcher has already passed this check — the resolved flag will be `"enabled"` when you get here, and the gate is a fast no-op.)*

### Step 1: Gather Context

Read the PR details to provide context to all reviewers:
- Use `gh pr view $ARGUMENTS` to get PR title, description, and metadata
- Use `gh pr diff $ARGUMENTS` to see the actual changes
- Read the root AGENTS.md file for project context

### Step 2: Spawn Reviewer Team

**CRITICAL:** You must spawn multiple specialized reviewers to get different perspectives. In Vibe, we spawn them as independent tasks and then synthesize their findings.

Spawn all reviewers in parallel:

1. **Security Specialist**:
   ```
   task: {
     "agent": "security-specialist",
     "task": "Conduct a security-focused review of PR #$ARGUMENTS. Follow your review checklist and output format. Focus on: secrets exposure, authentication/authorization gaps, input validation, SQL injection, XSS vulnerabilities, dependency risks, and data protection. Return your findings in a structured format with clear severity ratings."
   }
   ```

2. **Product Manager**:
   ```
   task: {
     "agent": "product-reviewer",
     "task": "Conduct a product-focused review of PR #$ARGUMENTS. Follow your review checklist and output format. Focus on: user experience, feature completeness, edge cases, error handling, API design, and user-facing behavior. Return your findings with UX impact assessments."
   }
   ```

3. **Senior Architect**:
   ```
   task: {
     "agent": "architect-reviewer",
     "task": "Conduct an architecture-focused review of PR #$ARGUMENTS. Follow your review checklist and output format. Focus on: code structure, design patterns, scalability, performance implications, maintainability, and alignment with project architecture. Return your findings with architectural recommendations."
   }
   ```

4. **Technical Writer**:
   ```
   task: {
     "agent": "technical-writer",
     "task": "Conduct a documentation-focused review of PR #$ARGUMENTS. Check that REFERENCE/ docs are updated, AGENTS.md is current, new files have ABOUT comments, and no temporal language was introduced. Follow your review checklist and output format. Return your findings."
   }
   ```

Wait for all tasks to complete and collect all results.

### Step 3: Synthesize Collaborative Findings

After all reviewers complete their analysis, gather their findings and produce a unified review:

```markdown
## Comprehensive PR Review - Multi-Perspective Analysis

> This review was conducted by specialized reviewers who independently analyzed the PR from different perspectives. Findings have been synthesized to provide a comprehensive assessment.

### ✅ Completion Requirements Met?
- [ ] Tests exist and pass (95%+ coverage shown)
- [ ] Documentation updated (check REFERENCE/ if implementation work)
- [ ] Code quality verified (conventions, no secrets, clean history)

### 🔴 Critical Issues - Must Fix Before Merge

[List all blocking issues with severity and perspective]

**Format per issue:**
**Issue:** [Description] [🛡️ Security / 📦 Product / 🏗️ Architecture / ✍️ Documentation]
- **Severity:** Critical
- **Perspective:** [which reviewer(s) flagged this]
- **Why blocking:** [specific impact if ignored]
- **Recommended fix:** [clear action item]

### ⚠️ Warnings & Concerns - Should Address

[List non-blocking but important issues]

**Format per concern:**
**Concern:** [Description] [🛡️ / 📦 / 🏗️ / ✍️]
- **Raised by:** [reviewer name]
- **Risk if ignored:** [specific consequence]
- **Suggested approach:** [how to address it]

### ✅ Strengths & Good Practices

[Highlight what reviewers praised]
**Format:**
**Strength:** [Description]
- **Noted by:** [which reviewer(s)]
- **Example:** [specific instance]

### 💡 Suggestions for Improvement

[Compile suggestions from all reviewers]

### 📊 Review Summary

**Reviewer Contributions:**
- 🛡️ Security Specialist: [X critical, Y warnings, Z suggestions]
- 📦 Product Manager: [X critical, Y warnings, Z suggestions]
- 🏗️ Senior Architect: [X critical, Y warnings, Z suggestions]
- ✍️ Technical Writer: [X gaps, Y suggestions]

**Overall Recommendation:** [BLOCK MERGE / APPROVE WITH CHANGES / APPROVE]
```

### Step 4: Post the Synthesized Review

Build the body as a string, write it to `SCRATCH/review-pr-$ARGUMENTS-team.md` via the Write tool, then post with `--body-file`:

```bash
gh pr comment $ARGUMENTS --body-file SCRATCH/review-pr-$ARGUMENTS-team.md
```

**Read-then-Write fallback (avoid `rm -f`).** If the Write tool errors with *"File has not been read yet"*, call **Read on the path first** to satisfy the Write prerequisite, then re-issue the Write. Do **not** use `Bash(rm -f SCRATCH/…)`.

### Step 5: User Summary and Follow-Through

After posting, give a one-line status: recommendation (block / approve with changes / approve) and link to the PR comment. Note the distribution of findings across reviewers.

Then run the follow-through protocol in [post-review-follow-through.md](../post-review-follow-through.md) — re-bucket findings by action tier, surface decisions, and create GitHub issues for anything genuinely out of scope.

If the review returned no findings, emit: "✅ Clean — nothing to follow up on."

---

## Example Usage

```
/review-pr-team 1
```

This will:
1. Spawn 4 specialized reviewers in parallel
2. Each reviewer gathers their own context and conducts independent analysis
3. Synthesize all findings into a unified review
4. Post comprehensive review to PR #1
5. Provide user summary and run follow-through protocol

Expected time: 2-7 minutes (depending on PR size)

---

## Tips for Best Results

- **Use for non-trivial PRs** - The multi-perspective analysis adds value for complex changes
- **Review the synthesis** - Ensure all reviewer voices are represented in the final output
- **Document disagreements** - If reviewers have conflicting assessments, document both positions clearly
- **Trust the process** - Multiple perspectives often surface issues individual reviewers miss

---

## When to Use Which Review

**Use `/review-pr`:**
- Quick sanity checks
- Small, straightforward changes
- Non-critical bug fixes
- Documentation updates
- You want fast feedback (1-2 minutes)

**Use `/review-pr-team`:**
- Critical infrastructure changes
- Security-sensitive features
- Major architectural decisions
- Complex multi-file changes
- When multiple perspectives add real value
- You want thorough multi-perspective analysis (2-7 minutes)

---

## Vibe-Specific Notes

This skill has been **significantly adapted** from Claude Code's version:

### Key Differences:
1. **No Agent Teams**: Vibe does not have Claude's experimental agent teams feature. Instead, we spawn independent subagents via the `task` tool and synthesize their findings.
2. **No Real-Time Discussion**: Unlike Claude's agent teams that can broadcast and message each other, Vibe's subagents work independently. The synthesis step replicates the collaborative analysis.
3. **Parallel Execution**: Vibe's `task` tool can spawn multiple agents in parallel, which is actually an improvement over sequential execution.

### Preserved Functionality:
- Same reviewer roles (Security, Product, Architecture, Documentation)
- Same review checklists and focus areas
- Same output format and structure
- Same follow-through protocol
- Same quality standards

### Trade-offs:
- **Lost**: Real-time debate and consensus-building between agents
- **Gained**: Parallel execution, explicit synthesis control, clearer result handling
- **Different**: Discussion happens in the synthesis step rather than between agents

The overall quality and thoroughness of the review should be equivalent, with the trade-off being less dynamic interaction between reviewers but more explicit control over the final output.
