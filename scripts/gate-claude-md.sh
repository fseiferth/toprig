#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# gate-claude-md.sh -- Type 1 enforcement for CLAUDE.md ecosystem changes
# Detects governance doc modifications and warns if steward wasn't invoked.
# Reference: ~/.claude/skills/claude-md-steward/SKILL.md
# Usage: ./scripts/gate-claude-md.sh [--force]
# Bash 3.2+ compatible (no associative arrays, no readarray, safe empty-array handling)
# ENH-011
set -eo pipefail
# NOTE: -u omitted intentionally. Bash 3.2 (macOS default) crashes on
# ${#array[@]} when array is empty under set -u. We use explicit checks instead.

LOG_FILE="$HOME/.claude/state/gate-claude-md.log"
MARKER="$HOME/.claude/state/claude-md-steward-last-run"
TTL_SECONDS=3600  # 60 minutes

log_event() {
  mkdir -p "$HOME/.claude/state"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $*" >> "$LOG_FILE"
}

compute_gov_hash() {
  # Deterministic hash of staged governance content + global CLAUDE.md
  # MUST match the computation in ~/.claude/skills/claude-md-steward/SKILL.md Step 1.8
  local hash
  hash=$({
    git diff --cached -- CLAUDE.md SDLC-ROLE-MAPPING.md HANDOVER_PROTOCOLS.md \
      ENGINEERING_BEST_PRACTICES.md GOVERNANCE_OPERATIONS_GUIDE.md EMERGENCY_PROCEDURES.md 2>/dev/null
    cat "$HOME/.claude/CLAUDE.md" 2>/dev/null
  } | shasum -a 256 | cut -d' ' -f1)
  echo "$hash"
}

# Verify we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "gate-claude-md: Not a git repository. Skipping."
  exit 0
fi

# Governance-sensitive files (basename matching with -F for literal match)
WATCHED_FILES=(
  "CLAUDE.md"
  "SDLC-ROLE-MAPPING.md"
  "HANDOVER_PROTOCOLS.md"
  "ENGINEERING_BEST_PRACTICES.md"
  "GOVERNANCE_OPERATIONS_GUIDE.md"
  "EMERGENCY_PROCEDURES.md"
)

# --- Global CLAUDE.md drift detection ---
REPO_ROOT=$(git rev-parse --show-toplevel)
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
SNAPSHOT="$REPO_ROOT/docs/claude-md-snapshots/global-CLAUDE.md"
GLOBAL_DRIFT=false

if [ ! -f "$GLOBAL_CLAUDE" ]; then
  echo "gate-claude-md: ~/.claude/CLAUDE.md not found — skipping drift detection."
else
  if ! diff -q "$GLOBAL_CLAUDE" "$SNAPSHOT" >/dev/null 2>&1; then
    GLOBAL_DRIFT=true
  fi
fi

# Check staged files
if git rev-parse HEAD >/dev/null 2>&1; then
  STAGED=$(git diff --cached --name-only 2>/dev/null || echo "")
else
  STAGED=$(git diff --cached --name-only 2>/dev/null || echo "")
fi

GOVERNANCE_CHANGED=()
for file in "${WATCHED_FILES[@]}"; do
  if [ -n "$STAGED" ] && echo "$STAGED" | grep -qF "$file"; then
    GOVERNANCE_CHANGED+=("$file")
  fi
done

# Also check global CLAUDE.md via snapshot (staged) or drift (content mismatch)
if [ -n "$STAGED" ] && echo "$STAGED" | grep -qF "docs/claude-md-snapshots/global-CLAUDE.md"; then
  GOVERNANCE_CHANGED+=("~/.claude/CLAUDE.md (via snapshot)")
fi
if [ "$GLOBAL_DRIFT" = true ]; then
  GOVERNANCE_CHANGED+=("~/.claude/CLAUDE.md (DRIFT detected — snapshot out of sync)")
fi

# Safe empty-array check (Bash 3.2 compatible)
if [ "${#GOVERNANCE_CHANGED[@]:-0}" -eq 0 ] 2>/dev/null || [ -z "${GOVERNANCE_CHANGED+x}" ]; then
  echo "gate-claude-md: No governance files in this change."
  exit 0
fi

echo "gate-claude-md: Governance files modified:"
for f in "${GOVERNANCE_CHANGED[@]}"; do
  echo "  - $f"
done

