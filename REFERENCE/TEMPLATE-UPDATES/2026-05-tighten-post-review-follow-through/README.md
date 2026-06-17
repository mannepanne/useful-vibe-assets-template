# Tighten post-review follow-through protocol

**Status:** Active
**Authoritative source:**
- [PR #55 — Tighten post-review follow-through based on downstream empirical feedback](https://github.com/mannepanne/useful-assets-template/pull/55)

**Prerequisite:** The `2026-05-reduce-github-issue-bias` packet must already be applied — this packet is a further refinement of the same protocol.

---

## Why

After the `2026-05-reduce-github-issue-bias` packet landed, a downstream project (char.gy) applied the protocol on a real feature PR and surfaced three gaps in the reasoning contract. All three were found empirically — not from inspection — which makes them high-signal.

1. **"Your call" had no teeth.** The tier required a recommendation but didn't close the escape valve: Claude could still park a finding in "Your call" without committing to a default, using the tier as a hedge rather than a genuine decision-point. Without an explicit rule forcing a default, the tier drifts into a junk-drawer for ambiguous items.

2. **Issue bodies were ad-hoc.** After 11 GitHub Issues were created in a single rollout, the bodies had inconsistent structure — same rough content but different ordering and field names. Comparing two issues side by side required re-reading rather than scanning. The protocol gave no skeleton.

3. **Partial confirmation had no contract.** The protocol only described the all-or-nothing response ("yes / go ahead"). Real interactions produce selective confirmations: "yes to 1 and 3, skip 2." Claude handled these by reading between the lines, but the protocol was silent on what the correct behaviour was — making the outcome dependent on the model's interpretation rather than an explicit rule.

The fourth suggestion from the downstream project (announcing label creation before doing it) was intentionally excluded — the side effect is trivially reversible, and the protocol's own cost-asymmetry framing argues against over-announcing small actions.

## What changed

- **"Your call" must always carry a default recommendation.** If Claude cannot pick a default, the item belongs in "Handle in this PR" with a best-guess action — "Your call" is explicitly not a hedge for items where Claude has a preference but didn't want to state it.
- **Issue body now has a fixed three-section skeleton** — Finding / Source / Suggested fix — so batches of issues stay consistent and navigable. The Source section requires the full PR URL (not just the number) so the issue is readable from the Issues UI without the repo URL pre-loaded.
- **Partial confirmation now has an explicit contract** — if the operator confirms some items and skips others, Claude must state which items it is acting on and which it is dropping before making any change.
- **Step 2 prompts hint at partial confirmation** — both the "Handle in this PR" and "Tracking as GitHub issues" prompts now surface that item-level responses are valid, so the operator doesn't have to discover the contract by trial and error.

## File manifest

### Merge carefully

This packet changes one file that already exists in any project that has applied `2026-05-reduce-github-issue-bias`.

- `.claude/skills/post-review-follow-through.md` — four targeted changes: the "Your call" tier row (Step 1 table), two Step 2 confirmation prompts, a new partial-confirmation paragraph at the end of Step 2, and the issue body entry in Step 3. See PR #55 for the exact diff. Preserve any local customisations the project may have made to this file.

## Apply prompt

> Copy the block below into the receiving project's Claude session. It is self-contained — the receiving Claude won't have access to this packet's surrounding context.

```
I want to roll out a template improvement to this project. The migration packet README is at:

  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-05-tighten-post-review-follow-through/README.md

Source PR:
- https://github.com/mannepanne/useful-assets-template/pull/55

How to fetch source files: use WebFetch on the raw GitHub URL pattern

  https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/<path>

substituting <path> for any file listed in the manifest (e.g.
`.claude/skills/post-review-follow-through.md`). Do NOT invent file contents — every source
file must come from the raw URL above.

Please:

1. WebFetch the packet README first and read it end-to-end. Understand WHY the change
   exists and WHAT changed before touching any file.
2. Create a feature branch (e.g. `feature/adopt-tighten-post-review-follow-through`). Do NOT
   work on main.
3. Read the local `.claude/skills/post-review-follow-through.md` and WebFetch the source
   version. The packet makes four targeted changes to that file:
   a. Step 1 tier table — the "Your call" row: adds a mandatory default-recommendation rule
      and an explicit "not a hedge" constraint.
   b. Step 2 "Handle in this PR" prompt — extends the confirmation parenthetical to hint that
      item-level replies are valid ("yes for all, or name specific items").
   c. Step 2 "Tracking as GitHub issues" prompt — same hint added.
   d. Step 2 end — new "Partial confirmation" paragraph defining the contract for selective
      operator responses.
   e. Step 3 item 3 — replaces the vague "Issue body: what was found..." line with a fixed
      three-section skeleton (Finding / Source / Suggested fix) plus a full-PR-URL note.
   Propose a merged version that applies all four changes and preserves any local
   customisation elsewhere in the file.
4. Before writing ANY changes, list every proposed edit with a one-line rationale, and flag
   any place where local customisation would be lost. Wait for my confirmation.
5. After I confirm and you've applied the changes, run the verification commands from the
   packet and report results.

Note: this packet only touches one file. If the local copy of
`.claude/skills/post-review-follow-through.md` does not exist, apply the
`2026-05-post-review-follow-through` packet first, then `2026-05-reduce-github-issue-bias`,
then this one.
```

## Verification

```bash
# "Your call" default-recommendation rule is in place
grep -q "Always present a default recommendation" .claude/skills/post-review-follow-through.md && echo "OK: default-recommendation rule present" || echo "MISSING: default-recommendation rule not found"

# "Your call" not-a-hedge constraint is in place
grep -q "not a hedge" .claude/skills/post-review-follow-through.md && echo "OK: not-a-hedge constraint present" || echo "MISSING: not-a-hedge constraint not found"

# Partial-confirmation contract is present
grep -q "Partial confirmation" .claude/skills/post-review-follow-through.md && echo "OK: partial-confirmation contract present" || echo "MISSING: partial-confirmation contract not found"

# Issue body skeleton is in place
grep -q "## Finding" .claude/skills/post-review-follow-through.md && echo "OK: issue body skeleton present" || echo "MISSING: issue body skeleton not found"

# Full PR URL note is present
grep -q "full PR URL" .claude/skills/post-review-follow-through.md && echo "OK: full-PR-URL note present" || echo "MISSING: full-PR-URL note not found"

# Step 2 prompts hint at partial confirmation
grep -q "yes for all" .claude/skills/post-review-follow-through.md && echo "OK: partial-confirmation hint in prompts" || echo "MISSING: partial-confirmation hint not found in prompts"
```

## Notes for the receiving Claude

- **One file, four targeted changes.** This packet only modifies `.claude/skills/post-review-follow-through.md`. No other files need touching.
- **Preserve local customisation.** The receiving project may have adjusted the tier table, the Step 2 format, or the issue-creation block. Read the local file carefully before proposing the merge — do not overwrite wholesale.
- **Prerequisite chain.** This packet builds on `2026-05-post-review-follow-through` → `2026-05-reduce-github-issue-bias` → this packet. If either predecessor is missing, apply them in order first.
- **The Step 2 example** in the source file already uses the "Your call" tier correctly (it includes "My recommendation: …"). The new "Your call" rule makes the existing example coherent rather than contradicting it — no change to the example is needed.
