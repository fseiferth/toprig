#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# rollback-steward.sh -- Removes all claude-md-steward artifacts
# Usage: ./scripts/rollback-steward.sh [--dry-run]
# ENH-011
set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then DRY_RUN=true; fi

run_or_echo() {
  if [ "$DRY_RUN" = true ]; then echo "[DRY RUN] $*"; else eval "$@"; fi
}

echo "=== claude-md-steward rollback ==="

# 1. Remove skill
run_or_echo "rm -rf ~/.claude/skills/claude-md-steward/"

# 2. Remove command
run_or_echo "rm -f ~/.claude/commands/claude-md-steward.md"

# 3. Remove gate script
run_or_echo "rm -f ./scripts/gate-claude-md.sh"

# 4. Remove hook integration (sed out the gate-claude-md lines)
if [ -f .git/hooks/pre-commit ]; then
  run_or_echo "sed -i.bak '/gate-claude-md/d' .git/hooks/pre-commit"
  run_or_echo "rm -f .git/hooks/pre-commit.bak"
fi

# 5. Remove marker + audit log
run_or_echo "rm -f ~/.claude/state/claude-md-steward-last-run"
run_or_echo "rm -f ~/.claude/state/steward-decisions.log"
run_or_echo "rm -f ~/.claude/state/gate-claude-md.log"

# 6. Revert CLAUDE.md entries (requires manual git revert or edit)
echo ""
echo "MANUAL: Remove 'claude-md-steward' references from:"
echo "  - ~/.claude/CLAUDE.md (self-sufficient + auto-invoke)"
echo "  - CLAUDE.md (Change Management section)"
echo "  - Use: git diff to review, then edit"

echo ""
echo "Rollback complete. Verify: grep -rc 'claude-md-steward' ~/.claude/CLAUDE.md CLAUDE.md"
