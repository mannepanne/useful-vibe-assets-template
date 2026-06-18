---
name: check-profile-setup
description: Check if personal profile setup is required and trigger setup flow if needed. Replaces the SessionStart hook functionality from Claude Code.
user-invocable: true
---

# Profile Setup Check

This skill replaces the SessionStart hook functionality from Claude Code. It checks whether the user has completed their personal profile setup and guides them through the setup process if needed.

## Purpose

In Claude Code, the SessionStart hook would automatically check for profile setup on session start. In Vibe, since there's no equivalent hook system, this skill provides the same functionality in a user-invocable form. It should be run at the beginning of significant sessions or when the user first starts working with the template.

---

## Instructions for Vibe

### Step 0: Check conditions

Check the following conditions in order:

1. **Check for local profile**: Read `.vibe/COLLABORATION/personal-profile.local.md`:
   - If it exists: Setup is complete. Exit with confirmation: "✅ Personal profile is already set up. You're good to go!"

2. **Check for default profile marker**: Read `.vibe/COLLABORATION/personal-profile.md`:
   - If it does NOT contain `<!-- profile_status: default -->`: Setup is complete. Exit with confirmation: "✅ Personal profile is already set up. You're good to go!"

3. **If neither condition is met**: Profile setup is required. Continue to Step 1.

### Step 1: Trigger setup

If profile setup is required:

1. Inform the user:
   > "Personal profile setup is required before we continue. This template uses personalized profiles to provide better context and guidance."

2. Offer two options:
   - **Option A: Quick setup** - Guide them to run the setup-profile skill:
     > "Run `/setup-profile` and I'll guide you through the setup process."
   
   - **Option B: Manual setup** - Provide instructions:
     > "Or you can manually copy `.vibe/COLLABORATION/personal-profile.md` to `.vibe/COLLABORATION/personal-profile.local.md` and customize it with your information."

3. Provide the full setup instructions from `.vibe/COLLABORATION/profile-setup-flow.md` (if it exists), or give these instructions:
   ```
   To set up your profile:
   1. Copy .vibe/COLLABORATION/personal-profile.md to .vibe/COLLABORATION/personal-profile.local.md
   2. Open the new file and replace all placeholders with your actual information
   3. Save the file
   4. The file is gitignored, so your personal info won't be committed
   ```

### Step 2: Verify (optional)

After the user indicates they've completed setup, re-check the conditions from Step 0 to confirm completion:
- If setup is now complete: "✅ Profile setup complete! Thank you. You can now use all template features."
- If setup is still incomplete: "I don't see the profile file yet. Would you like to try again or skip setup for now?"

---

## When to Run

This skill should be run:

1. **At the start of a new project** - First thing when using the template
2. **Before running review skills** - To ensure proper context
3. **Periodically** - To verify setup is still current
4. **After updating the template** - To check for new profile fields

---

## Vibe-Specific Notes

This skill **replaces Claude Code's SessionStart hook** which would automatically run this check. In Vibe's model:

- **Claude**: Hooks run automatically on session start
- **Vibe**: Skills must be explicitly invoked

### Integration Points

Other skills and workflows can call this skill as a prerequisite:

```
skill: {"name": "check-profile-setup"}
```

This can be added to the beginning of other skills that require profile information.

### Future Enhancement

If Vibe adds hook support or MCP server event triggers, this check could be automated. For now, explicit invocation or integration into other skills is the best approach.

---

## Related Files

- `.vibe/COLLABORATION/personal-profile.md` - Template profile (committed)
- `.vibe/COLLABORATION/personal-profile.local.md` - User's profile (gitignored)
- `.vibe/COLLABORATION/profile-setup-flow.md` - Detailed setup instructions (if exists)
- `.vibe/COLLABORATION/README.md` - Overview of the collaboration system

---

## Example Usage

```
/check-profile-setup
```

This will check if your personal profile is set up and guide you through the process if needed.
