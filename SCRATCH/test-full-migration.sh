#!/bin/bash
set -e

echo "=== Full Migration Test Suite ==="
echo ""

# Test 1: Directory structure
echo "Test 1: .vibe/ directory structure"
for dir in .vibe .vibe/config .vibe/agents .vibe/skills .vibe/COLLABORATION; do
  [ -d "$dir" ] || { echo "FAIL: Missing directory $dir"; exit 1; }
done
echo "PASS"

# Test 2: Required files
echo "Test 2: Required files exist"
for file in \
  .vibe/AGENTS.md \
  .vibe/README.md \
  .vibe/config/permissions.json \
  .vibe/config/project-config.json \
  .vibe/config/README.md \
  .vibe/agents/AGENTS.md \
  .vibe/skills/AGENTS.md; do
  [ -f "$file" ] || { echo "FAIL: Missing file $file"; exit 1; }
done
echo "PASS"

# Test 3: Agent files
echo "Test 3: Agent files exist"
for agent in code-reviewer light-reviewer triage-reviewer security-specialist \
            product-reviewer architect-reviewer technical-writer \
            requirements-auditor technical-skeptic devils-advocate; do
  [ -f ".vibe/agents/${agent}.md" ] || { echo "FAIL: Missing agent ${agent}.md"; exit 1; }
done
echo "PASS"

# Test 4: Skill files
echo "Test 4: Skill files exist"
for skill in review-pr review-pr-team review-spec review-gate \
            post-review-follow-through check-profile-setup setup-profile; do
  [ -f ".vibe/skills/${skill}/SKILL.md" ] || [ -f ".vibe/skills/${skill}.md" ] || \
    { echo "FAIL: Missing skill ${skill}"; exit 1; }
done
echo "PASS"

# Test 5: Documentation files
echo "Test 5: Documentation files exist"
for file in \
  REFERENCE/vibe-learning-notes.md \
  REFERENCE/vibe-architecture-overview.md \
  REFERENCE/vibe-permissions.md \
  REFERENCE/vibe-safety.md \
  REFERENCE/scratch-write-hook.md; do
  [ -f "$file" ] || { echo "FAIL: Missing documentation ${file}"; exit 1; }
done
echo "PASS"

# Test 6: Archive completeness
echo "Test 6: Archive completeness"
[ -d "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-originals" ] || { echo "FAIL: Missing claude-originals archive"; exit 1; }
[ -d "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks" ] || { echo "FAIL: Missing claude-hooks archive"; exit 1; }
echo "PASS"

# Test 7: No .claude/ references (except in archive and .claude/ dir)
echo "Test 7: No .claude/ references outside archive and .claude/ dir"
if grep -r "\.claude/" --include="*.md" . | grep -v "SPECIFICATIONS/ARCHIVE/" | grep -v "\.claude/" | grep -v "\.git/"; then
  echo "FAIL: Found .claude/ references outside archive and .claude/ dir"
  exit 1
fi
echo "PASS"

# Test 8: Check CLAUDE.md references (allow in documentation)
echo "Test 8: CLAUDE.md references are in appropriate contexts"
# Allow CLAUDE.md references in:
# - Archive directories
# - .claude/ directory (backward compatibility)
# - Documentation files that explain migration context
# Only fail if found in SKILL.md or agent definition files
if grep -r "CLAUDE\.md" --include="*.md" .vibe/skills/ .vibe/agents/ 2>/dev/null; then
  echo "FAIL: Found CLAUDE.md references in skill or agent files"
  exit 1
fi
echo "PASS"

# Test 9: JSON validity
echo "Test 9: JSON configuration files are valid"
for file in .vibe/config/*.json; do
  [ -f "$file" ] && python3 -m json.tool "$file" > /dev/null || { echo "FAIL: Invalid JSON in $file"; exit 1; }
done
echo "PASS"

# Test 10: Git ignore entries
echo "Test 10: .gitignore has .vibe/ entries"
grep -q "\.vibe/" .gitignore || { echo "FAIL: Missing .vibe/ in .gitignore"; exit 1; }
grep -q "\.vibe/COLLABORATION/personal-profile.local.md" .gitignore || { echo "FAIL: Missing personal-profile.local.md in .gitignore"; exit 1; }
grep -q "\.vibe/config/project-config.local.json" .gitignore || { echo "FAIL: Missing project-config.local.json in .gitignore"; exit 1; }
echo "PASS"

echo ""
echo "=== All migration tests passed! ==="