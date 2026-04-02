#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# detect-governance-removal.sh - Pre-commit detection of governance pattern removal
# Reference: SDLC-ROLE-MAPPING.md Quality Gate Engine
# Reference: governance.md Section 0.3 (Type 1 Preservation)
#
# Purpose: Detect when governance patterns are being removed from agent definitions.
# This is called from pre-commit hook when agent files are modified.
#
# Usage:
#   ./scripts/detect-governance-removal.sh [options]
#
# Options:
#   --staged          Check staged changes (for pre-commit)
#   --compare <ref>   Compare against specific git ref (default: HEAD)
#   --force           Allow commit with justification (creates warning bead)
#   -v, --verbose     Show detailed output
#   -h, --help        Show this help message
#
# Exit Codes:
#   0 = No governance patterns removed
#   1 = Governance pattern removal detected (BLOCKS commit)
#   2 = Warning: Section modified (needs review)

set -e

# ============================================
# Configuration
# ============================================
AGENTS_DIR="${AGENTS_DIR:-$HOME/.claude/agents}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source quality gate functions if available
if [ -f "$SCRIPT_DIR/quality-gate-functions.sh" ]; then
    source "$SCRIPT_DIR/quality-gate-functions.sh"
else
    # Fallback color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
    pass() { echo -e "${GREEN}PASS${NC}: $1"; }
    fail() { echo -e "${RED}FAIL${NC}: $1"; }
    warn() { echo -e "${YELLOW}WARN${NC}: $1"; }
    info() { echo "INFO: $1"; }
fi

# Protected patterns that MUST NOT be removed
PROTECTED_PATTERNS=(
    "MANDATORY FIRST ACTIONS"
    "bd ready"
    "bd update.*--status"
    "bd sync"
    "Feature ID"
    "Entrance Validation"
    "Exit Criteria\|Exit Validation"
    "Landing the Plane"
    "Beads Workflow\|Beads Work Tracking"
)

# ============================================
# Variables
# ============================================
VERBOSE=false
STAGED_MODE=false
COMPARE_REF="HEAD"
FORCE_MODE=false
ERRORS=0
WARNINGS=0

# ============================================
# Functions
# ============================================

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Detects governance pattern removal from agent definitions."
    echo ""
    echo "Options:"
    echo "  --staged          Check staged changes (for pre-commit hook)"
    echo "  --compare <ref>   Compare against specific git ref (default: HEAD)"
    echo "  --force           Allow commit with justification (creates warning)"
    echo "  -v, --verbose     Show detailed output"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Exit Codes:"
    echo "  0 = No governance patterns removed"
    echo "  1 = Governance pattern removal detected (BLOCKS commit)"
    echo "  2 = Warning: Section modified (needs review)"
    echo ""
    echo "Examples:"
    echo "  $0 --staged                # Check staged agent file changes"
    echo "  $0 --compare main          # Compare against main branch"
}

get_modified_agent_files() {
    if [ "$STAGED_MODE" = true ]; then
        # Get staged files that are in the agents directory
        git diff --cached --name-only --diff-filter=M 2>/dev/null | grep -E "\.claude/agents/.*\.md$" || true
    else
        # Get modified files compared to ref
        git diff --name-only --diff-filter=M "$COMPARE_REF" 2>/dev/null | grep -E "\.claude/agents/.*\.md$" || true
    fi
}

check_pattern_in_file() {
    local file="$1"
    local pattern="$2"

    grep -qiE "$pattern" "$file" 2>/dev/null
    return $?
}

check_pattern_removal() {
    local file="$1"
    local pattern="$2"
    local old_content new_content

    # Get old content (from HEAD or compare ref)
    if [ "$STAGED_MODE" = true ]; then
        old_content=$(git show "HEAD:$file" 2>/dev/null || echo "")
    else
        old_content=$(git show "$COMPARE_REF:$file" 2>/dev/null || echo "")
    fi

    # Get new content
    if [ "$STAGED_MODE" = true ]; then
        new_content=$(git show ":$file" 2>/dev/null || cat "$file" 2>/dev/null || echo "")
    else
        new_content=$(cat "$file" 2>/dev/null || echo "")
    fi

    # Check if pattern existed before
    local had_pattern=false
    if echo "$old_content" | grep -qiE "$pattern" 2>/dev/null; then
        had_pattern=true
    fi

    # Check if pattern exists now
    local has_pattern=false
    if echo "$new_content" | grep -qiE "$pattern" 2>/dev/null; then
        has_pattern=true
    fi

    # Pattern was removed
    if [ "$had_pattern" = true ] && [ "$has_pattern" = false ]; then
        return 0  # Pattern removed
    fi

    return 1  # Pattern not removed
}

