# Reduce GitHub Issue bias in post-review follow-through

**Status:** Active
**Authoritative source:**
- [PR #50 — Raise the bar for creating GitHub Issues in post-review follow-through](https://github.com/mannepanne/useful-assets-template/pull/50)

**Prerequisite:** The `2026-05-post-review-follow-through` packet must already be applied — this packet is a refinement of the protocol introduced there.

---

## Why

After the `2026-05-post-review-follow-through` packet landed, reviews were significantly better structured — findings got re-bucketed and follow-up was explicit. But there was still a strong pull toward creating GitHub Issues for minor work: documentation gaps, missing ABOUT comments, small style fixes, minor tech debt. These are things that can and should be fixed in the current PR, not deferred.

The root cause was two-fold:

1. **The "Track as issue" tier only required "out of scope"** — it didn't require *non-trivial*. Minor pre-existing issues felt technically out-of-scope, so they drifted toward GitHub Issues even when a fix would take two minutes.
2. **The worked example taught the wrong thing.** The `ENHANCEMENT: Password reset email uses old brand colours` example in Step 2 is a one-line fix, not a separate story — but it was in the "Tracking as GitHub issues" bucket, signalling to the model that this kind of deferral was normal.

The effect: a review might surface five small documentation gaps and turn them into five GitHub Issues, where the right answer was "fix all five in this PR right now."

## What changed

- **"Track as issue" is now a two-factor gate** — work must be both out of scope *and* non-trivial. Previously only "out of scope" was required.
- **Explicit anti-pattern list added** — the tier definition now says: "Never create a GitHub Issue for: documentation gaps, ABOUT comments, evergreen-language fixes, minor code quality or style improvements, or anything resolvable in a few lines."
- **Cost-asymmetry framing added** — "A GitHub Issue for a 5-minute fix costs more (time spent triaging it later) than just fixing it now." Reframes issue creation as the expensive option rather than the safe one.
- **Bad example replaced** — `ENHANCEMENT: Password reset email uses old brand colours` (a minor one-line fix) replaced with `BUG: Pre-existing race condition in payment retry path — unrelated to this PR, needs separate investigation` and `FEATURE: Add SAML SSO login — came up in review discussion, distinct piece of work`. The new examples are genuinely out-of-scope, non-trivial pieces of work.
- **"Handle in this PR" now explicit about minor work** — the tier description adds "minor tech debt, small style/convention fixes" and the clarifying note "Minor does not mean defer — if it can be done in a few minutes, do it now."

## File manifest

### Merge carefully

This packet changes one file that already exists in any project that has applied `2026-05-post-review-follow-through`.

- `.claude/skills/post-review-follow-through.md` — Step 1 tier table and Step 2 example updated. See the diff in PR #50 for the exact text. Preserve any local customisations the project may have made to this file.

## Apply prompt

> Copy the block below into the receiving project's Claude session. It is self-contained — the receiving Claude won't have access to this packet's surrounding context.

```
I want to roll out a template improvement to this project. The migration packet README is at:

  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-05-reduce-github-issue-bias/README.md

Source PR:
- https://github.com/mannepanne/useful-assets-template/pull/50

How to fetch source files: use WebFetch on the raw GitHub URL pattern

  https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/<path>

substituting <path> for any file listed in the manifest (e.g.
`.claude/skills/post-review-follow-through.md`). Do NOT invent file contents — every source
file must come from the raw URL above.

Please:

1. WebFetch the packet README first and read it end-to-end. Understand WHY the change
   exists and WHAT changed before touching any file.
2. Create a feature branch (e.g. `feature/adopt-reduce-github-issue-bias`). Do NOT work on
   main.
3. Read the local `.claude/skills/post-review-follow-through.md` and WebFetch the source
   version. The packet changes two things in that file:
   a. The Step 1 tier table — specifically the "Handle in this PR" and "Track as issue" row
      definitions.
   b. The Step 2 example — the two lines under "Tracking as GitHub issues".
   Propose a merged version that applies both changes and preserves any local customisation
   elsewhere in the file.
4. Before writing ANY changes, list every proposed edit with a one-line rationale, and flag
   any place where local customisation would be lost. Wait for my confirmation.
5. After I confirm and you've applied the changes, run the verification commands from the
   packet and report results.

Note: this packet only touches one file. If the local copy of
`.claude/skills/post-review-follow-through.md` does not exist, apply the
`2026-05-post-review-follow-through` packet first.
```

## Verification

```bash
# Two-factor gate is in place
grep -q "non-trivial" .claude/skills/post-review-follow-through.md && echo "OK: non-trivial gate present" || echo "MISSING: 'non-trivial' not found in post-review-follow-through.md"

# Anti-pattern list is present
grep -q "Never create a GitHub Issue for" .claude/skills/post-review-follow-through.md && echo "OK: anti-pattern list present" || echo "MISSING: anti-pattern list not found"

# Cost-asymmetry framing is present
grep -q "5-minute fix costs more" .claude/skills/post-review-follow-through.md && echo "OK: cost-asymmetry framing present" || echo "MISSING: cost-asymmetry framing not found"

# Bad example is gone
grep -q "Password reset email" .claude/skills/post-review-follow-through.md && echo "WARNING: old bad example still present" || echo "OK: old example removed"
```

## Notes for the receiving Claude

- **One file, targeted merge.** This packet only changes `.claude/skills/post-review-follow-through.md`. No other files need touching.
- **Preserve local customisation.** The receiving project may have adjusted the three-tier table or the example in Step 2. Read the local file carefully before proposing the merge — do not overwrite wholesale.
- **Prerequisite check.** If `.claude/skills/post-review-follow-through.md` does not exist locally, the `2026-05-post-review-follow-through` packet has not been applied. Flag this to the user and apply that packet first.
