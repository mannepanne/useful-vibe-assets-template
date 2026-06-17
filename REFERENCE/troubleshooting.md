# Troubleshooting Guide

**When to read this:** Debugging issues, fixing deployment problems, or resolving integration errors.

**Related Documents:**
- [CLAUDE.md](../CLAUDE.md) - Project navigation index
- [environment-setup.md](./environment-setup.md) - Environment and secrets configuration

---

**⚠️ TEMPLATE GUIDANCE** - This file starts with generic troubleshooting patterns. Add your project-specific issues as you encounter them.

---

## Local development issues

### Port already in use
```bash
# Kill existing dev server (adjust process name as needed)
pkill -f next       # For Next.js
pkill -f wrangler   # For Wrangler
pkill -f django     # For Django
pkill -f flask      # For Flask
pkill -f node       # Generic Node process

# Or find and kill specific port
lsof -ti:3000 | xargs kill -9  # Replace 3000 with your port
```

### TypeScript errors
```bash
# Run type checking
npx tsc --noEmit

# Clear TypeScript cache if issues persist
rm -rf node_modules/.cache
npx tsc --noEmit
```

### Environment variables not loading
- Check `.dev.vars` (or `.env.local`) exists and has correct format
- Restart dev server after changing environment files
- Verify variable names match exactly (case-sensitive)
- Check for extra spaces or quotes in values
- Confirm environment file is in correct location
- For framework-specific variables (e.g., `NEXT_PUBLIC_`), check naming conventions

### Dependency issues
```bash
# Clear and reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Or use yarn/pnpm
rm -rf node_modules yarn.lock
yarn install

# Check for version conflicts
npm list [package-name]
```

### Database connection issues
- Verify database URL and credentials in environment file
- Check database service is running (local or cloud)
- For cloud databases, check if service is paused (common with free tiers)
- Verify network connectivity and firewall rules
- Test connection with database client directly
- Check connection pool limits

### Cache issues
```bash
# Clear various caches
rm -rf .next                    # Next.js
rm -rf .cache                   # General cache
rm -rf dist                     # Build output
rm -rf .wrangler                # Wrangler
npm run clean                   # If you have a clean script

# Clear browser cache for local development
# Use browser DevTools → Application → Clear storage
```

---

## Build and deployment issues

### Build failures

**General debugging:**
```bash
# Run build with verbose output
npm run build -- --verbose

# Check for build errors in specific files
# Look for import errors, missing dependencies, etc.
```

**Common causes:**
- Missing dependencies in `package.json`
- Environment variables not set in build environment
- TypeScript errors (run `npx tsc --noEmit` first)
- Import path errors (case sensitivity on Linux vs macOS)
- Unsupported Node.js APIs in edge/serverless environments

### Platform-specific build issues

**Cloudflare Workers / Next.js on Edge:**
- Check Next.js version compatibility (14+)
- Verify all dependencies support edge runtime
- Review build output for unsupported APIs (e.g., `fs`, `path`)
- Use dynamic imports for server-only code

**Vercel:**
- Check build logs in Vercel dashboard
- Verify Node.js version matches locally
- Check build command matches `package.json` scripts

**[Your deployment platform]:**
- [Platform-specific troubleshooting steps]

### Deployment authentication errors
```bash
# Cloudflare
npx wrangler login
npx wrangler whoami

# Vercel
vercel login
vercel whoami

# [Your platform]
# [Platform-specific commands]
```

### Production environment variables not set
```bash
# Cloudflare Workers
npx wrangler secret list          # Check configured secrets
npx wrangler secret put VAR_NAME  # Add missing secrets
npx wrangler secret delete VAR_NAME  # Remove old secrets

# Vercel
vercel env ls                     # List variables
vercel env add VAR_NAME           # Add variable
vercel env rm VAR_NAME            # Remove variable

# [Your platform]
# [Platform-specific commands]
```

---

## API integration issues

### Generic API troubleshooting

**Connection issues:**
- Verify API endpoint URL is correct
- Check API key/token is valid and not expired
- Verify API key has required permissions
- Check network connectivity
- Verify SSL/TLS certificates (for HTTPS)
- Check if API service is down (status page)

**Authentication failures:**
- Confirm API key is copied correctly (no extra spaces)
- Check key format matches API requirements
- Verify headers are set correctly (`Authorization`, `Content-Type`, etc.)
- For OAuth, check token hasn't expired and refresh if needed

**Rate limiting:**
- Check response headers for rate limit info
- Implement exponential backoff for retries
- Monitor API usage in service dashboard
- Consider upgrading plan if consistently hitting limits

**Response parsing errors:**
- Log full response to inspect structure
- Check for API version changes
- Verify Content-Type header
- Handle both success and error response formats

### [Service Name 1] API

**Common issues:**
- [Specific issue 1 and solution]
- [Specific issue 2 and solution]

**Debugging:**
```bash
# Test API connection directly
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.service.com/endpoint
```

**Useful links:**
- Status page: [URL]
- API documentation: [URL]
- Community forum: [URL]

### [Service Name 2] API

[Add project-specific API troubleshooting as you encounter issues]

---

