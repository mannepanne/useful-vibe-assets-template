# Combined apply prompt — PR review triage + threat model & safety harness

A single self-contained message to paste into a derivative project's Claude Code session that rolls out **both** of the following packets back-to-back, in order:

1. [`2026-04-pr-review-triage/`](./2026-04-pr-review-triage/) — tiered review dispatcher, `prReviewMode` opt-in, extracted `review-gate.md`.
2. [`2026-04-threat-model-and-safety-harness/`](./2026-04-threat-model-and-safety-harness/) — threat-model ADR, silent-review conventions, PreToolUse safety-harness hook.

## When to use this

- The derivative project has neither packet applied yet (typical for an older fork from before PR #13).
- You want a single paste rather than running the two packets' apply prompts separately.

## When NOT to use this

- The derivative project already has packet 1 applied. In that case, paste only the apply prompt from `2026-04-threat-model-and-safety-harness/README.md` — no need for the combined version.
- The derivative project has a contributor model that differs from the template's (open-source PRs from strangers, multi-team enterprise, regulated environment, junior developers as primary users). Use the individual packet READMEs and engage with the threat-model ADR's tightening checklist deliberately rather than running this combined flow.

## How to use it

1. Open Claude Code in the derivative project's directory (clean working tree).
2. Copy the entire fenced block below (including the outer code fences only as visual delimiters — paste the inner content).
3. Paste into the session and let Claude work through it. It will pause between packets so you can review and merge packet 1's PR before packet 2 starts.

## Notes for future maintenance

- If a third packet lands that should also be combined into this rollout, either extend this file (and rename it) or — better — create a new combined-apply file for the new pair/triple, leaving this one in place for projects that only need these two.
- If either underlying packet is superseded, mark this file with a `**Superseded by:** [link]` line at the top rather than deleting it. Derivative projects on older forks may still reference it.

## Magnus "pre-prompt prompt" to explain...

Ok, we are going to try a new thing. I don't know if you recall, but the basic structure for this repo comes from a "template" I use when setting up collaborative projects with Claude. The template "lives" in its own repo, and I constantly improve it and sometimes roll the improvements out to projects that are "derivatives" of an earlier version of that template. I now have a set of improvements that are quite complex, that I can't simply roll out on a file by file basis. So I have tried creating a "template update" that works on a prompt level to use your knowledge of this local repo together with a definition of what improvements to apply hosted in the updated template repo to try and "absorb" the improvements safely without ruining any local tweaks we have done.

Makes sense? I have a prompt to get this started, if you are ready.

## The combined apply prompt

```
I want to roll out two template improvements from `mannepanne/useful-assets-template` into
this project, in order. Each is a self-contained "migration packet" with its own README and
"Apply prompt". Run them as two sequential feature branches + PRs.

Source repo: https://github.com/mannepanne/useful-assets-template (branch: main)

How to fetch source files: WebFetch on the raw GitHub URL pattern

  https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/<path>

Do NOT invent file contents — every source file must come from the raw URL above.

================================================================================
PACKET 1 — PR review triage system
================================================================================

Migration packet README:
  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-04-pr-review-triage/README.md

Source PRs in mannepanne/useful-assets-template: #13, #14, #15, #16

Steps:

1. WebFetch the packet 1 README and read it end-to-end. The two ADRs it references are
   the best design-rationale context.
2. Create a feature branch (e.g. `feature/adopt-pr-review-triage`). Do NOT work on main.
3. For each file in "Copy verbatim" (including the "Predecessor files" sub-section),
   check whether a file at that path exists locally. If not, WebFetch the source and
   create it. If it does, treat as "merge carefully" and flag the conflict. The
   predecessor files are required baseline that older forks may not have — fetch them
   silently if absent rather than treating as a manifest gap.
4. For each file in "Merge carefully", read the local version and WebFetch the source
   version. Identify the sections this rollout adds or modifies and propose a merged
   version that preserves any local customisation. Pay special attention to
   `.claude/CLAUDE.md` and `.claude/skills/review-pr/SKILL.md` — highest conflict surface.
5. For each "Conditional" file, evaluate the stated condition before deciding.
6. Before writing ANY changes, list every proposed edit with a one-line rationale and
   flag every place where local customisation could be lost. Wait for my confirmation.
7. After I confirm and you've applied the changes, run the packet's verification commands
   and report results.
8. Commit, push, open a PR, wait for me to merge it before continuing to packet 2.

================================================================================
PACKET 2 — Threat-model calibration, silent reviews, safety-harness, and SCRATCH-write hook
================================================================================

(Only proceed once packet 1's PR is merged.)

Migration packet README:
  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-04-threat-model-and-safety-harness/README.md

Source PRs in mannepanne/useful-assets-template: #18, #19, #21, #22, #23, #24, #25,
#30, #31, #32, #33, #34

Steps:

1. WebFetch the packet 2 README and read it end-to-end. The "Why" section is load-bearing
   — the threat model is the foundational assumption that calibrates everything downstream.

2. **BEFORE applying anything**, surface this question to me:

   "This packet's calibrations (severity defaults, safety-harness block/ask choices,
    PR-review tool grants) all assume a single trusted contributor or small team of
    mutually-trusted contributors. If this project's contributor model differs (open-
    source PRs from strangers, multi-team enterprise, regulated environments, junior
    developers as primary users), the threat-model ADR's tightening checklist applies
    before adopting the calibrations. Should I read the threat-model ADR and surface
    any calibration that should be tightened for this project, or proceed with the
    template defaults?"

   Wait for my answer before proceeding.

3. Create a feature branch (e.g. `feature/adopt-threat-model-and-safety-harness`).
   Do NOT work on main.

4. Apply the FOUR sub-changes IN ORDER (see the packet's "Application order" section):
   a. Threat-model ADR + agent severity calibration.
   b. Silent-review conventions (Tool invocation conventions section, allowlist
      additions, triage patterns file rename, dispatcher fallback, WebFetch grants on
      spec-review agents).
   c. Safety harness — establishes the `hooks.PreToolUse` block (first entry, Bash matcher).
   d. SCRATCH-write hook — appends the second entry to `hooks.PreToolUse` (Write matcher).
      Apply after Stage c so the block-merge is a single pass.

5. For each "Copy verbatim" file, check existence; WebFetch + create if absent, treat as
   "merge carefully" if present.

6. For each "Merge carefully" entry, the manifest is section-level for the highest-
   conflict files (`.claude/agents/CLAUDE.md`, `.claude/settings.json`). Read the local
   version section-by-section, WebFetch source, identify what to add/replace, propose
   per-section merge. Do NOT treat `.claude/settings.json` as a single-file merge — its
   three deltas (env, permissions.allow, hooks.PreToolUse) must apply independently. The
   `hooks.PreToolUse` block now contains TWO entries (safety-harness + approve-scratch-write);
   append both if neither is present, or just the missing one.

7. Triage patterns file rename: if the local file exists under the OLD name
   (`triage-secret-patterns.txt`), delete it and create the new name
   (`triage-scan-patterns.txt`). If neither exists, create the new name only.

8. `chmod +x` on these four .sh files immediately after WebFetching them. Raw GitHub URLs
   do not preserve the executable bit. Without this step, the hooks silently fail:
   - `.claude/hooks/safety-harness.sh`
   - `.claude/hooks/tests/safety-harness/run-tests.sh`
   - `.claude/hooks/approve-scratch-write.sh`
   - `.claude/hooks/tests/approve-scratch-write/run-tests.sh`

9. Two fixture directories need bulk-fetching:
   - `.claude/hooks/tests/safety-harness/fixtures/` — 39 pairs (78 files)
   - `.claude/hooks/tests/approve-scratch-write/fixtures/` — 6 pairs (12 files)

   Do NOT enumerate them in the apply plan. Use the GitHub tree API to list both
   directories once, then WebFetch each file:

     https://api.github.com/repos/mannepanne/useful-assets-template/git/trees/main?recursive=1

   Filter to entries with path prefix `.claude/hooks/tests/safety-harness/fixtures/` and
   `.claude/hooks/tests/approve-scratch-write/fixtures/`, fetch each via the raw URL
   pattern.

10. For "Conditional" files, evaluate the stated condition before deciding.

11. Excluded files — do NOT fetch any of the following even though they appear in the
    source PRs' diffs. All are template-internal historical context:
    - `SPECIFICATIONS/ARCHIVE/pretooluse-safety-harness.md` (template's own historical
      spec record)
    - `SPECIFICATIONS/ARCHIVE/INVESTIGATION-claude-code-write-path-normalisation.md`
      (the diagnosis trail that motivated the SCRATCH-write hook; the conclusion
      travels via the ADR, the trail stays in the template — the ADR points to the
      upstream URL for the breadcrumb)
    - `TEMPLATE-INSTRUCTIONS.md` (template-bootstrap doc)

12. Before writing ANY changes, list every proposed edit with a one-line rationale and
    flag every place where local customisation could be lost. Wait for my confirmation.

13. After applying, run the packet's verification commands and report results. The two
    test-suite checks catch partial rollouts:
    - `bash .claude/hooks/tests/safety-harness/run-tests.sh` (Stage c, expect 40/40)
    - `bash .claude/hooks/tests/approve-scratch-write/run-tests.sh` (Stage d, expect 7/7)
    `test -f` and `grep -q` checks are necessary but not sufficient.

14. Commit, push, open a PR.

================================================================================
GROUND RULES (BOTH PACKETS)
================================================================================

- NEVER work on main. Feature branch + PR per packet, always.
- NEVER invent file contents — always WebFetch from the raw URL.
- Always diff before overwriting; flag local customisation that could be lost and wait
  for my confirmation before writing.
- If a step in a packet's apply prompt conflicts with the local project's own CLAUDE.md
  rules, stop and ask — don't silently choose one.
- Stop and report between packet 1 and packet 2 — don't run them back-to-back without
  giving me a chance to merge packet 1's PR first.
```

## Post applying both packets

Run this prompt to do a repo wide sweep for consistency and any clean up.

```
Now that both rollout packets have landed, do a post-rollout consistency sweep
  of the whole repo. Audit-only — surface findings in a structured report and
  wait for my confirmation before changing anything.

  Scope: every documentation file, every agent, every skill, every hook, settings,
  gitignore, ADR index, archive index. NOT SPECIFICATIONS/ phase files (active
  work, read-only).

  Check these nine areas:

  1. **Markdown link integrity.** Every relative link in every .md file should
     resolve. Every anchor (#section-name) should resolve to a real heading.
     Common post-rollout breakage:
     - Links to files renamed or deleted upstream (e.g. triage-secret-patterns →
       triage-scan-patterns, anything that pointed at TEMPLATE-FOLLOWUPS.md)
     - Anchors renamed when sections were restructured
     - Cross-doc links from CLAUDE.md/SKILL.md/agent files that referenced
       pre-rollout structure

  2. **Index / catalogue consistency.** Each directory's CLAUDE.md should list
     every file present in that directory, and only files that are present:
     - `.claude/CLAUDE.md`, `.claude/agents/CLAUDE.md`, `.claude/skills/` (if it
       has an index)
     - `REFERENCE/CLAUDE.md`, `REFERENCE/decisions/CLAUDE.md`
     - `SPECIFICATIONS/CLAUDE.md` (read-only — just check the list, don't propose
       phase-status changes), `SPECIFICATIONS/ARCHIVE/CLAUDE.md`
     For each: cross-check entries against `ls` of the directory. Flag orphan
     entries (pointing at non-existent files) and unindexed files.

  3. **Skill ↔ agent wiring.** Every skill that calls an agent via the Agent tool
     should reference an agent file that exists. Every agent file should be
     referenced from at least one skill or its directory's index. Orphan agents
     are dead code.

  4. **Settings + hook hookup.** In `.claude/settings.json`:
     - Hook script paths point at files that exist on disk
     - No orphan permission allow-list entries pointing at tools/paths the project
       doesn't actually use
     - No duplicated permission entries
     - Any project-specific keys (e.g. `enabledPlugins.*` entries the template
       doesn't ship) preserved
     On disk:
     - `.claude/hooks/safety-harness.sh` and
       `.claude/hooks/tests/safety-harness/run-tests.sh` both have executable
       bits set (`test -x`)
     - `.claude/hooks/approve-scratch-write.sh` and
       `.claude/hooks/tests/approve-scratch-write/run-tests.sh` both have
       executable bits set (`test -x`)
     - Run both `bash .claude/hooks/tests/safety-harness/run-tests.sh` and
       `bash .claude/hooks/tests/approve-scratch-write/run-tests.sh` once and
       report pass/fail for each
     - Fixture pair count matches the packet manifest

  5. **Legacy / stale content.** Search the whole repo for:
     - References to the older single-pipeline `/review-pr` (pre-triage);
       replaced by the triage dispatcher
     - The old name `triage-secret-patterns.txt` (renamed to
       `triage-scan-patterns.txt`)
     - Any mention of `TEMPLATE-FOLLOWUPS.md`
     - Older 2-tier review workflow language
     - Stale "Current phase" / status markers that don't match reality

  6. **Dead files on disk.** Files that exist but have no purpose:
     - `.bak` / `.orig` / `.swp` files from interrupted edits
     - Stray temp files (`/tmp/review-pr-*` legacy artefacts and any
       non-gitignored contents of `SCRATCH/` shouldn't persist in the repo)
     - Empty directories
     - Scratch files left from the rollout work
     **Caution:** be conservative. Many files look unused but are referenced
     indirectly (e.g. via WebFetch URL patterns or hook matchers). When unsure,
     list as a question rather than a removal recommendation.

  7. **Local project customisation preserved.** Spot-check that the rollout
     didn't silently drop project-specific content. The exact items vary by
     project — adapt this list to what your project actually has:
     - Project-specific REFERENCE entries (domain feature docs, integration
       guides, environment notes that aren't from the template)
     - Local ADRs in `REFERENCE/decisions/` that record project-specific
       decisions (i.e. anything not dated from the template's packet rollouts)
     - Project-specific `.gitignore` entries
     - Project context in root CLAUDE.md (project name, project narrative,
       phase index, stack section, naming inspiration)
     - Project-specific phase docs in `SPECIFICATIONS/`
     - Customised content in spec-review agent files
       (`devils-advocate.md`, `requirements-auditor.md`, `technical-skeptic.md`)
       where the template ships placeholders but the project has filled them
       with concrete stack mentions

  8. **Cross-packet coherence.** A few things should hook up across the two
     packets:
     - Anchors pointing at `.claude/agents/CLAUDE.md#severity-calibration`
       resolve
     - Anchors pointing at `.claude/agents/CLAUDE.md#untrusted-input-contract`
       resolve
     - **Per-file direct ADR reference (do not rely on inheritance).** Each of
       `.claude/agents/triage-reviewer.md`, `.claude/agents/light-reviewer.md`,
       and `.claude/agents/security-specialist.md` MUST contain a direct,
       grep-able reference to `2026-04-25-pr-review-threat-model.md`. Verify
       with `grep -l '2026-04-25-pr-review-threat-model' <each file>` — all
       three should match. Transitive inheritance through the
       `agents/CLAUDE.md` severity-calibration section is not sufficient:
       reviewers should be self-contained on their calibration assumptions, and
       a reviewer read in isolation needs the ADR pointer without having to
       know the inheritance chain.
     - The two packet-1 ADRs (`2026-04-22-...`) and the three packet-2 ADRs
       (`2026-04-25-pr-review-threat-model.md`,
       `2026-04-26-allowlist-pinning-principle.md`,
       `2026-04-26-scratch-write-pretooluse-hook.md`) are all in
       `REFERENCE/decisions/CLAUDE.md`'s index

  9. **Branch / git state.** Confirm working tree is clean, on main, and any
     feature branches from the rollout that have been merged can be deleted.

  Output format: structured report grouped by area. For each finding:
  - File path (and line number if relevant)
  - What's wrong
  - Severity: blocker / drift / nit
  - Proposed fix (one line) or "needs discussion"

  Constraints:
  - Audit only — do NOT write, edit, or delete files yet
  - Do NOT touch SPECIFICATIONS/ phase files
  - Do NOT propose stylistic changes that aren't actually broken (headline case,
    comment style, etc.) — focus on real drift
  - If unsure whether something is drift or intentional project customisation,
    list as a question, not a finding

  When the report is ready, present it. I'll triage and approve specific fixes
  before you change anything.
```
