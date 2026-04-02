#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# verify-handover-ready.sh - Unified Type 1 enforcement for all SDLC handovers
# Reference: HANDOVER_PROTOCOLS.md Section 0.1
# Reference: SDLC-ROLE-MAPPING.md Quality Gate Engine
#
# Usage: ./scripts/verify-handover-ready.sh <handover-type> [options]
#
# Handover Types:
#   pm-designer      - PM → Designer (PRD handoff)
#   designer-architect - Designer → Architect (design constraints)
#   designer-frontend - Designer → Frontend (design spec handoff)
#   architect-backend - Architect → Backend (architecture handoff)
#   architect-frontend - Architect → Frontend (architecture handoff)
#   architect-security - Architect → Security (security review)
#   backend-qa       - Backend → QA (backend testing)
#   frontend-qa      - Frontend → QA (frontend testing)
#   qa-pm           - QA → PM (test results)
#   security-devops  - Security → DevOps (security sign-off)
#   engineer-respect-spec - Engineer → Respect-the-Spec (spec compliance validation)
#
# Options:
#   --prd PATH       - Path to PRD file (for pm-designer)
#   --design PATH    - Path to design spec directory (for designer-*)
#   --feature FEAT-XXX - Feature ID (auto-detected if not provided)
#   --help           - Show this help message

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source shared functions
if [ -f "$SCRIPT_DIR/quality-gate-functions.sh" ]; then
  source "$SCRIPT_DIR/quality-gate-functions.sh"
else
  echo "❌ ERROR: quality-gate-functions.sh not found"
  exit 1
fi

# ============================================
# Configuration
# ============================================
ERRORS=0
WARNINGS=0

# ============================================
# Usage
# ============================================
show_usage() {
  echo "Usage: ./scripts/verify-handover-ready.sh <handover-type> [options]"
  echo ""
  echo "Handover Types:"
  echo "  pm-designer        - PM → Designer (PRD handoff)"
  echo "  designer-architect - Designer → Architect (design constraints)"
  echo "  designer-frontend  - Designer → Frontend (design spec handoff)"
  echo "  architect-backend  - Architect → Backend (architecture handoff)"
  echo "  architect-frontend - Architect → Frontend (architecture handoff)"
  echo "  architect-security - Architect → Security (security review)"
  echo "  backend-qa         - Backend → QA (backend testing)"
  echo "  frontend-qa        - Frontend → QA (frontend testing)"
  echo "  qa-pm              - QA → PM (test results)"
  echo "  security-devops    - Security → DevOps (security sign-off)"
  echo "  engineer-respect-spec - Engineer → Respect-the-Spec (spec compliance validation)"
  echo ""
  echo "Options:"
  echo "  --prd PATH         - Path to PRD file (for pm-designer)"
  echo "  --design PATH      - Path to design spec directory"
  echo "  --feature FEAT-XXX - Feature ID"
  echo "  --handoff PATH     - Path to handoff document"
  echo "  --help             - Show this help"
  echo ""
  echo "Examples:"
  echo "  ./scripts/verify-handover-ready.sh pm-designer --prd product-docs/BASELINE-MVP-v1.0.md"
  echo "  ./scripts/verify-handover-ready.sh backend-qa --feature ENH-001"
}

# ============================================
# Parse Arguments
# ============================================
HANDOVER_TYPE=""
PRD_PATH=""
DESIGN_PATH=""
FEATURE_ID=""
HANDOFF_PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --prd)
      PRD_PATH="$2"
      shift 2
      ;;
    --design)
      DESIGN_PATH="$2"
      shift 2
      ;;
    --feature)
      FEATURE_ID="$2"
      shift 2
      ;;
    --handoff)
      HANDOFF_PATH="$2"
      shift 2
      ;;
    --help)
      show_usage
      exit 0
      ;;
    *)
      if [ -z "$HANDOVER_TYPE" ]; then
        HANDOVER_TYPE="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$HANDOVER_TYPE" ]; then
  echo "❌ ERROR: No handover type specified"
  echo ""
  show_usage
  exit 1
fi

# ============================================
# Handover Validators
# ============================================

