#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Weekly Compliance Audit (Layer 4: Detection Only)
# Purpose: Detect violations that slipped through (continuous improvement)
# Usage: ./scripts/audit-workflow-compliance.sh [days]

set -euo pipefail

# Configuration
DAYS_TO_AUDIT="${1:-7}"  # Default: last 7 days
BEADS_CLI="bd"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Audit 1: Commits without bead references
audit_commits_without_beads() {
    info "Audit 1: Checking commits without bead references (last $DAYS_TO_AUDIT days)..."

    local violations=0
    local total_commits=0

    # Get commits from last N days
    while IFS= read -r commit_hash; do
        total_commits=$((total_commits + 1))

        # Get commit message
        local commit_msg
        commit_msg=$(git log -1 --pretty=%B "$commit_hash")

        # Get files changed
        local files_changed
        files_changed=$(git show --name-only --pretty="" "$commit_hash" | wc -l | tr -d ' ')

        # Get lines changed (handle non-numeric values, convert to integer)
        local lines_changed
        lines_changed=$(git show --numstat "$commit_hash" | awk '{sum += $1 + $2} END {print (sum == "" || sum == "inf") ? 0 : int(sum)}')

        # Skip if minor work: single file AND less than 50 lines
        if [ "$files_changed" -le 1 ] && [ "$lines_changed" -lt 50 ]; then
            # Minor work - no bead required
            continue
        fi

        # Check if commit message indicates exempt work type (first line only)
        local commit_subject
        commit_subject=$(echo "$commit_msg" | head -1)
        local exempt_commit_patterns="^(test:|chore:|docs:|cleanup:|refactor\(governance\)|feat\(governance\)|fix\(governance\)|feat\(keepalive\)|fix\(keepalive\)|docs\(keepalive\)|docs\(diary\)|style:|ci:)"
        if echo "$commit_subject" | grep -qiE "$exempt_commit_patterns"; then
            # Infrastructure/governance/test/docs work - no bead required
            continue
        fi

        # Check if commit contains only exempt files (handoff docs, RCA, etc.)
        local commit_files
        commit_files=$(git show --name-only --pretty="" "$commit_hash")
        local is_exempt=true
        local exempt_pattern="^(HANDOFF-.*\.md|CONTEXT-.*\.md|.*-RECOVERY-.*\.md|RCA-.*\.md|PHASE-.*\.md|\.github/workflows/.*|scripts/.*\.sh|dev-diary/.*)$"

        while IFS= read -r file; do
            [ -z "$file" ] && continue
            if ! echo "$file" | grep -qE "$exempt_pattern"; then
                is_exempt=false
                break
            fi
        done <<< "$commit_files"

        # If all files are exempt, skip bead check
        if [ "$is_exempt" = true ] && [ -n "$commit_files" ]; then
            continue
        fi

        # Multi-file work detected (>=3 files OR >=50 lines)
        if [ "$files_changed" -ge 3 ] || [ "$lines_changed" -ge 50 ]; then
            # Check for bead reference (supports multiple formats):
            # 1. Body format: "Bead: ${PROJECT_NAME}-xxx.y.z"
            # 2. Subject format: "bd-${PROJECT_NAME}-xxx" or "bd-${PROJECT_NAME}-2j6"
            # 3. Emergency bypass: "no-bead-required"
            if ! echo "$commit_msg" | grep -qiE "(Bead: ${PROJECT_NAME}-[a-z0-9]+|bd-${PROJECT_NAME}-[a-z0-9]+|no-bead-required)"; then
                violations=$((violations + 1))
                warning "Commit $commit_hash: Multi-file work without bead reference"
                info "  Files changed: $files_changed, Lines changed: $lines_changed"
                info "  Message: $(echo "$commit_msg" | head -1)"
                echo ""
            fi
        fi
    done < <(git log --since="$DAYS_TO_AUDIT days ago" --pretty=%H)

    if [ "$violations" -eq 0 ]; then
        success "Audit 1: All $total_commits commits have proper bead references"
    else
        error "Audit 1: Found $violations violations out of $total_commits commits"
    fi

    return "$violations"
}

# Audit 2: Beads not synced to git
audit_beads_sync() {
    info "Audit 2: Checking beads sync status..."

    if ! command -v "$BEADS_CLI" >/dev/null 2>&1; then
        warning "Beads CLI not found, skipping sync audit"
        return 0
    fi

    # Check if .beads/issues.jsonl is up to date
    if [ ! -f ".beads/issues.jsonl" ]; then
        warning "Audit 2: .beads/issues.jsonl not found (file is gitignored)"
        info "Skipping beads sync audit in CI environment"
        return 0  # Don't fail audit if file is gitignored
    fi

    # Check if .beads/issues.jsonl has uncommitted changes
    if ! git diff --quiet .beads/issues.jsonl 2>/dev/null; then
        warning "Audit 2: .beads/issues.jsonl has uncommitted changes"
        info "Run: git add .beads/issues.jsonl && git commit -m 'chore: sync beads'"
        return 0  # Warning only, don't fail audit
    fi

    success "Audit 2: Beads are synced to git"
    return 0
}