validate_agent_changes() {
    local file="$1"
    local agent_name
    agent_name=$(basename "$file" .md)

    echo ""
    echo "Checking: $agent_name"
    echo "-----------------------------------"

    local agent_errors=0
    local agent_warnings=0

    for pattern in "${PROTECTED_PATTERNS[@]}"; do
        if check_pattern_removal "$file" "$pattern"; then
            fail "REMOVED: Pattern '$pattern' was removed from $agent_name"
            agent_errors=$((agent_errors + 1))
        elif [ "$VERBOSE" = true ]; then
            pass "Pattern intact: $pattern"
        fi
    done

    # Check for significant line removals (more than 50 lines removed)
    local old_lines new_lines removed_lines
    if [ "$STAGED_MODE" = true ]; then
        old_lines=$(git show "HEAD:$file" 2>/dev/null | wc -l | tr -d ' ')
        new_lines=$(git show ":$file" 2>/dev/null | wc -l | tr -d ' ')
    else
        old_lines=$(git show "$COMPARE_REF:$file" 2>/dev/null | wc -l | tr -d ' ')
        new_lines=$(cat "$file" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ -n "$old_lines" ] && [ -n "$new_lines" ]; then
        removed_lines=$((old_lines - new_lines))
        if [ $removed_lines -gt 50 ]; then
            warn "Large deletion: $removed_lines lines removed from $agent_name"
            agent_warnings=$((agent_warnings + 1))
        fi
    fi

    # Summary for this file
    if [ $agent_errors -eq 0 ]; then
        if [ $agent_warnings -gt 0 ]; then
            echo -e "${YELLOW}[WARN] $agent_name: $agent_warnings warnings${NC}"
        else
            echo -e "${GREEN}[OK] $agent_name: No governance patterns removed${NC}"
        fi
    else
        echo -e "${RED}[BLOCKED] $agent_name: $agent_errors governance patterns removed!${NC}"
    fi

    ERRORS=$((ERRORS + agent_errors))
    WARNINGS=$((WARNINGS + agent_warnings))

    return $agent_errors
}

# ============================================
# Main
# ============================================

# Parse arguments
while [ $# -gt 0 ]; do
    case $1 in
        --staged)
            STAGED_MODE=true
            shift
            ;;
        --compare)
            COMPARE_REF="$2"
            shift 2
            ;;
        --force)
            FORCE_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

echo ""
echo "========================================================"
echo "  Governance Pattern Removal Detection (Type 1)"
echo "========================================================"
echo ""

# Get modified agent files
MODIFIED_FILES=$(get_modified_agent_files)

if [ -z "$MODIFIED_FILES" ]; then
    if [ "$VERBOSE" = true ]; then
        info "No agent files modified"
    fi
    exit 0
fi

info "Modified agent files detected:"
echo "$MODIFIED_FILES" | while read -r file; do
    echo "  - $file"
done

# Validate each modified file
for file in $MODIFIED_FILES; do
    # Expand path if needed
    if [[ "$file" == "~/"* ]]; then
        file="${file/#\~/$HOME}"
    fi

    # Handle relative vs absolute paths
    if [ ! -f "$file" ]; then
        # Try from home directory
        if [ -f "$HOME/$file" ]; then
            file="$HOME/$file"
        elif [ -f "/$file" ]; then
            file="/$file"
        fi
    fi

    if [ -f "$file" ] || [ "$STAGED_MODE" = true ]; then
        validate_agent_changes "$file" || true
    else
        warn "Cannot find file: $file"
    fi
done

# Final summary
echo ""
echo "========================================"
echo "  Summary"
echo "========================================"
echo ""
echo "Governance patterns removed: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}[WARN] Commit allowed with warnings${NC}"
        echo "Consider reviewing the large deletions."
        exit 2
    else
        echo -e "${GREEN}[OK] No governance patterns removed - commit allowed${NC}"
        exit 0
    fi
else
    if [ "$FORCE_MODE" = true ]; then
        echo -e "${YELLOW}[FORCED] Commit proceeding despite governance removals${NC}"
        echo ""
        echo "WARNING: You are removing governance patterns!"
        echo "This should only be done as part of approved governance cleanup."
        echo ""
        echo "If this is intentional, document the reason in your commit message."
        exit 0
    else
        echo -e "${RED}[BLOCKED] COMMIT REJECTED: Governance patterns removed!${NC}"
        echo ""
        echo "The following protected patterns were removed:"
        echo "  - MANDATORY FIRST ACTIONS section"
        echo "  - Beads workflow commands (bd ready, bd update, bd sync)"
        echo "  - Feature ID traceability"
        echo "  - Entrance/Exit validation sections"
        echo "  - Landing the Plane section"
        echo ""
        echo "These patterns are Type 1 enforcement - they MUST exist in all agents."
        echo ""
        echo "Options:"
        echo "  1. Restore the removed patterns (recommended)"
        echo "  2. Use --force with justification (creates warning bead)"
        echo "  3. If this is approved governance cleanup, contact governance team"
        echo ""
        echo "Reference: governance.md Section 0.3 (Type 1 Preservation)"
        exit 1
    fi
fi
