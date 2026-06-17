# Profile setup hook

Operations reference for `.claude/hooks/check-profile-setup.sh`.

Decision rationale: [`decisions/2026-05-24-personal-profile-setup-sentinel.md`](./decisions/2026-05-24-personal-profile-setup-sentinel.md)

---

## What it does

Fires on every `SessionStart`. Emits a structured JSON signal (`PERSONAL_PROFILE_SETUP_REQUIRED`) when the project hasn't been personalised for this machine yet — causing Claude to run the profile setup flow before doing any other work.

**Conditions for signal:**
1. `personal-profile.local.md` does not exist (operator hasn't personalised on this machine), AND
2. `personal-profile.md` contains the `<!-- profile_status: default -->` sentinel (committed file is still the template default)

If either condition fails, the hook exits silently. This means:
- A returning operator (`.local` exists) → no prompt, ever
- A project that's removed the sentinel from `personal-profile.md` → no prompt (manual override)
- `personal-profile.md` missing entirely → no prompt (not a template project)

---

## The `.local` file pattern

The committed `personal-profile.md` always ships with the sentinel intact. Operators never modify it. Instead, setup creates `personal-profile.local.md` (gitignored) on their machine — this is their personalised profile.

Claude reads `.local` first each session; if absent, falls back to the committed `.md`.

This mirrors the `project-config.local.json` pattern used by the PR review system.

---

## How the signal is consumed

The hook outputs structured JSON to stdout:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "PERSONAL_PROFILE_SETUP_REQUIRED: ..."
  }
}
```

Claude Code injects this into the session context. Claude detects the `PERSONAL_PROFILE_SETUP_REQUIRED` magic string and runs the setup flow in `.claude/COLLABORATION/profile-setup-flow.md` before any other work.

---

## Running the tests

```bash
.claude/hooks/tests/check-profile-setup/run-tests.sh
```

Five fixture cases: sentinel present + no `.local` (signal emitted), sentinel absent (silent), `.local` exists (silent), `personal-profile.md` missing (silent), `CLAUDE_PROJECT_DIR` unset (silent).

---

## Extending

**To add a new signal condition:** edit `check-profile-setup.sh` and add a new `if` block that outputs a new `additionalContext` string. Update the tests.

**To add a new setup question:** edit `profile-setup-flow.md` — the hook doesn't encode question content.

**To add a new field to the written profile:** edit the "Write the profile" step in `profile-setup-flow.md`.

---

## Removing / disabling

**To suppress the prompt on one machine without creating a profile:** create an empty `.local` file:

```bash
touch .claude/COLLABORATION/personal-profile.local.md
```

**To disable entirely for a project:** remove the sentinel from `personal-profile.md`. The hook exits silently when the sentinel is absent, and won't prompt again.

**To remove the hook:** delete `.claude/hooks/check-profile-setup.sh` and remove its entry from `.claude/settings.json` → `hooks.SessionStart`.
