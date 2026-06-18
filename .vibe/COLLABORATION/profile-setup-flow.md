# Profile setup flow

Instructions for Vibe on first project use. Unlike Claude's hook-based system, Vibe requires explicit invocation or first-use detection in skills.

---

## When this runs

**Vibe model**: There is no SessionStart hook. This flow should be triggered by:
1. Explicit user invocation of a setup skill
2. First-use detection in any skill (checking for personal-profile.local.md existence)
3. User reading AGENTS.md files that reference this flow

The check is: if `personal-profile.local.md` does not exist and `.vibe/COLLABORATION/personal-profile.md` still contains the `<!-- profile_status: default -->` sentinel, the project hasn't been personalised yet.

---

## The flow

### Step 1: Check intent

Open with:

> "This project is using the default collaboration profile — it hasn't been personalised for you yet. If it already describes how you work, just say so and I'll set it up as-is. Otherwise, a few quick questions and we'll make it yours."

### Step 2a: Keep as-is

If they say they want to keep it (e.g. "keep it", "that's fine", "I'm Magnus"):
- Create `.vibe/COLLABORATION/personal-profile.local.md` as a copy of `.vibe/COLLABORATION/personal-profile.md`, with the `<!-- profile_status: default -->` sentinel line removed
- Tell them: "Done — your profile is saved to `personal-profile.local.md`, which is gitignored and private by default."
- Skip to Step 5

### Step 2b: Personalise

Ask four questions one at a time — wait for the answer before asking the next:

1. *"What's your name, and how would you like me to address you?"*
2. *"What's your background? I calibrate how I explain things based on this — whether you're a developer, designer, non-technical founder, or something else entirely."*
3. *"How direct should I be? Think bluntness: should I call out bad ideas plainly, or soften the edges?"*
4. *"How technical should my explanations be? Think: whether to use ELI5 analogies or go deep on the details. And is occasional humour welcome?"*

If they mention product work, add:

5. *"One more — when we're in product-thinking mode (strategy, discovery, requirements), how do you see yourself? Technical PM, domain expert, generalist, something else?"*

### Step 3: Write the profile

Create `.vibe/COLLABORATION/personal-profile.local.md` based on their answers:
- Keep the same section structure (Identity, Background and role, Communication style)
- Add a PM profile section only if they mentioned product work (question 5)
- Write in first person from the operator's perspective, matching the style of the default profile
- Do NOT include the `<!-- profile_status: default -->` sentinel

### Step 4: Confirm privacy

Tell them:

> "Your profile is saved to `personal-profile.local.md`, which is gitignored — it won't be committed to the repo. If you'd like it checked in (for example, for a team setup where others should see your preferences), just say so and I can move it."

### Step 5: Guide to the next step

> "You're all set. Here's how this works: we'll have a conversation about your project, then I'll write it up as `project-outline.md` in `SPECIFICATIONS/ORIGINAL_IDEA/` — a starting point we'll use to build out a full specification before any code gets written."
>
> "Before we dive in: if you have anything written already — notes, a brief, mockups, sketches, a rough doc — drop it into the `SPECIFICATIONS/ORIGINAL_IDEA/` folder now. It'll become part of the input and save us from covering ground you've already mapped out."
>
> "Ready when you are. Tell me about the project."

---

## Vibe-Specific Notes

### Trigger Mechanism

**Claude**: Automatic via SessionStart hook
**Vibe**: Manual invocation or first-use detection

Options for triggering in Vibe:
1. **Explicit setup skill**: User invokes `/setup` or similar on first use
2. **First-use in any skill**: Skills check for profile existence before proceeding
3. **AGENTS.md instruction**: Strong instructions in auto-loaded AGENTS.md files

### Path Changes

All paths updated from `.claude/COLLABORATION/` to `.vibe/COLLABORATION/`.

### Profile Status

The `<!-- profile_status: default -->` sentinel is still used for detection, but instead of a hook checking it, Vibe skills must explicitly check for it.
