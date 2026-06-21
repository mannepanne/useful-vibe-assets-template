#!/usr/bin/env bash
# ABOUT: Fixture tests for check-profile-setup.sh
# ABOUT: Creates temp directories to simulate project state; tests are filesystem-based.

set -euo pipefail

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/check-profile-setup.sh"
PASS=0
FAIL=0

run_hook() {
  local project_dir="$1"
  CLAUDE_PROJECT_DIR="$project_dir" bash "$HOOK"
}

assert_signal_emitted() {
  local label="$1"
  local output="$2"
  if echo "$output" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ctx = data.get('hookSpecificOutput', {}).get('additionalContext', '')
assert 'PERSONAL_PROFILE_SETUP_REQUIRED' in ctx, 'signal not in additionalContext'
" 2>/dev/null; then
    echo "PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $label (expected PERSONAL_PROFILE_SETUP_REQUIRED in JSON output)"
    FAIL=$((FAIL + 1))
  fi
}

assert_silent() {
  local label="$1"
  local output="$2"
  if [ -z "$output" ]; then
    echo "PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $label (expected no output, got: $output)"
    FAIL=$((FAIL + 1))
  fi
}

# --- Test 1: sentinel present + no .local → signal emitted ---
T=$(mktemp -d)
mkdir -p "$T/.claude/COLLABORATION"
echo "<!-- profile_status: default -->" > "$T/.claude/COLLABORATION/personal-profile.md"
OUTPUT=$(run_hook "$T")
assert_signal_emitted "sentinel present + no .local → signal emitted" "$OUTPUT"
rm -rf "$T"

# --- Test 2: sentinel absent + no .local → silent ---
T=$(mktemp -d)
mkdir -p "$T/.claude/COLLABORATION"
echo "# My personalised profile" > "$T/.claude/COLLABORATION/personal-profile.md"
OUTPUT=$(run_hook "$T")
assert_silent "sentinel absent + no .local → silent" "$OUTPUT"
rm -rf "$T"

# --- Test 3: .local exists (with sentinel in .md) → silent ---
T=$(mktemp -d)
mkdir -p "$T/.claude/COLLABORATION"
echo "<!-- profile_status: default -->" > "$T/.claude/COLLABORATION/personal-profile.md"
echo "# My local profile" > "$T/.claude/COLLABORATION/personal-profile.local.md"
OUTPUT=$(run_hook "$T")
assert_silent ".local exists → silent (even if sentinel present)" "$OUTPUT"
rm -rf "$T"

# --- Test 4: personal-profile.md missing → silent ---
T=$(mktemp -d)
mkdir -p "$T/.claude/COLLABORATION"
OUTPUT=$(run_hook "$T")
assert_silent "personal-profile.md missing → silent" "$OUTPUT"
rm -rf "$T"

# --- Test 5: CLAUDE_PROJECT_DIR unset → silent (no crash) ---
OUTPUT=$(CLAUDE_PROJECT_DIR="" bash "$HOOK" 2>&1 || true)
assert_silent "CLAUDE_PROJECT_DIR empty string → silent" "$OUTPUT"

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
