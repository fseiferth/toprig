#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Pre-Work Validation (Layer 2: Type 1 Enforcement)
# Purpose: Catch violations BEFORE work accumulates
# Usage: Run before starting ANY multi-step work

set -euo pipefail

BEADS_CLI="bd"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FEAT_ID=""

# Parse optional --feature flag
for arg in "$@"; do
  case "$arg" in
    --feature=*) FEAT_ID="${arg#--feature=}" ;;
    --feature) shift_next=true ;;
    *)
      if [ "${shift_next:-false}" = true ]; then
        FEAT_ID="$arg"
        shift_next=false
      fi
      ;;
  esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo -e "${RED}❌ PROBLEM: $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

info() {
    echo -e "$1"
}

# Check for uncommitted work
check_uncommitted_work() {
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        return 0 # Has uncommitted work
    fi
    return 1 # Clean working directory
}

# Check for active beads
check_active_beads() {
    if ! command -v "$BEADS_CLI" >/dev/null 2>&1; then
        error "Beads CLI not found"
        info "Install: https://github.com/steveyegge/beads"
        return 1
    fi

    # Get ready beads (in_progress status)
    local active_beads
    active_beads=$("$BEADS_CLI" ready --assignee claude-main 2>/dev/null | wc -l | tr -d ' ')

    if [ "$active_beads" -eq 0 ]; then
        return 1 # No active beads
    fi

    return 0 # Has active beads
}

# Main validation
main() {
    info "Validating work readiness..."
    info ""

    # Check 1: Uncommitted work?
    if check_uncommitted_work; then
        warning "Uncommitted work detected"

        # Check 2: Active beads?
        if ! check_active_beads; then
            error "Work in progress but NO active beads"
            info ""
            info "Before continuing, create a bead:"
            info ""
            info "  1. Find or create epic:"
            info "     bd list --type epic"
            info ""
            info "  2. Create your bead:"
            info "     bd create \"Description\" --parent ${PROJECT_NAME}-xxx --assignee claude-main -p 2"
            info ""
            info "  3. Mark in progress:"
            info "     bd update <bead-id> --status in_progress  # Dolt auto-persists"
            info ""
            info "Then continue with your work."
            exit 1
        else
            success "Active beads found for current work"
        fi
    else
        success "No uncommitted work - starting fresh"
    fi

    # Check 3: Bead structure exists for Feature ID (if provided)
    if [ -n "$FEAT_ID" ]; then
        info ""
        info "Checking bead structure for ${FEAT_ID}..."
        if [ -x "$SCRIPT_DIR/validate-bead-structure.sh" ]; then
            if ! "$SCRIPT_DIR/validate-bead-structure.sh" "$FEAT_ID"; then
                warning "No epic structure for ${FEAT_ID}"
                info "  Create one: ./scripts/create-feature-epic.sh ${FEAT_ID} \"Feature Name\""
                info "  (Proceeding — this is a warning, not a blocker)"
            fi
        else
            warning "validate-bead-structure.sh not found — skipping structure check"
        fi
    fi

    info ""
    info "Pre-Work Checklist (for multi-step work):"
    info ""
    info "  [ ] Find parent epic: bd list --type epic"
    info "  [ ] Create bead: bd create \"Description\" --parent EPIC_ID --assignee <name> -p 2"
    info "  [ ] Mark in progress: bd update <bead-id> --status in_progress  # Dolt auto-persists"
    info "  [ ] Do work (edit files)"
    info "  [ ] Update progress: bd update <bead-id> --append-notes \"Progress update\""
    info "  [ ] Commit with bead reference: git commit -m \"feat: Description\n\nBead: ${PROJECT_NAME}-xxx.yyy\""
    info "  [ ] Close when done: bd close <bead-id> --reason \"Work complete\""
    info ""
    success "Ready to start work"
    exit 0
}

main "$@"
