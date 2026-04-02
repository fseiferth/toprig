#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# governance-metrics.sh
# Track governance health metrics for ${PROJECT_NAME} project
# Run: ./scripts/governance-metrics.sh [--json]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="${HOME}/.claude/agents"
JSON_OUTPUT=false

# Parse args
if [[ "$1" == "--json" ]]; then
    JSON_OUTPUT=true
fi

# Colors (only for non-JSON output)
if ! $JSON_OUTPUT; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

# ========================================
# 1. CLAUDE.md Size Metrics
# ========================================
CLAUDE_LINES=$(wc -l < "${PROJECT_ROOT}/CLAUDE.md" | tr -d ' ')
CLAUDE_BYTES=$(wc -c < "${PROJECT_ROOT}/CLAUDE.md" | tr -d ' ')
CLAUDE_KB=$((CLAUDE_BYTES / 1024))

# Thresholds
CLAUDE_WARN_LINES=1500
CLAUDE_CRIT_LINES=2000

if [ "$CLAUDE_LINES" -gt "$CLAUDE_CRIT_LINES" ]; then
    CLAUDE_STATUS="CRITICAL"
elif [ "$CLAUDE_LINES" -gt "$CLAUDE_WARN_LINES" ]; then
    CLAUDE_STATUS="WARNING"
else
    CLAUDE_STATUS="OK"
fi

# ========================================
# 2. Feature ID Coverage in Code
# ========================================
# Count files with Feature ID comments
BACKEND_FEAT_FILES=$(grep -rl "# FEAT-[0-9]\|// FEAT-[0-9]" "${PROJECT_ROOT}/${project_name}-backend/app" 2>/dev/null | wc -l | tr -d ' ')
FRONTEND_FEAT_FILES=$(grep -rl "// FEAT-[0-9]\|# FEAT-[0-9]" "${PROJECT_ROOT}/${project_name}-frontend/src" 2>/dev/null | wc -l | tr -d ' ')