## Testing issues

### Tests failing locally
```bash
# Run tests with verbose output
npm test -- --verbose

# Run specific test file
npm test -- path/to/test.test.ts

# Run tests in watch mode for debugging
npm run test:watch
```

**Common causes:**
- Missing test data or fixtures
- Environment variables not set for tests
- Mocking not configured correctly
- Async/await timing issues
- Database not seeded for integration tests

### Tests passing locally but failing in CI
- Check Node.js version matches CI environment
- Verify environment variables are set in CI
- Check for timezone differences
- Look for race conditions in parallel test execution
- Verify test database is properly seeded in CI

### Coverage not meeting targets
```bash
# Generate detailed coverage report
npm run test:coverage

# Open HTML report
open coverage/index.html
```

**Strategies:**
- Add unit tests for uncovered functions
- Test error/edge cases
- Add integration tests for complex flows
- Check if unreachable code can be removed

---

## Performance issues

### Slow local development
- Check for file watching issues (too many files)
- Verify SSD is not full (can slow down builds)
- Disable unnecessary browser extensions
- Close unused applications
- Check for circular dependencies
- Review bundler configuration

### Slow API responses
- Add logging to identify bottlenecks
- Check for N+1 query problems
- Review database indexes
- Consider caching frequently accessed data
- Profile API endpoints with timing logs

### Large bundle sizes
```bash
# Analyse bundle size
npm run build
# Check output for large dependencies

# Next.js specific
npm run build -- --analyse

# Webpack bundle analyser (if using webpack)
npx webpack-bundle-analyser dist/stats.json
```

**Optimization strategies:**
- Code split large dependencies
- Use dynamic imports for heavy components
- Remove unused dependencies
- Use lighter alternatives for large libraries

---

## Git and version control issues

### Merge conflicts
```bash
# See conflicted files
git status

# For each conflicted file:
# 1. Open file and resolve <<< === >>> markers
# 2. Stage resolved file
git add path/to/resolved/file

# Complete merge
git commit
```

### Accidentally committed secrets
1. **Immediately rotate credentials** (critical!)
2. Remove from git history:
```bash
# Remove file from all commits
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret/file" \
  --prune-empty --tag-name-filter cat -- --all

# Or use git-filter-repo (recommended)
git filter-repo --path path/to/secret/file --invert-paths

# Force push (coordinate with team first!)
git push origin --force --all
```
3. Update `.gitignore` to prevent recurrence

### Large files causing issues
```bash
# Remove large file from history
git filter-repo --path path/to/large/file --invert-paths

# Add to .gitignore
echo "path/to/large/files/" >> .gitignore
```

---

## Database issues

### Migration failures
```bash
# Check migration status
[your migration status command]

# Rollback last migration
[your rollback command]

# Re-run migration
[your migration command]
```

### Connection pool exhausted
- Verify connections are properly closed
- Check for long-running queries
- Review connection pool configuration
- Monitor active connections
- Consider increasing pool size if needed

### Schema out of sync
- Run pending migrations
- Verify migration files are in correct order
- Check if manual schema changes were made
- Consider resetting local database if dev environment

---

## Browser/client issues

### JavaScript not loading
- Check browser console for errors
- Verify build completed successfully
- Clear browser cache
- Check Content Security Policy headers
- Verify correct script paths in HTML

### CORS errors
```javascript
// Backend needs appropriate CORS headers
res.setHeader('Access-Control-Allow-Origin', 'https://yourdomain.com');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
```

### Authentication/session issues
- Clear browser cookies
- Check session storage/localStorage
- Verify token expiration handling
- Check for HTTPS requirement in production
- Review SameSite cookie attributes

---

## When all else fails

### Systematic debugging approach
1. **Isolate the problem**
   - Can you reproduce it consistently?
   - Does it happen in a fresh environment?
   - What's the minimal reproduction case?

2. **Gather information**
   - Check error messages carefully
   - Review logs (application, server, browser console)
   - Check recent changes (git diff, git log)
   - Search error messages online

3. **Form hypotheses**
   - What could cause this behavior?
   - What changed recently?
   - Are there similar reported issues?

4. **Test systematically**
   - Change one thing at a time
   - Document what you try
   - Verify each change

5. **Ask for help**
   - Prepare clear reproduction steps
   - Show what you've already tried
   - Share relevant error messages and logs
   - Provide system/environment details

### Useful debugging commands
```bash
# Check versions
node --version
npm --version
git --version

# System info
uname -a              # OS info (Unix/Linux/macOS)
systeminfo            # System info (Windows)

# Network debugging
ping api.example.com  # Test connectivity
nslookup api.example.com  # DNS lookup
curl -I https://api.example.com  # Test HTTP connection

# Process debugging
ps aux | grep node    # Find Node processes
lsof -i :3000         # See what's using port 3000
```

---

## Project-specific issues

[Add issues specific to your project as you encounter them]

### [Issue Category]

**Symptoms:**
- [What you observe]

**Cause:**
- [Why it happens]

**Solution:**
- [How to fix it]

---

**Remember:** Update this document whenever you encounter and solve a new issue. Your future self (and team) will thank you!
