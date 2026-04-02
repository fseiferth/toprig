#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# FEAT-012: Governance Observatory - Symmetry Scanner
# Detects enforcement asymmetries in universal rules

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

exec python3 scripts/validate-governance-symmetry.py "$@"