# Count total source files
BACKEND_TOTAL=$(find "${PROJECT_ROOT}/${project_name}-backend/app" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
FRONTEND_TOTAL=$(find "${PROJECT_ROOT}/${project_name}-frontend/src" -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')

# Calculate percentages (avoid division by zero)
if [ "$BACKEND_TOTAL" -gt 0 ]; then
    BACKEND_COVERAGE=$((BACKEND_FEAT_FILES * 100 / BACKEND_TOTAL))
else
    BACKEND_COVERAGE=0
fi

if [ "$FRONTEND_TOTAL" -gt 0 ]; then
    FRONTEND_COVERAGE=$((FRONTEND_FEAT_FILES * 100 / FRONTEND_TOTAL))
else
    FRONTEND_COVERAGE=0
fi

# ========================================
# 3. Handover Section Completeness
# ========================================
# Count Section X.1 (Entrance)
ENTRANCE_COUNT=$(grep -l "Section.*\.1.*Entrance\|Pre-Work Entrance Validation" "${AGENTS_DIR}"/*.md 2>/dev/null | wc -l | tr -d ' ')

# Count Section X.5 (Exit)
EXIT_COUNT=$(grep -l "Section.*\.5.*Exit Criteria" "${AGENTS_DIR}"/*.md 2>/dev/null | wc -l | tr -d ' ')

# Expected counts
EXPECTED_ENTRANCE=6  # Designer, Architect, Backend, Frontend, QA, Security
EXPECTED_EXIT=7      # PM, Designer, Architect, Backend, Frontend, QA, Security

# ========================================
# 4. Agent File Sizes
# ========================================
TOTAL_AGENT_LINES=0
LARGEST_AGENT=""
LARGEST_SIZE=0

for agent in product-manager ux-ui-designer system-architect senior-backend-engineer senior-frontend-engineer qa-test-automation-engineer security-analyst; do
    if [ -f "${AGENTS_DIR}/${agent}.md" ]; then
        lines=$(wc -l < "${AGENTS_DIR}/${agent}.md" | tr -d ' ')
        TOTAL_AGENT_LINES=$((TOTAL_AGENT_LINES + lines))
        if [ "$lines" -gt "$LARGEST_SIZE" ]; then
            LARGEST_SIZE=$lines
            LARGEST_AGENT="${agent}.md"
        fi
    fi
done

# ========================================
# 5. Type 2 Enforcement Coverage
# ========================================
TYPE2_COUNT=$(grep -l "Type 2.*Agent Rejection\|HANDOFF REJECTED" "${AGENTS_DIR}"/*.md 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_TYPE2=7

# ========================================
# 6. Recent Commits with Feature IDs
# ========================================
RECENT_COMMITS=$(git log --oneline -20 2>/dev/null | wc -l | tr -d ' ')
FEAT_COMMITS=$(git log --oneline -20 2>/dev/null | grep -i "FEAT-[0-9]\|feat(" | wc -l | tr -d ' ')

if [ "$RECENT_COMMITS" -gt 0 ]; then
    COMMIT_COMPLIANCE=$((FEAT_COMMITS * 100 / RECENT_COMMITS))
else
    COMMIT_COMPLIANCE=0
fi

# ========================================
# Output
# ========================================

if $JSON_OUTPUT; then
    cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "claude_md": {
    "lines": $CLAUDE_LINES,
    "bytes": $CLAUDE_BYTES,
    "status": "$CLAUDE_STATUS",
    "thresholds": {"warn": $CLAUDE_WARN_LINES, "critical": $CLAUDE_CRIT_LINES}
  },
  "feature_id_coverage": {
    "backend": {"files_with_id": $BACKEND_FEAT_FILES, "total_files": $BACKEND_TOTAL, "percent": $BACKEND_COVERAGE},
    "frontend": {"files_with_id": $FRONTEND_FEAT_FILES, "total_files": $FRONTEND_TOTAL, "percent": $FRONTEND_COVERAGE}
  },
  "handover_sections": {
    "entrance": {"count": $ENTRANCE_COUNT, "expected": $EXPECTED_ENTRANCE},
    "exit": {"count": $EXIT_COUNT, "expected": $EXPECTED_EXIT}
  },
  "agent_files": {
    "total_lines": $TOTAL_AGENT_LINES,
    "largest": {"file": "$LARGEST_AGENT", "lines": $LARGEST_SIZE}
  },
  "enforcement": {
    "type2_agents": $TYPE2_COUNT,
    "expected": $EXPECTED_TYPE2
  },
  "commit_compliance": {
    "recent_commits": $RECENT_COMMITS,
    "with_feature_id": $FEAT_COMMITS,
    "percent": $COMMIT_COMPLIANCE
  }
}
EOF
else
    echo "========================================"
    echo "  ${PROJECT_NAME} Governance Metrics"
    echo "  $(date '+%Y-%m-%d %H:%M')"
    echo "========================================"
    echo ""

    # CLAUDE.md Status
    echo -e "${BLUE}1. CLAUDE.md Size${NC}"
    if [ "$CLAUDE_STATUS" == "CRITICAL" ]; then
        echo -e "   Status: ${RED}$CLAUDE_STATUS${NC}"
    elif [ "$CLAUDE_STATUS" == "WARNING" ]; then
        echo -e "   Status: ${YELLOW}$CLAUDE_STATUS${NC}"
    else
        echo -e "   Status: ${GREEN}$CLAUDE_STATUS${NC}"
    fi
    echo "   Lines: $CLAUDE_LINES (warn: $CLAUDE_WARN_LINES, critical: $CLAUDE_CRIT_LINES)"
    echo "   Size: ${CLAUDE_KB}KB"
    echo ""

    # Feature ID Coverage
    echo -e "${BLUE}2. Feature ID Coverage${NC}"
    echo "   Backend:  $BACKEND_FEAT_FILES / $BACKEND_TOTAL files ($BACKEND_COVERAGE%)"
    echo "   Frontend: $FRONTEND_FEAT_FILES / $FRONTEND_TOTAL files ($FRONTEND_COVERAGE%)"
    echo ""

    # Handover Sections
    echo -e "${BLUE}3. Handover Sections${NC}"
    if [ "$ENTRANCE_COUNT" -eq "$EXPECTED_ENTRANCE" ]; then
        echo -e "   Entrance (X.1): ${GREEN}$ENTRANCE_COUNT / $EXPECTED_ENTRANCE${NC}"
    else
        echo -e "   Entrance (X.1): ${RED}$ENTRANCE_COUNT / $EXPECTED_ENTRANCE${NC}"
    fi
    if [ "$EXIT_COUNT" -eq "$EXPECTED_EXIT" ]; then
        echo -e "   Exit (X.5):     ${GREEN}$EXIT_COUNT / $EXPECTED_EXIT${NC}"
    else
        echo -e "   Exit (X.5):     ${RED}$EXIT_COUNT / $EXPECTED_EXIT${NC}"
    fi
    echo ""

    # Agent Files
    echo -e "${BLUE}4. Agent File Sizes${NC}"
    echo "   Total lines: $TOTAL_AGENT_LINES"
    echo "   Largest: $LARGEST_AGENT ($LARGEST_SIZE lines)"
    echo ""

    # Enforcement
    echo -e "${BLUE}5. Type 2 Enforcement${NC}"
    if [ "$TYPE2_COUNT" -eq "$EXPECTED_TYPE2" ]; then
        echo -e "   Agents with Type 2: ${GREEN}$TYPE2_COUNT / $EXPECTED_TYPE2${NC}"
    else
        echo -e "   Agents with Type 2: ${YELLOW}$TYPE2_COUNT / $EXPECTED_TYPE2${NC}"
    fi
    echo ""

    # Commit Compliance
    echo -e "${BLUE}6. Recent Commit Compliance${NC}"
    echo "   Last 20 commits: $FEAT_COMMITS / $RECENT_COMMITS with Feature ID ($COMMIT_COMPLIANCE%)"
    echo ""

    # Summary
    echo "========================================"
    echo -e "  ${GREEN}Governance Health Summary${NC}"
    echo "========================================"

    ISSUES=0
    if [ "$CLAUDE_STATUS" != "OK" ]; then
        echo -e "  ${YELLOW}! CLAUDE.md size needs attention${NC}"
        ISSUES=$((ISSUES + 1))
    fi
    if [ "$ENTRANCE_COUNT" -lt "$EXPECTED_ENTRANCE" ]; then
        echo -e "  ${RED}! Missing entrance validation sections${NC}"
        ISSUES=$((ISSUES + 1))
    fi
    if [ "$EXIT_COUNT" -lt "$EXPECTED_EXIT" ]; then
        echo -e "  ${RED}! Missing exit criteria sections${NC}"
        ISSUES=$((ISSUES + 1))
    fi
    if [ "$TYPE2_COUNT" -lt "$EXPECTED_TYPE2" ]; then
        echo -e "  ${YELLOW}! Type 2 enforcement incomplete${NC}"
        ISSUES=$((ISSUES + 1))
    fi

    if [ "$ISSUES" -eq 0 ]; then
        echo -e "  ${GREEN}All governance checks healthy${NC}"
    else
        echo ""
        echo "  Issues found: $ISSUES"
    fi
    echo ""
fi
