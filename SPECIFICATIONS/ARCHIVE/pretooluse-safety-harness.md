# Spec: PreToolUse safety-harness hook

**Status:** Implemented. Hook script is live; how-it-works documentation is at [`REFERENCE/safety-harness.md`](../../REFERENCE/safety-harness.md). This file is the implementation history.
**Type:** Template tooling (not a derivative-project phase)

---

## Purpose

Add a `PreToolUse` hook in `.claude/settings.json` that intercepts dangerous bash commands before they execute. The hook acts as a safety net against honest mistakes — fat-finger typos, AI agents reaching for a destructive shortcut, commands that look fine in isolation but are catastrophic in context — by blocking irreversible operations against high-value targets and prompting for confirmation on ambiguous-but-destructive operations. The educational signal for less-experienced users rides on the ask-tier confirmation prompt; the originally-drafted warn tier was dropped during implementation (see *Implementation findings* below).

This is **distinct from the allowlist**. The allowlist exists to silence UX friction on safe operations (auto-allow `git status`, `gh pr diff`, etc.). The safety harness is the inverse: catch dangerous operations *regardless* of whether they would have been silently allowed. Allowlist = ergonomics; safety harness = guardrail.

## Threat model alignment

This spec inherits the threat model from [`REFERENCE/decisions/2026-04-25-pr-review-threat-model.md`](../../REFERENCE/decisions/2026-04-25-pr-review-threat-model.md), and is calibrated specifically against the **less-experienced-user sub-case** introduced in that ADR's *Sub-cases within in-scope* section. The PR review system is calibrated for the experienced-user sub-case (silent execution on safe ops); the safety harness is calibrated for the less-experienced-user sub-case (catch dangerous ops, prompt on ambiguous ones).

The harness is sized for **honest mistakes**, not malicious actors. The contributor already trusts Claude Code with bash access; the hook is not a defence against an adversarial AI or hostile committer. It exists to catch:

