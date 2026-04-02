#!/bin/bash
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test Email Validation Script
# Purpose: Validate that all test email accounts follow the standard format
# Format: ${project_name}700X[agent-name]@mailinator.com
# Reference: ENGINEERING_BEST_PRACTICES.md Section 13
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Test Email Format Validation ==="
echo ""

# Expected format
EXPECTED_FORMAT="${project_name}700X[agent-name]@mailinator.com"
echo "Expected format: ${EXPECTED_FORMAT}"
echo ""

# Search locations for test emails
SEARCH_PATHS=(
  "${project_name}-backend"
  "${project_name}-frontend"
  "features"
  "dev-diary"
  "governance-reports"
)

# Find all email addresses in codebase
echo "[1/4] Searching for email addresses in codebase..."
TEMP_FILE=$(mktemp)

for path in "${SEARCH_PATHS[@]}"; do
  if [ -d "$path" ]; then
    # Search for email patterns, excluding node_modules and .git
    grep -r -o -h -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "$path" \
      --exclude-dir=node_modules \
      --exclude-dir=.git \
      --exclude-dir=build \
      --exclude-dir=dist \
      --exclude="*.min.js" \
      2>/dev/null | sort -u >> "$TEMP_FILE" || true
  fi
done

# Filter for test-related emails (exclude production domains)
PRODUCTION_DOMAINS=(
  "@gmail.com"
  "@anthropic.com"
  "@${project_name}.app"
)

TEST_EMAILS=$(cat "$TEMP_FILE" | grep -E "${project_name}|test|qa|dev" || true)

# Count emails
TOTAL_FOUND=$(echo "$TEST_EMAILS" | grep -v "^$" | wc -l | xargs)
echo "Found ${TOTAL_FOUND} test email addresses"
echo ""

# Validate format
echo "[2/4] Validating email format compliance..."

COMPLIANT_COUNT=0
NON_COMPLIANT_COUNT=0
NON_COMPLIANT_EMAILS=()

while IFS= read -r email; do
  [ -z "$email" ] && continue

  # Check if email matches expected format
  if [[ "$email" =~ ^${project_name}700[0-9]+[a-z-]+@mailinator\.com$ ]]; then
    COMPLIANT_COUNT=$((COMPLIANT_COUNT + 1))
    echo -e "${GREEN}✅${NC} $email"
  else
    NON_COMPLIANT_COUNT=$((NON_COMPLIANT_COUNT + 1))
    NON_COMPLIANT_EMAILS+=("$email")
    echo -e "${RED}❌${NC} $email (non-compliant format)"
  fi
done <<< "$TEST_EMAILS"

echo ""

# Check domain compliance
echo "[3/4] Validating domain compliance..."

NON_MAILINATOR=$(echo "$TEST_EMAILS" | grep -v "@mailinator.com" | grep -v "^$" || true)
NON_MAILINATOR_COUNT=$(echo "$NON_MAILINATOR" | grep -v "^$" | wc -l | xargs)

if [ "$NON_MAILINATOR_COUNT" -gt 0 ]; then
  echo -e "${RED}❌ Found ${NON_MAILINATOR_COUNT} test emails NOT using mailinator.com:${NC}"
  echo "$NON_MAILINATOR"
else
  echo -e "${GREEN}✅ All test emails use mailinator.com domain${NC}"
fi

echo ""

# Summary
echo "[4/4] Validation Summary"
echo "───────────────────────────────────────"
echo "Total test emails found: ${TOTAL_FOUND}"
echo -e "Compliant emails: ${GREEN}${COMPLIANT_COUNT}${NC}"
echo -e "Non-compliant emails: ${RED}${NON_COMPLIANT_COUNT}${NC}"
echo ""

# Exit status
if [ "$NON_COMPLIANT_COUNT" -gt 0 ]; then
  echo -e "${RED}❌ VALIDATION FAILED${NC}"
  echo ""
  echo "Non-compliant emails found:"
  for email in "${NON_COMPLIANT_EMAILS[@]}"; do
    echo "  - $email"
  done
  echo ""
  echo "Required format: ${EXPECTED_FORMAT}"
  echo "  - ${project_name} = project identifier (constant)"
  echo "  - 700X = sequential counter (7001, 7002, 7003, etc.)"
  echo "  - [agent-name] = your agent MD file name"
  echo "  - @mailinator.com = email domain (constant)"
  echo ""
  echo "Examples:"
  echo "  ✅ ${project_name}7001qa-test-automation-engineer@mailinator.com"
  echo "  ✅ ${project_name}7002senior-backend-engineer@mailinator.com"
  echo "  ❌ test@gmail.com (wrong domain)"
  echo "  ❌ qa7001@mailinator.com (missing ${project_name} prefix)"
  echo ""
  echo "Reference: ENGINEERING_BEST_PRACTICES.md Section 13"
  exit 1
else
  if [ "$TOTAL_FOUND" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  WARNING: No test emails found in codebase${NC}"
    echo "This may be expected if no test users have been created yet."
    echo "If test users exist, ensure they are documented in QA reports."
    exit 0
  else
    echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
    echo "All test emails comply with standard format."
    exit 0
  fi
fi

# Cleanup
rm -f "$TEMP_FILE"