# Audit 3: Multi-file commits without beads
audit_multi_file_commits() {
    info "Audit 3: Checking multi-file commits (last $DAYS_TO_AUDIT days)..."

    local violations=0
    local multi_file_commits=0

    while IFS= read -r commit_hash; do
        # Get files changed
        local files_changed
        files_changed=$(git show --name-only --pretty="" "$commit_hash" | wc -l | tr -d ' ')

        if [ "$files_changed" -ge 3 ]; then
            # Get commit message first (needed for multiple checks)
            local commit_msg
            commit_msg=$(git log -1 --pretty=%B "$commit_hash")

            # Check if commit message indicates exempt work type (first line only)
            local commit_subject
            commit_subject=$(echo "$commit_msg" | head -1)
            local exempt_commit_patterns="^(test:|chore:|docs:|cleanup:|refactor\(governance\)|feat\(governance\)|fix\(governance\)|feat\(keepalive\)|fix\(keepalive\)|docs\(keepalive\)|docs\(diary\)|style:|ci:)"
            if echo "$commit_subject" | grep -qiE "$exempt_commit_patterns"; then
                # Infrastructure/governance/test/docs work - no bead required
                continue
            fi

            # Check if commit contains only exempt files
            local commit_files
            commit_files=$(git show --name-only --pretty="" "$commit_hash")
            local is_exempt=true
            local exempt_pattern="^(HANDOFF-.*\.md|CONTEXT-.*\.md|.*-RECOVERY-.*\.md|RCA-.*\.md|PHASE-.*\.md|\.github/workflows/.*|scripts/.*\.sh|dev-diary/.*)$"

            while IFS= read -r file; do
                [ -z "$file" ] && continue
                if ! echo "$file" | grep -qE "$exempt_pattern"; then
                    is_exempt=false
                    break
                fi
            done <<< "$commit_files"

            # If all files are exempt, skip bead check
            if [ "$is_exempt" = true ] && [ -n "$commit_files" ]; then
                continue
            fi

            multi_file_commits=$((multi_file_commits + 1))

            # Check for bead reference (supports multiple formats):
            # 1. Body format: "Bead: ${PROJECT_NAME}-xxx.y.z"
            # 2. Subject format: "bd-${PROJECT_NAME}-xxx" or "bd-${PROJECT_NAME}-2j6"
            # 3. Emergency bypass: "no-bead-required"
            if ! echo "$commit_msg" | grep -qiE "(Bead: ${PROJECT_NAME}-[a-z0-9]+|bd-${PROJECT_NAME}-[a-z0-9]+|no-bead-required)"; then
                # No bead reference found
                violations=$((violations + 1))
                error "Commit $commit_hash: Multi-file work without bead reference"
                info "  Files changed: $files_changed"
                info "  Message: $(echo "$commit_msg" | head -1)"
                echo ""
            fi
        fi
    done < <(git log --since="$DAYS_TO_AUDIT days ago" --pretty=%H)

    if [ "$violations" -eq 0 ]; then
        success "Audit 3: All $multi_file_commits multi-file commits have bead references"
    else
        error "Audit 3: Found $violations violations out of $multi_file_commits multi-file commits"
    fi

    return "$violations"
}

# Summary report
generate_summary() {
    local total_violations="$1"

    echo ""
    info "=========================================="
    info "Workflow Compliance Audit Summary"
    info "=========================================="
    info "Audit Period: Last $DAYS_TO_AUDIT days"
    info "Total Violations: $total_violations"
    echo ""

    if [ "$total_violations" -eq 0 ]; then
        success "PASSED: No workflow violations detected"
        info ""
        info "Recommendations:"
        info "  - Continue following Beads workflow"
        info "  - Keep beads synced to git"
        info "  - Reference beads in all multi-file commits"
    else
        error "FAILED: $total_violations workflow violations detected"
        info ""
        info "Corrective Actions:"
        info "  1. Review violations above"
        info "  2. Create retroactive beads for untracked work"
        info "  3. Update commit messages if possible"
        info "  4. Document lessons learned"
        info ""
        info "Prevention:"
        info "  - Run pre-work validation: ./scripts/validate-work-readiness.sh"
        info "  - Ensure pre-commit hook is active"
        info "  - Self-assess context pressure (Type 3 behavioral rule in CLAUDE.md)"
    fi

    echo ""
}

# Main audit flow
main() {
    info "Starting Weekly Workflow Compliance Audit..."
    info "Auditing last $DAYS_TO_AUDIT days"
    echo ""

    local total_violations=0

    # Run audits
    audit_commits_without_beads || total_violations=$((total_violations + $?))
    echo ""

    audit_beads_sync || total_violations=$((total_violations + $?))
    echo ""

    audit_multi_file_commits || total_violations=$((total_violations + $?))

    # Generate summary
    generate_summary "$total_violations"

    # Exit with violation count (0 = success)
    exit "$total_violations"
}

main "$@"
