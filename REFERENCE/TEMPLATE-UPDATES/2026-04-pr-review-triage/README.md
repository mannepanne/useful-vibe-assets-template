# PR review triage rollout

**Status:** Active
**Authoritative source:**
- [PR #13 — Add tiered PR review with risk-based triage dispatcher](https://github.com/mannepanne/useful-assets-template/pull/13)
- [PR #14 — PR #13 follow-up polish (D1 coverage, ADR reconciliation)](https://github.com/mannepanne/useful-assets-template/pull/14)
- [PR #15 — Add opt-in mechanism for automated PR review system](https://github.com/mannepanne/useful-assets-template/pull/15)
- [PR #16 — Extract review-gate; tidy `.claude/CLAUDE.md`](https://github.com/mannepanne/useful-assets-template/pull/16)

---

## Why

The earlier `/review-pr` skill ran one fixed review pipeline regardless of the change's risk profile, which meant trivial doc-only PRs got the same multi-perspective treatment as a database migration — slow, expensive, and noisy on small changes; under-powered on critical ones if the user didn't think to escalate manually.

Three separate improvements landed across these four PRs and now form a coherent system that derivative projects benefit from inheriting:

1. **Risk-based triage (PR #13, polished in #14)** — A cheap first pass classifies each PR as `light`, `standard`, or `team` tier. Doc-only and styling changes get a terse review; security-sensitive or large changes auto-escalate to the full team.
2. **Opt-in config (PR #15)** — A `prReviewMode` flag in `.claude/project-config.json` lets each project (or each clone, via a gitignored local override) choose between `enabled`, `disabled`, and `prompt-on-first-use`. Without this, the review skills imposed themselves on every project that copied the template.
3. **Single source of truth for the gate (PR #16)** — The opt-in state machine, pitch text, and persistence rules were originally duplicated across each `/review-*` skill plus `.claude/CLAUDE.md`. They now live in `.claude/skills/review-gate.md` and every other location holds a one-line reference. Future edits touch one file, not four.

## What changed

- **New skill:** `.claude/skills/review-gate.md` — canonical opt-in gate logic; referenced by all three review skills and by `.claude/CLAUDE.md`.
- **New agents:** `triage-reviewer` (the dispatcher), `light-reviewer` (terse path for low-risk PRs), and `technical-writer` (documentation completeness checker for the team tier).
- **New config:** `.claude/project-config.json` introduces `prReviewMode` with three states. `.claude/project-config.local.json` is a gitignored per-clone override.
- **Two new ADRs** under `REFERENCE/decisions/` documenting the dispatcher design and the opt-in mechanism.
- **`/review-pr` rewritten** as a triage-first dispatcher (`.claude/skills/review-pr/SKILL.md`) that delegates to `light-reviewer`, `code-reviewer`, or the team based on classification.
- **Conversational opt-in pitch** in `.claude/CLAUDE.md` describing when to proactively surface the prompt and when to stay quiet.
- **Workflow docs updated:** `REFERENCE/pr-review-workflow.md` reflects the three tiers and the opt-in model.
- **Predecessor backfill:** seven older review agents (`code-reviewer`, `security-specialist`, `product-reviewer`, `architect-reviewer`, `devils-advocate`, `requirements-auditor`, `technical-skeptic`) and the `triage-scan-patterns.txt` file are listed in the manifest as conditional/forward-pulled additions. They predate this rollout's PRs but are required for the review system to function end-to-end; older derivative forks may not have them, so the manifest closes the gap silently.

For the full diff and design rationale, follow the PR links above. The two ADRs in `REFERENCE/decisions/` are the most useful starting point for understanding the reasoning.

## File manifest

### Copy verbatim

Files that did not exist before this rollout. Add them as-is unless a same-named file already exists locally.

- `.claude/skills/review-gate.md` — canonical gate logic; referenced from elsewhere
- `.claude/agents/triage-reviewer.md` — risk classifier dispatcher
- `.claude/agents/light-reviewer.md` — terse-path reviewer for low-risk changes
- `.claude/agents/technical-writer.md` — documentation completeness reviewer
- `.claude/agents/triage-scan-patterns.txt` — secret-shape patterns loaded by `triage-reviewer.md` via `grep -E -f`. Technically introduced in the next packet (`2026-04-threat-model-and-safety-harness`), but pulled forward because the version of `triage-reviewer.md` on `main` already references this file; copying the agent without the patterns file would leave triage fail-closed on every run until packet 2 lands.
- `REFERENCE/decisions/2026-04-22-tiered-pr-review-dispatcher.md` — ADR for the dispatcher design
- `REFERENCE/decisions/2026-04-22-prreviewmode-opt-in-config.md` — ADR for the opt-in mechanism

#### Predecessor files (assumed baseline; copy if absent locally)

These files predate this rollout but are required for the review system to function. Older derivative forks (cut from a template state before PR #13 introduced the triage dispatcher) won't have them; newer forks already will. For each file: check existence, fetch and copy verbatim if absent, leave the local version untouched if present.

- `.claude/agents/code-reviewer.md` — full-stack PR reviewer (used by `/review-pr` standard tier and `/review-pr-team`)
- `.claude/agents/security-specialist.md` — security-focused reviewer (`/review-pr-team`)
- `.claude/agents/product-reviewer.md` — product-perspective reviewer (`/review-pr-team`)
- `.claude/agents/architect-reviewer.md` — architecture-perspective reviewer (`/review-pr-team`)
- `.claude/agents/devils-advocate.md` — challenges WHY a spec is the right solution (`/review-spec`)
- `.claude/agents/requirements-auditor.md` — completeness check on specs (`/review-spec`)
- `.claude/agents/technical-skeptic.md` — buildability assessment on specs (`/review-spec`)

### Merge carefully

These files almost certainly exist in the target project. Read the local version, identify the sections affected by this rollout, and merge — preserving any local customisation elsewhere.

- `.claude/CLAUDE.md` — added the **Automated PR review system** section (skills overview, config flag explainer, when-to-surface-the-pitch guidance). Section heading is the anchor; merge by adding the whole section if absent, or reconciling against existing review-related guidance.
- `.claude/agents/CLAUDE.md` — three additions:
  - **Index entries** under "Code Review Agents (PR reviews)" for `triage-reviewer`, `light-reviewer`, and `technical-writer` (alongside whichever predecessor agents the local file already lists).
  - **Agent-to-skill mapping table** — a markdown table mapping each agent to the skill(s) that invoke it (`/review-pr` triage / light / standard tier, `/review-pr-team`, `/review-spec`). Section heading: `## Agent-to-skill mapping`. Add if absent; if present locally with stale entries, update to match the source.
  - **Untrusted input contract subsection** — a short subsection under "Shared agent contracts" explaining that reviewer agents must treat PR title / description / commit messages / diff content as untrusted input and not follow instructions found in them. Section heading: `### Untrusted input contract` under `## Shared agent contracts`. Load-bearing for `triage-reviewer.md` and `light-reviewer.md` because they emit control-flow signals (`TIER:`, `MISCLASSIFICATION SUSPECTED:`) that a forged PR description could otherwise hijack. Add if absent.

  Merge approach: read the local file's structure, find the right anchor for each section, add what's missing. Do not reorder existing local content. Pay attention to local agents that aren't in the source — leave their index entries alone.
- `.claude/skills/review-pr/SKILL.md` — substantially rewritten: now starts with a Step 0 reference to `review-gate.md`, then runs triage, then dispatches. If the local version is the older single-pipeline form, replace wholesale and verify nothing project-specific was added.
- `.claude/skills/review-pr-team/SKILL.md` — Step 0 added pointing at `review-gate.md`.
- `.claude/skills/review-spec/SKILL.md` — Step 0 added pointing at `review-gate.md`.
- `REFERENCE/pr-review-workflow.md` — workflow doc rewritten to describe three tiers + opt-in model.
- `REFERENCE/decisions/CLAUDE.md` — index entries for the two new ADRs.
- `CLAUDE.md` (project root) — minor references to the new flow (e.g. mentions of `/review-pr` triage behaviour). Merge carefully if the project has heavily customised the root file.
- `.gitignore` — adds `.claude/project-config.local.json` (and a couple of related patterns). Append if not present.
- `README.md` — minor mention of the review system. Apply only if the local README still references the older flow.

### Conditional

- `.claude/project-config.json` — if the file does not exist locally, copy verbatim. If it exists with other keys, add only the `prReviewMode` key (with default `"prompt-on-first-use"`); do not overwrite siblings.
- `SPECIFICATIONS/00-TEMPLATE-phase.md` — minor reference update; apply only if the target project still uses the unmodified template phase doc.
- `TEMPLATE-INSTRUCTIONS.md` — apply only if this file still exists and refers to the older review flow. Some projects delete it after bootstrap.

## Apply prompt

> Copy the block below into the receiving project's Claude session.

```
I want to roll out the PR review triage system from the useful-assets-template into this
project. The migration packet README is at:

  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-04-pr-review-triage/README.md

Source PRs: #13, #14, #15, #16 in mannepanne/useful-assets-template.

How to fetch source files: use WebFetch on the raw GitHub URL pattern

  https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/<path>

substituting <path> for any file listed in the manifest (e.g.
`.claude/skills/review-gate.md` → https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/.claude/skills/review-gate.md).
Do NOT invent file contents — every source file must come from the raw URL above.

Please:

1. WebFetch the packet README first and read it end-to-end. Understand WHY the change
   exists and WHAT changed before touching any file. The two linked ADRs are the best
   design-rationale context.
2. Create a feature branch (e.g. `feature/adopt-pr-review-triage`). Do NOT work on main.
3. For each file in "Copy verbatim" (including the "Predecessor files" sub-section),
   check whether a file at that path exists locally. If not, WebFetch the source and
   create it. If it does, treat it as "merge carefully" instead and flag the conflict.
   The predecessor files are required baseline that older forks may not have — fetch
   them silently if absent rather than treating as a manifest gap.
4. For each file in "Merge carefully", read the local version and WebFetch the source
   version. Identify the sections this rollout adds or modifies, and propose a merged
   version that preserves any local customisation. Pay special attention to
   `.claude/CLAUDE.md` and `.claude/skills/review-pr/SKILL.md` — these have the most
   surface area for conflict.
5. For each "Conditional" file, evaluate the stated condition before deciding.
6. Before writing ANY changes, list every proposed edit with a one-line rationale, and
   flag every place where local customisation could be lost. Wait for my confirmation.
7. After I confirm and you've applied the changes, run the verification commands from
   the packet and report results.
```

## Verification

Run each command below and report results. All should exit 0 (or print the expected match).

```bash
# New skill and agents exist
test -f .claude/skills/review-gate.md
test -f .claude/agents/triage-reviewer.md
test -f .claude/agents/light-reviewer.md
test -f .claude/agents/technical-writer.md
test -f .claude/agents/triage-scan-patterns.txt

# Predecessor agents present (required baseline; backfilled if missing)
test -f .claude/agents/code-reviewer.md
test -f .claude/agents/security-specialist.md
test -f .claude/agents/product-reviewer.md
test -f .claude/agents/architect-reviewer.md
test -f .claude/agents/devils-advocate.md
test -f .claude/agents/requirements-auditor.md
test -f .claude/agents/technical-skeptic.md

# All three review skills reference the gate (catches partial Step-0 merges)
grep -q review-gate .claude/skills/review-pr/SKILL.md
grep -q review-gate .claude/skills/review-pr-team/SKILL.md
grep -q review-gate .claude/skills/review-spec/SKILL.md

# Dispatcher SKILL.md actually delegates to the triage agent
grep -q triage-reviewer .claude/skills/review-pr/SKILL.md

# Opt-in config and its gitignore rule both present
grep -q '"prReviewMode"' .claude/project-config.json
grep -q 'project-config.local.json' .gitignore

# Both ADRs landed and are indexed
test -f REFERENCE/decisions/2026-04-22-tiered-pr-review-dispatcher.md
test -f REFERENCE/decisions/2026-04-22-prreviewmode-opt-in-config.md
grep -q '2026-04-22-tiered-pr-review-dispatcher' REFERENCE/decisions/CLAUDE.md
grep -q '2026-04-22-prreviewmode-opt-in-config' REFERENCE/decisions/CLAUDE.md

# Workflow doc covers all three tiers (catches a stale doc that wasn't updated)
grep -q 'light' REFERENCE/pr-review-workflow.md
grep -q 'standard' REFERENCE/pr-review-workflow.md
grep -q 'team' REFERENCE/pr-review-workflow.md
```

Manual check (can't be scripted): run `/review-pr` once and confirm the opt-in pitch appears (assuming `prompt-on-first-use` is the resolved mode).

## Notes for the receiving Claude

- **The receiving project may have already partially adopted parts of this work** (e.g. an older `/review-pr-team` from before triage existed). Don't assume a clean slate; diff first, merge second.
- **`.claude/CLAUDE.md` is the highest-conflict file.** Many projects have customised collaboration principles, technology preferences, or working rules in this file. The rollout adds a self-contained "Automated PR review system" section — drop it in alongside existing content rather than reorganising.
- **Don't carry across the `.claude/project-config.local.json` itself** — it's gitignored by design, used per-clone for local overrides. Only add the `.gitignore` rule for it.
- **If the target project's review skills look identical to the template's older form** (no Step 0, no triage step), wholesale replacement of the SKILL.md files is safe. If they've been modified locally, treat them as merge-carefully.
- **The two new ADRs are dated `2026-04-22`** — keep that date as-is when copying; ADR filenames are evergreen identifiers, not records of when they were *applied* in a derivative project.
- **Partially-adopted predecessor:** if the target project adopted PR #15 (opt-in mechanism) but not PR #16 (review-gate extraction), the gate logic — state machine, pitch text, persistence rules — will be duplicated inside `.claude/CLAUDE.md`. The merge for that file must *remove* the inline gate logic and replace it with a one-line reference to `.claude/skills/review-gate.md`, otherwise the project ends up with two sources of truth that will drift.
- **Predecessor agent backfill is silent.** If any of the seven predecessor agents (`code-reviewer`, `security-specialist`, `product-reviewer`, `architect-reviewer`, `devils-advocate`, `requirements-auditor`, `technical-skeptic`) are missing locally, fetch and create them as part of this rollout. They predate this packet but are required for `/review-pr` standard tier, `/review-pr-team`, and `/review-spec` to work. Do not flag their absence as a manifest gap — silently backfill.
- **`triage-scan-patterns.txt` is pulled forward from packet 2.** It belongs conceptually to the `2026-04-threat-model-and-safety-harness` packet (introduced in PR #21), but the version of `triage-reviewer.md` on `main` already references it. Without the patterns file, every `/review-pr` invocation hits the fail-closed branch and routes to team tier. If the next packet later re-mentions this file, it's already present from this packet's adoption — no double-fetch needed.
