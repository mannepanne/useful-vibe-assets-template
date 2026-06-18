# Getting started with this template

Welcome! This template is designed to be driven through **conversation with Mistral Vibe**, not by editing a pile of files yourself. If you've never used a template like this before, that's the whole point — you describe your project, Vibe does the work.

You don't need to be technical. You need an idea and a willingness to chat about it.

---

## A note before you start

**The template will introduce itself.** The first time you open Vibe in this project, read the AGENTS.md files for collaboration guidance. **Vibe note**: Unlike Claude's automatic profile setup hook, Vibe requires explicit invocation or first-use detection in skills. If you'd rather skip setup and keep the default profile as-is, just say so when Vibe asks.

**Heads-up:** the template ships with an automated PR review system that's opt-in. In Vibe, the first time you invoke a review skill, you'll be asked whether to enable it for this project — yes / no / later. It's optional and you can change your mind later by editing `.vibe/config/project-config.json`.

---

## The services this template recommends

This template is opinionated about technology. Vibe follows a set of defaults chosen for cost, quality, and developer experience. The key services:

| What for | Recommended |
|---|---|
| Hosting & edge | [Cloudflare](https://cloudflare.com) (Workers, KV, D1, R2) |
| Database | [Cloudflare D1](https://developers.cloudflare.com/d1/) or [Supabase](https://supabase.com) |
| Email | Cloudflare Email Sending (or [Resend](https://resend.com) as fallback) |
| Payments | [Stripe](https://stripe.com) |
| Frontend | Next.js (React) |

Not every project needs all of these — only the ones your project actually uses. Most have generous free tiers.

**You'll need accounts on the relevant services before you can deploy.** Vibe will identify which ones apply when it writes your project spec — that's the right moment to sign up if you haven't already.

If you'd rather use different services, say so during the project conversation. The defaults are a strong starting point, not a requirement.

---

## The shape of things to come

If you get lost, this is the basic outline:

1. Unzip the template and rename the folder to your project name.
2. Drop any existing notes, design files, or sketches into `SPECIFICATIONS/ORIGINAL_IDEA/` or `REFERENCE/`.
3. Open Vibe in the project folder and have a conversation about your project.
4. Ask Vibe to update all the templated docs based on what you discussed.
5. Start building, one phase at a time, with a PR for every change.

Everything below is a more detailed version of those five steps, plus example prompts you can copy.

---

## Step 1 — Get the template onto your machine

1. Download the zipped template from GitHub.
2. Unzip it somewhere sensible (e.g. `~/Documents/Coding/`).
3. Rename the folder from `useful-assets-template` to whatever your project is called.
4. Drop any pre-existing material into the right folder:
   - **Project ideas, briefs, vision docs, naming notes** → `SPECIFICATIONS/ORIGINAL_IDEA/`
   - **Design files, diagrams, research, reference material** → `REFERENCE/`
   - Don't worry about format — Vibe can read most things.

That's it for manual file work. From here on, talk to Vibe.

---

## Step 2 — Have the orientation conversation

Open a terminal in your new project folder and start Vibe:

```bash
vibe
```

Then open with something like one of these:

> *"Take a look around this repo and tell me what you see, and what you think this is. Then let's have a chat about the project I want to build."*

> *"I've dropped some notes into ORIGINAL_IDEA. Have a read, then ask me whatever you need to understand the project."*

> *"I have a vague idea — I want to build [your idea in one sentence]. Help me think through what it should actually be."*

What happens next: Vibe will look around, read your notes if you dropped any in, and start asking questions. Answer them honestly, push back when something doesn't feel right, and let the conversation refine the idea. Don't worry about being precise — that's what the conversation is for.

When you've talked enough to feel like the shape is clear, say:

> *"Great. Now write that up as `project-outline.md` in `SPECIFICATIONS/ORIGINAL_IDEA/` so we have a source of truth."*

There's a stub at `SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md` that Vibe can fill in.

---

## Step 3 — Let Vibe de-templatify the docs

The template ships with a lot of placeholder content (root `AGENTS.md`, `SPECIFICATIONS/AGENTS.md`, the `REFERENCE/` files, etc.). Once Vibe understands your project, ask it to update them all:

> *"Now go through all the project documentation — `AGENTS.md`, `SPECIFICATIONS/AGENTS.md`, the files in `REFERENCE/`, and anywhere else with template warnings or `[PLACEHOLDER]` text — and update them to fit this project. Show me what you're changing as you go."*

You don't need to know which files those are. Vibe will find them. Review the changes, push back where something looks off, and commit when you're happy.

---

## Step 4 — Plan the build, then build it

Once the docs reflect your project, ask Vibe to break the work into phases:

> *"Let's break this project into 4–6 sequential implementation phases. Use `SPECIFICATIONS/00-TEMPLATE-phase.md` as the structure. Each phase should deliver something working and testable."*

A typical first phase is "foundation" — basic setup, deployment scaffolding, the smallest possible thing that runs. The last phase is usually "polish and launch."

Then start Phase 1:

> *"Let's start Phase 1. Read the spec, create a todo list, and walk me through what you're going to do before you write any code."*

---

## The rhythm of building

A few habits that make the template work well:

**Every change goes through a feature branch and a PR.** Vibe knows this and will create branches for you. If it ever forgets and starts editing on `main`, just say "you're on main, please branch first."

**Use the review skills.** When you've built something:

- `/review-pr` — for most things. It looks at the change and decides how thorough to be.
- `/review-pr-team` — when you know it's a big or risky change.
- `/review-spec` — *before* writing code, for non-trivial features. Catches wrong assumptions early.

**Let Vibe check the docs occasionally.** As the project grows, the template docs and the reality of the code can drift apart. Vibe is set up to offer a documentation refresh at natural breakpoints (end of a phase, after a few PRs) — when it asks, say yes. It's cheap and keeps everything coherent. You can also just ask any time:

> *"Have a look at all the project docs and tell me what's out of date or inconsistent with the code."*

---

## Try saying things like…

A handful of prompts for common moments:

| Moment | Try saying |
|---|---|
| Stuck on what to do next | *"What's the most useful thing for us to do next?"* |
| Want a sanity check on an idea | *"Be honest — is this a good idea, or am I overcomplicating it?"* |
| Something feels off | *"This doesn't feel right. Walk me through what you just did and why."* |
| Want to slow down and plan | *"Don't write code yet. Let's just talk through the approach."* |
| Want to speed up | *"Just go ahead and do it — I'll review the PR."* |
| Need to remember something later | *"Remember that [fact / preference / constraint]."* |
| Documentation might be stale | *"Do a quick sweep of the docs and tell me what's drifted."* |

You can't really break anything by asking. If a prompt didn't produce the result you wanted, revert it (using git reset or by going back to a previous commit), then tell Vibe what you actually meant.

---

## What Vibe will touch on your behalf

For the curious — here's roughly what gets customised during the orientation conversation. You don't need to do any of this yourself.

- **Root `AGENTS.md`** — project name, description, stack, current phase
- **`SPECIFICATIONS/AGENTS.md`** — your actual phase list
- **`SPECIFICATIONS/ORIGINAL_IDEA/project-outline.md`** — your vision and scope
- **`SPECIFICATIONS/01-…`, `02-…` etc.** — phase-by-phase plans
- **`REFERENCE/environment-setup.md`** — your env vars and credentials
- **`REFERENCE/testing-strategy.md`** — adjusted for your test framework
- **`.gitignore`** — adjusted for your stack
- **`.dev.vars.template`** (or equivalent) — created by Vibe once your stack and env-var needs are clear
- **This file** — Vibe will offer to delete or archive it once you're up and running

---

## When something goes wrong

**"Vibe is doing something I didn't expect."** Stop it (Esc or Ctrl+C) and explain what you wanted instead. It won't take offence.

**"I don't know what to ask."** Say exactly that: *"I don't know what to do next — what should I be thinking about?"*

**"The conversation has gone in circles."** Ask Vibe to summarise the decisions made so far and what's still open. Often that re-anchors things.

**"I want to start over with a section."** Just say so. Files are in git; nothing is permanent. You can always go back to a previous commit. You did do regular commits, right? ;)

**"I want a real human."** Fair. The template's source repo has a README with contact info, or ask Vibe to point you at the right help.

---

**That's it.** Don't try to read this whole repo before starting — open Vibe, drop in your notes, and start talking. The rest will fall into place.
