#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# scan-sensitive-terms.sh — Scan staged files against .toprig-secret-patterns
# Used by: pre-commit hook (${PROJECT_NAME}), future TopRig pre-commit + pre-push
# Exit 1 = CRITICAL match found (blocks commit)
# Exit 0 = clean
#
# Context-aware: In ${PROJECT_NAME}, only Category 3 (client/business) and Category 4
# (credentials) are CRITICAL. Categories 1-2 (project name, domain terms) are
# expected in ${PROJECT_NAME}'s own files and are skipped.
# In TopRig, ALL categories are enforced.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
PATTERNS_FILE="$REPO_ROOT/.toprig-secret-patterns"

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "⚠️  .toprig-secret-patterns not found — skipping sensitive term scan" >&2
  exit 0
fi

# Detect context: ${PROJECT_NAME} (private) vs TopRig (public)
REPO_NAME=$(basename "$REPO_ROOT")
if [[ "$REPO_NAME" == "${PROJECT_NAME}" ]]; then
  # In ${PROJECT_NAME}: only enforce Category 3 (client/business) and Category 4 (credentials)
  # Skip Category 1 (project name/paths) and Category 2 (product domain terms)
  SKIP_CATEGORIES="Category 1|Category 2"
else
  # In TopRig or any other repo: enforce ALL categories
  SKIP_CATEGORIES=""
fi

# Files to always skip (false positives)
SKIP_PATTERNS='\.toprig-secret-patterns$|package-lock\.json$|\.svg$|ios/Pods/|node_modules/|\.png$|\.jpg$|\.gif$|\.woff|\.ttf'

# Get staged files, filter out skipped patterns and deleted files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | grep -vE "$SKIP_PATTERNS" || true)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

FOUND_CRITICAL=0
FOUND_HIGH=0
CURRENT_CATEGORY=""

while IFS= read -r line; do
  # Track which category we're in
  if [[ "$line" =~ ^#.*Category ]]; then
    CURRENT_CATEGORY="$line"
    continue
  fi

  # Skip comments and empty lines
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

  # Skip categories not enforced in this repo
  if [ -n "$SKIP_CATEGORIES" ] && [ -n "$CURRENT_CATEGORY" ]; then
    if echo "$CURRENT_CATEGORY" | grep -qE "$SKIP_CATEGORIES"; then
      continue
    fi
  fi

  # Parse severity|pattern|description
  severity=$(echo "$line" | cut -d'|' -f1)
  pattern=$(echo "$line" | cut -d'|' -f2)
  description=$(echo "$line" | cut -d'|' -f3-)

  # Build grep pattern — use word boundary where pattern is purely alphabetic
  if [[ "$pattern" =~ ^[a-zA-Z]+$ ]]; then
    GREP_PATTERN="\b${pattern}\b"
  else
    GREP_PATTERN="$pattern"
  fi

  # Scan only NEW/CHANGED lines in staged content (added lines from diff)
  # This avoids flagging pre-existing content that's already committed
  MATCHES=""
  DIFF_ADDED=$(git diff --cached -U0 -- $STAGED_FILES 2>/dev/null | grep -E '^\+[^\+]' | sed 's/^\+//' || true)
  if [ -n "$DIFF_ADDED" ]; then
    FILE_MATCHES=$(echo "$DIFF_ADDED" | grep -inE "$GREP_PATTERN" 2>/dev/null || true)
    if [ -n "$FILE_MATCHES" ]; then
      MATCHES="$FILE_MATCHES"
    fi
  fi

  if [ -n "$MATCHES" ]; then
    if [ "$severity" = "CRITICAL" ]; then
      FOUND_CRITICAL=$((FOUND_CRITICAL + 1))
      echo "❌ CRITICAL: '$pattern' — $description" >&2
      echo -e "$MATCHES" | head -3 | sed 's/^/   /' >&2
    elif [ "$severity" = "HIGH" ]; then
      FOUND_HIGH=$((FOUND_HIGH + 1))
      echo "⚠️  HIGH: '$pattern' — $description" >&2
      echo -e "$MATCHES" | head -3 | sed 's/^/   /' >&2
    fi
  fi
done < "$PATTERNS_FILE"

if [ "$FOUND_CRITICAL" -gt 0 ]; then
  echo "" >&2
  echo "🛑 BLOCKED: $FOUND_CRITICAL CRITICAL + $FOUND_HIGH HIGH sensitive term(s) in staged files." >&2
  echo "   Review .toprig-secret-patterns for the full watchlist." >&2
  echo "   Override: git commit --no-verify (use with extreme caution)" >&2
  exit 1
fi

if [ "$FOUND_HIGH" -gt 0 ]; then
  echo "" >&2
  echo "⚠️  WARNING: $FOUND_HIGH HIGH sensitive term(s) in staged files. Proceeding." >&2
fi

exit 0
