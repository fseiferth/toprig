#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# install-governance-hooks.sh — Reconstruct governance hooks from tracked templates
# ENH-011: For fresh clones or after bd hooks install overwrites custom hooks
#
# Usage: ./scripts/install-governance-hooks.sh
# Prerequisites: bd initialized (.beads/hooks/ exists), governance/hooks/ tracked in git

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
TEMPLATES="$REPO_ROOT/governance/hooks"
RUNTIME="$REPO_ROOT/.beads/hooks"
CONFIG="$REPO_ROOT/.beads/config.yaml"
HOOKS=(pre-commit.old commit-msg post-commit)

echo "=== Governance Hooks Installer ==="

# Step 1: Verify core.hooksPath
HOOKS_PATH=$(git config core.hooksPath 2>/dev/null || echo "")
if [ "$HOOKS_PATH" != ".beads/hooks" ]; then
    echo "ERROR: core.hooksPath is '$HOOKS_PATH', expected '.beads/hooks'"
    echo "Fix: git config core.hooksPath .beads/hooks"
    exit 1
fi

# Step 2: Verify .beads/hooks/ exists (bd must be initialized)
if [ ! -d "$RUNTIME" ]; then
    echo "ERROR: $RUNTIME does not exist. Initialize bd first:"
    echo "  bd init"
    exit 1
fi

# Step 3: Verify governance/hooks/ exists with all templates
MISSING=()
for hook in "${HOOKS[@]}"; do
    if [ ! -f "$TEMPLATES/$hook" ]; then
        MISSING+=("$hook")
    fi
done
if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: Missing template files in $TEMPLATES:"
    printf "  - %s\n" "${MISSING[@]}"
    echo "Ensure governance/hooks/ is checked out from git."
    exit 1
fi

# Step 4: Copy templates to runtime
for hook in "${HOOKS[@]}"; do
    cp "$TEMPLATES/$hook" "$RUNTIME/$hook"
done

# Step 5: Set executable
chmod +x "$RUNTIME/pre-commit.old" "$RUNTIME/commit-msg" "$RUNTIME/post-commit"

# Step 6: Check chain_strategy config
if ! grep -q "chain_strategy: before" "$CONFIG" 2>/dev/null; then
    echo ""
    echo "WARNING: chain_strategy: before NOT found in $CONFIG"
    echo "Without this, pre-commit.old will NOT be executed by bd."
    echo "Add to $CONFIG:"
    echo "  hooks:"
    echo "    chain_strategy: before"
    echo "    chain_timeout_ms: 10000"
    echo ""
fi

# Step 7: Summary
echo ""
echo "Installed governance hooks:"
for hook in "${HOOKS[@]}"; do
    SIZE=$(wc -c < "$RUNTIME/$hook" | tr -d ' ')
    PERM=$(ls -la "$RUNTIME/$hook" | awk '{print $1}')
    echo "  $PERM  ${SIZE}B  $RUNTIME/$hook"
done

echo ""
echo "Verified: templates match runtime (canonical source: governance/hooks/)"
echo "=== Done ==="