# Check for steward marker with TTL and format validation
if [ -f "$MARKER" ]; then
  MARKER_CONTENT=$(cat "$MARKER" 2>/dev/null || echo "")

  # Validate marker format: <ISO8601> mode=<0|1> invoker=skill
  if ! echo "$MARKER_CONTENT" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z mode=[012] invoker=skill( hash=[a-f0-9]{64})?$'; then
    echo "gate-claude-md: WARNING: Marker file has invalid format. Treating as absent."
    log_event "MARKER_INVALID format='$MARKER_CONTENT'"
  else
    # Extract timestamp and check TTL (60 minutes)
    MARKER_TS=$(echo "$MARKER_CONTENT" | cut -d' ' -f1)
    if command -v python3 >/dev/null 2>&1; then
      AGE_SECONDS=$(python3 -c "
from datetime import datetime, timezone
ts = datetime.strptime('$MARKER_TS', '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=timezone.utc)
print(int((datetime.now(timezone.utc) - ts).total_seconds()))
" 2>/dev/null || echo "99999")
    else
      # Fallback: accept marker if python3 unavailable (log warning)
      AGE_SECONDS=0
      log_event "TTL_SKIP python3_unavailable"
    fi

    if [ "$AGE_SECONDS" -le "$TTL_SECONDS" ]; then
      # --- Content hash verification ---
      MARKER_HASH=$(echo "$MARKER_CONTENT" | grep -oE 'hash=[a-f0-9]{64}' | cut -d= -f2 || true)
      if [ -z "$MARKER_HASH" ]; then
        echo "gate-claude-md: WARNING: Marker has no content hash (old format). Re-run steward."
        log_event "HASH_MISSING marker_age=${AGE_SECONDS}s files=${GOVERNANCE_CHANGED[*]}"
        exit 1
      else
        CURRENT_HASH=$(compute_gov_hash)
        if [ "$MARKER_HASH" != "$CURRENT_HASH" ]; then
          echo "gate-claude-md: BLOCKED: Content changed since steward reviewed it."
          echo "  Marker hash:  ${MARKER_HASH:0:16}..."
          echo "  Current hash: ${CURRENT_HASH:0:16}..."
          echo "  Re-run: /claude-md-steward mode=1"
          log_event "HASH_MISMATCH marker=${MARKER_HASH:0:16} current=${CURRENT_HASH:0:16} files=${GOVERNANCE_CHANGED[*]}"
          exit 1
        else
          echo "gate-claude-md: Steward validation detected (last run: $MARKER_TS, age: ${AGE_SECONDS}s, hash: ${MARKER_HASH:0:16}...)"
          log_event "PASS marker_age=${AGE_SECONDS}s hash=${MARKER_HASH:0:16} files=${GOVERNANCE_CHANGED[*]}"
          if [ "$GLOBAL_DRIFT" = true ]; then
            mkdir -p "$(dirname "$SNAPSHOT")"
            cp "$GLOBAL_CLAUDE" "$SNAPSHOT"
            git add "$SNAPSHOT"
            echo "gate-claude-md: Auto-synced global CLAUDE.md snapshot."
          fi
          exit 0
        fi
      fi
    else
      echo "gate-claude-md: Marker expired (age: ${AGE_SECONDS}s, TTL: ${TTL_SECONDS}s). Re-run steward."
      log_event "MARKER_EXPIRED age=${AGE_SECONDS}s ttl=${TTL_SECONDS}s"
    fi
  fi
fi

echo ""
echo "gate-claude-md: Steward was NOT invoked for this change."
echo "   Run: /claude-md-steward (Mode 1 for edits, Mode 0+1 for additions)"
echo ""
if [ "$GLOBAL_DRIFT" = true ]; then
  echo "NOTE: ~/.claude/CLAUDE.md has changed since last snapshot."
  echo "Resolution options:"
  echo "  (a) Run /claude-md-steward mode=1 then retry commit"
  echo "  (b) Use --force flag: bash scripts/gate-claude-md.sh --force"
  echo "      (then re-run your commit)"
  echo "After running steward, the snapshot will auto-sync on next commit."
  echo ""
fi

# Blocking (Type 1 enforcement) -- use --force to override
if [ "${1:-}" = "--force" ]; then
  echo "gate-claude-md: Force override -- proceeding without steward validation."
  log_event "FORCE_OVERRIDE files=${GOVERNANCE_CHANGED[*]}"
  if [ "$GLOBAL_DRIFT" = true ]; then
    mkdir -p "$(dirname "$SNAPSHOT")"
    cp "$GLOBAL_CLAUDE" "$SNAPSHOT"
    git add "$SNAPSHOT"
    echo "gate-claude-md: Auto-synced global CLAUDE.md snapshot."
  fi
  exit 0
fi

log_event "BLOCKED files=${GOVERNANCE_CHANGED[*]}"
exit 1
