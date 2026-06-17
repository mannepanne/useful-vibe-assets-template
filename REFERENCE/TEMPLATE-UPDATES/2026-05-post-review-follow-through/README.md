# Post-review follow-through protocol

**Status:** Active
**Authoritative source:**
- [PR #43 — Add post-review follow-through protocol — action tiers and GitHub issues](https://github.com/mannepanne/useful-assets-template/pull/43)
- [PR #44 — Replace technical-debt.md with GitHub issues tracking](https://github.com/mannepanne/useful-assets-template/pull/44)

---

## Why

After a review posted, the old Step 4 emitted a count of critical findings and left it at that. Warnings and suggestions had no structured home: they might get addressed, might drift, might get mentally filed as "we'll do that later" with no record anywhere. Two problems flowed from this:

1. **Reviews felt incomplete.** The hard work of the reviewer agents produced findings but no clear owner or action path for each one.
2. **Technical debt accumulated invisibly.** "Track it later" almost always meant "forget it." The `REFERENCE/technical-debt.md` file was empty in most projects — because there was no protocol pointing people to fill it in, and because it was a second tracking system that duplicated GitHub issues (which is where real work lives).

The fix is a shared post-review protocol that re-buckets every finding into one of three action tiers — **handle in this PR / your call / track as GitHub issue** — and makes deferral concrete rather than verbal. The `technical-debt.md` file is retired in favour of GitHub issues with a `technical-debt` label, which is where work tracking already happens.

## What changed

- **New shared protocol:** `.claude/skills/post-review-follow-through.md` — defines the three action tiers, the output format, and the GitHub issue creation steps. Both review skills reference it rather than duplicating the logic.
- **`/review-pr` Step 4 rewritten:** was a bullet-list summary (tier, counts, recommendation, link). Is now a one-line status followed by the follow-through protocol.
- **`/review-pr-team` Step 4 rewritten:** same change — one-line status plus the follow-through protocol.
- **`REFERENCE/technical-debt.md` retired:** the file is deleted. Technical debt is now tracked as GitHub issues with the `technical-debt` label.
- **Documentation references updated:** `CLAUDE.md` (root), `REFERENCE/CLAUDE.md`, `REFERENCE/troubleshooting.md`, and `SPECIFICATIONS/00-TEMPLATE-phase.md` all point to GitHub issues instead of the now-deleted file.

## File manifest

### Copy verbatim

Files that did not exist before this change. Add them as-is.

- `.claude/skills/post-review-follow-through.md` — the shared follow-through protocol

### Merge carefully

Files that almost certainly exist in the target project with different content. Read the local version, apply the sections below, and preserve any local customisation elsewhere in the file.

- `.claude/skills/review-pr/SKILL.md` — **Step 4** was a bullet-list summary; replace with a one-line status + reference to `post-review-follow-through.md`. See the diff in PR #43 for the exact replacement text.
- `.claude/skills/review-pr-team/SKILL.md` — **Step 4** (same change as above). See PR #43.
- `CLAUDE.md` (project root) — two small edits:
  - In the `REFERENCE/` listing, remove the `[technical-debt.md](./REFERENCE/technical-debt.md)` line.
  - In the Quick reference section, change the "Known issues?" link from `technical-debt.md` to: `GitHub Issues with \`technical-debt\` label`.
- `REFERENCE/CLAUDE.md` — remove the `### [technical-debt.md]` section (heading + two-line description).
- `REFERENCE/troubleshooting.md` — remove or update any line that references `technical-debt.md` as a destination for recording issues.
- `SPECIFICATIONS/00-TEMPLATE-phase.md` — update any reference to `technical-debt.md` to read: "Track deferred items as GitHub issues with the `technical-debt` label."

### Remove / migrate

**Important: read and migrate before deleting.**

- `REFERENCE/technical-debt.md` — check whether the local copy has any non-empty entries (items below the frontmatter / intro). If it does, **list them and ask the user to confirm** conversion to GitHub issues (using the `technical-debt` label) *before* removing the file. Do not delete silently. If the file is empty or contains only boilerplate, it is safe to delete directly.

## Apply prompt

> Copy the block below into the receiving project's Claude session. It is self-contained — the receiving Claude won't have access to this packet's surrounding context.

```
I want to roll out a template improvement to this project. The migration packet README is at:

  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-05-post-review-follow-through/README.md

Source PRs:
- https://github.com/mannepanne/useful-assets-template/pull/43
- https://github.com/mannepanne/useful-assets-template/pull/44

How to fetch source files: use WebFetch on the raw GitHub URL pattern

  https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/<path>

substituting <path> for any file listed in the manifest (e.g.
`.claude/skills/post-review-follow-through.md`). Do NOT invent file contents — every source
file must come from the raw URL above.

Please:

1. WebFetch the packet README first and read it end-to-end. Understand WHY the change
   exists and WHAT changed before touching any file.
2. Create a feature branch (e.g. `feature/adopt-post-review-follow-through`). Do NOT work
   on main.
3. For "Copy verbatim" files: check whether the file exists locally. If not, WebFetch the
   source and create it. If it does, treat as "merge carefully" instead and flag the
   conflict.
4. For "Merge carefully" files: read the local version and WebFetch the source version.
   Identify the sections this packet adds or modifies, and propose a merged version that
   preserves any local customisation.
5. For "Remove / migrate" files: read the local `REFERENCE/technical-debt.md` first. If it
   has any non-empty entries (real tracked items, not boilerplate), list them and ask me to
   confirm converting them to GitHub issues before deleting the file. If empty, safe to
   delete directly.
6. Before writing ANY changes, list every proposed edit with a one-line rationale, and
   flag any place where local customisation would be lost. Wait for my confirmation.
7. After I confirm and you've applied the changes, run the verification commands from
   the packet and report results.

Prerequisite: this packet assumes `gh` is authenticated against this repo
(`gh auth status` should succeed). The follow-through protocol uses `gh issue create` and
`gh label create` — if `gh` is not set up, flag that to me before proceeding.
```

## Verification

```bash
# New protocol file is present
test -f .claude/skills/post-review-follow-through.md && echo "OK: post-review-follow-through.md present" || echo "MISSING: post-review-follow-through.md"

# review-pr Step 4 references the protocol
grep -q "post-review-follow-through" .claude/skills/review-pr/SKILL.md && echo "OK: review-pr references protocol" || echo "MISSING: review-pr/SKILL.md reference"

# review-pr-team Step 4 references the protocol
grep -q "post-review-follow-through" .claude/skills/review-pr-team/SKILL.md && echo "OK: review-pr-team references protocol" || echo "MISSING: review-pr-team/SKILL.md reference"

# technical-debt.md is gone
test ! -f REFERENCE/technical-debt.md && echo "OK: technical-debt.md removed" || echo "NOT REMOVED: REFERENCE/technical-debt.md still present"

# No dangling references to technical-debt.md in docs
grep -rn "technical-debt\.md" CLAUDE.md REFERENCE/ SPECIFICATIONS/ 2>/dev/null && echo "WARNING: dangling technical-debt.md references found above" || echo "OK: no dangling references"

# GitHub issues label convention is referenced somewhere
grep -q "technical-debt" CLAUDE.md && echo "OK: technical-debt label mentioned in CLAUDE.md" || echo "WARNING: CLAUDE.md may not reference the GitHub label"
```

## Notes for the receiving Claude

- **`technical-debt.md` content first.** Do not delete the file without checking it. Real projects may have non-trivial entries; those need converting to GitHub issues before the file goes. The packet's "Remove / migrate" section and apply prompt both repeat this — do not skip the check.
- **`gh` CLI prerequisite.** The follow-through protocol calls `gh issue create` and `gh label create`. If `gh` is not authenticated, flag it to the user before proceeding — the protocol still has value as a conversational workflow, but the automated issue creation won't work.
- **Soft dependency on `2026-04-pr-review-triage`.** This packet modifies `.claude/skills/review-pr/SKILL.md` and `.claude/skills/review-pr-team/SKILL.md`. Those files must already exist — they were introduced in the `2026-04-pr-review-triage` packet. If they are absent, apply that packet first.
- **`SPECIFICATIONS/00-TEMPLATE-phase.md`** — some derivative projects may have renamed or removed this file if they've completed their initial phase. Check for its existence before editing; if absent, skip it.
