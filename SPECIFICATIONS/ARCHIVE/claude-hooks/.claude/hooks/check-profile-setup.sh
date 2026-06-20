#!/usr/bin/env bash
# ABOUT: SessionStart hook — detects missing personal-profile.local.md and
# ABOUT: default sentinel in personal-profile.md; signals first-run setup.
#
# Decision rationale: REFERENCE/decisions/2026-05-24-personal-profile-setup-sentinel.md
# Operations / extension / removal: REFERENCE/profile-setup-hook.md

set -u

LOCAL="${CLAUDE_PROJECT_DIR:-}/.claude/COLLABORATION/personal-profile.local.md"
PROFILE="${CLAUDE_PROJECT_DIR:-}/.claude/COLLABORATION/personal-profile.md"

# Local file exists — operator has already personalised on this machine.
if [ -f "$LOCAL" ]; then
  exit 0
fi

# Default profile not present — nothing to detect.
if [ ! -f "$PROFILE" ]; then
  exit 0
fi

if grep -q "<!-- profile_status: default -->" "$PROFILE"; then
  python3 -c "
import json
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': 'PERSONAL_PROFILE_SETUP_REQUIRED: The personal-profile.md file still contains the default template profile and personal-profile.local.md does not exist. Before doing anything else this session, run the profile setup flow described in .claude/COLLABORATION/profile-setup-flow.md.'
    }
}))
"
fi

exit 0
