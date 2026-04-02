#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# TopRig hook installer — copies hooks to .git/hooks/ with executable permissions
# Idempotent: safe to run multiple times

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

if [ ! -d "$GIT_HOOKS_DIR" ]; then
  echo "❌ Not a git repository (no .git/hooks/ directory found)." >&2
  exit 1
fi

HOOKS=(pre-commit pre-push)
INSTALLED=0
SKIPPED=0

for hook in "${HOOKS[@]}"; do
  src="$SCRIPT_DIR/$hook"
  dst="$GIT_HOOKS_DIR/$hook"

  if [ ! -f "$src" ]; then
    echo "⚠️  Source hook not found: $src" >&2
    continue
  fi

  # Check if already installed and identical
  if [ -f "$dst" ] && diff -q "$src" "$dst" >/dev/null 2>&1; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Backup existing hook if different
  if [ -f "$dst" ]; then
    cp "$dst" "$dst.backup-$(date +%Y%m%d%H%M%S)"
    echo "   Backed up existing $hook hook" >&2
  fi

  cp "$src" "$dst"
  chmod 755 "$dst"
  INSTALLED=$((INSTALLED + 1))
  echo "✅ Installed: $hook" >&2
done

if [ "$INSTALLED" -eq 0 ] && [ "$SKIPPED" -gt 0 ]; then
  echo "✅ Hooks already up to date ($SKIPPED hooks)." >&2
else
  echo "✅ Done: $INSTALLED installed, $SKIPPED already current." >&2
fi

# Ensure .toprig-secret-patterns exists
PATTERNS_FILE="$REPO_ROOT/.toprig-secret-patterns"
PATTERNS_EXAMPLE="$REPO_ROOT/.toprig-secret-patterns.example"
if [ ! -f "$PATTERNS_FILE" ] && [ -f "$PATTERNS_EXAMPLE" ]; then
  cp -n "$PATTERNS_EXAMPLE" "$PATTERNS_FILE"
  echo "✅ Created .toprig-secret-patterns from .example template." >&2
fi
