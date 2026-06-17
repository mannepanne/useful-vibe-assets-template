# Threat-model calibration, silent reviews, safety-harness, and SCRATCH-write hook

**Status:** Active
**Authoritative source:**
- [PR #18 — Add TEMPLATE-UPDATES migration packet system](https://github.com/mannepanne/useful-assets-template/pull/18)
- [PR #19 — Calibrate triage-reviewer for solo-trusted-contributor threat model](https://github.com/mannepanne/useful-assets-template/pull/19)
- [PR #21 — Recalibrate reviewer-agent severity defaults against threat-model ADR](https://github.com/mannepanne/useful-assets-template/pull/21)
- [PR #22 — Replace dispatcher rm -f with Read-then-Write fallback](https://github.com/mannepanne/useful-assets-template/pull/22)
- [PR #23 — Add safety-harness spec + threat-model ADR sub-case](https://github.com/mannepanne/useful-assets-template/pull/23)
- [PR #24 — Implement PreToolUse safety-harness hook (block/ask tiers)](https://github.com/mannepanne/useful-assets-template/pull/24)
- [PR #25 — Steer reviewer agents toward silent built-in tools](https://github.com/mannepanne/useful-assets-template/pull/25)
- [PR #30 — Silent JSON validation tooling (python3/jq) + allow-list pinning ADR](https://github.com/mannepanne/useful-assets-template/pull/30)
- [PR #31 — Move scratch files to .claude/scratch/ + bare-grep allow-list](https://github.com/mannepanne/useful-assets-template/pull/31)
- [PR #32 — Investigation: fifth sighting captured + belt-and-braces SCRATCH allow-list](https://github.com/mannepanne/useful-assets-template/pull/32)
- [PR #33 — PreToolUse hook to silence Write-to-SCRATCH prompt + read-only allow-list expansion](https://github.com/mannepanne/useful-assets-template/pull/33)
- [PR #34 — Silence hook test-runner prompts during reviews](https://github.com/mannepanne/useful-assets-template/pull/34)
- Also rolled in: standalone commits `e3521c7`, `4813aad`, `f6050b2`, `db5f200` (silence + threat-model groundwork that landed between PRs 18 and 19)

---

## Why

A coherent set of improvements landed across PRs 18–34 that together shift the review system from a fixed "worst-case attacker" stance to a calibrated, threat-model-driven one — with the operational consequences that follow. Four things are easier to understand together than separately, so this packet rolls them up:

1. **A documented threat model.** Reviewer agents previously rated severity against an implicit "all attackers including malicious committers" stance, producing theoretical-RCE findings that didn't apply to the actual contributor model (solo trusted contributor, or small team of mutually-trusted contributors). The threat-model ADR makes that calibration explicit, and the reviewer agents now read against it.
2. **Silent reviews.** Many small frictions added up to a `/review-pr` or `/review-spec` run that prompted the human for manual approval throughout — unnecessary `git -C` forms, pipe-compounds the matcher couldn't allowlist, secret-shape regex on the command line, reviewers reaching for `curl` and `python3 -c` when built-in tools were silent. Cumulative fix: a Tool invocation conventions section in `.claude/agents/CLAUDE.md`, allowlist tuning in `.claude/settings.json` (including silent JSON-validation tooling and the allow-list pinning principle ADR that calibrates how broad each rule should be), a triage-reviewer patterns file split, the dispatcher's Read-then-Write fallback, and `WebFetch` granted to spec-review agents only.
3. **A PreToolUse safety-harness hook.** A two-tier (block/ask) hook script that intercepts genuinely destructive Bash commands before the shell sees them. Calibrated for the *less-experienced-user* sub-case in the threat model (the threat-model ADR has an addendum for this) — block tier catches one-way doors against personal data (`rm -rf` against root/home/`$HOME`, `dd of=/dev/disk*`, `mkfs * /dev/disk*`, `diskutil eraseDisk`, SQL `DROP TABLE/DATABASE/SCHEMA`, `gh repo delete`); ask tier surfaces a permission dialog with educational reason for `git reset --hard`, `git push --force` to non-main, `chmod 777`. Comes with a 32-test fixture-based test suite and an inline `SAFETY_HARNESS_OFF=1` bypass.
4. **A PreToolUse SCRATCH-write hook.** A second `PreToolUse` hook scoped to `Write` that auto-approves writes under `<project>/SCRATCH/`. Required because Claude Code's `Write` tool gates *beyond* the allow-list matcher — `Write(/SCRATCH/*)` and three sibling glob shapes empirically do not silence the prompt across five fresh-session sightings (PR #32 captured the fifth and ran it with all four shapes simultaneously committed). The hook is fail-safe by design (only ever emits `permissionDecision: "allow"`, falls through silently on any error or unexpected input), narrowly scoped (`Write` only, paths textually under `$CLAUDE_PROJECT_DIR/SCRATCH/` only, with `..`-traversal rejection), and ships with a 7-test fixture suite (6 fixture pairs + one unset-`CLAUDE_PROJECT_DIR` case). The dead `Write(/SCRATCH/*)` allow-list entries are removed; the hook is the canonical path until the upstream matcher is fixed.

> **⚠️ Read this before adopting any calibration downstream.** The threat-model ADR at `REFERENCE/decisions/2026-04-25-pr-review-threat-model.md` is the load-bearing assumption. **Most derivative projects do not have the template's exact contributor model.** The severity defaults, the safety-harness block/ask choices, and the decision to withhold `WebFetch` from PR-review agents all depend on that calibration. If your project's contributor model differs (open-source PRs from strangers, multi-team enterprise, regulated environments, junior developers as primary users), follow the ADR's *tightening checklist* before adopting downstream changes — otherwise you ship the template's defaults into a project that needs different ones. The receiving Claude must surface this question before applying anything in the manifest.

## What changed

- **New ADR + sub-case:** `REFERENCE/decisions/2026-04-25-pr-review-threat-model.md` documents the in-scope/out-of-scope split for severity calibration and includes a less-experienced-user sub-case that justifies the safety-harness defaults.
- **Reviewer-agent severity recalibration:** `security-specialist` and `triage-reviewer` no longer flag malicious-committer attacks as blockers; they note them as "out-of-scope per threat model" with a one-line pointer.
- **Tool invocation conventions:** new section in `.claude/agents/CLAUDE.md` that steers reviewer agents toward built-in tools (`Read`, `Glob`, `Grep`, `WebFetch`) over shell equivalents (`cat`, `find`/`ls`, `grep`, `curl`, `python3 -c`). Top-line principle: built-ins are silent and bounded; shell forms prompt and are unbounded.
- **Tool grant asymmetry:** spec-review agents (`technical-skeptic`, `requirements-auditor`, `devils-advocate`) gain `WebFetch` for verifying claims against authoritative external docs. PR-review agents do NOT — their substrate is local (code, PR content) and a PR description containing an attacker-controlled URL would otherwise be a fetch target. The asymmetry is documented to prevent future "harmonization" reverts.
- **Triage patterns file rename:** `.claude/agents/triage-secret-patterns.txt` → `.claude/agents/triage-scan-patterns.txt`. The file is loaded via `grep -E -f` to keep the regex off the command line (the Claude Code permission validator was misreading `{N,}` quantifiers as brace expansion). Receiving projects on the previous packet may have neither; receiving projects mid-rename may have the old name.
- **Dispatcher Read-then-Write fallback:** `/review-pr` and `/review-pr-team` no longer use `rm -f /tmp/...` to clear stale temp files (which prompted because `rm` isn't allowlisted). They Read first, then Write — silent under default permissions.
- **Project-relative scratch directory:** review skills write their intermediate comment-body files to a top-level `SCRATCH/` directory rather than `/tmp/`. The directory contents are gitignored (`*\n!.gitignore` inside `SCRATCH/.gitignore`). For `Read`, the allow-list rule `Read(/SCRATCH/*)` works as documented — the leading-`/` is project-root-relative and the matcher honours it. For `Write`, the allow-list rule `Write(/SCRATCH/*)` does **not** silence the prompt across five fresh-session sightings — the upstream `Write` matcher gates beyond the allow-list. The supported path is the `PreToolUse` SCRATCH-write hook bundled in this packet (see the next bullet). Derivative projects on an earlier draft of this packet that committed `Write(/SCRATCH/*)` (or any of `Write(/SCRATCH/**)`, `Write(SCRATCH/*)`, `Write(SCRATCH/**)`) should remove all four — they are dead code — and adopt the hook instead. Sidesteps two distinct problems: (1) an intermittent matcher quirk where absolute `/tmp/...` paths were sometimes displayed in `../../../../../../tmp/...` traversal form and failed allow-list matching (the diagnosis trail is template-internal historical context — the conclusion travels via the SCRATCH-write hook ADR); and (2) a settings-self-modification approval gate that fires on any Write under `.claude/`, regardless of allowlist entries — which is why the directory lives at the repo root rather than inside `.claude/`. Root cause of (1) unresolved upstream; the symptom is now silenced by the SCRATCH-write hook rather than the allow-list.
- **PreToolUse safety-harness hook:** new `.claude/hooks/safety-harness.sh` script + 39-fixture test suite at `.claude/hooks/tests/safety-harness/`. Registered in `.claude/settings.json` under `hooks.PreToolUse` with an `if`-filter alternation to keep the script invocation cheap. Inline `SAFETY_HARNESS_OFF=1 <cmd>` bypass works because the script checks the command string explicitly (the env var alone wouldn't propagate — Claude Code spawns the hook before the command shell).
- **PreToolUse SCRATCH-write hook:** new `.claude/hooks/approve-scratch-write.sh` script + a 7-test fixture suite at `.claude/hooks/tests/approve-scratch-write/` (6 fixture pairs + one unset-`CLAUDE_PROJECT_DIR` case that needs no fixture). Registered as the second entry in `hooks.PreToolUse` with `matcher: "Write"`. Shares the parse helper at `.claude/hooks/lib/parse-tool-input.sh` with the safety-harness hook. Fail-safe: only ever emits `permissionDecision: "allow"`, exits silently on any error or unexpected shape, never weakens existing safety. Replaces the dead `Write(/SCRATCH/*)` (and three sibling glob) allow-list entries — those are removed because the upstream `Write` matcher empirically does not honour them. The `permissions._comment_scratch_writes` field in `.claude/settings.json` documents the situation for future readers and points at the ADR.
- **Reference doc:** `REFERENCE/safety-harness.md` describes block-tier / ask-tier / what's not caught / how to bypass / how to extend patterns. `REFERENCE/scratch-write-hook.md` is the operations doc for the SCRATCH-write hook (what it approves, where it sits in the call path, what's deliberately out of scope, fail-closed semantics, how to extend, and the rollback path if the upstream matcher is fixed).
- **Allowlist tuning** in `.claude/settings.json` for git-pipe forms, `git fetch`, `Read(/SCRATCH/*)` (and three sibling glob shapes for `Read`), the safety-harness and SCRATCH-write hook test-runner entries, etc. The `Write(/SCRATCH/...)` entries are deliberately *absent* — the SCRATCH-write hook handles those.

For the full design rationale, the threat-model ADR is the single most useful starting point. The PR descriptions linked above carry the per-change specifics.

## Application order

The sub-changes have dependencies. Apply in this order:

1. **Threat-model ADR + agent severity calibration** (commits `4813aad`, PR #19, PR #21) — every other calibration in this packet refers back to this ADR. If a derivative project edits the ADR to fit a different contributor model, that edit must land first; downstream calibrations follow.
2. **Silent-review conventions** (commits `e3521c7`, `f6050b2`, `db5f200`, PR #22, PR #25, PR #30, PR #31, PR #32, PR #34) — Tool invocation conventions section, allowlist additions (including JSON-validation tooling pinned per the allow-list pinning ADR, bare-grep and jq, hook test-runner entries, the four `Read(/SCRATCH/...)` glob shapes), triage patterns file rename, dispatcher Read-then-Write fallback, WebFetch grants on spec-review agents.
3. **Safety harness** (PR #23 ADR sub-case, PR #24 implementation) — independent of the silent-review work; establishes the `hooks.PreToolUse` block for the first time. The `chmod +x` step (see below) is essential.
4. **SCRATCH-write hook** (PR #32 investigation, PR #33 implementation) — appends the second entry to `hooks.PreToolUse`, so apply *after* Stage 3 to keep the block-merge clean. Conceptually this closes the silent-reviews loop (Stage 2 added `Read(/SCRATCH/*)` allow-list rules; this stage handles the `Write` side that the matcher doesn't honour). File-content-wise it doesn't depend on Stage 3, but adjacency keeps the `hooks.PreToolUse` merge to a single pass. The `chmod +x` step on `approve-scratch-write.sh` and its test runner is essential.

## File manifest

### Copy verbatim

Files that did not exist before this rollout. Add them as-is unless a same-named file already exists locally (in which case treat as *merge carefully* and flag the conflict).

**Threat-model ADR**
- `REFERENCE/decisions/2026-04-25-pr-review-threat-model.md` — the threat-model ADR with less-experienced-user sub-case

**Allow-list pinning principle ADR**
- `REFERENCE/decisions/2026-04-26-allowlist-pinning-principle.md` — companion to the threat-model ADR; the granularity rule for individual `permissions.allow` entries (subcommand-pin for code-eval-capable binaries, binary-level for pure data transformers). Read this before adding new tooling rules to a derivative project's settings.json.

**Scratch directory placeholder**
- `SCRATCH/.gitignore` — single file, two lines (`*\n!.gitignore`). Keeps the directory tracked but ignores all contents. Review skills write their intermediate comment-body files here; the gitignored contents mean artefacts don't leak into commits. Without this file, the directory wouldn't exist in fresh clones and the first Write would have to create the parent. The directory lives at the repo root (not inside `.claude/`) because Writes under `.claude/` trigger Claude Code's settings-self-modification approval gate regardless of allowlist entries.

**Triage patterns file** (RENAMED — see "Easy-to-miss mechanics" below)
- `.claude/agents/triage-scan-patterns.txt` — secret-shape patterns, loaded via `grep -E -f` to keep regex off the command line. **Note:** the previous packet (`2026-04-pr-review-triage`) now also ships this file, so projects that adopted that packet first will already have it. Skip this entry if the file is already present locally.

**Safety-harness implementation**
- `.claude/hooks/safety-harness.sh` — the hook script (**must `chmod +x` after fetch**)
- `.claude/hooks/tests/safety-harness/run-tests.sh` — fixture runner (**must `chmod +x` after fetch**)
- `.claude/hooks/tests/safety-harness/fixtures/` — 39 fixture pairs (78 files: `*.in.json` + `*.expected.json`). See "Easy-to-miss mechanics" for how to fetch a directory rather than enumerating files.
- `REFERENCE/safety-harness.md` — how-it-works doc (block/ask tiers, what's not caught, bypass mechanics, extension guide)

**SCRATCH-write hook implementation**
- `.claude/hooks/approve-scratch-write.sh` — the hook script (**must `chmod +x` after fetch**)
- `.claude/hooks/lib/parse-tool-input.sh` — shared parse helper used by both PreToolUse hooks. **Note:** the safety-harness hook also depends on this file, so projects that already applied Stage 3 will have it. If absent, fetch and place at the listed path; if present, leave alone (a content diff between local and source would be unexpected — flag rather than overwrite). **Older-shape edge case:** projects that applied Stage 3 *before* PR #33 landed have a `safety-harness.sh` that does inline JSON parsing (no `. "$SCRIPT_DIR/lib/parse-tool-input.sh"` line near the top). On re-application, that file should also be updated from source — otherwise you have the helper sitting unused alongside the older inline shape. A quick `grep -q parse-tool-input.sh .claude/hooks/safety-harness.sh` confirms which shape is local.
- `.claude/hooks/tests/approve-scratch-write/run-tests.sh` — fixture runner (**must `chmod +x` after fetch**)
- `.claude/hooks/tests/approve-scratch-write/fixtures/` — 6 fixture pairs (12 files: `*.in.json` + `*.expected.json`). Test count is 7 because one test (the unset-`CLAUDE_PROJECT_DIR` case) needs no fixture pair. Use the same tree-API approach as the safety-harness fixtures; the directory is small enough to enumerate but consistent with the broader pattern.
- `REFERENCE/scratch-write-hook.md` — how-it-works doc (what's caught, fail-closed semantics, threat-model carve-outs for symlinks and exotic filenames, how to extend, how to remove if upstream is fixed)
- `REFERENCE/decisions/2026-04-26-scratch-write-pretooluse-hook.md` — the ADR documenting *why* this hook exists (the upstream `Write` matcher gates beyond the allow-list) and the trade-offs accepted

### Merge carefully

Files that almost certainly exist in the target project but with different content. The receiving Claude must read the local version, identify the section(s) added/changed by this packet, and merge — preserving local customisation elsewhere.

**`.claude/agents/CLAUDE.md` — multiple distinct sections**

This file accumulates four sections across the rolled-up PRs. Treat each as an independent merge:

- **Severity calibration** (heading: `### Severity calibration`) — added by commit `4813aad`. Adds a paragraph and bullet list pointing at the threat-model ADR. If absent locally, add the section. If present with locally-customised wording, keep the local wording but verify it points at the threat-model ADR path.
- **Tool invocation conventions** (heading: `### Tool invocation conventions`) — final form added in PR #25 (subsumes earlier "Bash invocation conventions" content from commits `f6050b2`, `db5f200`). If the local file has the older "Bash invocation conventions" section, replace it wholesale with the broader "Tool invocation conventions" section. If absent, add. The table inside is the source of truth.
- **Tool grant asymmetry** (heading: `#### Tool grant asymmetry`) — added by PR #25. Sub-section under "Tool invocation conventions". If absent, add.
- **Untrusted-content scope when fetching** (heading: `#### Untrusted-content scope when fetching`) — added by PR #25. Sub-section under "Tool invocation conventions". If absent, add.

**`.claude/settings.json` — three independent deltas**

Don't treat this file as a single merge. Apply each delta independently:

- **`env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"`** — already required by the previous packet (`2026-04-pr-review-triage`); it's listed here only because it appears in the source file. **If already present locally with the same value, no change.** If absent, add.
- **`permissions.allow` additions** — multiple new entries across thematic groups, plus two `_comment_*` fields that document load-bearing assumptions (the threat-model `_comment` and the `_comment_scratch_writes` field that explains why no `Write(/SCRATCH/...)` entries are present and points at the SCRATCH-write hook ADR):
  - **Review-tooling entries** (the silent-reviews work): `Bash(git fetch *)`, `Bash(git -C * log/show/diff/status *)`, `Bash(git show * | sed -n *)` and the related git-pipe siblings, `Bash(gh pr diff * | grep *)`, the four `Read(/SCRATCH/*)` / `Read(/SCRATCH/**)` / `Read(SCRATCH/*)` / `Read(SCRATCH/**)` glob shapes (all four are committed deliberately — `Read` honours the matcher and the four-shape coverage was the empirical answer that surfaced from PR #32's investigation; cheaper than guessing which form a future Claude Code build prefers). **Do NOT add `Write(/SCRATCH/*)` (or any of `Write(/SCRATCH/**)`, `Write(SCRATCH/*)`, `Write(SCRATCH/**)`)** — the upstream `Write` matcher empirically does not honour these entries across five fresh-session sightings. Silencing the SCRATCH/ Write prompt is the job of the `PreToolUse` SCRATCH-write hook bundled in this packet (Stage 4; the second `hooks.PreToolUse` array entry, registered with `matcher: "Write"` and pointing at `.claude/hooks/approve-scratch-write.sh`). Older versions of this packet pinned to `/tmp/review-pr-*` and `/tmp/spec-review-*` — derivative projects upgrading from the older form should swap those `/tmp` rules for the four `Read(/SCRATCH/...)` glob shapes and add `SCRATCH/.gitignore`. Projects upgrading from an earlier draft of THIS packet that committed `Write(/SCRATCH/*)` (or any of the four `Write` glob shapes) should remove all four — they are dead code. An even-earlier intermediate shape used `.claude/scratch/*`; that form triggered Claude Code's settings-self-modification approval prompt on every Write and was abandoned for the repo-root location.
  - **Test / typecheck / lint entries** (silent test runs across common JS/TS toolchains). Two shape families, both needed:
    - **Plain prefix forms:** `Bash(npm test:*)`, `Bash(npm run test:*)`, `Bash(npm run typecheck:*)`, `Bash(npm run lint:*)`, `Bash(bun test:*)`, `Bash(bun run test:*)`, `Bash(bun run typecheck:*)`, `Bash(bun run lint:*)`, `Bash(node_modules/.bin/vitest:*)`, `Bash(node_modules/.bin/jest:*)`, `Bash(node_modules/.bin/tsc:*)`, `Bash(npx vitest:*)`, `Bash(npx tsc:*)`.
    - **Pipe-aware forms** for common output-truncation patterns Claude reaches for (`| tail -<n>`, `| head -<n>`, `| grep <pattern>`): `Bash(npm test * | tail/head/grep *)`, `Bash(npm run test * | tail/head/grep *)`, `Bash(npm run typecheck * | tail *)`, `Bash(npm run lint * | tail *)`, `Bash(bun run test * | tail/head/grep *)`, `Bash(bun run typecheck * | tail *)`, `Bash(bun run lint * | tail *)`, `Bash(node_modules/.bin/vitest * | tail/head/grep *)`, `Bash(node_modules/.bin/jest * | tail *)`, `Bash(node_modules/.bin/tsc * | tail *)`, `Bash(npx vitest * | tail *)`, `Bash(npx tsc * | tail *)`. The pipe variants are **necessary**, not redundant — the permission matcher checks the full compound command against the pattern, so `Bash(node_modules/.bin/vitest:*)` alone won't silence `vitest run X 2>&1 | tail -30`. The same reason the manifest's git-pipe rules (`Bash(git show * | tail *)` etc) exist as siblings of `Bash(git -C * show *)`.
    - The set is broad on purpose (npm + bun + raw binaries + npx) so it works regardless of which package manager the receiving project uses; entries that don't apply to the local toolchain are harmless no-ops. If a derivative project's existing settings have narrow exact-match forms like `Bash(bun run test)`, it's safe to leave them — but broadening to `:*` form silences flag variants like `--watch` and `--coverage`.
  - **Validation tooling entries** (silent JSON syntax checks and field extraction Claude reaches for after editing settings/config files). The granularity choices below follow the **allow-list pinning principle** ADR (`REFERENCE/decisions/2026-04-26-allowlist-pinning-principle.md`) — read it before adding more tooling rules:
    - **`python3 -m json.tool` (pinned narrowly):** `Bash(python3 -m json.tool:*)`, `Bash(python3 -m json.tool * > /dev/null)`, `Bash(python3 -m json.tool * > /dev/null && echo *)`, `Bash(python3 -m json.tool * && echo *)`. The risk is the binary, not the module — `Bash(python3:*)` or `Bash(python3 -m *)` would silently allow `python3 -c "import os; os.system(...)"` (full arbitrary code execution) and any other Python module. Pin to the specific subcommand only.
    - **`jq` (binary-level allow):** `Bash(jq:*)` plus pipe siblings `Bash(jq * | tail *)`, `Bash(jq * | head *)`, `Bash(jq * | grep *)`. **Different risk profile from Python** — `jq` has no escape hatch to arbitrary code execution: no `-c`-equivalent, no shell-out, no module imports, no file writes. It's a pure JSON-in / JSON-out transformer. So binary-level allow at `Bash(jq:*)` is genuinely safe; the pipe siblings cover jq-as-source patterns. (jq-as-sink — `<command> | jq *` — is intentionally NOT allow-listed broadly: the matcher checks the full compound, so `Bash(* | jq *)` would smuggle in any source command. Add narrow source-piped-to-jq rules only as specific sources surface as pain points.)
    - **`grep` (binary-level allow + semicolon-echo sibling):** `Bash(grep:*)` plus `Bash(grep * ; echo *)`. Same pinning-ADR rationale as `jq` — `grep` is a pure data transformer with no code-eval, no shell-out, no file writes. Binary-level allow is safe. The semicolon-echo sibling silences the `grep ... ; echo "exit=$?"` workaround pattern (used to disambiguate "no matches" from "error" since `grep` exits 1 when the pattern doesn't match, which the shell treats as a failure).
  - **Hook test-runner entries** (silent execution of bundled hook test suites that reviewer agents reach for after `.claude/settings.json` or hook-script changes — empirically observed three times in a single review before silencing): `Bash(.claude/hooks/tests/safety-harness/run-tests.sh:*)` (Stage 3) and `Bash(.claude/hooks/tests/approve-scratch-write/run-tests.sh:*)` (Stage 4). Same pinning-ADR rationale as `node_modules/.bin/vitest:*` — both runners are deterministic shell scripts that invoke a single fixed hook and exit, with no `-c`-equivalent escape hatch, so binary-level (script-path) allow is the right granularity. Pin to the script path, not the parent directory. Each entry is dead until its corresponding hook + test suite is in place — Stage 3 establishes the safety-harness side, Stage 4 establishes the SCRATCH-write side.
  - Append entries that are absent locally; do not deduplicate or reorder existing local entries. The `_comment` and `_comment_scratch_writes` keys are no-op fields for documentation purposes — fine to add.
- **`hooks.PreToolUse` block** — new top-level `hooks` key with the `PreToolUse` array containing two entries:
  1. **Bash matcher (safety-harness, Stage 3):** `matcher: "Bash"`, the `if`-filter alternation (`rm * | dd * | mkfs* | diskutil* | git push * | git reset * | gh repo * | psql * | supabase * | chmod *`), and the command pointing at `$CLAUDE_PROJECT_DIR/.claude/hooks/safety-harness.sh`.
  2. **Write matcher (SCRATCH-write hook, Stage 4):** `matcher: "Write"`, no `if`-filter (the script does its own scoping in pure shell — see the ADR's "trade-offs accepted" section for why an `if`-filter doesn't cleanly express path-prefix matching), and the command pointing at `$CLAUDE_PROJECT_DIR/.claude/hooks/approve-scratch-write.sh`.

  If `hooks.PreToolUse` is absent, add the whole block with both entries. If present with other entries, append each as an additional array element. **Do not overwrite local hook entries.** If only the Bash entry is present (i.e. the project applied an earlier shape of this packet that didn't include the SCRATCH-write hook), append the Write entry — that's the Stage 4 delta.

**`.claude/agents/triage-reviewer.md`**
- Adopted across PRs #19, `f6050b2`, and PR #21. Three changes: (1) reads patterns from the patterns file via `grep -E -f` rather than inline regex; (2) gained a one-line note explaining its rubric doesn't need recalibration (path-based HIGH triggers are runtime concerns); (3) fail-closed contract escalates to `team` tier when the patterns file is missing or unreadable. If the local file is the older form (inline secret regex on the command line), replace wholesale and verify nothing project-specific was added.

**`.claude/agents/security-specialist.md`**
- Recalibrated by PR #21. Gained a `Threat model` section after Role and a recalibrated `Review Standards` block. Merge by adding the `Threat model` section if absent and reconciling `Review Standards` — keep local-specific stack notes, fold in the threat-model-aware language.

**`.claude/agents/devils-advocate.md`, `.claude/agents/requirements-auditor.md`, `.claude/agents/technical-skeptic.md`**
- All three gained `WebFetch` in their `tools:` frontmatter via PR #25. **Apply ONLY the frontmatter `tools:` line change** — change `tools: Bash, Read, Glob, Grep` to `tools: Bash, Read, Glob, Grep, WebFetch`. If the local frontmatter already lists `WebFetch`, no change.
- **DO NOT apply any body diffs from the source.** The source body of these spec-review agents may include placeholder stack mentions (`Readwise API`, `Perplexity API`, `Supabase Realtime`, `Cloudflare Workers` etc.) that derivative projects often customise with their actual stack. Applying a body diff verbatim would clobber that customisation and silently degrade review quality. The packet's net contribution to these three files is the WebFetch frontmatter line and nothing else; surface any body differences you observe between source and local but do not write them.

**`.claude/skills/review-pr/SKILL.md` and `.claude/skills/review-pr-team/SKILL.md`**
- PR #22 added a Read-then-Write fallback paragraph to both files, removing the need for `rm -f /tmp/...` cleanup. The paragraph appears under the "Posting the comment" section in `review-pr/SKILL.md` and the equivalent in `review-pr-team/SKILL.md`. The skill text now references `SCRATCH/review-pr-...` paths (not `/tmp/review-pr-...`) — derivative projects upgrading from an earlier shape of this packet should sweep the skill files for any remaining `/tmp/` or `.claude/scratch/` paths and replace with `SCRATCH/`. If the local skill files don't have this paragraph, add it. If they have a different stale-file workaround (e.g. `rm -f`), replace it with the Read-then-Write text.

**`.claude/skills/review-spec/SKILL.md`**
- PR #25 changed the spec-resolution step from `find SPECIFICATIONS/...` to using the `Glob` tool. Replace the bash code block + surrounding sentence with the Glob-based instruction. Localised wording around it can stay as-is.

**`REFERENCE/CLAUDE.md`**
- Two index entries to add under "Files in this directory": one for `safety-harness.md` (Stage 3, PR #24) and one for `scratch-write-hook.md` (Stage 4, PR #33). Add each in alphabetical/topical order alongside existing entries.

**`REFERENCE/decisions/CLAUDE.md`**
- Three index entries to add: one for the threat-model ADR (`2026-04-25-pr-review-threat-model.md`, Stage 1), one for the allow-list pinning principle ADR (`2026-04-26-allowlist-pinning-principle.md`, Stage 2 — already in the "Copy verbatim" list above), and one for the SCRATCH-write hook ADR (`2026-04-26-scratch-write-pretooluse-hook.md`, Stage 4). The index typically lists ADRs newest-first.

**`SPECIFICATIONS/ARCHIVE/CLAUDE.md`**
- PR #23 added a "Link convention for archived specs" rule. Apply only if the project uses the `SPECIFICATIONS/ARCHIVE/` pattern. The rule is short and self-contained — append it.
- **DO NOT copy any "Completed phases" / index entries from the source file.** The source `SPECIFICATIONS/ARCHIVE/CLAUDE.md` lists template-internal archived specs (e.g. `pretooluse-safety-harness.md`, `INVESTIGATION-claude-code-write-path-normalisation.md`) that derivative projects don't have. Index entries in this file should reflect the *local* archive contents; only the link-convention rule itself is generic and shippable.

### Conditional

Files that may or may not be relevant depending on whether the target project has related infrastructure.

- **`.gitignore`** — apply only if not already covered by a previous packet. The relevant entries are `.claude/project-config.local.json` (from the previous packet) — no new gitignore entries are introduced by this rollup.
- **`README.md` (project root)** — minor updates only if the project's README references the older review behaviour. Most derivative projects will not need this.
- **`.claude/CLAUDE.md` — Severity calibration cross-reference** — verify there's a one-line pointer at the threat-model ADR somewhere in the file (the existing review-system section is a good location). If absent, add. Localised collaboration content stays as-is.

## Excluded by design — do NOT copy these even though they appear in the source PRs' diffs

- `SPECIFICATIONS/ARCHIVE/pretooluse-safety-harness.md` — template-internal historical spec record (the implementation is what matters; the spec is preserved for the template's own audit trail)
- `SPECIFICATIONS/ARCHIVE/INVESTIGATION-claude-code-write-path-normalisation.md` — the five-sighting diagnosis trail that motivated the SCRATCH-write hook. Template-internal historical context. Derivatives inherit the conclusion (the hook + the ADR + the ops doc); the diagnosis trail itself stays in the template. The SCRATCH-write hook ADR's "Hook compensates for an unfixed upstream defect" trade-off section points to the upstream URL for anyone who wants the breadcrumb.
- `REFERENCE/TEMPLATE-UPDATES/CLAUDE.md` and `REFERENCE/TEMPLATE-UPDATES/TEMPLATE.md` — the migration-packet-system infrastructure (introduced in PR #18). Template-internal: derivative projects don't need this scaffold unless they themselves intend to become templates for further forks, which is rare. Shipping them creates dead links in derivatives because the index inside `TEMPLATE-UPDATES/CLAUDE.md` points at packet directories (`./2026-04-pr-review-triage/`, `./2026-04-threat-model-and-safety-harness/`) that don't exist in derivative projects. If a derivative later wants to author its own packets, it can copy these two files at that point.
- `TEMPLATE-INSTRUCTIONS.md` — template-internal bootstrap doc; derivative projects either delete it after first clone or have their own version

## Apply prompt

> Copy the block below into the receiving project's Claude session. It is self-contained — the receiving Claude won't see this packet's surrounding context.

```
I want to roll out a template improvement to this project: threat-model calibration,
silent reviews, a PreToolUse safety-harness, and a PreToolUse SCRATCH-write hook. The
migration packet README is at:

  https://github.com/mannepanne/useful-assets-template/blob/main/REFERENCE/TEMPLATE-UPDATES/2026-04-threat-model-and-safety-harness/README.md

Source PRs: #18, #19, #21, #22, #23, #24, #25, #30, #31, #32, #33, #34 in
mannepanne/useful-assets-template.

How to fetch source files: use WebFetch on the raw GitHub URL pattern

  https://raw.githubusercontent.com/mannepanne/useful-assets-template/main/<path>

substituting <path> for any file listed in the manifest. Do NOT invent file contents —
every source file must come from the raw URL above.

Two fixture directories need bulk-fetching rather than enumeration:
- .claude/hooks/tests/safety-harness/fixtures/ — 39 pairs (78 files)
- .claude/hooks/tests/approve-scratch-write/fixtures/ — 6 pairs (12 files)

Use the GitHub tree API to list both directories once, then WebFetch each file:

  https://api.github.com/repos/mannepanne/useful-assets-template/git/trees/main?recursive=1

Filter the response to entries with path prefix
".claude/hooks/tests/safety-harness/fixtures/" and
".claude/hooks/tests/approve-scratch-write/fixtures/", and fetch each via the raw URL pattern.

Please:

1. WebFetch the packet README first and read it end-to-end. The "Why" section is
   load-bearing — the threat model is the foundational assumption that calibrates
   everything downstream.

2. **BEFORE applying anything**, surface this question to the user:

   "This packet's calibrations (severity defaults, safety-harness block/ask choices,
   PR-review tool grants) all assume a single trusted contributor or small team of
   mutually-trusted contributors. If this project's contributor model differs (open-
   source PRs from strangers, multi-team enterprise, regulated environments, junior
   developers as primary users), the threat-model ADR's tightening checklist applies
   before adopting the calibrations. Should I read the threat-model ADR and surface
   any calibration that should be tightened for this project, or proceed with the
   template defaults?"

   Wait for an answer before proceeding.

3. Create a feature branch (e.g. feature/adopt-threat-model-and-safety-harness).
   Do NOT work on main.

4. Apply the FOUR sub-changes IN ORDER (the README's "Application order" section
   describes dependencies):

   a. Threat-model ADR + agent severity calibration.
   b. Silent-review conventions (Tool invocation conventions section, allowlist
      additions, triage patterns file rename, dispatcher fallback, WebFetch grants
      on spec-review agents).
   c. Safety harness — establishes the hooks.PreToolUse block (first entry, Bash matcher).
   d. SCRATCH-write hook — appends the second entry to hooks.PreToolUse (Write matcher).
      Apply after Stage c so the block-merge is a single pass.

5. **For each "Copy verbatim" file**, check whether a file at that path exists locally.
   If not, WebFetch the source and create it. If it does, treat as "merge carefully"
   instead and flag the conflict.

6. **For each "Merge carefully" entry**, the manifest is section-level for the
   highest-conflict files (.claude/agents/CLAUDE.md, .claude/settings.json). Read the
   local version section-by-section, WebFetch the source, identify what to add/replace,
   and propose a per-section merge. Do NOT treat .claude/settings.json as a single-file
   merge — its three deltas (env, permissions.allow, hooks.PreToolUse) must be applied
   independently. The hooks.PreToolUse block now contains TWO entries (safety-harness
   and approve-scratch-write); append both if neither is present, or just the missing
   one if the other is already there.

7. **For triage-secret-patterns.txt → triage-scan-patterns.txt rename**: if the local
   file exists under the OLD name, delete it and create the new name. If neither exists,
   create the new name.

8. **chmod +x** on the four .sh files after fetching:
   - .claude/hooks/safety-harness.sh
   - .claude/hooks/tests/safety-harness/run-tests.sh
   - .claude/hooks/approve-scratch-write.sh
   - .claude/hooks/tests/approve-scratch-write/run-tests.sh
   Raw GitHub URLs do not preserve the executable bit. Without this step, the hook
   scripts will not run and the test runners will fail.

9. **For "Conditional" files**, evaluate the stated condition before deciding.

10. **Excluded files**: do NOT fetch any of the following even though they appear in the
    source PRs' diffs. All are template-internal historical context:
    - SPECIFICATIONS/ARCHIVE/pretooluse-safety-harness.md (template's own historical
      spec record)
    - SPECIFICATIONS/ARCHIVE/INVESTIGATION-claude-code-write-path-normalisation.md
      (the diagnosis trail that motivated the SCRATCH-write hook; the conclusion
      travels via the ADR, the trail stays in the template — the ADR points to the
      upstream URL for anyone who wants the diagnosis breadcrumb)
    - TEMPLATE-INSTRUCTIONS.md (template-bootstrap doc)

11. **Before writing ANY changes**, list every proposed edit with a one-line rationale,
    and flag every place where local customisation could be lost. Wait for user
    confirmation.

12. **After applying, run the verification commands from the packet** and report results.
    Two test-suite checks catch partial rollouts:
    - bash .claude/hooks/tests/safety-harness/run-tests.sh (Stage 3)
    - bash .claude/hooks/tests/approve-scratch-write/run-tests.sh (Stage 4)
    The test -f and grep -q checks are necessary but not sufficient — only the test
    runners confirm behaviour.
```

## Verification

Run each command below and report results. Most should exit 0; the safety-harness test suite should report 40/40 passing and the SCRATCH-write test suite should report 7/7 passing.

```bash
# Stage 1: Threat-model ADR + calibration
test -f REFERENCE/decisions/2026-04-25-pr-review-threat-model.md
grep -q '2026-04-25-pr-review-threat-model' REFERENCE/decisions/CLAUDE.md
test -f REFERENCE/decisions/2026-04-26-allowlist-pinning-principle.md
grep -q '2026-04-26-allowlist-pinning-principle' REFERENCE/decisions/CLAUDE.md
grep -q 'Severity calibration' .claude/agents/CLAUDE.md
grep -q 'threat-model' .claude/agents/security-specialist.md

# Stage 2: Silent reviews
grep -q 'Tool invocation conventions' .claude/agents/CLAUDE.md
grep -q 'Tool grant asymmetry' .claude/agents/CLAUDE.md
grep -q 'WebFetch' .claude/agents/technical-skeptic.md
grep -q 'WebFetch' .claude/agents/requirements-auditor.md
grep -q 'WebFetch' .claude/agents/devils-advocate.md
test -f .claude/agents/triage-scan-patterns.txt
test ! -f .claude/agents/triage-secret-patterns.txt   # old name must be gone
grep -q 'grep -E -f' .claude/agents/triage-reviewer.md
grep -q 'Read-then-Write' .claude/skills/review-pr/SKILL.md
grep -q 'Read-then-Write' .claude/skills/review-pr-team/SKILL.md
grep -q 'Glob' .claude/skills/review-spec/SKILL.md
grep -q 'Bash(git fetch \*)' .claude/settings.json
grep -q 'Bash(npm test:\*)' .claude/settings.json       # test/lint/typecheck allow-list applied
grep -q 'Bash(node_modules/.bin/vitest:\*)' .claude/settings.json
grep -q 'Bash(python3 -m json.tool:\*)' .claude/settings.json   # JSON-validation allow-list applied
grep -q 'Bash(jq:\*)' .claude/settings.json                     # jq allow-list applied
grep -q 'Bash(grep:\*)' .claude/settings.json                   # bare grep allow-list applied
grep -q 'safety-harness/run-tests.sh:\*' .claude/settings.json  # safety-harness test-runner allow-list applied
grep -q 'approve-scratch-write/run-tests.sh:\*' .claude/settings.json  # SCRATCH-write test-runner allow-list applied
test -f SCRATCH/.gitignore                                      # scratch dir present
grep -q 'Read(/SCRATCH/' .claude/settings.json                  # SCRATCH read allow-list applied
! grep -q 'Write(/SCRATCH/' .claude/settings.json               # dead Write entries must be absent
! grep -q 'Write(SCRATCH/' .claude/settings.json
grep -q 'SCRATCH/' .claude/skills/review-pr/SKILL.md            # review skills point at scratch dir
grep -q 'SCRATCH/' .claude/skills/review-pr-team/SKILL.md

# Stage 3: Safety harness
test -x .claude/hooks/safety-harness.sh                # chmod +x landed
test -x .claude/hooks/tests/safety-harness/run-tests.sh
test -f REFERENCE/safety-harness.md
grep -q 'safety-harness' REFERENCE/CLAUDE.md
grep -q 'PreToolUse' .claude/settings.json
grep -q 'safety-harness.sh' .claude/settings.json

# Fixture count: 39 pairs = 78 files
test "$(ls .claude/hooks/tests/safety-harness/fixtures/*.in.json 2>/dev/null | wc -l)" -eq 39
test "$(ls .claude/hooks/tests/safety-harness/fixtures/*.expected.json 2>/dev/null | wc -l)" -eq 39

# Stage 4: SCRATCH-write hook
test -x .claude/hooks/approve-scratch-write.sh         # chmod +x landed
test -x .claude/hooks/tests/approve-scratch-write/run-tests.sh
test -f .claude/hooks/lib/parse-tool-input.sh          # shared parse helper
test -f REFERENCE/scratch-write-hook.md                # ops doc
test -f REFERENCE/decisions/2026-04-26-scratch-write-pretooluse-hook.md   # ADR
grep -q '2026-04-26-scratch-write-pretooluse-hook' REFERENCE/decisions/CLAUDE.md   # ADR indexed
grep -q 'scratch-write-hook' REFERENCE/CLAUDE.md       # ops doc indexed
grep -q 'approve-scratch-write.sh' .claude/settings.json   # hook registered
grep -q '_comment_scratch_writes' .claude/settings.json    # documented why no Write(/SCRATCH/...) entries

# Fixture count: 6 pairs = 12 files (7th test needs no fixture)
test "$(ls .claude/hooks/tests/approve-scratch-write/fixtures/*.in.json 2>/dev/null | wc -l)" -eq 6
test "$(ls .claude/hooks/tests/approve-scratch-write/fixtures/*.expected.json 2>/dev/null | wc -l)" -eq 6

# The two checks that catch a partial rollout: run both test suites end-to-end
bash .claude/hooks/tests/safety-harness/run-tests.sh
bash .claude/hooks/tests/approve-scratch-write/run-tests.sh
```

### Required smoke tests (cannot be scripted — fixtures don't substitute)

The fixture suites verify the hook scripts' JSON output. They cannot verify that Claude Code is actually firing the hooks before the relevant tool gates fire — that's a registration concern, and registration only fails empirically in a fresh session. Run all three smoke tests below; if any fails, the hook is not actually wired up and the corresponding test suite passing is a misleading green.

1. **Safety-harness fires (Stage 3 registration check).** Type `rm -rf $HOME/test-nonexistent` at the prompt (the path doesn't exist, so it's a no-op even if it ran). The hook should block with a clear reason. Then prefix with `SAFETY_HARNESS_OFF=1 ` and confirm the bypass works. If the block doesn't fire, the hook is misregistered — the matcher in `.claude/settings.json` `hooks.PreToolUse[0]` is not pointing at the script, or the script isn't executable.
2. **SCRATCH-write hook fires silently (Stage 4 registration check).** In a *fresh* Claude Code session (not the one that just merged the rollout — registration is read at session start), run any `/review-*` skill against any PR. The skill writes its comment body to `SCRATCH/review-pr-<N>-*.md` via the `Write` tool. **No approval prompt should appear.** If the prompt fires, the hook is misregistered — see [`REFERENCE/scratch-write-hook.md`](../../scratch-write-hook.md) → "Troubleshooting → The prompt still fires when writing to SCRATCH/" for the diagnosis steps.
3. **Reviewer agents run silent (Stage 2 conventions check).** Run `/review-spec` once on any spec and confirm no Bash approval prompts surface during the reviewer agents' work. If prompts appear, the Tool invocation conventions section didn't land or the allowlist additions are incomplete.

## Notes for the receiving Claude

- **The threat model is the load-bearing assumption.** Do not silently ship the template's calibration into a project whose contributor model differs. Step 2 of the apply prompt is mandatory — surface the question, wait for the user to answer.
- **Application order matters.** Stage 1 (threat-model ADR) must precede Stage 2 (silent-review conventions reference the ADR), Stage 3 (safety-harness docs link to the ADR's tightening checklist), and Stage 4 (SCRATCH-write hook ADR cross-references the threat-model ADR for symlink/exotic-filename carve-outs). Stage 4 must follow Stage 3 — both write into `hooks.PreToolUse` and adjacency makes the merge a single pass. If you apply the hooks before the ADR, the cross-references go nowhere.
- **`.claude/agents/CLAUDE.md` accumulates four sections.** Don't merge it as a single file — merge each section independently. The local file may have any subset of the four sections from earlier packets or piecemeal adoption.
- **`.claude/settings.json` has three independent deltas.** The `env` block is likely already present (from the previous packet). The `permissions.allow` array gets new entries appended (and gains a `_comment_scratch_writes` key documenting why no `Write(/SCRATCH/...)` entries are present). The `hooks` block is new and contains TWO `PreToolUse` entries (Bash matcher → safety-harness, Write matcher → approve-scratch-write). Treat each delta as its own merge; do not overwrite the file wholesale.
- **`triage-secret-patterns.txt` was renamed to `triage-scan-patterns.txt`.** If the receiving project is mid-adoption and has the old name, delete it. If it has neither, create the new name. Don't ship both.
- **`chmod +x` on all four `.sh` files is essential.** Raw GitHub URLs do not preserve executable bits. Without this step, the hooks silently fail (Claude Code will error trying to invoke a non-executable script) and the test runners won't run. Apply `chmod +x` immediately after WebFetch for each. The four files are: `safety-harness.sh`, `safety-harness/run-tests.sh`, `approve-scratch-write.sh`, `approve-scratch-write/run-tests.sh`.
- **Two fixture directories need bulk-fetching.** The 39-pair safety-harness fixtures and the 6-pair SCRATCH-write fixtures are both small enough to fetch via the GitHub tree API. Do not manually list filenames in the apply plan — that's noise and risks transcription errors.
- **The two test suites are the single most useful verification checks.** All the `test -f` and `grep -q` checks confirm presence; only the test runners confirm behaviour. If `bash .claude/hooks/tests/safety-harness/run-tests.sh` or `bash .claude/hooks/tests/approve-scratch-write/run-tests.sh` exits non-zero, something is wrong (likely a fixture missing, the script not executable, the parse helper missing, or a regex/bash quirk on the receiving system).
- **Excluded files**: three template-internal files appear in the source PRs' diffs but should NOT be copied: `SPECIFICATIONS/ARCHIVE/pretooluse-safety-harness.md` (template's own historical spec record), `SPECIFICATIONS/ARCHIVE/INVESTIGATION-claude-code-write-path-normalisation.md` (diagnosis trail; the conclusion travels via the SCRATCH-write hook ADR, which points to the upstream URL for the trail), and `TEMPLATE-INSTRUCTIONS.md` (template-bootstrap doc).
- **Shared parse helper at `.claude/hooks/lib/parse-tool-input.sh`** — used by both `safety-harness.sh` and `approve-scratch-write.sh`. Stage 3 may already have placed it; if so, Stage 4 doesn't need to re-fetch. If a content diff between local and source surfaces, flag it rather than overwriting — the helper is small and a difference would suggest local divergence worth investigating.
- **Project-specific stack mentions in `security-specialist.md`** — the template's reference includes generic mentions like "Supabase RLS", "Cloudflare Workers". If the receiving project uses different infrastructure, fold the threat-model-aware language in but keep local stack-specific guidance.
