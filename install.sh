#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# TopRig installer — copies governance framework to ~/.claude/
#
# Usage:
#   ./install.sh                    # Standard install
#   ./install.sh --dev              # Symlink mode (for TopRig developers)
#   ./install.sh --version v0.1.0   # Install specific version
#   ./install.sh --strict           # Exit 1 on integrity mismatch
#
# What it does:
#   1. Checks prerequisites (git, bash, yq, gh, shellcheck, trufflehog)
#   2. Copies agents, skills, commands to ~/.claude/
#   3. Installs hooks
#   4. Creates .toprig-secret-patterns from .example
#   5. Records manifest for uninstall

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
MANIFEST_FILE="$CLAUDE_HOME/.toprig-manifest.yml"
VERSION=""
DEV_MODE=false
STRICT=false

# ── Parse arguments ───────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    --dev) DEV_MODE=true; shift ;;
    --strict) STRICT=true; shift ;;
    --help|-h)
      echo "Usage: ./install.sh [--dev] [--version TAG] [--strict]"
      echo "  --dev      Symlink instead of copy (for TopRig developers)"
      echo "  --version  Install specific git tag"
      echo "  --strict   Exit 1 on integrity mismatch (default: warn)"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Reject sudo ───────────────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
  echo "❌ Do not run install.sh with sudo." >&2
  exit 1
fi

# ── Reject mutually exclusive flags ──────────────────────────────────
if [ "$DEV_MODE" = true ] && [ -n "$VERSION" ]; then
  echo "❌ --dev and --version are mutually exclusive." >&2
  exit 1
fi

# ── Check prerequisites ──────────────────────────────────────────────
echo "Checking prerequisites..."
MISSING=0

check_tool() {
  local name="$1" install_hint="$2"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "❌ Missing: $name — $install_hint" >&2
    MISSING=$((MISSING + 1))
  fi
}

check_tool git "Install via your package manager"
check_tool gh "brew install gh (macOS) or see https://cli.github.com"
check_tool shellcheck "brew install shellcheck (macOS) or apt install shellcheck"
check_tool trufflehog "brew install trufflehog (macOS) or see https://github.com/trufflesecurity/trufflehog"

# Check yq (must be mikefarah version)
if command -v yq >/dev/null 2>&1; then
  if ! yq --version 2>&1 | grep -qi 'mikefarah'; then
    echo "❌ Wrong yq implementation. Need mikefarah/yq v4+." >&2
    echo "   Install: brew install yq (macOS) or see https://github.com/mikefarah/yq" >&2
    MISSING=$((MISSING + 1))
  fi
else
  echo "❌ Missing: yq — brew install yq (macOS)" >&2
  MISSING=$((MISSING + 1))
fi

# Check bash version
BASH_MAJOR=$(bash -c 'echo ${BASH_VERSINFO[0]}')
if [ "$BASH_MAJOR" -lt 3 ]; then
  echo "❌ bash 3.2+ required. Current: $(bash --version | head -1)" >&2
  MISSING=$((MISSING + 1))
elif [ "$BASH_MAJOR" -lt 4 ]; then
  echo "⚠️  bash $BASH_MAJOR detected. 4+ recommended: brew install bash" >&2
fi

if [ "$MISSING" -gt 0 ]; then
  echo "" >&2
  echo "🛑 $MISSING prerequisite(s) missing. Install them and re-run." >&2
  exit 1
fi
echo "✅ All prerequisites met"

# ── Version checkout ──────────────────────────────────────────────────
if [ -n "$VERSION" ]; then
  echo "Checking out version $VERSION..."
  git -C "$SCRIPT_DIR" checkout "$VERSION" 2>/dev/null || {
    echo "❌ Version $VERSION not found. Available versions:" >&2
    git -C "$SCRIPT_DIR" tag -l 'v*' | sort -V >&2
    exit 1
  }
fi

# ── Create directories ───────────────────────────────────────────────
mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills" "$CLAUDE_HOME/commands"

# ── Install function ─────────────────────────────────────────────────
INSTALLED=0
SKIPPED=0
MANIFEST_ENTRIES=""

install_file() {
  local src="$1" dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"
  mkdir -p "$dst_dir"

  if [ "$DEV_MODE" = true ]; then
    # Symlink mode
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      SKIPPED=$((SKIPPED + 1))
      return
    fi
    ln -sf "$src" "$dst"
  else
    # Copy mode with atomic write
    if [ -f "$dst" ] && diff -q "$src" "$dst" >/dev/null 2>&1; then
      SKIPPED=$((SKIPPED + 1))
      return
    fi
    local tmp="${dst}.toprig-tmp"
    cp "$src" "$tmp"
    mv "$tmp" "$dst"
  fi

  # Set permissions
  case "$dst" in
    *.sh) chmod 755 "$dst" ;;
    *) chmod 644 "$dst" ;;
  esac

  INSTALLED=$((INSTALLED + 1))
  local checksum
  checksum=$(shasum -a 256 "$dst" | cut -d' ' -f1)
  MANIFEST_ENTRIES="${MANIFEST_ENTRIES}  - path: \"$dst\"\n    sha256: \"$checksum\"\n"
}

# ── Install agents ───────────────────────────────────────────────────
echo "Installing agents..."
for f in "$SCRIPT_DIR"/agents/*.md; do
  [ -f "$f" ] || continue
  install_file "$f" "$CLAUDE_HOME/agents/$(basename "$f")"
done

# ── Install skills ───────────────────────────────────────────────────
echo "Installing skills..."
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  # Skip toprig-internal skills (release-gate, propagate)
  case "$skill_name" in
    toprig-release-gate|toprig-propagate) continue ;;
  esac
  find "$skill_dir" -type f | while read -r f; do
    rel="${f#$skill_dir}"
    install_file "$f" "$CLAUDE_HOME/skills/$skill_name/$rel"
  done
done

# ── Install commands ─────────────────────────────────────────────────
echo "Installing commands..."
for f in "$SCRIPT_DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  install_file "$f" "$CLAUDE_HOME/commands/$(basename "$f")"
done

# ── Install hooks ────────────────────────────────────────────────────
echo "Installing hooks..."
bash "$SCRIPT_DIR/hooks/install.sh" 2>/dev/null || true

# ── Create .toprig-secret-patterns ───────────────────────────────────
if [ -f "$SCRIPT_DIR/.toprig-secret-patterns.example" ]; then
  cp -n "$SCRIPT_DIR/.toprig-secret-patterns.example" "$SCRIPT_DIR/.toprig-secret-patterns" 2>/dev/null || true
fi

# ── Write manifest ───────────────────────────────────────────────────
{
  echo "# TopRig installation manifest"
  echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "version: \"${VERSION:-dev}\""
  echo "source_repo: \"$SCRIPT_DIR\""
  echo "dev_mode: $DEV_MODE"
  echo "files:"
  echo -e "$MANIFEST_ENTRIES"
} > "$MANIFEST_FILE"

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
echo "✅ TopRig installed: $INSTALLED new, $SKIPPED unchanged"
echo "   Manifest: $MANIFEST_FILE"
if [ "$DEV_MODE" = true ]; then
  echo "   Mode: dev (symlinks)"
else
  echo "   Mode: copy"
fi
echo "═══════════════════════════════════════════════"
echo ""
echo "Next: cd your-project && toprig init"
