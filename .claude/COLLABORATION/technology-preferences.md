# Technology Stack and Choices

**When to read this:** Selecting frameworks, libraries, services, or making technology stack decisions.

**Related Documents:**
- [CLAUDE.md](./../../CLAUDE.md) - Project navigation index
- [CLAUDE.md](./../CLAUDE.md) - Collaboration principles

---

Reference guide for selecting technologies across projects.

## General preferences

- Free or low cost solutions are always preferred
- We prefer state-of-the-art solutions, but avoid experimental code or beta versions (unless nothing else is available)
- Never use outdated or deprecated solutions
- If a suitable technology doesn't seem to be available, recommend running a deep research task first to understand the topic better and find potential alternatives
- For any selected framework, library, third party component, API or other service, read the manual to ensure you use the latest stable version and follow best practice usage and patterns

## Platform-specific preferences

| Use Case | Preferred Technology | Reason |
| --- | --- | --- |
| CLI/Headless projects | Python | Simplicity and extensive standard library |
| Web application projects | TypeScript (strict mode) | Industry standard type safety |
| Web APIs and backend services | [Hono.js](https://hono.dev/) on Cloudflare Workers | Lightweight, edge-native, excellent TypeScript support — ideal for APIs and Worker-first services |
| Web frontend / full-stack | Next.js (React) with App Router | Full-stack framework for consumer-facing products needing SSR, SEO, and a strong ecosystem |
| Web frontend design | Tailwind CSS with shadcn/ui | Utility-first styling with a solid accessible component library |
| Hosting | Cloudflare Workers | Global edge network, generous free tier; all services stay on one platform |
| Key-value storage / sessions / config | Cloudflare KV | Fast global reads; ideal for caching, feature flags, and session state |
| SQL / relational data | Cloudflare D1 or Supabase for complex needs | D1 (SQLite-based, native Workers binding) for most cases; Supabase when relational depth, row-level security, or realtime subscriptions are needed |
| Object / blob storage | Cloudflare R2 | Files, documents, media — S3-compatible, no egress fees |
| Image hosting with transforms | Cloudflare Images | Resizing, optimisation, and global delivery built in |
| Stateful coordination / real-time | Cloudflare Durable Objects | Per-instance persistent state — rate limiting, presence, real-time counters, leader election |
| Email | Cloudflare Email Sending (Beta), or Resend as fallback | Cloudflare's first-party transactional email — native Workers bindings, built-in DNS auth (SPF/DKIM/DMARC), 1,000 emails/day on paid Workers plan. Resend is the clean fallback with excellent developer experience |
| Authentication | Magic links (or Cloudflare Zero Trust for internal tools) | No password management; simple and secure for most use cases |
| Payment processing | Stripe | Industry standard with excellent developer experience and global coverage |
| Web analytics | Cloudflare Web Analytics | Privacy-focused, cookie-free — no consent banner required |

## Security and launch auditing tools

These are not stack components — they are validation tools to run at key project milestones (pre-launch, post-deploy, and periodically in production). Treat them as required checklist items, not optional extras.

| Tool | Purpose | When to use |
| --- | --- | --- |
| [securityheaders.com](https://securityheaders.com/) | Scans a live URL and grades the HTTP security headers your server sends (Content-Security-Policy, Strict-Transport-Security, X-Frame-Options, Referrer-Policy, Permissions-Policy, etc.) on an A+ to F scale | Before launch (on staging), immediately after first production deploy, and after any significant infrastructure or middleware change. Aim for A grade minimum; A+ where feasible. If the score is below B, do not consider the project production-ready |
