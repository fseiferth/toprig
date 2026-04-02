#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# verify-handover-protocols.sh
# Validates Universal Two-Sided Handover Protocol implementation
# Run: ./scripts/verify-handover-protocols.sh

AGENTS_DIR="${HOME}/.claude/agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_CLAUDE="${PROJECT_ROOT}/CLAUDE.md"
ERRORS=0
WARNINGS=0

echo "========================================"
echo "  Handover Protocol Validation"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN${NC}: $1"; WARNINGS=$((WARNINGS + 1)); }

# ========================================
# 1. Check Section X.1 (Entrance Validation)
# ========================================
echo "1. Checking Section X.1 (Entrance Validation)..."

check_entrance() {
  local agent="$1"
  local section="$2"
  if grep -q "${section}.*Entrance\|Pre-Work Entrance Validation\|Entrance Validation" "${AGENTS_DIR}/${agent}" 2>/dev/null; then
    pass "${agent}: ${section} found"
  else
    fail "${agent}: ${section} MISSING"
  fi
}

check_entrance "ux-ui-designer.md" "Section 2.1"
check_entrance "system-architect.md" "Section 3.1"
check_entrance "senior-backend-engineer.md" "Section 4.1"
check_entrance "senior-frontend-engineer.md" "Section 5.1"
check_entrance "qa-test-automation-engineer.md" "Section 6.1"
check_entrance "security-analyst.md" "Section 7.1"

# ========================================
# 2. Check Section X.5 (Exit Criteria)
# ========================================
echo ""
echo "2. Checking Section X.5 (Exit Criteria)..."

check_exit() {
  local agent="$1"
  local section="$2"
  if grep -q "${section}.*Exit Criteria" "${AGENTS_DIR}/${agent}" 2>/dev/null; then
    pass "${agent}: ${section} found"
  else
    fail "${agent}: ${section} MISSING"
  fi
}

check_exit "product-manager.md" "Section 1.5"
check_exit "ux-ui-designer.md" "Section 2.5"
check_exit "system-architect.md" "Section 3.5"
check_exit "senior-backend-engineer.md" "Section 4.5"
check_exit "senior-frontend-engineer.md" "Section 5.5"
check_exit "qa-test-automation-engineer.md" "Section 6.5"
check_exit "security-analyst.md" "Section 7.5"

# ========================================
# 3. Check Section X.6 (Bug Fix Handoff - Reverse Flow)
# ========================================
echo ""
echo "3. Checking Section X.6 (Bug Fix Handoff)..."

check_bugfix() {
  local agent="$1"
  local section="$2"
  if grep -q "${section}.*Bug Fix" "${AGENTS_DIR}/${agent}" 2>/dev/null; then
    pass "${agent}: ${section} found"
  else
    fail "${agent}: ${section} MISSING"
  fi
}

check_bugfix "senior-backend-engineer.md" "Section 4.6"
check_bugfix "senior-frontend-engineer.md" "Section 5.6"

# ========================================
# 4. Check CLAUDE.md Handover Sections
# ========================================
echo ""
echo "4. Checking CLAUDE.md Handover Sections..."

check_claude() {
  local pattern="$1"
  if grep -q "${pattern}" "${PROJECT_CLAUDE}" 2>/dev/null; then
    pass "CLAUDE.md: '${pattern}' found"
  else
    fail "CLAUDE.md: '${pattern}' MISSING"
  fi
}

# Consolidated patterns after CLAUDE.md optimization (v3.5)
# Handover details split: behavioral rules → global ~/.claude/CLAUDE.md, bindings → project CLAUDE.md
check_claude "Handover Script Types"
check_claude "verify-handover-ready.sh"

# Also check global CLAUDE.md for handover behavioral rules
GLOBAL_CLAUDE="${HOME}/.claude/CLAUDE.md"
if [ -f "$GLOBAL_CLAUDE" ]; then
  if grep -q "Handover Validation" "$GLOBAL_CLAUDE" 2>/dev/null; then
    pass "Global CLAUDE.md: 'Handover Validation' found"
  else
    fail "Global CLAUDE.md: 'Handover Validation' MISSING"
  fi
  if grep -q "entrance validation.*exit criteria" "$GLOBAL_CLAUDE" 2>/dev/null; then
    pass "Global CLAUDE.md: entrance/exit criteria reference found"
  else
    fail "Global CLAUDE.md: entrance/exit criteria reference MISSING"
  fi
else
  fail "Global CLAUDE.md not found at ${GLOBAL_CLAUDE}"
fi

# ========================================
# 5. Check Type 2 Enforcement (Agent Rejection)
# ========================================
echo ""
echo "5. Checking Type 2 Enforcement (Agent Rejection)..."

for agent in product-manager ux-ui-designer system-architect senior-backend-engineer senior-frontend-engineer qa-test-automation-engineer security-analyst; do
  if grep -q "Type 2.*Agent Rejection\|HANDOFF REJECTED\|Agent Rejection" "${AGENTS_DIR}/${agent}.md" 2>/dev/null; then
    pass "${agent}.md: Type 2 enforcement found"
  else
    warn "${agent}.md: Type 2 enforcement not found"
  fi
done

# ========================================
# 6. Check Feature ID Traceability
# ========================================
echo ""
echo "6. Checking Feature ID Traceability..."

FEATURE_ID_COUNT=$(grep -r "Feature ID\|FEAT-XXX" "${AGENTS_DIR}"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$FEATURE_ID_COUNT" -gt 50 ]; then
  pass "Feature ID references: ${FEATURE_ID_COUNT} occurrences"
else
  warn "Feature ID references: only ${FEATURE_ID_COUNT} (expected 50+)"
fi

# ========================================
# 7. Check Inline Reporting Pattern
# ========================================
echo ""
echo "7. Checking Inline Reporting Pattern..."

INLINE_COUNT=$(grep -ri "inline.*report\|NOT.*separate.*\.md\|Never create.*transient" "${AGENTS_DIR}"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$INLINE_COUNT" -gt 10 ]; then
  pass "Inline reporting patterns: ${INLINE_COUNT} occurrences"
else
  warn "Inline reporting patterns: only ${INLINE_COUNT} (expected 10+)"
fi

# ========================================
# Summary
# ========================================
echo ""
echo "========================================"
echo "  Validation Summary"
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}All checks passed!${NC}"
  echo "Errors: 0 | Warnings: 0"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}Passed with warnings${NC}"
  echo "Errors: ${ERRORS} | Warnings: ${WARNINGS}"
  exit 0
else
  echo -e "${RED}Validation failed${NC}"
  echo "Errors: ${ERRORS} | Warnings: ${WARNINGS}"
  exit 1
fi
