#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# TopRig Release Gate — 4-layer security verification before any push
#
# Usage:
#   ./scripts/release-gate.sh [--dry-run]
#
# Layers:
#   0: Pattern file integrity (SHA256)
#   1: Custom pattern scan (CRITICAL/HIGH from .toprig-secret-patterns)
#   2: TruffleHog entropy scan
#   2.5: Encoded content scan (base64/hex decode + re-scan)
#   3: Semantic review placeholder (invoked by skill, not this script)
#   4: Human approval (interactive prompt)
#
# Exit codes:
#   0 = all layers passed + approved
#   1 = layer failed or approval denied

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
PATTERNS_FILE="$REPO_ROOT/.toprig-secret-patterns"
PATTERNS_EXAMPLE="$REPO_ROOT/.toprig-secret-patterns.example"
CHECKSUM_FILE="$REPO_ROOT/.toprig-secret-patterns.example.sha256"
APPROVED_FILE="$REPO_ROOT/.toprig-approved-shas"
APPROVAL_LOG="${HOME}/.toprig/approval-log.yml"
CURRENT_SHA=$(git rev-parse HEAD)
SHORT_SHA="${CURRENT_SHA:0:8}"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 DRY RUN — no approvals will be recorded"
  echo ""
fi

LAYER_FAILURES=0

echo "═══════════════════════════════════════════════"
echo "TOPRIG RELEASE GATE"
echo "═══════════════════════════════════════════════"
echo "SHA: $CURRENT_SHA"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo ""

# ── Layer 0: Pattern file integrity (SP1) ─────────────────────────────
echo "── Layer 0: Pattern file integrity ──"
if [ -f "$CHECKSUM_FILE" ] && [ -f "$PATTERNS_EXAMPLE" ]; then
  if (cd "$REPO_ROOT" && shasum -a 256 -c "$CHECKSUM_FILE" >/dev/null 2>&1); then
    echo "✅ PASS — .toprig-secret-patterns.example checksum verified"
  else
    echo "❌ FAIL — .toprig-secret-patterns.example integrity check failed"
    echo "   Regenerate: shasum -a 256 .toprig-secret-patterns.example > .toprig-secret-patterns.example.sha256"
    LAYER_FAILURES=$((LAYER_FAILURES + 1))
  fi
elif [ ! -f "$PATTERNS_EXAMPLE" ]; then
  echo "❌ FAIL — .toprig-secret-patterns.example not found"
  LAYER_FAILURES=$((LAYER_FAILURES + 1))
else
  echo "⚠️  No checksum file — skipping integrity check"
fi
echo ""

# ── Layer 1: Custom pattern scan ──────────────────────────────────────
echo "── Layer 1: Custom pattern scan ──"

# Use the consumer patterns file if available, fall back to .example
SCAN_PATTERNS="$PATTERNS_FILE"
if [ ! -f "$SCAN_PATTERNS" ]; then
  SCAN_PATTERNS="$PATTERNS_EXAMPLE"
fi

if [ ! -f "$SCAN_PATTERNS" ]; then
  echo "❌ FAIL — No pattern file found"
  LAYER_FAILURES=$((LAYER_FAILURES + 1))
else
  FOUND_CRITICAL=0
  FOUND_HIGH=0

  # Scan ALL tracked files (not just diff — this is a full gate)
  ALL_FILES=$(git ls-files | grep -vE '\.toprig-secret-patterns|LICENSE|NOTICE|\.sha256$|\.png$|\.ico$|\.woff' || true)

  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    severity=$(echo "$line" | cut -d'|' -f1)
    pattern=$(echo "$line" | cut -d'|' -f2)
    description=$(echo "$line" | cut -d'|' -f3-)

    if [ "$severity" = "CRITICAL" ] || [ "$severity" = "HIGH" ]; then
      for f in $ALL_FILES; do
        if [ -f "$REPO_ROOT/$f" ]; then
          MATCHES=$(grep -inE "$pattern" "$REPO_ROOT/$f" 2>/dev/null || true)
          if [ -n "$MATCHES" ]; then
            if [ "$severity" = "CRITICAL" ]; then
              FOUND_CRITICAL=$((FOUND_CRITICAL + 1))
              echo "❌ CRITICAL in $f: $description"
              echo "$MATCHES" | head -3 | sed 's/^/   /'
            else
              FOUND_HIGH=$((FOUND_HIGH + 1))
              echo "⚠️  HIGH in $f: $description"
              echo "$MATCHES" | head -3 | sed 's/^/   /'
            fi
          fi
        fi
      done
    fi
  done < "$SCAN_PATTERNS"

  if [ "$FOUND_CRITICAL" -gt 0 ] || [ "$FOUND_HIGH" -gt 0 ]; then
    echo "❌ FAIL — $FOUND_CRITICAL CRITICAL + $FOUND_HIGH HIGH finding(s)"
    LAYER_FAILURES=$((LAYER_FAILURES + 1))
  else
    echo "✅ PASS — 0 CRITICAL, 0 HIGH"
  fi
fi
echo ""

