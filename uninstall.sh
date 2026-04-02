#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# TopRig uninstaller — removes files tracked in manifest
# Preserves user-modified files with warning

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
MANIFEST_FILE="$CLAUDE_HOME/.toprig-manifest.yml"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "❌ No TopRig manifest found at $MANIFEST_FILE" >&2
  echo "   TopRig may not be installed, or was installed manually." >&2
  exit 1
fi

REMOVED=0
PRESERVED=0

echo "Uninstalling TopRig..."

# Parse manifest and remove files
if command -v yq >/dev/null 2>&1; then
  FILE_COUNT=$(yq '.files | length' "$MANIFEST_FILE" 2>/dev/null || echo 0)
  for i in $(seq 0 $((FILE_COUNT - 1))); do
    path=$(yq ".files[$i].path" "$MANIFEST_FILE" 2>/dev/null)
    expected_sha=$(yq ".files[$i].sha256" "$MANIFEST_FILE" 2>/dev/null)

    if [ -f "$path" ]; then
      actual_sha=$(shasum -a 256 "$path" | cut -d' ' -f1)
      if [ "$actual_sha" = "$expected_sha" ]; then
        rm "$path"
        REMOVED=$((REMOVED + 1))
      else
        echo "⚠️  Preserved (modified): $path" >&2
        PRESERVED=$((PRESERVED + 1))
      fi
    fi
  done
else
  echo "⚠️  yq not available — removing all manifest files without checksum verification" >&2
  grep 'path:' "$MANIFEST_FILE" | sed 's/.*path: *"\(.*\)"/\1/' | while read -r path; do
    if [ -f "$path" ]; then
      rm "$path"
      REMOVED=$((REMOVED + 1))
    fi
  done
fi

# Remove empty skill directories
find "$CLAUDE_HOME/skills" -type d -empty -delete 2>/dev/null || true

# Remove manifest
rm "$MANIFEST_FILE"

echo ""
echo "═══════════════════════════════════════════════"
echo "✅ TopRig uninstalled: $REMOVED removed, $PRESERVED preserved"
if [ "$PRESERVED" -gt 0 ]; then
  echo "   Modified files were kept — remove manually if desired."
fi
echo "═══════════════════════════════════════════════"