- Fat-finger typos (`rm -rf /` when `rm -rf ./build` was meant)
- AI agents improvising a destructive shortcut when an allowed alternative exists
- Commands that are catastrophic in context (`gh repo delete` against the project's actual repo, `DROP TABLE` against a production DB)
- Commands a less-experienced user might run without recognising the consequences

**Honest limit on AI-self-bypass.** The escape hatch (`SAFETY_HARNESS_OFF=1`) is a UX affordance for human users who genuinely need to bypass — it provides no meaningful resistance to an AI agent that wants to self-administer the bypass via inline-prefix on retry. This is consistent with the threat model: we are not defending against an adversarial AI; we are defending against honest mistakes by humans and ill-considered shortcuts by helpful AIs. The block message communicates the bypass mechanism clearly *to the user* and the AI can learn it; the harness's value is that the block creates a moment where the user can intervene, not that an AI can't get past it.

Derivative projects with a tighter threat model should follow the *Tightening checklist* in the threat-model ADR — that's where defence-in-depth goes, not here.

## Scope and deliverables

### In scope

- One PreToolUse hook script (`.claude/hooks/safety-harness.sh`) intercepting **Bash** tool calls
- **Two-tier rubric** (revised from the originally-planned three): **block** (catastrophic, hard stop) and **ask** (ambiguous-but-destructive, user confirms via Claude Code's permission dialog)
- Pattern coverage for the commands listed in *Commands to catch* below
- Environment-variable escape hatch (`SAFETY_HARNESS_OFF=1`) for the rare case where bypass is needed, with documented limits
- Hook registration in `.claude/settings.json` with an `if` filter so the script doesn't spawn for unrelated Bash calls
- Documentation: a short `REFERENCE/safety-harness.md` explaining what's caught, how to bypass, what's intentionally not caught, and how to extend the patterns

### Out of scope (v1)

- **Write/Edit interception.** Bash is where the asymmetric blast radius lives; Write/Edit changes are reversible via git. Revisit if a clear class of Write/Edit footguns emerges.
- **MCP tool policy** (preferring one scraper over another, etc.). Mixes safety with policy — keep the hook strictly safety.
- **Static analysis of command intent** (interpreting variables, expanding heredocs, decoding base64). Pattern matching against the literal command string is good enough for honest-mistake catching; deliberate evasion is out of scope per the threat model.
- **Logging / telemetry.** The user-visible signal (block reason, ask dialog) is the only output; no separate log file.
- **Sentinel-file escape hatch.** Considered as a stronger alternative to the env var (an AI can't `touch` a file as easily as it can inline-prefix an env var) but deferred — the env-var hatch with documented limits is enough for v1, and the sentinel-file design has its own footguns (forgotten-and-left-on, accidentally committed). Revisit if AI-self-bypass becomes a real failure mode.

### Acceptance criteria

- [x] Hook blocks every command in the *block* list with a clear `permissionDecisionReason` string visible to the user
- [x] Hook prompts via the `"ask"` decision for every command in the *ask* list, surfacing in Claude Code's standard permission-dialog UI
- [x] Setting `SAFETY_HARNESS_OFF=1` disables the hook and is itself logged to stderr so the bypass is visible
- [x] Allowlist composition is correct: a command on the *block* list is blocked even if `permissions.allow` would have auto-allowed it
- [x] **Smoke tests pass on day one**: harmless `echo hello` exits 0 silently with the hook installed; ask dialogs actually surface to the user; block reasons actually surface; the env-var bypass actually disables the hook
- [x] Documentation in `REFERENCE/safety-harness.md` explains the two-tier rubric, the bypass mechanism with its limits, the compound-command coverage limits, and how to extend the patterns
- [x] Hand-curated fixture-based tests cover each pattern (input JSON → expected output JSON, looped through with `diff`)

## Risk-tier rubric

The hook informs the user clearly in every case — silent guarding is worse than no guarding, because it teaches the contributor to ignore the system.

**Primary discriminator: target × destructiveness, not reversibility alone.**
- **Block** patterns target *irreversible destruction of high-value paths*: filesystem roots (`/`, `~`, `$HOME`, `/Users`), raw disk devices (`/dev/disk*`, `/dev/sd*`, `/dev/nvme*`), the project's data layer (SQL `DROP TABLE/DATABASE/SCHEMA`), or the project's GitHub repo (`gh repo delete`).
- **Ask** patterns are *destructive or risky operations where the user can disambiguate intent*: `git reset --hard` is right when you want to throw away local work, wrong when you don't; `chmod 777` is rare and almost always overkill but occasionally what's wanted. The hook surfaces a confirmation dialog, the educational message rides on the dialog reason, and the user decides.

Reversibility is a *secondary* heuristic — useful when target+destructiveness is ambiguous, but not the primary frame. `rm -rf ./build` is fully irreversible and completely fine; the target (a build artefact) is what makes it safe. `chmod 777` on a public web directory is reversible but a security disaster while it's in effect; the target (a public path) is what makes it dangerous. **When extending the patterns, ask "what target does this command operate against, and what kind of destruction does it cause?" before deciding the tier.**

### Tier 1: Block (`permissionDecision: "deny"`, command does not run)

For commands targeting irreversible destruction of high-value paths. Block-tier output to the user includes:

1. **What was caught** (the specific pattern matched)
2. **Why it was blocked** (one sentence)
3. **How to override** if the user really meant it (the `SAFETY_HARNESS_OFF=1` env var, with a note about per-shell semantics)

### Tier 2: Ask (`permissionDecision: "ask"`, command awaits user confirmation)

For destructive or risky operations where intent matters and only the user can disambiguate. The hook returns `"ask"`; Claude Code surfaces the standard permission-dialog UI. Per Claude Code's contract, the prompt is **shown to the user but not to Claude** — the AI can't auto-answer. Ask-tier output includes the same three fields as block, framed as a confirmation question rather than a refusal. The ask reason carries any educational message the user benefits from (e.g. for `chmod 777`, the reason explains what 777 means and suggests safer alternatives).

### Why no warn tier?

The original spec had a third tier — *warn* — that would allow the command to run while displaying an educational `systemMessage` to the user. During implementation, live testing revealed that `systemMessage` does not render in interactive Claude Code (the hook fires with the correct JSON, but the field is invisible to the user). Rather than ship a warn tier that doesn't actually warn, the single warn-tier pattern (`chmod 777`) was moved to the ask tier. The educational message now rides on the ask-dialog reason, which the user genuinely sees. See *Implementation findings* below for the full record.

## Commands to catch

### Block (Tier 1)

| Pattern | Reason |
|---|---|
| `rm -rf` against `/`, `~`, `$HOME`, `/Users` | Catastrophic filesystem destruction |
| `rm -rf /` (any flag order) | Same — explicit pattern as fail-safe for `rm -rf -- /` etc. |
| `dd` with `of=/dev/(disk|sd|nvme|rdisk)*` | Raw disk overwrite. **Note:** `dd if=...` alone (input flag) is *not* matched — that's a benign file copy or stream operation, including the legitimate truncate idiom `dd if=/dev/null of=somefile bs=1` |
| `mkfs.*` against `/dev/(disk|sd|nvme|rdisk)*` | Raw disk format. **Note:** `mkfs.ext4 /tmp/loopfile` for loopback testing is fine and not caught |
| `diskutil eraseDisk` | Disk wipe |
| `DROP TABLE`, `DROP DATABASE`, `DROP SCHEMA` (case-insensitive) | SQL destruction. Catches `psql -c "..."`, `supabase db execute "..."`, and similar direct-execution patterns. Editing migration files is not caught (Write/Edit out of scope) |
| `gh repo delete` | GitHub repo deletion |

**Note on Supabase / SQL workflows.** Derivative projects using Supabase CLI, direct `psql`, or similar tools may legitimately drop tables during dev iteration. The block tier is correct here: dropping a table at the command line against the wrong database (e.g. linked production) is exactly the catastrophic case the harness is for. When the legitimate use case fires, set `SAFETY_HARNESS_OFF=1` inline and re-run, or run the destructive operation through a migration file (which the harness doesn't intercept).

### Ask (Tier 2)

| Pattern | Reason |
|---|---|
| `git reset --hard` | Discards local work; legitimate when you mean it, catastrophic when you don't. Confirming forces a pause. **Note:** detection is pattern-only — no `git rev-list` lookup, no branch-state introspection. The user's confirmation is the disambiguator |
| `git push --force` (or `-f`) to **non-main/master** branches | Rewrites personal-branch history; routine during rebase workflows but worth a confirm pause for less-experienced users |
| `chmod 777`, `chmod -R 777` | Grants read/write/execute to **everyone** including other users on the system. Almost always overkill — the ask-dialog reason explains and suggests `chmod 750` or `chmod 755` as alternatives. Originally drafted at warn tier; moved to ask during implementation when `systemMessage` was found not to render |

### Deliberately excluded patterns

These are listed because they were on early drafts and someone reading the spec or extending it later will wonder why.

- **`git push --force` to `main`/`master`** — already covered by GitHub branch protection (server-side) and the explicit `.claude/CLAUDE.md` rule (read every session). The hook would be a third layer for a problem two layers already solve. If a derivative project doesn't have branch protection, that's the bug to fix; don't substitute the hook for upstream defences.
- **`git commit --no-verify`** — Claude Code itself sometimes invokes `--no-verify` legitimately (e.g. when a hook bypass has been granted for a specific commit). Blocking would create false-positives that train bypass behaviour.
- **`kill -9`** — by the time someone is typing `kill -9`, they've usually already tried `kill` and want the nuke. A warning here is pure friction with no educational lift.
- **`TRUNCATE TABLE`** — also data destruction, but technically reversible inside a transaction in most DBs, and rare enough in command-line use that v1 doesn't include it. Reconsider if a real near-miss occurs.
- **Variable-expanded paths** (`TARGET=/; rm -rf $TARGET`), **base64'd commands**, **commands sourced from files** — pattern matching against the literal command string can't catch these. They are out of scope per *Out of scope* above; an attacker (or AI) deliberately constructing one of these is past the honest-mistakes threat model.

## Implementation

### Hook protocol

Claude Code's PreToolUse hook contract (current, per [Anthropic's hooks docs](https://docs.claude.com/en/docs/claude-code/hooks.md)):

- Hook receives JSON on stdin: `{"tool_name": "Bash", "tool_input": {"command": "..."}}`
- Hook responds via JSON on stdout using `hookSpecificOutput.permissionDecision`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked: rm -rf targeting home directory. Set SAFETY_HARNESS_OFF=1 inline (e.g. `SAFETY_HARNESS_OFF=1 rm -rf ~/old-project`) and re-run if you really mean it."
  }
}
```

Valid `permissionDecision` values: `allow`, `deny`, `ask`, `defer`. The block tier uses `deny`; the ask tier uses `ask`. The originally-planned warn tier was to use `allow` plus a `systemMessage` field at the top level of the JSON output — that approach was abandoned during implementation because `systemMessage` does not render in interactive Claude Code (see *Implementation findings*).

**Note:** the older `{"decision":"allow|block","reason":"..."}` shape is **deprecated** for PreToolUse and must not be used. The Dex reference implementation uses the deprecated shape — adopt its patterns, not its protocol envelope.

### Reference implementation

The Dex repository has a working PreToolUse safety guard whose **patterns** we adapt directly:

- [`.claude/hooks/dex-safety-guard.sh`][dex-hook] — covers `rm -rf` against root/home, disk wipes, force push to main, SQL DROP, repo deletion, plus warnings for `chmod 777` and `kill -9`. We adopt these patterns (with the modifications noted in *Commands to catch* — narrowed `dd`/`mkfs` to output devices, dropped `kill -9`, dropped force-push-to-main, added `DROP SCHEMA`).

We **do not** adopt:
- Dex's MCP tool-preference blocks (firecrawl/webfetch denials) — those mix policy with safety.
- Dex's JSON envelope shape (deprecated `decision`/`reason`) — see *Hook protocol* above.

[dex-hook]: https://github.com/davekilleen/Dex/blob/main/.claude/hooks/dex-safety-guard.sh

### Escape hatch

A single environment variable, `SAFETY_HARNESS_OFF=1`, disables the hook. When set:

- The hook still runs (registered in settings.json), reads stdin, but exits 0 immediately
- It prints a single line to stderr: `[safety-harness] disabled via SAFETY_HARNESS_OFF`
- This makes the bypass visible — the user never accidentally runs with the harness off without knowing

**Honest about the limits:**

1. **Per-shell semantics.** Each Claude Code Bash tool call spawns a fresh shell. `export SAFETY_HARNESS_OFF=1` in tool call N does *not* persist to tool call N+1. The bypass must be either (a) set in the parent shell *before* launching `claude` (`SAFETY_HARNESS_OFF=1 claude`), or (b) inline-prefixed per command (`SAFETY_HARNESS_OFF=1 rm -rf ~/old-project`). Block-tier messages should show the inline form as the primary example.

2. **No defence against AI self-bypass.** An AI agent that hits a block and wants to retry can read the block message, learn the inline-prefix form, and apply it. This is intentional: the threat model (honest mistakes by humans, ill-considered shortcuts by helpful AIs) is not "adversarial AI determined to bypass." The harness's value is that the block creates a moment where the user can intervene, not that an AI can't get past it. The block message should communicate the bypass mechanism clearly to the user.

3. **Stale-bypass risk.** A user who sets `SAFETY_HARNESS_OFF=1` in `.zshrc` or `.envrc` for one legitimate use will then run with the harness off indefinitely without realising. Documentation in `REFERENCE/safety-harness.md` should explicitly advise against persistent-shell setting and prefer inline-prefix.

Why an env var rather than a per-command bypass token (`# safety-harness: ack`): per-command tokens creep into committed scripts and erode the guardrail across the whole project. The env var keeps the bypass at the invocation surface.

### Interaction with the existing allowlist

The two systems compose:

- The **allowlist** (`permissions.allow` in `.claude/settings.json`) decides whether Claude Code prompts the user before running a command. It controls UX friction, not safety.
- The **safety harness** runs *after* the allowlist — Claude Code's hook lifecycle is: allowlist → PreToolUse hook → command executes. Per the hooks docs, "PreToolUse hooks run before tool execution regardless of permission status." So allowlisting `Bash(git push *)` does not bypass the harness's force-push patterns.

This means we deliberately do **not** add `Bash(rm -rf:*)` to the allowlist as a "convenience" — the allowlist would silence the prompt, but the harness would still block. Cleaner to leave that command pattern un-allowlisted so the contributor sees both layers when (rarely) needed.

### Compound-command coverage

The hook matches against the literal command string. What this catches and doesn't:

**Caught (free, via Claude Code's built-in subcommand matching for `&&`, `;`, `|`):**
- `git status && rm -rf /` — the destructive subcommand fires the regex
- `echo / | xargs rm -rf` — the pipeline body fires
- `cat <<'EOF' | bash\nrm -rf /\nEOF` — the heredoc body is part of the command string
- `sh -c "rm -rf /"` — match `sh\s+-c.*rm` patterns explicitly

**Not caught (fundamentally hard without a parser, out of scope per the threat model):**
- Variable-expanded paths: `TARGET=/; rm -rf $TARGET`
- Base64'd / obfuscated commands: `echo "cm0gLXJmIC8=" | base64 -d | sh`
- Commands written to a file then sourced: `echo "rm -rf /" > /tmp/x.sh && sh /tmp/x.sh`

Document this honestly in `REFERENCE/safety-harness.md`. Honest mistakes don't construct these forms; deliberate evasion does, and the threat model puts deliberate evasion out of scope.

### File layout

```
.claude/
├── hooks/
│   └── safety-harness.sh   # the hook script (chmod +x)
└── settings.json           # registers the hook under PreToolUse

REFERENCE/
└── safety-harness.md        # what's caught, how to bypass, limits, how to extend
```

### Settings.json registration

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Bash",
      "if": "Bash(rm * | dd * | mkfs* | diskutil* | git push * | git reset * | gh repo * | psql * | supabase *)",
      "hooks": [
        { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/safety-harness.sh" }
      ]
    }
  ]
}
```

The `if` filter limits which Bash commands trigger the hook script. Without it, the hook fires on every Bash invocation including `git status`, `ls`, `cat` — and pays ~80–150ms cold-start cost per fire (two `python3 -c` JSON parses). With the filter, the script only spawns when patterns might match.

**Verify during implementation** that the `if` filter accepts `|` as alternation. If not, split into separate handlers per command family — same effect, more JSON.

### Test approach

Hand-curated fixtures over a heavy framework. For each pattern:

- `tests/fixtures/{name}.in.json` — input JSON the hook will receive
- `tests/fixtures/{name}.expected.json` — expected output JSON

A small shell runner pipes each `.in.json` through the hook, captures stdout, diffs against `.expected.json`. Patterns and fixtures get added together in the same PR. Documented extension procedure in `REFERENCE/safety-harness.md`.

This avoids pulling in `bats` or another test framework for an ~80-line script while still giving regression coverage when patterns are tweaked.

## User-facing experience

### Block example

User (or AI agent) runs: `rm -rf ~/projects`

Hook output (stdout, JSON):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked: rm -rf targeting home directory (~/projects). If you really mean this, prefix the command inline: `SAFETY_HARNESS_OFF=1 rm -rf ~/projects`."
  }
}
```

The user sees the reason in Claude Code's tool-result UI. The command does not execute.

### Ask example

User runs: `git reset --hard`

Hook output (stdout, JSON):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "git reset --hard discards all local changes since the last commit. Continue?"
  }
}
```

Claude Code surfaces the standard permission-dialog UI. The user answers (yes/no); the command runs only on yes. The AI can't see the dialog content.

### Escape-hatch example

User runs: `SAFETY_HARNESS_OFF=1 rm -rf ~/old-project`

Hook output (stderr):

```
[safety-harness] disabled via SAFETY_HARNESS_OFF
```

The command runs with no further checks.

## Implementation findings

The three open questions raised during `/review-spec` were all settled by live smoke-testing against the actual Claude Code runtime. Recording the results here so future maintainers don't re-derive them.

1. **`systemMessage` does not render to the user in interactive Claude Code.** The hook fires with the correct JSON shape (verified offline) but the `systemMessage` field is invisible to the user in interactive sessions. Block reasons (on `deny`) and ask reasons (on `ask`) both surface correctly, so it isn't a hook-protocol issue — `systemMessage` specifically doesn't make it to the terminal. **Resolution:** drop the warn tier entirely; move the single warn pattern (`chmod 777`) to the ask tier. The educational message now rides on the ask-dialog reason. The fallback proposed in the original spec — using `permissionDecisionReason` on `permissionDecision: "allow"` — was not pursued because moving to ask is cleaner and aligns with the review-team's preference for fewer informational mechanisms.

2. **The `if` filter accepts `|` alternation.** Verified by registering the spec's filter (`Bash(rm * | dd * | mkfs* | diskutil* | git push * | git reset * | gh repo * | psql * | supabase * | chmod *)`) and triggering a block-tier `dd` command. The block fired correctly, meaning Claude Code parsed the alternation and matched `dd *` against the command. No need to split into separate handlers per command family.

3. **Ask-tier dialog surfaces to the user; AI cannot see or auto-answer it.** Verified by running `git reset --hard <nonexistent-ref>` and `chmod 777 <test-file>` — both produced permission dialogs the user could approve or deny, neither produced any signal visible to the AI. This confirms the ask tier is structurally safe against AI-self-bypass per the spec's design intent.

4. **The inline-prefix bypass needed an explicit hook-side check.** The original hook checked `[ "$SAFETY_HARNESS_OFF" = "1" ]` against the script's own environment. That works for parent-shell export (the env var propagates from the shell that started `claude`) but NOT for the inline form (`SAFETY_HARNESS_OFF=1 rm -rf ~/old`) — Claude Code spawns the hook script before the command shell exists, so an inline prefix on the user's command never reaches the hook's environment. **Resolution:** the hook now explicitly checks the *command string* for a leading `SAFETY_HARNESS_OFF=1 ` prefix as well, in addition to its own environment. This was discovered during fixture generation when bypassing the hook to write test data with destructive command strings — the inline form silently failed until the explicit check was added. The behaviour the spec promised is now actually delivered.

5. **Three regex bugs surfaced by the team PR review.** A `/review-pr-team` pass on the implementation found three regex bugs that the test suite hadn't caught — the empty `block-mkfs-disk.expected.json` fixture was encoding the C1 bug as expected behaviour, hiding it from the suite. Findings:
   - **`mkfs.ext4 /dev/disk2` (canonical 2-token form) silently allowed.** The regex required an extra whitespace-separated token between `mkfs.*` and `/dev/`. Fix: make that group optional — `mkfs(\.[a-z0-9]+)?[[:space:]]+(.*[[:space:]])?/dev/(disk|sd|nvme|rdisk)`.
   - **`chmod 0777` (zero-padded octal) silently allowed.** `\b777\b` doesn't match because `\b` doesn't sit between `0` and `7`. Fix: `0?777\b`.
   - **`git push --force origin master-prod` silently allowed.** `\b(main|master)\b` matched the `master` substring inside `master-prod`, so the exclusion fired and prevented the ask. Fix: anchor end-of-arg with `(main|master)([[:space:]]|$)`.

   Plus a structural fix to the test runner: a fixture-naming convention check (`block-*` and `ask-*` must have non-empty `.expected.json`; `allow-*` and `bypass-*` must have empty) catches the empty-expected class of bug at suite-startup. The runner also now `unset`s `SAFETY_HARNESS_OFF` at the top so it doesn't pass silently when a developer has the bypass exported.

   The team review's deeper architectural lesson: three of four findings were the same shape — *claim made in markdown, no machine check that the claim holds*. Beyond the script-level fixture-naming check, the broader template should consider a markdown-link validator at the same validation layer to catch the class of bug where a file move (like the SPECIFICATIONS → SPECIFICATIONS/ARCHIVE move that broke this spec's outbound `../` links) silently rots references. Captured as a future-extension idea below.

**Sentinel-file escape hatch — still deferred.** Revisit if AI-self-bypass becomes a real failure mode in practice. The v1 design doesn't foreclose it.

## Future extensions (not in v1)

- Write/Edit hooks for protected paths (`.env`, `.git/*`, `secrets/*`)
- A `safety-harness audit` command that reviews recent Claude Code sessions for blocked-and-bypassed events
- Per-project pattern overrides (a `safety-harness-patterns.local.json` ignored by git, so derivative projects can tighten without forking the script)
- A second hook for `Read` to catch attempts to print secrets to chat output (different threat shape — accidental leakage, not destruction)
- Supabase-specific patterns at `ask` tier (`supabase db reset`, `supabase db push --linked`) once a real workflow surfaces
- Filter-alternation extension for alternative SQL tooling (`mysql`, `sqlite3`, `dropdb`) — the script's DROP regex catches them, but the `if` filter's command-family alternation doesn't currently include them so the script never spawns. Add when a real workflow surfaces.
- Markdown-link validator at the project's pre-merge layer (e.g. `markdown-link-check` over `SPECIFICATIONS/` and `REFERENCE/`) — would catch the class of bug where a file move silently breaks outbound references.

These are listed so the v1 design doesn't accidentally foreclose them, not as commitments.

## Credits

The pattern set and many of the regex patterns are adapted from [`davekilleen/Dex`'s `dex-safety-guard.sh`][dex-hook]. Attribution and a link belong in the head comment of the hook script and in `REFERENCE/safety-harness.md`.

Note that we **diverge from Dex** in three ways:
- JSON envelope shape: we use the current `hookSpecificOutput.permissionDecision`, Dex uses the deprecated `decision`/`reason`
- We add the `ask` tier; Dex is binary block/allow
- We narrow `dd` and `mkfs` to output-device patterns (Dex matches the bare commands)

[dex-hook]: https://github.com/davekilleen/Dex/blob/main/.claude/hooks/dex-safety-guard.sh