# PM → Designer
validate_pm_designer() {
  echo "========================================"
  echo "  PM → Designer Handoff Validation"
  echo "========================================"
  echo ""

  # Find PRD if not specified
  if [ -z "$PRD_PATH" ]; then
    PRD_PATH=$(find "$PROJECT_ROOT/product-docs" -name "*.md" -newer "$PROJECT_ROOT/product-docs" 2>/dev/null | head -1)
    if [ -z "$PRD_PATH" ]; then
      PRD_PATH="$PROJECT_ROOT/product-docs/BASELINE-MVP-v1.0.md"
    fi
    info "Auto-detected PRD: $PRD_PATH"
  fi

  echo "1. Checking PRD exists..."
  validate_deliverable_exists "$PRD_PATH" "5K" || ERRORS=$((ERRORS + 1))

  echo "2. Checking YAML frontmatter..."
  validate_yaml_frontmatter "$PRD_PATH" "featureId" || ERRORS=$((ERRORS + 1))

  echo "3. Checking userApproval..."
  if grep -q "^userApproval: true" "$PRD_PATH" 2>/dev/null; then
    pass "userApproval: true"
  else
    fail "userApproval must be 'true' in frontmatter"
    ERRORS=$((ERRORS + 1))
  fi

  echo "4. Checking Feature ID..."
  validate_feature_id "$PRD_PATH" || ERRORS=$((ERRORS + 1))

  echo "5. Checking User Stories section..."
  validate_content_completeness "$PRD_PATH" "User Stor" || ERRORS=$((ERRORS + 1))

  echo "6. Checking Acceptance Criteria..."
  validate_content_completeness "$PRD_PATH" "Acceptance Criteria" || ERRORS=$((ERRORS + 1))

  validation_summary $ERRORS $WARNINGS "PM → Designer"
}