# ── Layer 2: TruffleHog entropy scan ─────────────────────────────────
echo "── Layer 2: TruffleHog entropy scan ──"
if command -v trufflehog >/dev/null 2>&1; then
  TRUFFLEHOG_OUTPUT=$(trufflehog filesystem "$REPO_ROOT" --fail --no-update 2>&1 || true)
  if echo "$TRUFFLEHOG_OUTPUT" | grep -q "found"; then
    echo "❌ FAIL — TruffleHog found high-entropy secrets"
    echo "$TRUFFLEHOG_OUTPUT" | head -20
    LAYER_FAILURES=$((LAYER_FAILURES + 1))
  else
    echo "✅ PASS — No high-entropy secrets found"
  fi
else
  echo "❌ FAIL — trufflehog not installed (required for release gate)"
  echo "   Install: brew install trufflehog"
  LAYER_FAILURES=$((LAYER_FAILURES + 1))
fi
echo ""

# ── Layer 2.5: Encoded content scan (SP5) ────────────────────────────
echo "── Layer 2.5: Encoded content scan ──"
ENCODED_FOUND=0

for f in $ALL_FILES; do
  if [ -f "$REPO_ROOT/$f" ]; then
    # Extract base64-like strings
    BASE64_STRINGS=$(grep -oE '[A-Za-z0-9+/=]{40,}' "$REPO_ROOT/$f" 2>/dev/null || true)
    if [ -n "$BASE64_STRINGS" ]; then
      CRITICAL_PATTERNS=$(grep '^CRITICAL' "$SCAN_PATTERNS" | cut -d'|' -f2)
      while IFS= read -r b64; do
        decoded=$(echo "$b64" | base64 -d 2>/dev/null || true)
        if [ -n "$decoded" ]; then
          for cp in $CRITICAL_PATTERNS; do
            if echo "$decoded" | grep -qE "$cp" 2>/dev/null; then
              echo "❌ CRITICAL in $f: Base64 decodes to match '$cp'"
              ENCODED_FOUND=$((ENCODED_FOUND + 1))
              break
            fi
          done
        fi
      done <<< "$BASE64_STRINGS"
    fi
  fi
done

if [ "$ENCODED_FOUND" -gt 0 ]; then
  echo "❌ FAIL — $ENCODED_FOUND encoded secret(s) found"
  LAYER_FAILURES=$((LAYER_FAILURES + 1))
else
  echo "✅ PASS — No encoded secrets found"
fi
echo ""

# ── Layer 3: Semantic review ──────────────────────────────────────────
echo "── Layer 3: Semantic review ──"
echo "ℹ️  Layer 3 (security analyst semantic review) is invoked by the"
echo "   toprig-release-gate SKILL, not this script. The skill dispatches"
echo "   the security analyst agent with the S1-S8 checklist."
echo "   Status: PENDING (requires skill invocation)"
echo ""

# ── Layer 4: Human approval ──────────────────────────────────────────
echo "═══════════════════════════════════════════════"

if [ "$LAYER_FAILURES" -gt 0 ]; then
  echo "🛑 GATE FAILED: $LAYER_FAILURES layer(s) reported failures."
  echo "Fix all issues and re-run."
  echo "═══════════════════════════════════════════════"
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "✅ DRY RUN COMPLETE — All automated layers passed."
  echo "   In a real run, Layer 3 (semantic review) and Layer 4"
  echo "   (human approval) would follow."
  echo "═══════════════════════════════════════════════"
  exit 0
fi

# Show staged changes summary
echo ""
echo "Staged changes (all tracked files):"
git log --oneline -5 | sed 's/^/  /'
echo ""
echo "Files in repo:"
git ls-files | wc -l | xargs printf "  %s files\n"
echo ""
echo "Automated layers: ✅ ALL PASS"
echo ""
echo "To approve this release, type exactly:"
echo "  APPROVE TOPRIG RELEASE $SHORT_SHA"
echo ""
echo "To reject: type REJECT or Ctrl+C"
echo "═══════════════════════════════════════════════"
echo ""

read -r RESPONSE

if [ "$RESPONSE" = "APPROVE TOPRIG RELEASE $SHORT_SHA" ]; then
  # Record approval
  mkdir -p "$(dirname "$APPROVAL_LOG")"
  {
    echo "- timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "  sha: $CURRENT_SHA"
    echo "  short_sha: $SHORT_SHA"
    echo "  branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "  layer_0: PASS"
    echo "  layer_1: PASS"
    echo "  layer_2: PASS"
    echo "  layer_2_5: PASS"
    echo "  layer_3: PENDING_SKILL"
    echo "  layer_4: APPROVED"
    echo "  approver: manual"
  } >> "$APPROVAL_LOG"

  # Add SHA to approved list
  echo "$CURRENT_SHA" >> "$APPROVED_FILE"

  echo ""
  echo "✅ APPROVED — SHA $SHORT_SHA added to .toprig-approved-shas"
  echo "   You may now: git push"
  echo "   Approval logged to: $APPROVAL_LOG"
else
  echo ""
  echo "❌ REJECTED — approval phrase did not match."
  echo "   Expected: APPROVE TOPRIG RELEASE $SHORT_SHA"
  exit 1
fi
