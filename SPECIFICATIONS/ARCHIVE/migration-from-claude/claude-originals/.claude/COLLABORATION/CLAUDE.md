# Collaboration Reference Library

Auto-loaded when working with files in this directory. Navigation index for collaboration guidance.

## Files in this directory

### [personal-profile.md](./personal-profile.md) / [personal-profile.local.md](./personal-profile.local.md)
**When to read:** Every session — tells you who you're working with, how they like to be addressed, their background, communication preferences, and PM style.

Read `personal-profile.local.md` if it exists (gitignored, operator's personalised copy); otherwise fall back to `personal-profile.md` (the committed template default). The SessionStart hook handles detection — if it fires `PERSONAL_PROFILE_SETUP_REQUIRED`, run the setup flow in `profile-setup-flow.md` before anything else.

### [profile-setup-flow.md](./profile-setup-flow.md)
**When to read:** When `PERSONAL_PROFILE_SETUP_REQUIRED` fires at session start (hook detected the default sentinel in `personal-profile.md`).

Step-by-step instructions for personalising the profile, handling the "keep as-is" case, making the file private, and guiding the operator to the project-outline conversation.

### [documentation-standards.md](./documentation-standards.md)
**When to read:** Creating or updating project documentation, README files, or reference guides.

Templates and standards for writing clear, complete technical documentation.

### [product-management-mode.md](./product-management-mode.md)
**When to read:** Product discovery, strategy, requirements definition, or business decisions.

**Trigger phrases:** "Let's think about this as PMs", "I need product thinking on this", "Help me with discovery/strategy"

Product Operating Model, four big risks framework, PM mental models, and archetypes for product thinking.

### [technology-preferences.md](./technology-preferences.md)
**When to read:** Selecting frameworks, libraries, services, or making technology stack decisions.

Platform-specific technology preferences and selection criteria across the stack.

### [debugging-mindset.md](./debugging-mindset.md)
**When to read:** Working on a tricky bug, considering a workaround vs root-cause fix, or deciding when to ask for help.

Scientific debugging principles, what to do when stuck, and the practical reality check on shortcuts vs proper fixes.
