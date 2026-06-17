# ADR: Sentinel in committed profile + gitignored `.local` sibling for first-run personalisation

**Date:** 2026-05-24
**Status:** Active

---

## Decision

Use a `<!-- profile_status: default -->` sentinel in the committed `personal-profile.md` to signal "not yet personalised", and write the operator's actual profile to a gitignored `personal-profile.local.md` on their machine. A `SessionStart` hook detects the combination (sentinel present + `.local` absent) and signals Claude to run the setup flow.

## Context

The template ships with a collaboration profile (`personal-profile.md`) that tells Claude who it's working with and how they like to collaborate. This needs to be personalised per operator, but the template must also ship in a state that prompts new users to personalise — without relying on them knowing to do so. The operator who maintains the template also needs to work under their own personalised profile without their personal details leaking into the committed repo.

## Alternatives considered

- **Remove sentinel from `personal-profile.md` after setup (edit the committed file):** Setup modifies the committed file, which means the operator can't safely develop template improvements — every session after first run would be fine, but the repo would diverge from the template's intended starting state. Template author couldn't test that new cloners get prompted correctly without resetting the file manually.
- **Store personalisation flag in `project-config.json`:** Couples two orthogonal concerns (PR review mode and profile state) into one file. Also doesn't solve the "operator's personal details in git" problem.
- **Separate flag file (e.g., `.claude/profile-setup-done`):** Solves the "don't modify the profile file" concern, but adds a file that communicates only to the hook — not to Claude or the user. The `.local` file serves the same signal role while also *being* the profile.
- **No automation — rely on README instructions:** Cloners forget. The hook is invisible when not needed (exits in ~10ms) and only fires once per machine.

## Reasoning

The `.local` sibling pattern solves all three concerns simultaneously:

1. **Operator safety:** The committed `personal-profile.md` is never modified. Magnus can maintain the template under his own personalised `.local` profile, and the repo always looks like an unmodified template to cloners.

2. **Correct first-run experience:** A fresh clone has no `.local` file and the sentinel is in `personal-profile.md`. The hook fires, Claude runs setup, and `.local` is created. The hook never fires again on that machine.

3. **Git hygiene:** The `.local` file is gitignored. Personal details (name, communication preferences, PM style) never accidentally land in version control.

The pattern is consistent with `project-config.local.json` used by the PR review system — operators already understand the `.local` override convention if they've used that feature.

The sentinel approach (vs. a flag file) means Claude can also manually detect "this is the default profile" by reading `personal-profile.md` — useful if the hook doesn't fire but Claude reads the profile anyway.

## Trade-offs accepted

- The hook runs on every `SessionStart`, even when not needed. Exit cost is ~10ms (two filesystem checks); negligible.
- The sentinel is permanent in `personal-profile.md`. Authors must not remove it from the committed file — this is enforced by convention, not by the tool.
- If an operator deletes their `.local` file, the prompt fires again. This is correct behaviour (they'd need to re-personalise).

## Implications

- `personal-profile.md` in the repo is always the unmodified template default. It can be treated as read-only after initial template creation.
- Claude must always read `.local` first, falling back to `.md` — this is documented in `.claude/COLLABORATION/CLAUDE.md` and `.claude/CLAUDE.md`.
- The `.local` pattern is available to any future per-machine override (e.g., machine-specific tool preferences).

---

## References

- Related ADRs: [`2026-04-22-prreviewmode-opt-in-config.md`](./2026-04-22-prreviewmode-opt-in-config.md) — the `project-config.local.json` pattern this mirrors
- Operations reference: [`REFERENCE/profile-setup-hook.md`](../profile-setup-hook.md)
- Setup flow: [`.claude/COLLABORATION/profile-setup-flow.md`](../../.claude/COLLABORATION/profile-setup-flow.md)
