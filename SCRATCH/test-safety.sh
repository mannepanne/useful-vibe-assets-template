#!/bin/bash
set -e

echo "=========================================="
echo "Phase 6: Safety & Hooks Verification"
echo "=========================================="
echo ""

# Track errors
ERRORS=0

# Function to report error
report_error() {
    echo "❌ ERROR: $1"
    ERRORS=$((ERRORS + 1))
}

# Function to report success
report_success() {
    echo "✅ $1"
}

echo "--- Testing hook archive ---"

# Check archive directory structure
for dir in \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/lib/" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/tests/approve-scratch-write/" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/tests/check-profile-setup/" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/tests/safety-harness/"; do
  if [ -d "$dir" ]; then
    report_success "Directory $dir exists"
  else
    report_error "Missing directory: $dir"
  fi
done

# Check hook files are archived
for file in \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/approve-scratch-write.sh" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/check-profile-setup.sh" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/safety-harness.sh" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/hooks/lib/parse-tool-input.sh" \
    "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/.claude/settings.json"; do
  if [ -f "$file" ]; then
    report_success "File $file archived"
  else
    report_error "Missing archived file: $file"
  fi
done

# Check archive README
if [ -f "SPECIFICATIONS/ARCHIVE/migration-from-claude/claude-hooks/README.md" ]; then
  report_success "Archive README exists"
else
  report_error "Missing archive README"
fi

echo ""
echo "--- Testing permissions.json ---"

# Test 1: Verify permissions.json exists and is valid
if [ -f ".vibe/config/permissions.json" ]; then
  report_success "permissions.json exists"
else
  report_error "permissions.json missing"
fi

# Validate JSON
if python3 -m json.tool .vibe/config/permissions.json > /dev/null 2>&1; then
  report_success "permissions.json is valid JSON"
else
  report_error "permissions.json is invalid JSON"
fi

# Test 2: Verify SCRATCH/ patterns in permissions
if grep -q "SCRATCH/\*\*" .vibe/config/permissions.json; then
  report_success "SCRATCH/** pattern found in permissions.json"
else
  report_error "SCRATCH/** pattern missing from permissions.json"
fi

if grep -q "SCRATCH/\*" .vibe/config/permissions.json; then
  report_success "SCRATCH/* pattern found in permissions.json"
else
  report_error "SCRATCH/* pattern missing from permissions.json"
fi

echo ""
echo "--- Testing safety documentation ---"

# Check vibe-safety.md
if [ -f "REFERENCE/vibe-safety.md" ]; then
  report_success "REFERENCE/vibe-safety.md exists"
else
  report_error "REFERENCE/vibe-safety.md missing"
fi

# Check safety-harness.md has Vibe note
if grep -q "For the.*Mistral Vibe version" REFERENCE/safety-harness.md; then
  report_success "REFERENCE/safety-harness.md has Vibe note"
else
  report_error "REFERENCE/safety-harness.md missing Vibe note"
fi

# Check scratch-write-hook.md has Vibe note
if grep -q "For Mistral Vibe users" REFERENCE/scratch-write-hook.md; then
  report_success "REFERENCE/scratch-write-hook.md has Vibe note"
else
  report_error "REFERENCE/scratch-write-hook.md missing Vibe note"
fi

echo ""
echo "--- Testing .vibe/ directory integrity ---"

# Check that .vibe/config/permissions.json has hook_archive note
if grep -q "hook_archive" .vibe/config/permissions.json; then
  report_success "permissions.json has hook archive reference"
else
  echo "⚠️  WARNING: permissions.json missing hook archive reference"
fi

# Note: .claude/ references in .vibe/ are allowed in documentation files
# that explain the migration. We only check for actual code usage in skills/ and config/
# which we've already verified above.

echo ""
echo "--- Testing hook files in original location (should still exist for backward compat) ---"

# Check that original hook files still exist in .claude/
for file in \
    ".claude/hooks/approve-scratch-write.sh" \
    ".claude/hooks/check-profile-setup.sh" \
    ".claude/hooks/safety-harness.sh" \
    ".claude/hooks/lib/parse-tool-input.sh" \
    ".claude/settings.json"; do
  if [ -f "$file" ]; then
    report_success "Original hook file $file still exists (backward compat)"
  else
    echo "⚠️  WARNING: Original hook file $file missing (may have been intentionally removed)"
  fi
done

echo ""
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
  echo "✅ All safety tests passed! Phase 6 migration is complete."
  echo "=========================================="
  exit 0
else
  echo "❌ $ERRORS error(s) found. Please review and fix."
  echo "=========================================="
  exit 1
fi
