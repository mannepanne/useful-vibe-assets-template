# Environment & Secrets Setup

**When to read this:** Setting up local development, configuring secrets, or deploying to production.

**Related Documents:**
- [CLAUDE.md](./../CLAUDE.md) - Project navigation index
- [troubleshooting.md](./troubleshooting.md) - Common issues and solutions

---

**⚠️ TEMPLATE GUIDANCE** - Replace this file with your project-specific environment configuration. Use the structure below as a guide.

---

## Configuration overview

**Environment files used:**
- **Local development:** [e.g., `.dev.vars`, `.env.local`, etc. - specify which and why]
- **Production:** [e.g., Cloudflare Workers secrets, Vercel env vars, AWS Parameter Store, etc.]

**Security reminder:**
- Never commit secret files to git
- Add all secret files to `.gitignore`
- Use different credentials for development and production

---

## Required environment variables

### [SERVICE_1_API_KEY]
[Description of what this key is for]

**How to obtain:**
1. [Step 1: e.g., "Sign up at service.com"]
2. [Step 2: e.g., "Navigate to API settings"]
3. [Step 3: e.g., "Generate new API key"]

**Local setup:**
```bash
# Add to .dev.vars (or .env.local)
SERVICE_1_API_KEY=your_key_here
```

**Production setup:**
```bash
# Example for Cloudflare Workers
npx wrangler secret put SERVICE_1_API_KEY

# Example for Vercel
vercel env add SERVICE_1_API_KEY

# Example for generic env var
export SERVICE_1_API_KEY=your_key_here
```

**Permissions needed:** [e.g., "Read-only access to user data"]
**Cost:** [e.g., "Free tier: 1000 requests/month, Paid: $0.001/request"]

---

### [DATABASE_URL]
[Description of what this connects to]

**How to obtain:**
1. [Step 1: e.g., "Create project at supabase.com"]
2. [Step 2: e.g., "Navigate to project settings"]
3. [Step 3: e.g., "Copy connection string"]

**Local setup:**
```bash
# Add to .dev.vars
DATABASE_URL=postgresql://user:password@host:port/database
```

**Production setup:**
```bash
npx wrangler secret put DATABASE_URL
```

**Format:** `[connection string format and explanation]`
**Security:** [e.g., "Use SSL mode, rotate credentials quarterly"]

---

### [ADDITIONAL_VARIABLE]
[Continue pattern for each environment variable your project needs]

---

## Environment file templates

### `.dev.vars` Template
```bash
# Local development environment variables
# Copy this to .dev.vars and fill in your actual values

# Service 1
SERVICE_1_API_KEY=your_key_here

# Database
DATABASE_URL=your_connection_string_here

# Email (if applicable)
EMAIL_API_KEY=your_email_key_here
EMAIL_FROM=noreply@yourdomain.com

# Add other variables as needed
```

### `.env.local` Template (if using Next.js or similar)
```bash
# Next.js environment variables
# Copy this to .env.local and fill in your actual values

# Public variables (accessible in browser)
NEXT_PUBLIC_API_URL=http://localhost:3000

# Private variables (server-side only)
DATABASE_URL=your_connection_string_here
SERVICE_1_API_KEY=your_key_here
```

---

## Third-party service setup

### [Service Name 1]
**Purpose:** [What this service does for your project]
**Website:** [URL]
**Documentation:** [Docs URL]

**Setup steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Configuration:**
- [Config item 1]
- [Config item 2]

**Testing connection:**
```bash
# Command to verify service is working
[test command here]
```

---

### [Service Name 2]
[Repeat pattern for each third-party service]

---

## Local development setup

### First-time setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Create environment file**
   ```bash
   cp .dev.vars.template .dev.vars
   # Edit .dev.vars and add your actual values
   ```

3. **Verify configuration**
   ```bash
   npm run dev
   # Check that services connect successfully
   ```

### Updating environment variables

**When you add a new variable:**
1. Update this documentation
2. Update `.dev.vars.template`
3. Add to production environment (Cloudflare/Vercel/etc.)
4. Notify team members to update their local `.dev.vars`

---

## Production deployment

### Environment variables checklist

Before deploying, ensure all required variables are set:

- [ ] [SERVICE_1_API_KEY]
- [ ] [DATABASE_URL]
- [ ] [ADDITIONAL_VARIABLE]
- [ ] [Add all your variables to this checklist]

### Deployment commands

**Cloudflare Workers:**
```bash
# List current secrets
npx wrangler secret list

# Add/update secret
npx wrangler secret put VARIABLE_NAME

# Deploy
npm run deploy
```

**Vercel:**
```bash
# Add environment variable
vercel env add VARIABLE_NAME production

# Deploy
vercel --prod
```

**[Your platform]:**
```bash
# Platform-specific commands
```

---

## Security best practices

### Development
- Use separate API keys for development and production
- Never log or expose secret values
- Rotate development credentials regularly

### Production
- Use environment-specific credentials
- Enable IP restrictions where possible
- Monitor API usage for anomalies
- Rotate credentials quarterly or when team members leave
- Use secret management services (e.g., AWS Secrets Manager, HashiCorp Vault)

### Git Safety
- Double-check `.gitignore` includes all secret files
- Use pre-commit hooks to prevent accidental secret commits
- If secrets are committed, rotate immediately and clean git history

---

## Troubleshooting

### "Environment variable not found"
- Verify variable name matches exactly (case-sensitive)
- Restart dev server after changing `.dev.vars`
- Check variable is actually set: `echo $VARIABLE_NAME`

### "Invalid API key" errors
- Verify key is copied correctly (no extra spaces)
- Check key hasn't expired
- Verify key has required permissions
- Try regenerating key

### "Connection refused" errors
- Check service URLs are correct
- Verify network connectivity
- Check if service is down (status page)
- Verify firewall/security group settings

---

## Environment variable reference

Quick reference table of all variables:

| Variable Name | Required | Default | Description |
|---------------|----------|---------|-------------|
| SERVICE_1_API_KEY | Yes | - | API key for Service 1 |
| DATABASE_URL | Yes | - | Database connection string |
| ADDITIONAL_VAR | No | `default_value` | Description |
| [Add all vars] | - | - | - |

---

**Remember to update this document** whenever you add, remove, or change environment variables!
