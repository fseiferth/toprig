#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# FEAT-012: Governance coverage scanner (bash wrapper)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

exec python3 scripts/validate-governance-coverage.py "$@"
