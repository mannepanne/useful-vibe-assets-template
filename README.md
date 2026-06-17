# Project template for AI-Assisted development

My (Magnus Hultberg) battle-tested project template for working with AI coding assistants, refined over 12-18 months of AI-assisted development using Claude Code.

## What is this

This template encapsulates patterns and workflows that have worked well for me when building software with AI assistants like Claude Code. It's opinionated, practical, and designed to minimise friction while maximising collaboration quality and consistency of output over time.

## Core principles

**Lifecycle-based documentation** - Documents move through clear stages (SPECIFICATIONS → REFERENCE → ARCHIVE), keeping active context minimal and focused.

**Tests as guardrails** - Tests serve dual purposes: validation as well as directional context for AI driven changes and refinements. They guide how to evolve a build, not just verify it works.

**Token efficiency** - CLAUDE.md files act as "library indexes" that lazy-load context only when needed. My assumption is that this makes token usage more efficient, and leads to better results.

**Collaboration framework** - Clear behavioral guidelines for working with AI (directness over politeness, evidence-based pushback, systematic decision-making). Collaboration mode support for "product management" style work as well as software development.

**Systematic over ad-hoc** - Consistent patterns (PR reviews, phased implementation structure, testing strategy) that compound over time.

## What's inside

```
.claude/                    # AI collaboration config (auto-loads)
├── COLLABORATION/          # Behavioral guidance, PM mode, tech preferences
├── skills/                 # Automated PR review workflows
└── project-config.json     # Per-project feature flags (e.g. prReviewMode)

SPECIFICATIONS/             # What are we building
├── ORIGINAL_IDEA/         # Initial project vision
└── ARCHIVE/               # Completed phase specs

REFERENCE/                  # How implemented features work
├── testing-strategy.md
├── environment-setup.md
└── troubleshooting.md
```

**Automated reviews are opt-in.** The first time you invoke `/review-pr`, `/review-pr-team`, or `/review-spec` (or the first review-adjacent moment in conversation with Claude), you'll be asked whether to enable the review system for this project. Your answer persists in `.claude/project-config.json`. For throwaway experiments where reviews are overkill, answer `no` once — all `/review-*` skills become no-ops. You can change your mind later by editing the file.

## If you want to try using this as a template

1. **Use this template** (click "Use this template" button on GitHub) or download the zip and rename the folder
2. **Open Claude in the folder and have a conversation about your project** — the template is designed to be customised through chat, not by editing files yourself
3. **Let Claude de-templatify the docs** based on what you discussed
4. **Start building** — break the project into phases, work systematically, one PR at a time

Full walkthrough (with example prompts) in [TEMPLATE-INSTRUCTIONS.md](./TEMPLATE-INSTRUCTIONS.md). It's short — and aimed at non-technical users too.

## Why did I end up here...

After 12-18 months of LLM-assisted coding, a few things became clear:

- **AI assistants are coworkers, not servants** - Best results come from treating them as collaborators with domain expertise
- **Documentation is leverage** - Good docs enable both AI and humans to pick up work quickly, context matters
- **Tests guide better than specs alone** - Especially with AI, detailed specifications and ways of working mitigate drift
- **Simple beats clever** - Patterns that are easy to explain work better than complex optimization
- **Consistency compounds** - Using the same structure across projects builds muscle memory (yours and the AI's)

## Technology defaults

These are my preferences that I tend to reuse for all projects I dive into. YMMV, so if you try this template you should carefully review this section and make it yours.

TypeScript, Next.js, Cloudflare Workers, Supabase, Vitest - but easily customizable. See `.claude/COLLABORATION/technology-preferences.md` for rationale.

## Credits

Collaboration patterns inspired by [@obra](https://github.com/obra), [@harperreed](https://github.com/harperreed), [OpenAI's Harness Engineering](https://openai.com/index/harness-engineering/), and [steipete/agent-rules](https://github.com/steipete/agent-rules).

## License

MIT - Use freely, adapt as needed, share improvements.

---

**Ready to start?** Read [TEMPLATE-INSTRUCTIONS.md](./TEMPLATE-INSTRUCTIONS.md) to get going — it's short and aimed at non-technical users too.
