#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# quality-gate-functions.sh - Unified validation functions for SDLC handovers
# Reference: SDLC-ROLE-MAPPING.md Quality Gate Engine (Lines 724-940)
# Reference: HANDOVER_PROTOCOLS.md Section 0.1
#
# Usage: Source this file in handover validation scripts
#   source "$(dirname "$0")/quality-gate-functions.sh"

# ============================================
# Color Codes
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# Output Functions
# ============================================
pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; return 1; }
warn() { echo -e "${YELLOW}⚠️  WARN${NC}: $1"; }
info() { echo "ℹ️  INFO: $1"; }

# ============================================
# Phase 1: Deliverable Exists Check
# ============================================
# Usage: validate_deliverable_exists "/path/to/file" "5K"
validate_deliverable_exists() {
  local file_path=$1
  local min_size=${2:-"0"}  # e.g., "10K" for 10KB, default 0

  if [ ! -f "$file_path" ]; then
    fail "File missing at $file_path"
    return 1
  fi

  # Convert min_size to bytes
  local min_bytes=0
  if [[ "$min_size" =~ ^[0-9]+K$ ]]; then
    min_bytes=$(echo "$min_size" | sed 's/K$/000/')
  elif [[ "$min_size" =~ ^[0-9]+$ ]]; then
    min_bytes="$min_size"
  fi

  # Get file size (macOS and Linux compatible)
  local file_size
  file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)

  if [ -z "$file_size" ]; then
    warn "Could not determine file size for $file_path"
    return 0
  fi

  if [ "$file_size" -lt "$min_bytes" ]; then
    fail "File too small: ${file_size} bytes (need >$min_size)"
    return 1
  fi

  pass "Deliverable exists: $file_path ($file_size bytes)"
  return 0
}

# ============================================
# Phase 2: Approval Gate Check
# ============================================
# Usage: validate_approval_gate "/path/to/file" "PM" 7
validate_approval_gate() {
  local file_path=$1
  local approver_role=$2
  local max_age_days=${3:-7}

  if [ ! -f "$file_path" ]; then
    fail "Cannot check approval - file missing: $file_path"
    return 1
  fi

  # Check for approval marker
  local approval_line
  approval_line=$(grep -E "(✅ Approved by $approver_role|status:.*approved|userApproval: true)" "$file_path" 2>/dev/null)

  if [ -z "$approval_line" ]; then
    fail "No approval marker from $approver_role in $file_path"
    return 1
  fi

  # Extract date and check freshness (optional)
  local approval_date
  approval_date=$(echo "$approval_line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

  if [ -n "$approval_date" ]; then
    local days_old
    days_old=$(( ($(date +%s) - $(date -j -f "%Y-%m-%d" "$approval_date" +%s 2>/dev/null || echo 0)) / 86400 ))

    if [ "$days_old" -gt "$max_age_days" ]; then
      warn "Approval is $days_old days old (>$max_age_days days)"
    else
      pass "Approval valid: $approver_role ($days_old days old)"
      return 0
    fi
  fi

  pass "Approval found from $approver_role"
  return 0
}

# ============================================
# Phase 3: Content Completeness Check
# ============================================
# Usage: validate_content_completeness "/path/to/file" "Section1" "Section2" ...
validate_content_completeness() {
  local file_path=$1
  shift
  local required_sections=("$@")

  if [ ! -f "$file_path" ]; then
    fail "Cannot check content - file missing: $file_path"
    return 1
  fi

  local missing=0
  for section in "${required_sections[@]}"; do
    if ! grep -qi "$section" "$file_path" 2>/dev/null; then
      fail "Missing required section: $section"
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -gt 0 ]; then
    return 1
  fi

  pass "All required sections present (${#required_sections[@]} sections)"
  return 0
}

# ============================================
# Phase 4: Prerequisites Check
# ============================================
# Usage: validate_prerequisites "Frontend" "Designer" "/path/to/design-spec"
validate_prerequisites() {
  local current_role=$1
  local prerequisite_role=$2
  local prerequisite_file=$3

  if [ -z "$prerequisite_file" ]; then
    pass "No prerequisites for $current_role (first in chain)"
    return 0
  fi

  if [ ! -f "$prerequisite_file" ]; then
    fail "Prerequisite missing from $prerequisite_role: $prerequisite_file"
    return 1
  fi

  pass "Prerequisites met: $prerequisite_role deliverable exists"
  return 0
}

