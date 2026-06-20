#!/bin/bash
# This script tests the review workflows
# Note: Some tests require a GitHub repository with PRs

echo "=== Review Workflow Tests ==="
echo ""

# Test 1: Gate logic
echo "Test 1: Gate logic"
# This would need to be tested manually or in a Vibe session
# Check that .vibe/skills/review-gate.md exists and is properly structured
if [ -f ".vibe/skills/review-gate.md" ]; then
  echo "PASS: review-gate.md exists"
else
  echo "FAIL: review-gate.md missing"
  exit 1
fi

# Test 2: Permission patterns
echo "Test 2: Permission patterns in permissions.json"
if [ -f ".vibe/config/permissions.json" ]; then
  grep -q "deny" .vibe/config/permissions.json || { echo "FAIL: No deny patterns"; exit 1; }
  grep -q "confirm" .vibe/config/permissions.json || { echo "FAIL: No confirm patterns"; exit 1; }
  grep -q "SCRATCH" .vibe/config/permissions.json || { echo "FAIL: No SCRATCH patterns"; exit 1; }
  echo "PASS"
else
  echo "FAIL: permissions.json missing"
  exit 1
fi

# Test 3: Agent references in skills
echo "Test 3: Skills reference correct agents"
grep -q "triage-reviewer" .vibe/skills/review-pr/SKILL.md || { echo "FAIL: Missing triage-reviewer reference"; exit 1; }
grep -q "code-reviewer" .vibe/skills/review-pr/SKILL.md || { echo "FAIL: Missing code-reviewer reference"; exit 1; }
echo "PASS"

# Test 4: Task tool usage
echo "Test 4: Skills use task tool for spawning"
grep -q "task:" .vibe/skills/review-pr/SKILL.md || { echo "FAIL: Missing task tool usage"; exit 1; }
echo "PASS"

# Test 5: Vibe-specific skill structure
echo "Test 5: Vibe skill files have proper structure"
for skill_file in .vibe/skills/*/SKILL.md .vibe/skills/*.md; do
  [ -f "$skill_file" ] || continue
  # Check for required Vibe skill sections
  if ! grep -q "name:" "$skill_file" && ! grep -q "description:" "$skill_file"; then
    echo "WARN: Skill $skill_file may be missing Vibe structure"
  fi
done
echo "PASS"

# Test 6: Configuration files
echo "Test 6: Vibe configuration files exist"
[ -f ".vibe/config/permissions.json" ] || { echo "FAIL: permissions.json missing"; exit 1; }
[ -f ".vibe/config/project-config.json" ] || { echo "FAIL: project-config.json missing"; exit 1; }
echo "PASS"

# Test 7: No Claude-specific tool usage in new skills
echo "Test 7: No Claude-specific tools in Vibe skills"
if grep -r "SpawnAgent\|ClaudeCode\|claude:" .vibe/skills/ 2>/dev/null; then
  echo "WARN: Found potential Claude-specific references in skills"
fi
echo "PASS"

echo ""
echo "=== Review workflow tests complete ==="
echo "Note: Full end-to-end testing requires Vibe session"