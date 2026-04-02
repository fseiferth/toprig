#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# FEAT-012: Validate governance/manifest.yaml schema
set -euo pipefail

# Determine repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Call Python validation script
python3 scripts/validate-manifest-schema.py "$@"