# ============================================
# YAML Frontmatter Validation
# ============================================
# Usage: validate_yaml_frontmatter "/path/to/file" "featureId" "status" ...
validate_yaml_frontmatter() {
  local file_path=$1
  shift
  local required_fields=("$@")

  if [ ! -f "$file_path" ]; then
    fail "Cannot check frontmatter - file missing: $file_path"
    return 1
  fi

  # Check file starts with ---
  if ! head -1 "$file_path" | grep -q "^---"; then
    fail "YAML frontmatter missing (file must start with ---)"
    return 1
  fi

  local missing=0
  for field in "${required_fields[@]}"; do
    if ! grep -q "^${field}:" "$file_path" 2>/dev/null; then
      fail "Missing frontmatter field: $field"
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -gt 0 ]; then
    return 1
  fi

  pass "YAML frontmatter valid (${#required_fields[@]} fields)"
  return 0
}

# ============================================
# Feature ID Validation
# ============================================
# Usage: validate_feature_id "/path/to/file"
validate_feature_id() {
  local file_path=$1

  if [ ! -f "$file_path" ]; then
    fail "Cannot check Feature ID - file missing: $file_path"
    return 1
  fi

  # Check for Feature ID patterns
  if grep -qE "(featureId:|FEAT-[0-9]+|ENH-[0-9]+|BASELINE-|IDEA-[0-9]+)" "$file_path" 2>/dev/null; then
    local feature_id
    feature_id=$(grep -E "^featureId:" "$file_path" | head -1 | cut -d: -f2 | tr -d ' ')
    if [ -n "$feature_id" ]; then
      pass "Feature ID present: $feature_id"
    else
      pass "Feature ID reference found"
    fi
    return 0
  fi

  fail "No Feature ID found in $file_path"
  return 1
}

# ============================================
# Service Health Check
# ============================================
# Usage: validate_service_running "Backend" 8000
validate_service_running() {
  local service_name=$1
  local port=$2

  if lsof -i ":$port" > /dev/null 2>&1; then
    pass "$service_name running on port $port"
    return 0
  fi

  fail "$service_name not running on port $port"
  return 1
}

# Usage: validate_health_endpoint "http://localhost:8000/health"
validate_health_endpoint() {
  local url=$1
  local timeout=${2:-5}

  if curl -sf --max-time "$timeout" "$url" > /dev/null 2>&1; then
    pass "Health endpoint responding: $url"
    return 0
  fi

  fail "Health endpoint not responding: $url"
  return 1
}

# ============================================
# Directory Structure Check
# ============================================
# Usage: validate_directory_exists "/path/to/dir"
validate_directory_exists() {
  local dir_path=$1

  if [ -d "$dir_path" ]; then
    pass "Directory exists: $dir_path"
    return 0
  fi

  fail "Directory missing: $dir_path"
  return 1
}

# ============================================
# Summary Function
# ============================================
# Usage: validation_summary $errors $warnings "Handover Type"
validation_summary() {
  local errors=$1
  local warnings=$2
  local handover_type=$3

  echo ""
  echo "========================================"
  echo "  $handover_type - Validation Summary"
  echo "========================================"
  echo ""

  if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    echo "Errors: 0 | Warnings: 0"
    echo ""
    echo "✅ Handover APPROVED - Ready for next phase"
    return 0
  elif [ "$errors" -eq 0 ]; then
    echo -e "${YELLOW}Passed with warnings${NC}"
    echo "Errors: ${errors} | Warnings: ${warnings}"
    echo ""
    echo "✅ Handover APPROVED (with warnings)"
    return 0
  else
    echo -e "${RED}Validation FAILED${NC}"
    echo "Errors: ${errors} | Warnings: ${warnings}"
    echo ""
    echo "❌ HANDOFF REJECTED - Fix errors before proceeding"
    return 1
  fi
}

# Export functions for use in sourced scripts
export -f pass fail warn info
export -f validate_deliverable_exists validate_approval_gate
export -f validate_content_completeness validate_prerequisites
export -f validate_yaml_frontmatter validate_feature_id
export -f validate_service_running validate_health_endpoint
export -f validate_directory_exists validation_summary
