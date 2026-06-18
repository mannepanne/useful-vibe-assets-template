---
name: setup-profile
description: Guide user through personal profile setup process. Creates a personalized profile file for better context and guidance.
user-invocable: true
---

# Profile Setup Guide

This skill guides you through creating your personal profile for this template. A personalized profile helps the AI understand your preferences, expertise, and project context, leading to better guidance and recommendations.

---

## Instructions for Vibe

### Step 0: Check if already set up

Before starting, check if setup is already complete:

1. If `.vibe/COLLABORATION/personal-profile.local.md` exists:
   - Inform user: "You already have a personal profile set up at `.vibe/COLLABORATION/personal-profile.local.md`."
   - Ask: "Would you like to review and update it, or are you all set?"
   - If they want to update: continue to Step 1
   - If they're all set: exit with "✅ Your profile is ready to use!"

2. If `.vibe/COLLABORATION/personal-profile.md` does NOT contain `<!-- profile_status: default -->`:
   - Inform user: "It looks like you've already customized your profile."
   - Exit with "✅ Your profile is ready to use!"

### Step 1: Introduce the concept

Explain to the user:

> "Personal profiles help me provide better context and guidance tailored to your specific situation. The template comes with a default profile that we'll customize with your information. This file is gitignored, so your personal details won't be committed to version control."

### Step 2: Check for source files

Check if the required files exist:

- `.vibe/COLLABORATION/personal-profile.md` (template)
- If it doesn't exist: 
  - Warn: "The template profile file is missing. You may need to restore it from the template repository."
  - Offer to create a basic one

### Step 3: Guide through customization

Walk the user through the process:

1. **Read the template**:
   - Read `.vibe/COLLABORATION/personal-profile.md`
   - Explain: "This is the template profile with placeholders. We'll customize it for you."

2. **Identify placeholders**:
   - Look for placeholders like `{{NAME}}`, `{{ROLE}}`, `{{EXPERTISE}}`, etc.
   - Or look for commented instructions like `<!-- Replace this with your actual name -->`

3. **Ask for information**:
   
   Ask the user to provide the following information (use their responses to populate the file):
   
   **Required fields:**
   - Your name
   - Your primary role/title (e.g., "Software Engineer", "Product Manager", "Tech Lead")
   - Your areas of expertise (e.g., "TypeScript, React, Node.js, Cloudflare Workers")
   - Your experience level (e.g., "Senior", "Mid-level", "Junior")
   
   **Optional but recommended:**
   - Preferred coding style or conventions
   - Focus areas or interests
   - Any specific tools or frameworks you regularly use
   - Team or company context (if applicable)
   - Any special considerations or constraints you work under

4. **Create the profile**:
   - Copy the content from `.vibe/COLLABORATION/personal-profile.md`
   - Replace all placeholders with the user's actual information
   - Add a header comment: `<!-- profile_status: custom -->`
   - Write the customized content to `.vibe/COLLABORATION/personal-profile.local.md`

### Step 4: Verify the file

After creating the file:

1. Read the first few lines of `.vibe/COLLABORATION/personal-profile.local.md`
2. Confirm it has the custom status marker
3. Confirm it contains the user's actual information
4. Inform: "✅ Your personal profile has been created successfully!"

### Step 5: Explain next steps

Tell the user:

> "Your profile is now set up! Here's what this means:
> - I'll use this information to provide more tailored guidance
> - You can edit the file anytime to update your information
> - The file is gitignored, so your personal info stays private
> - Run `/check-profile-setup` anytime to verify your setup"

---

## Profile Template Structure

A typical `personal-profile.md` contains:

```markdown
<!-- profile_status: custom -->

# [Your Name]'s Profile

## Basic Information
- **Name**: [Your Name]
- **Role**: [Your Role]
- **Experience**: [Your Experience Level]

## Expertise
- **Primary**: [Your primary technologies/skills]
- **Secondary**: [Your secondary technologies/skills]

## Preferences
- **Coding Style**: [Your preferred style]
- **Review Depth**: [How thorough you want reviews to be]
- **Focus Areas**: [What you want me to pay special attention to]

## Context
- **Team**: [Your team name, if applicable]
- **Company**: [Your company, if applicable]
- **Current Project**: [What you're working on]
```

---

## Vibe-Specific Notes

This skill complements `/check-profile-setup` by providing the guided setup experience.

### Relationship to Claude Code

- **Claude Code**: Had a SessionStart hook that would prompt for setup
- **Vibe**: Uses explicit skills that users invoke when needed

### Integration

This skill can be called from other skills:

```
skill: {"name": "setup-profile"}
```

Or users can invoke it directly:

```
/setup-profile
```

---

## Example Usage

```
/setup-profile
```

This will guide you through creating your personal profile with interactive questions and explanations.