# Designer → Architect
validate_designer_architect() {
  echo "========================================"
  echo "  Designer → Architect Handoff Validation"
  echo "========================================"
  echo ""

  # Find design spec if not specified
  if [ -z "$DESIGN_PATH" ]; then
    DESIGN_PATH=$(find "$PROJECT_ROOT/design-documentation/features" -type d -name "*" -not -name "features" 2>/dev/null | head -1)
    info "Auto-detected design path: $DESIGN_PATH"
  fi

  if [ -z "$DESIGN_PATH" ] || [ ! -d "$DESIGN_PATH" ]; then
    fail "Design directory not found: $DESIGN_PATH"
    ERRORS=$((ERRORS + 1))
    validation_summary $ERRORS $WARNINGS "Designer → Architect"
    return
  fi

  echo "1. Checking design spec directory..."
  validate_directory_exists "$DESIGN_PATH" || ERRORS=$((ERRORS + 1))

  echo "2. Checking README.md..."
  validate_deliverable_exists "$DESIGN_PATH/README.md" "3K" || ERRORS=$((ERRORS + 1))

  echo "3. Checking YAML frontmatter..."
  validate_yaml_frontmatter "$DESIGN_PATH/README.md" "featureId" "status" || ERRORS=$((ERRORS + 1))

  echo "4. Checking Feature ID..."
  validate_feature_id "$DESIGN_PATH/README.md" || ERRORS=$((ERRORS + 1))

  echo "5. Checking technical constraints section..."
  if grep -qiE "(technical|constraints|architecture|api)" "$DESIGN_PATH/README.md" 2>/dev/null; then
    pass "Technical constraints section found"
  else
    warn "Technical constraints section may be missing"
    WARNINGS=$((WARNINGS + 1))
  fi

  echo "6. Checking user journey (MANDATORY)..."
  if [ -f "$DESIGN_PATH/user-journey.md" ]; then
    pass "User journey document exists"
  else
    fail "User journey document missing (MANDATORY for Architect handoff)"
    ERRORS=$((ERRORS + 1))
  fi

  echo "7. Checking UX specification (6-pass analysis)..."
  # Check in feature directory first, then in ux-specifications/ by exact name and glob
  FEATURE_NAME=$(basename "$DESIGN_PATH")
  UX_SPEC_IN_FEATURE="$DESIGN_PATH/ux-spec.md"
  UX_SPEC_IN_DIR="$PROJECT_ROOT/design-documentation/ux-specifications/${FEATURE_NAME}-ux-spec.md"
  UX_SPEC_FOUND=""

  if [ -f "$UX_SPEC_IN_FEATURE" ]; then
    UX_SPEC_FOUND="$UX_SPEC_IN_FEATURE"
  elif [ -f "$UX_SPEC_IN_DIR" ]; then
    UX_SPEC_FOUND="$UX_SPEC_IN_DIR"
  else
    # Search ux-specifications/ for any file matching part of the feature name
    UX_SPEC_FOUND=$(find "$PROJECT_ROOT/design-documentation/ux-specifications" -name "*-ux-spec.md" 2>/dev/null | head -1)
    # More targeted: extract key words from feature name for matching
    for UX_FILE in "$PROJECT_ROOT"/design-documentation/ux-specifications/*-ux-spec.md; do
      [ -f "$UX_FILE" ] || continue
      UX_BASENAME=$(basename "$UX_FILE")
      # Check if the feature ID from YAML frontmatter matches
      if grep -qi "featureId.*${FEATURE_ID:-NOMATCH}" "$UX_FILE" 2>/dev/null; then
        UX_SPEC_FOUND="$UX_FILE"
        break
      fi
    done
  fi

  if [ -n "$UX_SPEC_FOUND" ] && [ -f "$UX_SPEC_FOUND" ]; then
    pass "UX specification found: $UX_SPEC_FOUND"
    # Validate all 6 passes present
    PASS_COUNT=0
    for PASS_NUM in 1 2 3 4 5 6; do
      if grep -qi "pass $PASS_NUM\|pass${PASS_NUM}" "$UX_SPEC_FOUND" 2>/dev/null; then
        PASS_COUNT=$((PASS_COUNT + 1))
      fi
    done
    if [ "$PASS_COUNT" -ge 6 ]; then
      pass "All 6 UX passes documented ($PASS_COUNT/6)"
    else
      fail "Only $PASS_COUNT/6 UX passes found (expected 6: mental model, IA, affordances, cognitive load, states, flow)"
      ERRORS=$((ERRORS + 1))
    fi
  else
    fail "No UX specification found. Run enterprise-ux-foundation or demo-ux-foundation skill before handoff."
    ERRORS=$((ERRORS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Designer → Architect"
}

# Designer → Frontend
validate_designer_frontend() {
  echo "========================================"
  echo "  Designer → Frontend Handoff Validation"
  echo "========================================"
  echo ""

  # Find design spec if not specified
  if [ -z "$DESIGN_PATH" ]; then
    DESIGN_PATH=$(find "$PROJECT_ROOT/design-documentation/features" -type d -name "*" -not -name "features" 2>/dev/null | head -1)
    info "Auto-detected design path: $DESIGN_PATH"
  fi

  if [ -z "$DESIGN_PATH" ] || [ ! -d "$DESIGN_PATH" ]; then
    fail "Design directory not found: $DESIGN_PATH"
    ERRORS=$((ERRORS + 1))
    validation_summary $ERRORS $WARNINGS "Designer → Frontend"
    return
  fi

  echo "1. Checking design spec directory..."
  validate_directory_exists "$DESIGN_PATH" || ERRORS=$((ERRORS + 1))

  echo "2. Checking README.md..."
  validate_deliverable_exists "$DESIGN_PATH/README.md" "5K" || ERRORS=$((ERRORS + 1))

  echo "3. Checking YAML frontmatter..."
  validate_yaml_frontmatter "$DESIGN_PATH/README.md" "featureId" "status" "version" || ERRORS=$((ERRORS + 1))

  echo "4. Checking approval status..."
  if grep -q "status:.*approved" "$DESIGN_PATH/README.md" 2>/dev/null || \
     grep -q "✅ Approved" "$DESIGN_PATH/README.md" 2>/dev/null; then
    pass "Design approved"
  else
    fail "Design not approved (status must be 'approved')"
    ERRORS=$((ERRORS + 1))
  fi

  echo "5. Checking Feature ID..."
  validate_feature_id "$DESIGN_PATH/README.md" || ERRORS=$((ERRORS + 1))

  echo "6. Checking user journey (MANDATORY)..."
  if [ -f "$DESIGN_PATH/user-journey.md" ]; then
    pass "User journey document exists"
  else
    fail "User journey document missing (MANDATORY for Frontend handoff)"
    ERRORS=$((ERRORS + 1))
  fi

  echo "7. Checking component specifications..."
  validate_content_completeness "$DESIGN_PATH/README.md" "Component" || WARNINGS=$((WARNINGS + 1))

  echo "8. Checking UX specification (6-pass analysis)..."
  FEATURE_NAME=$(basename "$DESIGN_PATH")
  UX_SPEC_IN_FEATURE="$DESIGN_PATH/ux-spec.md"
  UX_SPEC_IN_DIR="$PROJECT_ROOT/design-documentation/ux-specifications/${FEATURE_NAME}-ux-spec.md"
  UX_SPEC_FOUND=""

  if [ -f "$UX_SPEC_IN_FEATURE" ]; then
    UX_SPEC_FOUND="$UX_SPEC_IN_FEATURE"
  elif [ -f "$UX_SPEC_IN_DIR" ]; then
    UX_SPEC_FOUND="$UX_SPEC_IN_DIR"
  else
    for UX_FILE in "$PROJECT_ROOT"/design-documentation/ux-specifications/*-ux-spec.md; do
      [ -f "$UX_FILE" ] || continue
      if grep -qi "featureId.*${FEATURE_ID:-NOMATCH}" "$UX_FILE" 2>/dev/null; then
        UX_SPEC_FOUND="$UX_FILE"
        break
      fi
    done
  fi

  if [ -n "$UX_SPEC_FOUND" ] && [ -f "$UX_SPEC_FOUND" ]; then
    pass "UX specification found: $UX_SPEC_FOUND"
    PASS_COUNT=0
    for PASS_NUM in 1 2 3 4 5 6; do
      if grep -qi "pass $PASS_NUM\|pass${PASS_NUM}" "$UX_SPEC_FOUND" 2>/dev/null; then
        PASS_COUNT=$((PASS_COUNT + 1))
      fi
    done
    if [ "$PASS_COUNT" -ge 6 ]; then
      pass "All 6 UX passes documented ($PASS_COUNT/6)"
    else
      fail "Only $PASS_COUNT/6 UX passes found (expected 6: mental model, IA, affordances, cognitive load, states, flow)"
      ERRORS=$((ERRORS + 1))
    fi
  else
    fail "No UX specification found. Run enterprise-ux-foundation or demo-ux-foundation skill before handoff."
    ERRORS=$((ERRORS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Designer → Frontend"
}

# Architect → Backend
validate_architect_backend() {
  echo "========================================"
  echo "  Architect → Backend Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking architecture docs exist..."
  validate_directory_exists "$PROJECT_ROOT/architecture" || ERRORS=$((ERRORS + 1))

  echo "2. Checking API contracts..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/02-api-contracts.md" "5K" || ERRORS=$((ERRORS + 1))

  echo "3. Checking database schema..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/03-database-schema.md" "3K" || ERRORS=$((ERRORS + 1))

  echo "4. Checking tech stack decisions..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/00-tech-stack-decisions.md" "2K" || ERRORS=$((ERRORS + 1))

  echo "5. Checking Feature ID inline comments..."
  # Search for Feature ID inline comments (<!-- FEAT-XXX --> format)
  if grep -qrE "<!-- (FEAT-[0-9]+|ENH-[0-9]+|BASELINE-[A-Za-z0-9.-]+) -->" "$PROJECT_ROOT/architecture/" 2>/dev/null; then
    feature_id=$(grep -rhoE "<!-- (FEAT-[0-9]+|ENH-[0-9]+|BASELINE-[A-Za-z0-9.-]+) -->" "$PROJECT_ROOT/architecture/" 2>/dev/null | head -1 | sed 's/<!-- //; s/ -->//')
    pass "Feature ID inline comments found: $feature_id"
  else
    fail "No Feature ID inline comments found in architecture docs (required format: <!-- FEAT-XXX -->)"
    ERRORS=$((ERRORS + 1))
  fi

  # Also check specific Feature ID if provided
  if [ -n "$FEATURE_ID" ]; then
    if grep -qr "$FEATURE_ID" "$PROJECT_ROOT/architecture/" 2>/dev/null; then
      pass "Specific Feature ID $FEATURE_ID found in architecture docs"
    else
      warn "Feature ID $FEATURE_ID not explicitly referenced in architecture"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

  validation_summary $ERRORS $WARNINGS "Architect → Backend"
}

# Architect → Frontend
validate_architect_frontend() {
  echo "========================================"
  echo "  Architect → Frontend Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking architecture docs exist..."
  validate_directory_exists "$PROJECT_ROOT/architecture" || ERRORS=$((ERRORS + 1))

  echo "2. Checking API contracts (frontend needs endpoints)..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/02-api-contracts.md" "5K" || ERRORS=$((ERRORS + 1))

  echo "3. Checking frontend architecture..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/05-frontend-architecture.md" "3K" || ERRORS=$((ERRORS + 1))

  echo "4. Checking Feature ID inline comments..."
  # Search for Feature ID inline comments (<!-- FEAT-XXX --> format)
  if grep -qrE "<!-- (FEAT-[0-9]+|ENH-[0-9]+|BASELINE-[A-Za-z0-9.-]+) -->" "$PROJECT_ROOT/architecture/" 2>/dev/null; then
    feature_id=$(grep -rhoE "<!-- (FEAT-[0-9]+|ENH-[0-9]+|BASELINE-[A-Za-z0-9.-]+) -->" "$PROJECT_ROOT/architecture/" 2>/dev/null | head -1 | sed 's/<!-- //; s/ -->//')
    pass "Feature ID inline comments found: $feature_id"
  else
    fail "No Feature ID inline comments found in architecture docs (required format: <!-- FEAT-XXX -->)"
    ERRORS=$((ERRORS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Architect → Frontend"
}

# Architect → Security
validate_architect_security() {
  echo "========================================"
  echo "  Architect → Security Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking architecture docs exist..."
  validate_directory_exists "$PROJECT_ROOT/architecture" || ERRORS=$((ERRORS + 1))

  echo "2. Checking API contracts (security review)..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/02-api-contracts.md" "5K" || ERRORS=$((ERRORS + 1))

  echo "3. Checking database schema (RLS policies)..."
  validate_deliverable_exists "$PROJECT_ROOT/architecture/03-database-schema.md" "3K" || ERRORS=$((ERRORS + 1))

  echo "4. Checking authentication documentation..."
  if grep -qri "authentication\|authorization\|RLS\|security" "$PROJECT_ROOT/architecture/" 2>/dev/null; then
    pass "Security-related documentation found"
  else
    warn "Limited security documentation in architecture"
    WARNINGS=$((WARNINGS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Architect → Security"
}

# Backend → QA
validate_backend_qa() {
  echo "========================================"
  echo "  Backend → QA Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking backend server (port 8000)..."
  validate_service_running "Backend" 8000 || ERRORS=$((ERRORS + 1))

  echo "2. Checking Redis (port 6379)..."
  validate_service_running "Redis" 6379 || ERRORS=$((ERRORS + 1))

  echo "3. Checking health endpoint..."
  validate_health_endpoint "http://localhost:8000/health" || ERRORS=$((ERRORS + 1))

  echo "4. Checking QA handoff document..."
  local handoff_doc="${HANDOFF_PATH:-$PROJECT_ROOT/docs/handoffs/QA_HANDOFF.md}"
  if [ -f "$handoff_doc" ]; then
    pass "QA handoff document exists: $handoff_doc"
  elif [ -f "$PROJECT_ROOT/docs/handoffs/QA_HANDOFF_BACKEND.md" ]; then
    pass "QA handoff document exists: QA_HANDOFF_BACKEND.md"
    handoff_doc="$PROJECT_ROOT/docs/handoffs/QA_HANDOFF_BACKEND.md"
  else
    fail "QA handoff document not found"
    ERRORS=$((ERRORS + 1))
    validation_summary $ERRORS $WARNINGS "Backend → QA"
    return
  fi

  echo "5. Checking Feature ID in handoff..."
  validate_feature_id "$handoff_doc" || ERRORS=$((ERRORS + 1))

  echo "6. Checking database connection (optional)..."
  if curl -sf http://localhost:8000/health | grep -qi "database\|db" 2>/dev/null; then
    pass "Database connection verified"
  else
    warn "Could not verify database connection"
    WARNINGS=$((WARNINGS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Backend → QA"
}

# Frontend → QA
validate_frontend_qa() {
  echo "========================================"
  echo "  Frontend → QA Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking QA handoff document..."
  local handoff_doc="${HANDOFF_PATH:-$PROJECT_ROOT/docs/handoffs/QA_HANDOFF_FRONTEND.md}"
  if [ -f "$handoff_doc" ]; then
    pass "QA handoff document exists"
  else
    fail "QA handoff document not found: $handoff_doc"
    ERRORS=$((ERRORS + 1))
  fi

  echo "2. Checking Feature ID..."
  if [ -f "$handoff_doc" ]; then
    validate_feature_id "$handoff_doc" || ERRORS=$((ERRORS + 1))
  fi

  echo "3. Checking specification verification matrix..."
  if [ -f "$handoff_doc" ] && grep -qi "specification\|matrix\|verification" "$handoff_doc" 2>/dev/null; then
    pass "Specification verification section found"
  else
    warn "Specification verification matrix may be incomplete"
    WARNINGS=$((WARNINGS + 1))
  fi

  echo "4. Checking backend accessibility..."
  validate_health_endpoint "http://localhost:8000/health" || WARNINGS=$((WARNINGS + 1))

  validation_summary $ERRORS $WARNINGS "Frontend → QA"
}

# QA → PM
validate_qa_pm() {
  echo "========================================"
  echo "  QA → PM Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking test results document..."
  local results_file=""
  if [ -n "$FEATURE_ID" ]; then
    results_file=$(find "$PROJECT_ROOT" -name "QA_TEST_RESULTS_*${FEATURE_ID}*.md" 2>/dev/null | head -1)
  fi
  if [ -z "$results_file" ]; then
    results_file=$(find "$PROJECT_ROOT" -name "QA_TEST_RESULTS_*.md" -newer "$PROJECT_ROOT" 2>/dev/null | head -1)
  fi

  if [ -n "$results_file" ] && [ -f "$results_file" ]; then
    pass "Test results document exists: $results_file"
  else
    fail "Test results document not found"
    ERRORS=$((ERRORS + 1))
    validation_summary $ERRORS $WARNINGS "QA → PM"
    return
  fi

  echo "2. Checking Feature ID..."
  validate_feature_id "$results_file" || ERRORS=$((ERRORS + 1))

  echo "3. Checking test status..."
  if grep -qiE "(pass|fail|blocked)" "$results_file" 2>/dev/null; then
    pass "Test status documented"
  else
    warn "Test status may be unclear"
    WARNINGS=$((WARNINGS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "QA → PM"
}

# Security → DevOps
validate_security_devops() {
  echo "========================================"
  echo "  Security → DevOps Handoff Validation"
  echo "========================================"
  echo ""

  echo "1. Checking security review document..."
  local security_doc=$(find "$PROJECT_ROOT" -name "*SECURITY*REVIEW*.md" -o -name "*security*sign*.md" 2>/dev/null | head -1)

  if [ -n "$security_doc" ] && [ -f "$security_doc" ]; then
    pass "Security review document exists"
  else
    warn "Security review document not found"
    WARNINGS=$((WARNINGS + 1))
  fi

  echo "2. Checking for critical vulnerabilities..."
  if [ -n "$security_doc" ] && grep -qi "critical.*0\|no critical" "$security_doc" 2>/dev/null; then
    pass "No critical vulnerabilities"
  else
    warn "Critical vulnerability status unclear"
    WARNINGS=$((WARNINGS + 1))
  fi

  echo "3. Checking security sign-off..."
  if [ -n "$security_doc" ] && grep -qi "sign.off\|approved\|✅" "$security_doc" 2>/dev/null; then
    pass "Security sign-off found"
  else
    warn "Explicit security sign-off not found"
    WARNINGS=$((WARNINGS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Security → DevOps"
}

# Engineer → Respect-the-Spec
validate_engineer_respect_spec() {
  echo "========================================"
  echo "  Engineer → Respect-the-Spec Validation"
  echo "========================================"
  echo ""

  # 1. At least one spec document exists to validate against
  echo "1. Checking specification documents exist..."
  local spec_count=0
  [ -d "$PROJECT_ROOT/product-docs" ] && spec_count=$((spec_count + $(find "$PROJECT_ROOT/product-docs" -name "*.md" 2>/dev/null | wc -l)))
  [ -d "$PROJECT_ROOT/architecture" ] && spec_count=$((spec_count + $(find "$PROJECT_ROOT/architecture" -name "*.md" 2>/dev/null | wc -l)))
  [ -d "$PROJECT_ROOT/design-documentation" ] && spec_count=$((spec_count + $(find "$PROJECT_ROOT/design-documentation" -name "*.md" 2>/dev/null | wc -l)))
  if [ "$spec_count" -gt 0 ]; then
    pass "Found $spec_count specification documents"
  else
    fail "No specification documents found in product-docs/, architecture/, or design-documentation/"
    ERRORS=$((ERRORS + 1))
  fi

  # 2. Implementation code exists (something to validate)
  echo "2. Checking implementation code exists..."
  local has_backend=false
  local has_frontend=false
  [ -d "$PROJECT_ROOT/${project_name}-backend/app" ] && has_backend=true
  [ -d "$PROJECT_ROOT/${project_name}-frontend/app" ] && has_frontend=true
  if [ "$has_backend" = true ] || [ "$has_frontend" = true ]; then
    pass "Implementation code found (backend=$has_backend, frontend=$has_frontend)"
  else
    fail "No implementation code found in ${project_name}-backend/app/ or ${project_name}-frontend/app/"
    ERRORS=$((ERRORS + 1))
  fi

  # 3. Feature ID traceable (if --feature provided)
  echo "3. Checking Feature ID traceability..."
  if [ -n "$FEATURE_ID" ]; then
    local feat_in_specs=false
    local feat_in_code=false
    grep -qr "$FEATURE_ID" "$PROJECT_ROOT/product-docs/" 2>/dev/null && feat_in_specs=true
    grep -qr "$FEATURE_ID" "$PROJECT_ROOT/${project_name}-backend/" "$PROJECT_ROOT/${project_name}-frontend/" 2>/dev/null && feat_in_code=true
    if [ "$feat_in_specs" = true ] && [ "$feat_in_code" = true ]; then
      pass "Feature ID $FEATURE_ID found in both specs and code"
    elif [ "$feat_in_specs" = true ]; then
      warn "Feature ID $FEATURE_ID found in specs but not in code"
      WARNINGS=$((WARNINGS + 1))
    else
      fail "Feature ID $FEATURE_ID not found in specification documents"
      ERRORS=$((ERRORS + 1))
    fi
  else
    info "No --feature specified, skipping Feature ID traceability check"
  fi

  # 4. No uncommitted changes that could skew validation
  echo "4. Checking git working tree clean..."
  if [ -z "$(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null)" ]; then
    pass "Working tree clean - validation will reflect committed state"
  else
    warn "Uncommitted changes exist - validation may not reflect final state"
    WARNINGS=$((WARNINGS + 1))
  fi

  validation_summary $ERRORS $WARNINGS "Engineer → Respect-the-Spec"
}

# ============================================
# Main Router
# ============================================
case "$HANDOVER_TYPE" in
  pm-designer)
    validate_pm_designer
    ;;
  designer-architect)
    validate_designer_architect
    ;;
  designer-frontend)
    validate_designer_frontend
    ;;
  architect-backend)
    validate_architect_backend
    ;;
  architect-frontend)
    validate_architect_frontend
    ;;
  architect-security)
    validate_architect_security
    ;;
  backend-qa)
    validate_backend_qa
    ;;
  frontend-qa)
    validate_frontend_qa
    ;;
  qa-pm)
    validate_qa_pm
    ;;
  security-devops)
    validate_security_devops
    ;;
  engineer-respect-spec)
    validate_engineer_respect_spec
    ;;
  *)
    echo "❌ ERROR: Unknown handover type: $HANDOVER_TYPE"
    echo ""
    show_usage
    exit 1
    ;;
esac

# Return exit code based on errors
if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
exit 0
