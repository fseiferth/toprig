#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Pre-Commit Workflow Validation (Layer 1: Type 1 Enforcement)
# Purpose: Detect multi-file work and signal to commit-msg hook for bead validation
# Usage: Called automatically by .git/hooks/pre-commit
#
# DESIGN NOTE (2026-02-03):
# Bead reference validation moved to commit-msg hook because:
# - COMMIT_EDITMSG doesn't exist during pre-commit phase
# - git log -1 returns PREVIOUS commit, not current one
# - This hook sets a marker file that commit-msg reads

set -euo pipefail

# Configuration
MULTI_FILE_THRESHOLD=3
LINES_CHANGED_THRESHOLD=50
MARKER_FILE=".git/MULTI_FILE_WORK_DETECTED"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "$1"
}

# Check if commit contains only exempt files (handoff docs, RCA, etc.)
check_exempt_files() {
    local staged_files
    staged_files=$(git diff --cached --name-only)

    # Exempt patterns: handoff docs, RCA, recovery plans, phase docs
    local exempt_pattern="^(HANDOFF-.*\.md|CONTEXT-.*\.md|.*-RECOVERY-.*\.md|RCA-.*\.md|PHASE-.*\.md|\.github/workflows/.*|scripts/.*\.sh|dev-diary/.*)$"

    local total_files=0
    local exempt_files=0

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        total_files=$((total_files + 1))
        if echo "$file" | grep -qE "$exempt_pattern"; then
            exempt_files=$((exempt_files + 1))
        fi
    done <<< "$staged_files"

    # If ALL files are exempt, return 0 (exempt commit)
    if [ "$total_files" -eq "$exempt_files" ] && [ "$total_files" -gt 0 ]; then
        return 0
    fi

    return 1
}

# GATE 1: Detect multi-file work
check_multi_file_work() {
    local files_changed
    local lines_changed

    files_changed=$(git diff --cached --name-only | wc -l | tr -d ' ')
    lines_changed=$(git diff --cached --numstat | awk '{sum += $1 + $2} END {print sum+0}')

    # Handle empty values (fix integer expression warnings)
    files_changed=${files_changed:-0}
    lines_changed=${lines_changed:-0}

    # No staged files = nothing to validate
    if [ "$files_changed" -eq 0 ]; then
        echo "no-files"
        return 0
    fi

    # Single file with small change = not multi-file work
    if [ "$files_changed" -le 1 ] && [ "$lines_changed" -lt "$LINES_CHANGED_THRESHOLD" ]; then
        echo "single-file"
        return 0
    fi

    # Multi-file work detected
    if [ "$files_changed" -ge "$MULTI_FILE_THRESHOLD" ] || [ "$lines_changed" -ge "$LINES_CHANGED_THRESHOLD" ]; then
        echo "multi-file"
        return 0
    fi

    echo "single-file"
    return 0
}

# Clean up marker file from previous runs
cleanup_marker() {
    rm -f "$MARKER_FILE" 2>/dev/null || true
}

# Main validation flow
main() {
    info "Running pre-commit workflow validation..."
    info ""

    # Clean up any stale marker
    cleanup_marker

    # GATE 1: Check work type
    work_type=$(check_multi_file_work)

    case "$work_type" in
        "no-files")
            success "GATE 1: No staged files"
            exit 0
            ;;
        "single-file")
            success "GATE 1: Single-file work, no bead required"
            exit 0
            ;;
        "multi-file")
            # Check if all files are exempt
            if check_exempt_files; then
                success "GATE 1: Exempt files only (handoff/RCA/recovery docs)"
                exit 0
            fi

            # Multi-file work detected - create marker for commit-msg hook
            local files_changed lines_changed
            files_changed=$(git diff --cached --name-only | wc -l | tr -d ' ')
            lines_changed=$(git diff --cached --numstat | awk '{sum += $1 + $2} END {print sum+0}')

            success "GATE 1: Multi-file work detected ($files_changed files, $lines_changed lines)"
            warning "Bead reference will be validated in commit-msg hook"

            # Create marker file with details for commit-msg hook
            echo "files=$files_changed" > "$MARKER_FILE"
            echo "lines=$lines_changed" >> "$MARKER_FILE"
            echo "timestamp=$(date +%s)" >> "$MARKER_FILE"
            ;;
    esac

    info ""
    success "Pre-commit validation passed (bead check deferred to commit-msg)"
    exit 0
}

main "$@"
